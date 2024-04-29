--------------------------------------------------------
--  DDL for Package Body PA_INVOICE_ACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INVOICE_ACTIONS" as
/* $Header: PAXVIACB.pls 120.8.12010000.2 2010/03/25 22:07:50 apaul ship $ */

/*----------------- Private Procedure/Function Declarations -----------------*/

/*----------------------------------------------------------------------------+
 | This Private Procedure Update_Approve_Invoices Updates                     |
 | PA_DRAFT_INVOICES_ALL table with invoice approval columns                  |
 +----------------------------------------------------------------------------*/
  Procedure Update_Approve_Invoices ( P_Project_ID         in  number,
                                      P_Draft_Invoice_Num  in  number,
                                      P_User_ID            in  number,
                                      P_Employee_ID        in  number) is
  BEGIN

    UPDATE PA_Draft_Invoices_ALL
       SET Approved_Date         = sysdate,
           Approved_by_person_id = P_Employee_ID,
           Last_Update_Date      = sysdate,
           Last_Updated_By       = P_User_ID
     WHERE Project_ID            = P_Project_ID
       AND Draft_Invoice_Num     = P_Draft_Invoice_Num;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Update_Approve_Invoices;

/*----------------------------------------------------------------------------+
 | This Private Procedure Update_Unapprove_Invoices Updates                   |
 | PA_DRAFT_INVOICES_ALL table with invoice approval columns as NULL          |
 +----------------------------------------------------------------------------*/
  Procedure Update_Unapprove_Invoices ( P_Invoice_Set_ID     in  number,
                                        P_User_ID            in  number) is
  BEGIN

    UPDATE PA_Draft_Invoices_ALL
       SET Approved_Date         = NULL,
           Approved_by_person_id = NULL,
           Released_Date         = NULL,
           Released_by_person_id = NULL,
           RA_Invoice_Number     = NULL,
           Invoice_Date          = NULL,
           Last_Update_Date      = sysdate,
           Last_Updated_By       = P_User_ID
     WHERE Invoice_Set_ID        = P_Invoice_Set_ID;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Update_Unapprove_Invoices;

/*----------------------------------------------------------------------------+
 | This Private Procedure Update_Release_Invoices Updates                     |
 | PA_DRAFT_INVOICES_ALL table with invoice Release attributes                |
 +----------------------------------------------------------------------------*/
  Procedure Update_Release_Invoices ( P_Project_ID               in  number,
                                      P_Draft_Invoice_Num        in  number,
                                      P_RA_Invoice_Date          in  date,
                                      P_RA_Invoice_Num           in  varchar2,
                                      P_User_ID                  in  number,
                                      P_Employee_ID              in  number,
				      P_Credit_Memo_Reason_Code  in  varchar2) is
  BEGIN

    UPDATE PA_Draft_Invoices_ALL
       SET Released_Date           = sysdate,
           Released_by_person_id   = P_Employee_ID,
           RA_Invoice_Number       = P_RA_Invoice_Num,
           Invoice_Date            = P_RA_Invoice_Date,
           Last_Update_Date        = sysdate,
           Last_Updated_By         = P_User_ID,
	   Credit_Memo_Reason_Code = P_Credit_Memo_Reason_Code /* Bug #2728431*/
     WHERE Project_ID              = P_Project_ID
       AND Draft_Invoice_Num       = P_Draft_Invoice_Num;


  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Update_Release_Invoices;


/*----------------------------------------------------------------------------+
 | This Private Procedure Update_Unrelease_Invoices Updates                   |
 | PA_DRAFT_INVOICES_ALL table with invoice Release attributes as NULL        |
 +----------------------------------------------------------------------------*/
  Procedure Update_Unrelease_Invoices ( P_Invoice_Set_ID     in  number,
                                        P_User_ID            in  number) is
  BEGIN

    UPDATE PA_Draft_Invoices_ALL
       SET Released_Date           = NULL,
           Released_by_person_id   = NULL,
           RA_Invoice_Number       = NULL,
           Invoice_Date            = NULL,
           Last_Update_Date        = sysdate,
           Last_Updated_By         = P_User_ID,
           Credit_memo_reason_code = NULL    /*  Bug #2728431*/
     WHERE Invoice_Set_ID        = P_Invoice_Set_ID;


  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Update_Unrelease_Invoices;


/*----------------------------------------------------------------------------+
 | This Private Procedure Insert_Distrbution_Warning Inserts draft Invoice    |
 | distribution warning.                                                      |
 +----------------------------------------------------------------------------*/
  Procedure Insert_Distrbution_Warning ( P_Project_ID         in  number,
                                         P_Draft_Invoice_Num  in  number,
                                         P_User_ID            in  number,
                                         P_Request_ID         in  number,
                                         P_Invoice_Set_ID     in  number,
                                         P_Error_Message_Code in  varchar2) is

    l_error_message   pa_lookups.meaning%TYPE;

  BEGIN

    BEGIN
      SELECT Meaning
        INTO l_error_message
        FROM PA_Lookups
       WHERE Lookup_Type = 'BILLING EXTENSION MESSAGES'
         AND Lookup_Code = P_Error_Message_Code;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_error_message := P_Error_Message_Code;
    END;

    IF (P_Invoice_Set_ID is NULL) THEN

      INSERT INTO PA_DISTRIBUTION_WARNINGS
      (
      PROJECT_ID, DRAFT_INVOICE_NUM, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      CREATION_DATE, CREATED_BY, REQUEST_ID, WARNING_MESSAGE
      )
      VALUES
      (
      P_Project_ID, P_Draft_Invoice_Num, sysdate, P_User_ID,
      sysdate, P_User_ID, P_Request_ID, l_error_message
      );

    ELSE

      INSERT INTO PA_DISTRIBUTION_WARNINGS
      (
      PROJECT_ID, DRAFT_INVOICE_NUM, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      CREATION_DATE, CREATED_BY, REQUEST_ID, WARNING_MESSAGE
      )
      SELECT Project_ID, Draft_Invoice_Num, sysdate, P_User_ID,
             sysdate, P_User_ID, P_Request_ID, l_error_message
        FROM PA_Draft_Invoices_ALL
       WHERE Invoice_Set_ID = P_Invoice_Set_ID;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Insert_Distrbution_Warning;


 /*----------------------------------------------------------------------------+
 |   This Private Procedure Validate_Credit_Memo_Reason validates the          |
 |  credit memo reason_Code                                                    |
 +----------------------------------------------------------------------------*/
 Procedure Validate_Credit_Memo_Reason( P_Project_ID               in  number,
                                        P_Draft_Invoice_Num        in  number,
                                        P_RA_Invoice_Date          in  date,
			                P_Credit_Memo_Reason_Code  in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                                        X_Error_Message_Code       out NOCOPY varchar2) is --File.Sql.39 bug 4440895
 l_Credit_memo_Reason_flag    pa_implementations.credit_Memo_Reason_Flag%TYPE :='N';
 l_credit_memo_exist          VARCHAR2(1):='N';
 l_credit_memo_reason_valid   VARCHAR2(1):='N';
 Cursor Credit_Memo_Reason_Flag is
   SELECT Credit_Memo_Reason_Flag
   FROM pa_implementations;

Cursor Credit_Memo_exist is
  SELECT 'Y'
  FROM dual
  WHERE EXISTS(SELECT draft_invoice_num
               FROM pa_draft_invoices i
               WHERE i.project_id = P_Project_ID
               AND i.draft_invoice_num = P_Draft_Invoice_Num
               AND i.draft_invoice_num_credited IS NOT NULL);

Cursor Credit_Memo_Reason_Valid is
  SELECT 'Y' FROM dual
  WHERE EXISTS( select lookup_code
                from   fnd_lookup_values_vl
                where  lookup_type='CREDIT_MEMO_REASON'
	        and    lookup_code = P_Credit_Memo_Reason_Code
                and    enabled_flag='Y'
                and    P_RA_invoice_date between start_date_active and nvl(end_date_active,P_RA_invoice_date));


BEGIN
  X_Error_Message_Code :=NULL;
  /* Checking the implementation options for Credit Memo Reason Required */
  OPEN Credit_Memo_Reason_Flag;
  FETCH Credit_Memo_Reason_Flag into l_Credit_Memo_Reason_Flag;
  CLOSE Credit_Memo_Reason_Flag;

  /* Checking Whether its a Credit Memo Invoice */
  OPEN Credit_Memo_exist;
  FETCH Credit_Memo_exist into l_Credit_Memo_exist;

  IF Credit_Memo_exist%NOTFOUND then
     l_Credit_Memo_exist := 'N';
  END IF;

  CLOSE Credit_Memo_exist;

  /* Checking Valid Credit Memo Reason Code */
  IF P_Credit_Memo_Reason_Code IS NOT NULL THEN
     OPEN Credit_Memo_Reason_valid;
     FETCH Credit_Memo_Reason_valid into l_Credit_Memo_Reason_valid;
     IF Credit_Memo_Reason_Valid%NOTFOUND then
        l_Credit_Memo_Reason_valid := 'N';
     END IF;
     CLOSE Credit_Memo_Reason_valid;
  END IF;

  IF l_credit_memo_exist ='Y' THEN
     IF l_Credit_Memo_Reason_Flag ='Y' THEN
        IF P_Credit_Memo_Reason_Code IS NOT NULL THEN
           IF l_Credit_Memo_Reason_valid <>'Y' THEN
              X_Error_Message_Code := 'PA_IN_INV_CR_MEMO_REASON';
              RETURN;
           END IF;
        ELSE
           X_Error_Message_Code := 'PA_IN_REQ_CR_MEMO_REASON';
           RETURN;
        END IF;
     ELSE
        IF P_Credit_Memo_Reason_Code IS NOT NULL THEN
           IF l_Credit_Memo_Reason_valid <>'Y' THEN
              X_Error_Message_Code := 'PA_IN_INV_CR_MEMO_REASON';
              RETURN;
           END IF;
        END IF;
     END IF;/* End of l_Credit_Memo_Reason_Flag ='Y'*/

  ELSE
     P_Credit_Memo_Reason_Code:=NULL;
  END IF;/* End of l_credit_memo_exist ='Y'*/

 END Validate_Credit_Memo_Reason;

/*------------- End of Private Procedure/Function Declarations ---------------*/


/*----------------- Public Procedure/Function Declarations -------------------*/

/*----------------------------------------------------------------------------+
 |      For Details/Comments Refer Package Specification Comments             |
 +----------------------------------------------------------------------------*/
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


/* Bug#4940211 - Performance Issue for calling the pa_draft_invoices_v
   Fix : commented the old code and Geting
         the value from pa_project_all and pa_draft_invoices table

     Cursor Inv_Cur is
       SELECT i.customer_id, i.generation_error_flag,
              i.approved_date , i.project_status_code
         FROM pa_draft_invoices_v i
        WHERE i.project_id = P_Project_ID
          AND i.draft_invoice_num = P_Draft_Invoice_Num;
*/

    Cursor Inv_cur is
        SELECT i.customer_id, i.generation_error_flag,
               i.approved_date, prj.project_status_code project_status_code
         FROM  pa_draft_invoices i,
               pa_projects_all prj
        WHERE  prj.project_id = P_Project_ID
          AND  i.project_id = prj.project_id
          AND  i.draft_invoice_num = P_Draft_Invoice_Num;



     Cursor Cust_Cur is
/* TCA changes
       SELECT 1
         FROM RA_CUSTOMERS
        WHERE customer_id = l_customer_id
          AND NVL(status, 'A') <> 'A'
          AND customer_prospect_code = 'CUSTOMER';
*/
       SELECT 1
         FROM HZ_CUST_ACCOUNTS
        WHERE cust_account_id = l_customer_id
          AND NVL(status, 'A') <> 'A';
--          AND customer_prospect_code = 'CUSTOMER';

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
        RAISE;
  END Validate_Approval;



