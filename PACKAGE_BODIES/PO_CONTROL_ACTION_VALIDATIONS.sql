--------------------------------------------------------
--  DDL for Package Body PO_CONTROL_ACTION_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CONTROL_ACTION_VALIDATIONS" AS
/* $Header: PO_CONTROL_ACTION_VALIDATIONS.plb 120.0.12010000.22 2014/03/28 02:50:40 roqiu noship $ */


-- The module base for this package.
g_debug_stmt  CONSTANT BOOLEAN      := (PO_DEBUG.is_debug_stmt_on And (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
g_debug_unexp CONSTANT BOOLEAN      := (PO_DEBUG.is_debug_unexp_on AND (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL));
g_pkg_name    CONSTANT varchar2(50) :=  PO_LOG.get_package_base('PO_CONTROL_ACTION_VALIDATIONS');


--------------------------------------------------------------
-- Common Validation Subroutines Constants
--------------------------------------------------------------

c_can_qty_rec_grt_ord             CONSTANT VARCHAR2(30) := 'C_CAN_QTY_REC_GRT_ORD';
c_can_qty_bill_grt_ord            CONSTANT VARCHAR2(30) := 'C_CAN_QTY_BILL_GRT_ORD';
c_can_qty_del_grt_ord             CONSTANT VARCHAR2(30) := 'C_CAN_QTY_DELL_GRT_ORD';
c_can_qty_rec_not_del             CONSTANT VARCHAR2(30) := 'C_CAN_QTY_REC_NOT_DEL';
c_can_qty_bill_grt_rec            CONSTANT VARCHAR2(30) := 'C_CAN_QTY_BILL_GRT_REC';
c_can_qty_bill_grt_del            CONSTANT VARCHAR2(30) := 'C_CAN_QTY_BILL_GRT_DEL';
c_can_ship_dist_diff_qty          CONSTANT VARCHAR2(30) := 'C_CAN_SHIP_DIST_DIFF_QTY';
c_can_line_ship_diff_qty          CONSTANT VARCHAR2(30) := 'C_CAN_LINE_SHIP_DIFF_QTY';
c_can_lcm_match_option_chk        CONSTANT VARCHAR2(30) := 'C_CAN_LCM_MATCH_OPTION_CHK';
c_can_lcm_dest_type_chk           CONSTANT VARCHAR2(30) := 'C_CAN_LCM_DEST_TYPE_CHK';
c_can_line_ship_diff_price        CONSTANT VARCHAR2(30) := 'C_CAN_LINE_SHIP_DIFF_PRICE';
c_can_line_price_grt_limit        CONSTANT VARCHAR2(30) := 'C_CAN_LINE_PRICE_GRT_LIMIT';


c_can_invalid_budget_acct_flex    CONSTANT VARCHAR2(30) := 'C_CAN_INVALID_BUDGET_ACCT_FLEX';
c_can_invalid_charge_acct_flex    CONSTANT VARCHAR2(30) := 'C_CAN_INVALID_CHARGE_ACCT_FLEX';

c_can_with_pending_rcv_trx        CONSTANT VARCHAR2(30) := 'C_CAN_WITH_PENDING_RCV_TRX';
c_can_with_asn                    CONSTANT VARCHAR2(30) := 'C_CAN_WITH_ASN';


--------------------------------------------------------------
-- Cancel Planned PO Header Validation Subroutine Constants
--------------------------------------------------------------
c_can_po_pa_with_open_rel 	  CONSTANT VARCHAR2(30) := 'C_CAN_PO_PA_WITH_OPEN_REL';


--------------------------------------------------------------
-- Cancel Blanket agreement Header Validation Subroutine Constants
--------------------------------------------------------------
c_can_ga_with_open_std_ref 	  CONSTANT VARCHAR2(30) := 'C_CAN_GA_WITH_OPEN_STD_REF';


--------------------------------------------------------------
-- Cancel Contract Agreement Validation Subroutine Constants
--------------------------------------------------------------
c_can_cga_with_open_std_ref 	  CONSTANT VARCHAR2(30) := 'C_CAN_CGA_WITH_OPEN_STD_REF';


--------------------------------------------------------------
-- Cancel Custom Validation Subroutine Constants
--------------------------------------------------------------
c_can_custom_validation 	  CONSTANT VARCHAR2(30) := 'C_CAN_CUSTOM_VALIDATION';


  -- Business Rule Validation set for Cancel Action
  cancel_validation_set CONSTANT PO_TBL_VARCHAR2000  := PO_TBL_VARCHAR2000(
   c_can_ship_dist_diff_qty
  ,c_can_line_ship_diff_qty
  ,c_can_line_ship_diff_price
  ,c_can_lcm_match_option_chk
  ,c_can_lcm_dest_type_chk
  ,c_can_line_price_grt_limit
  ,c_can_qty_rec_grt_ord
  ,c_can_qty_bill_grt_ord
  ,c_can_qty_del_grt_ord
  ,c_can_with_pending_rcv_trx
  ,c_can_qty_rec_not_del
  ,c_can_invalid_budget_acct_flex
  ,c_can_invalid_charge_acct_flex
  ,c_can_qty_bill_grt_rec
  ,c_can_qty_bill_grt_del
  ,c_can_with_asn
  ,c_can_po_pa_with_open_rel
  ,c_can_ga_with_open_std_ref
  ,c_can_cga_with_open_std_ref
  ,c_can_custom_validation);


--------------------------------------------------------------------------------
--Start of Comments
--Name: qty_rec_grt_ord_chk

--Function:
--  Validates If there are any Uncancelled shipments that have been received more
--  than they ordered (Fully Received) , the PO/Release Header/Line/Shipment cannot be cancelled
--
--Parameters:
--IN:
--  p_online_report_id
--  p_key
--  p_login_id
--  p_user_id
--  p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------
PROCEDURE qty_rec_grt_ord_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'qty_rec_grt_ord_chk.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;

    l_progress   VARCHAR2(3)   := '000' ;
    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token  NVARCHAR2(20);
    l_qty_token  NVARCHAR2(20);


  BEGIN
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;

    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress := '001';
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');


    -- Gt Table Columns Mapping
    --  num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and subtype=Planned/
    --    Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA
    INSERT INTO PO_ONLINE_REPORT_TEXT
      (ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
	  CREATION_DATE,
	  LINE_NUM,
	  SHIPMENT_NUM,
	  DISTRIBUTION_NUM,
	  SEQUENCE,
	  TEXT_LINE,
	  transaction_id,
	  transaction_type)
	(SELECT
	  p_online_report_id,
	  p_login_id,
	  p_user_id,
	  SYSDATE,
	  p_user_id,
	  SYSDATE,
	  POL.LINE_NUM,
	  poll.SHIPMENT_NUM,
	  0,
	  p_sequence + ROWNUM,
	  PO_CORE_S.get_translated_text
	    ('PO_CAN_SHIP_REC_GRT_ORD',
	    'LINE_SHIP_DIST_NUM', l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM,
	    'AMT_QTY_TOKEN', DECODE(poll.matching_basis, 'AMOUNT',l_amt_token,l_qty_token),
	    'QTY1',  DECODE(poll.matching_basis, 'AMOUNT', Nvl(poll.amount_received, 0), Nvl(poll.quantity_received, 0)),
	    'QTY2',  DECODE(poll.matching_basis, 'AMOUNT', Nvl(poll.amount, 0), Nvl(poll.quantity, 0)) ,
	    'DOC_NUM',gt.char6),
	  gt.num1,
	  gt.char3
	FROM
	  po_line_locations poll,
	  po_lines pol ,
	  po_session_gt gt
	WHERE gt.key=p_key
	      AND poll.line_location_id = gt.index_num1 -- lowestentityid i.e.
	      AND poll.po_line_id = pol.po_line_id
		  AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
		  AND gt.char2 <> po_document_cancel_pvt.c_doc_subtype_PLANNED
		  AND ((POLL.matching_basis ='QUANTITY'
				AND round(nvl(POLL.quantity_received,0),5) >0
	            AND round(nvl(POLL.quantity_received,0),5)  > = round(nvl(POLL.quantity,0),5))
	          OR
	          (POLL.matching_basis ='AMOUNT'
	           AND round(nvl(POLL.amount_received,0),5) >0
	           AND round(nvl(POLL.amount_received,0),5)  >= round(nvl(POLL.amount,0),5)))
	         );


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF ;

    EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END qty_rec_grt_ord_chk;

--------------------------------------------------------------------------------
-- Start of Comments
--
--Name: line_price_chk
--
-- Function: Validates if the Line Price is not exceeding the Price Limit
--
--Parameters:
--IN:
--  p_online_report_id
--  p_key
--  p_login_id
-- p_user_id
-- p_sequence
--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data
--
-- End of Comments
--------------------------------------------------------------------------------
PROCEDURE line_price_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'line_price_chk.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;

    l_progress   VARCHAR2(3)   := '000' ;
    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token  NVARCHAR2(20);
    l_amt_token   NVARCHAR2(20);
    l_price_token NVARCHAR2(20);


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;


    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress := '001';
    l_line_token  := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_amt_token   := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_price_token := fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE');



    --Gt Table Columns Mapping
    --num1        -    entity_id
    --char1       -    document_type
    --char2       -    document_subtype
    --char3       -    entity_level
    --char4       -    doc_id
    --char5       -    process_entity_flag
    --date1       -    entity_action_date
    --index_num1  -    lowestentityid
    --lowestentityid :
  	--  shipmentid in case of  document type= PO/Releases and
    --  subtype= Planned/Standard at any entity level
  	--  Lineid in case of BPA and GBPA  at any entity level
  	--  Headerid  in case of CPA

    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
   (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text(
        'PO_CAN_PRICE_LIMIT_LT_PRICE',
        'LINE_SHIP_DIST_NUM',
        l_line_token||pol.LINE_NUM,
       'AMT_PRICE_TOKEN',
        DECODE(pol.amount, NULL,l_price_token,l_amt_token),
        'PRICE1',
        DECODE(pol.amount, NULL,pol.unit_price,pol.amount),
        'PRICE2',
        pol.not_to_exceed_price,
        'DOC_NUM',gt.char6),
        gt.num1,
        gt.char3
    FROM
      po_lines pol,
      po_session_gt gt
    WHERE
     gt.key = p_key
     AND gt.char1 = po_document_cancel_pvt.c_doc_type_PA
     AND gt.char2 <>po_document_cancel_pvt.c_doc_subtype_contract
     AND pol.po_line_id=gt.index_num1
     AND nvl(POL.allow_price_override_flag, 'N') = 'Y'
     AND POL.not_to_exceed_price IS NOT NULL
     AND ((POL.unit_price IS NOT NULL and POL.not_to_exceed_price < POL.unit_price)
           or
          (POL.amount IS NOT NULL and POL.not_to_exceed_price < POL.amount)));



    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END line_price_chk;


--------------------------------------------------------------------------------
--Start of Comments
--
--Name: line_ship_qty_chk
--
-- Function:
-- Validates if the Quantities/Amounts match between Line and  Shipments
-- if it doesnot match,then the PO/Release Header/Line cannot be cancelled
--
--Parameters:
--IN:
--  p_online_report_id
--  p_key
--  p_login_id
-- p_user_id
-- p_sequence
--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE line_ship_qty_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS
    d_api_name CONSTANT VARCHAR2(30) := 'line_ship_qty_chk.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress VARCHAR2(3) := '000';
    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;

    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress := '001';
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');

    --Gt Table Columns Mapping
    --num1        -    entity_id
    --char1       -    document_type
    --char2       -    document_subtype
    --char3       -    entity_level
    --char4       -    doc_id
    --char5       -    process_entity_flag
    --date1       -    entity_action_date
    --index_num1  -    lowestentityid
    --lowestentityid :
  	--  shipmentid in case of  document type= PO/Releases and
    --  subtype= Planned/Standard at any entity level
  	--  Lineid in case of BPA and GBPA  at any entity level
  	--  Headerid  in case of CPA

    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
   (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text(
        'PO_CAN_PO_LINE_NE_SHIP_AMT',
        'LINE_SHIP_DIST_NUM',
        l_line_token||pol.LINE_NUM,
        'AMT_QTY_TOKEN',
        DECODE(pol.amount, NULL,l_qty_token,l_amt_token),
        'QTY1',
        DECODE(pol.amount, null, pol.quantity,pol.amount),
        'QTY2',
        DECODE(
          pol.amount,
           null,
          (SELECT Sum(poll.quantity - nvl(poll.quantity_cancelled,0))
           FROM   po_line_locations poll
           WHERE  poll.po_line_id = pol.po_line_id ),
          (SELECT sum(poll.amount - nvl(poll.amount_cancelled,0))
           FROM   po_line_locations poll
           WHERE  poll.po_line_id = pol.po_line_id )),
        'DOC_NUM',(SELECT segment1 FROM po_headers WHERE po_header_id=pol.po_header_id)),
        (SELECT gt.num1
         FROM   po_session_gt gt
         WHERE gt.KEY=p_key
              AND gt.num1 IN
               (SELECT pol1.po_line_id
                FROM   po_lines pol1
                WHERE  pol1.po_line_id=pol.po_line_id
                       AND gt.char3=po_document_cancel_pvt.c_entity_level_LINE
           UNION ALL
            SELECT pol1.po_header_id
            FROM   po_lines pol1
            WHERE  pol1.po_line_id=pol.po_line_id
                   AND gt.char3=po_document_cancel_pvt.c_entity_level_HEADER)),
        (SELECT gt.char3
         FROM  po_session_gt gt
         WHERE
         gt.KEY=p_key
         AND gt.num1 IN
           (SELECT pol1.po_line_id
            FROM po_lines pol1
            WHERE pol1.po_line_id=pol.po_line_id
                  AND gt.char3=po_document_cancel_pvt.c_entity_level_LINE
           UNION ALL
            SELECT pol1.po_header_id
            FROM   po_lines pol1
            WHERE  pol1.po_line_id=pol.po_line_id
                   AND gt.char3=po_document_cancel_pvt.c_entity_level_HEADER))

    FROM
      po_lines pol
    WHERE
     pol.po_line_id IN
       (SELECT DISTINCT po_line_id
         FROM  po_line_locations,
               po_session_gt gt
         WHERE gt.KEY=p_key
               AND line_location_id= gt.index_num1 -- lowestentityid)
               AND gt.char1 = po_document_cancel_pvt.c_doc_type_PO
               AND gt.char3<> po_document_cancel_pvt.c_entity_level_SHIPMENT)

      AND ((POL.quantity IS NOT null
            AND pol.quantity <> (SELECT Sum(poll.quantity - nvl(poll.quantity_cancelled,0))
                                 FROM   po_line_locations poll
                                 WHERE  poll.po_line_id = pol.po_line_id))
           OR
           (POL.amount IS NOT null
            AND pol.amount <> (SELECT sum(poll.amount- nvl(poll.amount_cancelled,0))
                               FROM   po_line_locations poll
                               WHERE  poll.po_line_id = pol.po_line_id )))
       );


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END line_ship_qty_chk;


--------------------------------------------------------------------------------
--Start of Comments
--Name: line_ship_price_chk
--
-- Function:
--  Validates if the Unit Price/Price_override matches between Line and Shipments
--  if it doesnot match,then the PO/Release Header/Line cannot be cancelled
--
--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE line_ship_price_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'line_ship_price_chk';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress VARCHAR2(3) := '000';

    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;

    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress := '001';
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');

    --Gt Table Columns Mapping
    --num1        -    entity_id
    --char1       -    document_type
    --char2       -    document_subtype
    --char3       -    entity_level
    --char4       -    doc_id
    --char5       -    process_entity_flag
    --date1       -    entity_action_date
    --index_num1  -    lowestentityid
    --lowestentityid :
  	--  shipmentid in case of  document type= PO/Releases and
    --  subtype= Planned/Standard at any entity level
  	--  Lineid in case of BPA and GBPA  at any entity level
  	--  Headerid  in case of CPA

    -- 18056560, update the select statement to hit the index of table po_line_locations and po_lines.
    FOR l_po_session IN
     (SELECT gt.index_num1,gt.char6,gt.num1,gt.char3
    FROM po_session_gt gt
    WHERE gt.key  = p_key
    AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA) LOOP
	    INSERT INTO PO_ONLINE_REPORT_TEXT(
	      ONLINE_REPORT_ID,
	      LAST_UPDATE_LOGIN,
	      LAST_UPDATED_BY,
	      LAST_UPDATE_DATE,
	      CREATED_BY,
	      CREATION_DATE,
	      LINE_NUM,
	      SHIPMENT_NUM,
	      DISTRIBUTION_NUM,
	      SEQUENCE,
	      TEXT_LINE,
	      transaction_id,
	      transaction_type)
	   (SELECT
	      p_online_report_id,
	      p_login_id,
	      p_user_id,
	      SYSDATE,
	      p_user_id,
	      SYSDATE,
	      POL.LINE_NUM,
	      poll.SHIPMENT_NUM,
	      0,
	      p_sequence + ROWNUM,
	      PO_CORE_S.get_translated_text(
	        'PO_CAN_SHIP_PRICE_NE_LINE',
	        'LINE_SHIP_DIST_NUM',
	        l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM,
	        'PRICE1',
	        pol.unit_price,
	        'PRICE2',
	        poll.price_override,
	        'DOC_NUM',
	        l_po_session.char6),
	      l_po_session.num1,
	      l_po_session.char3
	    FROM
	      po_line_locations_all poll,
	      po_lines_all pol
	    WHERE   poll.line_location_id = l_po_session.index_num1 -- lowestentityid i.e.
	      AND   poll.po_line_id = pol.po_line_id
	      AND   pol.unit_price <> poll.price_override
	      AND   poll.shipment_type in ('STANDARD','PLANNED')
	      AND   po_control_action_validations.is_complex_work_po(poll.po_header_id) ='N' );

	      p_sequence := P_SEQUENCE + SQL%ROWCOUNT;
    end loop;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END line_ship_price_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:ship_dist_qty_chk
--
-- Function:
-- Validates if the Quantities/Amounts match between Shipments and Distributions
-- if it doesnot match,then the PO/Release Header/Line/Shipment cannot be cancelled
--
--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE ship_dist_qty_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'ship_dist_qty_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';
    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress := '001';
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');



    --Gt Table Columns Mapping
    --num1        -    entity_id
    --char1       -    document_type
    --char2       -    document_subtype
    --char3       -    entity_level
    --char4       -    doc_id
    --char5       -    process_entity_flag
    --date1       -    entity_action_date
    --index_num1  -    lowestentityid
    --lowestentityid :
  	--  shipmentid in case of  document type= PO/Releases and
    --  subtype= Planned/Standard at any entity level
  	--  Lineid in case of BPA and GBPA  at any entity level
  	--  Headerid  in case of CPA



    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
   (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text(
        'PO_CAN_PO_SHIP_NE_DIST_AMT',
        'LINE_SHIP_DIST_NUM',
        l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM,
        'AMT_QTY_TOKEN',
        DECODE(poll.matching_basis, 'AMOUNT',l_amt_token,l_qty_token),
        'QTY1',
        DECODE(poll.matching_basis, 'AMOUNT', Nvl(poll.amount, 0), Nvl(poll.quantity, 0)),
        'QTY2',
        DECODE(
          poll.matching_basis,
          'AMOUNT',
          (SELECT sum(POD2.amount_ordered)
          FROM   PO_DISTRIBUTIONS_ALL POD2
          WHERE  POD2.line_location_id = poll.line_location_id ),
         (SELECT sum(POD2.quantity_ordered)
          FROM   PO_DISTRIBUTIONS_ALL POD2
          WHERE  POD2.line_location_id = poll.line_location_id )),
        'DOC_NUM',
        gt.char6
        ),
      gt.num1,
      gt.char3
    FROM
      po_line_locations poll,
      po_lines pol ,
      po_session_gt gt
    WHERE
      gt.key=p_key
      AND   poll.line_location_id = gt.index_num1 -- lowestentityid i.e.
      AND   poll.po_line_id = pol.po_line_id
      AND   gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
      AND   ((POLL.quantity IS NOT null
              AND POLL.quantity <> (SELECT sum(POD2.quantity_ordered)
                                    FROM   PO_DISTRIBUTIONS_ALL POD2
                                    WHERE  POD2.line_location_id = poll.line_location_id ))
             OR
             (POLL.amount IS NOT null
              AND POLL.amount <> (SELECT sum(POD2.amount_ordered)
                                  FROM   PO_DISTRIBUTIONS_ALL POD2
                                  WHERE  POD2.line_location_id = poll.line_location_id )))
       );


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ship_dist_qty_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:lcm_match_option_chk
--
-- Function:
--   Validates if the document is LCM enabled then its shipment
--   must have the invoice match option as 'Receipt'
--   If the validation fails, teh documnet cannot be cancelled
--
--
--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE lcm_match_option_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'lcm_match_option_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';

    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress := '001';
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');



    --Gt Table Columns Mapping
    --num1        -    entity_id
    --char1       -    document_type
    --char2       -    document_subtype
    --char3       -    entity_level
    --char4       -    doc_id
    --char5       -    process_entity_flag
    --date1       -    entity_action_date
    --index_num1  -    lowestentityid
    --lowestentityid :
  	--  shipmentid in case of  document type= PO/Releases and
    --  subtype= Planned/Standard at any entity level
  	--  Lineid in case of BPA and GBPA  at any entity level
  	--  Headerid  in case of CPA



    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
   (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text(
        'PO_CAN_SHIP_INV_MATCH_NE_R',
        'LINE_SHIP_DIST_NUM',
        l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM,
        'DOC_NUM',
        gt.char6
          ),
      gt.num1,
      gt.char3
    FROM
      po_line_locations poll,
      po_lines pol ,
      po_session_gt gt
    WHERE
      gt.key=p_key
      AND   poll.line_location_id = gt.index_num1 -- i.e lowestentityid .
      AND   poll.po_line_id = pol.po_line_id
      AND   gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
      AND   Nvl(poll.LCM_FLAG,'N') = 'Y'
      AND   Nvl(poll.match_option,'P') <> 'R');


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END lcm_match_option_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:lcm_dest_type_chk
--
-- Function:
--  Validates if the document is LCM enabled then distribution
--  must have the destination type as 'Inventory'
--  If the validation fails, teh documnet cannot be cancelled
--
--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE lcm_dest_type_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'lcm_dest_type_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';

    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_dist_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress := '001';
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_dist_token := fnd_message.get_string('PO', 'PO_ZMVOR_DISTRIBUTION');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');



    --Gt Table Columns Mapping
    --num1        -    entity_id
    --char1       -    document_type
    --char2       -    document_subtype
    --char3       -    entity_level
    --char4       -    doc_id
    --char5       -    process_entity_flag
    --date1       -    entity_action_date
    --index_num1  -    lowestentityid
    --lowestentityid :
  	--  shipmentid in case of  document type= PO/Releases and
    --  subtype= Planned/Standard at any entity level
  	--  Lineid in case of BPA and GBPA  at any entity level
  	--  Headerid  in case of CPA

    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
   (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      pod.distribution_num,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text(
        'PO_CAN_DIST_DEST_TYPE_NE_I',
        'LINE_SHIP_DIST_NUM',
        l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM||','||l_dist_token||pod.distribution_num,
        'DOC_NUM',
        gt.char6
      ),
      gt.num1,
      gt.char3
    FROM
      po_distributions_all pod,
      po_line_locations poll,
      po_lines pol ,
      po_session_gt gt
    WHERE
      gt.key=p_key
      AND   poll.line_location_id = gt.index_num1 -- i.e lowestentityid .
      AND   poll.po_line_id = pol.po_line_id
      AND   poll.line_location_id=pod.line_location_id
      AND   gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
      AND   Nvl(poll.LCM_FLAG,'N') = 'Y'
      AND   pod.DESTINATION_TYPE_CODE <> 'INVENTORY');


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END lcm_dest_type_chk;



--------------------------------------------------------------------------------
--Start of Comments
--Name:qty_del_grt_ord_chk
--
-- Function:
-- Validates If there are any Uncancelled shipments distributions that have
-- been delivered more than they ordered (Fully Received),the PO/Release
-- Header/Line/Shipment cannot be cancelled
--

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE qty_del_grt_ord_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'qty_del_grt_ord_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';

    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_dist_token NVARCHAR2(15);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_dist_token := fnd_message.get_string('PO', 'PO_ZMVOR_DISTRIBUTION');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');

    l_progress:= '001';



    --Gt Table Columns Mapping
    --num1        -    entity_id
    --char1       -    document_type
    --char2       -    document_subtype
    --char3       -    entity_level
    --char4       -    doc_id
    --char5       -    process_entity_flag
    --date1       -    entity_action_date
    --index_num1  -    lowestentityid
    --lowestentityid :
  	--  shipmentid in case of  document type= PO/Releases and
    --  subtype= Planned/Standard at any entity level
  	--  Lineid in case of BPA and GBPA  at any entity level
  	--  Headerid  in case of CPA

    --Bug15869000 : At the distribution level, quantity delivered can be
    --equal to the quantity ordered for cancel to go through (If it clears
    --all the other checks wrt line and shipment level). So removed the '='
    --condition while doing quantity checks at the distributions level.
    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      pod.DISTRIBUTION_NUM,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_CAN_DIST_DEL_GRT_ORD'
                      ,   'LINE_SHIP_DIST_NUM',  l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM||','||l_dist_token||pod.DISTRIBUTION_NUM
                      ,   'AMT_QTY_TOKEN', DECODE(poll.matching_basis, 'AMOUNT',l_amt_token,l_qty_token)
                      ,   'QTY1', DECODE(poll.matching_basis, 'AMOUNT',Round(Nvl(pod.amount_delivered, 0), 5), Round(Nvl(pod.quantity_delivered, 0), 5))
                      ,   'QTY2', DECODE(poll.matching_basis, 'AMOUNT',Round(Nvl(pod.amount_ordered, 0), 5), Round(Nvl(pod.quantity_ordered, 0), 5))
                      ,   'DOC_NUM', gt.char6
                      ),
      gt.num1,
      gt.char3
    FROM
      po_distributions pod,
      po_line_locations poll,
      po_lines pol,
      po_session_gt gt
    WHERE
      gt.key=p_key
      AND pod.line_location_id = gt.index_num1
      AND pod.line_location_id = poll.line_location_id
      AND pol.po_line_id = poll.po_line_id
      AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
      AND gt.char2 <> po_document_cancel_pvt.c_doc_subtype_PLANNED
      AND ((POLL.matching_basis ='QUANTITY'
            AND nvl(pod.quantity_delivered,0)> 0
            AND round(nvl(pod.quantity_delivered,0),5)  > round(nvl(pod.quantity_ordered,0),5)) --Bug15869000
          OR
          (POLL.matching_basis ='AMOUNT'
            AND nvl(pod.amount_delivered,0)> 0
            AND round(nvl(pod.amount_delivered,0),5)  > round(nvl(pod.amount_ordered,0),5))) ); --Bug15869000


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END qty_del_grt_ord_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:qty_bill_grt_ord_chk
--
-- Function:
-- Validates If there are any Uncancelled shipments distributions that
-- have been billed more than they ordered (Fully Invoiced) ,
-- the PO/Release Header/Line/Shipment cannot be cancelled
--

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE qty_bill_grt_ord_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'qty_bill_grt_ord_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';

    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_dist_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_dist_token := fnd_message.get_string('PO', 'PO_ZMVOR_DISTRIBUTION');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');

    l_progress:= '001';


    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA

    --Bug15869000 : At the distribution level, quantity billed can be
    --equal to the quantity ordered for cancel to go through (If it clears
    --all the other checks wrt line and shipment level). So removed the '='
    --condition while doing quantity checks at the distributions level.
    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      pod.DISTRIBUTION_NUM,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
        ('PO_CAN_DIST_BILL_GRT_ORD'
        ,   'LINE_SHIP_DIST_NUM',  l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM||','||l_dist_token||pod.DISTRIBUTION_NUM
        ,   'AMT_QTY_TOKEN', DECODE(poll.matching_basis, 'AMOUNT',l_amt_token,l_qty_token)
        ,   'QTY1', DECODE(poll.matching_basis, 'AMOUNT',
                    Round(Nvl(DECODE(POD.distribution_type,
                              'PREPAYMENT', POD.amount_financed,
                                POD.amount_billed), 0), 5),
                    Round(Nvl(DECODE(POD.distribution_type,
                              'PREPAYMENT',
                              POD.quantity_financed,
                              POD.quantity_billed), 0), 5))
        ,   'QTY2', DECODE(poll.matching_basis, 'AMOUNT',
                            Round(Nvl(pod.amount_ordered, 0), 5),
                            Round(Nvl(pod.quantity_ordered, 0), 5))
        ,   'DOC_NUM',  gt.char6
        ),
      gt.num1,
      gt.char3
    FROM
      po_distributions pod,
      po_line_locations poll,
      po_lines pol,
      po_session_gt gt
    WHERE
      gt.key=p_key
      AND pod.line_location_id = gt.index_num1
      AND pod.line_location_id = poll.line_location_id
      AND pol.po_line_id = poll.po_line_id
      AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
      AND gt.char2 <> po_document_cancel_pvt.c_doc_subtype_PLANNED
      AND ((POLL.matching_basis ='QUANTITY'
            AND nvl(DECODE(POD.distribution_type,
                      'PREPAYMENT',
                      POD.quantity_financed,
                      POD.quantity_billed
                      ),
                  0) >0
            AND Round(nvl(DECODE(POD.distribution_type,
                          'PREPAYMENT',
                            POD.quantity_financed,
                            POD.quantity_billed
                          ),
                      0),
                5) > round(nvl(pod.quantity_ordered,0),5)) --Bug15869000
            OR
          (POLL.matching_basis ='AMOUNT'
            AND nvl(DECODE(POD.distribution_type,
                      'PREPAYMENT',
                      POD.amount_financed,
                      POD.amount_billed
                      ),
                  0) >0
            AND Round(nvl(DECODE(POD.distribution_type,
                            'PREPAYMENT',
                            POD.amount_financed,
                            POD.amount_billed
                          ),
                      0),
                5) > round(nvl(pod.amount_ordered,0),5)))); --Bug15869000

    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END qty_bill_grt_ord_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:qty_bill_grt_rec_chk
