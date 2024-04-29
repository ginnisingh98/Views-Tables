--------------------------------------------------------
--  DDL for Package Body PO_RELEASES_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RELEASES_SV2" as
/* $Header: POXPOR2B.pls 115.10 2004/03/24 15:40:28 manram ship $ */


/*===========================================================================

  PROCEDURE NAME:	get_po_header_details

===========================================================================*/
 PROCEDURE get_po_header_details(
		     X_po_header_id IN NUMBER,
		     X_type_lookup_code IN OUT NOCOPY VARCHAR2,
		     X_revision_num IN OUT NOCOPY NUMBER,
		     X_currency_code IN OUT NOCOPY VARCHAR2,
		     X_supplier_id IN OUT NOCOPY NUMBER,
		     X_supplier_name IN OUT NOCOPY VARCHAR2,
		     X_supplier_site_id IN OUT NOCOPY NUMBER,
		     X_supplier_site_name IN OUT NOCOPY VARCHAR2,
                     X_pay_on_code IN OUT NOCOPY VARCHAR2,
                     X_pay_on_dsp IN OUT NOCOPY VARCHAR2,
		     X_ship_to_location_id IN OUT NOCOPY NUMBER,
		     X_ship_to_location_code IN OUT NOCOPY VARCHAR2,
		     X_organization_id IN OUT NOCOPY NUMBER,
		     X_organization_code IN OUT NOCOPY VARCHAR2,
                     x_shipping_control IN OUT NOCOPY VARCHAR2,    -- <INBOUND LOGISITCS FPJ>
		     x_supply_agreement_flag  IN OUT NOCOPY VARCHAR2, --Bug#3514141
		     x_confirming_order_flag  IN OUT NOCOPY VARCHAR2 --Bug#3514141
) IS

X_progress varchar2(3) := '';

/** <UTF8 FPI> **/
/** tpoon 9/27/2002 **/
/** Changed X_organization_name to use %TYPE **/
-- X_organization_name varchar2(60) := '';
X_organization_name hr_all_organization_units.name%TYPE := '';

X_set_of_books_id number := '';

   BEGIN

       po_headers_sv2.get_po_details(X_po_header_id,
                                     X_type_lookup_code,
		                     X_revision_num,
                                     X_currency_code,
			             X_supplier_id,
                                     X_supplier_site_id,
                                     X_ship_to_location_id);

       -- Get the location code.
       po_locations_s.get_loc_attributes(X_ship_to_location_id,
                                         X_ship_to_location_code,
                                         X_organization_id);

       SELECT set_of_books_id
       INTO   X_set_of_books_id
       FROM   financials_system_parameters;

       -- Get the organization code.
       po_orgs_sv.get_org_info(X_organization_id,
			       X_set_of_books_id,
			       X_organization_code,
			       X_organization_name);

       -- Get the vendor name
       po_vendors_sv.get_vendor_name(x_supplier_id,x_supplier_name);

       -- Get the vendor site
       po_vendor_sites_sv.get_vendor_site_name(x_supplier_site_id,
                                               x_supplier_site_name);


      -- Get pay on code
      --Bug#3514141: Modified the query to get the supply agreement flag and confirming order flag
      select
        ph.pay_on_code,
        lk.displayed_field,
        PH.shipping_control,    -- <INBOUND LOGISTICS FPJ>
	PH.SUPPLY_AGREEMENT_FLAG, --Bug#3514141
	PH.CONFIRMING_ORDER_FLAG  --Bug#3514141
      into
        x_pay_on_code,
        x_pay_on_dsp,
        x_shipping_control,    -- <INBOUND LOGISTICS FPJ>
	x_supply_agreement_flag, --Bug#3514141
	x_confirming_order_flag  --Bug#3514141
      from
        po_headers ph,
        po_lookup_codes lk
      where
        ph.po_header_id = X_po_header_id AND
        lk.lookup_type (+) = 'PAY ON CODE' AND
        lk.lookup_code (+) = ph.pay_on_code;

      EXCEPTION
	WHEN OTHERS THEN
	  -- dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_po_header_details', X_progress, sqlcode);
          raise;
      END get_po_header_details;

/*===========================================================================

  FUNCTION NAME:       get_rel_total

===========================================================================*/
  FUNCTION get_rel_total
        (X_release_id   number) return number is
         X_rel_total     number;
  BEGIN

    SELECT nvl(SUM((quantity-quantity_cancelled) * price_override), 0)
           into X_rel_total
    FROM   po_line_locations
    WHERE  po_release_id = X_release_id;

    RETURN (X_rel_total);

  EXCEPTION
    WHEN OTHERS then
       x_rel_total := 0;
  END get_rel_total;



