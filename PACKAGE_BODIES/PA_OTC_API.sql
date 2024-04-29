--------------------------------------------------------
--  DDL for Package Body PA_OTC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OTC_API" As
-- $Header: PAXVOTCB.pls 120.18.12010000.15 2009/12/03 22:19:30 apaul ship $

    -- Package Variables

    -- Used to indicate that last index point in the pl/sql detail attribute table that was accessed.
    G_Detail_Attr_Index             Binary_Integer := 0;

    -- Used to indicate that last index point in the pl/sql old detail attribute table that was accessed.
    G_Old_Detail_Attr_Index         Binary_Integer := 0;

    -- Stores the Timecard Scope BB_ID and BB_OVN and is used to populate in
    G_Orig_Exp_Txn_Reference1       Pa_Expenditures_All.Orig_Exp_Txn_Reference1%TYPE := Null;

    G_Time_BB_Id                    Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE := Null;

    -- Used to indicate what was actually happening when unexpected error occurs.
    G_Stage                         Varchar2(2000);

    -- Used to indentify the path taken to the point on where an unexpected error occurs.
    G_Path                          Varchar2(2000) := ' ';

    -- These pl/sql table are used for flushing out procedure tables
    G_Msg_Tokens_Table   Pa_Otc_Api.Message_Tokens;

    -- This pl/sql table stores a list of the expenditure_ending_dates and there associated batch_name
    -- This pl/sql table is used during the Pre-Import phase of Trx Import
    G_EndDateBatchName_Table Pa_Otc_Api.EndDateBatchName_Tab;

    -- Used to store the binary_index for the pl/sql table records inserted into the interface table so that can speed up
    -- the tieback process.
    G_Trx_Inserted_Tab     Pa_Otc_Api.Trx_Inserted_Table;

    -- Used to store the binary_index for pl/sql table records that were directly updated.  This is so that can speed up
    -- the tieback process.
    G_Trx_Direct_Upd_Tab   Pa_Otc_Api.Trx_Inserted_Table;

    -- Used as a check flag for the looping that is now been added in Trx Import for OTL.  The flag is used within
    -- the exception handler for Upload_Otc_Timecard() procedure.
    G_Processed_Import_Batch	   Boolean := Null;

    -- Global arrays for bulk insert into Trx Interface table
    G_Txn_Interface_Id_Tbl 		Pa_Txn_Interface_Items_Pkg.Txn_Interface_Id_Typ;
    G_Transaction_Source_Tbl 		Pa_Txn_Interface_Items_Pkg.Transaction_Source_Typ;
    G_User_Transaction_Source_Tbl 	Pa_Txn_Interface_Items_Pkg.User_Transaction_Source_Typ;
    G_Batch_Name_Tbl 			Pa_Txn_Interface_Items_Pkg.Batch_Name_Typ;
    G_Expenditure_End_Date_Tbl 		Pa_Txn_Interface_Items_Pkg.Expenditure_End_Date_Typ;
    G_Person_Bus_Grp_Name_Tbl 		Pa_Txn_Interface_Items_Pkg.Person_Business_Group_Name_Typ;
    G_Person_Bus_Grp_Id_Tbl 		Pa_Txn_Interface_Items_Pkg.Person_Business_Group_Id_Typ;
    G_Employee_Number_Tbl 		Pa_Txn_Interface_Items_Pkg.Employee_Number_Typ;
    G_Person_Id_Tbl 			Pa_Txn_Interface_Items_Pkg.Person_Id_Typ;
    G_Organization_Name_Tbl 		Pa_Txn_Interface_Items_Pkg.Organization_Name_Typ;
    G_Organization_Id_Tbl 		Pa_Txn_Interface_Items_Pkg.Organization_Id_Typ;
    G_Expenditure_Item_Date_Tbl 	Pa_Txn_Interface_Items_Pkg.Expenditure_Item_Date_Typ;
    G_Project_Number_Tbl 		Pa_Txn_Interface_Items_Pkg.Project_Number_Typ;
    G_Project_Id_Tbl 			Pa_Txn_Interface_Items_Pkg.Project_Id_Typ;
    G_Task_Number_Tbl 			Pa_Txn_Interface_Items_Pkg.Task_Number_Typ;
    G_Task_Id_Tbl 			Pa_Txn_Interface_Items_Pkg.Task_Id_Typ;
    G_Expenditure_Type_Tbl 		Pa_Txn_Interface_Items_Pkg.Expenditure_Type_Typ;
    G_System_Linkage_Tbl 		Pa_Txn_Interface_Items_Pkg.System_Linkage_Typ;
    G_Non_Labor_Resource_Tbl 		Pa_Txn_Interface_Items_Pkg.Non_Labor_Resource_Typ;
    G_Non_Labor_Res_Org_Name_Tbl 	Pa_Txn_Interface_Items_Pkg.Non_Labor_Res_Org_Name_Typ;
    G_Non_Labor_Res_Org_Id_Tbl 		Pa_Txn_Interface_Items_Pkg.Non_Labor_Res_Org_Id_Typ;
    G_Quantity_Tbl	 		Pa_Txn_Interface_Items_Pkg.Quantity_Typ;
    G_Raw_Cost_Tbl 			Pa_Txn_Interface_Items_Pkg.Raw_Cost_Typ;
    G_Raw_Cost_Rate_Tbl 		Pa_Txn_Interface_Items_Pkg.Raw_Cost_Rate_Typ;
    G_Burden_Cost_Tbl 			Pa_Txn_Interface_Items_Pkg.Burden_Cost_Typ;
    G_Burden_Cost_Rate_Tbl 		Pa_Txn_Interface_Items_Pkg.Burden_Cost_Rate_Typ;
    G_Expenditure_Comment_Tbl 		Pa_Txn_Interface_Items_Pkg.Expenditure_Comment_Typ;
    G_Gl_Date_Tbl 			Pa_Txn_Interface_Items_Pkg.Gl_Date_Typ;
    G_Transaction_Status_Code_Tbl 	Pa_Txn_Interface_Items_Pkg.Transaction_Status_Code_Typ;
    G_Trans_Rejection_Code_Tbl 		Pa_Txn_Interface_Items_Pkg.Transaction_Rejection_Code_Typ;
    G_Orig_Trans_Reference_Tbl 		Pa_Txn_Interface_Items_Pkg.Orig_Transaction_Reference_Typ;
    G_Unmatched_Neg_Txn_Flag_Tbl 	Pa_Txn_Interface_Items_Pkg.Unmatched_Neg_Txn_Flag_Typ;
    G_Expenditure_Id_Tbl 		Pa_Txn_Interface_Items_Pkg.Expenditure_Id_Typ;
    G_Attribute_Category_Tbl 		Pa_Txn_Interface_Items_Pkg.Attribute_Category_Typ;
    G_Attribute1_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute1_Typ;
    G_Attribute2_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute2_Typ;
    G_Attribute3_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute3_Typ;
    G_Attribute4_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute4_Typ;
    G_Attribute5_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute5_Typ;
    G_Attribute6_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute6_Typ;
    G_Attribute7_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute7_Typ;
    G_Attribute8_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute8_Typ;
    G_Attribute9_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute9_Typ;
    G_Attribute10_Tbl 			Pa_Txn_Interface_Items_Pkg.Attribute10_Typ;
    G_Dr_Code_Combination_Id_Tbl 	Pa_Txn_Interface_Items_Pkg.Dr_Code_Combination_Id_Typ;
    G_Cr_Code_Combination_Id_Tbl 	Pa_Txn_Interface_Items_Pkg.Cr_Code_Combination_Id_Typ;
    G_Cdl_System_Reference1_Tbl 	Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference1_Typ;
    G_Cdl_System_Reference2_Tbl 	Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference2_Typ;
    G_Cdl_System_Reference3_Tbl 	Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference3_Typ;
    G_Interface_Id_Tbl 			Pa_Txn_Interface_Items_Pkg.Interface_Id_Typ;
    G_Receipt_Currency_Amount_Tbl 	Pa_Txn_Interface_Items_Pkg.Receipt_Currency_Amount_Typ;
    G_Receipt_Currency_Code_Tbl 	Pa_Txn_Interface_Items_Pkg.Receipt_Currency_Code_Typ;
    G_Receipt_Exchange_Rate_Tbl 	Pa_Txn_Interface_Items_Pkg.Receipt_Exchange_Rate_Typ;
    G_Denom_Currency_Code_Tbl 		Pa_Txn_Interface_Items_Pkg.Denom_Currency_Code_Typ;
    G_Denom_Raw_Cost_Tbl 		Pa_Txn_Interface_Items_Pkg.Denom_Raw_Cost_Typ;
    G_Denom_Burdened_Cost_Tbl 		Pa_Txn_Interface_Items_Pkg.Denom_Burdened_Cost_Typ;
    G_Acct_Rate_Date_Tbl 		Pa_Txn_Interface_Items_Pkg.Acct_Rate_Date_Typ;
    G_Acct_Rate_Type_Tbl 		Pa_Txn_Interface_Items_Pkg.Acct_Rate_Type_Typ;
    G_Acct_Exchange_Rate_Tbl 		Pa_Txn_Interface_Items_Pkg.Acct_Exchange_Rate_Typ;
    G_Acct_Raw_Cost_Tbl 		Pa_Txn_Interface_Items_Pkg.Acct_Raw_Cost_Typ;
    G_Acct_Burdened_Cost_Tbl 		Pa_Txn_Interface_Items_Pkg.Acct_Burdened_Cost_Typ;
    G_Acct_Exch_Rounding_Limit_Tbl 	Pa_Txn_Interface_Items_Pkg.Acct_Exch_Rounding_Limit_Typ;
    G_Project_Currency_Code_Tbl 	Pa_Txn_Interface_Items_Pkg.Project_Currency_Code_Typ;
    G_Project_Rate_Date_Tbl 		Pa_Txn_Interface_Items_Pkg.Project_Rate_Date_Typ;
    G_Project_Rate_Type_Tbl 		Pa_Txn_Interface_Items_Pkg.Project_Rate_Type_Typ;
    G_Project_Exchange_Rate_Tbl 	Pa_Txn_Interface_Items_Pkg.Project_Exchange_Rate_Typ;
    G_Orig_Exp_Txn_Reference1_Tbl 	Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference1_Typ;
    G_Orig_Exp_Txn_Reference2_Tbl 	Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference2_Typ;
    G_Orig_Exp_Txn_Reference3_Tbl 	Pa_Txn_Interface_Items_Pkg.Orig_Exp_Txn_Reference3_Typ;
    G_Orig_User_Exp_Txn_Ref_Tbl 	Pa_Txn_Interface_Items_Pkg.Orig_User_Exp_Txn_Ref_Typ;
    G_Vendor_Number_Tbl 		Pa_Txn_Interface_Items_Pkg.Vendor_Number_Typ;
    G_Vendor_Id_Tbl 			Pa_Txn_Interface_Items_Pkg.Vendor_Id_Typ;
    G_Override_To_Org_Name_Tbl 		Pa_Txn_Interface_Items_Pkg.Override_To_Org_Name_Typ;
    G_Override_To_Org_Id_Tbl 		Pa_Txn_Interface_Items_Pkg.Override_To_Org_Id_Typ;
    G_Reversed_Orig_Txn_Ref_Tbl 	Pa_Txn_Interface_Items_Pkg.Reversed_Orig_Txn_Ref_Typ;
    G_Billable_Flag_Tbl 		Pa_Txn_Interface_Items_Pkg.Billable_Flag_Typ;
    G_ProjFunc_Currency_Code_Tbl 	Pa_Txn_Interface_Items_Pkg.ProjFunc_Currency_Code_Typ;
    G_ProjFunc_Cost_Rate_Date_Tbl 	Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Rate_Date_Typ;
    G_ProjFunc_Cost_Rate_Type_Tbl 	Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Rate_Type_Typ;
    G_ProjFunc_Cost_Exch_Rate_Tbl 	Pa_Txn_Interface_Items_Pkg.ProjFunc_Cost_Exch_Rate_Typ;
    G_Project_Raw_Cost_Tbl 		Pa_Txn_Interface_Items_Pkg.Project_Raw_Cost_Typ;
    G_Project_Burdened_Cost_Tbl 	Pa_Txn_Interface_Items_Pkg.Project_Burdened_Cost_Typ;
    G_Assignment_Name_Tbl 		Pa_Txn_Interface_Items_Pkg.Assignment_Name_Typ;
    G_Assignment_Id_Tbl 		Pa_Txn_Interface_Items_Pkg.Assignment_Id_Typ;
    G_Work_Type_Name_Tbl 		Pa_Txn_Interface_Items_Pkg.Work_Type_Name_Typ;
    G_Work_Type_Id_Tbl 			Pa_Txn_Interface_Items_Pkg.Work_Type_Id_Typ;
    G_Cdl_System_Reference4_Tbl 	Pa_Txn_Interface_Items_Pkg.Cdl_System_Reference4_Typ;
    G_Accrual_Flag_Tbl 			Pa_Txn_Interface_Items_Pkg.Accrual_Flag_Typ;
    G_Last_Update_Date_Tbl		Pa_Txn_Interface_Items_Pkg.Last_Update_Date_Typ;
    G_Last_Updated_By_Tbl		Pa_Txn_Interface_Items_Pkg.Last_Updated_By_Typ;
    G_Creation_Date_Tbl			Pa_Txn_Interface_Items_Pkg.Creation_Date_Typ;
    G_Created_By_Tbl			Pa_Txn_Interface_Items_Pkg.Created_By_Typ;
    -- PA.M/CWK changes
    G_PO_Number_Tbl			Pa_Txn_Interface_Items_Pkg.PO_Number_Typ;
    G_PO_Header_Id_Tbl			Pa_Txn_Interface_Items_Pkg.PO_Header_Id_Typ;
    G_PO_Line_Num_Tbl			Pa_Txn_Interface_Items_Pkg.PO_Line_Num_Typ;
    G_PO_Line_Id_Tbl                    Pa_Txn_Interface_Items_Pkg.PO_Line_Id_Typ;
    G_PO_Price_Type_Tbl                 Pa_Txn_Interface_Items_Pkg.PO_Price_Type_Typ;
    G_Person_Type_Tbl			Pa_Txn_Interface_Items_Pkg.Person_Type_Typ;
    -- Other PA.M changes
    G_Inventory_Item_Id_Tbl             Pa_Txn_Interface_Items_Pkg.Inventory_Item_Id_Typ;
    G_WIP_Resource_Id_Tbl		Pa_Txn_Interface_Items_Pkg.WIP_Resource_Id_Typ;
    G_Unit_Of_Measure_Tbl		Pa_Txn_Interface_Items_Pkg.Unit_Of_Measure_Typ;

    G_Trx_Import_Index			Binary_Integer := 0;

    -- Used as a counter to bulk insert.
    G_Txn_Rec_Count                     Number         := Null;

    -- Handling unhandled exceptions
    G_EXCEPT_CNT_ALLOWED		Number         := to_Number(Nvl(Fnd_Profile.Value('HXC_RETRIEVAL_MAX_ERRORS'),0));
    G_Unhandled_Except_Cnt		Number;

    G_BAD_OTL_DATA                      Exception;
    HXC_RETRIEVAL_MAX_ERRORS            Exception;

    G_Debug_Mode                        Varchar2(1)    := Nvl(Fnd_Profile.Value('PA_DEBUG_MODE'), 'N');

    -- Begin PA.M/CWK changes
    G_Po_Line_Id			Number         := Null;
    G_Vendor_Id				Number         := Null;
    G_PO_Header_Id			Number         := Null;
    -- End PA.M/CWK changes

    -- Added to support performance change in OTL, when creating billable flag record
    G_Billable_Segment                  HXC_MAPPING_COMPONENTS.SEGMENT%TYPE;

    -- 12i changes
    G_OU_Tbl                        Pa_Txn_Interface_Items_Pkg.OU_Id_Typ;
    G_Current_Org_Id                Number := Pa_Moac_Utils.Get_Current_Org_Id;

-- =======================================================================
-- Start of Comments
-- API Name      : TrackPath
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure tracks the path thru the code to attach to error messages.
--
--  Parameters:
--
--  IN
--    P_Function     -  Varchar2  -- ADD or STRIP
--    P_Value        -  Varchar2
--

/*-------------------------------------------------------------------------*/

   Procedure TrackPath (
        P_Function IN Varchar2,
        P_Value    IN Varchar2)

   Is

	l_Value Varchar2(2000) := '->' || P_Value;

   Begin

	G_Stage := 'Entering procedure TrackPath().';

	If P_Function = 'ADD' Then

		G_Stage := 'TrackPath(): Adding to G_Path.';
		G_Path := G_Path || l_Value;

	ElsIf P_Function = 'STRIP' Then

		G_Stage := 'TrackPath(): Stripping from G_Path.';
		G_Path := Substr(G_Path,1,Instr(G_Path,l_Value) - 1);

	End If;

	G_Stage := 'Leaving procedure TrackPath().';

   Exception
	When Others Then
		Raise;

   End TrackPath;


-- =======================================================================
-- Start of Comments
-- API Name      : Add_Error_To_Table
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure populates the error table for any expected errors.
--
--  Parameters:
--
--  IN
--    P_Message_Table           - Hxc_User_Type_Definition_Grp.Message_Table%TYPE
--    P_Message_Name            - Fnd_New_Messages.Message_Name%TYPE
--    P_Message_Level           - Varchar2
--    P_Message_Field           - Varchar2
--    P_Msg_Tokens              - Pa_Otc_Api.Messages_Tokens
--    P_Time_Building_Block_Id  - Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE
--    P_Time_Attribute_Id       - Hxc_Time_Attributes.Time_Attribute_Id%TYPE
--    P_Message_App             - Varchar2 Default 'PA'
--
-- OUT
--    P_Message_Table           - Hxc_User_Type_Definition_Grp.Message_Table%TYPE
--

/*-------------------------------------------------------------------------*/

    Procedure Add_Error_To_Table(
          P_Message_Table           IN OUT NOCOPY Hxc_User_Type_Definition_Grp.Message_Table, -- 2672653
          P_Message_Name            IN            Fnd_New_Messages.Message_Name%TYPE,
          P_Message_Level           IN            Varchar2,
          P_Message_Field           IN            Varchar2,
		  P_Msg_Tokens              IN            Pa_Otc_Api.Message_Tokens,
          P_Time_Building_Block_Id  IN            Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE,
          P_Time_Attribute_Id       IN            Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
		  P_Message_App             IN            Varchar2 )

    Is

        l_Last_Index Number         := P_Message_Table.Last;
	    l_Tokens     Varchar2(2000) := Null;

    Begin

	    G_Stage := 'Entering Add_Error_To_Table().';
        Pa_Otc_Api.TrackPath('ADD','Add_Error_To_Table');

	    G_Stage := 'Determine Error token count.';
	    If P_Msg_Tokens.Count > 0 Then

 		    G_Stage := 'Get token data if it exists.';
        	For i in P_Msg_Tokens.First .. P_Msg_Tokens.Last
        	Loop

			If l_Tokens is Null Then

				G_Stage := 'Concatenate the token name and token value 1.';
        		l_Tokens := P_Msg_Tokens(i).Token_Name || '&' || P_Msg_Tokens(i).Token_Value;

			Else

				G_Stage := 'Concatenate the token name and token value 2.';
                -- Added appending for l_Tokens for bug 4593869
                l_Tokens := l_Tokens || '&' || P_Msg_Tokens(i).Token_Name || '&' || P_Msg_Tokens(i).Token_Value;

			End If;

        	End Loop;

	    End If;

	    G_Stage := 'Get next available index for error table.';
	    l_Last_Index := Nvl(l_Last_Index,0) + 1;

	    G_Stage := 'Assign message name to error table record.';
	    P_Message_Table(l_last_index).Message_Name := P_Message_Name;

	    G_Stage := 'Assign message level to error table record.';
        P_Message_Table(l_last_index).Message_Level := P_Message_Level;

	    G_Stage := 'Assign message field to error table record.';
        P_Message_Table(l_last_index).Message_Field := P_Message_Field;

	    G_Stage := 'Assign application short name to error table record.';
	    P_Message_Table(l_last_index).Application_Short_Name := P_Message_App;

	    G_Stage := 'Assign token string to error table record.';
	    P_Message_Table(l_last_index).Message_Tokens := l_Tokens;

	    G_Stage := 'Assign Time Building Block Id to error table record.';
        P_Message_Table(l_last_index).Time_Building_Block_Id := P_Time_Building_Block_Id;

	    G_Stage := 'Assign Time Attribute Id to error table record.';
        P_Message_Table(l_last_index).Time_Attribute_Id := P_Time_Attribute_Id;

        G_Stage := 'Leaving Add_Error_To_Table() procedure.';
        Pa_Otc_Api.TrackPath('STRIP','Add_Error_To_Table');

    Exception
	    When Others Then
		    Raise;

    End Add_Error_To_Table;



--  ****   TRX IMPORT PROCEDURES AND FUNCTIONS ****

-- =======================================================================
-- Start of Comments
-- API Name      : Upload_Otc_Timecards
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to pull approved self service
--                 timecards into transaction interface table.  This is an
--                 entry point procedure for the pre_import extension call
--                 from Trx Import.
-- Parameters    :
-- IN
--           P_Transaction_Source: Unique identifier for source of the txn
--           P_Batch: Batch Name to group txns into batches
--           P_Xface_Id: Interface Id
--           P_User_Id: User Id

/*--------------------------------------------------------------------------*/

   Procedure Upload_Otc_Timecards(P_Transaction_Source IN Pa_Transaction_Interface_All.Transaction_Source%TYPE,
                                  P_Batch              IN Pa_Transaction_Interface_All.Batch_Name%TYPE,
                                  P_Xface_Id           IN Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE,
                                  P_User_Id            IN NUMBER) IS

     l_Txn_Rowid            RowId := Null;
     l_Txn_Xface_Id         Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE := NULL;
     l_Where_Clause         Varchar2(2000);
     l_Batch_Name           Pa_Transaction_Interface_All.Batch_Name%TYPE;
     l_Override_Approver_Id Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE;
     l_New_Orig_Trx_Ref     Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE;
     l_Old_Orig_Trx_Ref     Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE;
     l_Insert_Rec_Flag      Boolean := False;
     l_Org_Id               Hr_All_Organization_Units.Organization_Id%TYPE := NULL;
     l_Direct_Update_Flag   Boolean := False;
     l_Comment_Or_Dff       Varchar2(1);
     l_Comment              Varchar2(150);
     l_New_Timecard_Rec     Pa_Otc_Api.Timecard_Rec;
     l_Old_Timecard_Rec     Pa_Otc_Api.Timecard_Rec;
     l_Temp_Timecard_Rec    Pa_Otc_Api.Timecard_Rec := NULL;
     l_Old_Detail_Index     Binary_Integer := 0;
     l_Error_Code           Varchar2(30) := NULL;
     l_dummy                Number := NULL;
     l_Error_Text           Varchar2(2000);

     -- Maximum number of eis to be bulkinserted that is allowed
     L_MAX_RECS_FOR_BULKINSERT          Number := 1000;
     l_ac_termination_date   per_periods_of_service.actual_termination_date%type;  /* Bug 6698171 */

     Function GetVendorId(P_Po_Line_Id in Number) RETURN Number

     Is

	    X_Vendor_Id Number := Null;

     Begin

	    If Nvl(G_Po_Line_Id,-9999999) <> P_Po_Line_Id Then

		    Select
			    h.Vendor_Id
		    Into
			    X_Vendor_Id
		    from
			    PO_Headers_All h,
		     	PO_Lines_All l
		    where
			    l.po_line_Id = P_Po_Line_Id
		    and	l.po_header_id = h.po_header_Id;

		    G_Po_Line_Id := P_Po_Line_Id;
		    G_Vendor_Id  := G_Vendor_Id;

	    End If;

	    Return G_Vendor_Id;

    Exception
	    When Others Then
		     Return Null;

   End GetVendorId;

   Begin

     G_Path := ' ';

     G_Stage := 'Entering Upload_Otc_Timecard(), add procedure to trackpath.';
     If G_Debug_Mode = 'Y' Then
	    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        pa_cc_utils.log_message( Pa_Debug.G_Err_Stage,1);
     End If;
     Pa_Otc_Api.TrackPath('ADD','Upload_Otc_Timecards');

     If G_Processed_Import_Batch is Null Then

        G_Stage := 'Single time process initialization section needed.';
	    If G_Debug_Mode = 'Y' Then
	       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
	       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
	    End If;

	    G_Stage := 'Call BulkInsertReset() procedure for reset.';
	    If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           Pa_Cc_Utils.Log_Message(Pa_Debug.G_Err_Stage,0);
        End If;
        Pa_Otc_Api.BulkInsertReset(P_Command => 'RESET');

	    G_Stage := 'Initialize what remains.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           Pa_Cc_Utils.Log_Message(Pa_Debug.G_Err_Stage,0);
        End If;
        G_Processed_Import_Batch := FALSE;
        G_EndDateBatchName_Table.Delete;
	    G_Unhandled_Except_Cnt := 0;

     End If;

     G_Stage := 'Each time Upload_Otc_Timecards() called initializaion of global variables.';
     If G_Debug_Mode = 'Y' Then
        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
     End If;

     G_Old_Detail_Attr_Index := 0;
     G_Detail_Attr_Index := 0;
     G_Trx_Inserted_Tab.Delete;
     G_Trx_Direct_Upd_Tab.Delete;
     G_Trx_Import_Index := 0;
     Pa_Trx_Import.G_Batch_Size := 0;

     -- PA.M/CWK changes
     G_Po_Line_Id := Null;
     G_Vendor_Id := Null;
     G_PO_Header_Id := Null;

     /* Where clause must restrict the retrieval to the current
      * operating unit if Multi-Org is Implemented for Projects.
      */
     If Pa_Utils.Pa_Morg_Implemented = 'Y' Then

	    G_Stage := 'Create where clause.';
      	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
      	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
      	End If;

        -- 12i MOAC changes
	    -- l_Where_Clause := '[ORG_ID] { = ''' || to_Char(to_Number(SubStr(UserEnv('CLIENT_INFO'),1,10))) ||  ''' }';
        l_Where_Clause := '[ORG_ID] { = ''' || to_Char(G_Current_Org_Id) ||  ''' }';

     Else

	    G_Stage := 'No where clause.';
        If G_Debug_Mode = 'Y' Then
	       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

	    l_Where_Clause := NULL;

     End If;

     /* Pull the data into the OTL pl/sql tables.
      *
      * PL/SQL tables to work with once the procedure execute_retrieval_process is done:
      *      Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks             Using
      *      Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks         Using
      *      Hxc_User_Type_Definition_Grp.T_Detail_Attributes           Using
      *      Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes       Using
      *      Hxc_User_Type_Definition_Grp.T_Day_Bld_Blks                Using for ei date retrieval
      *      Hxc_User_Type_Definition_Grp.T_Old_Day_Bld_Blks            Using for ei date retrieval
      *      Hxc_User_Type_Definition_Grp.T_Day_Attributes              Not Using
      *      Hxc_User_Type_Definition_Grp.T_Old_Day_Attributes          Not Using
      *      Hxc_User_Type_Definition_Grp.T_Time_Bld_Blks               Not Using
      *      Hxc_User_Type_Definition_Grp.T_Old_Time_Bld_Blks           Not Using
      *      Hxc_User_Type_Definition_Grp.T_Time_Attributes             Not Using
      *      Hxc_User_Type_Definition_Grp.T_Old_Time_Attributes         Not Using
      *      Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status            Using
      *      Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception         Using
      */

     G_Stage := 'Call execute retrieval process API.';
     If G_Debug_Mode = 'Y' Then
        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
     End If;
     Hxc_Integration_Layer_V1_Grp.Execute_Retrieval_Process(
		P_Process	   => 'Projects Retrieval Process',
		P_Transaction_code => Null,
		P_Start_Date 	   => Null,
		P_End_Date 	   => Null,
		P_Incremental 	   => 'Y',
		P_Rerun_Flag 	   => 'N',
		P_Where_Clause 	   => l_Where_Clause,
		P_Scope 	   => 'DAY',
		P_Clusive 	   => 'EX');

     If Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks.COUNT > 0 Then

	      Pa_Trx_Import.G_Exit_Main := FALSE;

	      G_Stage := 'Loop thru all hxc detail building block records.';
	      If G_Debug_Mode = 'Y' Then
	           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
	           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
	      End If;
	      For i IN Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks.First .. Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks.Last
	      Loop

	           G_Stage := 'Process bb/ovn: ' || to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id) || ':' ||
			              to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Ovn) ||
		                  ' for Resource_Id(Person_Id): ' || to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Resource_Id);
               Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
               pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);

               Begin

		            G_Stage := 'Primary condition evaluation within the loop.';
                    If G_Debug_Mode = 'Y' Then
                         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                    End If;

		            If Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Changed = 'N' and
		               Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Deleted = 'Y' Then

			             G_Stage := 'Item Changed: N, Deleted: Y.';
			             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
			             pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);


			             -- Even though the building block was deleted prior to being imported into projects
                         -- appearantly attribution data is created and sent via the Generic retrieval process
                         -- via the Generic retrieval process.  Need to sequence thru to position
                         -- the global index variable for the next bb to process.
                         -- Since it was deleted means it does not need to be imported into projects.
			             -- There is also no need to look at the old pl/sql tables records.

			            G_Stage := 'Call Populate Project Record new 1 for positioning purposes only.';
                        If G_Debug_Mode = 'Y' Then
                           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                        End If;

                        Pa_Otc_Api.PopulateProjRec(
                                P_New_Old_BB   => 'NEW',
                                P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id,
                                P_Detail_Index => i,
                                P_Old_Detl_Ind => l_Old_Detail_Index,
                                P_Timecard_Rec => l_New_Timecard_Rec);

                       	Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'SUCCESS';

			            l_insert_rec_flag := FALSE;

		            ElsIf Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Changed = 'N' and
		                  Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Deleted = 'N' Then

			             -- If this is the condition then there is only new data to process via PopulateProjRec() procedure
			             -- and there is no need to look at the old data via the same procedure.

			             G_Stage := 'Item Changed: N, Deleted: N.';
			             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
			             pa_cc_Utils.log_message(Pa_Debug.G_Err_Stage,1);

			             G_Stage := 'Call Populate Project Record new 2.';
		                 If G_Debug_Mode = 'Y' Then
		                      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
		                      pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
		                 End If;

			             Pa_Otc_Api.PopulateProjRec(
                              P_New_Old_BB   => 'NEW',
				              P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id,
				              P_Detail_Index => i,
				              P_Old_Detl_Ind => l_Old_Detail_Index,
                              P_Timecard_Rec => l_New_Timecard_Rec);

			             G_Stage := 'EI data status check 2.';
                         If G_Debug_Mode = 'Y' Then
                             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                             pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                         End If;

			             If l_New_Timecard_Rec.Status is Not Null Then

				              G_Stage := 'New Record Status is not null 2. Timecard status is ' || l_New_Timecard_Rec.Status;
				              If G_Debug_Mode = 'Y' Then
				                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
				                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
				              End If;

				              Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'ERRORS';
				              Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(i) := l_New_Timecard_Rec.Status;
				              l_insert_rec_flag := FALSE;

			             Else

				               G_Stage := 'Create new orig trx ref 2.';
                               If G_Debug_Mode = 'Y' Then
                                    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                               End If;

                               l_new_orig_trx_ref :=
                                        to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id) || ':' ||
                                        to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Ovn);

				               G_Stage := 'Check if original transaction reference already exists 2';
                               If G_Debug_Mode = 'Y' Then
                                    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                               End If;

				               -- Calling the function is a sanity check to confirm that this is solely new data.
				               If NOT Pa_Otc_Api.OrigTrxRefValueExists(l_new_orig_trx_ref) Then

	                                -- Insert a new record.  There should be no records in either
	                        	    -- pl/sql tables t_old_detail_bld_blks or t_old_detail_attributes
	                        	    -- for this building block id.
	                        	    --

	                        	    l_insert_rec_flag := TRUE;

					                G_Stage := 'Call the GetBatchName procedure 2';
	                        	    If G_Debug_Mode = 'Y' Then
	                        	         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
	                        	         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
	                        	    End If;

					                Pa_Otc_Api.GetBatchName(
							             P_Exp_End_Date => l_New_Timecard_Rec.Expenditure_Ending_Date,
					        	         X_Batch_Name   => l_Batch_Name);

				               Else
					                -- This condition result should never happen, but it's here just in case.

					                G_Stage := 'Building block/ovn combo already exists in projects 2.';
                                    If G_Debug_Mode = 'Y' Then
                                         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                                    End If;
					                l_insert_rec_flag := FALSE;
					                Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'SUCCESS';

				               End If;

			             End If;

		            ElsIf Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Changed = 'Y' and
                          Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Deleted = 'N' Then

			             G_Stage := 'Item Changed: Y, Deleted: N.';
			             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
			             pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);

			             l_Old_Detail_Index := l_Old_Detail_Index + 1;

			             G_Stage := 'Create new orig trx ref 3.';
        		         If G_Debug_Mode = 'Y' Then
        		              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		         End If;

			             l_new_orig_trx_ref :=
			                  to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id) || ':' ||
			                  to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Ovn);

			             If NOT Pa_Otc_Api.OrigTrxRefValueExists(l_new_orig_trx_ref) Then

				              G_Stage := 'Call Populate Project Record new 3a.';
        			          If G_Debug_Mode = 'Y' Then
        			               Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			               pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        			          End If;

                        	  Pa_Otc_Api.PopulateProjRec(
                                   P_New_Old_BB   => 'NEW',
					               P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id,
					               P_Detail_Index => i,
					               P_Old_Detl_Ind => l_Old_Detail_Index,
                                   P_timecard_Rec => l_New_Timecard_Rec);

				              G_Stage := 'EI data status check 3a.';
                              If G_Debug_Mode = 'Y' Then
                                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                              End If;

                        	  If l_New_Timecard_Rec.Status is Not Null Then

					               G_Stage := 'New Record Status is not null 3a. Timecard status is ' || l_New_Timecard_Rec.Status;
					               If G_Debug_Mode = 'Y' Then
					                    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
					                    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
					               End If;

                                   Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'ERRORS';
                                   Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(i) := l_New_Timecard_Rec.Status;
					               l_insert_rec_Flag := FALSE;

					               G_Stage := 'Since the Status is not null 3a has been hit for new record, ' ||
						                      'call PopulateProjRec() for old records for positioning ' ||
						                      'purposes only to maintain sync with new pl/sql tables.';
					               If G_Debug_Mode = 'Y' Then
						                Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
						                pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
					               End If;

                                   Pa_Otc_Api.PopulateProjRec(
                                        P_New_Old_BB   => 'OLD',
                                        P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).bb_id,
                                        P_Detail_Index => i,
                                        P_Old_Detl_Ind => l_Old_Detail_Index,
                                        P_timecard_Rec => l_Old_Timecard_Rec);

					               -- We don't care about the handled errors, since using only for positioning
					               -- purposees so we don't check the status after the call to the procedure.

				              Else

					               G_Stage := 'Call Populate Project Record old 3a.';
        				           If G_Debug_Mode = 'Y' Then
        				                Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        				                pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        				           End If;

                        		   Pa_Otc_Api.PopulateProjRec(
                                        P_New_Old_BB   => 'OLD',
						                P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).bb_id,
						                P_Detail_Index => i,
						                P_Old_Detl_Ind => l_Old_Detail_Index,
                                		P_timecard_Rec => l_Old_Timecard_Rec);

                                   If l_Old_Timecard_Rec.Status is Not Null Then

						                G_Stage := 'Old Record Status is not null 3a. Timecard status is ' || l_Old_Timecard_Rec.Status;
						                If G_Debug_Mode = 'Y' Then
						                     Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
						                     pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
						                End If;

                                        Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'ERRORS';
                                        Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(i) := l_Old_Timecard_Rec.Status;
						                l_insert_rec_Flag := FALSE;

					               Else

						                -- Need to find out what has changed to determine whether or not need to
			 			                -- insert record into pa_transaction_interface or update tables
			        		            -- pa_expenditure_comments and/or pa_expenditure_items_all.
						                G_Stage := 'Call Determine Direct Update 3.';
        					            If G_Debug_Mode = 'Y' Then
        					                 Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        					                 pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        					            End If;

						                Pa_Otc_Api.DetermineDirectUpdate(
					      		             P_New_Timecard_Rec   => l_New_Timecard_Rec,
					      		             P_Old_Timecard_Rec   => l_Old_Timecard_Rec,
					      		             P_Direct_Update_Flag => l_direct_update_flag,
					      		             P_Comment_or_Dff     => l_Comment_or_Dff);

						                If l_direct_update_flag Then

							                 l_insert_rec_flag := FALSE;

                                             G_Stage := 'Direct Update of the exp item in projects.  '  ||
                                                        'Need to update (C)omment, (D)ff, (B)oth: ' || l_Comment_or_Dff;
                                             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                             pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);

							                 G_Stage := 'Direct Update get trx ref. by calling GetOrigTrxRef '||
								                        'to use to update the expenditure item.';
							                 If G_Debug_Mode = 'Y' Then
								                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
								                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
							                 End If;

							                 Pa_Otc_Api.GetOrigTrxRef(
                                                  P_Building_Block_Id => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id,
                                                  X_OrigTrxRef        => l_old_orig_trx_ref,
                                                  X_Status            => l_New_Timecard_Rec.Status);

							                 If l_New_Timecard_Rec.Status is not null Then

							                      G_Stage := 'Update hxc exception pl/sql tables 1.';
                                                  If G_Debug_Mode = 'Y' Then
                                                       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                                       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                                                  End If;

							                      Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'ERRORS';
                                        		  Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(i) := l_New_Timecard_Rec.Status;
							                      Raise G_BAD_OTL_DATA;

							                 End If;

							                 G_Stage := 'Call Update Changed Original Txn 3.';
        						             If G_Debug_Mode = 'Y' Then
        						                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        						                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        						             End If;

							                 Pa_Otc_Api.UpdateChangedOrigTxn(
				        			              P_Old_Orig_Txn_Ref => l_old_orig_trx_ref,
               							          P_New_Orig_Txn_Ref => l_new_orig_trx_ref,
               							          P_Comment_or_Dff   => l_comment_or_dff,
               							          P_Timecard_Rec     => l_new_timecard_rec,
               							          P_User_Id          => P_User_Id);

							                 G_Stage := 'Store the Bb_Id and index in pl/sql table for use ' ||
                                                        'in tieback process 3a for directly updated ei.';
                                             If G_Debug_Mode = 'Y' Then
                                                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                                             End If;

                                             G_Trx_Direct_Upd_Tab(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id).BB_Index := i;

						                Else

							                 l_insert_rec_flag := TRUE;

							                 G_Stage := 'Call the GetBatchName procedure 3';
                        				     If G_Debug_Mode = 'Y' Then
                        				          Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        				          pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                        				     End If;

                        				     Pa_Otc_Api.GetBatchName(
								                  P_Exp_End_Date => l_New_Timecard_Rec.Expenditure_Ending_Date,
                                                  X_Batch_Name   => l_Batch_Name);

                        				     G_Stage := 'Get old orig trx ref 3 using the new bb_id/ovn ' || 'combo ' ||
                                   				        to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id) || ':' ||
                                   				        to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Ovn);
							                 If G_Debug_Mode = 'Y' Then
                        				          Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        				          pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                        				     End If;

							                 -- Bug ?
							                 -- Switched from function to procedure to determine if
							                 -- ei is available for adjustment in projects
							                 G_Stage := 'Calling procedure GetOrigTrxRef() Determine if ' ||
								                        'availability of ei for adjusted 1';
							                 If G_Debug_Mode = 'Y' Then
								                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
								                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
							                 End If;

							                 Pa_Otc_Api.GetOrigTrxRef(
							                      P_Building_Block_Id => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id,
							                      X_OrigTrxRef        => l_old_orig_trx_ref,
							                      X_Status            => l_New_Timecard_Rec.Status);

                                             If l_New_Timecard_Rec.Status is not null Then

							                      G_Stage := 'Update hxc exception pl/sql tables 2.';
							                      If G_Debug_Mode = 'Y' Then
								                       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path ||	' :: ' || G_Stage;
								                       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
							                      End If;
                                                  Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'ERRORS';
                                                  Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(i) :=
                                                                                        l_New_Timecard_Rec.Status;
							                      Raise G_BAD_OTL_DATA;

                                             End If;

	                      				     -- l_old_orig_trx_ref :=
                                		     --	Pa_Otc_Api.GetOrigTrxRef(
							                 --	    Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id);

							                 -- End bug enhancement

							                 G_Stage := 'Call Build Reverse Item 3.';
		        				             If G_Debug_Mode = 'Y' Then
        						                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        						                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        						             End If;

							                 Pa_Otc_Api.Build_Reverse_Item(
								                  P_Old_Orig_Trx_Ref        => l_old_orig_trx_ref,
								                  P_New_Orig_Trx_Ref        => l_new_orig_trx_ref,
								                  P_Batch_Name              => l_batch_name,
								                  P_User_Id                 => P_User_Id,
								                  P_Orig_Exp_Txn_Reference1 => l_new_timecard_rec.Orig_Exp_Txn_Reference1,
								                  P_Xface_Id                => P_Xface_Id);

							                 G_Stage := 'Store the Bb_Id and index in pl/sql table for use ' ||
								                        'in tieback process 3b.';
							                 If G_Debug_Mode = 'Y' Then
							                      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
							                      pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
							                 End If;
							                 G_Trx_Inserted_Tab(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id).BB_Index := i;

						                End If; -- l_direct_update_flag

					               End If; -- l_Old_Timecard_Rec.Status

				              End If;  -- l_New_Timecard_Rec.Status

			             Else

			                  -- The bb_id/ovn combo already exists in projects. This happened because
                              -- during the validation of the timecard it was determined that need to
                              -- update the ei record orig_transaction_reference column due to the fact that
                              -- the ovn went up a version but not project specific data has changed.
                              -- When an approved timecard that has already be sent to projects if a ei has
                              -- change of the many that exist in the timecard and no other ei was changed
                              -- and the user decides to click on the "Save for Later" button then all
                              -- eis in OTL timecard get an incremented ovn number and we need to account for this.

		                      G_Stage := 'The bb_id/ovn combo already exists in projects, bypassing BB_Id: ' ||
				                         to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id) ||
                		                 ':' || to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Ovn) ||
		                                 ' for Resource_Id: ' || to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Resource_Id);
		                      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Stage;
		                      pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);

				              G_Stage := 'Call Populate Project Record new 3b for positioning purposes only.';
                              If G_Debug_Mode = 'Y' Then
                                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                              End If;

                              Pa_Otc_Api.PopulateProjRec(
                                   P_New_Old_BB   => 'NEW',
                                   P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id,
                                   P_Detail_Index => i,
                                   P_Old_Detl_Ind => l_Old_Detail_Index,
                                   P_timecard_Rec => l_New_Timecard_Rec);

				              G_Stage := 'Call Populate Project Record old 3b for positioning purposes only.';
                              If G_Debug_Mode = 'Y' Then
                                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                              End If;

                              Pa_Otc_Api.PopulateProjRec(
                                   P_New_Old_BB   => 'OLD',
                                   P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).bb_id,
                                   P_Detail_Index => i,
                                   P_Old_Detl_Ind => l_Old_Detail_Index,
                                   P_timecard_Rec => l_Old_Timecard_Rec);

				              Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'SUCCESS';
				              l_insert_rec_Flag := FALSE;

			             End If;

		            ElsIf Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Changed = 'Y' and
		                  Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Deleted = 'Y' Then

			             -- The item was deleted in OTL after it was imported into Projects.
                         -- Need to Reverse out the original transaction.

			             G_Stage := 'Item Changed: Y, Deleted: Y.';
			             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
			             pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);

			             l_insert_rec_flag := FALSE;
                         l_Old_Detail_Index := l_Old_Detail_Index + 1;

			             G_Stage := 'Create new orig trx ref 4.';
        		         If G_Debug_Mode = 'Y' Then
        		              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		         End If;

                         l_new_orig_trx_ref := to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id) || ':' ||
			                                   to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Ovn);

			             G_Stage := 'Call Populate Project Record new 4.';
                         If G_Debug_Mode = 'Y' Then
                              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                         End If;

                         Pa_Otc_Api.PopulateProjRec(
                              P_New_Old_BB   => 'NEW',
                              P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id,
                              P_Detail_Index => i,
                              P_Old_Detl_Ind => l_Old_Detail_Index,
                              P_timecard_Rec => l_New_Timecard_Rec);

			             G_Stage := 'EI data status check 4.';
                         If G_Debug_Mode = 'Y' Then
                              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                         End If;

                         If l_New_Timecard_Rec.Status is Not Null Then

				              G_Stage := 'Status is not null 4. Timecard status is '  || l_New_Timecard_Rec.Status;
				              If G_Debug_Mode = 'Y' Then
				                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
				                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
				              End If;

                              Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'ERRORS';
                              Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(i) := l_New_Timecard_Rec.Status;

                              G_Stage := 'Since Status is not null 4 occured for new record, call the ' ||
					                     'PopulateProjRec() procedure for the old record for positioning purposes ' ||
					                     'so as to maintain sync with new pl/sql tables.';
                              If G_Debug_Mode = 'Y' Then
                                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                              End If;

                              Pa_Otc_Api.PopulateProjRec(
                                   P_New_Old_BB   => 'OLD',
                                   P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).bb_id,
                                   P_Detail_Index => i,
                                   P_Old_Detl_Ind => l_Old_Detail_Index,
                                   P_timecard_Rec => l_Old_Timecard_Rec);

				              -- We don't check the status column since the only purpose for calling the
				              -- procedure is for positioning index values.

			             Else

				              G_Stage := 'Call the GetBatchName procedure 4';
                        	  If G_Debug_Mode = 'Y' Then
                        	       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        	       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                        	  End If;

                        	  Pa_Otc_Api.GetBatchName(
                                   P_Exp_End_Date => l_New_Timecard_Rec.Expenditure_Ending_Date,
                                   X_Batch_Name   => l_Batch_Name);

				              G_Stage := 'Call Populate Project Record old 4 positioning purposes only.';
                        	  If G_Debug_Mode = 'Y' Then
                        	       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        	       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                        	  End If;

                        	  Pa_Otc_Api.PopulateProjRec(
                                   P_New_Old_BB   => 'OLD',
                                   P_BB_Id        => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).bb_id,
                                   P_Detail_Index => i,
                                   P_Old_Detl_Ind => l_Old_Detail_Index,
                                   P_timecard_Rec => l_Old_Timecard_Rec);

				              -- We are not checking the status column since the call is for positioning purposes only.

                        	  G_Stage := 'Create old orig trx ref 4 using bb_id/ovn ' ||
                          		         to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id) || ':' ||
                          		         to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).Ovn);
				              If G_Debug_Mode = 'Y' Then
                        	       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        	       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                        	  End If;

                              -- Switched from function to procedure to determine if
                              -- ei is available for adjustment in projects

                              G_Stage := 'Calling procedure GetOrigTrxRef() Determine if ' ||
                                         'availability of ei for adjustment 4';
                              If G_Debug_Mode = 'Y' Then
                                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                              End If;

                              Pa_Otc_Api.GetOrigTrxRef(
                                   P_Building_Block_Id => Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id,
                                   X_OrigTrxRef        => l_old_orig_trx_ref,
                                   X_Status            => l_New_Timecard_Rec.Status);

                              If l_New_Timecard_Rec.Status is not null Then

					               G_Stage := 'Updating hxc exception pl/sql tables 3.';
					               If G_Debug_Mode = 'Y' Then
                                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                                   End If;

                                   Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'ERRORS';
                                   Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(i) := l_New_Timecard_Rec.Status;
					               Raise G_BAD_OTL_DATA;

                              End If;

                        	  -- l_old_orig_trx_ref :=
                              -- 	Pa_Otc_Api.GetOrigTrxRef(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id);

				              -- End switch from function to procedure

				              G_Stage := 'Call Build Reverse Item 4.';
        			          If G_Debug_Mode = 'Y' Then
        			               Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			               pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        			          End If;

				              l_error_code := NULL;

                        	  Pa_Otc_Api.Build_Reverse_Item(
                                   P_Old_Orig_Trx_Ref        => l_old_orig_trx_ref,
                                   P_New_Orig_Trx_Ref        => l_new_orig_trx_ref,
                                   P_Batch_Name              => l_batch_name,
					               P_User_id                 => P_User_Id,
					               P_Orig_Exp_Txn_Reference1 => l_New_Timecard_Rec.Orig_Exp_Txn_Reference1,
					               P_Xface_Id                => P_Xface_id);

				              G_Stage := 'Store the Bb_Id and index in pl/sql table for use in tieback process 4.';
				              If G_Debug_Mode = 'Y' Then
				                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
				                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
				              End If;
				              G_Trx_Inserted_Tab(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id).BB_Index := i;

			             End If; -- l_New_Timecard_Rec.Status

		            End If; -- Change/Delete flags

		            If l_insert_rec_flag Then

			             G_Stage := 'Get the next available Transaction Interface Id from sequence.';
        		         If G_Debug_Mode = 'Y' Then
        		              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		         End If;

			             select pa_txn_interface_s.nextval
			             into l_txn_xface_id
			             from dual;

	                     G_Stage := 'Store new/changed Trx Import Rec in pl/sql arrays for BB/Ovn: ' || l_New_Orig_Trx_Ref ||
                                    ' for Resource_Id(Person_Id): ' || to_char(l_New_Timecard_Rec.Incurred_By_Person_Id);
                         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Stage;
	                     pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);

			             G_Stage := 'Store Trx Import record in pl/sql arrays for bulk insert.';
        	             If G_Debug_Mode = 'Y' Then
        		              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	             End If;
/* Bug 6698171 */ if (l_New_Timecard_Rec.Person_Type = 'EMP') then   /* Added if..else for bug 7505424 */
                       patc.check_termination (l_New_Timecard_Rec.Incurred_By_Person_Id, l_New_Timecard_Rec.Expenditure_Item_Date, l_ac_termination_date);
                   else
                       patc.check_termination_for_cwk(l_New_Timecard_Rec.Incurred_By_Person_Id, l_New_Timecard_Rec.Expenditure_Item_Date, l_ac_termination_date);
                   end if;
                   -- following if does validation for employee termination
                   IF l_New_Timecard_Rec.Expenditure_Item_Date <= nvl(l_ac_termination_date, l_New_Timecard_Rec.Expenditure_Item_Date) then

			             G_Trx_Import_Index := G_Trx_Import_Index + 1;

                         G_Txn_Interface_Id_Tbl(G_Trx_Import_Index) := l_txn_xface_id;
                         G_Transaction_Source_Tbl(G_Trx_Import_Index) := 'ORACLE TIME AND LABOR';
                         G_User_Transaction_Source_Tbl(G_Trx_Import_Index) := Null;
                         G_Batch_Name_Tbl(G_Trx_Import_Index) := l_batch_name;
                         G_Expenditure_End_Date_Tbl(G_Trx_Import_Index) := Pa_Utils.NewGetWeekEnding(l_New_Timecard_Rec.Expenditure_Item_Date);
                         G_Person_Bus_Grp_Name_Tbl(G_Trx_Import_Index) := Null;
                         G_Person_Bus_Grp_Id_Tbl(G_Trx_Import_Index) := Null;
                         G_Employee_Number_Tbl(G_Trx_Import_Index) := Null;
                         G_Person_Id_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Incurred_By_Person_Id;
                         G_Organization_Name_Tbl(G_Trx_Import_Index) := Null;
                         G_Organization_Id_Tbl(G_Trx_Import_Index) := Null;
                         G_Expenditure_Item_Date_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Expenditure_Item_Date;
                         G_Project_Number_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Project_Number;
                         G_Project_Id_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Project_Id;
                         G_Task_Number_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Task_Number;
                         G_Task_Id_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Task_Id;
                         G_Expenditure_Type_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Expenditure_Type;
                         G_System_Linkage_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.System_Linkage_Function;
                         G_Non_Labor_Resource_Tbl(G_Trx_Import_Index) := Null;
                         G_Non_Labor_Res_Org_Name_Tbl(G_Trx_Import_Index) := Null;
                         G_Non_Labor_Res_Org_Id_Tbl(G_Trx_Import_Index) := Null;
                         G_Quantity_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Quantity;
                         G_Raw_Cost_Tbl(G_Trx_Import_Index) := Null;
                         G_Raw_Cost_Rate_Tbl(G_Trx_Import_Index) := Null;
                         G_Burden_Cost_Tbl(G_Trx_Import_Index) := Null;
                         G_Burden_Cost_Rate_Tbl(G_Trx_Import_Index) := Null;
                         G_Expenditure_Comment_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Expenditure_Item_Comment;
                         G_Gl_Date_Tbl(G_Trx_Import_Index) := Null;
                         G_Transaction_Status_Code_Tbl(G_Trx_Import_Index) := 'P';
                         G_Trans_Rejection_Code_Tbl(G_Trx_Import_Index) := Null;
                         G_Orig_Trans_Reference_Tbl(G_Trx_Import_Index) := l_New_Orig_Trx_Ref;
                         G_Unmatched_Neg_Txn_Flag_Tbl(G_Trx_Import_Index) := 'Y';
                         G_Expenditure_Id_Tbl(G_Trx_Import_Index) := Null;
                         G_Attribute_Category_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute_Category;
                         G_Attribute1_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute1;
                         G_Attribute2_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute2;
                         G_Attribute3_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute3;
                         G_Attribute4_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute4;
                         G_Attribute5_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute5;
                         G_Attribute6_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute6;
                         G_Attribute7_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute7;
                         G_Attribute8_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute8;
                         G_Attribute9_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute9;
                         G_Attribute10_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Attribute10;
                         G_Dr_Code_Combination_Id_Tbl(G_Trx_Import_Index) := Null;
                         G_Cr_Code_Combination_Id_Tbl(G_Trx_Import_Index) := Null;
                         G_Cdl_System_Reference1_Tbl(G_Trx_Import_Index) := Null;
                         G_Cdl_System_Reference2_Tbl(G_Trx_Import_Index) := Null;
                         G_Cdl_System_Reference3_Tbl(G_Trx_Import_Index) := Null;
                         G_Interface_Id_Tbl(G_Trx_Import_Index) := P_Xface_Id;
                         G_Receipt_Currency_Amount_Tbl(G_Trx_Import_Index) := Null;
                         G_Receipt_Currency_Code_Tbl(G_Trx_Import_Index) := Null;
                         G_Receipt_Exchange_Rate_Tbl(G_Trx_Import_Index) := Null;
                         G_Denom_Currency_Code_Tbl(G_Trx_Import_Index) := Null;
                         G_Denom_Raw_Cost_Tbl(G_Trx_Import_Index) := Null;
                         G_Denom_Burdened_Cost_Tbl(G_Trx_Import_Index) := Null;
                         G_Acct_Rate_Date_Tbl(G_Trx_Import_Index) := Null;
                         G_Acct_Rate_Type_Tbl(G_Trx_Import_Index) := Null;
                         G_Acct_Exchange_Rate_Tbl(G_Trx_Import_Index) := Null;
                         G_Acct_Raw_Cost_Tbl(G_Trx_Import_Index) := Null;
                         G_Acct_Burdened_Cost_Tbl(G_Trx_Import_Index) := Null;
                         G_Acct_Exch_Rounding_Limit_Tbl(G_Trx_Import_Index) := Null;
                         G_Project_Currency_Code_Tbl(G_Trx_Import_Index) := Null;
                         G_Project_Rate_Date_Tbl(G_Trx_Import_Index) := Null;
                         G_Project_Rate_Type_Tbl(G_Trx_Import_Index) := Null;
                         G_Project_Exchange_Rate_Tbl(G_Trx_Import_Index) := Null;
                         G_Orig_Exp_Txn_Reference1_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Orig_Exp_Txn_Reference1;
                         G_Orig_Exp_Txn_Reference2_Tbl(G_Trx_Import_Index) := Null;
                         G_Orig_Exp_Txn_Reference3_Tbl(G_Trx_Import_Index) := Null;
                         G_Orig_User_Exp_Txn_Ref_Tbl(G_Trx_Import_Index) := Null;
                         G_Vendor_Number_Tbl(G_Trx_Import_Index) := Null;
                         G_Vendor_Id_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Vendor_Id; -- PA.M/CWK changes
                         G_Override_To_Org_Name_Tbl(G_Trx_Import_Index) := Null;
                         G_Override_To_Org_Id_Tbl(G_Trx_Import_Index) := Null;
                         G_Reversed_Orig_Txn_Ref_Tbl(G_Trx_Import_Index) := Null;
                         G_Billable_Flag_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Billable_Flag;
                         G_ProjFunc_Currency_Code_Tbl(G_Trx_Import_Index) := Null;
                         G_ProjFunc_Cost_Rate_Date_Tbl(G_Trx_Import_Index) := Null;
                         G_ProjFunc_Cost_Rate_Type_Tbl(G_Trx_Import_Index) := Null;
                         G_ProjFunc_Cost_Exch_Rate_Tbl(G_Trx_Import_Index) := Null;
                         G_Project_Raw_Cost_Tbl(G_Trx_Import_Index) := Null;
                         G_Project_Burdened_Cost_Tbl(G_Trx_Import_Index) := Null;
                         G_Assignment_Name_Tbl(G_Trx_Import_Index) := Null;
                         G_Assignment_Id_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Assignment_Id;
                         G_Work_Type_Name_Tbl(G_Trx_Import_Index) := Null;
                         G_Work_Type_Id_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Work_Type_Id;
                         G_Cdl_System_Reference4_Tbl(G_Trx_Import_Index) := Null;
                         G_Accrual_Flag_Tbl(G_Trx_Import_Index) := Null;
                         G_Last_Update_Date_Tbl(G_Trx_Import_Index) := sysdate;
                         G_Last_Updated_By_Tbl(G_Trx_Import_Index) := P_User_Id;
                         G_Creation_Date_Tbl(G_Trx_Import_Index) := sysdate;
                         G_Created_By_Tbl(G_Trx_Import_Index) := P_User_Id;
			             -- Begin PA.M/CWK changes
			             G_PO_Number_Tbl(G_Trx_Import_Index) := Null;
			             G_PO_Header_Id_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.PO_Header_Id;
			             G_PO_Line_Num_Tbl(G_Trx_Import_Index) := Null;
			             G_PO_Line_Id_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.PO_Line_Id;
			             G_PO_Price_Type_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.PO_Price_Type;
			             G_Person_Type_Tbl(G_Trx_Import_Index) := l_New_Timecard_Rec.Person_Type;
			             -- End PA.M/CWK changes
			             G_Inventory_Item_Id_Tbl(G_Trx_Import_Index) := Null;
			             G_WIP_Resource_Id_Tbl(G_Trx_Import_Index) := Null;
		                 G_Unit_Of_Measure_Tbl(G_Trx_Import_Index) := Null;
                         -- 12i MOAC changes
                         G_OU_Tbl(G_Trx_Import_Index) := G_Current_Org_Id;

			             G_Stage := 'Pl/sql record counter increment.';
                         If G_Debug_Mode = 'Y' Then
                              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                         End If;
			             G_Txn_Rec_Count := nvl(G_Txn_Rec_Count,0) + 1;

			             G_Stage := 'Store the Bb_Id and index in pl/sql table for use in tieback process.';
                         If G_Debug_Mode = 'Y' Then
                              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                         End If;
			             G_Trx_Inserted_Tab(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id).BB_Index := i;

		            End If;

		            G_Stage := 'Check if need to call bulk insert.';
                    If G_Debug_Mode = 'Y' Then
                         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                    End If;
                    If G_Txn_Rec_Count >= L_MAX_RECS_FOR_BULKINSERT Then

			             G_Stage := 'Call BulkInsertReset() procedure for insert.';
                         If G_Debug_Mode = 'Y' Then
                              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                              Pa_Cc_Utils.Log_Message(Pa_Debug.G_Err_Stage,0);
                         End If;
                         Pa_Otc_Api.BulkInsertReset(P_Command => 'INSERT');

			             G_Stage := 'Store total records inserted. Reset counter to 0.';
                         If G_Debug_Mode = 'Y' Then
                              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                              Pa_Cc_Utils.Log_Message(Pa_Debug.G_Err_Stage,0);
                         End If;
                         Pa_Trx_Import.G_Batch_Size := Nvl(Pa_Trx_Import.G_Batch_Size,0) + G_Txn_Rec_Count;
                         G_Txn_Rec_Count := 0;

		            End If;
                   End if;              /* Bug 6698171, End of validation for terminated employee */

               Exception
		            When G_BAD_OTL_DATA Then
                	     Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(i) := 'ERRORS';
                	     Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(i) :=
					     nvl(l_New_Timecard_Rec.Status,l_Old_Timecard_Rec.Status);
                	     G_Unhandled_Except_Cnt := G_Unhandled_Except_Cnt + 1;

			             G_Stage := 'Unhandled exception count is now ' || to_char(G_Unhandled_Except_Cnt);
			             If G_Debug_Mode = 'Y' Then
                              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                              Pa_Cc_Utils.Log_Message(Pa_Debug.G_Err_Stage,0);
                         End If;

                         If G_Unhandled_Except_Cnt > G_EXCEPT_CNT_ALLOWED Then

                              G_Stage := 'Unhandled exceptions count exceeds maximum allowed of ' ||
					                     to_char(G_EXCEPT_CNT_ALLOWED) || '.  Raising user defined exception!';
                              If G_Debug_Mode = 'Y' Then
                                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                                   Pa_Cc_Utils.Log_Message(Pa_Debug.G_Err_Stage,0);
                              End If;

                              Raise HXC_RETRIEVAL_MAX_ERRORS;

			             End If;

		            When Others Then
			             Raise;

	           End;

	           G_Stage := 'Resetting the pl/sql new and old timecard record variables.';
	           If G_Debug_Mode = 'Y' Then
                    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                    Pa_Cc_Utils.Log_Message(Pa_Debug.G_Err_Stage,0);
               End If;
	           l_New_Timecard_Rec := l_Temp_Timecard_Rec;
	           l_Old_Timecard_Rec := l_Temp_Timecard_Rec;

	      End Loop;

	      G_Stage := 'Exited the loop.  Check if need to call bulk insert for any remaining pl/sql records.';
	      If G_Debug_Mode = 'Y' Then
	           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
	           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
	      End If;

	      If G_Txn_Rec_Count > 0 Then

		       G_Stage := 'Call bulk insert for the remaining pl/sql records.';
		       If G_Debug_Mode = 'Y' Then
		            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
		            pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
		       End If;
		       Pa_Otc_Api.BulkInsertReset(P_Command => 'INSERT');

		       G_Stage := 'Set the final records count for the next import phase.  Reset counter.';
               If G_Debug_Mode = 'Y' Then
                    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
               End If;
		       Pa_Trx_Import.G_Batch_Size := Nvl(Pa_Trx_Import.G_Batch_Size,0) + G_Txn_Rec_Count;

		       G_Txn_Rec_Count := 0;

          End If;

	      G_Stage := 'This chunk has ' || to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks.COUNT) ||
	    	         ' records, of which ' || to_char(Pa_Trx_Import.G_Batch_Size) || ' are to be processed' ||
		             ' in the next phase of Trx Import.';
	      If G_Debug_Mode = 'Y' Then
	           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
	           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);
	      End If;

     Else

          G_Stage := 'Last chunk from OTL.  Flag process we are done.  No further records to process.';
	      If G_Debug_Mode = 'Y' Then
               Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
               pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
          End If;

	      Pa_Trx_Import.G_Exit_Main := NULL;
	      Pa_Trx_Import.G_Batch_Size := 0;

	      G_Stage := 'Call Hxc_Generic_Retrieval_Pkg.Update_Transaction_Status() one last time.';
          If G_Debug_Mode = 'Y' Then
               Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
               pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
          End If;
          Hxc_Integration_Layer_V1_Grp.Set_Parent_Statuses;
          Hxc_Integration_Layer_V1_Grp.Update_Transaction_Status
               (P_Process               => 'Projects Retrieval Process',
                P_Status                => 'SUCCESS',
                P_Exception_Description => NULL);

     End If; -- Are there records in the otl pl/sql tables to process

     G_Stage := 'Leaving Upload_Otc_Timecards(), strip procedure from trackpath.';
     If G_Debug_Mode = 'Y' Then
        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);
     End If;
     Pa_Otc_Api.TrackPath('STRIP','Upload_Otc_Timecards');

   Exception

     When HXC_RETRIEVAL_MAX_ERRORS Then

          fnd_message.set_name('HXC','HXC_RET_MAX_ERRORS');
		  l_Error_Text := SUBSTR(fnd_message.get,1,2000);

		  Hxc_Integration_Layer_V1_Grp.Set_Parent_Statuses;
          Hxc_Integration_Layer_V1_Grp.Update_Transaction_Status
               (P_Process               => 'Projects Retrieval Process',
                P_Status                => 'ERRORS',
                P_Exception_Description => l_Error_Text);

          fnd_message.set_name('HXC','HXC_RET_MAX_ERRORS');
          fnd_message.raise_error;

     When Others Then

       	  If ( SQLERRM = 'ORA-20001: HXC_0012_GNRET_NO_TIMECARDS:' or
               SQLERRM = 'ORA-20001: HXC_0013_GNRET_NO_BLD_BLKS:' ) Then

               -- Begin bug 3422899 Customer feedback on this bit of code shows that we should always
               --                   suppress these 2 errors and let the report handle that there
               --                   was no data to process.
               --
               -- The G_Processed_Import_Batch is FALSE then this is the first time thru the Trx
               -- Import loop which would mean we want to raise.  If G_Processed_Import_Batch is TRUE
               -- that meains this is not the first time thru and we would not want to raise an error.
               -- The global variable is set to TRUE at the end of the Tieback_Otc_Timecards() procedure.
               -- If Not G_Processed_Import_Batch Then
               --
               --      Hxc_Integration_Layer_V1_Grp.Set_Parent_Statuses;
               --      Hxc_Integration_Layer_V1_Grp.Update_Transaction_Status
               --                 	(P_Process               => 'Projects Retrieval Process',
               --                  	 P_Status                => 'ERRORS',
               --                  	 P_Exception_Description =>
               --                                 substr('Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage ||
               --                                        ' : ' || SQLERRM, 1, 2000));
               --
		       -- 	  Fnd_Message.Raise_Error;
               --
			   -- End If;

               If SQLERRM = 'ORA-20001: HXC_0012_GNRET_NO_TIMECARDS:' Then

                    fnd_message.set_name('HXC','HXC_0012_GNRET_NO_TIMECARDS');
               Else

                    fnd_message.set_name('HXC','HXC_0013_GNRET_NO_BLD_BLKS');

               End If;
               Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' : ' || fnd_message.get;
               pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);

               -- End bug 3422899

		  Else

               Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' : ' || SQLERRM;
               Hxc_Integration_Layer_V1_Grp.Set_Parent_Statuses;
         	   Hxc_Integration_Layer_V1_Grp.Update_Transaction_Status
             			(P_Process               => 'Projects Retrieval Process',
             			 P_Status                => 'ERRORS',
             			 P_Exception_Description =>
				          substr('Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' : ' || SQLERRM, 1, 2000));
			   Raise;

		  End If;

   End Upload_Otc_Timecards;


-- =======================================================================
-- Start of Comments
-- API Name      : Build_Reverse_Item
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called when need to reverse expenditure_item
--                 already imported into projects and need to create a record to
--                 insert into pa_transaction_interface table for this.
-- Conditions    : 1. Deleted the original item
-- called          2. Changed either project,
--                                   task,
--                                   expenditure_type,
--                                   system_linkage_function,
--                                   quantity
--
-- Parameters    :
-- IN
--           P_Old_Orig_Trx_Ref           Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--           P_New_Orig_Trx_Ref           Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--           P_Batch_Name                 Pa_Transaction_Interface_All.Batch_Name%TYPE
--           P_User_Id                    Pa_Expenditure_Items_All.Last_Updated_By%TYPE
--           P_Orig_Exp_Txn_Reference1    Pa_Expenditures_All.Orig_Exp_Txn_Reference1%TYPE
--           P_Xface_Id                   Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE

/*------------------------------------------------------------------------- */

   Procedure Build_Reverse_Item(
            P_Old_Orig_Trx_Ref        IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE,
	    P_New_Orig_Trx_Ref        IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE,
	    P_Batch_Name              IN Pa_Transaction_Interface_All.Batch_Name%TYPE,
	    P_User_Id                 IN Pa_Expenditure_Items_All.Last_Updated_By%TYPE,
	    P_Orig_Exp_Txn_Reference1 IN Pa_Expenditures_All.Orig_Exp_Txn_Reference1%TYPE,
	    P_Xface_Id                IN Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE )

   Is

      l_txn_rowid           RowId := Null;
      l_txn_xface_id        Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE := Null;

      l_Exp_End_Date        Pa_Expenditures_All.Expenditure_Ending_Date%TYPE;
      l_Inc_By_Org_Id       Hr_Organization_Units.Organization_Id%TYPE;
      l_Exp_Item_Date       Pa_Expenditure_Items_All.Expenditure_Item_Date%TYPE;
      l_Proj_Id             Pa_Projects_All.Project_Id%TYPE;
      l_Task_Id             Pa_Tasks.Task_Id%TYPE;
      l_Exp_Type            Pa_Expenditure_Types.Expenditure_Type%TYPE;
      l_Sys_Link            Pa_Expenditure_Items_All.System_Linkage_Function%TYPE;
      l_Quantity            Pa_Expenditure_Items_All.Quantity%TYPE;
      l_Inc_By_Person_Id    Pa_Expenditures_All.Incurred_By_Person_Id%TYPE;
      l_Attribute_Category  Pa_Expenditure_Items_All.Attribute_Category%TYPE;
      l_Attribute1          Pa_Expenditure_Items_All.Attribute1%TYPE;
      l_Attribute2          Pa_Expenditure_Items_All.Attribute2%TYPE;
      l_Attribute3          Pa_Expenditure_Items_All.Attribute3%TYPE;
      l_Attribute4          Pa_Expenditure_Items_All.Attribute4%TYPE;
      l_Attribute5          Pa_Expenditure_Items_All.Attribute5%TYPE;
      l_Attribute6          Pa_Expenditure_Items_All.Attribute6%TYPE;
      l_Attribute7          Pa_Expenditure_Items_All.Attribute7%TYPE;
      l_Attribute8          Pa_Expenditure_Items_All.Attribute8%TYPE;
      l_Attribute9          Pa_Expenditure_Items_All.Attribute9%TYPE;
      l_Attribute10         Pa_Expenditure_Items_All.Attribute10%TYPE;
      l_Assignment_Id       Pa_Expenditure_Items_All.Assignment_Id%TYPE;
      l_Work_Type_Id        Pa_Expenditure_Items_All.Work_Type_Id%TYPE;
      l_Billable_Flag       Pa_Expenditure_Items_All.Billable_Flag%TYPE;
      l_Exp_Comment         Pa_Expenditure_Comments.Expenditure_Comment%TYPE;
      -- Begin CWK changes PA.M
      l_Person_Type	    Pa_Expenditures_All.Person_Type%TYPE;
      l_PO_Line_Id	    Pa_Expenditure_Items_All.PO_Line_Id%TYPE;
      l_PO_Price_Type	    Pa_Expenditure_Items_All.PO_Price_Type%TYPE;
      l_Vendor_Id	    Pa_Expenditures_All.Vendor_id%TYPE;
      l_PO_Header_Id        Number := Null;
      l_Dummy_Vendor_Id     Number := Null;
      -- End CWK changes PA.M
      -- 12i changes
      l_Org_Id             Number := Null;

   Begin

	G_Stage := 'Enter Build_Reverse_Item().';
    If G_Debug_Mode = 'Y' Then
         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;

	G_Stage := 'Add procedure to track path';
    If G_Debug_Mode = 'Y' Then
	     Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;
    Pa_Otc_Api.TrackPath('ADD','Build_Reverse_Item');

	G_Stage := 'Get needed data to build reversing item phase 1.';
    If G_Debug_Mode = 'Y' Then
         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;

	Select
		EI.Task_Id,
		EI.Project_Id, -- Changed from T.Project_Id
        E.Expenditure_Ending_Date,
		E.Incurred_By_Organization_Id,
		E.Incurred_By_Person_Id,
		EI.Expenditure_Item_Date,
        EI.Expenditure_Type,
		EI.System_Linkage_Function,
		-(EI.quantity),
		EI.Attribute_Category,
		EI.Attribute1,
		EI.Attribute2,
		EI.Attribute3,
		EI.Attribute4,
		EI.Attribute5,
		EI.Attribute6,
		EI.Attribute7,
		EI.Attribute8,
		EI.Attribute9,
		EI.Attribute10,
		EI.Assignment_Id,
		EI.Work_Type_Id,
		EI.Billable_Flag,
		EC.Expenditure_Comment,
		-- Begin CWK changes PA.M
		EI.PO_Line_Id,
		EI.PO_Price_Type,
		E.Person_Type,
		E.Vendor_Id,
		-- End CWK changes PA.M
        -- 12i changes
        ei.org_id
	Into
		l_Task_Id,
		l_Proj_Id,
        l_Exp_End_Date,
		l_Inc_By_Org_Id,
		l_Inc_By_Person_Id,
		l_Exp_Item_Date,
		l_Exp_Type,
		l_Sys_Link,
 		l_Quantity,
		l_Attribute_Category,
		l_Attribute1,
        l_Attribute2,
        l_Attribute3,
        l_Attribute4,
        l_Attribute5,
        l_Attribute6,
        l_Attribute7,
        l_Attribute8,
        l_Attribute9,
        l_Attribute10,
		l_Assignment_Id,
		l_Work_Type_Id,
		l_Billable_Flag,
		l_Exp_Comment,
		-- Begin CWK changes PA.M
		l_PO_Line_Id,
		l_PO_Price_Type,
		l_Person_Type,
		l_Vendor_Id,
		-- End CWK changes PA.M
        -- 12i changes
        l_org_id
	From
		Pa_Expenditure_Items EI,
		Pa_Expenditure_Comments EC,
		Pa_Expenditures E
-- 3457943 S.N.
		--Pa_Tasks T
-- 3457943 E.N.
	Where
-- 3457943 S.N.
		--T.Task_Id = EI.Task_Id
-- 3457943 E.N.
	    	E.Expenditure_Id = EI.Expenditure_Id
	And     EI.Expenditure_Item_Id = EC.Expenditure_Item_Id(+)
	And    	EI.Transaction_Source = 'ORACLE TIME AND LABOR'
	And    	EI.Orig_Transaction_Reference = P_Old_Orig_Trx_Ref
	And     Nvl(EI.Net_Zero_Adjustment_Flag,'N') = 'N'
        And     EI.Adjusted_Expenditure_Item_Id is Null;

	G_Stage := 'Get Transaction Interface Id from sequence for reversing item.';
	If G_Debug_Mode = 'Y' Then
	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
	End If;

        Select Pa_Txn_Interface_S.NextVal
	Into l_Txn_Xface_Id
	From Dual;

	If l_Person_Type = 'CWK' And l_PO_Line_Id Is Not Null Then

	        G_Stage := 'Get Supplier Info by calling GetPOInfo() 2.';
		If G_Debug_Mode = 'Y' Then
	        	Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Stage;
	        	pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);
		End If;

		Pa_Otc_Api.GetPOInfo(
			P_Po_Line_Id    => l_PO_Line_Id,
		      	X_Po_Header_Id  => l_PO_Header_Id,
		      	X_Vendor_Id     => l_Dummy_Vendor_Id);

	End If;

        G_Stage := 'Inserting reversing item into interface table BB/Ovn: ' || P_New_Orig_Trx_Ref ||
                   ' for Resource_Id(Person_Id): ' || to_char(l_Inc_By_Person_Id);
        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Stage;
        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);

	G_Stage := 'Store record for reversing item into arrays for bulk insert later.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

        G_Trx_Import_Index := G_Trx_Import_Index + 1;

        G_Txn_Interface_Id_Tbl(G_Trx_Import_Index) := l_Txn_Xface_Id;
        G_Transaction_Source_Tbl(G_Trx_Import_Index) := 'ORACLE TIME AND LABOR';
        G_User_Transaction_Source_Tbl(G_Trx_Import_Index) := Null;
        G_Batch_Name_Tbl(G_Trx_Import_Index) := P_Batch_Name;
        G_Expenditure_End_Date_Tbl(G_Trx_Import_Index) := l_Exp_End_Date;
        G_Person_Bus_Grp_Name_Tbl(G_Trx_Import_Index) := Null;
        G_Person_Bus_Grp_Id_Tbl(G_Trx_Import_Index) := Null;
        G_Employee_Number_Tbl(G_Trx_Import_Index) := Null;
        G_Person_Id_Tbl(G_Trx_Import_Index) := l_Inc_By_Person_Id;
        G_Organization_Name_Tbl(G_Trx_Import_Index) := Null;
        G_Organization_Id_Tbl(G_Trx_Import_Index) := l_Inc_By_Org_Id;
        G_Expenditure_Item_Date_Tbl(G_Trx_Import_Index) := l_Exp_Item_Date;
        G_Project_Number_Tbl(G_Trx_Import_Index) := Null;
        G_Project_Id_Tbl(G_Trx_Import_Index) := l_Proj_Id;
        G_Task_Number_Tbl(G_Trx_Import_Index) := Null;
        G_Task_Id_Tbl(G_Trx_Import_Index) := l_Task_Id;
        G_Expenditure_Type_Tbl(G_Trx_Import_Index) := l_Exp_Type;
        G_System_Linkage_Tbl(G_Trx_Import_Index) := l_Sys_Link;
        G_Non_Labor_Resource_Tbl(G_Trx_Import_Index) := Null;
        G_Non_Labor_Res_Org_Name_Tbl(G_Trx_Import_Index) := Null;
        G_Non_Labor_Res_Org_Id_Tbl(G_Trx_Import_Index) := Null;
        G_Quantity_Tbl(G_Trx_Import_Index) := l_Quantity;
        G_Raw_Cost_Tbl(G_Trx_Import_Index) := Null;
        G_Raw_Cost_Rate_Tbl(G_Trx_Import_Index) := Null;
        G_Burden_Cost_Tbl(G_Trx_Import_Index) := Null;
        G_Burden_Cost_Rate_Tbl(G_Trx_Import_Index) := Null;
        G_Expenditure_Comment_Tbl(G_Trx_Import_Index) := l_Exp_Comment;
        G_Gl_Date_Tbl(G_Trx_Import_Index) := Null;
        G_Transaction_Status_Code_Tbl(G_Trx_Import_Index) := 'P';
        G_Trans_Rejection_Code_Tbl(G_Trx_Import_Index) := Null;
        G_Orig_Trans_Reference_Tbl(G_Trx_Import_Index) := P_New_Orig_Trx_Ref;
        G_Unmatched_Neg_Txn_Flag_Tbl(G_Trx_Import_Index) := 'N';
        G_Expenditure_Id_Tbl(G_Trx_Import_Index) := Null;
        G_Attribute_Category_Tbl(G_Trx_Import_Index) := l_Attribute_Category;
        G_Attribute1_Tbl(G_Trx_Import_Index) := l_Attribute1;
        G_Attribute2_Tbl(G_Trx_Import_Index) := l_Attribute2;
        G_Attribute3_Tbl(G_Trx_Import_Index) := l_Attribute3;
        G_Attribute4_Tbl(G_Trx_Import_Index) := l_Attribute4;
        G_Attribute5_Tbl(G_Trx_Import_Index) := l_Attribute5;
        G_Attribute6_Tbl(G_Trx_Import_Index) := l_Attribute6;
        G_Attribute7_Tbl(G_Trx_Import_Index) := l_Attribute7;
        G_Attribute8_Tbl(G_Trx_Import_Index) := l_Attribute8;
        G_Attribute9_Tbl(G_Trx_Import_Index) := l_Attribute9;
        G_Attribute10_Tbl(G_Trx_Import_Index) :=l_Attribute10;
        G_Dr_Code_Combination_Id_Tbl(G_Trx_Import_Index) := Null;
        G_Cr_Code_Combination_Id_Tbl(G_Trx_Import_Index) := Null;
        G_Cdl_System_Reference1_Tbl(G_Trx_Import_Index) := Null;
        G_Cdl_System_Reference2_Tbl(G_Trx_Import_Index) := Null;
        G_Cdl_System_Reference3_Tbl(G_Trx_Import_Index) := Null;
        G_Interface_Id_Tbl(G_Trx_Import_Index) := P_Xface_Id;
        G_Receipt_Currency_Amount_Tbl(G_Trx_Import_Index) := Null;
        G_Receipt_Currency_Code_Tbl(G_Trx_Import_Index) := Null;
        G_Receipt_Exchange_Rate_Tbl(G_Trx_Import_Index) := Null;
        G_Denom_Currency_Code_Tbl(G_Trx_Import_Index) := Null;
        G_Denom_Raw_Cost_Tbl(G_Trx_Import_Index) := Null;
        G_Denom_Burdened_Cost_Tbl(G_Trx_Import_Index) := Null;
        G_Acct_Rate_Date_Tbl(G_Trx_Import_Index) := Null;
        G_Acct_Rate_Type_Tbl(G_Trx_Import_Index) := Null;
        G_Acct_Exchange_Rate_Tbl(G_Trx_Import_Index) := Null;
        G_Acct_Raw_Cost_Tbl(G_Trx_Import_Index) := Null;
        G_Acct_Burdened_Cost_Tbl(G_Trx_Import_Index) := Null;
        G_Acct_Exch_Rounding_Limit_Tbl(G_Trx_Import_Index) := Null;
        G_Project_Currency_Code_Tbl(G_Trx_Import_Index) := Null;
        G_Project_Rate_Date_Tbl(G_Trx_Import_Index) := Null;
        G_Project_Rate_Type_Tbl(G_Trx_Import_Index) := Null;
        G_Project_Exchange_Rate_Tbl(G_Trx_Import_Index) := Null;
        G_Orig_Exp_Txn_Reference1_Tbl(G_Trx_Import_Index) := P_Orig_Exp_Txn_Reference1;
        G_Orig_Exp_Txn_Reference2_Tbl(G_Trx_Import_Index) := Null;
        G_Orig_Exp_Txn_Reference3_Tbl(G_Trx_Import_Index) := Null;
        G_Orig_User_Exp_Txn_Ref_Tbl(G_Trx_Import_Index) := Null;
        G_Vendor_Number_Tbl(G_Trx_Import_Index) := Null;
        G_Vendor_Id_Tbl(G_Trx_Import_Index) := l_Vendor_Id; -- PA.M/CWK changes
        G_Override_To_Org_Name_Tbl(G_Trx_Import_Index) := Null;
        G_Override_To_Org_Id_Tbl(G_Trx_Import_Index) := Null;
        G_Reversed_Orig_Txn_Ref_Tbl(G_Trx_Import_Index) := P_Old_Orig_Trx_Ref;
        G_Billable_Flag_Tbl(G_Trx_Import_Index) := l_Billable_Flag;
        G_ProjFunc_Currency_Code_Tbl(G_Trx_Import_Index) := Null;
        G_ProjFunc_Cost_Rate_Date_Tbl(G_Trx_Import_Index) := Null;
        G_ProjFunc_Cost_Rate_Type_Tbl(G_Trx_Import_Index) := Null;
        G_ProjFunc_Cost_Exch_Rate_Tbl(G_Trx_Import_Index) := Null;
        G_Project_Raw_Cost_Tbl(G_Trx_Import_Index) := Null;
        G_Project_Burdened_Cost_Tbl(G_Trx_Import_Index) := Null;
        G_Assignment_Name_Tbl(G_Trx_Import_Index) := Null;
        G_Assignment_Id_Tbl(G_Trx_Import_Index) := l_Assignment_Id;
        G_Work_Type_Name_Tbl(G_Trx_Import_Index) := Null;
        G_Work_Type_Id_Tbl(G_Trx_Import_Index) := l_Work_Type_Id;
        G_Cdl_System_Reference4_Tbl(G_Trx_Import_Index) := Null;
        G_Accrual_Flag_Tbl(G_Trx_Import_Index) := Null;
        G_Last_Update_Date_Tbl(G_Trx_Import_Index) := SysDate;
        G_Last_Updated_By_Tbl(G_Trx_Import_Index) := P_User_Id;
        G_Creation_Date_Tbl(G_Trx_Import_Index) := SysDate;
        G_Created_By_Tbl(G_Trx_Import_Index) := P_User_Id;
	    -- Begin CWK changes PA.M
	    G_PO_Number_Tbl(G_Trx_Import_Index) := Null;
	    G_PO_Header_Id_Tbl(G_Trx_Import_Index) := l_PO_Header_Id;
	    G_PO_Line_Num_Tbl(G_Trx_Import_Index) := Null;
	    G_Person_Type_Tbl(G_Trx_Import_Index) := l_Person_Type;
	    G_PO_Line_Id_Tbl(G_Trx_Import_Index) := l_PO_Line_Id;
	    G_PO_Price_Type_Tbl(G_Trx_Import_Index) := l_PO_Price_Type;
	    -- End CWK changes PA.M
	    G_INVENTORY_ITEM_ID_Tbl(G_Trx_Import_Index) := Null;
	    G_WIP_RESOURCE_ID_Tbl(G_Trx_Import_Index) := Null;
    	G_UNIT_OF_MEASURE_Tbl(G_Trx_Import_Index) := Null;
        -- 12i MOAC changes
        G_OU_Tbl(G_Trx_Import_Index) := l_org_id;

	    G_Txn_Rec_Count := Nvl(G_Txn_Rec_Count,0) + 1;

	    G_Stage := 'About to leave Build_Reverse_Item(), strip procedure from trackpath.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
	    Pa_Otc_Api.TrackPath('STRIP','Build_Reverse_Item');

	G_Stage := 'Leaving Build_Reverse_Item().';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

   Exception
	When others then
		Raise;

   End Build_Reverse_Item;


-- =======================================================================
-- Start of Comments
-- API Name      : UpdateChangedOrigTxn
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to update the expenditure item directly
--                 for an item that has not being reversed but ONLY the
--                 item comment has been changed and/or the DFF has been changed.
--                 No record will be inserted into table pa_transaction_interface.
--
--       Values for parameter P_Comment_or_Dff
--       -------------------------------------
--                 C for Comment
--                 D for Dff
--                 B for Both
--
-- Parameters    :
-- IN            P_Old_Orig_Txn_Ref   - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--               P_New_Orig_Txn_Ref   - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--               P_Comment_Or_Dff     - Varchar2(1)
--               P_Timecard_Rec       - Pa_Otc_Api.Timecard_Rec
--               P_User_Id            - Pa_Expenditure_Items_All.Last_Updated_By%TYPE
--
-- OUT           NONE
--

/*--------------------------------------------------------------------------*/

   Procedure  UpdateChangedOrigTxn(
               P_Old_Orig_Txn_Ref   IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE,
               P_New_Orig_Txn_Ref   IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE,
               P_Comment_Or_Dff     IN Varchar2,
	           P_Timecard_Rec       IN Pa_Otc_Api.Timecard_Rec,
	           P_User_Id            IN Pa_Expenditure_Items_All.Last_Updated_By%TYPE)

   Is

        l_Exp_Item_Id 	    Pa_Expenditure_Items_All.Expenditure_Item_Id%TYPE := Null;
	    l_RowId             RowId;
	    l_Last_Update_Login Pa_Expenditure_Items_All.Last_Update_Login%TYPE := to_Number(Fnd_Profile.Value('LOGIN_ID'));
        --Added for bug 4105561
        x_request_id               NUMBER(15);
        x_program_application_id   NUMBER(15);
        x_program_id               NUMBER(15);

        Cursor CheckExpComment (P_Ei_Id IN Number) Is
        Select
               Count(*)
        From
               Pa_Expenditure_Comments
        Where
               Expenditure_Item_Id = P_Ei_Id;

	    l_Comment_Count     Number := 0;

   Begin

	    G_Stage := 'Entering UpdateChangedOrigTxn(), add procedure to trackpath.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
	    Pa_Otc_Api.TrackPath('ADD','UpdateChangedOrigTxn');

	    G_Stage := 'Get Expenditure Item Id.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

	    Select
		       RowId,
		       Expenditure_Item_Id
	    Into
		       l_RowId,
		       l_Exp_Item_Id
	    From
		       Pa_Expenditure_Items_All
	    Where
		       Transaction_Source = 'ORACLE TIME AND LABOR'
	    And     Orig_Transaction_Reference = P_Old_Orig_Txn_Ref
	    And	Net_Zero_Adjustment_Flag = 'N'; -- Bug 3480159

            --Added for bug 4105561
            X_request_id := FND_GLOBAL.CONC_REQUEST_ID ;
            X_program_id := FND_GLOBAL.CONC_PROGRAM_ID  ;
            X_program_application_id := FND_GLOBAL.PROG_APPL_ID ;

	    /* Though the if clause below requires more code, it is
	     * faster code due to potentially less updates taking place
	     * when P_Comment_Or_Dff has a value of B.
	     */
	    G_Stage := 'What updating needs to be done.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

	    If P_Comment_Or_Dff = 'C' Then

		    G_Stage := 'P_Comment_Or_Dff Is C: Update ei table.';
        	If G_Debug_Mode = 'Y' Then
        	Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

		    Update Pa_Expenditure_Items_All
		    Set Orig_Transaction_Reference = P_New_Orig_Txn_Ref,
		        Last_Updated_By            = P_User_Id,
		        Last_Update_Date           = SysDate,
		        Last_Update_Login          = l_Last_Update_Login,
                        Request_id                 = x_request_id,        --Added for bug 4105561
                        Program_application_id     = x_program_application_id,
                        Program_id                 = x_program_id,
                        Program_update_date        = sysdate
		    Where Rowid = l_RowId ;

		    Open CheckExpComment (P_Ei_Id => l_Exp_Item_Id);
		    Fetch CheckExpComment into l_Comment_Count;
		    Close CheckExpComment;

		    --If l_Comment_Count = 0 Then
		    If (l_Comment_Count = 0 AND P_Timecard_Rec.Expenditure_Item_Comment IS NOT NULL) Then /* Bug 8885514 */

			    G_Stage := 'P_Comment_Or_Dff Is C: Insert record into exp comment table.';
                If G_Debug_Mode = 'Y' Then
                     Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                     pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                End If;

			    Insert into Pa_Expenditure_Comments
			    (  	Expenditure_Item_Id,
 				    Line_Number,
 				    Last_Update_Date,
 				    Last_Updated_By,
 				    Creation_Date,
 				    Created_By,
 				    Expenditure_Comment,
 				    Last_Update_Login,
 				    Request_Id,
 				    Program_Id,
 				    Program_Application_Id,
 				    Program_Update_Date )
			    Values (
				    l_Exp_Item_Id,
				    10,
				    SysDate,
				    P_User_Id,
				    SysDate,
				    P_User_Id,
				    P_Timecard_Rec.Expenditure_Item_Comment,
				    l_Last_Update_Login,
		       		    X_request_id,   --Added for bug 4105561
				    X_program_id,
				    X_program_application_id,
				    sysdate);

		    ElsIf l_Comment_Count > 0 And P_Timecard_Rec.Expenditure_Item_Comment Is Not Null Then  -- Bug 3496762

			    G_Stage := 'P_Comment_Or_Dff Is C: Update exp comment table.';
			    If G_Debug_Mode = 'Y' Then
        		   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		End If;

			    Update Pa_Expenditure_Comments
			    Set Expenditure_Comment   = P_Timecard_Rec.Expenditure_Item_Comment,
			        Last_Updated_By       = P_User_Id,
			        Last_Update_Date      = SysDate,
			        Last_Update_Login     = l_Last_Update_Login,
                                Request_id            = x_request_id,        --Added for bug 4105561
                                Program_application_id= x_program_application_id,
                                Program_id            = x_program_id,
                                Program_update_date   = sysdate
			    Where Expenditure_Item_Id = l_exp_item_id ;

            -- Begin bug 3496762
            ElsIf l_Comment_Count > 0 And P_Timecard_Rec.Expenditure_Item_Comment Is Null Then

                G_Stage := 'P_Comment_Or_Dff Is B: Remove exp comment from table since comment has been updated to null by the user.';
                If G_Debug_Mode = 'Y' Then
                    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                End If;

                Delete From Pa_Expenditure_Comments
                Where Expenditure_Item_Id = l_Exp_Item_Id ;

            -- End bug 3496762
		    End If;

	    ElsIf P_Comment_Or_Dff = 'D' Then

		    G_Stage := 'P_Comment_Or_Dff Is D: Update ei table.';
		    If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

		    Update Pa_Expenditure_Items_All
		    Set Orig_Transaction_Reference = P_New_Orig_Txn_Ref,
		        Attribute_category         = P_Timecard_Rec.Attribute_Category,
		        Attribute1                 = P_Timecard_Rec.Attribute1,
                Attribute2                 = P_Timecard_Rec.Attribute2,
                Attribute3                 = P_Timecard_Rec.Attribute3,
                Attribute4                 = P_Timecard_Rec.Attribute4,
                Attribute5                 = P_Timecard_Rec.Attribute5,
                Attribute6                 = P_Timecard_Rec.Attribute6,
                Attribute7                 = P_Timecard_Rec.Attribute7,
                Attribute8                 = P_Timecard_Rec.Attribute8,
                Attribute9                 = P_Timecard_Rec.Attribute9,
                Attribute10                = P_Timecard_Rec.Attribute10,
	        Last_Updated_By            = P_User_Id,
                Last_Update_Date           = SysDate,
                Last_Update_Login          = l_Last_Update_Login,
                Request_id                 = x_request_id,        --Added for bug 4105561
                Program_application_id     = x_program_application_id,
                Program_id                 = x_program_id,
		Program_update_date        = sysdate
            Where RowId = l_RowId ;

	    ElsIf P_Comment_Or_Dff = 'B' Then

            Open CheckExpComment (P_Ei_Id => l_Exp_Item_Id);
            Fetch CheckExpComment into l_Comment_Count;
            Close CheckExpComment;

            --If l_Comment_Count = 0 Then
            If (l_Comment_Count = 0 AND P_Timecard_Rec.Expenditure_Item_Comment IS NOT NULL) Then /* Bug 8885514 */

                G_Stage := 'P_Comment_Or_Dff Is B: Insert record into exp comment table.';
			    If G_Debug_Mode = 'Y' Then
                    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                End If;

                Insert into Pa_Expenditure_Comments
                (       Expenditure_Item_Id,
                        Line_Number,
                        Last_Update_Date,
                        Last_Updated_By,
                        Creation_Date,
                        Created_By,
                        Expenditure_Comment,
                        Last_Update_Login,
                        Request_Id,
                        Program_Id,
                        Program_Application_Id,
                        Program_Update_Date )
                Values (
                        l_Exp_Item_Id,
                        10,
                        SysDate,
                        P_User_Id,
		        SysDate,
		        P_User_Id,
                        P_Timecard_Rec.Expenditure_Item_Comment,
                        l_Last_Update_Login,
			X_request_id,
			X_program_id,
			X_program_application_id,
			sysdate);

		    ElsIf l_Comment_Count > 0 and P_Timecard_Rec.Expenditure_Item_Comment Is Not Null Then -- Bug 3496762

	            G_Stage := 'P_Comment_Or_Dff Is B: Update exp comment table.';
			    If G_Debug_Mode = 'Y' Then
        		   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		End If;

               	Update Pa_Expenditure_Comments
                Set Expenditure_Comment   = P_Timecard_Rec.Expenditure_Item_Comment,
                	Last_Updated_By       = P_User_Id,
                	Last_Update_Date      = SysDate,
                	Last_Update_Login     = l_Last_Update_Login,
                        Request_id            = x_request_id,        --Added for bug 4105561
                        Program_application_id= x_program_application_id,
                        Program_id            = x_program_id,
                        Program_update_date   = sysdate
                Where Expenditure_Item_Id = l_Exp_Item_Id ;

            -- Begin bug 3496762
            ElsIf l_Comment_Count > 0 and P_Timecard_Rec.Expenditure_Item_Comment Is Null Then

                G_Stage := 'P_Comment_Or_Dff Is B: Remove exp comment from table since comment has been updated to null by the user.';
                If G_Debug_Mode = 'Y' Then
                    Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                End If;

                Delete From Pa_Expenditure_Comments
                Where Expenditure_Item_Id = l_Exp_Item_Id ;

            -- End bug 3496762
		    End If;

            G_Stage := 'P_Comment_Or_Dff Is B: Update ei table.';
		    If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

            Update Pa_Expenditure_Items_All
            Set Orig_Transaction_Reference = P_New_Orig_Txn_Ref,
                Attribute_category         = P_Timecard_Rec.Attribute_Category,
                Attribute1                 = P_Timecard_Rec.Attribute1,
                Attribute2                 = P_Timecard_Rec.Attribute2,
                Attribute3                 = P_Timecard_Rec.Attribute3,
                Attribute4                 = P_Timecard_Rec.Attribute4,
                Attribute5                 = P_Timecard_Rec.Attribute5,
                Attribute6                 = P_Timecard_Rec.Attribute6,
                Attribute7                 = P_Timecard_Rec.Attribute7,
                Attribute8                 = P_Timecard_Rec.Attribute8,
                Attribute9                 = P_Timecard_Rec.Attribute9,
                Attribute10                = P_Timecard_Rec.Attribute10,
                Last_Updated_By            = P_User_Id,
                Last_Update_Date           = SysDate,
                Last_Update_Login          = l_Last_Update_Login,
                Request_id                 = x_request_id,    --Added for bug 4105561
                Program_application_id     = x_program_application_id,
                Program_id                 = x_program_id,
                Program_update_date        = sysdate
            Where RowId = l_RowId ;

	    End If; -- P_Comment_Of_Dff is C or D or B

	    G_Stage := 'Leaving UpdateChangedOrigTxn(), strip procedure from trackpath.';
	    Pa_Otc_Api.TrackPath('STRIP','UpdateChangedOrigTxn');
        If G_Debug_Mode = 'Y' Then
	        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
            pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

   Exception
	When Others Then
		Raise;

   End UpdateChangedOrigTxn;


-- =======================================================================
-- Start of Comments
-- API Name      : Tieback_Otc_Timecards
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to tieback timecards that have been
--                 interfaced to Oracle Projects successfully. This procedure
--                 will stamp the OTL timecard transaction status PL/SQL arrays with the fact that
--                 timecards retrieved have been sucessfully imported.
--                 We do not plan to deal with any exception handling so the transaction exception
--                 arrays will not be used.  This is a entry point from the Trx Import
--                 post_import extension.
--                 We will use the transaction_source and P_Xface_Id and transaction_status_code of 'I'
--                 to pull the data from the interface table for review.
-- Parameters    :
-- IN
--           P_Transaction_source: Unique identifier for source of the txn
--           P_batch: Batch Name to group txns into batches
--           P_xface_id: Interface Id
--           P_user_id: User Id
-- OUT
--   none
/*--------------------------------------------------------------------------*/

   Procedure  Tieback_Otc_Timecards (
				  P_Transaction_Source IN Pa_Transaction_Interface_All.Transaction_Source%TYPE,
                                  P_Batch              IN Pa_Transaction_Interface_All.Batch_Name%TYPE,
                                  P_Xface_Id           IN Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE,
                                  P_User_Id            IN Number)

   Is

	Cursor TrxRecords (P_Interface_Id IN Pa_Transaction_Interface_All.Interface_Id%TYPE) Is
	Select To_Number(Substr(Orig_Transaction_Reference,1,Instr(Orig_Transaction_Reference,':') - 1)) Detail_BB_Id,
	       Transaction_Status_Code,
	       Transaction_Rejection_Code,
	       Txn_Interface_Id,
	       Expenditure_Id,
	       Expenditure_Item_Id,
	       Orig_Transaction_Reference,
	       Person_Id
	From
	       Pa_Transaction_Interface
	Where
	       Interface_Id = P_Interface_Id
	And    Transaction_Source = 'ORACLE TIME AND LABOR'
	And    Transaction_Status_Code in ('I','R')
	And    Pa_Otc_Api.TrxInCurrentChunk(To_Number(Substr(Orig_Transaction_Reference,1,Instr(Orig_Transaction_Reference,':') - 1))) = 'Y'
	Order by 7,3; -- Bug 3355510

	TrxRecord        TrxRecords%ROWTYPE;
	l_Detail_Index   Binary_Integer := Null;
	j                Binary_Integer := Null;

   Begin

	G_Path := ' ';

	G_Stage := 'Entering Tieback_Otc_Timecards().';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           Pa_CC_Utils.Log_Message(Pa_Debug.G_Err_Stage,0);
        End If;
	Pa_Otc_Api.TrackPath('ADD','Tieback_Otc_Timecards');

	G_Stage := 'Open cursor TrxRecords.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

	Open TrxRecords(P_Interface_Id => P_Xface_Id);

	G_Stage := 'Looping thru the Trx Records.';
	Loop

		G_Stage := 'Fetch record from cursor TrxRecs.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

		Fetch TrxRecords Into TrxRecord;
		Exit When TrxRecords%Notfound;

		If TrxRecord.Transaction_Status_Code = 'I' Then

                    G_Stage := 'Update Detail Status to SUCCESS for BB_Id: ' || to_char(TrxRecord.Detail_BB_Id) ||
                               ' Index position is: ' || to_char((G_Trx_Inserted_Tab(TrxRecord.Detail_BB_Id).BB_Index));
		    If G_Debug_Mode = 'Y' Then
                       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                    End If;
		    Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(G_Trx_Inserted_Tab(TrxRecord.Detail_BB_Id).BB_Index) :=
										'SUCCESS';

		ElsIf TrxRecord.Transaction_Status_Code = 'R' Then

                    G_Stage := 'Update Detail Status to ERRORS for BB_Id: ' || to_char(TrxRecord.Detail_BB_Id) ||
                               ' Index position is: ' || to_char((G_Trx_Inserted_Tab(TrxRecord.Detail_BB_Id).BB_Index));
		    If G_Debug_Mode = 'Y' Then
                       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                    End If;

		    /* Since we now have the looping functionality in Trx Import and we can't restrict the cursor
		     * more than it currently is.  We have to make sure that we don't try to update rejected
		     * Trx records from other loops that have already been ran.  They are at a status of 'R'
		     * So we check to first see if it exists in the pl/sql table and then if it does
		     * we update the otl pl/sql table accordingly run.
		     */

                   Hxc_User_Type_Definition_Grp.T_Tx_Detail_Status(G_Trx_Inserted_Tab(TrxRecord.Detail_BB_Id).BB_Index) := 'ERRORS';

		   If TrxRecord.Transaction_Rejection_Code is not null Then

			Fnd_Message.Set_Name('PA', TrxRecord.Transaction_Rejection_Code);
		   	Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(G_Trx_Inserted_Tab(TrxRecord.Detail_BB_Id).BB_Index) :=
 					Substr(Fnd_Message.Get,1,2000);

-- Begin Bug 3355510 Don't needed to explicitly set the value to null with by default it already is.  This was the problem.
--		   Else
--
--		   	Hxc_User_Type_Definition_Grp.T_Tx_Detail_Exception(G_Trx_Inserted_Tab(TrxRecord.Detail_BB_Id).BB_Index) := Null;
-- End Bug 3355510

		   End If;

		End If;

                G_Stage := 'Tieback Results are Bb_Id/Ovn: ' || TrxRecord.Orig_Transaction_Reference ||
                   	   ' Status(I is Success,R is Errors): ' || TrxRecord.Transaction_Status_Code ||
			   ' Exception: ' || TrxRecord.Transaction_Rejection_Code ||
                           ' Resource_Id(Person_Id): ' || TrxRecord.Person_Id ||
                           ' Exp_Id(Null when Errors): ' || to_char(TrxRecord.Expenditure_Id) ||
                           ' Ei_Id(Null when Errors): ' || to_char(TrxRecord.Expenditure_Item_Id);
                Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Stage;
                pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);

	End Loop;

	G_Stage := 'Loop is done so lose cursor TrxRecs.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

	Close TrxRecords;

	G_Stage := 'Update the Transaction_Status_Code for successful transactions in interface table.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

	Update Pa_Transaction_Interface
	Set
              Transaction_Status_Code = 'A'
	Where
              Interface_Id = P_Xface_Id
	And   Transaction_Status_Code = 'I';

	G_Stage := 'Loop thru and flag as success those building blocks where we directly updated the eis.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

	If G_Trx_Direct_Upd_Tab.COUNT > 0 Then

	    Loop

                If j is null then

                         j := G_Trx_Direct_Upd_Tab.First;

		Else

			/* The use of NEXT allows us to avoid going thru pl/sql records that do not exist.
			 * The pl/sql table will likely be sparcely populated and only want to deal with those
			 * records that were inserted.
			 * DO NOT CHANGE THIS SO WE DO NOT GET ANY NO_DATA_FOUND ERRORS.
			 */
			j := G_Trx_Direct_Upd_Tab.Next(j);

                End If;

                G_Stage := 'Update Detail Status to SUCCESS for direct updated ei BB_Id: ' || to_char(j) ||
                           '  Index position is: ' || to_char((G_Trx_Direct_Upd_Tab(j).BB_Index));
		If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                End If;

                Hxc_Generic_Retrieval_Pkg.T_Tx_Detail_Status(G_Trx_Direct_Upd_Tab(j).BB_Index) := 'SUCCESS';
		EXIT when j = G_Trx_Direct_Upd_Tab.Last;

	    End Loop;

	End If;

	G_Stage := 'Call OTL API to update transactions';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

       	Hxc_Integration_Layer_V1_Grp.Set_Parent_Statuses;
	Hxc_Integration_Layer_V1_Grp.Update_Transaction_Status (
				    P_Process               => 'Projects Retrieval Process',
                                    P_Status                => 'SUCCESS',
                                    P_Exception_Description => NULL);

        G_Stage := 'Set the process import looping flag to true since completed at least loop thru.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
	-- G_Processed_Import_Batch effects exception handling in the Upload_Otc_Timecard() procedure.
	-- When G_Processed_Import_Batch is TRUE then the exception handler in Upload_Otc_Timecard()
	-- will ignore 2 HXC exceptions that are thrown when there are no records found by the
	-- HXC Generic Retreival Process to pull for Import.
	G_Processed_Import_Batch := TRUE;

	G_Stage := 'Leaving Tieback_Otc_Timecards(), strip procedure from trackpath.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);
        End If;
	Pa_Otc_Api.TrackPath('STRIP','Tieback_Otc_Timecards');

   Exception
        When Others Then
		Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' : ' || SQLERRM;
                Hxc_Integration_Layer_V1_Grp.Update_Transaction_Status (
                                    P_Process               => 'Projects Retrieval Process',
                                    P_Status                => 'ERRORS',
                                    P_Exception_Description => Pa_Debug.G_err_Stage);
                RAISE;

   End Tieback_Otc_Timecards;

-- =======================================================================
-- Start of Comments
-- API Name      : DetermineDirectUpdate
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure determines if the expenditure item should be updated directly
--               : or if a reversing entry and a new entry neeed to be inserted into table
--               : pa_transaction_interface_all.  This is done by comparing to see what has
--               : actually changed.  If only the dff and/or the item comment has changed and
--               : nothing else then the item should be directly updated.
--
-- Parameters    :
-- IN
--                P_New_Timecard_Rec  - Pa_Otc_Api.Timecard_Rec
--                P_Old_Timecard_Rec  - Pa_Otc_Api.Timecard_Rec
-- OUT
--                P_Direct_Update_Flag - Boolean
--                P_comment_or_dff     - Varchar2
--                   B - Both comment and DFFs
--                   C - Comment only
--                   D - DFFs only
--
/*--------------------------------------------------------------------------*/

  Procedure DetermineDirectUpdate(
			P_New_Timecard_Rec   IN         Pa_Otc_Api.Timecard_Rec,
			P_Old_Timecard_Rec   IN         Pa_Otc_Api.Timecard_Rec,
                        P_Direct_Update_Flag OUT NOCOPY Boolean,
                        P_Comment_Or_Dff     OUT NOCOPY Varchar2) IS

	l_Others_Changed  Boolean := False;
	l_Comment_Changed Boolean := False;
	l_DFFs_Changed    Boolean := False;

  Begin

	G_Stage := 'Entering DetermineDirectUpdate(), add procedure to trackpath.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
	Pa_Otc_Api.TrackPath('ADD','DetermineDirectUpdate');

	If P_New_Timecard_Rec.Project_Id              <> P_Old_Timecard_Rec.Project_Id OR  -- bug 3241052
	   P_New_Timecard_Rec.Task_Id                 <> P_Old_Timecard_Rec.Task_Id OR     -- changed from number to id
	   P_New_Timecard_Rec.Expenditure_Type        <> P_Old_Timecard_Rec.Expenditure_Type OR
	   P_New_Timecard_Rec.Expenditure_Item_Date   <> P_Old_Timecard_Rec.Expenditure_Item_Date OR
	   P_New_Timecard_Rec.System_Linkage_Function <> P_Old_Timecard_Rec.System_Linkage_Function OR
	   P_New_Timecard_Rec.Quantity                <> P_Old_Timecard_Rec.Quantity OR
	   P_New_Timecard_Rec.Billable_Flag           <> P_Old_Timecard_Rec.Billable_Flag OR
           Nvl(P_New_Timecard_Rec.PO_Line_Id,-99999)  <> Nvl(P_Old_Timecard_Rec.PO_Line_Id,-99999) OR
           Nvl(P_New_Timecard_Rec.PO_Price_Type,'-99999') <> Nvl(P_Old_Timecard_Rec.PO_Price_Type,'-99999') Then

		G_Stage := 'Detail has changed.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

		l_Others_Changed := True;

	End If;

	If nvl(P_New_Timecard_Rec.Expenditure_Item_Comment,'-9999999999') <>
						nvl(P_Old_Timecard_Rec.Expenditure_Item_Comment,'-9999999999') Then

		G_Stage := 'Comment has changed.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

		l_Comment_Changed := True;

	End If;

	If nvl(P_New_Timecard_Rec.Attribute_Category,'-9999999999') <>
						       nvl(P_Old_Timecard_Rec.Attribute_Category,'-9999999999') OR
	   nvl(P_New_Timecard_Rec.Attribute1,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute1,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute2,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute2,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute3,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute3,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute4,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute4,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute5,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute5,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute6,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute6,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute7,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute7,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute8,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute8,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute9,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute9,'-9999999999') OR
           nvl(P_New_Timecard_Rec.Attribute10,'-9999999999') <> nvl(P_Old_Timecard_Rec.Attribute10,'-9999999999') Then

		G_Stage := 'DFFs have changed.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

		l_DFFs_Changed := True;

	End If;

	G_Stage := 'Determine change flag value.';

	If l_Others_Changed Then

		G_Stage := 'No Direct Update.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;
		/* No direct update since other columns have been updated besides
		 * the comments and DFFs.
		 */
		P_Direct_Update_Flag := FALSE;

	ElsIf Not l_Others_Changed And (l_Comment_Changed Or l_DFFs_Changed) Then

		/* Looks like the comment or DFFS where updated in
		 * OTL so will do direct updating of the tables instead of
		 * using TRX_IMPORT.
		 */

		G_Stage := 'Direct Update.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

		P_Direct_Update_Flag := TRUE;

		If l_Comment_Changed And l_DFFs_Changed Then

			G_Stage := 'Direct Update - Both.';
			If G_Debug_Mode = 'Y' Then
        		   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		End If;
			/* Update both the comment in the comment table and
			 * the DFFs in the ei table.
			 */
			P_Comment_Or_Dff := 'B';

		ElsIf l_Comment_Changed Then

			G_Stage := 'Direct Update - Comment only.';
			If G_Debug_Mode = 'Y' Then
        		   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		End If;
			/* Only need to update the comment in the comment table */
			P_Comment_Or_Dff := 'C';

		Else

			G_Stage := 'Direct Update - DFFs only.';
			If G_Debug_Mode = 'Y' Then
        		   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		End If;
			/* Only need to update the DFFs in the ei table. */
			P_Comment_Or_Dff := 'D';

		End If;

	End If;

	G_Stage := 'Leaving DetermineDirectUpdate(), strip procedure from trackpath.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
	Pa_Otc_Api.TrackPath('STRIP','DetermineDirectUpdate');

  Exception
	When Others Then
		Raise;

  End DetermineDirectUpdate;


-- =======================================================================
-- Start of Comments
-- API Name      : PopulateProjRec
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure pulls all the data from the OTL pl/sql tables into a projects
--               : oriented structure for easier processing.  It will also get the TIME scope
--               : BB_ID to be stored table pa_expenditures_all.orig_exp_txn_reference1.
--
-- Parameters    :
-- IN
--                P_New_Old_BB   -  Varchar2   Allowed Values:
--						Import values:  'OLD' 'NEW'
--						Validation value:
--                P_BB_Id        -  Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE
--                P_Detail_Index -  Binary_Integer
--                P_Old_Detl_Ind -  Binary_Integer
-- OUT
--                P_Timecard_Rec -  Pa_Otc_Api.Timecard_Rec
--
/*--------------------------------------------------------------------------*/

  Procedure PopulateProjRec(
     P_New_Old_BB   IN         Varchar2,
     P_BB_Id        IN         Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE,
	 P_Detail_Index IN         Binary_Integer,
	 P_Old_Detl_Ind IN         Binary_Integer,
     P_Timecard_Rec OUT NOCOPY Pa_Otc_Api.Timecard_Rec) IS -- 2672653

	l_attribute_category Varchar2(100)    := NULL;
	i                    Binary_Integer;
	j                    Binary_Integer;
	l_Rec_Found          Boolean          := False;
	l_error_text         Varchar2(1800)   := Null;
	l_Status_Code        Varchar2(40)     := Null;
    l_comment_text       VARCHAR2(2000)   := Null; -- bug 5412033

  Begin

	G_Stage := 'Entering PopulateProjRec(), add procedure to trackpath.';
	If G_Debug_Mode = 'Y' Then
	     Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;
	Pa_Otc_Api.TrackPath('ADD','PopulateProjRec');

    G_Stage := 'Set Timecard Rec to NULL.';
	If G_Debug_Mode = 'Y' Then
         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;

	P_Timecard_Rec := Null;

    G_Stage := 'The current Detail Building Block Id being processed is: ' || to_char(P_BB_Id);
	If G_Debug_Mode = 'Y' Then
         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;

	G_Stage := 'Checking if processsing new or old Building Block.';
	If G_Debug_Mode = 'Y' Then
         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;

    If P_New_Old_BB = 'NEW' Then

         G_Stage := 'Get New Detail Building Block data. Inc by person id(Resource Id): ' ||
			        to_char(Hxc_Generic_Retrieval_Pkg.T_Detail_Bld_Blks(P_Detail_Index).Resource_Id);
		 If G_Debug_Mode = 'Y' Then
		      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 P_Timecard_Rec.Incurred_By_Person_Id := Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Resource_Id;

		 G_Stage := 'Get New Detail Building Block data. Quantity: ' ||
                    to_char(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Measure);
		 If G_Debug_Mode = 'Y' Then
		      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 P_Timecard_Rec.Quantity := Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Measure;

         /* begin bug 5412033 */
		 G_Stage := 'Get New Detail Building Block data. Expenditure Item Comment: ' ||
			        Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Comment_Text ||
                    '(End of comment)';
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         G_Stage := 'Assigning comment to local variable.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;
         l_comment_text := Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Comment_Text;

         G_Stage := 'Checking if comment is not null.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         If l_comment_text is not Null Then

              G_Stage := 'The comment is not null so determine the length of comment.';
              If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;

              /* Bug 2930551 If the length of the comment_text is greater than 240 then we should only
                             grab the first 240 characters. */
              -- begin bug 4926265
              -- If length(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Comment_Text) > 240 Then
              -- If lengthb(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Comment_Text) > 240 Then
              If lengthb(l_comment_text) > 240 Then

                   If G_Debug_Mode = 'Y' Then
                        G_Stage := 'Comment_Text length > 240.';
                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                   End If;

                   -- P_Timecard_Rec.Expenditure_Item_Comment :=
                   --      substr(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Comment_Text,1,240);
                   -- P_Timecard_Rec.Expenditure_Item_Comment :=
                   --      substrb(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Comment_Text,1,240);
                   -- end bug 4926265
                   P_Timecard_Rec.Expenditure_Item_Comment := substrb(l_comment_text,1,240);

              Else

                   If G_Debug_Mode = 'Y' Then
                        G_Stage := 'Comment_Text length <= 240.';
                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                   End If;

                   -- P_Timecard_Rec.Expenditure_Item_Comment :=
                   --      Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Comment_Text;
                   P_Timecard_Rec.Expenditure_Item_Comment := l_comment_text;

              End If;

         Else -- l_comment_text is Null

              If G_Debug_Mode = 'Y' Then
                   G_Stage := 'Setting the comment to null.';
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;
              P_Timecard_Rec.Expenditure_Item_Comment := Null;

         End If; -- l_comment_text is not Null
         /* End bug 5412033 */

         G_Stage := 'Get New Detail Building Block data. Exp Item Date, first attempt.';
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 P_Timecard_Rec.Expenditure_Item_Date :=
						TRUNC(Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Start_Time);

		 If P_Timecard_Rec.Expenditure_Item_Date Is Null Then

		      G_Stage := 'Get New Detail Building Block data. Exp Item Date, second attempt.';
			  If G_Debug_Mode = 'Y' Then
			       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
			       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
			  End If;

			  i := 1;

              G_Stage := 'Get New Detail Building Block data. Exp Item Date, via day scope building block.';
			  If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;

			  While   i <= Hxc_User_Type_Definition_Grp.T_Day_Bld_Blks.LAST and NOT l_Rec_Found
              Loop

                   G_Stage := 'Check if the current record is the correct DAY ' ||
					          'record to grab Exp Item Date from.';
                   If G_Debug_Mode = 'Y' Then
                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                   End If;

                   If Hxc_User_Type_Definition_Grp.T_Day_Bld_Blks(i).BB_Id =
					  Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(P_Detail_Index).Parent_BB_Id Then

                        G_Stage := 'Grab the Exp Item Date from new day building block record.';
                        If G_Debug_Mode = 'Y' Then
                             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                             pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                        End If;

                        P_Timecard_Rec.Expenditure_Item_Date := Trunc(Hxc_User_Type_Definition_Grp.T_Day_Bld_Blks(i).Start_Time);
					    l_Rec_Found := TRUE;

                   End If;

				   i := i + 1;

        	  End Loop;

		 End If;  -- P_Timecard_Rec.Expenditure_Item_Date Is Null

         G_Stage := 'Exp Item Date(Detail Building Block Start Time): ' || to_char(P_Timecard_Rec.Expenditure_Item_Date);
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         G_Stage := 'Get Expenditure Ending Date from new building block data.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 If P_Timecard_Rec.Expenditure_Item_Date is not null Then

       	      P_Timecard_Rec.Expenditure_Ending_date :=
			  Pa_Utils.NewGetWeekEnding(P_Timecard_Rec.Expenditure_Item_Date);

		 End If;

		 -- Begin PA.M/CWK changes
		 -- The person type can be returned as null and will be handled later in the code.
		 G_Stage := 'Get Person_Type New.';
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 P_Timecard_Rec.Person_Type := GetPersonType(P_Person_Id => P_Timecard_Rec.Incurred_By_Person_Id,
							                         P_Ei_Date   => P_Timecard_Rec.Expenditure_Item_Date);

         G_Stage := 'New Person_Type: ' || P_Timecard_Rec.Person_Type;
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;
		 -- End PA.M/CWK changes

		 /* Pull data from the new detail_attributes pl/sql table */
		 G_Stage := 'Get NEW detail bb attribution using for loop.';
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         If G_Detail_Attr_Index = 0 Then

              G_Detail_Attr_Index := 1;

         End If;

         i := G_Detail_Attr_Index;

		 G_Stage := 'Looping thru NEW attibution starting at index position: ' || to_char(i) ;
		 If G_Debug_Mode = 'Y' Then
		      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 G_Stage := 'Current position in NEW attribute pl/sql table bb_id value is: ' ||
			        to_char(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).BB_Id);
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 While   i <= Hxc_User_Type_Definition_Grp.T_Detail_Attributes.LAST And
			     Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).BB_Id = P_BB_Id
		 Loop

		      If Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PROJECT_ID' Then

		           G_Stage := 'Retrieved Project Id: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
		           If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

                   P_Timecard_Rec.Project_Id := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'TASK_ID' Then

                   G_Stage := 'Retrieved Task Id: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
				     	     '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Task_Id := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'EXPENDITURE_TYPE' Then

                   G_Stage := 'Retrieved Expenditure Type: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
			 	     	      '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

			       P_Timecard_Rec.Expenditure_Type := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'SYSTEM_LINKAGE_FUNCTION' Then

                   G_Stage := 'Retrieve System Linkage Function: ' ||
                              Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

	               P_Timecard_Rec.System_Linkage_Function := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

      	      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'OVERRIDING_APPROVER_PERSON_ID' Then

                   G_Stage := 'Retrieve Overidding Approver Person Id: ' ||
                              Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

	 		       P_Timecard_Rec.Override_Approver_Person_Id := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'DUMMY PAEXPITDFF CONTEXT' Then

			       /* The value column contains the following format:
			        *   'PAEXPITDFF - <attribute_category>'
			        * So to get the attribute_category out will need to find the position
                    * for ' - ' that is: '<space>-<space>' and then add 3.
			        */

                   G_Stage := 'Get new attribute category: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                   End If;

			       l_attribute_category := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

                   /* Need to check for null so as to avoid the unecessary use of errors using instr
                    * to avoid unhandled exceptions.
                    */

			       G_Stage := 'Get new attribute category, checking if Null.';
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

			       If l_attribute_category is not null Then

			            G_Stage := 'Get new attribute category, Strip out prefix.';
				        If G_Debug_Mode = 'Y' Then
					         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        				     pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		        End If;

        		        P_Timecard_Rec.Attribute_Category := substr(l_attribute_category,instr(l_attribute_category,' - ') + 3);

			       End If;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE1' Then

                   G_Stage := 'Got new attribute1: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

			       P_Timecard_Rec.Attribute1 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE2' Then

                   G_Stage := 'Got new attribute2: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Attribute2 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE3' Then

                   G_Stage := 'Got new attribute3: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Attribute3 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

	          ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE4' Then

                   G_Stage := 'Got new attribute4: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Attribute4 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE5' Then

                   G_Stage := 'Got new attribute5: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
		           If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Attribute5 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE6' Then

                   G_Stage := 'Got new attribute6: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
          	       End If;

        	       P_Timecard_Rec.Attribute6 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE7' Then

                   G_Stage := 'Got new attribute7: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Attribute7 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE8' Then

                   G_Stage := 'Got new attribute8: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Attribute8 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE9' Then

                   G_Stage := 'Got new attribute9: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Attribute9 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PADFFATTRIBUTE10' Then

                   G_Stage := 'Got new attribute10: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.Attribute10 := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'BILLABLE_FLAG' Then

                   G_Stage := 'Got new Billable Flag: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
                              '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

           	       P_Timecard_Rec.Billable_Flag := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      -- Begin PA.M/CWK changes
		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PO LINE ID' Then

                   G_Stage := 'Retrieved Po Line Id: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
					          '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.PO_Line_Id := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Field_Name) = 'PO PRICE TYPE' Then

                   G_Stage := 'Retrieved Po Price Type: ' || Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value ||
					          '  Index position: ' || to_char(i);
			       If G_Debug_Mode = 'Y' Then
			            Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	       End If;

        	       P_Timecard_Rec.PO_Price_Type := Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).Value;

		      -- End PA.M/CWK changes
		      End If;

		      i := i + 1;

		 End Loop;

		 G_Stage := 'Exited loop.  No more NEW attribution for BB_Id. Store the current index position ' ||
			        to_char(i) || ' in global variable.';
		 If G_Debug_Mode = 'Y' Then
		      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 /* Note that variable G_Detail_Attr_Index is already pointing the the next building block.
		  * This is due to the fact that we are using the while/loop structure and only leaving the loop
		  * when the building block ids no longer match or have reach the end of the pl/sql table.
		  */

		 G_Detail_Attr_Index := i;

		 G_Stage := 'Determine why exited loop looking for NEW record attribution.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         If i > Hxc_User_Type_Definition_Grp.T_Detail_Attributes.LAST Then

		      G_Stage := 'Reached last record index position ' ||
			             to_char(Hxc_User_Type_Definition_Grp.T_Detail_Attributes.LAST) || ' ' ||
				         'in NEW attrib pl/sql table.';
              If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;

		 ElsIf Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).BB_Id <> P_BB_Id Then

		      G_Stage := 'P_BB_Id: ' || to_char(P_BB_Id) || ' --  ' ||
				         'BB_Id in NEW attrib pl/sql: ' ||
				         to_char(Hxc_User_Type_Definition_Grp.T_Detail_Attributes(i).BB_Id) || '.  ' ||
				         'They do not match!';
              If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;

		 End If;

		 -- Begin PA.M/CWK changes
         G_Stage := 'Check Person Type is CWK and PO_Line_Id is Not Null New.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 If P_Timecard_Rec.Person_Type = 'CWK' and P_Timecard_Rec.PO_Line_Id is Not Null Then

              G_Stage := 'Calling Pa_Otc_Api.GetPOInfo() procedure New.';
              If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;

			  Pa_Otc_Api.GetPOInfo(
                         P_Po_Line_Id   => P_Timecard_Rec.PO_Line_Id,
				  	     X_PO_Header_Id => P_Timecard_Rec.PO_Header_Id,
				  	     X_Vendor_Id    => P_Timecard_Rec.Vendor_Id);

			  G_Stage := 'Got new Vendor Id: ' || to_char(P_Timecard_Rec.Vendor_Id) || ' based on PO_Line_Id';
			  If G_Debug_Mode = 'Y' Then
			       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	  End If;

		 Else

              G_Stage := 'Set to null po info, vendor_id, and price_type New.';
              If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;
			  P_Timecard_Rec.PO_Line_Id := NULL;
			  P_Timecard_Rec.PO_Header_Id := NULL;
			  P_Timecard_Rec.Vendor_Id := NULL;
			  P_Timecard_Rec.PO_Price_Type := NULL;

		 End If;
		 -- End PA.M/CWK changes

    Elsif P_New_Old_BB = 'OLD' Then

		 G_Stage := 'Got Old Detail Building Block data. Incurred by Person Id(Resource Id): ' ||
			        to_char(Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Resource_Id);
		 If G_Debug_Mode = 'Y' Then
		      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         P_Timecard_Rec.Incurred_By_Person_Id := Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Resource_Id;

         G_Stage := 'Got Old Detail Building Block data. Incurred by Person Id';
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         G_Stage := 'Got Old Detail Building Block data. Quantity: ' ||
			        to_char(Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Measure);
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         P_Timecard_Rec.Quantity := Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Measure;

         /* Begin bug 5412033 */
		 G_Stage := 'Get Old Detail Building Block data. Expenditure Item Comment: ' ||
			        Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Comment_Text ||
                    '(End of comment)';
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         G_Stage := 'Assigning Old comment to local variable.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;
         l_comment_text := Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Comment_Text;

         G_Stage := 'Checking if Old comment is not null.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         If l_comment_text is not Null Then

              G_Stage := 'The old comment is not null so determine the length of comment.';
              If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;

              /* Bug 2930551 If the length of the comment_text is greater than 240 then we should only
                             grab the first 240 characters. */
              -- begin bug 4926265
              -- If length(Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Comment_Text) > 240 Then
              -- If lengthb(Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Comment_Text) > 240 Then
              If lengthb(l_comment_text) > 240 Then

                   If G_Debug_Mode = 'Y' Then
                        G_Stage := 'Old Comment_Text length > 240.';
                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                   End If;

                   -- P_Timecard_Rec.Expenditure_Item_Comment :=
                   --      substr(Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Comment_Text,1,240);
                   -- P_Timecard_Rec.Expenditure_Item_Comment :=
                   --      substrb(Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Comment_Text,1,240);
                   -- end bug 4926265
                   P_Timecard_Rec.Expenditure_Item_Comment := substrb(l_comment_text,1,240);

              Else

                   If G_Debug_Mode = 'Y' Then
                        G_Stage := 'Old Comment_Text length <= 240.';
                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                   End If;

                   -- P_Timecard_Rec.Expenditure_Item_Comment :=
                   --      Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Comment_Text;
                   P_Timecard_Rec.Expenditure_Item_Comment := l_comment_text;

              End If;

         Else -- l_comment_text is null

              If G_Debug_Mode = 'Y' Then
                   G_Stage := 'Setting the Old comment to null.';
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;
              P_Timecard_Rec.Expenditure_Item_Comment := Null;

         End If; -- l_comment_text is not Null
         /* End Bug 5412033 */

         G_Stage := 'Get Old Day Building Block data. Exp Item Date. First Attempt.';
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 P_Timecard_Rec.Expenditure_Item_Date := Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Start_Time;

		 If P_Timecard_Rec.Expenditure_Item_Date Is Null Then

		      G_Stage := 'Get Old Day Building Block data. Exp Item Date. Second Attempt.';
			  If G_Debug_Mode = 'Y' Then
			       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
			       pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
			  End If;

			  j := 1;

              G_Stage := 'Get Old Detail Building Block data. Exp Item Date, via old day scope building block.';
			  If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
              End If;

              While   j <= Hxc_User_Type_Definition_Grp.T_Old_Day_Bld_Blks.LAST and NOT l_Rec_Found
              Loop

                   G_Stage := 'Check if the current record is the correct DAY ' ||
				              'record to grab Exp Item Date from.';
                   If G_Debug_Mode = 'Y' Then
                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                   End If;

                   If Hxc_User_Type_Definition_Grp.T_Day_Bld_Blks(j).BB_Id =
				      Hxc_User_Type_Definition_Grp.T_Old_Detail_Bld_Blks(P_Old_Detl_Ind).Parent_BB_Id Then

                        G_Stage := 'Grab the Exp Item Date from old day building block record.';
                        If G_Debug_Mode = 'Y' Then
                             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        	 pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                        End If;

                        P_Timecard_Rec.Expenditure_Item_Date := Trunc(Hxc_User_Type_Definition_Grp.T_Old_Day_Bld_Blks(j).Start_Time);
					    l_Rec_Found := TRUE;

                   End If;

				   j := j + 1;

              End Loop;

		 End If;

         G_Stage := 'Exp Item Date(Detail Building Block Start Time): ' || to_char(P_Timecard_Rec.Expenditure_Item_Date);
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         G_Stage := 'Get Expenditure Ending Date for old building block data.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         P_Timecard_Rec.Expenditure_Ending_date := Pa_Utils.NewGetWeekEnding(P_Timecard_Rec.Expenditure_Item_Date);

		 G_Stage := 'Old Index check and assignment for use in loop';
		 If G_Debug_Mode = 'Y' Then
		      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	  Pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 -- Begin PA.M/CWK changes
		 -- The person type can be returned as null and will be handled later in the code.
		 G_Stage := 'Get Person_Type old.';
		 If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

		 P_Timecard_Rec.Person_Type := GetPersonType(P_Person_Id => P_Timecard_Rec.Incurred_By_Person_Id,
							                         P_Ei_Date   => P_Timecard_Rec.Expenditure_Item_Date);

         G_Stage := 'Old Person_Type: ' || P_Timecard_Rec.Person_Type;
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;
		 -- End PA.M/CWK changes

         If G_Old_Detail_Attr_Index = 0 Then

              G_Old_Detail_Attr_Index := 1;

         End If;

         j := G_Old_Detail_Attr_Index;

         /* Pull data from the detail_attributes pl/sql table */
         G_Stage := 'Looping thru OLD attibution starting at index position: ' || to_char(j) ;
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              Pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         G_Stage := 'Current position in OLD attribute pl/sql table bb_id value: ' ||
                    to_char(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).BB_Id);
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
              pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         While   j <= Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes.LAST and
			     Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).BB_Id = P_BB_Id
         Loop

              If Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PROJECT_ID' Then

			       G_Stage := 'Got old Project Id: ' || Hxc_Generic_Retrieval_Pkg.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Project_Id := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

              ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'TASK_ID' Then

			       G_Stage := 'Got old Task Id: ' || Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Task_Id := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

              ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'EXPENDITURE_TYPE' Then

				   G_Stage := 'Got old Expenditure Type: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Expenditure_Type := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

              ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'SYSTEM_LINKAGE_FUNCTION' Then

				   G_Stage := 'Got old System Linkage Function: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.System_Linkage_Function := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

              ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'OVERRIDING_APPROVER_PERSON_ID' Then

				   G_Stage := 'Got old Overriding Approver Person Id: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Override_Approver_Person_Id := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

              ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'DUMMY PAEXPITDFF CONTEXT' Then

                   /* The value column contains the following format:
                    *   'PAEXPITDFF - <attribute_category>'
                    * So to get the attribute_category out will need to find the position
                    * for ' - ' that is: '<space>-<space>' and then add 3.
                    */

                   G_Stage := 'Get old attribute category info: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
                        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                        pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                   End If;

				   l_attribute_category := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

				   /* Need to check for null to avoid the unecessary errors using instr
                    * avoiding unhandled exceptions.
                    */
				   G_Stage := 'Get old attribute category, checking if Null.'|| to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   If l_attribute_category is not null Then

				        G_Stage := 'Get old attribute category, Strip out prefix.'|| to_char(j);
					    If G_Debug_Mode = 'Y' Then
					         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        				     pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        				End If;

                        P_Timecard_Rec.Attribute_Category := substr(l_attribute_category,instr(l_attribute_category,' - ') + 3);

                   End If;

              ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE1' Then

				   G_Stage := 'Got old Attribute1: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute1 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

              ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE2' Then

				   G_Stage := 'Got old Attribute2: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute2 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

              ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE3' Then

				   G_Stage := 'Got old Attribute3: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute3 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE4' Then

				   G_Stage := 'Got old Attribute4: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute4 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE5' Then

				   G_Stage := 'Got old Attribute5: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute5 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE6' Then

				   G_Stage := 'Got old Attribute6: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute6 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE7' Then

				   G_Stage := 'Got old Attribute7: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute7 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE8' Then

				   G_Stage := 'Got old Attribute8: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute8 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE9' Then

				   G_Stage := 'Got old Attribute9: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute9 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PADFFATTRIBUTE10' Then

				   G_Stage := 'Got old Attribute10: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Attribute10 := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'BILLABLE_FLAG' Then

				   G_Stage := 'Got old Billable Flag: ' ||
                              Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					          '  Index position: ' || to_char(j);
				   If G_Debug_Mode = 'Y' Then
				        Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			    pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		   End If;

                   P_Timecard_Rec.Billable_Flag := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

			 -- Begin PA.M/CWK changes
             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PO LINE ID' Then

			      G_Stage := 'Got old Po Line Id: ' ||
                             Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					         '  Index position: ' || to_char(j);
				  If G_Debug_Mode = 'Y' Then
				       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		  End If;

                  P_Timecard_Rec.PO_Line_Id := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

             ElsIf Upper(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Field_Name) = 'PO PRICE TYPE' Then

			      G_Stage := 'Got old PO Price Type: ' ||
                             Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value ||
					         '  Index position: ' || to_char(j);
				  If G_Debug_Mode = 'Y' Then
				       Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        			   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		  End If;

                  P_Timecard_Rec.PO_Price_Type := Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).Value;

			 -- End PA.M/CWK changes
             End If;

			 j := j + 1;

        End Loop;

        G_Stage := 'Exited loop.  No more OLD attribution for BB_Id. Store the current index position ' ||
                   to_char(j) || ' in global variable.';
		If G_Debug_Mode = 'Y' Then
		     Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	 pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

        /* Note that variable G_Old_Detail_Attr_Index is already pointing the the next building block.
         * This is due to the fact that we are using the while/loop structure and only leaving the loop
         * when the building block ids no longer match or have reach the end of the pl/sql table.
         */

		G_Old_Detail_Attr_Index := j;

        G_Stage := 'Determine why exited loop while looking for OLD record attribution.';
        If G_Debug_Mode = 'Y' Then
             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
             pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

        If j > Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes.LAST Then

		     G_Stage := 'Reached last record index position ' ||
                        to_char(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes.LAST) || ' ' ||
                        'in OLD attrib pl/sql table.';
             If G_Debug_Mode = 'Y' Then
                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
             End If;

        ElsIf Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).BB_Id <> P_BB_Id Then

             G_Stage := 'P_BB_Id: ' || to_char(P_BB_Id) || ' --  ' ||
                        'BB_Id in OLD attrib pl/sql: ' ||
                        to_char(Hxc_User_Type_Definition_Grp.T_Old_Detail_Attributes(j).BB_Id) || '.  ' ||
				        'They do not match!';
             If G_Debug_Mode = 'Y' Then
                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
             End If;

        End If;

		-- Begin PA.M/CWK changes
        G_Stage := 'Check if P_Timecard_Rec.Person_Type is CWK and PO_Line_Id Is Not Null old.';
        If G_Debug_Mode = 'Y' Then
             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
             pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
		If P_Timecard_Rec.Person_Type = 'CWK' and P_Timecard_Rec.PO_Line_Id Is Not Null Then

             G_Stage := 'Calling Pa_Otc_Api.GetPOInfo() procedure old.';
             If G_Debug_Mode = 'Y' Then
                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
             End If;

			 Pa_Otc_Api.GetPOInfo(
                         P_Po_Line_Id   => P_Timecard_Rec.PO_Line_Id,
				  	     X_PO_Header_Id => P_Timecard_Rec.PO_Header_Id,
				  	     X_Vendor_Id    => P_Timecard_Rec.Vendor_Id);

			 G_Stage := 'Got old Vendor Id: ' || to_char(P_Timecard_Rec.Vendor_Id) || ' based on PO_Line_Id';
			 If G_Debug_Mode = 'Y' Then
			      Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	 End If;

		Else

             G_Stage := 'Set po infor, vendor_id and price_type to null old.';
             If G_Debug_Mode = 'Y' Then
                  Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
             End If;

			 P_Timecard_Rec.PO_Line_Id := NULL;
			 P_Timecard_Rec.PO_Header_Id := NULL;
			 P_Timecard_Rec.Vendor_Id := NULL;
			 P_Timecard_Rec.PO_Price_Type := NULL;

		End If;
		-- End PA.M/CWK changes

    End If;

    G_Stage := 'Checking that needed data was retrieved to properly process building block for import.';
    If G_Debug_Mode = 'Y' Then
	     Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
	     pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;

    If P_Timecard_Rec.Project_Id is null and
       P_Timecard_Rec.Task_Id is null and
       P_Timecard_Rec.Expenditure_Type is null and
       P_Timecard_Rec.System_Linkage_Function is null and
       P_Timecard_Rec.Quantity is null and
       P_Timecard_Rec.Incurred_By_Person_Id is null and
       P_Timecard_Rec.Expenditure_Item_Date is null and
       P_Timecard_Rec.Expenditure_Ending_Date is null and
       P_Timecard_Rec.Billable_Flag is null and
	   P_Timecard_Rec.Person_Type is null Then   -- CWK changes PA.M

         l_Status_Code := 'HXC_RET_NO_TIMECARD_DATA';

	     If P_New_Old_BB = 'OLD' Then

		      l_Status_Code := 'HXC_RET_NO_TIMECARD_DATA_OLD';

		 End If;

		 fnd_message.set_name('HXC', l_Status_Code);
		 P_Timecard_Rec.Status := SubStr(Fnd_Message.Get,1,2000);

    Elsif P_Timecard_Rec.Project_id is null and
          P_Timecard_Rec.Task_id is null and
	      P_Timecard_Rec.Expenditure_Type is null and
	      P_Timecard_Rec.System_Linkage_Function is null and
	      P_Timecard_Rec.Billable_flag is null and
	      P_Timecard_Rec.Person_Type is null Then   -- CWK changes PA.M

		 l_Status_Code := 'HXC_RET_NO_ATT_DATA';

		 If P_New_Old_BB = 'OLD' Then

		      l_Status_Code := 'HXC_RET_NO_ATT_DATA_OLD';

		 End If;
		 fnd_message.set_name('HXC',l_Status_Code);
		 fnd_message.set_token('STAGE', '1');
		 P_Timecard_Rec.Status := SubStr(Fnd_Message.Get,1,2000);

    ElsIf P_Timecard_Rec.Quantity is null or
          P_Timecard_Rec.Incurred_By_Person_Id is null or
          P_Timecard_Rec.Expenditure_Item_Date is null Then

         l_Status_Code := 'HXC_RET_NO_BLD_BLK_DATA';

		 If P_New_Old_BB = 'OLD' Then

		      l_Status_Code := 'HXC_RET_NO_BLD_BLK_DATA_OLD';

		 End If;
		 fnd_message.set_name('HXC',l_Status_Code);
		 fnd_message.set_token('STAGE', '1');
		 P_Timecard_Rec.Status := SubStr(Fnd_Message.Get,1,2000);

    ElsIf  P_Timecard_Rec.Billable_flag is null or
           P_Timecard_Rec.Project_id is null or
           P_Timecard_Rec.Task_id is null or
           P_Timecard_Rec.Expenditure_Type is null or
           P_Timecard_Rec.System_Linkage_Function is null  or
	       (P_Timecard_Rec.Person_Type = 'CWK' and              -- CWK changes PA.M
            P_Timecard_Rec.PO_Line_Id is Not Null  and          -- CWK changes PA.M  -- Bug 3643126
		   (P_Timecard_Rec.PO_Price_Type is Null or	            -- CWK changes PA.M
		    P_Timecard_Rec.Vendor_Id Is Null)) or               -- CWK changes PA.M
	       P_Timecard_Rec.Person_Type is NULL Then              -- CWK changes PA.M

		 l_Status_Code := 'HXC_RET_NO_ATT_DATA';

		 If P_New_Old_BB = 'OLD' Then

		      l_Status_Code := 'HXC_RET_NO_ATT_DATA_OLD';

		 End If;
		 fnd_message.set_name('HXC',l_Status_Code);
		 fnd_message.set_token('STAGE', '2');
		 P_Timecard_Rec.Status := SubStr(Fnd_Message.Get,1,2000);

    End If;

    G_Stage := 'Leaving PopulateProjRec(), strip procedure from trackpath.';
    If G_Debug_Mode = 'Y' Then
         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
    End If;
    Pa_Otc_Api.TrackPath('STRIP','PopulateProjRec');

  Exception
    When Others Then
	     l_error_text := SubStr('Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' --  ' || SqlErrM, 1, 1800);
		 fnd_message.set_name('HXC', 'HXC_RET_UNEXPECTED_ERROR');
		 fnd_message.set_token('ERR', l_Error_Text);
		 P_Timecard_Rec.Status := SubStr(Fnd_Message.Get,1,2000);

         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := P_Timecard_Rec.Status;
           	  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
         End If;

         l_error_text := 'Leaving PopulateProjRec() due to unhandled exception, strip procedure from trackpath.';
         If G_Debug_Mode = 'Y' Then
              Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || l_error_text;
           	  pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
       	 End If;
         Pa_Otc_Api.TrackPath('STRIP','PopulateProjRec');

		 Raise G_BAD_OTL_DATA;

  End PopulateProjRec;

-- ========================================================================
-- Start Of Comments
-- API Name      : GetDetailIndex
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure finds the Index located in the detail pl/sql
--                 Hxc_Generic_Retrieval_Pkg.T_Detail_Bld_Blks table generated
--                 during the generic retrieval process for the
--                 Building_Block_Id that is passed in to it.
--
-- Parameters    :
-- IN
--               P_Detail_BB_Id  - Hxc_Time_Building_Blocks.Resource_Id%TYPE
-- OUT
--               X_Detail_Index  - Binary_Integer

/*--------------------------------------------------------------------------*/


   Procedure GetDetailIndex( P_Detail_BB_Id IN         Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE,
                             X_Detail_Index OUT NOCOPY Binary_Integer)

   Is

   Begin

        G_Stage := 'Entering procedure GetDetailIndex(), add procedure to trackpath.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
        Pa_Otc_Api.TrackPath('ADD','GetDetailIndex');

        G_Stage := 'Begin loop searching for the matching BB_Id.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;

        For i in Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks.FIRST .. Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks.LAST
        Loop

                G_Stage := 'Determine if BB_Id in the pl/sql matches the one provided.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

                If Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks(i).BB_Id = P_Detail_BB_Id Then

                        G_Stage := 'Set Index to use since found the one needed.';
			If G_Debug_Mode = 'Y' Then
        		   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		End If;

                        X_Detail_Index := i;

                        G_Stage := 'Exiting the loop since found the index needed.';
			If G_Debug_Mode = 'Y' Then
        		   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        		   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        		End If;

                        EXIT;

                End If;

        End Loop;

        G_Stage := 'Leaving procedure GetDetailIndex().';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
        Pa_Otc_Api.TrackPath('STRIP','GetDetailIndex');

   Exception
        When Others Then
                Raise;

   End GetDetailIndex;




/* UPDATE and VALIDATION ROUTINES */

-- ========================================================================
-- Start Of Comments
-- API Name      : Projects_Retrieval_Process
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Function
-- Return        : Varchar2
-- Function      : This function is called to provide the retrieval process name so that the appropriate
--                 attribution is retrieved for validation.
--

/*--------------------------------------------------------------------------*/


   Function Projects_Retrieval_Process RETURN Varchar2

   Is

        l_retrieval_process Hxc_Time_Recipients.Application_Retrieval_Function%TYPE;

   Begin

        l_retrieval_process := 'Projects Retrieval Process';

        Return l_retrieval_process;

   End Projects_Retrieval_Process;


-- =======================================================================
-- Start of Comments
-- API Name      : Update_Otc_Data
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the OTL client team server-side
--                 non-user data modification section of their code.
--                 The only intent of the Procedure is get the data in Hxc and
--                 then call the Private procedure Update_Process() to update the
--                 Billable_flag when appropriate.  Then sent the changes back to Hxc.
--
-- Parameters    :
-- IN
--           P_operation            -  Varchar2

/*------------------------------------------------------------------------- */

  Procedure Update_Otc_Data
            (P_Operation            IN Varchar2)

  Is

	l_Blocks     Hxc_User_Type_Definition_Grp.Timecard_Info;
	l_Attributes Hxc_User_Type_Definition_Grp.App_Attributes_Info;
	l_Messages   Hxc_User_Type_Definition_Grp.Message_Table;

  Begin

	G_Path := ' ';

        G_Stage := 'Entering Update_Otc_Data() procedure.';
        Pa_Otc_Api.TrackPath('ADD','Update_Otc_Data');

	If P_Operation <> 'MIGRATION' Then

		G_Stage := 'Call Hxc_Integration_Layer_V1_Grp.Get_App_Hook_Params()';
        	Hxc_Integration_Layer_V1_Grp.Get_App_Hook_Params(
                        		P_Building_Blocks => l_Blocks,
                        		P_App_Attributes  => l_Attributes,
                        		P_Messages        => l_Messages);

		G_Stage := 'Call the Upate_Process() to update the billable flag.';
		Pa_Otc_Api.Update_Process (
					P_Operation       => P_Operation,
                    P_Building_Blocks => l_Blocks,
                    P_Attribute_Table => l_Attributes);

		G_Stage := 'Call hxc_self_service_time_deposit.set_app_hook_params()';
		Hxc_Integration_Layer_V1_Grp.Set_App_Hook_Params(
                			P_Building_Blocks => l_Blocks,
                			P_App_Attributes  => l_Attributes,
                			P_Messages        => l_Messages);

	End If; -- P_Operation

        G_Stage := 'Leaving Update_Otc_Data() procedure.';
        Pa_Otc_Api.TrackPath('STRIP','Update_Otc_Data');

  	Exception
	    When Others Then
		Raise_Application_Error(-20010, 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_stage || ' : ' || SqlErrM );

  End Update_Otc_Data;


-- =======================================================================
-- Start of Comments
-- API Name      : Update_Process
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by public procedure Update_Process.
--                 The only intent of this procedure is to get the BILLABLE_FLAG
--                 from patc/patcx and return control back to the calling procedure.
--                 No handled errors will be returned to the OTL client team server code calling
--                 procedure. Unhandled exceptions will be allowed.
--
--          P_Operation:  SAVE
--                        SUBMIT
--
-- Parameters:
-- IN
--           P_Operation        -- Varchar2
--           P_Building_Blocks  -- Hxc_User_Type_Definition_Grp.Timecard_Info
--           P_Attribute_Table  -- Hxc_User_Type_Definition_Grp.App_Attributes_Info
-- OUT
--           P_Building_Blocks  -- Hxc_User_Type_Definition_Grp.Timecard_Info
--           P_Attribute_Table  -- Hxc_User_Type_Definition_Grp.App_Attributes_Info

/*------------------------------------------------------------------------- */

  Procedure Update_Process(
                      P_Operation         IN     Varchar2,
                      P_Building_Blocks   IN OUT NOCOPY Hxc_User_Type_Definition_Grp.Timecard_Info, -- 2672653
                      P_Attribute_Table   IN OUT NOCOPY Hxc_User_Type_Definition_Grp.App_Attributes_Info) -- 2672653

  Is

	    l_Proj_Attrib_Rec           Pa_Otc_Api.Project_Attribution_Rec;

        /* Stores a single record from the Building Block Table */
        l_Building_Block_Record     Hxc_User_Type_Definition_Grp.Building_Block_Info;

        l_BB_Detail_Changed         Varchar2(1)    := 'N';  -- The OTL item has changed.
        l_BB_Detail_Deleted         Varchar2(1)    := 'N';  -- The OTL item has been deleted.
        l_BB_Detail_Pass            Varchar2(1)    := 'N';  -- The OTL item has changed but values same as in Projects
        l_Data_Conflict_Flag        Varchar2(1)    := 'N';  -- If attempt to delete,update after already saved change or
                                                            -- delete in OTL that should not have been allowed
        l_Adjusted_In_Projects      Varchar2(1)    := 'N';  -- The OTL item was adjusted in Projects already

	    l_Detail_Attr_Changed       Varchar2(1)    := 'N';
	    l_Logical_Rec_Changed       Varchar2(1)    := 'N';

        l_Msg_Name                  Varchar2(30)   := Null;
        l_Msg_Application           Varchar2(3)    := Null;
        l_Msg_Type                  Varchar2(30)   := Null;
        l_Msg_Token1_Name           Varchar2(30)   := Null;
        l_Msg_Token1_Value          Varchar2(30)   := Null;
        l_Msg_Token2_Name           Varchar2(30)   := Null;
        l_Msg_Token2_Value          Varchar2(30)   := Null;
        l_Msg_Token3_Name           Varchar2(30)   := Null;
        l_Msg_Token3_Value          Varchar2(30)   := Null;
        l_Msg_Count                 Number         := Null;
        l_Error_Code                Varchar2(30)   := Null;
        l_Error_Type                Varchar2(30)   := Null;
	    l_Status                    Varchar2(30)   := Null;

	    i			    Binary_Integer := Null;

  Begin

	G_Stage := 'Entering procedure Update_Process().';
        Pa_Otc_Api.TrackPath('ADD','Update_Process');

        G_Stage := 'Loop thru Building Blocks record to validate detail records.';
--      For i in P_Building_Blocks.First .. P_Building_Blocks.Last
        Loop

	    If i is null Then

		i := P_Building_Blocks.First;

	    Else

	    	i := P_Building_Blocks.Next(i);

	    End If;

        If P_Building_Blocks(i).Scope = 'DETAIL' Then

             G_Stage := 'Copy current record in BB table to BB record variable.';
             l_Building_Block_Record := P_Building_Blocks(i);
             G_Stage := 'Pull out the data to friendlier formated variables.';
             /* Pull out the data to project friendly variables */
             /* Bug 4318639
             Pa_Otc_Api.RetrieveProjAttribution( */
             Pa_Otc_Api.RetrieveProjAttribForUpd(
                  P_Building_Block_Rec  => l_Building_Block_Record,
                  P_Building_Block      => P_Building_Blocks,
                  P_Attribute_Table     => P_Attribute_Table,
                  X_Detail_Attr_Changed => l_Detail_Attr_Changed,
                  X_Proj_Attrib_Rec     => l_Proj_Attrib_Rec);

		     G_Stage := 'Determine building block change flag value to pass.';
		     If l_Detail_Attr_Changed = 'Y' OR P_Building_Blocks(i).Changed = 'Y' Then

			      l_Logical_Rec_Changed := 'Y';

		     Else

			      l_Logical_Rec_Changed := 'N';

		     End If;

             G_Stage := 'Determine the processing flags for using further in code.';
             Pa_Otc_Api.DetermineProcessingFlags(
                        P_BB_Id                => P_Building_Blocks(i).Time_Building_Block_Id,
                        P_BB_Ovn               => P_Building_Blocks(i).Object_Version_Number,
                        P_BB_Date_To           => P_Building_Blocks(i).Date_To,
                        P_BB_Changed           => l_Logical_Rec_Changed,
                        P_BB_New               => P_Building_Blocks(i).New,
                        P_Proj_Attribute_Rec   => l_Proj_Attrib_Rec,
                        P_Mode                 => 'UPDATE',
                        P_Process_Flag         => P_Building_Blocks(i).Process,
                        X_BB_Detail_Changed    => l_BB_Detail_Changed,
                        X_Data_Conflict_Flag   => l_Data_Conflict_Flag,
                        X_BB_Detail_Deleted    => l_BB_Detail_Deleted,
                        X_Adj_in_Projects_Flag => l_Adjusted_In_Projects);

		     If /* l_BB_Detail_Deleted = 'N' and  */ --Commented for  bug 8546092  / 8284884
		       (l_BB_Detail_Changed = 'Y' or P_Building_Blocks(i).New = 'Y') and
		        l_Adjusted_In_Projects = 'N' and
		        l_Data_Conflict_Flag = 'N' Then

			      l_Status := Null;

               	  G_Stage := 'Firing patc(). Only want the Billable Flag and no validation checked.';

               	  Pa_Transactions_Pub.Validate_Transaction(
                                X_Project_Id          => l_Proj_Attrib_Rec.Project_Id,
                                X_Task_Id             => l_Proj_Attrib_Rec.Task_Id,
                                X_Ei_Date             => l_Proj_Attrib_Rec.Expenditure_Item_Date,
                                X_Expenditure_Type    => l_Proj_Attrib_Rec.Expenditure_Type,
                                X_Non_Labor_Resource  => Null,
                                X_Person_Id           => l_Proj_Attrib_Rec.Inc_By_Person_Id,
                                X_Billable_Flag       => l_Proj_Attrib_Rec.Billable_Flag,
                                X_Quantity            => l_Proj_Attrib_Rec.Quantity,
                                X_Transfer_Ei         => Null,
                                X_Incurred_By_Org_Id  => Null,  -- letting patc get it
                                X_NL_Resource_Org_Id  => Null,
                                X_Transaction_Source  => 'ORACLE TIME AND LABOR',
                                X_Calling_Module      => 'PAXVOTCB',
                                X_Vendor_Id           => l_Proj_Attrib_Rec.Vendor_Id,  -- PA.M/CWK changes
                                X_Entered_By_User_Id  => l_Proj_Attrib_Rec.Inc_By_Person_Id,
                                X_Attribute_Category  => l_Proj_Attrib_Rec.Attrib_Category,
                                X_Attribute1          => l_Proj_Attrib_Rec.Attribute1,
                                X_Attribute2          => l_Proj_Attrib_Rec.Attribute2,
                                X_Attribute3          => l_Proj_Attrib_Rec.Attribute3,
                                X_Attribute4          => l_Proj_Attrib_Rec.Attribute4,
                                X_Attribute5          => l_Proj_Attrib_Rec.Attribute5,
                                X_Attribute6          => l_Proj_Attrib_Rec.Attribute6,
                                X_Attribute7          => l_Proj_Attrib_Rec.Attribute7,
                                X_Attribute8          => l_Proj_Attrib_Rec.Attribute8,
                                X_Attribute9          => l_Proj_Attrib_Rec.Attribute9,
                                X_Attribute10         => l_Proj_Attrib_Rec.Attribute10,
                                -- MC columns are NULL because OTL does not support
                                -- multi-currency
                                X_Denom_Currency_Code => Null,
                                X_Acct_Currency_Code  => Null,
                                X_Denom_Raw_Cost      => Null,
                                X_Acct_Raw_Cost       => Null,
                                X_Acct_Rate_Type      => Null,
                                X_Acct_Rate_Date      => Null,
                                X_Acct_Exchange_Rate  => Null,
                                X_Msg_Application     => l_Msg_Application,
                                X_Msg_Type            => l_Msg_Type,
                                X_Msg_Token1          => l_Msg_Token1_Name,
                                X_Msg_Token2          => l_Msg_Token2_Name,
                                X_Msg_Token3          => l_Msg_Token3_Name,
                                X_Msg_Count           => l_Msg_Count,
                                X_Msg_Data            => l_Status,
                                -- PA.M/CWK changes
                                P_Po_Header_Id	      => l_Proj_Attrib_Rec.Po_Header_Id,
                                P_Po_Line_Id	      => l_Proj_Attrib_Rec.Po_Line_Id,
                                P_Person_Type	      => l_Proj_Attrib_Rec.Person_Type,
                                P_Po_Price_Type	      => l_Proj_Attrib_Rec.Po_Price_Type,
                                P_Sys_Link_Function   => l_Proj_Attrib_Rec.Sys_Linkage_Func);



             G_Stage := 'Check the returned status from patc.';
             If ( l_Status is null  OR
                ( l_Status is NOT NULL AND nvl(l_Msg_Type,'W') <> 'E') ) Then  /*Bug4518893*/

                  G_Stage := 'Patc returned status that is Null.';

                  -- Populate the Billable Flag in the pl/sql table
                  -- Bug 4318639 Added IF condition to see if the billable_flag_index is populated.
                  --             If no project related data was entered or there is no project_id attribution data in the
                  --             attribution pl/sql table then we are able to build the billable_flag attribution record in
                  --             Pa_Otc_Api.RetrieveProjAttribForUpd() so won't be able to assign the billable_flag to the
                  --             attribution record.
                  G_Stage := 'Check if billable_flag attribution pl/sql record exists.';
                  If l_Proj_Attrib_Rec.Billable_Flag_Index is Not Null Then
                       G_Stage := 'Populate the Billable Flag in the attribution pl/sql table record.';
                       P_Attribute_Table(l_Proj_Attrib_Rec.Billable_Flag_Index).Attribute_Value := l_Proj_Attrib_Rec.Billable_Flag;
                  End If;

             End If; -- l_Status is null

		End If;  -- Detail building block not deleted and has changed.

	    End If; -- Detail Scope building block record

	    G_Stage := 'Check to exit loop.';
	    Exit When i = P_Building_Blocks.Last;

	End Loop;  -- End of looping thru the building_block table

	G_Stage := 'Leaving procedure Update_Process().';
	Pa_Otc_Api.TrackPath('STRIP','Update_Process');

  Exception
     	When Others Then
		Raise;

  End Update_Process;


-- =======================================================================
-- Start of Comments
-- API Name      : Validate_Otc_Data
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the OTL client team server-side
--                 Validation section of their code. The only intent of the
--                 Procedure is manipulate the parameters passed in and then call
--                 the Private procedure Validate_Process() to Validate the data.
--
-- Parameters    :
-- IN
--           P_operation -  Varchar2

/*------------------------------------------------------------------------- */

  Procedure Validate_Otc_Data
            (P_Operation IN Varchar2)

  Is

	l_Blocks     Hxc_User_Type_Definition_Grp.Timecard_Info;
	l_Attributes Hxc_User_Type_Definition_Grp.App_Attributes_Info;
	l_Messages   Hxc_User_Type_Definition_Grp.Message_Table;

  Begin

	G_Path := ' ';

        G_Stage := 'Entering procedure Validate_Otc_Data().';
        Pa_Otc_Api.TrackPath('ADD','Validate_Otc_Data');

	If P_Operation <> 'MIGRATION' Then

         G_Stage := 'Call hxc_self_service_time_deposit.get_app_hook_params()';
         Hxc_Integration_Layer_V1_Grp.Get_App_Hook_Params(
                				P_Building_Blocks => l_Blocks,
                				P_App_Attributes  => l_Attributes,
                				P_Messages        => l_Messages);

         G_Stage := 'Call the Validate_Process() to validate data.';
         Pa_Otc_Api.Validate_Process (
                     P_Operation       => P_Operation,
                     P_Building_Blocks => l_Blocks,
                     P_Attribute_Table => l_Attributes,
				     P_Message_Table   => l_Messages);

         If l_Messages.COUNT > 0 Then

                 G_Stage := 'Call hxc_self_service_time_deposit.set_app_hook_params()';
			     Hxc_Integration_Layer_V1_Grp.Set_App_Hook_Params(
                				P_Building_Blocks => l_Blocks,
                				P_App_Attributes  => l_Attributes,
                				P_Messages        => l_Messages);

         End If; -- l_Message.COUNT

	End If; -- P_Operation

        G_Stage := 'Leaving procedure Validate_Otc_Data().';
        Pa_Otc_Api.TrackPath('STRIP','Validate_Otc_Data');

  Exception
        When Others Then
                Raise_Application_Error(-20020,'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_stage || ' : ' || SQLERRM );

  End Validate_Otc_Data;


-- =======================================================================
-- Start of Comments
-- API Name      : Validate_Process
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure validates the Timecard Header/lines
--                 information entered by the user.
--
--          P_Operation:  SAVE
--                        SUBMIT
--
--
-- Parameters    :
-- IN
--           P_Operation        -- Varchar2
--           P_Building_Blocks  -- Hxc_User_Type_Definition_Grp.Timecard_Info
--           P_Attribute_Table  -- Hxc_User_Type_Definition_Grp.App_Attributes_Info
-- OUT
--           P_Message_Table    -- Hxc_User_Type_Definition_Grp.Message_Table

/*------------------------------------------------------------------------- */

   Procedure Validate_Process(
                     P_Operation         IN            Varchar2,
                     P_Building_Blocks   IN            Hxc_User_Type_Definition_Grp.Timecard_Info,
                     P_Attribute_Table   IN            Hxc_User_Type_Definition_Grp.App_Attributes_Info,
                     P_Message_Table     IN OUT NOCOPY Hxc_User_Type_Definition_Grp.Message_Table) -- 2672653

  Is

        l_Status                    Varchar2(30) := Null;
        l_Exp_Status                Varchar2(30) := Null;
        l_Not_Bypass_Patc_Flag      Boolean := True;
	    l_Error_Level               Varchar2(10) := Null; /* Added for Bug#2798986 */

        /* The OTL item has been imported into projects and max orig_transaction_reference does not match
         * its equivalent in OTL( to_char(BB_ID) || to_char(BB_OVN) ) Then l_BB_Detail_Changed = 'Y' else 'N'
         */
        l_BB_Detail_Changed         Varchar2(1) := 'N';  -- The OTL item has changed.
        l_BB_Detail_Deleted         Varchar2(1) := 'N';  -- The OTL item has been deleted.
        l_Data_Conflict_Flag        Varchar2(1) := 'N';  -- If attempt to delete,update after already saved change or
                                                         -- delete in OTL that should not have been allowed
        l_Adjusted_In_Projects      Varchar2(1) := 'N';  -- The OTL item was adjusted in Projects already

	    l_Detail_Attr_Changed       Varchar2(1) := 'N';
	    l_Logical_Rec_Changed       Varchar2(1) := 'N';

        l_Inc_By_Org_Id             Pa_Expenditures_All.Incurred_By_Organization_Id%TYPE := Null;
        l_Job_Id                    Pa_Expenditure_Items_All.Job_Id%TYPE:= Null;
        l_Ovr_Approver_Person_Id    Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE := Null;

        l_Bill_Flag_Meaning         Fnd_Lookups.Meaning%TYPE := Null;

        l_Proj_Attrib_Rec           Pa_Otc_Api.Project_Attribution_Rec;

        l_Msg_Name                  VARCHAR2(30)          := Null;
        l_Msg_Application           VARCHAR2(2)           := Null;
        l_Msg_Type                  VARCHAR2(30)          := Null;
        l_Msg_Token1_Name           VARCHAR2(30)          := Null;
	    l_Msg_Token1_Value          VARCHAR2(2000)        := Null;
        l_Msg_Token2_Name           VARCHAR2(30)          := Null;
        l_Msg_Token2_Value          VARCHAR2(2000)        := Null;
        l_Msg_Token3_Name           VARCHAR2(30)          := Null;
        l_Msg_Token3_Value          VARCHAR2(2000)        := Null;
	    l_dummy_Message             VARCHAR2(2000)        := Null;
        l_Msg_Count                 NUMBER                := Null;
        l_Error_Code                VARCHAR2(30)          := Null;
        l_Error_Type                VARCHAR2(30)          := Null;

   	    l_Error_Stack   	        Varchar2(2000);
   	    l_Old_Stack         	    Varchar2(2000);
   	    l_Error_Stage   	        Varchar2(2000);
   	    l_Error_Message 	        Varchar2(2000);

	    -- Variables for dff validation
   	    l_recDFlexR                 Fnd_Dflex.Dflex_R;
   	    l_recDFlexDR                Fnd_Dflex.Dflex_Dr;
   	    l_recContextsDR             Fnd_Dflex.Contexts_Dr;
   	    l_arrDflex                  Pa_Self_Service_Dflex_Pub.Dflex_Array;
   	    l_strContext                Varchar2(30); -- Changed length from 20 to 30.  Bug 4036480
   	    l_strReferenceField         Varchar2(200);
	    l_bresult                   Boolean;

        /* Variables needed for running of the summary-validation and Business Message APIs */
        l_Timecard_Table            Pa_Otc_Api.Timecard_Table;
        l_Timecard_Table_Week       Pa_Otc_Api.Timecard_Table;
        l_Weeks_To_Process          Binary_Integer := 0;
        l_Exp_Ending_Date_Check     Pa_Expenditures_All.Expenditure_Ending_Date%TYPE := Null;
        l_Timecard_Table_Index      Binary_Integer := 0;
        l_Time_Building_Block_Id    Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE := Null;
	    l_Approval_Status           Hxc_Time_Building_Blocks.Approval_Status%TYPE := Null;

        TYPE Exp_End_Date_Rec IS Record (
          Expenditure_Ending_Date     Pa_Expenditures_All.Expenditure_Ending_Date%TYPE,
          Incurred_By_Person_Id       Pa_Expenditures_All.Incurred_By_Person_Id%TYPE);

        TYPE Exp_End_Date_Tab IS Table OF Exp_End_Date_Rec
          INDEX BY Binary_Integer;

        l_Detail_BB_Id  Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE := Null;
        l_Detail_BB_Ovn Hxc_Time_Building_Blocks.Object_Version_Number%TYPE  := Null;

        l_Exp_End_Date_Tab Exp_End_Date_Tab;

        /* Stores a single record from the Building Block Table */
        l_Building_Block_Record Hxc_User_Type_Definition_Grp.Building_Block_Info;

        Cursor GetBillFlagMeaning(P_Lookup_Code IN VARCHAR2) Is
        Select
               Meaning
        From
               Fnd_Lookups
        Where
               Lookup_Type = 'YES_NO'
        And    Lookup_Code = P_Lookup_Code;

		/* For Bug 7645561*/
		Cursor Check_Term_with_pay(p_person_id IN NUMBER) is
		select max(person_id) from per_all_assignments_f paf,per_assignment_status_types past
		where paf.person_id = p_person_id
		and  paf.assignment_status_type_id = past.assignment_status_type_id
		and  past.per_system_status = 'TERM_ASSIGN';
		/* For Bug 7645561*/

		test_term_with_pay  Number := Null;

	    E_Unhandled_Exception 	Exception;
	    E_Dff_Exception       	Exception;

	    l_Header_Pass_Val_Flag 	Varchar2(1) := Null;
	    i 		       	Binary_Integer := Null;
	-- Added for bug 8345301
        l_closed_proj_flag          Varchar2(1) := 'N';
        l_bbid   Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE := Null;

  Begin

	G_Stage := 'Entering procedure Validate_Process().';
	Pa_Otc_Api.TrackPath('ADD','Validate_Process');

	-- The out variables are used in the summary level validation and the business message
	-- API calls.

	G_Stage := 'Find and Validate Header Record in the Building Blocks Pl/Sql table.';
	Pa_Otc_Api.FindandValidateHeader(
         P_Building_Blocks_Table  => P_Building_Blocks,
         P_Attribute_Table        => P_Attribute_Table,
         P_Message_Table          => P_Message_Table,
         X_TimeBB_Id              => l_Time_Building_Block_Id,
         X_Ovr_Approver_Person_Id => l_Ovr_Approver_Person_Id,
         X_Pass_Val_Flag          => l_Header_Pass_Val_Flag,
         X_Approval_Status        => l_Approval_Status);

	If l_Header_Pass_Val_Flag = 'N' Then

		RETURN;

	End If;

	-- Initializing dff validation procedures
	G_Stage := 'Call procedure Pa_Self_Service_Dflex_Pub.InitDFlex().';
    Pa_Self_Service_Dflex_Pub.InitDFlex(
         P_StrProductName => 'PA',
         P_StrDFlexName   => 'PA_EXPENDITURE_ITEMS_DESC_FLEX',
         P_sErrorStack    => l_Error_Stack,
         X_RecDFlexR      => l_RecDFlexR,
         X_RecDFlexDR     => l_RecDFlexDR,
         X_RecContextsDR  => l_RecContextsDR,
         X_sErrorType     => l_Error_Type,
         X_sErrorStack    => l_Error_Stack,
         X_sErrorStage    => l_Error_Stage,
         X_sErrorMessage  => l_Error_Message);

    --If an unexpected error occured in InitDFlex
    --then raise the exception.

    If (l_Error_Type = 'U') Then

         Raise E_Dff_Exception;

    End If;

    -- Call IsDFlexUsed to determine whether any desc flex segments
    -- are defined.  If no, then it is not necessary to perform DFF
    -- validation.

	G_Stage := 'Call Pa_Self_Service_Dflex_Pub.IsDFlexUsed().';
    Pa_Self_Service_Dflex_Pub.IsDFlexUsed(
         P_RecDFlexR     => l_RecDFlexR,
         P_RecContextsDR => l_RecContextsDR,
         P_sErrorStack   => l_Error_Stack,
         X_bResult       => l_bResult,
         X_sErrorType    => l_Error_Type,
         X_sErrorStack   => l_Error_Stack,
         X_sErrorStage   => l_Error_Stage,
         X_sErrorMessage => l_Error_Message);

    --If an unexpected error occured in IsDFlexUsed then raise the exception.

    If (l_Error_Type = 'U') Then

         Raise E_Dff_Exception;

    End If;

    --Call GetDFlexReferenceField to determine the Reference field for the DFF, either
    --system_linkage_function or expenditure_type in this case.

	G_Stage := 'Call Pa_Self_Service_Dflex_Pub.GetDFlexReferenceField().';
    Pa_Self_Service_DFlex_Pub.GetDFlexReferenceField(
         P_RecDFlexDR        => l_RecDFlexDR,
         P_sErrorStack       => l_Error_Stack,
         X_StrReferenceField => l_strReferenceField,
         X_sErrorType        => l_Error_Type,
         X_sErrorStack       => l_Error_Stack,
         X_sErrorStage       => l_Error_Stage,
         X_sErrorMessage     => l_Error_Message);

    --If an unexpected error occured in GetDFlexReferenceField then raise the exception.

    If (l_Error_Type = 'U') Then

         Raise E_Dff_Exception;

    End If;

    G_Stage := 'Loop thru Building Blocks record to validate detail records.';
    Loop

	     If i is null Then

		      i := P_Building_Blocks.First;

	     Else

		      i := P_Building_Blocks.Next(i);

	     End If;

	     If P_Building_Blocks(i).Scope = 'DETAIL' Then

	          G_Stage := 'Init variables within loop.';
	          l_Building_Block_Record := P_Building_Blocks(i);
	          l_Detail_Attr_Changed := 'N';

              G_Stage := 'Pull out the data to friendlier formated variables.';
               --  Pull out the data to project friendly variables
              Pa_Otc_Api.RetrieveProjAttribution(
                   P_Building_Block_Rec  => l_Building_Block_Record,
			       P_Building_Block      => P_Building_Blocks,
                   P_Attribute_Table     => P_Attribute_Table,
			       X_Detail_Attr_Changed => l_Detail_Attr_Changed,
			       X_Proj_Attrib_Rec     => l_Proj_Attrib_Rec);

		      G_Stage := 'Determine record change flag value.';
		      If l_Detail_Attr_Changed = 'Y' OR P_Building_Blocks(i).Changed = 'Y' Then

			       l_Logical_Rec_Changed := 'Y';

		      Else

			       l_Logical_Rec_Changed := 'N';

		      End If;

       /* bug 8345301 Code starts */

                G_Stage := 'Trying to modify an item on a closed project.';
				l_bbid := to_char( P_Building_Blocks(i).Time_Building_Block_Id) || ':%';

				Begin
				     Select
						'Y'
						into l_closed_proj_flag from  dual
						where  exists  (select 1
				    From
				        Pa_Expenditure_Items_All ei,
					pa_projects_all  ppa
				    Where
					    ei.project_id <>  l_Proj_Attrib_Rec.PROJECT_ID  and
				        ei.project_id =  ppa.project_id and
						nvl(ei.net_zero_adjustment_flag, 'N') <> 'Y' and
				        ei.Transaction_Source = 'ORACLE TIME AND LABOR' and
				        ei.Orig_Transaction_Reference like l_bbid
		               --and ppa.project_status_code = 'CLOSED'
			         AND PA_PROJECT_UTILS.check_prj_stus_action_allowed(ppa.PROJECT_STATUS_CODE, 'NEW_TXNS') = 'N' --Bug 8532951
			       );
				 Exception
				 When  NO_DATA_FOUND Then
				   l_closed_proj_flag := 'N';
				 End;



				If  l_closed_proj_flag = 'Y'  Then
				 -- Add record to error table.
	                            Pa_Otc_Api.Add_Error_To_Table(
	                                 P_Message_Table           => P_Message_Table,
	                                 P_Message_Name            => 'PA_NEW_TXNS_NOT_ALLOWED',
	                                 P_Message_Level           => 'ERROR',
	                                 P_Message_Field           => NULL,
	                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
	                                 --P_Time_Building_Block_Id  => NULL,
									 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
	                                 P_Time_Attribute_Id       => NULL);
			  end if ;

           /* bug 8345301 Code ends  */



              G_Stage := 'Determine the processing flags for use further in code.';
              Pa_Otc_Api.DetermineProcessingFlags(
                   P_BB_Id                => P_Building_Blocks(i).Time_Building_Block_Id,
                   P_BB_Ovn               => P_Building_Blocks(i).Object_Version_Number,
			       P_BB_Date_To           => P_Building_Blocks(i).Date_To,
			       P_BB_Changed           => l_Logical_Rec_Changed,
			       P_BB_New               => P_Building_Blocks(i).New,
			       P_Proj_Attribute_Rec   => l_Proj_Attrib_Rec,
			       P_Mode                 => 'VALIDATE',
                   P_Process_Flag         => P_Building_Blocks(i).Process,
                   X_BB_Detail_Changed    => l_BB_Detail_Changed,
			       X_Data_Conflict_Flag   => l_Data_Conflict_Flag,
			       X_BB_Detail_Deleted    => l_BB_Detail_Deleted,
                   X_Adj_in_Projects_Flag => l_Adjusted_In_Projects);

		     -- If the Building Block(BB) can be adjusted in OTL then that will consistently be the case
             -- until the BB is imported into projects at which point the ei associated to the
		     -- BB and Object_Version_Number combo can be adjusted or reversed out prior to any attempt to
             -- adjust the BB in OTL.  Anotherwards, once adjusted on OTL then can't adjust in Projects
		     -- and vice versa.
		     --
             -- If l_Adjusted_In_Projects is 'Y' then
		     --   An adjustment was made in Projects so can't adjust in OTL.
             -- If l_Adjusted_In_Projects is 'N' then
		     --   No adjustment was made in projects so it can be adjusted in OTL
		     --   or it is not in projects yet and can do whatever wanted.
             --

		     If l_Adjusted_In_Projects  = 'Y' Then

			      G_Stage := 'Item is Adjusted.';

		   	      If l_BB_Detail_Deleted = 'Y' Then

				       G_Stage := 'Building Block has been deleted.';

                       -- Really don't need to process this record any further.
                       -- The timecard cannot be save or submitted due to this.  Period!

				       If l_Data_Conflict_Flag = 'Y' Then

					        G_Stage := 'Not allowed to delete Item In OTL data conflict - Inserting error rec.';

                            G_Msg_Tokens_Table.Delete;

                            -- Add record to error table.
                            Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => 'PA_TR_UNDO_DEL_IN_OTC',
                                 P_Message_Level           => 'ERROR',
                                 P_Message_Field           => NULL,
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => NULL);

				       Else

					        G_Stage := 'Not allowed to Delete Item In OTL - Inserting error rec.';
					        G_Msg_Tokens_Table.Delete;

                            -- Add record to error table.
                            Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => 'PA_NO_DEL_EX_ITEM',
                                 P_Message_Level           => 'ERROR',
                                 P_Message_Field           => NULL,
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => NULL);

				       End If;  -- Data Confict or SUBMIT

			      End If; -- l_BB_Detail_Deleted is Y

                  If l_BB_Detail_Changed = 'Y' and l_BB_Detail_Deleted = 'N' Then

				       If l_Data_Conflict_Flag = 'Y' Then

					        -- Really don't need to process this record any further.
					        -- The timecard cannot be save due to this.  Period!

                            G_Stage := 'Not allowed to Adjust Item In OTL confict - Inserting error rec.';
					        G_Msg_Tokens_Table.Delete;

                            -- Add record to error table.
                            Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => 'PA_TR_UNDO_CHGE_IN_OTC',
                                 P_Message_Level           => 'ERROR',
                                 P_Message_Field           => NULL,
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => NULL);

				       Else

					        G_Stage := 'Not allowed to Adjust Item In OTL - Inserting error rec.';

					        G_Msg_Tokens_Table.Delete;

					        -- Add record to error table.
					        Pa_Otc_Api.Add_Error_To_Table(
       	           			     P_Message_Table           => P_Message_Table,
       	           			     P_Message_Name            => 'PA_TR_ADJ_NO_NET_ZERO',
                  			     P_Message_Level           => 'ERROR',
                  			     P_Message_Field           => NULL,
                  			     P_Msg_Tokens              => G_Msg_Tokens_Table,
                  			     P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                  			     P_Time_Attribute_Id       => NULL);

				       End If; -- l_Data_Conflict_Flag is 'Y'

                  End If;  -- l_BB_Detail_Changed is Y and l_BB_Detail_Deleted is N

		     End If; -- l_Adjusted_In_Projects is Y

		     If  /*l_BB_Detail_Deleted = 'N' and */    -- Commented for Bug 8546092  / 8284884
		        l_Adjusted_In_Projects = 'N' and
		        ( l_BB_Detail_Changed = 'Y' or P_Building_Blocks(i).New = 'Y') Then

			      G_Stage := 'Check the Unit Of Measure value.';
                  If l_Proj_Attrib_Rec.UOM <> 'HOURS' Then

                       -- Really don't need to process this record any further.
                       -- The timecard cannot be save due to this.  Period!

                       G_Stage := 'Cannot have data where UOM is not HOURS - Inserting error rec.';

                       G_Msg_Tokens_Table.Delete;

                       -- Add record to error table.
                       Pa_Otc_Api.Add_Error_To_Table(
                            P_Message_Table           => P_Message_Table,
                            P_Message_Name            => 'PA_UOM_MUST_BE_HOURS',
                            P_Message_Level           => 'ERROR',
                            P_Message_Field           => NULL,
                            P_Msg_Tokens              => G_Msg_Tokens_Table,
                            P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                            P_Time_Attribute_Id       => NULL);

                  End If; -- l_UOM <> 'HOURS'

			      G_Stage := 'Check for quantity being negative.';
                  If l_Proj_Attrib_Rec.Quantity < 0 And
			         Nvl(Fnd_Profile.Value('PA_SST_ALLOW_NEGATIVE_TXN'),'N') = 'N' Then

				       -- If the quantity is less than 0 and the profile is set to not allow
                       -- for negative transactions then raise error in error table.
				       --
                       -- Really don't need to process this record any further.
                       -- The timecard cannot be save due to this.  Period!

                       G_Stage := 'Negative quantity not allowed In OTL - Inserting error rec.';
                       G_Msg_Tokens_Table.Delete;

                       -- Add record to error table.
                       Pa_Otc_Api.Add_Error_To_Table(
                            P_Message_Table           => P_Message_Table,
                            P_Message_Name            => 'PA_SU_NEGATIVE_NUM_NOT_ALLOWED',
                            P_Message_Level           => 'ERROR',
                            P_Message_Field           => NULL,
                            P_Msg_Tokens              => G_Msg_Tokens_Table,
                            P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                            P_Time_Attribute_Id       => NULL);

                  End If; -- P_Building_Blocks_Table(i).Measure is negative and it is not allowed

			      -- Begin PA.M/CWK changes
			      If l_Proj_Attrib_Rec.Person_Type not in ('CWK','EMP') Then

	                   G_Stage := 'Invalid Person Type - Inserting error rec.';
        	           G_Msg_Tokens_Table.Delete;

                	   -- Add record to error table.
                       Pa_Otc_Api.Add_Error_To_Table(
                            P_Message_Table           => P_Message_Table,
	                        P_Message_Name            => 'PA_INVALID_PERSON_TYPE',
        	                P_Message_Level           => 'ERROR',
                	        P_Message_Field           => NULL,
                        	P_Msg_Tokens              => G_Msg_Tokens_Table,
                            P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
	                        P_Time_Attribute_Id       => NULL);

			      ElsIf l_Proj_Attrib_Rec.Person_Type = 'CWK' Then

				       If Pa_Pjc_Cwk_Utils.Is_Cwk_Tc_Xface_Allowed(l_Proj_Attrib_Rec.Project_Id) <> 'Y' And
                          l_Proj_Attrib_Rec.PO_Line_Id Is Not Null And
                          l_Proj_Attrib_Rec.Sys_Linkage_Func in ('OT','ST') Then

	                        G_Stage := 'Project organization does not allow CWK timecards - Inserting error rec.';
        	                G_Msg_Tokens_Table.Delete;

                	        -- Add record to error table.
                        	Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
	                             P_Message_Name            => 'PA_CWK_TC_NOT_ALLOWED',
        	                     P_Message_Level           => 'ERROR',
                	             P_Message_Field           => NULL,
                        	     P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
	                             P_Time_Attribute_Id       => NULL);

				       Else

                            G_Stage := 'Check if the CWK working is creating timecard with PO reference.';
                            If l_Proj_Attrib_Rec.PO_Line_Id Is Not Null Then

                                 G_Stage := 'Check if the PO_Price_Type is populated.  It is required.';
					             If l_Proj_Attrib_Rec.PO_Price_Type is Null Then

	                                  G_Stage := 'Price Type is null - Inserting error rec.';
        	                          G_Msg_Tokens_Table.Delete;

                	                  -- Add record to error table.
                        	          Pa_Otc_Api.Add_Error_To_Table(
                                	       P_Message_Table           => P_Message_Table,
	                                       P_Message_Name            => 'PA_CWK_PRICE_TYPE_NULL',
        	                               P_Message_Level           => 'ERROR',
                	                       P_Message_Field           => NULL,
                        	               P_Msg_Tokens              => G_Msg_Tokens_Table,
                                	       P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
	                                       P_Time_Attribute_Id       => NULL);

					             ElsIf l_Proj_Attrib_Rec.Vendor_Id is Null Then

	                                  G_Stage := 'Derived Vendor Id is null - Inserting error rec.';
        	                          G_Msg_Tokens_Table.Delete;

                	                  -- Add record to error table.
                        	          Pa_Otc_Api.Add_Error_To_Table(
                                	       P_Message_Table           => P_Message_Table,
	                                       P_Message_Name            => 'PA_CWK_VEND_INFO_NULL',
        	                               P_Message_Level           => 'ERROR',
                	                       P_Message_Field           => NULL,
                        	               P_Msg_Tokens              => G_Msg_Tokens_Table,
                                	       P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
	                                       P_Time_Attribute_Id       => NULL);

					             End If;

                            End If;  -- l_Proj_Attrib_Rec.PO_Line_Id Is Not Null

				       End If;

			      End If;
			      -- End PA.M/CWK changes

			      -- Get Project Number
			      l_Error_Code := Null;
			      G_stage := 'Get Project Number.';
			      Pa_Otc_Api.Validate_Project_Exists(
				       P_Project_Id     => l_Proj_Attrib_Rec.Project_Id,
                       X_Error_Code     => l_Error_Code,
                       X_Error_Type     => l_Error_Type,
                       X_Project_Number => l_Proj_Attrib_Rec.Project_Number);

			      If l_Error_Code is Not Null Then

				       G_Stage := 'Get Project Number - Inserting error rec.';
                       G_Msg_Tokens_Table.Delete;

				       -- Add record to error table.
                       Pa_Otc_Api.Add_Error_To_Table(
                            P_Message_Table           => P_Message_Table,
                            P_Message_Name            => l_Error_Code,
                            P_Message_Level           => 'ERROR',
                            P_Message_Field           => 'PROJECT_ID',
                            P_Msg_Tokens              => G_Msg_Tokens_Table,
                            P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                            P_Time_Attribute_Id       => l_Proj_Attrib_Rec.Proj_Attr_Id);

			      End If; -- l_Error_Code is not NULL

			      -- Get Task Number
			      l_Error_Code := Null;
			      G_stage := 'Get Task Number.';
			      Pa_Otc_Api.Validate_Task_Exists(
                       P_Task_Id     => l_Proj_Attrib_Rec.Task_Id,
					   P_Project_Id  => l_Proj_Attrib_Rec.Project_Id,
                       X_Error_Code  => l_Error_Code,
                       X_Error_Type  => l_Error_Type,
                       X_Task_Number => l_Proj_Attrib_Rec.Task_Number);

                  If l_Error_Code is Not Null Then

				       G_Stage := 'Get Task Number - Inserting error rec.';
                       G_Msg_Tokens_Table.Delete;

                       -- Add record to error table.
                       Pa_Otc_Api.Add_Error_To_Table(
                            P_Message_Table           => P_Message_Table,
                            P_Message_Name            => l_Error_Code,
                            P_Message_Level           => 'ERROR',
                            P_Message_Field           => 'TASK_ID',
                            P_Msg_Tokens              => G_Msg_Tokens_Table,
                            P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                            P_Time_Attribute_Id       => l_Proj_Attrib_Rec.Task_Attr_Id);

                  End If;

			      -- Validate the expenditure type and system linkage function
			      G_Stage := 'Validation the expenditure type and system linkage function.';
			      l_Error_Code := Null;

			      Pa_Otc_Api.Validate_Exp_Type_Exists(
               	       P_System_Linkage   => l_Proj_Attrib_Rec.Sys_Linkage_Func,
               		   P_Expenditure_Type => l_Proj_Attrib_Rec.Expenditure_Type,
               		   P_Exp_Item_Date    => l_Proj_Attrib_Rec.Expenditure_Item_Date,
               		   X_Error_Type       => l_Error_Type,
               		   X_Error_Code       => l_Error_Code);

			      If l_Error_Code is Not Null Then

				       G_Stage := 'Validate the exp type and syst link func - Inserting error rec.';
                       -- Add record to error table.

                       G_Msg_Tokens_Table.Delete;

				       If l_Proj_Attrib_Rec.Sys_Linkage_Func Is Null OR
				          l_Proj_Attrib_Rec.Sys_Linkage_Func Not in ('OT','ST') Then

                            Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => l_Error_Code,
                                 P_Message_Level           => 'ERROR',
                                 P_Message_Field           => 'SYSTEM_LINKAGE_FUNCTION',
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => l_Proj_Attrib_Rec.Sys_Link_Attr_Id);

				       Else

                            Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => l_Error_Code,
                                 P_Message_Level           => 'ERROR',
                                 P_Message_Field           => 'EXPENDITURE_TYPE',
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => l_Proj_Attrib_Rec.Exp_Type_Attr_Id);

				       End If; -- l_Sys_Linkage_Func

			      ElsIf l_Proj_Attrib_Rec.Sys_Linkage_Func Not in ('OT','ST') Then

				       G_Stage := 'Invalid sys link func - Inserting error rec.';
                       -- Add record to error table.

				       G_Msg_Tokens_Table.Delete;

                       Pa_Otc_Api.Add_Error_To_Table(
					        P_Message_Table           => P_Message_Table,
					        P_Message_Name            => 'INVALID_ETYPE_SYSLINK',
					        P_Message_Level           => 'ERROR',
					        P_Message_Field           => 'SYSTEM_LINKAGE_FUNCTION',
					        P_Msg_Tokens              => G_Msg_Tokens_Table,
					        P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
					        P_Time_Attribute_Id       => l_Proj_Attrib_Rec.Sys_Link_Attr_Id);

			      End If; -- l_Error_Code is not null

			      -- Get Incurred_By_Organization_Id
			      l_Error_Code := Null;
			      l_Inc_By_Org_Id := Null;
			      G_Stage := 'Get Incurred by Organization Id.';
   			      l_Inc_By_Org_Id := Pa_Utils.GetEmpOrgId(
                       				      X_Person_Id => l_Proj_Attrib_Rec.Inc_By_Person_Id,
                       				      X_Date      => l_Proj_Attrib_Rec.Expenditure_Item_Date);

			      If l_Inc_By_Org_Id is Null Then

				       G_Stage := 'Get Inc by Org Id - Inserting error rec.';
                       G_Msg_Tokens_Table.Delete;

				       G_Msg_Tokens_Table(1).Token_Name := 'EXPDATE';
				       G_Msg_Tokens_Table(1).Token_Value :=
					   fnd_date.date_to_displaydate(l_Proj_Attrib_Rec.Expenditure_Item_Date);

                       -- Add record to error table.
                       Pa_Otc_Api.Add_Error_To_Table(
                            P_Message_Table           => P_Message_Table,
                            P_Message_Name            => 'NO_ASSIGNMENT',
                            P_Message_Level           => 'ERROR',
                            P_Message_Field           => Null,
                            P_Msg_Tokens              => G_Msg_Tokens_Table,
                            P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                            P_Time_Attribute_Id       => Null);

                  Else

				       -- If the employee is assigned to an organization then it makes sense to check
				       -- to see if there is a job assigned to the employee
				       -- If there is no org then there is no need to check job since the same
				       -- error message is used.

		        	   -- Check Job_Id
		        	   G_Stage := 'Check for Job Id.';
				       l_Job_Id := Null;
				       l_Job_Id := Pa_Utils.GetEmpJobId (
					                    X_person_id => l_Proj_Attrib_Rec.Inc_By_Person_Id,
                       	                X_date      => l_Proj_Attrib_Rec.Expenditure_Item_Date);

				       If l_Job_Id is Null Then

                            G_Msg_Tokens_Table.Delete;

                            G_Msg_Tokens_Table(1).Token_Name := 'EXPDATE';
                            G_Msg_Tokens_Table(1).Token_Value :=
                            fnd_date.date_to_displaydate(l_Proj_Attrib_Rec.Expenditure_Item_Date);

					        G_Stage := 'Check Job Id - Inserting error rec.';

                       		-- Add record to error table.
                            Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => 'NO_ASSIGNMENT',
                                 P_Message_Level           => 'ERROR',
                                 P_Message_Field           => Null,
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => Null);

                       End If; -- l_Job_Id check

			      End If; -- l_Inc_By_Org_Id check

			      -- DFF validation section.
			      If l_bResult Then

	    		       If (l_StrReferenceField = 'SYSTEM_LINKAGE_FUNCTION') Then

 	             	        l_StrContext := l_Proj_Attrib_Rec.Sys_Linkage_Func;

  	    			   ElsIf (l_StrReferenceField = 'EXPENDITURE_TYPE') Then

 	             			l_StrContext := l_Proj_Attrib_Rec.Expenditure_Type;

 	     			   Else

 	             			l_StrContext := Null;

	      			   End If;

	        		   G_Stage := 'Customer has defined Dffs and enabled them.  ' ||
			                      'Populate dflex array with attributes 1 - 10.';

                       l_ArrDFlex(1)  := l_Proj_Attrib_Rec.Attribute1;
                       l_ArrDFlex(2)  := l_Proj_Attrib_Rec.Attribute2;
                       l_ArrDFlex(3)  := l_Proj_Attrib_Rec.Attribute3;
                       l_ArrDFlex(4)  := l_Proj_Attrib_Rec.Attribute4;
                       l_ArrDFlex(5)  := l_Proj_Attrib_Rec.Attribute5;
                       l_ArrDFlex(6)  := l_Proj_Attrib_Rec.Attribute6;
                       l_ArrDFlex(7)  := l_Proj_Attrib_Rec.Attribute7;
                       l_ArrDflex(8)  := l_Proj_Attrib_Rec.Attribute8;
                       l_ArrDFlex(9)  := l_Proj_Attrib_Rec.Attribute9;
                       l_ArrDFlex(10) := l_Proj_Attrib_Rec.Attribute10;

				       G_Stage := 'Call Pa_Self_Service_Dflex_Pub.ValidateDFlex().';
                       Pa_Self_Service_Dflex_Pub.ValidateDFlex(
                            P_StrProductName => 'PA',
                            P_StrDFlexName   => 'PA_EXPENDITURE_ITEMS_DESC_FLEX',
                            P_RecContextsDR  => l_RecContextsDR,
                            P_StrContextName => l_StrContext,
                            P_ArrDFlex       => l_ArrDFlex,
                            P_sErrorStack    => l_Error_Stack,
                            X_sErrorType     => l_Error_Type,
                            X_sErrorStack    => l_Error_Stack,
                            X_sErrorStage    => l_Error_Stage,
                            X_sErrorMessage  => l_Error_Message);

                       --If an unexpected error occured in ValidateDFlex then raise the exception.

                       If (l_Error_Type = 'U') Then

                            Raise E_Dff_Exception;

  				       ElsIf l_Error_Type = 'E' Then

  					        -- Can only provide generic message since can't pass back
  					        -- messages to OTL. Only message names and token info.

  					        G_Msg_Tokens_Table.Delete;

  					        Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => 'PA_DFF_VALIDATION_FAILED',
                                 P_Message_Level           => 'ERROR',
                                 P_Message_Field           => Null,
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => Null);

  				       End If;

  			      End If;

			      -- Transaction Control validation call.

			      l_Status := Null;

		    	  G_Stage := 'Firing patc call.';
        		  Pa_Transactions_Pub.Validate_Transaction(
                       X_Project_Id          => l_Proj_Attrib_Rec.Project_Id,
                       X_Task_Id             => l_Proj_Attrib_Rec.Task_Id,
                       X_Ei_Date             => l_Proj_Attrib_Rec.Expenditure_Item_Date,
                       X_Expenditure_Type    => l_Proj_Attrib_Rec.Expenditure_Type,
                       X_Non_Labor_Resource  => Null,
                       X_Person_Id           => l_Proj_Attrib_Rec.Inc_By_Person_Id,
                       X_Billable_Flag       => l_Proj_Attrib_Rec.Billable_Flag2,
                       X_Quantity            => l_Proj_Attrib_Rec.Quantity,
                       X_Transfer_Ei         => Null,
                       X_Incurred_By_Org_Id  => Null,  -- letting patc get it
                       X_NL_Resource_Org_Id  => Null,
                       X_Transaction_Source  => 'ORACLE TIME AND LABOR',
                       X_Calling_Module      => 'PAXVOTCB',
                       X_Vendor_Id           => l_Proj_Attrib_Rec.Vendor_Id,
                       X_Entered_By_User_Id  => l_Proj_Attrib_Rec.Inc_By_Person_Id,
                       X_Attribute_Category  => l_Proj_Attrib_Rec.Attrib_Category,
                       X_Attribute1          => l_Proj_Attrib_Rec.Attribute1,
                       X_Attribute2          => l_Proj_Attrib_Rec.Attribute2,
                       X_Attribute3          => l_Proj_Attrib_Rec.Attribute3,
                       X_Attribute4          => l_Proj_Attrib_Rec.Attribute4,
                       X_Attribute5          => l_Proj_Attrib_Rec.Attribute5,
                       X_Attribute6          => l_Proj_Attrib_Rec.Attribute6,
                       X_Attribute7          => l_Proj_Attrib_Rec.Attribute7,
                       X_Attribute8          => l_Proj_Attrib_Rec.Attribute8,
                       X_Attribute9          => l_Proj_Attrib_Rec.Attribute9,
                       X_Attribute10         => l_Proj_Attrib_Rec.Attribute10,
                       -- MC columns are NULL because OTL does not support
                       -- multi-currency
                       X_Denom_Currency_Code => Null,
                       X_Acct_Currency_Code  => Null,
                       X_Denom_Raw_Cost      => Null,
                       X_Acct_Raw_Cost       => Null,
                       X_Acct_Rate_Type      => Null,
                       X_Acct_Rate_Date      => Null,
                       X_Acct_Exchange_Rate  => Null,
                       X_Msg_Application     => l_Msg_Application,
                       X_Msg_Type            => l_Msg_Type,
                       X_Msg_Token1          => l_Msg_Token1_Value,
                       X_Msg_Token2          => l_Msg_Token2_Value,
                       X_Msg_Token3          => l_Msg_Token3_Value,
                       X_Msg_Count           => l_Msg_Count,
                       X_Msg_Data            => l_Status,
		               P_Po_Header_Id	      => l_Proj_Attrib_Rec.Po_Header_Id,
		               P_Po_Line_Id	      => l_Proj_Attrib_Rec.Po_Line_Id,
		               P_Person_Type	      => l_Proj_Attrib_Rec.Person_Type,
		               P_Po_Price_Type	      => l_Proj_Attrib_Rec.Po_Price_Type,
		               P_Sys_Link_Function   => l_Proj_Attrib_Rec.Sys_Linkage_Func);

					   /* Bug 7645561*/
					   Open Check_Term_with_pay(l_Proj_Attrib_Rec.Inc_By_Person_Id);
					   fetch Check_Term_with_pay into test_term_with_pay;
					   Close Check_Term_with_pay;


/* Bug 7645561*/
            If (l_status <> 'PA_NO_ASSIGNMENT' or test_term_with_pay is Null) then
	        	  -- check if patc has returned any errors
        		  If l_Status is Not Null Then

				       If Pa_Otc_Api.IsNumber(l_Status) Then

					        Raise E_Unhandled_Exception;

				       Else

					        G_Stage := 'Patc returned status that is Not Null - Inserting error rec.';
                            G_Msg_Tokens_Table.Delete;

					        If l_Msg_Token1_Value is not null Then

						         G_Msg_Tokens_Table(1).Token_Name := 'PATC_MSG_TOKEN1';
						         G_Msg_Tokens_Table(1).Token_Value := l_Msg_Token1_Value;

                            -- Begin message token is not defined for bug#4593869
                            Else

                                 G_Msg_Tokens_Table(1).Token_Name := 'PATC_MSG_TOKEN1';
                                 G_Msg_Tokens_Table(1).Token_Value := FND_API.G_MISS_CHAR;

                            -- End message token is not defined for bug#4593869
					        End If;

                            If l_Msg_Token2_Value is not null Then

                                 G_Msg_Tokens_Table(2).Token_Name := 'PATC_MSG_TOKEN2';
                                 G_Msg_Tokens_Table(2).Token_Value := l_Msg_Token2_Value;

                            -- Begin message token is not defined for bug#4593869
                            Else

                                 G_Msg_Tokens_Table(2).Token_Name := 'PATC_MSG_TOKEN2';
                                 G_Msg_Tokens_Table(2).Token_Value := FND_API.G_MISS_CHAR;

                            -- End message token is not defined for bug#4593869
                            End If;

                            If l_Msg_Token3_Value is not null Then

                                 G_Msg_Tokens_Table(3).Token_Name := 'PATC_MSG_TOKEN3';
                                 G_Msg_Tokens_Table(3).Token_Value := l_Msg_Token3_Value;

                            -- Begin message token is not defined for bug#4593869
                            Else

                                 G_Msg_Tokens_Table(3).Token_Name := 'PATC_MSG_TOKEN3';
                                 G_Msg_Tokens_Table(3).Token_Value := FND_API.G_MISS_CHAR;

                            -- End message token is not defined for bug#4593869
                            End If;

				       End If;

                       If l_Msg_Application is Null Then

					        l_Msg_Application := 'PA';

				       End If;

                       /* Added following if condition for Bug#2798986 */
				       If l_Msg_Type = 'W' Then

				            l_Error_Level := 'WARNING';

				       ElsIf l_Msg_Type = 'E' Then

				            l_Error_Level := 'ERROR';

				       End If;

				       If l_Status <> 'NO_ASSIGNMENT' Then

                            Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => l_Status,
                                 P_Message_Level           => l_Error_Level, /* Bug#2798986 */
                                 P_Message_Field           => Null,
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => Null,
						         P_Message_App             => l_Msg_Application);

				       End If;

                       -- Begin Bug 4518893
                       If l_Msg_Type = 'W' Then

                            /* Check if the billable flag was change externally either by other app
                             * in OTL or by third party.
                             */
                            If l_Proj_Attrib_Rec.Billable_Flag <> l_Proj_Attrib_Rec.Billable_Flag2 Then

                                 /* l_Billable_Flag is coming from the pl/sql table
                                  * This can occur if another app changes project,task,billable_flag
                                  * in update phase of validation logic and billable no longer
                                  * matches what patc returns.
                                  */

                                  G_Stage := 'Get translated value for Billable_flag code using fnd_lookups.';
                                  l_Bill_Flag_Meaning := Null;

                                  G_Stage := 'Open cursor getBillFlagMeaning.';
                                  Open GetBillFlagMeaning(l_Proj_Attrib_Rec.Billable_Flag);

                                  G_Stage := 'Fetch data for cursor getBillFlagMeaning.';
                                  Fetch GetBillFlagMeaning into l_Bill_Flag_Meaning;

                                  G_Stage := 'Close cursor GetBillFlagMeaning.';
                                  Close GetBillFlagMeaning;

                                  G_Stage := 'Invalid external change of billable flag  - Inserting error rec.';
                                  G_Msg_Tokens_Table.Delete;

                                  G_Msg_Tokens_Table(1).Token_Name := 'BILL_FLAG';
                                  G_Msg_Tokens_Table(1).Token_Value := l_Bill_Flag_Meaning;

                                  -- Add record to error message table.
                                  Pa_Otc_Api.Add_Error_To_Table(
                                       P_Message_Table           => P_Message_Table,
                                       P_Message_Name            => 'BILL_FLAG_CHGE_INVALID',
                                       P_Message_Level           => 'ERROR',
                                       P_Message_Field           => 'BILLABLE_FLAG',
                                       P_Msg_Tokens              => G_Msg_Tokens_Table,
                                       P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                       P_Time_Attribute_Id       => l_Proj_Attrib_Rec.Billable_Flag_Attr_Id);

                            End If; -- l_Proj_Attrib_Rec.Billable_Flag <> l_Proj_Attrib_Rec.Billable_Flag2

                       End If; -- l_Msg_Type = 'W'
                       -- end bug 4518893

		     	  Else -- l_Status is Not Null

				       /* Check if the billable flag was change externally either by other app
				        * in OTL or by third party.
				        */
				       If l_Proj_Attrib_Rec.Billable_Flag <> l_Proj_Attrib_Rec.Billable_Flag2 Then

					        /* l_Billable_Flag is coming from the pl/sql table
					         * This can occur if another app changes project,task,billable_flag
					         * in update phase of validation logic and billable no longer
					         * matches what patc returns.
					         */

					        G_Stage := 'Get translated value for Billable_flag code using fnd_lookups.';
					        l_Bill_Flag_Meaning := Null;

					        G_Stage := 'Open cursor getBillFlagMeaning.';
					        Open GetBillFlagMeaning(l_Proj_Attrib_Rec.Billable_Flag);

				            G_Stage := 'Fetch data for cursor getBillFlagMeaning.';
					        Fetch GetBillFlagMeaning into l_Bill_Flag_Meaning;

					        G_Stage := 'Close cursor GetBillFlagMeaning.';
					        Close GetBillFlagMeaning;

                            G_Stage := 'Invalid external change of billable flag  - Inserting error rec.';
	                        G_Msg_Tokens_Table.Delete;

					        G_Msg_Tokens_Table(1).Token_Name := 'BILL_FLAG';
					        G_Msg_Tokens_Table(1).Token_Value := l_Bill_Flag_Meaning;

                            -- Add record to error message table.
                            Pa_Otc_Api.Add_Error_To_Table(
                                 P_Message_Table           => P_Message_Table,
                                 P_Message_Name            => 'BILL_FLAG_CHGE_INVALID',
                                 P_Message_Level           => 'ERROR',
                                 P_Message_Field           => 'BILLABLE_FLAG',
                                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                                 P_Time_Building_Block_Id  => P_Building_Blocks(i).Time_Building_Block_Id,
                                 P_Time_Attribute_Id       => l_Proj_Attrib_Rec.Billable_Flag_Attr_Id);

				       End If; -- l_Proj_Attrib_Rec.billable_flag <> l_Proj_Attrib_Rec.billable_flag2

                  End If; -- l_Status check
				  End If; -- Bug 7645561

             End If; -- l_Adjusted_In_Projects = 'N' and l_BB_Detail_Changed = 'Y' and l_BB_Detail_Deleted = 'N'

             If P_Message_Table.Count = 0 and l_BB_Detail_Deleted = 'N' Then

			      -- Add ei record to l_Timecard_Table
			      G_Stage := 'Add ei record to l_Timecard_Table for use by extensions.';

			      l_Timecard_Table_Index := l_Timecard_Table_Index + 1;
			      l_Timecard_Table(l_Timecard_Table_Index).Project_Number := l_Proj_Attrib_Rec.Project_Number;
        	      l_Timecard_Table(l_Timecard_Table_Index).Project_Id     := l_Proj_Attrib_Rec.Project_id;
        	      l_Timecard_Table(l_Timecard_Table_Index).Task_Number    := l_Proj_Attrib_Rec.Task_Number;
        	      l_Timecard_Table(l_Timecard_Table_Index).Task_Id        := l_Proj_Attrib_Rec.Task_Id;
			      l_Timecard_Table(l_Timecard_Table_Index).Expenditure_Type := l_Proj_Attrib_Rec.Expenditure_Type;
			      l_Timecard_Table(l_Timecard_Table_Index).System_Linkage_Function := l_Proj_Attrib_Rec.Sys_Linkage_Func;
        	      l_Timecard_Table(l_Timecard_Table_Index).Quantity := l_Proj_Attrib_Rec.Quantity;
        	      l_Timecard_Table(l_Timecard_Table_Index).Incurred_By_Person_Id := l_Proj_Attrib_Rec.Inc_By_Person_Id;
        	      l_Timecard_Table(l_Timecard_Table_Index).Override_Approver_Person_Id := l_Ovr_Approver_Person_Id;
        	      l_Timecard_Table(l_Timecard_Table_Index).Expenditure_Item_Date := l_Proj_Attrib_Rec.Expenditure_Item_Date;
        	      l_Timecard_Table(l_Timecard_Table_Index).Expenditure_Ending_Date := l_Proj_Attrib_Rec.Exp_Ending_Date;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute_Category := l_Proj_Attrib_Rec.Attrib_Category;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute1 := l_Proj_Attrib_Rec.Attribute1;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute2 := l_Proj_Attrib_Rec.Attribute2;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute3 := l_Proj_Attrib_Rec.Attribute3;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute4 := l_Proj_Attrib_Rec.Attribute4;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute5 := l_Proj_Attrib_Rec.Attribute5;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute6 := l_Proj_Attrib_Rec.Attribute6;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute7 := l_Proj_Attrib_Rec.Attribute7;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute8 := l_Proj_Attrib_Rec.Attribute8;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute9 := l_Proj_Attrib_Rec.Attribute9;
        	      l_Timecard_Table(l_Timecard_Table_Index).Attribute10 := l_Proj_Attrib_Rec.Attribute10;
        	      l_Timecard_Table(l_Timecard_Table_Index).Billable_Flag := l_Proj_Attrib_Rec.Billable_Flag;
        	      l_Timecard_Table(l_Timecard_Table_Index).Expenditure_Item_Comment := l_Proj_Attrib_Rec.Expenditure_Item_Comment;
			      l_Timecard_Table(l_Timecard_Table_Index).Approval_Status := l_Approval_Status;
                  /* Begin bug 5087510 PA.M CWK changes. */
                  l_Timecard_Table(l_Timecard_Table_Index).Po_Line_Id := l_Proj_Attrib_Rec.Po_Line_Id;
                  l_Timecard_Table(l_Timecard_Table_Index).PO_Price_Type := l_Proj_Attrib_Rec.PO_Price_Type;
                  l_Timecard_Table(l_Timecard_Table_Index).Person_Type := l_Proj_Attrib_Rec.Person_Type;
                  l_Timecard_Table(l_Timecard_Table_Index).Po_Header_Id := l_Proj_Attrib_Rec.Po_Header_Id;
                  /* End bug 5087510 */
                  /* Bug 4022269 added action column to allowed summary validation extension to
                   * be able to determine if OTL timecard is being saved or submitted.
                   */
                  l_Timecard_Table(l_Timecard_Table_Index).Action := P_Operation; -- Validate values: SAVE or SUBMIT

			      -- Though this is not needed it helps to clarify that a reset these local
			      -- variables is assumed at this point.
			      --
			      G_Stage := 'Reset variable used for table insert';
			      l_Proj_Attrib_Rec := Null;

		     End If; -- P_Message_Table.Count = 0

	    End If; -- Detail Scope Building Block

	    G_Stage := 'Check to exit loop.';
	    Exit When i = P_Building_Blocks.Last;

   End Loop; -- Processing Building Blocks Loop

   G_Stage := 'Done with Processing Building Blocks loop.';
   If P_Message_Table.Count = 0 and l_Timecard_Table.COUNT > 0 Then

        /* Not need to null out l_msg_name and l_exp_status but doing so for clarity. */
		l_Msg_Name := Null;

		G_Stage := 'Calling Summary-validation Extension';
 		-- Summary level Validation Call
        Pagtcx.Summary_Validation_Extension(
             P_Timecard_Table        => l_Timecard_Table,
             P_Module                => 'OTL',
             X_Expenditure_Id        => Null,
             X_Incurred_By_Person_Id => l_Timecard_Table(1).Incurred_By_Person_Id,
             X_Expenditure_End_Date  => Null,
             X_Exp_Class_Code        => 'PT',
             X_Status                => l_Exp_Status,
             X_Comment               => l_Msg_Name);

		If l_Exp_Status = 'REJECTED' Then

			-- Add record to error message table
			G_Stage := 'Calling Summary-validation Extension - Insert Error Rec.';
            G_Msg_Tokens_Table.Delete;

            Pa_Otc_Api.Add_Error_To_Table(
                 P_Message_Table           => P_Message_Table,
                 P_Message_Name            => l_Msg_Name,
                 P_Message_Level           => 'ERROR',
                 P_Message_Field           => Null,
                 P_Msg_Tokens              => G_Msg_Tokens_Table,
                 P_Time_Building_Block_Id  => NULL, --Bug5215484  l_Time_Building_Block_Id,
                 P_Time_Attribute_Id       => Null);

		End If;

		If Nvl(Fnd_Profile.Value('PA_SST_ENABLE_BUS_MSG'),'N') = 'Y' Then

	       	 -- Business Message Call
			 G_Stage := 'Calling Business Message API';
             Pa_Time_Client_Extn.Display_Business_Message(
                  P_Timecard_Table       => l_Timecard_Table,
		          P_Module               => 'OTL',
                  P_Person_id            => l_Timecard_Table(1).Incurred_By_Person_Id,
                  P_Week_Ending_Date     => Null,
                  X_Msg_Application_Name => l_Msg_Application,
                  X_Message_Data         => l_Msg_Name,
                  X_Msg_Token1_Name      => l_Msg_Token1_Name,
                  X_Msg_Token1_Value     => l_Msg_Token1_Value ,
                  X_Msg_Token2_Name      => l_Msg_Token2_Name,
                  X_Msg_Token2_Value     => l_Msg_token2_Value,
                  X_Msg_Token3_Name      => l_Msg_Token3_Name,
                  X_Msg_Token3_Value     => l_Msg_Token3_Value);

			 If l_Msg_Name is Not Null Then

                  -- Add record to error message table
                  G_Stage := 'Calling Business Message API - Insert Business Rec Msg.';
		          G_Msg_Tokens_Table.Delete;

				  If l_Msg_Token1_Name is Not Null Then

				       G_Msg_Tokens_Table(1).Token_Name := l_Msg_Token1_Name;
					   G_Msg_Tokens_Table(1).Token_Value := l_Msg_Token1_Value;

				  End If;

                  If l_Msg_Token2_Name is Not Null Then

                       G_Msg_Tokens_Table(2).Token_Name := l_Msg_Token2_Name;
                       G_Msg_Tokens_Table(2).Token_Value := l_Msg_Token2_Value;

                  End If;

                  If l_Msg_Token3_Name is Not Null Then

                       G_Msg_Tokens_Table(3).Token_Name := l_Msg_Token3_Name;
                       G_Msg_Tokens_Table(3).Token_Value := l_Msg_Token3_Value;

                  End If;

				  If l_Msg_Application is Null Then

				       l_Msg_Application := 'PA';

				  End If;

                  Pa_Otc_Api.Add_Error_To_Table(
                       P_Message_Table           => P_Message_Table,
                       P_Message_Name            => l_Msg_Name,
                       P_Message_Level           => 'BUSINESS',
                       P_Message_Field           => Null,
                       P_Msg_Tokens              => G_Msg_Tokens_Table,
                       P_Time_Building_Block_Id  => NULL, --Bug5215484  l_Time_Building_Block_Id,
                       P_Time_Attribute_Id       => Null,
				       P_Message_App             => l_Msg_Application);

			 End If; -- l_Msg_Name is Not Null

		End If; -- Profile 'PA_SST_ENABLE_BUS_MSG' = 'Y'

		G_Stage := 'Last point of looping thru all the weeks.';

    End If; -- P_Message_Table.Count = 0 and l_Timecard_Table.Count > 0

    G_Stage := 'Leaving procedure Validate_Process().';
    Pa_Otc_Api.TrackPath('STRIP','Validate_Process');

  Exception
	When E_Unhandled_Exception Then
		Raise_Application_Error(-20021,SqlErrm(to_number(l_Status)));

	When E_Dff_Exception Then
		G_Stage := G_Stage || ' => ' || l_Error_Stage;
		Raise_Application_Error(-20021,l_Error_Message);

        When Others Then
                Raise;

  End Validate_Process;


-- =======================================================================
-- Start of Comments
-- API Name      : Validate_Project_Exists
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure accepts the Project_Id
--                 as IN parameter and ckecks if this project exists in
--                 Oracle Projects.  This procedure does not perform any
--                 extensive project related validations.  If the project
--                 exists in Oracle Projects, X_project_Number will be populated
--                 with segment1, else X_project_number will be null.
-- Parameters    :
-- IN
--           P_Project_Id - Pa_Projects_All.Project_Id%TYPE
-- OUT
--           X_Error_Code - Varchar2
--           X_Error_Type - Varchar2
--           X_Project_Id - Pa_Projects_All.Segment1%TYPE

/*-------------------------------------------------------------------------*/

  Procedure Validate_Project_Exists(
			P_Project_Id     IN         Pa_Projects_All.Project_Id%TYPE,
                        X_Error_Code     OUT NOCOPY Varchar2,
                        X_Error_Type     OUT NOCOPY Varchar2,
			X_Project_Number OUT NOCOPY Pa_Projects_All.Segment1%TYPE)
  Is

    /* begin bug 4766396
	Cursor GetProjInfo(P_Proj_Id IN Pa_Projects_All.Project_Id%TYPE) Is
	Select
                Project_Number
	From
                Pa_Online_Projects_V
	Where
                Project_Id = P_Proj_Id; */

    Cursor GetProjInfo(P_Proj_Id IN Pa_Projects_All.Project_Id%TYPE) IS
    select
          p.segment1
    from  Pa_Online_Projects_V pp,
          pa_projects_all p
    where pp.Project_Id = P_Proj_Id
    and   pp.project_id = p.project_id;
    /* end bug 4766396 */

	l_Proj_Num     Pa_Projects_All.Segment1%TYPE := Null;

  Begin

	G_Stage := 'Entering procedure Validate_Project_Exists().';
	Pa_Otc_Api.TrackPath('ADD','Validate_Project_Exists');

   	If P_Project_Id is Not Null Then

		G_Stage := 'Open cursor GetProjInfo.';
		Open GetProjInfo(P_Project_Id);

		G_Stage := 'Fetch Project info from cursor.';
		Fetch GetProjInfo Into l_Proj_Num;

		G_Stage := 'Close cursor GetProjInfo.';
		Close GetProjInfo;

      		If l_Proj_Num is Null Then

			G_Stage := 'No project number was returned - Invalid project.';

         		-- This implies that this project is no longer valid to use. This
			-- can be due to many different reasons.
			-- Providing the specific reason why the project can no longer be
			-- used is impractical, so a generic message is sent back to the user.

         		X_Error_Type := 'E';
         		X_Error_Code := 'INVALID_PROJECT';

		ELSE

			X_Project_Number := l_Proj_Num;

      		End If; -- End l_Proj_Num is null

   	Else  -- Project id is null

		G_Stage := 'The Project Id parameter are Null - Invalid parameter values.';

      		-- Both project id and project number are null,
      		-- this should not occur under normal situations.
      		-- if this occurs then populate error_type with 'E'
      		-- (normal Error).

      		X_Error_Type :=  'E';
      		X_Error_Code := 'PA_PROJ_PARAM_IS_NULL';

   	End If; -- End Project Id is not null

	G_Stage := 'Leaving procedure Validate_Project_Exists().';
	Pa_Otc_Api.TrackPath('STRIP','Validate_Project_Exists');

   EXCEPTION
	When Others Then
   		Raise;

   End Validate_Project_Exists;


-- =======================================================================
-- Start of Comments
-- API Name      : Validate_Task_Exists
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure accepts the Project_Id, Task_Number
--                 IN parameters and ckecks if this task exists in
--                 pa_online_task_v.  This procedure does not perform any
--                 extensive task related validations.  If the task
--                 exists in the online view, X_task_Id will be populated
--                 with task_id, else X_task_id will be null.
-- Parameters    :
-- IN
--           P_Task_Id     - Pa_Tasks.Task_Id%TYPE
--           P_Project_Id  - Pa_Projects.Project_Id%TYPE
-- OUT
--           X_Error_Code  - Varchar2
--           X_Error_Type  - Varchar2
--           X_Task_Number - Pa_Tasks.Task_Number%TYPE
/*-------------------------------------------------------------------------*/

   Procedure Validate_Task_Exists(
                        P_Task_Id     IN         Pa_Tasks.Task_Id%TYPE,
			P_Project_Id  IN         Pa_Projects.Project_Id%TYPE,
                        X_Error_Code  OUT NOCOPY Varchar2,
                        X_Error_Type  OUT NOCOPY Varchar2,
			X_Task_Number OUT NOCOPY Pa_Tasks.Task_Number%TYPE)
   Is

	l_Task_Num  Pa_Tasks.Task_Number%TYPE := Null;
	l_Task_Name Pa_Tasks.Task_Name%TYPE := Null;

    /* begin bug 4766396
	Cursor Validate_ProjTask_Combo(P_Prj_Id IN Number,
				       P_Tsk_Id IN Number) Is
	Select
              Task_Number
	From
              Pa_Online_Tasks_V
	Where
              Task_Id    = P_Tsk_Id
	And       Project_Id = P_Prj_Id; */

    cursor Validate_ProjTask_Combo(P_Prj_Id IN NUMBER,
                                   P_Tsk_Id IN NUMBER) is
    select
          t.task_number
    from  pa_online_tasks_v tt,
          pa_tasks t
    where
          tt.task_id    = P_Tsk_Id
    and   tt.project_id = P_Prj_Id
    and   t.task_id     = tt.task_id;
    /* end bug 4766396 */

   Begin

   	-- Validate project_id parameter

	G_Stage := 'Entering procedure Validate_Task_Exists().';
	Pa_Otc_Api.TrackPath('ADD','Validate_Task_Exists');

      	If P_Task_Id is Not Null Then

		G_Stage := 'Parameter P_Task_Id is not Null, get Task Info.';
		Pa_Utils.GetTaskInfo (
                        X_Task_Id   => P_Task_Id,
                        X_Task_Num  => l_Task_Num,
                        X_Task_Name => l_Task_Name);

       		-- Check if retrieved task number for the task id.
		-- If it didn't then the task id is invalid,
		-- return normal error.

         	If l_Task_Num is Null Then

			G_Stage := 'The returned Task Number is Null so error out.';
            		X_Error_Type := 'E';
            		X_Error_Code := 'INVALID_TASK';

		Else -- Check the project/task combo being valid

			G_Stage := 'Open cursor Validate_ProjTask_Combo.';
			Open Validate_ProjTask_Combo(P_Project_Id,P_Task_Id);

			G_Stage := 'Fetch data from cursor Validate_ProjTask_Combo.';
			Fetch Validate_ProjTask_Combo into l_Task_Num;

			G_Stage := 'Close cursor Validate_ProjTask_Combo.';
			Close Validate_ProjTask_Combo;

			If l_Task_Num is Null Then

				G_Stage := 'Invalid Project/Task combination.  Populate error code.';
				X_Error_Type := 'E';
				X_Error_Code := 'PA_INVALID_PROJ_TASK_COMB';

			Else

				G_Stage := 'The Project/Task combination is valid.';

				X_Task_Number := l_Task_Num;

			End If;

         	End If; -- end l_Task_Number is null

      	Else -- Task Id is Null

		G_Stage := 'The parameter P_Task_Id is Null so error out.';
         	X_Error_Type := 'E';
         	X_Error_Code := 'INVALID_TASK';

      	End If; -- End P_Task_Id is not null

	G_Stage := 'Leaving procedure Validate_Task_Exists().';
	Pa_Otc_Api.TrackPath('STRIP','Validate_Task_Exists');

   Exception
	When Others Then
   	   Raise;

   End Validate_Task_Exists;


-- ==========================================================================
-- Start of Comments
-- API Name      : Validate_Exp_Type_Exists
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure checks if the system linkage/expenditure type
--                 combination exists in the database for the given date.
-- Parameters    :
-- IN
--           P_System_Linkage   - Pa_System_Linkages.Function%TYPE
--           P_Expenditure_Type - Pa_Expenditure_Types.Expenditure_Type%TYPE
--           P_Exp_Item_date    - Pa_Expenditure_Items_All.Expenditure_Item_Date%TYPE
-- OUT
--           X_Error_Code       - Varchar2
--           X_Error_Type       - Varchar2

/*--------------------------------------------------------------------------*/

   Procedure Validate_Exp_Type_Exists(
               P_System_Linkage   IN         Pa_System_Linkages.Function%TYPE,
               P_Expenditure_Type IN         Pa_Expenditure_Types.Expenditure_Type%TYPE,
	       P_Exp_Item_Date    IN         Pa_Expenditure_Items_All.Expenditure_Item_Date%TYPE,
               X_Error_Type       OUT NOCOPY Varchar2,
               X_Error_Code       OUT NOCOPY Varchar2) Is

      Cursor Cur_Etype_Slink (P_EI_Date IN Date,
			      P_Sys_Link_Func IN Varchar2,
			      P_Exp_Type IN Varchar2) Is
      Select
             System_Linkage_Function,
             Expenditure_Type
      From
             Pa_Online_Expenditure_Types_V
      Where
             System_Linkage_Function = P_Sys_Link_Func
      And    Expenditure_Type        = P_Exp_Type
      And    P_Exp_Item_Date Between Sys_Link_Start_Date_Active
				                 And Nvl(Sys_Link_End_Date_Active,P_EI_Date)
      And    P_Exp_Item_Date Between Expnd_Typ_Start_Date_Active
				                 And Nvl(Expnd_Typ_End_Date_Active,P_EI_Date)
      And    system_linkage_function in ('ST','OT'); -- bug 5020394

      Rec_Ets Cur_Etype_Slink%RowType;

   Begin

	G_Stage := 'Entering procedure Validate_Exp_Type_Exists().';
	Pa_Otc_Api.TrackPath('ADD','Validate_Exp_Type_Exists');

	G_Stage := 'Open cursor Fetch AdjustmentAllowed.';
   	Open Cur_Etype_Slink(P_Exp_Item_Date,P_System_Linkage,P_Expenditure_Type);

	G_Stage := 'Fetch from cursor Cur_Etype_Slink.';
   	Fetch Cur_Etype_Slink Into Rec_Ets;

	G_Stage := 'Close cursor Cur_Etype_Slink.';
   	Close Cur_Etype_Slink;

	G_Stage := 'Check if exp type sys link func conditions passed muster.';
   	If Rec_Ets.Expenditure_Type is Null Then

		G_Stage := 'Expenditure Type is null so error out.';
      		X_Error_Type := 'E';
      		X_Error_Code := 'INVALID_ETYPE_SYSLINK';

   	End If;

	G_Stage := 'Leaving procedure Validate_Exp_Type_Exists().';
	Pa_Otc_Api.TrackPath('STRIP','Validate_Exp_Type_Exists');

   Exception
	When Others Then
   		Raise;

   End Validate_Exp_Type_Exists;


-- ===========================================================================
-- API Name      : Validate_overriding_approver
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This function validates the overriding approver entered
--                 in timecard header screen.  If the approver_id is passed
--                 then it is implied that the overriding approver is picked
--                 from the LOV provided in enter timecard header screen, in
--                 this case it is not necessary to validate the overriding
--                 approver bcoz the LOV displays only valid approvers.
--                 However if the overriding approver_id is null and
--                 overriding approver_name is provided, then the approver
--                 name is validated against pa_exp_ovrrde_approver_v view.
--
-- Parameters    :
--  IN
--           P_Approver_Id - Per_People_F.Person_Id%TYPE
--
--  OUT
--           X_Approver_Id - Per_People_F.Person_Id%TYPE
--           X_Error_Type  - Varchar2
--           X_Error_Code  - Varchar2
/* ------------------------------------------------------------------------*/

   Procedure Validate_Overriding_Approver(
		    P_Approver_Id IN         Per_People_F.Person_Id%TYPE,
                    X_Approver_Id OUT NOCOPY Per_People_F.Person_Id%TYPE,
                    X_Error_Type  OUT NOCOPY Varchar2,
                    X_Error_Code  OUT NOCOPY Varchar2) Is

   Begin

	G_Stage := 'Entering procedure Validate_Overriding_Approver().';
	Pa_Otc_Api.TrackPath('ADD','Validate_Overriding_Approver');

	G_Stage := 'Check if Approver Id populated or not.';
   	If P_Approver_Id is Not Null Then

      		/*
       		 * Performance related change:
       		 * distinct clause added in this query so that the view Pa_Exp_Ovrrde_Approver_V
       		 * gets merged.
       		 */
		G_Stage := 'Get Overriding Approver Id.';
      		Select
                        Distinct
			Person_Id
      		Into
			X_Approver_Id
      		From
			Pa_Exp_Ovrrde_Approver_V
      		Where
			Person_Id = P_Approver_Id;

	Else -- P_Approver_Id is Null.

		Raise No_Data_Found;

   	End If; -- End Approver_Id is not null

	G_Stage := 'Leaving procedure Validate_Overriding_Approver().';
	Pa_Otc_Api.TrackPath('STRIP','Validate_Overriding_Approver');

   Exception
	When No_Data_Found Then
   		X_Error_Type := 'E';
   		X_Error_Code := 'PA_OVRRDE_APPROVER_NOT_VALID';

	When Too_Many_Rows Then
   		X_Error_Type := 'E';
   		X_Error_Code := 'PA_TOO_MANY_OVRRD_APPROVER';

	When Others Then
   		Raise;

   End Validate_Overriding_Approver;


-- =======================================================================
-- Start of Comments
-- API Name      : DetermineProcessingFlags
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure deteremines the three flags necessary for processing
--                 of the data further along in the main processing routine
--                 Update_Validate_Timecard() which class this procedure at the for each
--                 DETAIL record being looped thru.
--
-- Parameters    :
-- IN
--		P_BB_Id                - Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE
--      P_BB_Ovn	           - Hxc_Time_Building_Blocks.Object_Version_Number%TYPE
--      P_BB_Date_To           - Hxc_Time_Building_Blocks.Date_To%TYPE
--      P_BB_Changed           - VARCHAR2
--      P_BB_New               - VARCHAR2
--      P_Proj_Attribute_Rec   - Pa_Otc_Api.Project_Attribution_Rec
--      P_Mode                 - VARCHAR2(10)
--      P_Process_Flag         - Varchar2(30)
-- OUT
--		X_BB_Detail_Changed    - VARCHAR2(1)
--		X_Data_Conflict_Flag   - VARCHAR2(1)
--      X_BB_Detail_Deleted    - VARCHAR2(1)
--      X_Adj_in_Projects_Flag - VARCHAR2(1)
--

/*--------------------------------------------------------------------------*/

   Procedure DetermineProcessingFlags (
		P_BB_Id                IN         Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE,
		P_BB_Ovn               IN         Hxc_Time_Building_Blocks.Object_Version_Number%TYPE,
		P_BB_Date_To           IN         Hxc_Time_Building_Blocks.Date_To%TYPE,
		P_BB_Changed           IN         Varchar2,
		P_BB_New               IN         Varchar2,
		P_Proj_Attribute_Rec   IN         Pa_Otc_Api.Project_Attribution_Rec,
		P_Mode                 IN         Varchar2,
        P_Process_Flag         IN         Varchar2,
		X_BB_Detail_Changed    OUT NOCOPY Varchar2,
		X_Data_Conflict_Flag   OUT NOCOPY Varchar2,
		X_BB_Detail_Deleted    OUT NOCOPY Varchar2,
		X_Adj_in_Projects_Flag OUT NOCOPY Varchar2)

   Is

	l_Orig_Trx_Ref     Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE := Null;
	l_Net_Zero_flag    Pa_Expenditure_Items_All.Net_Zero_Adjustment_Flag%TYPE := 'N';
	l_Max_Version      Number := 0;
	l_RowId            RowId;
	l_Exp_Item_Id      Pa_Expenditure_Items_All.Expenditure_Item_Id%TYPE;
	l_Exp_Item_Comment Pa_Expenditure_Comments.Expenditure_Comment%TYPE;
	l_Ovn_Check_Value  Number := 0;

	 /*Start -changes for bug:7604482 */
 	                  l_Proj_Id             Pa_Projects_All.Project_Id%TYPE;
 	                  l_Task_Id             Pa_Tasks.Task_Id%TYPE;
 	                  l_Exp_Type            Pa_Expenditure_Types.Expenditure_Type%TYPE;
 	 /*End -changes for bug:7604482 */

	Cursor AdjustmentRecords (P_Orig_Trx_Ref IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE) Is
	Select
		RowId,
		Expenditure_Item_Id,
                Net_Zero_Adjustment_Flag,
		Orig_Transaction_Reference
        From
                Pa_Expenditure_Items_All
        Where
                Transaction_Source = 'ORACLE TIME AND LABOR'
        And     Orig_Transaction_Reference like l_orig_trx_ref
	Order By Orig_Transaction_Reference;

        Cursor EiIsChanged ( P_RowId IN RowId ) Is
        Select
		'Y'
        From
		Pa_Expenditure_Items_All ei,
                Pa_Expenditure_Comments c
	Where
          	ei.Expenditure_Item_Id            =  c.Expenditure_Item_Id(+)
	And    (ei.Task_Id                        <> nvl(P_Proj_Attribute_Rec.Task_Id,-99)
        Or      ei.Expenditure_Type               <> nvl(P_Proj_Attribute_Rec.Expenditure_Type,'-999999999')
        Or      ei.System_Linkage_Function        <> nvl(P_Proj_Attribute_Rec.Sys_Linkage_Func,'-99')
        Or      ei.Quantity                       <> nvl(P_Proj_Attribute_Rec.Quantity,-99)
        Or      nvl(ei.Attribute_Category,'-99')  <> nvl(P_Proj_Attribute_Rec.Attrib_Category,'-99')
        Or      nvl(ei.Attribute1,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute1,'-99')
        Or      nvl(ei.Attribute2,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute2,'-99')
        Or      nvl(ei.Attribute3,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute3,'-99')
        Or      nvl(ei.Attribute4,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute4,'-99')
        Or      nvl(ei.Attribute5,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute5,'-99')
        Or      nvl(ei.Attribute6,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute6,'-99')
        Or      nvl(ei.Attribute7,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute7,'-99')
        Or      nvl(ei.Attribute8,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute8,'-99')
        Or      nvl(ei.Attribute9,'-99')          <> nvl(P_Proj_Attribute_Rec.Attribute9,'-99')
        Or      nvl(ei.Attribute10,'-99')         <> nvl(P_Proj_Attribute_Rec.Attribute10,'-99')
        Or      nvl(c.Expenditure_Comment,'-99')  <> nvl(P_Proj_Attribute_Rec.Expenditure_Item_Comment,'-99')
        Or      nvl(ei.PO_Line_Id,-99)            <> nvl(P_Proj_Attribute_Rec.PO_Line_Id,-99)
        Or      nvl(ei.PO_Price_Type,'-99')       <> nvl(P_Proj_Attribute_Rec.PO_Price_Type,'-99') )
        And     ei.RowId                          =  P_RowId;

	AdjRec AdjustmentRecords%RowType;
        l_Orig_Transaction_Reference Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE;
        l_Ei_Changed_Flag Varchar2(1) := 'N';

	E_Exception Exception;

   Begin

	G_Stage := 'Entering procedure DetermineProcessingFlags().';
	Pa_Otc_Api.TrackPath('ADD','DetermineProcessingFlags');

	G_Stage := 'Initialize the out parameters to No.';
        X_BB_Detail_Changed    := 'N';
        X_Data_Conflict_Flag   := 'N';
        X_BB_Detail_Deleted    := 'N';
        X_Adj_in_Projects_Flag := 'N';

        G_Stage := 'Check for deleted detail bb.';
        If P_BB_Date_To <> Hr_General.End_Of_Time Then

		G_Stage := 'Detail bb block has been deleted.';
               	X_BB_Detail_Deleted := 'Y';

        End If;

	-- If an item has been deleted in OTL then P_BB_Changed = Y as well.

	G_Stage := 'Check and setting the ovn value to scan Project ei table with';
	If P_BB_Changed = 'Y' and P_BB_New = 'N' Then

		G_Stage := 'The detail scope bb has changed.';
		l_Ovn_Check_Value := P_BB_Ovn + 1;
		X_BB_Detail_Changed := 'Y';

	ElsIf X_BB_Detail_Deleted = 'Y' Then

        G_Stage := 'The detail scope bb is being deleted.';
		l_Ovn_Check_Value := P_BB_Ovn + 1;

    ElsIf P_Process_Flag = 'Y' Then

        -- Only the header for the timecard has been changed and not the detail
        -- building block, but the detail bb ovn still needs to be incremented.
        G_Stage := 'The detail scope bb is being processed.';
        l_Ovn_Check_Value := P_BB_Ovn + 1;

	Else

		l_Ovn_Check_Value := P_BB_Ovn;

	End If;

	/* Build the value for "where like" clause in cursor to check for in projects
	 * in cursor call.
	 */

	G_Stage := 'Create conditional variable value.';
	l_orig_trx_ref := to_char(P_BB_Id) || ':%';

	G_Stage := 'Open cursor AdjustmentRecords.';
	Open AdjustmentRecords (l_orig_trx_ref);

	G_Stage := 'Start Loop for cursor AdjustmentRecords.';
	Loop

		G_Stage := 'Fetch AdjustmentRecords.';
		Fetch AdjustmentRecords into AdjRec;

		/* If there are no records then the exit routine is fire the first time
		 * it is executed and the default value for the net zero flag of 'N' will be used.
		 */
		Exit When AdjustmentRecords%NOTFOUND;

		/* Since the original_transaction_reference columns is a concatenation of Building Block Id
		 * and the Object Version Number for the OTL record being processed, we need to determine the
		 * max Object Version Number always for determining if adjustments can be done, since we only
		 * want to look at the last record imported into Projects for this with the same Building Block
		 * Id in the pa_expenditure_items table.
		 */

		G_Stage := 'Check match condition.';
		If l_Max_Version < To_Number(Substr(AdjRec.Orig_Transaction_Reference,
						Instr(AdjRec.Orig_Transaction_Reference,':') + 1)) Then

			G_Stage := 'Store nzf, row_id, ei_id, orig_trans_ref, and Max Version variables.';
			l_Net_Zero_flag := AdjRec.Net_Zero_Adjustment_Flag;
			l_Max_Version := To_Number(Substr(AdjRec.Orig_Transaction_Reference,
					     		Instr(AdjRec.Orig_Transaction_Reference,':') + 1));
			l_RowId := AdjRec.RowId;
			l_Exp_Item_Id := AdjRec.Expenditure_Item_Id;
			l_Orig_Transaction_Reference := AdjRec.Orig_Transaction_Reference;

		ElsIf l_Max_Version = To_Number(Substr(AdjRec.Orig_Transaction_Reference,
                                                Instr(AdjRec.Orig_Transaction_Reference,':') + 1)) And
		      nvl(AdjRec.Net_Zero_Adjustment_Flag,'N') <> 'Y' Then

                        /* If an earlier adjustment was made in OTL and that was sent to Project via Trx Import
                         * there will be two ei records with the same Orig_Transaction_Reference.  Both need to
                         * be looked at since one will have a Net_Zero_Adjustment_Flag = 'Y' and the other will not.
                         */

			G_Stage := 'Store nzf, row_id, ei_id variables where org_trx_ref is same.';
			l_Net_Zero_flag := AdjRec.Net_Zero_Adjustment_Flag;
			l_RowId := AdjRec.RowId;
			l_Exp_Item_Id := AdjRec.Expenditure_Item_Id;

		End If;

	End Loop;

	G_Stage := 'Close cursor AdjustmentRecords.';
	Close AdjustmentRecords;

	/* If l_Max_Version = 0 Then the OTL Building Block was never imported into Projects.
	 * If l_Max_Version > 0 Then the OTL Building Block has been imported at least once into Projects.
	 */

	G_Stage := 'Determining if BB sent for validation is a change from the one in projects.';
	If l_Max_Version > 0 Then

		/* l_Max_Version should always be less than or equal to the Object_Version_Number
               	 * passed to this procedure. It should never be greater than the Object_Version_Number passed in.
		 * If l_Max_Version = l_Ovn_Check_Value Then the bb was not changed and can ignore further testing.
		 */
		If l_Max_Version < l_Ovn_Check_Value Then

			G_Stage := 'Open cursor EiIsChanged.';
               		Open EiIsChanged( l_RowId ) ;

			G_Stage := 'Fetch from cursor EiIsChanged.';
               		Fetch EiIsChanged into l_Ei_Changed_Flag;

			G_Stage := 'Close cursor EiIsChanged.';
               		Close EiIsChanged;

               		If l_Ei_Changed_Flag = 'N' Then

				If P_Mode = 'VALIDATE' and
                   ( P_BB_Changed = 'Y' or P_Process_Flag = 'Y' ) and
				   X_BB_Detail_Deleted = 'N' Then

			   	   	G_Stage := 'Only Ovn has changed.  Update the orig_transaction_reference of the ei.';
                    Update Pa_Expenditure_Items
                    Set
                         Orig_Transaction_Reference = To_Char(P_BB_Id) || ':' || To_Char(l_Ovn_Check_Value),
                         last_update_date = sysdate,
                         last_updated_by = to_Number(Fnd_Profile.Value('USER_ID')),
                         last_update_login = to_Number(Fnd_Profile.Value('LOGIN_ID'))
                    Where
                         RowId = l_RowId;
                       /*Start-Changes for Bug:7604482 */
 	                   select  project_id , task_id, expenditure_type
 	                      into    l_Proj_Id , l_task_id , l_Exp_Type
 	                    from Pa_Expenditure_Items
 	                    where RowId = l_RowId;

 	              IF (l_Proj_Id <> nvl(P_Proj_Attribute_Rec.project_Id,-99)or l_Task_Id <> nvl(P_Proj_Attribute_Rec.Task_Id,-99) Or l_Exp_Type  <> nvl(P_Proj_Attribute_Rec.Expenditure_Type,'-999999999')) then
 	                    G_Stage := 'Set the BB_Detail_Changed flag to Y.';
 	                    X_BB_Detail_Changed := 'Y';
 	               ELSE
		    -- Since only the ovn has changed we don't care about net zero flag value.
                    -- And we can ignore the change over all since we are updating the
                    -- ei record to store the new ovn.  No change we care about has occurred.
                    G_Stage := 'Set the BB_Detail_Changed flag to N.';
                    X_BB_Detail_Changed := 'N';
		      END IF;
 	           /*End-Changes for Bug:7604482*/
			      /* Bug 2283011  The changed_flag is coming in as 'N' for deleted items not 'Y' so
                                 we don't need to consider it value then.
		 		ElsIf P_BB_Changed = 'Y' and */
				ElsIf X_BB_Detail_Deleted = 'Y' and
				      l_Net_Zero_flag = 'Y' Then

					G_Stage := 'BB/EI has been already changed in Projects, so cannot delete.';
					X_Adj_in_Projects_Flag := 'Y';

				End If;

			Else -- The OTL detail block record is different from what is in Projects.

			    	G_Stage := 'Check net zero flag value to indicate adj in Projects.';
               			/* Note that If net zero flag is 'Y' then l_max_version > 0 */
               			If l_Net_Zero_flag = 'Y' Then

				   	G_Stage := 'BB/EI has been already changed in Projects, so cannot change.';
                       		   	X_Adj_in_Projects_Flag := 'Y' ;

				   	G_Stage := 'Checking for Data confict.';
				   	If P_BB_Changed = 'N' and X_BB_Detail_Deleted = 'N' Then

				   		G_Stage := 'Data conflict exists.';
                                   		X_Data_Conflict_Flag := 'Y';

				   	End If;

               			End If; -- Net_Zero_Flag

               		End If; -- l_Ei_Changed_Flag = 'N'

		End If; -- l_Max_Version < l_Ovn_Check_Value

	End If; -- l_Max_Version > 0

	G_Stage := 'Leaving procedure DetermineProcessingFlags().';
	Pa_Otc_Api.TrackPath('STRIP','DetermineProcessingFlags');

   Exception
	When Others Then
		Raise;

   End DetermineProcessingFlags;


-- =======================================================================
-- Start of Comments
-- API Name      : AdjustAllowedToOTCItem
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to check and see if an OTL expenditure item that
--                 has been imported into Projects can adjusted in Projects by calling the
--                 API Hxc_Generic_Retrieval_Utils.Time_Bld_Blk_Changed.
--
-- Parameters    :
-- IN            P_Orig_Txn_Reference - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
-- OUT           X_Flag               - Varchar2(1)
--
/*--------------------------------------------------------------------------*/

   Procedure  AdjustAllowedToOTCItem(
                     P_Orig_Txn_Reference IN         Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE,
		     X_flag               OUT NOCOPY BOOLEAN) Is

      l_BB_Id        Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE;
      l_BB_Ovn       Hxc_Time_Building_Blocks.Object_Version_Number%TYPE;
      l_Changed_Flag Boolean := False;

   Begin

        G_Stage := 'Entering procedure AdjustAllowedToOTCItem().';
        Pa_Otc_Api.TrackPath('ADD','AdjustAllowedToOTCItem');

	G_Path := ' ';

	G_Stage := 'Check if the original transaction reference is null or not.';
	If P_Orig_Txn_Reference Is Not Null Then

		G_Stage := 'BB Id and BB Ovn.';
		l_BB_Id := To_Number(SubStr(P_Orig_Txn_Reference,1,InStr(P_Orig_Txn_Reference,':') - 1));
		l_BB_Ovn := To_Number(SubStr(P_Orig_Txn_Reference,InStr(P_Orig_Txn_Reference,':') + 1));

		G_Stage := 'Call Hxc_Integration_Layer_V1_Grp.Time_Bld_Blk_Changed API.';
		l_Changed_Flag := Hxc_Integration_Layer_V1_Grp.Time_Bld_Blk_Changed(
					P_Bb_Id => l_bb_id,
					P_Bb_Ovn => l_bb_ovn);

		G_Stage := 'Set out going flag based on what OTL is saying.';
		If l_Changed_Flag Then

			X_flag := False;

		Else

			X_Flag := True;

		End If;

	Else

                /* Did not originate in OTL.  This item is a resulting child of the
		 * original OTL item that was adjusted.  So want to always default it
		 * so that it can adjusted and let other code restrictions in PA handle
		 * whether or not the expenditure item can be adjusted.
		 */
		X_Flag := True;

	End If;

	G_Stage := 'Leaving procedure AdjustAllowedToOTCItem().';
	Pa_Otc_Api.TrackPath('STRIP','AdjustAllowedToOTCItem');

   Exception
	When Others Then
		Raise_Application_Error(-20003,'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' : ' || SQLERRM);

   End AdjustAllowedToOTCItem;


-- =======================================================================
-- Start of Comments
-- API Name      : ProjectTaskUsed
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to check to see if there are Project OTL
--                 expenditure items that are using a specific project or task. Will be calling
--                 an OTL API to determine this.  If parameters are not properly populated then
--                 return TRUE.
--
-- Parameters    :
-- IN            P_Search_Attribute - Varchar2 -- 'PROJECT_ID' or 'TASK_ID'
--               P_Search_Value     - Number   -- Project_Id or Task_Id
-- OUT           X_Used             - Boolean
--

/*--------------------------------------------------------------------------*/

   Procedure ProjectTaskUsed(
				P_Search_Attribute IN         Varchar2,
				P_Search_Value     IN         Number,
				X_Used             OUT NOCOPY Boolean)

   Is

	l_Attribute_Exists Boolean := False;

   Begin

	G_Stage := 'Entering procedure ProjectTaskUsed().';
	Pa_Otc_Api.TrackPath('ADD','ProjectTaskUsed');

        G_Path := ' ';

	G_Stage := 'Check that the parameters is valid.';
	If P_Search_Attribute in ('PROJECT','TASK') and P_Search_Value is not null Then

		If P_Search_Attribute = 'PROJECT' Then

			G_Stage := 'Call Hxc_Integration_Layer_V1_Grp.Chk_Mapping_Exists() API to check if project exists.';
                	l_Attribute_Exists := Hxc_Integration_Layer_V1_Grp.Chk_Mapping_Exists (
					   P_Bld_Blk_Info_Type => 'PROJECTS'
                                   ,       P_Field_Name        => 'Project_Id'
                                   ,       P_Field_Value       => P_Search_Value
                                   ,       P_status            => 'WORKING' -- 8360516
                                   ,       P_Scope             => 'DETAIL');

		Else

			G_Stage := 'Call Hxc_Integration_Layer_V1_Grp.Chk_Mapping_Exists() API to check if task exists.';
			l_Attribute_Exists := Hxc_Integration_Layer_V1_Grp.Chk_Mapping_Exists (
                                           P_Bld_Blk_Info_Type => 'PROJECTS'
                                   ,       P_Field_Name        => 'Task_Id'
                                   ,       P_Field_Value       => P_Search_Value
                                   ,       P_status            => 'WORKING' -- 8360516
                                   ,       P_Scope             => 'DETAIL');

		End If;


		X_Used := l_Attribute_Exists;

	Else

		X_Used := True;

	End If;

	G_Stage := 'Leaving procedure ProjectTaskUsed().';
	Pa_Otc_Api.TrackPath('STRIP','ProjectTaskUsed');

   Exception
	When Others Then
		Raise_Application_Error(-20005,'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' : ' || SQLERRM);

   End ProjectTaskUsed;

-- =======================================================================
-- Start of Comments
-- API Name      : ProjectTaskPurgeable
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to check to see if there are Project OTC
--                 expenditure items that are using a specific project or task that have/have not been
--                 imported successfullying into projects.  Will be calling
--                 an OTC API to determine this.  If parameters are not properly populated then
--                 return TRUE.
--
-- Parameters    :
-- IN            P_Search_Attribute - Varchar2 -- 'PROJECT' or 'TASK'
--               P_Search_Value     - Number   -- Project_Id or Task_Id
-- OUT           X_Purgeable        - Boolean
--

/*--------------------------------------------------------------------------*/

   Procedure ProjectTaskPurgeable(P_Search_Attribute IN         Varchar2,
                                  P_Search_Value     IN         Number,
                                  X_Purgeable        OUT NOCOPY Boolean)

   Is

        l_Attribute_Purgeable Boolean := False;

   Begin

        G_Stage := 'Entering procedure ProjectTaskPurgeable().';
        Pa_Otc_Api.TrackPath('ADD','ProjectTaskPurgeable');

        G_Path := ' ';

        G_Stage := 'Check that the parameters is valid.';
        If P_Search_Attribute in ('PROJECT','TASK') And P_Search_Value is Not Null Then

                If P_Search_Attribute = 'PROJECT' Then

                        G_Stage := 'Call Hxc_Integration_Layer_V1_Grp.Chk_Mapping_Exists() API procedure to check if project purgeable.';
                        l_Attribute_Purgeable := Hxc_Integration_Layer_V1_Grp.Chk_Mapping_Exists (
                                                       P_Bld_Blk_Info_Type      => 'PROJECTS'
                                               ,       P_Field_Name             => 'Project_Id'
                                               ,       P_Field_Value            => P_Search_Value
                                               ,       P_Scope                  => 'DETAIL'
				               ,       P_Retrieval_Process_Name => 'Projects Retrieval Process');

                Else

                        G_Stage := 'Call Hxc_Integration_Layer_V1_Grp.Chk_Mapping_Exists() API procedure to check if task purgeable.';
                        l_Attribute_Purgeable := Hxc_Integration_Layer_V1_Grp.Chk_Mapping_Exists (
                                                       P_Bld_Blk_Info_Type      => 'PROJECTS'
                                               ,       P_Field_Name             => 'Task_Id'
                                               ,       P_Field_Value            => P_Search_Value
                                               ,       P_Scope                  => 'DETAIL'
				               ,       P_Retrieval_Process_Name => 'Projects Retrieval Process');

                End If;


		/* Chk_Mapping_Exists() returns TRUE if the field name / value combination exist but have
		 * not yet been transferred. FALSE, if they have been transferred or the
		 * combination does not exist.
	         */
		If l_Attribute_Purgeable Then

                	X_Purgeable := False;

		Else

			X_Purgeable := True;

		End If;

        Else

                X_Purgeable := False;

        End If;

        G_Stage := 'Leaving procedure ProjectTaskPurgeable().';
        Pa_Otc_Api.TrackPath('STRIP','ProjectTaskPurgeable');

   Exception
        When Others Then
                Raise_Application_Error(-20006,'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' : ' || SQLERRM);

   End ProjectTaskPurgeable;


-- ========================================================================
-- Start Of Comments
-- API Name      : RetrieveProjAttribution
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to pull out the needed project specific data from
--                 the OTL pl/sql table P_Attribute_Table.
--
-- Parameters    :
-- IN            P_Building_Block_Rec  - Hxc_User_Type_Definition_Grp.Building_Block_Info
--               P_Building_Block      - Hxc_User_Type_Definition_Grp.Timecard_Info
--               P_Attribute_Table     - Hxc_User_Type_Definition_Grp.App_Attributes_Info
--               X_Detail_Attr_Changed - Varchar2
-- OUT
--               X_Detail_Attr_Changed - Varchar2
--               X_Proj_Attrib_Rec     - Pa_Otc_Api.Project_Attribution_Rec
--

/*--------------------------------------------------------------------------*/

   Procedure RetrieveProjAttribution(
        P_Building_Block_Rec  IN            Hxc_User_Type_Definition_Grp.Building_Block_Info,
		P_Building_Block      IN            Hxc_User_Type_Definition_Grp.Timecard_Info,
        P_Attribute_Table     IN            Hxc_User_Type_Definition_Grp.App_Attributes_Info,
		X_Detail_Attr_Changed IN OUT NOCOPY Varchar2,
        X_Proj_Attrib_Rec     OUT    NOCOPY Pa_Otc_Api.Project_Attribution_Rec) -- 2672653

   Is

	    j Binary_Integer := Null;
	    i Binary_Integer := Null;
        l_Attrib_Category Varchar2(30) := Null;

   Begin

        G_Stage := 'Entering procedure RetrieveProjAttribution().';
        Pa_Otc_Api.TrackPath('ADD','RetrieveProjAttribution');

        G_Stage := 'Entering attribute table loop.';
        Loop

		     If j is null Then

		          j := P_Attribute_Table.First;

		     Else

			      j := P_Attribute_Table.Next(j);

		     End If;

		     G_Stage := 'Looping thru attribute pl/sql table yanking out project attribution for current record.';
		     If P_Attribute_Table(j).Building_Block_Id = P_Building_Block_Rec.Time_Building_Block_Id Then

                  If Upper(P_Attribute_Table(j).Attribute_Name) = 'PROJECT_ID' Then

			           G_Stage := 'Get Project Id.';
                       X_Proj_Attrib_Rec.Project_Id   := To_Number(P_Attribute_Table(j).Attribute_Value);
				       G_Stage := 'Get Project Attribute Id.';
				       X_Proj_Attrib_Rec.Proj_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;
				       -- X_Proj_Attrib_Rec.Proj_Attr_Ovn := P_Attribute_Table(j).Object_Version_Number;

				       G_Stage := 'Check project  changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
				            X_Detail_Attr_Changed := 'Y';
			           End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'TASK_ID' Then

			           G_Stage := 'Get Task Id.';
                       X_Proj_Attrib_Rec.Task_Id      := To_Number(P_Attribute_Table(j).Attribute_Value);
				       G_Stage := 'Get Task Attribute Id';
				       X_Proj_Attrib_Rec.Task_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check task changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'EXPENDITURE_TYPE' Then

			           G_Stage := 'Get Expenditure Type.';
                       X_Proj_Attrib_Rec.Expenditure_Type := P_Attribute_Table(j).Attribute_Value;
				       G_Stage := 'Get Expenditure Type Attribute Id';
				       X_Proj_Attrib_Rec.Exp_Type_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check expenditure_type changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'SYSTEM_LINKAGE_FUNCTION' Then

			           G_Stage := 'Get Sys Link Func.';
                       X_Proj_Attrib_Rec.Sys_Linkage_Func := P_Attribute_Table(j).Attribute_Value;
				       G_Stage := 'Get Sys Link Func Attribute Id.';
				       X_Proj_Attrib_Rec.Sys_Link_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check sys link func changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'DUMMY PAEXPITDFF CONTEXT' Then

                       /* The value column contains the following format:
                        *   'PAEXPITDFF - <attribute_category>'
                        * So to get the attribute_category out will need to find the position
                        * for ' - ' that is: '<space>-<space>' and then add 3.
                        */

                       l_Attrib_Category := P_Attribute_Table(j).Attribute_Value;

                       /* Need to check for null to avoid the unecessary errors using instr
                        * avoiding unhandled exceptions.
                        */
                       If l_Attrib_Category is not null Then

				            G_Stage := 'Get DFF Attribute Category.';
                            X_Proj_Attrib_Rec.Attrib_Category := substr(l_Attrib_Category, instr(l_Attrib_category,' - ') + 3);

                       End If;

                       G_Stage := 'Check Attribute Category changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE1' Then

			           G_Stage := 'Get DFF Attribute 1.';
                       X_Proj_Attrib_Rec.Attribute1 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 1 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE2' Then

				       G_Stage := 'Get DFF Attribute 2.';
                       X_Proj_Attrib_Rec.Attribute2 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 2 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE3' Then

				       G_Stage := 'Get DFF Attribute 3.';
                       X_Proj_Attrib_Rec.Attribute3 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 3 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE4' Then

				       G_Stage := 'Get DFF Attribute 4.';
                       X_Proj_Attrib_Rec.Attribute4 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 4 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE5' Then

				       G_Stage := 'Get DFF Attribute 5.';
                       X_Proj_Attrib_Rec.Attribute5 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 5 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
				            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE6' Then

				       G_Stage := 'Get DFF Attribute 6.';
                       X_Proj_Attrib_Rec.Attribute6 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 6 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
				            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE7' Then

				       G_Stage := 'Get DFF Attribute 7.';
                       X_Proj_Attrib_Rec.Attribute7 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 7 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE8' Then

				       G_Stage := 'Get DFF Attribute 8.';
                       X_Proj_Attrib_Rec.Attribute8 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 8 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE9' Then

				       G_Stage := 'Get DFF Attribute 9.';
                       X_Proj_Attrib_Rec.Attribute9 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 9 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE10' Then

				       G_Stage := 'Get DFF Attribute 10.';
                       X_Proj_Attrib_Rec.Attribute10 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 10 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'BILLABLE_FLAG' Then

				       G_Stage := 'Get Billable Flag Index value.';
                       X_Proj_Attrib_Rec.Billable_Flag_Index := j;

				       G_Stage := 'Get Billable Flag.';
				       X_Proj_Attrib_Rec.Billable_Flag := P_Attribute_Table(j).Attribute_Value;

				       G_Stage := 'Get Billable Flag Attribute Id.';
				       X_Proj_Attrib_Rec.Billable_Flag_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

				       -- G_Stage := 'Get Billable Flag Attribute Ovn.';
				       -- X_Proj_Attrib_Rec.Billable_Flag_Attr_Ovn := P_Attribute_Table(j).Object_Version_Number;

			      -- Begin CWK changes PA.M
			      ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PO LINE ID' Then

				       G_Stage := 'Get PO_Line Number.';
                       X_Proj_Attrib_Rec.Po_Line_Id := P_Attribute_Table(j).Attribute_Value;
				       G_Stage := 'Get PO Line Id Attribute Id.';
				       X_Proj_Attrib_Rec.PO_Line_Id_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check PO_Line Number change flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

			      ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PO PRICE TYPE' Then

				       G_Stage := 'Get Price Type.';
                       X_Proj_Attrib_Rec.PO_Price_Type := P_Attribute_Table(j).Attribute_Value;
				       G_Stage := 'Get Price Type Attribute Id.';
				       X_Proj_Attrib_Rec.PO_Price_Type_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check Price Type change flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

			      -- End CWK changes PA.M
                  End If;

		     End If;  -- The correct building block to pull data from.

		     G_Stage := 'Exit loop check.';
		     Exit When j = P_Attribute_Table.Last;

        End Loop;

	    G_Stage := 'Get Expenditure Item Date using loop to grab from DAY scope record.';
	    /* The Start Time column in the DETAIL scope record passed to this procedure will not be populated.
           So we must grab the Start Time column value from the DAY scope.  We will loop thru the same table
           containing the entire timecard and find the correct DAY scope record for the detail scope record that
           we are currently working on. */

	    Loop

	         If i is null Then

		          i := P_Building_Block.First;

		     Else

			      i := P_Building_Block.Next(i);

		     End If;

		     G_Stage := 'Check if the current record is the correct DAY record to grab Exp Item Date from.';
		     If P_Building_Block(i).Time_Building_Block_Id = P_Building_Block_Rec.Parent_Building_Block_Id and
		        P_Building_Block(i).Scope = 'DAY' Then

		          G_Stage := 'Grab the Exp Item Date and exit the loop.';
			      X_Proj_Attrib_Rec.Expenditure_Item_Date := Trunc(P_Building_Block(i).Start_Time);
			      Exit;

		     End If;

        End Loop;

	    G_Stage := 'Get Expenditure Ending Date.';
	    X_Proj_Attrib_Rec.Exp_Ending_date := Pa_Utils.NewGetWeekEnding(X_Proj_Attrib_Rec.Expenditure_Item_Date);

	    G_Stage := 'Get Unit of Measure.';
	    X_Proj_Attrib_Rec.UOM := P_Building_Block_Rec.Unit_Of_Measure;

	    G_Stage := 'Get Inc By Person Id.';
	    X_Proj_Attrib_Rec.Inc_By_Person_Id := P_Building_Block_Rec.Resource_Id;

	    G_Stage := 'Get the Quantity.';
	    X_Proj_Attrib_Rec.Quantity := to_number(P_Building_Block_Rec.Measure);

	    G_Stage := 'Get the Expenditure Item Comment.';
        /* Bug 2930551 Check for length and truncate if needed */
        -- begin bug 4926265
        -- If length(P_Building_Block_Rec.Comment_Text) > 240 Then
        If lengthb(P_Building_Block_Rec.Comment_Text) > 240 Then

             -- X_Proj_Attrib_Rec.Expenditure_Item_Comment := substr(P_Building_Block_Rec.Comment_Text,1,240);
             X_Proj_Attrib_Rec.Expenditure_Item_Comment := substrb(P_Building_Block_Rec.Comment_Text,1,240);
             -- end  bug 4926265

        Else

             X_Proj_Attrib_Rec.Expenditure_Item_Comment := P_Building_Block_Rec.Comment_Text;

        End If;

	    -- Beging CWK changes PA.M
	    G_Stage := 'Get Person_Type.';
	    X_Proj_Attrib_Rec.Person_Type := Pa_Otc_Api.GetPersonType(
                                              P_Person_Id => X_Proj_Attrib_Rec.Inc_By_Person_Id,
						                      P_Ei_Date   => X_Proj_Attrib_Rec.Expenditure_Item_Date);


	    If X_Proj_Attrib_Rec.Person_Type = 'CWK' And X_Proj_Attrib_Rec.Po_Line_Id Is Not Null Then

	         G_Stage := 'Get PO Info.';
		     PA_Otc_Api.GetPOInfo(
                  P_PO_Line_Id   => X_Proj_Attrib_Rec.Po_Line_Id,
			      X_PO_Header_Id => X_Proj_Attrib_Rec.PO_Header_Id,
			      X_Vendor_Id    => X_Proj_Attrib_Rec.Vendor_Id);

	    End If;

	    -- End CWK changes PA.M
	    G_Stage := 'Leaving procedure RetrieveProjAttribution().';
	    Pa_Otc_Api.TrackPath('STRIP','RetrieveProjAttribution');

   Exception
	    When Others Then
	         Raise;

   End RetrieveProjAttribution;


-- ========================================================================
-- Start Of Comments
-- API Name      : RetrieveProjAttribForUpd
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to pull out the needed project specific data from
--                 the OTL pl/sql table P_Attribute_Table.
--
-- Parameters    :
-- IN            P_Building_Block_Rec  - Hxc_User_Type_Definition_Grp.Building_Block_Info
--               P_Building_Block      - Hxc_User_Type_Definition_Grp.Timecard_Info
--               P_Attribute_Table     - Hxc_User_Type_Definition_Grp.App_Attributes_Info
--               X_Detail_Attr_Changed - Varchar2
-- OUT
--               P_Attribute_Table     - Hxc_User_Type_Definition_Grp.App_Attributes_Info
--               X_Detail_Attr_Changed - Varchar2
--               X_Proj_Attrib_Rec     - Pa_Otc_Api.Project_Attribution_Rec
--

/*--------------------------------------------------------------------------*/

   Procedure RetrieveProjAttribForUpd(
        P_Building_Block_Rec  IN            Hxc_User_Type_Definition_Grp.Building_Block_Info,
        P_Building_Block      IN            Hxc_User_Type_Definition_Grp.Timecard_Info,
        P_Attribute_Table     IN OUT NOCOPY Hxc_User_Type_Definition_Grp.App_Attributes_Info,
        X_Detail_Attr_Changed IN OUT NOCOPY Varchar2,
        X_Proj_Attrib_Rec        OUT NOCOPY Pa_Otc_Api.Project_Attribution_Rec) -- 2672653

   Is

	    j Binary_Integer := Null;
	    i Binary_Integer := Null;
        l_Attrib_Category Varchar2(30) := Null;
        found_billable   BOOLEAN ;
        billable_index   BINARY_INTEGER := Null;
        project_index    BINARY_INTEGER := Null;

   Begin

        G_Stage := 'Entering procedure RetrieveProjAttribution().';
        Pa_Otc_Api.TrackPath('ADD','RetrieveProjAttribution');

        found_billable := false;

        G_Stage := 'Entering attribute table loop.';
        Loop

		     If j is null Then

		          j := P_Attribute_Table.First;

		     Else

			      j := P_Attribute_Table.Next(j);

		     End If;

		     G_Stage := 'Looping thru attribute pl/sql table yanking out project attribution for current record.';
		     If P_Attribute_Table(j).Building_Block_Id = P_Building_Block_Rec.Time_Building_Block_Id Then

                  If Upper(P_Attribute_Table(j).Attribute_Name) = 'PROJECT_ID' Then

			           G_Stage := 'Get Project Id.';
                       project_index := j;
                       X_Proj_Attrib_Rec.Project_Id   := To_Number(P_Attribute_Table(j).Attribute_Value);
				       G_Stage := 'Get Project Attribute Id.';
				       X_Proj_Attrib_Rec.Proj_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;
				       -- X_Proj_Attrib_Rec.Proj_Attr_Ovn := P_Attribute_Table(j).Object_Version_Number;

				       G_Stage := 'Check project  changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
				            X_Detail_Attr_Changed := 'Y';
			           End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'TASK_ID' Then

			           G_Stage := 'Get Task Id.';
                       X_Proj_Attrib_Rec.Task_Id      := To_Number(P_Attribute_Table(j).Attribute_Value);
				       G_Stage := 'Get Task Attribute Id';
				       X_Proj_Attrib_Rec.Task_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check task changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'EXPENDITURE_TYPE' Then

			           G_Stage := 'Get Expenditure Type.';
                       X_Proj_Attrib_Rec.Expenditure_Type := P_Attribute_Table(j).Attribute_Value;
				       G_Stage := 'Get Expenditure Type Attribute Id';
				       X_Proj_Attrib_Rec.Exp_Type_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check expenditure_type changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'SYSTEM_LINKAGE_FUNCTION' Then

			           G_Stage := 'Get Sys Link Func.';
                       X_Proj_Attrib_Rec.Sys_Linkage_Func := P_Attribute_Table(j).Attribute_Value;
				       G_Stage := 'Get Sys Link Func Attribute Id.';
				       X_Proj_Attrib_Rec.Sys_Link_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check sys link func changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'DUMMY PAEXPITDFF CONTEXT' Then

                       /* The value column contains the following format:
                        *   'PAEXPITDFF - <attribute_category>'
                        * So to get the attribute_category out will need to find the position
                        * for ' - ' that is: '<space>-<space>' and then add 3.
                        */

                       l_Attrib_Category := P_Attribute_Table(j).Attribute_Value;

                       /* Need to check for null to avoid the unecessary errors using instr
                        * avoiding unhandled exceptions.
                        */
                       If l_Attrib_Category is not null Then

				            G_Stage := 'Get DFF Attribute Category.';
                            X_Proj_Attrib_Rec.Attrib_Category := substr(l_Attrib_Category, instr(l_Attrib_category,' - ') + 3);

                       End If;

                       G_Stage := 'Check Attribute Category changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE1' Then

			           G_Stage := 'Get DFF Attribute 1.';
                       X_Proj_Attrib_Rec.Attribute1 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 1 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE2' Then

				       G_Stage := 'Get DFF Attribute 2.';
                       X_Proj_Attrib_Rec.Attribute2 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 2 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE3' Then

				       G_Stage := 'Get DFF Attribute 3.';
                       X_Proj_Attrib_Rec.Attribute3 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 3 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE4' Then

				       G_Stage := 'Get DFF Attribute 4.';
                       X_Proj_Attrib_Rec.Attribute4 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 4 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE5' Then

				       G_Stage := 'Get DFF Attribute 5.';
                       X_Proj_Attrib_Rec.Attribute5 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 5 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
				            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE6' Then

				       G_Stage := 'Get DFF Attribute 6.';
                       X_Proj_Attrib_Rec.Attribute6 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 6 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
				            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE7' Then

				       G_Stage := 'Get DFF Attribute 7.';
                       X_Proj_Attrib_Rec.Attribute7 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 7 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE8' Then

				       G_Stage := 'Get DFF Attribute 8.';
                       X_Proj_Attrib_Rec.Attribute8 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 8 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE9' Then

				       G_Stage := 'Get DFF Attribute 9.';
                       X_Proj_Attrib_Rec.Attribute9 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 9 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PADFFATTRIBUTE10' Then

				       G_Stage := 'Get DFF Attribute 10.';
                       X_Proj_Attrib_Rec.Attribute10 := P_Attribute_Table(j).Attribute_Value;

                       G_Stage := 'Check DFF Attribute 10 changed flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

                  ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'BILLABLE_FLAG' Then

				       G_Stage := 'Get Billable Flag Index value.';
                       X_Proj_Attrib_Rec.Billable_Flag_Index := j;

				       G_Stage := 'Get Billable Flag.';
				       X_Proj_Attrib_Rec.Billable_Flag := P_Attribute_Table(j).Attribute_Value;

				       G_Stage := 'Get Billable Flag Attribute Id.';
				       X_Proj_Attrib_Rec.Billable_Flag_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

				       -- G_Stage := 'Get Billable Flag Attribute Ovn.';
				       -- X_Proj_Attrib_Rec.Billable_Flag_Attr_Ovn := P_Attribute_Table(j).Object_Version_Number;

                       G_Stage := 'Found Billable Flag Attribute.';
                       found_billable := true;

			      -- Begin CWK changes PA.M
			      ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PO LINE ID' Then

				       G_Stage := 'Get PO_Line Number.';
                       X_Proj_Attrib_Rec.Po_Line_Id := P_Attribute_Table(j).Attribute_Value;
				       G_Stage := 'Get PO Line Id Attribute Id.';
				       X_Proj_Attrib_Rec.PO_Line_Id_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check PO_Line Number change flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

			      ElsIf Upper(P_Attribute_Table(j).Attribute_Name) = 'PO PRICE TYPE' Then

				       G_Stage := 'Get Price Type.';
                       X_Proj_Attrib_Rec.PO_Price_Type := P_Attribute_Table(j).Attribute_Value;
				       G_Stage := 'Get Price Type Attribute Id.';
				       X_Proj_Attrib_Rec.PO_Price_Type_Attr_Id := P_Attribute_Table(j).Time_Attribute_Id;

                       G_Stage := 'Check Price Type change flag.';
                       If P_Attribute_Table(j).Changed <> 'N' Then
                            X_Detail_Attr_Changed := 'Y';
                       End If;

			      -- End CWK changes PA.M
                  End If;

		     End If;  -- The correct building block to pull data from.

		     G_Stage := 'Exit loop check.';
		     Exit When j = P_Attribute_Table.Last;

        End Loop;

        G_Stage := 'Check if found billable_flag.';
        If(NOT found_billable) Then

             --
             -- We must add the billable flag to the attribute structure, and set the values
             -- appropriately.  We permit the normal processing of the PA code to determine
             -- if this value should be changed.
             --
             G_Stage := 'Did not find billable_flag so get next available index.';
             billable_index := P_Attribute_Table.Last+1;
             --
             -- Find the billable segment name
             -- Cache it, since we don't want to issue the statement
             -- more than we need to, and the value should be session
             -- independent.
             --
             G_Stage := 'Check if already know the dff segment for the billable_flag.';
             If(G_Billable_Segment is null) then

                  G_Stage := 'Get the segment for the billable_flag from hxc table.';
                  select mc.segment
                  Into   G_Billable_Segment
                  from hxc_mapping_components mc,
                  hxc_bld_blk_info_types bbit
                  where mc.field_name = 'BILLABLE_FLAG'
                  and bbit.bld_blk_info_type_id = mc.bld_blk_info_type_id
                  and bbit.bld_blk_info_type = 'PROJECTS';

             End If;

             If project_index is not null then
                  --
                  -- Add the (null) value
                  -- the PROJECTS attribute is a seeded one, but is customizable by the customer.
                  --
                  G_Stage := 'Create the billable_flag attribute record.';
                  P_Attribute_Table(billable_index).time_attribute_id := P_Attribute_Table(project_index).time_attribute_id;
                  P_Attribute_Table(billable_index).building_block_id := P_Attribute_Table(project_index).building_block_id;
                  P_Attribute_Table(billable_index).attribute_name := 'BILLABLE_FLAG';
                  P_Attribute_Table(billable_index).attribute_value := null;
                  P_Attribute_Table(billable_index).attribute_index := P_Attribute_Table(project_index).attribute_index;
                  P_Attribute_Table(billable_index).segment := G_Billable_Segment;
                  P_Attribute_Table(billable_index).bld_blk_info_type := P_Attribute_Table(project_index).bld_blk_info_type;
                  P_Attribute_Table(billable_index).category := P_Attribute_Table(project_index).category;
                  P_Attribute_Table(billable_index).updated := 'N';
                  P_Attribute_Table(billable_index).changed := 'N';
                  --
                  -- Set internal Project attributes based on above value
                  --
                  X_Proj_Attrib_Rec.Billable_Flag_Index := billable_index;
                  X_Proj_Attrib_Rec.Billable_Flag := Null;
                  X_Proj_Attrib_Rec.Billable_Flag_Attr_Id := P_Attribute_Table(billable_index).Time_Attribute_Id;

             End If;

     End If; -- Did we find the billable flag?

	 G_Stage := 'Get Expenditure Item Date using loop to grab from DAY scope record.';
	 /* The Start Time column in the DETAIL scope record passed to this procedure will not be populated.
        So we must grab the Start Time column value from the DAY scope.  We will loop thru the same table
        containing the entire timecard and find the correct DAY scope record for the detail scope record that
        we are currently working on. */

	 Loop

	         If i is null Then

		          i := P_Building_Block.First;

		     Else

			      i := P_Building_Block.Next(i);

		     End If;

		     G_Stage := 'Check if the current record is the correct DAY record to grab Exp Item Date from.';
		     If P_Building_Block(i).Time_Building_Block_Id = P_Building_Block_Rec.Parent_Building_Block_Id and
		        P_Building_Block(i).Scope = 'DAY' Then

		          G_Stage := 'Grab the Exp Item Date and exit the loop.';
			      X_Proj_Attrib_Rec.Expenditure_Item_Date := Trunc(P_Building_Block(i).Start_Time);
			      Exit;

		     End If;

     End Loop;

	 G_Stage := 'Get Expenditure Ending Date.';
	 X_Proj_Attrib_Rec.Exp_Ending_date := Pa_Utils.NewGetWeekEnding(X_Proj_Attrib_Rec.Expenditure_Item_Date);

	 G_Stage := 'Get Unit of Measure.';
	 X_Proj_Attrib_Rec.UOM := P_Building_Block_Rec.Unit_Of_Measure;

	 G_Stage := 'Get Inc By Person Id.';
	 X_Proj_Attrib_Rec.Inc_By_Person_Id := P_Building_Block_Rec.Resource_Id;

	 G_Stage := 'Get the Quantity.';
	 X_Proj_Attrib_Rec.Quantity := to_number(P_Building_Block_Rec.Measure);

	 G_Stage := 'Get the Expenditure Item Comment.';
     /* Bug 2930551 Check for length and truncate if needed */
     -- begin bug 4926265
     -- If length(P_Building_Block_Rec.Comment_Text) > 240 Then
     If lengthb(P_Building_Block_Rec.Comment_Text) > 240 Then

          -- X_Proj_Attrib_Rec.Expenditure_Item_Comment := substr(P_Building_Block_Rec.Comment_Text,1,240);
          X_Proj_Attrib_Rec.Expenditure_Item_Comment := substrb(P_Building_Block_Rec.Comment_Text,1,240);
          -- end bug 4926265

     Else

          X_Proj_Attrib_Rec.Expenditure_Item_Comment := P_Building_Block_Rec.Comment_Text;

     End If;

	 -- Beging CWK changes PA.M
	 G_Stage := 'Get Person_Type.';
	 X_Proj_Attrib_Rec.Person_Type := Pa_Otc_Api.GetPersonType(
                                              P_Person_Id => X_Proj_Attrib_Rec.Inc_By_Person_Id,
						                      P_Ei_Date   => X_Proj_Attrib_Rec.Expenditure_Item_Date);


	 If X_Proj_Attrib_Rec.Person_Type = 'CWK' And X_Proj_Attrib_Rec.Po_Line_Id Is Not Null Then

	      G_Stage := 'Get PO Info.';
		  PA_Otc_Api.GetPOInfo(
                  P_PO_Line_Id   => X_Proj_Attrib_Rec.Po_Line_Id,
			      X_PO_Header_Id => X_Proj_Attrib_Rec.PO_Header_Id,
			      X_Vendor_Id    => X_Proj_Attrib_Rec.Vendor_Id);

	 End If;

	 -- End CWK changes PA.M
	 G_Stage := 'Leaving procedure RetrieveProjAttribution().';
	 Pa_Otc_Api.TrackPath('STRIP','RetrieveProjAttribution');

   Exception
	    When Others Then
	         Raise;

   End RetrieveProjAttribForUpd;

-- ========================================================================
-- Start Of Comments
-- API Name      : GetPRMAssignTemplates
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to pull from PRM the Forecast Assignment data and provide
--                 it as template data for OTL.  It will not have TASK information in it.  It will
--                 be placed in OTL friendly format for the OTL team to populate the current timecard
--                 with the Forecast Assignment data.  Validation for expenditure_type and system_linkage_function
--                 combinations will take place within the code before passing it to OTL.  Any combo that
--                 is not valid for the day in question will not be pulled over.
--
-- Parameters    :
-- IN            P_Resource_Id - Hxc_Time_Building_Blocks.Resource_Id%TYPE
--               P_Start_Date  - Hxc_Time_Building_Blocks.Start_Time%TYPE
--               P_Stop_Date   - Hxc_Time_Building_Blocks.Stop_Time%TYPE
-- OUT
--               P_Attributes  - Varchar2
--               P_Timecard    - Varchar2
--               P_Messages    - Varchar2


/*--------------------------------------------------------------------------*/

   Procedure GetPRMAssignTemplates(
                P_Resource_Id IN         Hxc_Time_Building_Blocks.Resource_Id%TYPE,
                P_Start_Date  IN         Hxc_Time_Building_Blocks.Start_Time%TYPE,
                P_Stop_Date   IN         Hxc_Time_Building_Blocks.Stop_Time%TYPE,
                P_Attributes  OUT NOCOPY Varchar2,
                P_Timecard    OUT NOCOPY Varchar2,
                P_Messages    OUT NOCOPY Varchar2)

   Is

	l_BB_Index                Binary_Integer := 0;
	l_Attrib_Index            Binary_Integer := 0;
	l_Time_Building_Block_Id  Number := 1;
	l_Day_Parent_BB_Id        Number := Null;
	l_Org_Id                  Number := Null;
	l_Valid_ExpTypClass_Combo Varchar2(1) := Null;
	l_Val_Proj_Flag           Varchar2(1) := Null;

	l_Building_Blocks_Table Hxc_User_Type_Definition_Grp.Timecard_Info;
	l_Attribute_Table       Hxc_User_Type_Definition_Grp.App_Attributes_info;
	l_Message_Table         Hxc_User_Type_Definition_Grp.Message_Table;

	l_dummy_bb_Table        Hxc_User_Type_Definition_Grp.Timecard_Info;
	l_dummy_Attrib_Table    Hxc_User_Type_Definition_Grp.App_Attributes_info;

	/* If the profile value is NULL or 'N' then we want to retrieve all the records
	 * irregardless of the value stored in column Provisional_Flag.
	 * If the profile value is 'Y' then we only want to retrieve those records
	 * where column Provisional_Flag = 'Y'.
	 */
/* Begin bug 5011267
    Cursor PRMAssignments(
        P_Emp_Id      IN Number,
		P_Start_Date  IN Date,
		P_Stop_Date   IN Date,
		P_Exp_Org_Id  IN Number) is
	Select
		FI.Project_Id,
		P.Segment1,
		FI.Item_Date,
		FI.Expenditure_Type,
		FI.Expenditure_Type_Class,
		FI.Item_Quantity
	From
		Pa_Forecast_Items FI,
		Pa_Projects_All P,
		Pa_Project_Assignments PPA
	Where
		Person_Id = P_Emp_Id
	And	Item_Date Between P_Start_Date
	                      And P_Stop_Date
	And Forecast_Item_Type in ('A','U')
    And FI.Project_Id = P.Project_Id
	And PPA.assignment_id = FI.assignment_id
	And FI.delete_flag = 'N'
	And Nvl(FI.expenditure_org_id,-99) = Nvl(P_Exp_Org_Id,-99)
	And Nvl(FI.Item_Quantity,0) <> 0
    Order by 2,4,3; -- project/exp_type/item_date
    */

    /* Begin Bug 5366183
    Cursor PRMAssignments(
            P_Emp_Id      IN Number,
            P_Start_Date  IN Date,
            P_Stop_Date   IN Date,
            P_Exp_Org_Id  IN Number) is
    Select
            FI.Project_Id,
            P.Segment1,
            FI.Item_Date,
            FI.Expenditure_Type,
            FI.Expenditure_Type_Class,
            FI.Item_Quantity
    From
            Pa_Forecast_Items FI,
            Pa_Projects_All P
    Where
            Person_Id = P_Emp_Id
    And Item_Date Between P_Start_Date
                      And P_Stop_Date
    And Forecast_Item_Type = 'A'
    And FI.Project_Id = P.Project_Id
    And FI.delete_flag = 'N'
    And FI.expenditure_org_id = P_Exp_Org_Id
    And FI.Item_Quantity <> 0
    Order by 2,4,3; -- project/exp_type/item_date
    */
    /* End bug 5011267 */

    Cursor PRMAssignments(
                    P_Emp_Id      IN Number,
                    P_Start_Date  IN Date,
                    P_Stop_Date   IN Date,
                    P_Exp_Org_Id  IN Number) is
    Select
            FI.Project_Id,
            P.Segment1,
            FI.Item_Date,
            FI.Expenditure_Type,
            FI.Expenditure_Type_Class,
            FI.Item_Quantity
    From
            Pa_Forecast_Items FI,
            Pa_Projects_All P,
            Pa_Resource_Txn_Attributes PTA
    Where
            PTA.Person_Id = P_Emp_Id
    And FI.Resource_id = PTA.Resource_id
    And FI.Item_Date Between P_Start_Date
                     And P_Stop_Date
    And FI.Forecast_Item_Type = 'A'
    And FI.Project_Id = P.Project_Id
    And FI.delete_flag = 'N'
    And FI.expenditure_org_id = P_Exp_Org_Id
    And FI.Item_Quantity <> 0
    Order by 2,4,3; -- project/exp_type/item_date
    /* End bug 5366183 */

   	/* Expenditure_Type_Class is the system_linkage_function */
	--  Cursor ValidateExpTypeAndClass (P_Exp_Item_Date  IN Date,
    -- 					P_Exp_Type       IN Varchar2,
    -- 					P_Exp_Type_Class IN Varchar2) Is
    -- 	Select
    -- 		'Y'
    -- 	From
    -- 		Pa_Online_Expenditure_Types_V
    -- 	Where
    -- 		Expenditure_Type = P_Exp_Type
    -- 	And     System_Linkage_Function = P_Exp_Type_Class
    -- 	And     Trunc(P_Exp_Item_Date) Between Expnd_Typ_Start_Date_Active
    -- 					   And nvl(Expnd_Typ_End_Date_Active, P_Exp_Item_Date)
    -- 	And     Trunc(P_Exp_Item_Date) Between Sys_Link_Start_Date_Active
    -- 					   And nvl(Sys_Link_End_Date_Active, P_Exp_Item_Date);

	PRMAssignRecs  PRMAssignments%ROWTYPE;

	-- Cursor ValidateProject ( P_Project_Id IN Pa_Projects_All.Project_Id%TYPE ) Is
	-- Select
	-- 	'Y'
	-- From
	-- 	Pa_Online_Projects_V
	-- Where
    -- 	Project_Id = P_Project_Id;

   	TYPE Day_Rec IS Record (
        	Day_Index_Number Binary_Integer,
        	Date_for_Day     Date);

   	TYPE Day_Table IS Table OF Day_Rec
        	INDEX BY Binary_Integer;

   	l_Day_Table       Day_Table;
	l_Days_in_Period  Number := 0;


   Begin

	G_Path := ' ';

    G_Stage := 'Entering procedure GetPRMAssignTemplates().';
    Pa_Otc_Api.TrackPath('ADD','GetPRMAssignTemplates');

	G_Stage := 'Initialize the pl/sql message table.';
	l_Message_Table.Delete;
    l_Building_Blocks_Table.Delete;
    l_Attribute_Table.Delete;
    l_dummy_bb_Table.Delete;
    l_dummy_Attrib_Table.Delete;

    /* Begin Bug 3766110
      There is no reason to do any validation in building the template data
      since the data will get validated when the OTL user submits the timecard.

	  -- The default period length for a timecard is a week for Projects OTL timecards.
	  -- But that can be changed.  If the default is kept, then we want to make sure that
	  -- the week ending date is consistant with Projects implementation.

	  l_Days_in_Period := Trunc(P_Stop_Date) - Trunc(P_Start_Date) + 1;

	  G_Stage := 'Checking start and end dates.  Check if OTL using week long timecards.';
      If l_Days_in_Period = 7 Then

		G_Stage := 'Checking end the Stop_Date passed in matches WeekEnding dates in Projects.';
        If Pa_Utils.NewGetWeekEnding(Trunc(P_Stop_Date)) <> Trunc(P_Stop_Date) Then

             G_Msg_Tokens_Table.Delete;

             -- Add record to error table.
             Pa_Otc_Api.Add_Error_To_Table(
                   P_Message_Table           => l_Message_Table,
                   P_Message_Name            => 'PA_INVALID_WEEK_ENDING_DATE',
                   P_Message_Level           => 'ERROR',
                   P_Message_Field           => Null,
                   P_Msg_Tokens              => G_Msg_Tokens_Table,
                   P_Time_Building_Block_Id  => Null,
                   P_Time_Attribute_Id       => Null);

       	End If;

	End If;

    End bug 3766110 */

    l_Days_in_Period := Trunc(P_Stop_Date) - Trunc(P_Start_Date) + 1;

    /* Begin bug 3766110
	G_Stage := 'If messages now exist in pl/sql table then do not do any further processing.  OTL not properly setup.';
	If l_Message_Table.Count = 0 Then
    End bug 3766110 */

		G_Stage := 'Assigning null dummy tables to the BB and Attribution pl/sql tables. ';
		l_Building_Blocks_Table := l_dummy_BB_Table;
		l_Attribute_Table       := l_dummy_Attrib_Table;

		G_Stage := 'Check Multi Org';
		If Pa_Utils.Pa_Morg_Implemented = 'Y' Then

			l_Org_Id := Fnd_Profile.Value('ORG_ID');

		End If;

		-- Insert Timecard Scope record
		G_Stage := 'Build/Insert Timecard Scope BB record.';
		l_BB_Index := l_BB_Index + 1;
		l_Building_Blocks_Table(l_BB_Index).Resource_Id := P_Resource_Id;
		l_Building_Blocks_Table(l_BB_Index).Start_Time := P_Start_Date;
		l_Building_Blocks_Table(l_BB_Index).Stop_Time := P_Stop_Date;
		l_Building_Blocks_Table(l_BB_Index).Scope := 'TIMECARD';
		l_Building_Blocks_Table(l_BB_Index).Date_From := SysDate;
		l_Building_Blocks_Table(l_BB_Index).Date_To := Hr_General.End_Of_Time;
		l_Building_Blocks_Table(l_BB_Index).New := 'Y';
		l_Building_Blocks_Table(l_BB_Index).Resource_Type := 'PERSON';
		l_Building_Blocks_Table(l_BB_Index).Type := 'RANGE';
		l_Building_Blocks_Table(l_BB_Index).Parent_Building_Block_Id := Null;
		l_Building_Blocks_Table(l_BB_Index).Parent_Building_Block_Ovn := Null;
		l_Building_Blocks_Table(l_BB_Index).Approval_Status := 'WORKING';
		l_Building_Blocks_Table(l_BB_Index).Approval_Style_Id := Null;
		l_Building_Blocks_Table(l_BB_Index).Time_Building_Block_Id := l_Time_Building_Block_Id;
		l_Building_Blocks_Table(l_BB_Index).Object_Version_Number := 1;
		l_Building_Blocks_Table(l_BB_Index).Comment_Text := Null;
		l_Building_Blocks_Table(l_BB_Index).Measure := Null;
		l_Building_Blocks_Table(l_BB_Index).Unit_Of_Measure := Null;


		-- Insert Day Scope records.
		G_Stage := 'Build/Insert day scope records using loop based on the number of days in timecard period.';
		For i in 1 .. l_Days_in_Period
		loop

        		G_Stage := 'Create Day Scope Record 1.';
        		l_BB_Index := l_BB_Index + 1;
        		l_Time_Building_Block_Id := l_Time_Building_Block_Id + 1;

        		l_Building_Blocks_Table(l_BB_Index).Resource_Id := P_Resource_Id;
        		l_Building_Blocks_Table(l_BB_Index).Start_Time := P_Start_Date + i - 1;
        		l_Building_Blocks_Table(l_BB_Index).Stop_Time := P_Start_Date + i - 1;
        		l_Building_Blocks_Table(l_BB_Index).Scope := 'DAY';
        		l_Building_Blocks_Table(l_BB_Index).Date_From := SysDate;
        		l_Building_Blocks_Table(l_BB_Index).Date_To := Hr_General.End_Of_Time;
        		l_Building_Blocks_Table(l_BB_Index).New := 'Y';
        		l_Building_Blocks_Table(l_BB_Index).Resource_Type := 'PERSON';
        		l_Building_Blocks_Table(l_BB_Index).Type := 'RANGE';
        		l_Building_Blocks_Table(l_BB_Index).Parent_Building_Block_Id := 1;
        		l_Building_Blocks_Table(l_BB_Index).Parent_Building_Block_Ovn := 1;
        		l_Building_Blocks_Table(l_BB_Index).Approval_Status := 'WORKING';
        		l_Building_Blocks_Table(l_BB_Index).Approval_Style_Id := Null;
        		l_Building_Blocks_Table(l_BB_Index).Time_Building_Block_Id := l_Time_Building_Block_Id;
        		l_Building_Blocks_Table(l_BB_Index).Object_Version_Number := 1;
        		l_Building_Blocks_Table(l_BB_Index).Comment_Text := Null;
        		l_Building_Blocks_Table(l_BB_Index).Measure := Null;
        		l_Building_Blocks_Table(l_BB_Index).Unit_Of_Measure := Null;

			l_Day_Table(i).Day_Index_Number := l_BB_Index;
			l_Day_Table(i).Date_for_Day := l_Building_Blocks_Table(l_BB_Index).Start_Time;

		End Loop;

		-- Create Detail Scope Records as appropriate
        G_Stage := 'Open cursor PRMAssignments to get detail scope data.';
        Open PRMAssignments (
			     P_Emp_Id     => P_Resource_Id,
			     P_Start_Date => P_Start_Date,
			     P_Stop_Date  => P_Stop_Date,
			     P_Exp_Org_Id => l_Org_Id);

        G_Stage := 'Start Loop for cursor PRMAssignments.';
        Loop

			G_Stage := 'Fetch forecast assignment record into record.';
			Fetch PRMAssignments into PRMAssignRecs;
			Exit When PRMAssignments%NotFound;

            /* Begin bug 3766110
              There is no reason to do any validation in building the template data
              since the data will get validated when the OTL user submits the timecard.

			  Check if the expenditure and system_linkage_function combo is valid for the
			  date in question.

			l_Valid_ExpTypClass_Combo := 'N';

			G_Stage := 'Validate Expenditure_Type/Expenditure_Type_Class, open cursor.';
			Open ValidateExpTypeAndClass(
					     PRMAssignRecs.Item_Date,
					     PRMAssignRecs.Expenditure_Type,
					     PRMAssignRecs.Expenditure_Type_Class);

			G_Stage := 'Validate Expenditure_Type/Expenditure_Type_Class, fetch cursor data.';
			Fetch ValidateExpTypeAndClass Into l_Valid_ExpTypClass_Combo;

			G_Stage := 'Validate Expenditure_Type/Expenditure_Type_Class, close cursor.';
			Close ValidateExpTypeAndClass;

			l_Val_Proj_Flag := 'N';

			G_Stage := 'Validate Project, open cursor.';
			Open ValidateProject(PRMAssignRecs.Project_Id);

			G_Stage := 'Validate Project, fetch cursor data.';
			Fetch ValidateProject Into l_Val_Proj_Flag;

			G_Stage := 'Validate Project, close cursor.';
			Close ValidateProject;

			If l_Valid_ExpTypClass_Combo = 'Y' and l_Val_Proj_Flag = 'Y' Then
            */
            -- End bug 3766110

				G_Stage := 'Building and insert detail scope record.';

				l_BB_Index := l_BB_Index + 1;
				l_Time_Building_Block_Id := l_Time_Building_Block_Id + 1;

				<<Day_Loop>>
				For p in l_Day_Table.FIRST .. l_Day_Table.LAST
				Loop

					If l_Day_Table(p).Date_For_Day = PRMAssignRecs.Item_Date Then

						l_Day_Parent_BB_Id := l_Day_Table(p).Day_Index_Number;
						Exit Day_Loop;

					End If;

				End Loop Day_Loop;

                l_Building_Blocks_Table(l_BB_Index).Resource_Id := P_Resource_Id;
                l_Building_Blocks_Table(l_BB_Index).Start_Time := Null;
                l_Building_Blocks_Table(l_BB_Index).Stop_Time := Null;
                l_Building_Blocks_Table(l_BB_Index).Scope := 'DETAIL';
                l_Building_Blocks_Table(l_BB_Index).Date_From := SysDate;
                l_Building_Blocks_Table(l_BB_Index).Date_To := Hr_General.End_Of_Time;
                l_Building_Blocks_Table(l_BB_Index).New := 'Y';
                l_Building_Blocks_Table(l_BB_Index).Resource_Type := 'PERSON';
                l_Building_Blocks_Table(l_BB_Index).Type := 'MEASURE';
				l_Building_Blocks_Table(l_BB_Index).Parent_Building_Block_Id := l_Day_Parent_BB_Id;
				l_Building_Blocks_Table(l_BB_Index).Parent_Building_Block_Ovn := 1;
				l_Building_Blocks_Table(l_BB_Index).Approval_Status := 'WORKING';
				l_Building_Blocks_Table(l_BB_Index).Approval_Style_Id := Null;
                l_Building_Blocks_Table(l_BB_Index).Time_Building_Block_Id := l_Time_Building_Block_Id;
                l_Building_Blocks_Table(l_BB_Index).Object_Version_Number := 1;
                l_Building_Blocks_Table(l_BB_Index).Comment_Text := Null;
                l_Building_Blocks_Table(l_BB_Index).Measure := PRMAssignRecs.Item_Quantity;
                l_Building_Blocks_Table(l_BB_Index).Unit_Of_Measure := 'HOURS';

				-- Create Detail Scope Attribution

				G_Stage := 'Building and insert detail scope attribution records.';
				-- Project Id

				G_Stage := 'Building and insert detail scope attribution record project_Id.';
				l_Attrib_Index := l_Attrib_Index + 1;

                l_Attribute_Table(l_Attrib_Index).Time_Attribute_Id := l_Time_Building_Block_Id;
                l_Attribute_Table(l_Attrib_Index).Building_Block_Id := l_Time_Building_Block_Id;
                l_Attribute_Table(l_Attrib_Index).Attribute_Name := 'Project_Id';
                l_Attribute_Table(l_Attrib_Index).Attribute_Value := PRMAssignRecs.Project_Id;
                l_Attribute_Table(l_Attrib_Index).Updated := 'N';
                l_Attribute_Table(l_Attrib_Index).Bld_Blk_Info_Type := 'PROJECTS';
				l_Attribute_Table(l_Attrib_Index).Category := 'PROJECTS';

				-- Expenditure Type

				G_Stage := 'Building and insert detail scope attribution record Expenditure Type.';
				l_Attrib_Index := l_Attrib_Index + 1;

                l_Attribute_Table(l_Attrib_Index).Time_Attribute_Id := l_Time_Building_Block_Id;
                l_Attribute_Table(l_Attrib_Index).Building_Block_Id := l_Time_Building_Block_Id;
                l_Attribute_Table(l_Attrib_Index).Attribute_Name := 'Expenditure_Type';
                l_Attribute_Table(l_Attrib_Index).Attribute_Value := PRMAssignRecs.Expenditure_Type;
                l_Attribute_Table(l_Attrib_Index).Updated := 'N';
                l_Attribute_Table(l_Attrib_Index).Bld_Blk_Info_Type := 'PROJECTS';
				l_Attribute_Table(l_Attrib_Index).Category := 'PROJECTS';

				-- System Linkage Function

				G_Stage := 'Building and insert detail scope attribution record Expenditure_Type_Class.';
				l_Attrib_Index := l_Attrib_Index + 1;

                l_Attribute_Table(l_Attrib_Index).Time_Attribute_Id := l_Time_Building_Block_Id;
                l_Attribute_Table(l_Attrib_Index).Building_Block_Id := l_Time_Building_Block_Id;
                l_Attribute_Table(l_Attrib_Index).Attribute_Name := 'SYSTEM_LINKAGE_FUNCTION';
                l_Attribute_Table(l_Attrib_Index).Attribute_Value := PRMAssignRecs.Expenditure_Type_Class;
                l_Attribute_Table(l_Attrib_Index).Updated := 'N';
                l_Attribute_Table(l_Attrib_Index).Bld_Blk_Info_Type := 'PROJECTS';
				l_Attribute_Table(l_Attrib_Index).Category := 'PROJECTS';

            /* Begin bug 3766110
			Else

				G_Msg_Tokens_Table.Delete;

				If l_Val_Proj_Flag = 'N' Then

					G_Stage := 'Create error message for Invalid Project in PRM Template.';
					Pa_Otc_Api.Add_Error_To_Table(
                  		P_Message_Table           => l_Message_Table,
                  		P_Message_Name            => 'INVALID_PROJECT',
                  		P_Message_Level           => 'ERROR',
                  		P_Message_Field           => 'Project_Id',
                  		P_Msg_Tokens              => G_Msg_Tokens_Table,
                  		P_Time_Building_Block_Id  => Null,
                  		P_Time_Attribute_Id       => Null);

				End If;

				If l_Valid_ExpTypClass_Combo = 'N' Then

					G_Stage := 'Create error message for Invalid Exp Type/Sys ' ||
					           'Link func in PRM Template.';
                    Pa_Otc_Api.Add_Error_To_Table(
                         P_Message_Table           => l_Message_Table,
                         P_Message_Name            => 'INVALID_ETYPE_SYSLINK',
                         P_Message_Level           => 'ERROR',
                         P_Message_Field           => 'Expenditure_Type',
                         P_Msg_Tokens              => G_Msg_Tokens_Table,
                         P_Time_Building_Block_Id  => Null,
                         P_Time_Attribute_Id       => Null);

				End If;

			End If; -- Valid ExpTypeClass Combo
            */
            -- End bug 3766110

		End Loop; -- Cursor with the data from PRM Assignment forecast data.

		G_Stage := 'Closing cursor PRMAssignments.';
		Close PRMAssignments;

	-- End If; Bug 3766110


	-- The building blocs table will at least have the timecard scope record and the 7 day scope records
	-- so there must be more than 8 records in the pl/sql table to determine if there is data to send back to OTL.
	-- There cannot be any records in the message table as that would mean error and don't want to pass
    -- back a partial set of building blocks.
	If l_Building_Blocks_Table.Count > 1 Then -- and l_Message_Table.Count = 0 Then bug 3766110

		G_Stage := 'Convert Building Blocks pl/sql table to varchar2.';
		P_Timecard := Hxc_Integration_Layer_V1_Grp.Blocks_To_String( P_Blocks => l_Building_Blocks_Table );

		G_Stage := 'Convert Attribution pl/sql table to varchar2.';
		P_Attributes := Hxc_Integration_Layer_V1_Grp.Attributes_To_String ( P_Attributes => l_Attribute_Table );

	End If;

    -- Begin bug 3766110

	-- If l_Message_Table.Count > 0 Then

	--     G_Stage := 'Convert Message pl/sql table to varchar2.';
	-- 	P_Messages := Hxc_Integration_Layer_V1_Grp.Messages_to_String ( P_Messages => l_Message_Table );

	-- End If;

    -- End Bug 3766110

    G_Stage := 'Leaving procedure GetPRMAssignTemplates().';
    Pa_Otc_Api.TrackPath('STRIP','GetPRMAssignTemplates');

   Exception
	When Others then
		Raise_Application_Error(-20007,'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage || ' : ' || SQLERRM);

   End GetPRMAssignTemplates;

-- ========================================================================
-- Start Of Comments
-- API Name      : FindandValidateHeader
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure finds and validate the Timecard Header record.
--                 This procedure is only called when Mode is VALIDATE.
--
-- Parameters    :
-- IN
--           P_Building_Blocks_Table  - Hxc_User_Type_Definition_Grp.Timecard_Info
--           P_Attribute_Table        - Hxc_User_Type_Definition_Grp.App_Attributes_Info
--           P_Message_Table          - Hxc_User_Type_Definition_Grp.Message_Table
-- OUT
--           P_Message_Table          - Hxc_User_Type_Definition_Grp.Message_Table
--           X_TimeBB_Id              - Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE
--           X_Ovr_Approver_Person_Id - Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE
--           X_Timecard_Ending_Date   - Date

/*--------------------------------------------------------------------------*/


   Procedure FindandValidateHeader(
			P_Building_Blocks_Table  IN            Hxc_User_Type_Definition_Grp.Timecard_Info,
                        P_Attribute_Table        IN            Hxc_User_Type_Definition_Grp.App_Attributes_Info,
			P_Message_Table          IN OUT NOCOPY Hxc_User_Type_Definition_Grp.Message_Table, -- 2672653
                        X_TimeBB_Id                 OUT NOCOPY Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE,
			X_Ovr_Approver_Person_Id    OUT NOCOPY Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE,
			X_Pass_Val_Flag             OUT NOCOPY Varchar2,
			X_Approval_Status           OUT NOCOPY Hxc_Time_Building_Blocks.Approval_Status%TYPE)

   Is

	l_Error_Code      Varchar2(30)   := Null;
	l_Error_Type      Varchar2(30)   := Null;

	l_Pass_Val_Flag   Varchar2(1)    := 'Y';
	l_TimeBB_Ovn      Number         := Null;
	i                 Binary_Integer := Null;
	x		  Binary_Integer := Null;
	l_Found           Boolean        := Null;
        l_pref_table  hxc_preference_evaluation.t_pref_table;
        l_period_type varchar2(50);/* bug 5890771 */
	l_termination_date Date := Null; /* Added the variable for bug 7584432 */
        l_assign_end_date_flag Number := 0; /* Added the variable for bug 8528840 */

	 cursor check_tc_period (p_rec_id number) is
	     select hrp.period_type
	       from hxc_recurring_periods hrp
	      where hrp.recurring_period_id = p_rec_id;
      /* Added the cursor for bug 7584432 */
	      Cursor get_termination_date(p_person_id number, p_stop_date DATE) is
	      Select max(effective_end_date) from per_people_f
	      where person_id = p_person_id and
	      effective_end_date <= p_stop_date and
	      (current_employee_flag = 'Y' or current_npw_flag = 'Y');

            /* Added the cursor for bug 8528840 */
              Cursor is_assignment_end_date(p_person_id number, p_stop_date DATE) is
              Select '1' from per_assignments_f where
              person_id = p_person_id and
              trunc(p_stop_date) + 1 between effective_start_date and effective_end_date
              and  assignment_status_type_id in (select assignment_status_type_id
              from PER_ASSIGNMENT_STATUS_TYPES where per_system_status = 'SUSP_ASSIGN');


   Begin

        G_Stage := 'Entering FindandValidateHeader procedure.';
        Pa_Otc_Api.TrackPath('ADD','FindandValidateHeader');

        Loop

	        If i is Null Then

			     i := P_Building_Blocks_Table.First;

		    Else

			     i := P_Building_Blocks_Table.Next(i);

		    End If;

		    G_Stage := 'Get the Time Scope Building Block Id.';
		    If P_Building_Blocks_Table(i).Scope = 'TIMECARD' Then
		       /* bug 5890771*/
                  hxc_preference_evaluation.resource_preferences(
                   p_resource_id   =>  P_Building_Blocks_Table(i).resource_id
           ,       p_pref_code_list=> 'TC_W_TCRD_PERIOD'
           ,       p_pref_table    => l_pref_table );

		   open check_tc_period(l_pref_table(l_pref_table.first).attribute1);
	           fetch check_tc_period into l_period_type;
		   close check_tc_period;
		         X_TimeBB_Id := P_Building_Blocks_Table(i).Time_Building_Block_Id;
		         l_TimeBB_Ovn := P_Building_Blocks_Table(i).Object_Version_Number;
		         X_Approval_Status := P_Building_Blocks_Table(i).Approval_Status;

		  /* bug 5890771 If Trunc(P_Building_Blocks_Table(i).Stop_Time) - Trunc(P_Building_Blocks_Table(i).Start_Time) = 6 Then*/
		   if l_period_type = 'Week' then

			          -- The default timecard period in OTL is a week.

		              If Pa_Utils.NewGetWeekEnding(Trunc(P_Building_Blocks_Table(i).Stop_Time)) <>
			                                          Trunc(P_Building_Blocks_Table(i).Stop_Time) Then

		                               /* change for bug 8528840 start here */
                                                 open is_assignment_end_date(P_Building_Blocks_Table(i).resource_id,P_Building_Blocks_Table(i).Stop_Time);
                                                 fetch is_assignment_end_date into l_assign_end_date_flag;

                                                 If is_assignment_end_date%NOTFOUND Then
                                                   l_assign_end_date_flag := 0;
                                                 End If;
                                                 /* change for bug 8528840 end here */


                                  	           -- The the week ending dates don't match.  This is not allowed.
				            /* change for bug 7584432 start here */

			 			   open get_termination_date(P_Building_Blocks_Table(i).resource_id,P_Building_Blocks_Table(i).Stop_Time);
			 			  fetch get_termination_date into l_termination_date;
							 close get_termination_date;
			 		          if(l_assign_end_date_flag = 0) Then /* Added for bug 8528840 */
			 			  if Trunc(nvl(l_termination_date,P_Building_Blocks_Table(i).Stop_Time + 1)) <> Trunc(P_Building_Blocks_Table(i).Stop_Time) Then

			 			   /* change for bug 7584432 end here */

				           X_Pass_Val_Flag := 'N';
				           G_Msg_Tokens_Table.Delete;

                           -- Add record to error table.
                           Pa_Otc_Api.Add_Error_To_Table(
                                P_Message_Table           => P_Message_Table,
                                P_Message_Name            => 'PA_INVALID_WEEK_ENDING_DATE',
                                P_Message_Level           => 'ERROR',
                                P_Message_Field           => Null,
                                P_Msg_Tokens              => G_Msg_Tokens_Table,
                                P_Time_Building_Block_Id  => X_TimeBB_Id,
                                P_Time_Attribute_Id       => Null);

                        End if;  /*Added  bug 7584432  */

                        End If; /* Added for bug 8528840 */
		  	          End If;

		         End If;

                 -- R12 change
                 -- This section of code is conditionally getting the override approver person id if the
                 -- overriding approver flag is set to Yes and AutoApproval is set to No.  This is not
                 -- correct.  We need only be concerned about the autoapproval flag.
                 -- If Nvl(Fnd_Profile.Value('PA_ONLINE_OVERRIDE_APPROVER'),'N') = 'Y' Then
                 If Nvl(Fnd_Profile.Value('PA_PTE_AUTOAPPROVE_TS'),'N') = 'N' Then

                      /* This variable is being used in the summary validate and
                       * business message section of the procedure.
                       */

		              l_Found := False;

                      G_Stage := 'Time block found.  Need to pull out Overriding Approver if exists.';
		              Loop

			               If x is null Then

				                G_Stage := 'Get first record in attribution table.';
				                x := P_Attribute_Table.First;

			               Else

				                G_Stage := 'Get next record in attribution table.';
				                x := P_Attribute_Table.Next(x);

			               End If;

			               G_Stage := 'Check if found the correct record in attribution table.';
                           If X_TimeBB_Id = P_Attribute_Table(x).Building_Block_Id And
                              Upper(P_Attribute_Table(x).Attribute_Name) = 'OVERRIDING_APPROVER_PERSON_ID' And
                              P_Attribute_Table(x).Bld_Blk_Info_Type = 'APPROVAL' Then

			                    l_Found := True;

                                /* If there is attribute name 'OVERRIDING_APPROVER_PERSON_ID' is found then
                                 * the user populate the field during entry else the user left it alone even
                                 * though the user could have assigned an overriding approver.
                                 */

                                G_Stage := 'Call Validate_Overriding_Approver procedure.';
                                Pa_Otc_Api.Validate_Overriding_Approver(
                                   P_Approver_Id => to_number(P_Attribute_Table(x).Attribute_Value),
                                   X_Approver_Id => X_Ovr_Approver_Person_Id,
                                   X_Error_Code  => l_Error_Code,
                                   X_Error_Type  => l_Error_Type);

                                If l_Error_Code Is Not Null Then

                                     G_Stage := 'Validate Overriding Approver - Inserting error rec.';
				                     G_Msg_Tokens_Table.Delete;

                                     -- Add record to error table.
                                     Pa_Otc_Api.Add_Error_To_Table(
                                        P_Message_Table           => P_Message_Table,
                                        P_Message_Name            => l_Error_Code,
                                        P_Message_Level           => 'ERROR',
                                        P_Message_Field           => 'OVERRIDING_APPROVER_PERSON_ID',
                                        P_Msg_Tokens              => G_Msg_Tokens_Table,
                                        P_Time_Building_Block_Id  => X_TimeBB_Id,
                                        P_Time_Attribute_Id       => P_Attribute_Table(x).Time_Attribute_Id);

                                End If; --  l_Error_Code Is Not Null

                                G_Stage := 'Since found the Overriding Approver rec and validated then exit out of loop.';
                                Exit;

                           End If;  -- Same building block id and attribute_name and BB info type.

			               G_Stage := 'In case of incorrect implementation of overriding approver check if last record.';
			               Exit When x = P_Attribute_Table.LAST;

                      End Loop; -- Loop for Overriding Approver Person Id at Time Scope.

                      /* R12 changes.
                       * We no longer require the overriding approver to be populated.
                       * But will pull it if it is there.
		              G_Stage := 'Check if found the overriding approver person_id record in attribute table.';
		              If Not l_Found Then

		                   G_Stage := 'No attribute record was found for overriding approver when there should have been.';
                           G_Msg_Tokens_Table.Delete;

                           -- Add record to error table.
                           Pa_Otc_Api.Add_Error_To_Table(
                                P_Message_Table           => P_Message_Table,
                                P_Message_Name            => 'PA_OVRRDE_APPROVER_NOT_VALID',
                                P_Message_Level           => 'ERROR',
                                P_Message_Field           => 'OVERRIDING_APPROVER_PERSON_ID',
                                P_Msg_Tokens              => G_Msg_Tokens_Table,
                                P_Time_Building_Block_Id  => X_TimeBB_Id,
                                P_Time_Attribute_Id       => Null);

			               X_Pass_Val_Flag := 'N';

		              End If;
                      */

                 End If; -- Check if Override approver needs to be pulled if exists

		         G_Stage := 'Exit the loop since found the header record and validated it.';
                 Exit;

		     End If; --  Scope is TIMECARD

        End Loop; -- Processing Building Blocks to find Header info and validate.';

	    G_Stage := 'Check if header pass validation and set flag.';
	    If X_Pass_Val_Flag is null Then

		     X_Pass_Val_Flag := 'Y';

	    End If;

        G_Stage := 'Leaving FindandValidateHeader() procedure.';
        Pa_Otc_Api.TrackPath('STRIP','FindandValidateHeader');

   Exception
	When Others Then
		Raise;

   End FindandValidateHeader;

-- =======================================================================
-- Start of Comments
-- API Name      : Wf_AutoApproval_BusMsg
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the OTL client team.
--                 Calls the PA_CLIENT_EXTN_PTE.Get_Exp_AutoApproval() and
--                 the PA_TIME_CLIENT_EXTN.Display_Business_Message().
--
-- Parameters    :
-- OUT
--           X_AutoApproval_Flag    -  Varchar2
--           X_Messages             -  Varchar2

/*------------------------------------------------------------------------- */

  Procedure Wf_AutoApproval_BusMsg
            (X_AutoApproval_Flag    OUT NOCOPY Varchar2
            ,X_Messages             OUT NOCOPY Varchar2)

  Is

        l_Timecard_Table         Pa_Otc_Api.Timecard_Table;
        l_Inc_By_Person_Id       Pa_Expenditures_All.Incurred_By_Person_Id%TYPE;
	l_Overriding_Approver_Id Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE;

        /* Stores a single record from the Building Block Table */
        l_Building_Block_Record  Hxc_User_Type_Definition_Grp.Building_Block_Info;

	l_Message_Name           Varchar2(30);
	l_Message_Table          Hxc_User_Type_Definition_Grp.Message_Table;

        l_Status                 Number(10);
        l_Appl_Id                Varchar2(10);
        l_Msg_Name               Varchar2(30);
        l_Msg_Application        Varchar2(10);
        l_Msg_Token1_Name        Varchar2(30);
        l_Msg_Token1_Value       Varchar2(255);
        l_Msg_Token2_Name        Varchar2(30);
        l_Msg_Token2_Value       Varchar2(255);
        l_Msg_Token3_Name        Varchar2(30);
        l_Msg_Token3_Value       Varchar2(255);

  Begin

	G_Path := ' ';

	G_Stage := 'Entering Wf_AutoApproval_BusMsg() procedure.';
        Pa_Otc_Api.TrackPath('ADD','Wf_AutoApproval_BusMsg');

	G_Stage := 'Initialize the hxc pl/sql tables that will be used.';
        l_Timecard_Table.delete;
	l_Message_Table.delete;

	G_Stage := 'Calling Pa_Otc_Api.CreateProjTimecardTable()';
        Pa_Otc_Api.CreateProjTimecardTable(
                X_Inc_By_Person_Id       => l_Inc_By_Person_Id,
                X_Timecard_Table         => l_Timecard_Table,
                X_Overriding_Approver_Id => l_Overriding_Approver_Id );

	G_Stage := 'Calling Pa_Client_Extn_Pte.Get_Exp_AutoApproval()';
	Pa_Client_Extn_Pte.Get_Exp_AutoApproval (
	        X_Source          => 'PA',
                X_Exp_Class_Code  => 'PT',
                X_Txn_Id          => Null,
                X_Exp_Ending_Date => Null,
                X_Person_Id       => l_Inc_By_Person_Id,
                P_Timecard_Table  => l_Timecard_Table,
                P_Module          => 'OTL',
                X_Approved        => X_AutoApproval_Flag );

	If X_AutoApproval_Flag NOT IN ('N','Y') Then

		G_Stage := 'AutoApproval Extension does not return valid value. Create error message.';
		l_Message_Name := 'PA_TR_INVALID_AUTOAPPROVAL_FLG';
		X_AutoApproval_Flag := Null;

		G_Msg_Tokens_Table.Delete;

                Pa_Otc_Api.Add_Error_To_Table(
                	P_Message_Table           => l_Message_Table,
                        P_Message_Name            => l_Message_Name,
                        P_Message_Level           => 'ERROR',
                        P_Message_Field           => Null,
                        P_Msg_Tokens              => G_Msg_Tokens_Table,
                        P_Time_Building_Block_Id  => Null,
                        P_Time_Attribute_Id       => Null);

	End If;

	/* If the AutoApproval flag is Yes then there is no reason to get the business message for this
         * timecard.
         */
        If X_AutoApproval_Flag = 'N' and Nvl(Fnd_Profile.Value('PA_SST_ENABLE_BUS_MSG'),'N') = 'Y' Then

		G_Stage := 'Calling Pa_Time_Client_Extn.Display_Business_Message()';
                Pa_Time_Client_Extn.Display_Business_Message(
                         P_Timecard_Table       => l_Timecard_Table,
                         P_Module               => 'OTL',
                         P_Person_id            => l_Inc_By_Person_Id,
                         P_Week_Ending_Date     => Null,
                         X_Msg_Application_Name => l_Msg_Application,
                         X_Message_Data         => l_Msg_Name,
                         X_Msg_Token1_Name      => l_Msg_Token1_Name,
                         X_Msg_Token1_Value     => l_Msg_Token1_Value ,
                         X_Msg_Token2_Name      => l_Msg_Token2_Name,
                         X_Msg_Token2_Value     => l_Msg_token2_Value,
                         X_Msg_Token3_Name      => l_Msg_Token3_Name,
                         X_Msg_Token3_Value     => l_Msg_Token3_Value);

                If l_Msg_Name is Not Null Then

			 G_Stage := 'Message was returned from Display_Business_Message Extension.  Create message.';
                         G_Msg_Tokens_Table.Delete;

                         If l_Msg_Token1_Name Is Not Null Then

                                G_Msg_Tokens_Table(1).Token_Name := l_Msg_Token1_Name;
                                G_Msg_Tokens_Table(1).Token_Value := l_Msg_Token1_Value;

                         End If;

                         If l_Msg_Token2_Name Is Not Null Then

                                G_Msg_Tokens_Table(2).Token_Name := l_Msg_Token2_Name;
                                G_Msg_Tokens_Table(2).Token_Value := l_Msg_Token2_Value;

                         End If;

                         If l_Msg_Token3_Name Is Not Null Then

                                G_Msg_Tokens_Table(3).Token_Name := l_Msg_Token3_Name;
                                G_Msg_Tokens_Table(3).Token_Value := l_Msg_Token3_Value;

                         End If;

			 If l_Msg_Application Is Null Then

				l_Msg_Application := 'PA';

			 End If;

                         Pa_Otc_Api.Add_Error_To_Table(
                                    P_Message_Table           => l_Message_Table,
                                    P_Message_Name            => l_Msg_Name,
                                    P_Message_Level           => 'BUSINESS',
                                    P_Message_Field           => Null,
                                    P_Msg_Tokens              => G_Msg_Tokens_Table,
                                    P_Time_Building_Block_Id  => Null,
                                    P_Time_Attribute_Id       => Null,
				    P_Message_App             => l_Msg_Application);

                End If; -- l_Msg_Name Is Not Null

        End If; -- Profile 'PA_SST_ENABLE_BUS_MSG' = 'Y'

	If l_Message_Table.Count > 0 Then

		G_Stage := 'Calling Hxc_Deposit_Wrapper_Utilities.Messages_To_String().';
        	X_Messages := Hxc_Integration_Layer_V1_Grp.Messages_To_String(P_Messages => l_Message_Table);
        End If;

	G_Stage := 'Leaving Wf_AutoApproval_BusMsg() procedure.';
        Pa_Otc_Api.TrackPath('STRIP','Wf_AutoApproval_BusMsg');

  Exception
	When Others Then
		Raise_Application_Error(-20500, 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_stage || ' : ' || SQLERRM );

  End Wf_AutoApproval_BusMsg;

-- =======================================================================
-- Start of Comments
-- API Name      : Wf_RouteTo_CheckApproval
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the OTL client team.
--                 The only intent of the procedure is manipulate
--                 the parameters passed in and then call
--                 the PaRoutingX.Route_To_Extension().
--
-- Parameters    :
-- IN
--           P_Previous_Approver_Id -  Number
-- OUT
--           X_Approver_Person_Id   -  Number
--           X_Messages             -  Varchar2

/*------------------------------------------------------------------------- */

  Procedure Wf_RouteTo_CheckApproval(
            P_Previous_Approver_Id IN         Number,
            X_Approver_Person_Id   OUT NOCOPY Number,
            X_Messages             OUT NOCOPY Varchar2)

  Is

        l_Timecard_Table         Pa_Otc_Api.Timecard_Table;
        l_Inc_By_Person_Id       Pa_Expenditures_All.Incurred_By_Person_Id%TYPE;
	l_Overriding_Approver_Id Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE := Null;

        l_Message_Table          Hxc_User_Type_Definition_Grp.Message_Table;
	l_Message_Name           Varchar2(30);

        l_Status                 Number(10);
        l_Msg_App                Varchar2(10);
        l_Msg_Code               Varchar2(30);
        l_Token_1                Varchar2(255);
        l_Token_2                Varchar2(255);
        l_Token_3                Varchar2(255);
        l_Token_4                Varchar2(255);
        l_Token_5                Varchar2(255);

	l_Approval_Flag          Varchar2(30) := 'COMPLETE:FAIL';  -- Do not change!

        Unexpected_Error         Exception;

  Begin

        G_Path := ' ';

        G_Stage := 'Entering Wf_RouteTo_CheckApproval() procedure.';
        Pa_Otc_Api.TrackPath('ADD','Wf_RouteTo_CheckApproval');

        G_Stage := 'Initialize the PA pl/sql tables that will be used.';
        l_Timecard_Table.Delete;

	G_Stage := 'Calling Pa_Otc_Api.CreateProjTimecardTable()';
        Pa_Otc_Api.CreateProjTimecardTable(
                X_Inc_By_Person_Id       => l_Inc_By_Person_Id,
                X_Timecard_Table         => l_Timecard_Table,
 	        X_Overriding_Approver_Id => l_Overriding_Approver_Id);

	If P_Previous_Approver_Id is Not Null Then

		G_Stage := 'Previous_Approver is not null call Pa_Client_Extn_Rte.Check_Approval().';

        	Pa_Client_Extn_Rte.Check_Approval(
                        X_Expenditure_Id        => Null,
                        X_Incurred_By_Person_Id => l_Inc_By_Person_Id,
                        X_Expenditure_End_Date  => Null,
                        X_Exp_Class_Code        => 'PT',
                        X_Amount                => Null,
                        X_Approver_Id           => P_Previous_Approver_Id,
                        X_Routed_To_Mode        => 'SUPERVISOR',
                        P_Timecard_Table        => l_Timecard_Table,
                        P_Module                => 'OTL',
                        X_Status                => l_Status,
                        X_Application_Id        => l_Msg_App,
                        X_Message_Code          => l_Msg_Code,
                        X_Token_1               => l_Token_1,   -- Token Name --> 'TOKEN_1'
                        X_Token_2               => l_Token_2,   -- Token Name --> 'TOKEN_2'
                        X_Token_3               => l_Token_3,   -- Token Name --> 'TOKEN_3'
                        X_Token_4               => l_Token_4,   -- Token Name --> 'TOKEN_4'
                        X_Token_5               => l_Token_5 ); -- Token Name --> 'TOKEN_5'

        	If l_Status = 0 Then

			G_Stage := 'Previous Approver had final authority to approve the timecard.';
        		l_Approval_Flag := 'COMPLETE:PASS';

        	ElsIf l_Status < 0 Then

			G_Stage := 'Unexpected error occurred in the called routine Pa_Client_Extn_Rte.Check_Approval().';
                	Raise Unexpected_Error;

        	Else  -- l_Status > 0

			G_Stage := 'The previous approver did not have the final authority to approve the timecard.';
                	l_Approval_Flag := 'COMPLETE:FAIL';

                	G_Msg_Tokens_Table.Delete;

                	If l_Msg_Code Is Not Null Then

				G_Stage := 'A message has been passed back from Pa_Client_Extn_Rte.Check_Approval().  ' ||
					   'Create a message.';
                		If l_Token_1 Is Not Null Then

                        		G_Msg_Tokens_Table(1).Token_Name := 'TOKEN_1';
                                	G_Msg_Tokens_Table(1).Token_Value := l_Token_1;

                        	End If;

                        	If l_Token_2 Is Not Null Then

                        		G_Msg_Tokens_Table(2).Token_Name := 'TOKEN_2';
                                	G_Msg_Tokens_Table(2).Token_Value := l_Token_2;

                        	End If;

                        	If l_Token_3 Is Not Null Then

                                	G_Msg_Tokens_Table(3).Token_Name := 'TOKEN_3';
                                	G_Msg_Tokens_Table(3).Token_Value := l_Token_3;

                        	End If;

                        	If l_Token_4 Is Not Null Then

                                	G_Msg_Tokens_Table(4).Token_Name := 'TOKEN_4';
                                	G_Msg_Tokens_Table(4).Token_Value := l_Token_4;

                        	End If;

                        	If l_Token_5 Is Not Null Then

                                	G_Msg_Tokens_Table(5).Token_Name := 'TOKEN_5';
                                	G_Msg_Tokens_Table(5).Token_Value := l_Token_5;

                        	End If;


				If l_Msg_App Is Null Then

					l_Msg_App := 'PA';

				End If;

                        	Pa_Otc_Api.Add_Error_To_Table (
                                	P_Message_Table           => l_Message_Table,
                                	P_Message_Name            => l_Msg_Code,
                                	P_Message_Level           => 'ERROR',
                                	P_Message_Field           => Null,
                                	P_Msg_Tokens              => G_Msg_Tokens_Table,
                                	P_Time_Building_Block_Id  => Null,
                                	P_Time_Attribute_Id       => Null,
					P_Message_App             => l_Msg_App);

			End If; -- Message Code Is Not Null

		End If; -- l_Status

	End If; -- P_Previous_Approver_Id Is Not Null

	/* If the previous approver does not have the authority to make the final decision then
	 * the approval flag will be 'COMPLETE:FAIL'.  If the previous approver did have the
         * authority to have final approval for the timecard being process then the approval
         * flag will be 'COMPLETE:PASS' in which case the route_to_extension does not need
         * to be called.
         */

	-- Approver authority flag check
	If l_Approval_Flag = 'COMPLETE:FAIL' Then

		G_Stage := 'Checking who the next approver should be.';
		/* Want to check and see if there is an overriding approver to send the timecard to for approval.
		 * For this to be correct need to make sure that this part is only called when the timecard is submitted.
		 * That is why we check if the previous approver is null.  It has to be null upon submission.
		 */
		-- Bug 2773066
		-- We don't need to check if the profile is set at this point.
		-- If the overriding approver is populated then use it when appropriate.
		-- If Nvl(Fnd_Profile.Value('PA_ONLINE_OVERRIDE_APPROVER'),'N') = 'Y' And
		If l_Overriding_Approver_Id Is Not Null And
	 	   P_Previous_Approver_Id Is Null Then

			X_Approver_Person_Id := l_Overriding_Approver_Id;

		Else

			G_Stage := 'The previous approver did not have the final authority to approve the timecard.  ' ||
			           'Call PaRoutingX.Route_To_Extension() to get the next approver in line.';

        		PaRoutingX.Route_To_Extension(
            			X_Expenditure_Id               => Null,
            	        	X_Incurred_By_Person_Id        => l_Inc_By_Person_Id,
            	        	X_Expenditure_End_Date         => Null,
            	        	X_Exp_Class_Code               => 'PT',
            	        	X_Previous_Approver_Person_Id  => P_Previous_Approver_Id,
            	        	P_Timecard_Table               => l_Timecard_Table,
            	        	P_Module                       => 'OTL',
            	        	X_Route_To_Person_Id           => X_Approver_Person_Id );

			If P_Previous_Approver_Id Is Null And X_Approver_Person_Id Is Null Then

				G_Stage := 'There is no previous approver and no one to route the timecard to.  ' ||
				           'Create error message.';
				l_Message_Name := 'PA_TR_NO_ROUTE_TO_PERSON';

				G_Msg_Tokens_Table.Delete;

                        	Pa_Otc_Api.Add_Error_To_Table(
                                	P_Message_Table           => l_Message_Table,
                                    	P_Message_Name            => l_Message_Name,
                                    	P_Message_Level           => 'ERROR',
                                    	P_Message_Field           => Null,
                                    	P_Msg_Tokens              => G_Msg_Tokens_Table,
                                    	P_Time_Building_Block_Id  => Null,
                                    	P_Time_Attribute_Id       => Null);

			ElsIf P_Previous_Approver_Id Is Not Null And X_Approver_Person_Id Is Null Then

				G_Stage := 'There is no one to route the timecard to.  ' ||
				           'Create an error message.';
				l_Message_Name := 'PA_NO_APPROVER_FOUND';
				G_Msg_Tokens_Table.Delete;

                        	Pa_Otc_Api.Add_Error_To_Table(
                                    	P_Message_Table           => l_Message_Table,
                                    	P_Message_Name            => l_Message_Name,
                                    	P_Message_Level           => 'ERROR',
                                        P_Message_Field           => Null,
                                        P_Msg_Tokens              => G_Msg_Tokens_Table,
                                        P_Time_Building_Block_Id  => Null,
                                    	P_Time_Attribute_Id       => Null);

        		End If; -- l_Msg_Name Is Not Null

		End If; -- checking of overriding approver

	ElsIf  l_Approval_Flag = 'COMPLETE:PASS' Then

		G_Stage := 'The timecard has final approval.  Set approver person id to -99.';

		/* If the previous approver had the final authority to approver the timecard, then
		 * pass back -99 for the next approver to route to so that OTL knows that no further
                 * approvers are needed.
		 */
		X_Approver_Person_Id := -99;

	End If; -- Approver authority flag check

        If l_Message_Table.Count > 0 Then

		G_Stage := 'Messages have been created convert to varchar by calling ' ||
			   'Hxc_Integration_Layer_V1_Grp.Messages_To_String().';
        	X_Messages := Hxc_Integration_Layer_V1_Grp.Messages_To_String(P_Messages => l_Message_Table);
        End If;

        G_Stage := 'Leaving Wf_RouteTo_CheckApproval() procedure.';
        Pa_Otc_Api.TrackPath('STRIP','Wf_RouteTo_CheckApproval');

  Exception
        When Others Then
        	Raise_Application_Error(-20600, 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_stage || ' : ' || SQLERRM );

  End Wf_RouteTo_CheckApproval;

-- =======================================================================
-- Start of Comments
-- API Name      : CreateProjTimecardTable
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure create pl/sql table of OTL data in
--                 project friendly format.
--
-- Parameters    :
-- OUT
--           X_Inc_By_Person_Id       - Pa_Expenditures_All.Incurred_By_Person_Id%TYPE
--           X_Timecard_Table         - Pa_Otc_Api.Timecard_Table
--           X_Overriding_Approver_Id - Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE

/*------------------------------------------------------------------------- */

  Procedure CreateProjTimecardTable(
	    X_Inc_By_Person_Id       OUT NOCOPY Pa_Expenditures_All.Incurred_By_Person_Id%TYPE,
            X_Timecard_Table         OUT NOCOPY Pa_Otc_Api.Timecard_Table, --2672653
            X_Overriding_Approver_Id OUT NOCOPY Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE)

  Is

        l_Proj_Attrib_Rec       Pa_Otc_Api.Project_Attribution_Rec;
        j                       Binary_Integer := 0;

	l_Time_Building_Blocks Hxc_User_Type_Definition_Grp.Timecard_Info;
	l_Time_Attributes      Hxc_User_Type_Definition_Grp.App_Attributes_Info;
	l_Detail_Attr_Changed  Varchar2(1) := 'N';

        /* Stores a single record from the Building Block Table */
        l_Building_Block_Record     Hxc_User_Type_Definition_Grp.Building_Block_Info;

  Begin

        G_Stage := 'Entering CreateProjTimecardTable() procedure.';
        Pa_Otc_Api.TrackPath('ADD','CreateProjTimecardTable');

	G_Stage := 'Initialize PA structure pl/sql table.';

	X_Timecard_Table.delete;

	G_Stage := 'Get the hxc pl/sql building block and attribution tables.';
        l_Time_Building_Blocks := Hxc_Integration_Layer_V1_Grp.Get_Wf_G_Time_Building_Blocks;
        l_Time_Attributes      := Hxc_Integration_Layer_V1_Grp.Get_Wf_G_Time_App_Attributes;

	G_Stage := 'Begin looping thru hxc pl/sql building block table.';
        For i in l_Time_Building_Blocks.FIRST .. l_Time_Building_Blocks.LAST
        Loop

		G_Stage := 'Check if overriding approver exists when the scope is TIMECARD.';
		-- Bug 2773066
		-- We don't need to check the overriding approver profile.
		-- If it is populated then it should be picked up and used when and if needed.
        -- If Nvl(Fnd_Profile.Value('PA_ONLINE_OVERRIDE_APPROVER'),'N') = 'Y' And
		If l_Time_Building_Blocks(i).Scope = 'TIMECARD' Then

			G_Stage := 'Now loop thru and attribution records for the TIMECARD scope building block.';
                	<<Approval_Attribs_Loop>>
                        For q in l_Time_Attributes.FIRST .. l_Time_Attributes.LAST
                        Loop

				G_Stage := 'Check for overriding approver attribution record exists.';
                        	If l_Time_Building_Blocks(i).Time_Building_Block_Id =
                                                        l_Time_Attributes(q).Building_Block_Id And
                                   Upper(l_Time_Attributes(q).Attribute_Name) = 'OVERRIDING_APPROVER_PERSON_ID' And
				   l_Time_Attributes(q).Bld_Blk_Info_Type = 'APPROVAL' Then

					G_Stage := 'Assign overriding approver to out paramanter';
                                   	X_Overriding_Approver_Id := l_Time_Attributes(q).Attribute_Value;

					G_Stage := 'Exit Approval_Attribs_Loop.';
                                        Exit Approval_Attribs_Loop;

                                End If;

                        End Loop Approval_Attribs_Loop;

       		End If;

		G_Stage := 'Check if building block scope is DETAIL.';
                If l_Time_Building_Blocks(i).Scope = 'DETAIL' Then

                        G_Stage := 'Initialize variables for loop.';
                        l_Building_Block_Record := l_Time_Building_Blocks(i);
			l_Detail_Attr_Changed   := 'N';

                        G_Stage := 'Pull out the data to PA friendly format by calling RetrieveProjAttribution().';
                        Pa_Otc_Api.RetrieveProjAttribution(
                                P_Building_Block_Rec  => l_Building_Block_Record,
                                P_Building_Block      => l_Time_Building_Blocks,
                                P_Attribute_Table     => l_Time_Attributes,
				X_Detail_Attr_Changed => l_Detail_Attr_Changed,
                                X_Proj_Attrib_Rec     => l_Proj_Attrib_Rec);

                        j := j + 1;

			G_Stage := 'Push the PA friendly format pl/sql record into pl/sql table.';
                        X_Timecard_Table(j).Project_Number 		:= l_Proj_Attrib_Rec.Project_Number;
                        X_Timecard_Table(j).Project_Id     		:= l_Proj_Attrib_Rec.Project_id;
                        X_Timecard_Table(j).Task_Number    		:= l_Proj_Attrib_Rec.Task_Number;
                        X_Timecard_Table(j).Task_Id        		:= l_Proj_Attrib_Rec.Task_Id;
                        X_Timecard_Table(j).Expenditure_Type 		:= l_Proj_Attrib_Rec.Expenditure_Type;
                        X_Timecard_Table(j).System_Linkage_Function 	:= l_Proj_Attrib_Rec.Sys_Linkage_Func;
                        X_Timecard_Table(j).Quantity 			:= l_Proj_Attrib_Rec.Quantity;
                        X_Timecard_Table(j).Incurred_By_Person_Id 	:= l_Proj_Attrib_Rec.Inc_By_Person_Id;
                        X_Timecard_Table(j).Override_Approver_Person_Id := Null;
                        X_Timecard_Table(j).Expenditure_Item_Date 	:= l_Proj_Attrib_Rec.Expenditure_Item_Date;
                        X_Timecard_Table(j).Expenditure_Ending_Date 	:= l_Proj_Attrib_Rec.Exp_Ending_Date;
                        X_Timecard_Table(j).Attribute_Category 		:= l_Proj_Attrib_Rec.Attrib_Category;
                        X_Timecard_Table(j).Attribute1 			:= l_Proj_Attrib_Rec.Attribute1;
                        X_Timecard_Table(j).Attribute2 			:= l_Proj_Attrib_Rec.Attribute2;
                        X_Timecard_Table(j).Attribute3 			:= l_Proj_Attrib_Rec.Attribute3;
                        X_Timecard_Table(j).Attribute4 			:= l_Proj_Attrib_Rec.Attribute4;
                        X_Timecard_Table(j).Attribute5 			:= l_Proj_Attrib_Rec.Attribute5;
                        X_Timecard_Table(j).Attribute6 			:= l_Proj_Attrib_Rec.Attribute6;
                        X_Timecard_Table(j).Attribute7 			:= l_Proj_Attrib_Rec.Attribute7;
                        X_Timecard_Table(j).Attribute8 			:= l_Proj_Attrib_Rec.Attribute8;
                        X_Timecard_Table(j).Attribute9 			:= l_Proj_Attrib_Rec.Attribute9;
                        X_Timecard_Table(j).Attribute10 		:= l_Proj_Attrib_Rec.Attribute10;
                        X_Timecard_Table(j).Billable_Flag 		:= l_Proj_Attrib_Rec.Billable_Flag;
                        X_Timecard_Table(j).Expenditure_Item_Comment 	:= l_Proj_Attrib_Rec.Expenditure_Item_Comment;
                        X_Timecard_Table(j).Orig_Exp_Txn_Reference1  	:= Null;

                End If;

		G_Stage := 'Grab the Inc By Person Id to return as our parameter.';
		X_Inc_By_Person_Id := l_Proj_Attrib_Rec.Inc_By_Person_Id;

        End Loop;

	G_Stage := 'Leaving CreateProjTimecardTable() procedure.';
        Pa_Otc_Api.TrackPath('STRIP','CreateProjTimecardTable');

  Exception
	When Others Then
		Raise;

  End CreateProjTimecardTable;


-- =======================================================================
-- Start of Comments
-- API Name      : OrigTrxRefValueExists
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Function
-- Function      : This function checks to see if the detail scope bb_id/ovn
--                 combination is already in Projects.  This can occur during
--                 validation of the timecard under certain conditions.  The
--                 orig_transaction_reference columns may get updated during
--                 validation to resink with OTL.  (Changes are made that
--                 projects does not recognize and doesn't want to, thus the ovn changes in OTL.)
--
-- Parameters    :
-- IN
--           P_Orig_Transaction_Reference - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE

/*------------------------------------------------------------------------- */

  Function OrigTrxRefValueExists
		( P_Orig_Transaction_Reference IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE) Return Boolean

  Is

	l_Exists_Flag VARCHAR2(1) := 'N';

  Begin

	Select
               'Y'
	Into
               l_Exists_Flag
	From
               Pa_Expenditure_Items_All
	Where
               Transaction_Source = 'ORACLE TIME AND LABOR'
	And    Orig_Transaction_Reference = P_Orig_Transaction_Reference;

	If l_Exists_Flag = 'Y' Then

		Return ( True ) ;

	Else

		Return ( False );

	End If;

  Exception
	When No_Data_Found Then
		Return ( False );
	When Others Then
		Raise;

  End OrigTrxRefValueExists;


-- =======================================================================
-- Start of Comments
-- API Name      : ChkAdjustAllowedToOTCItem
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Function
-- Function      : This function s used to check and see if an OTL expenditure item that
--                 has been imported into Projects can adjusted in Projects by calling the
--                 API Hxc_Generic_Retrieval_Utils.Time_Bld_Blk_Changed.
--
-- Parameters    :
-- IN            P_Orig_Txn_Reference - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--
/*--------------------------------------------------------------------------*/

  Function ChkAdjustAllowedToOTCItem
	(P_Orig_Txn_Reference IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE) Return Varchar2

  Is

      l_BB_Id  Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE := Null;
      l_BB_Ovn Hxc_Time_Building_Blocks.Object_Version_Number%TYPE := Null;

  Begin

	-- Check if the original transaction reference is null or not.
	If P_Orig_Txn_Reference Is Not Null Then

      		l_BB_Id := to_number(substr(P_Orig_Txn_Reference,1,instr(P_Orig_Txn_Reference,':') - 1));
      		l_BB_Ovn := to_number(substr(P_Orig_Txn_Reference,instr(P_Orig_Txn_Reference,':') + 1));

      		/* The hxc function returns the case of whether or not there is a higher ovn value in the OTL table
      		 * than the ovn value we are passing in.
      		 * Therefore we actually want to return the opposite of that to the calling procedure/view.
       		 */
      		If Hxc_Integration_Layer_V1_Grp.Time_Bld_Blk_Changed( P_BB_Id => l_BB_id, P_BB_Ovn => l_BB_Ovn)  Then

			Return ( 'N' );

      		Else

			Return ( 'Y' );

		End If;

	Else

                /* Did not originate in OTL.  This item is a resulting child of the
                 * original OTL item that was adjusted.  So want to always default it
                 * so that it can adjusted and let other code restrictions in PA handle
                 * whether or not the expenditure item can be adjusted.
                 */
		Return ( 'Y' );

      	End If;

  Exception
	When Others Then
		Raise;

  End ChkAdjustAllowedToOTCItem;


-- =======================================================================
-- Start of Comments
-- API Name      : GetBatchName
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure returns a batch name for Trx Import to used based on the
--               : expenditure_ending_date passed in.  Each time a new batch is created a new
--               : record is added to a pl/sql table holding the Ending_Date Batch_Name so as
--               : to only create single batch_name for each Ending_Date for a Trx Import run.
--               : Used in the Upload_Otc_Timecards() procedure.
--
-- Parameters    :
-- IN
--		P_Exp_End_Date - Pa_Transaction_Interface_All.Expenditure_Ending_Date%TYPE
-- OUT
--              X_Batch_Name   - Pa_Transaction_Interface_All.Batch_Name%TYPE
/*--------------------------------------------------------------------------*/

  Procedure GetBatchName (P_Exp_End_Date IN         Pa_Transaction_Interface_All.Expenditure_Ending_Date%TYPE,
                          X_Batch_Name   OUT NOCOPY Pa_Transaction_Interface_All.Batch_Name%TYPE)

  Is

	l_Found_Match Boolean := False;
	l_Date_String Varchar2(10);
	l_Sequence_No Number;
	l_New_Index   Binary_Integer := 0;
	l_debug_text  Varchar2(200);

  Begin

        G_Stage := 'Entering GetBatchName(), add procedure to trackpath.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
        Pa_Otc_Api.TrackPath('ADD','GetBatchName');

	If G_EndDateBatchName_Table.Count > 0 Then

		G_Stage := 'There are already batch name recs in pl/sql table.  See if find a matching one via loop.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

		For i IN G_EndDateBatchName_Table.First .. G_EndDateBatchName_Table.Last
		Loop

			If G_EndDateBatchName_Table(i).Expenditure_Ending_Date = P_Exp_End_Date Then

				X_Batch_Name  := G_EndDateBatchName_Table(i).Batch_Name;
				l_Found_Match := True;

			End If;

		End Loop;

                G_Stage := 'Done searching for matching batch name record via loop.';
		If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                End If;

	End If; -- G_EndDateBatchName_Table.Count > 0

	If Not l_Found_Match Then

        	/* Create a batch Name for Import run.*/
		G_Stage := 'Get string of sysdate in YYMMDD format.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

        	Select
                       To_Char(P_Exp_End_Date,'YYMMDD')
        	Into
                       l_Date_String
        	From
                       Dual;

        	G_Stage := 'Use mod(pa_expenditure_groups_s.nextval,1000) to create number value.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

        	SELECT
                       Mod(Pa_Expenditure_Groups_S.NextVal,1000)
        	INTO
                       l_Sequence_No
        	FROM
                       Dual;

        	G_Stage := 'Create a batch Name for Import run.';
		If G_Debug_Mode = 'Y' Then
        	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
        	   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;

        	X_Batch_Name := l_Date_String || '-' || To_Char(l_Sequence_No);

		l_New_Index := G_EndDateBatchName_Table.Count + 1;

		G_EndDateBatchName_Table(l_New_Index).Expenditure_Ending_Date := P_Exp_End_Date;
		G_EndDateBatchName_Table(l_New_Index).Batch_Name := X_Batch_Name;

	End If; -- Not l_Found_Match

        G_Stage := 'Leaving GetBatchName(), strip procedure from trackpath.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
        Pa_Otc_Api.TrackPath('STRIP','GetBatchName');

  Exception
	When Others Then
        	l_debug_text := 'Leaving GetBatchName() due to unhandled exception, strip procedure from trackpath.';
        	If G_Debug_Mode = 'Y' Then
           		Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || l_debug_text;
           		pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        	End If;
        	Pa_Otc_Api.TrackPath('STRIP','GetBatchName');
		Raise;

  End GetBatchName;

-- =======================================================================
-- Start of Comments
-- API Name      : IsNumber
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Function
-- Returns       : BOOLEAN
-- Function      : This functions determines if the varchar passed back is a number.
--               : Used in the Validate_Process() procedure.
--
-- Parameters    :
-- IN
--              P_Value - Varchar2
/*--------------------------------------------------------------------------*/

  Function IsNumber (P_Value IN Varchar2) Return Boolean

  Is

	l_Converted_Value Number := Null;

  Begin

	l_Converted_Value := to_Number(P_Value);
	Return ( True );

  Exception

	When Others Then
		Return ( False );

  End IsNumber;


-- =======================================================================
-- Start of Comments
-- API Name      : GetOrigTrxRef
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Returns       :
-- Function      : This procedure determines the max orig_transaction_reference to
--               : return based on the Building Block Id passed in.
--               : Since this procedure is only called when OTL is sending a detail bb for
--               : adjustment of existing data in Projects a NO_DATA_FOUND error means data corruption
--               : Used in the Upload_Otc_Timecards() procedure.
--
-- Parameters    :
-- IN
--              P_Building_Block_Id - Number
-- OUT
--              X_OrigTrxRef        - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--              X_Status            - Varchar2
/*--------------------------------------------------------------------------*/

  Procedure GetOrigTrxRef (P_Building_Block_Id IN         Number,
		           X_OrigTrxRef        OUT NOCOPY Varchar2,
			   X_Status            OUT NOCOPY Varchar2)

  Is

	l_Search     Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE;
	l_Error_Text Varchar2(1800);

  Begin

        G_Stage := 'Entering GetOrigTrxRef(), add procedure to trackpath.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);
        End If;
        Pa_Otc_Api.TrackPath('ADD','GetOrigTrxRef');

        G_Stage := 'Build search string.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);
        End If;
	l_Search := to_char(P_Building_Block_Id) || ':%';

        G_Stage := 'Search ei table for available ei record.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,1);
        End If;
	Select
		Orig_Transaction_Reference
	Into
		X_OrigTrxRef
	From
		Pa_Expenditure_Items_All
	Where
		Orig_Transaction_Reference like l_Search
	And   	Transaction_Source = 'ORACLE TIME AND LABOR'
	And     Nvl(Net_Zero_Adjustment_Flag,'N') = 'N'
	And     Adjusted_Expenditure_Item_Id is Null
	And 	to_number(substr(Orig_Transaction_Reference,instr(Orig_Transaction_Reference,':') + 1)) = (
		Select
		    	Max(to_Number(Substr(Orig_Transaction_Reference,instr(Orig_Transaction_Reference,':') + 1)))
		From
		    	Pa_Expenditure_Items_All
		Where
		    	Orig_Transaction_Reference like l_Search
		And 	Transaction_Source = 'ORACLE TIME AND LABOR'
                And     Nvl(Net_Zero_Adjustment_Flag,'N') = 'N'
		And     Adjusted_Expenditure_Item_Id is Null);

        G_Stage := 'Leaving GetOrigTrxRef(), strip procedure from trackpath.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
        End If;
        Pa_Otc_Api.TrackPath('STRIP','GetOrigTrxRef');

  Exception
	When No_Data_Found Then
		-- Data corruption exists if this happens here.
                l_error_text := SubStr('Pa_Otc_Api ::: ' || G_Path || ' : ' || G_Stage || ' --  ' ||
				SqlErrM, 1, 1800);
                fnd_message.set_name('HXC', 'HXC_RET_UNEXPECTED_ERROR');
                fnd_message.set_token('ERR', l_error_text);
                X_Status := SubStr(fnd_message.get,1,2000);

                G_Stage := 'Leaving GetOrigTrxRef() due to unhandled exception, strip procedure from trackpath';
                If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                End If;
                Pa_Otc_Api.TrackPath('STRIP','GetOrigTrxRef');

                If G_Debug_Mode = 'Y' Then
                   Pa_Debug.G_err_Stage := l_error_text;
                   pa_cc_utils.log_message(Pa_Debug.G_Err_Stage,0);
                End If;

	When Others Then
		Raise;

  End GetOrigTrxRef;

-- =======================================================================
-- Start of Comments
-- API Name      : GetAdditionalTrxData
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Returns       :
-- Function      : Gets all the addition data needed to insert records into the Trx Interface table
--               : Used in the Upload_Otc_Timecards() procedure.
--
-- Parameters    :
-- IN
--      P_Ei_Date      Date
--      P_Person_Id    Number
-- OUT
--      X_Org_Id       Number
--      X_Error_Status Varchar2

/*--------------------------------------------------------------------------*/

  Procedure GetAdditionalTrxData (P_Ei_Date      IN         Date,
                                  P_Person_Id    IN         Number,
                                  X_Org_Id       OUT NOCOPY Number,
                                  X_Error_Status OUT NOCOPY Varchar2)

 Is

 Begin

        G_Stage := 'Entering GetAdditionalTrxData(), add procedure to trackpath.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message('GetAdditionalTrxData: ' || Pa_Debug.G_Err_Stage,0);
        End If;
        Pa_Otc_Api.TrackPath('ADD','GetAdditionalTrxData');

        G_Stage := 'Get Incurred by Organization Id.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message('GetAdditionalTrxData: ' || Pa_Debug.G_Err_Stage,0);
        End If;

        Pa_Utils3.GetCachedOrgId( P_Inc_By_Per_Id => P_Person_Id,
                                  P_Exp_Item_Date => P_EI_Date,
                                  X_Inc_By_Org_Id => X_Org_Id);

        G_Stage := 'Incurred by Organization Id is ' || to_char(X_Org_Id) ;
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message('GetAdditionalTrxData: ' || Pa_Debug.G_Err_Stage,0);
        End If;

	X_Error_Status := Null;

        G_Stage := 'Leaving GetAdditionalTrxData(), strip procedure from trackpath.';
	If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           Pa_Cc_Utils.Log_Message('GetAdditionalTrxData: ' || Pa_Debug.G_Err_Stage,0);
        End If;
        Pa_Otc_Api.TrackPath('STRIP','GetAdditionalTrxData');

 Exception
    When Others Then
	X_Error_Status := 'Could not get Incurred by Organization Id.';
        G_Stage := 'Leaving GetAdditionalTrxData() in exception handler.';
        If G_Debug_Mode = 'Y' Then
           Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
           pa_cc_utils.log_message('GetAdditionalTrxData: ' || Pa_Debug.G_Err_Stage,0);
        End If;
	Pa_Otc_Api.TrackPath('STRIP','GetAdditionalTrxData');

 End GetAdditionalTrxData;


-- =======================================================================
-- Start of Comments
-- API Name      : BulkInsertReset
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Returns       :
-- Function      : Calls bulk insert API.
--               : Empties out all the global pl/sql arrays used for the bulk insert.
--               : If the P_Command is 'INSERT' then the bulk insert command table handler is executed,
--               : then the pl/sql table arrays are reset for the next time thru.
--               : If the P_Command is 'RESET' then pl/sql table arrays are only reset.
--               : Used in the Upload_Otc_Timecards() procedure.
--
-- Parameters    :
-- IN            :
--               : P_Command   Varchar2
-- OUT           : n/a

/*--------------------------------------------------------------------------*/

  Procedure BulkInsertReset (P_Command IN Varchar2)

  Is

  Begin

	G_Stage := 'Entering BulkInsertReset(), add procedure to trackpath.';
	If G_Debug_Mode = 'Y' Then
	   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
	   pa_cc_utils.log_message('BulkInsertReset: ' || Pa_Debug.G_Err_Stage,0);
	End If;
	Pa_Otc_Api.TrackPath('ADD','BulkInsertReset');

	If P_Command = 'INSERT' Then

		G_Stage := 'Bulk Insert records into Interface table via Pa_Txn_Interface_Items_Pkg.Bulk_Insert().';
		If G_Debug_Mode = 'Y' Then
		   Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
		   pa_cc_utils.log_message('BulkInsertReset: ' || Pa_Debug.G_Err_Stage,0);
		End If;

		Pa_Txn_Interface_Items_Pkg.Bulk_Insert(
			   P_Txn_Interface_Id_Tbl               => G_Txn_Interface_Id_Tbl,
			   P_Transaction_Source_Tbl             => G_Transaction_Source_Tbl,
			   P_User_Transaction_Source_Tbl        => G_User_Transaction_Source_Tbl,
			   P_Batch_Name_Tbl                     => G_Batch_Name_Tbl,
			   P_Expenditure_End_Date_Tbl           => G_Expenditure_End_Date_Tbl,
			   P_Person_Bus_Grp_Name_Tbl            => G_Person_Bus_Grp_Name_Tbl,
			   P_Person_Bus_Grp_Id_Tbl              => G_Person_Bus_Grp_Id_Tbl,
			   P_Employee_Number_Tbl                => G_Employee_Number_Tbl,
			   P_Person_Id_Tbl                      => G_Person_Id_Tbl,
			   P_Organization_Name_Tbl              => G_Organization_Name_Tbl,
			   P_Organization_Id_Tbl                => G_Organization_Id_Tbl,
			   P_Expenditure_Item_Date_Tbl          => G_Expenditure_Item_Date_Tbl,
			   P_Project_Number_Tbl                 => G_Project_Number_Tbl,
			   P_Project_Id_Tbl                     => G_Project_Id_Tbl,
			   P_Task_Number_Tbl                    => G_Task_Number_Tbl,
			   P_Task_Id_Tbl                        => G_Task_Id_Tbl,
			   P_Expenditure_Type_Tbl               => G_Expenditure_Type_Tbl,
			   P_System_Linkage_Tbl                 => G_System_Linkage_Tbl,
			   P_Non_Labor_Resource_Tbl             => G_Non_Labor_Resource_Tbl,
			   P_Non_Labor_Res_Org_Name_Tbl         => G_Non_Labor_Res_Org_Name_Tbl,
			   P_Non_Labor_Res_Org_Id_Tbl           => G_Non_Labor_Res_Org_Id_Tbl,
			   P_Quantity_Tbl                       => G_Quantity_Tbl,
			   P_Raw_Cost_Tbl                       => G_Raw_Cost_Tbl,
			   P_Raw_Cost_Rate_Tbl                  => G_Raw_Cost_Rate_Tbl,
			   P_Burden_Cost_Tbl                    => G_Burden_Cost_Tbl,
			   P_Burden_Cost_Rate_Tbl               => G_Burden_Cost_Rate_Tbl,
			   P_Expenditure_Comment_Tbl            => G_Expenditure_Comment_Tbl,
			   P_Gl_Date_Tbl                        => G_Gl_Date_Tbl,
			   P_Transaction_Status_Code_Tbl        => G_Transaction_Status_Code_Tbl,
			   P_Trans_Rejection_Code_Tbl           => G_Trans_Rejection_Code_Tbl,
			   P_Orig_Trans_Reference_Tbl           => G_Orig_Trans_Reference_Tbl,
			   P_Unmatched_Neg_Txn_Flag_Tbl         => G_Unmatched_Neg_Txn_Flag_Tbl,
			   P_Expenditure_Id_Tbl                 => G_Expenditure_Id_Tbl,
			   P_Attribute_Category_Tbl             => G_Attribute_Category_Tbl,
			   P_Attribute1_Tbl                     => G_Attribute1_Tbl,
			   P_Attribute2_Tbl                     => G_Attribute2_Tbl,
			   P_Attribute3_Tbl                     => G_Attribute3_Tbl,
			   P_Attribute4_Tbl                     => G_Attribute4_Tbl,
			   P_Attribute5_Tbl                     => G_Attribute5_Tbl,
			   P_Attribute6_Tbl                     => G_Attribute6_Tbl,
			   P_Attribute7_Tbl                     => G_Attribute7_Tbl,
			   P_Attribute8_Tbl                     => G_Attribute8_Tbl,
			   P_Attribute9_Tbl                     => G_Attribute9_Tbl,
			   P_Attribute10_Tbl                    => G_Attribute10_Tbl,
			   P_Dr_Code_Combination_Id_Tbl         => G_Dr_Code_Combination_Id_Tbl,
			   P_Cr_Code_Combination_Id_Tbl         => G_Cr_Code_Combination_Id_Tbl,
			   P_Cdl_System_Reference1_Tbl          => G_Cdl_System_Reference1_Tbl,
			   P_Cdl_System_Reference2_Tbl          => G_Cdl_System_Reference2_Tbl,
			   P_Cdl_System_Reference3_Tbl          => G_Cdl_System_Reference3_Tbl,
			   P_Interface_Id_Tbl                   => G_Interface_Id_Tbl,
			   P_Receipt_Currency_Amount_Tbl        => G_Receipt_Currency_Amount_Tbl,
			   P_Receipt_Currency_Code_Tbl          => G_Receipt_Currency_Code_Tbl,
			   P_Receipt_Exchange_Rate_Tbl          => G_Receipt_Exchange_Rate_Tbl,
			   P_Denom_Currency_Code_Tbl            => G_Denom_Currency_Code_Tbl,
			   P_Denom_Raw_Cost_Tbl                 => G_Denom_Raw_Cost_Tbl,
			   P_Denom_Burdened_Cost_Tbl            => G_Denom_Burdened_Cost_Tbl,
			   P_Acct_Rate_Date_Tbl                 => G_Acct_Rate_Date_Tbl,
			   P_Acct_Rate_Type_Tbl                 => G_Acct_Rate_Type_Tbl,
			   P_Acct_Exchange_Rate_Tbl             => G_Acct_Exchange_Rate_Tbl,
			   P_Acct_Raw_Cost_Tbl                  => G_Acct_Raw_Cost_Tbl,
			   P_Acct_Burdened_Cost_Tbl             => G_Acct_Burdened_Cost_Tbl,
			   P_Acct_Exch_Rounding_Limit_Tbl       => G_Acct_Exch_Rounding_Limit_Tbl,
			   P_Project_Currency_Code_Tbl          => G_Project_Currency_Code_Tbl,
			   P_Project_Rate_Date_Tbl              => G_Project_Rate_Date_Tbl,
			   P_Project_Rate_Type_Tbl              => G_Project_Rate_Type_Tbl,
			   P_Project_Exchange_Rate_Tbl          => G_Project_Exchange_Rate_Tbl,
			   P_Orig_Exp_Txn_Reference1_Tbl        => G_Orig_Exp_Txn_Reference1_Tbl,
			   P_Orig_Exp_Txn_Reference2_Tbl        => G_Orig_Exp_Txn_Reference2_Tbl,
			   P_Orig_Exp_Txn_Reference3_Tbl        => G_Orig_Exp_Txn_Reference3_Tbl,
			   P_Orig_User_Exp_Txn_Ref_Tbl          => G_Orig_User_Exp_Txn_Ref_Tbl,
			   P_Vendor_Number_Tbl                  => G_Vendor_Number_Tbl,
			   P_Vendor_Id_Tbl                      => G_Vendor_Id_Tbl,
			   P_Override_To_Org_Name_Tbl           => G_Override_To_Org_Name_Tbl,
			   P_Override_To_Org_Id_Tbl             => G_Override_To_Org_Id_Tbl,
			   P_Reversed_Orig_Txn_Ref_Tbl          => G_Reversed_Orig_Txn_Ref_Tbl,
			   P_Billable_Flag_Tbl                  => G_Billable_Flag_Tbl,
			   P_ProjFunc_Currency_Code_Tbl         => G_ProjFunc_Currency_Code_Tbl,
			   P_ProjFunc_Cost_Rate_Date_Tbl        => G_ProjFunc_Cost_Rate_Date_Tbl,
			   P_ProjFunc_Cost_Rate_Type_Tbl        => G_ProjFunc_Cost_Rate_Type_Tbl,
			   P_ProjFunc_Cost_Exch_Rate_Tbl        => G_ProjFunc_Cost_Exch_Rate_Tbl,
			   P_Project_Raw_Cost_Tbl               => G_Project_Raw_Cost_Tbl,
			   P_Project_Burdened_Cost_Tbl          => G_Project_Burdened_Cost_Tbl,
			   P_Assignment_Name_Tbl                => G_Assignment_Name_Tbl,
			   P_Assignment_Id_Tbl                  => G_Assignment_Id_Tbl,
			   P_Work_Type_Name_Tbl                 => G_Work_Type_Name_Tbl,
			   P_Work_Type_Id_Tbl                   => G_Work_Type_Id_Tbl,
			   P_Cdl_System_Reference4_Tbl          => G_Cdl_System_Reference4_Tbl,
			   P_Accrual_Flag_Tbl                   => G_Accrual_Flag_Tbl,
			   P_Last_Update_Date_Tbl               => G_Last_Update_Date_Tbl,
			   P_Last_Updated_By_Tbl                => G_Last_Updated_By_Tbl,
			   P_Creation_Date_Tbl                  => G_Creation_Date_Tbl,
			   P_Created_By_Tbl                     => G_Created_By_Tbl,
			   P_PO_Number_Tbl			            => G_PO_Number_Tbl,
			   P_PO_Header_Id_Tbl			        => G_PO_Header_Id_Tbl,
			   P_PO_Line_Num_Tbl			        => G_PO_Line_Num_Tbl,
			   P_PO_Line_Id_Tbl                     => G_PO_Line_Id_Tbl,
			   P_PO_Price_Type_Tbl                  => G_PO_Price_Type_Tbl,
			   P_Person_Type_Tbl                    => G_Person_Type_Tbl,
			   P_Inventory_Item_Id_Tbl              => G_Inventory_Item_Id_Tbl,
			   P_WIP_Resource_Id_Tbl		        => G_WIP_Resource_Id_Tbl,
    		   P_Unit_Of_Measure_Tbl		        => G_Unit_Of_Measure_Tbl,
               P_Org_Id_Tbl                         => G_OU_Tbl);

	End If;

	If P_Command in ( 'INSERT', 'RESET' ) Then

        G_Stage := 'Reset all pl/sql table arrays used for bulk insert.';
		If G_Debug_Mode = 'Y' Then
             Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
             pa_cc_utils.log_message('BulkInsertReset: ' || Pa_Debug.G_Err_Stage,0);
        End If;

		G_Txn_Interface_Id_Tbl.Delete;
		G_Transaction_Source_Tbl.Delete;
		G_User_Transaction_Source_Tbl.Delete;
		G_Batch_Name_Tbl.Delete;
		G_Expenditure_End_Date_Tbl.Delete;
		G_Person_Bus_Grp_Name_Tbl.Delete;
		G_Person_Bus_Grp_Id_Tbl.Delete;
		G_Employee_Number_Tbl.Delete;
		G_Person_Id_Tbl.Delete;
		G_Organization_Name_Tbl.Delete;
		G_Organization_Id_Tbl.Delete;
		G_Expenditure_Item_Date_Tbl.Delete;
		G_Project_Number_Tbl.Delete;
		G_Project_Id_Tbl.Delete;
		G_Task_Number_Tbl.Delete;
		G_Task_Id_Tbl.Delete;
		G_Expenditure_Type_Tbl.Delete;
		G_System_Linkage_Tbl.Delete;
		G_Non_Labor_Resource_Tbl.Delete;
		G_Non_Labor_Res_Org_Name_Tbl.Delete;
		G_Non_Labor_Res_Org_Id_Tbl.Delete;
		G_Quantity_Tbl.Delete;
		G_Raw_Cost_Tbl.Delete;
		G_Raw_Cost_Rate_Tbl.Delete;
		G_Burden_Cost_Tbl.Delete;
		G_Burden_Cost_Rate_Tbl.Delete;
		G_Expenditure_Comment_Tbl.Delete;
		G_Gl_Date_Tbl.Delete;
		G_Transaction_Status_Code_Tbl.Delete;
		G_Trans_Rejection_Code_Tbl.Delete;
		G_Orig_Trans_Reference_Tbl.Delete;
		G_Unmatched_Neg_Txn_Flag_Tbl.Delete;
		G_Expenditure_Id_Tbl.Delete;
		G_Attribute_Category_Tbl.Delete;
		G_Attribute1_Tbl.Delete;
		G_Attribute2_Tbl.Delete;
		G_Attribute3_Tbl.Delete;
		G_Attribute4_Tbl.Delete;
		G_Attribute5_Tbl.Delete;
		G_Attribute6_Tbl.Delete;
		G_Attribute7_Tbl.Delete;
		G_Attribute8_Tbl.Delete;
		G_Attribute9_Tbl.Delete;
		G_Attribute10_Tbl.Delete;
		G_Dr_Code_Combination_Id_Tbl.Delete;
		G_Cr_Code_Combination_Id_Tbl.Delete;
		G_Cdl_System_Reference1_Tbl.Delete;
		G_Cdl_System_Reference2_Tbl.Delete;
		G_Cdl_System_Reference3_Tbl.Delete;
		G_Interface_Id_Tbl.Delete;
		G_Receipt_Currency_Amount_Tbl.Delete;
		G_Receipt_Currency_Code_Tbl.Delete;
		G_Receipt_Exchange_Rate_Tbl.Delete;
		G_Denom_Currency_Code_Tbl.Delete;
		G_Denom_Raw_Cost_Tbl.Delete;
		G_Denom_Burdened_Cost_Tbl.Delete;
		G_Acct_Rate_Date_Tbl.Delete;
		G_Acct_Rate_Type_Tbl.Delete;
		G_Acct_Exchange_Rate_Tbl.Delete;
		G_Acct_Raw_Cost_Tbl.Delete;
		G_Acct_Burdened_Cost_Tbl.Delete;
		G_Acct_Exch_Rounding_Limit_Tbl.Delete;
		G_Project_Currency_Code_Tbl.Delete;
		G_Project_Rate_Date_Tbl.Delete;
		G_Project_Rate_Type_Tbl.Delete;
		G_Project_Exchange_Rate_Tbl.Delete;
		G_Orig_Exp_Txn_Reference1_Tbl.Delete;
		G_Orig_Exp_Txn_Reference2_Tbl.Delete;
		G_Orig_Exp_Txn_Reference3_Tbl.Delete;
		G_Orig_User_Exp_Txn_Ref_Tbl.Delete;
		G_Vendor_Number_Tbl.Delete;
		G_Vendor_Id_Tbl.Delete;
		G_Override_To_Org_Name_Tbl.Delete;
		G_Override_To_Org_Id_Tbl.Delete;
		G_Reversed_Orig_Txn_Ref_Tbl.Delete;
		G_Billable_Flag_Tbl.Delete;
		G_ProjFunc_Currency_Code_Tbl.Delete;
		G_ProjFunc_Cost_Rate_Date_Tbl.Delete;
		G_ProjFunc_Cost_Rate_Type_Tbl.Delete;
		G_ProjFunc_Cost_Exch_Rate_Tbl.Delete;
		G_Project_Raw_Cost_Tbl.Delete;
		G_Project_Burdened_Cost_Tbl.Delete;
		G_Assignment_Name_Tbl.Delete;
		G_Assignment_Id_Tbl.Delete;
		G_Work_Type_Name_Tbl.Delete;
		G_Work_Type_Id_Tbl.Delete;
		G_Cdl_System_Reference4_Tbl.Delete;
		G_Accrual_Flag_Tbl.Delete;
		G_Last_Update_Date_Tbl.Delete;
		G_Last_Updated_By_Tbl.Delete;
		G_Creation_Date_Tbl.Delete;
		G_Created_By_Tbl.Delete;
		-- Begin PA.M/CWK changes
		G_PO_Number_Tbl.Delete;
		G_PO_Header_Id_Tbl.Delete;
		G_PO_Line_Num_Tbl.Delete;
		G_PO_Line_Id_Tbl.Delete;
		G_PO_Price_Type_Tbl.Delete;
		G_Person_Type_Tbl.Delete;
		-- End PA.M/CWK changes
		G_Inventory_Item_Id_Tbl.Delete;
		G_WIP_Resource_Id_Tbl.Delete;
    	G_Unit_Of_Measure_Tbl.Delete;
        -- 12i MOAC changes
        G_OU_Tbl.Delete;

	End If;

    G_Stage := 'Leaving BulkInsertReset(), strip procedure from trackpath.';
	If G_Debug_Mode = 'Y' Then
         Pa_Debug.G_err_Stage := 'Pa_Otc_Api ::: ' || G_Path || ' :: ' || G_Stage;
         Pa_Cc_Utils.Log_Message('BulkInsertReset: ' || Pa_Debug.G_Err_Stage,0);
    End If;
    Pa_Otc_Api.TrackPath('STRIP','BulkInsertReset');

  Exception
	When Others Then
		Raise;

  End BulkInsertReset;

-- =======================================================================
-- Start of Comments
-- API Name      : TrxInCurrentChunk
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Function
-- Returns       : Varchar2
-- Function      : Determine if the Trx in part of the current chunk being processed.
--               : Since we now have the looping functionality in Trx Import and we have to restrict the cursor
--               : more in what it picks up.  We have to make sure that we don't try to update rejected
--               : Trx records from other loops that have already been ran.  They are at a status of 'R'
--               : So we check to see if it exists in the pl/sql table and then if it does
--               : we update the otl pl/sql table accordingly run.
--               : Used in the Tieback_Otc_Timecards() procedure.
--
-- Parameters    :
-- IN            :
--               : P_Detail_BB_Id  - Number
-- OUT           : n/a

/*--------------------------------------------------------------------------*/

  Function TrxInCurrentChunk (P_Detail_BB_Id IN Number) Return Varchar2 Is

  Begin

        If G_Trx_Inserted_Tab.Exists(P_Detail_BB_Id) Then

                Return ( 'Y' );

        Else

                Return ( 'N' );

        End If;

  Exception
	When Others Then
		Raise;


  End TrxInCurrentChunk;

-- =======================================================================
-- Start of Comments
-- API Name      : GetProjectManager
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Function
-- Returns       : Number
-- Function      : Returns the current project manager, person_id, for a project
--
-- Parameters    :
-- IN            :
--               : P_Project_Id  - Number
-- OUT           : n/a

/*--------------------------------------------------------------------------*/

  Function GetProjectManager ( P_Project_Id IN Number ) Return Number Is

        l_Proj_Mgr_Person_Id Number := Null;

  Begin

         l_Proj_Mgr_Person_Id := Pa_Projects_Maint_Utils.Get_Project_Manager(p_project_id);
         Return l_Proj_Mgr_Person_Id;

  Exception
        When Others Then
                Raise;


  End GetProjectManager;

-- =======================================================================
-- Start of Comments
-- API Name      : GetPersonType
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Function
-- Returns       : Varchar2
-- Function      : Returns the Person Type based on the employee id.
--                 Valid Values: 'CWK' or 'EMP'
--
-- Parameters    :
-- IN            :
--               : P_Person_Id  - NUMBER
--		 : P_Ei_Date    - DATE
-- OUT           : n/a

/*--------------------------------------------------------------------------*/

  Function GetPersonType ( P_Person_Id IN Number, P_Ei_Date IN Date) Return Varchar2

  Is

	X_Person_Type Pa_Expenditures_All.Person_Type%TYPE := Null;

  Begin

	Select
		Decode(Current_Npw_Flag,'Y','CWK','EMP')
	Into
		X_Person_Type
	From
		Per_People_F
	Where
		P_Ei_Date between Effective_Start_Date
			      and Effective_End_Date
	And	Person_Id = P_Person_Id;

	Return ( X_Person_Type );

  Exception
	When Others Then
		Return ( Null );

  End GetPersonType;


-- =======================================================================
-- Start of Comments
-- API Name      : GetPOInfo
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Returns       : n/a
-- Function      : Returns the Vendor_Id and PO_Header_Id
--
-- Parameters    :
-- IN            :
--               : P_PO_Line_Id   - Number
-- OUT           :
--		 : X_Po_Header_Id - Number
--		 : X_Vendor_Id    - Number

/*--------------------------------------------------------------------------*/

  Procedure GetPOInfo(P_Po_Line_Id   In         Number,
		      X_Po_Header_Id OUT NOCOPY Number,
		      X_Vendor_Id    OUT NOCOPY Number)

  Is

	l_Vendor_Id 	Number := Null;
	l_Po_Header_Id  Number := Null;

  Begin

	If nvl(G_Po_Line_Id,-99999) <> P_Po_Line_Id Then

		Select
			h.Vendor_Id,
			h.Po_Header_Id
		Into
			l_Vendor_Id,
			l_Po_Header_Id
		from
			PO_Headers_All h,
		     	PO_Lines_All l
		where
			l.po_line_Id = P_Po_Line_Id
		and	l.po_header_id = h.po_header_Id;

		G_Po_Line_Id   := P_Po_Line_Id;
		G_Vendor_Id    := l_Vendor_Id;
		G_PO_Header_Id := l_Po_Header_Id;

	End If;

	X_Po_Header_Id := G_PO_Header_Id;
	X_Vendor_Id := G_Vendor_Id;

  Exception
	When Others Then
		Null;

  End GetPOInfo;


END Pa_Otc_Api ;

/
