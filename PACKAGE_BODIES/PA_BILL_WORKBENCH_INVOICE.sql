--------------------------------------------------------
--  DDL for Package Body PA_BILL_WORKBENCH_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILL_WORKBENCH_INVOICE" AS
/*$Header: PABWINVB.pls 120.5 2005/11/23 22:48:10 rkchoudh noship $ */



 PROCEDURE get_inv_global_value(p_project_id                    IN   NUMBER,
                                p_draft_inv_num                 IN   NUMBER,
                                x_mcb_flag                      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_user_id                       OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_login_id                      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_person_id                     OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_yes_m                         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_no_m                          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_na_m                          OUT  NOCOPY VARCHAR2,                           --File.Sql.39 bug 4440895
                                x_employee_name                 OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                X_fs_approve                    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                X_prj_closed_flag               OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_dist_warn_flag                OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_org_id                        OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_multi_cust_flag 	        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status                 OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                     OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data                      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ) IS


l_project_status_code      VARCHAR2(30);

l_emp_not_found           EXCEPTION;

l_warning_count           NUMBER;
l_related_inv_num         VARCHAR2(30) := NULL;
l_dummy                   NUMBER;

/*
Cursor related_Inv_Cur is
       select to_char(draft_invoice_num) draft_inv_num
         FROM pa_draft_invoices_all
        WHERE project_id = P_Project_ID
          AND invoice_set_id = (select invoice_set_id from
                  pa_draft_invoices_all
                 where draft_invoice_num = p_draft_inv_num
                 and project_id = p_project_id)
          and nvl(customer_bill_split,0) not in (0,100);
*/

BEGIN



     x_return_status    := FND_API.G_RET_STS_SUCCESS;
     x_msg_count        := 0;
     x_msg_data         := NULL;


    /* -----------------------------------------
        Get the value from pa_projects table
       ----------------------------------------- */

        SELECT nvl(multi_currency_billing_flag, 'N'),
               nvl(org_id, -99)
         INTO  x_mcb_flag,
               x_org_id
         FROM  pa_projects_all
        WHERE  project_id = p_project_id;


   /* ------------------------------------------------------------
      Get the project closed flag based on the project status code
      ------------------------------------------------------------ */


       x_prj_closed_flag := 'N';



   /* -------------------------------------------------------
      Get the User Id and the login id from the FND profile
      ------------------------------------------------------- */




      BEGIN

        x_user_id  := fnd_profile.value ('USER_ID');
        x_login_id := fnd_profile.value('LOGIN_ID');


       EXCEPTION
             WHEN OTHERS THEN
             /* ATG NOCOPY changes */
             x_user_id    := null;
             x_login_id   := null;


             RAISE l_emp_not_found;

      END;


    /* -----------------------------------------
      Get the meaning of Yes/No Lookup value
       ----------------------------------------- */



          SELECT meaning
            INTO x_yes_m
            FROM fnd_lookups
           WHERE lookup_type = 'YES_NO'
             AND lookup_code = 'Y';

          SELECT meaning
            INTO x_no_m
            FROM fnd_lookups
           WHERE lookup_type = 'YES_NO'
             AND lookup_code = 'N';




     /* ------------------------------------------
         Get the Emplpyee Name and Person Id
        ------------------------------------------ */


       BEGIN

           SELECT employee_id
             INTO x_person_id
             FROM fnd_user
            WHERE user_id  = x_user_id;

           SELECT full_name
             INTO x_employee_name
             FROM pa_employees
            WHERE  person_id = x_person_id;

         EXCEPTION
             WHEN NO_DATA_FOUND THEN

              /* ATG changes */
              x_person_id := null;
              x_employee_name := null;

             RAISE l_emp_not_found;

       END;


    /* ------------------------------------------------------
       Get the Function security of the invoice action
       ------------------------------------------------------*/


        IF (fnd_function.test('PA_PAXINRVW_APPROVE') = TRUE) THEN
            x_fs_approve := 'Y';
        ELSE
            x_fs_approve := 'N';
        END IF;


     /* -----------------------------------------------------------
        Get the distribution warning flag (if any any warning set for
        this project
        ------------------------------------------------------------ */


         SELECT count(*)
          INTO  l_warning_count
          FROM  pa_distribution_warnings
         WHERE  project_id = p_project_id
          AND   draft_invoice_num = p_draft_inv_num;


           IF (l_warning_count = 0) then
              x_dist_warn_flag := 'N';
           else
              x_dist_warn_flag := 'Y';
           END IF;


     /* -----------------------------------------------------------
        Get the meaning for Not Applicable
        ------------------------------------------------------------ */


         SELECT meaning
           INTO x_na_m
           FROM pa_lookups
          WHERE lookup_type = 'PA_BILL_WRKBNCH_NA'
            AND lookup_code = 'N_A';



     /* -----------------------------------------------------------
        Get related invoices - invoice number
        ------------------------------------------------------------ */
