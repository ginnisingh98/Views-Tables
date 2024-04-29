--------------------------------------------------------
--  DDL for Package Body PO_WF_PO_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_PO_NOTIFICATION" AS
/* $Header: POXWPA7B.pls 120.9.12010000.33 2013/02/01 07:16:54 gjyothi ship $ */

g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_pkg_name         VARCHAR2(30) := 'PO_WF_PO_NOTIFICATION';    -- <BUG 3607009>

--Added this private procedure as part of bug 13951919 fix
PROCEDURE update_action_history (p_action_code         IN VARCHAR2,
                              p_recipient_id           IN NUMBER,
                              p_note                   IN VARCHAR2,
                              p_po_header_id           IN NUMBER,
                              p_current_id             IN NUMBER,
                              p_doc_type               IN  po_action_history.OBJECT_TYPE_CODE%TYPE,
			      p_doc_subtype            IN po_action_history.OBJECT_SUB_TYPE_CODE%TYPE,
                              p_approval_path_id       IN po_action_history.APPROVAL_PATH_ID%TYPE); --<bug 14105414>

PROCEDURE get_po_approve_msg (	 document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type    wf_items.item_type%TYPE;
  l_item_key     wf_items.item_key%TYPE;

  l_document_id      po_headers.po_header_id%TYPE;
  l_org_id           po_headers.org_id%TYPE;
  l_currency_code    fnd_currencies.CURRENCY_CODE%TYPE;
  l_header_msg       VARCHAR2(500);
  l_po_amount        VARCHAR2(30);
  l_tax_amount       VARCHAR2(30);

  --bug 12396408
  l_po_amount_numeric        NUMBER;
  l_tax_amount_numeric       NUMBER;

  l_description      po_headers.comments%TYPE;
  l_forwarded_from   per_all_people_f.full_name%TYPE;
  l_preparer         per_all_people_f.full_name%TYPE;
--<UTF-8 FPI START>
--  l_note             VARCHAR2(480);  /* < UTF8 FPI - changed from VARCHAR2(240) > */
  l_note             po_action_history.note%TYPE;
--<UTF-8 FPI END>
  l_document         VARCHAR2(32000) := '';
  l_tax_amt          NUMBER;

  /* Start Bug# 3972475 */
  X_precision        number;
  X_ext_precision    number;
  X_min_acct_unit    number;
  /* End Bug# 3972475*/
  l_supplier         po_vendors.vendor_name%type; --Bug 4254468
  l_supplier_site    po_vendor_sites_all.vendor_site_code%type; --Bug 4254468
  NL                 VARCHAR2(1) := fnd_global.newline;

--Added by Eric Ma for IL PO Notification on Apr-13,2009 ,Begin
-------------------------------------------------------------------------------------
lv_tax_region        varchar2(30);        --tax region code
ln_jai_excl_nr_tax   NUMBER;              --exclusive non-recoverable tax
lv_progress          VARCHAR2(255);       --for saving the debug information
lv_document_type     VARCHAR2(25);        --document type
-------------------------------------------------------------------------------------
--Added by Eric Ma for IL PO Notification on Apr-13,2009 ,End
BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>


  l_currency_code := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FUNCTIONAL_CURRENCY');

  l_po_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'PO_AMOUNT_DSP');

  l_tax_amount := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TAX_AMOUNT_DSP');
  -- bug 12396408   --bug 14007360
  l_po_amount_numeric := PO_WF_UTIL_PKG.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'PO_AMOUNT_DSP_NUMERIC');

  l_tax_amount_numeric := PO_WF_UTIL_PKG.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'TAX_AMOUNT_DSP_NUMERIC');


  l_description := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'PO_DESCRIPTION');

  l_forwarded_from := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'FORWARD_FROM_DISP_NAME');

  l_preparer := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'PREPARER_DISPLAY_NAME');

  l_note := wf_engine.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'NOTE');

  --<Bug 4254468 Start> Show supplier and supplier site for
  -- approval notifications
  l_supplier := PO_WF_UTIL_PKG.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'SUPPLIER');

  l_supplier_site := PO_WF_UTIL_PKG.GetItemAttrText
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'SUPPLIER_SITE');
  --<Bug 4254468 End>

/*Start Bug# 3972475 - replaced the below sql to get the tax amount
  to account for canceled QTY. Also accounted for new order types introduced
  in 11i10 that use amount instead of quantity (where quantity_ordered is null).

  Since we are performing divide and multiply by operations we need rounding
  logic based on the currency.

  If we are using minimum accountable unit we apply:
   rounded tax = round(tax/mau)*mau, otherwise
   rounded tax = round(tax, precision)

   Old tax select:
  SELECT nvl(sum(nonrecoverable_tax), 0)
    INTO l_tax_amt
    FROM po_lines pol,
         po_distributions pod
   WHERE pol.po_header_id = l_document_id
     AND pod.po_line_id = pol.po_line_id;
*/

  --Modified by Eric Ma for IL po workflow notification on Apr-13,2009 ,Begin
  -------------------------------------------------------------------------------------
  lv_tax_region      := JAI_PO_WF_UTIL_PUB.Get_Tax_Region (pn_org_id => l_org_id);

  IF (lv_tax_region ='JAI')
  THEN
    --Get document type
    lv_document_type := wf_engine.GetItemAttrText
                        ( itemtype   => l_item_type
                        , itemkey    => l_item_key
                        , aname      => 'DOCUMENT_TYPE'
                        );

    --Indian localization tax calculation
    IF  lv_document_type = 'RELEASE'
    THEN
      JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount
      ( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_REL_DOC_TYPE
      , pn_document_id        => l_document_id
      , xn_excl_tax_amount    => l_tax_amt
      , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
      );

    ELSE
      JAI_PO_WF_UTIL_PUB.Get_Jai_Tax_Amount
      ( pv_document_type      => JAI_PO_WF_UTIL_PUB.G_PO_DOC_TYPE
      , pn_document_id        => l_document_id
      , xn_excl_tax_amount    => l_tax_amt
      , xn_excl_nr_tax_amount => ln_jai_excl_nr_tax
      );
    END IF; --(lv_document_type = 'RELEASE')
  ELSE
    --original tax calc code

    fnd_currency.get_info( l_currency_code,
                           X_precision,
                           X_ext_precision,
                           X_min_acct_unit);

    IF (x_min_acct_unit IS NOT NULL) AND
        (x_min_acct_unit <> 0)
    THEN
      SELECT sum( round (POD.nonrecoverable_tax *
                         decode(quantity_ordered,
                                NULL,
                                 --Bug16222308 Handling the quantity zero on distribution
                                (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) / decode ( nvl(POD.amount_ordered, 1),0,1,nvl(POD.amount_ordered, 1) ) ,
                                (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) / decode ( nvl(POD.quantity_ordered, 1),0,1, nvl(POD.quantity_ordered, 1) )
                               ) / X_min_acct_unit
                         ) * X_min_acct_unit
                )
      INTO l_tax_amt
      FROM po_lines pol,
           po_distributions pod
     WHERE pol.po_header_id = l_document_id
       AND pod.po_line_id = pol.po_line_id;
    ELSE
      SELECT sum( round (POD.nonrecoverable_tax *
                         decode(quantity_ordered,
                                NULL,
                                --Bug16222308 Handling the quantity zero on distribution
                                (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) / decode ( nvl(POD.amount_ordered, 1),0,1,nvl(POD.amount_ordered, 1) ) ,
                                (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) / decode ( nvl(POD.quantity_ordered, 1),0,1, nvl(POD.quantity_ordered, 1) )
                               ),
                         X_precision
                        )
                )
      INTO l_tax_amt
      FROM po_lines pol,
           po_distributions pod
     WHERE pol.po_header_id = l_document_id
       AND pod.po_line_id = pol.po_line_id;
    END IF;
  END IF;--(lv_tax_region ='JAI')
  -------------------------------------------------------------------------------------
  --Modified by Eric Ma for IL po workflow notification on Apr-13,2009 ,End

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- PO_APPROVE_MSG -->'|| NL || NL || '<P>';

    l_document := l_document || '</P>' || NL;
--Bug 9067919
--&nbsp; which is the entity used to represent a non-breaking space had the semi-colon missing
--Replaced all occurences with the correct syntax &nbsp; instead of &nbsp

    l_document := l_document || '<P><TABLE border=0 cellpadding=0 cellspacing=0 SUMMARY=""><TR><TD align=right >' || NL ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_AMOUNT') ||
                  '&nbsp;&nbsp;</TD>' || NL;

     -- 12396408 Formatting the total amount
    l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || nvl(TO_CHAR(l_po_amount_numeric, FND_CURRENCY.GET_FORMAT_MASK(
                              l_currency_code, 30)),'&nbsp;') || '</TD></TR>' || NL;

    if l_tax_amt > 0 then

      l_document := l_document || '<TR><TD align=right>' ||
                    fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX_AMOUNT') ||
                    '&nbsp;&nbsp;</TD>' || NL;
      --bug 12396408 formatting the tax
      l_document := l_document || '<TD align=left>' || l_currency_code || ' ' || nvl(TO_CHAR(l_tax_amount_numeric , FND_CURRENCY.GET_FORMAT_MASK(
                              l_currency_code, 30)),'&nbsp;') ||
                    '</TD></TR></TABLE></P>' || NL;

    else

      l_document := l_document || '</TABLE></P>' || NL || NL;

    end if;

    --<Bug 4254468 Start> Show supplier and supplier site for
    -- approval notifications
    l_document := l_document || '<P>' || NL;
    l_document := l_document || fnd_message.get_string('PO', 'PO_FO_VENDOR') ||
                  ' '|| l_supplier || NL;
    l_document := l_document || '<BR>' || NL;
    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SUPPLIER_SITE') ||
                  ' '|| l_supplier_site || NL;
    l_document := l_document || '</P>' || NL;
    --<Bug 4254468 End>

    if l_description is not null then
      l_document := l_document || '<P>' || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_DESCRIPTION') || NL || '<BR>';
      l_document := l_document || l_description;
      l_document := l_document || '<BR></P>' || NL;
    end if;

  else  -- plain text notification is defined in the WF.

	null;

  end if;

  document := l_document;

END;


PROCEDURE get_po_lines_details ( document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY CLOB, -- <BUG 7006113>
                                 document_type	in out	NOCOPY varchar2) IS

  l_item_type        wf_items.item_type%TYPE;
  l_item_key         wf_items.item_key%TYPE;

  l_document_id      po_lines.po_header_id%TYPE;
  l_org_id           po_lines.org_id%TYPE;
  l_document_type    VARCHAR2(25);

  l_document         VARCHAR2(32000) := '';

  l_currency_code    fnd_currencies.currency_code%TYPE;

  -- Bug 3668188: added new local var. note: the length of this
  -- varchar was determined based on the length in POXWPA1B.pls,
  -- which is the other place 'OPEN_FORM_COMMAND' attribute is used

  l_open_form_command VARCHAR2(200);
  l_view_po_url      varchar2(1000);   -- HTML Orders R12
  l_edit_po_url      varchar2(1000);   -- HTML Orders R12

  NL                 VARCHAR2(1) := fnd_global.newline;

  i 		     NUMBER := 0;
  max_lines_dsp      NUMBER ;  -- <BUG 7006113>
  l_line_count       NUMBER := 0; -- <BUG 3616816> # lines/shipments on document
  line_mesg          fnd_new_messages.message_text%TYPE; --Bug 4695601
  l_num_records_to_display NUMBER;      -- <BUG 3616816> actual # of records to be displayed in table

  -- <BUG 7006113 START>
  curr_len           NUMBER := 0; --<BUG 7614278 Reverting back the commented variable>
  -- prior_len          NUMBER := 0;
  -- <BUG 7006113 END>

