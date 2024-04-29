--------------------------------------------------------
--  DDL for Package Body FA_LEASE_PITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_LEASE_PITEMS_PKG" AS
/* $Header: FAXLPIEB.pls 120.2.12010000.2 2009/07/19 14:15:18 glchen ship $ */

/* This is a wrapper procedure for inserting a row into table
   FA_LEASE_PAYMENT_ITEMS.*/
PROCEDURE  Insert_Row(

    X_Lease_ID			IN	NUMBER,
    X_Payment_Schedule_ID	IN	NUMBER,
    X_Schedule_Amort_Line_Num	IN	NUMBER,
    X_Export_Status		IN	VARCHAR2,
    X_Lessor_ID			IN	NUMBER,
    X_Lessor_Site_ID		IN	NUMBER,
    X_Dist_Code_Combination_ID	IN	NUMBER,
    X_Invoice_Number            IN      VARCHAR2,
    X_Invoice_ID		IN	NUMBER,
    X_Invoice_Line_ID		IN	NUMBER,
    X_Terms_ID	                IN	NUMBER,
    X_Last_Updated_by		IN	NUMBER,
    X_Last_Update_Date		IN	DATE,
    X_Last_Update_Login		IN	NUMBER,
    X_Created_by		IN	NUMBER,
    X_Creation_Date		IN	DATE,
    X_Request_ID		IN	NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

    INSERT INTO FA_Lease_Payment_Items(

	Lease_ID,
	Payment_Schedule_ID,
	Schedule_Amort_Line_Num,
	Export_Status,
	Lessor_ID,
	Lessor_Site_ID,
	Dist_Code_Combination_ID,
        Invoice_Number,
	Invoice_ID,
	Invoice_Line_ID,
        Terms_ID,
	Last_Updated_by,
	Last_Update_Date,
	Last_Update_Login,
	Created_by,
	Creation_Date,
	Request_ID)

    VALUES (

	X_Lease_ID,
	X_Payment_Schedule_ID,
	X_Schedule_Amort_Line_Num,
	X_Export_Status,
	X_Lessor_ID,
	X_Lessor_Site_ID,
	X_Dist_Code_Combination_ID,
        X_Invoice_Number,
	X_Invoice_ID,
	X_Invoice_Line_ID,
        X_Terms_ID,
	X_Last_Updated_by,
	X_Last_Update_Date,
	X_Last_Update_Login,
	X_Created_by,
	X_Creation_Date,
	X_Request_ID);

EXCEPTION

    WHEN others THEN

        FA_SRVR_MSG.ADD_MESSAGE(

               CALLING_FN => 'FA_LEASE_PITEMS_PKG.Insert_Row',  p_log_level_rec => p_log_level_rec);

END Insert_Row;

/* This is a wrapper procedure for updating a row of table
   FA_LEASE_PAYMENT_ITEMS.*/
PROCEDURE  Update_Row(

    X_Rowid			IN	VARCHAR2,
    X_Lease_ID			IN	NUMBER,
    X_Payment_Schedule_ID	IN	NUMBER,
    X_Schedule_Amort_Line_Num	IN	NUMBER,
    X_Export_Status		IN	VARCHAR2,
    X_Lessor_ID			IN	NUMBER,
    X_Lessor_Site_ID		IN	NUMBER,
    X_Dist_Code_Combination_ID	IN	NUMBER,
    X_Invoice_Number            IN      VARCHAR2,
    X_Invoice_ID		IN	NUMBER,
    X_Invoice_Line_ID		IN	NUMBER,
    X_Terms_ID	                IN	NUMBER,
    X_Last_Updated_by		IN	NUMBER,
    X_Last_Update_Date		IN	DATE,
    X_Last_Update_Login		IN	NUMBER,
    X_Created_by		IN	NUMBER,
    X_Creation_Date		IN	DATE,
    X_Request_ID		IN	NUMBER   :=   NULL , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

BEGIN

    UPDATE FA_Lease_Payment_Items SET

	Lease_ID		= X_Lease_ID,
	Payment_Schedule_ID	= X_Payment_Schedule_ID,
	Schedule_Amort_Line_Num	= X_Schedule_Amort_Line_Num,
	Export_Status		= X_Export_Status,
	Lessor_ID		= X_Lessor_ID,
	Lessor_Site_ID		= X_Lessor_Site_ID,
	Dist_Code_Combination_ID= X_Dist_Code_Combination_ID,
        Invoice_Number		= X_Invoice_Number,
	Invoice_ID		= X_Invoice_ID,
	Invoice_Line_ID		= X_Invoice_Line_ID,
        Terms_ID                = X_Terms_ID,
	Last_Updated_by		= X_Last_Updated_by,
	Last_Update_Date	= X_Last_Update_Date,
	Last_Update_Login	= X_Last_Update_Login,
	Created_by		= X_Created_by,
	Creation_Date		= X_Creation_Date,
	Request_ID		= X_Request_ID

    WHERE Rowid = X_Rowid;

EXCEPTION

    WHEN others THEN

        FA_SRVR_MSG.ADD_MESSAGE(

               CALLING_FN => 'FA_LEASE_PITEMS_PKG.Update_Row',  p_log_level_rec => p_log_level_rec);

END Update_Row;

/* Procedure Lock_Rows() locks all rows in FA_LEASE_PAYMENT_ITEMS
   associated with the specified lease.*/
PROCEDURE  Lock_Rows(
    X_Lease_ID		IN	NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  IS

    CURSOR payitems  IS

        SELECT *
        FROM   FA_LEASE_PAYMENT_ITEMS
        WHERE  Lease_ID = X_Lease_ID
        FOR    UPDATE NOWAIT;

    V_Rowdata   payitems%ROWTYPE;

BEGIN

    OPEN payitems;

    FETCH payitems INTO V_Rowdata;

    CLOSE payitems;

END  Lock_Rows;

/* Procedure Delete_Rows() deletes all rows in FA_LEASE_PAYMENT_ITEMS
   associated with the specified lease.*/
PROCEDURE    Delete_Rows(

    X_Lease_ID		IN	NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)  IS

BEGIN


    DELETE FROM FA_LEASE_PAYMENT_ITEMS
    WHERE  Lease_ID = X_Lease_ID;

END  Delete_Rows;

/* Procedure Payments_Itemize() will create payment items for a lease.
   New rows will be inserted into table FA_LEASE_PAYMENT_ITEMS. It will
   be called after a user associates a schedule with a lease. A user
   can also sumbit a concurrent program to run it to create payment
   items for existing leases. */
FUNCTION  Payments_Itemize (

    P_Lease_ID   		IN      NUMBER,
    P_Payment_Schedule_ID	IN	NUMBER,
    P_Lessor_ID			IN	NUMBER,
    P_Lessor_Site_ID		IN	NUMBER 	:= NULL,
    P_Dist_Code_Combination_ID	IN	NUMBER	:= NULL,
    P_Terms_ID                  IN      NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

RETURN  BOOLEAN  IS

    V_Lessor_ID			Number;
    V_Lessor_Site_ID		Number;
    V_Dist_Code_Combination_ID	Number;
    V_Terms_ID			Number;
    V_User_ID			Number;
    V_Invoice_Number		VARCHAR2(50);
    V_Lease_Number		VARCHAR2(15);

    CURSOR payment_items IS

        SELECT  Amortization_Line_Num Amort_Line_Num
        FROM    FA_AMORT_SCHEDULES
        WHERE	Payment_Schedule_ID = P_Payment_Schedule_ID;

BEGIN

    V_User_ID := TO_Number(FND_Profile.Value('USER_ID'));

    IF  (P_Lessor_Site_ID is NULL or P_Dist_Code_Combination_ID is NULL) THEN

        /* get Lessor Site and Account related with the lease. */
        SELECT   Lessor_ID, Lessor_Site_ID,
                 Dist_Code_Combination_ID, Lease_Number
        INTO     V_Lessor_ID, V_Lessor_Site_ID,
                 V_Dist_Code_Combination_ID, V_Lease_Number
        FROM     FA_Leases
        WHERE    Lease_ID = P_Lease_ID;

        IF  (V_Lessor_Site_ID is NULL or V_Dist_Code_Combination_ID is NULL) THEN

            -- lessor site and code combination id are required, the user will
            -- be notified by a message window
            RETURN FALSE;

        END IF;

    ELSE

        SELECT Lease_Number INTO V_Lease_Number
        FROM FA_Leases WHERE Lease_ID = P_Lease_ID;
        V_Lessor_ID := P_Lessor_ID;
        V_Lessor_Site_ID := P_Lessor_Site_ID;
        V_Dist_Code_Combination_ID := P_Dist_Code_Combination_ID;

    END IF;

    V_Terms_ID := P_Terms_ID;

    -- insert rows into FA_LEASE_PAYMENT_ITEMS table
    FOR current_item IN payment_items LOOP

        --create an informative invoice number
        V_Invoice_Number := 'FA-'||V_Lease_Number||'-'||current_item.Amort_Line_Num;

        FA_LEASE_PITEMS_PKG.Insert_Row(
            X_Lease_ID                  =>      P_Lease_ID,
            X_Payment_Schedule_ID       =>      P_Payment_Schedule_ID,
            X_Schedule_Amort_Line_Num   =>      current_item.Amort_Line_Num,
            X_Export_Status             =>      'NEW',
            X_Lessor_ID                 =>      V_Lessor_ID,
            X_Lessor_Site_ID            =>      V_Lessor_Site_ID,
            X_Dist_Code_Combination_ID  =>      V_Dist_Code_Combination_ID,
            X_Invoice_Number            =>      V_Invoice_Number,
            X_Invoice_ID                =>      NULL,
            X_Invoice_Line_ID           =>      NULL,
            X_Terms_ID                  =>      V_Terms_ID,
            X_Last_Updated_by           =>      V_User_ID,
            X_Last_Update_Date          =>      Sysdate,
            X_Last_Update_Login         =>      V_User_ID,
            X_Created_by                =>      V_User_ID,
            X_Creation_Date             =>      Sysdate,
            X_Request_ID                =>      NULL, p_log_level_rec => p_log_level_rec);

    END LOOP;

    RETURN TRUE;

EXCEPTION

    WHEN others THEN

        FA_SRVR_MSG.ADD_MESSAGE(

              CALLING_FN => 'FA_LEASE_PITEMS_PKG.PAYMENTS_ITEMIZE',  p_log_level_rec => p_log_level_rec);

END Payments_Itemize;

END FA_LEASE_PITEMS_PKG;

/