/*
     for related_inv_rec  in related_inv_cur loop

          if l_related_inv_num is not null then
             l_related_inv_num := l_related_inv_num ||',';
          end if;
           l_related_inv_num := l_related_inv_num || trim(related_inv_rec.draft_inv_num);
     end loop;

    x_related_inv_num := l_related_inv_num;
*/

   /* check for multi customer invoices */

    SELECT count(*)
      INTO l_dummy
      FROM PA_Draft_Invoices_ALL i
     WHERE i.invoice_set_id    =  (select invoice_set_id from pa_draft_invoices_all
                                   where project_id = p_project_id
                                   and draft_invoice_num = p_draft_inv_num)
       AND i.customer_bill_split not in (0, 100)
       AND i.approved_date is null
       and i.project_id = p_project_id;

    IF (l_dummy > 1) THEN
      X_multi_cust_flag := 'Y';
    else
      X_multi_cust_flag := 'N';

    END IF;

 EXCEPTION
    WHEN l_emp_not_found THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_count := 1;
         x_msg_data := 'PA_ALL_WARN_NO_EMPL_REC';

    WHEN OTHERS THEN
              x_mcb_flag       := null;
              x_user_id        := null;
              x_login_id       := null;
              x_person_id      := null;
              x_yes_m          := null;
              x_no_m           := null;
              x_na_m             := null;
              x_employee_name    := null;
              X_fs_approve         := null;
              X_prj_closed_flag    := null;
              x_dist_warn_flag     := null;
              x_org_id             := null;
              x_multi_cust_flag    := null;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data := SUBSTR(SQLERRM,1,100);

END get_inv_global_value;




PROCEDURE Approve_info_commit
                           ( p_project_id            IN   NUMBER,
                             p_draft_invoice_num     IN   NUMBER,
                             P_user_id               IN   NUMBER,
                             p_person_id             IN   NUMBER,
                             p_login_id              IN   NUMBER,
                             x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count             OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           ) IS


l_approved_date            date;


BEGIN


    x_return_status    := FND_API.G_RET_STS_SUCCESS;
    x_msg_count        := 0;
    x_msg_data         := NULL;


    /* -----------------------------------------------------------------------------
       get the approved date if the approved date is not null then raise the error
       otherwise approve the invoice.
       ------------------------------------------------------- */


        SELECT approved_date
          INTO l_approved_date
          FROM pa_draft_invoices_all
         WHERE project_id = p_project_id
           AND draft_invoice_num = p_draft_invoice_num;


    /* -------------------------------------------------------
       Update Approve Information to the invoice header table
       ------------------------------------------------------- */


    IF (l_approved_date is null ) THEN

       UPDATE pa_draft_invoices_all
          SET last_update_date    =  sysdate,
              Last_updated_by     =  p_user_id,
              last_update_login   =  p_login_id,
              approved_date       =  TRUNC(sysdate),
              approved_by_person_id = p_person_id
        WHERE project_id = p_project_id
          AND draft_invoice_num = p_draft_invoice_num ;

    ELSE

          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_data := 'PA_XC_RECORD_CHANGED';
          x_msg_count := 1;

    END IF;



 EXCEPTION
     WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data := SUBSTR(SQLERRM,1,100);