--
-- Function:
--  Validates If there are any Uncancelled shipments that have been billed
--  more than they are received ,then cancel action is not allowed on the entity
--

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE qty_bill_grt_rec_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'qty_bill_grt_rec_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';
    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;
    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');
    l_progress:= '001';



    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA


    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
        0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
        ('PO_CAN_SHIP_BILL_GRT_REC'
        ,   'LINE_SHIP_DIST_NUM',  l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM
        ,   'AMT_QTY_TOKEN', DECODE(poll.matching_basis, 'AMOUNT',l_amt_token,l_qty_token)
        ,   'QTY1', DECODE(poll.matching_basis, 'AMOUNT',
                           Round(Nvl(DECODE(POLL.shipment_type, 'PREPAYMENT',
                                     poll.amount_financed, poll.amount_billed), 0), 5),
                           Round(Nvl(DECODE(POLL.shipment_type, 'PREPAYMENT',
                                     poll.quantity_financed, poll.quantity_billed), 0), 5))
        ,   'QTY2', DECODE(poll.matching_basis, 'AMOUNT',
                           Round(Nvl(poll.amount_received, 0), 5),
                           Round(Nvl(poll.quantity_received, 0), 5))
        ,   'DOC_NUM',  gt.char6
          ),
      gt.num1,
      gt.char3
    FROM
      po_line_locations poll,
      po_lines pol,
      po_session_gt gt
    WHERE gt.key=p_key
          AND poll.line_location_id = gt.index_num1
          AND pol.po_line_id = poll.po_line_id
          AND nvl(POLL.receipt_required_flag, 'Y')<> 'N'
          AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
          AND gt.char2 <> po_document_cancel_pvt.c_doc_subtype_PLANNED
          AND ((POLL.matching_basis ='QUANTITY'
                AND nvl(DECODE(poll.shipment_type,
                          'PREPAYMENT',
                          poll.quantity_financed,
                          poll.quantity_billed),
                      0)>0
                AND Round(nvl(DECODE(poll.shipment_type,
                                'PREPAYMENT',
                                  poll.quantity_financed,
                                  poll.quantity_billed),
                            0),
                      5) >  round(nvl(poll.quantity_received,0),5)) --bug#15971932
                OR
                (POLL.matching_basis ='AMOUNT'
                AND nvl(DECODE(poll.shipment_type,
                          'PREPAYMENT',
                          poll.amount_financed,
                          poll.amount_billed),
                      0)>0
                AND Round(nvl(DECODE(poll.shipment_type,
                                'PREPAYMENT',
                                poll.amount_financed,
                                poll.amount_billed),
                            0),
                      5) > round(nvl(poll.amount_received,0),5)))); --bug#15971932



    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                      || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END qty_bill_grt_rec_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:qty_bill_grt_del_chk
--
-- Function:
--  Validates If there are any Uncancelled shipments distributions that have
--  been billed more than they are delivered ,then cancel action is not allowed
--  on the entity

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE qty_bill_grt_del_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'qty_bill_grt_del_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';

    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_dist_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);
  BEGIN

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_dist_token := fnd_message.get_string('PO', 'PO_ZMVOR_DISTRIBUTION');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');

    l_progress:= '001';


    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA


    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      pod.DISTRIBUTION_NUM,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
        ('PO_CAN_DIST_BILL_GRT_DEL'
          ,'LINE_SHIP_DIST_NUM',l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM||','||l_dist_token||pod.DISTRIBUTION_NUM
          ,'AMT_QTY_TOKEN',DECODE(poll.matching_basis, 'AMOUNT',l_amt_token,l_qty_token)
          ,'QTY1',DECODE(poll.matching_basis, 'AMOUNT',
                         Round(Nvl(DECODE(POD.distribution_type, 'PREPAYMENT', POD.amount_financed, POD.amount_billed), 0), 5),
                         Round(Nvl(DECODE(POD.distribution_type, 'PREPAYMENT', POD.quantity_financed, POD.quantity_billed), 0), 5))
          , 'QTY2',DECODE(poll.matching_basis, 'AMOUNT',Round(Nvl(pod.amount_delivered, 0), 5), Round(Nvl(pod.quantity_delivered, 0), 5))
          , 'DOC_NUM',  gt.char6
        ),
      gt.num1,
      gt.char3
    FROM
      po_distributions pod,
      po_line_locations poll,
      po_lines pol,
      po_session_gt gt
    WHERE
      gt.key=p_key
      AND pod.line_location_id = gt.index_num1
      AND pod.line_location_id = poll.line_location_id
      AND pol.po_line_id = poll.po_line_id
      AND nvl(POLL.receipt_required_flag, 'Y')<> 'N'
      AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
      AND gt.char2 <> po_document_cancel_pvt.c_doc_subtype_PLANNED
      AND ((POLL.matching_basis ='QUANTITY'
            AND nvl(DECODE(pod.distribution_type,
                            'PREPAYMENT',
                              pod.quantity_financed,
                              pod.quantity_billed)
                  ,0) >0
            AND Round(nvl(DECODE(pod.distribution_type,
                          'PREPAYMENT',
                            pod.quantity_financed,
                            pod.quantity_billed)
                    ,0)
              ,5)> round(nvl(pod.quantity_delivered,0),5))
          OR
          (POLL.matching_basis ='AMOUNT'
            AND nvl(DECODE(pod.distribution_type,
                            'PREPAYMENT',
                              pod.quantity_financed,
                              pod.quantity_billed)
                  ,0) >0
            AND Round(nvl(DECODE(pod.distribution_type,
                          'PREPAYMENT',
                            pod.amount_financed,
                            pod.amount_billed)
                      ,0)
                , 5) > round(nvl(pod.amount_delivered,0),5))) );



    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END qty_bill_grt_del_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:qty_rec_not_del_chk
