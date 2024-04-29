--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_CHECK_CMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_CHECK_CMT" AS
/* $Header: PACECMTB.pls 120.2 2005/07/06 15:10:37 sbharath noship $*/


FUNCTION COMMITMENTS_CHANGED ( p_ProjectID IN NUMBER )
	RETURN VARCHAR2
IS

v_tmp		VARCHAR2(1) := 'N';

BEGIN

/** The below code lists all standard sqls to identify whether commitments
    have changed or not since the last summarization run. Customers can
    uncomment the below code to check whether commitments have changed or not.
    One benefit of uncommenting the below code is that customers can add hints
    (which are suitable for the data distribution that exists in their system)
    to the below sqls which will make the Summarization process much faster.
    The default code which is written below inside comments is simlar to
    what has been coded inside the standard Oracle Projects function
    PA_CHECK_COMMITMENTS.COMMITMENTS_CHANGED. If customer uncomments the below
    code then the same code in PA_CHECK_COMMITMENTS.COMMITMENTS_CHANGED
    will not get executed again ensuring that performance is not hit.

    If customers want they can modify a part of or entire code below to account
    for the way they want to consider whether commitments have changed or not.

    This function should be able to determine whether the user defined
    commitments have changed from the last summarization run or not.
    If the commitments have changed, then the function should return
    Y, else it should return S indicating STOP. If customers return 'N'
    from this procedure then the code in standard Oracle Projects function
    PA_CHECK_COMMITMENTS.COMMITMENTS_CHANGED will also get executed.
    So for users who are going to uncomment the below code it is not
    recommended to return 'N' from this function.

    If Y is returned, then the summarization process would rebuild the
    commitments, if S is returned then it will not rebuild the
    commitments and if N is returned then it may or may not rebuild the commitments
    depending on the output of the sqls coded inside standard Oracle Projects function
    PA_CHECK_COMMITMENTS.COMMITMENTS_CHANGED. **/

   v_tmp := 'N';

 -- Code addition for bug 3258046 starts
