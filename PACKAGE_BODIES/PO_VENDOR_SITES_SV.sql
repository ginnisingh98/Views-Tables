--------------------------------------------------------
--  DDL for Package Body PO_VENDOR_SITES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDOR_SITES_SV" AS
/* $Header: POXVDVSB.pls 120.13.12010000.7 2014/08/13 14:26:12 roqiu ship $*/

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');

--==============================================================================
-- FUNCTION    : get_vendor_site_id                    -- <GA FPI>
-- TYPE        : Private
--
-- REQUIRES    : p_po_header_id must be a valid document ID.
-- MODIFIES    : -
--
-- DESCRIPTION : Gets the vendor_site_id specified on a particular PO document.
--
-- PARAMETERS  : p_po_header_id - document ID
--
-- RETURNS     : vendor_site_id specified for the p_po_header_id
--               NULL if no Supplier Site is specified for the p_po_header_id
--                    or if the p_po_header_id does not exist
--
-- EXCEPTIONS  : -
--==============================================================================
FUNCTION get_vendor_site_id
(
    p_po_header_id        IN   PO_HEADERS_ALL.po_header_id%TYPE
)
RETURN PO_HEADERS_ALL.vendor_site_id%TYPE
IS
    x_vendor_site_id      PO_HEADERS_ALL.vendor_site_id%TYPE;
BEGIN

    SELECT    vendor_site_id
    INTO      x_vendor_site_id
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

    return (x_vendor_site_id);

EXCEPTION
    WHEN OTHERS THEN
        return (NULL);

END get_vendor_site_id;


--------------------------------------------------------------------------------
--Start of Comments
--Name: val_vendor_site_id
--Pre-reqs:
--  None.
--Modifies:
--  FND_MESSAGE on error.
--Locks:
--  None.
--Function:
--  Checks if p_vendor_site_id is an active purchasing supplier site in
--  p_org_id. If p_org_id is NULL, then the current OU is used for validation.
--  If the p_document_type is a purchase order ('PO', 'BLANKET'), then the
--  supplier site cannot be an RFQ only site.
--Parameters:
--IN:
--p_document_type
--  The document type to validate p_vendor_site_id with.
--p_vendor_site_id
--p_org_id
--  The operating unit ID associated with this vendor site, or NULL to use the
--  current OU.
--Returns:
--  TRUE if p_vendor_site_id is valid,
--  FALSE otherwise
--End of Comments
--------------------------------------------------------------------------------
FUNCTION val_vendor_site_id
(
    p_document_type  IN VARCHAR2,
    p_vendor_site_id IN NUMBER,
    p_org_id IN NUMBER              --< Shared Proc FPJ >
)
return BOOLEAN
IS

  l_progress 	      varchar2(3) := NULL;
  l_vendor_site_id_v  number      := NULL;

BEGIN

    l_progress := '010';

    /* Check if the given Supplier Site is active.  Also check
    ** that the Site is not an RFQ Only site if validating for use on
    ** a purchase order (requisitions, rfqs and quotations can use
    ** RFQ only sites).
    */

    --< Shared Proc FPJ Start >
    IF (p_org_id IS NULL) THEN

        --SQL What: Query org-striped view to validate vendor site ID
        --SQL Why: No org_id specified, so validate in current OU.
        SELECT vendor_site_id
          INTO l_vendor_site_id_v
          FROM po_vendor_sites
         WHERE vendor_site_id = p_vendor_site_id
           AND SYSDATE < NVL(inactive_date, SYSDATE + 1)
           AND purchasing_site_flag = 'Y'
           AND (   (    p_document_type IN ('PO', 'BLANKET')
                    AND NVL(rfq_only_site_flag,'N') = 'N'
                   )
                OR (p_document_type IN ('REQ', 'MENU', 'RFQ', 'QUOTATION'))
               );

    ELSE

        --SQL What: Query base table to validate vendor site ID
        --SQL Why: Validate site in specified org_id
        SELECT vendor_site_id
          INTO l_vendor_site_id_v
          FROM po_vendor_sites_all
         WHERE vendor_site_id = p_vendor_site_id
           AND org_id = p_org_id
           AND SYSDATE < NVL(inactive_date, SYSDATE + 1)
           AND purchasing_site_flag = 'Y'
           AND (   (    p_document_type IN ('PO', 'BLANKET')
                    AND NVL(rfq_only_site_flag,'N') = 'N'
                   )
                OR (p_document_type IN ('REQ', 'MENU', 'RFQ', 'QUOTATION'))
               );

    END IF;
    --< Shared Proc FPJ End >

    return (TRUE);

EXCEPTION

  when no_data_found then
     return (FALSE);
  when others then
     po_message_s.sql_error('PO_VENDOR_SITES_SV.val_vendor_site',l_progress,sqlcode);
     raise;

END val_vendor_site_id;

/*===========================================================================

  PROCEDURE NAME:	get_def_vendor_site()

===========================================================================*/

PROCEDURE get_def_vendor_site(X_vendor_id IN NUMBER,
                              X_vendor_site_id OUT NOCOPY number,
                              X_vendor_site_code OUT NOCOPY varchar2,
			      X_document_type IN varchar2 ) IS

       X_vendor_site_count number;
       X_progress varchar2(3) := '';

       /* The foll. variable has been introduced as all of a sudden
       ** although it is all on the server side, this function resulted
       ** in ORA-6502 errors - For now, defining this temp variable
       ** and copying it back  thru the argument seems to be working ... */

       X_temp_vendor_site_code varchar2(15);
BEGIN
       X_Progress := '010';

       /* Get the number of ACTIVE PURCHASING SITES
       ** and those that are not ONLY RFQ SITES
       ** for the give vendor
       **
       ** MS 11/14/95:  Added if then else to support processing
       ** 		for RFQs and Quotations.
       **		(took out rfq_only_site_flag condition)
       */

  if (X_document_type not in ('RFQ', 'QUOTATION')) then

       select count(vendor_site_id),
              max(vendor_site_code),
              max(vendor_site_id)
       into   X_vendor_site_count,
              X_temp_vendor_site_code,
              X_vendor_site_id
       from   po_vendor_sites
       where  vendor_id            = X_vendor_id
       and    purchasing_site_flag = 'Y'
       and    sysdate < nvl(inactive_date, sysdate + 1)
       and    nvl(rfq_only_site_flag, 'N') <> 'Y' ;

  else
       select count(vendor_site_id),
              max(vendor_site_code),
              max(vendor_site_id)
       into   X_vendor_site_count,
              X_temp_vendor_site_code,
              X_vendor_site_id
       from   po_vendor_sites
       where  vendor_id            = X_vendor_id
       and    purchasing_site_flag = 'Y'
       and    sysdate < nvl(inactive_date, sysdate + 1);

  end if;

       /* If there are more than 1 active vendor sites,
       ** we cannot determine the default, we return
       ** NULL instead */

       if X_vendor_site_count  <>  1 then
          X_vendor_site_id := '';
          X_vendor_site_code := '';
       else
          X_vendor_site_code := X_temp_vendor_site_code;
       end if;

   EXCEPTION
      when too_many_rows then
            X_vendor_site_id := '';
            X_vendor_site_code := '';
      when no_data_found then
            X_vendor_site_id := '';
            X_vendor_site_code := '';

      WHEN OTHERS THEN
           po_message_s.sql_error('get_def_vendor_site', X_progress, sqlcode);
           raise;

