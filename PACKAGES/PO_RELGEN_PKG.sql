--------------------------------------------------------
--  DDL for Package PO_RELGEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RELGEN_PKG" AUTHID CURRENT_USER AS
/* $Header: porelges.pls 120.3.12010000.6 2012/12/18 01:03:35 rajarang ship $ */


/*  Declare cursor for requisition lines that meet the following criteria

    - the requisition lines must be on approved requisitions that are not
      already on a PO or a release
    - the requisition lines must not be cancelled or closed
    - the requisition lines must be sourced to an approved and active blanket
      that is not on hold
    - the vendor associated with the blanket must be active, and must not be
      on hold if vendors holds are enforced
    - the autosource rule for the item must be active and the document
      generation method must be either 'CREATE' or 'CREATE_AND_APPROVE'
    - the amount (qty*price) must be greater than the minimum release amount
      on the blanket line if one is specified
*/
/** Bug 787120
 *  bgu, June 09, 1999
 *  Port bug fix 772055 to 11.5
 */
/*
Bug # : 772055 - SVAIDYAN : Added condn. that the modified_by_agent_flag = 'N'
      so that the req. lines modified thru autocreate form do not get processed.
*/
/* Bug no 777230
   In both the cursor requisition_lines_cursor and
                      requisition_lines_cursor1
   we were not checking the if the line of the blanket is cancelled
   before allowing the release to be created.
   Made the fix to check for that.nvl(pol.cancel_flag,'N') = 'N'
*/
/* Bug no 996349
   In both the cursor requisition_lines_cursor and
                         requisition_lines_cursor1
   we were not checking the if the line of the blanket line is finally closed
   before allowing the release to be created.
   Made the fix to check for that.
          nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
*/
/* Bug #947709 - FRKHAN 8/4/99
   'requisition_header_id' is added to  requisition_lines_cursor and
   requisition_lines_cursor1.
*/
    /* Supplier PCard FPH. Get the pcard_id from the function
     * po_pcard_pkg.get_valid_pcard_id.  This will fetch pcard_id
     * if it is valid or null if it is not. The orderby is done
     * in such a way that all the null pcard_ids and the non null
     * pcard_ids are grouped together. This way all null will be
     * grouped into one release. For the others all the same non null
     * pcard_ids will be grouped into one.
    */
    cursor requisition_lines_cursor is
          select porl.requisition_line_id requisition_line_id,
                 poh.agent_id agent_id,
                 porl.blanket_po_header_id blanket_po_header_id,
                 pol.po_line_id blanket_po_line_id,
                 poh.vendor_id vendor_id,
                 poh.vendor_site_id vendor_site_id,
                 nvl(poh.rate,1) rate,
                 nvl(poh.rate_date,sysdate) rate_date,
                 porl.last_updated_by last_updated_by,
                 porl.last_update_login last_update_login,
                 porl.destination_type_code destination_type_code,
                 porl.item_id item_id,
                 porl.unit_price unit_price,
                 porl.quantity quantity,
                 porl.need_by_date need_by_date,
                 --togeorge 09/28/2000
                 --added note to receiver
                 porl.note_to_receiver note_to_receiver,
                 porl.destination_organization_id destination_organization_id,
                 porl.deliver_to_location_id deliver_to_location_id,
                 porl.to_person_id deliver_to_person_id,
                 decode(pad.doc_generation_method, 'CREATE_AND_APPROVE',
                   decode(fsp.req_encumbrance_flag, 'Y', 'CREATE', 'CREATE_AND_APPROVE'),
                        pad.doc_generation_method) doc_generation_method,
                 porl.unit_meas_lookup_code req_uom,
                 pol.unit_meas_lookup_code po_uom,
                 prh.requisition_header_id requisition_header_id,
                 porl.secondary_unit_of_measure secondary_unit_of_measure,
                 porl.secondary_quantity secondary_quantity,
                 porl.preferred_grade preferred_grade,  /* B1548597 OPM */
                decode(porl.pcard_flag,'N',null,'S',po_pcard_pkg.get_valid_pcard_id(-99999,porl.vendor_id,porl.vendor_site_id),'Y',po_pcard_pkg.get_valid_pcard_id(prh.pcard_id,porl.vendor_id,porl.vendor_site_id)) pcard_id,
                 porl.vmi_flag,   -- VMI FPH
                 porl.drop_ship_flag,   -- <DropShip FPJ>
                 porl.org_id            -- <R12 MOAC>
            from po_requisition_lines porl,
                 po_requisition_headers prh,
                 financials_system_parameters fsp,
                 po_system_parameters psp,
                 po_autosource_documents pad,
                 po_autosource_rules par,
                 po_headers poh,
                 po_lines pol,
                 po_vendors pov
           where porl.requisition_header_id = prh.requisition_header_id
             and prh.authorization_status = 'APPROVED'
             and porl.line_location_id is null
             and nvl(porl.cancel_flag,'N') = 'N'
             and nvl(porl.closed_code,'OPEN') <> 'FINALLY CLOSED'
             and nvl(porl.modified_by_agent_flag, 'N') = 'N'
             and porl.blanket_po_header_id is not null
             and porl.blanket_po_line_num is not null
             and porl.unit_price is not null
             and porl.item_id is not null
             and porl.document_type_code = 'BLANKET'
             and porl.blanket_po_header_id = poh.po_header_id
             and pol.po_header_id = poh.po_header_id
             and trunc(nvl(pol.expiration_date,sysdate+1)) > trunc(sysdate)
             and nvl(pol.cancel_flag,'N') = 'N'
             and nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
             and poh.type_lookup_code = 'BLANKET'
             and poh.approved_flag = 'Y'
             and nvl(poh.cancel_flag,'N') = 'N'