/*----------------------------------------------------------------------------+
 |      For Details/Comments Refer Package Specification Comments             |
 +----------------------------------------------------------------------------*/
  Procedure Validate_Release  ( P_Project_ID              in  number,
                                P_Draft_Invoice_Num       in  number,
                                P_Validation_Level        in  varchar2,
                                P_User_ID                 in  number,
                                P_RA_Invoice_Date         in  date,
                                P_RA_Invoice_Num          in  varchar2,
                                P_Credit_Memo_Reason_Code in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                                X_RA_Invoice_Num          out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                X_Error_Message_Code      out NOCOPY varchar2) is --File.Sql.39 bug 4440895

     l_entry_method    pa_implementations.user_defined_invoice_num_code%TYPE;
     l_num_type        pa_implementations.manual_invoice_num_type%TYPE;

     l_dummy           number;
     l_customer_id     number;
     l_err_msg_code    varchar2(30);
     l_RA_Invoice_Num  pa_draft_invoices_v.RA_Invoice_Number%TYPE;
     l_status          number;
     l_bill_to	         number;
     l_ship_to	         number;
	  l_Error_Message_Code VARCHAR2(80):=NULL;

     l_invoice_category  pa_draft_invoices_v.invoice_category%TYPE;
     l_bill_ship_to_customer_id number; /*Added for customer account relation enhancement*/
     Cursor Imp_Cur is
       SELECT user_defined_invoice_num_code, manual_invoice_num_type
         FROM pa_implementations;

     Cursor Imp_Cur_Inter is
       SELECT CC_MANUAL_INVOICE_NUM_CODE, CC_MANUAL_INVOICE_NUM_TYPE
         FROM pa_implementations;

     /* Added for Bug 2941112 */
     l_draft_inv_num_cr    number;

     l_Credit_Memo_Reason_Code    varchar2(100);

  BEGIN

    /* ATG Changes */

       l_Credit_Memo_Reason_Code := P_Credit_Memo_Reason_Code;


    -- Reset Output Parameters
    X_Error_Message_Code := NULL;
    -- Bug 682284
    /* Get customer, ship_to_address_id, bill_to_address_id
       for this draft Invoice */
    BEGIN

-- IC Changes
-- Invoice category field is added here to classify the invoice
-- into "INTERNAL INVOICE' and "EXTERNAL INVOICE"
--
/*PROJCUST.bill_to_customer_id is added for customer account relation enhancement*/
       SELECT PROJCUST.customer_id,PROJCUST.bill_to_customer_id,PROJCUST.bill_to_address_id,
              PROJCUST.ship_to_address_id,
              decode(nvl(PROJTYPE.cc_prvdr_flag,'N'),
                         'Y', 'INTERNAL-INVOICE',
                         decode(nvl(PROJCUST.bill_another_project_flag,'N'),
                                'Y', 'INTERNAL-INVOICE',
                                'EXTERNAL-INVOICE'))
       INTO  l_customer_id,l_bill_ship_to_customer_id, l_bill_to, l_ship_to, l_invoice_category
       FROM pa_draft_invoices INV, pa_agreements_all  AGREE, /* fix bug 2082864 for MCB2 */
            pa_project_customers PROJCUST,
            pa_projects PROJ,
            pa_project_types PROJTYPE
       WHERE INV.project_id = P_Project_id
       AND INV.draft_invoice_num = P_Draft_Invoice_Num
       AND AGREE.agreement_id = INV.agreement_id
       AND PROJCUST.customer_id = AGREE.customer_id
       AND PROJCUST.project_id = P_Project_id
       AND PROJ.project_id = INV.project_id
       AND PROJ.project_type = PROJTYPE.project_type;

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
/*          X_Error_Message_Code := 'PA_INV_NO_BILL_TO_ADDRESS'; commented for customer account relation enhancement*/
            X_Error_Message_Code := 'PA_INV_NO_CUSTOMER';
            GOTO all_done;

    END;

    /* Check for bill_to_address_id */

    IF (l_bill_to IS NULL) THEN
        X_Error_Message_Code := 'PA_INV_NO_BILL_TO_ADDRESS';
        GOTO all_done;
    END IF;

   /* Check for ship_to_address_id */
    IF (l_ship_to IS NULL) THEN
        X_Error_Message_Code := 'PA_INV_NO_SHIP_TO_ADDRESS';
        GOTO all_done;
    END IF;

   /* Check for bill_to_contact_id */

/* Commneting for bug 4879331 as we are no more validating if billing contact is
   populated or not.
    BEGIN

       SELECT null INTO l_dummy
       FROM sys.dual
       WHERE EXISTS ( SELECT project_id
                      FROM pa_project_contacts
                      WHERE project_id = P_project_id
                      AND customer_id = l_customer_id
                      AND bill_ship_customer_id=l_bill_ship_to_customer_id -- Added for customer account relation
                                                                            -- enhancement
                      AND project_contact_type_code = 'BILLING');

    EXCEPTION

       WHEN NO_DATA_FOUND THEN
            X_Error_Message_Code := 'PA_INV_NO_BILL_TO_CONTACT';
            GOTO all_done;

    END;
End Bug 4879331. */
    -- End Bug 682284

    /* Fix for bug 2941112  */
    BEGIN
         SELECT nvl(draft_invoice_num_credited,0)
         INTO   l_draft_inv_num_cr
         FROM   pa_draft_invoices
         WHERE  project_id = p_project_id
         AND    draft_invoice_num = P_Draft_Invoice_Num;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            NULL;
    END;

/* Commneting for bug 4879331 as we are no more validating if billing contact is
   populated or not.
    IF ( l_draft_inv_num_cr = 0 )
    THEN
        BEGIN
-- bug 4325231
--              SELECT null INTO l_dummy
--              FROM dual
--              WHERE EXISTS ( SELECT project_id
--                             FROM   pa_draft_invoices di, ra_contacts rc
--                             WHERE  di.project_id = p_project_id
--                             AND    di.draft_invoice_num = P_Draft_Invoice_Num
--                             AND    di.bill_to_contact_id = rc.contact_id
--                             AND    nvl(rc.status,'N') = 'A'
--                            );
             SELECT null INTO l_dummy
             FROM dual
             WHERE EXISTS ( SELECT project_id
                            FROM   pa_draft_invoices di, hz_cust_account_roles rc
                            WHERE  di.project_id = p_project_id
                            AND    di.draft_invoice_num = P_Draft_Invoice_Num
                            AND    di.bill_to_contact_id = rc.cust_account_role_id
                            AND    nvl(rc.status,'N') = 'A'
                           );
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            X_Error_Message_Code := 'PA_BIL_CONT_NOT_ACT';
            GOTO all_done;
       END;
    END IF;

End bug 4879331. */

if l_invoice_category = 'EXTERNAL-INVOICE'  then
    OPEN Imp_Cur;
    FETCH Imp_Cur into l_entry_method, l_num_type;
    CLOSE Imp_Cur;
else
    OPEN Imp_Cur_Inter;
    FETCH Imp_Cur_Inter into l_entry_method, l_num_type;
    CLOSE Imp_Cur_Inter;
end if;
    IF P_Validation_Level IN ('R','F_INV_DT','F_INV_NUM')
    THEN         /* Record Level Validation/Field level */

      /* RA invoice number checks for mannual numbering type */
      IF (l_entry_method <> 'AUTOMATIC')
      AND ( P_Validation_level IN ( 'R','F_INV_NUM'))  THEN

        /* RA invoice number should be entered */
        IF (P_RA_Invoice_Num is null) THEN
          X_Error_Message_Code := 'PA_IN_ENT_INV_NUMBER';
          GOTO all_done;
        END IF;

        /* Check for RA invoice number numeric */
        IF (l_num_type = 'NUMERIC') THEN
          BEGIN
            select to_number(P_RA_Invoice_Num)
              into l_dummy
              from dual;
          EXCEPTION
             WHEN INVALID_NUMBER THEN
                X_Error_Message_Code := 'PA_IN_ENT_NUM_INV_NUMBER';
                GOTO all_done;
             WHEN OTHERS THEN
               RAISE;
          END;
        END IF;
      END IF;  /* end of checks for mannual numbering type */

      IF  (P_Validation_Level IN ('R','F_INV_DT'))
      THEN
       /* Inv date should be entered */
       IF (P_RA_Invoice_Date is NULL) THEN
         X_Error_Message_Code := 'PA_IN_ENT_INV_DATE';
         GOTO all_done;
       END IF;

       /* Crediting Inv Date should be greater than Inv date */
       l_dummy := 0;
       SELECT COUNT(*)
         INTO l_dummy
        FROM pa_draft_invoices_all cm, pa_draft_invoices_all i
       WHERE cm.project_id = P_Project_ID
         AND cm.draft_invoice_num = P_Draft_Invoice_Num
         AND cm.project_id = i.project_id
         AND i.draft_invoice_num = cm.draft_invoice_num_credited
         AND i.invoice_date > P_RA_Invoice_Date;

       IF (l_dummy > 0) THEN
         X_Error_Message_Code := 'PA_IN_CM_INV_DATE';
         GOTO all_done;
       END IF;
       /* Call to procedure to validate Credit Memo Reason :Enhancement bug 2728431*/
       IF  (P_Validation_Level ='R') THEN

           Validate_Credit_Memo_Reason(P_Project_ID,P_Draft_Invoice_Num,P_RA_Invoice_Date,
    	                               P_Credit_Memo_Reason_Code,l_Error_Message_Code);

          IF (l_Error_Message_Code IS NOT NULL) THEN
            X_Error_Message_Code := l_Error_Message_Code;
            GOTO all_done;
          END IF;
       END IF;
     END IF;/* End Checking based on Record Level or Item level */
    ELSIF P_Validation_Level = 'C' THEN      /* Commit Level Validation */

       /* Check lower Invoice numbers have been released */
       l_dummy := 0;
       SELECT count(*)
         INTO l_dummy
         FROM pa_draft_invoices_all
        WHERE project_id = P_Project_ID
          AND draft_invoice_num < P_Draft_Invoice_Num
          AND released_date is null
          AND nvl(generation_error_flag, 'N') = 'N';

       IF (l_dummy > 0) THEN
          X_Error_Message_Code := 'PA_UNREL_INVOICES_EXIST';
          GOTO all_done;
       END IF;

       IF (l_entry_method = 'AUTOMATIC') THEN
        /* Added for bug 5924290 to get the invoice status. If released then 1 else 0 */
        begin
        SELECT 1
        into l_dummy
        FROM PA_DRAFT_INVOICES_ALL
        WHERE PROJECT_ID =P_Project_ID
        AND DRAFT_INVOICE_NUM = P_Draft_Invoice_Num
        AND RELEASED_DATE IS NOT NULL;
        exception
        when others
        then
        l_dummy := 0;
        end;

