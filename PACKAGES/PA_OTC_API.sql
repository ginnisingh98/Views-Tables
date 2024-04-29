--------------------------------------------------------
--  DDL for Package PA_OTC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OTC_API" AUTHID CURRENT_USER AS
--$Header: PAXVOTCS.pls 120.2 2005/12/01 08:53:40 eyefimov noship $

   TYPE Timecard_Rec IS Record (
	Project_Number              Pa_Projects_All.Segment1%TYPE,
	Project_Id                  Pa_Projects_All.Project_Id%TYPE,
	Task_Number                 Pa_Tasks.Task_Number%TYPE,
	Task_Id                     Pa_Tasks.Task_Id%TYPE,
	Expenditure_Type            Pa_Expenditure_Types.Expenditure_Type%TYPE,
	System_Linkage_Function     Pa_System_Linkages.Function%TYPE,
	Quantity                    Pa_Expenditure_Items_All.quantity%TYPE,
	Incurred_By_Person_Id       Pa_Expenditures_All.Incurred_By_Person_Id%TYPE,
    Override_Approver_Person_Id Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE,
	Expenditure_Item_Date       Pa_Expenditure_Items_All.Expenditure_Item_Date%TYPE,
	Expenditure_Ending_Date     Pa_Expenditures_All.Expenditure_Ending_Date%TYPE,
	Attribute_Category          Pa_Expenditure_Items_All.Attribute_Category%TYPE,
	Attribute1                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute2                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute3                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute4                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute5                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute6                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute7                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute8                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute9                  Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute10                 Pa_Expenditure_Items_All.Attribute1%TYPE,
	Billable_Flag               Pa_Expenditure_Items_All.Billable_Flag%TYPE,
    Expenditure_Item_Comment    Pa_Expenditure_Comments.Expenditure_Comment%TYPE,
	Orig_Exp_Txn_Reference1     Pa_Expenditures_All.Orig_Exp_Txn_Reference1%TYPE,
	Status                      Varchar2(2000),
    Work_Type_Id                Pa_Expenditure_Items_All.Work_Type_Id%TYPE,
    Assignment_Id               Pa_Expenditure_Items_All.Assignment_Id%TYPE,
	PO_Line_Id		            Pa_Expenditure_Items_All.PO_Line_Id%TYPE,
	PO_Price_Type		        Pa_Expenditure_Items_All.PO_Price_Type%TYPE,
	Person_Type      	        Pa_Expenditures_All.Person_Type%TYPE,
	Vendor_Id		            Pa_Expenditures_All.Vendor_Id%TYPE,
	PO_Header_Id		        Number,
	Approval_Status             Hxc_Time_Building_Blocks.Approval_Status%TYPE,
    Action                      Varchar2(30));

   TYPE Timecard_Table IS Table OF Timecard_Rec
        INDEX BY Binary_Integer;

   TYPE Project_Attribution_Rec IS Record (
	Project_Number            Pa_Projects_All.Segment1%TYPE,
	Project_Id                Pa_Projects_All.Project_Id%TYPE,
    Proj_Attr_Id              Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	Proj_Attr_Ovn             Hxc_Time_Attributes.Object_Version_Number%TYPE,
	Task_Number               Pa_Tasks.Task_Number%TYPE,
    Task_Id                   Pa_Tasks.Task_Id%TYPE,
    Task_Attr_Id              Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	Task_Attr_Ovn             Hxc_Time_Attributes.Object_Version_Number%TYPE,
    Expenditure_Type          Pa_Expenditure_Types.Expenditure_Type%TYPE,
	UOM                       Hxc_Time_Building_Blocks.Unit_Of_Measure%TYPE,
    Exp_Type_Attr_Id          Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	Exp_Type_Attr_Ovn         Hxc_Time_Attributes.Object_Version_Number%TYPE,
    Sys_Linkage_Func          Pa_Expenditure_Types.System_Linkage_Function%TYPE,
    Sys_Link_Attr_Id          Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	Sys_Link_Attr_Ovn	      Hxc_Time_Attributes.Object_Version_Number%TYPE,
	Quantity                  Pa_Expenditure_Items_All.Quantity%TYPE,
	Expenditure_Item_Date     Pa_Expenditure_Items_All.Expenditure_Item_Date%TYPE,
    Exp_Ending_Date           Pa_Expenditures_All.Expenditure_Ending_Date%TYPE,
	Inc_By_Person_Id          Pa_Expenditures_All.Incurred_By_Person_Id%TYPE,
    Attrib_Category           Pa_Expenditure_Items_All.Attribute_Category%TYPE,
    Attribute1                Pa_Expenditure_Items_All.Attribute1%TYPE,
    Attribute2                Pa_Expenditure_Items_All.Attribute2%TYPE,
    Attribute3                Pa_Expenditure_Items_All.Attribute3%TYPE,
    Attribute4                Pa_Expenditure_Items_All.Attribute4%TYPE,
    Attribute5                Pa_Expenditure_Items_All.Attribute5%TYPE,
    Attribute6                Pa_Expenditure_Items_All.Attribute6%TYPE,
    Attribute7                Pa_Expenditure_Items_All.Attribute7%TYPE,
    Attribute8                Pa_Expenditure_Items_All.Attribute8%TYPE,
    Attribute9                Pa_Expenditure_Items_All.Attribute9%TYPE,
    Attribute10               Pa_Expenditure_Items_All.Attribute10%TYPE,
    Expenditure_Item_Comment  Pa_Expenditure_Comments.Expenditure_Comment%TYPE,
	Billable_Flag             Pa_Expenditure_Items_All.Billable_Flag%TYPE,
	Billable_Flag_Attr_Id     Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	Billable_Flag_Attr_Ovn    Hxc_Time_Attributes.Object_Version_Number%TYPE,
    Billable_Flag2            Pa_Expenditure_Items_All.Billable_Flag%TYPE,
    Billable_Flag_Index       Binary_Integer,
    Work_Type_Id              Pa_Expenditure_Items_All.Work_Type_Id%TYPE,
	Work_Type_Attr_Id         Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	Work_Type_Attr_Ovn        Hxc_Time_Attributes.Object_Version_Number%TYPE,
    Assignment_Id             Pa_Expenditure_Items_All.Assignment_Id%TYPE,
	Assignment_Attr_Id        Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	Assignment_Attr_Ovn       Hxc_Time_Attributes.Object_Version_Number%TYPE,
	PO_Line_Id		          Pa_Expenditure_Items_All.PO_Line_Id%TYPE,
	PO_Line_Id_Attr_Id        Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	PO_Line_Id_Ovn		      Hxc_Time_Attributes.Object_Version_Number%TYPE,
	PO_Price_Type		      Pa_Expenditure_Items_All.PO_Price_Type%TYPE,
	PO_Price_Type_Attr_Id     Hxc_Time_Attributes.Time_Attribute_Id%TYPE,
	PO_Price_Type_Ovn	      Hxc_Time_Attributes.Object_Version_Number%TYPE,
	Person_Type		          Pa_Expenditures_All.Person_Type%TYPE,
	Vendor_Id		          Pa_EXpenditures_All.Vendor_Id%TYPE,
	PO_Header_Id		      Number,
	Approval_Status           Hxc_Time_Building_Blocks.Approval_Status%TYPE,
    Action                    Varchar2(30));

   G_timecard_table Timecard_Table;

   TYPE Message_Token IS Record (
        Token_Name   Varchar2(30),
        Token_Value  Varchar2(255));

   TYPE Message_Tokens IS Table OF Message_Token
	INDEX BY Binary_Integer;

   TYPE EndDateBatchName_Rec IS Record (
        Expenditure_Ending_Date   Pa_Transaction_Interface_All.Expenditure_Ending_Date%TYPE,
        Batch_Name                Pa_Transaction_Interface_All.Batch_Name%TYPE);

   TYPE EndDateBatchName_Tab IS Table OF EndDateBatchName_Rec
        INDEX BY Binary_Integer;

   TYPE Trx_Inserted IS Record (
	BB_Index      Binary_Integer);

   TYPE Trx_Inserted_Table IS Table OF Trx_Inserted
	INDEX BY Binary_Integer;