/* Bug 1128903
   Modifying the AND condition to accomodate the need_by_date so that
   documents effective for a future period can be chosen. */
           and trunc(nvl(porl.need_by_date, sysdate))
             between trunc(nvl(poh.start_date,nvl(porl.need_by_date, sysdate)))
                   and trunc(nvl(poh.end_date,nvl(porl.need_by_date, sysdate)))
             and nvl(poh.user_hold_flag,'N') = 'N'
             and poh.vendor_id = pov.vendor_id
             and trunc(sysdate) between trunc(nvl(pov.start_date_active,
                                                                      sysdate))
                                    and trunc(nvl(pov.end_date_active,sysdate))
             and not(nvl(psp.enforce_vendor_hold_flag,'N') = 'Y'
                     and nvl(pov.hold_flag,'N') = 'Y')
             and porl.blanket_po_line_num = pol.line_num
             and porl.blanket_po_header_id = pad.document_header_id
             and pol.po_line_id = pad.document_line_id
             and pad.doc_generation_method in ('CREATE','CREATE_AND_APPROVE')
             and pad.autosource_rule_id = par.autosource_rule_id
 /* Bug 1128903
   Modifying the AND condition to accomodate the need_by_date so that
   sourcing rules effective for a future period can be chosen. */
             and trunc(nvl(porl.need_by_date, sysdate))
                    between trunc(par.start_date)
                    and trunc(nvl(par.end_date,nvl(porl.need_by_date, sysdate)))
-- Bug 2701147 START
-- We should compare the BPA line minimum release amount against the total
-- amount of all shipments for that line on the release. This is now done
-- in Check 12 of preapproval_checks.
--             and (porl.quantity * round(porl.unit_price/nvl(poh.rate,1),5)
--                                         >= nvl(pol.min_release_amount,0))
-- Bug 2701147 END
        order by blanket_po_header_id,
                 doc_generation_method,
                 blanket_po_line_num,
                /* Supplier PCard FPH */
                decode(porl.pcard_flag,'N',null,'S',po_pcard_pkg.get_valid_pcard_id(-99999,porl.vendor_id,porl.vendor_site_id),'Y',po_pcard_pkg.get_valid_pcard_id(prh.pcard_id,porl.vendor_id,porl.vendor_site_id)),
                 need_by_date, -- bug 2378110
                 requisition_line_id
        for update of porl.line_location_id;

    /*  Cursor requisition_lines_cursor1 selects requisition lines based on
        the same criteria as requisition_lines_cursor except that it checks
        the asl entry to determine the release generation method.  The gets
        the asl entry based on the item/category on the req line and
        vendor/site on the source document.
    */