END get_def_vendor_site;

/*===========================================================================

  PROCEDURE NAME:	get_vendor_site_info()

===========================================================================*/

PROCEDURE get_vendor_site_info(X_vendor_site_id IN number,
                               X_vs_ship_to_location_id IN OUT NOCOPY number,
                               X_vs_bill_to_location_id IN OUT NOCOPY number,
                               X_vs_ship_via_lookup_code IN OUT NOCOPY varchar2,
                               X_vs_fob_lookup_code IN OUT NOCOPY varchar2,
                               X_vs_pay_on_code IN OUT NOCOPY varchar2,
                               X_vs_freight_terms_lookup_code IN OUT NOCOPY varchar2,
                               X_vs_terms_id IN OUT NOCOPY number,
                               X_vs_invoice_currency_code IN OUT NOCOPY varchar2,
                               x_vs_shipping_control    IN OUT NOCOPY    VARCHAR2    -- <INBOUND LOGISTICS FPJ>
) IS

cursor C is select nvl(ship_to_location_id,X_vs_ship_to_location_id),
                         nvl(bill_to_location_id,X_vs_bill_to_location_id),
                         ship_via_lookup_code ,
                         fob_lookup_code,
                         pay_on_code,
                         freight_terms_lookup_code,
                         terms_id ,
                         invoice_currency_code,
                         shipping_control    -- <INBOUND LOGISTICS FPJ>
                  from   po_vendor_sites_all --<Shared Proc FPJ>
                  where  vendor_site_id = X_vendor_site_id;

          X_progress varchar2(3) := '';

BEGIN

    if (X_vendor_site_id is not null) then
          X_progress := '010';
          open C;
          X_progress := '020';

          /* Get the other vendor site attributes for a given vendor site
          ** If there is no such vendor site, these attributes will have
          ** NULL value in them */

          fetch C into X_vs_ship_to_location_id ,
                       X_vs_bill_to_location_id ,
                       X_vs_ship_via_lookup_code ,
                       X_vs_fob_lookup_code ,
                       X_vs_pay_on_code,
                       X_vs_freight_terms_lookup_code ,
                       X_vs_terms_id ,
                       X_vs_invoice_currency_code,
                       x_vs_shipping_control;    -- <INBOUND LOGISTICS FPJ>
         close C;

    else

                       X_vs_ship_to_location_id := '' ;
                       X_vs_bill_to_location_id := '';
                       X_vs_ship_via_lookup_code := '' ;
                       X_vs_fob_lookup_code := '' ;
                       X_vs_pay_on_code := '';
                       X_vs_freight_terms_lookup_code := '' ;
                       X_vs_terms_id := '';
                       X_vs_invoice_currency_code := '';
                       x_vs_shipping_control := '';    -- <INBOUND LOGISTICS FPJ>

     end if;

   exception
       when others then
          po_message_s.sql_error('get_vendor_site_info', X_progress, sqlcode);
          raise;

END get_vendor_site_info;

/*===========================================================================

  PROCEDURE NAME:	val_vendor_site()

===========================================================================*/

PROCEDURE val_vendor_site  (X_vendor_id IN number,
                            X_vendor_site_id IN number,
                            X_org_id IN number,
                            X_set_of_books_id IN number,
                            X_res_ship_to_loc_id IN OUT NOCOPY number,
                            X_ship_to_loc_dsp IN OUT NOCOPY varchar2,
                            X_ship_org_code IN OUT NOCOPY varchar2,
                            X_ship_org_name IN OUT NOCOPY varchar2,
                            X_ship_org_id  IN OUT NOCOPY number,
                            X_res_bill_to_loc_id IN OUT NOCOPY number ,
                            X_bill_to_loc_dsp IN OUT NOCOPY varchar2,
                            X_res_fob IN OUT NOCOPY varchar2 ,
                            X_res_pay_on_code IN OUT NOCOPY varchar2,
                            X_res_ship_via IN OUT NOCOPY varchar2 ,
                            X_res_freight_terms IN OUT NOCOPY varchar2 ,
                            X_res_terms_id IN OUT NOCOPY number,
                            X_res_invoice_currency_code IN OUT NOCOPY varchar2,
                            X_fob_dsp IN OUT NOCOPY varchar2,
                            X_pay_on_dsp IN OUT NOCOPY varchar2,
                            X_ship_via_dsp IN OUT NOCOPY varchar2,
                            X_freight_terms_dsp IN OUT NOCOPY varchar2,
                            X_terms_dsp  IN OUT NOCOPY varchar2,
                            X_vendor_contact_id IN OUT NOCOPY number,
                            X_vendor_contact_name IN OUT NOCOPY varchar2,
                            x_res_shipping_control IN OUT NOCOPY VARCHAR2 -- <INBOUND LOGISTICS FPJ>
                           )
IS

   X_progress varchar2(3) := '';

   X_type_1099  varchar2(10);
   X_hold_flag  varchar2(1);
   X_ship_to_location_id number;
   X_bill_to_location_id number;
   X_ship_via_lookup_code varchar2(25);
-- Bug: 1710995 Define the codes according to the definition in the table.
   X_fob_lookup_code           po_lookup_codes.lookup_code%TYPE;
   X_freight_terms_lookup_code po_lookup_codes.lookup_code%TYPE;
   X_terms_id number;
   X_invoice_currency_code varchar2(15);
   X_receipt_required_flag varchar2(1);
   X_num_1099 varchar2(30);
   /*
   ** BUGNO 718328.
   ** X_vat_registration_num varchar2(15);
   ** changed to varchar2(20).
   */
   X_vat_registration_num  varchar2(20);
   X_inspection_required_flag varchar2(1);

   X_vs_ship_to_location_id number;
   X_vs_bill_to_location_id number;
   X_vs_ship_via_lookup_code varchar2(25);
-- Bug: 1710995 Define the codes according to the definition in the table.
   X_vs_fob_lookup_code 	   po_lookup_codes.lookup_code%TYPE;
   X_vs_freight_terms_lookup_code  po_lookup_codes.lookup_code%TYPE;
   X_vs_pay_on_code varchar2(25);
   X_vs_terms_id number;
   X_vs_invoice_currency_code varchar2(15);
   l_vs_shipping_control    PO_LOOKUP_CODES.lookup_code%TYPE := NULL;    -- <INBOUND LOGISTICS FPJ>

