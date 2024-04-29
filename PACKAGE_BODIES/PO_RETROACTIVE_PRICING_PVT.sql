--------------------------------------------------------
--  DDL for Package Body PO_RETROACTIVE_PRICING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RETROACTIVE_PRICING_PVT" AS
/*$Header: POXRPRIB.pls 120.19.12010000.9 2014/07/17 10:35:37 yuandli ship $*/

-- Global Variables
      G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_RETROACTIVE_PRICING_PVT';
      G_BULK_LIMIT number := 1000;
      g_log_mode         VARCHAR2(240) :=
        NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_CONCURRENT_ON'),'N') ;
      TYPE g_agreement_cur_type IS REF CURSOR;
      TYPE num_table         is table of number       index by binary_integer;
      TYPE char30_table       is table of varchar2(30) index by binary_integer;
      TYPE date_table       is table of date  index by binary_integer;

     /* Global tables that are defined for inserting into the global temp
      * table po_retroprice_gt.
     */
     g_row_id_table char30_table;
     g_exclude_row_id_table char30_table;
     g_new_price_table num_table;
     g_new_base_price_table num_table; --Enhanced Pricing
     g_po_header_id_table num_table;
     g_po_release_id_table num_table;
     g_auth_status_table char30_table;
     g_archived_rev_num_table num_table;
     g_po_auth_table char30_table;
     g_rel_auth_table char30_table;

     g_index number;
     g_exclude_index number;

     g_orig_org_id number;

     g_log_head CONSTANT VARCHAR2(60) := 'po.plsql.' || g_pkg_name || '.';
     g_sysdate DATE := sysdate;
     g_user_id NUMBER := fnd_global.user_id;

     -- <FPJ Retroactive Price>
     g_communicate_update VARCHAR2(1) := 'N';


     -- Debugging

     g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;
     g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;
     -- Read the profile option that enables/disables the debug log
     g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

     -- Bug 3231062
     g_projects_11i10_installed CONSTANT VARCHAR2(1) :=
                                PA_PO_INTEGRATION.is_pjc_11i10_enabled;

-- bug2935437
/**
 * Private Procedure: open_agreement_cur
 * Modifies: x_cursor
 * Effects:  This procedure opens a cursor with dynamic sql embedded in string
 *           p_sql_str. Since the number of bind variables can be different
 *           based on the values of parameters p_item_from (to) and p_cat_from (to),
 *           the command for opening the cursor needs to be coded several times
 *           and one of them will be executed based on the number of bind variables
 * Returns:
 *   x_cursor: cursor of an dynamic sql statement
 */
PROCEDURE open_agreement_cur(p_sql_str            IN    VARCHAR2,
                                p_po_header_id       IN    NUMBER,
                                p_vendor_id          IN    NUMBER,
                                p_vendor_site_id     IN    NUMBER,
                                p_category_struct_id IN    NUMBER,
                                p_ga_security        IN    VARCHAR2,
                                p_item_from          IN    VARCHAR2,
                                p_item_to            IN    VARCHAR2,
                                p_cat_from           IN    VARCHAR2,
                                p_cat_to             IN    VARCHAR2,
                                x_cursor          IN OUT NOCOPY g_agreement_cur_type);
--

-- Bug 4080732 START: Forward declaration of the private function
FUNCTION is_inv_org_period_open
( p_std_po_price_change IN VARCHAR2,
  p_po_line_id          IN NUMBER,
  p_po_line_loc_id      IN NUMBER
)
RETURN VARCHAR2;
-- Bug 4080732 END

/**
 * Private Procedure: MassUpdate_Releases
 * Modifies: Column price_override, retroactive_date  in po_line_locations,
 * Authorization_status, revision_num in po_headers and po_releases.
 * Effects: Selects the agreements( blankets and contracts) as specified
 *          by the concurrent parameters and selects the execution docs
 *          refering these agreements for retroactive price updates.
 *          Get the new price based on the release/Std PO shipment values.
 *          If they are different, then update po_line_locations with the
 *          new price. In either case, update retoractive_date in
 *          po_line_locations with the retroactive_date in po_lines so that
 *          this shipment will not be picked up again unless blanket line
 *          is retroactively changed. Once all the releases are done, update
 *          po_headers or po_releases with the new revision number and set
 *          authorization_status to "Requires Reapproval" and initiate
 *          Workflow if the document was already in Approved state.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if control action succeeds
 *                     FND_API.G_RET_STS_ERROR if control action fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
--------------------------------------------------------------------------------
--Start of Comments
--Name: MassUpdate_Releases
--Pre-reqs:
--  None.
--Modifies:
--  Column price_override, retroactive_date  in po_line_locations,
--  Authorization_status, revision_num in po_headers and po_releases.
--Locks:
--  None.
--Function:
--  This API is called from the Approval Window or by the
--  Concurrent Program. This procedure will update all
--  the releases against Blanket Agreeements or Standard
--  POs against Global Agreements that have lines that
--  are retroactively changed.
--  Selects the blanket lines that have been retroactively changed
--  and selects all the releases againt BA (or std PO against GA).
--  Get the new price based on the release/Std PO shipment values.
--  If they are different, then update po_line_locations with the
--  new price. In either case, update retoractive_date in
--  po_line_locations with the retroactive_date in po_lines so that
--  this shipment will not be picked up again unless blanket line
--  is retroactively changed. Once all the releases are done, update
--  po_headers or po_releases with the new revision number and set
--  authorization_status to "Requires Reapproval" and initiate
--  Workflow if the document was already in Approved state.
--Parameters:
--IN:
--p_api_version
--  Version number of API that caller expects. It
--  should match the l_api_version defined in the
--  procedure (expected value : 1.0)
--p_validation_level
--  validation level api uses
--p_vendor_id
--  Site_id of the Supplier site selected by the user.
--p_po_header_id
--  Header_id of the Blanket/Global Agreement selected by user.
--p_category_struct_id
--  Purchasing Category structure Id
--p_category_from / p_category_to
--  Category Range that user selects to process retroactive changes
--p_item_num_from / p_item_num_to
--  Item Range that user selects to process retroactive changes
--p_date
--  All releases or Std PO created on or after this date must be changed.
--p_communicate_update
--  Communicate Price Updates to Supplier
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--Testing:
--
--End of Comments
--------------------------------------------------------------------------------

Procedure MassUpdate_Releases ( p_api_version   IN  NUMBER,
                                p_validation_level  IN  NUMBER,
        p_vendor_id     IN  Number,
        p_vendor_site_id  IN  Number,
        p_po_header_id    IN  Number,
        p_category_struct_id  IN  Number,
        p_category_from   IN  Varchar2,
        p_category_to   IN  Varchar2,
        p_item_from   IN  Varchar2,
        p_item_to   IN  Varchar2,
        p_date      IN  Date,
        -- <FPJ Retroactive Price>
        p_communicate_update  IN  VARCHAR2 DEFAULT NULL,
        x_return_status   OUT NOCOPY VARCHAR2)

IS

--Bug 4176111: Add the paratemeter p_qp_license_on to conditionally enable logic to test retroactive_date
cursor select_open_releases(l_po_line_id number, l_retroactive_date date,p_date date, p_qp_license_on VARCHAR2 ) is
  select poll.rowid,poll.line_location_id, poll.quantity,
         poll.ship_to_organization_id, poll.ship_to_location_id,
         poll.price_override, nvl(poll.need_by_date,sysdate),
         por.po_release_id,
         por.authorization_status, por.revision_num,
         pora.revision_num
  from po_line_locations poll,
       po_releases_all por,    -- <R12 MOAC>
       po_releases_archive pora
  where  nvl(por.frozen_flag, 'N') = 'N'
  and nvl(por.authorization_status, 'INCOMPLETE') IN
    ('APPROVED', 'INCOMPLETE', 'REJECTED',
     'REQUIRES REAPPROVAL')
  and nvl(por.closed_code,'OPEN') IN ('OPEN','CLOSED',
       'CLOSED FOR RECEIVING',
        /* Bug 3334043: Releases that are closed by setting 'Invoice Close
         * Tolerance to 100%' should also be picked up
         */
                         'CLOSED FOR INVOICE')
  and nvl(por.cancel_flag,'N') <> 'Y'
  and nvl(por.consigned_consumption_flag,'N') ='N'
  and ((poll.accrue_on_receipt_flag = 'Y' and
    quantity_received =0 and quantity_billed =0
    /* Bug 18372756 */
    and NOT EXISTS
               (SELECT 'unvalidated debit memo'
               FROM  PO_HEADERS POH,
                     po_lines POL,
                     po_distributions pod
               WHERE POL.po_line_id = poll.po_line_id
                AND POH.po_header_id = POL.po_header_id
                AND por.po_header_id = poh.po_header_id
                AND pod.line_location_id = poll.line_location_id
                AND pod.po_release_id = por.po_release_id
                AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, por.po_release_id, pol.po_line_id, poll.line_location_id, pod.po_distribution_id, NULL, 'PO_AP_DEBIT_MEMO_UNVALIDATED') = 1
               )
    /* End bug 18372756 */
    )
    OR
        (poll.accrue_on_receipt_flag = 'N' and
    quantity_billed = 0
    /* Bug 18372756 */
    and NOT EXISTS
               (SELECT 'unvalidated debit memo'
               FROM  PO_HEADERS POH,
                     po_lines POL,
                     po_distributions pod
               WHERE POL.po_line_id = poll.po_line_id
                AND POH.po_header_id = POL.po_header_id
                AND por.po_header_id = poh.po_header_id
                AND pod.line_location_id = poll.line_location_id
                AND pod.po_release_id = por.po_release_id
                AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, por.po_release_id, pol.po_line_id, poll.line_location_id, pod.po_distribution_id, NULL, 'PO_AP_DEBIT_MEMO_UNVALIDATED') = 1
               )
    /* End bug 18372756 */
  ))
  /* Bug 2725744. Added the condition to check for closed_code
         * and cancel_flag flag for the release shipments.
        */
        and nvl(poll.closed_code,'OPEN') IN ('OPEN','CLOSED',
                         'CLOSED FOR RECEIVING',
        /* Bug 3334043: Releases that are closed by setting 'Invoice Close
         * Tolerance to 100%' should also be picked up
         */
                         'CLOSED FOR INVOICE')
        and nvl(poll.cancel_flag,'N') <> 'Y'
  and por.po_release_id = poll.po_release_id
  and poll.po_release_id is not null
  and poll.po_line_id = l_po_line_id
  --Bug 4176111: Only when the Advanced Pricing API is not enabled for PO, then use logic of comparing retroactive_date
  --to rule out unneccesary release linelocations
  and ( p_qp_license_on = 'Y' OR
        ( p_qp_license_on = 'N' and nvl(poll.retroactive_date,sysdate) <> l_retroactive_date))  --<R12 GBPA Adv Pricing >
  and nvl(poll.need_by_date,por.creation_date) >=
    nvl(p_date,nvl(poll.need_by_date,por.creation_date))
  AND    POR.po_release_id = PORA.po_release_id (+)
        AND    PORA.latest_external_flag (+) = 'Y'
 --Bug 10011874 Release/SPO should not be updated when there are open receiving transactions
  AND NOT EXISTS (SELECT 'no pending receiving transactions'
                    FROM RCV_TRANSACTIONS_INTERFACE RTI
                   WHERE RTI.po_line_location_id = POLL.line_location_id
                     AND RTI.transaction_status_code = 'PENDING'
                 )
  order by por.po_release_id
  for update of poll.retroactive_date;

--Bug 4176111: Add the paratemeter p_qp_license_on to conditionally enable logic to test retroactive_date
cursor select_open_stdpo(l_po_line_id number, l_retroactive_date date,
      p_date date, p_qp_license_on VARCHAR2) is
  select  pol.rowid,poll.line_location_id,pol.quantity,
         poll.ship_to_organization_id, poll.ship_to_location_id,
         poll.price_override, nvl(poll.need_by_date,sysdate),
         poh.po_header_id,
         poh.authorization_status, poh.revision_num,
         poha.revision_num
  from po_headers_all poh, po_lines_all pol, po_line_locations_all poll,
       po_headers_archive_all poha,financials_system_params_all fsp
  where pol.from_line_id = l_po_line_id
  and poh.po_header_id = pol.po_header_id
        and poh.org_id = fsp.org_id    -- <R12 MOAC>    -- Bug 3573266
        and nvl(fsp.purch_encumbrance_flag,'N') = 'N'      -- Bug 3573266
        --Bug 4176111: Only when the Advanced Pricing API is not enabled for PO, then use logic of comparing retroactive_date
        --to rule out unneccesary spo linelocations
        and ( p_qp_license_on = 'Y' OR
              ( p_qp_license_on = 'N' and nvl(poll.retroactive_date,sysdate) <> l_retroactive_date))  --<R12 GBPA Adv Pricing >
  and poll.shipment_num = (select min(poll.shipment_num)
         from po_line_locations_all polt
         where polt.po_line_id=pol.po_line_id)
  and  nvl(poh.frozen_flag, 'N') = 'N'
  and nvl(poh.authorization_status, 'INCOMPLETE') IN
    ('APPROVED', 'INCOMPLETE', 'REJECTED',
     'REQUIRES REAPPROVAL')
  and nvl(poh.closed_code,'OPEN') IN ('OPEN','CLOSED',
       'CLOSED FOR RECEIVING',
        /* Bug 3334043: Std.POs that are closed by setting 'Invoice Close
         * Tolerance to 100%' should also be picked up
         */
                         'CLOSED FOR INVOICE')
  and nvl(poh.cancel_flag,'N') <> 'Y'
  and nvl(poh.consigned_consumption_flag,'N') ='N'
  and pol.po_line_id = poll.po_line_id
        and not exists (Select 'billed received shipments'
                        from po_line_locations_all poll1
                        where poll1.po_line_id = pol.po_line_id
                        and ((poll1.accrue_on_receipt_flag = 'Y' and
                  poll1.quantity_received <> 0)
                        or
                        poll1.quantity_billed <> 0))
/* Bug 18372756 */
    and PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, NULL, pol.po_line_id, poll.line_location_id, NULL, NULL, 'PO_AP_DEBIT_MEMO_UNVALIDATED') = 0
    /* End bug 18372756 */
  /* Bug 2725744. Added the condition to check for closed_code
         * and cancel_flag  for the StdPO lines.
        */
        and nvl(pol.closed_code,'OPEN') IN ('OPEN','CLOSED',
                         'CLOSED FOR RECEIVING',
        /* Bug 3334043: Std.POs that are closed by setting 'Invoice Close
         * Tolerance to 100%' should also be picked up
         */
                         'CLOSED FOR INVOICE')
        and nvl(pol.cancel_flag,'N') <> 'Y'
  and nvl(poll.need_by_date,poh.creation_date) >=
    nvl(p_date,nvl(poll.need_by_date,poh.creation_date))
  AND    poh.po_header_id = poha.po_header_id (+)
        AND    poha.latest_external_flag (+) = 'Y'
        AND    pol.order_type_lookup_code not in ('RATE', 'FIXED PRICE') -- Bug 3524527
 --Bug 10011874 Release/SPO should not be updated when there are open receiving transactions
  AND NOT EXISTS (SELECT 'no pending receiving transactions'
                    FROM RCV_TRANSACTIONS_INTERFACE RTI
                   WHERE RTI.po_line_location_id = POLL.line_location_id
                     AND RTI.transaction_status_code = 'PENDING'
                 )
  order by poh.po_header_id
  for update of poll.retroactive_date;

-- <FPJ Retroactive Price START>
--Bug 4176111: Add the paratemeter p_qp_license_on to conditionally enable logic to test retroactive_date
cursor select_all_releases(l_po_line_id number, l_retroactive_date date,p_date date, p_qp_license_on VARCHAR2) is
  select poll.rowid,poll.line_location_id, poll.quantity,
         poll.ship_to_organization_id, poll.ship_to_location_id,
         poll.price_override, nvl(poll.need_by_date,sysdate),
         por.po_release_id,
         por.authorization_status, por.revision_num,
         pora.revision_num
  from po_line_locations poll,
       po_releases_all por,  -- <R12 MOAC>
       po_releases_archive pora
  where  nvl(por.frozen_flag, 'N') = 'N'
  and nvl(por.authorization_status, 'INCOMPLETE') IN
    ('APPROVED', 'INCOMPLETE', 'REJECTED',
     'REQUIRES REAPPROVAL')
  and nvl(por.closed_code,'OPEN') <> 'FINALLY CLOSED'
  and nvl(por.cancel_flag,'N') <> 'Y'
  /* Bug 2725744. Added the condition to check for closed_code
         * and cancel_flag flag for the release shipments.
        */
        and nvl(poll.closed_code,'OPEN') <> 'FINALLY CLOSED'
        and nvl(poll.cancel_flag,'N') <> 'Y'
  and por.po_release_id = poll.po_release_id
  and poll.po_release_id is not null
  and poll.po_line_id = l_po_line_id
  --Bug 4176111: Only when the Advanced Pricing API is not enabled for PO, then use logic of comparing retroactive_date
  --to rule out unneccesary release linelocations
  and ( p_qp_license_on = 'Y' OR
        ( p_qp_license_on = 'N' and nvl(poll.retroactive_date,sysdate) <> l_retroactive_date))  --<R12 GBPA Adv Pricing >
  and nvl(poll.need_by_date,por.creation_date) >=
    nvl(p_date,nvl(poll.need_by_date,por.creation_date))
  AND    POR.po_release_id = PORA.po_release_id (+)
        AND    PORA.latest_external_flag (+) = 'Y'
 --Bug 10011874 Release/SPO should not be updated when there are open receiving transactions
  AND NOT EXISTS (SELECT 'no pending receiving transactions'
                    FROM RCV_TRANSACTIONS_INTERFACE RTI
                   WHERE RTI.po_line_location_id = POLL.line_location_id
                     AND RTI.transaction_status_code = 'PENDING'
                 )
/* Bug 18372756 */
    and NOT EXISTS
               (SELECT 'unvalidated debit memo'
               FROM  PO_HEADERS POH,
                     po_lines POL,
                     po_distributions pod
               WHERE POL.po_line_id = poll.po_line_id
                AND POH.po_header_id = POL.po_header_id
                AND por.po_header_id = poh.po_header_id
                AND pod.line_location_id = poll.line_location_id
                AND pod.po_release_id = por.po_release_id
                AND (poll.quantity_billed = 0 or poll.quantity_billed is null)
                AND PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, por.po_release_id, pol.po_line_id, poll.line_location_id, pod.po_distribution_id, NULL, 'PO_AP_DEBIT_MEMO_UNVALIDATED') = 1
               )
    /* End bug 18372756 */
  order by por.po_release_id
  for update of poll.retroactive_date;

--Bug 4176111: Add the paratemeter p_qp_license_on to conditionally enable logic to test retroactive_date
cursor select_all_stdpo(l_po_line_id number, l_retroactive_date date,
      p_date date, p_qp_license_on VARCHAR2) is
  select  pol.rowid,poll.line_location_id,pol.quantity,
         poll.ship_to_organization_id, poll.ship_to_location_id,
         poll.price_override, nvl(poll.need_by_date,sysdate),
         poh.po_header_id,
         poh.authorization_status, poh.revision_num,
         poha.revision_num
  from po_headers_all poh, po_lines_all pol, po_line_locations_all poll,
       po_headers_archive_all poha, po_document_types_all_b pdt,
             financials_system_params_all fsp
  where pol.from_line_id = l_po_line_id
  and poh.po_header_id = pol.po_header_id
        and poh.org_id = fsp.org_id       -- <R12 MOAC>   -- Bug 3573266
        and nvl(fsp.purch_encumbrance_flag,'N') = 'N'    -- Bug 3573266
        and poh.org_id = pdt.org_id       -- <R12 MOAC> -- Bug 3573266
        and pdt.document_type_code = 'PO'               -- Bug 3573266
        and pdt.document_subtype = 'STANDARD'           -- Bug 3573266
        and (nvl(pdt.archive_external_revision_code,'PRINT') = 'APPROVE'  -- Bug 3573266
         or (not exists (Select 'billed received shipments'   -- Bug 3565522
                        from po_line_locations_all poll1
                        where poll1.po_line_id = pol.po_line_id
                        and ((poll1.accrue_on_receipt_flag = 'Y' and
                  poll1.quantity_received <> 0)
                        or
                        poll1.quantity_billed <> 0))) )
/* Bug 18372756 */
    and PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, NULL, pol.po_line_id, poll.line_location_id, NULL, NULL, 'PO_AP_DEBIT_MEMO_UNVALIDATED') = 0
    /* End bug 18372756 */
        --Bug 4176111: Only when the Advanced Pricing API is not enabled for PO, then use logic of comparing retroactive_date
        --to rule out unneccesary spo linelocations
        and ( p_qp_license_on = 'Y' OR
              ( p_qp_license_on = 'N' and nvl(poll.retroactive_date,sysdate) <> l_retroactive_date))  --<R12 GBPA Adv Pricing >
  and poll.shipment_num = (select min(poll.shipment_num)
         from po_line_locations_all polt
         where polt.po_line_id=pol.po_line_id)
  and  nvl(poh.frozen_flag, 'N') = 'N'
  and nvl(poh.authorization_status, 'INCOMPLETE') IN
    ('APPROVED', 'INCOMPLETE', 'REJECTED',
     'REQUIRES REAPPROVAL')
  and nvl(poh.closed_code,'OPEN') <> 'FINALLY CLOSED'
  and nvl(poh.cancel_flag,'N') <> 'Y'
  and pol.po_line_id = poll.po_line_id
  /* Bug 2725744. Added the condition to check for closed_code
         * and cancel_flag  for the StdPO lines.
        */
        and nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
        and nvl(pol.cancel_flag,'N') <> 'Y'
  and nvl(poll.need_by_date,poh.creation_date) >=
    nvl(p_date,nvl(poll.need_by_date,poh.creation_date))
  AND    poh.po_header_id = poha.po_header_id (+)
        AND    poha.latest_external_flag (+) = 'Y'
        AND    pol.order_type_lookup_code not in ('RATE', 'FIXED PRICE') -- Bug 3524527
 --Bug 10011874 Release/SPO should not be updated when there are open receiving transactions
  AND NOT EXISTS (SELECT 'no pending receiving transactions'
                    FROM RCV_TRANSACTIONS_INTERFACE RTI
                   WHERE RTI.po_line_location_id = POLL.line_location_id
                     AND RTI.transaction_status_code = 'PENDING'
                 )
  order by poh.po_header_id
  for update of poll.retroactive_date;
