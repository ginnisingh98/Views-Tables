--------------------------------------------------------
--  DDL for Package PA_MC_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MC_UPG" AUTHID CURRENT_USER AS
--$Header: PAXMCUPS.pls 120.1 2005/06/08 16:21:40 vgade noship $

PROCEDURE Upgrade_MRC ( 	x_errbuf 	OUT NOCOPY VARCHAR2,
                		x_retcode 	OUT NOCOPY VARCHAR2,
				x_Pri_SOB	IN	NUMBER,
				x_Rep_SOB	IN	NUMBER,
				x_From_Prj_Num	IN	VARCHAR2,
				x_To_Prj_Num	IN	VARCHAR2,
				x_Rounding	IN	VARCHAR2	DEFAULT 'N',
				x_Use_Curr_Rate	IN	VARCHAR2	DEFAULT 'N',
				x_Debug_Flag	IN	VARCHAR2	DEFAULT 'N',
                                x_include_closed_prj IN VARCHAR2    	DEFAULT 'N',
				x_Process	IN	VARCHAR2	DEFAULT 'PLSQL',
                                x_Validation_Check IN	VARCHAR2	DEFAULT 'Y'
			);

/** Upgrade_MRC : Main procedure for MRC upgrade.
	Parameters are passed from the script.
	G_Err_Code = 0 - Success, -1 - Error ( Abort ).
	G_Err_Stage contains the error msg.
	Ora Errors will be raised as exceptions.
**/


PROCEDURE	Validate_Params;

/** Validate_Params : Procedure to validate parameters.
	Parameters should be available as global vars.
	While validating certain variables are set.
        G_Err_Code = 0 - Success, -1 - Error ( Abort ).
        G_Err_Stage contains the error msg.
        Ora Errors will be raised as exceptions.
**/


PROCEDURE	Init_Upgrade;

/** Init_Upgrade : Procedure to initialize variables.
	Works on global vars. Sets variables as needed.
        G_Err_Code = 0 - Success, -1 - Error ( Abort ).
        G_Err_Stage contains the error msg.
        Ora Errors will be raised as exceptions.
**/

PROCEDURE cache_exchange_rates;

/** Cache_Exchange_Rates :
    This procedure will cache the exchange rates for various transaction
    Currencies and the Reporting currency before doing the MRC Upgrade. If
    It is unable to find rates for any currency, It will list out those
    currencies, so that the rates for them can be populated and this procedure
    is rerun
**/

PROCEDURE insert_temp_rates ( x_currency_code           IN VARCHAR2);

/** insert_temp_rates : Procedure to Insert a transaction currency along with its
    Fixed rate on the Initial MRC Date, into the cache table.
**/

PROCEDURE	Validate_SOB_Assign (	x_Pri_SOB_ID	IN	NUMBER,
					x_Rep_SOB_ID	IN	NUMBER);

/** Validate_SOB_Assign : Procedure to validate if the Primary and Reporting
	Set of books assignment is valid. If yes, then set the variables,
	else return with -1.
        G_Err_Code = 0 - Success, -1 - Error ( Abort ).
        G_Return_Msg contains the error msg.
        Ora Errors will be raised as exceptions.
**/

Function 	Check_Future_Record
		Return BOOLEAN;

/** Check_Future_Record checks availability of future record Table_Name = 'FUTURE' for the set of books and returns TRUE if available, FALSE otherwise   **/

Function 	Validate_First_MRC_Period
		RETURN BOOLEAN;
/** First GL_Period should be equal to First_MRC_Period.  Return TRUE on success else FALSE **/

PROCEDURE 	Insert_History_Rec (	x_Table_Name 	IN	VARCHAR2,
					x_Project_ID	IN 	NUMBER,
					x_Status	IN	VARCHAR2,
					x_Status_Value	IN	VARCHAR2);

/** Insert_History_Rec : Procedure to insert a history rec.
	x_table_name : Table to insert rec for.
	x_Project_ID : Project to insert recoed for.
	x_Status : 'CONVERSION' or 'ROUNDING' status
	x_Status_Value : 'C' Converted, 'S' In Process or NULL.
        G_Return_Code = 0 - Success, -1 - Error ( Abort ).
        G_Err_Stage contains the error msg.
        Ora Errors will be raised as exceptions.
**/



FUNCTION	Get_Project_Number (	x_Project_Range	IN	VARCHAR2 )
		RETURN VARCHAR2;

/** Get_Project_Number : Function to get the project number MIN or MAX.
	x_Project_Range can be MIN or MAX. Accordingly, a minimum or
	a maximum project number is returned. Project Number is Unique
	across Orgs. Hence PA_Projects_ALL used.
        Ora Errors will be raised as exceptions.
**/


FUNCTION	Validate_SOB (	x_SOB_ID	IN	NUMBER,
				l_Currency_Code OUT NOCOPY VARCHAR2)
		RETURN VARCHAR2;

/** Validate_SOB : Function to validate the set of books name passed.
	Returns Set of Books ID, if found, Else -1. ( ABORT )
        Ora Errors will be raised as exceptions.
**/


FUNCTION	Get_User_Lock (	x_Lock_Name	IN	VARCHAR2,
				x_Lock_Mode	IN	NUMBER default 6,
				x_Commit_Mode	IN	BOOLEAN default FALSE )
		RETURN VARCHAR2;