BEGIN
          --dbms_output.put_line('Before get_vendor_info');

          /* Get Vendor Information. May be required for
          ** defaulting values if the vendor site info
          ** is invalid */

          po_vendors_sv.get_vendor_info (X_vendor_id ,
                           X_ship_to_location_id ,
                           X_bill_to_location_id ,
                           X_ship_via_lookup_code ,
                           X_fob_lookup_code ,
                           X_freight_terms_lookup_code ,
                           X_terms_id ,
                           X_type_1099  ,
                           X_hold_flag ,
                           X_invoice_currency_code ,
                           X_receipt_required_flag ,
                           X_num_1099 ,
                           X_vat_registration_num,
                           X_inspection_required_flag );


      --dbms_output.put_line('Before get_vendor_Site_info');


           /* Get vendor site information */

             get_vendor_site_info(X_vendor_site_id ,
                                  X_vs_ship_to_location_id ,
                                  X_vs_bill_to_location_id ,
                                  X_vs_ship_via_lookup_code ,
                                  X_vs_fob_lookup_code ,
                                  X_vs_pay_on_code,
                                  X_vs_freight_terms_lookup_code ,
                                  X_vs_terms_id ,
                                  X_vs_invoice_currency_code,
                                  l_vs_shipping_control -- <INBOUND LOGISTICS FPJ>
                                  ) ;

/* Validate Invoice currency code with vendor site info first.
** If this turns out to be invalid, use the vendor information  */


           if X_vs_invoice_currency_code is not null then
                    X_res_invoice_currency_code :=  X_vs_invoice_currency_code;
           else
                    X_res_invoice_currency_code :=  X_invoice_currency_code;
           end if;

/* Validating FOB lookup code from vendor site if available.
** If not available or vendor site fob is inactive, validate the vendor fob */

              if X_vs_fob_lookup_code is not null then
                  po_vendors_sv.val_fob(X_vs_fob_lookup_code , X_res_fob);
             end if;
             if ((X_res_fob is null) and (X_fob_lookup_code is not null)) then
                po_vendors_sv.val_fob(X_fob_lookup_code , X_res_fob);
             end if;

/* Validating Freight Terms lookup code from vendor site if available.
** If not available or vendor site Freight Terms is inactive,
** validate the vendor Freight Terms */

        if X_vs_freight_terms_lookup_code is not null then
           po_vendors_sv.val_freight_terms( X_vs_freight_terms_lookup_code,
                                            X_res_freight_terms);
        end if;

        if ((X_res_freight_terms is null) and
            (X_freight_terms_lookup_code is not null)) then
             po_vendors_sv.val_freight_terms( X_freight_terms_lookup_code,
                                              X_res_freight_terms);
        end if;

/* Validating Ship Via lookup code from vendor site if available.
** If not available or vendor site Ship Via is inactive,
** validate the vendor Ship Via */

        if X_vs_ship_via_lookup_code is not null then
           po_vendors_sv.val_freight_carrier(X_vs_ship_via_lookup_code,
                                             X_org_id,
                                             X_res_ship_via);
        end if;
        if ((X_res_ship_via is null) and
            (X_ship_via_lookup_code is not null)) then
           po_vendors_sv.val_freight_carrier(X_ship_via_lookup_code,
                                             X_org_id,
                                             X_res_ship_via);
        end if;

/* Validating Terms Id from vendor site if available.
** If not available or vendor site Terms Id is inactive,
** validate the vendor Terms Id */

       if X_vs_terms_id  is not null then
          po_terms_sv.val_ap_terms(X_vs_terms_id, X_res_terms_id);
       end if;

       if ((X_res_terms_id is null) and
           (X_terms_id is not null)) then
            po_terms_sv.val_ap_terms(X_terms_id, X_res_terms_id);
       end if;


        /* Validating shipping control from vendor site */
        PO_VENDORS_SV.val_shipping_control
        (
            p_temp_shipping_control    =>    l_vs_shipping_control,
            x_res_shipping_control     =>    x_res_shipping_control
        );    -- <INBOUND LOGISTICS FPJ>

 /* Obtain displayed values for the valid ids  */

       po_vendors_sv.get_displayed_values(X_res_fob,
                                          X_res_freight_terms,
                                          X_res_ship_via,
                                          X_res_terms_id,
                                          X_fob_dsp,
                                          X_freight_terms_dsp,
                                          X_ship_via_dsp,
                                          X_terms_dsp,
                                          X_org_id);

 /* Get display value for pay on */

       X_res_pay_on_code := X_vs_pay_on_code;

       if X_res_pay_on_code is not null then
         po_core_s.get_displayed_value('PAY ON CODE',
                                       X_res_pay_on_code,
                                       X_pay_on_dsp);
       else
         X_pay_on_dsp := '';
       end if;

/* Validate Ship To location with vendor site info first.
** If it is invalid/null, use the vendor info to get it.
** Also bring in the appropriate atrributes */

       if X_vs_ship_to_location_id is not null then
          po_vendors_sv.get_ship_to_loc_attributes (X_vs_ship_to_location_id,
                                                    X_ship_to_loc_dsp,
                                       X_ship_org_code, X_ship_org_name ,
                                       X_ship_org_id, X_set_of_books_id );
          X_res_ship_to_loc_id := X_vs_ship_to_location_id;
       end if;

       if  (X_ship_to_loc_dsp is null)
and (X_ship_to_location_id is not null) then
           po_vendors_sv.get_ship_to_loc_attributes ( X_ship_to_location_id ,
                                       X_ship_to_loc_dsp ,
                                       X_ship_org_code , X_ship_org_name ,
                                       X_ship_org_id ,X_set_of_books_id );
           X_res_ship_to_loc_id := X_ship_to_location_id;
       end if;

/* Validate Bill  To location with vendor site info first.
** If it is invalid/null, use the vendor info to get it.
** Also bring in the appropriate atrributes */


       if X_vs_bill_to_location_id is not null then
          po_vendors_sv.get_bill_to_loc_attributes ( X_vs_bill_to_location_id ,
                                                     X_bill_to_loc_dsp );
          X_res_bill_to_loc_id := X_vs_bill_to_location_id;
       end if;


       if  (X_bill_to_loc_dsp is null)
       and (X_bill_to_location_id is not null) then
            po_vendors_sv.get_bill_to_loc_attributes ( X_bill_to_location_id ,
                                                       X_bill_to_loc_dsp);
            X_res_bill_to_loc_id := X_bill_to_location_id;
       end if;

/* Default the Vendor Contact if possible  */

    po_vendor_contacts_sv.get_vendor_contact(X_vendor_site_id,
                                             X_vendor_contact_id,
                                             X_vendor_contact_name);

   exception
        when others then
            po_message_s.sql_error('val_vendor_site', X_progress, sqlcode);
            raise;