-- <FPJ Retroactive Price END>

    --<R12 GBPA Adv Pricing Start >

    -- Cursor for open SPOs referencing to the CPA
      -- SQL What: Select only open execution documents refering to a CPA
      -- SQL Why : To be retro actively priced


cursor select_open_contract_exec_docs(l_po_header_id number, p_date date) is
    SELECT
      pol.rowid,
      poll.line_location_id,
      pol.quantity,
      poll.ship_to_organization_id,
      poll.ship_to_location_id,
      poll.price_override,
      nvl(poll.need_by_date,sysdate),
      poh.po_header_id,
      poh.authorization_status,
      poh.revision_num,
      poha.revision_num
  FROM po_headers_all poh,
      po_lines_all pol,
      po_line_locations_all poll,
      po_headers_archive_all poha,
      financials_system_params_all fsp
  WHERE pol.Contract_id = l_po_header_id
      AND pol.from_header_id IS NULL
      AND poh.po_header_id = pol.po_header_id
      AND poh.org_id = fsp.org_id
      AND nvl(fsp.purch_encumbrance_flag,'N') = 'N'
      AND poll.shipment_num =
      (
      SELECT
          min(poll.shipment_num)
      FROM po_line_locations_all polt
      WHERE polt.po_line_id=pol.po_line_id
      )
      AND nvl(poh.frozen_flag, 'N') = 'N'
      AND nvl(poh.authorization_status, 'INCOMPLETE') IN ('APPROVED', 'INCOMPLETE', 'REJECTED', 'REQUIRES REAPPROVAL')
      AND nvl(poh.closed_code,'OPEN') IN ('OPEN','CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED FOR INVOICE')
      AND nvl(poh.cancel_flag,'N') <> 'Y'
      AND nvl(poh.consigned_consumption_flag,'N') ='N'
      AND pol.po_line_id = poll.po_line_id
      AND not exists
      (
      SELECT
          'billed received shipments'
      FROM po_line_locations_all poll1
      WHERE poll1.po_line_id = pol.po_line_id
          AND
          (
              (
                  poll1.accrue_on_receipt_flag = 'Y'
                  AND poll1.quantity_received <> 0
              )
              OR poll1.quantity_billed <> 0
          )
      )
/* Bug 18372756 */
    and PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, NULL, pol.po_line_id, poll.line_location_id, NULL, NULL, 'PO_AP_DEBIT_MEMO_UNVALIDATED') = 0
    /* End bug 18372756 */

      AND nvl(pol.closed_code,'OPEN') IN ('OPEN','CLOSED', 'CLOSED FOR RECEIVING', 'CLOSED FOR INVOICE')
      AND nvl(pol.cancel_flag,'N') <> 'Y'
      AND nvl(poll.need_by_date,poh.creation_date) >= nvl(p_date,nvl(poll.need_by_date,poh.creation_date))
      AND poh.po_header_id = poha.po_header_id (+)
      AND poha.latest_external_flag (+) = 'Y'
      AND pol.order_type_lookup_code not in ('RATE', 'FIXED PRICE')
  ORDER BY poh.po_header_id for UPDATE  of poll.retroactive_date;


-- Cursor for all SPOs referencing to the CPA
      -- SQL What: Select all execution documents refering to a CPA
      -- SQL Why : To be retro actively priced

cursor select_all_contract_exec_docs(l_po_header_id number, p_date date) is
  SELECT
    pol.rowid,
    poll.line_location_id,
    pol.quantity,
    poll.ship_to_organization_id,
    poll.ship_to_location_id,
    poll.price_override,
    nvl(poll.need_by_date,sysdate),
    poh.po_header_id,
    poh.authorization_status,
    poh.revision_num,
    poha.revision_num
FROM po_headers_all poh,
    po_lines_all pol,
    po_line_locations_all poll,
    po_headers_archive_all poha,
    po_document_types_all_b pdt,
    financials_system_params_all fsp
WHERE pol.Contract_id = l_po_header_id
    AND pol.from_header_id IS NULL
    AND poh.po_header_id = pol.po_header_id
    AND poh.org_id = fsp.org_id
    AND nvl(fsp.purch_encumbrance_flag,'N') = 'N'
    AND poh.org_id = pdt.org_id
    AND pdt.document_type_code = 'PO'
    AND pdt.document_subtype = 'STANDARD'
    AND
    (
        nvl(pdt.archive_external_revision_code,'PRINT') = 'APPROVE'
        OR
        (
            not exists
            (
            SELECT
                'billed received shipments'
            FROM po_line_locations_all poll1
            WHERE poll1.po_line_id = pol.po_line_id
                AND
                (
                    (
                        poll1.accrue_on_receipt_flag = 'Y'
                        AND poll1.quantity_received <> 0
                    )
                    OR poll1.quantity_billed <> 0
                )
            )
        )
    )
/* Bug 18372756 */
    and PO_DOCUMENT_CHECKS_PVT.chk_unv_invoices('CREDIT', poh.po_header_id, NULL, pol.po_line_id, poll.line_location_id, NULL, NULL, 'PO_AP_DEBIT_MEMO_UNVALIDATED') = 0
    /* End bug 18372756 */
    AND poll.shipment_num =
    (
    SELECT
        min(poll.shipment_num)
    FROM po_line_locations_all polt
    WHERE polt.po_line_id=pol.po_line_id
    )
    AND nvl(poh.frozen_flag, 'N') = 'N'
    AND nvl(poh.authorization_status, 'INCOMPLETE') IN ('APPROVED', 'INCOMPLETE', 'REJECTED', 'REQUIRES REAPPROVAL')
    AND nvl(poh.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(poh.cancel_flag,'N') <> 'Y'
    AND pol.po_line_id = poll.po_line_id
    AND nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
    AND nvl(pol.cancel_flag,'N') <> 'Y'
    AND nvl(poll.need_by_date,poh.creation_date) >= nvl(p_date,nvl(poll.need_by_date,poh.creation_date))
    AND poh.po_header_id = poha.po_header_id (+)
    AND poha.latest_external_flag (+) = 'Y'
    AND pol.order_type_lookup_code not in ('RATE', 'FIXED PRICE')
ORDER BY poh.po_header_id for UPDATE
    of poll.retroactive_date;

    --<R12 GBPA Adv Pricing End >

cursor update_ship_price is
    SELECT row_id, new_price
    FROM po_retroprice_gt
    WHERE po_release_id is not null;

cursor update_line_price is
    SELECT row_id, new_price, new_base_price --Enhanced Pricing
    FROM po_retroprice_gt
    WHERE po_header_id is not null;


x_item_category_str varchar2(2000);
l_sql_str varchar2(3000);
l_sql_str1 varchar2(3000);
l_sql_str2 varchar2(3000);
l_sql_str3 varchar2(3000);
l_sql_str4 varchar2(3000);
l_sql_str5 varchar2(3000);
l_sql_str6 varchar2(3000);
l_sql_str7 varchar2(3000);
l_sql_str8 varchar2(3000);
l_sql_str9 varchar2(3000);      --<R12 GBPA Adv Pricing >
--Bug 4176111: declare a dynamic query string for retroactive date
l_retro_date_clause varchar2(3000);

l_ga_security varchar2(1);
l_fnd_enabled      varchar2(1);

l_agreement_cur g_agreement_cur_type;


l_po_line_id PO_LINES_ALL.PO_LINE_ID%TYPE;
l_retroactive_date PO_LINES_ALL.retroactive_date%TYPE;
l_global_agreement_flag PO_HEADERS_ALL.global_agreement_flag%TYPE;



l_api_version   CONSTANT NUMBER       := 1.0;
l_api_name      CONSTANT VARCHAR2(30) := 'MassUpdate_Releases';
l_progress varchar2(3);

l_row_id_table char30_table;
l_po_line_loc_table num_table;
l_quantity_table num_table;
l_ship_to_org_id_table num_table;
l_ship_to_location_id_table num_table;
l_old_price_override_table num_table;
l_po_release_id_table num_table;
l_po_header_id_table num_table;
l_po_line_id_table num_table;
l_rev_num_table num_table;
l_archived_rev_num_table num_table;
l_retroactive_date_table date_table;
l_need_by_date_table date_table;
l_global_agreement_flag_table char30_table;
l_auth_status_table char30_table;

l_po_agreement_id_table num_table;   --<R12 GBPA Adv Pricing >

l_temp_new_price_table num_table;
l_temp_new_base_price_table num_table; --Enhanced Pricing
l_temp_row_id_table char30_table;
l_module              VARCHAR2(100);
l_retroactive_update  VARCHAR2(30) := 'NEVER';
l_tax_failure exception;
l_archive_mode_rel     PO_DOCUMENT_TYPES.archive_external_revision_code%TYPE;
l_current_org_id   NUMBER;
l_error_message VARCHAR2(2000);

--Bug 4176111: Variable to show if Adv Pricing API is enabled for PO
l_qp_license 			VARCHAR2(30) := NULL;
l_qp_license_on 			VARCHAR2(240) := NULL;

BEGIN
      --Bug 4176111: Set the variable based on profile value for Adv Pricing API
      FND_PROFILE.get('QP_LICENSED_FOR_PRODUCT',l_qp_license);
      IF (l_qp_license IS NULL OR l_qp_license <> 'PO') THEN
        l_qp_license_on := 'N';
        l_retro_date_clause := 'and pol.retroactive_date is not null ';
      ELSE
        l_qp_license_on := 'Y';
        l_retro_date_clause := '';
      END IF;

        -- Setup for writing the concurrent logs based on
        -- the concurrent log Profile
        IF g_log_mode = 'Y' THEN
          po_debug.set_file_io(TRUE);
        ELSE
          po_debug.set_file_io(null);
        END IF;

        PO_DEBUG.put_line('Starting the Retroactive concurrent Program');

  /* Logic :
   * Get the GA function security to check  whether the user
         * has the function security for Global agreements set up.
         * Fetch all the blanket lines that are
   * retroactively changed and that have releases against them. For
   * each blanket or Global agreement lines, fetch release shipments
   * created against the line and update the shipments with the
   * new price.
  */

  l_module := g_log_head||l_api_name||'.'||'000'||'.';


  -- Standard call to check for call compatibility

        IF (NOT FND_API.Compatible_API_Call(l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,G_PKG_NAME))
        THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize API return status to success

        x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_stmt then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Input Parameters are as below');
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Vendor id: ' || p_vendor_id);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Vendor Site Id: ' || p_vendor_site_id);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Agreement Id: ' || p_po_header_id);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Purchasing Category Structure Id: ' ||
       p_category_struct_id);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Category From: ' || p_category_from);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Category To : ' || p_category_to);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Item From: ' || p_item_from);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Item To: ' || p_item_to);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Date: ' || p_date);
    END IF;
  end if; /*IF g_debug_stmt*/


  -- <FPJ Retroactive START>
  l_retroactive_update := Get_Retro_Mode;
  -- <FPJ Retroactive END>

        PO_DEBUG.put_line('Setting the Retroactive Pricing Mode from Profile');
        PO_DEBUG.put_line('Retro Mode :' || l_retroactive_update);

  IF (l_retroactive_update = 'NEVER') THEN
          PO_DEBUG.put_line('Retroactive Profile is set to Never or Financials patchset is not at the right level');
    RETURN;
  END IF;

  --<ECO 4905804>Removing MANAGE GLOBAL AGREEMENTS FUNCTION
  --Since we are removing the manage global agreement function
  --l_ga_security should by Y</ECO 4905804>

  l_ga_security := 'Y';

        l_current_org_id := PO_GA_PVT.get_current_org;
        -- Bug 3574895. Retroactively updated Releases/Std POs were not getting
        --              communicated to the supplier. Need to set this global
        --              variable here so that we may be able to revert back to
        --              the current org after the org is changed for processing
        --              Global Agreements
        g_orig_org_id := l_current_org_id;
  IF g_debug_stmt then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
      'GA function Security: ' ||l_ga_security);
    END IF;
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                  FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
      'Current OU: ' ||l_current_org_id);
                END IF;

  end if;

  -- <FPJ Retroactive Price START>

  -- Set Communicate Updates Flag
        IF (p_communicate_update = 'Y') THEN
          g_communicate_update := 'Y';
        ELSE
          g_communicate_update := 'N';
        END IF;

  -- <FPJ Retroactive Price END>
        -- Bug 3565522
        -- Get the archive mode for releases to be used later in the code

        l_archive_mode_rel := PO_DOCUMENT_ARCHIVE_PVT.get_archive_mode(
                                      p_doc_type    => 'RELEASE',
                                      p_doc_subtype => 'BLANKET');


  /* Sql to get the blanket lines that have been retroactively
   * changed.
  */
  l_module := g_log_head||l_api_name||'.'||'010'||'.';
        l_sql_str :=    'select poh.po_header_id,pol.po_line_id, pol.retroactive_date, ' ||
                        'poh.global_agreement_flag ' ||
                        'from po_headers_all poh, ' ||
                        'po_lines pol, ' ||
                        'mtl_system_items msi, ' ||
                        'financials_system_params_all fsp, ' ;                 -- <R12 MOAC>
l_sql_str1 :=                   'mtl_categories mca ' ||
                        'where poh.type_lookup_code = ''BLANKET''  ' ||
                        --Bug 4176111: Use a dynamic query string to change the retroactive date clause
                        l_retro_date_clause ||    --<R12 GBPA Adv Pricing >
                        'and pol.po_header_id = ' ;
l_sql_str2 :=           'nvl(:p_po_header_id, pol.po_header_id) ' ||
                        'and pol.po_header_id = poh.po_header_id ' ||
                        'and nvl(pol.price_break_lookup_code '||
                        ' ,''NON CUMULATIVE'') =''NON CUMULATIVE'' ' ;
l_sql_str3:=      'and poh.vendor_id = :p_vendor_id ' ||
                        'and poh.vendor_site_id = ' ||
                        'nvl(:p_vendor_site_id, poh.vendor_site_id) '
      ||'and pol.org_id = poh.org_id '||
      'and pol.org_id = fsp.org_id ';    -- <R12 MOAC>
l_sql_Str4 :=           'and nvl(poh.authorization_status,''INCOMPLETE'') = ''APPROVED'' ' ||
                        'and nvl(poh.frozen_flag, ''N'') = ''N'' ' ||
      'and nvl(poh.consigned_consumption_flag,''N'') =''N'' ';
l_sql_str5 :=           'and pol.item_id = msi.INVENTORY_ITEM_ID (+) ' ||
                        'AND nvl(msi.organization_id, ' ||
                        'fsp.inventory_organization_id)= ' ||
                        'fsp.inventory_organization_id ' ||
                        'AND mca.structure_id = ';
l_sql_str6 :=           'TO_CHAR(:p_category_struct_id) ' ||
                        'and pol.category_id = mca.category_id (+) ' ||
                        ' and (((nvl(poh.global_agreement_flag,''N'') = ''N'') ';
l_sql_str7 :=           ' and exists ' ||
                        ' (select ''has releases'' from ' ||
                        ' po_line_locations  poll where '||
                        ' poll.po_line_id = pol.po_line_id '||
                        ' and poll.po_release_id is not null)) ';
l_sql_str8 :=           '            OR                          ' ||
                        '((nvl(poh.global_agreement_flag,''N'') = ''Y'') '||
                        '         and ' ||
                        '         (:l_ga_security = ''Y'') '||
      ' and exists '||
      '(select ''has stdpo'' from po_lines_all pl where '||
      ' pl.from_line_id = pol.po_line_id))) ' ;
             --<R12 GBPA Adv Pricing Start>
l_sql_str9  :=      '         UNION ALL                       '||
                    'select poh.po_header_id,NULL, ' ||
                    'NULL, poh.global_agreement_flag ' ||
                    'from po_headers poh ' ||
                    'where poh.type_lookup_code = ''CONTRACT''  ' ||
                    'and poh.po_header_id = nvl(:p_po_header_id, poh.po_header_id) ' ||
                    'and poh.vendor_id = :p_vendor_id ' ||
                    'and poh.vendor_site_id = ' ||
                    'nvl(:p_vendor_site_id, poh.vendor_site_id) '||
                    'and nvl(poh.authorization_status,''INCOMPLETE'') = ''APPROVED'' ' ||
                    'and nvl(poh.frozen_flag, ''N'') = ''N'' ' ||
                    'and nvl(poh.consigned_consumption_flag,''N'') =''N'' '||
                    'and exists  ' ||
                    ' ( SELECT ''has stdpo'' FROM po_lines_all pl  '||
                    '    WHERE pl.contract_id = poh.po_header_id ) ';
                 --<R12 GBPA Adv Pricing End>


      /* Dynamically build the item cursor*/

      l_module := g_log_head||l_api_name||
          '.'||'020'||'.';
      PO_RETROACTIVE_PRICING_PVT.Build_Item_Cursor
      ( p_cat_structure_id => p_category_struct_id
      , p_cat_from         => p_category_from
      , p_cat_to           => p_category_to
      , p_item_from        => p_item_from
      , p_item_to          => p_item_to
      , x_item_cursor      => x_item_category_str
      );
      l_sql_str := l_sql_str ||l_sql_str1||l_sql_str2||
          l_sql_str3||l_sql_str4||l_sql_str5||
          l_sql_str6||l_sql_str7 ||l_sql_str8 ||
          x_item_category_str ||
                                        l_sql_str9 ;    --<R12 GBPA Adv Pricing >

          --' order by pol.po_line_id ';   --<R12 GBPA Adv Pricing >

  l_module := g_log_head||l_api_name||'.'||'030'||'.';

          IF g_debug_stmt then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,l_sql_str);
            END IF;
          END IF;

        -- bug2935437
        -- call a procedure to do all var binding and l_agreement_cur opening

        PO_DEBUG.put_line('Getting all the Agreements ');
           open_agreement_cur(p_sql_str            => l_sql_str,
                              p_po_header_id       => p_po_header_id,
                              p_vendor_id          => p_vendor_id,
                              p_vendor_site_id     => p_vendor_site_id,
                              p_category_struct_id => p_category_struct_id,
                              p_ga_security        => l_ga_security,
                              p_item_from          => p_item_from,
                              p_item_to            => p_item_to,
                              p_cat_from           => p_category_from,
                              p_cat_to             => p_category_to,
                              x_cursor             => l_agreement_cur);