/*

 --Second Block: NEW REQUISITIONS
 --Checks the PO Req Distributions' tables against PA_Commitment_Txns
 --for new Purchase Requisitions

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
            , PO_DOCUMENT_TYPES           PDT
            , PO_LINE_TYPES               LT
            , PA_TASKS                    T
            , HR_ALL_ORGANIZATION_UNITS   O
            , PA_EXPENDITURE_TYPES        ET
            , PA_PROJECTS                 P
        WHERE
          RH.REQUISITION_HEADER_ID = RL.REQUISITION_HEADER_ID
          AND RH.TYPE_LOOKUP_CODE = 'PURCHASE'
          AND PDT.DOCUMENT_TYPE_CODE = 'REQUISITION'
          AND RH.TYPE_LOOKUP_CODE = PDT.DOCUMENT_SUBTYPE
          AND RL.LINE_LOCATION_ID IS NULL
          AND NVL(RL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
          AND NVL(RL.CANCEL_FLAG,'N') = 'N'
          AND NVL(RL.MODIFIED_BY_AGENT_FLAG,'N') = 'N'
          AND RL.SOURCE_TYPE_CODE = 'VENDOR'
          AND REQ.PERSON_ID = RL.TO_PERSON_ID
          AND TRUNC(SYSDATE)
              BETWEEN NVL(REQ.EFFECTIVE_START_DATE,TRUNC(SYSDATE))
          AND NVL(REQ.EFFECTIVE_END_DATE,TRUNC(SYSDATE))
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
        v_tmp := 'S';
  End; -- Second Block, for new PO Reqs


-- Third Block: NEW AP INVOICES
-- Checks the AP Inv Distributions' tables against PA_Commitment_Txns
-- for new Invoices


v_tmp := 'S';

  Begin -- Third Block

  SELECT 'Y'
  INTO  v_tmp
  FROM 	DUAL
  WHERE EXISTS (
   	SELECT '1'  -- may use push_subq hint here
    FROM
        AP_INVOICES_ALL                 I
        , PO_DISTRIBUTIONS              POD
        , AP_INVOICE_DISTRIBUTIONS_ALL  D
    WHERE
      I.Invoice_ID = D.Invoice_ID
      AND D.PO_Distribution_ID = POD.PO_Distribution_ID(+)
      AND POD.Distribution_type <> 'PREPAYMENT'
      AND NVL(POD.Destination_Type_Code, 'EXPENSE') = 'EXPENSE'
      AND decode(D.Pa_Addition_Flag,'Z','Y','T','Y','E','Y',null,'N',D.Pa_Addition_Flag) <> 'Y'
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
          -- AND CMT.CMT_Line_Number = D.Distribution_Line_Number ) -- R12 change
          AND CMT.CMT_Distribution_ID = D.Invoice_Distribution_ID) -- R12 change
    );

  Return v_tmp;

  Exception
    WHEN NO_DATA_FOUND THEN
        v_tmp := 'S';
  End; -- Third Block, for new AP Invoices


-- Fourth Block: NEW POs
-- Checks the PO distributions' tables against PA_Commitment_Txns
-- for new POs


  v_tmp := 'S';

  Begin -- Fourth Block

  SELECT 'Y'
  INTO v_tmp
  FROM DUAL
  WHERE EXISTS
    (
    SELECT '1'   -- may use ordered and push_subq hints here
    FROM
          PO_DISTRIBUTIONS_ALL   POD
        , PO_HEADERS_ALL         POH
        , PO_LINES_ALL           POL
        , PO_RELEASES_ALL        POR
        , PO_DOCUMENT_TYPES      PDT
        , PO_LINE_LOCATIONS_ALL  PLL
        , PER_ALL_PEOPLE_F       BUY
        , PER_ALL_PEOPLE_F       REQ
    WHERE
      POH.AGENT_ID = BUY.PERSON_ID
      AND TRUNC(SYSDATE)
          BETWEEN BUY.EFFECTIVE_START_DATE
      AND BUY.EFFECTIVE_END_DATE
      AND POD.DELIVER_TO_PERSON_ID = REQ.PERSON_ID(+)
      AND POD.Distribution_type <> 'PREPAYMENT'
      AND NVL(POD.Destination_Type_Code, 'EXPENSE') = 'EXPENSE'
      AND TRUNC(SYSDATE)
          BETWEEN NVL(REQ.EFFECTIVE_START_DATE,TRUNC(SYSDATE))
      AND NVL(REQ.EFFECTIVE_END_DATE,TRUNC(SYSDATE))
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
         v_tmp := 'S';

  End; -- Fourth Block, for new POs


-- Fifth Block: UPDATED POs
-- Checks the PO distributions' tables against PA_Commitment_Txns
-- for updated POs
-- Note: For POs, all amounts are captured in Oracle Purchasing as denom amounts.


  v_tmp := 'S';

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
            , PO_LINES_ALL           POL
            , PO_LINE_TYPES          LT
            , PO_LINE_LOCATIONS_ALL  PLL
            , PER_ALL_PEOPLE_F       BUY
            , PER_ALL_PEOPLE_F       REQ
            , HR_ALL_ORGANIZATION_UNITS  O
            , PA_EXPENDITURE_TYPES   ET
            , PA_TASKS               T
            , PO_DISTRIBUTIONS_ALL   POD
            , PA_PROJECTS            P
        WHERE
              POH.AGENT_ID = BUY.PERSON_ID
          AND TRUNC(SYSDATE)
              BETWEEN BUY.EFFECTIVE_START_DATE
          AND BUY.EFFECTIVE_END_DATE
          AND POD.DELIVER_TO_PERSON_ID = REQ.PERSON_ID(+)
      AND POD.Distribution_type <> 'PREPAYMENT'
      AND NVL(POD.Destination_Type_Code, 'EXPENSE') = 'EXPENSE'
          AND TRUNC(SYSDATE)
              BETWEEN NVL(REQ.EFFECTIVE_START_DATE,TRUNC(SYSDATE))
          AND NVL(REQ.EFFECTIVE_END_DATE,TRUNC(SYSDATE))
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
      AND POD.PO_Distribution_ID = CMT.CMT_Distribution_ID
      and CMT.task_id = nvl(pod.task_id,0)
      and NVL(CMT.description,'<prm>') = NVL(POL.item_description,'<prm>')
      and NVL(CMT.expenditure_item_date,sysdate-15000) = NVL(POD.expenditure_item_date,sysdate-15000)
      and NVL(CMT.cmt_creation_date,sysdate-15000) = NVL(decode(POR.release_num,NULL,POH.creation_date,POR.creation_date),sysdate-15000)
      and NVL(CMT.cmt_approved_date,sysdate-15000) = NVL(decode(POR.release_num,NULL,POH.approved_date,POR.approved_date),sysdate-15000)
      and NVL(CMT.cmt_requestor_name,'<prm>') = NVL(REQ.full_name,'<prm>')
      and NVL(CMT.cmt_buyer_name,'<prm>') = NVL(BUY.full_name,'<prm>')
      and NVL(CMT.cmt_approved_flag,'<prm>') = NVL(decode(POR.release_num,NULL,decode(POH.authorization_status,'APPROVED','Y','N'),decode(POR.authorization_status,'APPROVED','Y','N')),'<prm>')
      and NVL(CMT.vendor_id,-1) = NVL(POH.vendor_id,-1)
      and NVL(CMT.expenditure_type,'<prm>') = NVL(POD.expenditure_type,'<prm>')
      and NVL(CMT.organization_id,0) = NVL(O.organization_id,0)
      and CMT.expenditure_category = ET.expenditure_category
      and CMT.revenue_category = ET.revenue_category_code
      and NVL(CMT.unit_of_measure,'<prm>') = NVL(decode(PLL.VALUE_BASIS,'AMOUNT',NULL,POL.unit_meas_lookup_code),'<prm>')
      and NVL(CMT.unit_price,0) = NVL(TO_NUMBER(decode(PLL.VALUE_BASIS,'AMOUNT',NULL,( PLL.price_override * NVL(POD.rate,1)))),0)
      and CMT.original_quantity_ordered = POD.quantity_ordered
      and NVL(CMT.quantity_cancelled,0) = NVL(POD.quantity_cancelled,0)
      and NVL(CMT.quantity_delivered,0) = NVL(POD.quantity_delivered,0)
      and CMT.quantity_invoiced = NVL(POD.quantity_billed,0)
      and nvl(CMT.denom_raw_cost,0) = GREATEST(0,(POD.QUANTITY_ORDERED-NVL(POD.QUANTITY_CANCELLED,0)
        -NVL(POD.QUANTITY_BILLED,0))) * ((PLL.PRICE_OVERRIDE) +
        (NVL(POD.NONRECOVERABLE_TAX,0) / POD.QUANTITY_ORDERED))
      and NVL(CMT.denom_burdened_cost,0) =
             NVL(PA_BURDEN_CMTS.get_cmt_burdened_cost(
                 NULL
                 , 'CMT'
                 , T.task_id
                 , POD.expenditure_item_date
                 , POD.expenditure_type
                 , O.organization_id
                 , 'C'
                 , GREATEST(0,(POD.QUANTITY_ORDERED-NVL(POD.QUANTITY_CANCELLED,0)
        -NVL(POD.QUANTITY_BILLED,0))) * ((PLL.PRICE_OVERRIDE) +
        (NVL(POD.NONRECOVERABLE_TAX,0) / POD.QUANTITY_ORDERED)) ),0)
      )
     );

  Return v_tmp;

  Exception
  	WHEN NO_DATA_FOUND THEN
	     v_tmp := 'S';

  End; -- Fifth Block, for updated POs


-- Sixth Block: UPDATED INVOICES
-- Checks the AP Inv Distributions' tables against PA_Commitment_Txns
-- for updated Invoices
-- Note: For AP Invoices, all amounts are captured in Oracle Payables as denom amounts.


  v_tmp := 'S';

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
          AND decode(D.pa_addition_flag,'Z','Y','T','Y','E','Y',null,'N',D.pa_addition_flag) <> 'Y'
            AND ( ES.system_linkage_function  = 'VI' OR
                  ( ES.system_linkage_function = 'ER' AND
                      V.employee_id IS NOT NULL ))
          AND D.po_distribution_id = PO.po_distribution_id (+)
          AND PO.Distribution_type <> 'PREPAYMENT'
          AND nvl(PO.destination_type_code, 'EXPENSE') = 'EXPENSE'
          AND D.project_id = P.project_id
          AND D.task_id = T.task_id
          AND D.expenditure_organization_id = O.organization_id
          AND D.expenditure_type = ES.expenditure_type
          AND ET.expenditure_type = ES.expenditure_type
          AND nvl(I.source, 'xxx') not in ('Oracle Project Accounting','PA_IC_INVOICES')
          AND D.project_id = p_ProjectID
      and CMT.task_id = nvl(d.task_id,0)
      AND I.Invoice_ID = CMT.CMT_Header_ID
      AND D.Distribution_Line_Number = CMT.CMT_Line_Number
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
	     v_tmp := 'S';

  End; -- Sixth Block, for updated AP Invoices


-- Seventh Block: UPADTED REQUISTIONS
--   Checks the PO Req Distributions' tables against PA_Commitment_Txns
--   for updated Purchase Requisitions

--   Note: For Requisitions, unit price is always captured in accounting currency! Therefore,
--         the raw cost and burdened cost comparative joins in this block use ACCT columns.

--         Please note that this is different than Updated POs and AP Invoices.


  v_tmp := 'S';

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
             , PO_DOCUMENT_TYPES           PDT
             , PO_LINE_TYPES               LT
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
          AND RL.LINE_LOCATION_ID IS NULL
          AND NVL(RL.CLOSED_CODE,'OPEN') <> 'FINALLY CLOSED'
          AND NVL(RL.CANCEL_FLAG,'N') = 'N'
          AND NVL(RL.MODIFIED_BY_AGENT_FLAG,'N') = 'N'
          AND RL.SOURCE_TYPE_CODE = 'VENDOR'
          AND REQ.PERSON_ID = RL.TO_PERSON_ID
          AND TRUNC(SYSDATE)
              BETWEEN NVL(REQ.EFFECTIVE_START_DATE,TRUNC(SYSDATE))
          AND NVL(REQ.EFFECTIVE_END_DATE,TRUNC(SYSDATE))
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
  		v_tmp := 'S';
  End; -- Seventh Block, for updated PO Reqs


-- Eighth Block: UPDATED MFG COMMITMENTS
-- Checks the CST_PROJMFG_CMT_VIEW against PA_Commitment_Txns
-- for updated commitments

-- Note: For MFG commitments, the view returns both acct and denom amounts for most amount
--       columns, So, where possible, joins are performed for denom amounts.


v_tmp := 'S';

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
  		v_tmp := 'S';
  End; -- Eighth Block, for updated commitments from CST_PROJMFG_CMT_VIEW


-- Ninth Block: NEW MFG COMMITMENTS
-- Checks the CST_PROJMFG_CMT_VIEW against PA_Commitment_Txns
-- for new commitments


v_tmp := 'S';

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
  		v_tmp := 'S';
  End; -- Ninth Block, for new commitments from CST_PROJMFG_CMT_VIEW

*/
-- Code addition for bug 3258046 ends
  Return v_tmp;

END Commitments_Changed;

END PA_CLIENT_EXTN_CHECK_CMT;

/