END val_vendor_site;

/*===================================================================

  PROCEDURE : get_vendor_site_name()

======================================================================*/



   PROCEDURE get_vendor_site_name
		      (X_vendor_site_id 	     IN     NUMBER,
                       X_vendor_site_name            IN OUT NOCOPY VARCHAR2) IS

      X_progress varchar2(3) := '';

   /* Get the vendor site associated with the vendor site id
   */

      CURSOR C is
         SELECT PVS.vendor_site_code
         FROM   PO_VENDOR_SITES_ALL PVS  --<Shared Proc FPJ>
         WHERE  PVS.vendor_site_id = X_vendor_site_id;

 BEGIN

	 --dbms_output.put_line('Before open cursor');

	 if (X_vendor_site_id is not null) then
	    X_progress := '010';
            OPEN C;
	    X_progress := '020';

            FETCH C into X_vendor_site_name;

            CLOSE C;

	    --dbms_output.put_line('Vendor Site Name'||X_vendor_site_name);

         end if;

EXCEPTION
	when others then
	  --dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_vendor_site_name', X_progress, sqlcode);

END get_vendor_site_name;

/*===================================================================

  PROCEDURE : derive_vendor_site_info()

======================================================================*/

 PROCEDURE derive_vendor_site_info (
               p_vendor_site_record IN OUT NOCOPY rcv_shipment_header_sv.VendorSiteRecType) IS

 cid            INTEGER;
 rows_processed INTEGER;
 sql_str        VARCHAR2(2000);

 vendor_site_code_null BOOLEAN := TRUE;
 vendor_id_null        BOOLEAN := TRUE;
 /* organization_id_null  BOOLEAN := TRUE;     Bug 607639 */
 vendor_site_id_null   BOOLEAN := TRUE;

 BEGIN

    sql_str := 'SELECT vendor_site_id, vendor_id, vendor_site_code,org_id FROM po_vendor_sites WHERE ';

    IF p_vendor_site_record.vendor_site_code IS NULL   and
       p_vendor_site_record.vendor_site_id  IS NULL   THEN

          p_vendor_site_record.error_record.error_status := 'W';
          RETURN;

    END IF;

    IF p_vendor_site_record.vendor_site_id IS NOT NULL and
       p_vendor_site_record.vendor_site_code IS NOT NULL   THEN

          p_vendor_site_record.error_record.error_status := 'S';
          RETURN;

    END IF;

    IF p_vendor_site_record.vendor_site_id IS NOT NULL THEN

      sql_str := sql_str || ' vendor_site_id = :v_site_id and';
      vendor_site_id_null := FALSE;

    END IF;

    IF p_vendor_site_record.vendor_site_code IS NOT NULL THEN

      sql_str := sql_str || ' vendor_site_code = :v_site_code and';
      vendor_site_code_null := FALSE;

    END IF;

    IF p_vendor_site_record.vendor_id IS NOT NULL THEN

      sql_str := sql_str || ' vendor_id = :v_id and';
      vendor_id_null := FALSE;

    END IF;

    /*      IF p_vendor_site_record.organization_id IS NOT NULL THEN

              sql_str := sql_str || ' org_id = :v_organization_id and';
              organization_id_null := FALSE;

           END IF;    bug 607639 org_id is actually the operating unit */

    sql_str := substr(sql_str,1,length(sql_str)-3);

    --dbms_output.put_line(substr(sql_str,1,255));
    --dbms_output.put_line(substr(sql_str,256,255));
    --dbms_output.put_line(substr(sql_str,513,255));

    cid := dbms_sql.open_cursor;

    dbms_sql.parse(cid, sql_str , dbms_sql.native);

    dbms_sql.define_column(cid,1,p_vendor_site_record.vendor_site_id);
    dbms_sql.define_column(cid,2,p_vendor_site_record.vendor_id);
    dbms_sql.define_column(cid,3,p_vendor_site_record.vendor_site_code,40);
    dbms_sql.define_column(cid,4,p_vendor_site_record.organization_id);

    IF NOT vendor_site_id_null THEN

      dbms_sql.bind_variable(cid,'v_site_id',p_vendor_site_record.vendor_site_id);

    END IF;

    IF NOT vendor_id_null THEN

      dbms_sql.bind_variable(cid,'v_id',p_vendor_site_record.vendor_id);

    END IF;

    IF NOT vendor_site_code_null THEN

      dbms_sql.bind_variable(cid,'v_site_code',p_vendor_site_record.vendor_site_code);

    END IF;

    /* IF NOT organization_id_null THEN

          dbms_sql.bind_variable(cid,'v_organization_id',p_vendor_site_record.organization_id);

       END IF; bug 607639 */

    rows_processed := dbms_sql.execute_and_fetch(cid);

    IF rows_processed = 1 THEN

       IF vendor_site_id_null THEN
          dbms_sql.column_value(cid,1,p_vendor_site_record.vendor_site_id);
       END IF;

       IF vendor_site_code_null THEN
          dbms_sql.column_value(cid,3,p_vendor_site_record.vendor_site_code);
       END IF;

       p_vendor_site_record.error_record.error_status := 'S';

    ELSIF rows_processed = 0 THEN

       p_vendor_site_record.error_record.error_status := 'W';

    ELSE

       p_vendor_site_record.error_record.error_status := 'W';

    END IF;

    IF dbms_sql.is_open(cid) THEN
       dbms_sql.close_cursor(cid);
    END IF;

 EXCEPTION
    WHEN others THEN

       IF dbms_sql.is_open(cid) THEN
           dbms_sql.close_cursor(cid);
       END IF;

       p_vendor_site_record.error_record.error_status := 'U';
       p_vendor_site_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_vendor_site_record.error_record.error_message);
       END IF;

 END derive_vendor_site_info;

-- Bug# 3532503
PROCEDURE validate_remit_to_site
(
  p_remit_to_site_id IN NUMBER,
  x_error_status     OUT NOCOPY VARCHAR2,
  x_error_message    OUT NOCOPY VARCHAR2
)
IS
  l_hold_all_payments_flag PO_VENDOR_SITES_ALL.hold_all_payments_flag%TYPE;
  l_pay_site_flag PO_VENDOR_SITES_ALL.pay_site_flag%TYPE;