/*
  OPEN l_blanket_line_cur FOR l_sql_str using p_po_header_id,
    p_vendor_id, p_vendor_site_id,
    p_category_struct_id,l_ga_security;
*/

        -- bug2935437 end

        LOOP


     --R12 GBPA Adv Pricing: Removed the 9.0 Database check
    FETCH l_agreement_cur BULK COLLECT INTO
    l_po_agreement_id_table,l_po_line_id_table,
    l_retroactive_date_table, l_global_agreement_flag_table
    LIMIT G_BULK_LIMIT;



          IF l_po_agreement_id_table.COUNT = 0 THEN
            l_error_message := 'Did not find any agreements to process. '||
                               'Make sure that the Cumulative Flag on the Blanket '||
                               'Price Breaks is set to OFF. Retro pricing does not '||
                               'work with cumulative price breaks.';
            PO_DEBUG.put_line(l_error_message);
            IF g_debug_stmt then
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module, l_error_message);
              END IF;
            END IF;
          END IF;

    if l_po_agreement_id_table.COUNT <> 0  then

             for i in l_po_agreement_id_table.FIRST..l_po_agreement_id_table.LAST LOOP

         IF g_debug_stmt then
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'l_po_agreement_id_table( ' || i || ')' ||
           l_po_agreement_id_table(i));
     END IF;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'l_po_line_id_table( ' || i || ')' ||
           l_po_line_id_table(i));
     END IF;
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'l_retroactive_date_table( ' || i || ')' ||
           l_retroactive_date_table(i));
           END IF;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'l_global_agreement_flag_table( ' || i ||
              ')' || l_global_agreement_flag_table(i));
     END IF;
         end if;

    l_module := g_log_head||l_api_name||'.'||'040'||'.';

    g_index := 0;
                g_exclude_index := 0;
    g_exclude_row_id_table.delete;
    g_row_id_table.delete;
    g_new_price_table.delete;
    g_new_base_price_table.delete; --Enhanced Pricing
    g_po_header_id_table.delete;
    g_po_release_id_table.delete;
    g_archived_rev_num_table.delete;
    g_auth_status_table.delete;

        if l_po_line_id_table(i) IS NOT NULL  then  -- Blankets

    if (l_global_agreement_flag_table(i) = 'Y') then

                   PO_DEBUG.put_line('Type of agreement being processes: Global Agreement');

       IF g_debug_stmt then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Global Agreement ');
          END IF;
       end if;

                   PO_DEBUG.put_line('Get all Std POs referencing the GA');

             -- <FPJ Retroactive Price START>
             IF (l_retroactive_update = 'OPEN_RELEASES') THEN
         OPEN select_open_stdpo(l_po_line_id_table(i),
                    l_retroactive_date_table(i),
                    p_date,
                    --Bug 4176111: Pass in the variable for Adv Pricing API
                    l_qp_license_on);
       ELSE
         OPEN select_all_stdpo(l_po_line_id_table(i),
                   l_retroactive_date_table(i),
                   p_date,
                   --Bug 4176111: Pass in the variable for Adv Pricing API
                   l_qp_license_on);
       END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */
             -- <FPJ Retroactive Price END>

       loop

             -- <FPJ Retroactive Price START>
             IF (l_retroactive_update = 'OPEN_RELEASES') THEN
         FETCH select_open_stdpo BULK COLLECT INTO
        l_row_id_table,
        l_po_line_loc_table,
        l_quantity_table,
        l_ship_to_org_id_table,
        l_ship_to_location_id_table,
        l_old_price_override_table,
        l_need_by_date_table,
        l_po_header_id_table,
        l_auth_status_table,
        l_rev_num_table,
        l_archived_rev_num_table
        LIMIT G_BULK_LIMIT;
       ELSE
         FETCH select_all_stdpo BULK COLLECT INTO
        l_row_id_table,
        l_po_line_loc_table,
        l_quantity_table,
        l_ship_to_org_id_table,
        l_ship_to_location_id_table,
        l_old_price_override_table,
        l_need_by_date_table,
        l_po_header_id_table,
        l_auth_status_table,
        l_rev_num_table,
        l_archived_rev_num_table
        LIMIT G_BULK_LIMIT;
       END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */
             -- <FPJ Retroactive Price END>

                        IF l_po_header_id_table.COUNT = 0 THEN
                          PO_DEBUG.put_line('Did not find any Std POs');
                          PO_DEBUG.put_line('Check for encumbrance setup and Archive mode in the PO creation OU');
                          PO_DEBUG.put_line('Retroactive Pricing is not supported in encumbered OUs ');
                          PO_DEBUG.put_line('Retroactive Pricing is not supported in OU with archive set to communicate');
                        END IF;

      if l_po_header_id_table.COUNT <> 0  then

          for j in  l_po_header_id_table.FIRST..l_po_header_id_table.LAST LOOP
              IF g_debug_stmt then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              /* Bug 2716741.
             * All the values that were printed below
             * were using the index from the outer
             * loop. It was using i when the index
             * should be using j for the inner index.
             * This was causing a no_data_found error
             * when trying to write the log.
            */
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_row_id_table('
           || j || ')' ||
           l_row_id_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_po_line_loc_table('
           || j || ')' ||
           l_po_line_loc_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_quantity_table('
           || j || ')' ||
           l_quantity_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_ship_to_org_id_table('
           || j || ')' ||
           l_ship_to_org_id_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_ship_to_locn_id_table('
           || j || ')' ||
           l_ship_to_location_id_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_old_price_table('
           || j || ')' ||
           l_old_price_override_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_need_by_date_table('
           || j || ')' ||
           l_need_by_date_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_po_header_id_table('
           || j || ')' ||
           l_po_header_id_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_auth_status_table('
           || j || ')' ||
           l_auth_status_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_rev_num_table('
           || j || ')' ||
           l_rev_num_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_arch_rev_num_table('
           || j || ')' ||
           l_archived_rev_num_table(j));
            END IF;
        end if;


        l_module := g_log_head||l_api_name||
            '.'||'050'||'.';

                                --<R12 GBPA Adv Pricing Changed Call to use named parameters>
                                Process_Price_Change
                                 (p_row_id                  => l_row_id_table(j),
                                  p_document_id             => l_po_header_id_table(j),
                                  p_po_line_location_id     => l_po_line_loc_table(j),
                                  p_retroactive_date        => l_retroactive_date_table(i),
                                  p_quantity                => l_quantity_table(j),
                                  p_ship_to_organization_id => l_ship_to_org_id_table(j),
                                  p_ship_to_location_id     => l_ship_to_location_id_table(j),
                                  p_po_line_id              => l_po_line_id_table(i),
                                  p_old_price_override      => l_old_price_override_table(j),
                                  p_need_by_date            => l_need_by_date_table(j),
                                  p_global_agreement_flag   => l_global_agreement_flag_table(i),
                                  p_authorization_status    => l_auth_status_table(j),
                                  p_rev_num                 => l_rev_num_table(j),
                                  p_archived_rev_num        => l_archived_rev_num_table(j),
                                  p_contract_id             => NULL
                                 );

          end loop; /*l_po_header_id_table.FIRST.*/
         /* This retroactive_date is later used when
          * we run the Concurrent program again. We
          * will not be selecting these Std PO
          * shipments whose retroactive_date is
          * greater than the retroactive_date in
          * po_lines. This means that this PO
                * shipment was processed after the blanket
          * line was changed.
         */
        -- Bulk Update
        l_module := g_log_head||l_api_name||'.'||
              '060'||'.';
        /* Bug 2718565.
         * We need to update po_line_locations_all with
         * time stamp since we process the Std POs
         * against GA in other operating units.
        */
        FORALL processed_index in
             1..l_po_line_loc_table.COUNT
        UPDATE po_line_locations_all
           SET retroactive_date= l_retroactive_date_table(i),
               last_update_date = g_sysdate,
               last_updated_by = g_user_id
         WHERE line_location_id =
          l_po_line_loc_table(processed_index);
      end if; /* l_po_header_id_table.COUNT <> 0 */
      -- <FPJ Retroactive Price START>
      IF (l_retroactive_update = 'OPEN_RELEASES') THEN
        EXIT WHEN select_open_stdpo%NOTFOUND;
      ELSE
        EXIT WHEN select_all_stdpo%NOTFOUND;
      END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */
      -- <FPJ Retroactive Price END>

       end loop; /*select_stdpo */

             -- <FPJ Retroactive Price START>
             IF (l_retroactive_update = 'OPEN_RELEASES') THEN
         CLOSE select_open_stdpo;
       ELSE
         CLOSE select_all_stdpo;
       END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */
             -- <FPJ Retroactive Price END>

                    PO_DEBUG.put_line('Completed Processsing of Std POs ');
                    PO_DEBUG.put_line('If price did not change - Check for encumbrance setup and
                                          Archive mode in the PO creation OU');
                    PO_DEBUG.put_line('Retroactive Pricing is not supported in encumbered OUs ');
                    PO_DEBUG.put_line('Retroactive Pricing of invoiced/Received releases is not supported in OU
                                              with archive set to communicate');

    else

                   PO_DEBUG.put_line('Type of agreement being processed : Blanket Agreement');

             IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,'Blanket Agreement');
      END IF;
       END IF;

                   -- Bug 3573266: Do not continue if the PO encumbrance in the current
                   -- OU is ON
       IF (PO_CORE_S.is_encumbrance_on(p_doc_type => 'RELEASE',
                                                   p_org_id   => l_current_org_id))
                   THEN
                       PO_DEBUG.put_line('Retroactive Pricing is not supported in encumbered OUs ');
                       IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,'Encumbrance ON');
      END IF;
           END IF;

                       EXIT;  -- exit out of blanket line cursor loop
                   END IF;

             -- <FPJ Retroactive Price START>
             IF (l_retroactive_update = 'OPEN_RELEASES')OR
                      (l_retroactive_update = 'ALL_RELEASES' AND
                       l_archive_mode_rel <> 'APPROVE')  -- Bug 3565522
                   THEN

                     PO_DEBUG.put_line('Getting all open releases');
                     PO_DEBUG.put_line('Profile is set to OPEN RELEASES or archive mode is set to communicate');

         OPEN select_open_releases(l_po_line_id_table(i),
                       l_retroactive_date_table(i),
                       p_date,
                       --Bug 4176111: Pass in the variable for Adv Pricing API
                       l_qp_license_on);
       ELSE
                     PO_DEBUG.put_line('Getting all releases including invoiced and received');

         OPEN select_all_releases( l_po_line_id_table(i),
                       l_retroactive_date_table(i),
                       p_date,
                       --Bug 4176111: Pass in the variable for Adv Pricing API
                       l_qp_license_on);
       END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */
             -- <FPJ Retroactive Price END>
       loop

             -- <FPJ Retroactive Price START>
             IF (l_retroactive_update = 'OPEN_RELEASES')OR
                      (l_retroactive_update = 'ALL_RELEASES' AND
                       l_archive_mode_rel <> 'APPROVE')  -- Bug 3565522
                   THEN
         FETCH select_open_releases BULK COLLECT INTO
        l_row_id_table,
        l_po_line_loc_table,
        l_quantity_table,
        l_ship_to_org_id_table,
        l_ship_to_location_id_table,
        l_old_price_override_table,
        l_need_by_date_table,
        l_po_release_id_table,
        l_auth_status_table,
        l_rev_num_table,
        l_archived_rev_num_table
        LIMIT G_BULK_LIMIT;
       ELSE
         FETCH select_all_releases BULK COLLECT INTO
        l_row_id_table,
        l_po_line_loc_table,
        l_quantity_table,
        l_ship_to_org_id_table,
        l_ship_to_location_id_table,
        l_old_price_override_table,
        l_need_by_date_table,
        l_po_release_id_table,
        l_auth_status_table,
        l_rev_num_table,
        l_archived_rev_num_table
        LIMIT G_BULK_LIMIT;
       END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */
             -- <FPJ Retroactive Price END>

      if l_po_release_id_table.COUNT <> 0  then

          for j in  l_po_release_id_table.FIRST..l_po_release_id_table.LAST LOOP
              IF g_debug_stmt then
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              /* Bug 2716741.
             * All the values that were printed below
             * were using the index from the outer
             * loop. It was using i when the index
             * should be using j for the inner index.
             * This was causing a no_data_found error
             * when trying to write the log.
            */
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_row_id_table('
           || j || ')' ||
           l_row_id_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_po_line_loc_table('
           || j || ')' ||
           l_po_line_loc_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_quantity_table('
           || j || ')' ||
           l_quantity_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_ship_to_org_id_table('
           || j || ')' ||
           l_ship_to_org_id_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_ship_to_locn_id_table('
           || j || ')' ||
           l_ship_to_location_id_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_old_price_table('
           || j || ')' ||
           l_old_price_override_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_need_by_date_table('
           || j || ')' ||
           l_need_by_date_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_po_release_id_table('
           || j || ')' ||
           l_po_release_id_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_auth_status_table('
           || j || ')' ||
           l_auth_status_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_rev_num_table('
           || j || ')' ||
           l_rev_num_table(j));
            END IF;
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_arch_rev_num_table('
           || j || ')' ||
           l_archived_rev_num_table(j));
            END IF;
        end if;

        l_module := g_log_head||l_api_name||'.'||
            '070'||'.';
                                --<R12 GBPA Adv Pricing Changed Call to use named parameters>

                                Process_Price_Change
                                 (p_row_id                  => l_row_id_table(j),
                                  p_document_id             => l_po_release_id_table(j),
                                  p_po_line_location_id     => l_po_line_loc_table(j),
                                  p_retroactive_date        => l_retroactive_date_table(i),
                                  p_quantity                => l_quantity_table(j),
                                  p_ship_to_organization_id => l_ship_to_org_id_table(j),
                                  p_ship_to_location_id     => l_ship_to_location_id_table(j),
                                  p_po_line_id              => l_po_line_id_table(i),
                                  p_old_price_override      => l_old_price_override_table(j),
                                  p_need_by_date            => l_need_by_date_table(j),
                                  p_global_agreement_flag   => l_global_agreement_flag_table(i),
                                  p_authorization_status    => l_auth_status_table(j),
                                  p_rev_num                 => l_rev_num_table(j),
                                  p_archived_rev_num        => l_archived_rev_num_table(j),
                                  p_contract_id             => NULL
                                 );


          end loop; /*l_po_release_id_table.FIRST.*/


          l_module := g_log_head||l_api_name||'.'||
            '080'||'.';
         /* This retroactive_date is later used when
          * we run the Concurrent program again. We
          * will not be selecting these Std PO
          * shipments whose retroactive_date is
          * greater than the retroactive_date in
          * po_lines. This means that this PO
                * shipment was processed after the blanket
          * line was changed.
         */
        -- Bulk Update
        FORALL processed_index in
             1..l_po_line_loc_table.COUNT
        UPDATE po_line_locations
           SET retroactive_date= l_retroactive_date_table(i),
               last_update_date = g_sysdate,
               last_updated_by = g_user_id
         WHERE line_location_id =
          l_po_line_loc_table(processed_index);

                                -- Bug 3339149
                                -- Remove the retroactive date for all the rows that
                                -- were excluded for the invalid adj account
                                FORALL exclude_index in
             1..g_exclude_row_id_table.COUNT
        UPDATE po_line_locations
           SET retroactive_date = null,
               last_update_date = g_sysdate,
               last_updated_by = g_user_id
         WHERE rowid = g_exclude_row_id_table(exclude_index);

      end if; /* l_po_release_id_table.COUNT <> 0 */

      -- <FPJ Retroactive Price START>
      IF (l_retroactive_update = 'OPEN_RELEASES')OR
                           (l_retroactive_update = 'ALL_RELEASES' AND
                            l_archive_mode_rel <> 'APPROVE')  -- Bug 3565522
                        THEN
        EXIT WHEN select_open_releases%NOTFOUND;
      ELSE
        EXIT WHEN select_all_releases%NOTFOUND;
      END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */
      -- <FPJ Retroactive Price END>

       end loop;/*select_releases*/

             -- <FPJ Retroactive Price START>
             IF (l_retroactive_update = 'OPEN_RELEASES')OR
                      (l_retroactive_update = 'ALL_RELEASES' AND
                       l_archive_mode_rel <> 'APPROVE')  -- Bug 3565522
                   THEN
         CLOSE select_open_releases;
       ELSE
         CLOSE select_all_releases;
       END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */
             -- <FPJ Retroactive Price END>

                   PO_DEBUG.put_line('Completed Processing blanket releases ');

    end if; /*l_global_agreement_flag = 'Y' */

--<R12 GBPA Adv Pricing Start >
      else   -- Contracts

        IF g_debug_stmt THEN
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,'contract Agreement');
           END IF;
        END IF;

        IF (l_retroactive_update = 'OPEN_RELEASES') THEN
            OPEN select_open_contract_exec_docs(l_po_agreement_id_table(i),
                                                      p_date);
        ELSE
            OPEN select_all_contract_exec_docs(l_po_agreement_id_table(i),
                                                      p_date);
        END IF;

       LOOP


       IF (l_retroactive_update = 'OPEN_RELEASES') THEN
          FETCH select_open_contract_exec_docs BULK COLLECT INTO
                l_row_id_table,
                l_po_line_loc_table,
                l_quantity_table,
                l_ship_to_org_id_table,
                l_ship_to_location_id_table,
                l_old_price_override_table,
                l_need_by_date_table,
                l_po_header_id_table,
                l_auth_status_table,
                l_rev_num_table,
                l_archived_rev_num_table
                LIMIT G_BULK_LIMIT;
      ELSE
          FETCH select_all_contract_exec_docs BULK COLLECT INTO
                l_row_id_table,
                l_po_line_loc_table,
                l_quantity_table,
                l_ship_to_org_id_table,
                l_ship_to_location_id_table,
                l_old_price_override_table,
                l_need_by_date_table,
                l_po_header_id_table,
                l_auth_status_table,
                l_rev_num_table,
                l_archived_rev_num_table
                LIMIT G_BULK_LIMIT;
      END IF;

      IF l_po_header_id_table.COUNT = 0 THEN
          PO_DEBUG.put_line('Did not find any Std POs');
          PO_DEBUG.put_line('Check for encumbrance setup and Archive mode in the PO creation OU');
          PO_DEBUG.put_line('Retroactive Pricing is not supported in encumbered OUs ');
          PO_DEBUG.put_line('Retroactive Pricing is not supported in OU with archive set to communicate');
      END IF;

      if l_po_header_id_table.COUNT <> 0  then

            for j in  l_po_header_id_table.FIRST..l_po_header_id_table.LAST LOOP

                     IF g_debug_stmt then
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_row_id_table(' || j || ')' || l_row_id_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_po_line_loc_table(' || j || ')' || l_po_line_loc_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_quantity_table(' || j || ')' || l_quantity_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_ship_to_org_id_table(' || j || ')' || l_ship_to_org_id_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_ship_to_locn_id_table(' || j || ')' || l_ship_to_location_id_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_old_price_table(' || j || ')' || l_old_price_override_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_need_by_date_table(' || j || ')' || l_need_by_date_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_po_header_id_table(' || j || ')' || l_po_header_id_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_auth_status_table(' || j || ')' || l_auth_status_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_rev_num_table(' || j || ')' || l_rev_num_table(j));
                    END IF;
                    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
                      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
                        l_module,'l_arch_rev_num_table(' || j || ')' || l_archived_rev_num_table(j));
                    END IF;
                end if;


                    l_module := g_log_head||l_api_name||
                                '.'||'084'||'.';
                 --<R12 GBPA Adv Pricingi Changed Call to use named Parameters >
                 Process_Price_Change
                  (p_row_id                  => l_row_id_table(j),
                   p_document_id             => l_po_header_id_table(j),
                   p_po_line_location_id     => l_po_line_loc_table(j),
                   p_retroactive_date        => l_retroactive_date_table(i),
                   p_quantity                => l_quantity_table(j),
                   p_ship_to_organization_id => l_ship_to_org_id_table(j),
                   p_ship_to_location_id     => l_ship_to_location_id_table(j),
                   p_po_line_id              => l_po_line_id_table(i),
                   p_old_price_override      => l_old_price_override_table(j),
                   p_need_by_date            => l_need_by_date_table(j),
                   p_global_agreement_flag   => l_global_agreement_flag_table(i),
                   p_authorization_status    => l_auth_status_table(j),
                   p_rev_num                 => l_rev_num_table(j),
                   p_archived_rev_num        => l_archived_rev_num_table(j),
                   p_contract_id             => l_po_agreement_id_table(i)
                  );

            end loop; /*l_po_header_id_table.FIRST.*/

                -- Bulk Update
                l_module := g_log_head||l_api_name||'.'||
                                        '088'||'.';

                FORALL processed_index in
                     1..l_po_line_loc_table.COUNT
                UPDATE po_line_locations_all
                   SET retroactive_date= l_retroactive_date_table(i),
                       last_update_date = g_sysdate,
                       last_updated_by = g_user_id
                 WHERE line_location_id =
                        l_po_line_loc_table(processed_index);
        end if; /* l_po_header_id_table.COUNT <> 0 */

        IF (l_retroactive_update = 'OPEN_RELEASES') THEN
          EXIT WHEN select_open_contract_exec_docs%NOTFOUND;
        ELSE
          EXIT WHEN select_all_contract_exec_docs%NOTFOUND;
        END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */

     end loop; /*select_stdpo */

     IF (l_retroactive_update = 'OPEN_RELEASES') THEN
         CLOSE select_open_contract_exec_docs;
     ELSE
         CLOSE select_all_contract_exec_docs;
     END IF; /* IF (l_retroactive_update = 'OPEN_RELEASES') */

        PO_DEBUG.put_line('Completed Processsing of Std POs ');
        PO_DEBUG.put_line('If price did not change - Check for encumbrance setup and
                              Archive mode in the PO creation OU');
        PO_DEBUG.put_line('Retroactive Pricing is not supported in encumbered OUs ');
        PO_DEBUG.put_line('Retroactive Pricing of invoiced/Received releases is not supported in OU  with archive set to communicate');
       --<R12 GBPA Adv Pricing End>

    END IF; /* l_po_line_id_table(i) IS NOT NULL */

    /* Insert the values in the temp table po_retroprice_gt
     * for each Blanket Line that we process.
    */
          l_module := g_log_head||l_api_name||'.'||
            '090'||'.';
    FORALL insert_index in 1..g_row_id_table.COUNT
    INSERT into po_retroprice_gt(
      row_id,
      new_price,
      new_base_price, --Enhanced Pricing
      po_header_id,
      po_release_id,
      archived_revision_num,
                        authorization_status)
    VALUES(
      g_row_id_table(insert_index),
      g_new_price_table(insert_index),
      g_new_base_price_table(insert_index), --Enhanced Pricing
      g_po_header_id_table(insert_index),
      g_po_release_id_table(insert_index),
      g_archived_rev_num_table(insert_index),
      g_auth_status_table(insert_index));


       end loop;/*l_po_line_id_table.FIRST */

    end if;/*l_po_line_id_table.COUNT <> 0 */

   exit when l_agreement_cur%notfound;

  END LOOP; /* l_agreement_cur */

  close l_agreement_cur;

  /* Update PO shipments with the new Price */
  -- Bulk Select
  l_module := g_log_head||l_api_name||'.'||'100'||'.';

  OPEN update_ship_price;
  LOOP
    fetch update_ship_price BULK COLLECT INTO
    l_temp_row_id_table,
    l_temp_new_price_table
    LIMIT G_BULK_LIMIT;

      l_module := g_log_head||l_api_name||'.'||'110'||'.';
    if l_temp_row_id_table.COUNT <> 0 then
      FORALL price_update_index in 1..l_temp_row_id_table.COUNT
      UPDATE po_line_locations_all
         SET price_override =
       l_temp_new_price_table(price_update_index),
       calculate_tax_flag = 'Y',
                         manual_price_change_flag = 'N', --<MANUAL PRICE OVERRIDE FPJ>
       last_update_date = g_sysdate,
                   last_updated_by = g_user_id,
       --<R12 eTax Integration Start>
       tax_attribute_update_code =
                      NVL(tax_attribute_update_code,'UPDATE')
       --<R12 eTax Integration End>
      WHERE  rowid =
      l_temp_row_id_table(price_update_index);
    end if; /*l_temp_row_id_table.COUNT <> 0 */
    exit when update_ship_price%notfound;

  END LOOP;
        CLOSE update_ship_price;   /* 2857628 Close the cursor */

  l_module := g_log_head||l_api_name||'.'||'120'||'.';

        OPEN update_line_price;
        LOOP
                fetch update_line_price BULK COLLECT INTO
                l_temp_row_id_table,
                l_temp_new_price_table,
                l_temp_new_base_price_table --Enhanced Pricing
                LIMIT G_BULK_LIMIT;

                  l_module := g_log_head||l_api_name||'.'||'110'||'.';
                if l_temp_row_id_table.COUNT <> 0 then
                  FORALL price_update_index in 1..l_temp_row_id_table.COUNT
                  UPDATE po_lines_all
                     SET unit_price = l_temp_new_price_table(price_update_index),
                         base_unit_price = NVL(l_temp_new_base_price_table(price_update_index)
                                              ,base_unit_price), --Enhanced Pricing
                         manual_price_change_flag = 'N', --<MANUAL PRICE OVERRIDE FPJ>
                         last_update_date = g_sysdate,
                         last_updated_by = g_user_id,
                         --<R12 eTax Integration Start>
                         tax_attribute_update_code = NVL(tax_attribute_update_code,'UPDATE')
                         --<R12 eTax Integration End>
                  WHERE rowid = l_temp_row_id_table(price_update_index);

                FORALL price_update_index in 1..l_temp_row_id_table.COUNT
                UPDATE po_line_locations_all poll
                SET poll.price_override =
                      l_temp_new_price_table(price_update_index),
                    poll.calculate_tax_flag = 'Y',
                    poll.last_update_date = g_sysdate,
                    poll.last_updated_by = g_user_id,
                    --<R12 eTax Integration Start>
                    tax_attribute_update_code =
                                  NVL(tax_attribute_update_code,'UPDATE')
                    --<R12 eTax Integration End>
                  WHERE poll.po_line_id =
                           (select pll.po_line_id
                            from po_lines_all pll where
                            rowid=l_temp_row_id_table(price_update_index));

                end if; /*l_temp_row_id_table.COUNT <> 0 */
                exit when update_line_price%notfound;

        END LOOP;
        CLOSE update_line_price;   /* 2857628 Close the cursor */

  l_module := g_log_head||l_api_name||'.'||'130'||'.';
  g_po_release_id_table.delete;
  g_po_header_id_table.delete;

  PO_RETROACTIVE_PRICING_PVT.WrapUp_Standard_PO;


  l_module := g_log_head||l_api_name||'.'||'140'||'.';
  PO_RETROACTIVE_PRICING_PVT.WrapUp_Releases;

  COMMIT;

  l_module := g_log_head||l_api_name||'.'||'150'||'.';

  PO_RETROACTIVE_PRICING_PVT.Launch_PO_Approval;

  l_module := g_log_head||l_api_name||'.'||'160'||'.';
  PO_RETROACTIVE_PRICING_PVT.Launch_REL_Approval;

        PO_DEBUG.put_line('End of Retroactive Pricing Program');

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
  END IF;
      ROLLBACK;
when l_tax_failure then
  x_return_status := FND_API.G_RET_STS_ERROR;
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
  END IF;
  ROLLBACK;
when no_data_found then
  x_return_status := FND_API.G_RET_STS_ERROR;
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
  END IF;
  ROLLBACK;
when others then
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
  END IF;
        /* Bug 2857628 START */
        if (select_open_releases%ISOPEN) then
     close select_open_releases;
        end if;
        if (select_open_stdpo%ISOPEN) then
     close select_open_stdpo;
        end if;
        /* Bug 2857628 END*/

  -- <FPJ Retroactive Price START>
  IF (select_all_stdpo%ISOPEN) THEN
    CLOSE select_all_stdpo;
  END IF;
  IF (select_all_releases%ISOPEN) THEN
    CLOSE select_all_releases;
  END IF;
  -- <FPJ Retroactive Price END>

  ROLLBACK;

END MASSUPDATE_RELEASES;


/**
 * Private Procedure: Build_Item_Cursor
 * Effects: This procedure builds the item cursor statement.
 *          This statement needs to be built at run time (dynamic SQL)
 *          because of the dynamic nature of the System Item and
 *          Category flexfields. This is called from massupdate_releases.
 * Returns: x_item_cursor - Sql string which contains the WHERE clause
 *          to be used in getting the blanket line that is retroactively
 *          changed.
 */


PROCEDURE Build_Item_Cursor
( p_cat_structure_id IN            NUMBER
, p_cat_from         IN            VARCHAR2
, p_cat_to           IN            VARCHAR2
, p_item_from        IN            VARCHAR2
, p_item_to          IN            VARCHAR2
, x_item_cursor      IN OUT NOCOPY VARCHAR2
)
IS
  l_flexfield_rec  FND_FLEX_KEY_API.flexfield_type;
  l_structure_rec  FND_FLEX_KEY_API.structure_type;
  l_segment_rec    FND_FLEX_KEY_API.segment_type;
  l_segment_tbl    FND_FLEX_KEY_API.segment_list;
  l_segment_number NUMBER;
  l_mstk_segs      VARCHAR2(850);
  l_mcat_segs      VARCHAR2(850);
  l_mcat_f         VARCHAR2(2000);
  l_mcat_w1        VARCHAR2(2000);
  l_mcat_w2        VARCHAR2(2000);
  l_mstk_w         VARCHAR2(2000);
  l_progress     VARCHAR2(3);
l_module              VARCHAR2(100);
l_api_name    CONSTANT VARCHAR2(50) := 'Build_Item_Cursor';
BEGIN

  l_module := g_log_head||l_api_name||'.'||'000'||'.';

  FND_FLEX_KEY_API.set_session_mode('customer_data');

  -- retrieve system item concatenated flexfield
  l_mstk_segs := '';
  l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MSTK');
  l_structure_rec := FND_FLEX_KEY_API.find_structure(l_flexfield_rec, 101);
  FND_FLEX_KEY_API.get_segments
  ( flexfield => l_flexfield_rec
  , structure => l_structure_rec
  , nsegments => l_segment_number
  , segments  => l_segment_tbl
  );
  FOR l_idx IN 1..l_segment_number LOOP
   l_segment_rec := FND_FLEX_KEY_API.find_segment
                   ( l_flexfield_rec
                   , l_structure_rec
                   , l_segment_tbl(l_idx)
                   );
   l_mstk_segs := l_mstk_segs ||'msi.'||l_segment_rec.column_name;
   IF l_idx < l_segment_number THEN

     -- bug2935437
     -- single quotes around segment_separator are needed

     l_mstk_segs := l_mstk_segs|| '||' || '''' ||
                    l_structure_rec.segment_separator || '''' || '||';
   END IF;
  END LOOP;


  -- retrieve item category concatenated flexfield
  l_mcat_segs := '';
  l_flexfield_rec := FND_FLEX_KEY_API.find_flexfield('INV', 'MCAT');
  l_structure_rec := FND_FLEX_KEY_API.find_structure
                     ( l_flexfield_rec
                     , p_cat_structure_id
                     );
  FND_FLEX_KEY_API.get_segments
  ( flexfield => l_flexfield_rec
  , structure => l_structure_rec
  , nsegments => l_segment_number
  , segments  => l_segment_tbl
  );
  FOR l_idx IN 1..l_segment_number LOOP
   l_segment_rec := FND_FLEX_KEY_API.find_segment
                   ( l_flexfield_rec
                   , l_structure_rec
                   , l_segment_tbl(l_idx)
                   );
   l_mcat_segs   := l_mcat_segs ||'mca.'||l_segment_rec.column_name;
   IF l_idx < l_segment_number THEN
     l_mcat_segs := l_mcat_segs||'||'||''''||
                    l_structure_rec.segment_separator||''''||'||';
   END IF;
  END LOOP;


  -- bug2935437
  -- Use Bind variables instead of literals

  IF p_item_from IS NOT NULL AND p_item_to IS NOT NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||' BETWEEN :p_item_from'||
                                          ' AND :p_item_to';
  ELSIF p_item_from IS NOT NULL AND p_item_to IS NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||' >= :p_item_from';
  ELSIF p_item_from IS NULL AND p_item_to IS NOT NULL THEN
    l_mstk_w := ' AND '||l_mstk_segs||' <= :p_item_to';
  ELSE
    l_mstk_w := NULL;
  END IF;
  IF p_cat_from IS NOT NULL AND p_cat_to IS NOT NULL THEN
    l_mcat_w2 := ' AND '||l_mcat_segs||' BETWEEN :p_cat_from'||
                                        ' AND :p_cat_to';
  ELSIF p_cat_from IS NOT NULL AND p_cat_to IS NULL THEN
    l_mcat_w2 := ' AND '||l_mcat_segs||' >= :p_cat_from';
  ELSIF p_cat_from IS NULL AND p_cat_to IS NOT NULL THEN
    l_mcat_w2 := ' AND '||l_mcat_segs||' <= :p_cat_to';
  ELSE
    l_mcat_f  := NULL;
    l_mcat_w2 := NULL;
  END IF;

  -- bug2935437 end

  x_item_cursor := l_mstk_w  || l_mcat_w2;
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,'x_item_cursor: ' ||
   x_item_cursor);
  END IF;
exception
when others then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
  END IF;

raise;
end BUILD_ITEM_CURSOR;

/**
 * Private Procedure: WrapUp_Releases
 * Modifies: authorization_Status and revision_num in po_releases.
 * Effects: If any release shipment is updated with the new price, then
 *          revision_num must be incremented and authorization_Status
 *          has to be updated to Requires approval if the status is
 *          Approved. This is called from massupdate_releases procedure.
 */

PROCEDURE WrapUp_Releases IS

l_global_arch_rev_num_table num_table;
l_row_id_table char30_table;

l_progress         varchar2(3);
l_module              VARCHAR2(100);
l_api_name    CONSTANT VARCHAR2(50) := 'WrapUp_Releases';
x_tax_status    VARCHAR2(10);
l_encode varchar2(2000);
l_error_message varchar2(2000);
l_tax_failure exception;

-- <FPJ Retroactive START>
l_consigned_flag_tbl  po_tbl_varchar1;
-- <FPJ Retroactive END>
l_return_status VARCHAR(1); --<R12 eTax Integration>
begin

        -- Setup for writing the concurrent logs based on
        -- the concurrent log Profile
        IF g_log_mode = 'Y' THEN
          po_debug.set_file_io(TRUE);
        ELSE
          po_debug.set_file_io(null);
        END IF;

  /* Increment Document Revision */
  -- Bulk Select
  l_module := g_log_head||l_api_name||'.'||'000'||'.';
  SELECT distinct po_release_id,
    nvl(authorization_status,'INCOMPLETE'),
    nvl(archived_revision_num,-999)
  BULK COLLECT INTO
    g_po_release_id_table,
    g_rel_auth_table,
    l_global_arch_rev_num_table
        FROM po_retroprice_gt prp
  WHERE  prp.po_release_id is not null;

  --
  -- Calculate Tax for updated Releases
  -- insert errors into debug log if any
  --
  IF (g_po_release_id_table.COUNT > 0) THEN
   FOR i IN g_po_release_id_table.first..g_po_release_id_table.LAST LOOP
    -- <R12 eTax Integration Start>
    l_return_status := NULL;
    IF g_debug_stmt then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
          'Callin Tax for Release ID  ' || g_po_release_id_table(i));
      END IF;
    END IF;
    po_tax_interface_pvt.calculate_tax(p_po_header_id    => NULL,
                                       p_po_release_id   => g_po_release_id_table(i),
                                       p_calling_program => 'PO_POXRPRIB_REL',
                                       x_return_status   => l_return_status);
    IF g_debug_stmt then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
          'Callin Tax : Return Status ' ||l_return_status);
      END IF;
    END IF;
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE l_tax_failure;
    END IF;
    -- <R12 eTax Integration End>
   END LOOP;
  END IF;

  -- Bulk Update
  /* Bug 2714259.
   * In addition to making authorization_status to Requires Reapproval,
   * we need to make the approved_flag in po_headers and the last
   * updated columns.
  */
          -- Bug 5168776 Update the Revised Date also
  l_module := g_log_head||l_api_name||'.'||'010'||'.';
  FORALL doc_update_index in 1..g_po_release_id_table.COUNT
        UPDATE po_releases por
           SET por.revision_num = decode(por.revision_num,
          l_global_arch_rev_num_table(doc_update_index),
          por.revision_num +1,por.revision_num),
          por.revised_date = decode(por.revision_num,
                                  l_global_arch_rev_num_table(doc_update_index),
                                  sysdate,por.revised_date),
         por.authorization_status = decode(por.authorization_status,
            'APPROVED', 'REQUIRES REAPPROVAL',
            por.authorization_status),
         por.approved_flag = decode(por.authorization_status,
          'APPROVED','R',por.approved_flag),
         por.last_update_date = g_sysdate,
         por.last_updated_by = g_user_id
  WHERE po_release_id = g_po_release_id_table(doc_update_index);


  /* Bug 2714259.
   * Update approved_flag to 'R', last_update_date and
   * last_updated_by columns in po_line_locations for which
   * the price has been updated .
  */
  l_module := g_log_head||l_api_name||'.'||'020'||'.';
  SELECT  row_id
  BULK COLLECT INTO
    l_row_id_table
        FROM po_retroprice_gt prp
  WHERE  prp.po_release_id is not null
  and nvl(authorization_status,'INCOMPLETE') = 'APPROVED';

  l_module := g_log_head||l_api_name||'.'||'030'||'.';
  FORALL release_update_index in 1..l_row_id_table.COUNT
        UPDATE po_line_locations poll
           SET poll.approved_flag = 'R',
         poll.last_update_date = g_sysdate,
         poll.last_updated_by = g_user_id
  WHERE rowid = l_row_id_table(release_update_index);

exception
when l_tax_failure then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
  END IF;
raise;
when no_data_found then
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
     /* No error since there need not be any rows in temp table */
  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
   END IF;
when others then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
  END IF;
raise;

end WrapUp_Releases;



/**
 * Private Procedure: WrapUp_Standard_PO
 * Modifies: authorization_Status and revision_num in po_headers.
 * Effects: If any release shipment is updated with the new price, then
 *          revision_num must be incremented and authorization_Status
 *          has to be updated to Requires approval if the status is
 *          Approved. This is called from massupdate_releases procedure.
 */

PROCEDURE WrapUp_Standard_PO IS

l_global_arch_rev_num_table num_table;
l_row_id_table char30_table;

l_progress         varchar2(3);
l_module              VARCHAR2(100);
l_api_name    CONSTANT VARCHAR2(50) := 'WrapUp_Standard_PO';
x_tax_status    VARCHAR2(10);
l_encode varchar2(2000);
l_error_message varchar2(2000);
l_doc_org_id number;
l_tax_failure exception;
l_return_status VARCHAR(1); --<R12 eTax Integration>
begin
        -- Setup for writing the concurrent logs based on
        -- the concurrent log Profile
        IF g_log_mode = 'Y' THEN
          po_debug.set_file_io(TRUE);
        ELSE
          po_debug.set_file_io(null);
        END IF;

  /* Increment Document Revision */

  -- Bulk Select
  l_module := g_log_head||l_api_name||'.'||'000'||'.';
  SELECT distinct po_header_id,
    nvl(authorization_status,'INCOMPLETE'),
    archived_revision_num
  BULK COLLECT INTO
    g_po_header_id_table,
    g_po_auth_table,
    l_global_arch_rev_num_table
        FROM po_retroprice_gt prp
  WHERE  prp.po_header_id is not null;

  --
  -- Calculate Tax for updated Releases
  -- insert errors into debug log if any
  --
  IF (g_po_header_id_table.COUNT > 0) THEN
   FOR i IN g_po_header_id_table.first..g_po_header_id_table.LAST LOOP
     -- <R12 eTax Integration Start>
     l_return_status := NULL;
     IF g_debug_stmt then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
          'Callin Tax : PO HEADER ID  ' ||g_po_header_id_table(i));
      END IF;
     END IF;
     po_tax_interface_pvt.calculate_tax(p_po_header_id    => g_po_header_id_table(i),
                                        p_po_release_id   => NULL,
                                        p_calling_program => 'PO_POXRPRIB_PO',
                                        x_return_status   => l_return_status);
    IF g_debug_stmt then
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
          'Callin Tax : Return Status ' ||l_return_status);
      END IF;
    END IF;
    IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE l_tax_failure;
    END IF;
     -- <R12 eTax Integration End>
   END LOOP;
  END IF;

  -- Bulk Update
  /* Bug 2714259.
   * In addition to making authorization_status to Requires Reapproval,
   * we need to make the approved_flag in po_headers and the last updated
   * columns.
  */
            -- Bug 5168776 Update the Revised Date also
  FORALL doc_update_index in 1..g_po_header_id_table.COUNT
        UPDATE po_headers_all poh
           SET poh.revision_num = decode(poh.revision_num,
          l_global_arch_rev_num_table(doc_update_index),
          poh.revision_num +1,poh.revision_num),
               poh.revised_date = decode(poh.revision_num,
                                  l_global_arch_rev_num_table(doc_update_index),
                                  sysdate, poh.revised_date ),
         poh.authorization_status = decode(poh.authorization_status,
            'APPROVED', 'REQUIRES REAPPROVAL',
            poh.authorization_status),
         poh.approved_flag = decode(poh.authorization_status,
          'APPROVED','R',poh.approved_flag),
         poh.last_update_date = g_sysdate,
         poh.last_updated_by = g_user_id
  WHERE po_header_id = g_po_header_id_table(doc_update_index);

  /* Bug 2714259.
   * Update approved_flag to 'R', last_update_date and
   * last_updated_by columns in po_line_locations for which
   * the price has been updated .
  */
  l_module := g_log_head||l_api_name||'.'||'020'||'.';
  SELECT  row_id
  BULK COLLECT INTO
    l_row_id_table
        FROM po_retroprice_gt prp
  WHERE  prp.po_header_id is not null
  and nvl(authorization_status,'INCOMPLETE') = 'APPROVED';

  l_module := g_log_head||l_api_name||'.'||'030'||'.';
  FORALL ship_update_index in 1..l_row_id_table.COUNT
  UPDATE po_line_locations_all poll
  SET poll.approved_flag = 'R',
      poll.last_update_date = g_sysdate,
      poll.last_updated_by = g_user_id
    WHERE poll.po_line_id =
       (select pll.po_line_id
        from po_lines_all pll where
        rowid=l_row_id_table(ship_update_index));

exception
when l_tax_failure then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
  END IF;
raise;
when no_data_found then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    /* No error since there need not be any rows in the temp table*/
  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
  END IF;
when others then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
  END IF;
raise;

end WrapUp_Standard_PO;

/**
 * Private Procedure: Process_Price_Change
 * Modifies: updates the global variables with the release_id, revision_num
 * from the archive table, authorization_status, row_id of the
 * po_line_locations to be updated and the new price if it is different
 * from the old price.
 * Effects: Get the new price for the release shipment attributes and if
 * different update the global variables.This is called from
 * massupdate_releases procedure.
 */

PROCEDURE Process_Price_Change
 (p_row_id        IN VARCHAR2,
  p_document_id                         IN NUMBER,
  p_po_line_location_id                 IN NUMBER,
  p_retroactive_date                    IN DATE,
  p_quantity                            IN NUMBER,
  p_ship_to_organization_id             IN NUMBER,
  p_ship_to_location_id                 IN NUMBER,
  p_po_line_id                          IN NUMBER,
  p_old_price_override                  IN NUMBER,
  p_need_by_date                        IN DATE,
  p_global_agreement_flag               IN VARCHAR2,
  p_authorization_status    IN VARCHAR2,
  p_rev_num                             IN Number,
  p_archived_rev_num                    IN Number,
  p_contract_id                         IN NUMBER) IS    --<R12 GBPA Adv Pricing >

l_new_price_override number;
l_cumulative_flag boolean :=FALSE;
l_progress     VARCHAR2(3);
l_module              VARCHAR2(100);
l_api_name    CONSTANT VARCHAR2(50) := 'Process_Price_Change';
l_error_message       varchar2(2000);
l_std_po_price_change VARCHAR2(1);
l_retroactive_update  VARCHAR2(30) := 'NEVER';
l_po_line_id   PO_LINES_ALL.po_line_id%TYPE;
l_enhanced_pricing_flag VARCHAR2(1); --Enhanced Pricing

--<R12 GBPA Adv Pricing Start>
   l_quantity                    PO_LINES.quantity%TYPE;
   l_ship_to_location_id         PO_LINE_LOCATIONS.ship_to_location_id%TYPE;
   l_ship_to_org_id              PO_LINE_LOCATIONS.ship_to_organization_id%TYPE;
   l_need_by_date                PO_LINE_LOCATIONS.need_by_date%TYPE;
   l_from_line_id                PO_LINES.from_line_id%TYPE;
   l_org_id                      po_lines.org_id%TYPE;
   l_contract_id                 po_lines.contract_id%TYPE;
   l_order_header_id             po_lines.po_header_id%TYPE;
   l_order_line_id               po_lines.po_line_id%TYPE;
   l_creation_date               po_lines.creation_date%TYPE;
   l_item_id                     po_lines.item_id%TYPE;
   l_item_revision               po_lines.item_revision%TYPE;
   l_category_id                 po_lines.category_id%TYPE;
   l_line_type_id                po_lines.line_type_id%TYPE;
   l_vendor_product_num          po_lines.vendor_product_num%TYPE;
   l_vendor_id                   po_headers.vendor_id%TYPE;
   l_vendor_site_id              po_headers.vendor_site_id%TYPE;
   l_uom                         po_lines.unit_meas_lookup_code%TYPE;
   l_in_unit_price               po_lines.unit_price%TYPE;
   l_base_unit_price             po_lines.base_unit_price%TYPE;
   l_currency_code               po_headers.currency_code%TYPE;
   l_return_status               VARCHAR2(1);

   x_base_unit_price             NUMBER ;
   x_price_break_id              NUMBER ;
  --<R12 GBPA Adv Pricing End>
begin
        -- Setup for writing the concurrent logs based on
        -- the concurrent log Profile
        IF g_log_mode = 'Y' THEN
          po_debug.set_file_io(TRUE);
        ELSE
          po_debug.set_file_io(null);
        END IF;



  l_module := g_log_head||l_api_name||'.'||'000'||'.';

        -- Bug 3339149 Start

     IF p_po_line_id is NOT NULL THEN

        IF p_global_agreement_flag = 'Y' THEN

           select po_line_id
           into l_po_line_id
           from po_line_locations_all
           where line_location_id = p_po_line_location_id ;

           l_std_po_price_change := 'Y';

        ELSE
           l_std_po_price_change := 'N';
        END IF;

     ELSE -- Contracts

            l_std_po_price_change := 'Y';
             select po_line_id
            into l_po_line_id
            from po_line_locations_all
            where line_location_id = p_po_line_location_id ;


     END IF;


        l_retroactive_update := Get_Retro_Mode;

        -- Bug 4080732 START
        -- For a consigned flow, check that the Inventory Org Period is open,
        -- before updating the price on the consumption advice. For this check,
        -- we get the Inv Org from the ship-to-org at the shipment level (for
        -- regular flows). And for Shared Procuremnet scenario, we use the
        -- logical inv org of the transaction flow.
        IF (l_retroactive_update = 'ALL_RELEASES') AND
           (is_inv_org_period_open(l_std_po_price_change,
                                   l_po_line_id,
                                   p_po_line_location_id) = 'N')
        THEN
           l_error_message := 'Can not retroactively update price on a consumption '||
                              'advice, since the Inventory Org period is not open.';

           IF g_debug_stmt then
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
               FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module, l_error_message);
             END IF;
           END IF;

           PO_DEBUG.put_line(l_error_message);

           g_exclude_index := g_exclude_index + 1;
           g_exclude_row_id_table(g_exclude_index) := p_row_id ;

           RETURN;

        END IF;
        -- Bug 4080732 END

        IF l_retroactive_update = 'ALL_RELEASES'
        AND (Is_Adjustment_Account_Valid(l_std_po_price_change,
                                        l_po_line_id,
                                        p_po_line_location_id) = 'N')
        THEN

           FND_MESSAGE.set_name('PO', 'PO_RETRO_PRICING_NOT_ALLOWED');
     l_error_message := FND_MESSAGE.get;
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,l_module,l_error_message);
     END IF;
           PO_DEBUG.put_line(l_error_message);

           g_exclude_index := g_exclude_index + 1;
           g_exclude_row_id_table(g_exclude_index) := p_row_id ;

           Return;

        END IF;
        -- Bug 3339149 End

        -- Bug 3231062 START
        IF (l_retroactive_update = 'ALL_RELEASES' AND
            (Is_Retro_Project_Allowed(l_std_po_price_change,
                                      l_po_line_id,
                                      p_po_line_location_id) = 'N'))
        THEN
     IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,l_module,
       'Can not update price since project 11i10 is not enabled');
     END IF;
           PO_DEBUG.put_line('Can not update price since project 11i10 is not enabled');

           g_exclude_index := g_exclude_index + 1;
           g_exclude_row_id_table(g_exclude_index) := p_row_id ;

           Return;

        END IF; /*IF (l_retroactive_update = 'ALL_RELEASES' AND*/
        -- Bug 3231062 END


        --<R12 GBPA Adv Pricing Start>
        IF g_debug_stmt then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
             FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module, 'intialising Get Price Break Call');
           END IF;
         END IF;

     if (l_std_po_price_change = 'Y') then
     --Bug5469245: Use Tables Instead of Synonyms for global procurement support
        SELECT NVL(p_quantity,POL.quantity),
           POL.from_line_id,
           NVL(p_ship_to_location_id, PLL.ship_to_location_id),
           NVL(p_need_by_date, NVL(PLL.need_by_date, sysdate)),
           NVL(p_ship_to_organization_id,PLL.ship_to_organization_id),
           POL.org_id,
           POL.contract_id,
           POL.po_header_id,
           POL.po_line_id,
           POL.creation_date,
           POL.item_id,
           POL.item_revision,
           POL.category_id,
           POL.line_type_id,
           POL.vendor_product_num,
           POH.vendor_id,
           POH.vendor_site_id,
           POL.unit_meas_lookup_code,
           POL.base_unit_price,
           POH.currency_code
        INTO   l_quantity,
           l_from_line_id,
           l_ship_to_location_id,
           l_need_by_date,
           l_ship_to_org_id,
           l_org_id,
           l_contract_id,
           l_order_header_id,
           l_order_line_id,
           l_creation_date,
           l_item_id,
           l_item_revision,
           l_category_id,
           l_line_type_id,
           l_vendor_product_num,
           l_vendor_id,
           l_vendor_site_id,
           l_uom,
           l_in_unit_price,
           l_currency_code
        FROM   po_line_locations_all PLL, po_lines_all POL,
           po_headers_all POH
        WHERE  PLL.line_location_id = p_po_line_location_id
        AND    POL.po_line_id = PLL.po_line_id
        AND    POH.po_header_id = POL.po_header_id;

        IF g_debug_stmt then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
             FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module, 'Call get price break API ');
           END IF;
        END IF;

        PO_SOURCING2_SV.get_break_price
           (  p_api_version          => 1.0
           ,  p_order_quantity       => l_quantity
           ,  p_ship_to_org          => l_ship_to_org_id
           ,  p_ship_to_loc          => l_ship_to_location_id
           ,  p_po_line_id           => l_from_line_id
           ,  p_cum_flag             => FALSE
           ,  p_need_by_date         => l_need_by_date
           ,  p_line_location_id     => p_po_line_location_id
           ,  p_contract_id          => l_contract_id
           ,  p_org_id               => l_org_id
           ,  p_supplier_id          => l_vendor_id
           ,  p_supplier_site_id     => l_vendor_site_id
           ,  p_creation_date        => l_creation_date
           ,  p_order_header_id      => l_order_header_id
           ,  p_order_line_id        => l_order_line_id
           ,  p_line_type_id         => l_line_type_id
           ,  p_item_revision        => l_item_revision
           ,  p_item_id              => l_item_id
           ,  p_category_id          => l_category_id
           ,  p_supplier_item_num    => l_vendor_product_num
           ,  p_in_price             => l_in_unit_price
           ,  p_uom                  => l_uom
           ,  p_currency_code        => l_currency_code
           --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
           ,  p_pricing_call_src     => 'RETRO' --Enhanced Pricing
           ,  x_base_unit_price      => x_base_unit_price
           ,  x_price_break_id       => x_price_break_id
           ,  x_price                => l_new_price_override
           ,  x_return_status        => l_return_status
           );

       --<R12 GBPA Adv Pricing End>

       ELSE

        IF g_debug_stmt then
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
             FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module, 'Call get price break API:old call ');
           END IF;
        END IF;

        /*<Enhanced Pricing Start: Replaced with overloaded API to retrieve base_unit_price>
        l_new_price_override := po_sourcing2_sv.get_break_price(
            p_quantity,
            p_ship_to_organization_id,
            p_ship_to_location_id,
            p_po_line_id,
            l_cumulative_flag,
            p_need_by_date,
            p_po_line_location_id,
            'RETRO'
           );
         */

      PO_SOURCING2_SV.get_break_price
        ( p_order_quantity   => p_quantity
        , p_ship_to_org      => p_ship_to_organization_id
        , p_ship_to_loc      => p_ship_to_location_id
        , p_po_line_id       => p_po_line_id
        , p_cum_flag         => l_cumulative_flag
        , p_need_by_date     => p_need_by_date
        , p_line_location_id => p_po_line_location_id
        --Bug:8598002 renamed p_retro_pricing to p_pricing_call_src, to distinguish calls from retro and auto creation
        , p_pricing_call_src => 'RETRO'
        , x_price            => l_new_price_override
        , x_base_unit_price  => x_base_unit_price
        );
     --<Enhanced Pricing End>
      END IF;    -- if (l_std_po_price_change = 'Y') then

  IF g_debug_stmt then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'l_new_price_override'||
     l_new_price_override);
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,
          l_module,'p_old_price_override' ||
     p_old_price_override);
    END IF;
  end if;

  if (l_new_price_override <> p_old_price_override) then
    l_module := g_log_head||l_api_name||'.'||'010'||'.';
    g_index := g_index + 1;
    g_row_id_table(g_index) := p_row_id ;
    g_new_price_table(g_index) := l_new_price_override ;

    --Enhanced Pricing Start: Base Price change will only be considered if the unit price is overridden
    BEGIN
      SELECT DISTINCT STL.enhanced_pricing_flag
      INTO l_enhanced_pricing_flag
      FROM PO_DOC_STYLE_HEADERS STL,
           PO_HEADERS_ALL HDR,
           PO_LINES_ALL LIN
      WHERE LIN.po_line_id = l_po_line_id
      AND   LIN.po_header_id = HDR.po_header_id
      AND   HDR.style_id = STL.style_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_enhanced_pricing_flag := 'N';
    END;

    IF (l_enhanced_pricing_flag = 'Y') THEN
      g_new_base_price_table(g_index) := x_base_unit_price;
    ELSE
      g_new_base_price_table(g_index) := null;
    END IF;
    --Enhanced Pricing End

    g_auth_status_table(g_index) := p_authorization_status ;
    g_archived_rev_num_table(g_index) := p_archived_rev_num;

    if (l_std_po_price_change = 'Y') then
             g_po_header_id_table(g_index) := p_document_id ;
             g_po_release_id_table(g_index) := null ;
    else
             g_po_release_id_table(g_index) := p_document_id ;
             g_po_header_id_table(g_index) := null ;
    end if; /*l_std_po_price_change= 'Y' */

  end if; /* l_new_price_override <> l_old_price_override*/


exception
when others then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
  END IF;
raise;

end Process_Price_Change;


/**
 * Private Procedure: Launch_PO_Approval
 * Modifies: Authorization_status of po_headers if the document was
 *           already approved.
 * Effects: Get the po_header_id from the global temp table po_retroprice_gt
 *          which has all the document ids that have been updated with
 *          new price. If the document is in the approved state, then
 *          call submission_check and if it is successful, initiate
 *          approval. This is called from massupdate_releases procedure.
 */

PROCEDURE Launch_PO_Approval IS
l_progress varchar2(3);
l_module              VARCHAR2(100);
l_api_name    CONSTANT VARCHAR2(50) := 'Launch_PO_Approval';
l_msg_buf varchar2(2000);
x_return_status varchar2(1);
x_sub_check_status varchar2(1);
x_msg_data varchar2(2000);
x_online_report_id number;
x_msg_count number;
l_doc_org_id number;
-- Bug 3318625
l_consigned_flag PO_HEADERS_ALL.consigned_consumption_flag%TYPE;
x_text_line po_online_report_text.text_line%TYPE; --Bug9040655
max_sequence_num po_online_report_text.sequence%TYPE; --Bug9040655
begin

  l_module := g_log_head||l_api_name||'.'||'000'||'.';
  /* Bug 2707350.
         * Org context needs to be set for the submission check procedure.
   * Get the orig org_id and then for each document that will be sent
   * sent for submission check, get the org_id from po_headers_all.
   * Set the org context using this org_id and if submission check
   * is successful, initiate approval.  When all documents are done
   * set the original org context.
  */

      if (g_po_header_id_table.count > 0) then
  for i in g_po_header_id_table.first..g_po_header_id_table.LAST loop

          -- Bug 3318625, Re-approve 'REQUIRES REAPPROVAL' Consumption Advices
    -- if (g_po_auth_table(i) ='APPROVED') then
    if (g_po_auth_table(i) in ('APPROVED', 'REQUIRES REAPPROVAL')) then

      select org_id,
       NVL(consigned_consumption_flag, 'N') -- Bug 3318625
      into   l_doc_org_id,
             l_consigned_flag -- Bug 3318625
      from   po_headers_all
      where  po_header_id = g_po_header_id_table(i);

      -- Bug 3318625 START
      IF (g_po_auth_table(i) = 'APPROVED' OR
          (g_po_auth_table(i) = 'REQUIRES REAPPROVAL' AND
    l_consigned_flag = 'Y'))
      THEN
      -- Bug 3318625 END

                PO_MOAC_UTILS_PVT.set_org_context(l_doc_org_id) ;       -- <R12 MOAC>

    PO_DOCUMENT_CHECKS_GRP.po_submission_check(
      p_api_version => 1.0,
      p_action_requested => 'DOC_SUBMISSION_CHECK',
      p_document_type => 'PO',
      p_document_subtype => 'STANDARD',
      p_document_id => g_po_header_id_table(i),
      x_return_status => x_return_status,
      x_sub_check_status => x_sub_check_status,
      x_msg_data => x_msg_data,
      x_online_report_id => x_online_report_id);

    /* For FND_LOG level, using LEVEL_EXCEPTION since these
     * are really exception that happened but we are not
     * erroring out here but just logging it and then continue
     * trying to submit next document for approval.
    */

    If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_msg_buf := null;
             l_msg_buf := FND_MSG_PUB.Get(p_msg_index => 1,
                   p_encoded   => 'F');
      l_msg_buf := 'Std PO ' ||g_po_header_id_table(i)||
          l_msg_buf;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
            l_module,l_msg_buf);
             END IF;
    end if;
    If ((x_return_status = FND_API.G_RET_STS_SUCCESS) and
        (x_sub_check_status = FND_API.G_RET_STS_ERROR)) THEN

      l_msg_buf := 'Std PO: ' ||g_po_header_id_table(i)||
          ' Online Report Id: '||x_online_report_id;
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,l_msg_buf);

	  END IF;
    --<Bug9040655 START Added code to display the submission check failure message on the log file>
    PO_DEBUG.put_line('submission check failed for PO id '
    ||TO_CHAR(g_po_header_id_table(i)));
    PO_DEBUG.put_line('Reason(s) :');
    SELECT MAX(sequence)
    INTO   max_sequence_num
    FROM   po_online_report_text_gt
    WHERE  online_report_id = x_online_report_id ;

    FOR i IN 1..max_sequence_num
    LOOP
            SELECT text_line
            INTO   x_text_line
            FROM   po_online_report_text_gt
            WHERE  online_report_id = x_online_report_id
            AND    sequence     = i;

            PO_DEBUG.put_line(x_text_line);
    END LOOP;

    --<Bug9040655 END>
    end if;
    l_module := g_log_head||l_api_name||'.'||'010'||'.';

    If ((x_return_status = FND_API.G_RET_STS_SUCCESS) and
        (x_sub_check_status = FND_API.G_RET_STS_SUCCESS)) THEN

      PO_RETROACTIVE_PRICING_PVT.Retroactive_Launch_Approval
        ( p_doc_id      =>  g_po_header_id_table(i),
         p_doc_type     => 'PO',
       p_doc_subtype  => 'STANDARD');
    end if;

      -- Bug 3318625
      END IF; /* if (g_po_auth_table(i) = 'APPROVED' OR */

          end if; /*if (g_po_auth_table(i) in ('APPROVED', 'REQUIRES REAPPROVAL')) */

  end loop; /* l_global_document_id_table.first */
      end if;/*g_po_header_id_table.count > 0 */

      PO_MOAC_UTILS_PVT.set_org_context(g_orig_org_id) ;       -- <R12 MOAC>
exception
when no_data_found then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
    END IF;
          raise;
when others then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
  END IF;
raise;

end Launch_PO_Approval;


/**
 * Private Procedure: Launch_REL_Approval
 * Modifies: Authorization_status of po_releases if the document was
 *           already approved.
 * Effects: Get the po_release_id from the global temp table po_retroprice_gt
 *          which has all the document ids that have been updated with
 *          new price. If the document is in the approved state, then
 *          call submission_check and if it is successful, initiate
 *          approval. This is called from massupdate_releases procedure.
 */

PROCEDURE Launch_REL_Approval IS
l_progress varchar2(3);
l_module              VARCHAR2(100);
l_api_name    CONSTANT VARCHAR2(50) := 'Launch_REL_Approval';
l_msg_buf varchar2(2000);
x_return_status varchar2(1);
x_sub_check_status varchar2(1);
x_msg_data varchar2(2000);
x_online_report_id number;
-- Bug 3318625
l_consigned_flag PO_RELEASES_ALL.consigned_consumption_flag%TYPE;
x_text_line po_online_report_text.text_line%TYPE; --Bug9040655
max_sequence_num po_online_report_text.sequence%TYPE; --Bug9040655
begin

  /* Get po_header_id for the documents that are in the Approved STate.
   * Call submission checks and initiate approval.
  */
  l_module := g_log_head||l_api_name||'.'||'000'||'.';

      if (g_po_release_id_table.count > 0) then
  for i in g_po_release_id_table.first..g_po_release_id_table.LAST loop

          -- Bug 3318625 START
          -- Re-approve 'REQUIRES REAPPROVAL' Consumption Advices
    -- if (g_rel_auth_table(i) ='APPROVED') then
    if (g_rel_auth_table(i) in ('APPROVED', 'REQUIRES REAPPROVAL')) then

      select NVL(consigned_consumption_flag, 'N') -- Bug 3318625
      into   l_consigned_flag
      from   po_releases_all
      where  po_release_id = g_po_release_id_table(i);

      IF (g_rel_auth_table(i) = 'APPROVED' OR
          (g_rel_auth_table(i) = 'REQUIRES REAPPROVAL' AND
    l_consigned_flag = 'Y'))
      THEN
      -- Bug 3318625 END

    PO_DOCUMENT_CHECKS_GRP.po_submission_check(
      p_api_version => 1.0,
      p_action_requested => 'DOC_SUBMISSION_CHECK',
      p_document_type => 'RELEASE',
      p_document_subtype => 'BLANKET',
      p_document_id => g_po_release_id_table(i),
      x_return_status => x_return_status,
      x_sub_check_status => x_sub_check_status,
      x_msg_data => x_msg_data,
      x_online_report_id => x_online_report_id);

    /* For FND_LOG level, using LEVEL_EXCEPTION since these
     * are really exception that happened but we are not
     * erroring out here but just logging it and then continue
     * trying to submit next document for approval.
    */
    If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_msg_buf := null;
             l_msg_buf := FND_MSG_PUB.Get(p_msg_index => 1,
                   p_encoded   => 'F');
      l_msg_buf := 'Release ' ||g_po_release_id_table(i)||
          l_msg_buf;
             IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
            l_module,l_msg_buf);
             END IF;
    end if;

    If ((x_return_status = FND_API.G_RET_STS_SUCCESS) and
        (x_sub_check_status = FND_API.G_RET_STS_ERROR)) THEN

      l_msg_buf := 'Release ' ||g_po_release_id_table(i)||
          'Online Report Id '||x_online_report_id;
           IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,l_msg_buf);
     END IF;
   --<Bug9040655 START Added code to display the submission check failure message on the log file>

   PO_DEBUG.put_line('submission check failed for RELEASE id '
   ||TO_CHAR(g_po_release_id_table(i)));
   PO_DEBUG.put_line('Reason(s) :');
   SELECT MAX(sequence)
   INTO   max_sequence_num
   FROM   po_online_report_text_gt
   WHERE  online_report_id = x_online_report_id ;

   FOR i IN 1..max_sequence_num
   LOOP
           SELECT text_line
           INTO   x_text_line
           FROM   po_online_report_text_gt
           WHERE  online_report_id = x_online_report_id
           AND    sequence     = i;

           PO_DEBUG.put_line(x_text_line);
   END LOOP;
    --<Bug9040655 END>

    end if;

    l_module := g_log_head||l_api_name||'.'||'010'||'.';
    If ((x_return_status = FND_API.G_RET_STS_SUCCESS) and
        (x_sub_check_status = FND_API.G_RET_STS_SUCCESS)) THEN

      PO_RETROACTIVE_PRICING_PVT.Retroactive_Launch_Approval
        ( p_doc_id      =>  g_po_release_id_table(i),
         p_doc_type     => 'RELEASE',
         p_doc_subtype  => 'BLANKET');
    end if;

      -- Bug 3318625
      END IF; /* if (g_rel_auth_table(i) = 'APPROVED' OR */

          end if; /*if (g_rel_auth_table(i) in ('APPROVED', 'REQUIRES REAPPROVAL')) */

  end loop; /* l_global_document_id_table.first */
      end if;/*g_po_release_id_table.count > 0 */
