--------------------------------------------------------
--  DDL for Package Body PA_PWP_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PWP_SUMM_PKG" AS
--  $Header: PAPWPSMB.pls 120.0.12010000.17 2009/08/07 11:56:03 sosharma noship $

-- This procedure populates data in PA_PWP_CUSTOMER_SUMM_ALL table.
-- The data populated in PA_PWP_CUSTOMER_SUMM_ALL table is used in subcontractor
--(supplier) workbench.
PROCEDURE Populate_summary
        (P_Project_Id IN NUMBER)
    IS
        l_start_date DATE ;
        l_end_date DATE ;
	    l_user_id     number(15);
        l_date date ;
	    l_org_id number(15);
BEGIN

        DELETE
        FROM   PA_PWP_CUSTOMER_SUMM WHERE project_id = P_Project_Id ;

    SELECT    org_id
     INTO l_org_id
     FROM pa_implementations;


 --Insert the Invoice level attributes to the temp Table
        INSERT
        INTO   PA_PWP_CUSTOMER_SUMM
               (      ORG_ID
                    , PROJECT_ID
                    , draft_invoice_num
                    , RA_INVOICE_NUMBER
                    , DRAFT_INVOICE_NUM_CREDITED
                    , SYSTEM_REFERENCE
                    , TRANSFER_STATUS_CODE
                    , CUSTOMER_ID
                    , CUSTOMER_NAME
                    , CUSTOMER_NUMBER
                    , INVOICE_DATE
                    , INVOICE_STATUS
		    , INVOICE_CLASS
                    , AGREEMENT_NUM
                    , BILL_THROUGH_DATE
                    , PROJFUNC_INVTRANS_RATE_TYPE
                    , PROJFUNC_INVTRANS_RATE_DATE
                    , INV_CURRENCY_CODE
		    , CREATED_BY
                    , CREATION_DATE
                    , LAST_UPDATED_BY
                    , LAST_UPDATE_DATE
               )

SELECT    l_org_id,I.PROJECT_ID
             , I.draft_invoice_num
             , I.RA_INVOICE_NUMBER
             , I.DRAFT_INVOICE_NUM_CREDITED
             , I.SYStem_reference
             , I.TRANSFER_STATUS_CODE
             , I.CUSTOMER_ID
             , C.CUSTOMER_NAME
             , C.CUSTOMER_NUMBER
             , I.INVOICE_DATE
             , LK.MEANING INVOICE_STATUS_M
	     ,(select LK3.MEANING FROM PA_LOOKUPS LK3 WHERE LK3.LOOKUP_TYPE = 'INVOICE_CLASS'
			AND LK3.LOOKUP_CODE = DECODE(ORG_INV.CANCELED_FLAG, 'Y', 'CANCEL',
					            DECODE(I.WRITE_OFF_FLAG, 'Y', 'WRITE_OFF',
					            DECODE(I.concession_flag, 'Y', 'CONCESSION',
					            DECODE(NVL(I.DRAFT_INVOICE_NUM_CREDITED, 0), 0, 'INVOICE',
					            'CREDIT_MEMO'))))
			AND LK3.ENABLED_FLAG = 'Y'
			AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(LK3.START_DATE_ACTIVE, SYSDATE- 1))
		        AND TRUNC(NVL(LK3.END_DATE_ACTIVE, SYSDATE)))
             , A.AGREEMENT_NUM
             , I.BILL_THROUGH_DATE
             ,  PA_MULTI_CURRENCY.GET_USER_CONVERSION_TYPE(I.PROJFUNC_INVTRANS_RATE_TYPE) -- Bug 8205105
             , I.PROJFUNC_INVTRANS_RATE_DATE
             , I.INV_CURRENCY_CODE
	     , l_user_id
             , l_date
             , l_user_id
             , l_date
        FROM   PA_DRAFT_INVOICES_ALL I
	     , PA_DRAFT_INVOICES_ALL  ORG_INV
             , PA_CUSTOMERS_V C
              ,PA_LOOKUPS LK
              ,PA_AGREEMENTS_ALL A
        WHERE   I.AGREEMENT_ID = A.AGREEMENT_ID
           and    I.PROJECT_ID = P_Project_Id
	   AND C.CUSTOMER_ID  = I.CUSTOMER_ID
           AND C.CUSTOMER_ID  =  A.CUSTOMER_ID
	   AND ORG_INV.PROJECT_ID (+) = I.PROJECT_ID
           AND ORG_INV.DRAFT_INVOICE_NUM (+) = I.DRAFT_INVOICE_NUM_CREDITED
           AND LK.LOOKUP_TYPE = 'INVOICE STATUS'
  AND LK.LOOKUP_CODE = DECODE(I.GENERATION_ERROR_FLAG, 'Y', 'GENERATION ERROR',
                             DECODE(I.APPROVED_DATE, NULL, 'UNAPPROVED',
                             DECODE(I.RELEASED_DATE, NULL, 'APPROVED',
                                      DECODE(I.TRANSFER_STATUS_CODE,
                                                    'P', 'RELEASED',
                                                    'X', 'REJECTED IN TRANSFER',
                                                    'T', 'TRANSFERRED',
                                                    'A', 'ACCEPTED',
                                                    'R', 'REJECTED' ) ) ) ) ;

