--------------------------------------------------------
--  DDL for Package Body PO_CHANGE_RESPONSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHANGE_RESPONSE_PVT" AS
/* $Header: POXCHREB.pls 120.9.12010000.6 2014/05/01 12:55:10 pneralla ship $*/

/*Initializing Private Procedures-Functions
 */

/**
* Private Procedure: CreateSingleDistributionRecords
* Effects: Creates a distribution record in PO_CHANGE_REQUESTS for each
*   shipment change where the shipment has a single distribution.
*   Note: Normally, distribution records are created by the
*   "Respond to Changes" page. However, for the single distribution case,
*   we allow users to respond through a notification, so we need to create
*   the distribution records here.
* Modifies: Creates distribution records in PO_CHANGE_REQUESTS for any
*   changes to shipments with one distribution.
**/

PROCEDURE CreateSingleDistribution (
  p_change_request_group_id IN NUMBER
) IS

  CURSOR single_dist_shipments_csr IS
    SELECT change_request_id
    FROM po_change_requests PCR
    WHERE request_status = 'BUYER_APP'
    AND change_request_group_id = p_change_request_group_id
    AND request_level = 'SHIPMENT'
    AND initiator = 'SUPPLIER'
    AND 1 = (SELECT count(*)
             FROM po_distributions POD
             WHERE POD.line_location_id =
             NVL(PCR.document_line_location_id, PCR.parent_line_location_id));

       -- there is only one distribution for this shipment

   l_change_request_id NUMBER;

BEGIN

  OPEN single_dist_shipments_csr;
  LOOP
    FETCH single_dist_shipments_csr INTO l_change_request_id;
    EXIT WHEN single_dist_shipments_csr%NOTFOUND;

    -- Create a distribution CR record by copying most of the fields from
    -- the shipment record.
    INSERT INTO po_change_requests
      ( Change_Request_Group_Id, Change_Request_Id, Initiator, Action_Type, Request_Reason,
      Document_Type, Request_Level,
      Request_Status, Document_Header_Id, Document_Num, Document_Revision_Num, Created_By, Creation_Date,
      Last_Updated_By, Last_Update_Date, Last_Update_Login, Vendor_Id, Vendor_Site_Id, Vendor_Contact_Id,
      Request_Expiration_Date, PO_Release_Id, Document_Line_Id, Document_Line_Number, Document_Line_Location_Id,
      Document_Shipment_Number, Parent_Line_Location_Id, Document_distribution_id, Document_distribution_Number,
      Old_Quantity, New_Quantity, Old_Promised_Date, New_Promised_Date,
      Old_Supplier_Part_Number, New_Supplier_Part_Number, Old_Price, New_Price,
      Old_Need_By_Date, New_Need_By_Date,
      Old_Supplier_Reference_Number, New_Supplier_Reference_Number,
      Requester_Id, Responded_by, Response_date, Response_Reason,
      Old_Currency_Unit_Price, New_Currency_Unit_Price,
      Recoverable_Tax, Nonrecoverable_Tax,
      WF_Item_type, WF_Item_key, Parent_Change_Request_Id, Validation_Error,
      Approval_Required_Flag, Old_Supplier_Order_Number, New_Supplier_Order_Number,
      Old_Supplier_Order_Line_Number, New_Supplier_Order_Line_Number,Old_Amount,New_Amount)  -- Added Amount for FPS Changes
    SELECT
      PCR.Change_Request_Group_Id,
      PO_CHG_REQUEST_SEQ.nextval, -- CHANGE_REQUEST_ID
      PCR.Initiator, PCR.Action_Type, PCR.Request_Reason,
      PCR.Document_Type,
      'DISTRIBUTION', -- REQUEST_LEVEL
      PCR.Request_Status, PCR.Document_Header_Id, PCR.Document_Num,
      PCR.Document_Revision_Num, PCR.Created_By, PCR.Creation_Date,
      PCR.Last_Updated_By, PCR.Last_Update_Date, PCR.Last_Update_Login,
      PCR.Vendor_Id, PCR.Vendor_Site_Id, PCR.Vendor_Contact_Id,
      PCR.Request_Expiration_Date, PCR.PO_Release_Id, PCR.Document_Line_Id,
      PCR.Document_Line_Number, PCR.Document_Line_Location_Id,
      PCR.Document_Shipment_Number, PCR.Parent_Line_Location_Id,
      Decode(PCR.Parent_Line_Location_Id, null, POD.po_distribution_id, null),
      POD.distribution_num,
      PCR.Old_Quantity, PCR.New_Quantity, PCR.Old_Promised_Date, PCR.New_Promised_Date,
      PCR.Old_Supplier_Part_Number, PCR.New_Supplier_Part_Number,
      PCR.Old_Price, PCR.New_Price,
      PCR.Old_Need_By_Date, PCR.New_Need_By_Date,
      PCR.Old_Supplier_Reference_Number, PCR.New_Supplier_Reference_Number,
      PCR.Requester_Id, PCR.Responded_by, PCR.Response_date, PCR.Response_Reason,
      PCR.Old_Currency_Unit_Price, PCR.New_Currency_Unit_Price,
      PCR.Recoverable_Tax, PCR.Nonrecoverable_Tax,
      PCR.WF_Item_type, PCR.WF_Item_key, PCR.Parent_Change_Request_Id,
      PCR.Validation_Error, PCR.Approval_Required_Flag,
      PCR.Old_Supplier_Order_Number, PCR.New_Supplier_Order_Number,
      PCR.Old_Supplier_Order_Line_Number, PCR.New_Supplier_Order_Line_Number,PCR.Old_Amount,PCR.New_Amount
    FROM po_change_requests PCR, po_distributions_all POD
    WHERE PCR.change_request_id = l_change_request_id
    AND POD.line_location_id =
        NVL(PCR.document_line_location_id, PCR.parent_line_location_id);

  END LOOP;
  CLOSE single_dist_shipments_csr;