--
-- Function:
--   Validates If there is anything that is received but not delivered the
--   PO cannot be cancelled

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE qty_rec_not_del_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'qty_rec_not_del_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';

    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_dist_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_line_token := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_dist_token := fnd_message.get_string('PO', 'PO_ZMVOR_DISTRIBUTION');
    l_amt_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token  := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');

    l_progress:= '001';


    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA


    INSERT INTO po_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      null,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text(
        'PO_CAN_SHIP_REC_NOT_DEL'
          ,   'LINE_SHIP_DIST_NUM',  l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM
          ,   'AMT_QTY_TOKEN', DECODE(poll.matching_basis, 'AMOUNT',l_amt_token,l_qty_token)
          ,   'QTY1', DECODE(poll.matching_basis, 'AMOUNT',
                             Nvl(poll.amount_received, 0),
                             Nvl(poll.quantity_received, 0))
          ,   'QTY2', (SELECT Sum(Decode(poll.matching_basis, 'AMOUNT',
                                          Nvl(pod.amount_delivered, 0),
                                          Nvl(pod.quantity_delivered, 0)))
                        FROM po_distributions_all pod
                        WHERE pod.line_location_id=poll.line_location_id)
          ,   'DOC_NUM',   gt.char6
      ),
      gt.num1,
      gt.char3
    FROM
      po_line_locations poll,
      po_lines pol,
      po_session_gt gt

    WHERE gt.KEY =p_key
          AND poll.line_location_id =gt.index_num1
          AND pol.po_line_id = poll.po_line_id
          AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
          AND gt.char2 <> po_document_cancel_pvt.c_doc_subtype_PLANNED
          AND ((poll.matching_basis = 'AMOUNT'
                AND nvl(poll.amount_received, 0) <>(SELECT Sum(Nvl(amount_delivered, 0))
                                                    FROM   po_distributions_all
                                                    WHERE  line_location_id=poll.line_location_id))
                OR (poll.matching_basis <>'AMOUNT'
                    AND Nvl(poll.quantity_received, 0) <> (SELECT Sum(Nvl(quantity_delivered, 0))
                                                          FROM   po_distributions_all
                                                          WHERE  line_location_id=poll.line_location_id))));


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END qty_rec_not_del_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:pending_rcv_trx_chk
--
-- Function:
--   Validates If there are any receiving transctions in the receiving interface
--   that have not been processes  for the current entity ,
--   then the entity ccannot be canceleld


--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE pending_rcv_trx_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'pending_rcv_trx_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';

  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress:= '001';

    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA


    INSERT INTO po_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_CAN_SHIP_WITH_RCV_TRX'
                      ,   'LINE_NUM',  pol.LINE_NUM
                      ,   'SHIP_NUM',  poll.SHIPMENT_NUM
                      ,   'DOC_NUM',   gt.char6
                      ),
      gt.num1,
      gt.char3
    FROM
      po_line_locations poll,
      po_lines pol,
      po_session_gt gt
    WHERE
      gt.key=p_key
      AND poll.line_location_id =gt.index_num1
      AND pol.po_line_id = poll.po_line_id
      AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
      AND gt.char2 <> po_document_cancel_pvt.c_doc_subtype_PLANNED
	  --<bug17438571 start>
      --AND EXISTS
            --(SELECT 'Pending Transaction'
            --FROM RCV_TRANSACTIONS_INTERFACE RTI
            --WHERE RTI.processing_status_code = 'PENDING'
            --AND   RTI.po_line_location_id =poll.line_location_id)
	  AND RCV_VALIDATE_PO.prevent_doc_action
                   (decode(gt.char3,'HEADER','Header','LINE','Line','LINE_LOCATION','Shipment'),
                    'cancel', null, pol.org_id, pol.po_header_id, null, null, null,
                    pol.po_line_id, null, poll.line_location_id, pol.item_id, null, null, null, null) = 'TRUE'
	);
	  --<bug17438571 end>


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                   d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                      || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END pending_rcv_trx_chk;


--------------------------------------------------------------------------------
--Start of Comments
--Name:pending_asn_chk
--
-- Function:
--   Validates If there are any ASN that have not been fully received for the
--    shipments,then cancel action is not allowed on the entity

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE pending_asn_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'pending_asn_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress:= '001';

    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA


    INSERT INTO po_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_CAN_SHIP_WITH_ASN'
                      ,   'LINE_NUM',  pol.LINE_NUM
                      ,   'SHIP_NUM',  poll.SHIPMENT_NUM
                      ,   'DOC_NUM',   gt.char6
                      ),
      gt.num1,
      gt.char3
    FROM
      po_line_locations poll,
      po_lines pol,
      po_session_gt gt
    WHERE gt.key=p_key
          AND poll.line_location_id =gt.index_num1
          AND pol.po_line_id = poll.po_line_id
          AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
          AND gt.char2 <> po_document_cancel_pvt.c_doc_subtype_PLANNED
          AND POLL.payment_type IS NULL
          AND EXISTS
          (SELECT 'ASN outstanding'
           FROM RCV_SHIPMENT_LINES RSL
           WHERE RSL.po_line_location_id = poll.line_location_id
                AND  NVL(RSL.quantity_shipped,0) > NVL(RSL.quantity_received,0)
                AND NVL(RSL.ASN_LINE_FLAG,'N') = 'Y'
                AND NVL(RSL.SHIPMENT_LINE_STATUS_CODE,'EXPECTED') <> 'CANCELLED'));


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        IF (G_DEBUG_UNEXP) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                      || l_progress || ' SQL CODE IS '||sqlcode);
        END IF;

        x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END pending_asn_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:invalid_budget_acct_chk
--
-- Function:
--   Validates Validates If encumbrance is on and the budget account is invalid,
--   then cancel action is not allowed on the entity

--Parameters:
--IN:
-- p_online_report_id
-- p_action_date
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE invalid_budget_acct_chk(
            p_online_report_id  IN NUMBER,
            p_action_date       IN DATE,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'invalid_budget_acct_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';



  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress:= '001';

    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA

	--Bug 15913701. p_action_date is already a date variable.
	--Wrapping this inside to_date is giving unexpected results and query is
	--unnecessarily inserting values. Removed the to_date wrap around p_action_date.

    INSERT INTO po_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      pod.distribution_num,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_CAN_DIST_INV_BUDGET_ACCT'
                      ,   'LINE_NUM',  pol.LINE_NUM
                      ,   'SHIP_NUM',  poll.SHIPMENT_NUM
                      ,   'DIST_NUM',  pod.distribution_num
                      ,   'DOC_NUM',    gt.char6
                      ),
        gt.num1,
        gt.char3
    FROM
      po_distributions pod,
      po_line_locations poll,
      po_lines pol,
      po_session_gt gt,
      FINANCIALS_SYSTEM_PARAMETERS FSP,
      gl_code_combinations gcc
    WHERE gt.key=p_key
          AND  pod.line_location_id=gt.index_num1
          AND  POD.line_location_id = POLL.line_location_id
          AND  POL.po_line_id = POLL.po_line_id
          AND  POLL.shipment_type in ('STANDARD', 'PLANNED','PREPAYMENT')
          AND  GCC.code_combination_id = POD.BUDGET_ACCOUNT_ID
          AND  gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
          AND  fsp.purch_encumbrance_flag = 'Y'
          AND  (GCC.enabled_flag <> 'Y' OR
                nvl(p_action_date,trunc(sysdate)) not between
                nvl(GCC.start_date_active, nvl(p_action_date,trunc(sysdate)-1))
                AND NVL(GCC.end_date_active, nvl(p_action_date,trunc(sysdate)+1))));


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        IF (G_DEBUG_UNEXP) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                      || l_progress || ' SQL CODE IS '||sqlcode);
        END IF;

        x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END invalid_budget_acct_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:invalid_charge_acct_chk
--
-- Function:
--   Validates Validates If the charge account is invalid,
--   then cancel action is not allowed on the entity

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE invalid_charge_acct_chk(
            p_online_report_id  IN NUMBER,
            p_action_date       IN DATE,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'invalid_charge_acct_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress:= '001';

    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA

	--Bug 15913701. p_action_date is already a date variable.
	--Wrapping this inside to_date is giving unexpected results and query is
	--unnecessarily inserting values. Removed the to_date wrap around p_action_date.

    INSERT INTO po_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      poll.SHIPMENT_NUM,
      pod.distribution_num,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_CAN_DIST_INV_CHARGE_ACCT'
                      ,   'LINE_NUM',  pol.LINE_NUM
                      ,   'SHIP_NUM',  poll.SHIPMENT_NUM
                      ,   'DIST_NUM',  pod.distribution_num
                      ,   'DOC_NUM',   gt.char6

                        ),
      gt.num1,
      gt.char3
    FROM
      po_distributions pod,
      po_line_locations poll,
      po_lines pol,
      gl_code_combinations gcc,
      po_session_gt gt
    WHERE gt.key=p_key
          AND  pod.line_location_id=gt.index_num1
          AND  POD.line_location_id = POLL.line_location_id
          AND  POL.po_line_id = POLL.po_line_id
          AND  GCC.code_combination_id = POD.code_combination_id
          AND  gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
          AND  (Nvl(GCC.enabled_flag,'N') <> 'Y' OR
                nvl(p_action_date,trunc(sysdate)) not between
                nvl(GCC.start_date_active, nvl(p_action_date,trunc(sysdate)-1))
                AND NVL(GCC.end_date_active, nvl(p_action_date,trunc(sysdate)+1))));



    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END invalid_charge_acct_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:ga_with_open_std_ref_chk
--
-- Function:
--   Validates If GBPA has Uncancelled Open Standard PO reference,
--   then the GBPA cannot be cancelled

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE ga_with_open_std_ref_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'ga_with_open_std_ref_chk';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';


  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress:= '001';

    -- Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA


    INSERT INTO po_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_CAN_GA_WITH_OPEN_STD_REF'
                      ,   'LINE_NUM',  pol.LINE_NUM
                      ,   'DOC_NUM', gt.char6),

      gt.num1,
      gt.char3
    FROM
      po_lines pol,
      po_headers poh,
      po_session_gt gt
    WHERE gt.key=p_key
          AND poh.po_header_id=pol.po_header_id
          AND pol.po_line_id =gt.index_num1
          AND gt.char1 = po_document_cancel_pvt.c_doc_type_PA
          AND poh.global_agreement_flag = 'Y'
          AND EXISTS
             (SELECT 'Uncancelled std PO lines ref this ga line Exist'
              FROM   po_lines POL1
              WHERE  POL1.from_line_id = POL.po_line_id
                     AND nvl(POL1.cancel_flag,'N') = 'N'
                     AND nvl(POL1.closed_code, 'OPEN') <> 'FINALLY CLOSED'));


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END ga_with_open_std_ref_chk;

--------------------------------------------------------------------------------
--Start of Comments
--Name:po_pa_WITH_OPEN_REL_chk
--
-- Function:
--   Validates If Blanket PA/Planned PO has Uncancelled Open Releases,
--   then the BPA/PPO cannot be cancelled

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE po_pa_WITH_OPEN_REL_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'po_pa_WITH_OPEN_REL_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';
    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_ship_token NVARCHAR2(20);  -- bug 16525950


  BEGIN
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;

    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress:= '001';
    -- bug 16525950
    l_ship_token   := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');

    -- Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    -- lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA


    -- Bug 16174863: Add condition in the select statement for
    -- po_pa_WITH_OPEN_REL_chk() to restrict the document type as BPA or planned PO.

    INSERT INTO po_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      POL.LINE_NUM,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_CAN_PA_WITH_OPEN_REL'
                      ,   'LINE_NUM',  pol.LINE_NUM
                      ,   'DOC_NUM',gt.char6),

      gt.num1,
      gt.char3
    FROM  po_lines pol,
          po_session_gt gt
    WHERE  gt.key=p_key
           AND pol.po_line_id =gt.index_num1
           -- bug 16174863
           AND  gt.char1 = po_document_cancel_pvt.c_doc_type_PA
           AND EXISTS
               (SELECT 'Uncancelled Releases Exist'
                FROM   PO_LINE_LOCATIONS PLL
                WHERE  PLL.po_line_id = POL.po_line_id
                       AND PLL.shipment_type in ('BLANKET')
                       AND nvl(PLL.cancel_flag,'N') = 'N'
                       AND nvl(PLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
               UNION
                SELECT 'Uncancelled Releases Exist'
                FROM   po_releases por
                WHERE  POR.po_header_id = pol.po_header_id
                       -- bug 16590732: Do this check if it is Header level cancel
                       AND  gt.char3 = po_document_cancel_pvt.c_entity_level_header
                       AND  nvl(POR.cancel_flag,'N') = 'N'
                       AND nvl(POR.closed_code,'OPEN') <> 'FINALLY CLOSED')
               );

    -- bug 16525950: seperately validate for Planned PO
    --  as index_num1 is Shipment id in this case
    INSERT INTO po_online_report_text(
          ONLINE_REPORT_ID,
          LAST_UPDATE_LOGIN,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          CREATED_BY,
          CREATION_DATE,
          LINE_NUM,
          SHIPMENT_NUM,
          DISTRIBUTION_NUM,
          SEQUENCE,
          TEXT_LINE,
          transaction_id,
          transaction_type)
        (SELECT
          p_online_report_id,
          p_login_id,
          p_user_id,
          SYSDATE,
          p_user_id,
          SYSDATE,
          POL.LINE_NUM,
          POLL.SHIPMENT_NUM,
          0,
          p_sequence + ROWNUM,
      -- bug 16525950 : Constructing the token value to display shipment number also
          PO_CORE_S.get_translated_text
                          ('PO_CAN_PA_WITH_OPEN_REL'
                      ,   'LINE_NUM',  pol.LINE_NUM || l_ship_token || poll.SHIPMENT_NUM
                          ,   'DOC_NUM',gt.char6),

          gt.num1,
          gt.char3
    FROM
      po_lines pol,
      po_line_locations poll,
      po_session_gt gt
        WHERE  gt.key=p_key
      AND poll.LINE_LOCATION_ID =gt.index_num1
      AND pol.po_line_id =poll.po_line_id
               AND gt.char2 = po_document_cancel_pvt.c_doc_subtype_PLANNED
      AND EXISTS(
            SELECT 'Uncancelled Releases Exist'
                    FROM   PO_LINE_LOCATIONS PLL
            WHERE
              PLL.SOURCE_SHIPMENT_ID = POLL.LINE_LOCATION_ID
              AND PLL.shipment_type in ('SCHEDULED')
                           AND nvl(PLL.cancel_flag,'N') = 'N'
                           AND nvl(PLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
                   UNION
                    SELECT 'Uncancelled Releases Exist'
                    FROM   po_releases por
                    WHERE  POR.po_header_id = pol.po_header_id
                   -- bug 16590732: Do this check if it is Header level cancel
                   AND  gt.char3 = po_document_cancel_pvt.c_entity_level_header
                           AND  nvl(POR.cancel_flag,'N') = 'N'
                           AND nvl(POR.closed_code,'OPEN') <> 'FINALLY CLOSED')
                   );

    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END po_pa_WITH_OPEN_REL_chk;


--------------------------------------------------------------------------------
--Start of Comments
--Name:cga_with_open_std_ref_chk
--
-- Function:
--   Validates If CPA has Uncancelled Open Standard PO reference,
--   then the CPA cannot be cancelled

--Parameters:
--IN:
-- p_online_report_id
-- p_key
-- p_login_id
-- p_user_id
-- p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE cga_with_open_std_ref_chk(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'cga_with_open_std_ref_chk.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;



    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data:=NULL;

    l_progress:= '001';

    --Gt Table Columns Mapping
    -- num1        -    entity_id
    -- char1       -    document_type
    -- char2       -    document_subtype
    -- char3       -    entity_level
    -- char4       -    doc_id
    -- char5       -    process_entity_flag
    -- date1       -    entity_action_date
    -- index_num1  -    lowestentityid
    --lowestentityid :
    --	  shipmentid in case of  document type= PO/Releases and
    --    subtype= Planned/Standard at any entity level
    --	  Lineid in case of BPA and GBPA  at any entity level
    --	  Headerid  in case of CPA


    INSERT INTO po_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      gt.num1,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_CAN_CGA_WITH_OPEN_STD_REF'
                      ,   'DOC_NUM',gt.char6),

      gt.num1,
      gt.char3
    FROM
      po_session_gt gt
    WHERE gt.key=p_key
          AND gt.char1 = po_document_cancel_pvt.c_doc_type_PA
          AND EXISTS
                (SELECT 'Has open std Po lines ref this contract'
                 FROM   po_lines POL
                 WHERE  POL.contract_id = gt.index_num1
                        AND NVL(POL.cancel_flag, 'N') = 'N'
                        AND NVL(POL.closed_code, 'OPEN') <> 'FINALLY CLOSED') );

    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END cga_with_open_std_ref_chk;



