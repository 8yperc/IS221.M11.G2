set serveroutput on size 30000

--procedure--
CREATE OR REPLACE PROCEDURE PROC_KHACHHANG(makh_in IN KHACHHANG.MaKH%TYPE)
IS
    var_soluong number;
    var_tenkh KHACHHANG.TenKH%TYPE;
    var_tichluy KHACHHANG.TienTichLuy%TYPE;

BEGIN
    SELECT KHACHHANG.TENKH, KHACHHANG.tientichluy INTO var_tenkh, var_tichluy
    FROM KHACHHANG
    WHERE MAKH=makh_in;
    
    SELECT COUNT(*) INTO var_soluong
    FROM DATPHONG
    WHERE MAKH=makh_in AND TRANGTHAIDAT='Dat thanh cong'
    GROUP BY MAKH;
    
    DBMS_OUTPUT.PUT_LINE('THONG TIN CUA KHACH HANG '||var_tenkh);
    DBMS_OUTPUT.PUT_LINE('SO TIEN TICH LUY: '||var_tichluy);
    DBMS_OUTPUT.PUT_LINE('SO PHONG DA DAT: '||var_soluong);
    
    FOR rec IN (SELECT MAPHONG, THOIDIEMDAT, SOGIO 
        FROM DATPHONG
        WHERE DATPHONG.MAKH = makh_in
        AND TRANGTHAIDAT='Dat thanh cong'
        )
    LOOP
    DBMS_OUTPUT.PUT_LINE ('---------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('MA PHONG: '|| rec.MAPHONG);
    DBMS_OUTPUT.PUT_LINE('THOI DIEM DAT PHONG: '|| rec.THOIDIEMDAT);
    DBMS_OUTPUT.PUT_LINE('SO GIO DAT: '|| rec.SOGIO);
    END LOOP;

END;

BEGIN
    proc_khachhang('KH01');
END;

--function--
CREATE OR REPLACE FUNCTION func_tinhtien(datphong_in IN DATPHONG.MADATPHONG%TYPE)
RETURN NUMBER
as
tongtien number;
tienDV NUMBER;
tienphong NUMBER;
BEGIN   
    SELECT SUM(DV.DONGIA*CT.SOLUONG) INTO tienDV
    FROM CHITIETDICHVU CT, DICHVU DV
    WHERE CT.MADV = DV.MADV AND CT.MADATPHONG = datphong_in
    GROUP BY CT.MADATPHONG;
    SELECT DP.SoGio*P.GiaPhong INTO tienphong
    FROM DATPHONG DP, PHONG P
    WHERE DP.MAPHONG=P.MAPHONG AND DP.MADATPHONG = datphong_in AND dp.trangthaidat='Dat thanh cong';
    tongtien := tienDV + tienphong;
    RETURN tongtien;
    exception
when no_data_found
then
return('Du lieu khong tim thay');
when others then
return('loi ham');

END;

DECLARE THANHTOAN NUMBER;
BEGIN
    THANHTOAN:= func_tinhtien('DP01');
    DBMS_OUTPUT.PUT_LINE('Tong tien thu: '||THANHTOAN );
END;

--trigger--
CREATE OR REPLACE TRIGGER TR_DATPHONG
AFTER INSERT OR UPDATE
ON DATPHONG 
FOR EACH ROW
DECLARE 
trangthai datphong.trangthaidat%TYPE;
sogio datphong.sogio%TYPE;
BEGIN
    IF (trangthai<>'Dat thanh cong' and sogio<>null) THEN
        RAISE_APPLICATION_ERROR(-20020, 'KHONG HOP LE');
    END IF;
END;