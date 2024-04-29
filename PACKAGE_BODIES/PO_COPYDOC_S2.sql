--------------------------------------------------------
--  DDL for Package Body PO_COPYDOC_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COPYDOC_S2" AS
/* $Header: POXCPO2B.pls 120.3 2006/04/27 15:12:35 bao noship $*/


/****************************************************************
 ****  Nullify some attributes that need to be done so in the PO.
 ****  Set states to some flags.
 ****  Find next available po_header_id and segment1
*****************************************************************/
PROCEDURE validate_header(
  x_action_code             IN      VARCHAR2,
  x_to_doc_subtype	    IN      po_headers.type_lookup_code%TYPE,
  x_to_global_flag	    IN	    PO_HEADERS_ALL.global_agreement_flag%TYPE,	-- FPI GA
  x_po_header_record        IN OUT NOCOPY  PO_HEADERS%ROWTYPE,
  x_to_segment1             IN      po_headers.segment1%TYPE,
  x_agent_id                IN      po_headers.agent_id%TYPE,
  x_sob_id                  IN      financials_system_parameters.set_of_books_id%TYPE,
  x_inv_org_id              IN      financials_system_parameters.inventory_organization_id%TYPE,
  x_online_report_id        IN      po_online_report_text.online_report_id%TYPE,
  x_sequence                IN OUT NOCOPY  po_online_report_text.sequence%TYPE,
  x_return_code             OUT NOCOPY     NUMBER
) IS

  COPYDOC_HEADER_FAILURE  EXCEPTION;
  x_progress              VARCHAR2(4) := NULL;
  x_rowid ROWID;

  tmp_pay_on_code         VARCHAR2(25) := NULL; -- <BUG 4766467>

BEGIN

  po_copydoc_s1.copydoc_debug('validate_header()');

  /***** Unchanged attributes:
  government_context
  org_id
  comments
  attribute_{category,1-15}
  vendor_{id, site_id, contact_id}
  {ship, bill}_to_location_id
  terms_id (Does this need to be unique?)
  ship_via_lookup_code
  fob_lookup_code
  freight_terms_lookup_code
  currency_code
  rate{,_type, _date}
  mrc_rate{, _type, _date}
  price_update_tolerance
  pay_on_code  -- <BUG 4776467> Changed pay_on_code
  {start,end}_date
  note_to_{authorizer,  receiver}
  agent_id
  segment{1-5}
  {start, end}_date_active
  global_attribute{_category, 1-20}
  ******/

  /* FROM_HEADER_ID of a copied document contains the PO_HEADER_ID
     of the original document.  Otherwise it's null.  We only perform
     additional validation if this field is not null.
     do the following two lines first before anything is changed.
  */
     x_po_header_record.from_header_id        := x_po_header_record.po_header_id;
     x_po_header_record.from_type_lookup_code := x_po_header_record.type_lookup_code;

     -- Bug 3202754: Insert null for GA flag value of 'N'
     IF (x_to_global_flag = 'Y') THEN   -- FPI GA
       x_po_header_record.global_agreement_flag := 'Y';
     ELSE
       x_po_header_record.global_agreement_flag := NULL;
     END IF;

    -- <GC FPJ START>
    -- Firm flag is not applicable for contract document type

    IF (x_to_doc_subtype = 'CONTRACT') THEN
      x_po_Header_record.firm_status_lookup_code := 'N';
    END IF;

    -- <GC FPJ END>

    -- <2740069 START>: If copying to a Global Agreement,
    -- 'Firm' flag and 'Supply Agreement' flag should be set to 'N'.
    --
    IF ( x_to_global_flag = 'Y' )
    THEN
        x_po_header_record.firm_status_lookup_code  := 'N';
        x_po_header_record.supply_agreement_flag    := 'N';
    END IF;
    --
    -- <2740069 END>

    -- <ENCUMBRANCE FPJ START>
    IF(x_action_code = 'PO' AND x_to_doc_subtype = 'BLANKET') THEN

       --If we don't want to copy BPA distribution, then reset the
       --encumbrance required flag to 'N', which will prevent the
       --distribution copy

       If (PO_CORE_S.is_encumbrance_on(
              p_doc_type => PO_CORE_S.g_doc_type_PA
           ,  p_org_id => NULL) = FALSE) Then
         --For encumbered BPA, the distribution will be copied only if
         --BPA encumbrance is on.
         x_po_header_record.encumbrance_required_flag := 'N';

       Elsif (x_po_header_record.type_lookup_code <> 'BLANKET') Then
         --Only copy distribution if FROM document is also a BPA
         x_po_header_record.encumbrance_required_flag := 'N';
       End If;

    END IF; --action code is PO, to-doc is BPA
    -- <ENCUMBRANCE FPJ END>

  IF (x_action_code = 'QUOTATION') THEN
     IF (x_po_header_record.quotation_class_code = 'CATALOG') THEN
        x_po_header_record.type_lookup_code := 'BLANKET';

     ELSIF (x_po_header_record.quotation_class_code = 'BID') THEN
        IF (x_to_doc_subtype = 'PLANNED' OR x_to_doc_subtype = 'STANDARD') THEN
           x_po_header_record.type_lookup_code := x_to_doc_subtype;
        ELSE
           -- fnd_message.debug('Invalid to_type for a bid quotation copy: ' || x_to_doc_subtype);
           NULL;
        END IF;
     END IF;