--------------------------------------------------------------------------------
--Start of Comments
--Name: cancel_custom_validation
--
-- Function:
--   This routine is a Handle to support custom validations
--Parameters:
--IN:
--  p_online_report_id
--  p_key
--  p_login_id
--  p_user_id
--  p_sequence

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE cancel_custom_validation(
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE ,
            p_sequence	        IN OUT NOCOPY NUMBER,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'cancel_custom_validation.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;

    l_progress VARCHAR2(3) := '000';


  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_sequence',p_sequence);
    END IF;



    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN FND_API.G_EXC_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END cancel_custom_validation;



--------------------------------------------------------------------------------
--Start of Comments
--Name:
--
--Modifies: p_key to a new key in po_session_gt [see the explanation below]
-- Function:
--   Cancel action be performed at any of the three levels[Header/Line/Shipment]
--   for a docuemnt
--   But All Business Rules Valdiations are with the :
--   * shipments in case of  document type= PO/Releases and subtype= Planned/Standard
--   * Lines in case of BPA and GBPA
--   * Header in case of CPA
--   Ex: On cancelling a PO Header, all its shipments are validated against
--       the business rules,similarly, if we cancel a PO line, all its shipments
--       are validated, For BPA header, its lines are used for validation, so on.
--   So in order to avoid multiple if else conditions like,If entity level=Header,
--   then join with po_header_id, else for entity_level=LINE
--   then join with po_line_id, and so on,fetching all the lowest entities for
--   the entity being cancelled based on the entity_level and updating in po_session_gt.
--
--   The entire entity record was already inserted in po_session_gt with l_old_key,
--   but as the lowest entity for a document can be multiple,
--   ex: there can be more than one shipment for a PO, so not updating the
--   existing records in po_session_gt,
--   rather inserting new records[with key=l_new_key],which will be used further
--   for validations.
--   Following is the entity record and columns in po_session_gt mapping:
--            entity_id           -  num1
--            document_type       -  char1
--            document_subtype    -  char2
--            entity_level        -  char3
--            doc_id              -  char4
--            process_entity_flag -  char5
--            entity_action_date  -  date1
--            lowestentityid      -  index_num1

--Parameters:
--IN:
-- p_entity_rec_tbl
-- p_key
--

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE update_gt_with_low_entity(
            p_entity_rec_tbl IN  po_document_action_pvt.entity_dtl_rec_type_tbl,
            p_key            IN OUT NOCOPY po_session_gt.key%TYPE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_data       OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_gt_with_low_entity.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3):= '000';

    l_old_key  po_session_gt.key%TYPE;
    l_new_key  po_session_gt.key%TYPE;

  BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    x_msg_data :=NULL;
    l_progress:= '001';



    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
    END IF;


    l_new_key := PO_CORE_S.get_session_gt_nextval;
    l_old_key := p_key;
    l_progress :='002';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'l_old_key',l_old_key);
      PO_DEBUG.debug_var(d_module,l_progress,'l_new_key',l_new_key);
    END IF;



    -- Lowest entity for SPO/PPO and Releases that will be used for validations
    -- is Shipments .Get all the shipments for the SPO/PPO and Releases for
    -- entity level =shipment/line/header
    INSERT INTO PO_session_gt gt(
      key,
      index_num1,
      num1,
      char1,
      char2,
      char3,
      char4,
      char5,
      char6,
      date1)
    (SELECT
      l_new_key,
      line_location_id,
      num1,
      char1,
      char2,
      char3,
      char4,
      'Y',
      Decode (
          pgt.char1,
          po_document_cancel_pvt.c_doc_type_RELEASE,
          (SELECT poh.segment1||'-'|| por.release_num
          FROM    po_releases por,
                  po_headers poh
          WHERE   por.po_release_id=poll.po_release_id
                  AND por.po_header_id=poh.po_header_id),
          (SELECT segment1
          FROM    po_headers
          WHERE   po_header_id=poll.po_header_id)
      ),
      date1
    FROM po_line_locations poll,
         po_session_gt pgt
    WHERE pgt.key = l_old_key
          AND nvl(poll.cancel_flag,'N') = 'N'
          AND nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          AND ( ( pgt.char3 = po_document_cancel_pvt.c_entity_level_shipment
                  AND pgt.num1 = line_location_id )
              OR( pgt.char3 = po_document_cancel_pvt.c_entity_level_line
                  AND pgt.char1 <> po_document_cancel_pvt.c_doc_type_PA
                  -- bug 16525950 : consider only the PO shipment and not release
			      -- In case of PPO, the release shipment will also be considered
			      -- if we do not add this condition, and as this is for level =Line
				  -- it is not applicable for releases
                  AND poll.po_release_id IS NULL
                  AND pgt.num1 = po_line_id )
              OR(pgt.char1 = po_document_cancel_pvt.c_doc_type_PO
                  AND pgt.char3 = po_document_cancel_pvt.c_entity_level_header
                  -- bug 16525950
                  AND poll.po_release_id IS NULL
                  AND pgt.num1 = po_header_id )
              OR (pgt.char1 = po_document_cancel_pvt.c_doc_type_RELEASE
                  AND pgt.char3 = po_document_cancel_pvt.c_entity_level_header
                  AND pgt.num1 = po_release_id ) ));



    -- Lowest entity for BPA /GBPA that will be used for validations is Lines
    -- Get all the Lines  for the BPA /GBPA for entity level =line/header

    INSERT INTO po_session_gt gt(
      key,
      num1,
      index_num1,
      char1,
      char2,
      char3,
      char4,
      char5,
      char6,
      date1)
    (SELECT
      l_new_key,
      num1,
      po_line_id,
      char1,
      char2,
      char3,
      char4,
      'Y',
      (SELECT segment1
        FROM    po_headers
        WHERE   po_header_id=pol.po_header_id
      ),
      date1
    FROM
      po_lines pol,
      po_session_gt pgt
    WHERE pgt.key = l_old_key
          AND  nvl(pol.cancel_flag,'N') = 'N'
          AND  nvl(pol.closed_code, 'OPEN') <> 'FINALLY CLOSED'
          AND  (( pgt.char3 = po_document_cancel_pvt.c_entity_level_line
                  AND pgt.char1 = po_document_cancel_pvt.c_doc_type_PA
                  AND pgt.num1 = po_line_id )
                OR(pgt.char1 = po_document_cancel_pvt.c_doc_type_PA
                  AND pgt.char3 = po_document_cancel_pvt.c_entity_level_header
                  AND pgt.num1 = pol.po_header_id ) ));



    -- Lowest entity for CPA that will be used for validations is CPA Header
    -- Get all the Header id  for the CPA for entity level =header

    INSERT INTO po_session_gt gt(
      key,
      num1,
      index_num1,
      char1,
      char2,
      char3,
      char4,
      char5,
      char6,
      date1)
   (SELECT
      l_new_key,
      num1,
      num1,
      char1,
      char2,
      char3,
      char4,
      'Y',
      (SELECT segment1
          FROM    po_headers
          WHERE   po_header_id=num1
      ),
      date1
    FROM  po_session_gt pgt
    WHERE pgt.key = l_old_key
          AND pgt.char1 = po_document_cancel_pvt.c_doc_type_PA
          AND pgt.char2 = po_document_cancel_pvt.c_doc_subtype_contract);


    -- Return the new key
    p_key :=l_new_key;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF;


  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

  END update_gt_with_low_entity;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_set
--
-- Function:
--   This routine executes the business rule validations for cancel action
--Parameters:
--IN:
--  p_validation_set
--  p_online_report_id
--  p_action_date
--  p_login_id
--  p_user_id
--  p_sequence
--  p_key

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_set(
            p_validation_set    IN PO_TBL_VARCHAR2000,
            p_online_report_id  IN NUMBER,
            p_action_date       IN DATE,
            p_login_id          IN po_lines.last_update_login%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_sequence          IN OUT NOCOPY po_online_report_text.sequence%TYPE,
            p_key               IN po_session_gt.key%TYPE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_msg_data          OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'validate_set.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
    l_progress VARCHAR2(3):= '000';
    l_val VARCHAR2(2000);

  BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    x_msg_data :=NULL;
    l_progress:= '001';


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_action_date',p_action_date);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;


    l_progress := '002';
    FOR i IN 1 .. p_validation_set.COUNT
    LOOP
      l_val := p_validation_set(i);

      BEGIN
        CASE l_val

          -- If there are any Uncancelled shipments that have quantity/amount
          -- not matching to sum of its ditributions, then the PO/Release
          -- Header/Line/Shipment cannot be cancelled
          WHEN c_can_ship_dist_diff_qty THEN
            ship_dist_qty_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any Uncancelled lines that have quanity/amount
          -- not matching to sum of its shipments, then the PO/Release
          -- Header/Line cannot be cancelled
          WHEN c_can_line_ship_diff_qty THEN
            line_ship_qty_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any Uncancelled sipments that have unit price
          -- not matching to price of its line, then the PO/Release
          -- Header/Line/Shipment cannot be cancelled
          WHEN c_can_line_ship_diff_price THEN
            line_ship_price_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any Uncancelled Line that have unit price exceeding
          -- the price limit
          WHEN c_can_line_price_grt_limit THEN
            line_price_chk(
            p_online_report_id  =>p_online_report_id,
            p_key => p_key,
            p_user_id  =>p_user_id,
            p_login_id  =>p_login_id,
            p_sequence	=>p_sequence,
            x_return_status =>x_return_status,
            x_msg_data =>x_msg_data);

          -- if the document is LCM enabled then its shipment
          -- must have the invoice match option as 'Receipt'
          -- If the validation fails, teh documnet cannot be cancelled
          WHEN c_can_lcm_match_option_chk THEN
            lcm_match_option_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- if the document is LCM enabled then its Ditsribution
          -- must have the destination type as 'Inventory'
          -- If the validation fails, teh documnet cannot be cancelled
          WHEN c_can_lcm_dest_type_chk THEN
            lcm_dest_type_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any Uncancelled shipments that have been received
          -- more than they ordered (Fully Received) , the PO/Release
          -- Header/Line/Shipment cannot be cancelled
          WHEN c_can_qty_rec_grt_ord  THEN
            qty_rec_grt_ord_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any Uncancelled shipments distributions that have
          -- been billed more than they ordered (Fully Invoiced) ,
          -- the PO/Release Header/Line/Shipment cannot be cancelled
          WHEN c_can_qty_bill_grt_ord  THEN
            qty_bill_grt_ord_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any Uncancelled shipments distributions that have
          -- been delivered more than they ordered (Fully Received),
          --the PO/Release Header/Line/Shipment cannot be cancelled
          WHEN c_can_qty_del_grt_ord THEN
            qty_del_grt_ord_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any Uncancelled shipments that have been billed more
          -- than they are received ,then cancel action is not allowed on
          -- the entity
          WHEN c_can_qty_bill_grt_rec THEN
            qty_bill_grt_rec_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any Uncancelled shipments distributions that have been
          -- billed more than they are delivered ,then cancel action is not
          -- allowed on the entity
          WHEN c_can_qty_bill_grt_del THEN
            qty_bill_grt_del_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there is anything that is received but not delivered the PO
          -- cannot be cancelled
          WHEN c_can_qty_rec_not_del THEN
            qty_rec_not_del_chk (
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If there are any receiving transctions in the receiving interface
          -- that have not been processes for the current entity , then the
          -- entity ccannot be canceleld
          WHEN c_can_with_pending_rcv_trx THEN
            pending_rcv_trx_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);


          -- If there are any ASN that have not been fully received for the
          -- shipments,then cancel action is not allowed on the entity
          WHEN c_can_with_asn THEN
            pending_asn_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If encumbrance is on, then  If the budget account is invalid,
          -- then cancel action is not allowed on the entity
          WHEN c_can_invalid_budget_acct_flex THEN
            invalid_budget_acct_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_action_date =>p_action_date,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);


          -- If the charge account is invalid, then cancel action is not
          -- allowed on the entity
          WHEN c_can_invalid_charge_acct_flex THEN
            invalid_charge_acct_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_action_date =>p_action_date,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If GBPA has Uncancelled Open Standard PO reference,
          -- then the GBPA cannot be cancelled
          WHEN c_can_ga_with_open_std_ref THEN
            ga_with_open_std_ref_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

          -- If Blanket PA/Planned PO has Uncancelled Open Releases,
          -- then the BPA/PPO cannot be cancelled
          WHEN c_can_po_pa_with_open_rel THEN
            po_pa_WITH_OPEN_REL_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);


          -- If CPA has Uncancelled Open Standard PO reference,
          -- then the CPA cannot be cancelled
          WHEN c_can_cga_with_open_std_ref THEN
            cga_with_open_std_ref_chk(
              p_online_report_id  =>p_online_report_id,
              p_key => p_key,
              p_user_id  =>p_user_id,
              p_login_id  =>p_login_id ,
              p_sequence	=>p_sequence,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

        -- If there are any custom validations, until they pass,
        -- the document can not be cancelled
        WHEN c_can_custom_validation THEN
          cancel_custom_validation(
            p_online_report_id  =>p_online_report_id,
            p_key => p_key,
            p_user_id  =>p_user_id,
            p_login_id  =>p_login_id ,
            p_sequence	=>p_sequence,
            x_return_status =>x_return_status,
            x_msg_data =>x_msg_data);

        ELSE
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(d_module,l_progress,'Invalid identifier in validation set',l_val);
          END IF;
          RAISE CASE_NOT_FOUND;
        END CASE;

      EXCEPTION
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        WHEN FND_API.G_EXC_ERROR THEN
          x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
          x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
          IF (G_DEBUG_UNEXP) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
          END IF;

          x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      END;

    END LOOP;

  IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
  END IF;

  END validate_set;

--------------------------------------------------------------------------------
--Start of Comments
--Name: po_cancel_action_checks
--
-- Function:
--   Performs the following. Business Rule Valdiations to allow cancel action
--         1.  If there are any Uncancelled shipments that have been received
--             more than they ordered (Fully Received),
--             the PO/Release Header/Line/Shipment cannot be cancelled
--         2.  If there are any Uncancelled shipments distributions that have
--             been billed more than they ordered (Fully Invoiced) ,
--             the PO/Release Header/Line/Shipment cannot be cancelled
--         3.  If there are any Uncancelled shipments distributions that have
--             been delivered more than they ordered (Fully Received),
--             the PO/Release Header/Line/Shipment cannot be cancelled
--         4.  If there are any receiving transctions in the receiving interface
--             that have not been processes for the current entity , then
--             the entity ccannot be canceleld
--         5.  If there is anything that is received but not delivered the PO
--             cannot be cancelled
--         6.  If encumbrance is on, then if the budget account is invalid, then
--             cancel action is not allowed on the entity
--         7.  If the charge account is invalid, thenn cancel action is not
--             allowed on the entity
--         8.  If there are any Uncancelled shipments that have been billed more
--             than they are received ,then cancel action is not allowed on
--             the entity
--         9.  If there are any Uncancelled shipments distributions that have
--             been billed more than they are delivered ,then cancel action is
--             not allowed on the entity
--        10.  If there are any ASN that have not been fully received for the
--             shipments,then cancel action is not allowed on the entity
--        11.  If Blanket PA/Planned PO has Uncancelled Open Releases, then the
--             BPA/PPO cannot be cancelled
--        12.  If GBPA has Uncancelled Open Standard PO reference, then the GBPA
--             cannot be cancelled
--        12.  If CPA has Uncancelled Open Standard PO reference, then the CPA
--             cannot be cancelled
--        14. If there are any custom validations, until they pass, the document
--             can not be cancelled
--
--If any of the above validation fails,it inserts the error in po-onlie_report_text

--Parameters:
--IN:
-- p_entity_rec_tbl
-- p_action_date
-- p_key
-- p_user_id
-- p_login_id
-- p_sequence
-- p_online_report_id

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE po_cancel_action_checks(
            p_entity_rec_tbl   IN po_document_action_pvt.entity_dtl_rec_type_tbl,
            p_action_date      IN DATE,
            p_key              IN po_session_gt.key%TYPE,
            p_login_id         IN po_lines.last_update_login%TYPE,
            p_user_id          IN po_lines.last_updated_by%TYPE,
            p_sequence         IN OUT NOCOPY po_online_report_text.sequence%TYPE,
            p_online_report_id IN NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_return_msg       OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'po_cancel_action_checks';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress VARCHAR2(3) := '000';


  BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    x_return_msg :=NULL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_action_date',p_action_date);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;


    l_progress := '001';

    validate_set(
      p_validation_set => cancel_validation_set,
      p_online_report_id => p_online_report_id,
      p_action_date => p_action_date,
      p_key =>p_key,
      p_user_id  =>p_user_id,
      p_login_id  =>p_login_id,
      p_sequence	=>p_sequence,
      x_return_status => x_return_status,
      x_msg_data => x_return_msg);



    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'x_return_status',x_return_status);
      PO_DEBUG.debug_end(d_module);
    END IF;


    EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      WHEN FND_API.G_EXC_ERROR THEN
        x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
        IF (G_DEBUG_UNEXP) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
        END IF;

        x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END po_cancel_action_checks;

--------------------------------------------------------------------------------
--Start of Comments
--Name: val_doc_security
--
-- Function:
-- This is wrapper function on  PO_REQS_CONTROL_SV.val_doc_security.
-- PO_REQS_CONTROL_SV.val_doc_security returns boolean , so cannot be used
-- in sql statmemt
-- So creating a wrapper on it, that will return 'Y'/'N'.

--Parameters:
--IN:
-- p_doc_agent_id
-- p_agent_id
-- p_doc_type
-- p_doc_subtype

-- Returns
--  'Y' >>TRUE
--  'N' >> FALSE

--End of Comments
--------------------------------------------------------------------------------


FUNCTION val_doc_security(
          p_doc_agent_id            IN     NUMBER,
          p_agent_id                IN     NUMBER,
          p_doc_type                IN     VARCHAR2,
          p_doc_subtype             IN     VARCHAR2)
    RETURN VARCHAR2
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'val_doc_security.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress VARCHAR2(3) := '000';


  BEGIN
    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_agent_id',p_agent_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_doc_agent_id',p_doc_agent_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_doc_type',p_doc_type);
      PO_DEBUG.debug_var(d_module,l_progress,'p_doc_subtype',p_doc_subtype);
    END IF;


    IF PO_REQS_CONTROL_SV.val_doc_security(
        x_doc_agent_id => p_doc_agent_id,
        x_agent_id => p_agent_id,
        x_doc_type => p_doc_type,
        x_doc_subtype => p_doc_subtype) THEN

      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: is_complex_work_po
--
-- Function:
-- This is wrapper function on  PO_COMPLEX_WORK_PVT.is_complex_work_
-- PO_COMPLEX_WORK_PVT.is_complex_work_po returns boolean,so cannot be used
-- in sql statmemt
-- So creating a wrapper on it, that will return 'Y'/'N'.

--Parameters:
--IN:
-- p_doc_id

-- Returns
--  'Y' >>TRUE
--  'N' >> FALSE

--End of Comments
--------------------------------------------------------------------------------

FUNCTION is_complex_work_po(
          p_doc_id IN NUMBER)
    RETURN VARCHAR2
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'is_complex_work_po.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress VARCHAR2(3) := '000';

  BEGIN

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_doc_id',p_doc_id);
    END IF;

    IF  PO_COMPLEX_WORK_PVT.is_complex_work_po(
          p_po_header_id => p_doc_id) THEN

      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;

END;

--------------------------------------------------------------------------------
--Start of Comments
--Name: val_doc_state_check
--
-- Function:
--   Checks if p_agent_id has the access and security clearance to modify
--   or act upon the document

--Parameters:
--IN:
-- p_entity_rec_tbl
-- p_online_report_id
-- p_user_id
-- p_login_id
-- p_sequence
-- p_agent_id
-- p_key

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE val_security_check(
            p_entity_rec_tbl    IN po_document_action_pvt.entity_dtl_rec_type_tbl,
            p_online_report_id  IN NUMBER,
            p_key               IN po_session_gt.key%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN  po_lines.last_update_login%TYPE,
            p_sequence          IN OUT NOCOPY po_online_report_text.sequence%TYPE,
            p_agent_id          IN PO_HEADERS.agent_id%TYPE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_return_msg        OUT NOCOPY VARCHAR2)



  IS

    d_api_name CONSTANT VARCHAR2(30) := 'val_security_check.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress VARCHAR2(3) := '000';
    l_flag BOOLEAN := FALSE ;



  BEGIN

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    x_return_msg :=NULL;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_agent_id',p_agent_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_sequence',p_sequence);
    END IF;

    l_progress :='001';

    -- Validate agent security for SPO/PPO/BPA/CPA
    INSERT INTO PO_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
   (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      0,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text('PO_CAN_CONTROL_SECURITY_FAILED',
                              'DOC_NUM', gt.char6),
      gt.num1,
      gt.char3
    FROM  po_headers poh,
          po_session_gt gt
    WHERE gt.key=p_key
          AND poh.po_header_id = gt.char4
          AND gt.char1 <> po_document_cancel_pvt.c_doc_type_RELEASE
          AND (po_control_action_validations.val_doc_security(
                 poh.agent_id,
                 p_agent_id,
                 gt.char1,
                 gt.char2) <>'Y' )) ;



    p_sequence :=p_sequence+SQL%ROWCOUNT;

    l_progress :='002';

    IF g_debug_stmt THEN
       PO_DEBUG.debug_var(d_module,l_progress,'p_sequence',p_sequence);
    END IF;


    -- Validate agent security for Releases

    INSERT INTO PO_online_report_text(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      0,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text('PO_CAN_CONTROL_SECURITY_FAILED',
                              'DOC_NUM',gt.char6),
      gt.num1,
      gt.char3
    FROM
      po_releases prh,
      po_session_gt gt
    WHERE gt.key=p_key
          AND prh.po_release_id = gt.char4
          AND gt.char1 = po_document_cancel_pvt.c_doc_type_RELEASE
          AND(po_control_action_validations.val_doc_security(
                prh.agent_id,
                p_agent_id,
                gt.char1,
                gt.char2) <>'Y' )) ;

    p_sequence :=p_sequence+SQL%ROWCOUNT;

    l_progress :='003';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'p_sequence',p_sequence);
      PO_DEBUG.debug_end(d_module);
    END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END  val_security_check;