BEGIN
  IF p_remit_to_site_id IS NULL THEN
    x_error_status  := 'E';
    x_error_message := 'All blanks';
    RETURN;
  END IF;

  SELECT hold_all_payments_flag, pay_site_flag
  INTO   l_hold_all_payments_flag, l_pay_site_flag
  FROM   PO_VENDOR_SITES
  WHERE  vendor_site_id = p_remit_to_site_id;

  -- Check for hold payments flag
  IF nvl(l_hold_all_payments_flag, 'N') = 'Y' THEN
    x_error_status := 'E';
    x_error_message := 'VEN_SITE_HOLD_PMT';
    RETURN;
  END IF;

  -- Check for Pay on Receipt site flag
  IF nvl(l_pay_site_flag, 'Y') = 'N' THEN
    x_error_status := 'E';
    x_error_message := 'VEN_SITE_NOT_POR_SITE';
    RETURN;
  END IF;

  x_error_status := 'S';
  x_error_message := NULL;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_status := 'E';
    x_error_message := 'VEN_SITE_ID';
  WHEN TOO_MANY_ROWS THEN
    x_error_status := 'E';
    x_error_message := 'TOOMANYROWS';
  WHEN OTHERS THEN
    RAISE;
END validate_remit_to_site;

/*===================================================================

  PROCEDURE : validate_vendor_site_info()

======================================================================*/

 PROCEDURE validate_vendor_site_info
        (p_vendor_site_record IN OUT NOCOPY rcv_shipment_header_sv.VendorSiteRecType,
         p_remit_to_site_id   NUMBER DEFAULT NULL) -- Bug# 3532503
 IS

 X_cid            INTEGER;
 X_rows_processed INTEGER;
 X_sql_str VARCHAR2(2000) := 'SELECT povs.inactive_date, povs.purchasing_site_flag, povs.pay_site_flag , povs.hold_all_payments_flag FROM po_vendor_sites povs where ';

 X_vendor_site_code_null BOOLEAN := TRUE;
 X_vendor_id_null   BOOLEAN := TRUE;
 --  X_organization_id_null BOOLEAN := TRUE;  bug 621385
 X_vendor_site_id_null  BOOLEAN := TRUE;

 X_sysdate  DATE := sysdate;
 X_inactive_date DATE;
 X_purchasing_site_flag VARCHAR2(1);
 X_pay_site_flag   VARCHAR2(1);
 X_hold_all_payments_flag VARCHAR2(1);

 BEGIN

    IF p_vendor_site_record.vendor_site_code IS NULL   and
       p_vendor_site_record.vendor_site_id  IS NULL   THEN

          --dbms_output.put_line('No values');
          p_vendor_site_record.error_record.error_status := 'E';
          p_vendor_site_record.error_record.error_message := 'All blanks';
          RETURN;

    END IF;

    IF p_vendor_site_record.vendor_site_id IS NOT NULL THEN

      X_sql_str := X_sql_str || ' vendor_site_id = :v_site_id and';
      X_vendor_site_id_null := FALSE;

    END IF;

    IF p_vendor_site_record.vendor_site_code IS NOT NULL THEN

      X_sql_str := X_sql_str || ' vendor_site_code = :v_site_code and';
      X_vendor_site_code_null := FALSE;

    END IF;

    IF p_vendor_site_record.vendor_id IS NOT NULL THEN

      X_sql_str := X_sql_str || ' vendor_id = :v_id and';
      X_vendor_id_null := FALSE;

    END IF;

    /*  IF p_vendor_site_record.organization_id IS NOT NULL THEN

          X_sql_str := X_sql_str || ' org_id = :v_organization_id and';
          X_organization_id_null := FALSE;

        END IF;   bug 621385  org_id is actually the operating unit*/

    X_sql_str := substr(X_sql_str,1,length(X_sql_str)-3);

    --dbms_output.put_line(substr(X_sql_str,1,255));
    --dbms_output.put_line(substr(X_sql_str,256,255));
    --dbms_output.put_line(substr(X_sql_str,513,255));

    X_cid := dbms_sql.open_cursor;

    dbms_sql.parse(X_cid, X_sql_str , dbms_sql.native);

    dbms_sql.define_column(X_cid,1,X_inactive_date);
    dbms_sql.define_column(X_cid,2,X_purchasing_site_flag,1);
    dbms_sql.define_column(X_cid,3,X_pay_site_flag,1);
    dbms_sql.define_column(X_cid,4,X_hold_all_payments_flag,1);

    IF NOT X_vendor_site_id_null THEN

      dbms_sql.bind_variable(X_cid,'v_site_id',p_vendor_site_record.vendor_site_id);

    END IF;

    IF NOT X_vendor_id_null THEN

      dbms_sql.bind_variable(X_cid,'v_id',p_vendor_site_record.vendor_id);

    END IF;

    IF NOT X_vendor_site_code_null THEN

      dbms_sql.bind_variable(X_cid,'v_site_code',p_vendor_site_record.vendor_site_code);

    END IF;

    /* IF NOT X_organization_id_null THEN

         dbms_sql.bind_variable(X_cid,'v_organization_id',p_vendor_site_record.organization_id);

       END IF;  bug 621385 */

    X_rows_processed := dbms_sql.execute_and_fetch(X_cid);

    IF X_rows_processed = 1 THEN

          dbms_sql.column_value(X_cid,1,X_inactive_date);
          dbms_sql.column_value(X_cid,2,X_purchasing_site_flag);
          dbms_sql.column_value(X_cid,3,X_pay_site_flag);
          dbms_sql.column_value(X_cid,4,X_hold_all_payments_flag);

    -- check whether Vendor_site_id is enabled
    -- Active if Inactive date is in the future ie > sysdate

       IF nvl(X_inactive_date,X_sysdate+1) < X_sysdate THEN

          --dbms_output.put_line('Disabled Vendor Site');
          p_vendor_site_record.error_record.error_status := 'E';
          p_vendor_site_record.error_record.error_message := 'VEN_SITE_DISABLED';

          IF dbms_sql.is_open(X_cid) THEN
             dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

    -- Bug# 3532503: If remit_to_site id is not null, then perform the
    -- validations for hold_all_payments_flag and pay_site_flag using
    -- the remit_to_site_id instead of the vendor_site_id.
    IF p_remit_to_site_id IS NOT NULL THEN
      validate_remit_to_site(p_remit_to_site_id => p_remit_to_site_id,
                             x_error_status     => p_vendor_site_record.error_record.error_status,
                             x_error_message    => p_vendor_site_record.error_record.error_message);
      -- In case the status is not 'S', close the cursor and return
      IF (p_vendor_site_record.error_record.error_status <> 'S') THEN
        IF dbms_sql.is_open(X_cid) THEN
          dbms_sql.close_cursor(X_cid);
        END IF;
        RETURN;
      END IF;
    ELSE
    -- Bug# 3532503: End

    -- Check for hold payments flag

       IF nvl(X_hold_all_payments_flag,'N') = 'Y' THEN

          --dbms_output.put_line('Payment Hold');
          p_vendor_site_record.error_record.error_status := 'E';
          p_vendor_site_record.error_record.error_message := 'VEN_SITE_HOLD_PMT';

          IF dbms_sql.is_open(X_cid) THEN
             dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

    -- Check for Pay on Receipt site flag

       IF nvl(X_pay_site_flag,'Y') = 'N' THEN

          --dbms_output.put_line('Not pay on receipt site');
          p_vendor_site_record.error_record.error_status := 'E';
          p_vendor_site_record.error_record.error_message := 'VEN_SITE_NOT_POR_SITE';

          IF dbms_sql.is_open(X_cid) THEN
             dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

    END IF; -- IF p_remit_to_site_id IS NOT NULL (Bug# 3532503)

    -- Check for purchasing site flag

       IF nvl(X_purchasing_site_flag,'Y') = 'N' THEN

          --dbms_output.put_line('Not purchasing site');
          p_vendor_site_record.error_record.error_status := 'E';
          p_vendor_site_record.error_record.error_message := 'VEN_SITE_NOT_PURCH';

          IF dbms_sql.is_open(X_cid) THEN
             dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

       p_vendor_site_record.error_record.error_status := 'S';
       p_vendor_site_record.error_record.error_message := NULL;

    ELSIF X_rows_processed = 0 THEN -- No rows found

       p_vendor_site_record.error_record.error_status := 'E';
       p_vendor_site_record.error_record.error_message := 'VEN_SITE_ID';

    ELSE    -- More than 1 row found

       p_vendor_site_record.error_record.error_status := 'E';
       p_vendor_site_record.error_record.error_message := 'TOOMANYROWS';

    END IF;

    IF dbms_sql.is_open(X_cid) THEN
       dbms_sql.close_cursor(X_cid);
    END IF;

 EXCEPTION
    WHEN others THEN
       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;
       p_vendor_site_record.error_record.error_status := 'U';
       p_vendor_site_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_vendor_site_record.error_record.error_message);
       END IF;

 END validate_vendor_site_info;

