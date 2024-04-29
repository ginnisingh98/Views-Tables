--------------------------------------------------------
--  DDL for Package Body PA_PURGE_VALIDATE_ICIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_VALIDATE_ICIP" as
/* $Header: PAICIPVB.pls 120.2 2005/08/19 16:34:27 mwasowic noship $ */

 Function Is_InterPrj_Provider_Project ( p_project_id      in NUMBER )
 Return VARCHAR2  is

      cursor ISInterPrjRPrvdrPrj is
      select 'This is an Inter-Project Provider Project'
        from dual
       where exists ( select NULL
                        from pa_project_customers ppc
                       where ppc.project_id = p_project_id
                         and ppc.bill_another_project_flag = 'Y'
                         and ppc.receiver_task_id is not null
                    );

   l_dummy VARCHAR2(100);

 Begin

     Open ISInterPrjRPrvdrPrj;
     Fetch ISInterPrjRPrvdrPrj into l_dummy;

     IF ISInterPrjRPrvdrPrj%NOTFOUND then
        Close ISInterPrjRPrvdrPrj;
         RETURN 'N';
     END IF;

     If l_dummy is not null then
        Close ISInterPrjRPrvdrPrj;
         RETURN 'Y';
     End If;

 EXCEPTION
  WHEN OTHERS THEN
       RETURN 'N';

 END Is_InterPrj_Provider_Project;


 Function Is_InterPrj_Receiver_Project ( p_project_id    in NUMBER )
 Return VARCHAR2  is

      cursor ISInterPrjRecvPrj IS
      select 'This is an Inter-Project Receiver Project'
        from dual
       where exists ( select NULL
                        from pa_tasks pt
                       where pt.project_id = p_project_id
                         and pt.receive_project_invoice_flag = 'Y'
                         and exists ( select NULL
                                      from   pa_project_customers ppc
                                      where  ppc.receiver_task_id = pt.task_id )
                    );

   l_dummy VARCHAR2(100);

 Begin

     Open ISInterPrjRecvPrj;
     Fetch ISInterPrjRecvPrj into l_dummy;

     IF ISInterPrjRecvPrj%NOTFOUND then
        Close ISInterPrjRecvPrj;
         RETURN 'N';
     END IF;

     If l_dummy is not null then
        Close ISInterPrjRecvPrj;
         RETURN 'Y';
     End If;

 EXCEPTION
  WHEN OTHERS THEN
       RETURN 'N';

 END Is_InterPrj_Receiver_Project;