/* Bug 1909325
   Defaulted 'N' to acceptance_required_flag
   If this value is NULL then these PO's cannot be queried from
   'Acknowledge POs' */

     x_po_header_record.supply_agreement_flag := 'N';
     x_po_header_record.confirming_order_flag := 'N';
     x_po_header_record.firm_status_lookup_code := 'N';
     x_po_header_record.firm_date               := NULL;
     x_po_header_record.acceptance_required_flag := 'N';
     x_po_header_record.acceptance_due_date      := NULL;
     x_po_header_record.blanket_total_amount     := NULL;
     x_po_header_record.amount_limit             := NULL;
     x_po_header_record.min_release_amount       := NULL;

     -- <BUG 4766467 START>
     --
     BEGIN

         SELECT pay_on_code
         INTO   tmp_pay_on_code
         FROM   po_vendor_sites_all
         WHERE  vendor_site_id = x_po_header_record.vendor_site_id;

     EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
     END;

     x_po_header_record.pay_on_code := tmp_pay_on_code ;
     --
     -- <BUG 4766467 END>

  END IF; --action code is Quotation

  /*  Functionality for PA->RFQ Copy : dreddy
    header related fields are processed */
  IF (x_action_code = 'RFQ') THEN

/* Bug 1909325
   Defaulted 'N' to acceptance_required_flag
   If this value is NULL then these PO's cannot be queried from
   'Acknowledge POs' */

      x_po_header_record.type_lookup_code := 'RFQ';
      x_po_header_record.quote_type_lookup_code := x_to_doc_subtype;
      x_po_header_record.quotation_class_code := 'CATALOG';
      x_po_header_record.status_lookup_code  := 'I';
      x_po_header_record.supply_agreement_flag := 'N';
      x_po_header_record.confirming_order_flag := 'N';
      x_po_header_record.firm_status_lookup_code := 'N';
      x_po_header_record.firm_date               := NULL;
      x_po_header_record.acceptance_required_flag := 'N';
      x_po_header_record.acceptance_due_date      := NULL;
      x_po_header_record.blanket_total_amount     := NULL;
      x_po_header_record.amount_limit             := NULL;
      x_po_header_record.min_release_amount       := NULL;

  END IF; --action code is RFQ

  x_po_header_record.pcard_id := NULL;
  x_po_header_record.last_updated_by   := fnd_global.user_id;
  x_po_header_record.last_update_date  := SYSDATE;
  x_po_header_record.last_update_login := fnd_global.login_id;
  x_po_header_record.created_by        := fnd_global.user_id;
  x_po_header_record.creation_date     := SYSDATE;

  -- Standard WHO columns, not inserted
  x_po_header_record.program_application_id := NULL;
  x_po_header_record.program_id             := NULL;
  x_po_header_record.program_update_date    := NULL;
  x_po_header_record.request_id             := NULL;

  -- To be updated by WF.
  x_po_header_record.wf_item_key := NULL;
  x_po_header_record.wf_item_type := NULL;

  -- EDI
  x_po_header_record.edi_processed_flag    := NULL;
  x_po_header_record.edi_processed_status  := NULL;
  x_po_header_record.interface_source_code := NULL;
  x_po_header_record.reference_num         := NULL;

  IF (x_action_code <> 'RFQ') THEN
   x_po_header_record.quotation_class_code      := NULL;
   x_po_header_record.quote_type_lookup_code    := NULL;
   x_po_header_record.status_lookup_code        := NULL;
  END IF;

  x_po_header_record.quote_vendor_quote_number := NULL;
  x_po_header_record.quote_warning_delay       := NULL;
  x_po_header_record.quote_warning_delay_unit  := NULL;
  x_po_header_record.rfq_close_date            := NULL;
  x_po_header_record.reply_date                := NULL;
  x_po_header_record.reply_method_lookup_code  := NULL;

  x_po_header_record.revised_date := NULL;
  x_po_header_record.revision_num := 0;
  x_po_header_record.printed_date := NULL;
  x_po_header_record.print_count  := 0;

  x_po_header_record.approval_required_flag := NULL;
  x_po_header_record.approved_date          := NULL;
  x_po_header_record.approved_flag          := NULL;
  x_po_header_record.authorization_status   := NULL;

  x_po_header_record.frozen_flag := 'N';
  x_po_header_record.cancel_flag := 'N';
  x_po_header_record.closed_code := NULL;
  x_po_header_record.closed_date := NULL;

  x_po_header_record.user_hold_flag := NULL;

  -- Bug 271011. vendor_order_num is unique to PDOI docs, so don't copy.
  x_po_header_record.vendor_order_num := NULL;

  /* bug 969442: The note to vendor field is nulled because it is specific to
     a PO and also for a cancelled po case it contains the reason for cancel.
   */