/* Added if condition for bug 5924290. If released then no need to call PA_UTILS_SQNUM_PKG.get_unique_invoice_num
   to increment the auto number. */
         IF l_dummy = 0 THEN
         PA_UTILS_SQNUM_PKG.get_unique_invoice_num(l_invoice_category,
                           P_User_ID ,l_RA_Invoice_Num , l_status);
         END IF;
       ELSE
         /* RA Inv Number is entered (Mannual Method). Check Unique */
         l_RA_Invoice_Num := P_RA_Invoice_Num;

         l_dummy := 0;
         SELECT count(*)
           INTO l_dummy
           FROM pa_draft_invoices i,
                pa_projects  p,
                pa_project_types pt,
                pa_agreements_all AGREE, /* fix bug 2082864 for MCB2 */
                pa_project_customers PROJCUST
          WHERE i.ra_invoice_number      = l_RA_Invoice_Num
            AND NOT EXISTS ( SELECT 'x'
                               FROM pa_draft_invoices x
                              WHERE x.project_id = P_Project_ID
                                AND x.draft_invoice_num = P_Draft_Invoice_Num
                                AND x.project_id = i.project_id
                                AND x.draft_invoice_num = i.draft_invoice_num)
            AND i.project_id = p.project_id
            AND pt.project_type = p.project_type
            AND AGREE.agreement_id = i.agreement_id
            AND PROJCUST.customer_id = AGREE.customer_id
            AND projcust.project_id = p.project_id   /* added for bug#2634995 */
            AND decode(nvl(pt.cc_prvdr_flag,'N'),
                              'Y', 'INTERNAL-INVOICE',
                              decode(nvl(PROJCUST.bill_another_project_flag,'N'),
                                     'Y', 'INTERNAL-INVOICE',
                                     'EXTERNAL-INVOICE'))
                 = l_invoice_category;


          IF (l_dummy > 0 ) THEN
            X_Error_Message_Code := 'PA_IN_RA_INV_NUMBER_NOT_UNIQUE';
            GOTO all_done;
          END IF;

       END IF;

          X_Ra_Invoice_Num := l_RA_Invoice_Num;
       /* Call to procedure to validate Credit Memo Reason :Enhancement bug 2728431*/
       Validate_Credit_Memo_Reason(P_Project_ID,P_Draft_Invoice_Num,P_RA_Invoice_Date,
	                          P_Credit_Memo_Reason_Code,l_Error_Message_Code);

       IF (l_Error_Message_Code IS NOT NULL) THEN
          X_Error_Message_Code := l_Error_Message_Code;
          GOTO all_done;
       END IF;

       /*  Start of Bug 3344912 - Check if lower invoices have Generation Error */
       l_dummy := 0;

       SELECT count(*)
         INTO l_dummy
         FROM pa_draft_invoices_all
        WHERE project_id = P_Project_ID
          AND draft_invoice_num < P_Draft_Invoice_Num
          AND released_date is null
          AND nvl(generation_error_flag, 'N') = 'Y';

       IF (l_dummy > 0) THEN
          X_Error_Message_Code := 'PA_GEN_ERR_INV_EXIST';
          GOTO all_done;
       END IF;
       /* End of Bug 3344912 */

    END IF; /* Validate Level Checks */

    <<all_done>>
      NULL;

  EXCEPTION
    WHEN OTHERS THEN
        /* ATG Changes */
            P_Credit_Memo_Reason_Code := l_Credit_Memo_Reason_Code ;
            X_RA_Invoice_Num  := null;

        RAISE;
  END Validate_Release;

/* Overloaded procedure validate_release for credit memo reason */
  Procedure Validate_Release  ( P_Project_ID              in  number,
                                P_Draft_Invoice_Num       in  number,
                                P_Validation_Level        in  varchar2,
                                P_User_ID                 in  number,
                                P_RA_Invoice_Date         in  date,
                                P_RA_Invoice_Num          in  varchar2,
                                X_RA_Invoice_Num          out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                X_Error_Message_Code      out NOCOPY varchar2) is --File.Sql.39 bug 4440895

new_excp        exception;
BEGIN
Raise new_excp;
END Validate_Release ;


/*----------------------------------------------------------------------------+
 |      For Details/Comments Refer Package Specification Comments             |
 +----------------------------------------------------------------------------*/
  Procedure validate_multi_Customer ( P_Invoice_Set_ID     in  number,
                                      X_Error_Message_Code out NOCOPY varchar2) is --File.Sql.39 bug 4440895
    l_dummy number;
  BEGIN

    X_Error_Message_Code := NULL;
    l_dummy := 0;

    SELECT count(*)
      INTO l_dummy
      FROM PA_Draft_Invoices_ALL i
     WHERE i.invoice_set_id    = P_Invoice_Set_ID
       AND i.customer_bill_split not in (0, 100)
       AND (   (    (i.approved_date is not null)
                AND EXISTS ( SELECT 'APPROVED ERROR'
                               FROM pa_draft_invoices ia
                               WHERE ia.project_id = i.project_id
                                 AND ia.invoice_set_id = i.invoice_set_id
                                 AND ia.approved_date is null))
            OR (    (i.released_date is not null)
                AND EXISTS ( SELECT 'RELEASED ERROR'
                               FROM pa_draft_invoices ir
                               WHERE ir.project_id = i.project_id
                                 AND ir.invoice_set_id = i.invoice_set_id
                                 AND ir.released_date is null)));

    IF (l_dummy > 0) THEN
      X_Error_Message_Code := 'PA_REL_ALL_DR_INV';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END validate_multi_Customer;


/*----------------------------------------------------------------------------+
 |      For Details/Comments Refer Package Specification Comments             |
 +----------------------------------------------------------------------------*/
  Procedure Post_Update_Release ( P_Project_ID         in  number,
                                  P_Draft_Invoice_Num  in  number,
                                  P_User_ID            in  number,
                                  P_Employee_ID        in  number) is


/* Commented for bug 3088395 */ /* The following SQL statement was uncommented for bug 3872496 */
    CURSOR EI_BILL_HOLD_CUR IS
       SELECT ei.expenditure_item_id
         FROM pa_expenditure_items_all ei, pa_tasks t
        WHERE ei.bill_hold_flag = 'O'
          AND ei.task_id = t.task_id
          AND t.project_id = P_Project_ID;


/* The following SQL statement was commented for bug 3872496 */
/*Added for bug 3088395
    CURSOR EI_BILL_HOLD_CUR IS
       SELECT ei.expenditure_item_id
         FROM pa_expenditure_items_all ei
        WHERE ei.bill_hold_flag = 'O'      /*Bill Hold Once
          AND ei.project_id = P_Project_ID;
*/


    l_outcome          varchar2(100);
    l_num_processed    number;
    l_num_rejected     number;
    l_dummy            number;
    l_msg_application  VARCHAR2(30) :='PA';
    l_msg_type         VARCHAR2(1) := 'E';
    l_msg_token1       Varchar2(240) := '';
    l_msg_token2       Varchar2(240) :='';
    l_msg_token3       Varchar2(240) :='';
    l_msg_count        Number ;


  BEGIN

    /* Releasing bill event based revenue */
    UPDATE pa_draft_revenues dr
    SET    dr.last_update_date      = sysdate,
           dr.last_updated_by       = P_User_ID,
           dr.released_date         = sysdate,
           dr.last_update_login     = P_Employee_ID
    WHERE  dr.project_id            = P_Project_ID
    AND    dr.generation_error_flag = 'N'
    AND    dr.released_date        IS  NULL
    AND    dr.draft_revenue_num <=
              (SELECT max(rdl.draft_revenue_num)
               FROM   pa_cust_event_rev_dist_lines rdl
               WHERE  rdl.project_id             = P_Project_ID
               AND    rdl.draft_invoice_num      = P_Draft_Invoice_Num);


/* Releasing Revenue based on Automatic Events which have both revenue and
   invoice amounts -For bug 5401384 - base bug 5246804*/

 UPDATE pa_draft_revenues dr
    SET    dr.last_update_date      = sysdate,
           dr.last_updated_by       = P_User_ID,
           dr.released_date         = sysdate,
           dr.last_update_login     = P_Employee_ID
    WHERE  dr.project_id            = P_Project_ID
    AND    dr.generation_error_flag = 'N'
    AND    dr.released_date        IS  NULL
    AND    dr.draft_revenue_num <=
              (SELECT max(rdl.draft_revenue_num)
               FROM   pa_cust_event_rev_dist_lines rdl
               WHERE  rdl.project_id             = P_Project_ID
               and    exists /* check if the event is an automatic event */
                      (select 1
                       from pa_events e, pa_event_types et
                       where e.project_id = rdl.project_id
                       and e.event_num = rdl.event_num
                       and nvl(e.task_id,-99) = nvl(rdl.task_id,-99)
                       and e.event_type = et.event_type
                       and et.event_type_classification = 'AUTOMATIC')
               AND    exists /* check if the invoice released is related to this automatic event */
                      (select 1
                       from pa_draft_invoice_items dii
                       where dii.project_id = rdl.project_id
		       and dii.draft_invoice_num = P_Draft_Invoice_Num
                       and dii.event_num is not null
                       and dii.event_num = rdl.event_num
                       and nvl(dii.event_task_id, -99) = nvl(rdl.task_id, -99)));

/* End of Changes for bug 5401384 - Base Bug 5246804 */


    /* Releasing Expenditure item based revenue */
    UPDATE pa_draft_revenues dr
    SET    dr.last_update_date      =  sysdate,
           dr.last_updated_by       =  P_User_ID,
           dr.released_date         =  sysdate,
           dr.last_update_login     =  P_Employee_ID
    WHERE  dr.project_id            =  P_Project_ID
    AND    dr.generation_error_flag = 'N'
    AND    dr.released_date        IS  NULL
    AND    dr.draft_revenue_num <=
                /* Commented code fix for bug 2968645
              (SELECT max(rdl.draft_revenue_num)
               FROM   pa_cust_rev_dist_lines rdl
               WHERE  rdl.project_id             = P_Project_ID
               AND    rdl.draft_invoice_num      = P_Draft_Invoice_Num); */
               /* Bug fix for bug 2968645 Starts here */
               (SELECT max(rdl1.draft_revenue_num)
               FROM   pa_cust_rev_dist_lines rdl1
               WHERE  rdl1. expenditure_item_id in
                                (       SELECT  expenditure_item_id
                                        FROM    pa_cust_rev_dist_lines rdl2
                                        WHERE   rdl2.project_id = P_Project_ID
                                        AND     rdl2.draft_invoice_num = P_Draft_Invoice_Num));
               /* Bug fix for bug 2968645 Ends here */



    /* Release One Time EI BILL Holds */
    FOR EI_BILL_HOLD_REC in EI_BILL_HOLD_CUR
    LOOP
      pa_adjustments.adjust (X_adj_action          => 'BILLING HOLD RELEASE',
                             X_module              => 'PAXINADI',
                             X_user                => P_User_ID,
                             X_login               => P_Employee_ID,
                             X_project_id          => P_Project_ID,
                             X_adjust_level        => 'I',    -- item level
                             X_expenditure_item_id =>
                                          EI_BILL_HOLD_REC.expenditure_item_id,
                             X_outcome             => l_outcome,
                             X_num_processed       => l_num_processed,
                             X_num_rejected        => l_num_rejected,
                             X_msg_application     => l_msg_application,
                             X_msg_type            => l_msg_type,
                             X_msg_token1          => l_msg_token1,
                             X_msg_token2          => l_msg_token2,
                             X_msg_token3          => l_msg_token3,
                             X_msg_count           => l_msg_count );

    END LOOP;

    /* Release One Time Event BILL Holds */
    UPDATE pa_events
      SET bill_hold_flag    = 'N',
          last_update_date  = sysdate,
          last_updated_by   = P_User_ID,
          last_update_login = P_Employee_ID
    WHERE project_id = P_Project_ID
      AND bill_hold_flag || '' = 'O';

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Post_Update_Release;