-- Define exceptions used in the API

   Delete_Line_Exception   Exception;
   E_Validation_Failure    Exception;
   E_Is_Deleted		   Exception;


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
--    P_Function     -  Varchar2 -- ADD or STRIP
--    P_Value        -  Varchar2
--
/*-------------------------------------------------------------------------*/

   Procedure TrackPath (
	P_Function IN Varchar2,
	P_Value    IN Varchar2);

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
--    P_Message_Table           - Hxc_User_Type_Definition_Grp.Message_Table
--    P_Message_Name            - Fnd_New_Messages.Message_Name%TYPE
--    P_Message_Level           - Varchar2
--    P_Message_Field           - Varchar2
--    P_Msg_Tokens              - Pa_Otc_Api.Message_Tokens
--    P_Time_Building_Block_Id  - Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE
--    P_Time_Attribute_Id       - Hxc_Time_Attributes.Time_Attribute_Id%TYPE
--    P_Message_App             - Varchar2 Default 'PA'
--
-- OUT
--    P_Message_Table           - Hxc_User_Type_Definition_Grp.Message_Table
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
		  P_Message_App             IN            Varchar2 Default 'PA');


/*  IMPORT ROUTINES  */


-- =======================================================================
-- Start of Comments
-- API Name      : Upload_Otc_Timecards
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to pull approved self service
--                 timecards into transaction interface table.
-- Parameters    :
-- IN
--           P_Transaction_Source:  - Pa_Transaction_Interface_All.Transaction_Source%TYPE
--           P_Batch:               - Pa_Transaction_Interface_All.Batch_Name%TYPE
--           P_Xface_Id             - Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE
--           P_User_Id              - Number