/*Bug 1790311:Before fix the following cursor was picking up a record from
              po_asl_attributes even if there was no blanket attached to the
              supplier line in the ASL.This caused duplicate shipments to be
              created in the Release if there are two supplier lines in the
              ASL.One with a supplier and null supplier site combination  and
              the other with a supplier and a supplier site,attached to the same
              blanket.Now adding the table po_asl_documents in the cursor and
              adding a condition which checks whether a blanket has been
              attached to a supplier line in the ASL.*/

/*Bug 1916078. Pchintal. Reverted the fix done in bug 1361935, which was a forward port
  from 11.0 and was causing a performance problem in 11.5. The performance with out this
  fix is very good and the fix from bug 1361935 was causing a performance problem.
*/
/* Bug 2008371. pchintal. Added the ORDERED hint and changed the order of
  the tables in the from clause to improve the performance.
*/

/*Bug 2005755:

1.Reverting the fix for bug 1790311.
2.Now a shipment will be created for all the valid supplier lines with null
  supplier site.
3.A shipment will be created for a valid supplier line having a supplier site
  only when there is no other supplier line is existing with the same supplier-
  item combination having a null supplier site. */

--bug2880298
--pass req_enc_flag and enforce_vendor_hold_flag information from the caller
--instead of getting them in the cursor itself to improve performance

/*bug12602301 starts:  Performance issue.
 	 in order to determine the one particular entry from
 	 the asl table the earlier cursor had many queries within itself
 	 i.e subqueries. As a part of the fix all the conditions of the subqueries have been
 	 incorporated in a single sql.This sql is in the function get_asl_id which retruns the asl_id
 	 The precedence for picking up an asl entry is
 	 1. Item level asl.
 	 2. Category ASl
 	 For each of the above
 	 Local ASL will be preferred over global asl
 	 Valid Vendor site will be preferred than vendor_site being null
 	   */
 	 FUNCTION get_asl_id( p_item_id IN po_requisition_lines_all.item_id%TYPE,
 	                      p_category_id IN po_requisition_lines_all.category_id%TYPE,
 	                      p_destination_organization_id      IN po_requisition_lines_all.destination_organization_id%TYPE,
 	                      p_vendor_id IN po_headers_all.vendor_id%TYPE,
 	                      p_vendor_site_id IN po_headers_all.vendor_site_id%TYPE) return number;


    cursor requisition_lines_cursor1
    ( p_req_enc_flag IN VARCHAR2,
      p_enforce_vendor_hold_flag IN VARCHAR2
    ) is
          select /*+ FIRST_ROWS LEADING(PORL)*/
                 porl.requisition_line_id requisition_line_id,
                 poh.agent_id agent_id,
                 porl.blanket_po_header_id blanket_po_header_id,
                 pol.po_line_id blanket_po_line_id,
                 poh.vendor_id vendor_id,
                 poh.vendor_site_id vendor_site_id,
                 nvl(poh.rate,1) rate,
                 nvl(poh.rate_date,sysdate) rate_date,
                 porl.last_updated_by last_updated_by,
                 porl.last_update_login last_update_login,
                 porl.destination_type_code destination_type_code,
                 porl.item_id item_id,
                 porl.unit_price unit_price,
                 porl.quantity quantity,
                 porl.need_by_date need_by_date,
                 --togeorge 09/28/2000
                 --added note to receiver
                 porl.note_to_receiver note_to_receiver,
                 porl.destination_organization_id destination_organization_id,
                 porl.deliver_to_location_id deliver_to_location_id,
                 porl.to_person_id deliver_to_person_id,
                  decode(paa.release_generation_method, 'CREATE_AND_APPROVE',
--                 decode(pad.doc_generation_method, 'CREATE_AND_APPROVE',
                   DECODE (p_req_enc_flag, 'Y', 'CREATE',
                                                'CREATE_AND_APPROVE'),
                        paa.release_generation_method) doc_generation_method,
--                        pad.doc_generation_method) doc_generation_method,
                 porl.unit_meas_lookup_code req_uom,
                 pol.unit_meas_lookup_code po_uom,
                 prh.requisition_header_id requisition_header_id,
                 porl.secondary_unit_of_measure secondary_unit_of_measure,
                 porl.secondary_quantity secondary_quantity,
                 porl.preferred_grade preferred_grade,  /* B1548597 OPM */
                /* Supplier PCard FPH */
                decode(porl.pcard_flag,'N',null,'S',po_pcard_pkg.get_valid_pcard_id(-99999,porl.vendor_id,porl.vendor_site_id),'Y',po_pcard_pkg.get_valid_pcard_id(prh.pcard_id,porl.vendor_id,porl.vendor_site_id)) pcard_id,
                 porl.vmi_flag,   -- VMI FPH
                 porl.drop_ship_flag,   -- <DropShip FPJ>
                 porl.org_id            -- <R12 MOAC>
         from     po_requisition_lines porl,
                  po_requisition_headers prh,
                  po_headers poh,
                  po_vendors pov,
                  po_lines pol,
                  po_asl_attributes_val_v  paa    -- Bug: 1945461
