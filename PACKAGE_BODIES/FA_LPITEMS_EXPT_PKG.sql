--------------------------------------------------------
--  DDL for Package Body FA_LPITEMS_EXPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_LPITEMS_EXPT_PKG" AS
/* $Header: FAXLPTPB.pls 120.9.12010000.2 2009/07/19 14:16:18 glchen ship $ */

/*This is a wrapper procedure for inserting rows into table
  AP_INVOICE_LINES_INTERFACE.*/
PROCEDURE  Invoice_Insert_Row(

    X_Invoice_ID		IN	NUMBER,
    X_Invoice_Num		IN	VARCHAR2,
    X_Vendor_ID			IN	NUMBER,
    X_Vendor_Site_ID		IN	NUMBER,
    X_Invoice_Amount		IN	NUMBER,
    X_Invoice_Currency_Code	IN	VARCHAR2,
    X_Source			IN	VARCHAR2,
    X_Terms_ID	        	IN	NUMBER,
    X_Last_Updated_by		IN	NUMBER,
    X_Last_Update_Date		IN	DATE,
    X_Last_Update_Login		IN	NUMBER,
    X_Created_by		IN	NUMBER,
    X_Creation_Date		IN	DATE,
    X_GL_Date			IN	DATE,
    X_Invoice_Date		IN	DATE,
    X_Org_ID			IN	NUMBER,
    X_LE_ID			IN	NUMBER,
    X_LE_Name			IN	VARCHAR2,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type )  IS

BEGIN

    INSERT INTO AP_Invoices_Interface(

	Invoice_ID,
	Invoice_Num,
	Vendor_ID,
	Vendor_Site_ID,
	Invoice_Amount,
	Invoice_Currency_Code,
	Source,
	Terms_ID,
	Last_Updated_by,
	Last_Update_Date,
	Last_Update_Login,
	Created_by,
	Creation_Date,
	GL_Date,
       	Invoice_Date,
        Invoice_Received_Date,
	Org_ID,
	Legal_Entity_ID,
	Legal_Entity_Name,
        Goods_Received_Date
        )

    VALUES (

	X_Invoice_ID,
	X_Invoice_Num,
	X_Vendor_ID,
	X_Vendor_Site_ID,
	X_Invoice_Amount,
	X_Invoice_Currency_Code,
	X_Source,
	X_Terms_ID,
	X_Last_Updated_by,
	X_Last_Update_Date,
	X_Last_Update_Login,
	X_Created_by,
	X_Creation_Date,
	X_GL_Date,
       	X_Invoice_Date,
        X_GL_Date, -- BUG# 2267117
	X_Org_ID,
	X_LE_ID,
	X_LE_Name,
        X_GL_Date -- BUG# 3900673
        );


EXCEPTION

    WHEN others THEN

        FA_SRVR_MSG.ADD_MESSAGE(

                       CALLING_FN => 'FA_LPITEMS_EXPT_PKG.Invoice_Insert_Row'
                       ,p_log_level_rec => p_log_level_rec);

END Invoice_Insert_Row;

/*This is a wrapper procedure for inserting rows into table
  AP_INVOICE_LINES_INTERFACE.*/
PROCEDURE  Invoice_Line_Insert_Row(

    X_Invoice_ID		IN	NUMBER,
    X_Invoice_Line_ID		IN	NUMBER,
    X_Line_Number		IN	NUMBER,
    X_Line_Type_Lookup_Code	IN	VARCHAR2 := 'ITEM',
    X_Amount			IN	NUMBER,
    X_Dist_Code_Combination_ID	IN	NUMBER,
    X_Last_Updated_by		IN	NUMBER,
    X_Last_Update_Date		IN	DATE,
    X_Last_Update_Login		IN	NUMBER,
    X_Created_by		IN	NUMBER,
    X_Creation_Date		IN	DATE,
    X_Accounting_Date		IN	DATE,
    X_Org_ID			IN	NUMBER,
    p_log_level_rec             IN     FA_API_TYPES.log_level_rec_type )  IS

BEGIN

    INSERT INTO AP_Invoice_Lines_Interface(

	Invoice_ID,
	Invoice_Line_ID,
	Line_Number,
	Line_Type_Lookup_Code,
	Amount,
	Dist_Code_Combination_ID,
	Last_Updated_by,
	Last_Update_Date,
	Last_Update_Login,
	Created_by,
	Creation_Date,
        Accounting_Date,
	Org_ID)

    VALUES (

	X_Invoice_ID,
	X_Invoice_Line_ID,
	X_Line_Number,
	X_Line_Type_Lookup_Code,
	X_Amount,
	X_Dist_Code_Combination_ID,
	X_Last_Updated_by,
	X_Last_Update_Date,
	X_Last_Update_Login,
	X_Created_by,
	X_Creation_Date,
	X_Accounting_Date,
	X_Org_ID);

