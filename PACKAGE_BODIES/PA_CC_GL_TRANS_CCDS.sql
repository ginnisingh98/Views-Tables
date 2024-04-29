--------------------------------------------------------
--  DDL for Package Body PA_CC_GL_TRANS_CCDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CC_GL_TRANS_CCDS" 
--  $Header: PACCGLTB.pls 120.5.12010000.2 2009/06/04 22:48:44 apaul ship $
AS

-- Declaration of Global variables

   G_Debug_Mode                 BOOLEAN ;
   G_User_Id                    NUMBER ;
   G_Conc_Request_ID            NUMBER ;
   G_Conc_Prog_Appl_Id          NUMBER ;
   G_Conc_Program_Id            NUMBER ;
   G_Conc_Login_Id              NUMBER ;
   G_EI_Set_Size                NUMBER ;
   G_Current_SOB_Id		NUMBER ;
   G_Calling_Module		VARCHAR2(2);

PROCEDURE TRANSFER_CCDS_TO_GL (
          P_Gl_Category          IN     VARCHAR2,
          P_Expenditure_Batch    IN     VARCHAR2,
          P_From_Project_Number  IN     VARCHAR2,
          P_To_Project_Number    IN     VARCHAR2,
          P_End_Gl_Date          IN     DATE,
          P_Debug_Mode           IN     VARCHAR2,
          RET_CODE               IN OUT NOCOPY VARCHAR2,
          ERRBUF                 IN OUT NOCOPY VARCHAR2)
IS

Cursor Exp_Items is
 SELECT expenditure_item_id from pa_expenditure_items_all where expenditure_item_id in
(SELECT ei.expenditure_item_id
           FROM pa_cc_dist_lines ccd,
                Pa_expenditure_items ei,
                Pa_expenditures exp
          WHERE ccd.transfer_status_code in ('P','R')
	AND  (p_gl_category is null OR ccd.line_type = p_gl_category)
            AND (ccd.line_type = 'BL' OR
		(Ccd.line_type = 'PC' AND EXISTS (SELECT 'X'
                          		FROM pa_draft_invoices_all di,
                                     	Pa_draft_invoice_details_all did
                               		WHERE di.draft_invoice_num = did.draft_invoice_num
			                        AND di.project_id = did.project_id /* Added for bug 8505010*/

                                 		AND ccd.reference_1 = did.draft_invoice_detail_id
                                 		AND di.transfer_status_code = 'A')))
	AND TRUNC (CCD.GL_Date) <= NVL (p_END_GL_DATE, CCD.GL_DATE)
	AND NVL (CCD.request_id, G_Conc_Request_ID+1) <> G_Conc_Request_ID
            AND ei.expenditure_item_id = ccd.expenditure_item_id
            AND exp.expenditure_id = ei.expenditure_id
            AND exp.expenditure_group = p_EXPENDITURE_BATCH)
   AND p_EXPENDITURE_BATCH is NOT NULL
UNION ALL
 SELECT expenditure_item_id from pa_expenditure_items_all where expenditure_item_id in
 (SELECT ei.expenditure_item_id
           FROM pa_cc_dist_lines ccd,
                pa_expenditure_items ei,
	    pa_projects_all proj
          WHERE ccd.transfer_status_code in ('P','R')
	AND  (p_gl_category is null OR ccd.line_type = p_gl_category)
            AND (ccd.line_type = 'BL' OR
		(Ccd.line_type = 'PC' AND EXISTS (SELECT 'X'
                          		FROM pa_draft_invoices_all di,
                                     	Pa_draft_invoice_details_all did
                               		WHERE di.draft_invoice_num = did.draft_invoice_num
			                        AND di.project_id = did.project_id /* Added for bug 8505010*/
                                 		AND ccd.reference_1 = did.draft_invoice_detail_id
                                 		AND di.transfer_status_code = 'A')))
	AND TRUNC (CCD.GL_DATE) <= NVL (p_END_GL_DATE, CCD.GL_DATE)
	AND NVL (CCD.request_id, G_Conc_Request_ID+1) <> G_Conc_Request_ID
            AND ei.expenditure_item_id = ccd.expenditure_item_id
	AND ei.project_id = proj.project_id
	AND  (((p_FROM_PROJECT_NUMBER is not null and proj. SEGMENT1 >= p_FROM_PROJECT_NUMBER)
                       AND  (p_TO_PROJECT_NUMBER is not null and proj. SEGMENT1 <= p_TO_PROJECT_NUMBER))
                    OR
                      (p_FROM_PROJECT_NUMBER is not null and p_TO_PROJECT_NUMBER is null
                       and proj.SEGMENT1 >= p_FROM_PROJECT_NUMBER)
                    OR
                      (p_TO_PROJECT_NUMBER is not null and p_FROM_PROJECT_NUMBER is null
                       and proj.SEGMENT1 <= p_TO_PROJECT_NUMBER)))
  AND (p_FROM_PROJECT_NUMBER is NOT NULL or p_TO_PROJECT_NUMBER is NOT NULL)
  AND p_EXPENDITURE_BATCH is NULL