END CreateSingleDistribution;


/**  CheckPartialAck
*    ----------------
*    Purpose:
*    This procedure is used to determine whether the PO is in partial ack state.
*    The PO is said to be NOT in partial ack state
*    when either the PO does not require acknowledgement or all the shipments have been either acked or changed
*    Usage:
*    This procedure is called in following scenarios -
*    1. To determine that the supplier is acting on the PO and the buyer cannot currently act on it
*    Return Value:
*    This procedure returns p_partial_ack which has a value of 'Y' if the PO is in a partial ack state
*    and 'N' if the PO is not in a partial ack state
*/

PROCEDURE CheckPartialAck (p_api_version in number,
                           x_return_status out NOCOPY varchar2,
                           p_po_header_id in number,
	         	           p_po_release_id in number,
                           p_change_request_group_id in number,
                           x_partial_ack out NOCOPY varchar2) is

l_acceptance_required VARCHAR2(1);
l_authorization_status VARCHAR2(20);
l_change_requested_by VARCHAR2(20);
l_revision_num NUMBER;
l_change_shipment_count NUMBER;
l_acc_shipment_count NUMBER;
l_total_shipment_count NUMBER;
l_all_ack VARCHAR2(1);

BEGIN

-- determine if the PO needs acknowledgement, is 'in process' and the change_requested_by is 'SUPPLIER'

if (p_po_release_id is null) then

  select acceptance_required_flag,
  authorization_status,
  change_requested_by,
  revision_num
  into l_acceptance_required,
  l_authorization_status,
  l_change_requested_by,
  l_revision_num
  from po_headers_all
  where po_header_id = p_po_header_id;

else

  select acceptance_required_flag,
  authorization_status,
  change_requested_by,
  revision_num
  into l_acceptance_required,
  l_authorization_status,
  l_change_requested_by,
  l_revision_num
  from po_releases_all
  where po_release_id = p_po_release_id;

end if;

if ((l_acceptance_required = 'Y') AND (l_authorization_status = 'IN PROCESS')
     AND (l_change_requested_by = 'SUPPLIER')) then

--bug 4107241
--buyer should not be able to ack PO's which are partially acknowledged
--this code block replaces commented code

   l_all_ack := PO_ACKNOWLEDGE_PO_PVT.All_Shipments_Responded(1.0, FND_API.G_FALSE,
	p_po_header_id,p_po_release_id,l_revision_num );

   if(l_all_ack = FND_API.G_TRUE) then
   	x_partial_ack := 'N';
   else
   	x_partial_ack := 'Y';
   end if;