/*--------------------------------------------------------------------------*/

PROCEDURE Upload_Otc_Timecards(P_Transaction_Source IN Pa_Transaction_Interface_All.Transaction_Source%TYPE,
                               P_Batch              IN Pa_Transaction_Interface_All.Batch_Name%TYPE,
                               P_Xface_Id           IN Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE,
                               P_User_Id            IN Number);


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
--           P_Batch_Name                 Varchar2
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
            P_Xface_Id                IN Pa_Transaction_Interface_All.Txn_Interface_Id%TYPE);

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
--       Values for parameter P_Commend_Or_Dff
--       -------------------------------------
--                 C for Comment
--                 D for Dff
--                 B for Both
--
-- Parameters    :
-- IN            P_Old_Orig_Txn_Ref   - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--               P_New_Orig_Txn_Ref   - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--               P_Comment_Or_Dff     - Varchar2
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
               P_User_Id            IN Pa_Expenditure_Items_All.Last_Updated_By%TYPE);

-- =======================================================================
-- Start of Comments
-- API Name      : Tieback_Otc_Timecards
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to tieback timecards that have been
--                 interfaced to Oracle Projects successfully. This API
--                 will stamp the OTC timecard PL/SQL tables with the fact that
--                 timecards retrieved have been sucessfully import. This will be
--                 done via a call to an OTC API.
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
                                  P_User_Id            IN Number);

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
--               : nothing else then the expenditure item should be directly updated.
--
-- Parameters    :
-- IN
--                P_New_Timecard_Rec  - Pa_Otc_Api.Timecard_Rec
--                P_Old_Timecard_Rec  - Pa_Otc_Api.Timecard_Rec
-- OUT
--                P_Direct_Update_Flag - Boolean
--                P_Comment_Or_Dff     - Varchar2
--
/*--------------------------------------------------------------------------*/

  Procedure DetermineDirectUpdate(
                        P_New_Timecard_Rec   IN         Pa_Otc_Api.Timecard_Rec,
                        P_Old_Timecard_Rec   IN         Pa_Otc_Api.Timecard_Rec,
                        P_Direct_Update_Flag OUT NOCOPY Boolean,
                        P_Comment_Or_Dff     OUT NOCOPY Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : PopulateProjRec
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure pulls all the data from the OTC pl/sql into a projects
--               : oriented structure for easier processing.
--
-- Parameters    :
-- IN
--                P_New_Old_BB   - Varchar2  Allowed Values:
--                                              Import values:  'OLD' 'NEW'
--                                              Validation value:
--                P_BB_Id        - Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE
--                P_Detail_Index - Binary_Integer
--                P_Old_Detl_Ind - Binary_Integer
-- OUT
--                P_Timecard_Rec - Pa_Otc_Api.Timecard_Rec
--
/*--------------------------------------------------------------------------*/

  Procedure PopulateProjRec(
                  P_New_Old_BB   IN         Varchar2,
                  P_BB_Id        IN         Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE,
                  P_Detail_Index IN         Binary_Integer,
		  P_Old_Detl_Ind IN         Binary_Integer,
                  P_Timecard_Rec OUT NOCOPY Pa_Otc_Api.Timecard_Rec); -- 2672653


-- ========================================================================
-- Start Of Comments
-- API Name      : GetDetailIndex
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure finds the Index located in the detail pl/sql
--                 Hxc_User_Type_Definition_Grp.T_Detail_Bld_Blks table generated
--                 during the generic retrieval process for the
--                 Building_Block_Id that is passed in to it.
--
-- Parameters    :
-- IN
--               P_Detail_BB_Id  - Hxc_User_Type_Definition_Grp.Resource_Id%TYPE
-- OUT
--               X_Detail_Index  - Binary_Integer

/*--------------------------------------------------------------------------*/


   Procedure GetDetailIndex( P_Detail_BB_Id IN         Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE,
                             X_Detail_Index OUT NOCOPY Binary_Integer);



/*  UPDATE and VALIDATION ROUTINES */


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


   Function Projects_Retrieval_Process RETURN Varchar2;


-- =======================================================================
-- Start of Comments
-- API Name      : Update_Otc_Data
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the OTC client team server-side
--                 non-user data modification section of their code.
--                 The only intent of the Procedure is manipulate the parameters
--                 passed in and then call the Private procedure Update_Otc_Data()
--                 to update the Billable_flag when appropriate.
--
-- Parameters    :
-- IN
--           P_operation            -  Varchar2

/*------------------------------------------------------------------------- */

  Procedure Update_Otc_Data
            (P_Operation            IN Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : Update_Process
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the Public procedure Update_Process()
--                 The only intent of this procedure is to get the BILLABLE_FLAG
--                 from patc/patcx and return control back to the calling procedure.
--                 No handled errors will be returned to the OTC client team server code calling
--                 procedure. Unhandled exceptions will be allowed.
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
                      P_Operation         IN            Varchar2,
                      P_Building_Blocks   IN OUT NOCOPY Hxc_User_Type_Definition_Grp.Timecard_Info, -- 2672653
                      P_Attribute_Table   IN OUT NOCOPY Hxc_User_Type_Definition_Grp.App_Attributes_Info); -- 2672653

-- =======================================================================
-- Start of Comments
-- API Name      : Validate_Otc_Data
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the OTC client team server-side
--                 Validation section of their code. The only intent of the
--                 Procedure is manipulate the parameters passed in and then call
--                 the Private procedure Validate_Otc_Date() to Validate the data.
--
-- Parameters    :
-- IN
--           P_operation            -  Varchar2

/*------------------------------------------------------------------------- */

  Procedure Validate_Otc_Data
            (P_Operation            IN Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : Validate_Process
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure validates the Timecard Header/lines
--                 information entered by the user.
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
              P_Message_Table     IN OUT NOCOPY Hxc_User_Type_Definition_Grp.Message_Table); -- 2672653


-- =======================================================================
-- Start of Comments
-- API Name      : Validate_Project_Exists
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure accepts the Project_Id as an IN parameter
--                 and ckecks if this project exists in Oracle Projects.
--                 This procedure does not perform any extensive project
--                 related validations.  If the project exists in
--                 Oracle Projects, X_Project_Number will be populated
--                 with segment1, else X_Project_Number will be null.
-- Parameters    :
-- IN
--           P_Project_Id      - Pa_Projects_All.Project_Id%TYPE
-- OUT
--           X_Error_Code      - Varchar2
--           X_Error_Type      - Varchar2
--           X_Project_Number  - Pa_Projects_All.Segment1%TYPE

/*-------------------------------------------------------------------------*/

PROCEDURE Validate_Project_Exists(
			P_Project_Id     IN         Pa_Projects_All.Project_Id%TYPE,
            X_Error_Code     OUT NOCOPY Varchar2,
            X_Error_Type     OUT NOCOPY Varchar2,
			X_Project_Number OUT NOCOPY Pa_Projects_All.Segment1%TYPE);


-- =======================================================================
-- Start of Comments
-- API Name      : Validate_Task_Exists
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure accepts the Project_Id and Task_Id
--                 as IN parameters and ckecks if this task exists in
--                 pa_online_task_v.  This procedure does not perform any
--                 extensive task related validations.  If the task
--                 exists in the online view, X_Task_Number will be populated
--                 with Task_Number, else X_Task_Number will be null.
-- Parameters    :
-- IN
--           P_Task_Id       - Pa_Tasks.Task_Id%TYPE
--           P_Project_Id    - Pa_Projects.Project_Id%TYPE
-- OUT
--           X_Error_Code    - Varchar2
--           X_Error_Type    - Varchar2
--           X_Task_Number   - Pa_Tasks.Task_Number%TYPE

/*-------------------------------------------------------------------------*/

   Procedure Validate_Task_Exists(
            P_Task_Id       IN         Pa_Tasks.Task_Id%TYPE,
			P_Project_Id    IN         Pa_Projects.Project_Id%TYPE,
            X_Error_Code    OUT NOCOPY Varchar2,
            X_Error_Type    OUT NOCOPY Varchar2,
			X_Task_Number   OUT NOCOPY Pa_Tasks.Task_Number%TYPE);



-- ==========================================================================
-- Start of Comments
-- API Name      : Validate_Exp_Type_Exists
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure checks if the system linkage/expenditure type
--                 combination exists in the database.
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
           X_Error_Code       OUT NOCOPY Varchar2);


