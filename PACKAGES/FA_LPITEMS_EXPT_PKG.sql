--------------------------------------------------------
--  DDL for Package FA_LPITEMS_EXPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_LPITEMS_EXPT_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXLPTPS.pls 120.3.12010000.2 2009/07/19 14:03:39 glchen ship $ */

/* This is a wrapper procedure for inserting rows into table
   AP_INVOICES_INTERFACE. */
PROCEDURE  Invoice_Insert_Row(

	X_Invoice_ID			IN	NUMBER,
	X_Invoice_Num			IN	VARCHAR2,
	X_Vendor_ID			IN	NUMBER,
	X_Vendor_Site_ID		IN	NUMBER,
	X_Invoice_Amount		IN	NUMBER,
	X_Invoice_Currency_Code		IN	VARCHAR2,
	X_Source			IN	VARCHAR2,
	X_Terms_ID		        IN	NUMBER,
	X_Last_Updated_by		IN	NUMBER,
	X_Last_Update_Date		IN	DATE,
	X_Last_Update_Login		IN	NUMBER,
	X_Created_by			IN	NUMBER,
	X_Creation_Date			IN	DATE,
	X_GL_Date			IN	DATE,
	X_Invoice_Date			IN	DATE,
	X_Org_ID			IN	NUMBER,
        X_LE_ID                         IN      NUMBER,
        X_LE_Name                       IN      VARCHAR2,
        p_log_level_rec                 IN      FA_API_TYPES.log_level_rec_type default null
        );

/*This is a wrapper procedure for inserting rows into table
  AP_INVOICE_LINES_INTERFACE.*/
PROCEDURE  Invoice_Line_Insert_Row(

	X_Invoice_ID			IN	NUMBER,
	X_Invoice_Line_ID		IN	NUMBER,
	X_Line_Number			IN	NUMBER,
	X_Line_Type_Lookup_Code		IN	VARCHAR2 := 'ITEM',
	X_Amount			IN	NUMBER,
	X_Dist_Code_Combination_ID	IN	NUMBER,
	X_Last_Updated_by		IN	NUMBER,
	X_Last_Update_Date		IN	DATE,
	X_Last_Update_Login		IN	NUMBER,
	X_Created_by			IN	NUMBER,
	X_Creation_Date			IN	DATE,
	X_Accounting_Date		IN	DATE,
	X_Org_ID			IN	NUMBER,
        p_log_level_rec                 IN      FA_API_TYPES.log_level_rec_type default null);

/* Procedure Payment_Items_to_AP pushes lease payment items in Fixed
   Assets into Account Payables. For all rows with Export Status
   'POST', it will create new rows in tables AP_INVOICES_INTERFACE and
   AP_INVOICE_LINES_INTERFACE. It will be called when a user presses
   the EXPORT button in the Export Lease Payments to Payables window
   and run as a concurrent program.*/

PROCEDURE Payment_Items_to_AP(
        errbuf                  OUT NOCOPY VARCHAR2,
        retcode                 OUT NOCOPY NUMBER,
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
        p_log_level_rec         IN      FA_API_TYPES.log_level_rec_type default null);

END FA_LPITEMS_EXPT_PKG;

/