--------------------------------------------------------------------------------
--Start of Comments
--Name: val_doc_state_check
--
-- Function:
--   1. Validates the document state,in other words action is valid for the
--      current document state if the caller is CANCEL API
--         - Document should be atleast once approved
--         - Document should be in APPROVED/REJECTED/REQUIRES-REAPPROVAL status
--         - Document should not be Finally Closed/Hold
--   2. Validates if the document has not been changed since its last revision.
--      If any of the above validation fails,it inserts the error in
--      po_onlie_report_text

--Parameters:
--IN:
-- p_entity_rec_tbl
-- p_online_report_id
-- p_user_id
-- p_login_id
-- p_sequence
-- p_source
-- p_key

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE val_doc_state_check(
            p_entity_rec_tbl    IN po_document_action_pvt.entity_dtl_rec_type_tbl,
            p_online_report_id  IN NUMBER,
            p_agent_id          IN PO_HEADERS.agent_id%TYPE,
            p_user_id           IN po_lines.last_updated_by%TYPE,
            p_login_id          IN po_lines.last_update_login%TYPE,
            p_sequence          IN OUT NOCOPY po_online_report_text.sequence%TYPE,
            p_source            IN VARCHAR2 DEFAULT NULL,
            p_key               IN po_session_gt.key%TYPE,
            x_return_status     OUT NOCOPY VARCHAR2,
            x_return_msg        OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'val_doc_state_check.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress VARCHAR2(3) := '000';


    l_allowable_actions_tbl PO_Document_Control_PVT.g_lookup_code_tbl_type;
    l_displayed_field_tbl   PO_Document_Control_PVT.g_displayed_field_tbl_type;
    l_action                PO_LOOKUP_CODES.lookup_code%TYPE;

    l_doc_subtype PO_DOCUMENT_TYPES.document_subtype%TYPE;
    l_doc_type    PO_DOCUMENT_TYPES.document_type_code%TYPE;

    l_doc_line_loc_id NUMBER;
    l_doc_line_id  NUMBER;
    l_doc_id       NUMBER;

    l_current_entity_changed VARCHAR2(1);
    l_action_ok BOOLEAN;

  BEGIN


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_msg :=NULL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_source',p_source);
    END IF;


    l_action :='CANCEL';
    l_progress :='001';

    -- For each entity
    FOR i IN 1..p_entity_rec_tbl.Count LOOP

      l_doc_subtype := p_entity_rec_tbl(i).document_subtype;
      l_doc_type := p_entity_rec_tbl(i).document_type;
      l_doc_id := p_entity_rec_tbl(i).doc_id;

      -- If the calling mode is cancel api, then only validate the applicability
      -- of cancel action on the current entity state, other wise, it will
      -- already be validated
      IF nvl(p_source,'NULL') NOT IN(PO_DOCUMENT_CANCEL_PVT.c_HTML_CONTROL_ACTION,
                                     PO_DOCUMENT_CANCEL_PVT.c_FORM_CONTROL_ACTION)
      THEN

        l_action_ok := FALSE;

        IF p_entity_rec_tbl(i).entity_level=po_document_cancel_pvt.c_entity_level_HEADER  THEN
          l_doc_line_id := NULL;
          l_doc_line_loc_id := NULL;

          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(d_module,l_progress,'l_doc_subtype',l_doc_subtype);
            PO_DEBUG.debug_var(d_module,l_progress,'l_doc_id',l_doc_id);
            PO_DEBUG.debug_var(d_module,l_progress,'l_doc_type',l_doc_type);
          END IF;

          IF l_doc_type =po_document_cancel_pvt.c_doc_type_RELEASE THEN
            l_progress :='002';
            l_action := 'CANCEL REL';

            PO_Document_Control_PVT.get_rel_header_actions(
              p_doc_subtype         => l_doc_subtype,
              p_doc_id              => l_doc_id,
              p_agent_id            => p_agent_id,
              x_lookup_code_tbl     => l_allowable_actions_tbl,
              x_displayed_field_tbl => l_displayed_field_tbl,
              x_return_status       => x_return_status);
          ELSE
            l_progress :='003';
            l_action := 'CANCEL PO';
            PO_Document_Control_PVT.get_header_actions(
              p_doc_subtype         => l_doc_subtype,
              p_doc_id              => l_doc_id,
              p_agent_id            => p_agent_id,
              x_lookup_code_tbl     => l_allowable_actions_tbl,
              x_displayed_field_tbl => l_displayed_field_tbl,
              x_return_status       => x_return_status);
          END IF;

        ELSIF p_entity_rec_tbl(i).entity_level=po_document_cancel_pvt.c_entity_level_LINE THEN
          l_doc_line_id := p_entity_rec_tbl(i).entity_id;
          l_doc_line_loc_id := NULL;

          l_progress :='004';
          l_action := 'CANCEL PO LINE';

          PO_Document_Control_PVT.get_line_actions(
            p_doc_subtype         => l_doc_subtype,
            p_doc_line_id         => l_doc_line_id,
            p_agent_id            => p_agent_id,
            x_lookup_code_tbl     => l_allowable_actions_tbl,
            x_displayed_field_tbl => l_displayed_field_tbl,
            x_return_status       => x_return_status);



        ELSIF p_entity_rec_tbl(i).entity_level=po_document_cancel_pvt.c_entity_level_SHIPMENT THEN
          l_doc_line_id := NULL;
          l_doc_line_loc_id :=p_entity_rec_tbl(i).entity_id;

          IF l_doc_type =po_document_cancel_pvt.c_doc_type_RELEASE THEN
            l_progress :='005';
            l_action := 'CANCEL REL SHIPMENT';

            PO_Document_Control_PVT.get_rel_shipment_actions(
              p_doc_subtype         => l_doc_subtype,
              p_doc_line_loc_id     => l_doc_line_loc_id,
              p_agent_id            => p_agent_id,
              x_lookup_code_tbl     => l_allowable_actions_tbl,
              x_displayed_field_tbl => l_displayed_field_tbl,
              x_return_status       => x_return_status);
          ELSE
            l_action := 'CANCEL PO SHIPMENT';
            l_progress :='006';
            PO_Document_Control_PVT.get_shipment_actions(
              p_doc_type            => l_doc_type,
              p_doc_subtype         => l_doc_subtype,
              p_doc_line_loc_id     => l_doc_line_loc_id,
              p_agent_id            => p_agent_id,
              x_lookup_code_tbl     => l_allowable_actions_tbl,
              x_displayed_field_tbl => l_displayed_field_tbl,
              x_return_status       => x_return_status);
          END IF;   -- l_doc_type  =po_document_cancel_pvt.c_doc_type_RELEASE

        END IF;-- p_entity_rec_tbl(i).entity_level=c_entity_level_HEADER




        IF (x_return_status = FND_API.g_ret_sts_error) THEN
          l_action_ok := FALSE;
          x_return_status := FND_API.g_ret_sts_success;
          l_progress :='007';
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;


        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module,l_progress,'l_action',l_action);
          PO_DEBUG.debug_var(d_module,l_progress,'p_agent_id',p_agent_id);
          PO_DEBUG.debug_var(d_module,l_progress,'l_allowable_actions_tbl.count',l_allowable_actions_tbl.count);
          PO_DEBUG.debug_var(d_module,l_progress,'l_displayed_field_tbl.count',l_displayed_field_tbl.count);
        END IF;


        l_progress :='007';

        -- If any valid actions are returned for this entity
        IF l_allowable_actions_tbl.Count >0 THEN
          l_progress :='008';
          -- Loop through allowable actions to see if this action is in the set
          FOR i IN l_allowable_actions_tbl.first..l_allowable_actions_tbl.last
          LOOP
            IF (l_action = l_allowable_actions_tbl(i)) THEN
              l_action_ok := TRUE;
              EXIT;
            END IF;
          END LOOP;
        END IF ;

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module,l_progress,'l_action_ok',l_action_ok);
        END IF;

        l_progress :='009';
        -- If not in the set, insert  error
        IF NOT l_action_ok THEN

          INSERT INTO po_online_report_text(
            ONLINE_REPORT_ID,
            LAST_UPDATE_LOGIN,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LINE_NUM,
            SHIPMENT_NUM,
            DISTRIBUTION_NUM,
            SEQUENCE,
            TEXT_LINE,
            transaction_id,
            transaction_type) VALUES
          (p_online_report_id,
          p_login_id,
          p_user_id,
          SYSDATE,
          p_user_id,
          SYSDATE,
          0,
          0,
          0,
          p_sequence + 1,
          PO_CORE_S.get_translated_text(
            'PO_CAN_CONTROL_INVALID_ACTION',
            'DOC_NUM',
            Decode(p_entity_rec_tbl(i).document_type,
            po_document_cancel_pvt.c_doc_type_RELEASE,
            (SELECT poh.segment1||'-'|| por.release_num
            FROM    po_releases por,
                    po_headers poh
            WHERE   por.po_release_id=p_entity_rec_tbl(i).doc_id
                    AND por.po_header_id=poh.po_header_id),
            (SELECT segment1
            FROM    po_headers
            WHERE   po_header_id=p_entity_rec_tbl(i).doc_id)
            ),
            'ACTION',
            'CANCEL',
            'ENTITY_LEVEL',
            p_entity_rec_tbl(i).entity_level),

          p_entity_rec_tbl(i).entity_id,
          p_entity_rec_tbl(i).entity_level);

          p_sequence := P_SEQUENCE + 1;
        END IF;  -- NOT l_action_ok


      END IF; --- p_source =c_cancel_api


      l_progress :='010';

    END LOOP;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END  val_doc_state_check;

--------------------------------------------------------------------------------
--Start of Comments
--Name: revert_pending_changes

--Function:
--  Reverts the non archived changes[only vital columns] in the base tables
--  If the user i/p flag  "Revert_change_flag" is set to Y.
--  Following columns are reverted :
--  Po Distributions : Amount Ordered and Quantity Ordered
--  Po Shipments : Amount,Quantity,Price Override,Need By date and Promised Date
--  Po Lines     : Amount,Quantity and Unit Price


--Parameters:
--IN:
--  p_revert_chg_flag
--  p_online_report_id
--  p_user_id
--  p_login_id
--  p_key

--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status -
--    FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--    FND_API.G_RET_STS_ERROR if cancel action fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------