/*

    -- select count of shipments of the latest revision from po_acceptances which have been acked

   if (p_po_release_id is null) then

    select count(*) into l_acc_shipment_count
    from po_acceptances
    where po_header_id = p_po_header_id
    and po_line_location_id is not null
    and revision_num = l_revision_num
    and po_release_id is null;

   else

    select count(*) into l_acc_shipment_count
    from po_acceptances
    where po_release_id = p_po_release_id
    and po_line_location_id is not null
    and revision_num = l_revision_num;

   end if;

  -- select count of non-split shipments with same change request group id

  if (p_po_release_id is null) then

    select count(*) into l_change_shipment_count
    from  po_change_requests
    where document_header_id = p_po_header_id
    and po_release_id is null
    and change_request_group_id = p_change_request_group_id
    and request_level = 'SHIPMENT'
    and parent_line_location_id is null;

  else

    select count(*) into l_change_shipment_count
    from  po_change_requests
    where po_release_id = p_po_release_id
    and change_request_group_id = p_change_request_group_id
    and request_level = 'SHIPMENT'
    and parent_line_location_id is null;

  end if;

    -- select total count of shipments to be acknowledged i.e.
    -- all shipments which have not been cancelled or closed

   if (p_po_release_id is null) then

    select count(*) into l_total_shipment_count
    from po_line_locations_all
    where po_header_id = p_po_header_id
    and po_release_id is null
    and nvl(cancel_flag, 'N')  <> 'Y'
    and nvl(closed_code, 'OPEN') = 'OPEN'
    and nvl(payment_type,'NULL')<>'ADVANCE'; --Bug 5132565

   else

    select count(*) into l_total_shipment_count
    from po_line_locations_all
    where po_header_id = p_po_header_id
    and po_release_id = p_po_release_id
    and nvl(cancel_flag, 'N')  <> 'Y'
    and nvl(closed_code, 'OPEN') = 'OPEN'
    and nvl(payment_type,'NULL')<>'ADVANCE'; --Bug 5132565


   end if;

    --  now compare quantities to determine whether all required shipments have been acked or changed

    if ((l_acc_shipment_count + l_change_shipment_count) < (l_total_shipment_count )) then
          x_partial_ack := 'Y';
    else
          x_partial_ack := 'N';
    end if;

*/

else         /* either PO does not require acceptance or supplier is not acting on the PO */

    x_partial_ack := 'N';

end if;

EXCEPTION WHEN OTHERS THEN

   x_partial_ack := 'N';

END  CheckPartialAck;



/**  CheckChangePending
*    -------------------
*    Purpose:
*    This procedure is used to determine if there are any supplier initiated changes in pending status
*    Usage:
*    This procedure is called in following scenarios -
*    1. To determine if there is a pending change request from the supplier on a PO and
*       if so activate the Repsonse button for that PO on the PO summary form
*    2. To determine after the buyer responds whether there are any more changes in pending status
*       to which the buyer needs to respond before we call the PO validation and update procedures
*    Return Value:
*    This procedure returns p_change_pending with value 'Y' if there are some changes in pending state and
*    with value 'N' if there are no changes in pending state
*/

PROCEDURE CheckChangePending  (p_api_version in number,
                               x_return_status out NOCOPY varchar2,
                               p_po_header_id in number,
                               p_po_release_id in number,
                               x_change_pending out NOCOPY varchar2) is

   l_pending_count NUMBER;
   l_revision_num NUMBER;

BEGIN

   select revision_num
   into l_revision_num
   from po_headers_all
   where po_header_id = p_po_header_id;

   select count(*) into l_pending_count
   from po_change_requests
   where document_header_id = p_po_header_id
   and document_revision_num = l_revision_num
   and request_status = 'PENDING';

   if  (l_pending_count > 0) then
        x_change_pending := 'Y';
   else
        x_change_pending := 'N';
   end if;
EXCEPTION
   WHEN OTHERS THEN
     x_change_pending := 'N';
End CheckChangePending;


/** get_distribution_count
 */

FUNCTION get_distribution_count(p_request_level IN VARCHAR,
                                p_document_line_location_Id IN NUMBER,
                                p_parent_line_location_id IN NUMBER) RETURN NUMBER is
 l_distribution_count NUMBER;