-- Start of comments
-- API name         : validate_IC
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is for the Intercompany Billing validations.
--
-- Parameters       : p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_txn_to_date			IN     DATE,
--                              If the purging is being done on projects
--                              that are active then this parameter is
--                              determine the date to which the transactions
--                              need to be purged.
--		      p_active_flag			IN    VARCHAR2,
--                              The flag to specify purging is done on
--                              open or closed projects.
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
-- End of comments

 procedure Validate_IC (
			p_project_id                     in NUMBER,
                        p_txn_to_date                    in DATE,
                        p_active_flag                    in VARCHAR2,
                        x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_err_stage                      in OUT NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
 is

/*** In part III of archive purge, projects with intercompany transactions are to be
     purged. Hence check for the existence of any EIs with cross charge code 'I' and
     draft invoices are not yet generated. ***/

  cursor  IsIntercompany_InvGen is
      select 'INTERCOMPANY INV NOT GENERATED'
        from dual
      where exists (
               select ei.expenditure_item_id
               from pa_expenditure_items_all ei,
                    pa_tasks t
               where ei.task_id = t.task_id
                 and t.project_id = p_project_id
                 and ei.cc_cross_charge_code = 'I'
                 and ( p_active_flag <> 'A'
                    or ei.expenditure_item_date < p_txn_to_date  )
        /*
                 and not exists ( select null
                                from pa_draft_invoice_details_all di
                               where di.cc_project_id = p_project_id
                                 and di.expenditure_item_id = ei.expenditure_item_id
                             )
         */
		 and ei.cc_ic_processed_code <> 'Y'  /* Bug#2423804 changed the '=' to '<>'  */
                   );

/*  To purge any project that has Cross charged transactions we need to ensure that transactions
    are fully processed.

    Cross Charged transactions are fully processed, which necessarily means

    1. All the check required for regular transactions are met (Such as Costs / revenues accepted
       in General Ledger , Invoices to Receivables etc), which are already in place.
    2. Expenditure Item is Borrowed and Lent Distributed (If applicable) and interfaced to and
       accepted in General Ledger.
    3. Expenditure Item is Intercompany Invoiced (If Applicable) and this Inter Company Invoice is
       Interfaced to Accounts Receivables and Tied back to Projects. Also such interfaced invoices
       are transferred successfully to Payables.
*/

/* Bug#2423804 Joined the project_id of pa_draft_invoices_all and pa_draft_invoice_details_all
   instead of cc_project_id as the cc_project_id in pa_draft_invoices_all is populated as 0.
   Also, the comparision of di.cc_project_id = p_project_id is changed as
   did.cc_project_id = p_project_id.
   These change is done in the cursors IsIcInv_Transferred_to_AR and IsIcInv_Accepted_in_AP  */

  cursor  IsIcInv_Transferred_to_AR is
    select 'IC INV NOT TIEDBACK SUCCESSFULLY'
      from dual
     where exists (
             select null
               from pa_expenditure_items_all ei,
                    pa_tasks t
              where ei.task_id = t.task_id
                and t.project_id = p_project_id
                and ei.cc_cross_charge_code = 'I'
                and ei.cc_ic_processed_code = 'Y'
                and ei.cc_rejection_code is NULL
                and ( p_active_flag <> 'A'
                    or ei.expenditure_item_date < p_txn_to_date  )
                and exists ( select null
                                   from pa_draft_invoices_all di,
                                        pa_draft_invoice_details_all did
                                  where did.cc_project_id = p_project_id
                                    and did.project_id = di.project_id
				    and di.draft_invoice_num = did.draft_invoice_num
                                    and did.expenditure_item_id = ei.expenditure_item_id
                                    and di.transfer_status_code <> 'A'
                               )
                   );

  cursor  IsIcInv_Accepted_in_AP is
    select 'IC INV NOT ACCEPTED IN AP'
     from dual
     where exists (
             select null
               from pa_expenditure_items_all ei,
                    pa_tasks t
              where ei.task_id = t.task_id
                and t.project_id = p_project_id
                and ei.cc_cross_charge_code = 'I'
                and ei.cc_ic_processed_code = 'Y'
                and ei.cc_rejection_code is NULL
                and ( p_active_flag <> 'A'
                    or ei.expenditure_item_date < p_txn_to_date  )
                and exists ( select null
                                   from pa_draft_invoices_all di,
                                        pa_draft_invoice_details_all did
                                  where did.cc_project_id = p_project_id
                                    and did.project_id = di.project_id
                                    and did.expenditure_item_id = ei.expenditure_item_id
				    and di.draft_invoice_num = did.draft_invoice_num
                                    and di.transfer_status_code = 'A'
                                    and not exists ( select null
                                                       from ap_invoices_all ap
                                                      where ap.invoice_num = di.ra_invoice_number
                                                    )
                               )
                   );


      l_err_code         NUMBER ;
      l_err_stack_old    VARCHAR2(2000);
      l_err_stack        VARCHAR2(2000);
      l_err_stage        VARCHAR2(500);
      l_dummy            VARCHAR2(500);

      l_old_err_stage     VARCHAR2(500);
      l_old_err_code      number;

 BEGIN
     l_err_code  := 0 ;
     l_err_stack_old := x_err_stack;


     /* ATG changes */
      l_old_err_stage   := x_err_stage ;
      l_old_err_code    := x_err_code ;

     pa_debug.debug(' -- Performing Inter Company validation for project '||to_char(p_project_id));

    -- Check whether the intercompany invoice is generated or not

    Open IsIntercompany_InvGen;
    Fetch IsIntercompany_InvGen into l_dummy;
    If l_dummy is not null then
       fnd_message.set_name('PA','PA_ARPR_IC_INV_NOT_GEN');
       fnd_msg_pub.add;
       l_err_code  := 10;
       l_err_stage := 'After intercompany check ';
       l_err_stack := l_err_stack|| ' -> After intercompany check';
       pa_debug.debug('    * Intercompany Invoice is not Generated for the project '||
                      to_char(p_project_id));
    End If;
    Close IsIntercompany_InvGen;
    l_dummy := NULL;

    -- Check whether the intercompany invoice is successfully tied-back from AR

    Open IsIcInv_Transferred_to_AR;
    Fetch IsIcInv_Transferred_to_AR into l_dummy;
    If l_dummy is not null then
       fnd_message.set_name('PA','PA_ARPR_IC_INV_NOT_TIEDBACK');
       fnd_msg_pub.add;
       l_err_code  := 10;
       l_err_stage := 'After intercompany check ';
       l_err_stack := l_err_stack|| ' -> After intercompany check';
       pa_debug.debug('    * Intercompany Invoice is not Tiedback from AR for the project '||
                      to_char(p_project_id));
    End If;
    Close IsIcInv_Transferred_to_AR;
    l_dummy := NULL;

    -- Check whether the intercompany invoice is successfully accepted in AP

    Open IsIcInv_Accepted_in_AP;
    Fetch IsIcInv_Accepted_in_AP into l_dummy;
    If l_dummy is not null then
       fnd_message.set_name('PA','PA_ARPR_IC_INV_NOT_IN_AP');
       fnd_msg_pub.add;
       l_err_code  := 10;
       l_err_stage := 'After intercompany check ';
       l_err_stack := l_err_stack|| ' -> After intercompany check';
       pa_debug.debug('    * Intercompany Invoice is not Successfully Accepted in AP for the project '||
                      to_char(p_project_id));
    End If;
    Close IsIcInv_Accepted_in_AP;
    l_dummy := NULL;


     x_err_code  := l_err_code ;
     x_err_stage := l_err_stage ;
     x_err_stack := l_err_stack_old ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE_ICIP.VALIDATE_IC' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);

    /* ATG Changes */
      x_err_stack := l_err_stack_old ;
      x_err_stage   := l_old_err_stage ;
      x_err_code    := l_old_err_code ;

    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END Validate_IC ;


-- Start of comments
-- API name         : validate_IP_Prvdr
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is for the Interproject Billing validations.
--
-- Parameters       : p_project_Id                      IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--                    p_txn_to_date                     IN     DATE,
--                              If the purging is being done on projects
--                              that are active then this parameter is
--                              determine the date to which the transactions
--                              need to be purged.
--                    p_active_flag                     IN    VARCHAR2,
--                              The flag to specify purging is done on
--                              open or closed projects.
--                    X_Err_Stack                       IN OUT VARCHAR2,
--                              Error stack
--                    X_Err_Stage                       IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--                    X_Err_Code                        IN OUT NUMBER
--                              Error code returned from the procedure
-- End of comments

 PROCEDURE Validate_IP_Prvdr (
                        p_project_id                     in NUMBER,
                        p_txn_to_date                    in DATE,
                        p_active_flag                    in VARCHAR2,
                        x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_err_stage                      in OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
 IS


 /*  A provider project is a 'CONTRACT' project that performs work on behalf of another
     (receiver) project so, no txn_to_date checking */

 /*  To Purge any Provider Project which has Inter-Project billing set-up attached (Bill to
     Another Project set to Yes and receiver Task is identified), we need to ensure that the
     transaction is fully processed.

     Expenditure Item is fully processed, which necessarily means

     1. All the check required for regular transactions are met (Such as Costs / revenues accepted
        in GL, Invoices to receivables etc), which are already in place.
     2. For Provider Project, Draft Invoice of provider project is interfaced to Receivables and
        transferred to Payables as a supplier invoice cost for Receiver Project.

     Once both the above mentioned steps are performed, core Archive/Purge functionality in
     place will take care of rest of the validations, as this Supplier Invoice will be visible as
     a commitment for the receiver project.
 */

    cursor IsIpInv_Transferred_to_AR is
    select 'IP INV NOT TIEDBACK SUCCESSFULLY'
      from dual
     where exists (
             select null
               from pa_draft_invoices_all di,
                    pa_project_customers ppc,
                    pa_agreements_all pag
              where di.project_id = p_project_id
		and di.agreement_id = pag.agreement_id
		and pag.customer_id = ppc.customer_id
	        and di.project_id = ppc.project_id
		and ppc.bill_another_project_flag = 'Y'
		and ppc.receiver_task_id IS NOT NULL
                and di.transfer_status_code <> 'A'
                   );

    cursor IsIpInv_Accepted_in_AP is
    select 'IP INV NOT ACCEPTED IN AP'
      from dual
     where exists (
             select null
               from pa_draft_invoices_all di,
                    pa_project_customers ppc,
		    pa_agreements_all pag
              where di.project_id = p_project_id
	        and di.project_id = ppc.project_id
	        and di.agreement_id = pag.agreement_id
		and pag.customer_id = ppc.customer_id
		and ppc.bill_another_project_flag = 'Y'
		and ppc.receiver_task_id IS NOT NULL
                and di.transfer_status_code ='A'
		and not exists ( select null
		                   from ap_invoices_all ap
				  where ap.invoice_num = di.ra_invoice_number
			       )
                   );


      l_err_code         NUMBER ;
      l_err_stack_old    VARCHAR2(2000);
      l_err_stack        VARCHAR2(2000);
      l_err_stage        VARCHAR2(500);
      l_dummy            VARCHAR2(500);

  l_old_err_stage     VARCHAR2(500);
  l_old_err_code      number;


 BEGIN

     l_err_code  := 0 ;
     l_err_stack_old := x_err_stack;


    /* ATG changes */
      l_old_err_stage   := x_err_stage ;
      l_old_err_code    := x_err_code ;


     pa_debug.debug(' -- Performing Inter Project validation for provider project '||
                        to_char(p_project_id));

      -- Check whether the interproject invoice is successfully tied-back from AR

     Open IsIpInv_Transferred_to_AR;
     Fetch IsIpInv_Transferred_to_AR into l_dummy;

     If l_dummy is not null then
        fnd_message.set_name('PA','PA_ARPR_IP_INV_NOT_TIEBACK');
        fnd_msg_pub.add;
        l_err_code  := 10;
        l_err_stage := 'After interproject check ';
        l_err_stack := l_err_stack|| ' -> After interproject check';
        pa_debug.debug(' * Interproject Invoice is not Tiedback from AR for the project '||
        		   to_char(p_project_id));
     End If;

     Close IsIpInv_Transferred_to_AR;
     l_dummy := NULL;


      -- Check whether the interproject invoice is successfully accepted in AP

     Open IsIpInv_Accepted_in_AP;
     Fetch IsIpInv_Accepted_in_AP into l_dummy;

     If l_dummy is not null then
        fnd_message.set_name('PA','PA_ARPR_IP_INV_NOT_IN_AP');
        fnd_msg_pub.add;
        l_err_code  := 10;
        l_err_stage := 'After interproject check ';
        l_err_stack := l_err_stack|| ' -> After interproject check';
        pa_debug.debug(' * Interproject Invoice is not Successfully Accepted in AP for the project '||
			  to_char(p_project_id));
     End If;

     Close IsIpInv_Accepted_in_AP;
     l_dummy := NULL;

     x_err_code  := l_err_code ;
     x_err_stage := l_err_stage ;
     x_err_stack := l_err_stack_old ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE_ICIP.VALIDATE_IP_PRVDR' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);

    /* ATG Changes */
      x_err_stack := l_err_stack_old ;
      x_err_stage   := l_old_err_stage ;
      x_err_code    := l_old_err_code ;




    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END Validate_IP_Prvdr ;


-- Start of comments
-- API name         : validate_IP_Rcvr
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is for the Interproject Billing validations.
--
-- Parameters       : p_project_Id                      IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--                    p_txn_to_date                     IN     DATE,
--                              If the purging is being done on projects
--                              that are active then this parameter is
--                              determine the date to which the transactions
--                              need to be purged.
--                    p_active_flag                     IN    VARCHAR2,
--                              The flag to specify purging is done on
--                              open or closed projects.
--                    X_Err_Stack                       IN OUT VARCHAR2,
--                              Error stack
--                    X_Err_Stage                       IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--                    X_Err_Code                        IN OUT NUMBER
--                              Error code returned from the procedure
-- End of comments

 PROCEDURE Validate_IP_Rcvr (
                        p_project_id                     in NUMBER,
                        x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_err_stage                      in OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
 IS


 /* To purge Receiver Project (in the case of interProject Billing Set-up), all associated
    Provider Projects must be Purged (rest all other validation checks remains the same). */

 /*  cursor to get all the provider projects associated with the given receiver project */

      cursor c_provider_projects is
      select ppc.project_id
        from pa_project_customers ppc
       where ppc.bill_another_project_flag = 'Y'
         and ppc.receiver_task_id is not null
	 and ppc.customer_bill_split <> 0     /* Bug#2429956  */
         and ppc.receiver_task_id in ( select task_id
                                         from pa_tasks pt
                                        where pt.project_id = p_project_id);

      l_err_code         NUMBER ;
      l_err_stack_old    VARCHAR2(2000);
      l_err_stack        VARCHAR2(2000);
      l_err_stage        VARCHAR2(500);

      l_project_status_code  pa_projects_all.project_status_code%TYPE;

  l_old_err_stage     VARCHAR2(500);
  l_old_err_code      number;



 BEGIN

     l_err_code  := 0 ;
     l_err_stack_old := x_err_stack;

     /* ATG changes */
      l_old_err_stage   := x_err_stage ;
      l_old_err_code    := x_err_code ;


     FOR c_prvdr_prj_rec in c_provider_projects LOOP

         select project_status_code
           into l_project_status_code
           from pa_projects_all
          where project_id = c_prvdr_prj_rec.project_id;

      if pa_project_stus_utils.is_project_in_purge_status( l_project_status_code ) <> 'Y' then

       /* A provider to the given receiver project can again be a receiver project. So, checking
          for existance of any provider projects if it is a receiver project by calling the
          procedure Validate_IP_Rcvr recursively  */

       if Is_InterPrj_Receiver_Project(c_prvdr_prj_rec.project_id) = 'Y' then

          Validate_IP_Rcvr(c_prvdr_prj_rec.project_id,
                           x_err_code,
                           x_err_stack,
                           x_err_stage );

         if pa_project_stus_utils.is_project_in_purge_status( l_project_status_code ) <> 'Y'
         then

          if g_insert_errors_no_duplicate = 'N' then  /* Bug#2431705  */

            fnd_message.set_name('PA','PA_ARPR_PRVDR_NOT_PURGED');
            fnd_msg_pub.add;
            l_err_code  := 10;
            l_err_stage := 'After interproject receiver check ';
            l_err_stack := l_err_stack|| ' -> After interproject receiver check';
            pa_debug.debug(' * Provider project is not purged corresponding to the receiver project '||
                            to_char(p_project_id));

          end if;

	  g_insert_errors_no_duplicate := 'Y';  /* Bug# 2431705  */

         EXIT;

         end if;

       else

         if pa_project_stus_utils.is_project_in_purge_status( l_project_status_code ) <> 'Y'
         then

          if g_insert_errors_no_duplicate = 'N' then   /* Bug# 2431705 */

	     fnd_message.set_name('PA','PA_ARPR_PRVDR_NOT_PURGED');
             fnd_msg_pub.add;
	     l_err_code  := 10;
	     l_err_stage := 'After interproject receiver check ';
  	     l_err_stack := l_err_stack|| ' -> After interproject receiver check';
             pa_debug.debug(' * Provider project is not purged corresponding to the receiver project '||
	  		    to_char(p_project_id));

  	  end if;

	  g_insert_errors_no_duplicate := 'Y';  /* Bug# 2431705  */

         EXIT;

	 end if;

       end if;

      end if;

     END LOOP;

     x_err_code  := l_err_code ;
     x_err_stage := l_err_stage ;
     x_err_stack := l_err_stack_old ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_VALIDATE_ICIP.VALIDATE_IP_Rcvr' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    /* ATG Changes */
      x_err_stack := l_err_stack_old ;
      x_err_stage   := l_old_err_stage ;
      x_err_code    := l_old_err_code ;


    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

 END Validate_IP_Rcvr ;



-- API name         : Validate_IC_IP
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This is the main procedure for the Intercompany and Interproject
--                    (only for Provider Project) Billing  validations.


 PROCEDURE Validate_IC_IP (
                           p_project_id                     in NUMBER,
                           p_txn_to_date                    in DATE,
                           p_active_flag                    in VARCHAR2,
                           x_err_code                       in OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_err_stage                      in OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
 IS

 BEGIN

      /* Validate Intercompany receiver projects  */

               Validate_IC (
                        p_project_id,
                        p_txn_to_date,
                        p_active_flag,
                        x_err_code,
                        x_err_stack,
                        x_err_stage );

     /* Validate interproject provider projects  */

   if Is_InterPrj_Provider_Project(p_project_id) = 'Y' then

               Validate_IP_Prvdr (
                        p_project_id,
                        p_txn_to_date,
                        p_active_flag,
                        x_err_code,
                        x_err_stack,
                        x_err_stage );

   end if;

  /* If any of the Project which is a Receiver Project (InterProject Setup) is pulled in purge batch,
     we will NOT pull associated provider projects programmatically. But the code will Invalidate the
     batch prompting user to pull all associated un-purged provider projects in the same batch or to
     remove receiver project from the batch to make the batch valid for purge.
     To implement the above logic with the receiver project and provider projects are in the same
     purge batch, the Interproject receiver project validation is called after all the regular
     checks are completed in pa_purge_validate.BatchVal.
     Individually receiver and provider projects can be valid for regular checks but after the
     receiver project validation, the receiver project can be invalid incase,
      1. if any of its provider projects which is not in purge status and is not included in the
         purge batch  or
      2. included in the purge batch but is invalid for regular checks
  */


 END Validate_IC_IP;

END ;

/