/* Bug# 1523449  draising
  While using 'Copy Document' functionality from
  Quotation to PO  below line was nullifying the note_to_vendor field
  in copied PO form. It shouldn't happen while copying from Quotation
  to PO.Addded if condition that when x_action_code is 'QUOTATION' then
  it will not nullify the note_to_vendor field  */

 IF (x_action_code <> 'QUOTATION') THEN
 x_po_header_record.note_to_vendor := NULL;
 END IF;

  x_po_header_record.enabled_flag := 'Y';
  x_po_header_record.summary_flag := 'N';

  /** find the next available po_headers.po_header_id  **/
  x_progress := '001';
  BEGIN
    SELECT po_headers_s.nextval
    INTO   x_po_header_record.po_header_id
    FROM   SYS.DUAL;
  EXCEPTION
    WHEN OTHERS THEN
      x_po_header_record.po_header_id := NULL;
      po_copydoc_s1.copydoc_sql_error('validate_header', x_progress, sqlcode,
                                     x_online_report_id,
                                     x_sequence,
                                     0, 0, 0);
      RAISE COPYDOC_HEADER_FAILURE;
  END;

   IF (x_action_code = 'RFQ') THEN
   -- we insert a row into the po_rfq_vendors. this contains the supplier
   -- from the blanket header : RFQ Copy

         po_copydoc_s6.insert_rfq_vendors(x_po_header_record.po_header_id,
                                         x_po_header_record.vendor_id,
                                         x_po_header_record.vendor_site_id,
                               	         x_po_header_record.vendor_contact_Id);

    END IF;

  IF (x_to_segment1 IS NULL) THEN

    -- bug5176308
    -- Get next availbale PO number by calling the API
    IF (x_action_code = 'RFQ') THEN
      x_progress := '002';

      x_po_header_record.segment1 :=
        PO_CORE_SV1.default_po_unique_identifier
        ( x_table_name => 'PO_HEADERS_RFQ'
        );

    ELSE
      x_progress := '02a';

      x_po_header_record.segment1 :=
        PO_CORE_SV1.default_po_unique_identifier
        ( x_table_name => 'PO_HEADERS'
        );
    END IF;

  ELSE
    x_po_header_record.segment1 := x_to_segment1;
  END IF;


  x_return_code := 0;
  po_copydoc_s1.copydoc_debug('End: validate_header()');

EXCEPTION
  WHEN COPYDOC_HEADER_FAILURE THEN
    x_return_code := -1;
  WHEN OTHERS THEN
    po_copydoc_s1.copydoc_sql_error('validate_header', x_progress, sqlcode,
                                    x_online_report_id,
                                    x_sequence,
                                    0, 0, 0);
    x_return_code := -1;
END validate_header;



END po_copydoc_s2;


/