-- ===========================================================================
-- API Name      : Validate_overriding_approver
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This function validates the overriding approver entered
--                 in timecard header screen.
--
-- Parameters    :
--  IN
--           P_Approver_Id      - Per_People_F.Person_Id%TYPE
--
--  OUT
--           X_Approver_Id      - Per_People_F.Person_Id%TYPE
--           X_Error_Type       - Varchar2
--           X_Error_Code       - Varchar2

/* ------------------------------------------------------------------------*/

   Procedure Validate_Overriding_Approver(

		    P_Approver_Id         IN         Per_People_F.Person_Id%TYPE,
                    X_Approver_Id         OUT NOCOPY Per_People_F.Person_Id%TYPE,
                    X_Error_Type          OUT NOCOPY Varchar2,
                    X_Error_Code          OUT NOCOPY Varchar2);


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
--              P_BB_Id                - Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE
--              P_BB_Ovn               - Hxc_Time_Building_Blocks.Object_Version_Number%TYPE
--              P_BB_Date_To           - Hxc_Time_Building_Blocks.Date_To%TYPE
--              P_BB_Changed           - Varchar2
--              P_BB_New               - Varchar2
--              P_Proj_Attribute_Rec   - Pa_Otc_Api.Project_Attribution_Rec
--              P_Mode                 - Varchar2
--              P_Proces_Flag          - Varchar2
-- OUT
--              X_BB_Detail_Changed    - Varchar2
--              X_Data_Conflict_Flag   - Varchar2
--              X_BB_Detail_Deleted    - Varchar2
--              X_Adj_in_Projects_Flag - Varchar2
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
                X_Adj_in_Projects_Flag OUT NOCOPY Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : AdjustAllowedToOTCItem
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to check and see if an OTC expenditure item that
--                 has been imported into Projects can adjusted in Projects.  Will be calling
--                 an OTC API to determine this. Hxc_Integration_Layer_V1_Grp.Time_Bld_Blk_Changed().
--
-- Parameters    :
-- IN            P_Orig_Txn_Reference - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
-- OUT           X_Flag               - Boolean
--