exception
when others then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
  END IF;
raise;

end Launch_REL_Approval;

/**
 * Private Procedure: Retroactive_Launch_Approval
 * Modifies: Authorization_status of po_headers and po_releaes.
 * Effects: Get the default supplier communiation flags using
 *          po_vendor_sites_sv.get_transmission_defaults and then
 *          call start_wf_process by setting the correct values
 *          for the supplier communication flags. This is called from
 *          massupdate_releases procedure.
*/

Procedure Retroactive_Launch_Approval(
p_doc_id                IN      Number,
p_doc_type              IN      Varchar2,
p_doc_subtype           IN      Varchar2) IS

l_workflow_process     varchar2(40) := null;
l_submitter_action   varchar2(25);
l_forward_to_id      number;
l_forward_from_id      number;
l_def_approval_path_id      number;
l_note               varchar2(25);
l_ItemType             po_headers_all.WF_ITEM_TYPE%TYPE := null;
l_ItemKey              po_headers_all.WF_ITEM_Key%TYPE := null;
l_seq_for_item_key      varchar2(6)  := null;
l_action_orig_from      varchar2(30) := 'RETRO'; --need to findout
l_xmlsetup             varchar2(1)    := 'N';
l_docnum    po_headers_all.segment1%type;
l_preparer_id          po_headers.agent_id%type;
l_default_method      PO_VENDOR_SITES.SUPPLIER_NOTIF_METHOD%TYPE  := null;
l_email_address     po_vendor_sites.email_Address%type := null;
l_fax_number        varchar2(30) := null;  --Changed as part of Bug 5765243
l_document_num      po_headers.segment1%type;
l_xml_flag          varchar2(1) := 'N';
l_email_flag          varchar2(1) := 'N';
l_fax_flag          varchar2(1) := 'N';
l_print_flag          varchar2(1) := 'N';
l_org_id      number;