-- Bug 5407459 Added the p_retrieve_only_flag parameter. Also modified the
-- queries in Get_Transmission_Defaults to use the _ALL tables, so that this
-- procedure can be invoked from HTML.

/* RETROACTIVE FPI START */
Procedure Get_Transmission_Defaults(p_document_id          IN NUMBER,
                                    p_document_type        IN VARCHAR2,
				    p_document_subtype     IN VARCHAR2,
                                    p_preparer_id          IN OUT NOCOPY NUMBER,
                                    x_default_method          OUT NOCOPY VARCHAR2,
                                    x_email_address           OUT NOCOPY VARCHAR2,
                                    x_fax_number              OUT NOCOPY VARCHAR2,
                                    x_document_num            OUT NOCOPY VARCHAR2,
                                    p_retrieve_only_flag   IN VARCHAR2)
IS

l_fax_area             po_vendor_sites_all.fax_area_code%type;

l_faxnum               varchar2(30);                   -- Need to change this also as part of bug 5765243

l_party_site_id        po_headers_all.vendor_site_id%type;
l_party_id             po_headers_all.vendor_id%type;
l_retcode               pls_integer;
l_errmsg                varchar2(2000);
l_result                boolean := FALSE;
l_preparer_id  po_headers.agent_id%type;
l_authorization_status  po_headers.authorization_status%type;
l_transaction_subtype VARCHAR2(240);

l_progress             varchar2(3);
l_consigned_consumption_flag po_headers_all.consigned_consumption_flag%TYPE;
l_api_name    CONSTANT VARCHAR2(50) := 'Get_Transmission_Defaults';
l_xml_flag             po_headers_all.xml_flag%TYPE; --bug fix 2764348
l_approved_date        po_headers_all.approved_date%TYPE; --Bug 6074733
l_po_comm_email_default VARCHAR2(10); -- <Bug 8352586>