/*===========================================================================

  FUNCTION NAME:	get_release_status


===========================================================================*/
   FUNCTION get_release_status
	     (X_po_release_id NUMBER) return VARCHAR2 IS

   -- Bug 1186210: increase the length of status.

   X_status             VARCHAR2(4000);
   x_status_code	VARCHAR2(80) := '';
   x_cancel_status	VARCHAR2(80) := '';
   x_closed_status      VARCHAR2(80) := '';
   x_frozen_status      VARCHAR2(80) := '';
   x_hold_status        VARCHAR2(80) := '';
   x_auth_status        VARCHAR2(25) := '';
   x_cancel_flag	VARCHAR2(1)  := 'N';
   x_closed_code        VARCHAR2(25) := '';
   x_frozen_flag	VARCHAR2(1)  := 'N';
   x_user_hold_flag     VARCHAR2(1)  := 'N';
   x_reserved_flag      VARCHAR2(1)  := 'N';
   x_reserved_status    VARCHAR2(80)  := '';
   x_delimiter		VARCHAR2(2)  := ', ';

   BEGIN



      SELECT plc_sta.displayed_field,
                     decode(por.cancel_flag,
                            'Y', plc_can.displayed_field, NULL),
                     decode(nvl(por.closed_code, 'OPEN'), 'OPEN', NULL,
                            plc_clo.displayed_field),
                     decode(por.frozen_flag,
                            'Y', plc_fro.displayed_field, NULL),
                     decode(por.hold_flag,
                            'Y', plc_hld.displayed_field, NULL),
                     por.authorization_status,
                     nvl(por.cancel_flag, 'N'),
                     nvl(por.closed_code, 'OPEN'),
                     nvl(por.frozen_flag, 'N'),
                     nvl(por.hold_flag, 'N')
              into   x_status_code,
                     x_cancel_status,
                     x_closed_status,
                     x_frozen_status,
                     x_hold_status,
                     x_auth_status,
                     x_cancel_flag,
                     x_closed_code,
                     x_frozen_flag,
                     x_user_hold_flag
              from   po_releases por,
                     po_lookup_codes plc_sta,
                     po_lookup_codes plc_can,
                     po_lookup_codes plc_clo,
                     po_lookup_codes plc_fro,
                     po_lookup_codes plc_hld
              where  plc_sta.lookup_code =
                     decode(por.approved_flag,
                            'R', por.approved_flag,
                                 nvl(por.authorization_status,'INCOMPLETE'))
              and    plc_sta.lookup_type in ('PO APPROVAL', 'DOCUMENT STATE')
              and    plc_can.lookup_code = 'CANCELLED'
              and    plc_can.lookup_type = 'DOCUMENT STATE'
              and    plc_clo.lookup_code = nvl(por.closed_code, 'OPEN')
              and    plc_clo.lookup_type = 'DOCUMENT STATE'
              and    plc_fro.lookup_code = 'FROZEN'
              and    plc_fro.lookup_type = 'DOCUMENT STATE'
              and    plc_hld.lookup_code = 'ON HOLD'
              and    plc_hld.lookup_type = 'DOCUMENT STATE'
              and    por.po_release_id = X_po_release_id;


      --<Encumbrance FPJ START>
      PO_CORE_S.should_display_reserved(
         p_doc_type => PO_CORE_S.g_doc_type_RELEASE
      ,  p_doc_level => PO_CORE_S.g_doc_level_HEADER
      ,  p_doc_level_id => x_po_release_id
      ,  x_display_reserved_flag => x_reserved_flag
      );

      IF (x_reserved_flag = 'Y') THEN
         PO_CORE_S.get_reserved_lookup(x_displayed_field => x_reserved_status);
      END IF;
      --<Encumbrance FPJ END>



	      SELECT x_status_code||
			decode(x_closed_code, 'OPEN', '',
				x_delimiter||x_closed_status)||
			decode(x_cancel_flag, 'N', '', '', '',
			        x_delimiter||x_cancel_status)||
			decode(x_frozen_flag, 'N', '', '', '',
				x_delimiter||x_frozen_status)||
		        decode(x_user_hold_flag, 'N', '', '', '',
				x_delimiter||x_hold_status)||
			decode(x_reserved_flag, 'N', '', '', '',
				x_delimiter||x_reserved_status)
	      INTO   X_status
              FROM   dual;

      RETURN(X_status);

      EXCEPTION
	WHEN OTHERS THEN
	  X_status :=  '';
          RETURN(X_status);

   END get_release_status;

END PO_RELEASES_SV2;

/