END Approve_info_commit;


 PROCEDURE Get_invoice_mode
                           ( p_project_id            IN   NUMBER,
                             p_draft_invoice_num     IN   NUMBER,
                             p_inv_line_num          IN   NUMBER,
                             p_event_task_id         IN   NUMBER,
                             p_event_num             IN   NUMBER,
                             p_retn_inv_flag         IN   VARCHAR2,
                             p_inv_items_line_type   IN   VARCHAR2,
                             x_invoice_mode          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count             OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           )  IS


l_event_type          varchar2(30) ;

BEGIN


   l_event_type := null;


    x_return_status    := FND_API.G_RET_STS_SUCCESS;
    x_msg_count        := 0;
    x_msg_data         := NULL;



    IF  (NVL(p_retn_inv_flag,'N')  = 'Y' ) THEN

         x_invoice_mode := 'RETENTION';

    ELSE

        IF ((p_event_num IS NOT NULL) AND (NVL(p_inv_items_line_type,'A') <> 'RETENTION')) THEN

           /* Get the event Type from event type classification */

                SELECT et.event_type_classification
                  INTO l_event_type
		  FROM pa_event_types et, pa_events ev
		 WHERE et.event_type = ev.event_type
		   AND ev.project_id = p_project_id
		   AND ev.event_num  = p_event_num
		   AND nvl(ev.task_id,0) = nvl(p_event_task_id,0);


                 IF (l_event_type = 'SCHEDULED PAYMENTS') THEN

                      x_invoice_mode := 'FROM-EI';

                 ELSE

                      x_return_status := FND_API.G_RET_STS_ERROR;
                      x_msg_count     := 1;
                      x_msg_data      := 'PA_IN_NO_FIFO_ITEMS';

                 END IF;

        ELSE


                IF (nvl(p_inv_items_line_type, 'A')  <> 'RETENTION') THEN

                       x_invoice_mode := 'FROM-RDL';

                ELSE

                       x_invoice_mode := 'FROM-RDL-RETN';

                END IF;

        END IF;


     END IF;


 EXCEPTION
     WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data := SUBSTR(SQLERRM,1,100);

END Get_invoice_mode;


 Procedure Validate_Approval ( P_Project_ID         in  number,
                               P_Draft_Invoice_Num  in  number,
                               P_Validation_Level   in  varchar2,
                               X_Error_Message_Code out NOCOPY varchar2 ) is --File.Sql.39 bug 4440895

     l_customer_id            pa_draft_invoices_v.customer_id%TYPE;
     l_generation_error_flag  pa_draft_invoices_v.generation_error_flag%TYPE;
     l_approved_date          pa_draft_invoices_v.approved_date%TYPE;
     l_project_status_code    pa_draft_invoices_v.project_status_code%TYPE;
     l_dummy                  number;
     l_err_msg_code           varchar2(30);

     Cursor Inv_Cur is

       SELECT i.customer_id, i.generation_error_flag,
              i.approved_date , p.project_status_code
         FROM pa_draft_invoices_all i, /* changed the refrence to base table instead of pa_draft_invoices_all_v for bug # 4666256 */
	      pa_projects_all p       /* added the refrence to pa_projects_all for project_status_code */
        WHERE i.project_id = P_Project_ID
          AND p.project_id = i.project_id
          AND i.draft_invoice_num = P_Draft_Invoice_Num;