/*--------------------------------------------------------------------------*/

   Procedure  AdjustAllowedToOTCItem(
             P_Orig_Txn_Reference IN         Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE,
		     X_Flag               OUT NOCOPY Boolean);


-- =======================================================================
-- Start of Comments
-- API Name      : ProjectTaskUsed
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to check to see if there are Project OTC
--                 expenditure items that are using a specific project or task. Will be calling
--                 an OTC API to determine this.  If parameters are not properly populated then
--                 return TRUE.
--
-- Parameters    :
-- IN            P_Search_Attribute - Varchar2 -- 'PROJECT' or 'TASK'
--               P_Search_Value     - Number   -- Project_Id or Task_Id
-- OUT           X_Used             - Boolean
--

/*--------------------------------------------------------------------------*/

   Procedure ProjectTaskUsed(P_Search_Attribute IN         Varchar2,
			     P_Search_Value     IN         Number,
			     X_Used             OUT NOCOPY Boolean);

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
                                  X_Purgeable        OUT NOCOPY Boolean);

-- ========================================================================
-- Start Of Comments
-- API Name      : RetrieveProjAttribution
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to pull out the needed project specific data from
--                 the OTC pl/sql table P_Attribute_Table.
--
-- Parameters    :
-- IN            P_Building_Block_Rec  - Hxc_User_Type_Definition_Grp.Building_Block_Info
--               P_Building_Block      - Hxc_User_Type_Definition_Grp.Timecard_Info,
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
                X_Proj_Attrib_Rec     OUT    NOCOPY Pa_Otc_Api.Project_Attribution_Rec); -- 2672653