--Update the  Bill Amount /Line Amounts for  PFC,PC,INV

        UPDATE PA_PWP_CUSTOMER_SUMM pwp
        SET
               (     PFC_BILL_AMOUNT     -- Bug 7707807   re-ordered the columns
                    ,PFC_LINE_AMOUNT
					,PFC_OUTSTANDING_AMOUNT    --Bug 8200941 Outstanding amount columns added in the query
					,PC_BILL_AMOUNT
                    ,PC_LINE_AMOUNT
					,PC_OUTSTANDING_AMOUNT
                    ,INV_BILL_AMOUNT
                    ,INV_LINE_AMOUNT
					,INV_OUTSTANDING_AMOUNT


               )
               =
               (SELECT
			         SUM(PROJFUNC_BILL_AMOUNT) a
                    ,SUM(PROJFUNC_BILL_AMOUNT) b
					,SUM(PROJFUNC_BILL_AMOUNT)c
                    ,SUM(PROJECT_BILL_AMOUNT)d
                    ,SUM(PROJECT_BILL_AMOUNT)e
					,SUM(PROJECT_BILL_AMOUNT)f
                    ,SUM(INV_AMOUNT)g
                    ,SUM(INV_AMOUNT)h
					,SUM(INV_AMOUNT) i
               FROM   pa_draft_invoice_items pdii
               WHERE  pdii .project_id       = pwp.project_id
                  AND pdii.draft_invoice_num = pwp.draft_invoice_num
               )
        WHERE  project_id = P_Project_Id;

--Update columns with AR amounts .
--Only records of interfaced invoices will get updated

        UPDATE PA_PWP_CUSTOMER_SUMM pwp
        SET
               (
                      INV_BILL_AMOUNT
                    , INV_OUTSTANDING_AMOUNT
                    , INV_RECIEPT_AMOUNT
                    , INV_ADJUSTMENT_AMOUNT
                    , INV_TAX_AMOUNT
               )
               =
               (SELECT SUM(ARP.amount_due_original )
                    , SUM(ARP.amount_due_remaining)
                    , SUM(ARP.amount_applied)
                    , SUM(nvl(ARP.amount_credited,0)) + SUM(nvl(ARP.amount_adjusted,0))  -- Bug 7785173 Added NVL
                    , SUM(ARP.TAX_ORIGINAL) Tax
               FROM   AR_PAYMENT_SCHEDULES ARP
               WHERE  PWP.SYSTEM_REFERENCE = ARP.CUSTOMER_TRX_ID
               )
        WHERE  project_id = P_Project_Id
        AND    TRANSFER_STATUS_CODE = 'A';