PROCEDURE revert_pending_changes(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_revert_chg_flag       IN VARCHAR2,
            p_online_report_id      IN NUMBER,
            p_user_id               IN po_lines.last_updated_by%TYPE,
            p_login_id              IN po_lines.last_update_login%TYPE,
            p_key                   IN po_session_gt.key%TYPE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_data              OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'revert_pending_changes';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;

    l_progress          VARCHAR2(3)   := '000' ;
    l_line_loc_id_tbl   po_tbl_number;
    l_line_id_tbl       po_tbl_number;
    l_sequence          po_online_report_text.sequence%TYPE;

    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token NVARCHAR2(20);
    l_qty_token NVARCHAR2(20);
    l_doc_token  NVARCHAR2(20);
    l_to_token  NVARCHAR2(20);
	--Bug#17512423 FIX:: START
	l_po_header_id      po_line_locations.po_header_id%TYPE;
    l_po_line_id        po_line_locations.po_line_id%TYPE;
    l_payment_type      po_line_locations.payment_type%TYPE;
	l_continue boolean := false; --Bug#18105658 FIX
    --Bug#17512423 FIX:: END


  BEGIN

    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_line_token   := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token   := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_amt_token    := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token    := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');
    l_doc_token    := fnd_message.get_string('PO', 'PO_DOCUMENT_LABEL');
    l_to_token     := fnd_message.get_string('PO', 'PO_WF_NOTIF_TO');


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_revert_chg_flag',p_revert_chg_flag);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
    END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_revert_chg_flag ='Y' THEN

    SELECT Nvl(Max(sequence) ,0)
    INTO   l_sequence
    FROM   PO_ONLINE_REPORT_TEXT
    WHERE  online_report_id=p_online_report_id;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'l_sequence',l_sequence);
    END IF;

      -- Reverting back the distributions amount_ordered and quantity_ordered
      UPDATE  po_distributions_all pod
      SET     (amount_ordered ,
               quantity_ordered )=
              (SELECT
                amount_ordered,
                quantity_ordered
              FROM  po_distributions_archive_all poad
              WHERE poad.po_distribution_id =pod.po_distribution_id
                    AND poad.latest_external_flag ='Y')
      WHERE pod.line_location_id IN
              (SELECT poll.line_location_id
               FROM   po_session_gt gt,
                      po_line_locations poll,
                      po_line_locations_archive_all poall
               WHERE  gt.key=p_key
                      AND gt.char1 <> PO_Document_Cancel_PVT.c_doc_type_PA
                      AND  nvl(gt.char5,'Y') <> 'N'
                      AND poall.line_location_id =poll.line_location_id
                      AND poall.latest_external_flag ='Y'
                      AND (Nvl(poll.price_override,0) <> Nvl(poall.price_override,0)
                           OR Nvl(poll.quantity,0) <> Nvl(poall.quantity,0)
                           OR Nvl(poll.amount,0) <> Nvl(poall.amount,0)
                           OR Nvl(poll.promised_date,sysdate) <> Nvl(poall.promised_date,sysdate)
                           OR Nvl(poll.need_by_date,sysdate) <> Nvl(poall.need_by_date,sysdate))
                      AND (( poll.line_location_id=gt.num1
                             AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_SHIPMENT)
                           OR (poll.po_line_id=gt.num1
                              AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_LINE)
                           OR (poll.po_header_id=gt.num1
                               AND gt.char1<>PO_Document_Cancel_PVT.c_doc_type_RELEASE
                               AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_HEADER)
                           OR (poll.po_release_id=gt.num1
                               AND gt.char1=PO_Document_Cancel_PVT.c_doc_type_RELEASE
                               AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_HEADER)

                          ))

      RETURNING line_location_id,po_line_id
      BULK COLLECT INTO l_line_loc_id_tbl,l_line_id_tbl;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module,l_progress,'Updated distributions -Line Loc Count',l_line_loc_id_tbl.count);
        PO_DEBUG.debug_var(d_module,l_progress,'Updated distributions-Line Count',l_line_id_tbl.count);
      END IF;

      -- Reverting back the Lines Quantity and amount
      UPDATE po_line_locations poll
      SET    (price_override,
              quantity,
              amount,
              need_by_date,
              promised_date) =
             (SELECT
                price_override,
                quantity,
                amount,
                need_by_date,
                promised_date
              FROM
                po_line_locations_archive_all poall
              WHERE poall.line_location_id =poll.line_location_id
                    AND poall.latest_external_flag ='Y')
      WHERE line_location_id IN
                (SELECT *
                 FROM TABLE (CAST (l_line_loc_id_tbl AS po_tbl_number)));


      -- Reverting back the Lines Quantity and amount
      UPDATE  po_lines pol
      SET     (amount , quantity )=
              (SELECT SUM(DECODE(
                            POLL.amount,
                            NULL,
                            --Quantity or Amount Line Locations
                            ((NVL(poll.quantity,0) - NVL(poll.quantity_cancelled,0))
                            * POLL.price_override),
                            -- Fixed Price or Rate Line Locations
                            (NVL(poll.amount, 0) - NVL(poll.amount_cancelled,0))
                            )),
                      SUM(NVL(poll.quantity,0)
                          - NVL(poll.quantity_cancelled, 0))


               FROM   po_line_locations POLL
               WHERE  poll.po_line_id = pol.po_line_id)
      WHERE po_line_id IN (SELECT *
                            FROM TABLE (CAST (l_line_id_tbl AS po_tbl_number)));


	  --Bug#17512423 FIX::START Performence fix, Execute the update sql only when its required.
      IF (l_line_loc_id_tbl IS NOT NULL AND
	       l_line_loc_id_tbl.count > 0) THEN

		FOR i IN 1..l_line_loc_id_tbl.count LOOP

		l_continue := true; --Bug#18105658 FIX

		BEGIN
		  SELECT PO_HEADER_ID,
                 PO_LINE_ID,
				 PAYMENT_TYPE
		  INTO	 l_po_header_id,
                 l_po_line_id,
				 l_payment_type
          FROM   po_line_locations
          WHERE  line_location_id = l_line_loc_id_tbl(i);
        EXCEPTION
		  WHEN NO_DATA_FOUND THEN
		    --Bug#18105658 FIX don't continue with furthure processing
		     l_continue := false;
		END;

		IF l_continue THEN  --Bug#18105658 FIX
		   IF (l_payment_type IS NOT NULL) THEN
		    -- Updating Price for Complex PO Line with Milestone pay items
            UPDATE  po_lines pol
            SET     pol.unit_price =
                   (SELECT SUM(price_override)
                     FROM   po_line_locations
                     WHERE  po_line_id = pol.po_line_id)
             WHERE po_line_id = l_po_line_id
                AND pol.order_type_lookup_code IN ('QUANTITY', 'AMOUNT');
		    ELSE
		    -- Updating Price for Non Complex SPO Lines
		    UPDATE  po_lines pol
             SET     pol.unit_price =
                    (SELECT unit_price
                      FROM   po_lines_archive_all
                      WHERE  po_line_id = pol.po_line_id
                         AND latest_external_flag='Y')
             WHERE po_line_id = l_po_line_id;
	       END IF;
	    END IF;   --Bug#18105658 FIX

		END LOOP;
      END IF;
	  --Bug#17512423 FIX::END

      --Gt Table Columns Mapping
      --num1        -    entity_id
      --char1       -    document_type
      --char2       -    document_subtype
      --char3       -    entity_level
      --char4       -    doc_id
      --char5       -    process_entity_flag
      --date1       -    entity_action_date
      --index_num1  -    lowestentityid
      --lowestentityid :
  	  --  shipmentid in case of  document type= PO/Releases and
      --  subtype= Planned/Standard at any entity level
  	  --  Lineid in case of BPA and GBPA  at any entity level
  	  --  Headerid  in case of CPA


      INSERT INTO PO_ONLINE_REPORT_TEXT(
        ONLINE_REPORT_ID,
        LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATED_BY,
        CREATION_DATE,
        LINE_NUM,
        SHIPMENT_NUM,
        DISTRIBUTION_NUM,
        SEQUENCE,
        TEXT_LINE,
        message_type,
        transaction_id,
        transaction_type)
     (SELECT
        p_online_report_id,
        p_login_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        POL.LINE_NUM,
        poll.SHIPMENT_NUM,
        0,
        l_sequence + ROWNUM,
        PO_CORE_S.get_translated_text(
          'PO_CHANGED_CANT_CANCEL_INFO',
           'DOC_LINE_SHIP_DIST_NUM',l_doc_token||gt.char6||','|| l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM,
           'PRICE_TOKEN',poll.price_override||l_to_token || (SELECT price_override
                                                             FROM   po_line_locations_archive_all
                                                             WHERE latest_external_flag ='Y'
                                                                    AND  line_location_id =poll.line_location_id),
            'AMT_QTY_TOKEN', DECODE(poll.amount,NULL, 'AMOUNT',l_amt_token,l_qty_token),
            'QTY_AMT',Decode(poll.amount,NULL,
                              poll.quantity||l_to_token || (SELECT quantity
                                                         FROM   po_line_locations_archive_all
                                                         WHERE latest_external_flag ='Y'
                                                               AND  line_location_id =poll.line_location_id),
                              poll.amount||l_to_token || (SELECT amount
                                                         FROM   po_line_locations_archive_all
                                                         WHERE latest_external_flag ='Y'
                                                               AND  line_location_id =poll.line_location_id)
                           ),
            'NEED_BY_PRM_DATE', Decode(poll.promised_date,NULL,
                                       poll.need_by_date||l_to_token || (SELECT need_by_date
                                                                         FROM   po_line_locations_archive_all
                                                                         WHERE latest_external_flag ='Y'
                                                                                AND  line_location_id =poll.line_location_id),
                                        poll.promised_date||l_to_token || (SELECT promised_date
                                                                           FROM   po_line_locations_archive_all
                                                                           WHERE latest_external_flag ='Y'
                                                                                  AND line_location_id =poll.line_location_id)



                        )),
        'I',
        gt.num1,
        gt.char3
      FROM
        po_line_locations poll,
        po_lines pol,
        po_session_gt gt
      WHERE
        gt.key=p_key
        AND gt.char1 <> PO_Document_Cancel_PVT.c_doc_type_PA
        AND poll.po_line_id = pol.po_line_id
        AND poll.line_location_id IN
                (SELECT line_location_id
                 FROM TABLE (CAST (l_line_loc_id_tbl AS po_tbl_number)))
        AND (   (poll.line_location_id=gt.num1
                 AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_SHIPMENT)
              OR(poll.po_line_id=gt.num1
                 AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_LINE)
              OR(poll.po_header_id=gt.num1
                 AND gt.char1<>PO_Document_Cancel_PVT.c_doc_type_RELEASE
                 AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_HEADER)
              OR (poll.po_release_id=gt.num1
                  AND gt.char1=PO_Document_Cancel_PVT.c_doc_type_RELEASE
                  AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_HEADER)

            ));




   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_pkg_name, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
        IF (G_DEBUG_UNEXP) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                      || l_progress || ' SQL CODE IS '||sqlcode);
        END IF;

        x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.add_exc_msg(g_pkg_name, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

END revert_pending_changes;


--------------------------------------------------------------------------------
--Start of Comments
--Name: check_revert_pending_changes

-- Function:
--   Checks if there are any non-approved changes in the base tables
--   and reverts it to sync teh base table with latest revision of archive.
--   If the user inputs the rervert change flag as 'Y' and archive exists
--   then reverts the non archived changes[only vital columns] in the base tables
--   If user inputs the rervert change flag as 'Y' and archive doesnot exist
--   then throw an error as Cannot revert Changes
--   If User inputs the rervert change flag as 'N',then throw an error
--   asking user to revert the changes before canceling the document

--Parameters:
--IN:
-- p_revert_chg_flag
-- p_source
-- p_key
-- p_user_id
-- p_login_id
-- p_sequence    ,
-- p_online_report_id

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------
PROCEDURE check_revert_pending_changes(
            p_revert_chg_flag       IN VARCHAR2,
            p_online_report_id      IN NUMBER,
            p_user_id               IN po_lines.last_updated_by%TYPE,
            p_login_id              IN po_lines.last_update_login%TYPE,
            p_sequence              IN OUT NOCOPY po_online_report_text.sequence%TYPE,
            p_source                IN VARCHAR2 DEFAULT NULL,
            p_low_level_key         IN po_session_gt.key%TYPE,
            p_entity_level_key      IN po_session_gt.key%TYPE,
            p_po_enc_flag           IN FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_return_msg            OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'check_revert_pending_changes.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;

    l_progress          VARCHAR2(3)   := '000' ;
    p_line_loc_id_tbl   po_tbl_number;
    p_line_id_tbl       po_tbl_number;
    -- Bug 17318886:
    -- Russian lang. characters would be multibyte unlike English alphabets
    -- which are single byte characters.
    -- This variable requires NVARCHAR declaration to handle multibyte languages
    l_line_token NVARCHAR2(20);
    l_ship_token NVARCHAR2(20);
    l_amt_token  NVARCHAR2(20);
    l_qty_token  NVARCHAR2(20);
    l_doc_token  NVARCHAR2(20);
    l_to_token   NVARCHAR2(20);



  BEGIN

    l_line_token   := fnd_message.get_string('PO', 'PO_ZMVOR_LINE');
    l_ship_token   := fnd_message.get_string('PO', 'PO_ZMVOR_SHIPMENT');
    l_amt_token    := fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT');
    l_qty_token    := fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY');
    l_doc_token    := fnd_message.get_string('PO', 'PO_DOCUMENT_LABEL');
    l_to_token     := fnd_message.get_string('PO', 'PO_WF_NOTIF_TO');





    IF p_revert_chg_flag ='Y' THEN

      INSERT INTO PO_ONLINE_REPORT_TEXT(
        ONLINE_REPORT_ID,
        LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATED_BY,
        CREATION_DATE,
        LINE_NUM,
        SHIPMENT_NUM,
        DISTRIBUTION_NUM,
        SEQUENCE,
        TEXT_LINE,
        message_type,
        transaction_id,
        transaction_type)
     (SELECT
        p_online_report_id,
        p_login_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        POL.LINE_NUM,
        poll.SHIPMENT_NUM,
        0,
        p_sequence + ROWNUM,
        PO_CORE_S.get_translated_text(
          'PO_CANT_REVERT_PENDING_CHG',
          'DOC_LINE_SHIP_DIST_NUM',l_doc_token||gt.char6||','|| l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM
        ),
        'E',
        gt.num1,
        gt.char3
      FROM
        po_distributions_all pod,
        po_line_locations poll,
        po_lines pol ,
        po_session_gt gt
      WHERE
        gt.key=p_low_level_key
        AND pod.line_location_id=poll.line_location_id
        AND poll.line_location_id = gt.index_num1 -- lowestentityid i.e.
        AND poll.po_line_id = pol.po_line_id
        AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
        AND Nvl(poll.approved_flag,'N')<>'Y'
        -- <13503748: Edit without unreserve ER START>
        -- Throw an error if the encumbered flag at PO distributions is N for
        -- encumbered enabled environment
        AND (p_po_enc_flag = 'Y' AND pod.encumbered_flag = 'N')
        -- <13503748: Edit without unreserve ER END>
        AND (p_po_enc_flag ='Y'
             OR NOT EXISTS (SELECT 'exists archive'
                          FROM   po_distributions_archive_all
                          WHERE  po_distribution_id =pod.po_distribution_id)
            )

     );

      l_progress := '002';

      -- Revert the pending changes on the docuemnt before proceeding for the
      -- Cancel action
      revert_pending_changes(
        p_api_version=> 1.0,
        p_init_msg_list=>FND_API.G_FALSE,
        p_revert_chg_flag       => p_revert_chg_flag,
        p_online_report_id      => p_online_report_id,
        p_user_id               => p_user_id,
        p_login_id              => p_login_id,
        p_key                   => p_entity_level_key ,
        x_return_status         => x_return_status,
        x_msg_data              => x_return_msg);


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;



    ELSE

      --Gt Table Columns Mapping
      --num1        -    entity_id
      --char1       -    document_type
      --char2       -    document_subtype
      --char3       -    entity_level
      --char4       -    doc_id
      --char5       -    process_entity_flag
      --date1       -    entity_action_date
      --index_num1  -    lowestentityid
      --lowestentityid :
  	  --  shipmentid in case of  document type= PO/Releases and
      --  subtype= Planned/Standard at any entity level
  	  --  Lineid in case of BPA and GBPA  at any entity level
  	  --  Headerid  in case of CPA


      INSERT INTO PO_ONLINE_REPORT_TEXT(
        ONLINE_REPORT_ID,
        LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATED_BY,
        CREATION_DATE,
        LINE_NUM,
        SHIPMENT_NUM,
        DISTRIBUTION_NUM,
        SEQUENCE,
        TEXT_LINE,
        message_type,
        transaction_id,
        transaction_type)
     (SELECT
        p_online_report_id,
        p_login_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        POL.LINE_NUM,
        poll.SHIPMENT_NUM,
        0,
        p_sequence + ROWNUM,
        PO_CORE_S.get_translated_text(
          'PO_CHANGED_CANT_CANCEL_ERR',
           'DOC_LINE_SHIP_DIST_NUM',l_doc_token||gt.char6||','|| l_line_token||pol.LINE_NUM||','||l_ship_token||poll.SHIPMENT_NUM,
           'PRICE_TOKEN', (SELECT price_override
                                                             FROM   po_line_locations_archive_all
                                                             WHERE latest_external_flag ='Y'
                                  AND  line_location_id =poll.line_location_id)||l_to_token || poll.price_override,
            'AMT_QTY_TOKEN', DECODE(poll.amount,NULL, 'AMOUNT',l_amt_token,l_qty_token),
            'QTY_AMT',Decode(poll.amount,NULL,
                          (SELECT quantity
                                                         FROM   po_line_locations_archive_all
                                                         WHERE latest_external_flag ='Y'
                                 AND  line_location_id =poll.line_location_id) ||l_to_token || poll.quantity,
                           (SELECT amount
                                                         FROM   po_line_locations_archive_all
                                                         WHERE latest_external_flag ='Y'
                                 AND  line_location_id =poll.line_location_id) ||l_to_token || poll.amount
                        ),
            'NEED_BY_PRM_DATE', Decode(poll.promised_date,NULL,
                                       (SELECT need_by_date
                                                                         FROM   po_line_locations_archive_all
                                                                         WHERE latest_external_flag ='Y'
                                              AND  line_location_id =poll.line_location_id)||l_to_token||poll.need_by_date ,
                                       (SELECT promised_date
                                                                           FROM   po_line_locations_archive_all
                                                                           WHERE latest_external_flag ='Y'
                                              AND line_location_id =poll.line_location_id)||l_to_token||poll.promised_date



                        )),
        'E',
        gt.num1,
        gt.char3
      FROM
        po_distributions_all pod,
        po_line_locations poll,
        po_lines pol ,
        po_session_gt gt
      WHERE
        gt.key=p_low_level_key
        AND pod.line_location_id=poll.line_location_id
        AND poll.line_location_id = gt.index_num1 -- lowestentityid i.e.
        AND poll.po_line_id = pol.po_line_id
        AND gt.char1 <> po_document_cancel_pvt.c_doc_type_PA
        AND ((NOT EXISTS (SELECT 'exists archive'
                          FROM    po_distributions_archive_all
                          WHERE   po_distribution_id =pod.po_distribution_id)
                AND Nvl(poll.approved_flag,'N')<>'Y')
              OR EXISTS (SELECT 'change exists'
                         FROM po_line_locations_archive_all poall
                         WHERE poall.line_location_id =poll.line_location_id
                               AND  poall.latest_external_flag ='Y'
                               AND (Nvl(poll.price_override,0) <> Nvl(poall.price_override,0)
                                    OR Nvl(poll.quantity,0) <> Nvl(poall.quantity,0)
                                    OR Nvl(poll.amount,0) <> Nvl(poall.amount,0)
                                    OR Nvl(poll.promised_date,sysdate) <> Nvl(poall.promised_date,sysdate)
                                    OR Nvl(poll.need_by_date,sysdate) <> Nvl(poall.need_by_date,sysdate))

                            )
            )
      );

    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF ;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
          || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END check_revert_pending_changes;

--------------------------------------------------------------------------------

--Start of Comments
--Name: check_cancel_reqs_flag

-- Function:
--   Compares x_cancel_reqs_flag to the current OU's purchasing options.
--   If the current OU option is Always cancel, then x_cancel_reqs_flag is set
--   to 'Y'.
--   If the current OU option is Never cancel, then x_cancel_reqs_flag is set
--   to 'N'. Otherwise, x_cancel_reqs_flag is not modified.
--   A warning message is appended to the API message list if the caller passed
--   in a value for x_cancel_reqs_flag, and this was overwritten because it
--   conflicted with the current OU's purchasing options.
--

--Parameters:
--IN:
-- p_user_id
-- p_login_id
-- p_sequence    ,
-- p_online_report_id
-- p_doc_type
-- p_doc_id
-- p_entity_id     -- bug#17805976
-- p_entity_level  -- bug#17805976
-- p_po_encumbrance_flag
-- p_req_encumbrance_flag

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_cancel_reqs_flag:
--    A 'Y' or 'N' indicating that cancelling backing reqs when PO's are
--    cancelled is desired.

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE check_cancel_reqs_flag(
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_data         OUT NOCOPY VARCHAR2,
            p_user_id          IN  po_lines.last_updated_by%TYPE,
            p_login_id         IN po_lines.last_update_login%TYPE,
            p_sequence         IN OUT NOCOPY po_online_report_text.sequence%TYPE,
            x_cancel_reqs_flag IN OUT NOCOPY  VARCHAR2,
            p_online_report_id     IN  NUMBER,
            p_doc_type             IN  VARCHAR2,
            p_doc_id               IN  NUMBER,
            p_entity_id            IN  NUMBER,            -- bug#17805976
            p_entity_level         IN  VARCHAR2,          -- bug#17805976
            p_po_encumbrance_flag  IN  VARCHAR2,
            p_req_encumbrance_flag IN  VARCHAR2)
  IS

   d_api_name CONSTANT VARCHAR2(30) := 'check_cancel_reqs_flag.';
   d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;
   l_cancel_reqs_sys_val
           PO_SYSTEM_PARAMETERS_ALL.cancel_reqs_on_po_cancel_flag%TYPE;
   l_show_warning BOOLEAN := FALSE;
   l_progress VARCHAR2(3);
   l_cancel_reqs_flag VARCHAR2(1);

  BEGIN
    l_progress := '000';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_sequence',p_sequence);
      PO_DEBUG.debug_var(d_module,l_progress,'x_cancel_reqs_flag',x_cancel_reqs_flag);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_doc_type',p_doc_type);
      PO_DEBUG.debug_var(d_module,l_progress,'p_doc_id',p_doc_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_entity_id',p_entity_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_entity_level',p_entity_level);
      PO_DEBUG.debug_var(d_module,l_progress,'p_po_encumbrance_flag',p_po_encumbrance_flag);
      PO_DEBUG.debug_var(d_module,l_progress,'p_req_encumbrance_flag',p_req_encumbrance_flag);
      PO_DEBUG.debug_var(d_module,l_progress,'l_show_warning',l_show_warning);

    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_cancel_reqs_flag:=x_cancel_reqs_flag;
    x_msg_data :=NULL;

    l_progress := '001';

    SELECT cancel_reqs_on_po_cancel_flag
    INTO   l_cancel_reqs_sys_val
    FROM   po_system_parameters;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'l_cancel_reqs_sys_val',l_cancel_reqs_sys_val);
    END IF;


    IF (l_cancel_reqs_sys_val = 'A' AND
       NVL(x_cancel_reqs_flag, 'X') <> 'Y') THEN

      l_progress := '002';
      l_show_warning:=TRUE;
      x_cancel_reqs_flag := 'Y';

    ELSIF(l_cancel_reqs_sys_val = 'N' AND
          NVL(x_cancel_reqs_flag, 'X') <> 'N') THEN

      l_progress := '003';
      l_show_warning:=TRUE;
      x_cancel_reqs_flag := 'N';
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'l_show_warning',l_show_warning);
      PO_DEBUG.debug_var(d_module,l_progress,'x_cancel_reqs_flag',x_cancel_reqs_flag);
    END IF;

    IF l_show_warning AND x_cancel_reqs_flag IS NOT NULL THEN
      INSERT INTO po_online_report_text(
        ONLINE_REPORT_ID,
        LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATED_BY,
        CREATION_DATE,
        LINE_NUM,
        SHIPMENT_NUM,
        DISTRIBUTION_NUM,
        SEQUENCE,
        TEXT_LINE,
        transaction_id,
        transaction_type) VALUES
       (p_online_report_id,
        p_login_id,
        p_user_id,
        SYSDATE,
        p_user_id,
        SYSDATE,
        0,
        0,
        0,
        p_sequence + 1,
        PO_CORE_S.get_translated_text('PO_INVALID_CANCEL_REQS_FLAG',
                                      'USER_VALUE',l_cancel_reqs_flag,
                                      'SYSTEM_VALUE',l_cancel_reqs_sys_val),

        0,
        0
        );

      p_sequence :=p_sequence+1;
    END IF;


    IF (x_cancel_reqs_flag ='Y'
        AND p_po_encumbrance_flag = 'Y'
        AND p_req_encumbrance_flag='Y')
    THEN
      PO_Document_Cancel_PVT.val_cancel_backing_reqs(
        p_api_version   => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        x_return_status => x_return_status,
        p_doc_type      => p_doc_type,
        p_doc_id        => p_doc_id,
        p_entity_id     => p_entity_id,           -- bug#17805976
        p_entity_level  => p_entity_level );      -- bug#17805976

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
         -- Cannot cancel backing reqs, so reset to 'N'
        x_cancel_reqs_flag := 'N';
        x_return_status := FND_API.g_ret_sts_success;

      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');


  END check_cancel_reqs_flag;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_doc_params