--bug  2005755                  po_asl_documents pod             -- Bug 1790311
--                 po_autosource_documents pad,
--                 po_autosource_rules par,
           where porl.requisition_header_id = prh.requisition_header_id
             -- <REQINPOOL>: removed parameters made redundant by new
             -- reqs_in_pool_flag def
             and nvl(prh.authorization_status,'INCOMPLETE') = 'APPROVED'     --Bug: 14031382
             and nvl(porl.reqs_in_pool_flag,'N') = 'Y'       /* Requisition To Sourcing FPH  */
             -- <REQINPOOL END>
             and porl.source_type_code = 'VENDOR'
             and porl.blanket_po_header_id is not null
             and porl.blanket_po_line_num is not null
             and porl.unit_price is not null
             and porl.item_id is not null
             and porl.document_type_code = 'BLANKET'
             and porl.blanket_po_header_id = poh.po_header_id
             and pol.po_header_id = poh.po_header_id
             and trunc(nvl(pol.expiration_date,sysdate+1)) >= trunc(sysdate) --Bug 5636580 , Modified so that we can Create Releases for a Blanket
                                                                             --Purchase Agreement which has the line level expiration date as Current date
             and nvl(pol.cancel_flag,'N') = 'N'
             and nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
             and poh.type_lookup_code = 'BLANKET'
             and nvl(poh.global_agreement_flag,'N') = 'N'   -- FPI GA
             and poh.approved_flag = 'Y'
             and nvl(poh.cancel_flag,'N') = 'N'
/* Bug 1128903
   Modifying the AND condition to accomodate the need_by_date so that
   documents effective for a future period can be fixed. */

/* Bug 2402167: In order to allow releases to be created even if the need by date
   is after the blanket's expiry date, modifying the condition put in by 1128903.
   Now, it allows release to be created as long as:
   1. blanket is not ALREADY expired.
   2. blanket is becoming effective on or before the need by date. */
--           and trunc(nvl(porl.need_by_date, sysdate))
--            between trunc(nvl(poh.start_date,nvl(porl.need_by_date, sysdate)))
--             and trunc(nvl(poh.end_date,nvl(porl.need_by_date, sysdate)))


/* Bug 3397912: Requisition lines without need-by dates were being missed by
 * this cursor, because one of the need-by dates below was missing an NVL(...,sysdate).
 * All porl.need_by_date items should now have NVL() around them in this query.
 */

             and trunc(nvl(poh.end_date, sysdate + 1)) >= trunc(sysdate)
             and trunc(nvl(poh.start_date, NVL(porl.need_by_date,SYSDATE) - 1))
                                      <= trunc(nvl(porl.need_by_date, sysdate))