-- ========================================================================
-- Start Of Comments
-- API Name      : RetrieveProjAttrForUpd
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to pull out the needed project specific data from
--                 the OTL pl/sql table P_Attribute_Table, and if necessary create
--                 the billable flag record.
--
-- Parameters    :
-- IN            P_Building_Block_Rec  - Hxc_Self_Service_Time_Deposit.Building_Block_Info
--               P_Building_Block      - Hxc_Self_Service_Time_Deposit.Timecard_Info
--               P_Attribute_Table     - Hxc_Self_Service_Time_Deposit.App_Attributes_Info
--               X_Detail_Attr_Changed - VARCHAR2(1)
-- OUT
--               P_Attribute_table     - Hxc_Self_Service_Time_Deposit.App_Attributes_Info
--               X_Detail_Attr_Changed - VARCHAR2(1)
--               X_Proj_Attrib_Rec     - Pa_Otc_Api.Project_Attribution_Rec
--

/*--------------------------------------------------------------------------*/

   Procedure RetrieveProjAttribForUpd(
              P_Building_Block_Rec  IN            Hxc_User_Type_Definition_Grp.Building_Block_Info,
              P_Building_Block      IN            Hxc_User_Type_Definition_Grp.Timecard_Info,
              P_Attribute_Table     IN OUT NOCOPY Hxc_User_Type_Definition_Grp.App_Attributes_Info,
              X_Detail_Attr_Changed IN OUT NOCOPY Varchar2,
              X_Proj_Attrib_Rec        OUT NOCOPY Pa_Otc_Api.Project_Attribution_Rec);


-- ========================================================================
-- Start Of Comments
-- API Name      : GetPRMAssignTemplates
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Return        : n/a
-- Function      : This procedure is used to pull from PRM the Forecast Assignment data and provide
--                 it as template data for OTC.  It will not have TASK information in it.  It will
--                 be placed in OTC friendly format for the OTC team to populate the current timecard
--                 with the Forecast Assignment data.  Validation for expenditure_type and system_linkage_function
--                 combinations will take place within the code before passing it to OTC.  Any combo that
--                 is not valid for the day in question will not be pulled over.
--
-- Parameters    :
-- IN            P_Resource_Id            IN  Hxc_Time_Building_Blocks.Resource_Id%TYPE
--               P_Start_Date             IN  Hxc_Time_Building_Blocks.Start_Time%TYPE
--               P_Stop_Date              IN  Hxc_Time_Building_Blocks.Stop_Time%TYPE
-- OUT
--               P_Attributes             OUT Varchar2
--               P_Timecard               OUT Varchar2
--               P_Messages               OUT Varchar2