/** Get_User_Lock : Function to acquire a user lock.
	x_lock_name : name of the lock.
	x_lock_mode : Mode of the lock ( Exclusive,..)
	x_commit_mode : Rls with commit or not
	Returns : lock handle if successful in acquiring lock
	else  NULL - Cannot acquire lock.
        Ora Errors will be raised as exceptions.
**/


FUNCTION	Rls_User_Lock (	x_Lock_Hndl	IN	VARCHAR2 )
		RETURN NUMBER;

/** Rls_User_Lock : Function to release user lock.
	x_Lock_Hndl : The lock handle obtained earlier.
	Returns 0 - success, -1 - Error. ( Abort ).
**/



FUNCTION	Get_Table_Status (	x_Table_Name	IN	VARCHAR2,
					x_Project_ID	IN	NUMBER,
					x_Status	IN	VARCHAR2 )
		RETURN	VARCHAR2;

/** Get_Table_Status : Function to get the table status for the project from
	the MRC upgrade history table.
	x_table_name : table to be checked for.
	x_Project_ID : Project to be checked for.
	x_Status : Status to check for - Conversion or Rounding.
		   Can have values - CONVERSION or ROUNDING.
	Returns : 'C' = Converted, NULL = Not done yet.
**/


PROCEDURE	Convert_Table (		x_Table_Name	IN	VARCHAR2);

/** Convert_Table : Procedure to convert table.
        x_Table_Name: Table to be converted.
**/

PROCEDURE	Insert_Recs (		x_Table_Name	IN	VARCHAR2);

PROCEDURE	Update_Recs (		x_Table_Name	IN	VARCHAR2);

PROCEDURE	Insert_CDL;

PROCEDURE	Insert_CRDL;

PROCEDURE	Insert_ERDL;

PROCEDURE	Insert_DR;

PROCEDURE	Insert_Event;

PROCEDURE	Insert_AL;

PROCEDURE	Insert_ALD;

Procedure 	Insert_DINV(		x_Project_ID 	IN	NUMBER,
				      	x_Rep_SOB_ID	IN	NUMBER);

PROCEDURE 	Insert_exp_items(	x_Project_ID	IN	Number,
					x_Rep_SOB_ID	IN	Number);

PROCEDURE	Update_CDL;

PROCEDURE	Update_CRDL;

PROCEDURE	Update_ERDL;

PROCEDURE	Update_DR;

PROCEDURE	Update_EVENT;

PROCEDURE	Update_AL;

PROCEDURE	Update_ALD;

PROCEDURE	Update_DINV;

PROCEDURE	Insert_CCDL;

PROCEDURE	Insert_DINVDTLS;

PROCEDURE	Update_CCDL;

PROCEDURE	Update_DINVDTLS;

PROCEDURE 	Update_exp_items(	x_Project_ID	IN	Number,
					x_Rep_SOB_ID	IN	Number);
-------------------------------------------------------------------------------
/** Important: Dependencies: Get_Rate_Type,Get_Rate_Date. If you modify any
	       logic in get_converted_amount check if the logic has any
	       impact on those two dependent functions **/
FUNCTION Get_Converted_Amount ( x_Denom_Cur_Code  IN    Varchar2,
                                x_Acct_Rate_Type  IN    Varchar2,
                                x_Conversion_Date IN    Date,
                                x_Amount          IN    Number,
                                x_Acct_Amt        IN    Number,
                                x_Rate            IN    Varchar2	DEFAULT 'N'
				)
RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (Get_Converted_Amount,WNDS);

PROCEDURE Get_Cached_Rate ( x_curr_code         IN      VARCHAR2,
                            x_denom_rate        OUT NOCOPY  NUMBER,
                            x_num_rate          OUT NOCOPY  NUMBER);

PROCEDURE	Write_Log (		x_Msg	IN	VARCHAR2);

PROCEDURE       Write_Out (             x_Msg   IN      VARCHAR2);

PROCEDURE       Submit_Report;

FUNCTION Check_Intercompany_Project (p_project_id IN Number )
RETURN BOOLEAN;

FUNCTION Different_SOB (p_prvdr_org_id       IN     Number,
			p_recvr_org_id       IN     Number)

Return Varchar2;

PRAGMA RESTRICT_REFERENCES (Different_SOB,WNDS);
------------------------------------------------------------------------------
FUNCTION Prvdr_Proj_Converted
Return Boolean;
-------------------------------------------------------------------------
Procedure Insert_CC_CDL;
-------------------------------------------------------------------------
PROCEDURE	Update_CC_CDL;
-------------------------------------------------------------------------
PROCEDURE Insert_CC_exp_items(	x_Project_ID	IN	Number,
				x_Rep_SOB_ID	IN	Number);
-------------------------------------------------------------------------
PROCEDURE update_cc_exp_items (	x_Project_ID 	IN	Number,
				x_Rep_SOB_ID	IN	Number) ;
-------------------------------------------------------------------------
Procedure Insert_CC_CCDL;
------------------------------------------------------------------------
Function Get_Rate_Type (x_rate_type        IN       Varchar2,
			x_conversion_date  IN       Date)
return Varchar2;
------------------------------------------------------------------------
Function Get_Rate_Date (x_conversion_date  IN       Date)
return Date;
------------------------------------------------------------------------

END PA_MC_UPG;

 

/