BEGIN
   l_distribution_count := 0;

   if (p_request_level = 'SHIPMENT') then

      if ((p_parent_line_location_id is null) OR (p_parent_line_location_id = 0)) then

          select count(*) into l_distribution_count
          from po_distributions_all where line_location_id = p_document_line_location_id;

        else  /* line is a split shipment */

          select count(*) into l_distribution_count
          from po_distributions_all where line_location_id = p_parent_line_location_id;

        end if; /* split shipment test */

   end if;

   return l_distribution_count;

EXCEPTION WHEN OTHERS THEN

   return l_distribution_count;

END get_distribution_count;



/**  MoveChangeToPO
*    ---------------
*    Purpose:
*    This procedure is used to perform validation of changes requested to PO and perform updates on the PO
*    Usage:
*    This procedure is called in the following scenario:
*    1. When the buyer completes responding to all the requested changes, this procedure is
*       called by ProcessResponse procedure
*    Return Value:
*    This procedure returns return_code which has a value
*     0 if the validation was completely successful,
*     1 if the validation failed for some or all changes
*     2 if there was an unexpected error
*/

PROCEDURE MoveChangeToPO (p_api_version in number,
                          x_return_status out NOCOPY varchar2,
                          p_po_header_id  in  number,
                          p_po_release_id in number,
                          p_change_request_group_id in number,
                          p_user_id  in number,
                          x_return_code out NOCOPY NUMBER,
                          x_err_msg out NOCOPY VARCHAR2,
                          x_doc_check_rec_type out NOCOPY POS_ERR_TYPE,
                          p_launch_approvals_flag IN VARCHAR2,
                          p_mass_update_releases   IN VARCHAR2 DEFAULT NULL, -- Bug 3373453
                          p_req_chg_initiator IN VARCHAR2 DEFAULT NULL --Bug 14549341
                         ) is

CURSOR changed_lines_cursor IS
      SELECT document_line_id, new_price, new_supplier_part_number,
      new_start_date, new_expiration_date, new_amount
      FROM po_change_requests
      where request_status = 'BUYER_APP'
      AND document_header_id = p_po_header_id
      AND change_request_group_id = p_change_request_group_id
      AND request_level = 'LINE';

    CURSOR changed_shipments_cursor IS
      SELECT document_line_location_id,
      new_quantity, new_promised_date, new_need_by_date, new_price,
      parent_line_location_id,
      Decode(parent_line_location_id, null, null, document_shipment_number),
      new_amount,
      new_progress_type,  --    << Complex work changes for R12 >>
      new_pay_description,
      new_supplier_order_line_number
      FROM po_change_requests
      where request_status = 'BUYER_APP'
      AND document_header_id = p_po_header_id
      AND change_request_group_id = p_change_request_group_id
      AND request_level = 'SHIPMENT';

    CURSOR changed_distributions_cursor IS
      SELECT PCR.document_distribution_id, PCR.new_quantity, Decode(PCR.parent_line_location_id, null, null, PCR.document_shipment_number),
      POD.po_distribution_id parent_distribution_id, PCR.new_amount
      FROM po_change_requests PCR,
           po_distributions POD
      where PCR.request_status = 'BUYER_APP'
      AND PCR.document_header_id = p_po_header_id
      AND PCR.change_request_group_id = p_change_request_group_id
      AND PCR.request_level = 'DISTRIBUTION'
      -- Identify the parent of a split distribution:
      AND POD.line_location_id (+)= PCR.parent_line_location_id
      AND POD.distribution_num (+)= PCR.document_distribution_number
      AND nvl(PCR.new_quantity,-1)<>0
      AND nvl(PCR.new_amount,-1)<>0;

  l_po_line_id_tbl               PO_TBL_NUMBER;
  l_quantity_tbl                 PO_TBL_NUMBER;
  l_price_tbl                    PO_TBL_NUMBER;
  l_amount_tbl                   PO_TBL_NUMBER;
  l_po_line_location_id_tbl      PO_TBL_NUMBER;
  l_parent_line_location_id_tbl  PO_TBL_NUMBER;
  l_promised_date_tbl            PO_TBL_DATE;
  l_need_by_date_tbl             PO_TBL_DATE;
  l_start_date_tbl               PO_TBL_DATE;
  l_expiration_date_tbl          PO_TBL_DATE;
  l_split_shipment_num_tbl       PO_TBL_NUMBER;
  l_po_distribution_id_tbl       PO_TBL_NUMBER;
  l_parent_distribution_id_tbl   PO_TBL_NUMBER;
  l_supplier_part_number_tbl     PO_TBL_VARCHAR30;
  l_err_msg_name_tbl             po_tbl_varchar30;
  l_err_msg_text_tbl             po_tbl_varchar2000;
  l_line_changes                 PO_LINES_REC_TYPE;
  l_shipment_changes             PO_SHIPMENTS_REC_TYPE;
  l_distribution_changes         PO_DISTRIBUTIONS_REC_TYPE;
  l_changes                      PO_CHANGES_REC_TYPE;
 /* << Complex work changes for R12 >>*/
  l_new_progress_type_tbl        PO_TBL_VARCHAR30;
  l_new_pay_description_tbl      PO_TBL_VARCHAR240;
  l_new_supp_order_line_no       PO_TBL_VARCHAR25;


