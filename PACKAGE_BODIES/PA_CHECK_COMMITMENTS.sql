--------------------------------------------------------
--  DDL for Package Body PA_CHECK_COMMITMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CHECK_COMMITMENTS" AS
/* $Header: PAXCMTVB.pls 120.11.12010000.3 2008/10/14 06:21:47 sugupta ship $*/


FUNCTION COMMITMENTS_CHANGED ( p_ProjectID IN NUMBER )
	RETURN VARCHAR2
IS

         v_tmp		Varchar2(1) := 'N';
 /* Added for bug 4360855 */
	 tmp            NUMBER;
	 CURSOR c IS
             SELECT organization_id
             FROM pjm_org_parameters
             WHERE common_project_id = p_ProjectID ;

	    Cursor is_cash_basis_enabled_cur IS  /* Bug#4905546 */
	    SELECT 'Y'    /* to find whether cash basis accounting is enabled or not */
	    FROM DUAL
	    WHERE   EXISTS (
			SELECT NVL(GLSLA.SLA_LEDGER_CASH_BASIS_FLAG,'N')
				FROM   GL_LEDGERS GLSLA,
				PA_IMPLEMENTATIONS_ALL IMP,
				AP_INVOICE_DISTRIBUTIONS_ALL APD
			WHERE NVL(GLSLA.SLA_LEDGER_CASH_BASIS_FLAG,'N') = 'Y'
			AND   GLSLA.LEDGER_ID = IMP.SET_OF_BOOKS_ID
			AND   APD.PROJECT_ID = p_ProjectID
			AND   DECODE(APD.PA_ADDITION_FLAG,'Z','Y','T','Y','E','Y', null,'N', APD.PA_ADDITION_FLAG) <> 'Y'
			AND   APD.ORG_ID = IMP.ORG_ID );

    	    	    is_cash_basis_enabled_flag varchar(1) := 'N' ;

BEGIN

OPEN   is_cash_basis_enabled_cur;
FETCH is_cash_basis_enabled_cur into is_cash_basis_enabled_flag;
CLOSE is_cash_basis_enabled_cur;

/* First Block: NEW COMMITMENTS VIA CLIENT EXTENSION
   Checks Client Extension for commitments against PA_Commitment_Txns
*/



  Begin -- First Block

       v_tmp :=  PA_Client_Extn_Check_CMT.Commitments_Changed(p_ProjectID);
       If v_tmp = 'Y' then
          Return v_tmp;
       end if;

  End; -- First Block

    -- Grants Management Integrated Commitment Processing  ---------------------
    -- added 30-MAY-2003, jwhite

    -- If GMS enabled, Check manual encumbrance changes here for grants.
    --
    -- Since a GMS view is used for inserting GMS commitments if GMS is enabled,
    -- then there is not any point doing any processing beyond this portion
    -- of the code. Therefore, this code must ALWAYS return control to the calling object.


    Begin

      -- R12 AP Lines uptake:	Commitment changed for grants is merged with the commitment
      -- changed for projects. Additionally check for encumbrance as follows.
      --IF (PA_PROJ_ACCUM_MAIN.G_GMS_Enabled = 'Y')
      --  THEN
      --   v_tmp :=  GMS_PA_API3.Commitments_Changed(p_ProjectID);
      --   RETURN v_tmp;
      --END IF ;
      --
      IF (PA_PROJ_ACCUM_MAIN.G_GMS_Enabled = 'Y')
        THEN
         BEGIN
            SELECT 'Y'       INTO  v_tmp
            FROM DUAL
            WHERE EXISTS (
               SELECT enc1.encumbrance_item_id
               FROM gms_encumbrance_items_all Enc1,
                    pa_tasks T
               WHERE enc1.task_id = T.task_id
                 AND T.project_id = p_ProjectID
                 AND enc1.enc_distributed_flag = 'Y'
               MINUS
               SELECT CMT.CMT_Header_ID
               FROM PA_COMMITMENT_TXNS CMT
               WHERE CMT.Line_Type = 'N'
                 AND CMT.Project_ID = p_ProjectID
                 AND CMT.Transaction_Source = 'OUTSIDE_SYSTEM');
               -- Bug 3504811 : End
               Return v_tmp;
         Exception
             WHEN NO_DATA_FOUND THEN
                v_tmp := 'N' ;
         End; -- End First block , Manual Enc.
      END IF ;

     End;

    -- -------------------------------------------------------------------------

/* Code addition for bug 3258046 starts */
       If v_tmp = 'S' then
          Return 'N';
       end if;
/* Code addition for bug 3258046 ends */

/* Second Block: NEW REQUISITIONS
   Checks the PO Req Distributions' tables against PA_Commitment_Txns
   for new Purchase Requisitions
*/

/* Bug 1517186 made chagnes for performance tuning.
   1. Altered the table sequence. 2. replaced per_people_f with per_all_people_f
   3. Replace hr_organization_units with hr_all_organization_units
*/

