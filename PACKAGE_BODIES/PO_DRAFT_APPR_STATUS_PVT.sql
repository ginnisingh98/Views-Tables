--------------------------------------------------------
--  DDL for Package Body PO_DRAFT_APPR_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DRAFT_APPR_STATUS_PVT" AS
/* $Header: PO_DRAFT_APPR_STATUS_PVT.plb 120.7.12010000.3 2013/05/27 15:31:52 srpantha ship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_DRAFT_APPR_STATUS_PVT');

-------------------------------------------------------
----------- PRIVATE PROCEDURES PROTOTYPE --------------
-------------------------------------------------------

PROCEDURE handle_shipment_approved_flag
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
);

PROCEDURE val_auth_status_header
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
);

PROCEDURE val_auth_status_line
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
);

PROCEDURE val_auth_status_line_loc
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN,
  x_changed_line_loc_list OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE val_auth_status_dist
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN,
  x_changed_line_loc_list OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE val_auth_status_org_assign
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
);

PROCEDURE val_auth_status_price_diff
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
);


-------------------------------------------------------
-------------- PUBLIC PROCEDURES ----------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: update_approval_status
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Changes header and shipment approval status in the transaction table
--  based on the changes recorded in draft table
--Parameters:
--IN:
--p_draft_info
--  Record structure holding change request information
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE update_approval_status
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_rebuild_attribs OUT NOCOPY BOOLEAN
) IS

d_api_name CONSTANT VARCHAR2(30) := 'udpate_approval_status';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_new_auth_status PO_HEADERS_ALL.authorization_status%TYPE;
l_new_approved_flag PO_HEADERS_ALL.approved_flag%TYPE;
l_orig_auth_status PO_HEADERS_ALL.authorization_status%TYPE;
l_orig_approved_flag PO_HEADERS_ALL.approved_flag%TYPE;
l_type_lookup_code PO_HEADERS_ALL.type_lookup_code%TYPE;

l_change_status BOOLEAN := FALSE;
BEGIN

  x_rebuild_attribs := FALSE; --Bug#5264722
  d_position := 0;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.new_document = FND_API.G_TRUE) THEN
    RETURN;
  END IF;

  d_position := 10;

  SELECT NVL(authorization_status, 'INCOMPLETE'),
         NVL(approved_flag, 'N'),
         type_lookup_code --Bug#5264722
  INTO l_orig_auth_status,
       l_orig_approved_flag,
       l_type_lookup_code --Bug#5264722
  FROM po_headers_all
  WHERE po_header_id = p_draft_info.po_header_id;

  d_position := 20;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'orig_auth_status', l_orig_auth_status);
    PO_LOG.stmt(d_module, d_position, 'orig_approved_flag',
                                      l_orig_approved_flag);
  END IF;

  IF (l_orig_auth_status = 'INCOMPLETE') THEN
    RETURN;
  END IF;

  d_position := 30;

  -- This procedure takes care of shipment and distribution records
  handle_shipment_approved_flag
  ( p_draft_info => p_draft_info,
    x_change_status => l_change_status
  );

  -- if document status is 'REQUIRES REAPPROVAL', we know that the header
  -- status will not be changed, so no need to check other entities that
  -- can only affect header approval status

  IF (l_orig_approved_flag = 'Y' OR
      l_orig_auth_status = 'PRE-APPROVED') THEN

    d_position := 40;

    IF (NOT l_change_status) THEN
      val_auth_status_header
      ( p_draft_info => p_draft_info,
        x_change_status => l_change_status
      );
    END IF;

    d_position := 50;

    IF (NOT l_change_status) THEN
      val_auth_status_line
      ( p_draft_info => p_draft_info,
        x_change_status => l_change_status
      );
    END IF;

    d_position := 60;

    IF (NOT l_change_status) THEN
      val_auth_status_org_assign
      ( p_draft_info => p_draft_info,
        x_change_status => l_change_status
      );
    END IF;

    d_position := 70;

    IF (NOT l_change_status) THEN
      val_auth_status_price_diff
      ( p_draft_info => p_draft_info,
        x_change_status => l_change_status
      );
    END IF;

    d_position := 80;

    IF (l_change_status) THEN

      IF (l_orig_auth_status = 'PRE-APPROVED') THEN
        l_new_auth_status := 'IN PROCESS';
        l_new_approved_flag := 'N';
      ELSE
        l_new_approved_flag := 'R';
        l_new_auth_status := 'REQUIRES REAPPROVAL';
      END IF;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_position, 'new_auth_status',
                                          l_new_auth_status);
        PO_LOG.stmt(d_module, d_position, 'new_approved_flag',
                                          l_new_approved_flag);
      END IF;

      d_position := 90;

      UPDATE po_headers_all
      SET    authorization_status = l_new_auth_status,
             approved_flag = l_new_approved_flag,
             last_update_date = SYSDATE
      WHERE po_header_id = p_draft_info.po_header_id;

      d_position := 100;
      -- update draft table as well so that the merge statement would
      -- not set the status back to its original one
      UPDATE po_headers_draft_all
      SET    authorization_status = l_new_auth_status,
             approved_flag = l_new_approved_flag,
             last_update_date = SYSDATE
      WHERE po_header_id = p_draft_info.po_header_id
      AND   draft_id = p_draft_info.draft_id;

      -- <HTML Agreement R12 START>
      -- Since approval status is changed, give the functional lock to
      -- BUYER
      PO_DRAFTS_PVT.lock_document
      ( p_po_header_id => p_draft_info.po_header_id,
        p_role => PO_GLOBAL.g_ROLE_BUYER,
        p_role_user_id => FND_GLOBAL.user_id,
        p_unlock_current => FND_API.G_FALSE
      );
      -- <HTML Agreement R12 END>
    END IF;
  END IF;

  --Bug#5264722
  d_position := 107;
  if(l_orig_auth_status = 'APPROVED' AND l_change_status = FALSE
     AND l_type_lookup_code in (PO_PDOI_CONSTANTS.g_DOC_TYPE_BLANKET,
                                PO_PDOI_CONSTANTS.g_DOC_TYPE_QUOTATION))
  then
    x_rebuild_attribs := TRUE;
  end if;

  d_position := 110;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END update_approval_status;

-------------------------------------------------------
-------------- PRIVATE PROCEDURES ---------------------
-------------------------------------------------------

-----------------------------------------------------------------------
--Start of Comments
--Name: handle_shipment_approved_flag
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Checks shipment and distribution changes and see if approval status
--  change will be triggered. This procedure also determines the approved
--  flag value for shipments based on shipment and distribution changes
--Parameters:
--IN:
--p_draft_info
--  Record structure holding draft information
--IN OUT:
--x_change_status
--  This procedure sets this parameter to TRUE if status needs to be
--  changed
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE handle_shipment_approved_flag
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
) IS

d_api_name CONSTANT VARCHAR2(30) := 'handle_shipment_approved_flag';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_line_loc_list1 PO_TBL_NUMBER; -- list of line locations that need to
                                -- have approved_flag re-evaluated due to
                                -- line location changes

l_line_loc_list2 PO_TBL_NUMBER; -- list of line locations that need to have
                                -- approved_flag re-evaluated due to
                                -- distribution changes

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  val_auth_status_line_loc
  ( p_draft_info => p_draft_info,
    x_change_status => x_change_status,
    x_changed_line_loc_list => l_line_loc_list1
  );

  d_position := 10;
  IF (l_line_loc_list1 IS NOT NULL) THEN

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,
                  'Update shipment approved flag for shipment changes');
    END IF;

    FORALL i IN 1..l_line_loc_list1.COUNT
      UPDATE po_line_locations_draft_all
      SET approved_flag = 'R'
      WHERE line_location_id = l_line_loc_list1(i)
      AND draft_id = p_draft_info.draft_id
      AND approved_flag = 'Y';
  END IF;

  d_position := 20;
  val_auth_status_dist
  ( p_draft_info => p_draft_info,
    x_change_status => x_change_status,
    x_changed_line_loc_list => l_line_loc_list2
  );

  d_position := 30;
  IF (l_line_loc_list2 IS NOT NULL) THEN
    d_position := 40;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,
                  'Update shipment approved flag for distribution changes');
    END IF;

    FORALL i IN 1..l_line_loc_list2.COUNT
      UPDATE po_line_locations_draft_all
      SET approved_flag = 'R'
      WHERE line_location_id = l_line_loc_list2(i)
      AND draft_id = p_draft_info.draft_id
      AND approved_flag = 'Y';

    d_position := 50;

    -- need to update transaction table as well because there may not be
    -- shipment changes for the distribution being changed.
    FORALL i IN 1..l_line_loc_list2.COUNT
      UPDATE po_line_locations_all
      SET approved_flag = 'R'
      WHERE line_location_id = l_line_loc_list2(i)
      AND approved_flag = 'Y';
  END IF;

  d_position := 60;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END handle_shipment_approved_flag;

-----------------------------------------------------------------------
--Start of Comments
--Name: val_auth_status_header
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Checks whether there are any changes at the header that trigger
--  approval status to be updated
--Parameters:
--IN:
--p_draft_info
--  Record structure holding draft information
--IN OUT:
--x_change_status
--  This procedure sets this parameter to TRUE if status needs to be
--  changed
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE val_auth_status_header
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
) IS

d_api_name CONSTANT VARCHAR2(30) := 'val_auth_status_header';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_different VARCHAR2(1);

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.headers_changed = FND_API.G_FALSE) THEN
    RETURN;
  END IF;

  d_position := 10;
  --SQL What: Compare attributes of the transaction and draft record. Return 'Y'
  --          if any of the attributes is different
  --SQL Why: Need to figure out if the change triggers a change to approval
  --         status
  SELECT MAX(FND_API.G_TRUE)
  INTO l_different
  FROM dual
  WHERE EXISTS
    ( SELECT NULL
      FROM po_headers_draft_all PHD,
           po_headers_all PH
      WHERE PHD.po_header_id = p_draft_info.po_header_id
      AND   PHD.draft_id = p_draft_info.draft_id
      AND    NVL(PHD.delete_flag, 'N') = 'N'
      AND    NVL(PHD.change_accepted_flag, 'Y') = 'Y'
      AND   PHD.po_header_id = PH.po_header_id
      AND
       (   DECODE (PHD.agent_id, PH.agent_id, 'Y', 'N') = 'N'
        OR DECODE (PHD.vendor_site_id, PH.vendor_site_id, 'Y', 'N') = 'N'
        OR DECODE (PHD.vendor_contact_id, PH.vendor_contact_id, 'Y', 'N') = 'N'
        OR DECODE (PHD.confirming_order_flag, PH.confirming_order_flag, 'Y', 'N') = 'N'
        OR DECODE (PHD.ship_to_location_id, PH.ship_to_location_id, 'Y', 'N') = 'N'
        OR DECODE (PHD.bill_to_location_id, PH.bill_to_location_id, 'Y', 'N') = 'N'
        OR DECODE (PHD.terms_id, PH.terms_id, 'Y', 'N') = 'N'
        OR DECODE (PHD.ship_via_lookup_code, PH.ship_via_lookup_code, 'Y', 'N') = 'N'
        OR DECODE (PHD.fob_lookup_code, PH.fob_lookup_code, 'Y', 'N') = 'N'
        OR DECODE (PHD.freight_terms_lookup_code, PH.freight_terms_lookup_code, 'Y', 'N') = 'N'
        OR DECODE (PHD.note_to_vendor, PH.note_to_vendor, 'Y', 'N') = 'N'
        OR DECODE (PHD.acceptance_required_flag, PH.acceptance_required_flag, 'Y', 'N') = 'N'
        OR DECODE (PHD.blanket_total_amount, PH.blanket_total_amount, 'Y', 'N') = 'N'
        OR DECODE (PHD.start_date, PH.start_date, 'Y', 'N') = 'N'
        OR DECODE (PHD.end_date, PH.end_date, 'Y', 'N') = 'N'
        OR DECODE (PHD.amount_limit, PH.amount_limit, 'Y', 'N') = 'N'
        OR DECODE (PHD.conterms_articles_upd_date, PH.conterms_articles_upd_date, 'Y', 'N') = 'N'
        OR DECODE (PHD.conterms_deliv_upd_date, PH.conterms_deliv_upd_date, 'Y', 'N') = 'N'
        OR DECODE (PHD.shipping_control, PH.shipping_control, 'Y', 'N') = 'N'
       )
    );

  d_position := 20;
  IF (l_different = FND_API.G_TRUE) THEN

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'header causes approval change');
    END IF;

    x_change_status := TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END val_auth_status_header;

-----------------------------------------------------------------------
--Start of Comments
--Name: val_auth_status_line
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Checks whether there are any changes at the line level that trigger
--  approval status to be updated
--Parameters:
--IN:
--p_draft_info
--  Record structure holding draft information
--IN OUT:
--x_change_status
--  This procedure sets this parameter to TRUE if status needs to be
--  changed
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE val_auth_status_line
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
) IS

d_api_name CONSTANT VARCHAR2(30) := 'val_auth_status_line';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_has_new_records VARCHAR2(1);
l_different VARCHAR2(1);
BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.lines_changed = FND_API.G_FALSE) THEN
    RETURN;
  END IF;

  d_position := 10;
  -- Change auth status if there is a new line
  SELECT MAX(FND_API.G_TRUE)
  INTO l_has_new_records
  FROM dual
  WHERE EXISTS
    ( SELECT NULL
      FROM   po_lines_draft_all PLD
      WHERE  PLD.draft_id = p_draft_info.draft_id
      AND    NVL(PLD.delete_flag, 'N') = 'N'
      AND    NVL(PLD.change_accepted_flag, 'Y') = 'Y'
      AND NOT EXISTS
        ( SELECT NULL
          FROM   po_lines_all PL
          WHERE PLD.po_line_id = PL.po_line_id));

  IF (l_has_new_records = FND_API.G_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'new reocrds at line - approval change');
    END IF;

    x_change_status := TRUE;
    RETURN;
  END IF;

  -- Combining blanekt and standard PO approval status checking
  -- together. Any changes to the attributes listed in the SQL will
  -- trigger approval status change

  --SQL What: Compare attributes of the transaction and draft record. Return 'Y'
  --          if any of the attributes is different
  --SQL Why: Need to figure out if the change triggers a change to approval
  --         status
  SELECT MAX(FND_API.G_TRUE)
  INTO l_different
  FROM dual
  WHERE EXISTS
    ( SELECT NULL
      FROM   po_lines_draft_all PLD,
             po_lines_all PL
      WHERE PLD.draft_id = p_draft_info.draft_id
      AND   NVL(PLD.delete_flag, 'N') = 'N'
      AND   NVL(PLD.change_accepted_flag, 'Y') = 'Y'
      AND   PLD.po_line_id = PL.po_line_id
      AND
       (   DECODE (PLD.unit_price, PL.unit_price, 'Y', 'N') = 'N'
        OR DECODE (PLD.line_num, PL.line_num, 'Y', 'N') = 'N'
        OR DECODE (PLD.item_id, PL.item_id, 'Y', 'N') = 'N'
        OR DECODE (PLD.item_description, PL.item_description, 'Y', 'N') = 'N'
        OR DECODE (PLD.quantity, PL.quantity, 'Y', 'N') = 'N'
        OR DECODE (PLD.unit_meas_lookup_code, PL.unit_meas_lookup_code, 'Y', 'N') = 'N'
        OR DECODE (PLD.from_header_id, PL.from_header_id, 'Y', 'N') = 'N'
        OR DECODE (PLD.from_line_id, PL.from_line_id, 'Y', 'N') = 'N'
        OR DECODE (PLD.hazard_class_id, PL.hazard_class_id, 'Y', 'N') = 'N'
        OR DECODE (PLD.vendor_product_num, PL.vendor_product_num, 'Y', 'N') = 'N'
        OR DECODE (PLD.un_number_id, PL.un_number_id, 'Y', 'N') = 'N'
        OR DECODE (PLD.note_to_vendor, PL.note_to_vendor, 'Y', 'N') = 'N'
        OR DECODE (PLD.item_revision, PL.item_revision, 'Y', 'N') = 'N'
        OR DECODE (PLD.category_id, PL.category_id, 'Y', 'N') = 'N'
        OR DECODE (PLD.price_type_lookup_code, PL.price_type_lookup_code, 'Y', 'N') = 'N'
        OR DECODE (PLD.not_to_exceed_price, PL.not_to_exceed_price, 'Y', 'N') = 'N'
        OR DECODE (PLD.contract_id, PL.contract_id, 'Y', 'N') = 'N'
        OR DECODE (PLD.start_date, PL.start_date, 'Y', 'N') = 'N'
        OR DECODE (PLD.expiration_date, PL.expiration_date, 'Y', 'N') = 'N'
        OR DECODE (PLD.contractor_first_name, PL.contractor_first_name, 'Y', 'N') = 'N'
        OR DECODE (PLD.contractor_last_name, PL.contractor_last_name, 'Y', 'N') = 'N'
        OR DECODE (PLD.amount, PL.amount, 'Y', 'N') = 'N'
        OR DECODE (PLD.quantity_committed, PL.quantity_committed, 'Y', 'N') = 'N'
        OR DECODE (PLD.committed_amount, PL.committed_amount, 'Y', 'N') = 'N'
        -- <Complex Work R12 START>
        OR DECODE (PLD.retainage_rate, PL.retainage_rate, 'Y', 'N') = 'N'
        OR DECODE (PLD.max_retainage_amount, PL.max_retainage_amount, 'Y', 'N') = 'N'
        OR DECODE (PLD.progress_payment_rate, PL.progress_payment_rate, 'Y', 'N') = 'N'
        OR DECODE (PLD.recoupment_rate, PL.recoupment_rate, 'Y', 'N') = 'N'
        -- <Complex Work R12 END>
       )
    );

  d_position := 20;
  IF (l_different = FND_API.G_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Line causes approval change');
    END IF;

    x_change_status := TRUE;
  END IF;

  d_position := 30;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END val_auth_status_line;


-----------------------------------------------------------------------
--Start of Comments
--Name: val_auth_status_line_loc
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Checks whether there are any changes at the line location level that trigger
--  approval status to be updated. This procedure also determines what
--  shipments should have their status updated
--Parameters:
--IN:
--p_draft_info
--  Record structure holding draft information
--IN OUT:
--x_change_status
--  This procedure sets this parameter to TRUE if status needs to be
--  changed
--OUT:
--x_changed_line_loc_list
--  List of line locations that should have their status updated
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE val_auth_status_line_loc
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN,
  x_changed_line_loc_list OUT NOCOPY PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'val_auth_status_line_loc';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_has_new_records VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.line_locations_changed = FND_API.G_FALSE) THEN
    RETURN;
  END IF;

  d_position := 10;
  -- Change auth status if there is a new line
  SELECT MAX(FND_API.G_TRUE)
  INTO l_has_new_records
  FROM dual
  WHERE EXISTS
    ( SELECT NULL
      FROM   po_line_locations_draft_all PLLD
      WHERE  PLLD.draft_id = p_draft_info.draft_id
      AND   NVL(PLLD.delete_flag, 'N') = 'N'
      AND   NVL(PLLD.change_accepted_flag, 'Y') = 'Y'
      AND NOT EXISTS
        ( SELECT NULL
          FROM   po_line_locations_all PLL
          WHERE PLLD.line_location_id = PLL.line_location_id));

  IF (l_has_new_records = FND_API.G_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'New shipments - approval change');
    END IF;

    x_change_status := TRUE;
  END IF;

  SELECT PLLD.line_location_id
  BULK COLLECT
  INTO x_changed_line_loc_list
  FROM   po_line_locations_draft_all PLLD,
         po_line_locations_all PLL
  WHERE PLLD.draft_id = p_draft_info.draft_id
  AND   NVL(PLLD.delete_flag, 'N') = 'N'
  AND   NVL(PLLD.change_accepted_flag, 'Y') = 'Y'
  AND   PLLD.line_location_id = PLL.line_location_id
  AND
   (   DECODE (PLLD.quantity, PLL.quantity, 'Y', 'N') = 'N'
    OR DECODE (PLLD.ship_to_location_id, PLL.ship_to_location_id, 'Y', 'N') = 'N'
    OR DECODE (PLLD.promised_date, PLL.promised_date, 'Y', 'N') = 'N'
    OR DECODE (PLLD.need_by_date, PLL.need_by_date, 'Y', 'N') = 'N'
    OR DECODE (PLLD.shipment_num, PLL.shipment_num, 'Y', 'N') = 'N'
    OR DECODE (PLLD.start_date, PLL.start_date, 'Y', 'N') = 'N'
    OR DECODE (PLLD.end_date, PLL.end_date, 'Y', 'N') = 'N'
    OR DECODE (PLLD.days_early_receipt_allowed, PLL.days_early_receipt_allowed, 'Y', 'N') = 'N'
    OR DECODE (PLLD.last_accept_date, PLL.last_accept_date, 'Y', 'N') = 'N'
    OR DECODE (PLLD.price_discount, PLL.price_discount, 'Y', 'N') = 'N'
    OR DECODE (PLLD.price_override, PLL.price_override, 'Y', 'N') = 'N'
    OR DECODE (PLLD.ship_to_organization_id, PLL.ship_to_organization_id, 'Y', 'N') = 'N'
    OR DECODE (PLLD.tax_code_id, PLL.tax_code_id, 'Y', 'N') = 'N'
    -- <Complex Work R12 START>
    OR DECODE (PLLD.amount, PLL.amount, 'Y', 'N') = 'N'
    OR DECODE (PLLD.payment_type, PLL.payment_type, 'Y', 'N') = 'N'
    OR DECODE (PLLD.description, PLL.description, 'Y', 'N') = 'N'
    OR DECODE (PLLD.work_approver_id, PLL.work_approver_id, 'Y', 'N') = 'N'
    -- <Complex Work R12 END>
   );

  d_position := 20;
  IF (x_changed_line_loc_list.COUNT > 0) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Shipment causes approval change');
    END IF;

    x_change_status := TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END val_auth_status_line_loc;

-----------------------------------------------------------------------
--Start of Comments
--Name: val_auth_status_dist
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Checks whether there are any changes at the distribution level that trigger
--  approval status to be updated. This procedure also determines what
--  shipments should have their status updated
--Parameters:
--IN:
--p_draft_info
--  Record structure holding draft information
--IN OUT:
--x_change_status
--  This procedure sets this parameter to TRUE if status needs to be
--  changed
--OUT:
--x_changed_line_loc_list
--  List of line locations that should have their status updated
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE val_auth_status_dist
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN,
  x_changed_line_loc_list OUT NOCOPY PO_TBL_NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'val_auth_status_dist';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_has_new_records VARCHAR2(1);

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.distributions_changed = FND_API.G_FALSE) THEN
    RETURN;
  END IF;

  d_position := 10;
  -- Change auth status if there is a new line
  SELECT MAX(FND_API.G_TRUE)
  INTO l_has_new_records
  FROM dual
  WHERE EXISTS
    ( SELECT NULL
      FROM   po_distributions_draft_all PDD
      WHERE  PDD.draft_id = p_draft_info.draft_id
      AND   NVL(PDD.delete_flag, 'N') = 'N'
      AND   NVL(PDD.change_accepted_flag, 'Y') = 'Y'
      AND NOT EXISTS
        ( SELECT NULL
          FROM   po_distributions_all PD
          WHERE PDD.po_distribution_id = PD.po_distribution_id));

  IF (l_has_new_records = FND_API.G_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'New distribution: approval change');
    END IF;

    x_change_status := TRUE;
  END IF;

  d_position := 20;
  -- We need to use DISTINCT here because one shipment can have multiple
  -- distribution changes, and we only need one line location id in this case
  SELECT DISTINCT PDD.line_location_id
  BULK COLLECT
  INTO x_changed_line_loc_list
  FROM   po_distributions_draft_all PDD,
         po_distributions_all PD
  WHERE PDD.draft_id = p_draft_info.draft_id
  AND   NVL(PDD.delete_flag, 'N') = 'N'
  AND   NVL(PDD.change_accepted_flag, 'Y') = 'Y'
  AND   PDD.po_distribution_id = PD.po_distribution_id
  AND
   (   DECODE (PDD.quantity_ordered, PD.quantity_ordered, 'Y', 'N') = 'N'
    OR DECODE (PDD.amount_ordered, PD.amount_ordered, 'Y', 'N') = 'N'
    OR DECODE (PDD.deliver_to_person_id, PD.deliver_to_person_id, 'Y', 'N') = 'N'
    OR DECODE (PDD.rate_date, PD.rate_date, 'Y', 'N') = 'N'
    OR DECODE (PDD.rate, PD.rate, 'Y', 'N') = 'N'
    OR DECODE (PDD.gl_encumbered_date, PD.gl_encumbered_date, 'Y', 'N') = 'N'
    OR DECODE (PDD.recovery_rate, PD.recovery_rate, 'Y', 'N') = 'N'
    OR DECODE (PDD.destination_subinventory, PD.destination_subinventory, 'Y', 'N') = 'N'
    OR DECODE (PDD.code_combination_id, PD.code_combination_id, 'Y', 'N') = 'N'
    OR DECODE (PDD.dest_charge_account_id, PD.dest_charge_account_id, 'Y', 'N') = 'N'
    OR DECODE (PDD.distribution_num, PD.distribution_num, 'Y', 'N') = 'N'
   );

  d_position := 30;
  IF (x_changed_line_loc_list.COUNT > 0) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,
                  'Distribution changes cause approval change');
    END IF;

    x_change_status := TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END val_auth_status_dist;

-----------------------------------------------------------------------
--Start of Comments
--Name: val_auth_status_org_assign
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Checks whether there are any changes at org assignment level that trigger
--  approval status to be updated.
--Parameters:
--IN:
--p_draft_info
--  Record structure holding draft information
--IN OUT:
--x_change_status
--  This procedure sets this parameter to TRUE if status needs to be
--  changed
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE val_auth_status_org_assign
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
) IS

d_api_name CONSTANT VARCHAR2(30) := 'val_auth_status_org_assign';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.ga_org_assign_changed = FND_API.G_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position, 'Org assign change - approval changes');
    END IF;

    x_change_status := TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END val_auth_status_org_assign;

-----------------------------------------------------------------------
--Start of Comments
--Name: val_auth_status_price_diff
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Checks whether there are any changes at price differential level that
--  trigger approval status to be updated.
--Parameters:
--IN:
--p_draft_info
--  Record structure holding draft information
--IN OUT:
--x_change_status
--  This procedure sets this parameter to TRUE if status needs to be
--  changed
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE val_auth_status_price_diff
( p_draft_info IN PO_DRAFTS_PVT.DRAFT_INFO_REC_TYPE,
  x_change_status IN OUT NOCOPY BOOLEAN
) IS

d_api_name CONSTANT VARCHAR2(30) := 'val_auth_status_price_diff';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  IF (p_draft_info.price_diff_changed = FND_API.G_TRUE) THEN
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_position,
                  'price diff changes cause approval change');
    END IF;

    x_change_status := TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END val_auth_status_price_diff;

END PO_DRAFT_APPR_STATUS_PVT;

/