-- po lines cursor

    -- <BUG 3616816 START> Declare TABLEs for each column that is selected
    -- from po_line_csr and po_line_loc_csr.
    --
    TYPE line_num_tbl_type IS TABLE OF PO_LINES.line_num%TYPE;
    TYPE shipment_num_tbl_type IS TABLE OF PO_LINE_LOCATIONS.shipment_num%TYPE;
    TYPE item_num_tbl_type IS TABLE OF MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;
    TYPE item_revision_tbl_type IS TABLE OF PO_LINES.item_revision%TYPE;
    TYPE item_desc_tbl_type IS TABLE OF PO_LINES.item_description%TYPE;
    TYPE uom_tbl_type IS TABLE OF MTL_UNITS_OF_MEASURE.unit_of_measure_tl%TYPE;
    TYPE quantity_tbl_type IS TABLE OF PO_LINES.quantity%TYPE;
    TYPE unit_price_tbl_type IS TABLE OF PO_LINES.unit_price%TYPE;
    TYPE amount_tbl_type IS TABLE OF PO_LINES.amount%TYPE;
    TYPE location_tbl_type IS TABLE OF HR_LOCATIONS.location_code%TYPE;
    TYPE organization_name_tbl_type IS TABLE OF ORG_ORGANIZATION_DEFINITIONS.organization_name%TYPE;
    TYPE need_by_date_tbl_type IS TABLE OF PO_LINE_LOCATIONS.need_by_date%TYPE;
    TYPE promised_date_tbl_type IS TABLE OF PO_LINE_LOCATIONS.promised_date%TYPE;
    TYPE shipment_type_tbl_type IS TABLE OF PO_LINE_LOCATIONS.shipment_type%TYPE;

    l_line_num_tbl         line_num_tbl_type;
    l_shipment_num_tbl     shipment_num_tbl_type;
    l_item_num_tbl         item_num_tbl_type;
    l_item_revision_tbl    item_revision_tbl_type;
    l_item_desc_tbl        item_desc_tbl_type;
    l_uom_tbl              uom_tbl_type;
    l_quantity_tbl         quantity_tbl_type;
    l_unit_price_tbl       unit_price_tbl_type;
    l_amount_tbl           amount_tbl_type;
    l_location_tbl         location_tbl_type;
    l_org_name_tbl         organization_name_tbl_type;
    l_need_by_date_tbl     need_by_date_tbl_type;
    l_promised_date_tbl    promised_date_tbl_type;
    l_shipment_type_tbl    shipment_type_tbl_type;
	l_inventory_org_id    number; -- bug 13410981
    --
    -- <BUG 3616816 END>

/* Bug# 1419139: kagarwal
** Desc: The where clause pol.org_id = msi.organization_id(+) in the
** PO lines cursor, po_line_csr, is not correct as the pol.org_id
** is the operating unit which is not the same as the inventory
** organization_id.
**
** We need to use the financials_system_parameter table for the
** inventory organization_id.
**
** Also did the similar changes for the Release cursor,po_line_loc_csr.
*/

/* Bug 2401933: sktiwari
   Modifying cursor po_line_csr to return the translated UOM value
   instead of unit_meas_lookup_code.
*/

 /*Bug 13410981 : For fixing performance removing the fsp from the cursor select and bind the
 inventory organization id with outer join. Also adding hint.*/

CURSOR po_line_csr(v_document_id NUMBER) IS
SELECT /*+ FIRST_ROWS */ pol.line_num,
       msi.concatenated_segments,
       pol.item_revision,
       pol.item_description,
--     pol.unit_meas_lookup_code, -- bug 2401933.remove
       nvl(muom.unit_of_measure_tl, pol.unit_meas_lookup_code), -- bug 2401933.add
       pol.quantity,
       pol.unit_price,
       nvl(pol.amount, pol.quantity * pol.unit_price)
  FROM po_lines   pol,
       mtl_system_items_kfv   msi,
       mtl_units_of_measure   muom     -- bug 2401933.add
 WHERE pol.po_header_id = v_document_id
   AND pol.item_id = msi.inventory_item_id(+)
   AND msi.organization_id(+) = 	l_inventory_org_id
/* Bug 2299484 fixed. prevented the canceled lines to be displayed
   in notifications.
*/
   AND NVL(pol.cancel_flag,'N') = 'N'
   AND muom.unit_of_measure (+) = pol.unit_meas_lookup_code  -- bug 2401933.add
 ORDER BY pol.line_num;

-- release shipments cursor

/* Bug# 1530303: kagarwal
** Desc: We need to change the where clause as the item
** may not be an inventory item. For this case we should
** have an outer join with the mtl_system_items_kfv.
**
** Changed the condition:
** pol.item_id = msi.inventory_item_id
** to pol.item_id = msi.inventory_item_id(+)
**
*/

/* Bug# 1718725: kagarwal
** Desc: The unit of measure may be null at the shipment level
** hence in this case we need to get the uom from line level.
**
** Changed nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)
*/
/* Bug# 1770951: kagarwal
** Desc: For Releases we should consider the price_override on the shipments
** and not the price on the Blanket PO line as the shipment price could be
** different if the price override is enabled on the Blanket.
*/

/* Bug 2401933: sktiwari
   Modifying cursor po_line_loc_csr to return the translated UOM value
   instead of unit_meas_lookup_code.
*/

 /*Bug 13410981 : For fixing performance removing the fsp from the cursor select and bind the
 inventory organization id with outer join. Also adding hint.*/

CURSOR po_line_loc_csr(v_document_id NUMBER) IS
SELECT /*+ FIRST_ROWS */ pll.shipment_num,
       msi.concatenated_segments,
       pol.item_revision,
       pol.item_description,
-- Bug 2401933.start
--     nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code)
--         unit_meas_lookup_code,
       nvl(muom.unit_of_measure_tl, pol.unit_meas_lookup_code),
-- Bug 2401933.end
       pll.quantity,
       nvl(pll.price_override, pol.unit_price) unit_price,
       hrl.location_code,
       ood.organization_name,
       pll.need_by_date,
       pll.promised_date,
       pll.shipment_type,
       --Bug 4950850 Added pll.amount
       --Bug 5563024 AMOUNT NOT SHOWN FOR A RELEASE SHIPMENT IN APPROVAL NOTIFICATION.
       nvl(pll.amount, nvl(pll.price_override, pol.unit_price) * pll.quantity)
  FROM po_lines   pol,
       po_line_locations pll,
       mtl_system_items_kfv msi,
       hr_locations_all hrl,
       hz_locations hz,
       org_organization_definitions ood,
       mtl_units_of_measure   muom     -- Bug 2401933.add
  where  PLL.PO_RELEASE_ID = v_document_id
  and    PLL.po_line_id    = POL.po_line_id
  and    PLL.ship_to_location_id = HRL.location_id (+)
  and    PLL.ship_to_location_id = HZ.location_id (+)
  and    PLL.ship_to_organization_id = OOD.organization_id
  and    pol.item_id = msi.inventory_item_id(+)
  and    msi.organization_id(+) = l_inventory_org_id
 /* Bug 2299484 fixed. prevented the canceled shipments to be displayed
   in notifications.
*/
   AND NVL(PLL.cancel_flag,'N') = 'N'
   AND muom.unit_of_measure (+) = pol.unit_meas_lookup_code  -- Bug 2401933.add
  order by Shipment_num asc;

BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  /* Bug# 2353153
  ** Setting application context
  */

  PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(l_item_type, l_item_key);

  l_document_id := wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                         	itemkey    => l_item_key,
                                         	aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber (itemtype   => l_item_type,
                                           itemkey    => l_item_key,
                                           aname      => 'ORG_ID');

  l_document_type := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                           	itemkey    => l_item_key,
                                           	aname      => 'DOCUMENT_TYPE');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>


  /* Bug# 1686066: kagarwal
  ** Desc: Use the functional currency of the PO for the precision of
  ** line amounts.
  */

  l_currency_code := wf_engine.GetItemAttrText
                               (itemtype   => l_item_type,
                                itemkey    => l_item_key,
                                aname      => 'FUNCTIONAL_CURRENCY');


  -- Bug 3668188
  l_open_form_command := PO_WF_UTIL_PKG.GetItemAttrText
                               (itemtype   => l_item_type,
                                itemkey    => l_item_key,
                                aname      => 'OPEN_FORM_COMMAND');

  -- HTML Orders R12
  -- Get the PO HTML Page URL's
  l_view_po_url := PO_WF_UTIL_PKG.GetItemAttrText (
                              itemtype   => l_item_type,
                              itemkey    => l_item_key,
                              aname      => 'VIEW_DOC_URL');

  l_edit_po_url := PO_WF_UTIL_PKG.GetItemAttrText (
                              itemtype   => l_item_type,
                              itemkey    => l_item_key,
                              aname      => 'EDIT_DOC_URL');


/* Bug# 2668222: kagarwal
** Desc: Using profile PO_NOTIF_LINES_LIMIT to get the maximum
** number of PO lines to be displayed in Approval notification.
** The same profile is also used for Requisitions.
*/
  -- <BUG 7006113  START Moved this code to the later section of the procedure >
  --  max_lines_dsp:= to_number(fnd_profile.value('PO_NOTIF_LINES_LIMIT'));

  -- if max_lines_dsp is NULL then
  --   max_lines_dsp := 20;
  -- end if;
  -- <BUG 7006113 END>

    -- <BUG 3616816 START> Fetch Release Shipments/PO Lines data into Tables.
    --
/* Bug 13410981 :  Fetching inventory organization id and maximum num,ber of lines to display from profile.*/
    SELECT inventory_organization_id
      INTO l_inventory_org_id
      FROM financials_system_parameters;

    max_lines_dsp:= to_number(fnd_profile.value('PO_NOTIF_LINES_LIMIT'));