v_tmp := 'N';

  Begin -- Second Block

  SELECT 'Y'
  INTO  v_tmp
  FROM 	DUAL
  WHERE EXISTS (
   	SELECT '1'
     FROM
              PO_REQ_DISTRIBUTIONS_ALL    RD
            , PO_REQUISITION_LINES_ALL    RL
            , PER_ALL_PEOPLE_F            REQ
            , PO_REQUISITION_HEADERS_ALL  RH
            , PO_DOCUMENT_TYPES_ALL_TL    PDT  /* modified for bug 4758887 */
            , PO_LINE_TYPES_B               LT /* modified for bug 6367516 */
            , PA_TASKS                    T
            , HR_ALL_ORGANIZATION_UNITS   O
            , PA_EXPENDITURE_TYPES        ET
            , PA_PROJECTS                 P
        WHERE
          RH.REQUISITION_HEADER_ID = RL.REQUISITION_HEADER_ID
          AND RH.TYPE_LOOKUP_CODE = 'PURCHASE'
          AND PDT.DOCUMENT_TYPE_CODE = 'REQUISITION'
          AND RH.TYPE_LOOKUP_CODE = PDT.DOCUMENT_SUBTYPE
          AND NVL( PDT.ORG_ID , -99 ) = NVL( RH.ORG_ID , -99 )  /* added for bug 4758887 */
          AND PDT.LANGUAGE = USERENV('LANG')                    /* added for bug 4758887 */
          AND RL.LINE_LOCATION_ID IS NULL
          AND NVL(RL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
          AND NVL(RL.CANCEL_FLAG,'N') = 'N'
          AND NVL(RL.MODIFIED_BY_AGENT_FLAG,'N') = 'N'
          AND RL.SOURCE_TYPE_CODE = 'VENDOR'
          AND REQ.PERSON_ID = RL.TO_PERSON_ID
          AND TRUNC(SYSDATE)
              BETWEEN REQ.EFFECTIVE_START_DATE                 /* modified for bug 6367516 */
                    AND REQ.EFFECTIVE_END_DATE
          AND RL.LINE_TYPE_ID = LT.LINE_TYPE_ID
          AND RD.REQUISITION_LINE_ID = RL.REQUISITION_LINE_ID
          AND RD.PROJECT_ID = P.PROJECT_ID
          AND RD.TASK_ID = T.TASK_ID
          AND RD.EXPENDITURE_ORGANIZATION_ID = O.ORGANIZATION_ID
          AND RD.EXPENDITURE_TYPE = ET.EXPENDITURE_TYPE
       AND RD.Project_ID = p_ProjectID
       AND NOT EXISTS (
           SELECT '2'
           FROM  PA_COMMITMENT_TXNS CMT
           WHERE CMT.Line_Type = 'R'
           AND CMT.Project_ID = p_ProjectID
		   AND CMT.Burden_Sum_Dest_Run_ID is NULL
           AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
           AND CMT.CMT_Header_ID = RH.Requisition_Header_ID
           AND CMT.CMT_Line_Number = RL.Line_Num
           AND CMT.CMT_Distribution_ID = RD.Distribution_ID )
    );

  Return v_tmp;

  Exception
    WHEN NO_DATA_FOUND THEN
        v_tmp := 'N';
  End; -- Second Block, for new PO Reqs


/* Third Block: NEW AP INVOICES
   Checks the AP Inv Distributions' tables against PA_Commitment_Txns
   for new Invoices
*/

v_tmp := 'N';

  Begin -- Third Block

  IF is_cash_basis_enabled_flag = 'Y' Then   /* Bug#4905546 */

	SELECT 'Y' /* When cash basis accounting is enabled  */
	INTO  v_tmp
	FROM DUAL
	WHERE EXISTS (
		SELECT '1'
		FROM
			pa_proj_ap_inv_distributions apd
		WHERE
		apd.PROJECT_ID = p_ProjectID
		AND NOT EXISTS (
			SELECT '2'
			FROM  PA_COMMITMENT_TXNS CMT
			WHERE CMT.Line_Type = 'I'
			AND CMT.Project_ID = p_ProjectID
			AND CMT.Burden_Sum_Dest_Run_ID is NULL
			AND CMT.Transaction_Source = 'ORACLE_PAYABLES'
			AND CMT.CMT_Header_ID = apD.Invoice_ID
			AND CMT.cmt_distribution_id = apd.invoice_distribution_id
			AND cmt.acct_raw_cost  = apd.amount)
	 );
  ELSE

	SELECT 'Y'  /* When cash basis accounting is not enabled  */
	INTO  v_tmp
	FROM  DUAL
	WHERE EXISTS (
	SELECT '1'
	FROM
	   AP_INVOICES_ALL                 I     /* Changed for the bug #1530740 */
	   , PO_DISTRIBUTIONS              POD
	   , AP_INVOICE_DISTRIBUTIONS_ALL  D     /* Changed for the bug #1530740 */
	WHERE
	 I.Invoice_ID = D.Invoice_ID
	 AND NVL(POD.Distribution_type, 'XX') <> 'PREPAYMENT'
	 AND D.PO_Distribution_ID = POD.PO_Distribution_ID(+)
	 AND NVL(POD.Destination_Type_Code, 'EXPENSE') = 'EXPENSE'
	 AND decode(D.Pa_Addition_Flag,'Z','Y','T','Y','E','Y', null,'N',D.Pa_Addition_Flag) <> 'Y'
	 /*Bug# 2061817:Added PA_IC_INVOICES in the condition of i.source below*/
	 AND nvl(I.source, 'xxx') not in ('Oracle Project Accounting','PA_IC_INVOICES')
	 AND D.Project_ID = p_ProjectID
	 AND NOT EXISTS (
		SELECT '2'
		FROM  PA_COMMITMENT_TXNS CMT
		WHERE CMT.Line_Type = 'I'
		AND CMT.Project_ID = p_ProjectID
		  AND CMT.Burden_Sum_Dest_Run_ID is NULL
		AND CMT.Transaction_Source = 'ORACLE_PAYABLES'
		AND CMT.CMT_Header_ID = D.Invoice_ID
		AND CMT.CMT_DISTRIBUTION_ID = D.invoice_distribution_id)
	);
  END IF;

  Return v_tmp;

  Exception
    WHEN NO_DATA_FOUND THEN
        v_tmp := 'N';
  End; -- Third Block, for new AP Invoices

/* Fourth Block: NEW POs
   Checks the PO distributions' tables against PA_Commitment_Txns
   for new POs
*/

  v_tmp := 'N';

  Begin -- Fourth Block

  SELECT 'Y'
  INTO v_tmp
  FROM DUAL
  WHERE EXISTS
    (
    SELECT /*+ leading(pod) */ '1'     --bug 6872563 - skkoppul : Added hint
    FROM
          PO_DISTRIBUTIONS_ALL   POD
        , PO_HEADERS_ALL         POH
        , PO_LINES_ALL           POL
        , PO_RELEASES_ALL        POR
        , PO_DOCUMENT_TYPES_TL    PDT  --/* added for bug 6367516 */
        , PO_LINE_LOCATIONS_ALL  PLL
        , PER_ALL_PEOPLE_F       BUY
        , PER_ALL_PEOPLE_F       REQ
    WHERE
      POH.AGENT_ID = BUY.PERSON_ID
      AND POD.Distribution_type <> 'PREPAYMENT'
      AND TRUNC(SYSDATE)
          BETWEEN BUY.EFFECTIVE_START_DATE
      AND BUY.EFFECTIVE_END_DATE
      AND POD.DELIVER_TO_PERSON_ID = REQ.PERSON_ID(+)
      AND PDT.LANGUAGE = USERENV('LANG')     /* added for bug 6367516 */
      AND NVL( PDT.ORG_ID , -99 ) = NVL( POH.ORG_ID , -99 )  /* added for bug 6367516 */
      AND TRUNC(SYSDATE)
              BETWEEN REQ.EFFECTIVE_START_DATE                 /* modified for bug 6367516 */
                    AND REQ.EFFECTIVE_END_DATE
      AND NVL(POH.CLOSED_CODE,'OPEN') NOT IN ('CLOSED','FINALLY CLOSED')
      AND NVL(PLL.CLOSED_CODE,'OPEN') NOT IN ('CLOSED','FINALLY CLOSED')
      AND PLL.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
      AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','BLANKET','PLANNED')
      AND POH.TYPE_LOOKUP_CODE = PDT.DOCUMENT_SUBTYPE
      AND PDT.DOCUMENT_TYPE_CODE IN ('PO','PA')
      AND PLL.PO_RELEASE_ID = POR.PO_RELEASE_ID(+)
      AND NVL(POH.CANCEL_FLAG,'N') = 'N'
      AND DECODE(POR.RELEASE_NUM,NULL,'OPEN',NVL(POR.CLOSED_CODE,'OPEN'))
          NOT IN ('CLOSED','FINALLY CLOSED')
      AND DECODE(POR.RELEASE_NUM,NULL,'N',NVL(POR.CANCEL_FLAG,'N')) = 'N'
      AND PLL.LINE_LOCATION_ID = POD.LINE_LOCATION_ID
      AND POH.PO_Header_ID = POD.PO_Header_ID
      AND POL.PO_Line_ID = POD.PO_Line_ID
      AND POD.Project_ID = p_ProjectID
      AND NOT EXISTS (
          SELECT '2'
          FROM PA_COMMITMENT_TXNS CMT
          WHERE CMT.Line_Type = 'P'
            AND CMT.Project_ID = p_ProjectID
		    AND CMT.Burden_Sum_Dest_Run_ID is NULL
            AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
            AND CMT.CMT_Header_ID = POD.PO_Header_ID
            AND CMT.CMT_Line_Number = POL.Line_Num
            AND CMT.CMT_Distribution_ID = POD.PO_Distribution_ID )
    );
  Return v_tmp;

  Exception
    WHEN NO_DATA_FOUND THEN
         v_tmp := 'N';

  End; -- Fourth Block, for new POs


/* Fifth Block: UPDATED POs
   Checks the PO distributions' tables against PA_Commitment_Txns
   for updated POs
   Note: For POs, all amounts are captured in Oracle Purchasing as denom amounts.
*/

  v_tmp := 'N';

  Begin -- Fifth Block

  SELECT 'Y'
  INTO v_tmp
  FROM DUAL
  WHERE EXISTS
    (
	SELECT '1'
	FROM PA_COMMITMENT_TXNS CMT
	WHERE 	CMT.Project_ID = p_ProjectID
    AND CMT.Burden_Sum_Dest_Run_ID is NULL
	AND	CMT.Line_Type||'' = 'P'
	AND	CMT.Transaction_Source = 'ORACLE_PURCHASING'
	AND	NOT EXISTS
        (
        SELECT '2'
        FROM
              PO_HEADERS_ALL         POH
            , PO_RELEASES_ALL        POR
            , PO_DOCUMENT_TYPES      PDT
/*          , PO_VENDORS             V        Removed for bug 1751445 */
            , PO_LINES_ALL           POL
            , PO_LINE_TYPES_B          LT /* modified for bug 6367516 */
            , PO_LINE_LOCATIONS_ALL  PLL
            , PER_ALL_PEOPLE_F       BUY
            , PER_ALL_PEOPLE_F       REQ
            , HR_ALL_ORGANIZATION_UNITS  O
            , PA_EXPENDITURE_TYPES   ET
            , PA_TASKS               T
            , PO_DISTRIBUTIONS_ALL   POD
            , PA_PROJECTS            P
    		  , GL_LEDGERS			  G  /* Added for bug     3537697 */
        WHERE
/*            POH.VENDOR_ID = V.VENDOR_ID (+)  Removed join for bug 1751445 */
              POH.AGENT_ID = BUY.PERSON_ID
          AND TRUNC(SYSDATE)
              BETWEEN BUY.EFFECTIVE_START_DATE
          AND BUY.EFFECTIVE_END_DATE
          AND POD.Distribution_type <> 'PREPAYMENT'
          AND POD.DELIVER_TO_PERSON_ID = REQ.PERSON_ID(+)
          AND TRUNC(SYSDATE)
              BETWEEN REQ.EFFECTIVE_START_DATE                 /* modified for bug 6367516 */
                    AND REQ.EFFECTIVE_END_DATE
          AND NVL(POH.CLOSED_CODE,'OPEN') NOT IN ('CLOSED','FINALLY CLOSED')
          AND NVL(PLL.CLOSED_CODE,'OPEN') NOT IN ('CLOSED','FINALLY CLOSED')
          AND PLL.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
          AND POH.TYPE_LOOKUP_CODE IN ('STANDARD','BLANKET','PLANNED')
          AND POH.TYPE_LOOKUP_CODE = PDT.DOCUMENT_SUBTYPE
          AND PDT.DOCUMENT_TYPE_CODE IN ('PO','PA')
          AND PLL.PO_RELEASE_ID = POR.PO_RELEASE_ID(+)
          AND NVL(POH.CANCEL_FLAG,'N') = 'N'
          AND DECODE(POR.RELEASE_NUM,NULL,'OPEN',NVL(POR.CLOSED_CODE,'OPEN'))
              NOT IN ('CLOSED','FINALLY CLOSED')
          AND DECODE(POR.RELEASE_NUM,NULL,'N',NVL(POR.CANCEL_FLAG,'N')) = 'N'
          AND POL.PO_HEADER_ID = POH.PO_HEADER_ID
          AND POL.LINE_TYPE_ID = LT.LINE_TYPE_ID
          AND POL.PO_LINE_ID = PLL.PO_LINE_ID
          AND PLL.LINE_LOCATION_ID = POD.LINE_LOCATION_ID
          AND POD.PROJECT_ID = P.PROJECT_ID
          AND POD.TASK_ID = T.TASK_ID
          AND POD.EXPENDITURE_ORGANIZATION_ID = O.ORGANIZATION_ID
          AND POD.EXPENDITURE_TYPE = ET.EXPENDITURE_TYPE
          AND POD.PROJECT_ID = p_ProjectID
		AND POH.PO_Header_ID = CMT.CMT_Header_ID
          AND G.LEDGER_ID = POD.SET_OF_BOOKS_ID  /* Added for bug     3537697 */
      AND POD.PO_Distribution_ID = CMT.CMT_Distribution_ID
      and CMT.task_id = nvl(pod.task_id,0)
      and NVL(CMT.description,'<prm>') = NVL(POL.item_description,'<prm>')
      and NVL(CMT.expenditure_item_date,sysdate-15000) = NVL(POD.expenditure_item_date,sysdate-15000)
      and NVL(CMT.cmt_creation_date,sysdate-15000) = NVL(decode(POR.release_num,NULL,POH.creation_date,POR.creation_date),sysdate-15000)
      and NVL(CMT.cmt_approved_date,sysdate-15000) = NVL(decode(POR.release_num,NULL,POH.approved_date,POR.approved_date),sysdate-15000)
      and NVL(CMT.cmt_requestor_name,'<prm>') = NVL(REQ.full_name,'<prm>')
      and NVL(CMT.cmt_buyer_name,'<prm>') = NVL(BUY.full_name,'<prm>')
      and NVL(CMT.cmt_approved_flag,'<prm>') = NVL(decode(POR.release_num,NULL,decode(POH.authorization_status,'APPROVED','Y','N'),decode(POR.authorization_status,'APPROVED','Y','N')),'<prm>')
      and NVL(CMT.vendor_id,-1) = NVL(POH.vendor_id,-1)   /* Changed for bug 1751445 */
      and NVL(CMT.expenditure_type,'<prm>') = NVL(POD.expenditure_type,'<prm>')
      and NVL(CMT.organization_id,0) = NVL(O.organization_id,0)
      and CMT.expenditure_category = ET.expenditure_category
      and CMT.revenue_category = ET.revenue_category_code
      and NVL(CMT.unit_of_measure,'<prm>') = NVL(decode(pll.value_basis,'AMOUNT',NULL,POL.unit_meas_lookup_code),'<prm>')
      and NVL(CMT.unit_price,0) = NVL(TO_NUMBER(DECODE(pll.value_basis,   'AMOUNT', NULL,
                           pa_multi_currency.convert_amount_sql(POH.CURRENCY_CODE, G.CURRENCY_CODE,
                                                                POD.RATE_DATE, POH.RATE_TYPE,
                                                                NVL(POD.RATE, 1), PLL.PRICE_OVERRIDE ) )) , 0)
      /*  Added above code and commented the below for Bug 3537697
      NVL(TO_NUMBER(decode(pll.value_basis,'AMOUNT',NULL,( PLL.price_override * NVL(POD.rate,1)))),0) */
      and CMT.original_quantity_ordered = POD.quantity_ordered
      and NVL(CMT.quantity_cancelled,0) = NVL(POD.quantity_cancelled,0)
      and NVL(CMT.quantity_delivered,0) = NVL(POD.quantity_delivered,0)
      and CMT.quantity_invoiced = NVL(POD.quantity_billed,0)
      and nvl(CMT.denom_raw_cost,0) = GREATEST(0,(PA_CMT_UTILS.get_rcpt_qty(pod.po_distribution_id,
                                   			  POD.QUANTITY_ORDERED,
                                 			  NVL(POD.QUANTITY_CANCELLED,0),
                                 			  NVL(POD.QUANTITY_BILLED,0),'PO',
                                                          pol.po_line_id,
                                                          t.project_id,
                                                          t.task_id,
                                                          pod.code_combination_id,0, NULL, NULL, NULL, NULL, nvl(g.sla_ledger_cash_basis_flag,'N')))) *   /*Bug#4905552*/
                                                 ((PLL.PRICE_OVERRIDE) +(NVL(POD.NONRECOVERABLE_TAX,0) / POD.QUANTITY_ORDERED))
/*      Added above condition and commented this for bug 3537697
      GREATEST(0,(POD.QUANTITY_ORDERED-NVL(POD.QUANTITY_CANCELLED,0)
        -NVL(POD.QUANTITY_BILLED,0))) * ((PLL.PRICE_OVERRIDE) +
        (NVL(POD.NONRECOVERABLE_TAX,0) / POD.QUANTITY_ORDERED))  */
      and NVL(CMT.denom_burdened_cost,0) =
             NVL(PA_BURDEN_CMTS.get_cmt_burdened_cost(
                 NULL
                 , 'CMT'
                 , T.task_id
                 , POD.expenditure_item_date
                 , POD.expenditure_type
                 , O.organization_id
                 , 'C'
                 , GREATEST(0,(PA_CMT_UTILS.get_rcpt_qty(pod.po_distribution_id,
                                   			  POD.QUANTITY_ORDERED,
                                 			  NVL(POD.QUANTITY_CANCELLED,0),
                                 			  NVL(POD.QUANTITY_BILLED,0),'PO',
                                                          pol.po_line_id,
                                                          t.project_id,
                                                          t.task_id,
                                                          pod.code_combination_id,0,NULL,NULL, NULL, NULL, nvl(g.sla_ledger_cash_basis_flag,'N')))) *  /*Bug#4905552*/
                                                  ((PLL.PRICE_OVERRIDE) +(NVL(POD.NONRECOVERABLE_TAX,0) / POD.QUANTITY_ORDERED))
/*	Added above condition and commented this for bug 3537697
                 , GREATEST(0,(POD.QUANTITY_ORDERED-NVL(POD.QUANTITY_CANCELLED,0)
        -NVL(POD.QUANTITY_BILLED,0))) * ((PLL.PRICE_OVERRIDE) +
        (NVL(POD.NONRECOVERABLE_TAX,0) / POD.QUANTITY_ORDERED))  */
	),0)
      )
     );

  Return v_tmp;

  Exception
  	WHEN NO_DATA_FOUND THEN
	     v_tmp := 'N';

  End; -- Fifth Block, for updated POs


/* Sixth Block: UPDATED INVOICES
   Checks the AP Inv Distributions' tables against PA_Commitment_Txns
   for updated Invoices
   Note: For AP Invoices, all amounts are captured in Oracle Payables as denom amounts.
*/

  v_tmp := 'N';

  Begin -- Sixth Block

	  SELECT 'Y'
	  INTO v_tmp
	  FROM DUAL
	  WHERE EXISTS
	    (
		SELECT '1'
		FROM PA_COMMITMENT_TXNS CMT
		WHERE 	CMT.Project_ID = p_ProjectID
	    AND CMT.Burden_Sum_Dest_Run_ID is NULL
		AND	CMT.Line_Type||'' = 'I'
		AND	CMT.Transaction_Source = 'ORACLE_PAYABLES'
		AND	NOT EXISTS
		   (
		   SELECT '2'
		   FROM
			    AP_INVOICE_DISTRIBUTIONS_ALL D
			  , AP_INVOICES_ALL              I
			  , PO_VENDORS                   V
			  , HR_ALL_ORGANIZATION_UNITS    O
			  , PA_EXPEND_TYP_SYS_LINKS      ES
			  , PA_EXPENDITURE_TYPES         ET
			  , PA_TASKS                     T
			  , PO_DISTRIBUTIONS             PO
			  , PA_PROJECTS                  P
		   WHERE
			I.vendor_id = V.vendor_id
			AND I.invoice_id = D.invoice_id
			AND decode(D.pa_addition_flag,'Z','Y','T','Y','E','Y', null,'N',D.pa_addition_flag) <> 'Y'
			  AND ( ES.system_linkage_function  = 'VI' OR
				   ( ES.system_linkage_function = 'ER' AND
					  V.employee_id IS NOT NULL ))
			AND D.po_distribution_id = PO.po_distribution_id (+)
			AND NVL(PO.Distribution_type, 'XX') <> 'PREPAYMENT'
			AND nvl(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
			AND D.project_id = P.project_id
			AND D.task_id = T.task_id
			AND D.expenditure_organization_id = O.organization_id
			AND D.expenditure_type = ES.expenditure_type
			AND ET.expenditure_type = ES.expenditure_type
			/*Bug#2061817:Added PA_IC_INVOICES in the condition for i.source*/
			AND nvl(I.source, 'xxx') not in ('Oracle Project Accounting','PA_IC_INVOICES')
			AND D.project_id = p_ProjectID
		 and CMT.task_id = nvl(d.task_id,0)
		 AND I.Invoice_ID = CMT.CMT_Header_ID
		 AND CMT.CMT_DISTRIBUTION_ID = D.invoice_distribution_id
		 and NVL(CMT.description,'<prm>') = NVL(D.description,'<prm>')
		 and NVL(CMT.expenditure_item_date,sysdate-15000) = NVL(D.expenditure_item_date,sysdate-15000)
		 and NVL(CMT.cmt_creation_date,sysdate-15000) = NVL(I.invoice_date,sysdate-15000)
		 and CMT.cmt_approved_flag = decode(AP_INVOICES_PKG.GET_APPROVAL_STATUS(I.invoice_id,I.invoice_amount,I.payment_status_flag,I.invoice_type_lookup_code),'APPROVED','Y','N')
		 and CMT.vendor_id = I.vendor_id
		 and NVL(CMT.expenditure_type,'<prm>') = NVL(D.expenditure_type,'<prm>')
		 and NVL(CMT.organization_id,0) = NVL(O.organization_id,0)
		 and CMT.expenditure_category = ET.expenditure_category
		 and CMT.revenue_category = ET.revenue_category_code
		 and NVL(CMT.denom_raw_cost,0) = NVL(D.amount,0)
		 and NVL(CMT.tot_cmt_quantity,0) = NVL(D.pa_quantity,0)
		 and NVL(CMT.denom_burdened_cost,0) =
			   NVL(PA_BURDEN_CMTS.get_cmt_burdened_cost(
				  NULL
				  , 'CMT'
				  , T.task_id
				  , D.expenditure_item_date
				  , D.expenditure_type
				  , O.organization_id
				  , 'C'
				  , D.amount),0)
		 )
	    );

  Return v_tmp;

  Exception
  	WHEN NO_DATA_FOUND THEN
	     v_tmp := 'N';

  End; -- Sixth Block, for updated AP Invoices


/* Seventh Block: UPADTED REQUISTIONS
   Checks the PO Req Distributions' tables against PA_Commitment_Txns
   for updated Purchase Requisitions

   Note: For Requisitions, unit price is always captured in accounting currency! Therefore,
         the raw cost and burdened cost comparative joins in this block use ACCT columns.

         Please note that this is different than Updated POs and AP Invoices.
*/

  v_tmp := 'N';

  Begin -- Seventh Block

  SELECT 'Y'
  INTO  v_tmp
  FROM 	DUAL
  WHERE EXISTS
    (
   	SELECT '1'
   	FROM PA_COMMITMENT_TXNS CMT
   	WHERE CMT.Project_ID = p_ProjectID
    AND CMT.Burden_Sum_Dest_Run_ID is NULL
   	AND CMT.Line_Type||'' = 'R'
   	AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
   	AND NOT EXISTS
        (
        SELECT '2'
        FROM
               PO_REQ_DISTRIBUTIONS_ALL    RD
             , PO_REQUISITION_LINES_ALL    RL
             , PO_REQUISITION_HEADERS_ALL  RH
             , PO_DOCUMENT_TYPES_ALL_TL    PDT  /* modified for bug 4758887 */
             , PO_LINE_TYPES_B               LT /* modified for bug 6367516 */
             , PER_ALL_PEOPLE_F            REQ
             , PA_TASKS                    T
             , HR_ALL_ORGANIZATION_UNITS   O
             , PA_EXPENDITURE_TYPES        ET
             , PA_PROJECTS                 P
        WHERE
          RH.REQUISITION_HEADER_ID = RL.REQUISITION_HEADER_ID
          AND RH.TYPE_LOOKUP_CODE = 'PURCHASE'
          AND PDT.DOCUMENT_TYPE_CODE = 'REQUISITION'
          AND RH.TYPE_LOOKUP_CODE = PDT.DOCUMENT_SUBTYPE
          AND NVL( PDT.ORG_ID , -99 ) = NVL( RH.ORG_ID , -99 )  /* added for bug 4758887 */
          AND PDT.LANGUAGE = USERENV('LANG')                    /* added for bug 4758887 */
          AND RL.LINE_LOCATION_ID IS NULL
          AND NVL(RL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
          AND NVL(RL.CANCEL_FLAG,'N') = 'N'
          AND NVL(RL.MODIFIED_BY_AGENT_FLAG,'N') = 'N'
          AND RL.SOURCE_TYPE_CODE = 'VENDOR'
          AND REQ.PERSON_ID = RL.TO_PERSON_ID
          AND TRUNC(SYSDATE)
              BETWEEN REQ.EFFECTIVE_START_DATE                 /* modified for bug 6367516 */
                    AND REQ.EFFECTIVE_END_DATE
          AND RL.LINE_TYPE_ID = LT.LINE_TYPE_ID
          AND RD.REQUISITION_LINE_ID = RL.REQUISITION_LINE_ID
          AND RD.PROJECT_ID = P.PROJECT_ID
          AND RD.TASK_ID = T.TASK_ID
          AND RD.EXPENDITURE_ORGANIZATION_ID = O.ORGANIZATION_ID
          AND RD.EXPENDITURE_TYPE = ET.EXPENDITURE_TYPE
          AND RD.PROJECT_ID = p_ProjectID
      and CMT.task_id = nvl(rd.task_id,0)
      and CMT.cmt_distribution_id = RD.Distribution_ID
      and CMT.description = RL.item_description
      and NVL(CMT.expenditure_item_date,sysdate-15000) = NVL(RD.expenditure_item_date,sysdate-15000)
      and NVL(CMT.cmt_creation_date,sysdate-15000) = NVL(RL.creation_date,sysdate-15000)
      and CMT.cmt_approved_flag = decode(NVL(RH.authorization_status,'NOT APPROVED'),'APPROVED','Y','N')
      and NVL(CMT.cmt_need_by_date,sysdate-15000) = NVL(RL.need_by_date,sysdate-15000)
      and NVL(CMT.vendor_id,0) = NVL(RL.vendor_id,0)
      and NVL(CMT.expenditure_type,'<prm>') = NVL(RD.expenditure_type,'<prm>')
      and NVL(CMT.organization_id,0) = NVL(O.organization_id,0)
      and CMT.expenditure_category = ET.expenditure_category
      and CMT.revenue_category = ET.revenue_category_code
      and CMT.acct_raw_cost = (RD.REQ_LINE_QUANTITY * RL.UNIT_PRICE) + NVL(RD.NONRECOVERABLE_TAX,0)
      and CMT.tot_cmt_quantity = RD.req_line_quantity
      and NVL(CMT.acct_burdened_cost,0) =
             NVL(PA_BURDEN_CMTS.get_cmt_burdened_cost(
                 NULL
                 , 'CMT'
                 , T.task_id
                 , RD.expenditure_item_date
                 , RD.expenditure_type
                 , O.organization_id
                 , 'C'
                 , (RD.REQ_LINE_QUANTITY * RL.UNIT_PRICE) + NVL(RD.NONRECOVERABLE_TAX,0)
                 ),0)
      )
	);

  Return v_tmp;

  Exception
  	WHEN NO_DATA_FOUND THEN
  		v_tmp := 'N';
  End; -- Seventh Block, for updated PO Reqs


/* Eighth Block: UPDATED MFG COMMITMENTS
   Checks the CST_PROJMFG_CMT_VIEW against PA_Commitment_Txns
   for updated commitments

   Note: For MFG commitments, the view returns both acct and denom amounts for most amount
         columns, So, where possible, joins are performed for denom amounts.
*/

v_tmp := 'N';

  Begin -- Eighth Block

  SELECT 'Y'
  INTO  v_tmp
  FROM  DUAL
  WHERE EXISTS
    (
    SELECT '1'
    FROM PA_COMMITMENT_TXNS CMT
    WHERE CMT.Project_ID = p_ProjectID
    AND   CMT.Burden_Sum_Dest_Run_ID is NULL
    AND   CMT.Transaction_Source = 'ORACLE_MANUFACTURING'
    AND   NOT EXISTS
          (
          SELECT '2'
          FROM CST_PROJMFG_CMT_VIEW CST
          WHERE
            CST.Project_ID = p_ProjectID
            AND CMT.task_id = nvl(CST.task_id,0)
            AND nvl(CMT.CMT_Header_ID,0)       = nvl(CST.CMT_Header_ID,0)
            AND nvl(CMT.CMT_Line_Number,0)     = nvl(CST.CMT_Line_Number,0)
            AND nvl(CMT.CMT_Distribution_ID,0) = nvl(CST.CMT_Distribution_ID,0)
            and nvl(cmt.DESCRIPTION,'<prm>')     = nvl(cst.DESCRIPTION,'<prm>')
 and nvl(cmt.EXPENDITURE_ITEM_DATE,sysdate-15000) = nvl(cst.EXPENDITURE_ITEM_DATE,sysdate-15000)
            and nvl(cmt.CMT_LINE_NUMBER,0) = nvl(cst.CMT_LINE_NUMBER,0)
 and nvl(cmt.CMT_CREATION_DATE,sysdate-15000) = nvl(cst.CMT_CREATION_DATE,sysdate-15000)
 and nvl(cmt.CMT_APPROVED_DATE,sysdate-15000) = nvl(cst.CMT_APPROVED_DATE,sysdate-15000)
            and nvl(cmt.CMT_REQUESTOR_NAME,'<prm>') = nvl(cst.CMT_REQUESTOR_NAME,'<prm>')
            and nvl(cmt.CMT_BUYER_NAME,'<prm>') = nvl(cst.CMT_BUYER_NAME,'<prm>')
            and nvl(cmt.CMT_APPROVED_FLAG,'<prm>') = nvl(cst.CMT_APPROVED_FLAG,'<prm>')
 and nvl(cmt.CMT_PROMISED_DATE,sysdate-15000) = nvl(cst.CMT_PROMISED_DATE,sysdate-15000)
 and nvl(cmt.CMT_NEED_BY_DATE,sysdate-15000) = nvl(cst.CMT_NEED_BY_DATE,sysdate-15000)
            and nvl(cmt.ORGANIZATION_ID,0) = nvl(cst.ORGANIZATION_ID,0)
            and nvl(cmt.VENDOR_ID,0) = nvl(cst.VENDOR_ID,0)
            and nvl(cmt.EXPENDITURE_TYPE,'<prm>') = nvl(cst.EXPENDITURE_TYPE,'<prm>')
            and nvl(cmt.EXPENDITURE_CATEGORY,'<prm>') = nvl(cst.EXPENDITURE_CATEGORY,'<prm>')
            and nvl(cmt.REVENUE_CATEGORY,'<prm>') = nvl(cst.REVENUE_CATEGORY,'<prm>')
            and nvl(cmt.UNIT_OF_MEASURE,'<prm>') = nvl(cst.UNIT_OF_MEASURE,'<prm>')
            and nvl(cmt.UNIT_PRICE,0) = nvl(cst.UNIT_PRICE,0)
            and nvl(cmt.denom_RAW_COST,0) = nvl(cst.denom_RAW_COST,0)
            and nvl(cmt.denom_BURDENED_COST,0) = nvl(cst.denom_BURDENED_COST,0)
            and nvl(cmt.TOT_CMT_QUANTITY,0) = nvl(cst.TOT_CMT_QUANTITY,0)
            and nvl(cmt.QUANTITY_ORDERED,0) = nvl(cst.QUANTITY_ORDERED,0)
            and nvl(cmt.AMOUNT_ORDERED,0) = nvl(cst.AMOUNT_ORDERED,0)
            and nvl(cmt.ORIGINAL_QUANTITY_ORDERED,0) = nvl(cst.ORIGINAL_QUANTITY_ORDERED,0)
            and nvl(cmt.ORIGINAL_AMOUNT_ORDERED,0) = nvl(cst.ORIGINAL_AMOUNT_ORDERED,0)
            and nvl(cmt.QUANTITY_CANCELLED,0) = nvl(cst.QUANTITY_CANCELLED,0)
            and nvl(cmt.AMOUNT_CANCELLED,0) = nvl(cst.AMOUNT_CANCELLED,0)
            and nvl(cmt.QUANTITY_DELIVERED,0) = nvl(cst.QUANTITY_DELIVERED,0)
            and nvl(cmt.AMOUNT_DELIVERED,0) = nvl(cst.AMOUNT_DELIVERED,0)
            and nvl(cmt.QUANTITY_INVOICED,0) = nvl(cst.QUANTITY_INVOICED,0)
            and nvl(cmt.AMOUNT_INVOICED,0) = nvl(cst.AMOUNT_INVOICED,0)
            and nvl(cmt.QUANTITY_OUTSTANDING_DELIVERY,0) = nvl(cst.QUANTITY_OUTSTANDING_DELIVERY,0)
            and nvl(cmt.AMOUNT_OUTSTANDING_DELIVERY,0) = nvl(cst.AMOUNT_OUTSTANDING_DELIVERY,0)
            and nvl(cmt.QUANTITY_OUTSTANDING_INVOICE,0) = nvl(cst.QUANTITY_OUTSTANDING_INVOICE,0)
            and nvl(cmt.AMOUNT_OUTSTANDING_INVOICE,0) = nvl(cst.AMOUNT_OUTSTANDING_INVOICE,0)
            and nvl(cmt.QUANTITY_OVERBILLED,0) = nvl(cst.QUANTITY_OVERBILLED,0)
            and nvl(cmt.AMOUNT_OVERBILLED,0) = nvl(cst.AMOUNT_OVERBILLED,0)
            and nvl(cmt.ORIGINAL_TXN_REFERENCE1,'<prm>') = nvl(cst.ORIGINAL_TXN_REFERENCE1,'<prm>')
            and nvl(cmt.ORIGINAL_TXN_REFERENCE2,'<prm>') = nvl(cst.ORIGINAL_TXN_REFERENCE2,'<prm>')
            and nvl(cmt.ORIGINAL_TXN_REFERENCE3,'<prm>') = nvl(cst.ORIGINAL_TXN_REFERENCE3,'<prm>')
           )
    );

  Return v_tmp;

  Exception
  	WHEN NO_DATA_FOUND THEN
  		v_tmp := 'N';
  End; -- Eighth Block, for updated commitments from CST_PROJMFG_CMT_VIEW


/* Ninth Block: NEW MFG COMMITMENTS
   Checks the CST_PROJMFG_CMT_VIEW against PA_Commitment_Txns
   for new commitments
*/

v_tmp := 'N';

  Begin -- Ninth Block

  SELECT 'Y'
  INTO  v_tmp
  FROM  DUAL
  WHERE EXISTS (
    SELECT '1'
     FROM
         CST_PROJMFG_CMT_VIEW CST
     WHERE
       CST.PROJECT_ID = p_ProjectID
       AND  NOT EXISTS (
            SELECT '2'
            FROM  PA_COMMITMENT_TXNS CMT
            WHERE CMT.Transaction_Source  = 'ORACLE_MANUFACTURING'
            AND CMT.Project_ID = p_ProjectID
            AND   CMT.Burden_Sum_Dest_Run_ID is NULL
            AND   CMT.CMT_Header_ID       = CST.CMT_Header_ID
            AND   CMT.CMT_Line_Number     = CST.CMT_Line_Number
            AND   CMT.CMT_Distribution_ID = CST.CMT_Distribution_ID )
    );

  Return v_tmp;

  Exception
  	WHEN NO_DATA_FOUND THEN
  		v_tmp := 'N';
  End; -- Ninth Block, for new commitments from CST_PROJMFG_CMT_VIEW

/* Added the following four blocks for the bug #3631172. */

/* Tenth Block: NEW Shop Floor/Inventory REQUISITIONS
   Checks the PJM Req Commitments View against PA_Commitment_Txns
   for new Shop Floor/Inventory Purchase Requisitions.
*/

v_tmp := 'N';

  Begin -- Tenth Block
/* Commented and Modified for bug 4360855 as below as suggested by PJM Team.
  SELECT 'Y'
  INTO  v_tmp
  FROM 	DUAL
  WHERE EXISTS (
   	SELECT '1'
         FROM
              PJM_REQ_COMMITMENTS_V       PJREQ
         WHERE
          PJREQ.Project_ID = p_ProjectID
       AND NOT EXISTS (
           SELECT '2'
           FROM  PA_COMMITMENT_TXNS CMT
           WHERE CMT.Line_Type = 'R'
           AND CMT.Project_ID = p_ProjectID
           AND CMT.Burden_Sum_Dest_Run_ID is NULL
           AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
           AND CMT.CMT_Header_ID = PJREQ.Requisition_Header_ID
           AND CMT.CMT_Line_Number = PJREQ.Req_Line
           AND CMT.CMT_Distribution_ID = PJREQ.Req_Distribution_ID )
    );*/
/* Bug 	5517898  */
  SELECT 1         -- common project
  INTO tmp
  FROM dual where exists (select 1 from pjm_org_parameters
  WHERE common_project_id = p_ProjectID);
/*  Bug 	5517898 */

    FOR c_rec in c loop
     Begin
	  SELECT 'Y'
	  INTO  v_tmp
	  FROM 	DUAL
	  WHERE EXISTS (
	    SELECT REQUISITION_HEADER_ID,
	           LINE_NUM,
		   DISTRIBUTION_ID
		    from (
	      SELECT RL.REQUISITION_HEADER_ID,
	             RL.LINE_NUM,
		     RD.DISTRIBUTION_ID
	      FROM   PO_REQ_DISTRIBUTIONS_ALL     RD
	      ,      PO_REQUISITION_LINES_ALL     RL
	      ,      PJM_ORG_PARAMETERS           POP
	      ,      MTL_SYSTEM_ITEMS             MSI
	      ,      MTL_UNITS_OF_MEASURE_VL      UOM
	      WHERE  RL.DESTINATION_TYPE_CODE = 'INVENTORY'
	      AND    RL.REQUISITION_LINE_ID = RD.REQUISITION_LINE_ID
	      AND    RD.PROJECT_ID IS NULL
	      AND    POP.COMMON_PROJECT_ID = p_ProjectID
	      AND    POP.ORGANIZATION_ID = c_rec.organization_id
	      AND    POP.ORGANIZATION_ID = RL.DESTINATION_ORGANIZATION_ID
	      AND    MSI.ORGANIZATION_ID = RL.DESTINATION_ORGANIZATION_ID
	      AND    MSI.INVENTORY_ITEM_ID = RL.ITEM_ID
	      AND    UOM.UOM_CODE = MSI.PRIMARY_UOM_CODE
	      UNION ALL
	      SELECT RL.REQUISITION_HEADER_ID,
	             RL.LINE_NUM,
		     RD.DISTRIBUTION_ID
	      FROM   PO_REQ_DISTRIBUTIONS_ALL     RD
	      ,      PO_REQUISITION_LINES_ALL     RL
	      ,      PJM_ORG_PARAMETERS           POP
	      ,      WIP_DISCRETE_JOBS            WDJ
	      ,      WIP_OPERATIONS               WO
	      ,      BOM_DEPARTMENTS              BD
	      ,      MTL_UNITS_OF_MEASURE_VL      UOM
	      WHERE  RL.DESTINATION_TYPE_CODE = 'SHOP FLOOR'
	      AND    RL.REQUISITION_LINE_ID = RD.REQUISITION_LINE_ID
	      AND    RD.PROJECT_ID IS NULL
	      AND    POP.COMMON_PROJECT_ID = p_ProjectID
	      AND    RL.DESTINATION_ORGANIZATION_ID = c_rec.organization_id
	      AND    POP.ORGANIZATION_ID = RL.DESTINATION_ORGANIZATION_ID
	      AND    WDJ.ORGANIZATION_ID = RL.DESTINATION_ORGANIZATION_ID
	      AND    WDJ.WIP_ENTITY_ID = RL.WIP_ENTITY_ID
	      AND    WO.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
	      AND    WO.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
	      AND    WO.OPERATION_SEQ_NUM = RL.WIP_OPERATION_SEQ_NUM
	      AND    BD.DEPARTMENT_ID = WO.DEPARTMENT_ID
	      AND    UOM.UNIT_OF_MEASURE = RL.UNIT_MEAS_LOOKUP_CODE)
	       WHERE NOT EXISTS (
		   SELECT '2'
		   FROM  PA_COMMITMENT_TXNS CMT
		   WHERE CMT.Line_Type = 'R'
		   AND CMT.Project_ID = p_ProjectID
		   AND CMT.Burden_Sum_Dest_Run_ID is NULL
		   AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
		   AND CMT.CMT_Header_ID = REQUISITION_HEADER_ID
		   AND CMT.CMT_Line_Number = LINE_NUM
		   AND CMT.CMT_Distribution_ID = DISTRIBUTION_ID )
	    );
    Return v_tmp;
     Exception
       WHEN NO_DATA_FOUND THEN
       v_tmp := 'N';
     End;
    end loop;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN      -- Regular Project
	  Begin

	  SELECT 'Y'
	  INTO  v_tmp
	  FROM 	DUAL
	  WHERE EXISTS (
		    SELECT REQUISITION_HEADER_ID,
			   LINE_NUM,
			   DISTRIBUTION_ID
		    from (
		      SELECT RL.REQUISITION_HEADER_ID,
			     RL.LINE_NUM,
			     RD.DISTRIBUTION_ID
			FROM PO_REQ_DISTRIBUTIONS_ALL RD
			, PO_REQUISITION_LINES_ALL RL
			, MTL_SYSTEM_ITEMS MSI
			, MTL_UNITS_OF_MEASURE_VL UOM
			WHERE RL.DESTINATION_TYPE_CODE = 'INVENTORY'
			AND RD.PROJECT_ID = p_ProjectID
			AND RL.REQUISITION_LINE_ID = RD.REQUISITION_LINE_ID
			AND MSI.ORGANIZATION_ID = RL.DESTINATION_ORGANIZATION_ID
			AND MSI.INVENTORY_ITEM_ID = RL.ITEM_ID
			AND UOM.UOM_CODE = MSI.PRIMARY_UOM_CODE
			UNION ALL
		        SELECT RL.REQUISITION_HEADER_ID,
		  	       RL.LINE_NUM,
			       RD.DISTRIBUTION_ID
			FROM PO_REQ_DISTRIBUTIONS_ALL RD
			, PO_REQUISITION_LINES_ALL RL
			, WIP_DISCRETE_JOBS WDJ
			, WIP_OPERATIONS WO
			, BOM_DEPARTMENTS BD
			, MTL_UNITS_OF_MEASURE_VL UOM
			WHERE RL.DESTINATION_TYPE_CODE = 'SHOP FLOOR'
			AND RD.PROJECT_ID = p_ProjectID
			AND RL.REQUISITION_LINE_ID = RD.REQUISITION_LINE_ID
			AND WDJ.ORGANIZATION_ID = RL.DESTINATION_ORGANIZATION_ID
			AND WDJ.WIP_ENTITY_ID = RL.WIP_ENTITY_ID
			AND WO.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
			AND WO.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
			AND WO.OPERATION_SEQ_NUM = RL.WIP_OPERATION_SEQ_NUM
			AND BD.DEPARTMENT_ID = WO.DEPARTMENT_ID
			AND UOM.UNIT_OF_MEASURE = RL.UNIT_MEAS_LOOKUP_CODE)
	       WHERE NOT EXISTS (
		   SELECT '2'
		   FROM  PA_COMMITMENT_TXNS CMT
		   WHERE CMT.Line_Type = 'R'
		   AND CMT.Project_ID = p_ProjectID
		   AND CMT.Burden_Sum_Dest_Run_ID is NULL
		   AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
		   AND CMT.CMT_Header_ID = REQUISITION_HEADER_ID
		   AND CMT.CMT_Line_Number = LINE_NUM
		   AND CMT.CMT_Distribution_ID = DISTRIBUTION_ID )
	    );
    Return v_tmp;

	  Exception
	    WHEN NO_DATA_FOUND THEN
		v_tmp := 'N';
	  End;
  End; -- Tenth Block, for new Shop Floor/Inventory Reqs

/* Eleventh Block: UPDATED Shop Floor/Inventory REQUISTIONS
   Checks the PJM Req Commitments View against PA_Commitment_Txns
   for updated Shop Floor/Inventory Purchase Requisitions.

*/

  v_tmp := 'N';

  Begin -- Eleventh Block

  SELECT 'Y'
  INTO  v_tmp
  FROM 	DUAL
  WHERE EXISTS
    (
   	SELECT '1'
   	FROM PA_COMMITMENT_TXNS CMT
   	WHERE CMT.Project_ID = p_ProjectID
        AND CMT.Burden_Sum_Dest_Run_ID is NULL
   	AND CMT.Line_Type||'' = 'R'
   	AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
   	AND NOT EXISTS
        (
        SELECT '2'
        FROM
              PJM_REQ_COMMITMENTS_V  PJREQ
        WHERE PJREQ.PROJECT_ID = p_ProjectID
          AND CMT.task_id = nvl(PJREQ.task_id,0)
          AND CMT.cmt_distribution_id = PJREQ.REQ_DISTRIBUTION_ID
          AND CMT.description = PJREQ.item_description
          AND NVL(CMT.expenditure_item_date,sysdate-15000) = NVL(PJREQ.expenditure_item_date,sysdate-15000)
          AND NVL(CMT.cmt_creation_date,sysdate-15000) = NVL(PJREQ.creation_date,sysdate-15000)
          AND CMT.cmt_approved_flag = PJREQ.APPROVED_FLAG
          AND NVL(CMT.cmt_need_by_date,sysdate-15000) = NVL(PJREQ.need_by_date,sysdate-15000)
          AND NVL(CMT.vendor_id,0) = NVL(PJREQ.vendor_id,0)
          AND NVL(CMT.expenditure_type,'<prm>') = NVL(PJREQ.expenditure_type,'<prm>')
          AND NVL(CMT.organization_id,0) = NVL(PJREQ.expenditure_organization_id,0)
          AND CMT.expenditure_category = PJREQ.expenditure_category
          AND CMT.revenue_category = PJREQ.revenue_category
          AND CMT.acct_raw_cost = PJREQ.amount
          AND CMT.tot_cmt_quantity = PJREQ.quantity
          AND NVL(CMT.acct_burdened_cost,0) =
             NVL(PA_BURDEN_CMTS.get_cmt_burdened_cost(
                 NULL
                 , 'CMT'
                 , PJREQ.task_id
                 , PJREQ.expenditure_item_date
                 , PJREQ.expenditure_type
                 , PJREQ.expenditure_organization_id
                 , 'C'
                 , PJREQ.amount
                 ),0)
      )
	);

  Return v_tmp;

  Exception
  	WHEN NO_DATA_FOUND THEN
  		v_tmp := 'N';
  End; -- Eleventh Block, for updated Shop Floor/Inventory Reqs

/* Twelvth Block: NEW Shop Floor/Inventory POs
   Checks the PJM PO Commitments View against PA_Commitment_Txns
   for new Shop Floor/Inventory Purchase Orders
*/

v_tmp := 'N';

  Begin -- Twelvth Block
  /* Commented and Modified for bug 4360855 as below as suggested by PJM Team.
  SELECT 'Y'
  INTO v_tmp
  FROM DUAL
  WHERE EXISTS
    (
    SELECT '1'
    FROM
          PJM_PO_COMMITMENTS_V   PJPO
   WHERE
          PJPO.Project_ID = p_ProjectID
      AND NOT EXISTS (
          SELECT '2'
          FROM PA_COMMITMENT_TXNS CMT
          WHERE CMT.Line_Type = 'P'
            AND CMT.Project_ID = p_ProjectID
	    AND CMT.Burden_Sum_Dest_Run_ID is NULL
            AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
            AND CMT.CMT_Header_ID = PJPO.PO_Header_ID
            AND CMT.CMT_Line_Number = PJPO.PO_Line
            AND CMT.CMT_Distribution_ID = PJPO.PO_Distribution_ID )
    );*/
/* Bug 	5517898 */
  SELECT 1         -- common project
  INTO tmp
  FROM dual where exists (select 1 from pjm_org_parameters
  WHERE common_project_id = p_ProjectID);
/* Bug 	5517898 */
    FOR c_rec in c loop
     Begin
	  SELECT 'Y'
	  INTO  v_tmp
	  FROM 	DUAL
	  WHERE EXISTS (
	    SELECT PO_HEADER_ID,
		   LINE_NUM,
		   PO_DISTRIBUTION_ID
	              FROM (
		      SELECT POL.PO_HEADER_ID,
		             POL.LINE_NUM,
			     POD.PO_DISTRIBUTION_ID
		      FROM   PO_DISTRIBUTIONS_ALL         POD
		      ,      PO_LINES_ALL                 POL
		      ,      PJM_ORG_PARAMETERS           POP
		      ,      MTL_SYSTEM_ITEMS             MSI
		      ,      MTL_UNITS_OF_MEASURE_VL      UOM
		      WHERE  POD.DESTINATION_TYPE_CODE = 'INVENTORY'
		      AND    POL.PO_LINE_ID = POD.PO_LINE_ID
		      AND    POD.PROJECT_ID IS NULL
		      AND    POP.COMMON_PROJECT_ID = p_ProjectID
		      AND    POP.ORGANIZATION_ID = c_rec.organization_id
		      AND    POP.ORGANIZATION_ID = POD.DESTINATION_ORGANIZATION_ID
		      AND    MSI.ORGANIZATION_ID = POD.DESTINATION_ORGANIZATION_ID
		      AND    MSI.INVENTORY_ITEM_ID = POL.ITEM_ID
		      AND    UOM.UOM_CODE = MSI.PRIMARY_UOM_CODE
		      UNION ALL
		      SELECT POL.PO_HEADER_ID,
		             POL.LINE_NUM,
			     POD.PO_DISTRIBUTION_ID
		      FROM   PO_DISTRIBUTIONS_ALL         POD
		      ,      PO_LINES_ALL                 POL
		      ,      PJM_ORG_PARAMETERS           POP
		      ,      WIP_DISCRETE_JOBS            WDJ
		      ,      WIP_OPERATIONS               WO
		      ,      BOM_DEPARTMENTS              BD
		      ,      MTL_UNITS_OF_MEASURE_VL      UOM
		      WHERE  POD.DESTINATION_TYPE_CODE = 'SHOP FLOOR'
		      AND    POL.PO_LINE_ID = POD.PO_LINE_ID
		      AND    POL.PROJECT_ID IS NULL
		      AND    POP.COMMON_PROJECT_ID = p_ProjectID
		      AND    POP.ORGANIZATION_ID = c_rec.organization_id
		      AND    POP.ORGANIZATION_ID = POD.DESTINATION_ORGANIZATION_ID
		      AND    WDJ.ORGANIZATION_ID = POD.DESTINATION_ORGANIZATION_ID
		      AND    WDJ.WIP_ENTITY_ID = POD.WIP_ENTITY_ID
		      AND    WO.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
		      AND    WO.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
		      AND    WO.OPERATION_SEQ_NUM = POD.WIP_OPERATION_SEQ_NUM
		      AND    BD.DEPARTMENT_ID = WO.DEPARTMENT_ID
		      AND    UOM.UNIT_OF_MEASURE = POL.UNIT_MEAS_LOOKUP_CODE)
		      WHERE NOT EXISTS (
			  SELECT '2'
			  FROM PA_COMMITMENT_TXNS CMT
			  WHERE CMT.Line_Type = 'P'
			    AND CMT.Project_ID = p_ProjectID
			    AND CMT.Burden_Sum_Dest_Run_ID is NULL
			    AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
			    AND CMT.CMT_Header_ID = PO_HEADER_ID
			    AND CMT.CMT_Line_Number = LINE_NUM
			    AND CMT.CMT_Distribution_ID = PO_DISTRIBUTION_ID )
		    );
     Return v_tmp;
     Exception
       WHEN NO_DATA_FOUND THEN
       v_tmp := 'N';
     End;
    end loop;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN      -- Regular Project
	  Begin

	  SELECT 'Y'
	  INTO  v_tmp
	  FROM 	DUAL
	  WHERE EXISTS (
	    SELECT PO_HEADER_ID,
	           LINE_NUM,
	           PO_DISTRIBUTION_ID
	      FROM (
		SELECT POL.PO_HEADER_ID,
		       POL.LINE_NUM,
		       POD.PO_DISTRIBUTION_ID
		FROM PO_DISTRIBUTIONS_ALL POD
		    , PO_LINES_ALL POL
		    , MTL_SYSTEM_ITEMS MSI
		    , MTL_UNITS_OF_MEASURE_VL UOM
		    WHERE POD.DESTINATION_TYPE_CODE = 'INVENTORY'
		    AND POD.PROJECT_ID = p_ProjectID
		    AND POL.PO_LINE_ID = POD.PO_LINE_ID
		    AND MSI.ORGANIZATION_ID = POD.DESTINATION_ORGANIZATION_ID
		    AND MSI.INVENTORY_ITEM_ID = POL.ITEM_ID
		    AND UOM.UOM_CODE = MSI.PRIMARY_UOM_CODE
		UNION ALL
		SELECT POL.PO_HEADER_ID,
		       POL.LINE_NUM,
		       POD.PO_DISTRIBUTION_ID
		FROM PO_DISTRIBUTIONS_ALL POD
		    , PO_LINES_ALL POL
		    , WIP_DISCRETE_JOBS WDJ
		    , WIP_OPERATIONS WO
		    , BOM_DEPARTMENTS BD
		    , MTL_UNITS_OF_MEASURE_VL UOM
		    WHERE POD.DESTINATION_TYPE_CODE = 'SHOP FLOOR'
		    AND POD.PROJECT_ID = p_ProjectID
		    AND POL.PO_LINE_ID = POD.PO_LINE_ID
		    AND WDJ.ORGANIZATION_ID = POD.DESTINATION_ORGANIZATION_ID
		    AND WDJ.WIP_ENTITY_ID = POD.WIP_ENTITY_ID
		    AND WO.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
		    AND WO.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
		    AND WO.OPERATION_SEQ_NUM = POD.WIP_OPERATION_SEQ_NUM
		    AND BD.DEPARTMENT_ID = WO.DEPARTMENT_ID
		    AND UOM.UNIT_OF_MEASURE = POL.UNIT_MEAS_LOOKUP_CODE)
	      WHERE NOT EXISTS (
		  SELECT '2'
		  FROM PA_COMMITMENT_TXNS CMT
		  WHERE CMT.Line_Type = 'P'
		    AND CMT.Project_ID = p_ProjectID
		    AND CMT.Burden_Sum_Dest_Run_ID is NULL
		    AND CMT.Transaction_Source = 'ORACLE_PURCHASING'
		    AND CMT.CMT_Header_ID = PO_HEADER_ID
		    AND CMT.CMT_Line_Number = LINE_NUM
		    AND CMT.CMT_Distribution_ID = PO_DISTRIBUTION_ID )
	    );
	  Return v_tmp;

	  Exception
	  	WHEN NO_DATA_FOUND THEN
  			v_tmp := 'N';
	  End;
  End; -- Twelvth Block, for new Shop Floor/Inventory POs

/* Thirteenth Block: Updated Shop Floor/Inventory POs
   Checks the PJM PO Commitments View against PA_Commitment_Txns
   for new Shop Floor/Inventory Purchase Orders
*/

v_tmp := 'N';

  Begin -- Thirteenth Block

  SELECT 'Y'
  INTO v_tmp
  FROM DUAL
  WHERE EXISTS
    (
	SELECT '1'
	FROM PA_COMMITMENT_TXNS CMT
	WHERE 	CMT.Project_ID = p_ProjectID
    AND CMT.Burden_Sum_Dest_Run_ID is NULL
	AND	CMT.Line_Type||'' = 'P'
	AND	CMT.Transaction_Source = 'ORACLE_PURCHASING'
	AND	NOT EXISTS
        (
        SELECT '2'
        FROM
              PJM_PO_COMMITMENTS_V PJPO
            , PO_HEADERS_ALL         POH
            , PO_LINE_LOCATIONS_ALL  PLL
            , PO_DISTRIBUTIONS_ALL   POD
            , PO_LINES_ALL           POL
		  , GL_LEDGERS			  G
        WHERE PJPO.PROJECT_ID = p_ProjectID
          AND PJPO.PO_Header_ID = POH.PO_Header_ID
          AND POL.PO_Header_ID = POH.PO_Header_ID
          AND POD.Distribution_type <> 'PREPAYMENT'
	      AND PJPO.PO_Line = POL.Line_Num
	      AND PJPO.PO_Distribution_ID = POD.PO_Distribution_ID
          AND POL.PO_Line_ID = PLL.PO_Line_ID
          AND PLL.Line_Location_ID = POD.Line_Location_ID
    	  AND PJPO.PO_Header_ID = CMT.CMT_Header_ID
          AND PJPO.PO_Distribution_ID = CMT.CMT_Distribution_ID
          AND CMT.task_id = nvl(PJPO.task_id,0)
          AND NVL(CMT.description,'<prm>') = NVL(PJPO.item_description,'<prm>')
          AND NVL(CMT.expenditure_item_date,sysdate-15000) = NVL(PJPO.expenditure_item_date,sysdate-15000)
          AND NVL(CMT.cmt_creation_date,sysdate-15000) = NVL(PJPO.creation_date,sysdate-15000)
          AND NVL(CMT.cmt_approved_date,sysdate-15000) = NVL(PJPO.approved_date,sysdate-15000)
          AND NVL(CMT.cmt_requestor_name,'<prm>') = NVL(PJPO.requestor_name,'<prm>')
          AND NVL(CMT.cmt_buyer_name,'<prm>') = NVL(PJPO.buyer_name,'<prm>')
          AND NVL(CMT.cmt_approved_flag,'<prm>') = NVL(PJPO.approved_flag,'<prm>')
          AND NVL(CMT.vendor_id,-1) = NVL(PJPO.vendor_id,-1)
          AND NVL(CMT.expenditure_type,'<prm>') = NVL(PJPO.expenditure_type,'<prm>')
          AND NVL(CMT.organization_id,0) = NVL(PJPO.Expenditure_Organization_ID,0)
          AND CMT.expenditure_category = PJPO.expenditure_category
          AND CMT.revenue_category = PJPO.revenue_category
          AND NVL(CMT.unit_of_measure,'<prm>') = NVL(PJPO.unit,'<prm>')
          AND NVL(CMT.unit_price,0) = NVL(PJPO.unit_price , 0)
          AND CMT.original_quantity_ordered = PJPO.quantity_ordered
          AND NVL(CMT.quantity_cancelled,0) = NVL(PJPO.quantity_cancelled,0)
          AND NVL(CMT.quantity_delivered,0) = NVL(PJPO.quantity_delivered,0)
          AND CMT.quantity_invoiced = NVL(PJPO.quantity_invoiced,0)
		AND G.LEDGER_ID = POD.SET_OF_BOOKS_ID
          AND nvl(CMT.denom_raw_cost,0) = GREATEST(0,(PA_CMT_UTILS.get_rcpt_qty(PJPO.po_distribution_id,
                                   			  PJPO.QUANTITY_ORDERED,
                                 			  NVL(PJPO.QUANTITY_CANCELLED,0),
                                 			  NVL(PJPO.QUANTITY_INVOICED,0),'PO',
                                                          PJPO.po_line_id,
                                                          PJPO.project_id,
                                                          PJPO.task_id,
                                                           POD.code_combination_id,0,NULL,NULL, NULL, NULL, nvl(g.sla_ledger_cash_basis_flag,'N')))) *  /*Bug#4905552*/
                                                 ((PLL.PRICE_OVERRIDE) +(NVL(POD.NONRECOVERABLE_TAX,0) / PJPO.QUANTITY_ORDERED))
          AND NVL(CMT.denom_burdened_cost,0) =
             NVL(PA_BURDEN_CMTS.get_cmt_burdened_cost(
                 NULL
                 , 'CMT'
                 , PJPO.task_id
                 , PJPO.expenditure_item_date
                 , PJPO.expenditure_type
                 , PJPO.expenditure_organization_id
                 , 'C'
                 , GREATEST(0,(PA_CMT_UTILS.get_rcpt_qty(PJPO.po_distribution_id,
                                   			  PJPO.QUANTITY_ORDERED,
                                 			  NVL(PJPO.QUANTITY_CANCELLED,0),
                                 			  NVL(PJPO.QUANTITY_INVOICED,0),'PO',
                                                          PJPO.po_line_id,
                                                          PJPO.project_id,
                                                          PJPO.task_id,
                                                         pod.code_combination_id,0,NULL,NULL, NULL, NULL, nvl(g.sla_ledger_cash_basis_flag,'N')))) *  /*Bug#4905552*/
                                                  ((PLL.PRICE_OVERRIDE) +(NVL(POD.NONRECOVERABLE_TAX,0) / PJPO.QUANTITY_ORDERED))
	),0)
      )
     ) ;

  Return v_tmp;

  Exception
  	WHEN NO_DATA_FOUND THEN
  		v_tmp := 'N';
  End; -- Thirteenth Block, for updated Shop Floor/Inventory POs

/* End of code added for the bug #3631172. */

  Return v_tmp;

END Commitments_Changed;

END PA_Check_Commitments;


/