/*  Commented and rewritten for tCA changes
       Cursor Cust_Cur is
       SELECT 1
         FROM RA_CUSTOMERS
        WHERE customer_id = l_customer_id
          AND NVL(status, 'A') <> 'A'
          AND customer_prospect_code = 'CUSTOMER'; */

     Cursor Cust_Cur is
       SELECT 1
         FROM HZ_CUST_ACCOUNTS
        WHERE cust_account_id = l_customer_id
          AND NVL(status, 'A') <> 'A';

  BEGIN
    -- Reset Output Parameters
    X_Error_Message_Code := NULL;

    IF P_Validation_Level = 'R' THEN         /* Record Level Validation */

      OPEN Inv_Cur;
      FETCH Inv_Cur into l_customer_id,  l_generation_error_flag,
                         l_approved_date,l_project_status_code;
      CLOSE Inv_Cur;

      /* Check Project Status */
      /* Remove Project Status Check as discussed
      IF (PA_Project_Stus_Utils.Is_Project_Status_Closed(l_project_status_code)
                                          = 'Y') THEN
        X_Error_Message_Code := 'PA_EX_CLOSED_PROJECT';
        GOTO all_done;
      END IF;*/

      /* Bug#1499480:Check whether action 'GENERATE_INV' is enabled for Project Status */
      IF (PA_Project_Utils.Check_Prj_Stus_Action_Allowed(l_project_status_code,'GENERATE_INV')
                                          = 'N') THEN
        X_Error_Message_Code := 'PA_INV_ACTION_INVALID';
        GOTO all_done;
      END IF;

      /* Check Generation Error */
      IF (l_generation_error_flag = 'Y') THEN
        X_Error_Message_Code := 'PA_IN_NO_APP_GEN_ERR';
        GOTO all_done;
      END IF;

      /* Check Invoice Status */
      IF (l_approved_date is not NULL) THEN
        X_Error_Message_Code := 'PA_IN_ALREADY_APPROVED';
        GOTO all_done;
      END IF;

      /* Check Customer Status */
      l_dummy := 0;
      OPEN Cust_Cur;
      Fetch Cust_Cur into l_dummy;
      CLOSE Cust_Cur;

      IF (l_dummy > 0) THEN
        X_Error_Message_Code := 'PA_EX_INACTIVE_CUSTOMER';
        GOTO all_done;
      END IF;


    ELSIF P_Validation_Level = 'C' THEN      /* Commit Level Validation */

      NULL;

    END IF;   /* Validation Level Checks */

    <<all_done>>
      NULL;

  EXCEPTION
    WHEN OTHERS THEN
         X_Error_Message_Code := NULL;
        RAISE;

END Validate_Approval;



PROCEDURE validate_multi_Customer ( P_Invoice_Set_ID     in  number,
                                    X_Error_Message_Code out NOCOPY varchar2) IS --File.Sql.39 bug 4440895


  l_dummy number;

  BEGIN

    X_Error_Message_Code := NULL;
    l_dummy := 0;

    SELECT count(*)
      INTO l_dummy
      FROM PA_Draft_Invoices_ALL i
     WHERE i.invoice_set_id    = P_Invoice_Set_ID
       AND i.customer_bill_split not in (0, 100)
       AND i.approved_date is null;

    IF (l_dummy > 1) THEN
      X_Error_Message_Code := 'PA_INV_APPROVE_MULTI_CUST';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

       /* ATG Changes */
       X_Error_Message_Code := NULL;
      RAISE;

END validate_multi_Customer;