-- Bug 2402167.end

             and nvl(poh.user_hold_flag,'N') = 'N'
             and poh.vendor_id = pov.vendor_id
             and trunc(sysdate) between trunc(nvl(pov.start_date_active,
                                                                      sysdate))
                                    and trunc(nvl(pov.end_date_active,sysdate))
             and not(p_enforce_vendor_hold_flag = 'Y'  -- bug2880298
                     and nvl(pov.hold_flag,'N') = 'Y')
             and porl.blanket_po_line_num = pol.line_num
               --bug 12602301 starts
 	             AND paa.vendor_id = poh.vendor_id
 	             AND paa.asl_id = po_relgen_pkg.get_asl_id(porl.item_id,porl.category_id,porl.destination_organization_id,
 	                                               poh.vendor_id, poh.vendor_site_id)
		     AND paa.using_organization_id =
    			(SELECT MAX(paa2.using_organization_id)
			 FROM po_asl_attributes paa2
			 WHERE paa2.asl_id = paa.asl_id
			 AND paa2.using_organization_id IN (-1, porl.destination_organization_id)
			) --Bug15893161

 	              /*and (paa.item_id = porl.item_id
               or (paa.item_id IS NULL
                     AND porl.category_id = paa.category_id
                  --Bug#2279155 start
                     and not exists
                 (select 'commodity level ASL should be used
                          only if there is no item level ASL'
                    from po_asl_attributes_val_v paa4
                   where paa4.item_id=porl.item_id
                     and paa4.vendor_id=paa.vendor_id
                     and nvl(paa4.vendor_site_id,-1)=nvl(paa.vendor_site_id,-1)
                     AND paa4.using_organization_id in (-1,porl.destination_organization_id))
                  --Bug#2279155 end
                  )
                 )
--Bug2005755 and pod.asl_id=paa.asl_id   --Bug 1790311
--Bug2005755 and porl.blanket_po_header_id=pod.document_header_id --Bug 1790311
--Bug2005755 and pol.po_line_id= pod.document_line_id  --Bug 1790311
--Bug2005755and pod.using_organization_id=paa.using_organization_id--Bug 1790311
             and paa.vendor_id = poh.vendor_id

--start of bug Bug2005755
             and (paa.vendor_site_id is null or
  ( poh.vendor_site_id = paa.vendor_site_id and
    not exists
    (SELECT 'select supplier line with null supplier site'
     FROM    po_asl_attributes_val_v paa3
     WHERE   nvl(paa.item_id, -1) = nvl(paa3.item_id, -1)
     AND     nvl(paa.category_id, -1) = nvl(paa3.category_id, -1)
     AND     paa.vendor_id = paa3.vendor_id
     AND     paa3.vendor_site_id is null
     AND paa3.using_organization_id in (-1,porl.destination_organization_id)
/*
    Bug 4001367 : Duplicate shipments were created for the requisition line
    sourced to a source document associated with the supplier and site and
    the release generation method set to 'Automatic' and also
    another ASL existed for the same supplier without supplier site and Release
    Generation method set to 'Automatic Release/Review'. We also need to add
    a check for release generation method CREATE(Automatic Release/Review)

     AND paa3.release_generation_method in ('CREATE_AND_APPROVE','CREATE'))))
--end of bug 2005755
             and paa.using_organization_id =
                        (SELECT  max(paa2.using_organization_id)
                         FROM         po_asl_attributes_val_v paa2
                         WHERE   nvl(paa.item_id, -1) = nvl(paa2.item_id, -1)
                         AND         nvl(paa.category_id, -1) = nvl(paa2.category_id, -1)
                         AND         paa.vendor_id = paa2.vendor_id
                         AND         nvl(paa.vendor_site_id, -1) = nvl(paa2.vendor_site_id, -1)
                         AND     paa2.using_organization_id in (-1,porl.destination_organization_id))
             and paa.release_generation_method in ('CREATE','CREATE_AND_APPROVE')   */
             --bug 12602301 ends
--             and porl.blanket_po_header_id = pad.document_header_id
--             and pol.po_line_id = pad.document_line_id
--             and pad.doc_generation_method in ('CREATE','CREATE_AND_APPROVE')
--             and pad.autosource_rule_id = par.autosource_rule_id
--             and trunc(sysdate) between trunc(par.start_date)
--                                    and trunc(nvl(par.end_date,sysdate))
-- Bug 2701147 START
-- We should compare the BPA line minimum release amount against the total
-- amount of all shipments for that line on the release. This is now done
-- in Check 12 of preapproval_checks.
--             and (porl.quantity * round(porl.unit_price/nvl(poh.rate,1),5)
--                                         >= nvl(pol.min_release_amount,0))
-- Bug 2701147 END
             and nvl(paa.consigned_from_supplier_flag, 'N') = 'N'
-- Bug 3411766 START
-- We should not select the lines which are created in iProcurement with
-- emergency PO number.
             and prh.emergency_po_num is null