/*----------------------------------------------------------------------------+
 |      For Details/Comments Refer Package Specification Comments             |
 +----------------------------------------------------------------------------*/
  Procedure Client_Extn_Driver( P_Request_ID         in  number,
                                P_User_ID            in  number,
                                P_Calling_Place      in  varchar2,
                                P_Project_ID         in  number ) is

    l_employee_id        number;

    l_project_id         number;
    l_prv_project_id     number;
    l_draft_invoice_num  number;
    l_invoice_set_id     number;
    l_prv_invoice_set_id number;
    l_tmp_invoice_set_id number;
    l_invoice_class      varchar2(15);
    l_action_flag        varchar2(1);
    l_err_msg_code       varchar2(30);
    l_status             number;
    l_dummy              number;
    l_invoice_amount     number;
    l_project_amount     number;
    l_inv_currency_code  varchar2(15);
    l_project_currency_code  varchar2(15);

    l_ra_invoice_num     varchar2(20);
    l_tmp_ra_invoice_num varchar2(20);
    l_ra_invoice_date    date;
    l_Credit_memo_reason_code pa_draft_invoices_all.credit_memo_reason_Code%TYPE;

    /* Cursor for Select All Unapproved invoices created in This Run */
    CURSOR UNAPP_INV_CUR is
      SELECT i.project_id,
             nvl(i.invoice_set_id, 0),
             i.draft_invoice_num,
             decode(P_Calling_Place, 'INV_CR_MEMO',
                decode(i.draft_invoice_num_credited, NULL, 'INVOICE',
                        'CREDIT_MEMO'), P_Calling_Place) invoice_class,
             sum(ii.amount),
             p.project_currency_code,
             i.inv_currency_code,
             sum(ii.inv_amount)
        FROM pa_projects p,
             pa_draft_invoices i,
             pa_draft_invoice_items ii
       WHERE p.project_id = i.project_id
         AND i.project_id = ii.project_id
         AND i.draft_invoice_num = ii.draft_invoice_num
         AND i.request_id = P_Request_ID
         AND i.approved_date is null
         AND nvl(i.generation_error_flag, 'N') = 'N'
         AND (i.project_id+0 = P_Project_ID or P_Project_ID is NULL)
    GROUP BY i.project_id,
             nvl(i.invoice_set_id, 0),
             i.draft_invoice_num,
             decode(P_Calling_Place, 'INV_CR_MEMO',
                decode(i.draft_invoice_num_credited, NULL, 'INVOICE',
                        'CREDIT_MEMO'), P_Calling_Place),
             p.project_currency_code,
             i.inv_currency_code
    ORDER BY i.project_id, i.draft_invoice_num; /*Added order by clause for bug 6009706 */


    /* Cursor for Select All Unreleased invoices created in This Run */
    CURSOR UNREL_INV_CUR is
      SELECT i.project_id,
             nvl(i.invoice_set_id, 0),
             i.draft_invoice_num,
             decode(P_Calling_Place, 'INV_CR_MEMO',
                decode(i.draft_invoice_num_credited, NULL, 'INVOICE',
                        'CREDIT_MEMO'), P_Calling_Place) invoice_class,
             sum(ii.amount),
             p.project_currency_code,
             i.inv_currency_code,
             sum(ii.inv_amount)
        FROM pa_projects p,
             pa_draft_invoices i,
             pa_draft_invoice_items ii
       WHERE p.project_id = i.project_id
         AND i.project_id = ii.project_id
         AND i.draft_invoice_num = ii.draft_invoice_num
         AND i.request_id = P_Request_ID
         AND i.approved_date is not null
         AND i.released_date is null   /* For bug 2863710 */
         AND nvl(i.generation_error_flag, 'N') = 'N'
         AND (i.project_id+0 = P_Project_ID or P_Project_ID is NULL)
    GROUP BY i.project_id,
             nvl(i.invoice_set_id, 0),
             i.draft_invoice_num,
             decode(P_Calling_Place, 'INV_CR_MEMO',
                decode(i.draft_invoice_num_credited, NULL, 'INVOICE',
                        'CREDIT_MEMO'), P_Calling_Place),
             p.project_currency_code,
             i.inv_currency_code
    ORDER BY i.project_id, i.draft_invoice_num; /*Added order by clause for bug 6009706 */


    /* Cursor for Select All invoices Released in This Run */
    CURSOR RELEASED_INV_CUR is
      SELECT i.project_id,
             i.draft_invoice_num
        FROM pa_draft_invoices i
       WHERE i.request_id = P_Request_ID
         AND i.released_date is not null;

  BEGIN

    /*------------------------------------------------------------------+
     |    Get Employee ID corresponding to User ID                      |
     +------------------------------------------------------------------*/
     BEGIN