x_pos_errors   POS_ERR_TYPE;
l_api_errors PO_API_ERRORS_REC_TYPE;
l_s_org_id NUMBER;
l_return_status VARCHAR2(30);
l_progress varchar2(3) := '000';
l_launch_approvals_flag VARCHAR2(1);

l_document_type        PO_DOCUMENT_TYPES_ALL_B.document_type_code%TYPE;
l_document_subtype     PO_DOCUMENT_TYPES_ALL_B.document_subtype%TYPE;


BEGIN

l_progress := '001';

x_return_code := 0;   /* 0 implies no error */
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_err_msg := '';
x_doc_check_rec_type := null;

/*
if (p_launch_approvals_flag = 'N') then
  l_launch_approvals_flag := FND_API.G_FALSE;

else
  l_launch_approvals_flag := FND_API.G_TRUE;

end if;
*/


if (p_po_release_id is not null) then

  select org_id, release_type
  into l_s_org_id, l_document_subtype
  from po_releases_all
  where po_release_id = p_po_release_id;

  l_document_type := 'RELEASE';

else

  select org_id, type_lookup_code
  into l_s_org_id, l_document_subtype
  from po_headers_all
  where po_header_id = p_po_header_id;

    IF (l_document_subtype IN ('BLANKET','CONTRACT')) THEN
      l_document_type := 'PA';
    ELSE
      l_document_type := 'PO';
    END IF;


end if;

PO_MOAC_UTILS_PVT.set_org_context(l_s_org_id) ;    -- <R12 MOAC>

l_progress := '002';

-- For shipments with a single distribution create distribution records in PO_CHANGE_REQUESTS

CreateSingleDistribution(p_change_request_group_id);

l_progress := '003';

-- Fetch the line changes from the PO_CHANGE_REQUESTS table and construct the line changes object

OPEN changed_lines_cursor;
FETCH changed_lines_cursor BULK COLLECT INTO
  l_po_line_id_tbl,
  l_price_tbl,
  l_supplier_part_number_tbl,
  l_start_date_tbl,
  l_expiration_date_tbl,
  l_amount_tbl;
CLOSE changed_lines_cursor;

l_progress := '004';

l_line_changes := PO_LINES_REC_TYPE.create_object (
  p_po_line_id         => l_po_line_id_tbl,
  p_unit_price         => l_price_tbl,
  p_vendor_product_num => l_supplier_part_number_tbl,
  p_start_date 	       => l_start_date_tbl,
  p_expiration_date    => l_expiration_date_tbl,
  p_amount             => l_amount_tbl
);

l_progress := '005';

-- Fetch the shipment changes from the PO_CHANGE_REQUESTS table and construct the shipment changes object

OPEN changed_shipments_cursor;
FETCH changed_shipments_cursor BULK COLLECT INTO
  l_po_line_location_id_tbl,
  l_quantity_tbl,
  l_promised_date_tbl,
  l_need_by_date_tbl,
  l_price_tbl,
  l_parent_line_location_id_tbl,
  l_split_shipment_num_tbl,
  l_amount_tbl,
  l_new_progress_type_tbl,
  l_new_pay_description_tbl, --<< Complex work changes for R12 >>
  l_new_supp_order_line_no;

CLOSE changed_shipments_cursor;

l_progress := '006';