-- Get the start and end dates  of the Latest Open GL Period.
-- This will be the open period with highest start date


        SELECT start_date
             , end_date
        INTO   l_start_date
             ,l_end_date
        FROM   gl_period_statuses GL1
             , pa_implementations pa
        WHERE  GL1.set_of_books_id = pa.set_of_books_id
           AND GL1.APPLICATION_ID  = 101	   --bug 8208525
           AND GL1.CLOSING_STATUS  = 'O'
           AND start_date          =
               (SELECT MAX(GL2.start_date)
               FROM   gl_period_statuses GL2
               WHERE  GL2.set_of_books_id = GL1.set_of_books_id
                  AND GL2.APPLICATION_ID  = 101
                  AND GL2.CLOSING_STATUS  = 'O'
               );

--Update  current period  Amounts
/*
        UPDATE PA_PWP_CUSTOMER_SUMM pwp
        SET
               (
                      INV_CP_BILL_AMOUNT
                     ,INV_CP_RECIEPT_AMOUNT
               )
               =
               (SELECT SUM(ARP.amount_due_original )
                    , SUM(ARP.amount_applied)
               FROM   AR_PAYMENT_SCHEDULES ARP
               WHERE  PWP.SYSTEM_REFERENCE = ARP.CUSTOMER_TRX_ID
                  AND GL_DATE BETWEEN l_start_date AND l_end_date
               )
        WHERE  project_id = P_Project_Id;  */  -- bug 8208525  commented the code .

	-- FOR UNINTERFACED INVOCIES...

UPDATE PA_PWP_CUSTOMER_SUMM pwp
        SET  ( INV_CP_BILL_AMOUNT
		     ,PFC_CP_BILL_AMOUNT
			 ,PC_CP_BILL_AMOUNT)
               =
               (SELECT  SUM(INV_AMOUNT )                 -- bug 8225160
                       ,SUM(PROJFUNC_BILL_AMOUNT)
					   ,SUM(PROJECT_BILL_AMOUNT)
                FROM   pa_draft_invoice_items pdii,
				       pa_draft_invoices_all  pda
               WHERE  pwp.project_id =  pda.project_id
			      AND  pwp.draft_invoice_num  = pda.draft_invoice_num
				  AND  pda.gl_date  between  l_start_date AND l_end_date
			      AND pdii.project_id       = pwp.project_id
                  AND pdii.draft_invoice_num = pwp.draft_invoice_num
                  AND  pda.project_id  =  pdii.project_id
               )
        WHERE  PWP.project_id = P_Project_Id AND PWP.TRANSFER_STATUS_CODE <> 'A';

  --  FOR INTERFACED INVOICES...


  UPDATE PA_PWP_CUSTOMER_SUMM pwp
        SET   INV_CP_BILL_AMOUNT  =  (SELECT SUM(ARP.amount_due_original )

               FROM   AR_PAYMENT_SCHEDULES ARP,
                      PA_DRAFT_INVOICES  PDA
               WHERE  PWP.SYSTEM_REFERENCE = ARP.CUSTOMER_TRX_ID
                      AND ARP.CUSTOMER_TRX_ID =  PDA.SYSTEM_REFERENCE
                      AND PDA.GL_DATE BETWEEN l_start_date AND l_end_date
               )
        WHERE  PWP.project_id = P_Project_Id AND PWP.TRANSFER_STATUS_CODE = 'A';

--FOR RECEIPT AMOUNTS