/* nvl added for the resolution of the bug 1510535 */
       SELECT nvl(Employee_ID,0)
         INTO l_employee_id
         FROM FND_USER
        WHERE User_ID = P_User_ID;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_employee_id := 0;
     END;


    /*------------------------------------------------------------------+
     |    Select The Invoices that were created in this run             |
     |    For a single run of generate Draft invoice program this API   |
     |    will be called once for Invoice/Credit Memo, Write Off or     |
     |    Cancellation of an invoice.                                   |
     +------------------------------------------------------------------*/

    /*------------------------------------------------------------------+
     |    Select UnApproved Invoices that were Created in this run      |
     +------------------------------------------------------------------*/

    -- Initialize Local Variables
    l_prv_project_id := 0;
    l_prv_invoice_set_id := 0;
    l_tmp_invoice_set_id := 0;

    OPEN UNAPP_INV_CUR;

    LOOP
      FETCH UNAPP_INV_CUR into l_project_id, l_invoice_set_id,
                             l_draft_invoice_num,
                             l_invoice_class,
                             l_project_amount,
                             l_project_currency_code,
                             l_inv_currency_code,
                             l_invoice_amount;

      EXIT WHEN UNAPP_INV_CUR%NOTFOUND;

      l_tmp_invoice_set_id := l_invoice_set_id;

      /* Lock The Project */
      IF (l_project_id <> l_prv_project_id) THEN
         SELECT Project_ID
           INTO l_dummy
           FROM PA_Projects_ALL
          WHERE Project_ID = l_project_id
         FOR UPDATE OF LAST_UPDATE_DATE;

         l_prv_project_id := l_project_id;

      END IF;

      -- Initialize Output Variables
      l_action_flag     := NULL;
      l_status          := NULL;

      PA_Client_Extn_Inv_Actions.Approve_Invoice( l_project_id,
                                                  l_draft_invoice_num,
                                                  l_invoice_class,
                                                  l_project_amount,
                                                  l_project_currency_code,
                                                  l_inv_currency_code,
                                                  l_invoice_amount,
                                                  l_action_flag,
                                                  l_Status);

      /* Check Extension Application Error */
      IF l_Status > 0 THEN
         Insert_Distrbution_Warning ( l_Project_ID, l_draft_invoice_num,
                                      P_User_ID, P_Request_ID, NULL,
                                      'PA_CLIENT_EXTN_APP_ERROR');
         GOTO FETCH_NEXT_UNAPP_REC;
      END IF;

      /* Check Extension Oracle Error */
      IF l_Status < 0 THEN
         Insert_Distrbution_Warning ( l_Project_ID, l_draft_invoice_num,
                                      P_User_ID, P_Request_ID, NULL,
                                      'PA_CLIENT_EXTN_ORACLE_ERROR');
         GOTO FETCH_NEXT_UNAPP_REC;
      END IF;

      /* At This Point Approval Billing Extension has returned success */
      IF (nvl(l_action_flag, 'N') = 'Y') THEN
        l_err_msg_code := NULL;
        /* Record Level Validations */
        PA_Invoice_Actions.Validate_Approval( l_Project_ID,
                                              l_draft_invoice_num, 'R',
                                              l_err_msg_code);
        IF l_err_msg_code is null THEN
          /* Commit Level Validations */
          PA_Invoice_Actions.Validate_Approval( l_Project_ID,
                                                l_draft_invoice_num, 'C',
                                                l_err_msg_code);
        END IF;

        IF l_err_msg_code is null THEN
          /* Approve Invoices */
          Update_Approve_Invoices( l_Project_ID, l_draft_invoice_num,
                                   P_User_ID, l_employee_id);
        ELSE
          Insert_Distrbution_Warning ( l_Project_ID, l_draft_invoice_num,
                                       P_User_ID, P_Request_ID, NULL,
                                       l_err_msg_code);
         GOTO FETCH_NEXT_UNAPP_REC;

        END IF;

      END IF;

      <<FETCH_NEXT_UNAPP_REC>>

      /* Check for Multiple Customers */
      IF ((l_invoice_set_id     <> l_prv_invoice_set_id) AND
          (l_invoice_set_id     <> 0)                    AND
          (l_prv_invoice_set_id <> 0))                   THEN

         PA_Invoice_Actions.Validate_Multi_Customer (l_prv_invoice_set_id,
                                                     l_err_msg_code);

         IF l_err_msg_code is not null THEN
           Insert_Distrbution_Warning ( NULL, NULL, P_User_ID, P_Request_ID,
                                        l_prv_invoice_set_id, l_err_msg_code);
           Update_Unapprove_Invoices ( l_prv_invoice_set_id, P_User_ID);
         END IF;

         l_prv_invoice_set_id := l_invoice_set_id;

      END IF;


    END LOOP;

    IF ( l_tmp_invoice_set_id <> 0) THEN

       PA_Invoice_Actions.Validate_Multi_Customer (l_invoice_set_id,
                                                   l_err_msg_code);

       IF l_err_msg_code is not null THEN
         Insert_Distrbution_Warning ( NULL, NULL, P_User_ID, P_Request_ID,
                                      l_invoice_set_id, l_err_msg_code);
         Update_Unapprove_Invoices ( l_invoice_set_id, P_User_ID);
       END IF;
    END IF;

    CLOSE UNAPP_INV_CUR;

    COMMIT;


    /*------------------------------------------------------------------+
     |    Select UnReleased Invoices that were Created in this run      |
     +------------------------------------------------------------------*/

    -- Initialize Local Variables
    l_prv_project_id := 0;
    l_prv_invoice_set_id := 0;
    l_tmp_invoice_set_id := 0;

    OPEN UNREL_INV_CUR;

    LOOP
      FETCH UNREL_INV_CUR into l_project_id, l_invoice_set_id,
                             l_draft_invoice_num,
                             l_invoice_class,
                             l_project_amount,
                             l_project_currency_code,
                             l_inv_currency_code,
                             l_invoice_amount;

      EXIT WHEN UNREL_INV_CUR%NOTFOUND;

      l_tmp_invoice_set_id := l_invoice_set_id;

      /* Lock The Project */
      IF (l_project_id <> l_prv_project_id) THEN
         SELECT Project_ID
           INTO l_dummy
           FROM PA_Projects_ALL
          WHERE Project_ID = l_project_id
         FOR UPDATE OF LAST_UPDATE_DATE;

         l_prv_project_id := l_project_id;

      END IF;


      -- Initialize Output and temporary Variables
      l_action_flag             := NULL;
      l_ra_invoice_date         := NULL;
      l_ra_invoice_num          := NULL;
      l_tmp_ra_invoice_num      := NULL;
      l_status                  := NULL;
      l_Credit_memo_reason_code := NULL;


      PA_Client_Extn_Inv_Actions.Release_Invoice( l_project_id,
                                                  l_draft_invoice_num,
                                                  l_invoice_class,
                                                  l_project_amount,
                                                  l_project_currency_code,
                                                  l_inv_currency_code,
                                                  l_invoice_amount,
                                                  l_action_flag,
                                                  l_ra_invoice_date,
                                                  l_ra_invoice_num,
                                                  l_Status,
                                                  l_Credit_memo_reason_code);

      /* Check Extension Application Error */
      IF l_Status > 0 THEN
         Insert_Distrbution_Warning ( l_Project_ID, l_draft_invoice_num,
                                      P_User_ID, P_Request_ID, NULL,
                                      'PA_CLIENT_EXTN_APP_ERROR');
         GOTO FETCH_NEXT_UNREL_REC;
      END IF;

      /* Check Extension Oracle Error */
      IF l_Status < 0 THEN
         Insert_Distrbution_Warning ( l_Project_ID, l_draft_invoice_num,
                                      P_User_ID, P_Request_ID, NULL,
                                      'PA_CLIENT_EXTN_ORACLE_ERROR');
         GOTO FETCH_NEXT_UNREL_REC;
      END IF;

      /* At This Point Release  Billing Extension has returned success */
      IF (nvl(l_action_flag, 'N') = 'Y') THEN
        l_err_msg_code := NULL;
        /* Record Level Validations */
        PA_Invoice_Actions.Validate_Release ( l_Project_ID,
                                              l_draft_invoice_num, 'R',
                                              P_User_ID, l_ra_invoice_date,
                                              l_ra_invoice_num,
                                              l_Credit_memo_reason_code,
                                              l_tmp_ra_invoice_num,
                                              l_err_msg_code);
        IF l_err_msg_code is null THEN
          /* Commit Level Validations */
          PA_Invoice_Actions.Validate_Release ( l_Project_ID,
                                                l_draft_invoice_num, 'C',
                                                P_User_ID, l_ra_invoice_date,
                                                l_ra_invoice_num,
                                                l_Credit_memo_reason_code,
                                                l_tmp_ra_invoice_num,
                                                l_err_msg_code);
        END IF;

        IF l_err_msg_code is null THEN
          /* Release Invoices */
          l_ra_invoice_num := l_tmp_ra_invoice_num;
          Update_Release_Invoices( l_Project_ID, l_draft_invoice_num,
                                   l_ra_invoice_date, l_ra_invoice_num,
                                   P_User_ID, l_employee_id,l_Credit_memo_reason_code);
        ELSE
          Insert_Distrbution_Warning ( l_Project_ID, l_draft_invoice_num,
                                       P_User_ID, P_Request_ID, NULL,
                                       l_err_msg_code);
         GOTO FETCH_NEXT_UNREL_REC;

        END IF;

      END IF;

      <<FETCH_NEXT_UNREL_REC>>

      /* Check for Multiple Customers */
      IF ((l_invoice_set_id     <> l_prv_invoice_set_id) AND
          (l_invoice_set_id     <> 0)                    AND
          (l_prv_invoice_set_id <> 0))                   THEN

         PA_Invoice_Actions.Validate_Multi_Customer (l_prv_invoice_set_id,
                                                     l_err_msg_code);

         IF l_err_msg_code is not null THEN
           Insert_Distrbution_Warning ( NULL, NULL, P_User_ID, P_Request_ID,
                                        l_prv_invoice_set_id, l_err_msg_code);
           Update_Unrelease_Invoices ( l_prv_invoice_set_id, P_User_ID);
         END IF;

         l_prv_invoice_set_id := l_invoice_set_id;

      END IF;

    END LOOP;

    IF ( l_tmp_invoice_set_id <> 0) THEN

       PA_Invoice_Actions.Validate_Multi_Customer (l_invoice_set_id,
                                                   l_err_msg_code);

       IF l_err_msg_code is not null THEN
         Insert_Distrbution_Warning ( NULL, NULL, P_User_ID, P_Request_ID,
                                      l_invoice_set_id, l_err_msg_code);
         Update_Unrelease_Invoices ( l_invoice_set_id, P_User_ID);
       END IF;
    END IF;

    CLOSE UNREL_INV_CUR;

    /* Do the Post Release update for all the released Records */
    FOR CUR_REC in RELEASED_INV_CUR
    LOOP
      PA_Invoice_Actions.Post_Update_Release(CUR_REC.Project_ID,
                                             CUR_REC.Draft_Invoice_Num,
                                             P_User_ID,
                                             l_employee_id);
    END LOOP;

    COMMIT;


  EXCEPTION
    WHEN OTHERS THEN
        RAISE;
  END Client_Extn_Driver;

  /* Begin Concession invoice modification */

  /*-----------------------------------------------------------------------------------------+
   |   Procedure  :   check_concurrency_issue                                                |
   |   Purpose    :   To ensure that no two users do credit processing on the same draft     |
   |                  at the same time                                                       |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_draft_invoice_num   IN      Draft invoice for which credit action is to be done   |
   |     p_rec_version_number  IN      Record version number of the draft invoice as         |
   |                                   retrieved by the user
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/
  Procedure check_concurrency_issue (
             p_project_id             IN NUMBER,
             p_draft_invoice_num      IN NUMBER,
             p_rec_version_number  IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2) IS


         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;

         l_record_version_number	NUMBER;
         l_cnt_recs	                NUMBER;

         l_last_credit_request_id   NUMBER;
         l_phase                    varchar2(255);
         l_status                   varchar2(255);
         l_dev_phase                varchar2(255);
         l_dev_status               varchar2(255);
         l_message                  varchar2(255);


  BEGIN

      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      x_msg_count        := 0;


      /* Get the current record version number in draft invoice table */

      select record_version_number, last_credit_request_id
      into l_record_version_number, l_last_credit_request_id
      from pa_draft_invoices
      where project_id = p_project_id
      and draft_invoice_num = p_draft_invoice_num;

      /* Check that it matches the one passed by the calling process */

      if  (nvl(p_rec_version_number,0) <> nvl(l_record_version_number,0)) then
	  l_return_status := FND_API.G_RET_STS_ERROR;
	  l_msg_data := 'PA_REC_ALREADY_UPDATED';
	  /*  This means that another session has updated the record_version_number and fired
	      the concurrent request for invoice processing since the start of the current session.
		  Hence the current session needs to rollback and restart in order to include the changes
		  from the other session.
       */
          rollback;
	  RAISE FND_API.G_EXC_ERROR;
      End if;

      /* Check the last request identifier that was run for crediting the current invoice
	     and get the status of the last run
       */

         if (l_last_credit_request_id is not null) then

		 /* The status needs to be checked only if there was a last run
		  */

            if (FND_CONCURRENT.GET_REQUEST_STATUS
                (
                  l_last_credit_request_id,
                  null,  --  pa_schema_name
                  null,  --  request_name
                  l_phase,
                  l_status,
                  l_dev_phase,
                  l_dev_status,
                  l_message
                )) then
              null;
            end if;
        /* For reference the possible combinations of dev_phase and dev_status
		   for the last run are:

           PENDING  NORMAL
                    STANDBY
                    SCHEDULED
                    PAUSED
           RUNNING  NORMAL
                    WAITING
                    RESUMING
                    TERMINATING
           COMPLETE NORMAL
                    ERROR
                    WARNING
                    CANCELLED
                    TERMINATED
           INACTIVE DISABLED
                    ON_HOLD
                    NO_MANAGER
                    SUSPENDED
         */


             if       (l_dev_phase = 'PENDING' or
                       l_dev_phase = 'RUNNING' or
                       l_dev_phase = 'INACTIVE'
                      ) then
                      l_return_status := FND_API.G_RET_STS_ERROR;
                      l_msg_data := 'PA_CREDIT_IN_PROGRESS';
	  /*  This means that the request for invoice processing fired by another session is still in
	      progress.  Hence the current session needs to rollback and restart after the prior request
		  has been completed, and no more changes are pending from the prior request, in order to
		  include the changes from the other session.
       */
	                  ROLLBACK;
                      RAISE FND_API.G_EXC_ERROR;
             elsif   (l_dev_phase = 'COMPLETE') then
                      null;
             end if;

         end if; -- (l_last_credit_request_id is not null)

  EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

       WHEN others then
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := SUBSTR(SQLERRM,1,100);

  END check_concurrency_issue;

  /*----------------------------------------------------------------------------------------------+
   |   Procedure  :   validate_invoice_amount                                                     |
   |   Purpose    :   To validate the net invoice amount for Write-Off/Concession                 |
   |   Parameters :                                                                               |
   |     ==================================================================================       |
   |     Name                       Mode    Description                                           |
   |     ==================================================================================       |
   |     p_project_id               IN      Project ID                                            |
   |     p_credit_action            IN      Indicates if credit is WRITE-OFF/CONCESSION           |
   |     p_credit_action_type       IN      Indicates if credit action type is                    |
   |                                        SUMMARY/GROUP/LINES                                   |
   |     p_draft_invoice_num        IN      Draft invoice for which credit action is to be done   |
   |     p_invoice_amount           IN      Invoice amount of the draft invoice for which credit  |
   |                                          action is to be done.                               |
   |     p_net_inv_amount           IN      Net invoice amount of the selected lines.             |
   |     p_credit_amount            IN      Total entered credit amount.                          |
   |     p_balance due              IN      Due amount in AR.                                     |
   |     x_tot_credited_amt         OUT     Total credited amount applied on invoice.             |
   |     x_return_status            OUT     Return status of this procedure                       |
   |     x_msg_count                OUT     Error message count                                   |
   |     x_msg_data                 OUT     Error message                                         |
   |     ==================================================================================       |
   +---------------------------------------------------------------------------------------------*/

  Procedure validate_invoice_amount (
             p_project_id             IN NUMBER,
             p_credit_action          IN VARCHAR2,
             p_credit_action_type     IN VARCHAR2,
             p_draft_invoice_num      IN NUMBER,
             p_invoice_amount         IN NUMBER,
             p_net_inv_amount         IN NUMBER,
             p_credit_amount          IN NUMBER,
             p_balance_due            IN NUMBER,
             x_tot_credited_amt       OUT   NOCOPY NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2)   IS

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;

         l_tot_credited_amt         NUMBER ;

    /* Bug 9459594 */
    l_intercompany_flag VARCHAR2(1) := 'N';
    CURSOR overapplication_csr IS
           SELECT NVL(typ.allow_overapplication_flag,'N')
           FROM   pa_implementations imp,
                  ra_batch_sources bs,
                  ra_cust_trx_types typ
           WHERE  decode(l_intercompany_flag,'N',imp.invoice_batch_source_id,
                         imp.cc_ic_ar_batch_source_id) = bs.batch_source_id
           and    bs.default_inv_trx_type = typ.cust_trx_type_id;
    l_overapplication_flag            VARCHAR2(1) := 'N';

    CURSOR get_intercompany_flag_csr IS
           SELECT NVL(ptype.cc_prvdr_flag, 'N')
           FROM   pa_projects proj,
                  pa_project_types ptype
           WHERE  proj.PROJECT_ID = p_project_id
           AND    proj.PROJECT_TYPE = ptype.PROJECT_TYPE;

    CURSOR get_centralized_flag_csr IS
           SELECT DECODE(CENTRALIZED_INVOICING_FLAG, 'N', 'Y', 'N')
           FROM   PA_IMPLEMENTATIONS;
    l_use_inv_org_flag VARCHAR2(1)  := 'N';

    CURSOR get_misc_details_csr IS
           SELECT IMP.business_group_id,
                  IMP.proj_org_structure_version_id,
                  BASELANG.language_code,
                  INV.invoice_date,
                  PROJ.Carrying_Out_Organization_ID
           FROM   pa_implementations IMP,
                  fnd_languages BASELANG,
                  pa_draft_invoices_all INV,
                  pa_projects PROJ
           WHERE  INV.project_id = p_project_id
           AND    INV.draft_invoice_num = p_draft_invoice_num
           AND    BASELANG.installed_flag = 'B'
           AND    PROJ.project_id = p_project_id;
    l_business_group_id pa_implementations.business_group_id%TYPE;
    l_org_st_ver_id pa_implementations.proj_org_structure_version_id%TYPE;
    l_base_language fnd_languages.language_code%TYPE;
    l_invoice_date  pa_draft_invoices_all.invoice_date%TYPE;
    l_carry_out_org_id  pa_projects.Carrying_Out_Organization_ID%TYPE;

    x_trx_type      VARCHAR2(10);
    x_cm_trx_type   VARCHAR2(10);
    x_error_status  NUMBER;
    x_error_message PA_LOOKUPS.DESCRIPTION%TYPE;

    CURSOR overapplication_csr_2 IS
           SELECT NVL(typ.allow_overapplication_flag,'N')
           FROM   ra_cust_trx_types typ
           WHERE  typ.cust_trx_type_id = TO_NUMBER(x_trx_type);

  BEGIN

      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      x_msg_count        := 0;
      x_tot_credited_amt := 0;

     /* First Check - Check if Invoice Amount is negative.
                      Write-Off/Concession cannot be performed when Invoice Amount is negative. */

          IF  sign(p_invoice_amount) <> 1  THEN

                    l_return_status := FND_API.G_RET_STS_ERROR;
                    l_msg_data := 'PA_IN_CRD_NOT_POSITIVE';
                    l_msg_count := 1;

                    RAISE FND_API.G_EXC_ERROR;

          END IF;

     /* Second Check - Check if net invoice amount of the selected lines is negative.
                      Write-Off/Concession cannot be performed when net invoice amount of the
                       selected lines is negative. */
          IF  (p_credit_action_type in ('GROUP', 'LINE'))THEN
              IF sign(p_net_inv_amount) <> 1 THEN

                    l_return_status := FND_API.G_RET_STS_ERROR;
                    l_msg_data := 'PA_IN_LINE_CRD_NOT_POSITIVE';
                    l_msg_count := 1;

                    RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;

      BEGIN

          /* Get the total credited amount for the selected invoice in Oracle Projects. */

          SELECT ABS(nvl(SUM(nvl(ii.inv_amount,0)),0))
          INTO	l_tot_credited_amt
          FROM	pa_draft_invoices i,
                pa_draft_invoice_items ii
          WHERE	i.project_id = p_project_id
          AND	ii.project_id = i.project_id
          AND	ii.draft_invoice_num = i.draft_invoice_num
          AND   i.draft_invoice_num_credited = p_draft_invoice_num
          AND	i.canceled_flag IS NULL
          AND	i.generation_error_flag = 'N';

          x_tot_credited_amt := l_tot_credited_amt;

      EXCEPTION

         WHEN NO_DATA_FOUND THEN

              l_tot_credited_amt := 0;

      END;

     /* Third Check - The following check is for over-credit application.  We allow
                       over-credit application only for credit action Concession. */

           IF ( p_invoice_amount < (l_tot_credited_amt + p_credit_amount) ) THEN

               /* The IF part is for credit action CONCESSION
                  This check is to warn the user that the Credit amount entered is going to result
                     to over-credit.  If user chooses to continue, Concession Invoice will get
                     processed otherwise no. */
	       IF p_credit_action = 'CONCESSION'  THEN
                  /* Bug 9459594 */
                  OPEN get_intercompany_flag_csr;
                  FETCH get_intercompany_flag_csr
                        INTO l_intercompany_flag;
                  CLOSE get_intercompany_flag_csr;

                  IF (l_intercompany_flag = 'Y')
                  THEN
                    l_use_inv_org_flag := 'N';
                  ELSE
                    OPEN get_centralized_flag_csr;
                    FETCH get_centralized_flag_csr
                          INTO l_use_inv_org_flag;
                    CLOSE get_centralized_flag_csr;
                  END IF;

                  IF (l_use_inv_org_flag = 'Y') THEN
                    OPEN get_misc_details_csr;
                    FETCH get_misc_details_csr
                          INTO l_business_group_id,
                               l_org_st_ver_id,
                               l_base_language,
                               l_invoice_date,
                               l_carry_out_org_id;
                    CLOSE get_misc_details_csr;
                    -- Call pa_invoice_xfer.get_trx_crmemo_types to
                    -- get trx_type_id. Get overapplication flag for
                    -- trx_type_id.
                    pa_invoice_xfer.get_trx_crmemo_types(
                             P_business_group_id=> l_business_group_id,
                             P_carrying_out_org_id => l_carry_out_org_id,
                             P_proj_org_struct_version_id => l_org_st_ver_id,
                             p_basic_language => l_base_language,
                             p_trans_date => l_invoice_date,
                             P_trans_type => x_trx_type,
                             P_crmo_trx_type => x_cm_trx_type,
                             P_error_status  => x_error_status,
                             P_error_message => x_error_message);
                    IF (x_error_status = 1) THEN
                      l_return_status := FND_API.G_RET_STS_ERROR;
                      l_msg_count     := 1;
                      l_msg_data      := x_error_message;
                      RAISE FND_API.G_EXC_ERROR;
                    ELSE
                      -- Get overapplication_flag for x_trx_type
                      OPEN overapplication_csr_2;
                      FETCH overapplication_csr_2
                            INTO l_overapplication_flag;
                      CLOSE overapplication_csr_2;
                    END IF;

                  ELSE
                    OPEN overapplication_csr;
                    FETCH overapplication_csr
                          INTO l_overapplication_flag;
                    CLOSE overapplication_csr;
                  END IF;

                  /* Bug 9459594 */

                  l_return_status := FND_API.G_RET_STS_ERROR;
                  IF (NVL(l_overapplication_flag,'N') = 'Y') THEN
                    l_msg_data := 'PA_OVER_CREDIT_INV';
                  ELSE
                    l_msg_data := 'PA_OVER_CREDIT_INV_ERR';
                  END IF;

                  l_msg_count := 1;

                  RAISE FND_API.G_EXC_ERROR;

               ELSE
               /* The ELSE part is for credit action WRITE-OFF */
                  /* The balance due in PA should not be <= 0.
                      Write-Off cannot be performed if balance due <= 0. */
                  IF sign(p_invoice_amount - l_tot_credited_amt) <> 1 THEN
                     l_return_status := FND_API.G_RET_STS_ERROR;
                     --l_msg_data := 'PA_IN_CRD_NOT_POSITIVE';
                     l_msg_data := 'PA_IN_CRD_NOT_POSITIVE_WO'; --Created new message for Bug3725206
                     l_msg_count := 1;

                     RAISE FND_API.G_EXC_ERROR;

                  ELSE
                  /* The entered credit amount should not exceed the balance due in PA. */
                     l_return_status := FND_API.G_RET_STS_ERROR;
                     l_msg_data := 'PA_IN_CRD_NOT_EXCEED_BAL';
                     l_msg_count := 1;

                     RAISE FND_API.G_EXC_ERROR;

                  END IF;

               END IF;

           END IF;

     /* Fourth check - The entered credit amount should not exceed the balance due in AR
                       for credit action Write-Off. */
          IF p_credit_action = 'WRITE_OFF'  THEN
                  IF p_credit_amount > p_balance_due THEN
                     l_return_status := FND_API.G_RET_STS_ERROR;
                     l_msg_data := 'PA_IN_CRD_EXCEED';
                     l_msg_count := 1;

                     RAISE FND_API.G_EXC_ERROR;
                  END IF;
          END IF;

      /* Initialises the credit related columns as previous credit data might have not been wiped out */

      pa_invoice_actions.init_draft_inv_lines(
                 p_project_id        => p_project_id,
                 p_draft_invoice_num => p_draft_invoice_num,
                 x_return_status     => l_return_status,
                 x_msg_count         => l_msg_count,
                 x_msg_data          => l_msg_data );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

            RAISE FND_API.G_EXC_ERROR;

      END IF;


     /* Fifth check - The total credit amount should not be zero
	                except for the credit_action_type of LINE.
         The purpose of this check is to not allow credit that total to zero in the header
         but allow the same if it is distributed over separate lines - eg +100 and -100 in 2 lines
      */

	  IF     sign(nvl(p_credit_amount,0))=0    THEN

	         if p_credit_action_type = 'LINE'  then
                    null;
                 else
                    l_return_status := FND_API.G_RET_STS_ERROR;
                    l_msg_data := 'PA_IN_ENT_CREDIT_AMT';
                    l_msg_count := 1;

                    RAISE FND_API.G_EXC_ERROR;

		 end if;
          END IF;

     /* Sixth check - the total credit amount should not be negative */