EXCEPTION

    WHEN others THEN

        FA_SRVR_MSG.ADD_MESSAGE(

                   CALLING_FN => 'FA_LPITEMS_EXPT_PKG.Invoice_Line_Insert_Row'
                   ,p_log_level_rec => p_log_level_rec);

END Invoice_Line_Insert_Row;

/* Procedure Payment_Items_to_AP pushes lease payment items in Fixed
   Assets into Account Payables. For all rows with Export Status
   'POST', it will create new rows in tables AP_INVOICES_INTERFACE and
   AP_INVOICE_LINES_INTERFACE. It will be called when a user presses
   the EXPORT button in the Export Lease Payments to Payables window
   and run as a concurrent program.*/
PROCEDURE  Payment_Items_to_AP(
        errbuf            out nocopy varchar2,
        retcode           out nocopy number,
        argument1               IN      VARCHAR2 := NULL,
        argument2               IN      VARCHAR2 := NULL,
        argument3               IN      VARCHAR2 := NULL,
        argument4               IN      VARCHAR2 := NULL,
        argument5               IN      VARCHAR2 := NULL,
        argument6               IN      VARCHAR2 := NULL,
        argument7               IN      VARCHAR2 := NULL,
        argument8               IN      VARCHAR2 := NULL,
        argument9               IN      VARCHAR2 := NULL,
        argument10              IN      VARCHAR2 := NULL,
        argument11              IN      VARCHAR2 := NULL,
        argument12              IN      VARCHAR2 := NULL,
        argument13              IN      VARCHAR2 := NULL,
        argument14              IN      VARCHAR2 := NULL,
        argument15              IN      VARCHAR2 := NULL,
        argument16              IN      VARCHAR2 := NULL,
        argument17              IN      VARCHAR2 := NULL,
        argument18              IN      VARCHAR2 := NULL,
        argument19              IN      VARCHAR2 := NULL,
        argument20              IN      VARCHAR2 := NULL,
        argument21              IN      VARCHAR2 := NULL,
        argument22              IN      VARCHAR2 := NULL,
        argument23              IN      VARCHAR2 := NULL,
        argument24              IN      VARCHAR2 := NULL,
        argument25              IN      VARCHAR2 := NULL,
        argument26              IN      VARCHAR2 := NULL,
        argument27              IN      VARCHAR2 := NULL,
        argument28              IN      VARCHAR2 := NULL,
        argument29              IN      VARCHAR2 := NULL,
        argument30              IN      VARCHAR2 := NULL,
        argument31              IN      VARCHAR2 := NULL,
        argument32              IN      VARCHAR2 := NULL,
        argument33              IN      VARCHAR2 := NULL,
        argument34              IN      VARCHAR2 := NULL,
        argument35              IN      VARCHAR2 := NULL,
        argument36              IN      VARCHAR2 := NULL,
        argument37              IN      VARCHAR2 := NULL,
        argument38              IN      VARCHAR2 := NULL,
        argument39              IN      VARCHAR2 := NULL,
        argument40              IN      VARCHAR2 := NULL,
        argument41              IN      VARCHAR2 := NULL,
        argument42              IN      VARCHAR2 := NULL,
        argument43              IN      VARCHAR2 := NULL,
        argument44              IN      VARCHAR2 := NULL,
        argument45              IN      VARCHAR2 := NULL,
        argument46              IN      VARCHAR2 := NULL,
        argument47              IN      VARCHAR2 := NULL,
        argument48              IN      VARCHAR2 := NULL,
        argument49              IN      VARCHAR2 := NULL,
        argument50              IN      VARCHAR2 := NULL,
        argument51              IN      VARCHAR2 := NULL,
        argument52              IN      VARCHAR2 := NULL,
        argument53              IN      VARCHAR2 := NULL,
        argument54              IN      VARCHAR2 := NULL,
        argument55              IN      VARCHAR2 := NULL,
        argument56              IN      VARCHAR2 := NULL,
        argument57              IN      VARCHAR2 := NULL,
        argument58              IN      VARCHAR2 := NULL,
        argument59              IN      VARCHAR2 := NULL,
        argument60              IN      VARCHAR2 := NULL,
        argument61              IN      VARCHAR2 := NULL,
        argument62              IN      VARCHAR2 := NULL,
        argument63              IN      VARCHAR2 := NULL,
        argument64              IN      VARCHAR2 := NULL,
        argument65              IN      VARCHAR2 := NULL,
        argument66              IN      VARCHAR2 := NULL,
        argument67              IN      VARCHAR2 := NULL,
        argument68              IN      VARCHAR2 := NULL,
        argument69              IN      VARCHAR2 := NULL,
        argument70              IN      VARCHAR2 := NULL,
        argument71              IN      VARCHAR2 := NULL,
        argument72              IN      VARCHAR2 := NULL,
        argument73              IN      VARCHAR2 := NULL,
        argument74              IN      VARCHAR2 := NULL,
        argument75              IN      VARCHAR2 := NULL,
        argument76              IN      VARCHAR2 := NULL,
        argument77              IN      VARCHAR2 := NULL,
        argument78              IN      VARCHAR2 := NULL,
        argument79              IN      VARCHAR2 := NULL,
        argument80              IN      VARCHAR2 := NULL,
        argument81              IN      VARCHAR2 := NULL,
        argument82              IN      VARCHAR2 := NULL,
        argument83              IN      VARCHAR2 := NULL,
        argument84              IN      VARCHAR2 := NULL,
        argument85              IN      VARCHAR2 := NULL,
        argument86              IN      VARCHAR2 := NULL,
        argument87              IN      VARCHAR2 := NULL,
        argument88              IN      VARCHAR2 := NULL,
        argument89              IN      VARCHAR2 := NULL,
        argument90              IN      VARCHAR2 := NULL,
        argument91              IN      VARCHAR2 := NULL,
        argument92              IN      VARCHAR2 := NULL,
        argument93              IN      VARCHAR2 := NULL,
        argument94              IN      VARCHAR2 := NULL,
        argument95              IN      VARCHAR2 := NULL,
        argument96              IN      VARCHAR2 := NULL,
        argument97              IN      VARCHAR2 := NULL,
        argument98              IN      VARCHAR2 := NULL,
        argument99              IN      VARCHAR2 := NULL,
        argument100             IN      VARCHAR2 := NULL,
        p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type ) IS

    V_Invoice_ID		NUMBER;
    V_Invoice_Num		VARCHAR2(50);
    V_Lease_Number              VARCHAR2(15);
    V_Invoice_Line_ID		NUMBER;
    V_Line_Number		NUMBER;
    V_Line_Type_Lookup_Code	VARCHAR2(25);
    V_Source			VARCHAR2(25);
    V_Dist_Code_Combination_ID	NUMBER;
    V_Vendor_ID			NUMBER;
    V_Vendor_Site_ID		NUMBER;
    V_Terms_ID  		NUMBER;
    V_Vendor_Name               VARCHAR2(240);
    V_Vendor_Site_Name          VARCHAR2(100);
    V_Invoice_Amount		NUMBER;
    V_Invoice_Currency_Code	VARCHAR2(15);
    V_Payment_Date		DATE;
    V_Org_ID			NUMBER := -1;
    Temp_Org_ID                 NUMBER;
    V_Org_Name                  VARCHAR2(240);
    V_Request_ID		NUMBER;
    V_User_ID			NUMBER;
    V_Row                       VARCHAR2(500);
    V_Title                     VARCHAR2(500);

    /* Stamping LE */
    V_Return_Status             VARCHAR2(1);
    V_Msg_Data                  VARCHAR2(1000);
    V_Ptop_LE_Info              XLE_BUSINESSINFO_GRP.ptop_le_rec;
    V_LE_ID                     NUMBER(15);
    V_LE_Name                   VARCHAR2(240);



    /* Bug 1782129 : Added a code to populate a correct
       ORG_ID from lessor_site_id. Added AP Payment Term ID - YYOON */

    /* Bug 2513136 : fl.lessor_site_id is replaced with flpi.lessor_site_id */

    CURSOR post_payment_items IS

	SELECT	flpi.Lease_ID			Lease_ID,
		flpi.Payment_Schedule_ID 	Payment_Schedule_ID,
		flpi.Schedule_Amort_Line_Num 	Amort_Line_Num,
                flpi.Dist_Code_Combination_ID,
                flpi.Invoice_Number 		Invoice_Number,
                flpi.Terms_ID 			Terms_ID,
		fas.Payment_Date 		Payment_Date,
		fas.Payment_Amount 		Payment_Amount,
                fl.Lease_Number 		Lease_Number,
		fl.Currency_Code 		Currency_Code,
		fl.Lessor_ID 			Lessor_ID,
		flpi.Lessor_Site_ID 		Lessor_Site_ID,
                pv.Vendor_Name 			Lessor_Name,
                pvsa.Vendor_Site_Code 		Lessor_Site_Name,
                pvsa.Org_ID                     Org_ID,
                hao.Name                        Org_Name
	FROM	FA_LEASE_PAYMENT_ITEMS flpi,
		FA_LEASES fl, FA_AMORT_SCHEDULES fas,
                PO_VENDORS pv, PO_VENDOR_SITES_ALL pvsa,
                HR_ALL_ORGANIZATION_UNITS hao
	WHERE	flpi.Export_Status = 'POST'
	AND	flpi.Lease_ID = fl.Lease_ID
	AND	flpi.Payment_Schedule_ID = fas.Payment_Schedule_ID
	AND	flpi.Schedule_Amort_Line_Num = fas.Amortization_Line_Num
        AND     pv.Vendor_ID = fl.Lessor_ID
        AND     pvsa.Vendor_Site_ID = flpi.Lessor_Site_ID
        AND     hao.Organization_ID = pvsa.Org_ID
        ORDER BY hao.Organization_ID, pv.Vendor_ID
