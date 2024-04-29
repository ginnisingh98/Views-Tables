--------------------------------------------------------
--  DDL for Package Body PO_EMAIL_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_EMAIL_GENERATE" AS
/* $Header: POXWPAMB.pls 120.8.12010000.13 2013/03/20 13:47:18 swagajul ship $ */

 /*=======================================================================+
 | FILENAME
 |   POXWPAMB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package:  PO_EMAIL_GENERATE
 |
 | NOTES        Diwas Kc Created 02/09/01
 | 		Created for generating the header and body of a PO Email notification.
 | MODIFIED    (MM/DD/YY)
 | -  bug fix 2203163 - release not showing correct price - 02/07/2002
 | -  bug fix 2336094 - davidng - 05/30/2002
 |                      Added 3 new exception handling cases in the exception
 |                      block in procedure generate_term
 | -  bug fix 2473707 - davidng - 08/12/2002
 |                      Added an IF conditional to display the item revision number
 |                      when it is present
 | -  PO UTF8 Project - tpoon - 09/06/2002
 |                      Changed the type of l_header_note_to_vendor from
 |                      VARCHAR2(240) to po_headers_all.note_to_vendor%TYPE.
 |
 | -  PO TIMEPHASED   - davidng - 09/09/2002
 |    Project           1. Added start_date and end_date to cursor shipment_blanket_cursor
 |                         to display effective dates at the Blanket Agreement price breaks.
 |                      2. Added start_date and end_date to the type declaration shipment_record.
 |                      3. Added code to display start_date and end_date in the HTML notification
 |                      4. All code changes done in procedure generate_html().
 |                         Search for keyword TIMEPHASED.
 *=======================================================================*/

c_log_head    CONSTANT VARCHAR2(30) := 'po.plsql.PO_EMAIL_GENERATE.';   -- Bug 2792156
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N'); -- <BUG 9891660>

TYPE shipment_record IS RECORD (
  line_num	   po_lines_all.line_num%TYPE,
  po_line_id	   po_lines_all.po_line_id%TYPE,
  item_num	   mtl_system_items_kfv.concatenated_segments%TYPE,
  item_revision    po_lines_all.item_revision%TYPE,
  vendor_product_num         po_lines.vendor_product_num%TYPE,  /* Bug 3105566 */
  item_desc        po_lines.item_description%TYPE,
  uom              mtl_units_of_measure_tl.unit_of_measure_tl%TYPE,   /* Bug 2701946 */
  quantity         po_line_locations.quantity%TYPE,
  unit_price       po_lines.unit_price%TYPE,
  need_by_date     po_line_locations.need_by_date%TYPE,
  promised_date    po_line_locations.promised_date%TYPE,
  taxable_flag	   po_line_locations.taxable_flag%TYPE,
  note_to_vendor   po_lines_all.note_to_vendor%TYPE,
  un_number_id	   po_lines_all.un_number_id%TYPE,
  hazard_class_id  po_lines_all.hazard_class_id%TYPE,
  cancel_flag	   po_line_locations_all.cancel_flag%TYPE,
  cancel_date	   po_line_locations_all.cancel_date%TYPE,
  quantity_cancelled po_line_locations_all.quantity_cancelled%TYPE,
  item_id	   po_lines_all.item_id%TYPE,
  org_id	   po_line_locations_all.org_id%TYPE,
  contract_num	   po_lines_all.contract_num%TYPE,
  line_location_id	   po_line_locations_all.line_location_id%TYPE,
  ship_to_location_id	po_line_locations_all.ship_to_location_id%TYPE,
  consigned_flag   po_line_locations_all.consigned_flag%TYPE, -- <SUP_CON FPI>
  start_date       po_line_locations_all.start_date%TYPE,   /* <TIMEPHASED FPI> */
  end_date         po_line_locations_all.end_date%TYPE,      /* <TIMEPHASED PFI> */
  --<Bug 2817117 mbhargav START>
  from_header_id   po_lines_all.from_header_id%type,
  from_line_id     po_lines_all.from_line_id%TYPE,
  --<Bug 2817117 mbhargav END>
  drop_ship_flag po_line_locations_all.drop_ship_flag%TYPE --Bug 9437371
);


procedure generate_html		(document_id	in	varchar2,
				 display_type	in 	Varchar2,
                                 document	in out	NOCOPY clob,
				 document_type	in out NOCOPY  varchar2) IS

l_document         VARCHAR2(32000) := '';
NL                 VARCHAR2(1) := fnd_global.newline;

shipmentNum 	   NUMBER := 1;

l_document_id	   VARCHAR2(30) := document_id;

l_document_type	  VARCHAR2(30) := '';

l_currency_code    fnd_currencies.currency_code%TYPE;

l_line_loc	   shipment_record;
l_date		   VARCHAR2(20) := '';
-- Bug 3637864. Need to display both Promised and Need By Date
l_promised_date		   VARCHAR2(20) := '';
l_needby_date		   VARCHAR2(20) := '';
l_start_date               VARCHAR2(20) := ''; -- Bug 2687751
l_end_date                 VARCHAR2(20) := ''; -- Bug 2687751

l_ship_to_count	 NUMBER := 0;

l_extension	   NUMBER := 0;
l_extension_total  NUMBER := 0;
l_blanket_total_amount NUMBER := 0;
x_subtype po_headers.type_lookup_code%TYPE;
l_datatype_count	NUMBER := 0;

l_vendor_quote_num	po_lines_print.VENDOR_QUOTE_NUM%TYPE;
l_po_quote_num		po_lines_print.PO_QUOTE_NUM%TYPE;
l_po_header_id          po_headers.po_header_id%TYPE;
l_src_ga_flag           po_lines_print.SRC_GA_FLAG%TYPE;    -- GA FPI

l_org_id	NUMBER;
x_orgid         NUMBER;
l_un_number	PO_UN_NUMBERS.UN_NUMBER%TYPE;
l_hazard_class	PO_HAZARD_CLASSES.HAZARD_CLASS%TYPE;
l_text		FND_DOCUMENTS_SHORT_TEXT.SHORT_TEXT%TYPE := null;

l_item_short_text		FND_DOCUMENTS_SHORT_TEXT.SHORT_TEXT%TYPE := null;
l_item_long_text	FND_DOCUMENTS_LONG_TEXT.LONG_TEXT%TYPE := null;

l_long_text	FND_DOCUMENTS_LONG_TEXT.LONG_TEXT%TYPE := null;
l_datatype_id	fnd_attached_docs_form_vl.datatype_id%TYPE;
l_media_id	fnd_attached_docs_form_vl.media_id%TYPE;
l_item_datatype_id	fnd_attached_docs_form_vl.datatype_id%TYPE;
l_item_media_id	fnd_attached_docs_form_vl.media_id%TYPE;
l_cancel_flag	po_line_locations_all.cancel_flag%TYPE;
l_cancel_date	   po_line_locations_all.cancel_date%TYPE;
l_quantity_cancelled po_line_locations_all.quantity_cancelled%TYPE;

l_requestor_name	po_distributions_print.requestor_name%TYPE;
l_requestor_id        po_distributions_print.requestor_id%TYPE;

/* Bug 2870932 increased the size */
l_phone           per_all_people_f.work_telephone%TYPE;
l_email_address  per_all_people_f.email_address%TYPE;
/* End of Bug 2870932 */

l_requestor_count	NUMBER := 0;
l_multiple_flag       varchar2(1);

l_prev_line_po_line_num	NUMBER := 0;
l_po_line_only	varchar2(2) := 'Y';
x_display_type varchar2(60);

--<Bug 2817117 mbhargav>
l_global_flag   po_headers_all.global_agreement_flag%type;

-- PO_WF_NOTIF_HEADER_NOTE
l_header_text	FND_DOCUMENTS_LONG_TEXT.LONG_TEXT%TYPE;


-- PO_WF_NOTIF_SHIPMENT_NOTE
l_shipment_text FND_DOCUMENTS_LONG_TEXT.LONG_TEXT%TYPE;


-- variable to hold html string for attachments
l_attachments_text varchar2(32000) := '';

/** Fix for PO UTF8 Project **/
-- This holds data from either po_headers.note_to_vendor or
-- po_releases.note_to_vendor:
l_header_note_to_vendor po_headers_all.note_to_vendor%TYPE;
-- l_header_note_to_vendor varchar2(240);

x_pb_count number;

l_hrl_location         hr_locations_all.location_code%TYPE;
l_hrl_description      hr_locations_all.description%TYPE;
l_hrl_address_line_1   hr_locations_all.address_line_1%TYPE;
l_hrl_address_line_2   hr_locations_all.address_line_2%TYPE;
l_hrl_address_line_3   hr_locations_all.address_line_3%TYPE;
l_hrl_town_or_city	   hr_locations_all.town_or_city%TYPE;
l_hrl_postal_code	   hr_locations_all.postal_code%TYPE;
-- EMAILPO FPH START--
l_hrl_to_region1	fnd_lookup_values.meaning%TYPE;
l_hrl_to_region2	fnd_lookup_values.meaning%TYPE;
l_hrl_to_region3	fnd_lookup_values.meaning%TYPE;
/* Bug 2766736. Changed nls_territory to territory_short_name */
l_hrl_country	   fnd_territories_vl.territory_short_name%TYPE;
-- EMAILPO FPH END--

--bug fix 2257742
l_min_unit fnd_currencies.minimum_accountable_unit%TYPE;
l_precision fnd_currencies.precision%TYPE;
l_ext_precision fnd_currencies.extended_precision%TYPE; -- Bug fix 3314246

l_allow_item_desc_update mtl_system_items.allow_item_desc_update_flag%TYPE;
l_mtl_system_items_desc mtl_system_items_tl.description%TYPE;


/* bug 4567441 : added the orderby clause, so that the document attachments
   are ordered by sequence */
cursor attachments_cursor(v_entity_name varchar2, v_document_id number) is
Select datatype_id, media_id
from fnd_attached_docs_form_vl
where entity_name = v_entity_name
and pk1_value = to_char(v_document_id) /* Bug 5964375 */
and function_name = 'PO_PRINTPO'
and datatype_id in (1,2)
and media_id is not null
order by seq_num;

--<Bug 2872552 mbhargav START>
--Cursor which ensures that only those attachments are picked which
--which are shared across operating unit or ones which belong to same
--security type
/* bug 4567441 : added the orderby clause, so that the document attachments
   are ordered by sequence */
cursor attachments_from_ga_cursor(v_entity_name varchar2, v_document_id number) is
Select datatype_id, media_id
from fnd_attached_docs_form_vl fad, financials_system_parameters fsp
where entity_name = v_entity_name
and pk1_value = to_char(v_document_id) /* Bug 5964375 */
and function_name = 'PO_PRINTPO'
and datatype_id in (1,2)
and media_id is not null
AND (publish_flag = 'Y'
     --Security level is Organization
     OR (security_type = 1 AND security_id = fsp.org_id)
     --Security level is Set Of Books
     OR (security_type = 2 AND security_id = fsp.set_of_books_id)
     --Security level is NONE
     OR (security_type = 4)
    )
order by fad.seq_num;
--<Bug 2872552 mbhargav END>
/* bug 4567441 : added the orderby clause, so that the document attachments
   are ordered by sequence */
cursor item_notes_cursor(v_org_id number, v_item_id number) is
SELECT datatype_id,
       media_id
  FROM fnd_attached_docs_form_vl
 WHERE entity_name = 'MTL_SYSTEM_ITEMS' AND
       pk1_value = to_char(v_org_id) AND
       pk2_value = to_char(v_item_id) AND
       function_name = 'PO_PRINTPO' and
	datatype_id in (1,2) and
	media_id is not null
	order by seq_num;

CURSOR shipment_cursor(v_document_id NUMBER) IS
SELECT pol.line_num,
       pll.po_line_id,
       msi.concatenated_segments,
       pol.item_revision,
       pol.vendor_product_num,
       pol.item_description,
       umvl.unit_of_measure_tl,   /* Bug 2701946 */
       pll.quantity,
       pol.unit_price,
       pll.need_by_date,
       pll.promised_date,
       pll.taxable_flag,
       pol.note_to_vendor,
       pol.un_number_id,
       pol.hazard_class_id,
       pll.cancel_flag,
       pll.cancel_date,
       pll.quantity_cancelled,
       pol.item_id,
       fsp.inventory_organization_id org_id,  /* Bug 3064519 */
       pol.contract_num,
       pll.line_location_id,
       pll.ship_to_location_id,
       pll.consigned_flag, --< SUP_CON FPI>
       null,                   /* <TIMEPHASED FPI> */
       null,                    /* <TIMEPHASED FPI> */
       --<Bug 2817117 mbhargav START>
       pol.from_header_id,
       pol.from_line_id,
       --<Bug 2817117 mbhargav END>
       pll.drop_ship_flag --Bug 9437371
  FROM po_lines_all   pol,    --<R12.MOAC>  --po_lines   pol,
       po_line_locations pll,
       mtl_system_items_kfv msi,
       mtl_units_of_measure_vl umvl,
       financials_system_params_all  fsp     --<R12.MOAC>  --financials_system_parameters  fsp
  where  PLL.PO_HEADER_ID = v_document_id
  and    PLL.po_line_id    = POL.po_line_id
  and    PLL.po_release_id is NULL /* Bug 4513703 */
  and    pol.item_id = msi.inventory_item_id(+)
  and    NVL(msi.organization_id, fsp.inventory_organization_id) = fsp.inventory_organization_id
  and    nvl(pol.cancel_flag,'N') = 'N'
  and    nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code) = umvl.unit_of_measure
  and    POL.org_id = FSP.org_id      --<R12.MOAC>
  order by line_num, pll.shipment_num asc;    --<Bug 14794256>


CURSOR shipment_blanket_cursor(v_document_id NUMBER) IS
SELECT pol.line_num,
       pll.po_line_id,
       msi.concatenated_segments,
       pol.item_revision,
       pol.vendor_product_num,
       pol.item_description,
       umvl.unit_of_measure_tl,   /* Bug 2701946 */
       pll.quantity,
       nvl(pll.price_override, pol.unit_price) unit_price,
       pll.need_by_date,
       pll.promised_date,
       pll.taxable_flag,
       pol.note_to_vendor,
       pol.un_number_id,
       pol.hazard_class_id,
       pll.cancel_flag,
       pll.cancel_date,
       pll.quantity_cancelled,
       pol.item_id,
       fsp.inventory_organization_id org_id,  /* Bug 3064519 */
       pol.contract_num,
       pll.line_location_id,
       pll.ship_to_location_id,
       NULL, -- <SUP_CON FPI>
       pll.start_date,                 /* <TIMEPHASED FPI> */
       pll.end_date,                    /* <TIMEPHASED FPI> */
       --<Bug 2817117 mbhargav START>
       null,
       NULL,
       --<Bug 2817117 mbhargav END>
       pll.drop_ship_flag --Bug 9437371
  FROM po_lines_all   pol,    --<R12.MOAC>  --po_lines   pol,
       po_line_locations pll,
       mtl_system_items_kfv msi,
       mtl_units_of_measure_vl umvl,
       financials_system_params_all  fsp     --<R12.MOAC>  --financials_system_parameters  fsp
  where  POL.PO_HEADER_ID = v_document_id
  and    POL.po_line_id  = PLL.po_line_id(+)
  and    pol.item_id = msi.inventory_item_id(+)
  and 	 pll.shipment_type(+) = 'PRICE BREAK'
  and    NVL(msi.organization_id, fsp.inventory_organization_id) = fsp.inventory_organization_id
  and    nvl(pol.cancel_flag,'N') = 'N'
  and    nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code) = umvl.unit_of_measure
  and    POL.org_id = FSP.org_id      --<R12.MOAC>
  order by line_num, pll.shipment_num asc;   --<Bug 14794256>

CURSOR blanket_line_cursor(v_document_id NUMBER) IS
SELECT pol.line_num,
       pol.po_line_id,
       msi.concatenated_segments,
       pol.item_revision,
       pol.vendor_product_num,
       pol.item_description,
       umvl.unit_of_measure_tl,   /* Bug 2701946 */
       pol.quantity,
       pol.unit_price,
       null, --pol.need_by_date,
       null, -- pol.promised_date,
       null, --pll.taxable_flag,
       pol.note_to_vendor,
       pol.un_number_id,
       pol.hazard_class_id,
       pol.cancel_flag,
       pol.cancel_date,
       null, --pll.quantity_cancelled,
       pol.item_id,
       fsp.inventory_organization_id org_id,  /* Bug 3064519 */
       pol.contract_num,
       null, --pll.line_location_id,
       poh.ship_to_location_id,
       NULL, -- <SUP_CON FPI>
       null,                   /* <TIMEPHASED FPI> */
       null,                    /* <TIMEPHASED FPI> */
       --<Bug 2817117 mbhargav START>
       null,
       NULL,
       --<Bug 2817117 mbhargav END>
        NULL --Bug 9437371
  FROM po_lines   pol,
       po_headers_all poh,       --<R12.MOAC>   --po_headers poh,
       mtl_system_items_kfv msi,
       mtl_units_of_measure_vl umvl,
       financials_system_params_all  fsp     --<R12.MOAC>  --financials_system_parameters  fsp
  where  POL.PO_HEADER_ID = v_document_id
  and    POL.po_header_id = POH.po_header_id
  and    pol.item_id = msi.inventory_item_id(+)
  and    NVL(msi.organization_id, fsp.inventory_organization_id) = fsp.inventory_organization_id
  and    nvl(pol.cancel_flag,'N') = 'N'
  and    pol.unit_meas_lookup_code = umvl.unit_of_measure
  and    POL.org_id = FSP.org_id      --<R12.MOAC>
  order by line_num asc;

CURSOR shipment_release_cursor(v_document_id NUMBER) IS
SELECT pol.line_num,
       pll.po_line_id,
       msi.concatenated_segments,
       pol.item_revision,
       pol.vendor_product_num,
       pol.item_description,
       umvl.unit_of_measure_tl,   /* Bug 2701946 */
       pll.quantity,
       pll.price_override,
       pll.need_by_date,
       pll.promised_date,
       pll.taxable_flag,
       pol.note_to_vendor,
       pol.un_number_id,
       pol.hazard_class_id,
       pll.cancel_flag,
       pll.cancel_date,
       pll.quantity_cancelled,
       pol.item_id,
       fsp.inventory_organization_id org_id,  /* Bug 3064519 */
       pol.contract_num,
       pll.line_location_id,
       pll.ship_to_location_id,
       NULL, -- <SUP_CON FPI>
       null,                   /* <TIMEPHASED FPI> */
       null,                    /* <TIMEPHASED FPI> */
       --<Bug 2817117 mbhargav START>
       null,
       NULL,
       --<Bug 2817117 mbhargav END>
       pll.drop_ship_flag --Bug 9437371
  FROM po_lines_all   pol,    --<R12.MOAC>  --po_lines   pol,
       po_line_locations pll,
       mtl_system_items_kfv msi,
       mtl_units_of_measure_vl umvl,
       financials_system_params_all  fsp     --<R12.MOAC>  --financials_system_parameters  fsp
  where  PLL.PO_RELEASE_ID = v_document_id
  and    PLL.po_line_id    = POL.po_line_id
  and    pol.item_id = msi.inventory_item_id(+)
  and    NVL(msi.organization_id, fsp.inventory_organization_id) =
          fsp.inventory_organization_id
  and   nvl(pol.cancel_flag,'N') = 'N'
  and   nvl(pll.unit_meas_lookup_code, pol.unit_meas_lookup_code) = umvl.unit_of_measure
  and   PLL.org_id = FSP.org_id      --<R12.MOAC>
  order by line_num, pll.shipment_num asc; --<Bug 14794256>

cursor requestor_cursor (v_line_location_id NUMBER) IS
select distinct deliver_to_person_id
FROM    po_distributions pdp
WHERE    pdp.line_location_id = v_line_location_id;

l_document_status varchar2(100);

/*Bug 9437371 defined local variables to display drop ship info*/
l_drop_ship NUMBER;
l_ship_cust_name VARCHAR2(400);
l_ship_cont_name VARCHAR2(400);
/*Bug 9437371 */

-- <BUG 9891660>
l_item_type wf_items.item_type%TYPE;
l_item_key  wf_items.item_key%TYPE;
l_progress  varchar2(100);

BEGIN

