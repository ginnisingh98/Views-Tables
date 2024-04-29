--------------------------------------------------------
--  DDL for Package Body PA_TIEBACK_ADJ_COSTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TIEBACK_ADJ_COSTS" As
/* $Header: PAXAPJTB.pls 115.1 2002/08/22 19:15:16 eyefimov noship $ */

   G_ParentTxnTab  PA_TIEBACK_ADJ_COSTS.ParentTxnTab;

   G_Success_Count NUMBER := 0;
   G_Reject_Count  NUMBER := 0;

   /*----------------------------------------------------------------------------------------+
    |   Procedure  :   Is_Adjusted                                                           |
    |   Purpose    :   Receipt corrections and returns whose original item has been adjusted |
    |                  in Projects will be displayed in a different section of the           |
    |                  AUD: Payables Costs Interface Audit report.                           |
    |                  This function is called from the receipt portion of the query in      |
    |                  PAAPIMPR.rdf                                                          |
    |                  Caching is done in this API based on the parent transaction id        |
    |                  (P_Parent_Txn_Id)                                                     |
    +----------------------------------------------------------------------------------------*/

   Function Is_Adjusted(P_Po_Dist IN Number,
                        P_Txn_Id  IN Number,
                        P_Parent_Txn_Id IN Number,
                        P_Trx_Type IN Varchar2) Return Varchar2
   Is

	l_Adjusted Varchar2(1) := 'N';
	l_Found    Boolean;

	Cursor c_Rcvtxns Is
	Select Transaction_Id
	From Rcv_Transactions
	Where (Transaction_Id = P_Parent_Txn_Id OR
	       Parent_Transaction_Id = P_Parent_Txn_Id)
	And Nvl(Pa_Addition_Flag,'N') IN ('Y', 'I');

   Begin

	If P_Trx_Type IN ('CORRECT', 'RETURN TO VENDOR', 'RETURN TO RECEIVING') Then

		l_Found := FALSE;

   		-- Check if there are any records in the pl/sql table.
		If G_ParentTxnTab.COUNT > 0 Then

			Begin

           			-- Get the value of the record for the given parent_txn_id
           			-- If there is no index with the value of the parent_txn_id passed
           			-- in then an ORA-1403: No_Data_Found is generated.
           			l_Adjusted := G_ParentTxnTab(P_Parent_Txn_Id);
				l_Found := TRUE;

       			Exception
           			When No_Data_Found Then
					l_Found := FALSE;
           			When Others Then
                			Raise;

       			End;

		End If;

		If Not l_Found Then

			-- Since the Rcpt has not been cached yet, will need to add it.
			-- So check to see if there are already 200 records in the pl/sql table.
			If G_ParentTxnTab.COUNT > 199 Then

				G_ParentTxnTab.Delete;

			End If;

			For EiRec IN c_Rcvtxns Loop

				Begin

					Select 'Y'
					Into l_Adjusted
					From Dual
					Where Exists
						(Select 1
					 	 From Pa_Expenditure_Items_All Ei,
					      	      Pa_Cost_Distribution_Lines_All Cdl
					 	 Where Nvl(Ei.Adjusted_Expenditure_Item_Id,
									Ei.Transferred_From_Exp_Item_Id) =
												Cdl.Expenditure_Item_Id
					 	 And Nvl(Cdl.System_Reference4,'X') = To_Char(EiRec.Transaction_Id)
					 	 And Cdl.Line_Num = 1);

					If l_Adjusted = 'Y' Then

						G_ParentTxnTab(P_Parent_Txn_Id) := l_Adjusted;

					End If;

				Exception
					When No_Data_Found Then
                        		    -- Add if the Rcpt is adjusted into the pl/sql table using the Parent_Txn_Id
                        		    -- as the index value.  This makes things fast.
                        		    l_Adjusted := 'N';
                        		    G_ParentTxnTab(P_Parent_Txn_Id) := l_Adjusted;
				End;

			End Loop;

   		End If;

 	End If;

 	Return l_Adjusted;

   EXCEPTION
   	When No_Data_Found Then
        	Return l_Adjusted;

   END Is_Adjusted;

   /*----------------------------------------------------------------------------------------+
    |   Procedure  :   Init                                                                  |
    |   Purpose    :   To initialize all required params/debug requirements                  |
    +----------------------------------------------------------------------------------------*/

   Procedure Init Is

	l_Debug_Mode VARCHAR2(10);

   Begin

	Fnd_Profile.Get('PA_DEBUG_MODE',l_Debug_Mode);
	l_Debug_Mode             := Nvl(l_Debug_Mode, 'N');

	Pa_Debug.G_Err_Stage := 'Entering Init';
	Log_Message(P_Message => Pa_Debug.G_Err_Stage);

	Pa_Debug.Set_Curr_Function( P_Function   => 'Init',
				    P_Debug_Mode => l_Debug_Mode);

	G_REQUEST_ID             := Fnd_Global.Conc_Request_Id;
	G_PROGRAM_APPLICATION_ID := Fnd_Global.Prog_Appl_Id;
	G_PROGRAM_ID             := Fnd_Global.Conc_Program_Id;
	G_DEBUG_MODE             := l_Debug_Mode;

   End Init;

   /*----------------------------------------------------------------------------------------+
    |   Procedure  :   Log_Message                                                           |
    |   Purpose    :   To write log message as supplied by the process                       |
    |   Parameters :                                                                         |
    |     ================================================================================== |
    |     Name                             Mode    Description                               |
    |     ================================================================================== |
    |     P_Message                        IN      Message to be logged                      |
    |     ================================================================================== |
    +----------------------------------------------------------------------------------------*/

   Procedure Log_Message(P_Message IN Varchar2) Is

   Begin

	Pa_Debug.Log_Message (P_Message => P_Message);

   End Log_Message;

   Procedure Write_Output (X_Return_Status      OUT Varchar2,
                           X_Error_Message_Code OUT Varchar2)

   Is

   Begin

	/* This has to be changed.  Cannot hard code text for a report.  Need to use messages that will be
	 * translated.
	 */

	Fnd_File.Put_Line(FND_FILE.OUTPUT, '               Tieback Adjustment Invoices Output               ');
	Fnd_File.Put_Line(FND_FILE.OUTPUT, '----------------------------------------------------------------');
	Fnd_File.Put_Line(FND_FILE.OUTPUT, 'Number of Records Successfully Processed = ' || G_Success_Count);
	Fnd_File.Put_Line(FND_FILE.OUTPUT, 'Number of Records Rejected = ' || G_Reject_Count);
	Fnd_File.Put_Line(FND_FILE.OUTPUT, '----------------------------------------------------------------');

   End Write_Output;

   /*----------------------------------------------------------------------------------------+
    |   Procedure  :   TiebackAdjCosts                                                       |
    |   Purpose    :   To tieback adjustment invoices from Payables                          |
    |   Parameters :                                                                         |
    |     ================================================================================== |
    |     Name                             Mode    Description                               |
    |     ================================================================================== |
    |     X_Return_Status                  OUT      Return Status                            |
    |     X_Error_Message_Code             OUT      Error Message Code (if any)              |
    |     ================================================================================== |
    |   Called By  :   PRC: Tieback Adjustment Invoices from Payables                        |
    |   Process    :                                                                         |
    |      1. Fetch a new set of CDL's to tie back - Transfer Status Code of 'I'             |
    |      2. Retrieve status from ap_invoices_interface, depending on the reference_2 and   |
    |         reference_2 columns in ap_invoice_lines_interface.                             |
    |      3. If status is PROCESSED then update transfer status code to 'A',                |
    |         Else if REJECTED then update to 'R'                                            |
    |      4. Write to OUTPUT file how many were rejected/succesfully processed              |
    |      5. Deleting rejected from ap_invoices_interface                                   |
    |      6. Deleting rejected from ap_invoice_lines_interface                              |
    |      7. Commit                                                                         |
    +----------------------------------------------------------------------------------------*/

   Procedure TiebackAdjCosts(X_Return_Status      OUT Varchar2,
                             X_Error_Message_Code OUT Varchar2)

   Is

	Cursor C_TiebackRecs Is
	     Select Cdl.RowId,
	            Cdl.Expenditure_Item_Id,
	            Cdl.Line_Num,
	            Inv.Status
	     From   Pa_Cost_Distribution_Lines Cdl,
	            Ap_Invoices_Interface Inv,
	            Ap_Invoice_Lines_Interface Lines
	     Where  Cdl.Transfer_Status_Code = 'I'
	     And    Inv.Source = 'PA_COST_ADJUSTMENTS'
	     And    Inv.Invoice_Id = Lines.Invoice_Id
	     And    Lines.Reference_2 = To_Char(Cdl.Expenditure_Item_Id) || '-' || To_Char(Cdl.Line_Num);

	   /* Need new index on Ap_Invoice_Lines_Interface (reference_2) */

	l_RowIdTab      PA_PLSQL_DATATYPES.RowidTabTyp;
	l_EiTab         PA_PLSQL_DATATYPES.IdTabTyp;
	l_LineNumTab    PA_PLSQL_DATATYPES.IdTabTyp;
	l_InvStatusTab  PA_PLSQL_DATATYPES.Char25TabTyp;

	L_ROWS          BINARY_INTEGER := 200;

   BEGIN

	Init;

	PA_DEBUG.Set_Curr_Function( 'TiebackAdjCosts', G_debug_mode);

	PA_DEBUG.g_err_stage := 'Start of Tieback Adjustment Invoices program';
	Log_Message(PA_DEBUG.g_err_stage);

	Open C_TiebackRecs;

	Loop

		Pa_Debug.G_Err_Stage := 'Inside Loop';
		Log_Message(Pa_Debug.G_Err_Stage);

		l_RowIdTab.Delete;
		l_EiTab.Delete;
		l_LineNumTab.Delete;
		l_InvStatusTab.Delete;

		Fetch C_TiebackRecs Bulk Collect Into
			l_RowIdTab,
			l_EiTab,
			l_LineNumTab,
			l_InvStatusTab
		Limit L_ROWS;

		Pa_Debug.G_Err_Stage := 'Log: No. of records Selected ' || l_RowIdTab.Count;
		Log_Message(Pa_Debug.G_Err_Stage);

		If l_RowIdTab.Count = 0 Then

			Pa_Debug.G_Err_Stage := 'Log: No records in C_TiebackRecs to process, exiting.';
			Log_Message(Pa_Debug.G_Err_Stage);
			Exit;

		End If;

		-- ForAll i IN l_RowIdTab.First .. l_RowIdTab.Last
		For i In l_RowIdTab.First .. l_RowIdTab.Last Loop

			Log_Message('Ei = ' || L_EiTab(i) ||
				    ' Line = ' || L_LineNumTab(i) ||
				    ' InvStatus = ' || l_InvStatusTab(i));

             		Update  PA_Cost_Distribution_Lines Cdl
                	   Set (Cdl.System_Reference2,
                      		Cdl.System_Reference3,
                      		Cdl.gl_date,
                      		Cdl.gl_period_name) =
                       	       		(Select  Decode(l_InvStatusTab(i),'PROCESSED',
							Dist.Invoice_Id,CDL.System_Reference2),
                          			 Decode(l_InvStatusTab(i),'PROCESSED',
							Dist.Distribution_Line_Number,Cdl.System_Reference3),
                          			 Decode(l_InvStatusTab(i),'PROCESSED',
							Dist.Accounting_Date,Cdl.Gl_Date),
                          			 Decode(l_InvStatusTab(i),'PROCESSED',
							Pa_Utils2.Get_Gl_Period_Name(Dist.Accounting_Date,Dist.Org_Id),
								Cdl.Gl_Period_Name)
                        		From Ap_Invoice_Distributions Dist
                        		Where Dist.Reference_2 = To_Char(Cdl.Expenditure_Item_Id) || '-' ||
												to_char(Cdl.Line_Num)
					And   Pa_Addition_Flag = 'T'),
		      		Cdl.Transfer_Status_Code = Decode(l_InvStatusTab(i), 'PROCESSED','A',
									   	     'REJECTED' ,'R',
											Cdl.Transfer_Status_Code),
                      		Cdl.Request_Id = G_REQUEST_ID,
                      		Cdl.Program_Application_Id = G_PROGRAM_APPLICATION_ID,
                      		Cdl.Program_Id = G_PROGRAM_ID,
                      		Cdl.Program_Update_Date = sysdate
              		Where   Cdl.RowId = l_RowIdTab(i);

			/* Need new index in ap_invoice_distributions(reference_2) */

		End Loop;

		For i in l_RowIdTab.first..l_RowIdTab.last Loop

			If l_InvStatusTab(i) = 'PROCESSED' Then

				G_Success_Count := G_Success_Count + 1;

			ElsIf l_InvStatusTab(i) = 'REJECTED' Then

				G_Reject_Count := G_Reject_Count + 1;

			End If;

		End Loop;

		Commit;

	End loop;

	Close C_TiebackRecs;

	Delete From Ap_Invoice_Lines_Interface
	Where Invoice_Id in (
		Select
			Invoice_Id
		From
			Ap_Invoices_Interface
		Where
			Source = 'PA_COST_ADJUSTMENTS'
		And     Status = 'REJECTED');

	Delete From Ap_Invoices_Interface
	Where Source = 'PA_COST_ADJUSTMENTS'
	And   Status = 'REJECTED';

	Commit;

	Write_Output(X_Return_Status, X_Error_Message_Code );

	Pa_Debug.Reset_Curr_Function;

   Exception

	When Others Then
		Raise;

   End TiebackAdjCosts;

End Pa_Tieback_Adj_Costs;

/