--For bug 4231721 :Changing the if condition from <>1 to <0 So that check is valid only is Credit amount <0
	  IF  sign(nvl(p_credit_amount,0)) < 0    THEN

             l_return_status := FND_API.G_RET_STS_ERROR;
             l_msg_data := 'PA_SU_NEGATIVE_NUM_NOT_ALLOWED';
             l_msg_count := 1;

             RAISE FND_API.G_EXC_ERROR;

	  END IF;


  EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

            /* ATG Changes */
             x_tot_credited_amt := null;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

            /* ATG Changes */
             x_tot_credited_amt := null;

       WHEN others then
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := SUBSTR(SQLERRM,1,100);

            /* ATG Changes */
             x_tot_credited_amt := null;

  END validate_invoice_amount;

  /*-----------------------------------------------------------------------------------------+
   |   Procedure  :   init_draft_inv_lines                                                   |
   |   Purpose    :   To initialize the credit related columns in draft invoice lines table  |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_draft_invoice_num   IN      Draft invoice for which credit action is to be done   |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

  PROCEDURE init_draft_inv_lines(
             p_project_id        IN     NUMBER,
             p_draft_invoice_num IN     NUMBER,
             x_return_status     OUT   NOCOPY VARCHAR2,
             x_msg_count         OUT   NOCOPY NUMBER,
             x_msg_data          OUT   NOCOPY VARCHAR2)   IS


         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;

  BEGIN

      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      x_msg_count        := 0;

      /* Update credit_process_flag, credit_amount to NULL */

      update pa_draft_invoice_items
      set credit_process_flag = NULL,
          credit_amount = NULL
      where project_id = p_project_id
      and   draft_invoice_num = p_draft_invoice_num;

  EXCEPTION

       WHEN others then
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := SUBSTR(SQLERRM,1,100);


  END init_draft_inv_lines;


  /*----------------------------------------------------------------------------------------------+
   |   Procedure  :   update_credit_qual_lines                                                    |
   |   Purpose    :   To mark the draft invoice lines which have been selected for                |
   |                  crediting                                                                   |
   |   Parameters :                                                                               |
   |     ==================================================================================       |
   |     Name                       Mode    Description                                           |
   |     ==================================================================================       |
   |     p_project_id               IN      Project ID                                            |
   |     p_credit_action            IN      Indicates if credit is WRITE-OFF/CONCESSION           |
   |     p_credit_action_type       IN      Indicates if credit action type is                    |
   |                                        SUMMARY/GROUP/LINES                                   |
   |     p_draft_invoice_num        IN      Draft invoice for which credit action is to be done   |
   |     p_draft_invoice_line_num   IN      Draft invoice line which has to be credited           |
   |     p_line_credit_amount       IN      Total credit amount on the invoice                    |
   |     x_return_status            OUT     Return status of this procedure                       |
   |     x_msg_count                OUT     Error message count                                   |
   |     x_msg_data                 OUT     Error message                                         |
   |     ==================================================================================       |
   +---------------------------------------------------------------------------------------------*/

  Procedure update_credit_qual_lines (
             p_project_id             IN NUMBER,
             p_credit_action          IN VARCHAR2,
             p_credit_action_type     IN VARCHAR2,
             p_draft_invoice_num      IN NUMBER,
             p_draft_invoice_line_num IN NUMBER,
             p_line_credit_amount     IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2)   IS

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;

  BEGIN

      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      x_msg_count        := 0;

      /* In the case of credit action type  at

         a) Invoice SUMMARY level all the lines of the invoice has to be credited.
            Basically the total credit amount will be pro-rated across all the lines. Credit amount will not
            be populated in the lines as this scenario exists currently and should go through the same flow.
            Only the credit_process_flag will be set to 'Y' for all lines. This is required to indicate that
            while calculating the rounding difference the sum of ALL line amounts (credit invoice) should match
            the credit amount entered by the user. In this case p_line_credit_amount/p_draft_invoice_line_num will be null

         b) GROUP level (user selects specific lines and gives credit amount which has to pro-rated only on those lines)
            The total credit amount will be pro-rated across the specified lines by subsequent API's. The line selected for
            crediting by the user will be specified by p_draft_invoice_line_num. Since the credit amount will be given as one
            whole amount, p_line_credit_amount will be NULL. Credit_process_flag will be set to 'Y' for the line specified
            by p_draft_invoice_line_num. While calculating the rounding difference the sum of line amounts
            SELECTED BY USER (INFERRED BY CREDIT_PROCESS_FLAG) should match the credit amount entered by the user.
            In this case p_line_credit_amount will be null

         c) LINES level (user selects the line and specifies the credit amount on the line)
            No pro-ration of credit amount is to be performed as it is specified one on one on the line.  No rounding also
            needs to be checked. Both p_line_credit_amount/p_draft_invoice_line_num will be specified

         Both (b) and (c) will be called in a loop for as many lines selected by the user in Invoice Review Form
       */

      if p_credit_action_type = 'SUMMARY' then

         /* Update all lines of draft_invoice_items for credit_process_flag = 'Y' */

         update pa_draft_invoice_items
         set credit_process_flag = 'Y'
         where project_id = p_project_id
         and   draft_invoice_num = p_draft_invoice_num;

      else


         if p_credit_action_type = 'GROUP' then

            /* Update specific line of draft_invoice_items for credit_process_flag = 'Y' */

            update pa_draft_invoice_items
            set credit_process_flag = 'Y'
            where project_id = p_project_id
            and   draft_invoice_num = p_draft_invoice_num
            and   line_num = p_draft_invoice_line_num;

         elsif p_credit_action_type = 'LINE' then

            /* Update specific line of draft_invoice_items for credit_process_flag = 'Y'and credit_amount = p_line_credit_amount */

            update pa_draft_invoice_items
            set credit_process_flag = 'Y',
                credit_amount = p_line_credit_amount
            where project_id = p_project_id
            and   draft_invoice_num = p_draft_invoice_num
            and   line_num = p_draft_invoice_line_num;

         end if;

      end if;

  EXCEPTION

       WHEN others then
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := SUBSTR(SQLERRM,1,100);

  END update_credit_qual_lines;

  /*----------------------------------------------------------------------------------------------+
   |   Procedure  :   validate_line_credit_amount                                                 |
   |   Purpose    :   To validate the credit amount on the specificed invoice line                |
   |   Parameters :                                                                               |
   |     ==================================================================================       |
   |     Name                       Mode    Description                                           |
   |     ==================================================================================       |
   |     p_project_id               IN      Project ID                                            |
   |     p_credit_action            IN      Indicates if credit is WRITE-OFF/CONCESSION           |
   |     p_credit_action_type       IN      Indicates if credit action type is                    |
   |                                        SUMMARY/GROUP/LINES                                   |
   |     p_draft_invoice_num        IN      Draft invoice for which credit action is to be done   |
   |     p_draft_invoice_line_num   IN      Draft invoice line which has to be credited           |
   |     p_inv_amount               IN      Invoice amount on the specified invoice line          |
   |     p_credit_amount            IN      Credit amount on the specified invoice line           |
   |     x_return_status            OUT     Return status of this procedure                       |
   |     x_msg_count                OUT     Error message count                                   |
   |     x_msg_data                 OUT     Error message                                         |
   |     ==================================================================================       |
   +---------------------------------------------------------------------------------------------*/

  Procedure validate_line_credit_amount (
             p_project_id             IN NUMBER,
             p_credit_action          IN VARCHAR2,
             p_credit_action_type     IN VARCHAR2,
             p_draft_invoice_num      IN NUMBER,
             p_draft_invoice_line_num IN NUMBER,
             p_inv_amount             IN NUMBER,
             p_credit_amount          IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2)   IS

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;


  BEGIN

      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      x_msg_count        := 0;

      /*  If credit is performed at GROUP, the total credit amount passed should not exceed the
          total selected line invoice amount for credit action WRITE-OFF.  For Concession, we allow
          over credit application. */

      IF p_credit_action_type = 'GROUP' THEN

      /* First check - Total credit amount should not exceed the net invoice amount of the selected
                        lines.  This is true for Write-Off only. */
         IF p_credit_action = 'CONCESSION' THEN
            NULL;
         ELSE
            IF p_credit_amount > p_inv_amount THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
               l_msg_data :=  'PA_IN_CRD_NOT_EXCEED_BAL';

               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

      ELSE
        /* This ELSE part is for the line credit amount check when the user
              chooses to enter the credit amount by line. */

        /* First check - Line credit amount should be greater than zero */

         IF p_credit_amount = 0  THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            l_msg_data := 'PA_IN_ENT_CREDIT_AMT';
            l_msg_count := 1;

            RAISE FND_API.G_EXC_ERROR;

         END IF;

        /* Second check - Line credit amount should be of the same sign as the line invoice amount */

         IF sign(p_inv_amount) <> sign(p_credit_amount) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            l_msg_data := 'PA_IN_CRD_SIGN_INV';
            l_msg_count := 1;

            RAISE FND_API.G_EXC_ERROR;

         END IF;
      END IF;


       /* Check that credit amount does not exceed invoice amount on the line
          This check has been removed from here since the check needs to be done in forms
          because we allow over-credit on the line for CONCESSION
       */


  EXCEPTION

       WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

       WHEN others then
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := SUBSTR(SQLERRM,1,100);

  END validate_line_credit_amount;

  /*-----------------------------------------------------------------------------------------+
   |   Procedure  :   distribute_credit_amount                                               |
   |   Purpose    :   To pro-rate the total credit amount across the lines selected for      |
   |                  crediting on the specified invoice                                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_credit_action       IN      Indicates if credit is WRITE-OFF/CONCESSION           |
   |     p_credit_action_type  IN      Indicates if credit action type is                    |
   |                                   SUMMARY/GROUP/LINES                                   |
   |     p_draft_invoice_num   IN      Draft invoice for which credit action is to be done   |
   |     p_total_credit_amount IN      Total credit amount on the invoice                    |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


  Procedure distribute_credit_amount (
             p_project_id             IN NUMBER,
             p_credit_action          IN VARCHAR2,
             p_credit_action_type     IN VARCHAR2,
             p_draft_invoice_num      IN NUMBER,
             p_total_credit_amount    IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2)   IS

      l_inv_amount   NUMBER;
      l_inv_currency_code VARCHAR2(3);
      l_return_status            VARCHAR2(30) := NULL;
      l_msg_count                NUMBER       := NULL;
      l_msg_data                 VARCHAR2(250) := NULL;

  BEGIN

      x_return_status    := FND_API.G_RET_STS_SUCCESS;
      x_msg_count        := 0;

--      insert into bss_conc (serial_no, proc_ind) values (1, 'DIST_CREDIT_AMT');

      /* This API will be called only in the case of GROUP/LINE level as SUMMARY will go through the existing
         flow as defined in paisql.lpc
         In case of GROUP, the total credit amount has to be pro-rated across the user selected lines indicated by
         credit_process_flag = 'Y'
         In case of LINES the credit amount is already populated  on the lines that are to be credited
         In case of GROUP/LINES, after the credit amount is populated in the standard lines, corresponding retention lines
         are also to be credited . A separate API distribute_credit_amount_retn will be called to do the same */

      if p_credit_action_type = 'GROUP' then

            /* Get the sum of invoice amount of the user selected lines (credit_process_flag = 'Y'). Apply the ratio
            of p_total_credit_amount over sum_invoice_amount on the line invoice amount. Inv_currency_code is required
            to define the precision of the computed credit amount */

            select sum(dii.inv_amount), max(di.inv_currency_code)
            into l_inv_amount, l_inv_currency_code
            from pa_draft_invoice_items dii, pa_draft_invoices di
            where di.project_id = p_project_id
            and   di.draft_invoice_num = p_draft_invoice_num
            and   dii.project_id = di.project_id
            and   dii.draft_invoice_num = di.draft_invoice_num
            and   nvl(dii.credit_process_flag,'N') = 'Y' ;

            update pa_draft_invoice_items dii
            set credit_amount =
                  pa_currency.round_trans_currency_amt(
                            (inv_amount * (p_total_credit_amount/l_inv_amount)),
                            rtrim(l_inv_currency_code))
            where project_id = p_project_id
            and   draft_invoice_num = p_draft_invoice_num
            and   nvl(dii.credit_process_flag,'N') = 'Y' ;

      end if;

      /* Call API to calculate credit amount for corresponding retention lines */

      pa_invoice_actions.distribute_credit_amount_retn(
                 p_project_id        => p_project_id,
                 p_draft_invoice_num => p_draft_invoice_num,
                 x_return_status     => l_return_status,
                 x_msg_count         => l_msg_count,
                 x_msg_data          => l_msg_data );

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

            RAISE FND_API.G_EXC_ERROR;

      END IF;



  EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK;
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK;
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

       WHEN others then
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := SUBSTR(SQLERRM,1,100);

  END distribute_credit_amount;

  /*-----------------------------------------------------------------------------------------+
   |   Procedure  :   distribute_credit_amount_retn                                          |
   |   Purpose    :   To distribute the credit amount on the retention lines based on the    |
   |                  corresponding standard line's credit amount                            |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_draft_invoice_num   IN      Draft invoice for which credit action is to be done   |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/


  Procedure distribute_credit_amount_retn (
             p_project_id             IN NUMBER,
             p_draft_invoice_num      IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2)   IS


        l_retention_percentage number;
        l_retention_rule_id number;
        l_retention_line_num number;
        l_inv_currency_code varchar2(3);

        l_tot_credit_amount   number;
        l_amount   number;
        l_credit_amount   number;
        l_retn_credit_amount   number;
        l_retained_amount   number;
        l_line_processed    VARCHAR2(5);

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;

  BEGIN

        x_return_status    := FND_API.G_RET_STS_SUCCESS;
        x_msg_count        := 0;

/*        insert into bss_conc
          (serial_no, proc_ind)
        values(2, 'DISTRIBUTE_RETN_CREDIT');
*/
        /* Check if retention for this invoice is generated using old/new model
           In old model, retention% will be stamped on the draft invoice

           This SQL also ensures that the invoice does have RETENTION LINE */

        SELECT nvl(retention_percentage,0), inv_currency_code
        INTO l_retention_percentage, l_inv_currency_code
        FROM pa_draft_invoices
        WHERE project_id = p_project_id
        AND draft_invoice_num = p_draft_invoice_num
        AND EXISTS (select null from pa_draft_invoice_items
                    WHERE project_id = p_project_id
                    AND draft_invoice_num = p_draft_invoice_num
                    AND invoice_line_type = 'RETENTION');

       if nvl(l_retention_percentage, 0) <> 0 THEN  -- old model

          /* In old model, the retention credit amount will be calculated by applying the retention% on the sum of
             the credit amount stamped on the draft invoice lines

             Since retention amount is always negative, the calculated retention credit amount is multiplied by -1 */

          select sum(nvl(credit_amount,0))
          into l_tot_credit_amount
          from pa_draft_invoice_items
          where project_id = p_project_id
          and  draft_invoice_num = p_draft_invoice_num;

          l_retn_credit_amount := (-1) * (l_tot_credit_amount * l_retention_percentage)/100;

          /* In old model there will be only one retention line for an invoice. So credit amount is stamped on that line */

          update pa_draft_invoice_items
          set credit_amount =
               pa_currency.round_trans_currency_amt(l_retn_credit_amount, rtrim(l_inv_currency_code))
          where project_id = p_project_id
          and  draft_invoice_num = p_draft_invoice_num
          and invoice_line_type = 'RETENTION';

       else -- NEW MODEL

           /* select the standard lines which are to be credited within a loop
              For every line of the draft invoice item, we require the retained amount
                 (will be in invoice processing currency) , retention rule id and retention_line_num (indicates which line
                 in the draft_invoice_items corresponds to retention of this standard line.
                 Once we get these, store these values into local variables and set line_processed_flag to TRUE
                 Call compute_retn_credit_amount API with the fetched values. The logic to get these values will be:

              If the line represents event (event_num will be not null)
                 the retained amount (will be in invoice processing currency) ,
                 retention rule id, retention_line_num  will be stored on the line itself. Set line_processed flag to TRUE

              If line_processed is FALSE, then check in ERDL( Could be WRITE-ON events) with project_id, draft_invoice_num,
                 and line_num.  One line of draft invoice item may have multiple lines in ERDL. Since we need to get the
                 retention info for every retention_rule_id, we group by retention_rule_id and get sum of the amount.
                 Set line_processed_flag to TRUE

              If line_processed is FALSE, then check in RDL( Could be EI's) with project_id, draft_invoice_num,
                 and line_num.  One line of draft invoice item may have multiple lines in RDL. Since we need to get the
                 retention info for every retention_rule_id, we group by retention_rule_id and get sum of the amount.
                 Set line_processed_flag to TRUE
           */

           for inv_lines in (
               select nvl(dii.line_num,0) line_num,
                           nvl(dii.event_num,0) event_num,
                           nvl(dii.retn_draft_invoice_line_num,0) retention_line_num,
                           nvl(dii.retention_rule_id,-1) retention_rule_id,
                           nvl(dii.retained_amount,0)  retained_amount,
                           dii.amount          amount,
                           dii.credit_amount   credit_amount
                from pa_draft_invoice_items dii
                where project_id = p_project_id
                AND draft_invoice_num = p_draft_invoice_num
                AND invoice_line_type <> 'RETENTION'
                AND nvl(dii.credit_amount, 0) <> 0
                order by dii.line_num) LOOP

                l_amount          := inv_lines.amount;
                l_credit_amount   := inv_lines.credit_amount;
                l_line_processed  := 'FALSE';

                if nvl(inv_lines.event_num,0) <> 0 then -- events line

                   if nvl(inv_lines.retained_amount,0) <> 0  then -- retention exists for this line

                      l_line_processed  := 'TRUE';
                      l_retention_line_num := inv_lines.retention_line_num;
                      l_retention_rule_id := inv_lines.retention_rule_id;
                      l_retained_amount := inv_lines.retained_amount;