/* Bug# 2493568: kagarwal
** Desc: The cancelled qty on shipments, if any, was not getting subtracted
** from the ordered shipment qty and the calculated PO Total also included
** the amount for cancelled qty on the shipment.
**
** Added clause (l_line_loc.quantity - nvl(l_line_loc.quantity_cancelled, 0))
** wherever the qty ordered was being displayed or being used in calculation.
*/

	--<BUG 9891660 START>
	l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  	l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);

	l_document_id:=wf_engine.GetItemAttrNumber (itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'DOCUMENT_ID');

        l_document_type:=wf_engine.GetItemAttrText (itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'DOCUMENT_TYPE');

	l_org_id := wf_engine.GetItemAttrNumber ( itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'ORG_ID');

        l_progress := 'PO_EMAIL_GENERATE.GENERATE_HTML';
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug('itemtype','itemkey','l_item_type= ' || l_item_type);
		PO_WF_DEBUG_PKG.insert_debug('itemtype','itemkey','l_item_key= ' || l_item_key);
		PO_WF_DEBUG_PKG.insert_debug('itemtype','itemkey','l_document_id= ' || l_document_id);
		PO_WF_DEBUG_PKG.insert_debug('itemtype','itemkey','l_document_type= ' || l_document_type);
		PO_WF_DEBUG_PKG.insert_debug('itemtype','itemkey','l_org_id= ' || l_org_id);
	END IF;

	IF l_org_id IS NOT NULL THEN
		--fnd_client_info.set_org_context(to_char(l_org_id));
    PO_MOAC_UTILS_PVT.set_org_context(to_char(l_org_id)) ;
        END IF;
	--<BUG 9891660 END>

        x_display_type := 'text/html';

        --2332866, check if the document is in processing, and
        -- show warning message to the supplier
        if(l_document_type in ('PO', 'PA')) then
          select authorization_status
            into l_document_status
            from po_headers_all
           where po_header_id = l_document_id;

        elsif (l_document_type = 'RELEASE') then
         /* Bug 2791859 po_releases_all should be used instead of po_releases */
          select po_header_id into l_po_header_id from po_releases_all
          where po_release_id = l_document_id;

          select authorization_status
            into l_document_status
            from po_headers_all
           where po_header_id = l_po_header_id;
        end if;

        if(l_document_status is null or
                l_document_status in ('IN PROCESS', 'INCOMPLETE', 'REQUIRES REAPPROVAL')) then
          WF_NOTIFICATION.WriteToClob(document, ' ');
          return;
        end if;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_document_status= ' || l_document_status);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_po_header_id= ' || l_po_header_id);
	END IF;
	--<BUG 9891660 END>

        /* setting the org context here inside this procedure because wf mailer does not supply the
           context. */
	/* BUG 9891660
        PO_REQAPPROVAL_INIT1.get_multiorg_context (l_document_type, l_document_id, x_orgid);

        IF x_orgid is NOT NULL THEN

          PO_MOAC_UTILS_PVT.set_org_context(x_orgid) ;       -- <R12.MOAC>

        END IF;*/

        IF (l_document_type = 'PA') THEN
            select type_lookup_code
            into x_subtype
            from po_headers
            where po_header_id = l_document_id;
        END IF;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'x_subtype= ' || x_subtype);
	END IF;
	--<BUG 9891660 END>

IF (l_document_type = 'PA') and  (x_subtype = 'CONTRACT') THEN
          null;

ELSE
	IF (l_document_type = 'PO') THEN
	-- Seeing if the ship to locations are distinct or not
		select count(distinct pll.ship_to_location_id) into l_ship_to_count
		from
	        po_lines_all   pol,   -- <R12.MOAC>  --po_lines   pol,
       		po_line_locations pll
  		where  PLL.PO_HEADER_ID = l_document_id
  		and    PLL.po_line_id    = POL.po_line_id;
	ELSIF  (l_document_type = 'RELEASE') THEN
	  -- Seeing if the ship to locations are distinct or not
	  	select count(distinct pll.ship_to_location_id) into l_ship_to_count
	        FROM  po_lines_all   pol,   -- <R12.MOAC>  --po_lines   pol,
       		po_line_locations pll
  		where  PLL.PO_RELEASE_ID = l_document_id
  		and    PLL.po_line_id    = POL.po_line_id;
	  ELSIF (l_document_type = 'PA') THEN
	-- Seeing if the ship to locations are distinct or not

/* Bug# 2684059: kagarwal
** Added nvl clause for the case when the Blanket PA does not have
** any PRICE BREAKS
*/
		select nvl(count(distinct pll.ship_to_location_id),0)
                into l_ship_to_count
  		FROM po_lines_all   pol,   -- <R12.MOAC>  --po_lines   pol,
       		po_line_locations pll
  		where  PLL.PO_HEADER_ID = l_document_id
  		and    PLL.po_line_id    = POL.po_line_id
		and    PLL.shipment_type = 'PRICE BREAK';
	ELSE
		null;
	END IF;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_ship_to_count= ' || l_ship_to_count);
	END IF;
        --<BUG 9891660 END>

	IF (l_document_type = 'PA') THEN
           select count(*) into x_pb_count
           from po_line_locations
           where po_header_id = l_document_id;
        END IF;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'x_pb_count= ' || x_pb_count);
	END IF;
	--<BUG 9891660 END>

IF (x_display_type = 'text/html') THEN


    	l_document := NL || NL || '<!-- PO_LINE_DETAILS -->'|| NL || NL || '<P><B>';
    	-- l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_DETAILS');
    	-- l_document := l_document || '</B>';

    	l_document := l_document || '<TABLE WIDTH=100% border=1 cellpadding=2 cellspacing=1>';

    	l_document := l_document || '<TR>' || NL;

    	l_document := l_document || '<TH>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || '</TH>' || NL;

    	 l_document := l_document || '<TH width=100>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PART_NO_DESC') || '</TH>' || NL;

	l_document := l_document || '<TH>' ||
    	                fnd_message.get_string('PO', 'PO_WF_NOTIF_DELIVERY_DATE') || '</TH>' || NL;

        /* <TIMEPHASED FPI> */
        /* Displaying the Effective Date and Expires On column titles */
	/* Bug 2780755 start.
	 * We need to show effective start and end dates only for document
	 * type PA.
	*/
        IF ((l_document_type = 'PA') and (x_subtype = 'BLANKET')) THEN
		l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_EFFECTIVE_DATE') || '</TH>' || NL;

		l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_EXPIRES_ON') || '</TH>' || NL;
	end if;
	/* Bug 2780755 End. */
        /* <TIMEPHASED FPI> */

	l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || '</TH>' || NL;

    	l_document := l_document || '<TH>' ||
                  	fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || '</TH>' || NL;
	l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || '</TH>' || NL;

        l_document := l_document || '<TH>' ||
             fnd_message.get_string('PO','PO_WF_NOTIF_TAX') || '</TH>' || NL;
	l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_EXTENSION') || '</TH>' || NL;
/*
	l_document := l_document || '<TH>' ||
                  fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX') || '</TH>' || NL;
*/
    	l_document := l_document || '</TR>' || NL;

	l_document := l_document || '</B>';


	/* Now generate the html code for the individual rows in the table */
	--<BUG 9891660> Removed fetching org_id from the following sqls
	IF (l_document_type = 'PO') THEN

		select note_to_vendor ,currency_code
		into l_header_note_to_vendor , l_currency_code
		from po_headers
		where po_header_id = to_number(l_document_id);
		open shipment_cursor(l_document_id);


	ELSIF (l_document_type = 'RELEASE') THEN


		select note_to_vendor ,po_header_id
		into l_header_note_to_vendor , l_po_header_id
		from po_releases
		where po_release_id = to_number(l_document_id);

                select currency_code into l_currency_code
                from po_headers
                where po_header_id = l_po_header_id;

		open shipment_release_cursor(l_document_id);

	ELSIF (l_document_type = 'PA') THEN

		select note_to_vendor ,currency_code, blanket_total_amount
		into l_header_note_to_vendor ,l_currency_code, l_blanket_total_amount
		from po_headers
		where po_header_id = to_number(l_document_id);

                if x_pb_count <> 0 then
		  open shipment_blanket_cursor(l_document_id);
                else
                  open blanket_line_cursor(l_document_id);
                end if;


	ELSE
		null;
	END IF;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_header_note_to_vendor= ' || l_header_note_to_vendor);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_currency_code= ' || l_currency_code);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_blanket_total_amount= ' || l_blanket_total_amount);
	END IF;
	--<BUG 9891660 END>
--	l_currency_code := PO_CORE_S2.get_base_currency;

	-- Bug fix 2257742
    fnd_currency.get_info(l_currency_code, l_precision, l_ext_precision, l_min_unit);