l_create_sourcing_rule      varchar2(30) := null;
l_update_sourcing_rule      varchar2(30) := null;
l_rel_gen_method      varchar2(30) := null;
l_progress varchar2(3);
l_module              VARCHAR2(100);
l_api_name    CONSTANT VARCHAR2(50) := 'Retroactive_Launch_Approval';

begin



  l_module := g_log_head||l_api_name||'.'||'000'||'.';
  /* Get the org context and set it since we will initiate approvals
   * for Std PO against Global Agreement in other operating units too.
  */
  If ((p_doc_type = 'PO') OR (p_doc_type = 'PA')) then
                SELECT poh.org_id
                into l_org_id
                FROM po_headers_all poh
                WHERE poh.po_header_id = p_doc_id;
        elsif (p_doc_type = 'RELEASE') then
                SELECT por.org_id
                into l_org_id
                FROM po_releases_all por
                WHERE por.po_release_id = p_doc_id;
        end if; /*If ((p_document_type = 'PO') OR (p_document_type = 'PA'))*/

        PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

        PO_VENDOR_SITES_SV.Get_Transmission_Defaults(
                                        p_document_id => p_doc_id,
                                        p_document_type => p_doc_type,
                                        p_document_subtype => p_doc_subtype,
                                        p_preparer_id => l_preparer_id,
                                        x_default_method => l_default_method,
                                        x_email_address => l_email_address,
                                        x_fax_number => l_fax_number,
                                        x_document_num => l_document_num);

        If ((l_default_method = 'EMAIL') and
                        (l_email_address is not null)) then
                l_email_flag := 'Y';
        elsif ((l_default_method  = 'FAX')  and (l_fax_number is not null)) then
                l_email_address := null;

                l_fax_flag := 'Y';
        elsif  l_default_method  = 'PRINT' then
                l_email_address := null;
                l_fax_number := null;

                l_print_flag := 'Y';
        else
                l_email_address := null;
                l_fax_number := null;
        end if;

  l_module := g_log_head||l_api_name||'.'||'000'||'.';


        po_reqapproval_init1.start_wf_process
                      ( ItemType => l_ItemType,
                        ItemKey => l_ItemKey,
                        WorkflowProcess => l_workflow_process,
                        ActionOriginatedFrom => l_action_orig_from,
                        DocumentID => p_doc_id,
                        DocumentNumber => l_docnum,
                        PreparerID => l_preparer_id,
                        DocumentTypeCode => p_doc_type,
                        DocumentSubtype => p_doc_subtype,
                        SubmitterAction => l_submitter_action,
                        forwardToID => l_forward_to_id,
                        forwardFromID => l_forward_from_id,
                        DefaultApprovalPathID => l_def_approval_path_id,
                        Note => l_note,
                        printFlag => l_print_flag,
                        FaxFlag => l_fax_flag,
                        FaxNumber => l_fax_number,
                        EmailFlag => l_email_flag,
                        EmailAddress => l_email_address,
                        CreateSourcingRule => l_create_sourcing_rule,
                        UpdateSourcingRule => l_update_sourcing_rule,
                        ReleaseGenMethod => l_rel_gen_method,
                        MassUpdateReleases => 'N',
                        --Bug 3574895. Retroactively updated releases were not
                        --             getting communicated to supplier
                        CommunicatePriceChange => g_communicate_update,
                        RetroactivePriceChange => 'Y');