/*                      insert into bss_conc values (3, p_project_id, p_draft_invoice_num,
                                                   'DII', l_retention_rule_id, l_retention_line_num,
                                                    l_retained_amount, l_amount, l_credit_amount, inv_lines.line_num, 'RETN');
*/
                      compute_retn_credit_amount (
                                     p_project_id         => p_project_id,
                                     p_draft_invoice_num  => p_draft_invoice_num,
                                     p_retention_rule_id  => l_retention_rule_id,
                                     p_retention_line_num => l_retention_line_num,
                                     p_retained_amount    => l_retained_amount,
                                     p_amount             => l_amount,
                                     p_credit_amount      => l_credit_amount,
                                     x_return_status      => l_return_status,
                                     x_msg_count          => l_msg_count,
                                     x_msg_data          => l_msg_data );

                      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                         RAISE FND_API.G_EXC_ERROR;

                      END IF;

                   end if; -- retained_amount <> 0

                end if; -- events line

                if l_line_processed = 'FALSE' then

                   for erdl_lines in (
                       select nvl(erdl.retn_draft_invoice_line_num, -1) retention_line_num,
                           nvl(erdl.retention_rule_id,-1) retention_rule_id,
                           nvl(sum(nvl(erdl.retained_amount,0)),0) retained_amount
                       from pa_cust_event_rdl_all erdl
                       where project_id = p_project_id
                       AND draft_invoice_num = p_draft_invoice_num
                       AND draft_invoice_item_line_num = inv_lines.line_num
                       group by nvl(erdl.retn_draft_invoice_line_num,-1) , nvl(erdl.retention_rule_id,-1) ) LOOP

                       l_line_processed  := 'TRUE';
                       l_retention_line_num := erdl_lines.retention_line_num;
                       l_retention_rule_id := erdl_lines.retention_rule_id;
                       l_retained_amount := nvl(erdl_lines.retained_amount,0);

                       if l_retained_amount <> 0 then -- retention exists for this line