BEGIN
	l_progress := '000';

	/* Get the authorization_status for the document */
	If ((p_document_type = 'PO') OR (p_document_type = 'PA')) then
	  begin
		SELECT poh.authorization_status,
		       poh.consigned_consumption_flag,
		       poh.agent_id,
                      poh.segment1,
                      poh.vendor_site_id,
                      poh.vendor_id,
		      poh.approved_date	--Bug 6074733
		into l_authorization_status,
		     l_consigned_consumption_flag,
                     l_preparer_id,
                     x_document_num,
                     l_party_site_id,
                     l_party_id,
		     l_approved_date	--Bug 6074733
		FROM po_headers_all poh
		WHERE poh.po_header_id = p_document_id;
	  exception
	  when others then
	  po_message_s.sql_error('Get_Transmission_Defaults',
					 l_progress, sqlcode);
	  raise;
	  end;
	   /* Bug 7232666, get approved_date from po_releases_all */
        elsif (p_document_type = 'RELEASE') then
	  begin
		SELECT por.authorization_status ,
		       por.consigned_consumption_flag,
		       por.agent_id,
                      poh.segment1,
                      poh.vendor_site_id,
                      poh.vendor_id,
		      por.approved_date --Bug 6074733   Bug 7232666
		into l_authorization_status,
		     l_consigned_consumption_flag,
                     l_preparer_id,
                     x_document_num,
                     l_party_site_id,
                     l_party_id,
		     l_approved_date	--Bug 6074733
                from  po_headers_all poh,
                      po_releases_all por
                where por.po_release_id = p_document_id and
                      poh.po_header_id = por.po_header_id ;
	  exception
	  when others then
	  po_message_s.sql_error('Get_Transmission_Defaults',
					 l_progress, sqlcode);
	  end;
	end if; /*If ((p_document_type = 'PO') OR (p_document_type = 'PA'))*/

	   /* NO communication is to be sent if
	    * l_consigned_consumption_flag is Y.
	    * return after setting default_method to null.
	   */
	   if (nvl(l_consigned_consumption_flag,'N') = 'Y') then
		   x_default_method := null;
		   return;
	   end if;

	l_progress := '010';

	if(p_document_type = 'PO' OR p_document_type = 'RELEASE') then

	   /* Bug 2734857. Authorization status must be 'REQUIRES REAPPROVA"' and
	    * not REQUIRES_REAPPROVAL. Because of this, transaction_type was always
	    * PRO and hence we were not showing the correct method in the approval
            * window.
           */
		/* Bug 6074733, added new parameter l_approved_date and modified
		the if condition to ensure the delivery option does not default
		in case of document revision. */
		If ((nvl(l_authorization_status, 'INCOMPLETE') IN ('REQUIRES REAPPROVAL', 'APPROVED')) OR (nvl(l_authorization_status, 'INCOMPLETE') = 'REJECTED' AND l_approved_date IS NOT NULL)) then
			l_transaction_subtype := 'POCO';
		elsif (nvl(l_authorization_status, 'INCOMPLETE') IN ('INCOMPLETE', 'REJECTED') AND l_approved_date IS NULL) then
			l_transaction_subtype := 'PRO';
		 end if;
		 /* End Bug 6074733 */

                -- bug 2764348. The following call raises an exception when TP setup is not done correctly
                -- In addition to reading the resultout we need to trap any exceptions and set the xml_flag to N
                begin
		     ecx_document.isDeliveryRequired
				(
				transaction_type    => 'PO',
				transaction_subtype => l_Transaction_SubType,
				party_id            => l_party_id,
				party_site_id       => l_party_site_id,
				resultout           => l_result,
				retcode             => l_retcode,
				errmsg              => l_errmsg
				);
                     --bug 2764348
		     If (l_result) then
		          x_default_method := 'XML';
                          l_xml_flag := 'Y';
                     else
                          l_xml_flag := 'N';
                     end if;
                exception
                     when others then
                          l_xml_flag := 'N'; -- bug 2764348
                end;

                -- Bug 5407459 Do not update the database if
                -- p_retrieve_only_flag = 'Y'.
                if (NVL(p_retrieve_only_flag,'N') <> 'Y') THEN

                  if ((p_document_type = 'RELEASE') and
                      (p_document_subtype = 'BLANKET')) then

                    update po_releases_all
                    set xml_flag = l_xml_flag -- bug 2764348
                    where po_release_id = p_document_id;

                  elsif ((p_document_type = 'PO') and
                         (p_document_subtype = 'STANDARD')) then

                    update po_headers_all
                    set xml_flag = l_xml_flag -- bug 2764348
                    where po_header_id = p_document_id;

                  end if;
                END IF;


	   end if; /* (p_document_type = 'PO' OR p_document_type = 'RELEASE') */

	l_progress := '020';
	If (p_preparer_id is null) then
		p_preparer_id := l_preparer_id;
	end if;

	If (x_default_method is null) then
         -- <Bug 8352586>
         -- Get the value of profile option "PO: Communication Email Default"
         FND_PROFILE.get('PO_COMM_EMAIL_DEFAULT', l_po_comm_email_default);

         If ((p_document_type = 'PO') OR (p_document_type = 'PA')) then
          begin
                -- Bug 5295179 If the supplier notif method is defined on the
                -- PO (i.e. for POs created/modified in HTML), use that instead
                -- of the Supplier Site defaults. Also, we default email/fax
                -- from 3 places, in order of priority:
                -- 1. po_headers_all
                -- 2. po_vendor_contacts (see Bug 4597324)
                -- 3. po_vendor_sites_all

                -- Bug 6625807 / 6526600
		-- Added pvs.vendor_site_id = NVL(pvc.vendor_site_id,
		-- pvs.vendor_site_id) condition so that following query returns
		-- only 1 record in case one vendor contact id is attached with
		-- multiple sites.
                -- <Bug 8352586>
                -- Get email address depending on value of profile PO_COMM_EMAIL_DEFAULT
		/*Bug#14612574: handle case email address is NULL in the
                        header for the 'EMAIL' communication method*/

		/* Bug 19014787, Update the email retrieve method, if the PO was submitted,
		  get the email address from table po_headers_all if the PO status
		  is in-complete, then get the emaild address from site or contact
		depends user setting.*/
                select NVL(poh.supplier_notif_method,
                       pvs.supplier_notif_method),
                   case
                    when   poh.authorization_status is null
                    or poh.authorization_status = 'INCOMPLETE'
                    then DECODE(l_po_comm_email_default,
                     'SITE', pvs.email_address,
                      NVL(pvc.email_address, pvs.email_address))
                  else
                    -- Bug#14612574 : replace above with DECODE below
                    DECODE(poh.supplier_notif_method,
                     'EMAIL', NVL(poh.email_address,
                      DECODE(l_po_comm_email_default,
                       'SITE', pvs.email_address,
                       NVL(pvc.email_address, pvs.email_address))),
                      NULL, DECODE(l_po_comm_email_default,
                       'SITE', pvs.email_address,
                        NVL(pvc.email_address, pvs.email_address)),
                      poh.email_address)
                  end ,
                  DECODE(poh.supplier_notif_method, NULL,
                         NVL(pvc.fax_area_code, pvs.fax_area_code),
                         ''), -- poh.fax includes the area code
                  DECODE(poh.supplier_notif_method, NULL,
                         NVL(pvc.fax, pvs.fax),
                         poh.fax)
                into  x_default_method,
                      x_email_address,
                      l_fax_area,
                      l_faxnum
                from  po_headers_all poh,
                      po_vendor_sites_all pvs,
                      po_vendor_contacts pvc
                where poh.vendor_site_id = pvs.vendor_site_id and
                      poh.vendor_contact_id = pvc.vendor_contact_id (+) and
                      poh.po_header_id = p_document_id and
		      pvs.vendor_site_id = NVL(pvc.vendor_site_id, pvs.vendor_site_id);

                -- Bug 5295179 In HTML, we store the method as 'NONE' to
                -- distinguish from POs created in Forms. It means that the PO
                -- should not be communicated.
                IF (x_default_method = 'NONE') THEN
                  x_default_method := null;
                END IF;

                -- Bug 16987394: XML Trading partner must be setup
                -- if supplier_notif_method is XML.
                IF (x_default_method = 'XML' AND l_xml_flag <> 'Y') THEN
                  x_default_method := null;
                END IF;
                -- Bug 16987394 End
          exception
	  when others then
	  po_message_s.sql_error('Get_Transmission_Defaults',
					 l_progress, sqlcode);
	  raise;
          end;


        elsif (p_document_type = 'RELEASE') then
             begin
                -- We default email/fax from po_vendor_contacts (see Bug
                -- 4597324), then po_vendor_sites_all.

                -- Bug 6625807 / 6526600
		-- Added pvs.vendor_site_id = NVL(pvc.vendor_site_id,
		-- pvs.vendor_site_id) condition so that following query returns
		-- only 1 record in case one vendor contact id is attached with
		-- multiple sites.
                -- <Bug 8352586>
                -- Get email address depending on value of profile PO_COMM_EMAIL_DEFAULT
                select pvs.supplier_notif_method,
                      DECODE(l_po_comm_email_default,
                             'SITE', pvs.email_address,
                             NVL(pvc.email_address, pvs.email_address)),
                      NVL(pvc.fax_area_code, pvs.fax_area_code),
                      NVL(pvc.fax, pvs.fax)
                into  x_default_method,
                      x_email_address,
                      l_fax_area,
                      l_faxnum
                from  po_headers_all poh,
                      po_vendor_sites_all pvs,
                      po_vendor_contacts pvc,
                      po_releases por
                where poh.vendor_site_id = pvs.vendor_site_id and
                      poh.vendor_contact_id = pvc.vendor_contact_id (+) and
                      poh.po_header_id = por.po_header_id and
                      por.po_release_id = p_document_id and
		      pvs.vendor_site_id = NVL(pvc.vendor_site_id, pvs.vendor_site_id);

                -- Bug 16987394: XML Trading partner must be setup
                -- if supplier_notif_method is XML.
                IF (x_default_method = 'XML' AND l_xml_flag <> 'Y') THEN
                  x_default_method := null;
                END IF;
                -- Bug 16987394 End

          exception
	  when others then
	  po_message_s.sql_error('Get_Transmission_Defaults',
					 l_progress, sqlcode);
	  raise;
          end;

         end if; /* p_document_type = 'PO' */

	l_progress := '030';

	 If (l_faxnum is not null) then
		x_fax_number := l_fax_area || l_faxnum ;
	 end if;

	end if; /* x_default_method is null */