exception
when no_data_found then
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
    END IF;
          raise;
when others then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
          l_module,SQLERRM(SQLCODE));
  END IF;
raise;

end Retroactive_Launch_Approval;



--<R12 GBPA Adv Pricing >
--Changed the procedure name
PROCEDURE open_agreement_cur(p_sql_str            IN    VARCHAR2,
                                p_po_header_id       IN    NUMBER,
                                p_vendor_id          IN    NUMBER,
                                p_vendor_site_id     IN    NUMBER,
                                p_category_struct_id IN    NUMBER,
                                p_ga_security        IN    VARCHAR2,
                                p_item_from          IN    VARCHAR2,
                                p_item_to            IN    VARCHAR2,
                                p_cat_from           IN    VARCHAR2,
                                p_cat_to             IN    VARCHAR2,
                                x_cursor     IN OUT NOCOPY g_agreement_cur_type) IS

    TYPE bind_var_tbl_type IS TABLE OF VARCHAR2(800) INDEX BY BINARY_INTEGER;

    l_bind_vars     bind_var_tbl_type;
    l_current_index NUMBER := 1;
    l_num_bind_vars NUMBER := 5;    -- number of bind variables known

    l_module        VARCHAR2(100);
    l_api_name      CONSTANT VARCHAR2(50) := 'open_agreement_cur';

BEGIN

    l_module := g_log_head||l_api_name||'.'||'000'||'.';

    IF (p_item_from IS NOT NULL) THEN
        l_bind_vars(l_current_index) := p_item_from;
        l_current_index := l_current_index + 1;
        l_num_bind_vars := l_num_bind_vars + 1;
    END IF;

    IF (p_item_to IS NOT NULL) THEN
        l_bind_vars(l_current_index) := p_item_to;
        l_current_index := l_current_index + 1;
        l_num_bind_vars := l_num_bind_vars + 1;
    END IF;

    IF (p_cat_from IS NOT NULL) THEN
        l_bind_vars(l_current_index) := p_cat_from;
        l_current_index := l_current_index + 1;
        l_num_bind_vars := l_num_bind_vars + 1;
    END IF;

    IF (p_cat_to IS NOT NULL) THEN
        l_bind_vars(l_current_index) := p_cat_to;
        l_current_index := l_current_index + 1;
        l_num_bind_vars := l_num_bind_vars + 1;
    END IF;

    l_module := g_log_head||l_api_name||'.'||'010'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
                   'Ready to open x_cursor, num of binds = ' || l_num_bind_vars);
    END IF;

    IF (l_num_bind_vars = 5) THEN
        OPEN x_cursor FOR p_sql_str USING p_po_header_id,   p_vendor_id,
                                          p_vendor_site_id, p_category_struct_id,
                                          p_ga_security,
                                          p_po_header_id,   p_vendor_id, p_vendor_site_id;
    ELSIF (l_num_bind_vars = 6) THEN
        OPEN x_cursor FOR p_sql_str USING p_po_header_id,   p_vendor_id,
                                          p_vendor_site_id, p_category_struct_id,
                                          p_ga_security,    l_bind_vars(1),
                                          p_po_header_id,   p_vendor_id, p_vendor_site_id;
    ELSIF (l_num_bind_vars = 7) THEN
        OPEN x_cursor FOR p_sql_str USING p_po_header_id,   p_vendor_id,
                                          p_vendor_site_id, p_category_struct_id,
                                          p_ga_security,    l_bind_vars(1),
                                          l_bind_vars(2),
                                          p_po_header_id,   p_vendor_id, p_vendor_site_id;
    ELSIF (l_num_bind_vars = 8) THEN
        OPEN x_cursor FOR p_sql_str USING p_po_header_id,   p_vendor_id,
                                          p_vendor_site_id, p_category_struct_id,
                                          p_ga_security,    l_bind_vars(1),
                                          l_bind_vars(2),   l_bind_vars(3),
                                          p_po_header_id,   p_vendor_id, p_vendor_site_id;
    ELSIF (l_num_bind_vars = 9) THEN
        OPEN x_cursor FOR p_sql_str USING p_po_header_id,   p_vendor_id,
                                          p_vendor_site_id, p_category_struct_id,
                                          p_ga_security,    l_bind_vars(1),
                                          l_bind_vars(2),   l_bind_vars(3),
                                          l_bind_vars(4),
                                          p_po_header_id,   p_vendor_id, p_vendor_site_id;
    END IF;

    l_module := g_log_head||l_api_name||'.'||'020'||'.';
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
                   'x_cursor is opened');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                       l_module,SQLERRM(SQLCODE));
        END IF;
END open_agreement_cur;

-- bug2935437 end


-- <FPJ Retroactive Price START>
--------------------------------------------------------------------------------
--Start of Comments
--Name: Get_Retro_mode
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns retroactive pricing mode.
--Parameters:
--IN:
--  None.
--RETURN:
--  'NEVER':    Not Supported
--  'OPEN_RELEASES':    Retroactive Pricing Update on Open Releases
--  'ALL_RELEASES':   Retroactive Pricing Update on All Releases
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Get_Retro_Mode RETURN VARCHAR2 IS
  l_api_name    CONSTANT varchar2(30) := 'Get_Retro_Mode';
  l_log_head    CONSTANT VARCHAR2(100):= g_log_head || l_api_name;
  l_progress    VARCHAR2(3);
  l_retroactive_update  VARCHAR2(30) := 'NEVER';
  -- Bug 3614598
  l_ap_family_pack      FND_PRODUCT_INSTALLATIONS.patch_level%TYPE;

BEGIN

  l_progress := '000';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
  END IF;

  FND_PROFILE.get('PO_ALLOW_RETROPRICING_OF_PO',l_retroactive_update);
  IF (l_retroactive_update IS NULL) THEN
    l_retroactive_update := 'NEVER';
  END IF; /* IF (l_retroactive_update IS NULL) */

  l_progress := '020';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_retroactive_update', l_retroactive_update);
  END IF;

  IF (l_retroactive_update = 'NEVER') THEN
    RETURN l_retroactive_update;
  END IF; /* IF (l_retroactive_update = 'NEVER') */

  l_progress := '060';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_retroactive_update', l_retroactive_update);
  END IF;

  IF (l_retroactive_update = 'ALL_RELEASES') THEN

    -- Bug 3614598 START
    -- Remove checking for inventory since it is now part of SCM
    -- Use AD_VERSION_UTIL.get_product_patch_level instead of direct query
    AD_VERSION_UTIL.get_product_patch_level
    ( p_appl_id     => 200,   -- AP
      p_patch_level => l_ap_family_pack
    );

    l_progress := '080';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_ap_family_pack', l_ap_family_pack);
    END IF;

    IF (l_ap_family_pack < '11i.AP.L') THEN
      l_retroactive_update := 'OPEN_RELEASES';
    END IF; /* IF (l_ap_family_pack > '11i.AP.L') */
    -- Bug 3614598 END

  END IF; /* IF (l_retroactive_update = 'ALL_RELEASES') */

  l_progress := '100';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'l_retroactive_update', l_retroactive_update);
  END IF;

  return l_retroactive_update;
EXCEPTION
  WHEN OTHERS THEN
    return 'NEVER';

END Get_Retro_Mode;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Is_Retro_Update
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns retroactive pricing status.
--Parameters:
--IN:
--p_document_id
--  The id of the document (po_header_id or po_release_id)
--p_document_type
--  The type of the document
--    PO :      Standard PO
--    RELEASE : Release
--RETURN:
--  'Y':  Retroactive Pricing Update
--  'N':    Not a Retroactive Pricing Update
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Is_Retro_Update(p_document_id    IN         NUMBER,
                       p_document_type  IN         VARCHAR2)
  RETURN VARCHAR2
IS
  l_retro_change  VARCHAR2(1) := 'N';
BEGIN

     --<R12 GBPA Adv Pricing Start>

     -- bug5358954
     -- Added the where clause
     -- 'poll.line_location_id = polla.line_location_id'
     -- in the following two sqls.


     IF (p_document_type = 'PO') THEN
       -- SQL What: Find out any retroactive pricing change for this PO
       --           by comparing the price in the latest revision
       SELECT 'Y'
       INTO   l_retro_change
       FROM   dual
       WHERE  EXISTS (SELECT 'retroactive pricing changes'
                      FROM    po_line_locations poll,
                             po_line_locations_archive polla
                      WHERE  poll.po_header_id = p_document_id
                      AND    poll.po_header_id =polla.po_header_id
                      AND    poll.line_location_id = polla.line_location_id
                      AND    polla.latest_external_flag = 'Y'
                      AND    poll.price_override <> polla.price_override);
     ELSE
       -- SQL What: Find out any retroactive pricing change for this Release
       --           by comparing the price in the latest revision

       SELECT 'Y'
       INTO   l_retro_change
       FROM   dual
       WHERE  EXISTS (SELECT 'retroactive pricing changes'
                      FROM    po_line_locations poll,
                             po_line_locations_archive polla
                      WHERE  poll.po_release_id = p_document_id
                      AND    poll.po_header_id =polla.po_header_id
                      AND    poll.line_location_id = polla.line_location_id
                      AND    polla.latest_external_flag = 'Y'
                      AND    poll.price_override <> polla.price_override);
     END IF; /* IF (p_document_type = 'PO') */

     --<R12 GBPA Adv Pricing End>


  return l_retro_change;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';

END Is_Retro_Update;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Reset_Retro_Update
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function resets retroactive_date.
--Parameters:
--IN:
--p_document_id
--  The id of the document (po_header_id or po_release_id)
--p_document_type
--  The type of the document
--    PO :      Standard PO
--    RELEASE : Release
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE Reset_Retro_Update(p_document_id  IN         NUMBER,
                           p_document_type  IN         VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
-- Bug 3251646
-- The autonomous transaction is required if the workflow function modifies
-- records in main document entity tables.

  l_api_name  CONSTANT varchar2(30) := 'Reset_Retro_Update';
  l_log_head  CONSTANT VARCHAR2(100):= g_log_head || l_api_name;
  l_progress  VARCHAR2(3);
  l_user_id NUMBER := FND_GLOBAL.user_id;
BEGIN

  l_progress := '000';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_begin(l_log_head);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_id', p_document_id);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type', p_document_type);
  END IF;

  IF (p_document_type = 'PO') THEN
    l_progress := '100';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Reset retroactive_date for PO');
    END IF; /* IF g_debug_stmt */

    -- SQL What: Reset retroactive_date for this PO
    -- SQL Why : For Standard PO, column po_lines.retroactive_date will
    --           be updated if any retroactive pricing changes. Reset it
    --           to NULL after processing retroactive pricing.
    UPDATE  po_lines_all
    SET     retroactive_date = NULL,
            last_update_date = SYSDATE,
            last_updated_by = l_user_id
    WHERE   po_header_id = p_document_id;
  ELSE
    --Bug12931756 no need to update the retroactive_date again as it is updated
    --in Massupdate_Releases already
    --For retroactive_date update via release form, modified POXPOL2B to take
    --care of the correct retroactive_date update.
    --For standard PO retroactive_date update (in above if condition), decdide
    --to leave the code untouched as I did not do regression research for PO
    --case
    RETURN;

    l_progress := '200';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Reset retroactive_date for Release');
    END IF; /* IF g_debug_stmt */

    -- SQL What: Find out any retroactive pricing change for this Release
    -- SQL Why : For Release, column po_line_locations.retroactive_date will
    --           be updated if any retroactive pricing changes, Reset it
    --           to the corresponding blanket line retroactive_date after
    --           processing retroactive pricing.
    UPDATE  po_line_locations_all pll
    SET     retroactive_date = (SELECT pl.retroactive_date
                                FROM   po_lines_all pl
                                WHERE  pl.po_line_id = pll.po_line_id),
            last_update_date = SYSDATE,
            last_updated_by = l_user_id
    WHERE   pll.po_release_id = p_document_id;
  END IF; /* IF (p_document_type = 'PO') */

  l_progress := '300';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
  END IF;

  COMMIT;  -- <Bug 3251646>

EXCEPTION
  WHEN OTHERS THEN
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
    END IF;

    RAISE;

END Reset_Retro_Update;