l_shipment_changes := PO_SHIPMENTS_REC_TYPE.create_object (
  p_po_line_location_id     => l_po_line_location_id_tbl,
  p_quantity                => l_quantity_tbl,
  p_promised_date           => l_promised_date_tbl,
  p_price_override          => l_price_tbl,
  p_parent_line_location_id => l_parent_line_location_id_tbl,
  p_split_shipment_num      => l_split_shipment_num_tbl,
  p_need_by_date            => l_need_by_date_tbl,
  p_amount                  => l_amount_tbl,
  p_payment_type            => l_new_progress_type_tbl, -- << Complex work changes for R12 >>
  p_description             => l_new_pay_description_tbl,
  p_new_supp_order_line_no  => l_new_supp_order_line_no
);

l_progress := '007';

-- Fetch the distribution changes from the PO_CHANGE_REQUESTS table and
-- construct the distribution changes object

OPEN changed_distributions_cursor;
FETCH changed_distributions_cursor BULK COLLECT INTO
  l_po_distribution_id_tbl,
  l_quantity_tbl,
  l_split_shipment_num_tbl,
  l_parent_distribution_id_tbl,
  l_amount_tbl;
CLOSE changed_distributions_cursor;

l_progress := '008';

l_distribution_changes := PO_DISTRIBUTIONS_REC_TYPE.create_object (
  p_po_distribution_id     => l_po_distribution_id_tbl,
  p_quantity_ordered       => l_quantity_tbl,
  p_parent_distribution_id => l_parent_distribution_id_tbl,
  p_split_shipment_num     => l_split_shipment_num_tbl,
  p_amount_ordered         => l_amount_tbl
);

l_progress := '009';

-- Construct the document-level changes object.
l_changes := PO_CHANGES_REC_TYPE.create_object (
  p_po_header_id         => p_po_header_id,
  p_po_release_id        => p_po_release_id,
  p_line_changes         => l_line_changes,
  p_shipment_changes     => l_shipment_changes,
  p_distribution_changes => l_distribution_changes
);

l_progress := '010';

-- The document is currently in 'IN PROCESS' status. Set it to 'APPROVED'
-- status to allow the PO Change API to process it

IF (p_po_release_id IS NULL) THEN -- PO, PA
  UPDATE po_headers_all
  SET authorization_status = 'APPROVED'
  WHERE po_header_id = p_po_header_id;
ELSE -- Release
  UPDATE po_releases_all
  SET authorization_status = 'APPROVED'
  WHERE po_release_id = p_po_release_id;
END IF;

l_progress := '011';

-- Call the PO Change API to apply these changes to the document
PO_DOCUMENT_UPDATE_GRP.update_document (
  p_api_version     	  => 1.0,
  p_init_msg_list 	  => FND_API.G_TRUE,
  x_return_status 	  => l_return_status,
  p_changes 		  => l_changes,
  p_run_submission_checks => FND_API.G_TRUE,
  p_launch_approvals_flag => FND_API.G_FALSE,
  p_buyer_id              => NULL,
  p_update_source 	  => NULL,          -- default
  p_override_date  	  => NULL,
  x_api_errors    	  => l_api_errors,
  p_mass_update_releases  => p_mass_update_releases,
  p_req_chg_initiator     => p_req_chg_initiator --Bug 14549341
);

l_progress := '012';

-- Construct a POS_ERR_TYPE object from the errors returned by the PO Change API.
IF ((l_return_status = FND_API.G_RET_STS_ERROR) OR (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)) THEN
  l_err_msg_name_tbl := po_tbl_varchar30();
  l_err_msg_text_tbl := po_tbl_varchar2000();
  x_pos_errors := POS_ERR_TYPE( l_err_msg_name_tbl, l_err_msg_text_tbl);

  FOR i IN 1..l_api_errors.message_name.COUNT LOOP

   if ((nvl(l_api_errors.message_name(i),'NULL') not in
         ('PO_SUB_SHIP_NO_DIST','PO_SUB_REL_SHIP_NO_DIST',
          'PO_SUB_QTY_MISMATCH_DIST','PO_SUB_QTY_MISMATCH_SHIPMENT'))
       AND nvl(l_api_errors.message_type(i), 'E') <> 'W') then

    x_pos_errors.message_name.extend;
    x_pos_errors.message_name(i) := l_api_errors.message_name(i);
    x_pos_errors.text_line.extend;
    x_pos_errors.text_line(i) := l_api_errors.message_text(i);

   end if;

  END LOOP;

  x_doc_check_rec_type := x_pos_errors;