/* Bug# 2737371: kagarwal
** Desc: Adding the <PRE> tag when adding the attachment text to
** the html document in order to preserve the text formatting in the attachments.
** Made changes to the Header and Line Level attachments only.
*/

	-- Getting the header level text information and displaying it if it exists
	if (l_document_type in ('PO', 'PA')) then
		open attachments_cursor('PO_HEADERS', l_document_id);
	elsif (l_document_type = 'RELEASE') then
		open attachments_cursor('PO_RELEASES', l_document_id);
	else
		null;
	end if;
	loop

	   fetch attachments_cursor into l_datatype_id, l_media_id;
	   exit when attachments_cursor%NOTFOUND;



	    if (l_datatype_id = 1) then
	      select short_text into l_text from fnd_documents_short_text
	      where media_id = l_media_id;


		if (l_attachments_text is null) then

		l_attachments_text := l_attachments_text ||'<PRE>'||  l_text ||'</PRE>'||NL;

		else

		l_attachments_text := l_attachments_text || '<BR>' || NL;
                l_attachments_text := l_attachments_text ||'<PRE>'||  l_text ||'</PRE>'|| NL;

		end if;

	    elsif  (l_datatype_id = 2) then

	        select long_text into l_long_text from fnd_documents_long_text
	        where media_id = l_media_id;

		if (l_attachments_text is null) then

      	        l_attachments_text := l_attachments_text || '<BR>' || NL;
		-- removed nowrap

		l_attachments_text := l_attachments_text ||'<PRE>'|| l_long_text ||'</PRE>'|| NL;

		else

		l_attachments_text := l_attachments_text || '<BR>' || NL;
		l_attachments_text := l_attachments_text ||'<PRE>'|| l_long_text ||'</PRE>'|| NL;

		end if;
	  else
	  	null;

	    end if;

	end loop;

	close attachments_cursor;

        --<Bug 2817117 mbhargav START>
	-- Getting the header level text information and displaying it if it exists
        -- for the blanket to which this release is sourced
	if (l_document_type = 'RELEASE') THEN
	  select po_header_id into l_po_header_id from po_releases
	    where po_release_id = l_document_id;

	  open attachments_cursor('PO_HEADERS', l_po_header_id);

          loop

	   fetch attachments_cursor into l_datatype_id, l_media_id;
	   exit when attachments_cursor%NOTFOUND;



	    if (l_datatype_id = 1) then
	      select short_text into l_text from fnd_documents_short_text
	      where media_id = l_media_id;


		if (l_attachments_text is null) then

		l_attachments_text := l_attachments_text ||'<PRE>'||  l_text ||'</PRE>'||NL;

		else

		l_attachments_text := l_attachments_text || '<BR>' || NL;
                l_attachments_text := l_attachments_text ||'<PRE>'||  l_text ||'</PRE>'|| NL;

		end if;

	    elsif  (l_datatype_id = 2) then

	        select long_text into l_long_text from fnd_documents_long_text
	        where media_id = l_media_id;

		if (l_attachments_text is null) then

      	        l_attachments_text := l_attachments_text || '<BR>' || NL;
		-- removed nowrap

		l_attachments_text := l_attachments_text ||'<PRE>'|| l_long_text ||'</PRE>'|| NL;

		else

		l_attachments_text := l_attachments_text || '<BR>' || NL;
		l_attachments_text := l_attachments_text ||'<PRE>'|| l_long_text ||'</PRE>'|| NL;

		end if;
	  else
	  	null;

	    end if;

	end loop;

	close attachments_cursor;
      end if; --its a Release
      --<Bug 2817117 mbhargav END>


	if (l_header_note_to_vendor is not null) then
	   l_attachments_text	:= l_header_note_to_vendor || '<BR>' || l_attachments_text || NL;
	end if;

	if (l_attachments_text is not null) then
	   l_document	:= l_document || '<TR><TD colspan=9><font color=black>' || l_attachments_text || '</font></TD></TR>' || NL;
	end if;


    	loop


		l_un_number	:= null;
		l_hazard_class	:= null;
		l_text		:= null;
		l_datatype_id	:= null;
		l_media_id	:= null;

	      l_vendor_quote_num := null;
		l_po_quote_num	   := null;




		IF (l_document_type = 'PO') THEN

			fetch shipment_cursor into l_line_loc;
			exit when shipment_cursor%notfound;

		ELSIF (l_document_type = 'RELEASE') THEN
			fetch shipment_release_cursor into l_line_loc;
			exit when shipment_release_cursor%notfound;

		ELSIF (l_document_type = 'PA') THEN
                      if x_pb_count <> 0 then
			fetch shipment_blanket_cursor into l_line_loc;
			  exit when shipment_blanket_cursor%notfound;
                      else
                          fetch blanket_line_cursor into l_line_loc;
			  exit when blanket_line_cursor%notfound;
                      end if;

		ELSE
			null;

		END IF;


		begin
			/*
			EMAILPO FPH
			should not print region1, 2 and 3
			for US address only region2 code should be printed ignoring 1 and 3
			for non US addresses region1 i.e. County or region3 i.e. province should be printed
			for region1 or region3 the meaning should be printed instead of code from fnd_lookup_values
			Also country should be spelled out instead of code
			*/
                        /* Bug 2766736. Changed ftv.nls_territory to ftv.territory_short_name in
                           the select statement */

                    -- Bug 3574886: Query from base tables in case the session context is not set correctly
                    -- when this SQL is executed; fetch translated columns from hr_locations_all_tl
		    select distinct
                           hlt.location_code,
                           hlt.description,
                           hrl.address_line_1,
		           hrl.address_line_2,
                           hrl.address_line_3,
                         --hrl.town_or_city, --bug#5870952 commented to fetch tow_or_city from fnd_lookup_values
			   Decode(hrl.town_or_city,flv4.lookup_code,flv4.meaning,hrl.town_or_city),
                           hrl.postal_code,
                           ftv.territory_short_name,
			   nvl(decode(hrl.region_1, null,
                                      hrl.region_2, decode(flv1.meaning,null,
                                                           decode(flv2.meaning, null, flv3.meaning, flv2.lookup_code),
                                                           flv1.lookup_code)),
   			       hrl.region_2)
		    into  l_hrl_location,
                          l_hrl_description,
		          l_hrl_address_line_1,
                          l_hrl_address_line_2,
		          l_hrl_address_line_3,
                          l_hrl_town_or_city,
		          l_hrl_postal_code,
                          l_hrl_country,
                          l_hrl_to_region1
		    from  hr_locations_all hrl,
                          hr_locations_all_tl hlt,
                          fnd_territories_vl ftv,
                          fnd_lookup_values_vl flv1,
			  fnd_lookup_values_vl flv2,
                          fnd_lookup_values_vl flv3,
			  fnd_lookup_values_vl flv4
		    where hrl.region_1 = flv1.lookup_code (+)
                    and   hrl.country || '_PROVINCE' = flv1.lookup_type (+)
                    and   hrl.location_id = hlt.location_id and hlt.language = USERENV('LANG')
	            and   hrl.region_2 = flv2.lookup_code (+)
                    and   hrl.country || '_STATE' = flv2.lookup_type (+)
		    and   hrl.region_1 = flv3.lookup_code (+)
                    and   hrl.country || '_COUNTY' = flv3.lookup_type (+)
		    and   hrl.country = ftv.territory_code (+)
                    and   hrl.location_id = l_line_loc.ship_to_location_id
 		    AND   hrl.town_or_city = flv4.lookup_code(+)
 	            AND   hrl.country || '_PROVINCE'  = flv4.lookup_type (+);

                  /* Bug 2646120. The country code is not a mandatory one in hr_locations. So the country code
                     may be null. Changed the join with ftv to outer join.  */
                  /*  Bug 2791859 fnd_lookup_values_vl should be used instead of fnd_lookup_values */

		exception
		    when no_data_found then

                     BEGIN
                     --Bug 9437371 Commented the following
                     /* select description, address1,
                    address2, address3, city, postal_code,
                    country
                    into  l_hrl_description,
                    l_hrl_address_line_1, l_hrl_address_line_2,
                    l_hrl_address_line_3, l_hrl_town_or_city,
                    l_hrl_postal_code, l_hrl_country
                    from hz_locations
                    where location_id = l_line_loc.ship_to_location_id;*/

                     --Bug 9437371 Added following sql to get state info in email notification
                    	   SELECT
   			     HLC.DESCRIPTION,
   			     HLC.ADDRESS1,
   			     HLC.ADDRESS2,
   			     HLC.ADDRESS3,
   			     HLC.CITY,
   			     HLC.POSTAL_CODE,
   			     HLC.COUNTRY,
   			     NVL(DECODE(HLC.county, NULL, HLC.state,
   			     DECODE(FCL1.MEANING, NULL,
   			     DECODE(FCL2.MEANING, NULL,FCL3.MEANING, FCL2.LOOKUP_CODE),
   			     FCL1.LOOKUP_CODE)), HLC.state)
   		   INTO
   			   l_hrl_description,
   			   l_hrl_address_line_1,
   			   l_hrl_address_line_2,
   			   l_hrl_address_line_3,
   			   l_hrl_town_or_city,
   			   l_hrl_postal_code,
   			   l_hrl_country,
   			   l_hrl_to_region1
   		    FROM
   			   HZ_LOCATIONS 	    HLC,
   			   FND_LOOKUP_VALUES	    FCL1,
   			   FND_LOOKUP_VALUES	    FCL2,
   			   FND_LOOKUP_VALUES	    FCL3
   		    WHERE
   			HLC.LOCATION_ID  = l_line_loc.ship_to_location_id AND
   			HLC.county = FCL1.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_PROVINCE' = FCL1.LOOKUP_TYPE (+) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.SECURITY_GROUP_ID) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL1.LOOKUP_TYPE,
   			FCL1.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.VIEW_APPLICATION_ID) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.LANGUAGE) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
   			HLC.state = FCL2.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_STATE' = FCL2.LOOKUP_TYPE (+) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.SECURITY_GROUP_ID) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL2.LOOKUP_TYPE,
   			FCL2.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.VIEW_APPLICATION_ID) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.LANGUAGE) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', USERENV('LANG'))	AND
   			HLC.county = FCL3.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_COUNTY' = FCL3.LOOKUP_TYPE (+) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.SECURITY_GROUP_ID) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL3.LOOKUP_TYPE,
   			FCL3.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.VIEW_APPLICATION_ID) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.LANGUAGE) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', USERENV('LANG')) ;



                    exception
                      when no_data_found then

                         null;

                    end;
		end;

                -- Bug 3637864. Need to display both promised and needby date
                                                    /*Modified as part of bug 7551115 changing date format*/
		l_promised_date := to_char(l_line_loc.promised_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)  , 'GREGORIAN' ) || '''');
                l_needby_date := to_char(l_line_loc.need_by_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                         'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) , 'GREGORIAN' ) || '''');

		if (l_line_loc.un_number_id is not null) then
		  begin
		    select un_number into l_un_number from po_un_numbers pun
		    where pun.un_number_id = l_line_loc.un_number_id;
		    /*  l_un_number := fnd_message.get_string('PO', 'PO_WF_NOTIF_UN_NUMBER') || ' ' || l_un_number;  */
                    /*  Bug 2774206  */
		  exception
		      when no_data_found then
			null;
		  end;
		end if;

		if (l_line_loc.hazard_class_id is not null) then
		   begin
		    select hazard_class into l_hazard_class
		    from po_hazard_classes phc
		    where phc.hazard_class_id = l_line_loc.hazard_class_id;
			-- bug fix 2436110  -- display label is handled when html is built - search for 2436110
		    --l_hazard_class := fnd_message.get_string('PO', 'PO_WF_NOTIF_HAZARD_CLASS') || ' ' || l_hazard_class;
		   exception
			when no_data_found then
			   null;
		   end;
		end if;



      		l_document := l_document || '<TR>' || NL;

		IF (l_line_loc.line_Num <> l_prev_line_po_line_num) THEN
		    l_po_line_only	:= 'Y';
		    l_prev_line_po_line_num := l_line_loc.line_Num;
		ELSE
		    l_po_line_only 	:= 'N';

		END IF;






	     IF (l_po_line_only = 'Y') THEN
		-- modification here : added shipmentnum instead
      		l_document := l_document || '<TD nowrap align=center><font color=black>' || nvl(to_char(l_line_loc.line_Num), '&nbsp') || '</font></TD>' || NL;
		shipmentNum := shipmentNum + 1;


		/* Bug 2780755.
		 * Colspan used to be 8 before FPI time phased pricing project.
		 * But we need to show the effective start and end dates only when
		 * document type is PA. Hence make colspan 9 for PA and changed it to 7
		 * for other document types.
		*/
		IF ((l_document_type = 'PA') and (x_subtype = 'BLANKET')) THEN
			l_document :=  l_document || '<TD colspan=9><font color=black>' || NL;
		else
			l_document :=  l_document || '<TD colspan=7><font color=black>' || NL;
		end if;
		if (l_line_loc.vendor_product_num is not null) then
		     l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SUPPLIER_ITEM') || ' ' || l_line_loc.vendor_product_num || '<BR wrap>' || NL;
		end if;

		/*
		Fix for bug 2473707 by davidng
		Added item revision to display in the notification next to item part number
		*/
		if (l_line_loc.item_revision is not null) then
		     l_document := l_document ||  nvl(l_line_loc.item_num, '&nbsp') || ' ' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REVISION') ||': ' || l_line_loc.item_revision || NL;
		else
		     l_document := l_document ||  nvl(l_line_loc.item_num, '&nbsp') || NL;
		end if;
		/* End fix for 2473707 */

		begin
			l_mtl_system_items_desc := NULL;
			select allow_item_desc_update_flag into l_allow_item_desc_update
            from mtl_system_items_vl
            where inventory_item_id = l_line_loc.item_id
			and organization_id = l_org_id;

			if (l_allow_item_desc_update = 'N') then
				select description into l_mtl_system_items_desc
                from mtl_system_items_vl
                where inventory_item_id = l_line_loc.item_id
			    and organization_id = l_org_id;
			end if;
		exception
			when others then
				null;
		end;

      		l_document := l_document ||  '<BR wrap>'  || nvl(l_mtl_system_items_desc, l_line_loc.item_desc)  || NL;
		open item_notes_cursor(l_line_loc.org_id, l_line_loc.item_id);
		loop

			fetch item_notes_cursor into l_datatype_id, l_media_id;
			exit when item_notes_cursor%NOTFOUND;

                        -- Bug 3129802. Should use PRE tag as the text is pre formatted

			if (l_datatype_id = 1) then
	      		   select short_text into l_item_short_text from fnd_documents_short_text
	      		   where media_id = l_media_id;
			   l_document := l_document || '<PRE>' || l_item_short_text ||'</PRE>'|| NL;
			elsif (l_datatype_id = 2) then
			   select long_text into l_item_long_text from fnd_documents_long_text
			   where media_id = l_media_id;
			   l_document := l_document || '<PRE>' || l_item_long_text ||'</PRE>'|| NL;
			else
			   null;
			end if;



		end loop;
		close item_notes_cursor;

		-- UN Number
		if (l_un_number is not null) then
                      /*  Bug 2774206  */
		     /*  l_document := l_document || '<BR wrap>' || l_un_number || NL;  */
                     l_document := l_document || '<BR wrap>' ||fnd_message.get_string('PO', 'PO_WF_NOTIF_UN_NUMBER')
                                   || ' ' || l_un_number;
		end if;

		-- hazard class
		if (l_hazard_class is not null) then
			 --Bug fix 2436110
		     --l_document := l_document || '<BR wrap>' || l_hazard_class || NL;
		     l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_HAZARD_CLASS') || ' ' || l_hazard_class || NL;
		end if;



		-- note to vendor
		if (l_line_loc.note_to_vendor is not null) then
		     l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE_TO_VENDOR') || ' ' || l_line_loc.note_to_vendor || NL;
		end if;


		open attachments_cursor('PO_LINES', l_line_loc.po_line_id);
		loop

	   	fetch attachments_cursor into l_datatype_id, l_media_id;
	   	exit when attachments_cursor%NOTFOUND;


	    	if (l_datatype_id = 1) then
	      	   select short_text into l_text from fnd_documents_short_text
	      	   where media_id = l_media_id;

		   l_document := l_document || '<BR wrap>' ||
                                 fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                 '<PRE>'|| l_text ||'</PRE>'|| NL;

		elsif (l_datatype_id = 2) then
		    select long_text into l_long_text from fnd_documents_long_text
	      	    where media_id = l_media_id;

		    l_document := l_document || '<BR wrap>' ||
                                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                  '<PRE>'|| l_long_text ||'</PRE>'|| NL;

		else
		    null;

		end if;

		end loop;

		close attachments_cursor;

              --<Bug 2817117 mbhargav START>
              --If the document is a PO, check if it refers to any
              --Global Agreement. If it does then email also the attachments from
              --that document
              if (l_document_type = 'PO' and l_line_loc.from_header_id is NOT NULL and
                     l_line_loc.from_line_id is NOT NULL)
              then
                begin
                 select nvl(global_agreement_flag, 'N') into l_global_flag
                 from po_headers_all where po_header_id = l_line_loc.from_header_id;
                exception
                  when NO_DATA_FOUND then
                     l_global_flag := 'N';
                end;

                 if l_global_flag = 'Y' then
                   --<Bug 2872552 mbhargav>
                   --Use attachments_from_ga_cursor instead of attachments_cursor
		   open attachments_from_ga_cursor('PO_HEADERS', l_line_loc.from_header_id);
		   loop

        	    	fetch attachments_from_ga_cursor into l_datatype_id, l_media_id;
	        	exit when attachments_from_ga_cursor%NOTFOUND;


	    	     if (l_datatype_id = 1) then
	      	        select short_text into l_text from fnd_documents_short_text
	      	        where media_id = l_media_id;

		        l_document := l_document || '<BR wrap>' ||
                                 fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                 '<PRE>'|| l_text ||'</PRE>'|| NL;

		     elsif (l_datatype_id = 2) then
		         select long_text into l_long_text from fnd_documents_long_text
	      	         where media_id = l_media_id;

		         l_document := l_document || '<BR wrap>' ||
                                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                  '<PRE>'|| l_long_text ||'</PRE>'|| NL;

  		       else
		         null;
		       end if;

   	              end loop;

	              close attachments_from_ga_cursor;

                   --<Bug 2872552 mbhargav>
                   --Use attachments_from_ga_cursor instead of attachments_cursor
		    open attachments_from_ga_cursor('PO_LINES', l_line_loc.from_line_id);
		    loop

        	   	fetch attachments_from_ga_cursor into l_datatype_id, l_media_id;
	        	exit when attachments_from_ga_cursor%NOTFOUND;


	    	      if (l_datatype_id = 1) then
	      	         select short_text into l_text from fnd_documents_short_text
	      	         where media_id = l_media_id;

		         l_document := l_document || '<BR wrap>' ||
                                 fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                 '<PRE>'|| l_text ||'</PRE>'|| NL;

		      elsif (l_datatype_id = 2) then
		          select long_text into l_long_text from fnd_documents_long_text
	      	          where media_id = l_media_id;

		          l_document := l_document || '<BR wrap>' ||
                                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                  '<PRE>'|| l_long_text ||'</PRE>'|| NL;

		       else
		           null;

		       end if;

		      end loop;

		     close attachments_from_ga_cursor;
                 end if; --its global agreement reference

               END IF; --doc is PO and from_header_id, from_line_id are not NULL
               --<Bug 2817117 mbhargav END>

		if ( l_line_loc.contract_num is not null) then
		   l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_CONTRACT_PO') || ' ' || l_line_loc.contract_num || NL;
		end if;


		begin
		if (l_document_type in ('PO', 'PA')) then

		select vendor_quote_num into l_vendor_quote_num
		from po_lines_print
		where po_line_id = l_line_loc.po_line_id
		and po_header_id = l_document_id;

		elsif (l_document_type = 'RELEASE') then
		select vendor_quote_num into l_vendor_quote_num
		from po_lines_print
		where po_line_id = l_line_loc.po_line_id
		and po_release_id = l_document_id;

		else
		  null;

		end if;

		exception
		   when too_many_rows then
			null;
		   when no_data_found then
			null;
		end;


		begin

		if (l_document_type in ('PO', 'PA')) then

		   select po_quote_num, src_ga_flag
                   into l_po_quote_num, l_src_ga_flag
		   from po_lines_print
		   where po_line_id = l_line_loc.po_line_id
		   and po_header_id = l_document_id;

		elsif (l_document_type = 'RELEASE') then

		   select po_quote_num into l_po_quote_num
		   from po_lines_print
		   where po_line_id = l_line_loc.po_line_id
		   and po_release_id = l_document_id;
		else

		   null;

		end if;

		exception
		   when too_many_rows then
			null;
		   when no_data_found then
			null;
		end;


		if (l_po_quote_num is not null) then
                   /* GA FPI Start - Change the ref document prompt depending on whether it is GA or Quote */
                   if l_src_ga_flag = 'Y' then

		      l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_GA_REF') || ' '
                                                                                          || l_po_quote_num || NL;
                   /* GA FPI End */
                   else
                       l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_QUOTE') || ' '
                                                                                          || l_po_quote_num || NL;
                   end if;
		end if;

                if (l_vendor_quote_num is not null) then
		   l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_VENDOR_QUOTE') || ' '
                                                                                          || l_vendor_quote_num || NL;
		end if;


		 l_document := l_document || '</font></TD></TR>' || NL;

	    	-- SHIPMENTS OF FIRST PO LINE
		l_document := l_document || '<TR><TD></TD><TD WIDTH=30% valign=top><font color=black>';

		-- Display the address only if they are distinct
		if (l_ship_to_count > 1) then
		  l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SMALL') ||  NL;
      /* Bug 9437371*/
           IF(l_line_loc.drop_ship_flag = 'Y') THEN -- Check for dropship flag If details present then display the same
                l_drop_ship:= PO_COMMUNICATION_PVT.get_drop_ship_details(l_line_loc.line_location_id);
                l_ship_cust_name := PO_COMMUNICATION_PVT.getShipCustName();
                l_ship_cont_name := PO_COMMUNICATION_PVT.getShipContName();
                l_document := l_document  || '<BR wrap>' || l_ship_cust_name  || NL;
                l_document := l_document  || '<BR wrap>' || l_ship_cont_name  || NL;
           END IF;
      /* Bug 9437371*/
		  l_document := l_document || '<BR wrap>' || l_hrl_description || NL;
		  l_document := l_document || '<BR wrap>' || l_hrl_address_line_1 || NL;
		  if (l_hrl_address_line_2 is not null) then
		     l_document := l_document || '<BR wrap>' || l_hrl_address_line_2 || NL;
		  end if;

		  if (l_hrl_address_line_3 is not null) then
		     l_document := l_document || '<BR wrap>' || l_hrl_address_line_3 || NL;
		  end if;

		if (l_hrl_town_or_city is not null) then
		  l_document := l_document || '<BR wrap>' || l_hrl_town_or_city || ', ' || NL;
		end if;

		if (l_hrl_to_region1 is not null) then
		  l_document := l_document || ' ' || l_hrl_to_region1 || NL;
		end if;


		/* EMAILPO FPH
		region1 will print either state code or  county or province appropriately
		No need to print all three
		if (l_hrl_to_region2 is not null) then
			l_document := l_document || ' ' || l_hrl_to_region2 || NL;
		end if;
		if (l_hrl_to_region3 is not null) then
			l_document := l_document || ' ' || l_hrl_to_region3 || NL;
		end if;
		*/


		if (l_hrl_postal_code is not null) then
		  l_document := l_document || ' ' || l_hrl_postal_code || NL;
		end if;

		  l_document := l_document || ' ' || l_hrl_country || NL;
		else
		  l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SMALL') ||  NL;
       /* Bug 9437371*/
           IF(l_line_loc.drop_ship_flag = 'Y') THEN -- Check for dropship flag If details present then display the same
                 l_drop_ship:= PO_COMMUNICATION_PVT.get_drop_ship_details(l_line_loc.line_location_id);
                l_ship_cust_name := PO_COMMUNICATION_PVT.getShipCustName();
                l_ship_cont_name := PO_COMMUNICATION_PVT.getShipContName();
                l_document := l_document  || '<BR wrap>' || l_ship_cust_name  || NL;
                l_document := l_document  || '<BR wrap>' || l_ship_cont_name  || NL;
           END IF;
      /* Bug 9437371*/
		  l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SEE_ABOVE') ||  NL;
		end if;

                /* < SUP_CON FPI > */
                /* Bug 2766996
                 * Concatenate '<BR wrap>' after l_document
                 * if consigned shipment
                 */
                IF (l_line_loc.consigned_flag = 'Y') THEN
                    l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO',  'PO_WF_NOTIF_CONSIGNED_SHIPMENT') ||  NL;
                END IF;
                /* < SUP_CON FPI > */

		-- Shipment Level Note
		open attachments_cursor('PO_SHIPMENTS', l_line_loc.line_location_id);
		loop

	   	fetch attachments_cursor into l_datatype_id, l_media_id;
	   	exit when attachments_cursor%NOTFOUND;


	    	if (l_datatype_id = 1) then
	      	   select short_text into l_text from fnd_documents_short_text
	      	   where media_id = l_media_id;

		   l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPMENT_NOTE') || ' ' ||  l_text || NL;

		elsif (l_datatype_id = 2) then
		    select long_text into l_long_text from fnd_documents_long_text
	      	    where media_id = l_media_id;

		    l_document := l_document ||  '<BR wrap>' || '&nbsp' || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPMENT_NOTE') || ' ' ||  l_long_text || NL;

		else
		    null;

		end if;

		end loop;

		close attachments_cursor;


		-- PO has been cancelled
		if (l_line_loc.cancel_flag = 'Y') then
                                                        /*Modified as part of bug 7551115 changing date format*/
		    l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_CANCELLED_ON') || ' ' ||
                                                                                to_char(l_line_loc.cancel_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                            'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) , 'GREGORIAN'  ) || '''')|| NL;
		    l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_QTY_ORDERED') || ' ' || l_line_loc.quantity || NL;
		    l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_QTY_CANCELLED') || ' ' || l_line_loc.quantity_cancelled || NL;
		end if;


		-- Deliver to person
		l_requestor_count := 0;
                l_multiple_flag := 'N';
		open requestor_cursor(l_line_loc.line_location_id);
		loop
		fetch requestor_cursor into l_requestor_id;
		exit when requestor_cursor%NOTFOUND;
		l_requestor_count := l_requestor_count + 1;
		if (l_requestor_count > 1) then
                        l_multiple_flag := 'Y';
			l_requestor_id := 0;
			exit;
		end if;
		end loop;
		close requestor_cursor;

               if (l_requestor_id <> 0) then
                begin

                select full_name,work_telephone,email_address
                  into l_requestor_name,l_phone,l_email_address
                  from per_all_people_f
                  where person_id = l_requestor_id
                  and effective_start_date <= sysdate
                  and effective_end_date >= sysdate;

                 exception
                      when others then
                        l_requestor_name := null;
                        l_phone := null;
                        l_email_address := null;
                 end;
              end if;

         if (l_requestor_name is not null) then
		   l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQUESTER_DELIVER') || ' : ' ||   NL;
                   l_document := l_document || '<BR wrap>' || l_requestor_name || NL;
               if (l_phone is not null) then
                   l_document := l_document || '<BR wrap>' || l_phone || NL;
               end if;
               if (l_email_address is not null) then
                   l_document := l_document || '<BR wrap>' || l_email_address || NL;
               end if;
         else
            if (l_multiple_flag = 'N') then
                null;
            else
                l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQUESTER_DELIVER') || ' : ' ||   NL;
                l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_MULTIPLE_REQUESTOR')  ||   NL;
           end if;
       	end if;

          /* dreddy - After printing the requestor name we need to null it out
             because for the next record in the loop it will print even if the
             requestor id is null */
            l_requestor_name := null;

		l_document := l_document ||'</font></TD>' || NL;

		-- <Bug 3637864 Start> Need to display both Promised and Need By Dates
                l_document := l_document || '<TD nowrap valign=top><font color=black>';
		IF l_promised_date IS NOT null THEN
                   l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PROMISED_DATE') || '<BR>';
                   l_document := l_document || l_promised_date;
                   IF l_needby_date IS NOT null THEN
                      l_document := l_document || '<BR>';
                   END IF;
                END IF;
		IF l_needby_date IS NOT null THEN
                   l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEEDBY_DATE') || '<BR>';
                   l_document := l_document || l_needby_date;
                ELSIF l_promised_date IS NULL THEN
                   l_document := l_document || '&nbsp';
                END IF;
		l_document := l_document || '</font></TD>' || NL;
                -- <Bug 3637864 End>

                /* <TIMEPHASED FPI START> */
                   /*
                   Display the Effective Date and Expires On fields on to the
                   HTML notification. This is for the first shipment.
                   */
		/* Bug 2687751.
		 * l_line_loc.start_date and l_line_loc.end_date had
		 * to be converted into varchar variables and then concatenated
		 * with l_document. Not doing so resulted an ORA-01858 error.
		*/
		/* Bug 2780755.
		 * Effective start and end dates have to be shown only when
		 * the document type is PA.
		*/
                                                     /*Modified as part of bug 7551115 changing date format*/
		IF ((l_document_type = 'PA') and (x_subtype = 'BLANKET')) THEN
			l_start_date := to_char(l_line_loc.start_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                      'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) , 'GREGORIAN'  ) || '''');
			l_end_date := to_char(l_line_loc.end_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                    'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)  , 'GREGORIAN'  ) || '''');
			l_document := l_document || '<TD nowrap><font color=black>' || nvl(l_start_date, '&nbsp') || '</font></TD>' || NL;
			l_document := l_document || '<TD nowrap><font color=black>' || nvl(l_end_date, '&nbsp') || '</font></TD>' || NL;
		end if;

                /* <TIMEPHASED FPI END> */

/* Bug# 2493568 */
		l_document := l_document || '<TD nowrap align=right><font color=black>' || nvl(to_char(l_line_loc.quantity - nvl(l_line_loc.quantity_cancelled, 0)), '&nbsp') || '</font></TD>' || NL;

      		l_document := l_document || '<TD nowrap><font color=black>' || nvl(l_line_loc.uom, '&nbsp') || '</font></TD>' || NL;
/*

		l_document := l_document || '<TD nowrap><font color=black>' || nvl(to_char(l_line_loc.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), '&nbsp') || '</font></TD>'|| NL;
*/
              l_document := l_document || '<TD nowrap><font color=black>' ||
'(' || l_currency_code || ')' || l_line_loc.unit_price || '</font></TD>' ||
NL;
                l_document := l_document || '<TD nowrap><font color=black>' || nvl(l_line_loc.taxable_flag, '&nbsp') || '</font></TD>' || NL;

/* Bug# 2493568 */
		l_extension := (l_line_loc.quantity - nvl(l_line_loc.quantity_cancelled, 0)) * l_line_loc.unit_price;
		if (l_document_type = 'PA') then
			-- bug fix 2257742
			if l_min_unit is null then
				l_extension_total := round(nvl(l_blanket_total_amount,0), l_precision);
			else
				l_extension_total := round(nvl(l_blanket_total_amount,0)/l_min_unit) * l_min_unit;
			end if;
		else
			-- bug fix 2257742
			if l_min_unit is null then
				l_extension := round(nvl(l_extension,0), l_precision);
            else
            	l_extension := round(nvl(l_extension,0)/l_min_unit) * l_min_unit;
            end if;
            l_extension_total := l_extension_total + l_extension;
		end if;

		-- don't display the extension if this is a blanket
		if (l_document_type <> 'PA') then


                l_document := l_document || '<TD nowrap><font color=black>' || '(' || l_currency_code || ')' ||
                nvl(to_char(l_extension, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), '&nbsp') --bug 3405085
                || '</font></TD>' || NL;
		else

		l_document := l_document || '<TD nowrap> &nbsp </TD>'|| NL;
		end if;



      		l_document := l_document || '</TR>' || NL;


	    -- Shipments of the other PO lines
	    ELSIF (l_po_line_only = 'N') THEN

                -- Deliver to person
                l_requestor_count := 0;
                l_multiple_flag := 'N';
                open requestor_cursor(l_line_loc.line_location_id);
                loop
                fetch requestor_cursor into l_requestor_id;
                exit when requestor_cursor%NOTFOUND;
                l_requestor_count := l_requestor_count + 1;
                if (l_requestor_count > 1) then
                        l_multiple_flag := 'Y';
                        l_requestor_id := 0;
                        exit;
                end if;
                end loop;
                close requestor_cursor;

              if (l_requestor_id <> 0) then
              begin
                select full_name,work_telephone,email_address
                  into l_requestor_name,l_phone,l_email_address
                  from per_all_people_f
                  where person_id = l_requestor_id
                     and effective_start_date <= sysdate
                     and effective_end_date >= sysdate;
               exception
                 when others then
                      l_requestor_name := null;
                      l_phone := null;
                      l_email_address := null;
               end;
              end if;


		l_document := l_document || '<TD></TD><TD valign=top><font color=black>';

		-- Display the address only if they are distinct
		if (l_ship_to_count > 1) then
		  l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SMALL') ||  NL;

       /* Bug 9437371*/
           IF(l_line_loc.drop_ship_flag = 'Y') THEN -- Check for dropship flag If details present then display the same
                 l_drop_ship:= PO_COMMUNICATION_PVT.get_drop_ship_details(l_line_loc.line_location_id);
                l_ship_cust_name := PO_COMMUNICATION_PVT.getShipCustName();
                l_ship_cont_name := PO_COMMUNICATION_PVT.getShipContName();
                l_document := l_document  || '<BR wrap>' || l_ship_cust_name  || NL;
                l_document := l_document  || '<BR wrap>' || l_ship_cont_name  || NL;
           END IF;
      /* Bug 9437371*/


		  if (l_hrl_description is not null) then
		  l_document := l_document || '<BR wrap>' || l_hrl_description || NL;
		  end if;

		  if (l_hrl_address_line_1 is not null) then
		  l_document := l_document || '<BR wrap>' || l_hrl_address_line_1 || NL;
		  end if;

		  if (l_hrl_address_line_2 is not null) then
		     l_document := l_document || '<BR wrap>' || l_hrl_address_line_2|| NL;
		  end if;

		  if (l_hrl_address_line_3 is not null) then
		     l_document := l_document || '<BR wrap>' || l_hrl_address_line_3|| NL;
		  end if;


		if (l_hrl_town_or_city is not null) then
		  l_document := l_document || '<BR wrap>' || l_hrl_town_or_city || ', ' || NL;
		end if;

		if (l_hrl_to_region1 is not null) then
		  l_document := l_document || ' ' || l_hrl_to_region1 || NL;
		end if;

		/*
        EMAILPO FPH
        region1 will print either state code or  county or province appropriately No need to print all three
		if (l_hrl_to_region2 is not null) then
			l_document := l_document || ' ' || l_hrl_to_region2 || NL;
		end if;
		if (l_hrl_to_region3 is not null) then
			l_document := l_document || ' ' || l_hrl_to_region3 || NL;
		end if;
		*/


		if (l_hrl_postal_code is not null) then
		  l_document := l_document || ' ' || l_hrl_postal_code || NL;
		end if;



		  l_document := l_document || ' ' || l_hrl_country || NL ;
		else

		-- more than one shipment
		  l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SMALL') ||  NL;
      /* Bug 9437371*/
           IF(l_line_loc.drop_ship_flag = 'Y') THEN -- Check for dropship flag If details present then display the same
                l_drop_ship:= PO_COMMUNICATION_PVT.get_drop_ship_details(l_line_loc.line_location_id);
                l_ship_cust_name := PO_COMMUNICATION_PVT.getShipCustName();
                l_ship_cont_name := PO_COMMUNICATION_PVT.getShipContName();
                l_document := l_document  || '<BR wrap>' || l_ship_cust_name  || NL;
                l_document := l_document  || '<BR wrap>' || l_ship_cont_name  || NL;
           END IF;
      /* Bug 9437371*/
		  l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SEE_ABOVE') ||  NL;

--		  l_document := l_document || '</font></TD>' || NL;
		end if;

/* Bug# 2557069: kagarwal
** Desc: Modified the code to display attachments for all the shipments
*/

                -- Shipment Level Note
                open attachments_cursor('PO_SHIPMENTS', l_line_loc.line_location_id);
                loop

                fetch attachments_cursor into l_datatype_id, l_media_id;
                exit when attachments_cursor%NOTFOUND;

                if (l_datatype_id = 1) then
                   select short_text into l_text from fnd_documents_short_text
                   where media_id = l_media_id;

                   l_document := l_document || '<BR wrap>' ||
                                 fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPMENT_NOTE') ||
                                 ' ' ||  l_text || NL;

                elsif (l_datatype_id = 2) then
                    select long_text into l_long_text from fnd_documents_long_text
                    where media_id = l_media_id;

                    l_document := l_document ||  '<BR wrap>' || '&nbsp' ||
                                  fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPMENT_NOTE') ||
                                  ' ' ||  l_long_text || NL;

                else
                    null;

                end if;

                end loop;

            close attachments_cursor;

            if (l_requestor_name is not null) then
               l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQUESTER_DELIVER') || ' : ' ||   NL;
               l_document := l_document || '<BR wrap>' || l_requestor_name || NL;
               if (l_phone is not null) then
                   l_document := l_document || '<BR wrap>' || l_phone || NL;
               end if;
               if (l_email_address is not null) then
                   l_document := l_document || '<BR wrap>' || l_email_address || NL;
               end if;

             else
              if (l_multiple_flag = 'N') then
                 null;
              else
                l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQUESTER_DELIVER') || ' : ' ||   NL;
                l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_MULTIPLE_REQUESTOR') ||   NL;
              end if;
             end if;

                l_requestor_name := null;

                l_document := l_document || '</font></TD>' || NL;

		-- <Bug 3637864 Start> Need to display both Promised and Need By Dates
                l_document := l_document || '<TD nowrap valign=top><font color=black>';
		IF l_promised_date IS NOT null THEN
                   l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PROMISED_DATE') || '<BR>';
                   l_document := l_document || l_promised_date;
                   IF l_needby_date IS NOT null THEN
                      l_document := l_document || '<BR>';
                   END IF;
                END IF;
		IF l_needby_date IS NOT null THEN
                   l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NEEDBY_DATE') || '<BR>';
                   l_document := l_document || l_needby_date;
                ELSIF l_promised_date IS NULL THEN
                   l_document := l_document || '&nbsp';
                END IF;
		l_document := l_document || '</font></TD>' || NL;
                -- <Bug 3637864 End>

                /* <TIMEPHASED FPI START> */
                   /*
                   Display the Effective Date and Expires On fields on to the
                   HTML notification. This is for subsequent shipments.
                   */
		/* Bug 2687751.
		 * l_line_loc.start_date and l_line_loc.end_date had
		 * to be converted into varchar variables and then concatenated
		 * with l_document. Not doing so resulted an ORA-01858 error.
		*/
		/* Bug 2780755.
		 * Effective start and end dates have to be shown only when
		 * the document type is PA.
		*/
                                                    /*Modified as part of bug 7551115 changing date format*/
		IF ((l_document_type = 'PA') and (x_subtype = 'BLANKET')) THEN
			l_start_date := to_char(l_line_loc.start_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                                  'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)  , 'GREGORIAN'  ) || '''');
			l_end_date := to_char(l_line_loc.end_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                                                  'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)  , 'GREGORIAN'  ) || '''');
			l_document := l_document || '<TD nowrap><font color=black>' || nvl(l_start_date, '&nbsp') || '</font></TD>' || NL;
			l_document := l_document || '<TD nowrap><font color=black>' || nvl(l_end_date, '&nbsp') || '</font></TD>' || NL;
		end if;
                /* <TIMEPHASED FPI END> */

/* Bug# 2493568 */
		l_document := l_document || '<TD nowrap align=right><font color=black>' || nvl(to_char(l_line_loc.quantity - nvl(l_line_loc.quantity_cancelled, 0)), '&nbsp') || '</font></TD>' || NL;

      		l_document := l_document || '<TD nowrap><font color=black>' || nvl(l_line_loc.uom, '&nbsp') || '</font></TD>' || NL;
/*

		l_document := l_document || '<TD nowrap><font color=black>' || nvl(to_char(l_line_loc.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), '&nbsp') || '</font></TD>'|| NL;

*/
              l_document := l_document || '<TD nowrap><font color=black>' ||
'(' || l_currency_code || ')' || l_line_loc.unit_price ||
'</font></TD>' || NL;
                l_document := l_document || '<TD nowrap><font color=black>' || nvl(l_line_loc.taxable_flag, '&nbsp') || '</font></TD>' || NL;

/* Bug# 2493568 */
		l_extension := (l_line_loc.quantity - nvl(l_line_loc.quantity_cancelled, 0)) * l_line_loc.unit_price;


        if (l_document_type = 'PA') then
            -- bug fix 2257742
            if l_min_unit is null then
                l_extension_total := round(nvl(l_blanket_total_amount,0), l_precision);
            else
                l_extension_total := round(nvl(l_blanket_total_amount,0)/l_min_unit) * l_min_unit;
            end if;
        else
            -- bug fix 2257742
            if l_min_unit is null then
                l_extension := round(nvl(l_extension,0), l_precision);
            else
                l_extension := round(nvl(l_extension,0)/l_min_unit) * l_min_unit;
            end if;
            l_extension_total := l_extension_total + l_extension;
        end if;


		-- don't display the extension if this is a blanket
		if (l_document_type <> 'PA') then


                l_document := l_document || '<TD nowrap><font color=black>' ||
'(' || l_currency_code || ')' ||
                nvl(to_char(l_extension, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), '&nbsp') --bug 3405085
                || '</font></TD>' || NL;
		else

		l_document := l_document || '<TD nowrap> &nbsp </TD>'|| NL;
		end if;



      		l_document := l_document || '</TR>' || NL;

	   -- LINES or SHIPMENTS
	   ELSE
		null;

	   END IF;

             /* writing the email body into a clob variable */
             WF_NOTIFICATION.WriteToClob(document, l_document);
             l_document := null;

    	end loop;


	IF (l_document_type = 'PO') THEN
    	    close shipment_cursor;
	ELSIF (l_document_type = 'RELEASE') THEN
	    close shipment_release_cursor;
	ELSIF (l_document_type = 'PA') THEN
           if x_pb_count <> 0 then
	     close shipment_blanket_cursor;
           else
            close blanket_line_cursor;
           end if;
	ELSE
		null;
	 END IF;


     if l_document is null then

      if (l_document_type <> 'PA') then
	l_document := l_document || '<TR>' || NL;
	l_document := l_document || '<TD colspan=8 align=right> ' || NL;
	l_document := l_document || '<B>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_TOTAL') || '&nbsp &nbsp </B>' || NL;

        l_document := l_document || '<font color=black>' || '(' || l_currency_code || ')' ||
        nvl(to_char(l_extension_total, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), '&nbsp') --bug 3405085
        ||  NL;
	l_document := l_document || '</font></TD></TR>';
       end if;

	l_document := l_document || '</TABLE></P>' || NL;

        WF_NOTIFICATION.WriteToClob(document, l_document);
     end if;

ELSE


	/* Now generate the text code for the individual rows in the table */
	--<BUG 9891660> Removed fetching org_id from the below sqls
	IF (l_document_type = 'PO') THEN
		select note_to_vendor,currency_code
		into l_header_note_to_vendor ,l_currency_code
		from po_headers
		where po_header_id = to_number(l_document_id);
		open shipment_cursor(l_document_id);
	ELSIF (l_document_type = 'RELEASE') THEN
		select note_to_vendor
		into l_header_note_to_vendor
		from po_releases where po_release_id = to_number(l_document_id);
		open shipment_release_cursor(l_document_id);
        ELSIF  (l_document_type = 'PA') THEN
               select note_to_vendor,currency_code
		into l_header_note_to_vendor ,l_currency_code
		from po_headers
		where po_header_id = to_number(l_document_id);
		open shipment_blanket_cursor(l_document_id);
	END IF;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_header_note_to_vendor= ' || l_header_note_to_vendor);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_currency_code= ' || l_currency_code);
	END IF;
	--<BUG 9891660 END>

--	l_currency_code := PO_CORE_S2.get_base_currency;

-- Getting the header level text information and displaying it if it exists
	if (l_document_type = 'PO') then
		open attachments_cursor('PO_HEADERS', l_document_id);
	elsif (l_document_type = 'RELEASE') then
		open attachments_cursor('PO_RELEASES', l_document_id);
	else
		null;
	end if;
	loop

	   fetch attachments_cursor into l_datatype_id, l_media_id;
	   exit when attachments_cursor%NOTFOUND;


	    if (l_datatype_id = 1) then
	      select short_text into l_text from fnd_documents_short_text
	      where media_id = l_media_id;

		if (length(l_attachments_text) = 0) then

      	 l_attachments_text :=  l_attachments_text || NL;
		l_attachments_text := l_attachments_text ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_HEADER_NOTE') || ' ' ||  l_text || NL;

		else

		l_attachments_text := l_attachments_text || NL;
		l_attachments_text := l_attachments_text ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_HEADER_NOTE') || ' ' ||  l_text || NL;

		end if;

	    elsif  (l_datatype_id = 2) then

	        select long_text into l_long_text from fnd_documents_long_text
	        where media_id = l_media_id;

		if (length(l_attachments_text) = 0) then

		l_attachments_text := l_attachments_text ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_HEADER_NOTE') || ' ' ||  l_long_text || NL;

		else

		l_attachments_text := l_attachments_text ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_HEADER_NOTE') || ' ' ||  l_long_text || NL;

		end if;
	  else
	  	null;

	    end if;


	end loop;

	close attachments_cursor;

        --<Bug 2817117 mbhargav START>
	-- Getting the header level text information and displaying it if it exists
        -- for the blanket to which this release is sourced
	if (l_document_type = 'RELEASE') THEN

          select po_header_id into l_po_header_id from po_releases
	  where po_release_id = l_document_id;

	  open attachments_cursor('PO_HEADERS', l_po_header_id);

         loop

	   fetch attachments_cursor into l_datatype_id, l_media_id;
	   exit when attachments_cursor%NOTFOUND;



	    if (l_datatype_id = 1) then
	      select short_text into l_text from fnd_documents_short_text
	      where media_id = l_media_id;


		if (l_attachments_text is null) then

		l_attachments_text := l_attachments_text ||'<PRE>'||  l_text ||'</PRE>'||NL;

		else

		l_attachments_text := l_attachments_text || '<BR>' || NL;
                l_attachments_text := l_attachments_text ||'<PRE>'||  l_text ||'</PRE>'|| NL;

		end if;

	    elsif  (l_datatype_id = 2) then

	        select long_text into l_long_text from fnd_documents_long_text
	        where media_id = l_media_id;

		if (l_attachments_text is null) then

      	        l_attachments_text := l_attachments_text || '<BR>' || NL;
		-- removed nowrap

		l_attachments_text := l_attachments_text ||'<PRE>'|| l_long_text ||'</PRE>'|| NL;

		else

		l_attachments_text := l_attachments_text || '<BR>' || NL;
		l_attachments_text := l_attachments_text ||'<PRE>'|| l_long_text ||'</PRE>'|| NL;

		end if;
	  else
	  	null;

	    end if;

	end loop;

	close attachments_cursor;
      end if; --its a Release
      --<Bug 2817117 mbhargav END>

	if (length(l_attachments_text) = 0) then
	   l_document	:= l_attachments_text || NL;
	end if;

    	loop


		l_un_number	:= null;
		l_hazard_class	:= null;
		l_text		:= null;
		l_datatype_id	:= null;
		l_media_id	:= null;
		l_po_quote_num	:= null;
		l_vendor_quote_num := null;


		IF (l_document_type = 'PO') THEN
			fetch shipment_cursor into l_line_loc;
			exit when shipment_cursor%notfound;
		ELSIF (l_document_type = 'RELEASE') THEN
			fetch shipment_release_cursor into l_line_loc;
			exit when shipment_release_cursor%notfound;
                ELSIF (l_document_type = 'PA') THEN
                       fetch shipment_release_cursor into l_line_loc;
			exit when shipment_blanket_cursor%notfound;
		END IF;
                                                    /*Modified as part of bug 7551115 changing date format*/
		l_date := to_char(nvl(l_line_loc.need_by_date, l_line_loc.promised_date),FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)  , 'GREGORIAN'  ) || '''');

		if (l_line_loc.un_number_id is not null) then
		    select un_number into l_un_number from po_un_numbers pun
		    where pun.un_number_id = l_line_loc.un_number_id;
                    /*  Bug 2774206   */
		    /*  l_un_number := fnd_message.get_string('PO', 'PO_WF_NOTIF_UN_NUMBER') || ' ' || l_un_number;  */
		end if;

		if (l_line_loc.hazard_class_id is not null) then
		    select hazard_class into l_hazard_class
		    from po_hazard_classes phc
		    where phc.hazard_class_id = l_line_loc.hazard_class_id;
		    l_hazard_class := fnd_message.get_string('PO', 'PO_WF_NOTIF_HAZARD_CLASS') || ' ' || l_hazard_class;
		end if;

      		l_document := l_document || NL;

		-- modification here : added shipmentnum instead
           l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NUMBER') || ' ' ;
           l_document := l_document || nvl(to_char(l_line_loc.line_Num), ' ') ||  NL;
		shipmentNum := shipmentNum + 1;


            l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_PART_NO_DESC') || ':  ' || NL;

            if (l_line_loc.vendor_product_num is not null) then
		     l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_SUPPLIER_ITEM') || ' ' || l_line_loc.vendor_product_num || NL;
		 end if;

		/* Fix for bug 2473707 by davidng */
		if (l_line_loc.item_revision is not null) then
		     l_document := l_document ||  nvl(l_line_loc.item_num, ' ') || ' ' || l_line_loc.item_revision || ' , ';
		else
		     l_document := l_document ||  nvl(l_line_loc.item_num, ' ') || ' , ';
		end if;
		/* End fix for 2473707 */

      	l_document := l_document ||   l_line_loc.item_desc  || NL;

            -- modifications from Diwas
            open item_notes_cursor(l_line_loc.org_id, l_line_loc.item_id);
		loop

			fetch item_notes_cursor into l_datatype_id, l_media_id;
			exit when item_notes_cursor%NOTFOUND;

                        -- Bug 3129802 Need to add PRE tag as the text is preformatted

			if (l_datatype_id = 1) then
	      		   select short_text into l_item_short_text from fnd_documents_short_text
	      		   where media_id = l_media_id;
			   l_document := l_document ||'<PRE>'|| l_item_short_text ||'</PRE>'|| NL;
			elsif (l_datatype_id = 2) then
			   select long_text into l_item_long_text from fnd_documents_long_text
			   where media_id = l_media_id;
			   l_document := l_document ||'<PRE>'|| l_item_long_text ||'</PRE>'|| NL;
			else
			   null;
			end if;

		end loop;
		close item_notes_cursor;



		-- UN Number
		if (l_un_number is not null) then
   	             /*  Bug 2774206  */
		     /*  l_document := l_document ||  l_un_number || NL;  */
                    l_document := l_document ||fnd_message.get_string('PO', 'PO_WF_NOTIF_UN_NUMBER') || ' ' || l_un_number;
		end if;

		-- hazard class
		if (l_hazard_class is not null) then
		     l_document := l_document || l_hazard_class || NL;
		end if;


		-- PO has been cancelled
		if (l_line_loc.cancel_flag = 'Y') then
                                                        /*Modified as part of bug 7551115 changing date format*/
		    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_CANCELLED_ON') || ' ' ||
                                                                               to_char(l_line_loc.cancel_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                                                                            'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)   , 'GREGORIAN'  ) || '''') || NL;
		    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QTY_ORDERED') || ' '  || l_line_loc.quantity || NL;
		    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QTY_CANCELLED') || ' ' || l_line_loc.quantity_cancelled || NL;
		end if;


		-- note to vendor
		if (l_line_loc.note_to_vendor is not null) then
		     l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_NOTE_TO_VENDOR') || ' ' || l_line_loc.note_to_vendor || NL;
		end if;

		-- note to vendor
		if (l_text is not null) then
		     l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||  l_text || NL;
		end if;

            -- modifications from Diwas
           	open attachments_cursor('PO_LINES', l_line_loc.po_line_id);
		loop

	   	fetch attachments_cursor into l_datatype_id, l_media_id;
	   	exit when attachments_cursor%NOTFOUND;


	    	if (l_datatype_id = 1) then
	      	   select short_text into l_text from fnd_documents_short_text
	      	   where media_id = l_media_id;

		   l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||  l_text || NL;

		elsif (l_datatype_id = 2) then
		    select long_text into l_long_text from fnd_documents_long_text
	      	    where media_id = l_media_id;

		    l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||  l_text || NL;

		else
		    null;

		end if;

		end loop;

		close attachments_cursor;

       --<Bug 2817117 mbhargav START>
        if (l_document_type = 'PO' and l_line_loc.from_header_id is NOT NULL and
                     l_line_loc.from_line_id is NOT NULL)
        then
              begin
                select nvl(global_agreement_flag, 'N') into l_global_flag
                 from po_headers_all where po_header_id = l_line_loc.from_header_id;
              exception
                when NO_DATA_FOUND then
                    l_global_flag := 'N';
              end;

             if l_global_flag = 'Y' then
                --<Bug 2872552 mbhargav>
                --Use attachments_from_ga_cursor instead of attachments_cursor
		open attachments_from_ga_cursor('PO_HEADERS', l_line_loc.from_header_id);
		loop

        	   	fetch attachments_from_ga_cursor into l_datatype_id, l_media_id;
	        	exit when attachments_from_ga_cursor%NOTFOUND;


	    	if (l_datatype_id = 1) then
	      	   select short_text into l_text from fnd_documents_short_text
	      	   where media_id = l_media_id;

		   l_document := l_document || '<BR wrap>' ||
                                 fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                 '<PRE>'|| l_text ||'</PRE>'|| NL;

		elsif (l_datatype_id = 2) then
		    select long_text into l_long_text from fnd_documents_long_text
	      	    where media_id = l_media_id;

		    l_document := l_document || '<BR wrap>' ||
                                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                  '<PRE>'|| l_long_text ||'</PRE>'|| NL;

		else
		    null;

		end if;

		end loop;

		close attachments_from_ga_cursor;

                --<Bug 2872552 mbhargav>
                --Use attachments_from_ga_cursor instead of attachments_cursor
		open attachments_from_ga_cursor('PO_LINES', l_line_loc.from_line_id);
		loop

        	   	fetch attachments_from_ga_cursor into l_datatype_id, l_media_id;
	        	exit when attachments_from_ga_cursor%NOTFOUND;


	    	if (l_datatype_id = 1) then
	      	   select short_text into l_text from fnd_documents_short_text
	      	   where media_id = l_media_id;

		   l_document := l_document || '<BR wrap>' ||
                                 fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                 '<PRE>'|| l_text ||'</PRE>'|| NL;

		elsif (l_datatype_id = 2) then
		    select long_text into l_long_text from fnd_documents_long_text
	      	    where media_id = l_media_id;

		    l_document := l_document || '<BR wrap>' ||
                                  fnd_message.get_string('PO', 'PO_WF_NOTIF_LINE_NOTE') || ' ' ||
                                  '<PRE>'|| l_long_text ||'</PRE>'|| NL;

		else
		    null;

		end if;

		end loop;

		close attachments_from_ga_cursor;
         end if; --reference a GA
      END IF; --doc is PO
      --<Bug 2817117 mbhargav END>


            -- modifications from Diwas
            if ( l_line_loc.contract_num is not null) then
		   l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_CONTRACT_PO') || ' ' || l_line_loc.contract_num || NL;
		end if;


		select vendor_quote_num into l_vendor_quote_num
		from po_lines_print
		where po_line_id = l_line_loc.po_line_id;

		if (l_vendor_quote_num is not null) then
		   l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_VENDOR_QUOTE') || ' ' || l_vendor_quote_num || NL;
		end if;


		select po_quote_num into l_po_quote_num
		from po_lines_print
		where po_line_id = l_line_loc.po_line_id;

		if (l_po_quote_num is not null) then
		   l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PO_QUOTE') || ' ' || l_po_quote_num || NL;
		end if;





		-- Display the address only if they are distinct
		if (l_ship_to_count > 1) then
		  l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SMALL') || ': ' || NL;
       /* Bug 9437371*/
           IF(l_line_loc.drop_ship_flag = 'Y') THEN -- Check for dropship flag If details present then display the same
                l_drop_ship:= PO_COMMUNICATION_PVT.get_drop_ship_details(l_line_loc.line_location_id);
                l_ship_cust_name := PO_COMMUNICATION_PVT.getShipCustName();
                l_ship_cont_name := PO_COMMUNICATION_PVT.getShipContName();
                l_document := l_document  || '     ' || l_ship_cust_name  || NL;
                l_document := l_document  || '     ' || l_ship_cont_name  || NL;
           END IF;
      /* Bug 9437371*/
		  l_document := l_document || '     ' ||  l_hrl_description || NL;
		  l_document := l_document || '     ' ||  l_hrl_address_line_1 || NL;
		  if (l_hrl_address_line_2 is not null) then
		     l_document := l_document || '     ' ||  l_hrl_address_line_2|| NL;
		  end if;

		  if (l_hrl_address_line_3 is not null) then
		     l_document := l_document || '     ' ||  l_hrl_address_line_3|| NL;
		  end if;

		  l_document := l_document || '     ' || l_hrl_town_or_city || ' ' || l_hrl_postal_code || NL;
		  l_document := l_document || '     ' ||  l_hrl_country || NL ;
		ELSE
    /* Bug 9437371*/
           IF(l_line_loc.drop_ship_flag = 'Y') THEN -- Check for dropship flag If details present then display the same
                l_drop_ship:= PO_COMMUNICATION_PVT.get_drop_ship_details(l_line_loc.line_location_id);
                l_ship_cust_name := PO_COMMUNICATION_PVT.getShipCustName();
                l_ship_cont_name := PO_COMMUNICATION_PVT.getShipContName();
                l_document := l_document  || '     ' || l_ship_cust_name  || NL;
                l_document := l_document  || '     ' || l_ship_cont_name  || NL;
           END IF;
      /* Bug 9437371*/

		  l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SEE_ABOVE') ||  NL;
		end if;

	-- Shipment Level Note
		open attachments_cursor('PO_SHIPMENTS', l_line_loc.line_location_id);
		loop

	   	fetch attachments_cursor into l_datatype_id, l_media_id;
	   	exit when attachments_cursor%NOTFOUND;


	    	if (l_datatype_id = 1) then
	      	   select short_text into l_text from fnd_documents_short_text
	      	   where media_id = l_media_id;

		   l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPMENT_NOTE') || ' ' ||  l_text || NL;

		elsif (l_datatype_id = 2) then
		    select long_text into l_long_text from fnd_documents_long_text
	      	    where media_id = l_media_id;

		    l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIPMENT_NOTE') || ' ' ||  l_text || NL;

		else
		    null;

		end if;

		end loop;

		close attachments_cursor;


		-- Deliver to person

		l_requestor_count := 0;
                l_multiple_flag := 'N';
		open requestor_cursor(l_line_loc.line_location_id);
		loop
		fetch requestor_cursor into l_requestor_id;
		exit when requestor_cursor%NOTFOUND;
		l_requestor_count := l_requestor_count + 1;
		if (l_requestor_count > 1) then
                        l_multiple_flag := 'Y';
			l_requestor_id := 0;
			exit;
		end if;
		end loop;
		close requestor_cursor;

              if (l_requestor_id <> 0) then
               begin
                  select full_name,work_telephone,email_address
                  into l_requestor_name,l_phone,l_email_address
                  from per_all_people_f
                  where person_id = l_requestor_id
                  and effective_start_date <= sysdate
                  and effective_end_date >= sysdate;
                exception
                   when others then
                       l_requestor_name := null;
                        l_phone := null;
                        l_email_address := null;
                end;

               end if;
		if (l_requestor_name is not null) then

		   l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_REQUESTER_DELIVER') || ' : ' ||  l_requestor_name || NL;
                   l_document := l_document || '<BR wrap>' || l_phone || NL;
                   l_document := l_document || '<BR wrap>' || l_email_address || NL;
                else
                 if (l_multiple_flag = 'N') then
                     null;
                 else
                  l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REQUESTER_DELIVER') || ' : ' ||   NL;
                l_document := l_document || '<BR wrap>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_MULTIPLE_REQUESTOR')  ||   NL;
                 end if;
 		end if;

                l_requestor_name := null;

            l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DELIVERY_DATE') || ':  ';
		l_document := l_document ||  nvl(l_date, ' ') || ', ';

/* Bug# 2493568 */
            l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_QUANTITY') || ':  ';
		l_document := l_document || nvl(to_char(l_line_loc.quantity - nvl(l_line_loc.quantity_cancelled, 0)), ' ') || ', ';

            l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UOM') || ':  ';
     		l_document := l_document || nvl(l_line_loc.uom, ' ') || ' , ';

            l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_UNIT_PRICE') || ':   ';
/*
		l_document := l_document ||  nvl(to_char(l_line_loc.unit_price, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), ' ') ||  ', ';
*/
          l_document := l_document || '(' || l_currency_code || ')' ||
l_line_loc.unit_price || ' , ' ;
              l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_TAX') || ':  ';
                l_document := l_document || nvl(l_line_loc.taxable_flag, ' ') ||  NL;

/* Bug# 2493568 */
		l_extension := (l_line_loc.quantity - nvl(l_line_loc.quantity_cancelled, 0)) * l_line_loc.unit_price;
                if (l_document_type = 'PA') then
                   l_extension_total := l_blanket_total_amount;
                else
		   l_extension_total := l_extension_total + l_extension;
                end if;

            l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_EXTENSION') ||  ':  ';
/*
		l_document := l_document || nvl(to_char(l_extension, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), ' ') ||  ' , ';
*/
            l_document := l_document || '(' || l_currency_code || ')' ||
            nvl(to_char(l_extension, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), '&nbsp') --bug 3405085
            || ' , ';



            -- modifications awaited from Diwas
            -- l_document := l_document || 'Shipment-level attachment' || NL;

      		l_document := l_document ||  NL;

                WF_NOTIFICATION.WriteToClob(document, l_document);
                l_document := null;
    	end loop;

      IF (l_document_type = 'PO') THEN
    	    close shipment_cursor;
	ELSIF (l_document_type = 'RELEASE') THEN
	    close shipment_release_cursor;
	ELSIF (l_document_type = 'PA') THEN
	    close shipment_blanket_cursor;
	ELSE
		null;
       END IF;

      if l_document is null then
	l_document := l_document || NL;
	l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_TOTAL') || ':  ';
        l_document := l_document || '(' || l_currency_code || ')' ||
        nvl(to_char(l_extension_total, FND_CURRENCY.GET_FORMAT_MASK(l_currency_code, 30)), '&nbsp') --bug 3405085
        || NL;
	l_document := l_document || NL;
        WF_NOTIFICATION.WriteToClob(document, l_document);
      end if;

END IF;

END IF;

EXCEPTION
   WHEN OTHERS THEN

	WF_NOTIFICATION.WriteToClob(document, 'failed');

   RAISE;

END;


procedure generate_header	(document_id	in	varchar2,
				 display_type	in 	Varchar2,
                                 document	in out	NOCOPY varchar2,
				 document_type	in out NOCOPY  varchar2) IS


NL                 VARCHAR2(1) := fnd_global.newline;

l_document         VARCHAR2(32000) := '';
x_display_type varchar2(60);

l_operating_unit_desc 	HR_LOCATIONS_ALL.DESCRIPTION%TYPE;
l_operating_unit_add1 	HR_LOCATIONS_ALL.address_line_1%TYPE;
l_operating_unit_add2 	HR_LOCATIONS_ALL.address_line_2%TYPE;
l_operating_unit_add3 	HR_LOCATIONS_ALL.address_line_3%TYPE;
l_operating_unit_city	HR_LOCATIONS_ALL.town_or_city%TYPE;
l_operating_unit_postal_code	HR_LOCATIONS_ALL.postal_code%TYPE;
-- EMAILPO FPH START--
/* Bug 2766736. Changed nls_territory to territory_short_name */
l_operating_unit_country FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
l_operating_unit_state	FND_LOOKUP_VALUES.MEANING%TYPE;
l_operating_unit_region2	FND_LOOKUP_VALUES.MEANING%TYPE;
l_operating_unit_region3	FND_LOOKUP_VALUES.MEANING%TYPE;
-- EMAILPO FPH END--
l_operating_unit_id 	NUMBER;


l_ship_to_desc	 	HR_LOCATIONS_ALL.DESCRIPTION%TYPE;
l_ship_to_add1	 	HR_LOCATIONS_ALL.address_line_1%TYPE;
l_ship_to_add2	 	HR_LOCATIONS_ALL.address_line_2%TYPE;
l_ship_to_add3	 	HR_LOCATIONS_ALL.address_line_3%TYPE;
l_ship_to_city		HR_LOCATIONS_ALL.town_or_city%TYPE;
l_ship_to_postal_code	HR_LOCATIONS_ALL.postal_code%TYPE;
-- EMAILPO FPH START--
/* Bug 2766736. Changed nls_territory to territory_short_name */
l_ship_to_country       FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
l_ship_to_region1	FND_LOOKUP_VALUES.MEANING%TYPE;
l_ship_to_region2	FND_LOOKUP_VALUES.MEANING%TYPE;
l_ship_to_region3	FND_LOOKUP_VALUES.MEANING%TYPE;
-- EMAILPO FPH END--

l_vendor_desc		PO_VENDORS.VENDOR_NAME%TYPE;
l_vendor_add1		PO_VENDOR_SITES.ADDRESS_LINE1%TYPE;
l_vendor_add2		PO_VENDOR_SITES.ADDRESS_LINE2%TYPE;
l_vendor_add3		PO_VENDOR_SITES.ADDRESS_LINE3%TYPE;
l_vendor_city		PO_VENDOR_SITES.CITY%TYPE;
l_vendor_state		PO_VENDOR_SITES.STATE%TYPE;
l_vendor_zip		PO_VENDOR_SITES.ZIP%TYPE;
/* Bug 2766736. Changed nls_territory to territory_short_name */
l_vendor_country        FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
l_vendor_site_id	NUMBER;

l_vendor_id 		NUMBER;

l_bill_to_desc		hr_locations_all.description%TYPE;
l_bill_to_add1		hr_locations_all.address_line_1%TYPE;
l_bill_to_add2		hr_locations_all.address_line_2%TYPE;
l_bill_to_add3		hr_locations_all.address_line_3%TYPE;
l_bill_to_city		hr_locations_all.town_or_city%TYPE;
l_bill_to_postal_code	HR_LOCATIONS_ALL.postal_code%TYPE;
/* Bug 2766736. Changed hr_locations_all.country to
   fnd_territories_vl.territory_short_name */
l_bill_to_country       fnd_territories_vl.territory_short_name%TYPE;
l_bill_to_region1	hr_locations_all.region_1%TYPE;
l_bill_to_region2	hr_locations_all.region_2%TYPE;
l_bill_to_region3	hr_locations_all.region_3%TYPE;
l_bill_to_id		NUMBER;

l_po_number		PO_HEADERS_ALL.SEGMENT1%TYPE;
l_po_revision		NUMBER;
l_release_num		PO_RELEASES_ALL.RELEASE_NUM%TYPE;

l_date_of_order		VARCHAR2(80);
l_buyer		        per_all_people_f.full_name%TYPE;  --bug 15957689
l_date_of_revision	VARCHAR2(80);
l_revision_buyer	per_all_people_f.full_name%TYPE;  --bug 15957689

l_ship_via_lookup_code	PO_HEADERS_ALL.ship_via_lookup_code%TYPE;
l_ship_via_lookup_desc	ORG_FREIGHT_TL.FREIGHT_CODE_TL%TYPE;
l_fob_lookup_code	PO_HEADERS_ALL.FOB_LOOKUP_CODE%TYPE;
l_fob_lookup_desc   PO_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
l_freight_terms_lc	PO_HEADERS_ALL.FREIGHT_TERMS_LOOKUP_CODE%TYPE;
l_freight_terms_dsp PO_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
l_payment_terms_id	NUMBER;
l_payment_terms		ap_terms_val_v.name%TYPE;
l_customer_acct_num	PO_VENDOR_SITES.CUSTOMER_NUM%TYPE;

l_org_id     NUMBER; --<BUG 9891660>

l_vendor_contact_id	NUMBER;
--EMAILPO FPH--
l_vendor_contact_name varchar2(200) := '';
l_vendor_phone		VARCHAR2(100);
l_vendor_num		PO_VENDORS.SEGMENT1%TYPE;

l_dummy_count		NUMBER := 0;
l_ship_to_string	VARCHAR2(500) := '';
l_ship_to_count		NUMBER := 0;
l_dummy_count_persons	NUMBER := 0;
l_vendor_contacts_count	NUMBER := 0;

l_document_id		VARCHAR2(30) := '';
l_document_type		VARCHAR2(30) := '';

l_po_header_id 		NUMBER;
l_release_id		NUMBER;
l_location_id		NUMBER;

l_persons_count		NUMBER;
l_deliver_to_id		NUMBER;
l_deliver_to_person	per_people_f.full_name%TYPE;
l_phone                 varchar2(20);
l_email_address         varchar2(80);
l_legal_entity_id          NUMBER;

/** <UTF8 FPI> **/
/** tpoon 9/27/2002 **/
/** Changed x_ship_to_organization_name to use %TYPE **/
-- l_company_name          varchar2(60);
l_company_name          hr_all_organization_units.name%TYPE;
l_start_date            varchar2(80);
l_requestor_count       NUMBER := 0;
l_multiple_flag         varchar2(1);

 l_end_date             varchar2(80);
l_blanket_amt_agreed    NUMBER := 0;
x_subtype po_headers.type_lookup_code%TYPE;

cursor po_requestor_cursor (v_po_header_id varchar2) IS
select distinct deliver_to_person_id
FROM    po_distributions
WHERE    po_header_id = v_po_header_id
  AND    distribution_type <> 'AGREEMENT'; -- <Encumbrance FPJ>

cursor release_requestor_cursor (v_po_release_id varchar2) IS
select distinct deliver_to_person_id
FROM    po_distributions
WHERE    po_release_id = v_po_release_id;


cursor release_location_id_cursor (v_po_release_id varchar2) IS
select distinct PLL.ship_to_location_id
FROM po_lines_all   pol,   -- <R12.MOAC>  --po_lines   pol,
po_line_locations pll
where  PLL.PO_RELEASE_ID = to_number(v_po_release_id)
and    PLL.po_line_id    = POL.po_line_id;

/* Bug# 2684059: kagarwal
** Desc: Introduced cursor pa_location_count_cursor to count the
** distinct ship_to_location_id in PRICE BREAKS, if exists, for a Blanket PA.
**
** Introduced cursor pa_header_location_id_cursor to get the
** ship_to_location_id from the PO Header table.
**
** Introduced cursor pa_location_id_cursor to get the distinct
** ship_to_location_id from the Blanket PA PRICE BREAKS.
*/

cursor pa_location_count_cursor (v_po_header_id varchar2) IS
select nvl(count(distinct pll.ship_to_location_id), 0)
FROM po_lines_all   pol,   -- <R12.MOAC>
     po_line_locations pll
where  PLL.PO_HEADER_ID = to_number(v_po_header_id)
and    PLL.po_line_id    = POL.po_line_id
and    PLL.shipment_type = 'PRICE BREAK';

cursor pa_header_location_id_cursor (v_po_header_id varchar2) IS
select ship_to_location_id
FROM   po_headers
where  PO_HEADER_ID = to_number(v_po_header_id);

cursor pa_location_id_cursor (v_po_header_id varchar2) IS
select distinct pll.ship_to_location_id
FROM po_lines_all   pol,   -- <R12.MOAC>
     po_line_locations pll
where  PLL.PO_HEADER_ID = to_number(v_po_header_id)
and    PLL.po_line_id    = POL.po_line_id
and    PLL.shipment_type = 'PRICE BREAK';

cursor po_location_id_cursor (v_po_header_id varchar2) IS
select distinct PLL.ship_to_location_id
FROM po_lines_all   pol,   -- <R12 MOAC>
po_line_locations pll
where  PLL.PO_HEADER_ID = to_number(v_po_header_id)
and    PLL.po_line_id    = POL.po_line_id;

cursor vendor_contacts_cursor(v_vendor_contact_id NUMBER) IS
select area_code || phone
from po_vendor_contacts
where vendor_contact_id = v_vendor_contact_id;

l_document_status varchar2(100);
l_price_break_count number := 0;
--<BUG 9891660 START>
l_progress VARCHAR2(100);
l_item_type wf_items.item_type%TYPE;
l_item_key wf_items.item_key%TYPE;
--<BUG 9891660 END>


/*Bug 11659917*/
x_legalentity_info  xle_utilities_grp.LegalEntity_Rec;
x_return_status	VARCHAR2(20) ;
x_msg_count    NUMBER ;
x_msg_data    VARCHAR2(4000) ;
/*Bug 11659917*/


begin

  	--<BUG 9891660 START>
	l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
  	l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);

	l_document_id:=wf_engine.GetItemAttrNumber (itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'DOCUMENT_ID');

        l_document_type:=wf_engine.GetItemAttrText (itemtype => l_item_type,
						    itemkey  => l_item_key,
						    aname    => 'DOCUMENT_TYPE');

	l_org_id := wf_engine.GetItemAttrNumber ( itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'ORG_ID');

        l_progress := 'PO_EMAIL_GENERATE.GENERATE_HEADER';
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_item_type= ' || l_item_type);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_item_key= ' || l_item_key);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_document_id= ' || l_document_id);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_document_type= ' || l_document_type);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_org_id= ' || l_org_id);
	END IF;

	IF l_org_id IS NOT NULL THEN
		--fnd_client_info.set_org_context(to_char(l_org_id));
    PO_MOAC_UTILS_PVT.set_org_context(to_char(l_org_id)) ;
        END IF;
	--<BUG 9891660 END>

        x_display_type := 'text/html';

        --2332866, check if the document is in processing, and
        -- show warning message to the supplier
        if(l_document_type in ('PO', 'PA')) then
          select authorization_status
            into l_document_status
            from po_headers_all
           where po_header_id = l_document_id;

        elsif (l_document_type = 'RELEASE') then

/* Bug# 3046054: kagarwal
** Desc: The org_context is not yet set hence need to use the _all table
*/

          select po_header_id into l_po_header_id from po_releases_all
          where po_release_id = l_document_id;

          select authorization_status
            into l_document_status
            from po_headers_all
           where po_header_id = l_po_header_id;
        end if;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_document_status= ' || l_document_status);
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_po_header_id= ' || l_po_header_id);
	END IF;
	--<BUG 9891660 END>

        if(l_document_status is null or
                l_document_status in ('IN PROCESS', 'INCOMPLETE', 'REQUIRES REAPPROVAL')) then
          document:=fnd_message.get_string('PO', 'PO_WF_NOTIF_DOC_UNAVAILABLE');
          return;
        end if;

         /* setting the org context here inside this procedure because wf mailer does not supply the
           context. */
	/* BUG 9891660
        PO_REQAPPROVAL_INIT1.get_multiorg_context (l_document_type, l_document_id, x_orgid);

        IF x_orgid is NOT NULL THEN

          PO_MOAC_UTILS_PVT.set_org_context(x_orgid) ;       -- <R12.MOAC>

        END IF;*/

	IF (l_document_type in ('PO', 'PA')) THEN

/* Bug# 2684059: kagarwal
** Desc: Get the subtype
*/
        select type_lookup_code
        into x_subtype
        from po_headers
        where po_header_id = l_document_id;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'x_subtype= ' || x_subtype);
	END IF;
	--<BUG 9891660 END>

	begin

	  /* Need the org_id to get the operating unit name later */
	  /* BUG 9891660
	  select org_id into l_operating_unit_id from po_headers_all
	  where po_header_id = l_document_id; */

	  l_po_header_id := l_document_id;

	exception
	  when no_data_found then
		null;
	end;

        l_requestor_count := 0;
        l_multiple_flag := 'N';
        open po_requestor_cursor(l_document_id);
        loop
           fetch po_requestor_cursor into l_deliver_to_id;
           exit when po_requestor_cursor%NOTFOUND;
           l_requestor_count := l_requestor_count + 1;
           if (l_requestor_count > 1) then
               l_multiple_flag := 'Y';
              l_deliver_to_id := 0;
              exit;
           end if;
         end loop;
         close po_requestor_cursor;

         if (l_deliver_to_id <> 0) then
            begin
              select full_name,work_telephone,email_address
                into l_deliver_to_person,l_phone,l_email_address
                from per_all_people_f
                where person_id = l_deliver_to_id
                and effective_start_date <= sysdate
                and effective_end_date >= sysdate;
              exception
                 when others then
                  l_deliver_to_person := null;
                  l_phone := null;
                  l_email_address := null;
              end;
          end if;

	  --<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_deliver_to_person= ' || l_deliver_to_person);
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_phone= ' || l_phone);
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_email_address= ' || l_email_address);
	END IF;
	--<BUG 9891660 END>

/* Bug# 2684059: kagarwal
** Desc: For a Blanket Purchase Agreement, check if the PRICE BREAKS exist.
** If no,then use the ship to location from the header.
** If yes, then use the ship to loction in the PRICE BREAKS.
*/
        IF ((l_document_type = 'PA') and (x_subtype = 'BLANKET')) THEN
           open pa_location_count_cursor(l_document_id);
           loop
             fetch pa_location_count_cursor into l_price_break_count;
             exit when pa_location_count_cursor%NOTFOUND;
           end loop;
           close pa_location_count_cursor;

           if l_price_break_count = 0 then
             /* No price breaks, get the header ship to id */

             open pa_header_location_id_cursor(l_document_id);
             loop
               fetch pa_header_location_id_cursor into l_location_id;
               exit when pa_header_location_id_cursor%NOTFOUND;
               l_ship_to_count := l_ship_to_count + 1;
             end loop;
             close pa_header_location_id_cursor;

           else
             open pa_location_id_cursor(l_document_id);
             loop
               fetch pa_location_id_cursor into l_location_id;
               exit when pa_location_id_cursor%NOTFOUND;
               l_ship_to_count := l_ship_to_count + 1;
             end loop;
             close pa_location_id_cursor;

           end if;

        ELSE
	   open po_location_id_cursor(l_document_id);
	   loop
	     fetch po_location_id_cursor into l_location_id;
	     exit when po_location_id_cursor%NOTFOUND;
	     l_ship_to_count := l_ship_to_count + 1;
	   end loop;
	   close po_location_id_cursor;
        END IF;

	  if (l_ship_to_count = 1) then
	    -- generate the string to display the ship_to_information at header level
		--EMAILPO FPH--
		-- DISPLAY correct region (either code or full name and also full country name instead of country code
	    begin
            /* Bug 2766736. Changed ftv.nls_territory to ftv.territory_short_name in
               the select statement. */

            -- Bug 3574886: Query from base tables in case the session context is not set correctly
            -- when this SQL is executed; fetch translated columns from hr_locations_all_tl
	    select distinct hlt.description,
       		   hrl.address_line_1,
	  	   hrl.address_line_2,
		   hrl.address_line_3,
       		 --hrl.town_or_city, -- bug#15993315 commented to fetch tow_or_city from fnd_lookup_values
		   Decode(hrl.town_or_city,flv4.lookup_code,flv4.meaning,hrl.town_or_city) ,
       		   hrl.postal_code,
                   ftv.territory_short_name,
                   nvl(decode(hrl.region_1, null,
                              hrl.region_2, decode(flv1.meaning,null,
                                                   decode(flv2.meaning,null,flv3.meaning,flv2.lookup_code),
                                                   flv1.lookup_code)),
                       hrl.region_2)
	    into
		  l_ship_to_desc,
		  l_ship_to_add1,
		  l_ship_to_add2,
		  l_ship_to_add3,
		  l_ship_to_city,
		  l_ship_to_postal_code,
		  l_ship_to_country,
		  l_ship_to_region2
  	    FROM  hr_locations_all hrl,
                  hr_locations_all_tl hlt,
                  fnd_territories_vl ftv,
                  fnd_lookup_values_vl flv1,
                  fnd_lookup_values_vl flv2,
		  fnd_lookup_values_vl flv3,
		  fnd_lookup_values_vl flv4
  	    where hrl.region_1 = flv1.lookup_code (+)
            and   hrl.country || '_PROVINCE' = flv1.lookup_type (+)
            and   hrl.location_id = hlt.location_id
            and   hlt.language = USERENV('LANG')
            and   hrl.region_2 = flv2.lookup_code (+)
            and   hrl.country || '_STATE' = flv2.lookup_type (+)
            and   hrl.region_1 = flv3.lookup_code (+)
            and   hrl.country || '_COUNTY' = flv3.lookup_type (+)
            and   hrl.country = ftv.territory_code(+)
            and   HRL.location_id = l_location_id
            AND  hrl.town_or_city = flv4.lookup_code(+)
 	    AND  hrl.country || '_PROVINCE'  = flv4.lookup_type (+);

    /* Bug 2646120. The country code is not a mandatory one in hr_locations. So the country code may be null.
       Changed the join with ftv to outer join. */

	exception
	  when no_data_found then

               BEGIN
               --Bug 9437371 Commented the following sql
               /*   select distinct
                  hrl.description,
                  hrl.address1,
                  hrl.address2,
                  hrl.address3,
                  hrl.city,
                  hrl.postal_code,
                  hrl.country
                 into
                  l_ship_to_desc,
                  l_ship_to_add1,
                  l_ship_to_add2,
                  l_ship_to_add3,
                  l_ship_to_city,
                  l_ship_to_postal_code,
                  l_ship_to_country
                  FROM  hz_locations hrl
                  where  HRL.location_id = l_location_id;*/

                    --Bug 9437371 Added the following sql to get state info
                   SELECT
   			     HLC.DESCRIPTION,
   			     HLC.ADDRESS1,
   			     HLC.ADDRESS2,
   			     HLC.ADDRESS3,
   			     HLC.CITY,
   			     HLC.POSTAL_CODE,
   			     HLC.COUNTRY,
   			     NVL(DECODE(HLC.county, NULL, HLC.state,
   			     DECODE(FCL1.MEANING, NULL,
   			     DECODE(FCL2.MEANING, NULL,FCL3.MEANING, FCL2.LOOKUP_CODE),
   			     FCL1.LOOKUP_CODE)), HLC.state)
   		   INTO
   	                  l_ship_to_desc,
   		          l_ship_to_add1,
   			  l_ship_to_add2,
   	                  l_ship_to_add3,
   		          l_ship_to_city,
   	                  l_ship_to_postal_code,
   		          l_ship_to_country,
     			  l_ship_to_region2
   		    FROM
   			   HZ_LOCATIONS 	    HLC,
   			   FND_LOOKUP_VALUES	    FCL1,
   			   FND_LOOKUP_VALUES	    FCL2,
   			   FND_LOOKUP_VALUES	    FCL3
   		    WHERE
   			HLC.LOCATION_ID  = l_location_id AND
   			HLC.county = FCL1.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_PROVINCE' = FCL1.LOOKUP_TYPE (+) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.SECURITY_GROUP_ID) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL1.LOOKUP_TYPE,
   			FCL1.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.VIEW_APPLICATION_ID) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.LANGUAGE) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
   			HLC.state = FCL2.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_STATE' = FCL2.LOOKUP_TYPE (+) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.SECURITY_GROUP_ID) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL2.LOOKUP_TYPE,
   			FCL2.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.VIEW_APPLICATION_ID) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.LANGUAGE) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', USERENV('LANG'))	AND
   			HLC.county = FCL3.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_COUNTY' = FCL3.LOOKUP_TYPE (+) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.SECURITY_GROUP_ID) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL3.LOOKUP_TYPE,
   			FCL3.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.VIEW_APPLICATION_ID) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.LANGUAGE) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', USERENV('LANG')) ;

                exception
                   when no_data_found then
		       null;
                end;
	end;

     IF (x_display_type = 'text/html') THEN

		  if (l_ship_to_desc is not null) then
	   	    l_ship_to_string :=  l_ship_to_desc || NL;
		  end if;

		  if (l_ship_to_add1 is not null) then
		    l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_add1 || NL;
		  end if;

		  if (l_ship_to_add2 is not null) then
		   l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_add2 || NL;
		  end if;

		  if (l_ship_to_add3 is not null) then
		     l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_add3 || NL;
		  end if;

		  if (l_ship_to_city is not null) then
		  	l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_city || NL;
		  end if;

		  l_ship_to_string :=  l_ship_to_string || ', ' || NL;

                  /* we will only be printing the region2 column which contains the state for
                     US addresses . region1 and region3 contain the county and other info which
                     we will not be printing */
		  if (l_ship_to_region2 is not null) then
		     l_ship_to_string :=  l_ship_to_string || ' ' || l_ship_to_region2 || NL;
		  end if;

		  if (l_ship_to_postal_code is not null) then
		     l_ship_to_string :=  l_ship_to_string || ' ' || l_ship_to_postal_code || NL;
		  end if;

		  l_ship_to_string :=  l_ship_to_string || '<br>' || l_ship_to_country || NL;

       ELSE

            if (l_ship_to_desc is not null) then
	   	    l_ship_to_string :=  l_ship_to_desc || NL;
		  end if;

		  if (l_ship_to_add1 is not null) then
		    l_ship_to_string :=  l_ship_to_string ||  l_ship_to_add1 || NL;
		  end if;

		  if (l_ship_to_add2 is not null) then
		   l_ship_to_string :=  l_ship_to_string || l_ship_to_add2 || NL;
		  end if;

		  if (l_ship_to_add3 is not null) then
		     l_ship_to_string :=  l_ship_to_string ||  l_ship_to_add3 || NL;
		  end if;

		  if (l_ship_to_city is not null) then
		  	l_ship_to_string :=  l_ship_to_string ||  l_ship_to_city ||  NL;
		  end if;

		  if (l_ship_to_region2 is not null) then
		     l_ship_to_string :=  l_ship_to_string || ' ' || l_ship_to_region2 || NL;
		  end if;

		  if (l_ship_to_postal_code is not null) then
		     l_ship_to_string :=  l_ship_to_string || ' ' || l_ship_to_postal_code || NL;
		  end if;

		  l_ship_to_string :=  l_ship_to_string ||  l_ship_to_country || NL;


        END IF;


	  else

	    l_ship_to_string := fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SPECIFIC');

	  end if;

	-- RELEASE
	ELSE

	IF (l_document_type = 'RELEASE') THEN


	  select po_header_id into l_po_header_id from po_releases
	  where po_release_id = l_document_id;

	  /*BUG 9891660
	  select org_id into l_operating_unit_id from po_headers
	  where po_header_id = l_po_header_id; */

        l_requestor_count := 0;
        l_multiple_flag := 'N';
        open release_requestor_cursor(l_document_id);
        loop
           fetch release_requestor_cursor into l_deliver_to_id;
           exit when release_requestor_cursor%NOTFOUND;
           l_requestor_count := l_requestor_count + 1;
           if (l_requestor_count > 1) then
              l_multiple_flag := 'Y';
              l_deliver_to_id := 0;
              exit;
           end if;
         end loop;
         close release_requestor_cursor;

         if (l_deliver_to_id <> 0) then
            begin
              select full_name,work_telephone,email_address
                into l_deliver_to_person,l_phone,l_email_address
                from per_all_people_f
                where person_id = l_deliver_to_id
                and effective_start_date <= sysdate
                and effective_end_date >= sysdate;
              exception
                 when others then
                  l_deliver_to_person := null;
                  l_phone := null;
                  l_email_address := null;
              end;
          end if;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_deliver_to_person= ' || l_deliver_to_person);
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_phone= ' || l_phone);
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_email_address= ' || l_email_address);
	END IF;
	--<BUG 9891660 END>

	open release_location_id_cursor(l_document_id);
	loop
	fetch release_location_id_cursor into l_location_id;
	exit when release_location_id_cursor%NOTFOUND;
	l_ship_to_count := l_ship_to_count + 1;
	end loop;
	close release_location_id_cursor;

	  if (l_ship_to_count = 1) then
	    -- generate the string to display the ship_to_information at header level
	  	-- EMAILPO FPH--
		-- region should be built correctly and the country should not be abbreviated
	   begin
           /* Bug 2766736. Changed ftv.nls_territory to ftv.territory_short_name in
              the select statement. */

           -- Bug 3574886: Query from base tables in case the session context is not set correctly
           -- when this SQL is executed; fetch translated columns from hr_locations_all_tl
	   select distinct hlt.description,
		  hrl.address_line_1,
		  hrl.address_line_2,
		  hrl.address_line_3,
       		  --hrl.town_or_city, -- bug#15993315 commented to fetch town_or_city from fnd_lookup_values
		  Decode(hrl.town_or_city,flv4.lookup_code,flv4.meaning,hrl.town_or_city) ,
       		  hrl.postal_code,
                  ftv.territory_short_name,
                  nvl(decode(hrl.region_1, null,
                             hrl.region_2, decode(flv1.meaning,null,
                                                  decode(flv2.meaning,null,flv3.meaning,flv2.lookup_code),
                                                  flv1.lookup_code)),
                      hrl.region_2)
	    into
		  l_ship_to_desc,
		  l_ship_to_add1,
		  l_ship_to_add2,
		  l_ship_to_add3,
		  l_ship_to_city,
		  l_ship_to_postal_code,
		  l_ship_to_country,
		  l_ship_to_region2
  	    FROM  hr_locations_all hrl,
                  hr_locations_all_tl hlt,
                  fnd_territories_vl ftv,
                  fnd_lookup_values_vl flv1,
                  fnd_lookup_values_vl flv2,
		  fnd_lookup_values_vl flv3,
		  fnd_lookup_values_vl flv4
	    where hrl.region_1 = flv1.lookup_code (+)
            and   hrl.country || '_PROVINCE' = flv1.lookup_type (+)
            and   hrl.location_id = hlt.location_id
            and   hlt.language = USERENV('LANG')
            and   hrl.region_2 = flv2.lookup_code (+)
            and   hrl.country || '_STATE' = flv2.lookup_type (+)
            and   hrl.region_1 = flv3.lookup_code (+)
            and   hrl.country || '_COUNTY' = flv3.lookup_type (+)
            and   hrl.country = ftv.territory_code(+)
            and   hrl.location_id = l_location_id
	    AND  hrl.town_or_city = flv4.lookup_code(+)
 	    AND  hrl.country || '_PROVINCE'  = flv4.lookup_type (+);

       /* Bug 2646120. The country code is not a mandatory one in hr_locations. So the country code may be null.
          Changed the join with ftv to outer join. */

	    exception
	 	when no_data_found then

                  BEGIN
                  --Bug 9437371 Commented the following sql
                   /*select distinct
                  hrl.description,
                  hrl.address1,
                  hrl.address2,
                  hrl.address3,
                  hrl.city,
                  hrl.postal_code,
                  hrl.country
                  into
                  l_ship_to_desc,
                  l_ship_to_add1,
                  l_ship_to_add2,
                  l_ship_to_add3,
                  l_ship_to_city,
                  l_ship_to_postal_code,
                  l_ship_to_country
                   FROM  hz_locations hrl
                  where HRL.location_id = l_location_id;*/
                   --Added the following sql to get state info in email notification

                    SELECT
   			     HLC.DESCRIPTION,
   			     HLC.ADDRESS1,
   			     HLC.ADDRESS2,
   			     HLC.ADDRESS3,
   			     HLC.CITY,
   			     HLC.POSTAL_CODE,
   			     HLC.COUNTRY,
   			     NVL(DECODE(HLC.county, NULL, HLC.state,
   			     DECODE(FCL1.MEANING, NULL,
   			     DECODE(FCL2.MEANING, NULL,FCL3.MEANING, FCL2.LOOKUP_CODE),
   				   FCL1.LOOKUP_CODE)), HLC.state)
   		   INTO
   	   		    l_ship_to_desc,
   			    l_ship_to_add1,
   			    l_ship_to_add2,
   			    l_ship_to_add3,
   			    l_ship_to_city,
   			    l_ship_to_postal_code,
   			    l_ship_to_country,
   			    l_ship_to_region2
   		    FROM
   			   HZ_LOCATIONS 	    HLC,
   			   FND_LOOKUP_VALUES	    FCL1,
   			   FND_LOOKUP_VALUES	    FCL2,
   			   FND_LOOKUP_VALUES	    FCL3
   		    WHERE
   			HLC.LOCATION_ID  = l_location_id AND
   			HLC.county = FCL1.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_PROVINCE' = FCL1.LOOKUP_TYPE (+) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.SECURITY_GROUP_ID) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL1.LOOKUP_TYPE,
   			FCL1.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.VIEW_APPLICATION_ID) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', FCL1.LANGUAGE) =
   			DECODE(FCL1.LOOKUP_CODE, NULL, '1', USERENV('LANG')) AND
   			HLC.state = FCL2.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_STATE' = FCL2.LOOKUP_TYPE (+) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.SECURITY_GROUP_ID) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL2.LOOKUP_TYPE,
   			FCL2.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.VIEW_APPLICATION_ID) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', FCL2.LANGUAGE) =
   			DECODE(FCL2.LOOKUP_CODE, NULL, '1', USERENV('LANG'))	AND
   			HLC.county = FCL3.LOOKUP_CODE (+) AND
   			HLC.COUNTRY || '_COUNTY' = FCL3.LOOKUP_TYPE (+) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.SECURITY_GROUP_ID) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1',
   			FND_GLOBAL.LOOKUP_SECURITY_GROUP(FCL3.LOOKUP_TYPE,
   			FCL3.VIEW_APPLICATION_ID)) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.VIEW_APPLICATION_ID) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', 3) AND
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', FCL3.LANGUAGE) =
   			DECODE(FCL3.LOOKUP_CODE, NULL, '1', USERENV('LANG')) ;

                  exception

                     when no_data_found then
                          null;

                  end;
	    end;

	    IF (x_display_type = 'text/html') THEN

		  if (l_ship_to_desc is not null) then
	   	    l_ship_to_string :=  l_ship_to_desc || NL;
		  end if;

		  if (l_ship_to_add1 is not null) then
		    l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_add1 || NL;
		  end if;

		  if (l_ship_to_add2 is not null) then
		   l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_add2 || NL;
		  end if;

		  if (l_ship_to_add3 is not null) then
		     l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_add3 || NL;
		  end if;

		  if (l_ship_to_city is not null) then
		  	l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_city || NL;
		  end if;

		  l_ship_to_string := l_ship_to_string || ', '  || NL;


		  if (l_ship_to_region2 is not null) then
		     l_ship_to_string :=  l_ship_to_string || ' ' || l_ship_to_region2 || NL;
		  end if;

		  if (l_ship_to_postal_code is not null) then
		     l_ship_to_string :=  l_ship_to_string || ' ' || l_ship_to_postal_code || NL;
		  end if;

		  l_ship_to_string :=  l_ship_to_string || '<BR wrap>' || l_ship_to_country || NL;


        ELSE

            if (l_ship_to_desc is not null) then
	   	    l_ship_to_string :=  l_ship_to_desc || NL;
		  end if;

		  if (l_ship_to_add1 is not null) then
		    l_ship_to_string :=  l_ship_to_string ||  l_ship_to_add1 || NL;
		  end if;

		  if (l_ship_to_add2 is not null) then
		   l_ship_to_string :=  l_ship_to_string || l_ship_to_add2 || NL;
		  end if;

		  if (l_ship_to_add3 is not null) then
		     l_ship_to_string :=  l_ship_to_string ||  l_ship_to_add3 || NL;
		  end if;

		  if (l_ship_to_city is not null) then
		  	l_ship_to_string :=  l_ship_to_string ||  l_ship_to_city ||  NL;
		  end if;

		  l_ship_to_string :=  l_ship_to_string || ', ' || NL;

		  if (l_ship_to_region2 is not null) then
		     l_ship_to_string :=  l_ship_to_string || ' ' || l_ship_to_region2 || NL;
		  end if;

		  if (l_ship_to_postal_code is not null) then
		     l_ship_to_string :=  l_ship_to_string || ' ' || l_ship_to_postal_code || NL;
		  end if;

		  l_ship_to_string :=  l_ship_to_string ||  l_ship_to_country || NL;


          END IF;


	  else

	    l_ship_to_string := fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SPECIFIC');

	  end if;

	 END if; -- type = release

	END IF; -- doc type


	begin
                          /*Modified as part of bug 8911898 */
	 select bill_to_location_id, vendor_site_id, vendor_id, segment1,
                                     revision_num, to_char(creation_date, FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                    'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) , 'GREGORIAN' ) || ''''), to_char(revised_date,
                                    FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                                   'NLS_CALENDAR = ''' ||  NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)  , 'GREGORIAN' ) || ''''),
                                   ship_via_lookup_code, freight_terms_lookup_code, FOB_LOOKUP_CODE,
                             nvl(vendor_contact_id, -99), terms_id, to_char(start_date,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                             'NLS_CALENDAR = ''' ||  NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)  , 'GREGORIAN' ) || '''') , to_char(end_date,
                             FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK', fnd_global.user_id),
                             'NLS_CALENDAR = ''' ||  NVL(FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id)  , 'GREGORIAN' ) || ''''),blanket_total_amount

	into l_bill_to_id, l_vendor_site_id, l_vendor_id,
	l_po_number, l_po_revision, l_date_of_order, l_date_of_revision,
	l_ship_via_lookup_code, l_freight_terms_lc, l_fob_lookup_code, l_vendor_contact_id,
	l_payment_terms_id,l_start_date,l_end_date,l_blanket_amt_agreed
	from po_headers
	where po_header_id = to_number(l_po_header_id);

	po_core_s.get_displayed_value('FREIGHT TERMS', l_freight_terms_lc,l_freight_terms_dsp);

		begin
			select freight_code_tl into l_ship_via_lookup_desc
			from org_freight_vl
			where organization_id = l_org_id --<BUG 9891660>
			and freight_code = l_ship_via_lookup_code;
		exception
			when no_data_found then
				null;
		end;
	exception
	   when no_data_found then
		null;
	end;

	--EMAILPO FPH--
	-- Need to print the Supplier Contact Name
	begin
		select last_name || ',' || first_name into l_vendor_contact_name from
			po_vendor_contacts where vendor_contact_id = l_vendor_contact_id;
	exception
		when others then
			null;
	end;

     /* Bug - 2112524 - Need to Print the displayed field for FOB instead of the code */

        if (l_fob_lookup_code is NOT NULL) then

         begin
           select displayed_field
             into l_fob_lookup_desc
             from po_lookup_codes
             where lookup_type = 'FOB'
              and lookup_code = l_fob_lookup_code;

          exception

           when others then
                null;

          end;
        end if;

	if (l_document_type = 'RELEASE') then
                             /*Modified as part of bug 8911898*/
	   begin
	   select release_num, to_char(revised_date ,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK',fnd_global.user_id),
                                                                             'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN' ) || ''''), revision_num
	   into l_release_num, l_date_of_revision, l_po_revision
	   from po_releases
	   where po_release_id = l_document_id;

	   /* Fix for 2341675 by davidng */
	   select  to_char(release_date ,FND_PROFILE.VALUE_SPECIFIC('ICX_DATE_FORMAT_MASK',fnd_global.user_id),
                                                                              'NLS_CALENDAR = ''' || NVL( FND_PROFILE.VALUE_SPECIFIC('FND_FORMS_USER_CALENDAR', fnd_global.user_id) ,'GREGORIAN') || '''')
      	   into l_date_of_order
	   from po_releases
	   where po_release_id = l_document_id;
	   /* End fix*/

	   exception
		when no_data_found then
		    null;
	   end;

	   l_po_number := l_po_number || '-' || to_char(l_release_num);


	end if;


	begin

        /* Bug - 1774523 - Changed the query to get the legal entity name */
        -- bug 4969659 - removed to_char on organization_id to prevent FTS
        /*select name
        into l_company_name
        from hr_all_organization_units
        where organization_id = (select to_number(org_information2)
                                 from hr_organization_information
                                 where org_information_context = 'Operating Unit Information'
                                 and organization_id = l_org_id); --<BUG 9891660>*/

      /*Bug 11659917 Commenting the above query and using XLE API to get legal entity name*/

     l_legal_entity_id :=  PO_CORE_S.get_default_legal_entity_id(l_org_id);

     XLE_UTILITIES_GRP.Get_LegalEntity_Info(
       		              x_return_status,
         	     	        x_msg_count,
       		              x_msg_data,
               	        null,
               	        l_legal_entity_id,
           	            x_legalentity_info);

        l_company_name := x_legalentity_info.name ;

        --<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'l_company_name= ' || l_company_name);
	END IF;
	--<BUG 9891660 END>
	-- EMAILPO FPH--
	-- retrieve correct region instead of just state and also print country in non abbreviated form
        /* Bug 2766736. Changed ftv.nls_territory to ftv.territory_short_name in
           the select statement. */
	select distinct houv.name, houv.address_line_1, houv.address_line_2, houv.address_line_3,
	houv.town_or_city,
    nvl(decode(houv.region_1,
		null, houv.region_2,
		decode(flv1.meaning,null, decode(flv2.meaning,null,flv3.meaning,flv2.lookup_code),flv1.lookup_code))
		,houv.region_2),
	houv.postal_code, ftv.territory_short_name
	into
	l_operating_unit_desc, l_operating_unit_add1,
	l_operating_unit_add2, l_operating_unit_add3, l_operating_unit_city,
	l_operating_unit_state,l_operating_unit_postal_code, l_operating_unit_country
	from hr_organization_units_v houv, fnd_territories_vl ftv, fnd_lookup_values_vl flv1, fnd_lookup_values_vl flv2,
	fnd_lookup_values_vl flv3
	where
	houv.region_1 = flv1.lookup_code (+) and houv.country || '_PROVINCE' = flv1.lookup_type (+)
	and houv.region_2 = flv2.lookup_code (+) and houv.country || '_STATE' = flv2.lookup_type (+)
	and houv.region_1 = flv3.lookup_code (+) and houv.country || '_COUNTY' = flv3.lookup_type (+)
	and houv.country = ftv.territory_code(+) and organization_id = l_org_id; --<BUG 9891660>

      /* Bug 2646120. The country code is not a mandatory one in hr_locations. So the country code may be null.
         Changed the join with ftv to outer join. */

	exception
	  when others then
	     null;
	end;


        /* Bug 2766736. Changed ftv.nls_territory to ftv.territory_short_name in
           the select statement. */
	begin

        -- Bug 3574886: Query from base tables in case the session context is not set correctly
        -- when this SQL is executed; fetch translated columns from hr_locations_all_tl
	select distinct hlt.description,
               hrl.address_line_1,
               hrl.address_line_2,
               hrl.address_line_3,
	       -- hrl.town_or_city,  --bug#15993315 commented to fetch town_or_city from fnd_lookup_values
	       Decode(hrl.town_or_city,flv4.lookup_code,flv4.meaning,hrl.town_or_city) ,
               ftv.territory_short_name,
               hrl.postal_code,
               nvl(decode(hrl.region_1, null,
                          hrl.region_2, decode(flv1.meaning, null,
                                               decode(flv2.meaning,null,flv3.meaning,flv2.lookup_code),
                                               flv1.lookup_code)),
                   hrl.region_2)
	into   l_bill_to_desc,
               l_bill_to_add1,
               l_bill_to_add2,
               l_bill_to_add3,
               l_bill_to_city,
	       l_bill_to_country,
               l_bill_to_postal_code,
               l_bill_to_region2
	from   hr_locations_all hrl,
               hr_locations_all_tl hlt,
               fnd_territories_vl ftv,
               fnd_lookup_values_vl flv1,
               fnd_lookup_values_vl flv2,
	       fnd_lookup_values_vl flv3,
	       fnd_lookup_values_vl flv4
	where  hrl.region_1 = flv1.lookup_code (+)
        and    hrl.country || '_PROVINCE' = flv1.lookup_type (+)
        and    hrl.location_id = hlt.location_id
        and    hlt.language = USERENV('LANG')
        and    hrl.region_2 = flv2.lookup_code (+)
        and    hrl.country || '_STATE' = flv2.lookup_type (+)
        and    hrl.region_1 = flv3.lookup_code (+)
        and    hrl.country || '_COUNTY' = flv3.lookup_type (+)
	and    hrl.country = ftv.territory_code(+)
        and    hrl.location_id = l_bill_to_id
	AND  hrl.town_or_city = flv4.lookup_code(+)
 	AND  hrl.country || '_PROVINCE'  = flv4.lookup_type (+);

     /* Bug 2646120. The country code is not a mandatory one in hr_locations. So the country code may be null.
        Changed the join with ftv to outer join. */

	exception
	   when no_data_found then
	      null;
	end;

        /* Bug 2766736. Changed ftv.nls_territory to ftv.territory_short_name in
           the select statement. */
	begin
	select pvs.address_line1, pvs.address_line2, pvs.address_line3, pvs.city, nvl(nvl(pvs.state, pvs.county), pvs.province),
	ftv.territory_short_name, zip
	into
	l_vendor_add1, l_vendor_add2, l_vendor_add3, l_vendor_city, l_vendor_state,
	l_vendor_country, l_vendor_zip
	from po_vendor_sites pvs , fnd_territories_vl ftv
	where
	ftv.territory_code(+) = pvs.country  ---Bug 16506490
	and vendor_site_id = l_vendor_site_id;

     /* Bug 2646120. The country code is not a mandatory one in hr_locations. So the country code may be null.
        Changed the join with ftv to outer join. */

	exception
	   when no_data_found then
		null;
	end;

	-- Need to obtain the buyers from po_headers_archive and po_releases_archive
       -- for global buyer's need to get buyer name from per_employees_current_x
	if  (l_document_type in ('PO', 'PA')) THEN
	  -- there will be an entry in this table regardless of whether there is a revision
	  -- or not
	  begin

	  if (l_po_revision = 0) then

	     select full_name into l_buyer
	     from per_all_people_f                   --<R12 CWK Enhancement>
         where person_id = (select agent_id from po_headers
						    where po_header_id = to_number(l_po_header_id))
         and trunc(sysdate) between trunc(effective_start_date) and trunc(effective_end_date); --Bug#5161502

          else
	     select full_name into l_buyer
	     from per_all_people_f                   --<R12 CWK Enhancement>
         where person_id = (select agent_id from po_headers_archive
						where po_header_id = to_number(l_po_header_id) and
						revision_num = 0)
         and trunc(sysdate) between trunc(effective_start_date) and trunc(effective_end_date); --Bug#5161502
	  end if;

	  exception
	     when no_data_found then
		 l_buyer := '';
	  end;


  	  begin
	    if (l_po_revision > 0) then
	        select full_name into l_revision_buyer
	        from per_all_people_f                   --<R12 CWK Enhancement>
            where person_id = (select agent_id from po_headers_archive
						where po_header_id = to_number(l_po_header_id) and
						revision_num = l_po_revision)
                  and trunc(sysdate) between trunc(effective_start_date) and trunc(effective_end_date); --Bug#5161502
	     end if;

	  exception
	     when no_data_found then
		  l_revision_buyer := '';
	  end;

	elsif (l_document_type = 'RELEASE') then

	  -- there will be an entry in this table regardless of whether there is a revision
	  -- or not
	  begin
	  select full_name into l_buyer
	  from per_all_people_f                   --<R12 CWK Enhancement>
      where person_id = (select agent_id from po_releases_archive
						where po_release_id = to_number(l_document_id) and
						revision_num = 0)
	    and trunc(sysdate) between trunc(effective_start_date) and trunc(effective_end_date); --Bug#5161502
	  exception
	     when no_data_found then
		 l_buyer := '';
	  end;


  	  begin
	    if (l_po_revision > 0) then
	        select full_name into l_revision_buyer
	       from per_all_people_f                   --<R12 CWK Enhancement>
            where person_id = (select agent_id from po_releases_archive
						where po_release_id = to_number(l_document_id) and
						revision_num = l_po_revision)
                 and trunc(sysdate) between trunc(effective_start_date) and trunc(effective_end_date); --Bug#5161502
	    else
		null;
	    end if;

	  exception
	     when no_data_found then
		  l_revision_buyer := '';
	     when too_many_rows then
		  l_revision_buyer := '';
	  end;

	else
	    null;
	end if;

	open vendor_contacts_cursor(l_vendor_contact_id);
	l_vendor_contacts_count := 0;
	loop
	    fetch vendor_contacts_cursor
	    into l_vendor_phone;

	    exit when vendor_contacts_cursor%NOTFOUND;
	    l_vendor_contacts_count := l_vendor_contacts_count + 1;

   	    if (l_vendor_contacts_count > 1) then
		l_vendor_phone := '';
	    end if;

	end loop;
	close vendor_contacts_cursor;


	begin
	  select nvl(pvs.customer_num, pov.customer_num) into l_customer_acct_num
	  from po_vendor_sites pvs, po_vendors pov
	  where pvs.vendor_site_id = l_vendor_site_id
	  and   pov.vendor_id	 = l_vendor_id;
	exception
	   when others then
		l_customer_acct_num := '';
	end;
	begin
	  select segment1, vendor_name
	  into l_vendor_num, l_vendor_desc
	  from po_vendors pov
	  where pov.vendor_id = l_vendor_id;
	exception
	  when others then
		l_vendor_num := '';
		l_vendor_desc := '';
	end;

	begin
	  select name into l_payment_terms
	  from ap_terms_val_v apv
	  where apv.TERM_ID = l_payment_terms_id;
	exception
	  when others then
		l_payment_terms := '';
	end;

IF (x_display_type = 'text/html') THEN

l_document := l_document || '<table width=100% border=0 cellpadding=2 cellspacing=1 cols=3 rows=2>' || NL;
l_document := l_document || '<!-- header -->' || NL;
l_document := l_document || '  <tr>' || NL;
l_document := l_document || '  <!-- ORACLE, ship-to, PURCHASE-ORDER -->' || NL;
l_document := l_document || '    <td width=45% valign=top>' || NL;
l_document := l_document || '    <!-- ORACLE -->' || NL;



-- ------------------------------------------------- START: COMPANY NAME / ADDRESS
l_document := l_document || '      <font color=black size=+2>' || NL;
l_document := l_document || '        ' || l_company_name || NL;
l_document := l_document || '      </font><br>' || NL;
/*
l_document := l_document || '  <font color=black>     ' || l_operating_unit_desc || NL;
l_document := l_document || '      </font><br>' || NL;
*/
l_document := l_document || '  <font color=black>    ' || l_operating_unit_add1 || NL;
if (l_operating_unit_add2 is not null) then
l_document := l_document || '  <br>    ' || l_operating_unit_add2 || NL;
end if;
if (l_operating_unit_add3 is not null) then
l_document := l_document || '  <br>    ' || l_operating_unit_add3 || NL;
end if;
if (l_operating_unit_city is not null) then
l_document := l_document || '  <br>    ' || l_operating_unit_city || NL;
end if;
if (l_operating_unit_state is not null) then
l_document := l_document || ', ' || l_operating_unit_state || NL;
end if;
if (l_operating_unit_postal_code is not null) then
l_document := l_document || ' ' || l_operating_unit_postal_code || NL;
end if;
if (l_operating_unit_country is not null) then
l_document := l_document || '  <br>    ' || l_operating_unit_country || NL;
end if;
l_document := l_document || '    </font>  </br>' || NL;
-- ------------------------------------------------- ENDED: COMPANY NAME / ADDRESS

l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td width=25% valign=top>' || NL;
l_document := l_document || '    <!-- ship-to -->' || NL;
l_document := l_document || '      <b><u><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO') || '</font></u></b><br>' || NL;
l_document := l_document || '      <font color=black>' || l_ship_to_string || '<br></font>' || NL;

l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td width=30% valign=top>' || NL;
l_document := l_document || '    <!-- PURCHASE-ORDER -->' || NL;
l_document := l_document || '      <table border=2 rows=2 cols=2>' || NL;
l_document := l_document || '        <tr>' || NL;
l_document := l_document || '          <td colspan=2 align=center valign=top>' || NL;
l_document := l_document || '            <b><font size=+2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PURCHASE_ORDER') || '</font></b><br>' || NL;
l_document := l_document || '          </td>' || NL;
l_document := l_document || '        </tr>' || NL;
l_document := l_document || '        <tr>' || NL;
l_document := l_document || '          <td width=50% align=left valign=top>' || NL;
l_document := l_document || '          <!-- PO number -->' || NL;
l_document := l_document || '            <b><font size=-3>' ||fnd_message.get_string('PO', 'PO_WF_NOTIF_PURCHASE_ORDER_NO') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: PURCHASE ORDER NO.
l_document := l_document || '            <font color=black>' || NL;
l_document := l_document || '               ' || l_po_number || NL;
l_document := l_document || '            <br></font>' || NL;
-- ------------------------------------------------- ENDED: PURCHASE ORDER NO.



l_document := l_document || '            <p>' || NL;
l_document := l_document || '          </td>' || NL;
l_document := l_document || '          <td width=50% align=left valign=top>' || NL;
l_document := l_document || '          <!-- Revision -->' || NL;



-- ------------------------------------------------- START: REVISION
l_document := l_document || '            <b><font size=-3>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_REVISION') || '</font></b><br>' || NL;
l_document := l_document || '            <font color=black>' || NL;
l_document := l_document || '              ' || l_po_revision || NL;
l_document := l_document || '            <br></font>' || NL;
-- ------------------------------------------------- ENDED: REVISION





l_document := l_document || '            <p>' || NL;
l_document := l_document || '          </td>' || NL;
l_document := l_document || '        </tr>' || NL;


l_document := l_document || '      </table><br>' || NL;
l_document := l_document || '      </font>' || NL;
l_document := l_document || '    </td>' || NL;

l_document := l_document || '  </tr>' || NL;
l_document := l_document || '  <tr>' || NL;
l_document := l_document || '  <!-- Vendor, bill-to, dates -->' || NL;
l_document := l_document || '    <td width=45% align=left valign=top>' || NL;
l_document := l_document || '    <!-- Vendor -->' || NL;

/* COMMENTING THIS OUT FOR LEFT ALIGNMENT OF VENDOR INFO, replaced with block below
l_document := l_document || '      <table cols=2>' || NL;
l_document := l_document || '        <tr>' || NL;
l_document := l_document || '          <td width=20% align=left valign=top>' || NL;

l_document := l_document || '            <b><u><font size=-1>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_VENDOR') || '</font></u></b>' || NL;
l_document := l_document || '          </td>' || NL;
l_document := l_document || '          <td width=80% align=left valign=top>' || NL;
*/


-- this line for the case without the vendor info
l_document := l_document || '      <b><u><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_VENDOR') || '</font></u></b>' || NL;

-- ------------------------------------------------- START: VENDOR_ADDR
l_document := l_document || '<font color=black>' || NL;
l_document := l_document || '<br>' || l_vendor_desc || NL;
l_document := l_document || '<br>' || l_vendor_add1 || NL;
if (l_vendor_add2 is not null) then
l_document := l_document || '<br>' || l_vendor_add2 || NL;
end if;
if (l_vendor_add3 is not null) then
l_document := l_document || '<br>' || l_vendor_add3 || NL;
end if;
/* Removed the not null check as we are printing city,state and zip
   on the same line
*/
l_document := l_document || '<br>' || l_vendor_city || ',' ||  l_vendor_state || ' ' || l_vendor_zip || NL;
if (l_vendor_country is not null) then
l_document := l_document || '<br>' || l_vendor_country || NL;
end if;

l_document := l_document || '<br></font>' || NL;

--EMAILPO FPH--
/* Commented off for 2336672 by davidng */
-- l_document := l_document || '<b><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_VENDOR_ATTN') || ':</font></b>'|| l_vendor_contact_name || NL;

-- ------------------------------------------------- ENDED: VENDOR_ADDR



-- These three lines are commented  out when the table for vendor add is removed
-- l_document := l_document || '          </td>' || NL;
-- l_document := l_document || '        </tr>' || NL;
-- l_document := l_document || '      </table>' || NL;


l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td width=25% valign=top>' || NL;
l_document := l_document || '    <!-- bill-to -->' || NL;
l_document := l_document || '      <b><u><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_BILL_TO') || '</font></u></b><br>' || NL;



-- ------------------------------------------------- START: BILL TO
l_document := l_document || '      <font color=black>' || NL;
l_document := l_document || '          ' || l_bill_to_desc || NL;
if (l_bill_to_add1 is not null) then
l_document := l_document || ' <br>         ' || l_bill_to_add1 || NL;
end if;
if (l_bill_to_add2 is not null) then
l_document := l_document || ' <br>         ' || l_bill_to_add2 || NL;
end if;
if (l_bill_to_add3 is not null) then
l_document := l_document || ' <br>         ' || l_bill_to_add3 || NL;
end if;

if (l_bill_to_city is not null) then
l_document := l_document || ' <br>         ' || l_bill_to_city ;
end if;
l_document := l_document || ', ' || NL;

if (l_bill_to_region2 is not null) then
l_document := l_document || l_bill_to_region2 ;
end if;

if (l_bill_to_postal_code is not null) then
l_document := l_document || ' ' || l_bill_to_postal_code ;
end if;
if (l_bill_to_country is not null) then
l_document := l_document || '<br>       ' || l_bill_to_country || NL;

end if;
l_document := l_document || '      <br></font>' || NL;
-- ------------------------------------------------- START: BILL TO



l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td width=30% valign=top>' || NL;
l_document := l_document || '    <!-- dates -->' || NL;
l_document := l_document || '      <table width=100% border=2 rows=2 cols=3>' || NL;
l_document := l_document || '        <tr>' || NL;
l_document := l_document || '          <td width=40% valign=top>' || NL;
l_document := l_document || '            <b><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_DATE_OF_ORDER') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: DATE OF ORDER
l_document := l_document || '            <font color=black>' || NL;
l_document := l_document || '              ' || l_date_of_order || NL;
l_document := l_document || '            <br></font>' || NL;
-- ------------------------------------------------- ENDED: DATE OF ORDER



l_document := l_document || '          </td>' || NL;
l_document := l_document || '          <td width=60% align=center valign=top>' || NL;
l_document := l_document || '            <b><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_BUYER') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: BUYER
l_document := l_document || '            <font color=black>' || NL;
l_document := l_document || '              ' || l_buyer || NL;
l_document := l_document || '            </font>' || NL;
-- ------------------------------------------------- ENDED: BUYER



l_document := l_document || '          </td>' || NL;
l_document := l_document || '        </tr>' || NL;
l_document := l_document || '        <tr>' || NL;
l_document := l_document || '          <td width=40% valign=top>' || NL;
l_document := l_document || '            <b><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_DATE_OF_REVISION') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: DATE OF REVISION
l_document := l_document || '            <font color=black>' || NL;
l_document := l_document || '             ' || l_date_of_revision || NL;
l_document := l_document || '            <br></font>' || NL;
-- ------------------------------------------------- ENDED: DATE OF REVISION



l_document := l_document || '          </td>' || NL;
l_document := l_document || '          <td width=60% align=center valign=top>' || NL;
l_document := l_document || '            <b><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_BUYER') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: BUYER

l_document := l_document || '            <font color=black>' || NL;
l_document := l_document || '              ' || l_revision_buyer || NL;
l_document := l_document || '            </font>' || NL;
-- ------------------------------------------------- ENDED: BUYER



l_document := l_document || '          </td>' || NL;
l_document := l_document || '        </tr>' || NL;
l_document := l_document || '      </table>' || NL;
l_document := l_document || '    </td>' || NL;
l_document := l_document || '  </tr>' || NL;
l_document := l_document || '</table>' || NL;



l_document := l_document || '<table width=100% border=1 cellpadding=2 cellspacing=1 cols=6 rows=2>' || NL;
l_document := l_document || '<!-- other info -->' || NL;
l_document := l_document || '  <tr>' || NL;
l_document := l_document || '    <td valign=top width=10%>' || NL;
l_document := l_document || '      <b><font size=-2>' ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_CUSTOMER_ACCT_NO') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: CUST A/C s.t. here?
l_document := l_document || '      <font color=black>' || NL;
l_document := l_document || '              ' || l_customer_acct_num || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: CUST A/C



l_document := l_document || '    </td>' || NL;

l_document := l_document || '    <td valign=top width=10%>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO','PO_WF_NOTIF_VENDOR_NO') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: VENDOR NO. s.t/ here?
l_document := l_document || '      <font color=black>' || NL;
l_document := l_document || '              ' || l_vendor_num || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: VENDOR NO.



l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td valign=top width=20%>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PAYMENT_TERMS') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: PAYMENT TERMS
l_document := l_document || '      <font color=black>' || NL;
l_document := l_document || '              ' || l_payment_terms || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: PAYMENT TERMS



l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td valign=top width=20%>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_FREIGHT_TERMS') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: FREIGHT TERMS
l_document := l_document || '      <font color=black>' || NL;
l_document := l_document || '              ' || nvl(l_freight_terms_dsp, l_freight_terms_lc) || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: FREIGHT TERMS



l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td valign=top width=20%>' || NL;
l_document := l_document || '<b><font size=-2>' ||  NL;
l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_FOB') || NL;
l_document := l_document || '</font></b>' || NL;



-- ------------------------------------------------- START: F.O.B.
l_document := l_document || '      <br><font color=black>' || NL;
l_document := l_document || '        ' || l_fob_lookup_desc || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: F.O.B.



l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td valign=top width=20%>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_VIA') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: SHIP VIA
l_document := l_document || '      <font color=black>' || NL;
l_document := l_document || '        ' || nvl(l_ship_via_lookup_desc, l_ship_via_lookup_code) || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: SHIP VIA

/* bug 2073564 : For blanket and contract PO's we show the effectivity dates
   and the amount agreed on the email . For a planned PO we only shoe the
   effectivity dates */

if (l_document_type = 'PA') then

l_document := l_document || '    </td>' || NL;
l_document := l_document || '  </tr>' || NL;
l_document := l_document || '  <tr>' || NL;
l_document := l_document || '    <td valign=top colspan=3>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO','PO_EMAIL_BLANKET_START_DATE') || '</font></b><br>' || NL;

-- ------------------------------------------------- START: START DATE
l_document := l_document || '      <font color=black>' || NL;

l_document := l_document || '         ' || l_start_date || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: START DATE

l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td valign=top colspan=2>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO','PO_EMAIL_BLANKET_END_DATE')  || '</font></b><br>' || NL;

-- ------------------------------------------------- START: END DATE
l_document := l_document || '      <font color=black>' || NL;

l_document := l_document || '         ' || l_end_date || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: END DATE

l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td valign=top colspan=1>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO','PO_EMAIL_BLANKET_AMT_AGREED')  || '</font></b><br>' || NL;

-- ------------------------------------------------- START: AMT AGREED
l_document := l_document || '      <font color=black>' || NL;

l_document := l_document || '         ' || l_blanket_amt_agreed || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: AMT AGREED

end if;
  IF (l_document_type = 'PO') THEN
            select type_lookup_code
            into x_subtype
            from po_headers
            where po_header_id = l_document_id;

	    --<BUG 9891660 START>
	    IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.INSERT_DEBUG(l_item_type, l_item_key, 'x_subtype= ' || x_subtype);
	    END IF;
            --<BUG 9891660 END>

    IF (x_subtype = 'PLANNED') THEN

       l_document := l_document || '    </td>' || NL;
       l_document := l_document || '  </tr>' || NL;
       l_document := l_document || '  <tr>' || NL;
       l_document := l_document || '    <td valign=top colspan=3>' || NL;
       l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO','PO_EMAIL_BLANKET_START_DATE') || '</font></b><br>' || NL;

       -- ------------------------------------------------- START: START DATE
       l_document := l_document || '      <font color=black>' || NL;

       l_document := l_document || '         ' || l_start_date || NL;
       l_document := l_document || '      </font>' || NL;
       -- ------------------------------------------------- ENDED: START DATE

       l_document := l_document || '    </td>' || NL;
       l_document := l_document || '    <td valign=top colspan=3>' || NL;
       l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO','PO_EMAIL_BLANKET_END_DATE')  || '</font></b><br>' || NL;

      -- ------------------------------------------------- START: END DATE
      l_document := l_document || '      <font color=black>' || NL;

      l_document := l_document || '         ' || l_end_date || NL;
      l_document := l_document || '      </font>' || NL;
      -- ------------------------------------------------- ENDED: END DATE

    END IF;
  END IF;



l_document := l_document || '    </td>' || NL;
l_document := l_document || '  </tr>' || NL;
l_document := l_document || '  <tr>' || NL;
l_document := l_document || '    <td valign=top colspan=4>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO','PO_WF_NOTIF_CONFIRM_TO_TELE') || '</font></b><br>' || NL;

-- ------------------------------------------------- START: CONFIRM TO/TELEPHONE
l_document := l_document || '      <font color=black>' || NL;

/*
Displaying the Contact Name and Telephone number in the Confirm To/Telephone field
*/

if (l_vendor_contact_name is not null) then
l_document := l_document || '        ' || l_vendor_contact_name || ' &nbsp ' || NL;
l_document := l_document || '      </font>' || NL;
end if;
/* END FIX */

l_document := l_document || '         ' || l_vendor_phone || NL;
l_document := l_document || '      </font>' || NL;
-- ------------------------------------------------- ENDED: CONFIRM TO/TELEPHONE



l_document := l_document || '    </td>' || NL;
l_document := l_document || '    <td valign=top colspan=2>' || NL;
l_document := l_document || '      <b><font size=-2>' || fnd_message.get_string('PO','PO_WF_NOTIF_REQUESTER_DELIVER') || '</font></b><br>' || NL;



-- ------------------------------------------------- START: REQUEST/DELIVER TO
l_document := l_document || '      <font color=black>' || NL;
if (l_deliver_to_person is not null) then
l_document := l_document || '        ' || l_deliver_to_person || ' &nbsp ' || NL;
l_document := l_document || '      </font>' || NL;
l_document := l_document || '  <font color=black>'      || l_phone || l_email_address || ' &nbsp ' || NL;
l_document := l_document || '      </font>' || NL;
else
if (l_multiple_flag = 'N') then
   null;
else
l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_MULTIPLE_REQUESTOR') || NL;
end if;
end if;
-- ------------------------------------------------- ENDED: REQUEST/DELIVER TO





l_document := l_document || '    </td>' || NL;
l_document := l_document || '  </tr>' || NL;
l_document := l_document || '</table>' || NL;

ELSE


-- ------------------------------------------------- START: COMPANY NAME / ADDRESS
/*
l_document := l_document ||  l_operating_unit_desc || NL;
*/
l_document := l_document || l_company_name || NL;
l_document := l_document ||  l_operating_unit_add1 || NL;

if (l_operating_unit_add2 is not null) then
l_document := l_document ||  l_operating_unit_add2 || NL;
end if;
if (l_operating_unit_add3 is not null) then
l_document := l_document  || l_operating_unit_add3 || NL;
end if;
if (l_operating_unit_city is not null) then
l_document := l_document ||  l_operating_unit_city || NL;
end if;
if (l_operating_unit_state is not null) then
l_document := l_document || ', ' || l_operating_unit_state || NL;
end if;
if (l_operating_unit_postal_code is not null) then
l_document := l_document || ' ' || l_operating_unit_postal_code || NL;
end if;
if (l_operating_unit_country is not null) then
l_document := l_document || l_operating_unit_country || NL;
end if;
l_document := l_document ||  NL;
-- ------------------------------------------------- ENDED: COMPANY NAME / ADDRESS

l_document := l_document || '-**- ' || fnd_message.get_string('PO', 'PO_WF_NOTIF_PURCHASE_ORDER') || ' -**-' ||  NL;
l_document := l_document ||  NL;

l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_TO_SMALL') ||  NL;
l_document := l_document ||  l_ship_to_string ||  NL;

l_document := l_document ||  NL;
-- l_document := l_document || '    <!-- PURCHASE-ORDER -->' || NL;


-- l_document := l_document || '          <!-- PO number -->' || NL;
l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PURCHASE_ORDER_NO') || ': ';



-- ------------------------------------------------- START: PURCHASE ORDER NO.
l_document := l_document ||  l_po_number || ' ,  ';
-- ------------------------------------------------- ENDED: PURCHASE ORDER NO.


-- ------------------------------------------------- START: REVISION
l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_REVISION') || ':  ';
l_document := l_document ||  l_po_revision || NL;
-- ------------------------------------------------- ENDED: REVISION


l_document := l_document ||  NL;

-- l_document := l_document || '  <!-- Vendor, bill-to, dates -->' || NL;
-- l_document := l_document || '    <!-- Vendor -->' || NL;

l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_VENDOR') ||  NL;



-- ------------------------------------------------- START: VENDOR_ADDR
l_document := l_document ||  l_vendor_desc || NL;
l_document := l_document ||  l_vendor_add1 || NL;
l_document := l_document ||  l_vendor_add2 || NL;
l_document := l_document ||  l_vendor_add3 || NL;
l_document := l_document ||  l_vendor_city || NL;
l_document := l_document ||  l_vendor_state || NL;
l_document := l_document ||  l_vendor_zip || NL;
l_document := l_document ||  l_vendor_country || NL;

-- ------------------------------------------------- ENDED: VENDOR_ADDR



-- l_document := l_document || '    <!-- bill-to -->' || NL;
l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_BILL_TO') ||  NL;



-- ------------------------------------------------- START: BILL TO
l_document := l_document ||  l_bill_to_desc || NL;
l_document := l_document ||  l_bill_to_add1 || NL;
l_document := l_document ||  l_bill_to_city || NL;
l_document := l_document ||  l_bill_to_region2 || NL;
l_document := l_document ||  l_bill_to_postal_code || NL;
l_document := l_document ||  l_bill_to_country || NL;
l_document := l_document ||  NL;
-- ------------------------------------------------- START: BILL TO


-- l_document := l_document || '<!-- dates -->' || NL;
l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_DATE_OF_ORDER') || ':   ';



-- ------------------------------------------------- START: DATE OF ORDER
l_document := l_document || l_date_of_order || ' ,  ';
-- ------------------------------------------------- ENDED: DATE OF ORDER

l_document := l_document ||  fnd_message.get_string('PO', 'POA_BUYER') ||  ':   ';


-- ------------------------------------------------- START: BUYER
l_document := l_document ||  l_buyer || NL;
-- ------------------------------------------------- ENDED: BUYER


l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_DATE_OF_REVISION') ||  ':   ';

-- ------------------------------------------------- START: DATE OF REVISION
l_document := l_document ||  l_date_of_revision || ' ,  ';
-- ------------------------------------------------- ENDED: DATE OF REVISION


l_document := l_document || fnd_message.get_string('PO', 'POA_BUYER') || ': ' ||  NL;



-- ------------------------------------------------- START: BUYER Do we need to have s.t. here?

-- ------------------------------------------------- ENDED: BUYER


l_document := l_document ||  NL;

-- l_document := l_document || '<!-- other info -->' || NL;
l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_CUSTOMER_ACCT_NO') ||  ':   ';



-- ------------------------------------------------- START: CUST A/C s.t. here?
l_document := l_document ||  l_customer_acct_num || ' , ';
-- ------------------------------------------------- ENDED: CUST A/C



l_document := l_document ||  fnd_message.get_string('PO','PO_WF_NOTIF_VENDOR_NO') ||  ':   ';



-- ------------------------------------------------- START: VENDOR NO. s.t/ here?
l_document := l_document ||  l_vendor_num || NL;
-- ------------------------------------------------- ENDED: VENDOR NO.



l_document := l_document || fnd_message.get_string('PO', 'PO_WF_NOTIF_PAYMENT_TERMS') ||  ':   ';

-- ------------------------------------------------- START: PAYMENT TERMS
l_document := l_document ||  l_payment_terms || NL;
-- ------------------------------------------------- ENDED: PAYMENT TERMS



l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_FREIGHT_TERMS') ||  ':  ';


-- ------------------------------------------------- START: FREIGHT TERMS
l_document := l_document ||  nvl(l_freight_terms_dsp, l_freight_terms_lc) || ' , ';
-- ------------------------------------------------- ENDED: FREIGHT TERMS


l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_FOB') ||  ':  ';


-- ------------------------------------------------- START: F.O.B.
l_document := l_document || l_fob_lookup_desc || ' , ';
-- ------------------------------------------------- ENDED: F.O.B.


l_document := l_document ||  fnd_message.get_string('PO', 'PO_WF_NOTIF_SHIP_VIA') ||  ':  ';

-- ------------------------------------------------- START: SHIP VIA
l_document := l_document ||  nvl(l_ship_via_lookup_desc, l_ship_via_lookup_code) || NL;
-- ------------------------------------------------- ENDED: SHIP VIA


l_document := l_document ||  fnd_message.get_string('PO','PO_WF_NOTIF_CONFIRM_TO_TELE') ||  ':   ';

-- ------------------------------------------------- START: CONFIRM TO/TELEPHONE
l_document := l_document ||  l_vendor_phone || NL;
-- ------------------------------------------------- ENDED: CONFIRM TO/TELEPHONE


l_document := l_document ||  fnd_message.get_string('PO','PO_WF_NOTIF_REQUESTER_DELIVER') || ':   ';


-- ------------------------------------------------- START: REQUEST/DELIVER TO
l_document := l_document || l_deliver_to_person ||  NL;
l_document := l_document || l_phone ||  NL;
l_document := l_document || l_email_address ||  NL;
-- ------------------------------------------------- ENDED: REQUEST/DELIVER TO


END IF;

document := l_document;

EXCEPTION
   WHEN OTHERS THEN
	null;
   RAISE;

end;

/*************************************************************************************/
--EMAILPO FPH--
--changed api signature. Refer to spec for additional explanation
procedure generate_terms  (document_id	  in	 varchar2,
		           display_type	  in 	 varchar2,
                           document	  in out NOCOPY clob,
			   document_type  in out NOCOPY varchar2) IS

v_filehandle   UTL_FILE.FILE_TYPE;
l_filedir      varchar2(2000) := null;
l_filename     varchar2(2000) := null;
v_terms        varchar2(4000) := null;
NL           VARCHAR2(1) := fnd_global.newline;
l_document     varchar2(32000);
x_progress     varchar2(3);
x_display_type varchar2(60);

--EMAILPO FPH START--
l_user_id number;
l_application_id number;
l_responsibility_id number;
l_userid_name varchar2(100) := 'USER_ID';
l_appid_name varchar2(100) := 'APPLICATION_ID';
l_respid_name varchar2(100) := 'RESPONSIBILITY_ID';
l_item_type varchar2(300) := document_id;
l_item_key WF_ITEM_ATTRIBUTE_VALUES.ITEM_KEY%TYPE := '';
l_filename_lang     varchar2(2000) := null;
--EMAILPO FPH END--

l_document_id           number ;
l_document_type         VARCHAR2(30) := '';
l_document_status       varchar2(100);
l_po_header_id number;
l_api_name              CONSTANT VARCHAR2(30) := 'generate_terms';   -- Bug 2792156
l_progress VARCHAR2(100); --<BUG 9891660>
l_org_id NUMBER; --<BUG 9891660>

BEGIN

/* get the directory and file name where the terms and conditions
   for email PO are stored */
l_document := '';
x_progress := '000';
 x_display_type := 'text/html';


/* EMAILPO FPH START
set the context so fnd_profile.get methods work correctly
For older wf notifications  that send in documentid and documenttypecode instead of
itemtype and itemkey combination the following code to get the user_id, app_id and
resp_id will fail. Will trap and ignore it. The consequence is that tandc profile
options will only be considered at site level(consistent with Previous Behaviour/Bug)
*/
BEGIN
	l_item_type := substr(document_id, 1, instr(document_id, ':') - 1);
	l_item_key := substr(document_id, instr(document_id, ':') + 1, length(document_id) - 2);

        --2332866, check if the document is in processing, and
        -- show warning message to the supplier
        l_document_id:=wf_engine.GetItemAttrNumber (   itemtype   => l_item_type,
                                        itemkey    => l_item_key,
                                        aname      => 'DOCUMENT_ID');
        --
        l_document_type:=wf_engine.GetItemAttrText (     itemtype        => l_item_type,
                                        itemkey         => l_item_key,
                                        aname           => 'DOCUMENT_TYPE');

	--<BUG 9891660 START>
	l_org_id := wf_engine.GetItemAttrNumber ( itemtype => l_item_type,
						  itemkey  => l_item_key,
						  aname    => 'ORG_ID');

	l_progress := 'PO_EMAIL_GENERATE.GENERATE_TERMS';
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,l_progress);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_item_type= ' || l_item_type);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_item_key= ' || l_item_key);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_document_id= ' || l_document_id);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_document_type= ' || l_document_type);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_org_id= ' || l_org_id);
	END IF;

	IF l_org_id IS NOT NULL THEN
		--fnd_client_info.set_org_context(to_char(l_org_id));
    PO_MOAC_UTILS_PVT.set_org_context(to_char(l_org_id)) ;
        END IF;
	--<BUG 9891660 END>

        if(l_document_type in ('PO', 'PA')) then
          select authorization_status
            into l_document_status
            from po_headers_all
           where po_header_id = l_document_id;

        elsif (l_document_type = 'RELEASE') then

          select po_header_id into l_po_header_id from po_releases
          where po_release_id = l_document_id;

          select authorization_status
            into l_document_status
            from po_headers_all
           where po_header_id = l_po_header_id;
        end if;

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_document_status= ' || l_document_status);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_po_header_id= ' || l_po_header_id);
	END IF;
	--<BUG 9891660 END>

        if(l_document_status is null or
                l_document_status in ('IN PROCESS', 'INCOMPLETE', 'REQUIRES REAPPROVAL')) then
          WF_NOTIFICATION.WriteToClob(document, ' ');
          return;
        end if;


	l_user_id := wf_engine.GetItemAttrNumber ( itemtype => l_item_type,
   		                                       itemkey => l_item_key,
                                           	   aname => l_userid_name);

	l_application_id := wf_engine.GetItemAttrNumber ( itemtype => l_item_type,
                                                  	  itemkey => l_item_key,
                                                  	  aname => l_appid_name);

	l_responsibility_id := wf_engine.GetItemAttrNumber ( itemtype => l_item_type,
                                                     	 itemkey => l_item_key,
                                                     	 aname => l_respid_name);

	--<BUG 9891660 START>
	IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_user_id= ' || l_user_id);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_application_id= ' || l_application_id);
		PO_WF_DEBUG_PKG.insert_debug(l_item_type,l_item_key,'l_responsibility_id= ' || l_responsibility_id);
	END IF;
	--<BUG 9891660 END>

EXCEPTION WHEN OTHERS THEN
	NULL;
END;
--EMAILPO FPH END--


-- bug 3128426: removed call to fnd_global.apps_initialize
-- instead, use fnd_profile.value_specific to get
-- profile values w/o resetting the app context
l_filedir := FND_PROFILE.VALUE_SPECIFIC(
                name => 'PO_EMAIL_TERMS_DIR_NAME'
             ,  user_id => l_user_id
             ,  responsibility_id => l_responsibility_id
             ,  application_id => l_application_id
             );
l_filename := FND_PROFILE.VALUE_SPECIFIC(
                 name => 'PO_EMAIL_TERMS_FILE_NAME'
              ,  user_id => l_user_id
              ,  responsibility_id => l_responsibility_id
              ,  application_id => l_application_id
              );

IF (l_filedir is null) OR (l_filename is null) THEN
  if (x_display_type = 'text/html') then
   l_document := '<p></p>';
  else
   l_document := ' ';
  end if;
  WF_NOTIFICATION.WriteToClob(document, l_document);
ELSE

x_progress := '001';

/*
EMAILPO FPH START--
Check for supplier site language tandc file first
if that doesn't exist then check for base language tandc file else check for just l_filename
*/
l_filename_lang := l_filename || '_' || userenv('LANG');
BEGIN
	/* open the file */
	v_filehandle := UTL_FILE.FOPEN(l_filedir,l_filename_lang,'r');
EXCEPTION WHEN OTHERS THEN
	BEGIN
		l_filename_lang := l_filename || '_' || fnd_global.base_language;
		v_filehandle := UTL_FILE.FOPEN(l_filedir,l_filename_lang, 'r');
	EXCEPTION WHEN OTHERS THEN
		v_filehandle := UTL_FILE.FOPEN(l_filedir,l_filename, 'r');
	END;
END;
--EMAILPO FPH END--

x_progress := '002';
IF (x_display_type = 'text/html') THEN
  l_document := l_document || '<p>' || NL;
 loop

   begin
    x_progress := '003';
    /* write the contents into the document */
    UTL_FILE.GET_LINE(v_filehandle,v_terms);
    l_document := l_document || v_terms || NL;
    l_document := l_document || '<br>' || NL;
    WF_NOTIFICATION.WriteToClob(document, l_document);
    l_document := null;

    x_progress := '004';

  exception
   when no_data_found then
   exit;
  end;

end loop;

 if l_document is null then
  WF_NOTIFICATION.WriteToClob(document, '</p>');
 end if;

ELSE

 loop

   begin
    x_progress := '003';
    /* write the contents into the document */
    UTL_FILE.GET_LINE(v_filehandle,v_terms);
    l_document := l_document || v_terms || NL;
    WF_NOTIFICATION.WriteToClob(document, l_document);
    x_progress := '004';

  exception
   when no_data_found then
   exit;
  end;
end loop;

END IF;


 x_progress := '005';
/* close the file */
UTL_FILE.FCLOSE(v_filehandle);

END IF;

-- Bug 2792156
-- When any type of exception occurs during the generation of the Terms and Conditions file,
-- it will no longer be raised. Instead, the Email notification will be sent out as
-- normal but without any attachment of Terms and Conditions and a message will be logged
-- in the FND_LOG_MESSAGES table.
EXCEPTION
	WHEN UTL_FILE.INVALID_PATH THEN
		l_document := '<p></p>';
		WF_NOTIFICATION.WriteToClob(document, l_document);
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, c_log_head || l_api_name ||'.EXCEPTION',
                               'generate_terms: Exception Type: INVALID_PATH' ||x_progress||sqlcode);
                END IF;
		UTL_FILE.FCLOSE(v_filehandle);

	WHEN UTL_FILE.INVALID_MODE THEN
                l_document := '<p></p>';
                WF_NOTIFICATION.WriteToClob(document, l_document);
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, c_log_head || l_api_name ||'.EXCEPTION',
                               'generate_terms: Exception Type: INVALID_MODE' ||x_progress||sqlcode);
                END IF;
                UTL_FILE.FCLOSE(v_filehandle);

	WHEN UTL_FILE.INTERNAL_ERROR THEN
                l_document := '<p></p>';
                WF_NOTIFICATION.WriteToClob(document, l_document);
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, c_log_head || l_api_name ||'.EXCEPTION',
                               'generate_terms: Exception Type: INTERNAL_ERROR' ||x_progress||sqlcode);
                END IF;
                UTL_FILE.FCLOSE(v_filehandle);

   	WHEN UTL_FILE.INVALID_FILEHANDLE THEN
                l_document := '<p></p>';
                WF_NOTIFICATION.WriteToClob(document, l_document);
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, c_log_head || l_api_name ||'.EXCEPTION',
                               'generate_terms: Exception Type: INVALID_FILEHANDLE' ||x_progress||sqlcode);
                END IF;
                UTL_FILE.FCLOSE(v_filehandle);

   	WHEN UTL_FILE.INVALID_OPERATION THEN
                l_document := '<p></p>';
                WF_NOTIFICATION.WriteToClob(document, l_document);
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, c_log_head || l_api_name ||'.EXCEPTION',
                               'generate_terms: Exception Type: INVALID_OPERATION' ||x_progress||sqlcode);
                END IF;
                UTL_FILE.FCLOSE(v_filehandle);

   	WHEN UTL_FILE.READ_ERROR THEN
                l_document := '<p></p>';
                WF_NOTIFICATION.WriteToClob(document, l_document);
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, c_log_head || l_api_name ||'.EXCEPTION',
                               'generate_terms: Exception Type: READ_ERROR' ||x_progress||sqlcode);
                END IF;
                UTL_FILE.FCLOSE(v_filehandle);

	WHEN OTHERS THEN
                l_document := '<p></p>';
                WF_NOTIFICATION.WriteToClob(document, l_document);
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
                  FND_LOG.string(FND_LOG.LEVEL_EXCEPTION, c_log_head || l_api_name ||'.EXCEPTION',
                               'generate_terms: Exception Type: OTHERS' ||x_progress||sqlcode);
                END IF;
                UTL_FILE.FCLOSE(v_filehandle);
END;


END PO_EMAIL_GENERATE;

/