UPDATE PA_PWP_CUSTOMER_SUMM PWP
        SET   INV_CP_RECIEPT_AMOUNT  =
		                (SELECT SUM(AMOUNT_APPLIED) FROM AR_RECEIVABLE_APPLICATIONS_ALL  ARA
 						 WHERE
		                 PWP.SYSTEM_REFERENCE  =  ARA.APPLIED_CUSTOMER_TRX_ID
                         AND ARA.GL_DATE BETWEEN l_start_date AND l_end_date
                          )
        WHERE  PWP.PROJECT_ID = P_PROJECT_ID AND PWP.TRANSFER_STATUS_CODE = 'A';




        UPDATE PA_PWP_CUSTOMER_SUMM pwp
        SET  (PROJFUNC_CURRENCY_CODE ,PROJECT_CURRENCY_CODE)
           = (select  PROJFUNC_CURRENCY_CODE, PROJECT_CURRENCY_CODE
              from  pa_projects_all pa   where pwp.project_id = pa.project_id )
        Where  project_id =  P_Project_Id;


  --  Updating the PC/PFC amounts  by convertig the  INV amount fetched from  AR


        UPDATE PA_PWP_CUSTOMER_SUMM
        SET    PFC_BILL_AMOUNT        = INV_BILL_AMOUNT        * (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
	         , PFC_CP_BILL_AMOUNT     = INV_CP_BILL_AMOUNT     * (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PFC_RECIEPT_AMOUNT     = INV_RECIEPT_AMOUNT     * (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PFC_CP_RECIEPT_AMOUNT  = INV_CP_RECIEPT_AMOUNT  * (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PFC_OUTSTANDING_AMOUNT = INV_OUTSTANDING_AMOUNT * (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PFC_ADJUSTMENT_AMOUNT  = INV_ADJUSTMENT_AMOUNT  * (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PFC_TAX_AMOUNT         = INV_TAX_AMOUNT         * (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PFC_LINE_AMOUNT        = INV_LINE_AMOUNT        * (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PC_BILL_AMOUNT         = INV_BILL_AMOUNT        * (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PC_CP_BILL_AMOUNT      = INV_CP_BILL_AMOUNT     * (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PC_RECIEPT_AMOUNT      = INV_RECIEPT_AMOUNT     * (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PC_CP_RECIEPT_AMOUNT   = INV_CP_RECIEPT_AMOUNT  * (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PC_OUTSTANDING_AMOUNT  = INV_OUTSTANDING_AMOUNT * (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PC_ADJUSTMENT_AMOUNT   = INV_ADJUSTMENT_AMOUNT  * (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
             , PC_TAX_AMOUNT          = INV_TAX_AMOUNT         * (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
	         , PC_LINE_AMOUNT         = INV_LINE_AMOUNT        * (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
        WHERE  project_id             = P_project_id
        AND    TRANSFER_STATUS_CODE = 'A';

    /*     --Bug 8200941  commented
	UPDATE PA_PWP_CUSTOMER_SUMM
	SET      PFC_OUTSTANDING_AMOUNT =  (INV_BILL_AMOUNT -  nvl(INV_RECIEPT_AMOUNT,0))   *  (PFC_LINE_AMOUNT/ INV_LINE_AMOUNT)
		    ,PC_OUTSTANDING_AMOUNT  =  (INV_BILL_AMOUNT -  nvl(INV_RECIEPT_AMOUNT,0))   *  (PC_LINE_AMOUNT/ INV_LINE_AMOUNT)
		    ,INV_OUTSTANDING_AMOUNT =  (INV_BILL_AMOUNT -  nvl(INV_RECIEPT_AMOUNT,0))
	WHERE    project_id             =  P_project_id  ;

    */
/*   bug 8200961   updating receipt amounts  to 0  for credit memos. */

UPDATE  PA_PWP_CUSTOMER_SUMM
 SET   PFC_RECIEPT_AMOUNT      = 0
      ,PFC_CP_RECIEPT_AMOUNT   = 0
      ,PC_RECIEPT_AMOUNT       = 0
      ,PC_CP_RECIEPT_AMOUNT    = 0
      ,INV_RECIEPT_AMOUNT      = 0
      ,INV_CP_RECIEPT_AMOUNT   = 0
 WHERE
       DRAFT_INVOICE_NUM_CREDITED IS NOT NULL
 AND  PROJECT_ID             = P_project_id  ;


/*Bug#:7834036 sosharma added update the personalizable columns*/
UPDATE PA_PWP_CUSTOMER_SUMM pwp
        SET  (APPROVED_DATE
		,GL_DATE
		,RELEASED_DATE)
               =
               (SELECT pda.APPROVED_DATE
                      , pda.GL_DATE
  		      , pda.RELEASED_DATE

                FROM   pa_draft_invoices_all pda

               WHERE  pwp.project_id =  pda.project_id
	   AND  pwp.draft_invoice_num  = pda.draft_invoice_num

               )
        WHERE  PWP.project_id = P_Project_Id ;

 UPDATE PA_PWP_CUSTOMER_SUMM pwp
        SET  (BILL_TO_CUST_NUMBER,
               BILL_TO_CUST_NAME,
               SHIP_TO_CUST_NUMBER,
               SHIP_TO_CUST_NAME
               )
             =
        (select bill_c.customer_number,
           bill_c.customer_name,
           ship_c.customer_number,
           ship_c.customer_name
	   from
	     pa_draft_invoices_all pda,
	      pa_customers_v bill_c,
             pa_customers_v ship_c

	   where
	    bill_c.customer_id (+)  = pda.bill_to_customer_id
           AND ship_c.customer_id (+)  = pda.ship_to_customer_id
          AND pwp.project_id =  pda.project_id
	   AND  pwp.draft_invoice_num  = pda.draft_invoice_num)

        WHERE  PWP.project_id = P_Project_Id ;


UPDATE PA_PWP_CUSTOMER_SUMM pwp
set(bill_to_address, ship_to_address) =
(select
hz_format_pub.format_address_lov(
  bill_p.address1 ,
  bill_p.address2,
  bill_p.address3,
  bill_p.address4 ,
  bill_p.city ,
  bill_p.postal_code ,
  bill_p.state,
  bill_p.province,
  bill_p.county,
  bill_p.country,
  bill_p.address_lines_phonetic
) bill_to_address,
hz_format_pub.format_address_lov(
 ship_p.address1 ,
  ship_p.address2,
  ship_p.address3,
  ship_p.address4 ,
  ship_p.city ,
  ship_p.postal_code ,
  ship_p.state,
  ship_p.province,
  ship_p.county,
  ship_p.country,
  ship_p.address_lines_phonetic
) ship_to_address

from
        pa_draft_invoices_all pda,
         RA_ADDRESSES_ALL bill_p,
         RA_ADDRESSES_ALL ship_p
      where
       bill_p.address_id(+)  = pda.bill_to_address_id
       AND ship_p.address_id (+) = pda.ship_to_address_id
       AND pwp.project_id =  pda.project_id
       AND  pwp.draft_invoice_num  = pda.draft_invoice_num)
   WHERE  PWP.project_id = P_Project_Id ;

/*sosharma end change*/
commit;

END Populate_summary;


--The function gets the AR invoice number of a Project's Draft invoice.
FUNCTION GET_RAINVOICE_NUM
    (
      P_PROJECT_ID        IN NUMBER ,
      P_DRAFT_INVOICE_NUM IN NUMBER )
    RETURN VARCHAR2
  IS
    L_INVOICE_NUM VARCHAR2(30);
  BEGIN
     SELECT ra_invoice_number
       INTO l_invoice_num
       FROM pa_draft_invoices
      WHERE project_id    = p_project_id
    AND draft_invoice_num = p_draft_invoice_num;
    RETURN l_invoice_num;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
    RETURN NULL;
  END GET_RAINVOICE_NUM;


--The function gets the Invoice Date of a Project's Draft invoice.
  FUNCTION GET_LAST_INVOICE_DATE
    (
      P_PROJECT_ID        IN NUMBER ,
      P_DRAFT_INVOICE_NUM IN NUMBER )
    RETURN DATE
  IS
    L_INVOICE_DATE DATE;
  BEGIN
     SELECT invoice_date
       INTO L_INVOICE_DATE
       FROM pa_draft_invoices
      WHERE project_id    = p_project_id
    AND draft_invoice_num = p_draft_invoice_num;
    RETURN L_INVOICE_DATE;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
    RETURN NULL;
  END GET_LAST_INVOICE_DATE;

END PA_PWP_SUMM_PKG;


/