-- Bug 3411766 END
        order by blanket_po_header_id,
                 doc_generation_method,
                 blanket_po_line_num,
                 /* Supplier PCard FPH */
                decode(porl.pcard_flag,'N',null,'S',po_pcard_pkg.get_valid_pcard_id(-99999,porl.vendor_id,porl.vendor_site_id),'Y',po_pcard_pkg.get_valid_pcard_id(prh.pcard_id,porl.vendor_id,porl.vendor_site_id)),
                 need_by_date, -- bug 2378110
                 requisition_line_id
        for update of porl.line_location_id;

/* Declare cursor for the receiving controls */

TYPE rcv_control_type IS RECORD
(inspection_required_flag   po_system_parameters.inspection_required_flag%type
                                                                       := null,
 receipt_required_flag      po_system_parameters.receiving_flag%type := null,
 days_early_receipt_allowed rcv_parameters.days_early_receipt_allowed%type
                                                                       :=null,
 days_late_receipt_allowed  rcv_parameters.days_late_receipt_allowed%type
                                                                       := null,
 enforce_ship_to_location   rcv_parameters.enforce_ship_to_location_code%type
                                                                       := null,
 receiving_routing_id       rcv_parameters.receiving_routing_id%type
                                                                       :=null,
 qty_rcv_tolerance          rcv_parameters.qty_rcv_tolerance%type
                                                                        :=null,
 receipt_days_exception_code rcv_parameters.receipt_days_exception_code%type
                                                                        :=null,
 qty_rcv_exception_code rcv_parameters.qty_rcv_exception_code%type
                                                                        :=null,
 allow_substitute_receipts_flag rcv_parameters.allow_substitute_receipts_flag%type
                                                                        :=null,
 invoice_close_tolerance    po_system_parameters.invoice_close_tolerance%type
                                                                       := null,
 receipt_close_tolerance    po_system_parameters.receive_close_tolerance%type
                                                                       := null);

/* Declare global variables */

x_inventory_org_id       number := 0;
x_expense_accrual_code   po_system_parameters.expense_accrual_code%type;
x_po_release_id          number := 0;
x_line_location_id       number := 0;
x_authorization_status   po_releases.authorization_status%type;
msgbuf                   varchar2(200);
x_period_name            gl_period_statuses.period_name%type;

/* Declare procedures and associated parameters */

/* Bug 1834138. pchintal. Added 2 new global variables to calculate the
shipment number. This was done as a part of improving the performance of
the create releases process.
*/

Gpo_release_id_prev      number := 0;
Gship_num_prev           number := 0;


PROCEDURE CREATE_RELEASES;

PROCEDURE CREATE_RELEASE_HEADER(req_line IN requisition_lines_cursor%rowtype);

PROCEDURE CREATE_RELEASE_SHIPMENT(req_line IN requisition_lines_cursor%rowtype);

PROCEDURE OE_DROP_SHIP(req_line IN requisition_lines_cursor%rowtype);

PROCEDURE MAINTAIN_SUPPLY(req_line IN requisition_lines_cursor%rowtype);

PROCEDURE GET_RCV_CONTROLS(req_line IN requisition_lines_cursor%rowtype,
                           rcv_controls IN OUT NOCOPY rcv_control_type);

PROCEDURE GET_INVOICE_MATCH_OPTION(req_line IN requisition_lines_cursor%rowtype,
                                 x_invoice_match_option OUT NOCOPY varchar2);

PROCEDURE WRAPUP(req_line IN requisition_lines_cursor%rowtype);

FUNCTION GET_BEST_PRICE(req_line IN requisition_lines_cursor%rowtype,
                               x_conversion_rate IN number,
                               x_ship_to_location_id IN number) return number;

-- <INBOUND LOGISITCS PFJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: create_deliveryrecord
--Pre-reqs:
--  None.
--Modifies:
--  l_fte_rec
--Locks:
--  None.
--Function:
--  Call FTE's API to create delivery record for Approved Blanket Release
--Parameters:
--IN:
--p_release_id
--  Corresponding to po_release_id
--Testing:
--  Pass in po_release_id for an approved release.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE create_deliveryrecord(p_release_id IN NUMBER);

-- <INBOUND LOGISITCS PFJ END>

END PO_RELGEN_PKG;

/