UNION ALL
 SELECT expenditure_item_id from pa_expenditure_items_all where expenditure_item_id in
 (SELECT ccd.expenditure_item_id
           FROM pa_cc_dist_lines ccd
          WHERE ccd.transfer_status_code in ('P','R')
	AND  (p_gl_category is null OR ccd.line_type = p_gl_category)
            AND (ccd.line_type = 'BL' OR
		(ccd.line_type = 'PC' AND  EXISTS (SELECT 'X'
                          		FROM pa_draft_invoices_all di,
                                     	pa_draft_invoice_details_all did
                               		WHERE di.draft_invoice_num = did.draft_invoice_num
			                        AND di.project_id = did.project_id /* Added for bug 8505010*/
                                 		AND ccd.reference_1 = did.draft_invoice_detail_id
                                 		AND di.transfer_status_code = 'A')))
	AND TRUNC (CCD.GL_DATE) <= NVL (p_END_GL_DATE, CCD.GL_DATE)
	AND NVL (CCD.request_id, G_Conc_Request_ID+1) <> G_Conc_Request_ID)
 AND p_FROM_PROJECT_NUMBER is NULL
 AND p_TO_PROJECT_NUMBER is NULL
 AND p_EXPENDITURE_BATCH is NULL;

 EiIdTab	PA_PLSQL_DATATYPES.IdTabTyp;
 l_result_code	VARCHAR2(30);