/*--------------------------------------------------------------------------*/

   Procedure GetPRMAssignTemplates(
		P_Resource_Id            IN         Hxc_Time_Building_Blocks.Resource_Id%TYPE,
                P_Start_Date             IN         Hxc_Time_Building_Blocks.Start_Time%TYPE,
                P_Stop_Date              IN         Hxc_Time_Building_Blocks.Stop_Time%TYPE,
		P_Attributes             OUT NOCOPY Varchar2,
		P_Timecard               OUT NOCOPY Varchar2,
		P_Messages               OUT NOCOPY Varchar2);


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
--           X_Pass_Val_Flag          - Varchar2
--	     X_Approval_Status        - Hxc_Time_Building_Blocks.Approval_Status%TYPE

/*--------------------------------------------------------------------------*/


   Procedure FindandValidateHeader(
                        P_Building_Blocks_Table  IN            Hxc_User_Type_Definition_Grp.Timecard_Info,
                        P_Attribute_Table        IN            Hxc_User_Type_Definition_Grp.App_Attributes_Info,
                        P_Message_Table          IN OUT NOCOPY Hxc_User_Type_Definition_Grp.Message_Table,-- 2672653
                        X_TimeBB_Id              OUT    NOCOPY Hxc_Time_Building_Blocks.Time_Building_Block_Id%TYPE,
                        X_Ovr_Approver_Person_Id OUT    NOCOPY Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE,
			X_Pass_Val_Flag          OUT    NOCOPY Varchar2,
			X_Approval_Status        OUT    NOCOPY Hxc_Time_Building_Blocks.Approval_Status%TYPE);

-- =======================================================================
-- Start of Comments
-- API Name      : Wf_AutoApproval_BusMsg
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the OTL client team.
--                 Calls the Pa_Client_Extn_Pte.Get_Exp_AutoApproval() and
--                 the PA_Time_Client_Extn.Display_Business_Message() extensions.
--
-- Parameters    :
-- OUT
--           X_AutoApproval_Flag    -  Varchar2
--           X_Messages             -  Varchar2