Procedure Validate_multi_invoices (
                 P_Project_ID         in  number,
                 P_invoice_set_id  in  number,
                 P_Validation_Level   in  varchar2,
                 X_Error_Message_Code out NOCOPY varchar2 ) is --File.Sql.39 bug 4440895

     l_inactive_customer      number;
     l_err_msg_code           varchar2(30);
     l_fst_flag               varchar2(1);

     Cursor Inv_Cur is
       SELECT project_id, draft_invoice_num, customer_id, approved_date
          FROM pa_draft_invoices_all		--For Bug 3961053
       --  FROM pa_draft_invoices_all_v		--For Bug 3961053
        WHERE project_id = P_Project_ID
          AND invoice_set_id = P_invoice_set_id
          and nvl(customer_bill_split,0) not in (0,100);

  BEGIN
    -- Reset Output Parameters

    X_Error_Message_Code := NULL;
    l_fst_flag := 'Y';

    IF P_Validation_Level = 'R' THEN         /* Record Level Validation */

       FOR inv_rec IN  Inv_Cur LOOP

           IF l_fst_flag = 'Y' THEN

              l_fst_flag := 'N';
              Validate_Approval ( P_Project_ID  => inv_rec.project_id,
                                  P_Draft_Invoice_Num => inv_rec.draft_invoice_num,
                                  P_Validation_Level  => p_validation_level ,
                                  X_Error_Message_Code => l_err_msg_code);

              if l_err_msg_code is not null then
                 x_error_message_code := l_err_msg_code;
                 exit;
              end if;

           END IF;

           IF inv_rec.approved_date IS NOT NULL THEN
             X_Error_Message_Code := 'PA_IN_ALREADY_APPROVED';
           ELSE
           /* Commented and rewritten for TCA changes
             SELECT count(*) INTO l_inactive_customer FROM ra_customers
             WHERE customer_id = inv_rec.customer_id
             AND NVL(status,'A') <> 'A'
             AND customer_prospect_code = 'CUSTOMER'; */

             SELECT count(*) INTO l_inactive_customer FROM hz_cust_accounts
             WHERE cust_account_id = inv_rec.customer_id
             AND NVL(status,'A') <> 'A';

             IF l_inactive_customer >0 THEN
                 X_Error_Message_Code := 'PA_EX_INACTIVE_CUSTOMER';
             END IF;

           END If;
           IF x_error_message_code IS NOT NULL THEN
             EXIT;
           END IF;
       END LOOP;

    ELSIF P_Validation_Level = 'C' THEN      /* Commit Level Validation */

      NULL;

    END IF;   /* Validation Level Checks */


  EXCEPTION
    WHEN OTHERS THEN

       /* ATG Changes */
       X_Error_Message_Code := NULL;

        RAISE;

END Validate_multi_invoices;


PROCEDURE Approve_multi_commit
                           ( p_project_id            IN   NUMBER,
                             p_invoice_set_id        IN   NUMBER,
                             P_user_id               IN   NUMBER,
                             p_person_id             IN   NUMBER,
                             p_login_id              IN   NUMBER,
                             x_app_draft_num         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count             OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           ) IS


l_approved_count            number;
l_app_draft_num            varchar2(30);

Cursor unappr_cur is
       select draft_invoice_num
         FROM pa_draft_invoices_all
        WHERE project_id = P_Project_ID
          AND invoice_set_id = p_invoice_set_id
          and nvl(customer_bill_split,0) not in (0,100);

BEGIN


    x_return_status    := FND_API.G_RET_STS_SUCCESS;
    x_msg_count        := 0;
    x_msg_data         := NULL;
    x_app_draft_num    := NULL;
    l_app_draft_num    := NULL;



    /* -----------------------------------------------------------------------------
       get the approved date if the approved date is not null then raise the error
       otherwise approve the invoice.
       ------------------------------------------------------- */


        SELECT count(*)
          INTO l_approved_count
          FROM pa_draft_invoices_all
         WHERE project_id = p_project_id
           AND invoice_set_id = p_invoice_set_id
           AND approved_date is not null
           AND nvl(customer_bill_split,0) not in (0,100);


    /* -------------------------------------------------------
       Update Approve Information to the invoice header table
       ------------------------------------------------------- */


    IF (l_approved_count = 0 ) THEN

       for unappr_rec  in unappr_cur loop

           if l_app_draft_num is not null then
              l_app_draft_num := l_app_draft_num ||',';
          end if;
           l_app_draft_num := l_app_draft_num || trim(to_char(unappr_rec.draft_invoice_num));

          UPDATE pa_draft_invoices_all
          SET last_update_date    =  sysdate,
              Last_updated_by     =  p_user_id,
              last_update_login   =  p_login_id,
              approved_date       =  TRUNC(sysdate),
              approved_by_person_id = p_person_id
        WHERE project_id = p_project_id
          AND draft_invoice_num = unappr_rec.draft_invoice_num;
     end loop;
     x_app_draft_num := l_app_draft_num;

    ELSE

          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_data := 'PA_XC_RECORD_CHANGED';
          x_msg_count := 1;

    END IF;



 EXCEPTION
     WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data := SUBSTR(SQLERRM,1,100);

         /* ATG Changes */
         x_app_draft_num    := NULL;
END Approve_multi_commit;

END pa_bill_workbench_invoice;

/