BEGIN
     IF p_debug_mode = 'Y'  THEN
            g_debug_mode := TRUE;
     ELSE
            g_debug_mode := FALSE;
     END IF;

     set_curr_function('transfer_ccds_to_gl');

     log_message('10 : Calling the initialization procedure ');

     PA_CC_GL_TRANS_CCDS.TRANSFER_CCDS_INITIALIZE ;

     log_message('20 : After the call to initialization procedure ');

    If P_Gl_Category is NOT NULL Then
         pa_cc_gl_trans_ccds.G_Calling_Module := P_Gl_Category;
    Else
         pa_cc_gl_trans_ccds.G_Calling_Module := 'CC';
    End If;

     log_message('30 : Calling module is '||G_Calling_Module);

     --
     -- Check if the profile option PA_EXP_ITEMS_PER_SET is set from the value
     -- set in G_EI_Set_Size variable by fnd_profile.value() function.
     -- If the value of G_EI_Set_Size is NULL, then set a default value of 500.
     --

     IF G_EI_Set_Size IS NULL THEN
        G_EI_Set_Size := 500;
     END IF;

	Open Exp_Items;

	LOOP

	Fetch Exp_Items bulk collect into EiidTab LIMIT G_EI_Set_Size;

	IF EiidTab.count > 0 Then

  	FORALL i IN 1..EiidTab.count
	UPDATE pa_expenditure_items
	SET last_updated_by = last_updated_by
	WHERE expenditure_item_id = EiidTab (i);

     log_message('40 : EI locked with '||sql%rowcount ||' records');

  	FORALL i IN 1..EiidTab.count
  	UPDATE pa_cc_dist_lines ccd
            SET ccd.transfer_status_code = 'X',
                ccd.transfer_rejection_code = NULL,
                ccd.request_id = G_conc_request_id
          WHERE ccd.expenditure_item_id = EiidTab (i)
          AND CCD.transfer_status_code IN ('P', 'R')
          AND    (p_gl_category IS NULL OR   CCD.line_type = p_gl_category)
          AND (CCD.line_type = 'BL'
                       OR (CCD.line_type = 'PC' AND EXISTS (SELECT 'X'
                                FROM pa_draft_invoices_all di,
                                     Pa_draft_invoice_details_all did
                               WHERE di.draft_invoice_num = did.draft_invoice_num
			         AND di.project_id = did.project_id /* Added for bug 8505010*/
                                 AND ccd.reference_1 = did.draft_invoice_detail_id
                                 AND di.transfer_status_code = 'A')))
          AND    TRUNC (CCD.GL_DATE) <= NVL (p_END_GL_DATE, CCD.GL_DATE)
          AND    NVL (CCD.request_id, G_Conc_Request_ID+1) <> G_Conc_Request_ID ;

     log_message('50 : CCDL updated with '||sql%rowcount ||' records');

	PA_XLA_INTERFACE_PKG.Create_Events
		(P_calling_module => G_Calling_Module,
		 P_data_set_id => G_conc_request_id,
		 x_result_code => l_result_code);

	commit ;

	End If;

	EXIT WHEN nvl (EiidTab.last,0) < G_EI_Set_Size;

     END LOOP ;  /** Exp_Items **/

     log_message('60 : End of the iteration ');

     Close Exp_Items;

     log_message('61 : End of the procedure ');

     reset_curr_function;

EXCEPTION
   WHEN OTHERS THEN
      reset_curr_function;
      RAISE ;

END TRANSFER_CCDS_TO_GL ;

PROCEDURE TRANSFER_CCDS_INITIALIZE
IS

BEGIN

    set_curr_function('transfer_ccds_initialize');
    -- Initialize the User_id (G_User_Id)
       log_message('10.10 : Initialize the User_id ');
       pa_cc_gl_trans_ccds.G_User_Id := fnd_profile.value('USER_ID');

    -- Initialize concurrent request id
    log_message('10.20 : Initialize concurrent request id ');
    pa_cc_gl_trans_ccds.G_Conc_Request_ID := fnd_global.conc_request_id ;

    -- Initialize concurrent program application id
    log_message('10.30 : Initialize concurrent program application id ');
    pa_cc_gl_trans_ccds.G_Conc_Prog_Appl_Id := fnd_global.prog_appl_id ;

    -- Initialize concurrent program application id
    log_message('10.40 : Initialize concurrent program application id ');
    pa_cc_gl_trans_ccds.G_Conc_Program_Id := fnd_global.conc_program_id ;

    -- Initialize login id
    log_message('10.50 : Initialize login id ');
    pa_cc_gl_trans_ccds.G_Conc_Login_Id := fnd_profile.value('LOGIN_ID');

    -- initialize set size
    log_message('10.60 : Initialize set size ');
    pa_cc_gl_trans_ccds.G_EI_Set_Size := fnd_profile.value('PA_NUM_EXP_ITEMS_PER_SET');

    select set_of_books_id
    into G_Current_SOB_Id
    from pa_implementations;

    reset_curr_function;

EXCEPTION

  WHEN OTHERS THEN
     reset_curr_function;
     RAISE ;

END TRANSFER_CCDS_INITIALIZE ;

PROCEDURE log_message( p_message IN VARCHAR2) IS
BEGIN

    pa_cc_utils.log_message(p_message);

END log_message;

PROCEDURE set_curr_function(p_function IN VARCHAR2) IS
BEGIN

     pa_cc_utils.set_curr_function(p_function);

END;

PROCEDURE reset_curr_function IS
BEGIN

     pa_cc_utils.reset_curr_function;

END;


END PA_CC_GL_TRANS_CCDS;

/