-- Function:1.Validates the entity id against the entity level :The entity id
--            should be a valid id at that level.
--             -  If the entity level is SHIPMENT, then the entity_id should a
--                valid line_location_id in po_line_locations
--             -  If the entity level is LINE, then the entity_id should a
--                valid po_line_id in po_lines
--             -  If the entity level is HEADER, then the entity_id should a
--                valid po_header_id/po_release_id in po_headers/po_releases
--          2. Validate the parameter doc_id
--             - doc_id should always be po_header_id
--          3. Validate doc_type and doc_subtype combination
--             ex: doc_type=PO and doc_subtype=STANADARD/PLANNED is valid
--                 but doc_type=PO and doc_subtype=CONTRACT/BLANKET is invalid
--           If any of the above validation fails, it inserts the error in
--           po-onlie_report_text
--

--Parameters:
--IN:
-- p_entity_rec_tbl
-- p_online_report_id
-- p_key
-- p_user_id
-- p_login_id
-- p_sequence    ,

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_doc_params(
            p_entity_rec_tbl        IN po_document_action_pvt.entity_dtl_rec_type_tbl,
            p_online_report_id      IN NUMBER,
            p_key                   IN po_session_gt.key%TYPE,
            p_user_id               IN po_lines.last_updated_by%TYPE,
            p_login_id              IN po_lines.last_update_login%TYPE,
            p_sequence              IN OUT NOCOPY po_online_report_text.sequence%TYPE,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_return_msg            OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'validate_doc_params.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;

    l_progress VARCHAR2(3) := '000';
    l_org_count NUMBER;


  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_msg :=NULL;
    l_org_count :=0;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;

    l_progress := '001';

    -- Validate doc_type and doc_subtype combination
    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      0,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_INVALID_DOC_TYPE_SUBTYPE'
                      ,   'TYPE',  gt.char1
                      ,   'SUBTYPE',  gt.char2
                        ),
      gt.num1,
      gt.char3
    FROM
      po_session_gt gt
    WHERE gt.key=p_key
          AND (gt.char1 IS NULL
              OR gt.char2 IS NULL
              OR gt.char1 NOT IN (po_document_cancel_pvt.c_doc_type_PO,
                                  po_document_cancel_pvt.c_doc_type_PA,
                                  po_document_cancel_pvt.c_doc_type_RELEASE)
              OR (gt.char1=po_document_cancel_pvt.c_doc_type_PO
                  AND gt.char2 NOT IN(po_document_cancel_pvt.c_doc_subtype_STANDARD,
                                      po_document_cancel_pvt.c_doc_subtype_PLANNED))
              OR (gt.char1=po_document_cancel_pvt.c_doc_type_PA
                  AND gt.char2 NOT IN (po_document_cancel_pvt.c_doc_subtype_BLANKET,
                                       po_document_cancel_pvt.c_doc_subtype_contract))
              OR (gt.char1=po_document_cancel_pvt.c_doc_type_RELEASE
                  AND gt.char2 NOT IN (po_document_cancel_pvt.c_doc_subtype_BLANKET,
                                       po_document_cancel_pvt.c_doc_subtype_SCHEDULED))
              ));

    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;
    l_progress := '002';

    -- Validate : If the entity level is SHIPMENT,
    -- then the entity_id should a valid line_location_id in po_line_locations
    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      0,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_INVALID_DOC_IDS',
                       'DOC_ID',
                        gt.num1),
      gt.num1,
      gt.char3
    FROM
      po_session_gt gt
    WHERE gt.key=p_key
          AND gt.char3 =po_document_cancel_pvt.c_entity_level_SHIPMENT
          AND NOT EXISTS (SELECT '1'
                          FROM po_line_locations poll
                          WHERE poll.line_location_id = gt.num1
                          ));


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;
    l_progress := '003';

    -- Validate : If the entity level is LINE,
    -- then the entity_id should a valid po_line_id in po_lines
    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      0,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_INVALID_DOC_IDS',
                       'DOC_ID',
                        gt.num1),
      gt.num1,
      gt.char3
    FROM
      po_session_gt gt
    WHERE gt.key=p_key
          AND gt.char3 =po_document_cancel_pvt.c_entity_level_LINE
          AND NOT EXISTS(SELECT '1'
                          FROM po_lines pol
                          WHERE pol.po_line_id = gt.num1
                        ));



    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;
    l_progress := '004';

    -- Validate : If the entity level is HEADER and docuemnt type is PO/PA,
    -- then the entity_id should a valid po_header_id in po_headers
    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      0,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_INVALID_DOC_IDS',
                       'DOC_ID',
                        gt.num1),
      gt.num1,
      gt.char3
    FROM
      po_session_gt gt
    WHERE gt.key=p_key
          AND gt.char3 =po_document_cancel_pvt.c_entity_level_HEADER
          AND gt.char1<>po_document_cancel_pvt.c_doc_type_RELEASE
          AND NOT EXISTS (SELECT '1'
                          FROM po_headers poh
                          WHERE poh.po_header_id = gt.num1
                          ));

    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;
    l_progress := '005';

    -- Validate : If the entity level is HEADER and docuemnt type is RELEASE,
    -- then the entity_id should a valid po_release_id in po_releases
    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
   (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      0,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_INVALID_DOC_IDS',
                       'DOC_ID',
                        gt.num1),
      gt.num1,
      gt.char3
    FROM
      po_session_gt gt
    WHERE gt.key=p_key
          AND gt.char3 =po_document_cancel_pvt.c_entity_level_HEADER
          AND gt.char1 =po_document_cancel_pvt.c_doc_type_RELEASE
          AND NOT EXISTS (SELECT '1'
                          FROM  po_releases poh
                          WHERE poh.po_release_id = gt.num1 ));



    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;
    l_progress := '006';

    -- Validate :doc_id parametr should be a valid po_header_id in po_headers
    --           or valid po_release_id in po_releases

    INSERT INTO PO_ONLINE_REPORT_TEXT(
      ONLINE_REPORT_ID,
      LAST_UPDATE_LOGIN,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      CREATED_BY,
      CREATION_DATE,
      LINE_NUM,
      SHIPMENT_NUM,
      DISTRIBUTION_NUM,
      SEQUENCE,
      TEXT_LINE,
      transaction_id,
      transaction_type)
    (SELECT
      p_online_report_id,
      p_login_id,
      p_user_id,
      SYSDATE,
      p_user_id,
      SYSDATE,
      0,
      0,
      0,
      p_sequence + ROWNUM,
      PO_CORE_S.get_translated_text
                      ('PO_INVALID_DOC_IDS',
                       'DOC_ID',
                       gt.char4),
      gt.num1,
      gt.char3
    FROM
      po_session_gt gt
    WHERE gt.key=p_key
          AND GT.char3 <> PO_Document_Cancel_PVT.c_entity_level_HEADER
          AND NOT EXISTS (SELECT '1'
                          FROM   po_headers poh
                          WHERE  poh.po_header_id = gt.char4
                          UNION ALL
                          SELECT '1'
                          FROM  po_releases prh
                          WHERE prh.po_release_id = gt.char4));--validate doc_id


    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;
    l_progress := '006';


    -- Validate : All documents should belong to same OU
    SELECT Count(DISTINCT OPERATING_UNIT)
    INTO   l_org_count
    FROM   po_headers,
           org_organization_definitions ood
    WHERE  ood.organization_id=org_id
           AND po_header_id IN
           (SELECT pol.po_header_id
            FROM   po_lines pol,
                   po_session_gt gt
            WHERE  gt.KEY=p_key
                   AND gt.num1=pol.po_line_id
                   AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_LINE
           UNION ALL
            SELECT poll.po_header_id
            FROM   po_line_locations poll,
                   po_session_gt gt
            WHERE  gt.KEY=p_key
                   AND gt.num1=poll.line_location_id
                   AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_SHIPMENT
           UNION ALL
            SELECT gt.num1
            FROM   po_session_gt gt
            WHERE  gt.KEY=p_key
                   AND gt.char3=PO_Document_Cancel_PVT.c_entity_level_HEADER
           ) ;

    IF l_org_count>1 THEN

      INSERT INTO PO_ONLINE_REPORT_TEXT(
        ONLINE_REPORT_ID,
        LAST_UPDATE_LOGIN,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATED_BY,
        CREATION_DATE,
        LINE_NUM,
        SHIPMENT_NUM,
        DISTRIBUTION_NUM,
        SEQUENCE,
        TEXT_LINE,
        transaction_id,
        transaction_type)
      VALUES
        (p_online_report_id,
         p_login_id,
         p_user_id,
         SYSDATE,
         p_user_id,
         SYSDATE,
         0,
         0,
         0,
         p_sequence + 1,
         PO_CORE_S.get_translated_text('PO_CAN_DIFF_OU_DOCS'),
         0,
         0
        );

    END IF;

    p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                    d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                    || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END  validate_doc_params;


--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_cancel_action_params

-- Function:1.Validated the entity id against the entity level :The entity id
--            should be a valid id at that level.
--            -  If the entity level is SHIPMENT, then the entity_id should a
--               valid line_location_id in po_line_locations
--            -  If the entity level is LINE, then the entity_id should a valid
--               po_line_id in po_lines
--            -  If the entity level is HEADER, then the entity_id should a
--               valid po_header_id/po_release_id in po_headers/po_releases
--         2. Validate the parameter doc_id
--            - doc_id should always be po_header_id
--         3. Validate doc_type and doc_subtype combination
--            ex: doc_type=PO and doc_subtype=STANADARD/PLANNED is valid
--                 but doc_type=PO and doc_subtype=CONTRACT/BLANKET is invalid
--         4. Valdiates the action_date gainst the open GL period in enc is
--            enabled/cbc accounting date if cbc is enabled
--         5. Validate the Cancel reqs falg against the Purchasing Option OU
--            If any of the above validation fails, it inserts the error in
--            po-onlie_report_text
--

--Parameters:
--IN:
-- p_da_call_rec
-- p_online_report_id
-- p_key
-- p_user_id
-- p_login_id
-- p_po_enc_flag
-- p_req_enc_flag
-- p_sequence


--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------