/* Bug 13410981 : Changing whole logic for fetching number of records to be displayed. Logic is to fetch
 max_lines_dsp + 1 record if profile value is non null and all records if profile value is null. This helps in improving performance.
 Also we fetch  max_lines_dsp + 1 instead of max_lines_dsp to check whether there are more reocrds so that
 message PO_WF_NOTIF_PO_LINE_MESG can be displyed accordingly.
 */

  IF ( l_document_type = 'RELEASE' ) THEN
        OPEN po_line_loc_csr(l_document_id);
        IF max_lines_dsp is NOT NULL THEN
			  FETCH po_line_loc_csr BULK COLLECT INTO l_shipment_num_tbl
																 , l_item_num_tbl
																 , l_item_revision_tbl
																 , l_item_desc_tbl
																 , l_uom_tbl
																 , l_quantity_tbl
																 , l_unit_price_tbl
																 , l_location_tbl
																 , l_org_name_tbl
																 , l_need_by_date_tbl
																 , l_promised_date_tbl
																 , l_shipment_type_tbl
																 , l_amount_tbl    --bug 4950850
														 LIMIT max_lines_dsp + 1;
			  l_line_count := po_line_loc_csr%ROWCOUNT; -- Get # of records fetched.
		  ELSE
			  FETCH po_line_loc_csr BULK COLLECT INTO l_shipment_num_tbl
																 , l_item_num_tbl
																 , l_item_revision_tbl
																 , l_item_desc_tbl
																 , l_uom_tbl
																 , l_quantity_tbl
																 , l_unit_price_tbl
																 , l_location_tbl
																 , l_org_name_tbl
																 , l_need_by_date_tbl
																 , l_promised_date_tbl
																 , l_shipment_type_tbl
																 , l_amount_tbl;    --bug 4950850
			  l_line_count := po_line_loc_csr%ROWCOUNT; -- Get # of records fetched.
		  END IF;
        CLOSE po_line_loc_csr;
    ELSE

        OPEN po_line_csr(l_document_id);
        IF max_lines_dsp is NOT NULL THEN
			  FETCH po_line_csr BULK COLLECT INTO l_line_num_tbl
															, l_item_num_tbl
															, l_item_revision_tbl
															, l_item_desc_tbl
															, l_uom_tbl
															, l_quantity_tbl
															, l_unit_price_tbl
															, l_amount_tbl
													LIMIT max_lines_dsp + 1;

			  l_line_count := po_line_csr%ROWCOUNT; -- Get # of records fetched.
		  ELSE
			  FETCH po_line_csr BULK COLLECT INTO l_line_num_tbl
															, l_item_num_tbl
															, l_item_revision_tbl
															, l_item_desc_tbl
															, l_uom_tbl
															, l_quantity_tbl
															, l_unit_price_tbl
															, l_amount_tbl;
			  l_line_count := po_line_csr%ROWCOUNT; -- Get # of records fetched.
		  END IF;
        CLOSE po_line_csr;

    END IF;

    IF max_lines_dsp IS NULL THEN

	max_lines_dsp := l_line_count;

    END IF;

    -- <BUG 3616816 START> Determine the actual number of records to display
    -- in the table.
    --
    IF ( l_line_count >= max_lines_dsp )
    THEN
        l_num_records_to_display := max_lines_dsp;
    ELSE
        l_num_records_to_display := l_line_count;
    END IF;
    --
    -- <BUG 3616816 END>

  if (display_type = 'text/html') then

    if (nvl(l_document_type, 'PO') <> 'RELEASE') then

    	l_document := NL || NL || '<!-- PO_LINE_DETAILS -->'|| NL || NL || '<P><B>';
    	l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_LINE_DETAILS');
    	l_document := l_document || '</B>' || NL || '<P>';     -- <BUG 3616816>

        -- <BUG 3616816 START> Only display message if # of actual lines is
        -- greater than maximum limit.
        --
        IF ( l_line_count > max_lines_dsp ) THEN

            -- Bug 3668188: changed the code check (originally created
            -- in bug 3607009) that determines which message to show
            -- based on whether Open Document icon is shown in the notif.
            -- The value of WF attribute 'OPEN_FORM_COMMAND' is set in a
            -- previous node, using the get_po_user_msg_attribute procedure.
            --
            -- HTML Orders R12
            -- Check for the URL parameters as well
            IF  (l_open_form_command IS NULL ) AND
                (l_view_po_url IS NULL )       AND
                (l_edit_po_url IS NULL )
            THEN
               -- "The first [COUNT] Purchase Order lines are summarized below."
               FND_MESSAGE.set_name('PO','PO_WF_NOTIF_PO_LINE_MESG_TRUNC');
            ELSE
               -- "The first [COUNT] Purchase Order lines are summarized
               -- below. For information on additional lines, please click
               -- the Open Document icon."
               FND_MESSAGE.set_name('PO','PO_WF_NOTIF_PO_LINE_MESG');
            END IF;

            FND_MESSAGE.set_token('COUNT',to_char(max_lines_dsp));
            line_mesg := FND_MESSAGE.get;
            l_document := l_document || line_mesg || '<P>';


        END IF;
        --
        -- <BUG 3616816 END>

    	l_document := l_document || NL || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_PO_TO_APPROVE_SUM') || '"> '|| NL;

    	l_document := l_document || '<TR>' || NL;

    	l_document := l_document || '<TH  id="lineNum_1">' ||
   	               fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="itemNum_1">' ||
    	              fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') || '</TH>' || NL;

   	l_document := l_document || '<TH  id="itemRev_1">' ||
        	      fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="itemDesc_1">' ||
                  	fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="uom_1">' ||
                  	fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="quant_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="unitPrice_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="lineAmt_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT') || '</TH>' || NL;

    	l_document := l_document || '</TR>' || NL;

        -- curr_len  := lengthb(l_document);
        -- prior_len := curr_len;

        FOR i IN 1..l_num_records_to_display LOOP              -- <BUG 3616816>

                /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */
		-- < BUG 7006113 START Commented the loop to avoid the check so that maximum
                --  lines can be displayed >
                -- if (curr_len + (2 * (curr_len - prior_len))) >= 32000 then
                --  exit;
                --  end if;
		--  prior_len := curr_len;
		-- < BUG 7006113 END >

      		l_document := l_document || '<TR>' || NL;

      		l_document := l_document || '<TD nowrap align=center headers="lineNum_1">'
						    || nvl(to_char(l_line_num_tbl(i)), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap headers="itemNum_1">'
						    || nvl(l_item_num_tbl(i), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap headers="itemRev_1">'
						    || nvl(l_item_revision_tbl(i), '&nbsp;') || '</TD>' || NL;
                /* Bug 11825584 removing nowrap and adding align=left*/
      		l_document := l_document || '<TD align=left headers="itemDesc_1">'
						    || nvl(l_item_desc_tbl(i), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap headers="uom_1">'
						    || nvl(l_uom_tbl(i), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap align=right headers="quant_1">'
						    || nvl(to_char(l_quantity_tbl(i)), '&nbsp;') || '</TD>' || NL;

/* Bug 2868931: kagarwal
** We will not format the unit price on the lines in notifications
*/
                -- Bug 3547777. Added the nvl clauses to unit_price and line_
                -- amount so that box is still displayed even if value is null.
      		l_document := l_document || '<TD nowrap align=right headers="unitPrice_1">' ||
                     nvl(PO_WF_REQ_NOTIFICATION.FORMAT_CURRENCY_NO_PRECESION(l_currency_code,l_unit_price_tbl(i)),'&nbsp;') || '</TD>' || NL; -- <BUG 7006113>

      		l_document := l_document || '<TD nowrap align=right headers="lineAmt_1">' ||
                  nvl(TO_CHAR(l_amount_tbl(i), FND_CURRENCY.GET_FORMAT_MASK(
                              l_currency_code, 30)),'&nbsp;') || '</TD>' || NL;

      		l_document := l_document || '</TR>' || NL;

                -- <BUG 7006113 START>
		--curr_len  := lengthb(l_document);

                wf_notification.writetoclob(document, l_document);

                l_document := NULL;

		EXIT WHEN i = l_num_records_to_display;
		-- <BUG 7006113 END>
    	end loop;

    else    -- release

    	l_document := NL || NL || '<!-- RELEASE_SHIPMENT_DETAILS -->'|| NL || NL || '<P><B>';
    	l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_DETAILS');
    	l_document := l_document || '</B>' || NL || '<P>';

        -- <BUG 3616816 START> Only display message if # of actual lines is
        -- greater than maximum limit.
        --
        IF ( l_line_count > max_lines_dsp )
        THEN
            FND_MESSAGE.set_name('PO','PO_WF_NOTIF_PO_REL_SHIP_MESG');
            FND_MESSAGE.set_token('COUNT',to_char(max_lines_dsp));
            line_mesg := FND_MESSAGE.get;
            l_document := l_document || line_mesg || '<P>';
        END IF;
        --
        -- <BUG 3616816 END>

    	l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="' ||  fnd_message.get_string('ICX','ICX_POR_TBL_BL_TO_APPROVE_SUM') || '"> '|| NL;

    	l_document := l_document || '<TR>' || NL;

    	l_document := l_document || '<TH  id="shipNum_2">' ||
   	               fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_NUMBER') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="itemNum_2">' ||
    	              fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') || '</TH>' || NL;

   	l_document := l_document || '<TH  id="itemRev_2">' ||
        	      fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="itemDesc_2">' ||
                  	fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="uom_2">' ||
                  	fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="quant_2">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="unitPrice_2">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="location_2">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LOCATION') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="shipToOrg_2">' ||
                  fnd_message.get_string('PO', 'POA_SHIP_TO_ORG') || '</TH>' || NL;

    	l_document := l_document || '<TH  id="needByDate_2">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_NEED_BY_DATE') || '</TH>' || NL;
	/* bug 4950850 */
       	l_document := l_document || '<TH  id="lineAmt_2">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT') || '</TH>' || NL;

    	l_document := l_document || '</TR>' || NL;

        -- curr_len  := lengthb(l_document);
        -- prior_len := curr_len;

        FOR i IN 1..l_num_records_to_display LOOP              -- <BUG 3616816>

                /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */
                -- < BUG 7006113 START Commented the loop to avoid the check so that
		--   maximum lines can be displayed >
                -- if (curr_len + (2 * (curr_len - prior_len))) >= 32000 then
                --   exit;
                -- end if;
		-- prior_len := curr_len;
		-- < BUG 7006113 END >

      		l_document := l_document || '<TR>' || NL;

   		l_document := l_document || '<TD nowrap align=center headers="shipNum_2">'
				|| nvl(to_char(l_shipment_num_tbl(i)), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap  headers="itemNum_2">'
				|| nvl(l_item_num_tbl(i), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap  headers="itemRev_2">'
				|| nvl(l_item_revision_tbl(i), '&nbsp;') || '</TD>' || NL;
        /* Bug 11825584 removing nowrap and adding align=left*/
      		l_document := l_document || '<TD align=left headers="itemDesc_2">'
				|| nvl(l_item_desc_tbl(i), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap  headers="uom_2">'
				|| nvl(l_uom_tbl(i), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap align=right  headers="quant_2">'
				|| nvl(to_char(l_quantity_tbl(i)), '&nbsp;') || '</TD>' || NL;

/* Bug 2868931: kagarwal
** We will not format the unit price on the lines in notifications
*/

      		l_document := l_document || '<TD nowrap align=right  headers="unitPrice_2">' ||
                                  nvl(PO_WF_REQ_NOTIFICATION.FORMAT_CURRENCY_NO_PRECESION(
				      l_currency_code,l_unit_price_tbl(i)),'&nbsp;') || '</TD>' || NL;  -- <BUG 7006113>

      		l_document := l_document || '<TD nowrap  headers="location_2">'
				|| nvl(l_location_tbl(i), '&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '<TD nowrap  headers="shipToOrg_2">'
				|| nvl(l_org_name_tbl(i), '&nbsp;') || '</TD>' || NL;
                                                    /*Modified as part of bug 7553798 changing date format*/
	      	l_document := l_document || '<TD nowrap  headers="needByDate_2">'
	     			|| to_char(l_need_by_date_tbl(i),FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                            'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || '''') || '</TD>' || NL;
                /* bug 4950850 */
                l_document := l_document || '<TD nowrap align=right headers="lineAmt_2">' ||
                  nvl(TO_CHAR(l_amount_tbl(i), FND_CURRENCY.GET_FORMAT_MASK(
                              l_currency_code, 30)),'&nbsp;') || '</TD>' || NL;
      		l_document := l_document || '</TR>' || NL;

                -- <BUG 7006113 START>
		-- curr_len  := lengthb(l_document);

                wf_notification.writetoclob(document, l_document);

                l_document := NULL;

		EXIT WHEN i = l_num_records_to_display;
		-- <BUG 7006113 END>

    	end loop;

    end if;
    l_document := l_document || '</TABLE></P>' || NL;

    --<BUG 7614278 Added condition to check whether the document has value and if
    --so call the function WriteToClob().
    curr_len := lengthb(l_document);
    IF (NVL(curr_len,0) > 0 ) THEN
	wf_notification.writetoclob(document, l_document); 	-- <BUG 7006113>
    END IF;
    -- document := l_document; -- <BUG 7006113>

  elsif (display_type = 'text/plain') then

    if (nvl(l_document_type, 'PO') <> 'RELEASE') then

    	l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_LINE_DETAILS') || NL || NL;

        -- <BUG 3616816 START> Only display message if # of actual lines is
        -- greater than maximum limit.
        --
        IF ( l_line_count > max_lines_dsp ) THEN

            -- Bug 3668188: changed the code check (originally created
            -- in bug 3607009) that determines which message to show
            -- based on whether Open Document icon is shown in then notif.
            -- The value of WF attribute 'OPEN_FORM_COMMAND' is set in a
            -- previous node, using the get_po_user_msg_attribute procedure.
            -- HTML Orders R12
            -- Check for the URL parameters as well
            IF  (l_open_form_command IS NULL) AND
                (l_view_po_url IS NULL)       AND
                (l_edit_po_url IS NULL)
            THEN
                -- "The first [COUNT] Purchase Order lines are summarized below."
                FND_MESSAGE.set_name('PO','PO_WF_NOTIF_PO_LINE_MESG_TRUNC');
            ELSE
                -- "The first [COUNT] Purchase Order lines are summarized
                -- below. For information on additional lines, please click
                -- the Open Document icon."
                FND_MESSAGE.set_name('PO','PO_WF_NOTIF_PO_LINE_MESG');
            END IF;

            FND_MESSAGE.set_token('COUNT',to_char(max_lines_dsp));
            line_mesg := FND_MESSAGE.get;
            l_document := l_document || line_mesg || NL || NL;

        END IF;
        --
        -- <BUG 3616816 END>

        -- curr_len  := lengthb(l_document);
        -- prior_len := curr_len;

        FOR i IN 1..l_num_records_to_display LOOP              -- <BUG 3616816>

                /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */
                -- < BUG 7006113 START Commented the loop to avoid the check so
		--   that maximum lines can be displayed >
                --   if (curr_len + (2 * (curr_len - prior_len))) >= 32000 then
                --     exit;
                --   end if;
		--   prior_len := curr_len;
		-- < BUG 7006113 END >

		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || ':' || to_char(l_line_num_tbl(i)) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') || ': ' || l_item_num_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') || ': ' || l_item_revision_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || ': ' || l_item_desc_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || ': ' || l_uom_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || ': ' || to_char(l_quantity_tbl(i)) || NL;

/* Bug 2868931: kagarwal
** We will not format the unit price on the lines in notifications
*/

		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || ': '
					|| PO_WF_REQ_NOTIFICATION.FORMAT_CURRENCY_NO_PRECESION(l_currency_code,l_unit_price_tbl(i)) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_AMOUNT') || ': '
					|| to_char(l_amount_tbl(i), FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || NL || NL;

	    -- < BUG 7006113 START >
            -- curr_len  := lengthb(l_document);

            wf_notification.writetoclob(document, l_document);

	    l_document := NULL;

	    EXIT WHEN i = l_num_records_to_display;
	    -- < BUG 7006113 END >

	end loop;

    else   -- release

    	l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_DETAILS') || NL || NL || NL;

        -- <BUG 3616816 START> Only display message if # of actual lines is
        -- greater than maximum limit.
        --
        IF ( l_line_count > max_lines_dsp )
        THEN
            FND_MESSAGE.set_name('PO','PO_WF_NOTIF_PO_REL_SHIP_MESG');
            FND_MESSAGE.set_token('COUNT',to_char(max_lines_dsp));
            line_mesg := FND_MESSAGE.get;
            l_document := l_document || line_mesg || NL || NL;
        END IF;
        --
        -- <BUG 3616816 END>

        -- curr_len  := lengthb(l_document);
        -- prior_len := curr_len;

        FOR i IN 1..l_num_records_to_display LOOP              -- <BUG 3616816>

                /* Exit the cursor if the current document length and 2 times the
                ** length added in prior line exceeds 32000 char */
                -- <BUG 7006113 START Commented the loop to avoid the check so that
		--  maximum lines can be displayed
                --  if (curr_len + (2 * (curr_len - prior_len))) >= 32000 then
                --  exit;
                --  end if;
		--  prior_len := curr_len;
		-- <BUG 7006113 END>

		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_NUMBER') || ': ' || to_char(l_shipment_num_tbl(i)) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_NUMBER') || ': ' || l_item_num_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_REVISION') || ': ' || l_item_revision_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ITEM_DESC') || ': ' || l_item_desc_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || ': ' || l_uom_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || ': ' || to_char(l_quantity_tbl(i)) || NL;

/* Bug 2868931: kagarwal
** We will not format the unit price on the lines in notifications
*/

		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || ': '
					||  PO_WF_REQ_NOTIFICATION.FORMAT_CURRENCY_NO_PRECESION(l_currency_code,l_unit_price_tbl(i)) || NL;
                -- bug 4950850
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_AMOUNT') || ': '
					|| to_char(l_amount_tbl(i), FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LOCATION') || ': ' || l_location_tbl(i) || NL;
		l_document := l_document || fnd_message.get_string('PO', 'POA_SHIP_TO_ORG') || ': ' || l_org_name_tbl(i) || NL;
                                                    /*Modified as part of bug 7553798 changing date format*/
		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEED_BY_DATE') || ': ' || to_char(l_need_by_date_tbl(i),FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                          'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN') || '''') || NL || NL;

            -- <BUG 7006113 START>
	    -- curr_len  := lengthb(l_document);


            wf_notification.writetoclob(document, l_document);

            l_document := NULL;

	    EXIT WHEN i = l_num_records_to_display;
	    -- <BUG 7006113 END>

	end loop;

    end if;

    --<BUG 7614278 Added condition to check whether the document has value and if
    --so call the function WriteToClob().
    curr_len := lengthb(l_document);
    IF (NVL(curr_len,0) > 0 ) THEN
	wf_notification.writetoclob(document, l_document); -- <BUG 7006113>
    END IF;
    -- document := l_document; -- <Bug 7006113>
  end if;

END get_po_lines_details;

PROCEDURE get_action_history (	 document_id	in	varchar2,
                                 display_type	in	varchar2,
                                 document	in out	NOCOPY varchar2,
                                 document_type	in out	NOCOPY varchar2) IS

    l_item_type    wf_items.item_type%TYPE;
    l_item_key     wf_items.item_key%TYPE;

    l_document_id      po_lines.po_header_id%TYPE;
    l_org_id           po_lines.org_id%TYPE;
    l_doc_type_code    VARCHAR2(80);

    l_document         VARCHAR2(32000) := '';

    -- Bug 3668188: added new local var. note: the length of this
    -- varchar was determined based on the length in POXWPA1B.pls,
    -- which is the other place 'OPEN_FORM_COMMAND' attribute is used
    l_open_form_command VARCHAR2(200);

    l_view_po_url varchar2(1000);   -- HTML Orders R12
    l_edit_po_url varchar2(1000);   -- HTML Orders R12

    NL                 VARCHAR2(1) := fnd_global.newline;

    -- <BUG 3616816 START> Declare TABLEs for each column that is selected
    -- from history_csr cursor.
    --
    TYPE sequence_num_tbl_type IS TABLE OF PO_ACTION_HISTORY.sequence_num%TYPE;
    TYPE full_name_tbl_type IS TABLE OF PER_ALL_PEOPLE_F.full_name%TYPE;
    TYPE displayed_field_tbl_type IS TABLE OF PO_LOOKUP_CODES.displayed_field%TYPE;
    TYPE action_date_tbl_type IS TABLE OF PO_ACTION_HISTORY.action_date%TYPE;
    TYPE note_tbl_type IS TABLE OF PO_ACTION_HISTORY.note%TYPE;
    TYPE object_revision_num_tbl_type IS TABLE OF PO_ACTION_HISTORY.object_revision_num%TYPE;
    TYPE employee_id_tbl_type IS TABLE OF PO_ACTION_HISTORY.employee_id%TYPE;
    TYPE created_by_tbl_type IS TABLE OF PO_ACTION_HISTORY.created_by%TYPE;

    l_sequence_num_tbl         sequence_num_tbl_type;
    l_employee_name_tbl        full_name_tbl_type;
    l_action_tbl               displayed_field_tbl_type;
    l_action_date_tbl          action_date_tbl_type;
    l_note_tbl                 note_tbl_type;
    l_object_revision_num_tbl  object_revision_num_tbl_type;
    l_employee_id_tbl          employee_id_tbl_type;
    l_created_by_tbl           created_by_tbl_type;
    --
    -- <BUG 3616816 END>

  --SQL What: Query action history which is updated by both buyer and vendor
  --SQL Why:  Since vendor doesn't have employee id, added outer join;
  CURSOR history_csr(v_document_id NUMBER, v_doc_type_code VARCHAR2) IS
    SELECT poh.SEQUENCE_NUM,
           per.FULL_NAME,
           polc.DISPLAYED_FIELD,
           poh.ACTION_DATE,
           poh.NOTE,
           poh.OBJECT_REVISION_NUM,
           poh.employee_id, /* bug 2788683 */
           poh.created_by /* bug 2788683 */
      from po_action_history  poh,
           per_all_people_f   per, -- Bug 3404451
           po_lookup_codes    polc
     where OBJECT_TYPE_CODE = v_doc_type_code
       and poh.action_code = polc.lookup_code
       and POLC.LOOKUP_TYPE IN ('APPROVER ACTIONS','CONTROL ACTIONS')
       and per.person_id(+) = poh.employee_id /* bug 2788683 */
       and trunc(sysdate) between per.effective_start_date(+)
                              and per.effective_end_date(+)
       and OBJECT_ID = v_document_id
    UNION ALL
    SELECT poh.SEQUENCE_NUM,
           per.FULL_NAME,
           NULL,
           poh.ACTION_DATE,
           poh.NOTE,
           poh.OBJECT_REVISION_NUM,
           poh.employee_id, /* bug 2788683 */
           poh.created_by /* bug 2788683 */
      from po_action_history  poh,
           per_all_people_f   per -- Bug 3404451
     where OBJECT_TYPE_CODE = v_doc_type_code
       and poh.action_code is null
       and per.person_id(+) = poh.employee_id /* bug 2788683 */
       and trunc(sysdate) between per.effective_start_date(+)
                              and per.effective_end_date(+)
       and OBJECT_ID = v_document_id
   order by 1 desc;

  i                         NUMBER := 0;
  max_actions_dsp           NUMBER := 20;
  l_action_count            NUMBER; -- <BUG 3616816> # of action history records
  l_num_records_to_display  NUMBER; -- <BUG 3616816> actual # of records to display in table
  action_mesg              fnd_new_messages.message_text%TYPE; --Bug 4695601
  curr_len                  NUMBER := 0;
  prior_len                 NUMBER := 0;

  /* Bug 2788683 start */
  l_user_name        fnd_user.user_name%TYPE;
  l_vendor_name      hz_parties.party_name%TYPE;
  l_party_name       hz_parties.party_name%TYPE;
  /* Bug 2788683 end */
  l_supplier         po_vendors.vendor_name%TYPE; --<BUG 7475571>


BEGIN

  l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  l_item_key := substr(document_id, instr(document_id, ':') + 1,
                       length(document_id) - 2);

  l_document_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'DOCUMENT_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                                        (itemtype   => l_item_type,
                                         itemkey    => l_item_key,
                                         aname      => 'ORG_ID');

  l_doc_type_code := wf_engine.GetItemAttrText (itemtype   => l_item_type,
                                           	itemkey    => l_item_key,
                                           	aname      => 'DOCUMENT_TYPE');

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id) ;       -- <R12 MOAC>

  -- Bug 3668188
  l_open_form_command :=  PO_WF_UTIL_PKG.GetItemAttrText
                               (itemtype   => l_item_type,
                                itemkey    => l_item_key,
                                aname      => 'OPEN_FORM_COMMAND');

  -- HTML Orders R12
  -- Get the PO HTML Page URL's
  l_view_po_url := PO_WF_UTIL_PKG.GetItemAttrText (
                              itemtype   => l_item_type,
                              itemkey    => l_item_key,
                              aname      => 'VIEW_DOC_URL');

  l_edit_po_url := PO_WF_UTIL_PKG.GetItemAttrText (
                              itemtype   => l_item_type,
                              itemkey    => l_item_key,
                              aname      => 'EDIT_DOC_URL');

/* Bug# 2577478: kagarwal
** Desc: Added a new attribute ACT_HST_IN_NTF in wf definition for
** users to specify the number of PO actions to be displayed in a
** notification.
** If the attribute does not exist or is null, then we would use default
** value of 20.
*/

  max_actions_dsp:= PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype   => l_item_type,
                                           itemkey    => l_item_key,
                                           aname      => 'ACT_HST_IN_NTF');

  if max_actions_dsp is NULL then
     max_actions_dsp := 20;
  end if;

    -- <BUG 3616816 START> Fetch all Action History data into Tables.
    --
    OPEN history_csr(l_document_id,l_doc_type_code);

    FETCH history_csr BULK COLLECT INTO l_sequence_num_tbl
                                      , l_employee_name_tbl
                                      , l_action_tbl
                                      , l_action_date_tbl
                                      , l_note_tbl
                                      , l_object_revision_num_tbl
                                      , l_employee_id_tbl
                                      , l_created_by_tbl;

    l_action_count := history_csr%ROWCOUNT; -- Get # of records fetched.

    CLOSE history_csr;
    --
    -- <BUG 3616816 END>

    -- <BUG 3616816 START> Only display message if # of actual Action History
    -- records is greater than maximum limit.
    --
    IF  ( l_action_count > max_actions_dsp ) THEN

        l_num_records_to_display := max_actions_dsp;

        -- Bug 3668188: changed the code check (originally created
        -- in bug 3607009) that determines which message to show
        -- based on whether Open Document icon is shown in then notif.
        -- The value of WF attribute 'OPEN_FORM_COMMAND' is set in a
        -- previous node, using the get_po_user_msg_attribute procedure.
        --
        IF  (l_open_form_command IS NULL) AND
            (l_view_po_url IS NULL)       AND
            (l_edit_po_url IS NULL)
        THEN
            -- "The last [COUNT] Approval History details are summarized below."
            FND_MESSAGE.set_name('PO','PO_WF_NOTIF_PO_ACT_MESG_TRUNC');
        ELSE
            -- "The last [COUNT] Approval History details are summarized below.
            -- For information on additional Approval History, please click the
            -- Open Document icon."
            FND_MESSAGE.set_name('PO','PO_WF_NOTIF_PO_ACT_MESG');
        END IF;

        FND_MESSAGE.set_token('COUNT',to_char(max_actions_dsp));
        action_mesg := FND_MESSAGE.get;

    ELSE

        l_num_records_to_display := l_action_count;
        action_mesg := NULL;

    END IF;
    --
    -- <BUG 3616816 END>

  if (display_type = 'text/html') then

    l_document := NL || NL || '<!-- ACTION_HISTORY -->'|| NL || NL || '<P><B>';
    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_HISTORY') || NL;
    l_document := l_document || '</B>' || NL || NL || '<P>';   -- <BUG 3616816>

    -- <BUG 3616816 START> Action History message may be NULL. Only append it
    -- and corresponding line breaks if there is a message to display.
    --
    IF ( action_mesg IS NOT NULL )
    THEN
        l_document := l_document || action_mesg || '<P>' || NL;
    END IF;
    --
    -- <BUG 3616816 END>

    l_document := l_document || '<TABLE border=1 cellpadding=2 cellspacing=1 summary="' || fnd_message.get_string('ICX', 'ICX_POR_TBL_OF_APPROVERS') || '">' || NL;

    l_document := l_document || '<TR>';

    l_document := l_document || '<TH id="seqNum_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SEQ_NUM') || '</TH>' || NL;

    l_document := l_document || '<TH id="employee_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_EMPLOYEE') || '</TH>' || NL;

    l_document := l_document || '<TH id="action_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION') || '</TH>' || NL;

    l_document := l_document || '<TH id="date_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_DATE') || '</TH>' || NL;

    l_document := l_document || '<TH id="actionNote_1">' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_NOTE') || '</TH>' || NL;

    l_document := l_document || '</TR>' || NL;

    curr_len  := lengthb(l_document);
    prior_len := curr_len;

    FOR i IN 1..l_num_records_to_display LOOP                  -- <BUG 3616816>

      /* Exit the cursor if the current document length and 2 times the
      ** length added in prior line exceeds 32000 char */

      if (curr_len + (2 * (curr_len - prior_len))) >= 32000 then
         exit;
      end if;

      prior_len := curr_len;

      l_document := l_document || '<TR>' || NL;

      l_document := l_document || '<TD nowrap align=center headers="seqNum_1">'
					 || nvl(to_char(l_sequence_num_tbl(i)), '&nbsp;') || '</TD>' || NL;

      /* Bug 2788683 start */
      /* if action history is updated by vendor
       *    show vendor true name(vendor name)
       * else action history is updated by buyer
       *    show buyer's true name
       */
      IF l_employee_id_tbl(i) IS NULL THEN
         BEGIN --<BUG 7475571>
		SELECT fu.user_name,
		       hp.party_name
		  INTO l_user_name,
		       l_party_name
		  FROM fnd_user fu,
		       hz_parties hp
		 WHERE hp.party_id = fu.customer_id
		   AND fu.user_id = l_created_by_tbl(i);
	 EXCEPTION
	 WHEN OTHERS THEN
		NULL;
	 END;
      -- <BUG 7475571 Added the below IF condition so that if the l_user_name
      -- returns NULL value because of supplier user setup the PO approval
      -- notifcation should not error out. Instead modified the code such that
      -- the action history column for change request will show the corresponding
      -- supplier name rather than supplier user name.
	IF l_user_name IS NULL THEN
		l_user_name := PO_WF_UTIL_PKG.GetItemAttrText(itemtype   => l_item_type,
                                                              itemkey    => l_item_key,
                                                              aname      => 'SUPPLIER');

		l_document := l_document || '<TD nowrap headers="employee1">' || l_user_name || '</TD>' || NL;
	ELSE
		po_inq_sv.get_vendor_name(l_user_name => l_user_name, x_vendor_name => l_vendor_name);

		l_document := l_document || '<TD nowrap headers="employee_1">' || l_party_name || '(' || l_vendor_name || ')' || '</TD>' || NL;
	END IF;
      ELSE
      l_document := l_document || '<TD nowrap headers="employee_1">'
					 || nvl(l_employee_name_tbl(i), '&nbsp;') || '</TD>' || NL;
      END IF;
      /* Bug 2788683 end */

      l_document := l_document || '<TD nowrap headers="action_1">'
					 || nvl(l_action_tbl(i), '&nbsp;') || '</TD>' || NL;
      /*Modified as part of bug 7553798 changing date format*/
      l_document := l_document || '<TD nowrap headers="date_1">'
					 || nvl(to_char(l_action_date_tbl(i),FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                             'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''), '&nbsp;') || '</TD>' || NL;
         /* Bug 11825584 removing nowrap and adding align=left*/
      l_document := l_document || '<TD align=left headers="actionNote_1">'
					 || nvl(l_note_tbl(i), '&nbsp;') || '</TD>' || NL;

      l_document := l_document || '</TR>' || NL;

      curr_len  := lengthb(l_document);

    end loop;

    l_document := l_document || '</TABLE></P>' || NL;

    document := l_document;

  elsif (display_type = 'text/plain') then

    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_HISTORY') || NL;

    -- <BUG 3616816 START> Action History message may be NULL. Only append it
    -- and corresponding line breaks if there is a message to display.
    --
    IF ( action_mesg IS NOT NULL )
    THEN
        l_document := l_document || action_mesg || NL || NL;
    END IF;
    --
    -- <BUG 3616816 END>

    curr_len  := lengthb(l_document);
    prior_len := curr_len;

    FOR i IN 1..l_num_records_to_display LOOP                  -- <BUG 3616816>

      /* Exit the cursor if the current document length and 2 times the
      ** length added in prior line exceeds 32000 char */

      if (curr_len + (2 * (curr_len - prior_len))) >= 32000 then
         exit;
      end if;

      prior_len := curr_len;

      l_document := l_document || NL;

/* Bug 2462005 sktiwari:
** Added a ':' between the prompt and the data. Modified the following lines.
*/
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SEQ_NUM') || ': ' || to_char(l_sequence_num_tbl(i)) || NL;

      /* Bug 2788683 start */
      /* if action history is updated by vendor
       *    show vendor true name(vendor name)
       * else action history is updated by buyer
       *    show buyer's true name
       */
      IF l_employee_id_tbl(i) IS NULL THEN
         BEGIN --<BUG 7475571>
		SELECT fu.user_name, hp.party_name
		  INTO l_user_name, l_party_name
		  FROM fnd_user fu,
		       hz_parties hp
		 WHERE hp.party_id = fu.customer_id
		   AND fu.user_id = l_created_by_tbl(i);
	 EXCEPTION
	 WHEN OTHERS THEN
		NULL;
	 END;
	 -- <BUG 7475571 Added the below IF condition so that if the l_user_name
         -- returns NULL value because of supplier user setup the PO approval
         -- notifcation should not error out. Instead modified the code such that
         -- the action history column for change request will show the corresponding
         -- supplier name rather than supplier user name.
	 IF l_user_name IS NULL THEN
		l_user_name := PO_WF_UTIL_PKG.GetItemAttrText(itemtype   => l_item_type,
                                                              itemkey    => l_item_key,
                                                              aname      => 'SUPPLIER');

		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_EMPLOYEE') || l_user_name || NL;
	ELSE
		po_inq_sv.get_vendor_name(l_user_name => l_user_name, x_vendor_name => l_vendor_name);

		l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_EMPLOYEE') || ': ' || l_party_name || '(' || l_vendor_name || ')' || NL;
	END IF;
      ELSE
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_EMPLOYEE') || ': ' || l_employee_name_tbl(i) || NL;
      END IF;
      /* Bug 2788683 end */

      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION') || ': ' || l_action_tbl(i) || NL;
      /*Modified as part of bug 7553798 changing date format*/
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DATE') || ': ' || to_char(l_action_date_tbl(i),FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                               'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || '''') || NL;
      l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_ACTION_NOTE') || ': ' || l_note_tbl(i) || NL;

      l_document := l_document || NL;

      curr_len  := lengthb(l_document);
    end loop;

    l_document := l_document;

    document := l_document;

  end if;

END;

PROCEDURE post_approval_notif(itemtype   in varchar2,
                              itemkey    in varchar2,
                              actid      in number,
                              funcmode   in varchar2,
                              resultout  in out NOCOPY varchar2) is

-- Context setting revamp <variable addition start>
l_responder_id       fnd_user.user_id%TYPE;
l_session_user_id    NUMBER;
l_session_resp_id    NUMBER;
l_session_appl_id    NUMBER;
l_preparer_resp_id   NUMBER;
l_preparer_appl_id   NUMBER;
l_progress           VARCHAR2(1000);
l_nid                NUMBER;
l_preserved_ctx      VARCHAR2(5);
-- Context setting revamp <variable addition end>

--Added the below variables as part of bug 13951919 fix. Used to log the Delegate action in the PO_ACTION_HISTORY table.
l_po_header_id      po_headers_all.po_header_id%TYPE;
l_doc_type          po_action_history.OBJECT_TYPE_CODE%TYPE;
l_doc_sub_type      po_action_history.OBJECT_SUB_TYPE_CODE%TYPE;
l_action             po_action_history.action_code%TYPE;
l_new_recipient_id   wf_roles.orig_system_id%TYPE;
l_current_recipient_id   wf_roles.orig_system_id%TYPE;
l_origsys            wf_roles.orig_system%TYPE;
l_original_recipient       wf_notifications.original_recipient%TYPE;
l_current_recipient_role   wf_notifications.recipient_role%TYPE;

--Added the below variables as part of bug 14105414 fix.
x_user_id         number;
l_forward_to_username_response varchar2(100);
l_forward_to_id                number;
l_forward_to_username          varchar2(100);
l_error_msg                    varchar2(500);
l_preparer_id number;
x_CanOwnerApproveFlag varchar2(1);
l_orgid         number;
l_note po_action_history.note%TYPE;
l_respond_action_text varchar2(100);
l_is_forward_valid boolean;
l_approval_path_id PO_ACTION_HISTORY.APPROVAL_PATH_ID%TYPE;

--15859236 start
l_new_recipient_name           wf_users.name%type;
l_new_recipient_display_name   wf_users.display_name%type;
--15859236 end

begin

--Start of code changes for inserting the delegate action in Action History. Bug 13951919 fix
  l_progress := '001';
  IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'funcmode : '||funcmode);
   END IF;

   if (funcmode IN  ('FORWARD', 'QUESTION', 'ANSWER','TIMEOUT')) then
   	if (funcmode = 'FORWARD') then
	  l_action := 'DELEGATE';
	elsif (funcmode = 'QUESTION') then
	  l_action := 'QUESTION';
	elsif (funcmode = 'ANSWER') then
	  l_action := 'ANSWER';
	elsif (funcmode = 'TIMEOUT') then
	  l_action := 'NO ACTION';
	end if;

	IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_action : '||l_action);
	END IF;

	l_po_header_id := wf_engine.GetItemAttrNumber(	itemtype   => itemtype,
							itemkey    => itemkey,
							aname      => 'DOCUMENT_ID');
	l_doc_type  := wf_engine.GetItemAttrText(itemtype   => itemtype,
						 itemkey    => itemkey,
						 aname      => 'DOCUMENT_TYPE');

	l_doc_sub_type  := wf_engine.GetItemAttrText(itemtype   => itemtype,
						 itemkey    => itemkey,
						 aname      => 'DOCUMENT_SUBTYPE');

	IF (g_po_wf_debug = 'Y') THEN
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'Document_ID : '||l_po_header_id);
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_doc_type : '||l_doc_type);
           PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_doc_sub_type : '||l_doc_sub_type);
   	END IF;

	IF (l_action <> 'NO ACTION') THEN
	    Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_NEW_ROLE, l_origsys, l_new_recipient_id);

	    IF (g_po_wf_debug = 'Y') THEN
          	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_origsys : '||l_origsys);
          	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_new_recipient_id : '||l_new_recipient_id);
	    END IF;

	ELSE
	    BEGIN
		SELECT  original_recipient,
			Decode(MORE_INFO_ROLE, NULL, RECIPIENT_ROLE,MORE_INFO_ROLE)
			INTO l_original_recipient, l_current_recipient_role
		FROM wf_notifications
		WHERE
			notification_id = WF_ENGINE.context_nid
			AND ( MORE_INFO_ROLE IS NOT NULL OR RECIPIENT_ROLE <> ORIGINAL_RECIPIENT );

      		IF (g_po_wf_debug = 'Y') THEN
          		PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_original_recipient : '||l_original_recipient);
          		PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_current_recipient_role : '||l_current_recipient_role);
      		END IF;

	    EXCEPTION
		WHEN OTHERS THEN
			l_original_recipient := NULL;
	    END;

	    IF l_original_recipient IS NOT NULL THEN
		Wf_Directory.GetRoleOrigSysInfo(l_original_recipient, l_origsys, l_new_recipient_id);
	    END IF;

	END IF;

	/* We should not be allowing the delegation of a notication
	     to a user who is not an employee. */

	if((funcmode = 'FORWARD') AND (l_origsys <> 'PER')) then
	    fnd_message.set_name('PO', 'PO_INVALID_USER_FOR_REASSIGN');
	    app_exception.raise_exception;
	end if;

	l_progress := '002';

	IF (funcmode = 'ANSWER') THEN
	   Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_MORE_INFO_ROLE, l_origsys, l_current_recipient_id);
	ELSIF (funcmode = 'TIMEOUT') THEN
	   Wf_Directory.GetRoleOrigSysInfo(l_current_recipient_role, l_origsys, l_current_recipient_id);
	ELSE
	   Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_RECIPIENT_ROLE, l_origsys, l_current_recipient_id);
	END IF;

	l_progress := '003';

     	IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
     	END IF;

	IF l_new_recipient_id IS NOT NULL THEN
      		IF (g_po_wf_debug = 'Y') THEN
          	   /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'Before executing update_action_history');
      		END IF;

		--15859236 start
      		wf_directory.GetUserName(l_origsys, l_new_recipient_id, l_new_recipient_name, l_new_recipient_display_name);

      		wf_engine.SetItemAttrNumber (itemtype        => itemtype,
                                   itemkey         => itemkey,
                                   aname           => 'FORWARD_TO_ID',
                                   avalue          =>  l_new_recipient_id);

      		wf_engine.SetItemAttrText (itemtype        => itemtype,
                                   itemkey         => itemkey,
                                   aname           => 'FORWARD_TO_USERNAME',
                                   avalue          =>  l_new_recipient_name);

      		wf_engine.SetItemAttrText (itemtype        => itemtype,
                                   itemkey         => itemkey,
                                   aname           => 'FORWARD_TO_DISPLAY_NAME',
                                   avalue          =>  l_new_recipient_display_name);
      		--15859236 end

		update_action_history(p_action_code => l_action,
                             p_recipient_id => l_new_recipient_id,
                             p_note => WF_ENGINE.CONTEXT_USER_COMMENT,
                             p_po_header_id => l_po_header_id,
                             p_current_id => l_current_recipient_id,
		             p_doc_type => l_doc_type,
			     p_doc_subtype => l_doc_sub_type,
                             p_approval_path_id => NULL); --<bug 14105414>

      		IF (g_po_wf_debug = 'Y') THEN
          		/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'After executing update_action_history');
      		END IF;
	END IF;

	l_progress := '004';

	IF (funcmode <> 'TIMEOUT') THEN
	    resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
	END IF;

	return;
   end if;

--End of code changes for inserting the delegate action in Action History. Bug 13951919 fix


 -- Context setting revamp <start>
if (funcmode = 'RESPOND') then
  l_nid := WF_ENGINE.context_nid;

    SELECT fu.USER_ID
      INTO l_responder_id
      FROM fnd_user fu,
           wf_notifications wfn
     WHERE wfn.notification_id = l_nid
       AND wfn.original_recipient = fu.user_name;

--Start of code changes for updating the action code in the action history
--as per the approver action. <bug 14105414>
  /* Get the current approver's response/action. Here it can be either FORWARD
    or APPROVE or APPROVE_AND_FORWARD or REJECT. */
  l_respond_action_text := Wf_Notification.GetAttrText(l_nid, 'RESULT');

  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
                       'l_respond_action_text: ' || l_respond_action_text);
  END IF;

  /* This boolean flag will be set to FALSE if the forwarded person is invalid */
  l_is_forward_valid := TRUE;

  IF (l_respond_action_text = 'FORWARD'
      OR l_respond_action_text = 'APPROVE_AND_FORWARD') THEN

    /*
    ** Desc: When responding from the E-mail notifications, the forward
    ** to failed as the org context was not set.
    */

    l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');
    IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
                       'l_orgid: ' || l_orgid);
    END IF;

    IF l_orgid is NOT NULL THEN

      po_moac_utils_pvt.set_org_context(l_orgid); --<R12 MOAC>

    END IF;

    /* Check that the value entered by responder as the FORWARD-TO user, is actually
    ** a valid employee (has an employee id).
    ** If valid, then set the FORWARD-FROM USERNAME and ID from the old FORWARD-TO.
    ** Then set the Forward-To to the one the user entered in the response.
    */
    /* NOTE: We take the value entered by the user and set it to ALL CAPITAL LETTERS!!!
    */
    l_forward_to_username_response := wf_notification.GetAttrText(l_nid, 'FORWARD_TO_USERNAME_RESPONSE');

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
                       'l_forward_to_username_response: ' || l_forward_to_username_response);
    END IF;

    l_forward_to_username_response := UPPER(l_forward_to_username_response);

    IF po_reqapproval_findapprv1.CheckForwardTo(l_forward_to_username_response,
                                   x_user_id) = 'Y'
    THEN

      /* The FORWARD-FROM is now the old FORWARD-TO and the NEW FORWARD-TO is set
      ** to what the user entered in the response
      */

      l_forward_to_username:= wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_USERNAME');
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
                       'l_forward_to_username: ' || l_forward_to_username);
      END IF;

    /*
    ** Desc: When the approver takes approve action from the Notification form after
    ** modifying the PO. The Approver attributes are set but forward-to attributes
    ** are set to Null. Now if any error is encountered, the Notification is sent to
    ** the approver and if after the error the approver forwards the PO, the
    ** is_forward_to_valid function sets the forward-from and approver attributes
    ** from the forward-to attributes (it has not changed as of now) and then sets
    ** the forward-to attributes to the the response-forward person but in this case
    ** the forward-to attributes had been set to null by previous approve action
    ** hence the approver_username was set to NULL by this function.
    **
    ** If the forward-to attributes are null when taking the forward action we
    ** should use the approver attributes. This will ensure that the approver
    ** attributes and the forward-from attributes are not set to NULL on
    ** forwarding the document.
    */

      IF l_forward_to_username is NOT NULL THEN

       	 l_forward_to_id:= wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FORWARD_TO_ID');
      ELSE /* get the approver name who took this action */
         l_forward_to_id:= wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');
      END IF;

      l_current_recipient_id := l_forward_to_id; --for updating action history

      /*
      ** Here, x_user_id is forwarded person user ID
      ** l_preparer_id is Document Preparer ID
      */
      l_preparer_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'PREPARER_ID');
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
                       'l_preparer_id: ' || l_preparer_id ||
                       ', x_user_id: ' || x_user_id);
      END IF;

      IF (x_user_id = l_preparer_id) THEN
       /* If the forward person is Preparer. Then check whether the owner can approve or not */
        PO_REQAPPROVAL_FINDAPPRV1.CheckOwnerCanApprove(itemtype, itemkey,
                                    x_CanOwnerApproveFlag);

        IF (g_po_wf_debug = 'Y') THEN
          PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
                       'l_preparer_id: ' || l_preparer_id ||
                       ', x_CanOwnerApproveFlag: ' || x_CanOwnerApproveFlag);
        END IF;

        IF x_CanOwnerApproveFlag = 'N' then
          l_is_forward_valid := FALSE;
        END IF;
      END IF;
    ELSE
      --Forward-To person is invalid, set current employee id as recipient.
      l_is_forward_valid := FALSE;
      l_current_recipient_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'APPROVER_EMPID');
    END IF;
  ELSE
    l_is_forward_valid := FALSE;
    --To record the real approver.
    Wf_Directory.GetRoleOrigSysInfo(WF_ENGINE.CONTEXT_RECIPIENT_ROLE, l_origsys, l_current_recipient_id);

  END IF;

  l_progress := '005 PO_WF_PO_NOTIFICATION.post_approval_notif';
  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  /* If the FORWARD is valid, set all the required workflow attributes */
  IF (l_is_forward_valid = TRUE) THEN

      l_progress := '005 is_forward_valid TRUE';
      IF (g_po_wf_debug = 'Y') THEN
         PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      END IF;

      /* Set the FORWARD_FROM */
      wf_engine.SetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'FORWARD_FROM_ID',
                                        avalue          =>  l_forward_to_id);

      /* Set the approver to the person who took the action on the notification,
      ** i.e. the old forward-to person
      */
      wf_engine.SetItemAttrNumber (     itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'APPROVER_EMPID',
                                        avalue          =>  l_forward_to_id);

      wf_engine.SetItemAttrNumber ( itemtype   => itemType,
                                   itemkey    => itemkey,
                                   aname      => 'FORWARD_TO_ID',
                                   avalue     => x_user_id);

     /* Set the Subject of the Approval notification to "requires your approval".
     ** Since the user entered a valid forward-to, then set the
     ** "Invalid Forward-to" message to NULL.
     */
     fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');
     l_error_msg := fnd_message.get;

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQUIRES_APPROVAL_MSG' ,
                                 avalue     => l_error_msg);

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'WRONG_FORWARD_TO_MSG' ,
                                 avalue     => '');


     /* Other workflow attributes are set in PO_REQAPPROVAL_FINDAPPRV1.Set_Forward_To_From_App_fwd */

  ELSIF (l_is_forward_valid = FALSE) THEN
     /* If the forwarded person is invalid or forwarded person is Preparer
     ** and doesn't have approval authority, show error message.
     */

     /* Set the error message that will be shown to the user in the ERROR MESSAGE
     ** Field in the Notification.
     */
    l_progress := '005 is_forward_valid FALSE';
    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;

     /* Set the Subject of the Approval notification to "Invalid forward-to"
     ** Since the user entered an invalid forward-to, then set the
     ** "requires your approval" message to NULL.
     */
     fnd_message.set_name ('PO','PO_WF_NOTIF_INVALID_FORWARD');
     l_error_msg := fnd_message.get;

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQUIRES_APPROVAL_MSG' ,
                                 avalue     => '');

     wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'WRONG_FORWARD_TO_MSG' ,
                                 avalue     => l_error_msg);

  END IF;

  /*
  ** Here the logic to update the action code in action history.
  ** The insert action is still performed in PO_DOCUMENT_ACTION_UTIL.handle_auth_action_history.
  */
  l_progress := '006 PO_WF_PO_NOTIFICATION.post_approval_notif';
  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  /*
  ** Update action history for APPROVE_AND_FORWARD
  ** even when the forward-to person is invalid.
  */
  IF (l_respond_action_text in ('APPROVE','APPROVE_AND_FORWARD'))
     OR (l_respond_action_text = 'FORWARD' AND l_is_forward_valid = TRUE) THEN

      IF l_respond_action_text = 'FORWARD' THEN
        l_action := 'FORWARD';
      ELSIF l_respond_action_text = 'APPROVE' THEN
        l_action := 'APPROVE';
      ELSIF l_respond_action_text = 'APPROVE_AND_FORWARD' THEN
        l_action := 'APPROVE AND FORWARD';
      END IF;

      /* Reset response note */
      l_doc_type := wf_engine.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

      IF (l_doc_type='PO' OR l_doc_type='PA' OR l_doc_type='RELEASE' ) THEN
        l_note := wf_notification.GetAttrText(l_nid, 'NOTE_R');
        PO_WF_UTIL_PKG.SetItemAttrText(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'NOTE',
	  			      avalue  => l_note);
        PO_WF_UTIL_PKG.SetItemAttrText(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'NOTE_R',
	  			      avalue  => NULL);
        wf_notification.SetAttrText(l_nid, 'NOTE', l_note);
        wf_notification.SetAttrText(l_nid, 'NOTE_R', null);
      END IF;


      l_po_header_id := wf_engine.GetItemAttrNumber(itemtype   => itemtype,
                                                    itemkey    => itemkey,
                                                    aname      => 'DOCUMENT_ID');
      l_doc_sub_type  := wf_engine.GetItemAttrText(itemtype   => itemtype,
                                                   itemkey    => itemkey,
                                                   aname      => 'DOCUMENT_SUBTYPE');
      l_approval_path_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'APPROVAL_PATH_ID');

      l_progress := '007 start to update action history';
      IF (g_po_wf_debug = 'Y') THEN
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_action : ' || l_action ||
                          ', l_po_header_id: ' || l_po_header_id ||
                          ', l_current_recipient_id: ' || l_current_recipient_id);
        PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,'l_note: ' || l_note);
      END IF;

      update_action_history(p_action_code => l_action,
                            p_recipient_id => NULL,
                            p_note => l_note,
                            p_po_header_id => l_po_header_id,
                            p_current_id => l_current_recipient_id,
                            p_doc_type=> l_doc_type,
                            p_doc_subtype => l_doc_sub_type,
                            p_approval_path_id => l_approval_path_id);
  END IF;

  l_progress := '008 PO_WF_PO_NOTIFICATION.post_approval_notif';
  IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;
--End of code changes. <bug 14105414>

-- <debug start>
   if (wf_engine.preserved_context = TRUE) then
      l_preserved_ctx := 'TRUE';
   else
      l_preserved_ctx := 'FALSE';
   end if;
   l_progress := 'notif callback preserved_ctx : '||l_preserved_ctx;
   IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
   END IF;
-- <debug end>

-- <debug start>
       l_progress := '010 notif callback -responder id : '||l_responder_id;
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;
--<debug end>
    --Bug 5389914
    --Fnd_Profile.Get('USER_ID',l_session_user_id);
    --Fnd_Profile.Get('RESP_ID',l_session_resp_id);
    --Fnd_Profile.Get('RESP_APPL_ID',l_session_appl_id);
    l_session_user_id := fnd_global.user_id;
    l_session_resp_id := fnd_global.resp_id;
    l_session_appl_id := fnd_global.resp_appl_id;

	  IF (l_session_user_id = -1) THEN
	      l_session_user_id := NULL;
	  END IF;

	  IF (l_session_resp_id = -1) THEN
	      l_session_resp_id := NULL;
	  END IF;

	  IF (l_session_appl_id = -1) THEN
	      l_session_appl_id := NULL;
	  END IF;

-- <debug start>
       l_progress :='020 notification callback ses_userid: '||l_session_user_id
                    ||' sess_resp_id '||l_session_resp_id||' sess_appl_id '
		    ||l_session_appl_id;
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
       END IF;
--<debug end>

-- bug 4901406 <start> : need to shift the setting of the preparer resp and appl id
-- to here, it was not initialized inside the if condition if the control went to the
-- else part.
          l_preparer_resp_id :=
	  PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONSIBILITY_ID');
          l_preparer_appl_id :=
          PO_WF_UTIL_PKG.GetItemAttrNumber (itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'APPLICATION_ID');

-- <debug start>
          l_progress := '030 notif callback prep resp_id:'||l_preparer_resp_id
	  		||' prep appl id '||l_preparer_appl_id;
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;
--<debug end>

-- bug 4901406 <end>


    if (l_responder_id is not null) then
       if (l_responder_id <> l_session_user_id) then
       /* possible in 2 scenarios :
          1. when the response is made from email using guest user feature
	  2. When the response is made from sysadmin login
       */



          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_preparer_resp_id);
          PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_preparer_appl_id);
       else
          if (l_session_resp_id is null) THEN
	  /* possible when the response is made from the default worklist
	     without choosing a valid responsibility */
	      PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
              PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_preparer_resp_id);
              PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_preparer_appl_id);
           else
	   /* all values available - possible when the response is made
	      after choosing a correct responsibility */

	   /* bug 5333226 : If the values of responsibility_id and application
	      id are available but are incorrect - i.e. not conforming to say the
	      sls (subledger security). This may happen when a response is made
	      through the email or the background process picks the wf up.
	      This may happen due to the fact that the mailer / background process
	      carries the context set by the notification/wf it processed last*/

		 	 if ( l_preserved_ctx = 'TRUE') then
	             PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
                     PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_session_resp_id);
                     PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_session_appl_id);
	          else
	             PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_USER_ID',
	  			      avalue  => l_responder_id);
                     PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_RESP_ID',
	  			      avalue  => l_preparer_resp_id);
                     PO_WF_UTIL_PKG.SetItemAttrNumber(itemtype=>itemtype,
	  			      itemkey => itemkey,
				      aname   => 'RESPONDER_APPL_ID',
	  			      avalue  => l_preparer_appl_id);
	          end if;


	   end if;
       end if;
    end if;

    -- Context setting revamp <end>


     resultout := wf_engine.eng_completed || ':' || wf_engine.eng_null;
      l_progress := '040 returning from notif callback -respond mode';
          IF (g_po_wf_debug = 'Y') THEN
             /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
          END IF;
     return;
  end if;


  -- Don't allow transfer
  if (funcmode = 'TRANSFER') then

    fnd_message.set_name('PO', 'PO_WF_NOTIF_NO_TRANSFER');
    app_exception.raise_exception;

  resultout := wf_engine.eng_completed;
  return;

  end if; -- end if for funcmode = 'TRANSFER'

end post_approval_notif;


/* Bug# 2616433: kagarwal
** Desc: Added new procedure to set notification subject token in
** user language.
*/

procedure Get_po_user_msg_attribute(itemtype in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2) IS

l_progress  VARCHAR2(100) := '000';
l_doc_string varchar2(200);
l_user_name varchar2(100);
l_preparer_user_name varchar2(100);
l_orgid number;
l_notification_type varchar2(15);  --bug 3668188

-- <Start Word Integration 11.5.10+>
l_okc_doc_type          varchar2(20);
l_conterms_exist_flag   PO_HEADERS_ALL.conterms_exist_flag%TYPE;
l_document_id           NUMBER;
l_document_subtype      PO_HEADERS_ALL.type_lookup_code%TYPE;
-- <End Word Integration 11.5.10+>

BEGIN

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then
      resultout := wf_engine.eng_null;
      return;
  end if;

  l_progress := 'Get_po_user_msg_attribute:001: actid: ' || actid;
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

  l_orgid := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORG_ID');

  IF l_orgid is NOT NULL THEN
    PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>
  END IF;

  l_progress := 'Get_po_user_msg_attribute:010: orgid: ' || l_orgid;
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

  l_user_name := wf_engine.GetActivityAttrText (itemtype => itemtype,
                                                itemkey  => itemkey,
                                                actid    => actid,
                                                aname    => 'NTF_USER_NAME',
                                                ignore_notfound => TRUE);

  PO_WF_PO_NOTIFICATION.GetDisplayValue(itemtype, itemkey, l_user_name);


  l_progress := 'Get_po_user_msg_attribute:015: username: ' || l_user_name;
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);


  -- Bug 3668188: added the NTF_USER_ROLE Activity Attribute, which is
  -- a constant with value 'SUBMITTER' or 'APPROVER'.  This distinguishes
  -- between the 3 different notification-functions that share this procedure.
  l_notification_type := wf_engine.GetActivityAttrText (
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      actid    => actid,
                                      aname    => 'NTF_USER_ROLE',
                                      ignore_notfound => TRUE);

  l_progress := 'Get_po_user_msg_attribute:020: notif type: ' || l_notification_type;
  -- DEBUG
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);


  -- Bug 3668188: Removed old logic from bug 3564727 and replaced it
  -- with a call to is_open_document_allowed, which has updated logic.
  IF NOT (PO_WF_PO_NOTIFICATION.is_open_document_allowed(
                                  p_itemtype => itemtype
                               ,  p_itemkey => itemkey
                               ,  p_notification_type => l_notification_type)
  ) THEN
     l_progress := 'Get_po_approver_msg_attribute: 040: NULL open form';
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

     -- HTML Orders R12
     -- Set the URL and form attributes
     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'OPEN_FORM_COMMAND' ,
                              avalue     => '');
      -- PO AME Project : VIEW_DOC_URL must always be seen even though po is in PRE-APPROVED state.
    /* PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'VIEW_DOC_URL' ,
                              avalue     => '');*/

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype   => itemType,
                              itemkey    => itemkey,
                              aname      => 'EDIT_DOC_URL' ,
                              avalue     => '');
  END IF;


  -- <Start Word Integration 11.5.10+>

  l_conterms_exist_flag := PO_WF_UTIL_PKG.GetItemAttrText(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'CONTERMS_EXIST_FLAG');

  l_document_subtype := PO_WF_UTIL_PKG.GetItemAttrText(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_SUBTYPE');

  l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname => 'DOCUMENT_ID');


  /* Set or reset the okc doc attachment attribute */

  IF (l_conterms_exist_flag = 'Y')
  THEN
    l_okc_doc_type :=
                PO_CONTERMS_UTL_GRP.get_po_contract_doctype(l_document_subtype);

    IF (('STRUCTURED' <>
     OKC_TERMS_UTIL_GRP.get_contract_source_code(p_document_type => l_okc_doc_type
                                               , p_document_id => l_document_id))
          AND
      ('N' =
      OKC_TERMS_UTIL_GRP.is_primary_terms_doc_mergeable(
                                               P_document_type => l_okc_doc_type
                                             , p_document_id => l_document_id))
         AND
      (PO_COMMUNICATION_PVT.PO_COMMUNICATION_PROFILE = 'T')
    )
    THEN

      PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                      itemkey => itemkey,
                                      aname => 'OKC_DOC_ATTACHMENT',
                                      avalue =>
                                'PLSQLBLOB:PO_COMMUNICATION_PVT.OKC_DOC_ATTACH/'||
                                    itemtype||':'||itemkey);

    ELSE

      /* Contract terms are structured, or attached document is mergeable.
       * All contract terms will be in pdf; no need for other okc doc attachment.
       */

      PO_WF_UTIL_PKG.SetItemAttrText (itemtype => itemtype,
                                      itemkey => itemkey,
                                      aname => 'OKC_DOC_ATTACHMENT',
                                      avalue => '');

    END IF /* not structured and not mergeable */;

  END IF; /* l_conterms_exist_flag = 'Y' */


  -- <End Word Integration 11.5.10+>



  l_progress := 'Get_po_approver_msg_attribute: 999';
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

  resultout := wf_engine.eng_completed || ':' ||  'ACTIVITY_PERFORMED';

EXCEPTION
 WHEN OTHERS THEN
    l_doc_string := PO_REQAPPROVAL_INIT1.get_error_doc(itemType, itemkey);
    l_preparer_user_name := PO_REQAPPROVAL_INIT1.get_preparer_user_name(itemType, itemkey);
    wf_core.context('PO_WF_PO_NOTIFICATION','Get_req_approval_msg_attribute',l_progress);
    PO_REQAPPROVAL_INIT1.send_error_notif(itemType, itemkey, l_preparer_user_name,
    l_doc_string, sqlerrm, 'PO_WF_PO_NOTIFICATION.Get_po_approver_msg_attribute');
    raise;

END Get_po_user_msg_attribute;


/* Bug# 2616433: kagarwal
** Desc: Added new procedure to set doc type display according to the
** default language of approver or preparer.
*/

procedure GetDisplayValue(itemtype in varchar2,
                          itemkey  in varchar2,
                          username in varchar2,
                          doctype  in varchar2,
                          docsubtype in varchar2) IS

l_progress  VARCHAR2(400) := '000';
l_doc_type varchar2(25);
l_doc_subtype varchar2(25);
l_doc_disp varchar2(240);
l_ga_flag   varchar2(1) := null;

l_display_name varchar2(240);
l_email_address varchar2(240);
l_notification_preference  varchar2(240);
l_language  varchar2(240);
l_territory varchar2(240);
l_msg_text   varchar2(2000) := NULL; -- Bug 3430545
l_language_code fnd_languages.language_code%TYPE;


cursor c_lookup_value_user(p_doc_type varchar2, p_doc_subtype varchar2,
                      p_language varchar2) is
  select type_name
  from po_document_types_tl tl, FND_LANGUAGES fl
  where fl.nls_language = p_language
  and   tl.LANGUAGE = fl.language_code
  and   tl.document_type_code = p_doc_type
  and   tl.document_subtype = p_doc_subtype;

cursor c_lookup_value_doc(p_doc_type varchar2, p_doc_subtype varchar2) is
  select type_name
  from po_document_types
  where document_type_code = p_doc_type
  and   document_subtype = p_doc_subtype;

  l_document_id      PO_HEADERS_ALL.po_header_id%TYPE; --<R12 STYLES PHASE II>

BEGIN
  l_progress := 'PO_WF_PO_NOTIFICATION.GetDisplayValue: 001, user name: '
                || username;
  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

  if ((doctype is NULL) or (docsubtype is null)) then
    l_doc_type := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_TYPE');

    l_doc_subtype := PO_WF_UTIL_PKG.GetItemAttrText (itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'DOCUMENT_SUBTYPE');
  else
   l_doc_type := doctype;
   l_doc_subtype := docsubtype;
  end if;

  IF l_doc_type = 'PA' AND l_doc_subtype = 'BLANKET' THEN

       l_ga_flag := PO_WF_UTIL_PKG.GetItemAttrText  ( itemtype    => itemtype,
                                         itemkey     => itemkey,
                                         aname       => 'GLOBAL_AGREEMENT_FLAG');
  END IF;

  /* Bug 3430545: Modified the code to get the translated values for the wf
   notification attribute 'REQUIRES_APPROVAL_MSG' and 'PO_GA_TYPE'.
   Deleted the previous code and revamped it.
  */
   --<R12 STYLES PHASE II START>
   l_document_id := PO_WF_UTIL_PKG.GetItemAttrNumber
                                       (itemtype   => itemtype,
                                        itemkey    => itemkey,
                                        aname      => 'DOCUMENT_ID');

  IF  username is NULL THEN
	  l_progress := 'PO_WF_PO_NOTIFICATION.GetDisplayValue: 050';
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

      IF l_doc_type = 'PA' AND l_doc_subtype IN ('BLANKET','CONTRACT') OR
         l_doc_type = 'PO' AND l_doc_subtype = 'STANDARD'  then

         l_doc_disp := PO_DOC_STYLE_PVT.GET_STYLE_DISPLAY_NAME(l_document_id);
      ELSE
         OPEN c_lookup_value_doc(l_doc_type, l_doc_subtype);
         FETCH c_lookup_value_doc into l_doc_disp;
         CLOSE c_lookup_value_doc;
      END IF;
  ELSE
	  l_progress := 'PO_WF_PO_NOTIFICATION.GetDisplayValue: 060';
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
      WF_DIRECTORY.GETROLEINFO(
           username,
           l_display_name,
           l_email_address,
           l_notification_preference,
           l_language,
           l_territory);
      l_progress := 'PO_WF_PO_NOTIFICATION.GetDisplayValue: 080, language: '
                    || l_language;
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

      BEGIN

      SELECT language_code
	INTO l_language_code
	FROM fnd_languages
       WHERE nls_language = l_language;

      EXCEPTION
      WHEN OTHERS THEN
	l_language_code := NULL;
      END;

      IF l_doc_type = 'PA' AND l_doc_subtype IN ('BLANKET','CONTRACT') OR
         l_doc_type = 'PO' AND l_doc_subtype = 'STANDARD'  then

         l_doc_disp := PO_DOC_STYLE_PVT.GET_STYLE_DISPLAY_NAME(l_document_id,l_language_code);
     ELSE
          OPEN c_lookup_value_user(l_doc_type, l_doc_subtype, l_language);
          FETCH c_lookup_value_user into l_doc_disp;
          CLOSE c_lookup_value_user;
     END IF;
  END IF;  /* if username is null  */
   --<R12 STYLES PHASE II END>
	 l_progress := 'PO_WF_PO_NOTIFICATION.GetDisplayValue: 100, type disp: '
                || l_doc_disp;
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype    => itemtype,
                                 itemkey     => itemkey,
                                 aname       => 'DOCUMENT_TYPE_DISP',
                                 avalue      =>  l_doc_disp);
     BEGIN
       select message_text
       into l_msg_text
       from fnd_new_messages fm,fnd_languages fl
       where fm.message_name = 'PO_WF_NOTIF_REQUIRES_APPROVAL'
       and fm.language_code = fl.language_code
       and fl.nls_language = l_language
       and fm.application_id = 201;  --<BUG 3712124> Include application_id to better use PK index
       EXCEPTION
           WHEN OTHERS THEN
            l_msg_text := PO_WF_UTIL_PKG.GetItemAttrText(itemtype    => itemtype,
                                                    itemkey     => itemkey,
                                                    aname       => 'REQUIRES_APPROVAL_MSG');
     END;

    PO_WF_UTIL_PKG.SetItemAttrText ( itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'REQUIRES_APPROVAL_MSG',
                                   avalue      => l_msg_text );

    /* PO AME Project start :
       Fetching and setting REQUIRES_REVIEW_MSG attribute */
     BEGIN
       select message_text
       into l_msg_text
       from fnd_new_messages fm,fnd_languages fl
       where fm.message_name = 'PO_WF_NOTIF_REQUIRES_REVIEW'
       and fm.language_code = fl.language_code
       and fl.nls_language = l_language
       and fm.application_id = 201;
       EXCEPTION
           WHEN OTHERS THEN
            l_msg_text := PO_WF_UTIL_PKG.GetItemAttrText(itemtype    => itemtype,
                                                    itemkey     => itemkey,
                                                    aname       => 'REQUIRES_REVIEW_MSG');
     END;

      PO_WF_UTIL_PKG.SetItemAttrText ( itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'REQUIRES_REVIEW_MSG',
                                   avalue      => l_msg_text );

     BEGIN
       select message_text
       into l_msg_text
       from fnd_new_messages fm,fnd_languages fl
       where fm.message_name = 'PO_WF_NOTIF_REQUIRES_ESIGN'
       and fm.language_code = fl.language_code
       and fl.nls_language = l_language
       and fm.application_id = 201;
       EXCEPTION
           WHEN OTHERS THEN
            l_msg_text := PO_WF_UTIL_PKG.GetItemAttrText(itemtype    => itemtype,
                                                         itemkey     => itemkey,
                                                         aname       => 'REQUIRES_ESIGN_MSG');
     END;

      PO_WF_UTIL_PKG.SetItemAttrText ( itemtype    => itemtype,
                                       itemkey     => itemkey,
                                       aname       => 'REQUIRES_ESIGN_MSG',
                                       avalue      => l_msg_text );

    /* PO AME Project end */

EXCEPTION
  WHEN OTHERS THEN
    l_progress := 'PO_WF_PO_NOTIFICATION.GetDisplayValue: sql err: ' || sqlerrm;
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    IF (c_lookup_value_user%ISOPEN) THEN
      CLOSE c_lookup_value_user;
    END IF;
    IF (c_lookup_value_doc%ISOPEN) THEN
      CLOSE c_lookup_value_doc;
    END IF;

END GetDisplayValue;

------------------------------------------------------------------<BUG 3607009>
-------------------------------------------------------------------------------
--Start of Comments
--Name: is_open_document_allowed
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Determines if the Open Document icon should be shown in the
--  PO Approval Notification. The Open Document should not be shown if...
--  (1) the document is in 'Pre-Approved' state and
--  (2) document signature is required.
--Parameters:
--IN:
--p_itemtype
--  Standard parameter to be used in a workflow procedure
--p_itemkey
--  Standard parameter to be used in a workflow procedure
--p_notification_type
--  Specifies whether this notification is for the Preparer/Submitter
--  or an Approver/Reviewer
--  The value is derived from the WF Function attribute NTF_USER_ROLE
--  in the GET_<>_NOTIFICATION_ATTRIBUTE functions in POAPPRV workflow
--  Added for bug 3668188
--Returns:
--resultout
--  A BOOLEAN TRUE if the Open Document icon should be shown, FALSE otherwise.
--Testing:
--  N/A
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION is_open_document_allowed
(
    p_itemtype            IN   VARCHAR2
,   p_itemkey             IN   VARCHAR2
,   p_notification_type   IN   VARCHAR2   --bug 3668188
)
RETURN BOOLEAN
IS
    l_api_name               VARCHAR2(30) := 'is_open_document_allowed';
    l_log_head               VARCHAR2(100) := g_pkg_name||'.'||l_api_name;
    l_progress               VARCHAR2(3);

    l_authorization_status   PO_HEADERS_ALL.authorization_status%TYPE;
    l_result                 BOOLEAN := TRUE;

BEGIN

l_progress:='000'; PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress || 'Notification Type = ' || p_notification_type);

    -- Get the Authorization Status (e.g. 'PRE-APPROVED','APPROVED',
    -- 'INCOMPLETE', etc.) of the document.
    --
    l_authorization_status := wf_engine.GetItemAttrText
                              (   itemtype => p_itemtype
                              ,   itemkey  => p_itemkey
                              ,   aname    => 'AUTHORIZATION_STATUS'
                              );

l_progress:='010'; PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress||' Authorization Status = '||l_authorization_status);


    -- bug 3668188: changed the Open Doc allowed logic.
    -- If document is ('Pre-Approved' or 'In Process') and the
    -- notification is going back to the Submitter, then that
    -- user should not be able to open the document for edit.
    --
    IF (l_authorization_status IN ('PRE-APPROVED', 'IN PROCESS')
        AND nvl(p_notification_type, 'SUBMITTER') = 'SUBMITTER')
    THEN
        l_progress:='020';
        PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress||':FALSE');
        l_result := FALSE;
    END IF;

    l_progress:='030';
    PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||l_progress||':TRUE');
    return (l_result);

EXCEPTION

    WHEN OTHERS THEN
        PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_log_head||':'||SQLERRM);
        RAISE;

END is_open_document_allowed;

------------------<BUG 13951919>-----------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: update_action_history
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  This procedure updates the po_action_history table based on the approvers response.
--Parameters:
--IN:
--p_action_code
--p_recipient_id
--p_note
--p_po_header_id
--p_current_id
--p_doc_type
--p_doc_subtype
--p_approval_path_id --<bug 14105414>

--OUT:

--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

PROCEDURE update_action_history (p_action_code         IN VARCHAR2,
                              p_recipient_id           IN NUMBER,
                              p_note                   IN VARCHAR2,
                              p_po_header_id           IN NUMBER,
                              p_current_id             IN NUMBER,
                              p_doc_type               IN  po_action_history.OBJECT_TYPE_CODE%TYPE,
			      p_doc_subtype            IN po_action_history.OBJECT_SUB_TYPE_CODE%TYPE,
                              p_approval_path_id       IN PO_ACTION_HISTORY.APPROVAL_PATH_ID%TYPE) --<bug 14105414>
IS
  pragma AUTONOMOUS_TRANSACTION;

  l_progress               VARCHAR2(100) := '000';

  l_sequence_num           PO_ACTION_HISTORY.SEQUENCE_NUM%TYPE;
  l_object_revision_num    PO_ACTION_HISTORY.OBJECT_REVISION_NUM%TYPE;
  l_approval_path_id       PO_ACTION_HISTORY.APPROVAL_PATH_ID%TYPE;
  l_request_id             PO_ACTION_HISTORY.REQUEST_ID%TYPE;
  l_program_application_id PO_ACTION_HISTORY.PROGRAM_APPLICATION_ID%TYPE;
  l_program_date           PO_ACTION_HISTORY.PROGRAM_DATE%TYPE;
  l_program_id             PO_ACTION_HISTORY.PROGRAM_ID%TYPE;

BEGIN

  SELECT max(sequence_num)
  INTO l_sequence_num
  FROM PO_ACTION_HISTORY
  WHERE object_id = p_po_header_id
     AND object_type_code = p_doc_type
     AND object_sub_type_code = p_doc_subtype;


   SELECT object_revision_num,
  	 approval_path_id,
	 request_id,
         program_application_id,
	 program_date,
	 program_id
  INTO   l_object_revision_num,
	 l_approval_path_id,
	 l_request_id,
	 l_program_application_id,
	 l_program_date,
	 l_program_id
  FROM PO_ACTION_HISTORY
  WHERE object_id = p_po_header_id
     AND object_type_code = p_doc_type
     AND object_sub_type_code = p_doc_subtype
     AND employee_id = p_current_id
     AND sequence_num = l_sequence_num;

  l_progress := '010';

  -- Updating action history with the approver action details

  UPDATE PO_ACTION_HISTORY
  SET     last_update_date = sysdate,
          last_updated_by =  fnd_global.user_id,
          last_update_login = fnd_global.login_id ,
          action_date = sysdate,
          action_code = p_action_code,
          note = p_note,
          approval_path_id = nvl(p_approval_path_id, l_approval_path_id), --<bug 14105414>
          offline_code = NULL
   WHERE   employee_id = p_current_id
   AND	object_id = p_po_header_id
   AND	object_type_code = p_doc_type
   AND  object_sub_type_code = p_doc_subtype
   AND  action_code IS NULL;


  l_progress := '020';

  IF p_recipient_id IS NOT NULL THEN --<bug 14105414>
    INSERT INTO PO_ACTION_HISTORY
        	(object_id,
        	object_type_code,
        	object_sub_type_code,
        	sequence_num,
        	last_update_date,
        	last_updated_by,
        	employee_id,
        	action_code,
		action_date,
        	note,
        	object_revision_num,
        	last_update_login,
        	creation_date,
        	created_by,
        	request_id,
        	program_application_id,
        	program_id,
        	program_date,
        	approval_path_id,
        	offline_code,
        	program_update_date
                )
    VALUES (p_po_header_id,
        	p_doc_type,
        	p_doc_subtype,
        	l_sequence_num + 1,
        	sysdate,
        	fnd_global.user_id,
        	p_recipient_id,
        	NULL,
		NULL,
        	NULL,
        	l_object_revision_num,
        	fnd_global.login_id,
        	sysdate,
        	fnd_global.user_id,
        	l_request_id,
        	l_program_application_id,
        	l_program_id,
        	l_program_date,
        	l_approval_path_id,
        	NULL,
        	sysdate);
  END IF; --<bug 14105414>
  l_progress := '030';

  commit;
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('PO_WF_PO_NOTIFICATION','update_action_history',l_progress,sqlerrm);
    RAISE;
END;

END PO_WF_PO_NOTIFICATION;

/