END IF;

l_progress := '013';

IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
  x_return_code := 1;
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_err_msg := l_progress||':'||FND_MSG_PUB.get(FND_MSG_PUB.G_LAST,'F');
  return;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
  raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF; -- l_return_status

l_progress := '014';

-- update_document generates a new PO_LINE_LOCATION_ID for each of the
-- split shipments. Update the PO_CHANGE_REQUESTS table with these IDs

--FOR i IN shipment changes LOOP
FOR i IN 1..l_changes.shipment_changes.PO_LINE_LOCATION_ID.COUNT LOOP
  IF (l_changes.shipment_changes.parent_line_location_id(i) IS NOT NULL) THEN
    UPDATE po_change_requests
    SET document_line_location_id =
      l_changes.shipment_changes.po_line_location_id(i)
    WHERE parent_line_location_id =
      l_changes.shipment_changes.parent_line_location_id(i)
    AND document_shipment_number =
      l_changes.shipment_changes.split_shipment_num(i)
    AND change_request_group_id = p_change_request_group_id;
  END IF;
END LOOP;

   l_progress := '015';
   x_err_msg := x_err_msg || 'SUCCESS : l_progress = ' || l_progress;


if (p_launch_approvals_flag = 'Y') then

  PO_DOCUMENT_UPDATE_GRP.launch_po_approval_wf (
	p_api_version			=> 1.0,
	p_init_msg_list			=> FND_API.G_TRUE,
	x_return_status			=> l_return_status,
	p_document_id			=> NVL(p_po_release_id, p_po_header_id),
	p_document_type         	=> l_document_type,
	p_document_subtype		=> l_document_subtype,
	p_preparer_id           	=> NULL,
	p_approval_background_flag 	=> NULL,
	p_mass_update_releases		=> p_mass_update_releases );

end if;


IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
  x_return_code := 1;
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_err_msg := l_progress||':'||FND_MSG_PUB.get(FND_MSG_PUB.G_LAST,'F');
  return;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
  raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF; -- l_return_status

l_progress := '016';

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

   x_return_code := 2;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_err_msg := l_progress||':'||FND_MSG_PUB.get(FND_MSG_PUB.G_LAST,'F');

  WHEN OTHERS THEN

   x_return_code := 2;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_err_msg := l_progress||':' || ':' || sqlcode ||':'||sqlerrm(sqlcode);

END MoveChangeToPO;



/** update_change_response
*   -----------------------
*   Purpose:
*   This procedure is used to Update Request Statuses in Change_Table when Buyer Submits his Response
*   from Response Page
*   Usage:
*   This is called from PosChangeResponseVO updateResponse procedure in a loop for all accepted/rejected changes
*   Return Value:
*   This procedure does not have a return value
*/

PROCEDURE update_change_response (p_request_status in VARCHAR2,
                                  p_responded_by in NUMBER,
                                  p_response_reason in VARCHAR2,
                                  p_change_request_id in NUMBER,
                                  p_request_level in VARCHAR2,
                                  p_change_request_group_id in NUMBER,
                                  p_line_location_id in NUMBER,
                                  p_splitFlag in VARCHAR2,
                                  p_cancel_backing_req in VARCHAR2)  is

   l_wf_item_key    po_change_requests.wf_item_key%TYPE;
   l_wf_item_type   po_change_requests.wf_item_type%TYPE;