--------------------------------------------------------------------------------
--Start of Comments
--Name: Retro_Invoice_Release
--Pre-reqs:
--  None.
--Modifies:
--  PO_DISTRIBUTIONS_ALL.invoice_adjustment_flag.
--Locks:
--  None.
--Function:
--  This procedure updates invoice adjustment flag, and calls Costing
--  and Inventory APIs. This is called from Approval workflow.
--Parameters:
--IN:
--p_api_version
--  Version number of API that caller expects. It
--  should match the l_api_version defined in the
--  procedure (expected value : 1.0)
--p_document_id
--  The id of the document (po_header_id or po_release_id)
--p_document_type
--  The type of the document
--    PO :      Standard PO
--    RELEASE : Release
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if API succeeds
--  FND_API.G_RET_STS_ERROR if API fails
--  FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--x_msg_count
--  Number of Error messages
--x_msg_data
--  Contains error msg in case x_return_status returned
--  FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE Retro_Invoice_Release(p_api_version IN         NUMBER,
                                p_document_id IN         NUMBER,
                        p_document_type IN         VARCHAR2,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
-- Bug 3251646
-- The autonomous transaction is required if the workflow function modifies
-- records in main document entity tables.

  l_api_name  CONSTANT varchar2(30) := 'Retro_Invoice_Release';
  l_api_version CONSTANT NUMBER       := 1.0;
  l_log_head  CONSTANT VARCHAR2(100):= g_log_head || l_api_name;
  l_progress  VARCHAR2(3);
  l_document_id NUMBER;

  -- Bug 3314204, Pass Inventory API price in functional price
  l_base_curr_precision     FND_CURRENCIES.precision%TYPE := 2;

  CURSOR c_stdpo(p_po_header_id NUMBER) IS
  -- SQL What: Querying for standard PO which is not consigned
  -- SQL Why:  Need to process retroactive price correction of
  --           invoices and receipt account adjustments
  -- SQL Join: po_header_id
  SELECT poll.po_header_id,
         poll.po_release_id,
         poll.po_line_id,
         poll.line_location_id,
         poll.quantity_billed,
         poll.price_override new_price,
         polla.price_override old_price
  FROM   po_line_locations poll,
         po_line_locations_archive polla
  WHERE  poll.po_header_id = p_po_header_id
  AND    poll.po_release_id IS NULL
  AND    ((poll.accrue_on_receipt_flag = 'Y' AND
           (poll.quantity_received > 0 OR
            poll.quantity_billed > 0)) OR
          NVL(poll.accrue_on_receipt_flag, 'N') = 'N')    -- <Bug 3197792>
  AND    poll.line_location_id = polla.line_location_id
  AND    polla.latest_external_flag = 'Y'
  AND    poll.price_override <> polla.price_override;   -- Bug 3526448


  CURSOR c_release(p_po_release_id NUMBER) IS
  -- SQL What: Querying for Rlease which is not consigned
  -- SQL Why:  Need to process retroactive price correction of
  --           invoices and receipt account adjustments
  -- SQL Join: po_release_id
  SELECT poll.po_header_id,
         poll.po_release_id,
         poll.po_line_id,
         poll.line_location_id,
         poll.quantity_billed,
         poll.price_override new_price,
         polla.price_override old_price
  FROM   po_line_locations poll,
         po_line_locations_archive polla
  WHERE  poll.po_release_id = p_po_release_id
  AND    ((poll.accrue_on_receipt_flag = 'Y' AND
           (poll.quantity_received > 0 OR
            poll.quantity_billed > 0)) OR
          NVL(poll.accrue_on_receipt_flag, 'N') = 'N')    -- <Bug 3197792>
  AND    poll.line_location_id = polla.line_location_id
  AND    polla.latest_external_flag = 'Y'
  AND    poll.price_override <> polla.price_override;   -- Bug 3526448

  CURSOR c_consigned_stdpo(p_po_header_id NUMBER) IS
  -- SQL What: Querying for standard PO which is consigned
  -- SQL Why:  Need to process retroactive price correction of
  --           invoices and receipt account adjustments
  -- SQL Join: po_header_id
  SELECT poh.po_header_id,
         to_number(NULL) po_release_id, --<Bug 3292429>
         pol.from_header_id,  -- <Bug 3245719>
         poh.currency_code,
   poh.rate_type,
   poh.rate_date,
   poh.rate,
         pol.po_line_id,
         pol.item_id inventory_item_id,
         -- Bug 3393219, Consumption transaction owning org
         -- fsp.inventory_organization_id organization_id,
         pod.destination_organization_id organization_id,
         poll.line_location_id,
         poll.quantity_billed,
         pol.unit_meas_lookup_code transaction_uom,
         -- Bug 3314204, Pass Inventory API price in functional price
         -- Bug 3303148, Include Non-Recovery Tax
         -- Bug 3834275, added nvl to non recoverable tax
         round((round(poll.price_override * poll.quantity,
                     l_base_curr_precision) +
                nvl(pod.nonrecoverable_tax,0)) * NVL(pod.rate, 1),
               l_base_curr_precision) / poll.quantity  new_price,
         -- poll.price_override new_price,
         round((round(polla.price_override * poll.quantity,
                     l_base_curr_precision) +
                nvl(poda.nonrecoverable_tax,0)) * NVL(pod.rate, 1),
               l_base_curr_precision) / poll.quantity  old_price,
         -- polla.price_override old_price,
         poll.quantity transaction_quantity,
         round((round(poll.price_override * poll.quantity,
                     l_base_curr_precision) +
                nvl(pod.nonrecoverable_tax,0)) * NVL(pod.rate, 1),
               l_base_curr_precision) / poll.quantity -
         round((round(polla.price_override * poll.quantity,
                     l_base_curr_precision) +
                nvl(poda.nonrecoverable_tax,0)) * NVL(pod.rate, 1),
               l_base_curr_precision) / poll.quantity  transaction_cost,
         -- poll.price_override - polla.price_override transaction_cost,
         pod.po_distribution_id,
         pod.project_id,
         pod.task_id,
         pod.accrual_account_id distribute_account_id
  FROM   po_headers poh,
         po_lines_all pol,   -- <R12 MOAC>
         -- Bug 3393219, Consumption transaction owning org
         -- financials_system_parameters fsp,
         po_line_locations_all poll,   -- <R12 MOAC>
         po_line_locations_archive_all polla,     -- <R12 MOAC>
         po_distributions_all pod,    -- <R12 MOAC>
         -- Bug 3314204, 3303148
         po_distributions_archive_all poda     -- <R12 MOAC>
  WHERE  pol.po_header_id = p_po_header_id
  AND    pol.po_header_id = poh.po_header_id
  AND    pol.po_line_id = poll.po_line_id
  AND    poll.line_location_id = pod.line_location_id
  AND    poll.line_location_id = polla.line_location_id
  AND    polla.latest_external_flag = 'Y'
  -- Bug 3314204, 3303148
  AND    pod.po_distribution_id = poda.po_distribution_id
  AND    poda.latest_external_flag = 'Y'
  AND    poll.price_override <> polla.price_override;   -- Bug 3526448

  CURSOR c_consigned_release(p_po_release_id NUMBER) IS
  -- SQL What: Querying for Rlease which is consigned
  -- SQL Why:  Need to process retroactive price correction of
  --           invoices and receipt account adjustments
  -- SQL Join: po_release_id
  SELECT to_number(NULL) po_header_id, --<Bug 3292429>
         por.po_release_id,
         poh.po_header_id from_header_id,
         poh.currency_code,
   poh.rate_type,
   poh.rate_date,
   poh.rate,
         pol.po_line_id,
         pol.item_id inventory_item_id,
         -- Bug 3393219, Consumption transaction owning org
         -- fsp.inventory_organization_id organization_id,
         pod.destination_organization_id organization_id,
         poll.line_location_id,
         poll.quantity_billed,
         pol.unit_meas_lookup_code transaction_uom,
         -- Bug 3314204, Pass Inventory API price in functional price
         -- Bug 3303148, Include Non-Recovery Tax
         -- Bug 3834275, added nvl to non recoverable tax
         round((round(poll.price_override * poll.quantity,
                     l_base_curr_precision) +
                nvl(pod.nonrecoverable_tax,0)) * NVL(pod.rate, 1),
               l_base_curr_precision) / poll.quantity  new_price,
         -- poll.price_override new_price,
         round((round(polla.price_override * poll.quantity,
                     l_base_curr_precision) +
                nvl(poda.nonrecoverable_tax,0)) * NVL(pod.rate, 1),
               l_base_curr_precision) / poll.quantity  old_price,
         -- polla.price_override old_price,
         poll.quantity transaction_quantity,
         round((round(poll.price_override * poll.quantity,
                     l_base_curr_precision) +
                nvl(pod.nonrecoverable_tax,0)) * NVL(pod.rate, 1),
               l_base_curr_precision) / poll.quantity -
         round((round(polla.price_override * poll.quantity,
                     l_base_curr_precision) +
                nvl(poda.nonrecoverable_tax,0)) * NVL(pod.rate, 1),
               l_base_curr_precision) / poll.quantity  transaction_cost,
         -- poll.price_override - polla.price_override transaction_cost,
         pod.po_distribution_id,
         pod.project_id,
         pod.task_id,
         pod.accrual_account_id distribute_account_id
  FROM   po_releases por,
         po_headers_all poh,     -- <R12 MOAC>
         po_lines pol,
         -- Bug 3393219, Consumption transaction owning org
         -- financials_system_parameters fsp,
         po_line_locations_all poll,     -- <R12 MOAC>
         po_line_locations_archive_all polla,     -- <R12 MOAC>
         po_distributions_all pod,     -- <R12 MOAC>
         -- Bug 3314204, 3303148
         po_distributions_archive poda
  WHERE  por.po_release_id = p_po_release_id
  AND    por.po_release_id = poll.po_release_id
  AND    poll.po_header_id = poh.po_header_id
  AND    poll.po_line_id = pol.po_line_id
  AND    poll.line_location_id = pod.line_location_id
  AND    poll.line_location_id = polla.line_location_id
  AND    polla.latest_external_flag = 'Y'
  -- Bug 3314204, 3303148
  AND    pod.po_distribution_id = poda.po_distribution_id
  AND    poda.latest_external_flag = 'Y'
  AND    poll.price_override <> polla.price_override;   -- Bug 3526448


  l_po_header_ids_tbl   po_tbl_number;
  l_po_release_ids_tbl    po_tbl_number;
  l_from_header_ids_tbl   po_tbl_number;
  l_currency_codes_tbl    po_tbl_varchar30;
  l_rate_types_tbl    po_tbl_varchar30;
  l_rate_dates_tbl    po_tbl_date;
  l_rates_tbl     po_tbl_number;
  l_po_line_ids_tbl   po_tbl_number;
  l_inventory_item_ids_tbl  po_tbl_number;
  l_organization_ids_tbl  po_tbl_number;
  l_line_location_ids_tbl po_tbl_number;
  l_quantity_billeds_tbl  po_tbl_number;
  l_transaction_uoms_tbl  po_tbl_varchar30;
  l_new_prices_tbl    po_tbl_number;
  l_old_prices_tbl    po_tbl_number;
  l_transaction_quantitys_tbl po_tbl_number;
  l_transaction_costs_tbl po_tbl_number;
  l_distribution_ids_tbl  po_tbl_number;
  l_project_ids_tbl   po_tbl_number;
  l_task_ids_tbl    po_tbl_number;
  l_dist_account_ids_tbl  po_tbl_number;

  l_primary_quantity    PO_LINES.quantity%TYPE;
  l_primary_uom     PO_LINES.unit_meas_lookup_code%TYPE;
  l_uom_code      MTL_UNITS_OF_MEASURE.uom_code%TYPE;

  l_consigned_flag    PO_HEADERS.consigned_consumption_flag%TYPE;
  l_return_status   varchar2(1);
  l_msg_data      varchar2(2000);
  l_msg_count     number;

  -- To call Inventory API
  l_mtl_trx_rec     INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_rec_type;
  l_mtl_trx_tbl     INV_LOGICAL_TRANSACTION_GLOBAL.mtl_trx_tbl_type;
  l_mtl_index     BINARY_INTEGER := 1;

  l_fnd_enabled      varchar2(1);


BEGIN

  l_progress := '000';
  SAVEPOINT RETRO_INVOICE_SP;

  -- Setup for writing the concurrent logs based on
  -- the concurrent log Profile
    IF g_log_mode = 'Y' THEN
      po_debug.set_file_io(TRUE);
    ELSE
      po_debug.set_file_io(null);
    END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  IF g_debug_stmt THEN
     PO_DEBUG.debug_begin(l_log_head);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_id', p_document_id);
     PO_DEBUG.debug_var(l_log_head,l_progress,'p_document_type', p_document_type);
  END IF;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Bug 3314204, Pass Inventory API price in functional price
  SELECT nvl(FND.precision, 2)
  INTO   l_base_curr_precision
  FROM   FND_CURRENCIES FND,
         FINANCIALS_SYSTEM_PARAMETERS FSP,
         GL_SETS_OF_BOOKS GSB
  WHERE  FSP.set_of_books_id = GSB.set_of_books_id AND
         FND.currency_code = GSB.currency_code;

  l_progress := '010';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_var(l_log_head,l_progress,
       'l_base_curr_precision', l_base_curr_precision);
     PO_DEBUG.debug_stmt(l_log_head,l_progress,
       'Check Consigned Consumption flag');
  END IF; /* IF g_debug_stmt */

  l_progress := '020';
  IF (p_document_type = 'PO') THEN
    SELECT NVL(consigned_consumption_flag, 'N')
    INTO   l_consigned_flag
    FROM   PO_HEADERS
    WHERE  po_header_id = p_document_id;
  ELSE
    SELECT NVL(consigned_consumption_flag, 'N')
    INTO   l_consigned_flag
    FROM   PO_RELEASES
    WHERE  po_release_id = p_document_id;
  END IF; /* IF (p_document_type = 'PO') */

  l_progress := '030';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_var(l_log_head,l_progress,'l_consigned_flag', l_consigned_flag);
  END IF; /* IF g_debug_stmt */

  IF (l_consigned_flag = 'N') THEN
    -- For standard POs and PO releases(not consigned),
    -- call the new accounting events API
    l_progress := '040';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
        'Open Cursor for Not Consigned PO/RELEASE');
    END IF; /* IF g_debug_stmt */

    l_progress := '050';
    IF (p_document_type = 'PO') THEN
      OPEN c_stdpo(p_document_id);
    ELSE
      OPEN c_release(p_document_id);
    END IF; /* IF (p_document_type = 'PO') */

    l_progress := '060';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Fetch from Cursor');
    END IF; /* IF g_debug_stmt */

    LOOP
      IF (p_document_type = 'PO') THEN
        FETCH c_stdpo BULK COLLECT INTO
            l_po_header_ids_tbl,
        l_po_release_ids_tbl,
        l_po_line_ids_tbl,
        l_line_location_ids_tbl,
      l_quantity_billeds_tbl,
        l_new_prices_tbl,
        l_old_prices_tbl
        LIMIT G_BULK_LIMIT;
      ELSE
        FETCH c_release BULK COLLECT INTO
            l_po_header_ids_tbl,
        l_po_release_ids_tbl,
        l_po_line_ids_tbl,
        l_line_location_ids_tbl,
      l_quantity_billeds_tbl,
        l_new_prices_tbl,
        l_old_prices_tbl
        LIMIT G_BULK_LIMIT;
      END IF; /* IF (p_document_type = 'PO') */

      l_progress := '070';
      IF l_po_header_ids_tbl.COUNT > 0  THEN
  IF g_debug_stmt THEN
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_header_ids_tbl', l_po_header_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_release_ids_tbl', l_po_release_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_line_ids_tbl', l_po_line_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_line_location_ids_tbl', l_line_location_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_quantity_billeds_tbl', l_quantity_billeds_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_new_prices_tbl', l_new_prices_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_old_prices_tbl', l_old_prices_tbl);
    PO_DEBUG.debug_stmt(l_log_head,l_progress,
            'Before updating the invoice_adjustment_flag to R');
  END IF; /* IF g_debug_stmt */

        l_progress := '080';
        FORALL i in 1..l_line_location_ids_tbl.COUNT
    UPDATE	po_distributions_all
    SET		invoice_adjustment_flag = 'R'
    WHERE	line_location_id = l_line_location_ids_tbl(i)
     AND	EXISTS (SELECT	'1'
					FROM	ap_invoice_lines_all apl
					WHERE	apl.po_line_location_id = l_line_location_ids_tbl(i)
					 AND	nvl(apl.discarded_flag,'N') <> 'Y'
					 AND	nvl(apl.cancelled_flag,'N') <> 'Y');

        l_progress := '090';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,
            'updated the invoice_adjustment_flag to R -- Rowcount: ' || SQL%ROWCOUNT);
          PO_DEBUG.debug_stmt(l_log_head,l_progress,
            'Before Calling Create_AccountingEvents()');
        END IF; /* IF g_debug_stmt */

        FOR i IN l_po_header_ids_tbl.FIRST..l_po_header_ids_tbl.LAST LOOP

          l_progress := '100';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,
              'Call RCV_AccrualAccounting_GRP.Create_AccountingEvents()');
          END IF;
            PO_DEBUG.put_line('Call RCV_AccrualAccounting_GRP.Create_AccountingEvents');

          RCV_AccrualAccounting_GRP.Create_AccountingEvents(
            p_api_version => 1.0,
      p_source_type => 'RETROPRICE',
      p_po_header_id  => l_po_header_ids_tbl(i),
      p_po_release_id => l_po_release_ids_tbl(i),
      p_po_line_id  => l_po_line_ids_tbl(i),
      p_po_line_location_id=> l_line_location_ids_tbl(i),
      p_old_po_price  => l_old_prices_tbl(i),
      p_new_po_price  => l_new_prices_tbl(i),
      x_return_status => l_return_status,
      x_msg_count   => l_msg_count,
      x_msg_data    => l_msg_data);

          l_progress := '105';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status', l_return_status);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_msg_count', l_msg_count);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_msg_data', l_msg_data);
          END IF; /* IF g_debug_stmt */

          PO_DEBUG.put_line('Return status : ' || l_return_status);
          PO_DEBUG.put_line('Message Count: ' || l_msg_count);
          PO_DEBUG.put_line('Message data : '|| l_msg_data);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) Then
      IF (l_return_status = FND_API.G_RET_STS_ERROR) Then
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; /* IF (l_return_status = FND_API.G_RET_STS_ERROR) */
    END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

	  /** INVCONV rseshadr - call OPM API for process organizations **/
          l_progress := '106';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,
              'Call GMF_Rcv_Accounting_Pkg.Create_Adjust_Txns()');
          END IF;
            PO_DEBUG.put_line('Call GMF_Rcv_Accounting_Pkg.Create_Adjust_Txns');

          GMF_Rcv_Accounting_Pkg.Create_Adjust_Txns(
            p_api_version => 1.0,
	    p_init_msg_list => FND_API.G_FALSE,
	    p_commit => FND_API.G_FALSE,
	    p_validation_level => FND_API.G_VALID_LEVEL_FULL,
            p_po_header_id  => l_po_header_ids_tbl(i),
            p_po_release_id => l_po_release_ids_tbl(i),
            p_po_line_id  => l_po_line_ids_tbl(i),
            p_po_line_location_id=> l_line_location_ids_tbl(i),
            p_old_po_price  => l_old_prices_tbl(i),
            p_new_po_price  => l_new_prices_tbl(i),
            x_return_status => l_return_status,
            x_msg_count   => l_msg_count,
            x_msg_data    => l_msg_data);

          l_progress := '108';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status', l_return_status);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_msg_count', l_msg_count);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_msg_data', l_msg_data);
          END IF; /* IF g_debug_stmt */

          PO_DEBUG.put_line('Return status : ' || l_return_status);
          PO_DEBUG.put_line('Message Count: ' || l_msg_count);
          PO_DEBUG.put_line('Message data : '|| l_msg_data);

          IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) Then
            IF (l_return_status = FND_API.G_RET_STS_ERROR) Then
              RAISE FND_API.G_EXC_ERROR;
            ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF; /* IF (l_return_status = FND_API.G_RET_STS_ERROR) */
          END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */
	  /** INVCONV rseshadr - end of changes **/

        END LOOP;

        l_progress := '110';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,
            'After Calling Create_AccountingEvents()');
        END IF; /* IF g_debug_stmt */

      END IF; /* IF l_po_header_ids_tbl.COUNT > 0 */

      l_progress := '120';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Check EXIT condition');
      END IF; /* IF g_debug_stmt */

      IF (p_document_type = 'PO') THEN
        EXIT WHEN c_stdpo%NOTFOUND;
      ELSE
        EXIT WHEN c_release%NOTFOUND;
      END IF; /* IF (p_document_type = 'PO') */

      l_progress := '125';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Clear PL/SQL tables');
      END IF; /* IF g_debug_stmt */

      l_po_header_ids_tbl.DELETE;
      l_po_release_ids_tbl.DELETE;
      l_po_line_ids_tbl.DELETE;
      l_line_location_ids_tbl.DELETE;
      l_quantity_billeds_tbl.DELETE;
      l_new_prices_tbl.DELETE;
      l_old_prices_tbl.DELETE;

    END LOOP; /* c_stdpo / c_release */

    l_progress := '130';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Close Cursor');
    END IF; /* IF g_debug_stmt */

    IF (p_document_type = 'PO') THEN
      CLOSE c_stdpo;
    ELSE
      CLOSE c_release;
    END IF; /* IF (p_document_type = 'PO') */

  ELSE  /* IF (l_consigned_flag = 'N') */
    -- For consumption advices, call the Inventory API

    l_progress := '140';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,
        'Open Cursor for Consigned PO/RELEASE');
    END IF; /* IF g_debug_stmt */

    l_progress := '150';
    IF (p_document_type = 'PO') THEN
      OPEN c_consigned_stdpo(p_document_id);
    ELSE
      OPEN c_consigned_release(p_document_id);
    END IF; /* IF (p_document_type = 'PO') */

    l_progress := '160';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Fetch from Cursor');
    END IF; /* IF g_debug_stmt */

    LOOP
      l_mtl_index := 1;

      IF (p_document_type = 'PO') THEN
        FETCH c_consigned_stdpo BULK COLLECT INTO
            l_po_header_ids_tbl,
      l_po_release_ids_tbl,
      l_from_header_ids_tbl,
      l_currency_codes_tbl,
      l_rate_types_tbl,
      l_rate_dates_tbl,
      l_rates_tbl,
      l_po_line_ids_tbl,
      l_inventory_item_ids_tbl,
      l_organization_ids_tbl,
      l_line_location_ids_tbl,
      l_quantity_billeds_tbl,
      l_transaction_uoms_tbl,
      l_new_prices_tbl,
      l_old_prices_tbl,
      l_transaction_quantitys_tbl,
            l_transaction_costs_tbl,
            l_distribution_ids_tbl,
      l_project_ids_tbl,
      l_task_ids_tbl,
            l_dist_account_ids_tbl
        LIMIT G_BULK_LIMIT;
      ELSE
        FETCH c_consigned_release BULK COLLECT INTO
            l_po_header_ids_tbl,
      l_po_release_ids_tbl,
      l_from_header_ids_tbl,
      l_currency_codes_tbl,
      l_rate_types_tbl,
      l_rate_dates_tbl,
      l_rates_tbl,
      l_po_line_ids_tbl,
      l_inventory_item_ids_tbl,
      l_organization_ids_tbl,
      l_line_location_ids_tbl,
      l_quantity_billeds_tbl,
      l_transaction_uoms_tbl,
      l_new_prices_tbl,
      l_old_prices_tbl,
      l_transaction_quantitys_tbl,
            l_transaction_costs_tbl,
            l_distribution_ids_tbl,
      l_project_ids_tbl,
      l_task_ids_tbl,
            l_dist_account_ids_tbl
        LIMIT G_BULK_LIMIT;
      END IF; /* IF (p_document_type = 'PO') */

      l_progress := '170';
      IF l_po_header_ids_tbl.COUNT > 0  THEN
  IF g_debug_stmt THEN
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_header_ids_tbl', l_po_header_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_release_ids_tbl', l_po_release_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_from_header_ids_tbl', l_from_header_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_currency_codes_tbl', l_currency_codes_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_rate_types_tbl', l_rate_types_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_rate_dates_tbl', l_rate_dates_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_rates_tbl', l_rates_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_line_ids_tbl', l_po_line_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_inventory_item_ids_tbl', l_inventory_item_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_organization_ids_tbl', l_organization_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_line_location_ids_tbl', l_line_location_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_quantity_billeds_tbl', l_quantity_billeds_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_transaction_uoms_tbl', l_transaction_uoms_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_new_prices_tbl', l_new_prices_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_old_prices_tbl', l_old_prices_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_transaction_quantitys_tbl', l_transaction_quantitys_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_transaction_costs_tbl', l_transaction_costs_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_distribution_ids_tbl', l_distribution_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_project_ids_tbl', l_project_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_task_ids_tbl', l_task_ids_tbl);
          PO_DEBUG.debug_var(l_log_head,l_progress,'l_dist_account_ids_tbl', l_dist_account_ids_tbl);
    PO_DEBUG.debug_stmt(l_log_head,l_progress,
            'Before updating the invoice_adjustment_flag to R');
        END IF; /* IF g_debug_stmt */

        l_progress := '180';
        FORALL i in 1..l_distribution_ids_tbl.COUNT
  UPDATE	po_distributions_all
  SET		invoice_adjustment_flag = 'R'
  WHERE		line_location_id = l_line_location_ids_tbl(i)
   AND		EXISTS (SELECT	'1'
					FROM	ap_invoice_lines_all apl
					WHERE	apl.po_line_location_id = l_line_location_ids_tbl(i)
					 AND	nvl(apl.discarded_flag,'N') <> 'Y'
					 AND	nvl(apl.cancelled_flag,'N') <> 'Y');

        l_progress := '200';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,
            'updated the invoice_adjustment_flag to R -- Rowcount: ' || SQL%ROWCOUNT);
          PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Before Calling Inventory API');
        END IF; /* IF g_debug_stmt */

        FOR i IN l_po_header_ids_tbl.FIRST..l_po_header_ids_tbl.LAST LOOP

          l_progress := '205';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Prepare Record before Call Inventory API');
          END IF; /* IF g_debug_stmt */

          -- calculate Primary Quantity and UOM
          RCV_QUANTITIES_S.get_primary_qty_uom (
            x_transaction_qty => l_transaction_quantitys_tbl(i),
      x_transaction_uom => l_transaction_uoms_tbl(i),
      x_item_id         => l_inventory_item_ids_tbl(i),
      x_organization_id => l_organization_ids_tbl(i),
      x_primary_qty     => l_primary_quantity,
      x_primary_uom     => l_primary_uom);

          l_progress := '210';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_primary_quantity', l_primary_quantity);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_primary_uom', l_primary_uom);
            PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Get UOM code');
          END IF; /* IF g_debug_stmt */

          BEGIN
            -- INV expects the uom_code whereas PO stores unit_of_measure.
      SELECT mum.uom_code
      INTO   l_uom_code
      FROM   mtl_units_of_measure mum
      WHERE  mum.unit_of_measure = l_transaction_uoms_tbl(i);
    EXCEPTION
      WHEN OTHERS THEN
        l_uom_code := NULL;
    END;

          l_progress := '220';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_uom_code', l_uom_code);
          END IF; /* IF g_debug_stmt */

          l_mtl_trx_rec.organization_id   := l_organization_ids_tbl(i);
          l_progress := '225';
          l_mtl_trx_rec.inventory_item_id := l_inventory_item_ids_tbl(i);
          l_progress := '230';
    l_mtl_trx_rec.transaction_type_id := 20;  -- Retroactive Price Update
          l_progress := '235';
    l_mtl_trx_rec.transaction_action_id := 25;  -- Retroactive Price Update
          l_progress := '240';
    l_mtl_trx_rec.transaction_source_type_id:= 1; -- PO
          l_progress := '245';
    l_mtl_trx_rec.transaction_source_id := l_from_header_ids_tbl(i);
          l_progress := '250';
    l_mtl_trx_rec.transaction_quantity  := l_transaction_quantitys_tbl(i);
          l_progress := '255';
    l_mtl_trx_rec.transaction_uom   := l_uom_code;
          l_progress := '260';
    l_mtl_trx_rec.primary_quantity  := l_primary_quantity;
          l_progress := '265';
    l_mtl_trx_rec.transaction_date  := SYSDATE;
          l_progress := '270';
    l_mtl_trx_rec.distribution_account_id := l_dist_account_ids_tbl(i);
          l_progress := '275';
    l_mtl_trx_rec.transaction_cost  := l_transaction_costs_tbl(i);
          l_progress := '280';
    l_mtl_trx_rec.currency_code   := l_currency_codes_tbl(i);
          l_progress := '285';
    l_mtl_trx_rec.currency_conversion_rate:= l_rates_tbl(i);
          l_progress := '290';
    l_mtl_trx_rec.currency_conversion_type:= l_rate_types_tbl(i);
          l_progress := '295';
    l_mtl_trx_rec.currency_conversion_date:= l_rate_dates_tbl(i);
          l_progress := '300';
    l_mtl_trx_rec.project_id    := l_project_ids_tbl(i);
          l_progress := '305';
    l_mtl_trx_rec.task_id     := l_task_ids_tbl(i);
          l_progress := '310';
    l_mtl_trx_rec.consumption_release_id  := l_po_release_ids_tbl(i);
          l_progress := '315';
    l_mtl_trx_rec.consumption_po_header_id:= l_po_header_ids_tbl(i);
          l_progress := '320';
    l_mtl_trx_rec.old_po_price    := l_old_prices_tbl(i);
          l_progress := '325';
    l_mtl_trx_rec.new_po_price    := l_new_prices_tbl(i);
          l_progress := '330';
    l_mtl_trx_rec.parent_transaction_flag := NULL; -- Not parent transaction
          l_progress := '335';
    l_mtl_trx_rec.po_distribution_id := l_distribution_ids_tbl(i); -- bug5112228


          l_progress := '340';
    l_mtl_trx_tbl(l_mtl_index) := l_mtl_trx_rec;
    l_mtl_index := l_mtl_index + 1;

        END LOOP;

        l_progress := '350';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Prepare Record Done');
        END IF; /* IF g_debug_stmt */

        IF (l_mtl_index > 0) THEN
          l_progress := '360';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Call Inventory API');
          END IF; /* IF g_debug_stmt */
          PO_DEBUG.put_line('Call Inventory API');

          INV_LOGICAL_TRANSACTIONS_PUB.create_logical_transactions(
      p_api_version_number        => 1.0,
      p_init_msg_lst              => FND_API.G_FALSE,
      p_validation_flag   => FND_API.G_TRUE,
      p_trx_flow_header_id  => NULL,
      p_defer_logical_transactions=> NULL,
      p_logical_trx_type_code => 4,
      p_exploded_flag   => 2,
      p_mtl_trx_tbl               => l_mtl_trx_tbl,
      x_return_status   => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

          l_progress := '370';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_return_status', l_return_status);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_msg_count', x_msg_count);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_msg_data', x_msg_data);
          END IF; /* IF g_debug_stmt */

          PO_DEBUG.put_line('Return status : ' || l_return_status);
          PO_DEBUG.put_line('Message Count: ' || l_msg_count);
          PO_DEBUG.put_line('Message data : '|| l_msg_data);

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) Then
      IF (l_return_status = FND_API.G_RET_STS_ERROR) Then
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; /* IF (l_return_status = FND_API.G_RET_STS_ERROR) */
    END IF; /* IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) */

        END IF; /* IF (l_mtl_index > 0) */

        l_progress := '380';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress, 'After Call Inventory API');
        END IF; /* IF g_debug_stmt */

      END IF; /* IF l_po_header_ids_tbl.COUNT > 0 */

      l_progress := '390';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Check EXIT condition');
      END IF; /* IF g_debug_stmt */

      IF (p_document_type = 'PO') THEN
        EXIT WHEN c_consigned_stdpo%NOTFOUND;
      ELSE
        EXIT WHEN c_consigned_release%NOTFOUND;
      END IF; /* IF (p_document_type = 'PO') */

      l_progress := '400';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Clear PL/SQL tables');
      END IF; /* IF g_debug_stmt */

      l_po_header_ids_tbl.DELETE;
      l_po_release_ids_tbl.DELETE;
      l_from_header_ids_tbl.DELETE;
      l_currency_codes_tbl.DELETE;
      l_rate_types_tbl.DELETE;
      l_rate_dates_tbl.DELETE;
      l_rates_tbl.DELETE;
      l_po_line_ids_tbl.DELETE;
      l_inventory_item_ids_tbl.DELETE;
      l_organization_ids_tbl.DELETE;
      l_line_location_ids_tbl.DELETE;
      l_quantity_billeds_tbl.DELETE;
      l_transaction_uoms_tbl.DELETE;
      l_new_prices_tbl.DELETE;
      l_old_prices_tbl.DELETE;
      l_transaction_quantitys_tbl.DELETE;
      l_transaction_costs_tbl.DELETE;
      l_distribution_ids_tbl.DELETE;
      l_project_ids_tbl.DELETE;
      l_task_ids_tbl.DELETE;
      l_dist_account_ids_tbl.DELETE;
      l_mtl_trx_tbl.DELETE;

    END LOOP; /* c_consigned_stdpo / c_consigned_release */

    l_progress := '410';
    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress, 'Close Cursor');
    END IF; /* IF g_debug_stmt */

    IF (p_document_type = 'PO') THEN
      CLOSE c_consigned_stdpo;
    ELSE
      CLOSE c_consigned_release;
    END IF; /* IF (p_document_type = 'PO') */

  END IF; /* IF (l_consigned_flag = 'N') */

  l_progress := '430';
  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
    PO_DEBUG.debug_end(l_log_head);
  END IF;

  COMMIT;  -- <Bug 3251646>

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO RETRO_INVOICE_SP;
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
    END IF;

    IF (c_stdpo%ISOPEN) THEN
      CLOSE c_stdpo;
    END IF;
    IF (c_release%ISOPEN) THEN
      CLOSE c_release;
    END IF;
    IF (c_consigned_stdpo%ISOPEN) THEN
      CLOSE c_consigned_stdpo;
    END IF;
    IF (c_consigned_release%ISOPEN) THEN
      CLOSE c_consigned_release;
    END IF;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO RETRO_INVOICE_SP;
    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
    END IF;

    IF (c_stdpo%ISOPEN) THEN
      CLOSE c_stdpo;
    END IF;
    IF (c_release%ISOPEN) THEN
      CLOSE c_release;
    END IF;
    IF (c_consigned_stdpo%ISOPEN) THEN
      CLOSE c_consigned_stdpo;
    END IF;
    IF (c_consigned_release%ISOPEN) THEN
      CLOSE c_consigned_release;
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO RETRO_INVOICE_SP;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name);
    END IF;

    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
    END IF;

    x_msg_data := FND_MSG_PUB.GET(p_msg_index => FND_MSG_PUB.G_LAST,
                                  p_encoded => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (c_stdpo%ISOPEN) THEN
      CLOSE c_stdpo;
    END IF;
    IF (c_release%ISOPEN) THEN
      CLOSE c_release;
    END IF;
    IF (c_consigned_stdpo%ISOPEN) THEN
      CLOSE c_consigned_stdpo;
    END IF;
    IF (c_consigned_release%ISOPEN) THEN
      CLOSE c_consigned_release;
    END IF;

END Retro_Invoice_Release;
-- <FPJ Retroactive Price END>

--------------------------------------------------------------------------------
--Start of Comments :Bug 3231062
--Name: Is_Retro_Project_Allowed
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns true if retroactive pricing update allow on line with
--  project reference.
--  If the profile option value is set to 'All Releases' and if the Archival
--  mode for the Operating Unit is set to 'Approve', you can update the PO Price
--  even if they were received and/or invoiced, except if there is project
--  information associated with any of the distributions, and PA 11.5.10 is not
--  installed.
--Note:
--  Removed after 11iX
--Parameters:
--IN:
--p_std_po_price_change
--p_po_line_id
--p_po_line_loc_id
--RETURN:
--  'Y':  Retroactive pricing update is allowed
--  'N':    Retroactive pricing update is not allowed
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Is_Retro_Project_Allowed(p_std_po_price_change IN VARCHAR2,
                                  p_po_line_id          IN NUMBER,
                                  p_po_line_loc_id      IN NUMBER
                                 )
  RETURN VARCHAR2
IS

  l_retro_proj_allowed  VARCHAR2(1) := 'Y';
  l_module              VARCHAR2(100);
  l_api_name   CONSTANT VARCHAR2(50) := 'Is_Retro_Project_Allowed';

BEGIN

  l_module := g_log_head||l_api_name||'.'||'000'||'.';

  IF g_debug_stmt then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
      'Project Check');
  END IF;
       IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
         FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
      'Price Change on std PO :' || p_std_po_price_change);
       END IF;
  END IF;

  IF g_projects_11i10_installed = 'Y' THEN
    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
        'Project 11i10 Enabled');
      END IF;
    END IF;
    RETURN 'Y';
  END IF;

  IF p_std_po_price_change = 'Y' THEN
    BEGIN
      -- SQL What: Returns Y if there are any shipment which has project information
      --           and is received/invoiced, 0 otherwise.
      -- SQL Why:  To prevent retro price changes if there are such shipments.
      SELECT 'N'
      INTO   l_retro_proj_allowed
      FROM   DUAL
      WHERE  EXISTS (SELECT 'has project information'
                     FROM   PO_LINE_LOCATIONS_ALL pll,
                            PO_DISTRIBUTIONS_ALL pod
                     WHERE  pll.po_line_id = p_po_line_id
                     AND    pod.line_location_id = pll.line_location_id
                     AND    ((NVL(pll.quantity_received,0) > 0 AND
                              NVL(pll.accrue_on_receipt_flag,'N') = 'Y') OR
                             NVL(pll.quantity_billed,0) > 0)
                     AND    pod.project_id IS NOT NULL);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_retro_proj_allowed := 'Y';
    END;
  ELSE
    BEGIN
      -- SQL What: Returns Y if there are any shipment which has project information
      --           and is received/invoiced, 0 otherwise.
      -- SQL Why:  To prevent retro price changes if there are such shipments.
      SELECT 'N'
      INTO   l_retro_proj_allowed
      FROM   DUAL
      WHERE  EXISTS (SELECT 'has project information'
                     FROM   PO_LINE_LOCATIONS_ALL pll,
                            PO_DISTRIBUTIONS_ALL pod
                     WHERE  pll.line_location_id = p_po_line_loc_id
                     AND    pod.line_location_id = pll.line_location_id
                     AND    ((NVL(pll.quantity_received,0) > 0 AND
                              NVL(pll.accrue_on_receipt_flag,'N') = 'Y') OR
                             NVL(pll.quantity_billed,0) > 0)
                     AND    pod.project_id IS NOT NULL);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_retro_proj_allowed := 'Y';
    END;
  END IF; /*IF p_std_po_price_change = 'Y'*/

  IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
         'Retro Projcet Allowed: '|| l_retro_proj_allowed);
    END IF;
  END IF;

  RETURN l_retro_proj_allowed;