/* code fix for bug no.3649844. adding the update clause to avoid duplicate lines in AP interface table*/
        FOR UPDATE;

BEGIN

    V_Request_ID := FND_Global.Conc_Request_ID;
    V_User_ID := TO_Number(FND_Profile.Value('USER_ID'));
    V_Line_Number := 1;
    V_Source := 'Oracle Assets';
    V_Line_Type_Lookup_Code := 'ITEM';

    FND_File.Put(FND_FILE.LOG, lpad('Export Lease Payments to Payables', 65, ' '));
    FND_File.New_Line(FND_FILE.LOG,2);

    V_Title := 'Lease Number    Lessor Name          Lessor Site     Amount'||
               '          Invoice Number            Status';
    FND_File.Put(FND_FILE.LOG, V_Title);
    FND_File.New_Line(FND_FILE.LOG,2);
    FOR current_item IN post_payment_items LOOP

	SELECT  ap_invoices_interface_s.nextval, ap_invoice_lines_interface_s.nextval
        INTO    V_Invoice_ID, V_Invoice_Line_ID
	FROM    dual;

	-- set other variables from current_item;
	V_Vendor_ID := current_item.Lessor_ID;
        V_Invoice_Num := current_item.Invoice_Number;
        V_Lease_Number := current_item.Lease_Number;
	V_Vendor_Site_ID := current_item.Lessor_Site_ID;
	V_Vendor_Name := current_item.Lessor_Name;
	V_Vendor_Site_Name := current_item.Lessor_Site_Name;
        V_Dist_Code_Combination_ID := current_item.Dist_Code_Combination_ID;
	V_Invoice_Amount := current_item.Payment_Amount;
	V_Invoice_Currency_Code := current_item.Currency_Code;
	V_Payment_Date := current_item.Payment_Date;
        V_Terms_ID := current_item.Terms_ID;
        Temp_Org_ID := V_Org_ID;
        V_Org_ID := current_item.Org_ID;
        V_Org_Name := current_item.Org_Name;


        /* Stamping LE:
          We populate the following columns in AP_INVOICE_INTERFACES.
          LEGAL_ENTITY_ID   NUMBER(15)
          LEGAL_ENTITY_NAME VARCHAR2(50) <- could be optional

          Changed the signature of FA_LPITEMS_EXPT_PKG.Invoice_Insert_Row
          to pass on the above two paramters.
        */

        begin

          XLE_BUSINESSINFO_GRP.GET_PURCHASETOPAY_INFO(
                      X_return_status       => V_Return_Status,
                      X_msg_data            => V_Msg_Data,
                      P_registration_code   => null,
                      P_registration_number => null,
                      P_location_id         => null,
                      P_code_combination_id => V_Dist_Code_Combination_ID,
                      P_operating_unit_id   => current_item.Org_ID,
                      X_ptop_le_info        => V_Ptop_LE_Info);

          V_LE_ID := V_Ptop_LE_Info.Legal_Entity_ID;
          V_LE_Name :=  V_Ptop_LE_Info.Name;

        exception
          when others then
            FND_File.Put(FND_File.Log, V_Msg_Data);
            FND_File.New_Line(FND_FILE.LOG,1);
            raise;
        end;


	-- insert into table AP_INVOICES_INTERFACE
	FA_LPITEMS_EXPT_PKG.Invoice_Insert_Row(

	    X_Invoice_ID		=>	V_Invoice_ID,
	    X_Invoice_Num		=>	V_Invoice_Num,
	    X_Vendor_ID			=>	V_Vendor_ID,
	    X_Vendor_Site_ID		=>	V_Vendor_Site_ID,
	    X_Invoice_Amount		=>	V_Invoice_Amount,
	    X_Invoice_Currency_Code	=>	V_Invoice_Currency_Code,
	    X_Source			=>	V_Source,
	    X_Terms_ID			=>	V_Terms_ID,
	    X_Last_Updated_by		=>	V_User_ID,
	    X_Last_Update_Date		=>	Sysdate,
	    X_Last_Update_Login		=>	V_User_ID,
	    X_Created_by		=>	V_User_ID,
	    X_Creation_Date		=>	Sysdate,
	    X_GL_Date			=>	V_Payment_Date,
	    X_Invoice_Date		=>	V_Payment_Date,
	    X_Org_ID			=>	V_Org_ID,
	    X_LE_ID			=>	V_LE_ID,
	    X_LE_Name			=>	V_LE_Name
	    ,p_log_level_rec => p_log_level_rec);

	-- insert into table AP_INVOICE_LINE_INTERFACE
	FA_LPITEMS_EXPT_PKG.Invoice_Line_Insert_Row(

	    X_Invoice_ID		=>	V_Invoice_ID,
	    X_Invoice_Line_ID		=>	V_Invoice_Line_ID,
	    X_Line_Number		=>	V_Line_Number,
	    X_Line_Type_Lookup_Code	=>	V_Line_Type_Lookup_Code,
	    X_Amount			=>	V_Invoice_Amount,
	    X_Dist_Code_Combination_ID	=>	V_Dist_Code_Combination_ID,
	    X_Last_Updated_by		=>	V_User_ID,
	    X_Last_Update_Date		=>	Sysdate,
	    X_Last_Update_Login		=>	V_User_ID,
	    X_Created_by		=>	V_User_ID,
	    X_Creation_Date		=>	Sysdate,
	    X_Accounting_Date		=>	V_Payment_Date,
	    X_Org_ID			=>	V_Org_ID
	    ,p_log_level_rec => p_log_level_rec);

        /*update the FA_Lease_Payment_Items table with new information.*/
	UPDATE  FA_Lease_Payment_Items
        SET     Invoice_ID = V_Invoice_ID,
                Invoice_Line_ID = V_Invoice_Line_ID,
		Request_ID = V_Request_ID,
		Export_Status = 'POSTED'
        WHERE   Lease_ID = current_item.Lease_ID
	AND	Payment_Schedule_ID = current_item.Payment_Schedule_ID
	AND	Schedule_Amort_Line_Num = current_item.Amort_Line_Num;

        if (V_Org_ID <> Temp_Org_ID) then
          FND_File.New_Line(FND_FILE.LOG,2);
          FND_File.Put(FND_FILE.LOG, 'Organization Name: '||V_Org_Name);
          FND_File.New_Line(FND_FILE.LOG,2);
        end if;

        V_Row := rpad(V_Lease_Number,15,' ')||' ' ||
                 rpad(substr(V_Vendor_Name,1,20),20,' ')||' '||
                 rpad(V_Vendor_Site_Name,15,' ')||' '||
                 rpad(substr(ltrim(to_char(V_Invoice_Amount,'9999999999999D99')),1,15),15,' ')||' '||
                 rpad(substr(V_Invoice_Num,1,25),25,' ')||' ==> Succeeded';

        FND_File.Put(FND_File.Log, V_Row);
        FND_File.New_Line(FND_FILE.LOG,1);

    END LOOP;

EXCEPTION

    WHEN others THEN

        V_Row := V_Lease_Number||V_Vendor_Name||V_Vendor_Site_Name||
                 to_char(V_Invoice_Amount)|| V_Invoice_Num||'==> Failed';

        FND_File.Put(FND_File.Log, V_Row);
        FND_File.New_Line(FND_FILE.LOG,1);

	FA_SRVR_MSG.ADD_MESSAGE(

                  CALLING_FN => 'FA_LPITEMS_EXPT_PKG.Payment_Items_to_AP'
                  ,p_log_level_rec => p_log_level_rec);

END   Payment_Items_to_AP;

END FA_LPITEMS_EXPT_PKG;

/