BEGIN

  -- first update the line or shipment record in po_change_requests

 if (p_request_status = 'REJECTED') then

  update po_change_requests
  set request_status = p_request_status,
  -- change_active_flag = 'N',  /* commented out due to bug 3574114 */
  responded_by = p_responded_by,
  response_date = sysdate,
  last_updated_by = p_responded_by,
  last_update_date = sysdate,
  response_reason = p_response_reason
  where change_request_id = p_change_request_id;

 else

  update po_change_requests
  set request_status = p_request_status,
  cancel_backing_req = p_cancel_backing_req,
  responded_by = p_responded_by,
  response_date = sysdate,
  last_updated_by = p_responded_by,
  last_update_date = sysdate,
  response_reason = p_response_reason
  where change_request_id = p_change_request_id;

 end if;


  begin

      select wf_item_type, wf_item_key
      into l_wf_item_type, l_wf_item_key
      from po_change_requests
      where change_request_id = p_change_request_id;

      if (Wf_Item.Item_Exist(l_wf_item_type, l_wf_item_key)) then

           wf_engine.abortprocess(l_wf_item_type, l_wf_item_key);

      end if;

  exception when others then
       null;
  end;

  -- then perform the following step to update distribution records in Change Request table
  -- if the the request_level for original record is 'SHIPMENT'

  if (p_request_level = 'SHIPMENT') then

     -- update the corresponding distribution records
     if (p_splitFlag = 'N') then

         update po_change_requests
         set request_status = p_request_status,
         responded_by = p_responded_by,
         response_date = sysdate,
         last_updated_by = p_responded_by,
         last_update_date = sysdate,
         response_reason = p_response_reason
         where change_request_group_id = p_change_request_group_id and
         request_level = 'DISTRIBUTION' and
         request_status = 'PENDING' and
         document_line_location_id = p_line_location_id;


       -- also update approved_flag of corresponding shipment if change request is rejected

       if (p_request_status = 'REJECTED') then

         update po_line_locations_all
         set approved_flag = 'Y'
         where line_location_id = p_line_location_id;

       end if;

     else    /* p_splitFlag is not 'N' */

         update po_change_requests
         set request_status = p_request_status,
         responded_by = p_responded_by,
         response_date = sysdate,
         last_updated_by = p_responded_by,
         last_update_date = sysdate,
         response_reason = p_response_reason
         where change_request_group_id = p_change_request_group_id and
         request_level = 'DISTRIBUTION' and
         request_status = 'PENDING' and
         parent_line_location_id = p_line_location_id;

     end if;   /* splitFlag */

   end if; 	/* request-level is 'SHIPMENT' */

END update_change_response;


/*  roll_back_acceptance is used to roll back buyer acceptance responses
 *  in po_change_requests to 'PENDING' when a validation error is
 *  encountered during PO update validation and we decide to roll back the transaction
 */

PROCEDURE roll_back_acceptance (p_change_request_group_id in NUMBER) is

BEGIN

 update po_change_requests
 set request_status = 'PENDING'
 where change_request_group_id = p_change_request_group_id
 and request_status in ('BUYER_APP', 'WAIT_MGR_APP');

exception when others then

  null;

END;

/*
BUG:17202260.
Below function checks if PO has backing requistions or not.
Bug: 18202450
Modified below procedure to get the required attributes for cancel backing req field in buyer response to PO cancellation request page
*/

PROCEDURE  check_backinreq_flag(p_po_header_id IN NUMBER,
                           p_po_release_id IN NUMBER,
                           isCancelChkBoxReadonly OUT NOCOPY BOOLEAN,
                           cancelReqVal OUT NOCOPY VARCHAR2,
                           x_ret_stat OUT NOCOPY VARCHAR2 )
IS
 l_req_id NUMBER;
 backingReqSwitch NUMBER := 0;

BEGIN
IF(p_po_release_id IS NOT NULL ) THEN
 SELECT Max(requisition_line_id)
 INTO   l_req_id
 FROM   po_requisition_lines_all
 WHERE  line_location_id IN (SELECT line_location_id
                            FROM   po_line_locations_all
                            WHERE  po_release_id = p_po_release_id
                            );

ELSE
 SELECT Max(requisition_line_id)
 INTO   l_req_id
 FROM   po_requisition_lines_all
 WHERE  line_location_id IN (SELECT line_location_id
                            FROM   po_line_locations_all
                            WHERE  po_header_id = p_po_header_id
                            );

END IF;

IF (l_req_id >0)
THEN

PO_Document_Control_PVT.cancelbackingReq(
 p_po_header_id,NULL,NULL,
 isCancelChkBoxReadonly,
 cancelReqVal,
 x_ret_stat);

 ELSE
 isCancelChkBoxReadonly := TRUE;
 cancelReqVal:='N';

END IF;

EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_ret_stat := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
   x_ret_stat := FND_API.G_RET_STS_UNEXP_ERROR;

END check_backinreq_flag;


END PO_CHANGE_RESPONSE_PVT;


/