EXCEPTION
WHEN OTHERS THEN
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
   END IF;

   RETURN 'N';
END Is_Retro_Project_Allowed;

--------------------------------------------------------------------------------
--Start of Comments :Bug 3339149
--Name: Is_Adjustment_Account_Valid
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns true if the adjustment account exists and is valid
--Parameters:
--IN:
--p_std_po_price_change
--p_po_line_id
--p_po_line_loc_id
--RETURN:
--  'Y':  Adjustment account is valid
--  'N':    Adjustment Account does not exist or is not valid
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Is_Adjustment_Account_Valid(p_std_po_price_change IN VARCHAR2,
                                     p_po_line_id          IN NUMBER,
                                     p_po_line_loc_id      IN NUMBER
                                     )
  RETURN VARCHAR2
IS

  l_account_valid              varchar2(1) := 'Y';
  l_retroprice_adj_account_id  number;
  l_ship_to_organization_id   PO_LINE_LOCATIONS.ship_to_organization_id%TYPE;
  l_qty_received              PO_LINE_LOCATIONS.quantity_received%TYPE;
  l_accrue_flag               PO_LINE_LOCATIONS.accrue_on_receipt_flag%TYPE;
  l_qty_billed                PO_LINE_LOCATIONS.quantity_billed%TYPE;
  -- Bug 3541961
  l_consigned_flag            PO_HEADERS.consigned_consumption_flag%TYPE;
  l_org_id                    PO_HEADERS.org_id%TYPE;
  l_trans_flow_header_id      PO_LINE_LOCATIONS.transaction_flow_header_id%TYPE;
  l_logical_inv_org_id        number;

  l_module              varchar2(100);
  l_api_name    CONSTANT VARCHAR2(50) := 'Is_Adjustment_Account_Valid';

  cursor c_std_po_shipments is
   select NVL(pll.quantity_received,0),
          NVL(pll.accrue_on_receipt_flag,'N'),
          NVL(pll.quantity_billed,0),
          -- Bug 3541961
          NVL(poh.consigned_consumption_flag,'N'),
          pll.ship_to_organization_id,
          poh.org_id,
          pll.transaction_flow_header_id  -- Bug 3880758
   from   po_line_locations_all pll,
          -- Bug 3541961
          po_headers_all poh
   where  pll.po_line_id = p_po_line_id
   -- Bug 3541961
   and    pll.po_header_id = poh.po_header_id;

  cursor c_rel_shipments is
   select NVL(pll.quantity_received,0),
          NVL(pll.accrue_on_receipt_flag,'N'),
          NVL(pll.quantity_billed,0),
          NVL(por.consigned_consumption_flag,'N'),
          pll.ship_to_organization_id,
          por.org_id,
          null                            -- Bug 3880758
   from   po_line_locations_all pll,
          -- Bug 3541961
          po_releases_all por
   where  pll.line_location_id = p_po_line_loc_id
   -- Bug 3541961
   and    pll.po_release_id = por.po_release_id;

BEGIN

   l_module := g_log_head||l_api_name||'.'||'000'||'.';

   IF g_debug_stmt then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
      'Adj Account validity check');
  END IF;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
      'Price Change on std PO :' || p_std_po_price_change);
        END IF;
   END IF;

   IF p_std_po_price_change = 'Y' THEN
     OPEN c_std_po_shipments;
   ELSE
     OPEN c_rel_shipments;
   END IF;

     LOOP

      IF p_std_po_price_change = 'Y' THEN
        FETCH c_std_po_shipments
         INTO l_qty_received,
              l_accrue_flag,
              l_qty_billed,
              l_consigned_flag, -- Bug 3541961
              l_ship_to_organization_id,
              l_org_id,         -- Bug 3610693
              l_trans_flow_header_id;  -- Bug 3880758
        EXIT when c_std_po_shipments%NOTFOUND;
      ELSE
        FETCH c_rel_shipments
         INTO l_qty_received,
              l_accrue_flag,
              l_qty_billed,
              l_consigned_flag, -- Bug 3541961
              l_ship_to_organization_id,
              l_org_id,         -- Bug 3610693
              l_trans_flow_header_id; -- Bug 3880758
        EXIT when c_rel_shipments%NOTFOUND;
      END IF;

       -- Bug 3880758 Start
       -- If a transaction flow exists we take the account from rcv
       -- parameters of the logical inventory org defined for the
       -- transaction flow
       IF l_trans_flow_header_id is null THEN

         IF g_debug_stmt then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
            'Adj Account from ship to org of PO');
          END IF;
         END IF;

         select retroprice_adj_account_id
         into l_retroprice_adj_account_id
         from rcv_parameters
         where organization_id = l_ship_to_organization_id;

       ELSE
         -- Get the logical inventory org defined for the
         -- transaction flow
         l_logical_inv_org_id := PO_SHARED_PROC_PVT.get_logical_inv_org_id(
               p_transaction_flow_header_id => l_trans_flow_header_id );

         IF g_debug_stmt then
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
            'Adj Account from logical inv org of start OU');
          END IF;
         END IF;

         select retroprice_adj_account_id
         into l_retroprice_adj_account_id
         from rcv_parameters
         where organization_id = l_logical_inv_org_id;

       END IF;
       -- Bug 3880758 End

        IF  (((l_qty_received > 0) AND (l_accrue_flag = 'Y'))
             OR (l_qty_billed > 0)
             -- Bug 3541961
             OR (l_consigned_flag = 'Y'))  THEN

          IF l_retroprice_adj_account_id is null THEN

              l_account_valid := 'N';
              exit;

          ELSE

           Begin
            SELECT distinct 'Y'
            INTO   l_account_valid
            FROM   gl_code_combinations gcc,
                   gl_sets_of_books sob,
                   financials_system_params_all fsp
            WHERE  gcc.code_combination_id = l_retroprice_adj_account_id
            AND  gcc.enabled_flag = 'Y'
            AND  trunc(SYSDATE) BETWEEN
                 trunc(nvl(start_date_active,SYSDATE - 1) )
                 AND
                 trunc(nvl (end_date_active,SYSDATE + 1) )
            AND  gcc.detail_posting_allowed_flag = 'Y'
            AND  gcc.summary_flag = 'N'
            AND  gcc.chart_of_accounts_id = sob.chart_of_accounts_id
            AND  fsp.org_id = l_org_id  -- Bug 3610693
            AND  sob.set_of_books_id = fsp.set_of_books_id;
           Exception
           When no_data_found then
             l_account_valid := 'N';
             exit;
           End;

          END IF; -- End of account null

        END IF; -- End of partially received/invoiced

      END LOOP;

     IF p_std_po_price_change = 'Y' THEN
      CLOSE c_std_po_shipments;
     ELSE
      CLOSE c_rel_shipments;
     END IF;

   IF g_debug_stmt then
  IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
    FND_LOG.string(FND_LOG.LEVEL_STATEMENT,l_module,
      'Adj Account validity flag: '|| l_account_valid);
  END IF;
   END IF;

   Return l_account_valid;

Exception
When Others then
   IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
      l_module,SQLERRM(SQLCODE));
   END IF;

   IF (c_std_po_shipments%ISOPEN) THEN
      CLOSE c_std_po_shipments;
   END IF;

   IF (c_rel_shipments%ISOPEN) THEN
      CLOSE c_rel_shipments;
   END IF;

   Return 'N';
END;

--------------------------------------------------------------------------------
--Start of Comments: Bug 4080732
--Name: is_inv_org_period_open
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function returns true if the Inventory accounting period is open for
--  all ship-to-org's at the shipment level for a Consumption Advice.
--      For Standard PO's, this function is called at the line level. So it
--  checks all PO shipments in a loop.
--      For Blanket releases, this function is called at shipment level. So we
--  do not need a loop.
--
--      If the document is not a Consumption Advice, this function returns 'Y'.
--
--  Note on geting the Inv Org:
--  ---------------------------
--      For this check, we get the Inv Org from the ship-to-org at the shipment
--  level (for regular flows). And for Shared Procuremnet scenario, we use the
--  logical inv org of the transaction flow.
--
--Parameters:
--IN:
--  p_std_po_price_change
--  p_po_line_id
--  p_po_line_loc_id
--RETURN:
--  'Y': If the Inventory accounting period is open for all ship-to-org's at the
--       shipment level. Also returns 'Y' is the document is not a Consumption
--       Advice.
--  'N': If even for one ship-to-org of the Consumption Advice, the Inventory
--       period is not open.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_inv_org_period_open
( p_std_po_price_change IN VARCHAR2,
  p_po_line_id          IN NUMBER,
  p_po_line_loc_id      IN NUMBER
)
RETURN VARCHAR2
IS

  l_is_inv_org_period_open    VARCHAR2(1) := 'Y';
  l_consigned_flag            PO_HEADERS.consigned_consumption_flag%TYPE;
  l_trans_flow_header_id      PO_LINE_LOCATIONS.transaction_flow_header_id%TYPE;
  l_ship_to_organization_id   PO_LINE_LOCATIONS.ship_to_organization_id%TYPE;
  l_logical_inv_org_id        MTL_TRANSACTION_FLOW_LINES.from_organization_id%TYPE;
  l_inv_org_id_period_check   HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE;

  l_module      VARCHAR2(100);
  l_api_name    CONSTANT VARCHAR2(50) := 'is_inv_org_period_open';
  l_count       NUMBER;

  CURSOR STD_PO_SHIPMENTS_CSR IS
    SELECT NVL(poh.consigned_consumption_flag, 'N'),
           pll.ship_to_organization_id,
           pll.transaction_flow_header_id
    FROM   po_line_locations_all pll,
           po_headers_all poh
    WHERE  pll.po_line_id = p_po_line_id
    AND    pll.po_header_id = poh.po_header_id;

  CURSOR REL_SHIPMENTS_CSR IS
    SELECT NVL(por.consigned_consumption_flag, 'N'),
           pll.ship_to_organization_id,
           NULL
    FROM   po_line_locations_all pll,
           po_releases_all por
    WHERE  pll.line_location_id = p_po_line_loc_id
    AND    pll.po_release_id = por.po_release_id;

BEGIN

  l_module := g_log_head || l_api_name || '.' || '000' || '.';

  IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Inventory Org Open Period Check');
    END IF;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Is price to be changed on Std PO ? : ' || p_std_po_price_change);
    END IF;
  END IF;

  IF p_std_po_price_change = 'Y' THEN
    OPEN STD_PO_SHIPMENTS_CSR;
  ELSE
    OPEN REL_SHIPMENTS_CSR;
  END IF;

  l_count := 1;
  LOOP

    IF p_std_po_price_change = 'Y' THEN
      FETCH STD_PO_SHIPMENTS_CSR
      INTO l_consigned_flag,
           l_ship_to_organization_id,
           l_trans_flow_header_id;

      EXIT when STD_PO_SHIPMENTS_CSR%NOTFOUND;
    ELSE
      FETCH REL_SHIPMENTS_CSR
      INTO l_consigned_flag,
           l_ship_to_organization_id,
           l_trans_flow_header_id;

      EXIT when REL_SHIPMENTS_CSR%NOTFOUND;
    END IF;

    IF g_debug_stmt THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                     'count='||l_count||
                     ', consigned_flag='||l_consigned_flag||
                     ', ship_to_org_id='||l_ship_to_organization_id||
                     ', trans_flow_header_id='||l_trans_flow_header_id);
      END IF;
    END IF;

    -- If it is not a consigned flow, there is no need of checking the status
    -- of Inventory Org Period. So exit the loop with return value 'Y'.
    IF (l_consigned_flag = 'N') THEN
      l_is_inv_org_period_open := 'Y';
      EXIT;
    END IF;

    -- If a transaction flow exists we use the logical inventory org defined
    -- for the transaction flow to check the Opne Inventory period.
    IF l_trans_flow_header_id IS NULL THEN

      l_inv_org_id_period_check := l_ship_to_organization_id;

      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'Open Period Check for ship-to-org');
        END IF;
      END IF;

    ELSE
      -- Get the logical inventory org defined for the transaction flow
      l_logical_inv_org_id := PO_SHARED_PROC_PVT.get_logical_inv_org_id(
                  p_transaction_flow_header_id => l_trans_flow_header_id );

      l_inv_org_id_period_check := l_logical_inv_org_id;

      IF g_debug_stmt THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                       'Open Period Check for logical inv org of start OU:'||
                       l_logical_inv_org_id);
        END IF;
      END IF;

    END IF; -- IF l_trans_flow_header_id IS NULL

    IF l_inv_org_id_period_check IS NULL THEN
      l_is_inv_org_period_open := 'N';
      EXIT;
    ELSE
      -- Call the API to check Inventory Org Open Period
      -- The SOB_ID parameter can be null for Inventory open period check,
      -- because it is not used inside this API when APP_NAME is 'INV'
      IF (PO_DATES_S.val_open_period(
                        x_trx_date => sysdate,  -- IN DATE
                        x_sob_id   => NULL,     -- IN NUMBER,
                        x_app_name => 'INV',    -- IN VARCHAR2
                        x_org_id   => l_inv_org_id_period_check) -- IN NUMBER
          = FALSE ) THEN

        l_is_inv_org_period_open := 'N';

        IF g_debug_stmt THEN
          IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                         'Result from PO_DATES_S.val_open_period is FALSE');
          END IF;
        END IF;

        EXIT;
      END IF;
    END IF; -- IF l_inv_org_id_period_check IS NULL
  END LOOP;

  IF (p_std_po_price_change = 'Y') THEN
    CLOSE STD_PO_SHIPMENTS_CSR;
  ELSE
    CLOSE REL_SHIPMENTS_CSR;
  END IF;

  IF g_debug_stmt THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, l_module,
                   'Returning: Inventory Org Period Open='||
                   l_is_inv_org_period_open);
    END IF;
  END IF;

  RETURN l_is_inv_org_period_open;

EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, l_module, SQLERRM(SQLCODE));
    END IF;

    IF (STD_PO_SHIPMENTS_CSR%ISOPEN) THEN
      CLOSE STD_PO_SHIPMENTS_CSR;
    END IF;

    IF (REL_SHIPMENTS_CSR%ISOPEN) THEN
      CLOSE REL_SHIPMENTS_CSR;
    END IF;

   RETURN 'N';
END is_inv_org_period_open;

END PO_RETROACTIVE_PRICING_PVT;

/