/*                      insert into bss_conc values (4,p_project_id, p_draft_invoice_num,
                                                   'ERDL', l_retention_rule_id, l_retention_line_num,
                                                    l_retained_amount, l_amount, l_credit_amount, inv_lines.line_num, 'RETN');
*/
                          compute_retn_credit_amount (
                                     p_project_id         => p_project_id,
                                     p_draft_invoice_num  => p_draft_invoice_num,
                                     p_retention_rule_id  => l_retention_rule_id,
                                     p_retention_line_num => l_retention_line_num,
                                     p_retained_amount    => l_retained_amount,
                                     p_amount             => l_amount,
                                     p_credit_amount      => l_credit_amount,
                                     x_return_status      => l_return_status,
                                     x_msg_count          => l_msg_count,
                                     x_msg_data          => l_msg_data );


                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                RAISE FND_API.G_EXC_ERROR;

                          END IF;

                       end if; -- l_retained_amunt <> 0

                   end loop; -- erdl_lines cursor

                end if; -- l_line_processed = 'FALSE'

                if l_line_processed = 'FALSE' then

                   for rdl_lines in (
                       select nvl(rdl.retn_draft_invoice_line_num, -1) retention_line_num,
                           nvl(rdl.retention_rule_id,-1) retention_rule_id,
                           sum(nvl(rdl.retained_amount,0)) retained_amount
                       from pa_cust_rev_dist_lines_all rdl
                       where project_id = p_project_id
                       AND draft_invoice_num = p_draft_invoice_num
                       AND draft_invoice_item_line_num = inv_lines.line_num
                       group by nvl(rdl.retn_draft_invoice_line_num,-1) , nvl(rdl.retention_rule_id,-1) ) LOOP

                       l_line_processed  := 'TRUE';
                       l_retention_line_num := rdl_lines.retention_line_num;
                       l_retention_rule_id := rdl_lines.retention_rule_id;
                       l_retained_amount := nvl(rdl_lines.retained_amount,0);

                       if l_retained_amount <> 0 then -- retention exists for this line

/*                      insert into bss_conc values (5, p_project_id, p_draft_invoice_num,
                                                   'RDL', l_retention_rule_id, l_retention_line_num,
                                                    l_retained_amount, l_amount, l_credit_amount, inv_lines.line_num,'RETN');
*/
                          compute_retn_credit_amount (
                                     p_project_id         => p_project_id,
                                     p_draft_invoice_num  => p_draft_invoice_num,
                                     p_retention_rule_id  => l_retention_rule_id,
                                     p_retention_line_num => l_retention_line_num,
                                     p_retained_amount    => l_retained_amount,
                                     p_amount             => l_amount,
                                     p_credit_amount      => l_credit_amount,
                                     x_return_status      => l_return_status,
                                     x_msg_count          => l_msg_count,
                                     x_msg_data          => l_msg_data );

                          IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

                          ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                                RAISE FND_API.G_EXC_ERROR;

                          END IF;

                       end if; -- l_retained_amunt <> 0

                   end loop; -- rdl_lines cursor

                end if; -- l_line_processed = 'FALSE'

           end loop; -- inv_lines cursor

           /* Since retention credit amount in the  original invoice should be negative and precision should be based
              on currency code we  multiply by -1 and round the amount based on inv_currency_code
           */
           update pa_draft_invoice_items
           set credit_amount =
                     pa_currency.round_trans_currency_amt(credit_amount, rtrim(l_inv_currency_code)) * -1
           where project_id = p_project_id
           and  draft_invoice_num = p_draft_invoice_num
           and invoice_line_type = 'RETENTION';

       end if; -- NEW MODEL

  EXCEPTION

       WHEN no_data_found then
            pa_mcb_invoice_pkg.log_message('No retention lines');

        WHEN FND_API.G_EXC_ERROR THEN
             ROLLBACK;
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK;
             x_return_status := l_return_status;
             x_msg_count := l_msg_count;
             x_msg_data := l_msg_data;

       WHEN others then
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := SUBSTR(SQLERRM,1,100);

  END distribute_credit_amount_retn;


  /*-----------------------------------------------------------------------------------------+
   |   Procedure  :   compute_retn_credit_amount                                             |
   |   Purpose    :   To compute retention credit amount based on the retention setup of     |
   |                  the standard lines                                                     |
   |   Parameters :                                                                          |
   |     ==================================================================================  |
   |     Name                             Mode    Description                                |
   |     ==================================================================================  |
   |     p_project_id          IN      Project ID                                            |
   |     p_draft_invoice_num   IN      Draft invoice for which retention is to be credited   |
   |     p_retention_rule_id   IN      Retention rule id applied on the standard line        |
   |     p_retention_line_num  IN      Draft invoice line num on which retention credit amt  |
   |                                   is to be stamped/computed                             |
   |     p_retained_amount     IN      Retained amount on the standard invoice line          |
   |     p_amount              IN      Line amount of the standard line for which retention  |
   |                                   credit amount is to be computed                       |
   |     p_credit_amount       IN      Line credit amount of the standard line for which     |
   |                                   retention credit amount is to be computed             |
   |     x_return_status       OUT     Return status of this procedure                       |
   |     x_msg_count           OUT     Error message count                                   |
   |     x_msg_data            OUT     Error message                                         |
   |     ==================================================================================  |
   +----------------------------------------------------------------------------------------*/

  Procedure compute_retn_credit_amount (
             p_project_id             IN NUMBER,
             p_draft_invoice_num      IN NUMBER,
             p_retention_rule_id      IN NUMBER,
             p_retention_line_num     IN NUMBER,
             p_retained_amount        IN NUMBER,
             p_amount                 IN NUMBER,
             p_credit_amount          IN NUMBER,
             x_return_status          OUT   NOCOPY VARCHAR2,
             x_msg_count              OUT   NOCOPY NUMBER,
             x_msg_data               OUT   NOCOPY VARCHAR2)   IS

       l_threshold_amount number;
       l_retention_percentage number;
       l_retention_amount number;
       l_retn_credit_amount number;

         l_return_status            VARCHAR2(30) := NULL;
         l_msg_count                NUMBER       := NULL;
         l_msg_data                 VARCHAR2(250) := NULL;
  BEGIN

        x_return_status    := FND_API.G_RET_STS_SUCCESS;
        x_msg_count        := 0;

        /* If the retention setup defines only the retention % (no threshold_amount, no retention amount)
           then this percentage will be applied on the line credit amount (p_credit_amount) to get retention
           credit amount

           If there is a threshold amount/retention amount defined, it is not possible to figure out the value of these
           amounts at the point invoice was generated. So we get the ratio of retained amount over line amount of the
           standard line on the line credit amount to get retention credit amount */

        select nvl(threshold_amount,0), nvl(retention_percentage,0), nvl(retention_amount,0)
        into l_threshold_amount, l_retention_percentage, l_retention_amount
        from pa_proj_retn_rules
        where retention_rule_id = p_retention_rule_id;


        if (l_threshold_amount <> 0) OR (l_retention_amount <> 0) then
           l_retn_credit_amount := (p_retained_amount/p_amount) * p_credit_amount ;
        else

           l_retn_credit_amount := (p_credit_amount * l_retention_percentage) / 100 ;

        end if;


        /* Since  one line of draft invoice item may have multiple lines in RDL/ERDL this procedure may be called more than
           once for the same line. So credit amount is acutally summed up */

        update pa_draft_invoice_items
        set credit_amount = nvl(credit_amount ,0) + l_retn_credit_amount
        where project_id = p_project_id
        and draft_invoice_num = p_draft_invoice_num
        and line_num =  p_retention_line_num;


  EXCEPTION

       WHEN no_data_found then
            pa_mcb_invoice_pkg.log_message('No retention lines');

       WHEN others then
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_count := l_msg_count;
            x_msg_data := SUBSTR(SQLERRM,1,100);

  END compute_retn_credit_amount;

  /* End Concession invoice modification */

/*------------- End of Public Procedure/Function Declarations ----------------*/

end PA_Invoice_Actions;

/