/*------------------------------------------------------------------------- */

  Procedure Wf_AutoApproval_BusMsg
            (X_AutoApproval_Flag    OUT NOCOPY Varchar2
            ,X_Messages             OUT NOCOPY Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : Wf_RouteTo_CheckApproval
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is called by the OTL client team.
--                 Calls the Paroutingx.Route_To_Extension() and
--                 and Pa_Client_Extn_Rte.Check_Approval() extensions.
--
-- Parameters    :
-- IN
--           P_Previous_Approver_Id -  Number
-- OUT
--           X_Approver_Person_Id   -  Number
--           X_Messages             -  Varchar2

/*------------------------------------------------------------------------- */

  Procedure Wf_RouteTo_CheckApproval
            (P_Previous_Approver_Id IN         Number
            ,X_Approver_Person_Id   OUT NOCOPY Number
            ,X_Messages             OUT NOCOPY Varchar2);

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
--           X_Inc_By_Person_Id              - Pa_Expenditures_All.Incurred_By_Person_Id%TYPE
--           X_Timecard_Table                - Pa_Otc_Api.Timecard_Table
--           X_Overriding_Approver_Id        - Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE

/*------------------------------------------------------------------------- */

  Procedure CreateProjTimecardTable
            (X_Inc_By_Person_Id              OUT NOCOPY Pa_Expenditures_All.Incurred_By_Person_Id%TYPE
            ,X_Timecard_Table                OUT NOCOPY Pa_Otc_Api.Timecard_Table --2672653
            ,X_Overriding_Approver_Id        OUT NOCOPY Pa_Expenditures_All.Overriding_Approver_Person_Id%TYPE);


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
	   ( P_Orig_Transaction_Reference IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE) RETURN Boolean;
  -- Pragma  RESTRICT_REFERENCES ( OrigTrxRefValueExists, WNPS );


-- =======================================================================
-- Start of Comments
-- API Name      : ChkAdjustAllowedToOTCItem
-- Type          : Public
-- Pre-Reqs      : None
-- Type          : Function
-- Function      : This function s used to check and see if an OTC expenditure item that
--                 has been imported into Projects can adjusted in Projects by calling the
--                 API Hxc_Generic_Retrieval_Utils.Time_Bld_Blk_Changed.
--
-- Parameters    :
-- IN            P_Orig_Txn_Reference - Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE
--
/*--------------------------------------------------------------------------*/

  Function ChkAdjustAllowedToOTCItem
        (P_Orig_Txn_Reference IN Pa_Expenditure_Items_All.Orig_Transaction_Reference%TYPE) RETURN Varchar2;

-- =======================================================================
-- Start of Comments
-- API Name      : GetBatchName
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure returns a batch name for Trx Import to used based on the
--                 expenditure_ending_date passed in.  Each time a new batch is created a new
--                 record is added to a pl/sql table holding the Ending_Date Batch_Name so as
--                 to only create single batch_name for each Ending_Date for a Trx Import run.
--
-- Parameters    :
-- IN
--              P_Exp_End_Date - Pa_Transaction_Interface_All.Expenditure_Ending_Date%TYPE
-- OUT
--              X_Batch_Name   - Pa_Transaction_Interface_All.Batch_Name%TYPE
/*--------------------------------------------------------------------------*/

  Procedure GetBatchName (P_Exp_End_Date IN         Pa_Transaction_Interface_All.Expenditure_Ending_Date%TYPE,
                          X_Batch_Name   OUT NOCOPY Pa_Transaction_Interface_All.Batch_Name%TYPE);


-- =======================================================================
-- Start of Comments
-- API Name      : IsNumber
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Function
-- Returns       : BOOLEAN
-- Function      : This functions determines if the varchar passed back is a number.
--
-- Parameters    :
-- IN
--              P_Value - VARCHAR2
/*--------------------------------------------------------------------------*/

  Function IsNumber (P_Value IN Varchar2) RETURN Boolean;


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
--              X_OrigTrxRef        - Varchar2
--              X_Status            - Varchar2
/*--------------------------------------------------------------------------*/

  Procedure GetOrigTrxRef (P_Building_Block_Id IN         Number,
                           X_OrigTrxRef        OUT NOCOPY Varchar2,
                           X_Status            OUT NOCOPY Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : GetAdditionalTrxData
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Returns       :
-- Function      : Gets all the addition data needed to insert records into the Trx Interface table
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
                                  X_Error_Status OUT NOCOPY Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : BulkInsertReset
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Returns       :
-- Function      : Calls bulk insert API.
--                 Empties out all the global pl/sql arrays used for the bulk insert.
--                 If the P_Command is 'INSERT' then the bulk insert command table handler is executed,
--                 then the pl/sql table arrays are reset for the next time thru.
--                 If the P_Command is 'RESET' then pl/sql table arrays are only reset.
--
-- Parameters    :
-- IN            :
--               : P_Command   Varchar2
-- OUT           : n/a

/*--------------------------------------------------------------------------*/

  Procedure BulkInsertReset (P_Command IN Varchar2);


-- =======================================================================
-- Start of Comments
-- API Name      : TrxInCurrentChunk
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Function
-- Returns       : Varchar2
-- Function      : Determine if the Trx in part of the current chunk being processed.
--
-- Parameters    :
-- IN            :
--               : P_Detail_BB_Id  - Number
-- OUT           : n/a

/*--------------------------------------------------------------------------*/

  Function TrxInCurrentChunk (P_Detail_BB_Id IN Number) RETURN Varchar2;


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

  Function GetProjectManager ( P_Project_Id IN Number ) RETURN Number;


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
--               : P_Person_Id  - Number
--		 : P_Ei_Date    - Date
-- OUT           : n/a

/*--------------------------------------------------------------------------*/

  Function GetPersonType ( P_Person_Id IN Number, P_Ei_Date IN Date) RETURN Varchar2;

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

  Procedure GetPOInfo(P_Po_Line_Id   IN         Number,
		      X_Po_Header_Id OUT NOCOPY Number,
		      X_Vendor_Id    OUT NOCOPY Number);


END;

 

/