EXCEPTION
	when others then
	  po_message_s.sql_error('Get_Transmission_Defaults',
					 l_progress, sqlcode);
	raise;

END Get_Transmission_Defaults;

/* RETROACTIVE FPI END */

-- Bug 5407459 Added this procedure.
---------------------------------------------------------------------------
--Start of Comments
--Name: get_transmission_defaults_edi
--Pre-reqs:
--  N/A
--Modifies:
--  po_headers_all.xml_flag, po_releases_all.xml_flag (unless
--  p_retrieve_only_flag = 'Y')
--Locks:
--  N/A
--Function:
--  Retrieves the document transmission setups, including EDI.
--  (Note that the original get_transmission_defaults procedure does not check
--  the EDI setups.)
--  By default, we will update the xml_flag in the database based on whether
--  the vendor site is set up for XML, unless p_retrieve_only_flag = 'Y'.
--Parameters:
--IN:
--p_document_id
--  po_header_id for POs and PAs, po_release_id for releases
--p_document_type
--  'PO', 'PA', 'RELEASE'
--p_document_subtype
--  'STANDARD', 'PLANNED', 'BLANKET', 'CONTRACT', 'SCHEDULED'
--p_preparer_id
--  IN OUT parameter for the buyer of the PO; can be passed as null
--p_retrieve_only_flag
--  if this is 'Y', we will not update the xml_flag in the database. This is
--  necessary to avoid locking issues from HTML.
--OUT:
--x_default_method
--  the communication method: null, 'PRINT', 'FAX', 'EMAIL', 'XML', 'EDI'
--x_email_address
--  the default email address
--x_fax_number
--  the default fax number
--x_document_num
--  the document number
--Testing:
--End of Comments
---------------------------------------------------------------------------
procedure get_transmission_defaults_edi (
                                    p_document_id          IN NUMBER,
                                    p_document_type        IN VARCHAR2,
                                    p_document_subtype     IN VARCHAR2,
                                    p_preparer_id          IN OUT NOCOPY NUMBER,
                                    x_default_method       OUT NOCOPY VARCHAR2,
                                    x_email_address        OUT NOCOPY VARCHAR2,
                                    x_fax_number           OUT NOCOPY VARCHAR2,
                                    x_document_num         OUT NOCOPY VARCHAR2,
                                    p_retrieve_only_flag   IN VARCHAR2) IS
  l_tp_header_id PO_VENDOR_SITES.tp_header_id%TYPE;
  l_edi_flag     ECE_TP_DETAILS.edi_flag%TYPE;
BEGIN

  -- Retrieve the non-EDI tranmission setups.
  get_transmission_defaults (
    p_document_id => p_document_id,
    p_document_type => p_document_type,
    p_document_subtype => p_document_subtype,
    p_preparer_id => p_preparer_id,
    x_default_method => x_default_method,
    x_email_address => x_email_address,
    x_fax_number => x_fax_number,
    x_document_num => x_document_num,
    p_retrieve_only_flag => p_retrieve_only_flag );

  -- Next, check the EDI settings. We can skip this check if the method is XML,
  -- since XML takes precedence over EDI.
  IF ((x_default_method IS NULL) OR (x_default_method <> 'XML')) THEN

    -- Bug 5593568 Fixed the queries below to use a subquery to handle the
    -- outer join with ece_tp_details.

    IF (p_document_type IN ('PO', 'PA')) THEN

      select phv.tp_header_id, nvl(etd.edi_flag,'N')
      into   l_tp_header_id, l_edi_flag
      from
        (select pvs.tp_header_id, ph.authorization_status, ph.type_lookup_code
         from   po_vendor_sites_all pvs,
                po_vendors pv,
                po_headers_all ph
         where  ph.vendor_id       = pv.vendor_id (+)
         and    ph.vendor_site_id  = pvs.vendor_site_id (+)
         and    ph.vendor_id       = pvs.vendor_id (+)
         and    ph.po_header_id    = p_document_id
         ) phv,
        ece_tp_details etd
      where etd.tp_header_id (+) = phv.tp_header_id
      and   etd.document_id (+)
        = decode(phv.authorization_status,'REQUIRES REAPPROVAL','POCO','POO')
      and   etd.document_type (+) = phv.type_lookup_code;

    ELSIF (p_document_type = 'RELEASE') THEN

      select phv.tp_header_id, nvl(etd.edi_flag,'N')
      into   l_tp_header_id, l_edi_flag
      from
        (select pvs.tp_header_id, pr.authorization_status
         from   po_vendor_sites_all pvs,
                po_vendors pv,
                po_headers_all ph,
                po_releases_all pr
         where  ph.vendor_id       = pv.vendor_id (+)
         and    ph.vendor_site_id  = pvs.vendor_site_id (+)
         and    ph.vendor_id       = pvs.vendor_id (+)
         and    ph.po_header_id    = pr.po_header_id
         and    pr.po_release_id   = p_document_id
         ) phv,
        ece_tp_details etd
      where etd.tp_header_id (+) = phv.tp_header_id
      and   etd.document_id (+)
        = decode(phv.authorization_status,'REQUIRES REAPPROVAL','POCO','POO')
      and   rownum = 1;

    END IF; --End of IF l_doc_type IN ('PO', 'PA')

    IF ((l_tp_header_id IS NOT NULL) AND (l_edi_flag = 'Y')) THEN
      x_default_method := 'EDI';
      x_email_address := null;
      x_fax_number := null;
    END IF;

  END IF;

END get_transmission_defaults_edi;

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_org_id_from_vendor_site
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Returns the operating unit id associated with given vendor_site_id
--Parameters:
--p_vendor_site_id
--  site_id from which to derive the OU id
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_org_id_from_vendor_site
(
    p_vendor_site_id   IN   NUMBER
)
RETURN PO_HEADERS_ALL.org_id%TYPE
IS
    x_org_id    PO_HEADERS_ALL.org_id%TYPE;

BEGIN

    SELECT      org_id
    INTO        x_org_id
    FROM        po_vendor_sites_all
    WHERE       vendor_site_id = p_vendor_site_id;

    return (x_org_id);

EXCEPTION

    WHEN OTHERS THEN
        return (NULL);

END get_org_id_from_vendor_site;
--<Shared Proc FPJ END>

END PO_VENDOR_SITES_SV;

/