PROCEDURE validate_cancel_action_params(
            p_da_call_rec        IN OUT NOCOPY po_document_action_pvt.DOC_ACTION_CALL_TBL_REC_TYPE,
            p_online_report_id   IN NUMBER,
            p_key                IN po_session_gt.key%TYPE,
            p_user_id            IN po_lines.last_updated_by%TYPE,
            p_login_id           IN po_lines.last_update_login%TYPE,
            p_po_enc_flag        IN FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE,
            p_req_enc_flag       IN FINANCIALS_SYSTEM_PARAMETERS.req_encumbrance_flag%TYPE,
            p_sequence           IN OUT NOCOPY po_online_report_text.sequence%TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_return_msg         OUT NOCOPY VARCHAR2)


  IS

    d_api_name CONSTANT VARCHAR2(30) := 'validate_cancel_action_params.';
    d_module CONSTANT VARCHAR2(100) := g_pkg_name||d_api_name;

    l_progress VARCHAR2(3) := '000';

    l_entity_rec_tbl po_document_action_pvt.entity_dtl_rec_type_tbl;
    l_cbc_enabled VARCHAR2(1);
    l_action_date DATE;
    id_count NUMBER :=0;
    l_doc_id_tbl po_tbl_number :=PO_TBL_NUMBER();
    l_source VARCHAR2(50);


  BEGIN

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
      PO_DEBUG.debug_var(d_module,l_progress,'p_req_enc_flag',p_req_enc_flag);
      PO_DEBUG.debug_var(d_module,l_progress,'p_po_enc_flag',p_po_enc_flag);
    END IF;

    l_progress := '001';

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_msg:=NULL;

    l_entity_rec_tbl  :=p_da_call_rec.entity_dtl_record_tbl;
    l_action_date     :=p_da_call_rec.action_date;
    l_source          := p_da_call_rec.caller;

    l_progress := '002';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'l_action_date',l_action_date);
    END IF;

    l_progress := '003';

    --validate entity_id,doc_id, doc_type, doc_subtype
    validate_doc_params(p_entity_rec_tbl  => l_entity_rec_tbl,
      p_online_report_id =>p_online_report_id,
      p_key =>p_key,
      p_user_id =>p_user_id,
      p_login_id => p_login_id,
      p_sequence =>p_sequence,
      x_return_status => x_return_status,
      x_return_msg =>x_return_msg );

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '004';

    -- for each entity id in the entity record table
    FOR i IN 1..l_entity_rec_tbl.Count LOOP
      -- Action date is validated at document level
      -- (i.e.doc_type,doc_subtype and doc_id).There can be entities belonging
      -- to same doc_id[ ex: 2 shipemnts from same PO],
      -- hence, checking if the action_date is already validated for that
      IF NOT l_doc_id_tbl.EXISTS(l_entity_rec_tbl(i).doc_id) THEN

        IF nvl(l_source,'NULL') NOT IN (PO_DOCUMENT_CANCEL_PVT.c_HTML_CONTROL_ACTION,
                                        PO_DOCUMENT_CANCEL_PVT.c_FORM_CONTROL_ACTION)
        THEN

        -- Initialize the action date
        -- If x_action_date is NULL, then sets it to a valid CBC accounting
        -- date if CBC is enabled. Otherwise, sets it to the current system date.
        PO_DOCUMENT_CONTROL_PVT.init_action_date(
          p_api_version   => 1.0,
	        p_init_msg_list => FND_API.G_FALSE,
	        x_return_status => x_return_status,
	        p_doc_type      => l_entity_rec_tbl(i).document_type,
	        p_doc_subtype   => l_entity_rec_tbl(i).document_subtype,
	        p_doc_id        => l_entity_rec_tbl(i).doc_id,
	        x_action_date   => l_action_date,
    	    x_cbc_enabled   => l_cbc_enabled);


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

        END IF; --nvl(l_source,'NULL') NOT IN (PO_DOCUMENT_CANCEL_PVT.c_HTML_CONTROL_ACTION,PO_DOCUMENT_CANCEL_PVT.c_FORM_CONTROL_ACTION)

      l_progress := '005';

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module,l_progress,'l_action_date',l_action_date);
        PO_DEBUG.debug_var(d_module,l_progress,'l_cbc_enabled',l_cbc_enabled);
      END IF;


      -- Validate the action date
      -- If encumbrance is on, checks that l_action_date lies in an open GL period
      -- Also checks that action_date is a valid CBC accounting date if cbc is enabled
      PO_DOCUMENT_CONTROL_PVT.val_action_date(
        p_api_version   => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        x_return_status => x_return_status,
        p_doc_type      => l_entity_rec_tbl(i).document_type,
	      p_doc_subtype   => l_entity_rec_tbl(i).document_subtype,
	      p_doc_id        => l_entity_rec_tbl(i).doc_id,
        p_action        => 'CANCEL',
        p_action_date   => l_action_date,
        p_cbc_enabled   => l_cbc_enabled,
        p_po_encumbrance_flag  => p_po_enc_flag,
        p_req_encumbrance_flag => p_req_enc_flag );

      l_progress := '006';


      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module,l_progress,'x_return_status',x_return_status);
      END IF;

      -- If the valdation fails then insert error into online report text
      IF(x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN

        INSERT INTO po_online_report_text(
          ONLINE_REPORT_ID,
          LAST_UPDATE_LOGIN,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          CREATED_BY,
          CREATION_DATE,
          LINE_NUM,
          SHIPMENT_NUM,
          DISTRIBUTION_NUM,
          SEQUENCE,
          TEXT_LINE,
          transaction_id,
          transaction_type)
        (SELECT
          p_online_report_id,
          p_login_id,
          p_user_id,
          SYSDATE,
          p_user_id,
          SYSDATE,
          0,
          0,
          0,
          p_sequence + ROWNUM,
          PO_CORE_S.get_translated_text('PO_ACTION_DATE_INVALID',
                                    'DOC_NUM',
                                    gt.char6,
                                    'ACTION_DATE',
                                    l_action_date),
          gt.num1,
          gt.char3
        FROM
          po_session_gt gt
        WHERE gt.key=p_key
              AND gt.char4 =l_entity_rec_tbl(i).doc_id
        );

        p_sequence := P_SEQUENCE + SQL%ROWCOUNT;

      END IF;

      l_progress := '007';

      l_doc_id_tbl.extend;
      id_count:=id_count+1;
      l_doc_id_tbl(id_count):=l_entity_rec_tbl(i).doc_id;

      UPDATE po_session_gt
      SET    date1=  l_action_date
      WHERE  KEY=p_key
             AND char4= l_entity_rec_tbl(i).doc_id;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module,l_progress,'update row count',SQL%ROWCOUNT);
      END IF;

        l_progress := '008';

  -- Validate CancelReqs flag with the current OU's purchasing options.
  check_cancel_reqs_flag(
    p_online_report_id =>p_online_report_id,
    x_cancel_reqs_flag =>p_da_call_rec.cancel_reqs_flag,
    p_doc_type             => l_entity_rec_tbl(i).document_type,
    p_doc_id               => l_entity_rec_tbl(i).doc_id,
    p_entity_id            => l_entity_rec_tbl(i).entity_id,         --Bug#17805976
    p_entity_level         => l_entity_rec_tbl(i).entity_level,      --Bug#17805976
    p_user_id =>p_user_id,
    p_login_id => p_login_id,
    p_sequence =>p_sequence,
    p_po_encumbrance_flag  => p_po_enc_flag,
    p_req_encumbrance_flag => p_req_enc_flag,
    x_return_status => x_return_status,
    x_msg_data =>x_return_msg );



      END IF;
    END LOOP;



  IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
  END IF ;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                    P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                      || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;


      x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                    P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END validate_cancel_action_params;


--------------------------------------------------------------------------------
--Start of Comments
--Name: mark_errored_record

-- Modifies:process_entity_flag for each entity being canceled in the entity
--          record which will be used to identify records eligible for futher
--          processing
--
--Effects:1.Updates the process entity flag=N if for that entity id there is
--          an entry in po_online_report_text table
--        2.Deletes the data from session gt table, which was used for validations
--

--Parameters:
--IN:
--  p_da_call_rec
--  p_key
-- p_online_report_id
-- p_entity_rec_tbl

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_return_msg

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE mark_errored_record(
            p_key              IN po_session_gt.key%TYPE,
            p_online_report_id IN NUMBER,
            p_entity_rec_tbl   IN OUT NOCOPY po_document_action_pvt.entity_dtl_rec_type_tbl,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_return_msg       OUT NOCOPY VARCHAR2,
            x_return_code      OUT NOCOPY VARCHAR2)


  IS

    d_api_name CONSTANT VARCHAR2(30) := 'mark_errored_record.';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress   VARCHAR2(3)   := '000' ;

    l_count NUMBER;
    -- Bug  17033111
    is_lock_error VARCHAR2(1);

  BEGIN


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
      PO_DEBUG.debug_var(d_module,l_progress,'p_online_report_id',p_online_report_id);
    END IF;

    l_progress := '001';

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_msg:=NULL;
    x_return_code :='S';
    -- Bug 17033111
    is_lock_error :='N';

    -- Upadate char5[column corresponding to process_entity_flag in entity record
    -- table] in po_session_gt to 'N'
    -- If there is an entry in po_online_report_text for the entity_id  and
    -- entity_level  combination
    -- Columns mapping :
    -- entity_id in entity record = num1 in session gt = transaction_id in
    -- po_online_report_text
    -- entity_level in entity record = char3 in session gt = transaction_type in
    -- po_online_report_text
    -- process_entity_flag in entity record  char5 in session gt
    -- Block Modified for Bug 17033111 Starts
    BEGIN

    SELECT 'Y'
    INTO is_lock_error
    FROM po_online_report_text
    WHERE online_report_id =p_online_report_id
          AND TEXT_LINE LIKE  PO_CORE_S.get_translated_text('PO_DOC_CANNOT_LOCK');

    EXCEPTION
      WHEN OTHERS THEN
        is_lock_error :='N';
        NULL;
    END;

    -- If the error is locking error, mark all records process_entity_flag='N' \
    -- i.e. No record has passed validation.
    IF is_lock_error='Y' THEN

      UPDATE po_session_gt
      SET    char5 ='N'
      WHERE KEY=p_key;

      l_count :=SQL%ROWCOUNT;
    ELSE
    UPDATE po_session_gt
    SET    char5 ='N'
    WHERE KEY=p_key
          AND EXISTS(SELECT 'error record exists'
                     FROM   po_online_report_text
                     WHERE  transaction_id=num1
                            AND transaction_type=char3
                            AND Nvl(message_type,'E') = 'E'
                            AND online_report_id =p_online_report_id);


    l_count :=SQL%ROWCOUNT;
    END IF;
    -- Block Modified for Bug 17033111 Ends
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'records updated in po_session_gt',l_count);
    END IF;

    IF l_count>0 THEN
     x_return_code :='F';
    END IF;
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'x_return_code',x_return_code);
    END IF;

    l_progress  := '002';

    -- Bulk select from po_session_gt back into entity record so that the
    -- corresponding  process_entity_flag gets updated in entity record
    -- doc_id,document_type,document_subtype,entity_id,entity_level,
    -- process_entity_flag,recreate_demand_flag

    SELECT DISTINCT char4,
            char1,
            char2,
            num1,
            char3,
            date1,
            char5,
            'N'
    BULK COLLECT INTO
      p_entity_rec_tbl
    FROM
      po_session_gt
    WHERE KEY=p_key
    ORDER BY char4;

    l_count :=SQL%ROWCOUNT;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'records updated into p_entity_rec_tbl',l_count);
      PO_DEBUG.debug_end(d_module);
    END IF ;

    EXCEPTION
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                 P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      WHEN FND_API.G_EXC_ERROR THEN
        x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                    P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_ERROR;

      WHEN OTHERS THEN
        IF (G_DEBUG_UNEXP) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                      d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                      || l_progress || ' SQL CODE IS '||sqlcode);
        END IF;


        x_return_msg := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                    P_ENCODED => 'F');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


  END mark_errored_record;

--------------------------------------------------------------------------------
--Start of Comments
--Name: validate_cancel_action

--Requires: p_da_call_rec to be initialized with the proper data
--Modifies:1.process_entity_flag for each entity being canceled in the entity record
--           which will be used to identify records eligible for futher processing
--         2.online_report_id column in p_da_call_rec which will be used later
--           to report errors.
--
--Effects: Validates the document for Cancel Action and insert the error in
--         online_eport_text table.
--         Validation includes -
--         1. Validating the input parameters
--            - entity id against the entity level :The entity id should be a
--              valid id at that level.
--            - Initializes the action date and validate it based on the
--              encumbrance enabled/cbc enabled flags
--         2. Validates if the current user has access and security clearance
--            to modfiy/act upon the entiy being canceled.
--         3. Validates the document state if the caller is CANCEL API
--              - Document should be atleast once approved
--               - Document should be in APPROVED/REJECTED/REQUIRES-REAPPROVAL
--                 status
--               - Document should not be Finally Closed/Hold
--         4. Validates if the document has not been changed since its last
--            revision.
--         5. Business Rule Valdiations to allow cancel action
--           If any of the above validation fails, it inserts the error in
--           po-onlie_report_text
--
--

--Parameters:
--IN:
--  p_da_call_rec
--  p_key
--  p_user_id
--  p_login_id
--  p_po_enc_flag
--  p_req_enc_flag

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_cancel_action(
            p_da_call_rec    IN OUT NOCOPY po_document_action_pvt.DOC_ACTION_CALL_TBL_REC_TYPE,
            p_key            IN po_session_gt.key%TYPE,
            p_user_id        IN po_lines.last_updated_by%TYPE,
            p_login_id       IN po_lines.last_update_login%TYPE,
            p_po_enc_flag    IN FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE,
            p_req_enc_flag   IN FINANCIALS_SYSTEM_PARAMETERS.req_encumbrance_flag%TYPE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_data       OUT NOCOPY VARCHAR2,
            x_return_code    OUT NOCOPY VARCHAR2)
  IS

    l_online_report_id NUMBER;
    l_temp_key  po_session_gt.key%TYPE;
    l_key  po_session_gt.key%TYPE;



    l_agent_id PO_HEADERS.agent_id%TYPE := FND_GLOBAL.employee_id;
    l_sequence   po_online_report_text.sequence%TYPE ;

    d_api_name CONSTANT VARCHAR2(30) := 'validate_cancel_action';
    d_module   CONSTANT VARCHAR2(100) := g_pkg_name || d_api_name;
    l_progress   VARCHAR2(3)   := '000' ;


    BEGIN

      IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(d_module);
        PO_DEBUG.debug_var(d_module,l_progress,'l_agent_id',l_agent_id);
        PO_DEBUG.debug_var(d_module,l_progress,'p_key',p_key);
        PO_DEBUG.debug_var(d_module,l_progress,'p_login_id',p_login_id);
        PO_DEBUG.debug_var(d_module,l_progress,'p_user_id',p_user_id);
        PO_DEBUG.debug_var(d_module,l_progress,'p_po_enc_flag',p_po_enc_flag);
        PO_DEBUG.debug_var(d_module,l_progress,'p_req_enc_flag',p_req_enc_flag);
      END IF;


      l_key :=p_key;
      x_return_status := FND_API.g_ret_sts_success;
      x_msg_data:=NULL;
      x_return_code :='S';
      l_sequence := 0;

      l_progress := '001';

      --Get the unique id to be used for this document
      SELECT PO_ONLINE_REPORT_TEXT_S.nextval
      INTO   l_online_report_id
      FROM   sys.dual;


      l_progress := '002';


      -- Update the  l_online_report_id into the record
      p_da_call_rec.online_report_id :=l_online_report_id;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module,l_progress,'l_online_report_id',l_online_report_id);
      END IF;


      -- Validate the input parameters like entity ids, action date
      validate_cancel_action_params(
        p_da_call_rec           => p_da_call_rec,
        p_online_report_id      => l_online_report_id,
        p_key                   => l_key,
        p_user_id               => p_user_id,
        p_login_id              => p_login_id,
        p_po_enc_flag           => p_po_enc_flag,
        p_req_enc_flag          => p_req_enc_flag,
        p_sequence	            => l_sequence,
        x_return_status         => x_return_status,
        x_return_msg            => x_msg_data);




      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;


      l_progress := '004';


      -- Ensure that we are not using a NULL agent ID.
      IF (l_agent_id IS NULL) THEN
         l_agent_id := -1;
      END IF;


      -- Check if this agent has security clearance for the documents being cancelled
      val_security_check(
        p_entity_rec_tbl        => p_da_call_rec.entity_dtl_record_tbl,
        p_online_report_id      => l_online_report_id,
        p_key                   => l_key,
        p_user_id               => p_user_id,
        p_login_id              => p_login_id,
        p_sequence	             => l_sequence,
        p_agent_id              => l_agent_id,
        x_return_status         => x_return_status,
        x_return_msg            => x_msg_data);



      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;


      l_progress := '005';

      -- Validate the document state
      val_doc_state_check(
        p_entity_rec_tbl    => p_da_call_rec.entity_dtl_record_tbl,
        p_key                   => l_key,
        p_agent_id              => l_agent_id,
        p_online_report_id      => l_online_report_id,
        p_user_id               => p_user_id,
        p_login_id              => p_login_id,
        p_sequence	         => l_sequence,
        p_source                => p_da_call_rec.caller,
        x_return_status         => x_return_status,
        x_return_msg            => x_msg_data);



      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_progress := '006';
      l_temp_key :=l_key;

      -- For Cancel , all the business rules are to be valdiated on the lowest
      -- level entity of any docuemnt
      -- ex:On cancelling PO header, we need to validate the rules for all
      --    its shipments
      --    On cancelling PO Line, we need to validate the rules for all
      --    its shipments
      --    On Cancelling Blanket header, we need to validate all its line ,
      --    and so on..
      -- So, updating the session gt with the lowest level enity for each
      -- entity being cancelled,which will be used for business rule valdiations
      update_gt_with_low_entity(
        p_entity_rec_tbl=>p_da_call_rec.entity_dtl_record_tbl,
        p_key =>l_temp_key,
        x_return_status =>x_return_status,
        x_msg_data  =>x_msg_data);


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module,l_progress,'l_key',l_key);
        PO_DEBUG.debug_var(d_module,l_progress,'l_temp_key',l_temp_key);
      END IF;

       l_progress := '007';

      -- Lock all the docuemnts being cancelled
      PO_DOCUMENT_LOCK_GRP.lock_document (
        p_online_report_id =>l_online_report_id,
        p_api_version   =>1.0,
        p_init_msg_list =>FND_API.G_FALSE,
        po_sesiongt_key  => l_key,
        p_user_id  => p_user_id,
        p_login_id  =>p_login_id,
        x_return_status =>x_return_status);

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        -- Bug 17033111
        --RAISE FND_API.g_exc_error;
        --Update the process_entity_flag to N in p_da_call_rec
        --for all the entities as Cannot be proceeded for further cancel cation
        mark_errored_record(
          p_key => l_key,
          p_online_report_id      => l_online_report_id,
          p_entity_rec_tbl        => p_da_call_rec.entity_dtl_record_tbl,
          x_return_status         => x_return_status,
          x_return_msg            => x_msg_data,
          x_return_code           => x_return_code);
        x_return_status := FND_API.g_ret_sts_success;
        RETURN;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;


      l_progress := '008';

      --check for any change in its current revision  with that of in the Archive
      -- If there are pending changes, revert it based on user input flag
      check_revert_pending_changes(
        p_revert_chg_flag       => p_da_call_rec.revert_pending_chg_flag,
        p_online_report_id      => l_online_report_id,
        p_user_id               => p_user_id,
        p_login_id              => p_login_id,
        p_sequence	            => l_sequence,
        p_source                => p_da_call_rec.caller,
        p_low_level_key         => l_temp_key ,
        p_po_enc_flag           => p_po_enc_flag,
        p_entity_level_key      => l_key ,
        x_return_status         => x_return_status,
        x_return_msg            => x_msg_data);


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;


      l_progress := '009';


      -- Preform all business validations needed for cancelling the docuemnt
      po_cancel_action_checks(
        p_entity_rec_tbl        => p_da_call_rec.entity_dtl_record_tbl,
        p_action_date           => p_da_call_rec.action_date,
        p_key                   => l_temp_key,
        p_online_report_id      => l_online_report_id,
        p_user_id               => p_user_id,
        p_login_id              => p_login_id,
        p_sequence	            => l_sequence,
        x_return_status         => x_return_status,
        x_return_msg            => x_msg_data);


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_progress := '010';

      DELETE FROM po_session_gt WHERE KEY=l_temp_key;

      l_progress :='011';

      --Update the process_entity_flag to N in p_da_call_rec
      --for the entities which didnt pass the validations
      mark_errored_record(
        p_key => l_key,
        p_online_report_id      => l_online_report_id,
        p_entity_rec_tbl        => p_da_call_rec.entity_dtl_record_tbl,
        x_return_status         => x_return_status,
        x_return_msg            => x_msg_data,
        x_return_code           => x_return_code);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_end(d_module);
    END IF ;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                  P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     d_module || '.UNEXPECTED_EXCEPTION', 'EXCEPTION: LOCATION IS '
                     || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;


    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                  P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     d_module || '.ERROR', 'ERROR: LOCATION IS '
                     || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                     d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS '
                     || l_progress || ' SQL CODE IS '||sqlcode);
      END IF;


      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                  P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END validate_cancel_action;




END PO_CONTROL_ACTION_VALIDATIONS;

/
