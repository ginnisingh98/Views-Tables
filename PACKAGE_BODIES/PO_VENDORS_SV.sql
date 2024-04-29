--------------------------------------------------------
--  DDL for Package Body PO_VENDORS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDORS_SV" as
/* $Header: POXVDVEB.pls 120.4.12010000.2 2012/02/16 09:39:23 rkandima ship $*/

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');

/*===========================================================================

  FUNCTION NAME:	val_vendor()

===========================================================================*/
FUNCTION val_vendor(X_vendor_id IN NUMBER) return BOOLEAN IS

  X_progress 	varchar2(3) := NULL;
  X_vendor_id_v	number 	    := NULL;

BEGIN

  X_progress := '010';

  /* Check if the given Supplier is active */

  SELECT vendor_id
  INTO   X_vendor_id_v
  FROM   po_vendors
  WHERE  sysdate between nvl(start_date_active, sysdate -1)
  AND    nvl(end_date_active, sysdate + 1)
  AND    enabled_flag = 'Y'
  AND    vendor_id = X_vendor_id;

  return (TRUE);

EXCEPTION

  when no_data_found then
    return (FALSE);
  when others then
     po_message_s.sql_error('val_vendor',X_progress,sqlcode);
     raise;

END val_vendor;

/*===========================================================================

 PROCEDURE NAME :  get_vendor_info()

===========================================================================*/

procedure get_vendor_info (X_vendor_id IN number,
                           X_ship_to_location_id IN OUT NOCOPY number,
                           X_bill_to_location_id IN OUT NOCOPY number,
                           X_ship_via_lookup_code IN OUT NOCOPY varchar2,
                           X_fob_lookup_code IN OUT NOCOPY varchar2,
                           X_freight_terms_lookup_code IN OUT NOCOPY varchar2,
                           X_terms_id IN OUT NOCOPY number,
                           X_type_1099  IN OUT NOCOPY varchar2,
                           X_hold_flag IN OUT NOCOPY  varchar2,
                           X_invoice_currency_code IN OUT NOCOPY varchar2,
                           X_receipt_required_flag IN OUT NOCOPY varchar2,
                           X_num_1099 IN OUT NOCOPY varchar2,
                           X_vat_registration_num  IN OUT NOCOPY varchar2,
                           X_inspection_required_flag IN OUT NOCOPY varchar2 )  is

     X_progress varchar2(3) := '';
/* Bug  4421065:TCA Impact: Removed the obsolete column vat_code in po_vendors table */
-- Bug# 4546121:All columns that referred to the obsolete columns in po_vendors have
--              been nulled out.

          cursor C is select v.type_1099,
                      v.hold_flag,
                      null,
                      null,
                      null,
                      null,
                      null,
                      v.terms_id,
                      v.invoice_currency_code,
                      v.receipt_required_flag,
                      v.num_1099,
                      v.vat_registration_num,
                      v.inspection_required_flag
                from  po_vendors    v
                where v.vendor_id = X_vendor_id;

 begin
       if (X_vendor_id is not null) then
          X_progress := '010';
          open C;
          X_progress := '020';

         /* Get the other attributes for a given vendor id */

          fetch C into  X_type_1099,
                        X_hold_flag,
                        X_ship_to_location_id,
                        X_bill_to_location_id,
                        X_ship_via_lookup_code ,
                        X_fob_lookup_code,
                        X_freight_terms_lookup_code,
                        X_terms_id,
                        X_invoice_currency_code,
                        X_receipt_required_flag,
                        X_num_1099,
                        X_vat_registration_num,
                        X_inspection_required_flag;
           close C;
        end if;

exception
         when others then
         po_message_s.sql_error('get_vendor_info',X_progress,sqlcode);
      --   app_exception.raise_exception;
 end get_vendor_info;

/*===========================================================================

 PROCEDURE NAME :  get_vendor_defaults()

===========================================================================*/

procedure get_vendor_defaults ( X_vendor_id IN number,
                                  X_org_id IN number,
                                  X_set_of_books_id IN number,
                                  X_res_fob IN OUT NOCOPY varchar2 ,
                                  X_res_ship_via IN OUT NOCOPY varchar2 ,
                                  X_res_freight_terms IN OUT NOCOPY varchar2 ,
                                  X_res_terms_id  IN OUT NOCOPY number ,
                                  X_vendor_site_id IN OUT NOCOPY number ,
                                  X_vendor_site_code IN OUT NOCOPY VARCHAR2,
                                  X_fob_dsp IN OUT NOCOPY varchar2,
                                  X_ship_via_dsp IN OUT NOCOPY varchar2,
                                  X_freight_terms_dsp IN OUT NOCOPY varchar2,
                                  X_terms_dsp  IN OUT NOCOPY varchar2,
                                  X_res_ship_to_loc_id  IN OUT NOCOPY number,
                                  X_ship_to_loc_dsp IN OUT NOCOPY varchar2,
                                  X_ship_org_code IN OUT NOCOPY varchar2,
                                  X_ship_org_name IN OUT NOCOPY varchar2,
                                  X_ship_org_id  IN OUT NOCOPY number,
                                  X_res_bill_to_loc_id IN OUT NOCOPY number,
                                  X_bill_to_loc_dsp IN OUT NOCOPY varchar2,
                                  X_res_invoice_currency_code IN OUT NOCOPY varchar2,
                                  X_type_1099 IN OUT NOCOPY varchar2,
                                  X_receipt_required_flag IN OUT NOCOPY varchar2 ,
                                  X_vendor_contact_id IN OUT NOCOPY number,
                                  X_vendor_contact_name IN OUT NOCOPY varchar2,
                                  X_inspection_required_flag IN OUT NOCOPY varchar2,
				  X_document_type IN varchar2 ) is

   X_hold_flag  varchar2(1);
   X_ship_to_location_id number;
   X_bill_to_location_id number;
   X_ship_via_lookup_code varchar2(25);
-- Bug: 1710995 Define the codes according to the definition in the table.
   X_fob_lookup_code 		po_lookup_codes.lookup_code%TYPE;
   X_freight_terms_lookup_code 	po_lookup_codes.lookup_code%TYPE;
   X_terms_id number;
   X_invoice_currency_code varchar2(15);
   X_num_1099 varchar2(30);
   /*
   ** BUGNO 718328.
   ** X_vat_registration_num varchar2(15);
   ** changed to varchar2(20).
   */
   X_vat_registration_num  varchar2(20);

   /* The following 2 variables are used as parameters to
   ** get_def_vendor_site() proc. For some reason, passing
   ** X_vendor_site_id and X_vendor_site_code itself as
   ** parameters raises a value error in get_def_vendor_site() proc. */

   X_temp_vendor_site_id   number;
   X_temp_vendor_site_code varchar2(15);


   X_vs_ship_to_location_id number;
   X_vs_bill_to_location_id number;
   X_vs_ship_via_lookup_code varchar2(25);
   X_vs_pay_on_code varchar2(25);
-- Bug: 1710995 Define the codes according to the definition in the table.
   X_vs_fob_lookup_code 		po_lookup_codes.lookup_code%TYPE;
   X_vs_freight_terms_lookup_code	po_lookup_codes.lookup_code%TYPE;
   X_vs_terms_id number;
   X_vs_invoice_currency_code varchar2(15);
   x_vs_shipping_control                po_lookup_codes.lookup_code%TYPE;    -- <INBOUND LOGISTICS FPJ>


   X_progress varchar2(3) := '';




 begin

       /* Get the other attributes for a given vendor */
       get_vendor_info(X_vendor_id ,
                       X_ship_to_location_id ,
                       X_bill_to_location_id ,
                       X_ship_via_lookup_code ,
                       X_fob_lookup_code ,
                       X_freight_terms_lookup_code ,
                       X_terms_id ,
                       X_type_1099 ,
                       X_hold_flag ,
                       X_invoice_currency_code ,
                       X_receipt_required_flag ,
                       X_num_1099 ,
                       X_vat_registration_num ,
                       X_inspection_required_flag ) ;

       /* Default currency code to vendor first */

        IF X_invoice_currency_code is NOT NULL THEN
           X_res_invoice_currency_code :=  X_invoice_currency_code;
        ELSE
           X_res_invoice_currency_code := '';
        END IF;

        X_progress := '030';

        /* Get a default vendor site if one exists for the
        ** given vendor
	**
	** 11/14/95 - MS
	** Added X_document_type parameter for RFQ/Quote processing
	*/

        po_vendor_sites_sv.get_def_vendor_site(X_vendor_id ,
                            X_temp_vendor_site_id ,
                            X_temp_vendor_site_code,
			    X_document_type );

        /* Copy from the temp variable back to the actual variable */
          X_vendor_site_id :=  X_temp_vendor_site_id;
          X_vendor_site_code := X_temp_vendor_site_code;


        /* If the vendor site is not null,
        ** proceed to get the vendor site details
        ** otherwise, simply return to the client.
        ** The vendor attributes will be validated
        ** when the vendor site info is filled in */

        -- dbms_output.put_line('The Def Site is ' || X_vendor_site_id );


        if  (X_vendor_site_id is not null) then
            X_progress := '040';
            po_vendor_sites_sv.get_vendor_site_info(X_vendor_site_id ,
                                 X_vs_ship_to_location_id ,
                                 X_vs_bill_to_location_id ,
                                 X_vs_ship_via_lookup_code ,
                                 X_vs_fob_lookup_code ,
                                 X_vs_pay_on_code ,
                                 X_vs_freight_terms_lookup_code ,
                                 X_vs_terms_id ,
                                 X_vs_invoice_currency_code,
                                 x_vs_shipping_control    -- <INBOUND LOGISTICS FPJ>
                                 ) ;
        --   dbms_output.put_line('Vendor SIte Info : FOB is ' || X_vs_fob_lookup_code);
        else

          --   dbms_output.put_line('Returning back without Site');
             return;

        end if;

/* Validate Invoice currency code try vendor site info first,
** if that is invalid, try to validate the vendor info */


           if X_vs_invoice_currency_code is not null then
              X_res_invoice_currency_code :=  X_vs_invoice_currency_code;
           end if;


/* Validate the FOB lookup code from vendor site if available.
** If not available or vendor site fob is inactive, validate the vendor fob */

        if X_vs_fob_lookup_code is not null then
           val_fob(X_vs_fob_lookup_code , X_res_fob);
        end if;
        if ((X_res_fob is null) and (X_fob_lookup_code is not null)) then
            val_fob(X_fob_lookup_code , X_res_fob);
        end if;

/* Validating Freight Terms lookup code from vendor site if available.
** If not available or vendor site Freight Terms is inactive,
** validate the vendor Freight Terms */

        if X_vs_freight_terms_lookup_code is not null then
           val_freight_terms( X_vs_freight_terms_lookup_code, X_res_freight_terms);
        end if;

        if ((X_res_freight_terms is null) and
            (X_freight_terms_lookup_code is not null)) then
             val_freight_terms( X_freight_terms_lookup_code, X_res_freight_terms);
        end if;

/* Validating Ship Via lookup code from vendor site if available.
** If not available or vendor site Ship Via is inactive,
** validate the vendor Ship Via */

        if X_vs_ship_via_lookup_code is not null then
           val_freight_carrier(X_vs_ship_via_lookup_code, X_org_id, X_res_ship_via);
        end if;
        if ((X_res_ship_via is null) and
            (X_ship_via_lookup_code is not null)) then
           val_freight_carrier(X_ship_via_lookup_code, X_org_id, X_res_ship_via);
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


/* Obtain displayed values for the valid ids  */

       get_displayed_values(X_res_fob, X_res_freight_terms, X_res_ship_via, X_res_terms_id,
                            X_fob_dsp, X_freight_terms_dsp, X_ship_via_dsp, X_terms_dsp,
                            X_org_id);

/* Obtain Ship To location atrributes , use the vendor site info first.
** If that is null or it is inactive, use the vendor info  */

       if X_vs_ship_to_location_id is not null then
          get_ship_to_loc_attributes ( X_vs_ship_to_location_id, X_ship_to_loc_dsp,
                                       X_ship_org_code, X_ship_org_name ,
                                       X_ship_org_id, X_set_of_books_id );
          X_res_ship_to_loc_id := X_vs_ship_to_location_id;
       end if;

       if  (X_ship_to_loc_dsp is null)
       and (X_ship_to_location_id is not null) then
           get_ship_to_loc_attributes ( X_ship_to_location_id , X_ship_to_loc_dsp ,
                                       X_ship_org_code , X_ship_org_name ,
                                       X_ship_org_id ,X_set_of_books_id );
           X_res_ship_to_loc_id := X_ship_to_location_id;
       end if;

/* Obtain Bill To location atrributes , use the vendor site info first.
** If that is null or it is inactive, use the vendor info  */


       if X_vs_bill_to_location_id is not null then
          get_bill_to_loc_attributes ( X_vs_bill_to_location_id , X_bill_to_loc_dsp );
          X_res_bill_to_loc_id := X_vs_bill_to_location_id;
       end if;

       if  (X_bill_to_loc_dsp is null)
       and (X_bill_to_location_id is not null) then
            get_bill_to_loc_attributes ( X_bill_to_location_id , X_bill_to_loc_dsp);
            X_res_bill_to_loc_id := X_bill_to_location_id;
       end if;

/* Default the Vendor Contact if possible  */

    po_vendor_contacts_sv.get_vendor_contact(X_vendor_site_id,
                                             X_vendor_contact_id,
                                             X_vendor_contact_name);


 exception
       when others then
         po_message_s.sql_error('get_vendor_defaults',X_progress,sqlcode);
         raise;
 end get_vendor_defaults;


/*===========================================================================

 PROCEDURE NAME :  val_fob()

===========================================================================*/

 procedure val_fob( X_temp_fob_lookup_code IN varchar2,
                    X_res_fob IN OUT NOCOPY varchar2) is

          X_progress varchar2(3) := '';
          x_lookup_type PO_LOOKUP_CODES.LOOKUP_TYPE%type; --bug3808435
 begin
                  X_progress := '010';
		  --Bug3808435
		  --Replaced the hardcoded literal 'FOB' in the sql with a
		  --bind variable.
		  x_lookup_type := 'FOB';
                 /* Check if the given FOB lookupcode is active */

                   select lookup_code
                   into  X_res_fob
                   from   po_lookup_codes
                   where  lookup_type = x_lookup_type
                   and    sysdate < nvl(inactive_date, sysdate + 1)
                   and    lookup_code = X_temp_fob_lookup_code;

  exception

             when no_data_found then
                  X_res_fob := '';
             when too_many_rows then
                  X_res_fob := '';
             when others then
                   po_message_s.sql_error('val_fob',X_progress,sqlcode);
                   raise;
 end val_fob;

/*===========================================================================

 PROCEDURE NAME :  val_freight_terms()

===========================================================================*/

 procedure val_freight_terms ( X_temp_freight_terms IN varchar2,
                               X_res_freight_terms IN OUT NOCOPY varchar2) is

           X_progress varchar2(3) := '';
           x_lookup_type PO_LOOKUP_CODES.LOOKUP_TYPE%type;  --bug3808435

 begin
              X_progress := '010';
              --Bug3808435
  	      --Replaced the hardcoded literal 'FREIGHT TERMS' in the sql with
	      --a bind variable.
   	      x_lookup_type := 'FREIGHT TERMS';
              /* Check if the given Freight Terms Code is active */

              SELECT lookup_code
              INTO   X_res_freight_terms
              FROM   po_lookup_codes
              WHERE  lookup_type = x_lookup_type
              AND    sysdate < nvl(inactive_date, sysdate + 1)
              AND    lookup_code = X_temp_freight_terms  ;
  exception

             when no_data_found then
                  X_res_freight_terms := '';
             when too_many_rows then
                  X_res_freight_terms := '';
             when others then
                 po_message_s.sql_error('val_freght_terms',X_progress,sqlcode);
                 raise;
 end val_freight_terms;

/*===========================================================================

 PROCEDURE NAME :  val_freight_carrier()

===========================================================================*/

 procedure val_freight_carrier (X_temp_ship_via IN varchar2,
                                X_org_id IN number,
                                X_res_ship_via IN OUT NOCOPY varchar2) is

           X_progress varchar2(3) := '';

 begin
            X_progress := '010';

            /* Check if the given Freight Code is active */

            SELECT freight_code
            INTO   X_res_ship_via
            FROM   org_freight
            WHERE  organization_id = X_org_id
            AND    freight_code    = X_temp_ship_via
            AND    nvl(disable_date, sysdate + 1) > sysdate;

 exception

             when no_data_found then
                  X_res_ship_via := '';
             when too_many_rows then
                  X_res_ship_via := '';
             when others then
              po_message_s.sql_error('val_freight_carrier',X_progress,sqlcode);
              raise;

 end val_freight_carrier;

/*INBOUND LOGISTICS FPJ START */
/**
* Private Procedure: val_shipping_control
* Requires: None
* Modifies: x_res_shipping_control
* Effects: If p_tmp_shipping_control is not valid then returns
*          NULL in x_res_shipping_control. Otherwise returns
*           sets x_res_shipping_control to p_tmp_shipping_control
*/

PROCEDURE val_shipping_control
(
    p_temp_shipping_control    IN               VARCHAR2,
    x_res_shipping_control     IN OUT NOCOPY    VARCHAR2
)
IS

    X_progress varchar2(3) := '';
    x_lookup_type PO_LOOKUP_CODES.LOOKUP_TYPE%type;  --bug3808435
BEGIN

    X_progress := '010';
    --Bug3808435
    --Replaced the hardcoded literal 'SHIPPING CONTROL' in the sql with a
    --bind variable.
    x_lookup_type := 'SHIPPING CONTROL';
    /* Check if the given shipping control is active */

    SELECT lookup_code
      INTO x_res_shipping_control
      FROM po_lookup_codes
     WHERE lookup_type = x_lookup_type
       AND TRUNC(SYSDATE) < NVL( TRUNC(inactive_date), SYSDATE + 1 )
       AND lookup_code = p_temp_shipping_control;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_res_shipping_control := '';
    WHEN TOO_MANY_ROWS THEN
        x_res_shipping_control := '';
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('val_shipping_control', x_progress, sqlcode);
    RAISE;

END val_shipping_control;

/* INBOUND LOGISTICS FPJ END */


/*=============================================================================

    PROCEDURE:    get_terms_conditions                <GA FPI>

    DESCRIPTION:  Based on the input po_header_id, retrieves the
                  (a) terms_id
                  (b) ship_via_lookup_code
                  (c) fob_lookup_code
                  (d) freight_terms_lookup_code.

=============================================================================*/
PROCEDURE get_terms_conditions
(
    p_po_header_id              IN     PO_HEADERS_ALL.po_header_id%TYPE,
    x_terms_id                  OUT NOCOPY    PO_HEADERS_ALL.terms_id%TYPE,
    x_ship_via_lookup_code      OUT NOCOPY    PO_HEADERS_ALL.ship_via_lookup_code%TYPE,
    x_fob_lookup_code           OUT NOCOPY    PO_HEADERS_ALL.fob_lookup_code%TYPE,
    x_freight_terms_lookup_code OUT NOCOPY    PO_HEADERS_ALL.freight_terms_lookup_code%TYPE,
    x_shipping_control          OUT NOCOPY    PO_HEADERS_ALL.shipping_control%TYPE    -- <INBOUND LOGISTICS FPJ>
)
IS
BEGIN

    SELECT    terms_id,
              ship_via_lookup_code,
              fob_lookup_code,
              freight_terms_lookup_code,
              shipping_control    -- <INBOUND LOGISTICS FPJ>
    INTO      x_terms_id,
              x_ship_via_lookup_code,
              x_fob_lookup_code,
              x_freight_terms_lookup_code,
              x_shipping_control    -- <INBOUND LOGISTICS FPJ>
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

EXCEPTION
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('get_terms_conditions','000',sqlcode);
        raise;

END get_terms_conditions;



/*===========================================================================

 PROCEDURE NAME :  get_displayed_values()

===========================================================================*/

 procedure get_displayed_values(X_res_fob IN varchar2, X_res_freight_terms IN varchar2,
                                X_res_ship_via IN varchar2, X_res_terms_id IN number,
                            X_fob_dsp IN OUT NOCOPY varchar2, X_freight_terms_dsp IN OUT NOCOPY varchar2,
                            X_ship_via_dsp IN OUT NOCOPY varchar2, X_terms_dsp IN OUT NOCOPY varchar2,
                            X_org_id IN number) is

         X_progress varchar2(3) := '';

         /* The foll. 2 variables are just defined as the get_displayed_value
         ** proc insists on returning it. We do not use the description  */

         X_fob_desc  varchar2(240) ;
         X_freight_terms_desc  varchar2(240);

         /* This is to tell get_displayed_value
         ** proc that it needs to get the
         ** displayed field ONLY for a valid code */

         X_validate boolean := TRUE ;

 begin

      /* Get the displayed value for  LOKKUP_TYPE = 'FOB' */

       po_core_s.get_displayed_value('FOB', X_res_fob, X_fob_dsp, X_fob_desc,
                                       X_validate );

     /*  begin
            X_progress := '010';

           -- Get the displayed value for a given FOB lookup Code

            select displayed_field
            into   X_fob_dsp
            from   po_lookup_codes
            where  lookup_type = 'FOB'
            and    sysdate < nvl(inactive_date, sysdate + 1)
            and    lookup_code = X_res_fob;
       exception

             when no_data_found then
                  X_fob_dsp := '';
             when too_many_rows then
                  X_fob_dsp := '';
             when others then
                   po_message_s.sql_error('get_displayed_values',X_progress,sqlcode);
                   raise;
       end;   */

   /* Get the displayed value for a given Lookup_Type = 'FREIGHT TERMS'*/

        po_core_s.get_displayed_value('FREIGHT TERMS', X_res_freight_terms,
                                       X_freight_terms_dsp,
                                       X_freight_terms_desc, X_validate );


   /*    begin
            X_progress := '020';

           --Get the displayed value for a given Freight Terms Lookup Type

            select displayed_field
            into   X_freight_terms_dsp
            from   po_lookup_codes
            where  lookup_type = 'FREIGHT TERMS'
            and    sysdate < nvl(inactive_date, sysdate + 1)
            and    lookup_code = X_res_freight_terms  ;

       exception

             when no_data_found then
                  X_freight_terms_dsp := '';
             when too_many_rows then
                  X_freight_terms_dsp := '';
             when others then
                   po_message_s.sql_error('get_displayed_values',X_progress,sqlcode);
                   raise;
       end;    */

      /* There is no po_core rooutine to return this  */

       begin
             X_progress := '030';

             /* Get the displayed value for a given Ship Via  Lookup Code */

             select  description
             into    X_ship_via_dsp
             from    org_freight
             where  organization_id = X_org_id
             and    freight_code    = X_res_ship_via
             and    nvl(disable_date, sysdate + 1) > sysdate;

       exception

             when no_data_found then
                  X_ship_via_dsp := '';
             when too_many_rows then
                  X_ship_via_dsp := '';
             when others then
                   po_message_s.sql_error('get_displayed_values',X_progress,sqlcode);
                   raise;
       end;

      /* No equivalent routine in PO CORE for this one too */

       begin
            X_progress := '040';

            /* Get the displayed value for a given Terms Id*/

            select name
            into   X_terms_dsp
            from ap_terms
            where term_id = X_res_terms_id;

      exception

             when no_data_found then
                  X_terms_dsp := '';
             when too_many_rows then
                  X_terms_dsp := '';
             when others then
                   po_message_s.sql_error('get_displayed_values',X_progress,sqlcode);
                   raise;
       end;

end get_displayed_values;


/*=============================================================================

    FUNCTION:        get_terms_dsp                  <GA FPI>

    DESCRIPTION:     Gets the displayed form of the terms ID.

=============================================================================*/
FUNCTION get_terms_dsp
(
    p_terms_id               AP_TERMS.term_id%TYPE
)
RETURN AP_TERMS.name%TYPE
IS
    x_terms_dsp          AP_TERMS.name%TYPE;

BEGIN

    SELECT    name
    INTO      x_terms_dsp
    FROM      ap_terms
    WHERE     term_id = p_terms_id;

    return (x_terms_dsp);

EXCEPTION
    WHEN OTHERS THEN
        return (NULL);

END get_terms_dsp;


/*===========================================================================

 PROCEDURE NAME :  get_ship_to_loc_attributes()

===========================================================================*/

 procedure get_ship_to_loc_attributes ( X_temp_ship_to_loc_id IN number, X_ship_to_loc_dsp IN OUT NOCOPY varchar2,
                                        X_ship_org_code IN OUT NOCOPY varchar2, X_ship_org_name IN OUT NOCOPY varchar2,
                                        X_ship_org_id IN OUT NOCOPY number, X_set_of_books_id IN number) is

     X_progress varchar2(3) := '';
     X_inv_org_id number;


 begin

           X_progress := '010';

          /* select location_code
           into   X_ship_to_loc_dsp
           from   hr_locations
           where  location_id = X_temp_ship_to_loc_id;*/

           /* Get the location_code ,inv_org_id for a given location */

           po_locations_s.get_loc_attributes(X_temp_ship_to_loc_id,X_ship_to_loc_dsp,
                                             X_inv_org_id);

           X_progress := '020';

        /*   select ood.organization_code,
                  ood.organization_name,
                  ood.organization_id
          into    X_ship_org_code,
                  X_ship_org_name,
                  X_ship_org_id
          from org_organization_definitions ood,
               hr_locations hrl
          where hrl.ship_to_location_id = X_temp_ship_to_loc_id
          and   hrl.inventory_organization_id = ood.organization_id(+)
          and   ( ood.set_of_books_id IS NULL
                 or ood.set_of_books_id = X_set_of_books_id);  */

          /* Get the Org name, Org id of the location's inventory Org */

         /* select ood.organization_code,
                  ood.organization_name,
                  ood.organization_id
          into    X_ship_org_code,
                  X_ship_org_name,
                  X_ship_org_id
          from org_organization_definitions ood
          where ood.organization_id(+) = X_inv_org_id
          and   ( ood.set_of_books_id IS NULL
                 or ood.set_of_books_id = X_set_of_books_id);*/

         /* Get the Org Code and Name for the given Ship-To-Loc's
         ** Inventory Org Id */

           po_orgs_sv.get_org_info(X_inv_org_id, X_set_of_books_id,
                                   X_ship_org_code, X_ship_org_name);

         /* The procedure get_org_info cannot pass back the ORG ID.
         ** If there is an ORG exisiting for that location, need to
         ** populate the ship_to_org_id as well */

           if X_ship_org_code is not null then
              X_ship_org_id := X_inv_org_id;
           end if;

exception

             when no_data_found then
                  X_ship_to_loc_dsp := '';
             when too_many_rows then
                  X_ship_to_loc_dsp := '';
             when others then
                   po_message_s.sql_error('get_ship_to_loc_attributes',X_progress,sqlcode);
                   raise;


end get_ship_to_loc_attributes;


/*===========================================================================

 PROCEDURE NAME :  get_bill_to_loc_attributes()

===========================================================================*/

procedure  get_bill_to_loc_attributes (X_temp_bill_to_loc_id IN number, X_bill_to_loc_dsp IN OUT NOCOPY varchar2) is

         X_progress varchar2(3) := '';
         X_inv_org_id   number;
 begin

             X_progress := '010';

           /*  select location_code
             into   X_bill_to_loc_dsp
             from   hr_locations
             where  location_id = X_temp_bill_to_loc_id; */

            /* Get the Bill_to_location for a given location_id
            ** The third parameter X_inv_org_id is passed back by the procedure, but never used
            ** in this case */

            po_locations_s.get_loc_attributes(X_temp_bill_to_loc_id, X_bill_to_loc_dsp, X_inv_org_id);


 exception

             when no_data_found then
                  X_bill_to_loc_dsp := '';
             when too_many_rows then
                  X_bill_to_loc_dsp := '';
             when others then
                   po_message_s.sql_error('get_bill_to_loc_attributes',X_progress,sqlcode);
                   raise;

 end get_bill_to_loc_attributes;

/* ========================================================================

   PROCEDURE  get_vendor_name()

===========================================================================*/

   PROCEDURE get_vendor_name
		      (X_vendor_id 	     IN     NUMBER,
                       X_vendor_name         IN OUT NOCOPY VARCHAR2) IS

      X_progress varchar2(3) := '';

   /* Get the vendor name associated with the vendor id
   */

      CURSOR C is
         SELECT POV.vendor_name
         FROM   PO_VENDORS POV
         WHERE  POV.vendor_id = X_vendor_id;

 BEGIN

	 -- dbms_output.put_line('Before open cursor');

	 if (X_vendor_id is not null) then

	    X_progress := '010';
            OPEN C;
	    X_progress := '020';

            FETCH C into X_vendor_name;

            CLOSE C;

	     -- dbms_output.put_line('Vendor Name'||X_vendor_name);

         end if;

 EXCEPTION

	when others then
	  -- dbms_output.put_line('In exception');
	  po_message_s.sql_error('get_vendor_name', X_progress, sqlcode);
          raise;
  END get_vendor_name;


/* =========================================================================
   PROCEDURE test_get_vendor()
==============================================================================*/

  PROCEDURE test_get_vendor (X_vendor_id IN NUMBER) IS

   X_vendor_namea PO_VENDORS.VENDOR_NAME%TYPE;  -- Bug 2823775

   BEGIN

   po_vendors_sv.get_vendor_name(X_vendor_id, X_vendor_namea);

   END test_get_vendor;


/* ========================================================================
Bug #508009
   FUNCTION get_vendor_name_func()

===========================================================================*/

 FUNCTION get_vendor_name_func (X_vendor_id  IN      number)

 RETURN VARCHAR2
 IS
        X_vendor_name   PO_VENDORS.VENDOR_NAME%TYPE := ''; -- Bug 2823775
        X_progress      varchar2(3) := '';

 BEGIN

        if X_vendor_id is null then
                X_vendor_name := '';
                RETURN X_vendor_name;
        end if;

        X_progress := '010';

        SELECT pov.vendor_name
        INTO   X_vendor_name
        FROM   po_vendors pov
        WHERE  pov.vendor_id = X_vendor_id;

        RETURN X_vendor_name;

        EXCEPTION
                WHEN OTHERS THEN
   --             po_message_s.sql_error('get_vendor_name',X_progress,sqlcode);
                  raise;

END  get_vendor_name_func;



/*===========================================================================

 PROCEDURE NAME :  get_vendor_details

===========================================================================*/

procedure  get_vendor_details (x_vendor_id      	IN     NUMBER,
		               x_vendor_site_id 	IN     NUMBER,
			       x_vendor_contact_id	IN     NUMBER,
			       x_vendor_name		IN OUT NOCOPY VARCHAR2,
			       x_vendor_location	IN OUT NOCOPY VARCHAR2,
			       x_vendor_contact		IN OUT NOCOPY VARCHAR2,
			       x_vendor_phone		IN OUT NOCOPY VARCHAR2)
IS

x_progress VARCHAR2(3) := '';

BEGIN

  x_progress := '010';

    po_vendors_sv.get_vendor_name (x_vendor_id, x_vendor_name);

  x_progress := '020';

    po_vendor_sites_sv.get_vendor_site_name (x_vendor_site_id,
					     x_vendor_location);
  x_progress := '030';

    po_vendor_contacts_sv.get_contact_info (x_vendor_contact_id,
					    x_vendor_site_id,
					    x_vendor_contact,
					    x_vendor_phone);

EXCEPTION
    WHEN OTHERS THEN
       po_message_s.sql_error('get_vendor_details',x_progress,sqlcode);
       raise;

END get_vendor_details;

/*===========================================================================

 PROCEDURE NAME :  derive_vendor_info()

===========================================================================*/

 PROCEDURE derive_vendor_info (
               p_vendor_record IN OUT NOCOPY rcv_shipment_header_sv.VendorRecType) IS

 cid            INTEGER;
 rows_processed INTEGER;
 sql_str        VARCHAR2(2000);

 vendor_name_null BOOLEAN := TRUE;
 vendor_id_null   BOOLEAN := TRUE;
 vendor_num_null  BOOLEAN := TRUE;

 BEGIN

    sql_str := 'select pov.vendor_name, pov.vendor_id, pov.segment1 from po_vendors pov where ';

    IF p_vendor_record.vendor_name IS NULL   and
       p_vendor_record.vendor_id   IS NULL   and
       p_vendor_record.vendor_num  IS NULL   THEN

          p_vendor_record.error_record.error_status := 'W';
          RETURN;

    END IF;

    IF p_vendor_record.vendor_name IS NOT NULL and
       p_vendor_record.vendor_id IS NOT NULL   and
       p_vendor_record.vendor_num IS NOT NULL     THEN

          p_vendor_record.error_record.error_status := 'S';
          RETURN;

    END IF;

    IF p_vendor_record.vendor_name IS NOT NULL THEN

      sql_str := sql_str || ' pov.vendor_name = :v_name and';
      vendor_name_null := FALSE;

    END IF;

    IF p_vendor_record.vendor_id IS NOT NULL THEN

      sql_str := sql_str || ' pov.vendor_id = :v_id and';
      vendor_id_null := FALSE;

    END IF;

    IF p_vendor_record.vendor_num IS NOT NULL THEN

      sql_str := sql_str || ' pov.segment1 = :v_num and';
      vendor_num_null := FALSE;

    END IF;

    sql_str := substr(sql_str,1,length(sql_str)-3);

    -- dbms_output.put_line(substr(sql_str,1,255));
    -- dbms_output.put_line(substr(sql_str,256,255));
    -- dbms_output.put_line(substr(sql_str,513,255));

    cid := dbms_sql.open_cursor;

     dbms_sql.parse(cid, sql_str , dbms_sql.native);

/* Bug 4885978: Changed the length of vendor_name, vendor_num
                as specified in PO_VENDORS table */

     dbms_sql.define_column(cid,1,p_vendor_record.vendor_name,240);
     dbms_sql.define_column(cid,2,p_vendor_record.vendor_id);
     dbms_sql.define_column(cid,3,p_vendor_record.vendor_num,30);

    IF NOT vendor_name_null THEN

       dbms_sql.bind_variable(cid,'v_name',p_vendor_record.vendor_name);

    END IF;

    IF NOT vendor_id_null THEN

       dbms_sql.bind_variable(cid,'v_id',p_vendor_record.vendor_id);

    END IF;

    IF NOT vendor_num_null THEN

       dbms_sql.bind_variable(cid,'v_num',p_vendor_record.vendor_num);

    END IF;

    rows_processed := dbms_sql.execute_and_fetch(cid);

    IF rows_processed = 1 THEN

       IF vendor_name_null THEN
          dbms_sql.column_value(cid,1,p_vendor_record.vendor_name);
       END IF;

       IF vendor_id_null THEN
          dbms_sql.column_value(cid,2,p_vendor_record.vendor_id);
       END IF;

       IF vendor_num_null THEN
          dbms_sql.column_value(cid,3,p_vendor_record.vendor_num);
       END IF;


       p_vendor_record.error_record.error_status := 'S';

    ELSIF rows_processed = 0 THEN

       p_vendor_record.error_record.error_status := 'W';

    ELSE

       p_vendor_record.error_record.error_status := 'W';

    END IF;


    IF dbms_sql.is_open(cid) THEN
       dbms_sql.close_cursor(cid);
    END IF;

 EXCEPTION
    WHEN others THEN
       IF dbms_sql.is_open(cid) THEN
           dbms_sql.close_cursor(cid);
       END IF;
       p_vendor_record.error_record.error_status := 'U';
       p_vendor_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_vendor_record.error_record.error_message);
       END IF;

 END derive_vendor_info;

/*===========================================================================

 PROCEDURE NAME :  validate_vendor_info()

===========================================================================*/

 PROCEDURE validate_vendor_info (p_vendor_record IN OUT NOCOPY
                                             rcv_shipment_header_sv.VendorRecType) IS

 X_cid integer;
 X_rows_processed integer;
 X_sql_str varchar2(2000) := 'SELECT pov.start_date_active, pov.end_date_active, pov.enabled_flag, pov.hold_flag FROM po_vendors pov where ';

 X_vendor_name_null boolean := TRUE;
 X_vendor_id_null   boolean := TRUE;
 X_vendor_num_null  boolean := TRUE;
 X_sysdate          date    := sysdate;

 X_start_date_active  date;
 X_end_date_active date;
 X_enabled_flag varchar2(1);
 X_hold_flag    varchar2(1);

 BEGIN

  IF p_vendor_record.vendor_id IS NULL and
     p_vendor_record.vendor_name IS NULL and
     p_vendor_record.vendor_num IS NULL THEN

     -- dbms_output.put_line('Major Problem here');
     p_vendor_record.error_record.error_status := 'E';
     p_vendor_record.error_record.error_message := 'All Null';
     RETURN;

  END IF;


  -- Build where clause for selection based on which passed columns have values
  -- Check whether the vendor is enabled
  -- Check that the vendor is not on hold


  IF p_vendor_record.vendor_name IS NOT NULL THEN

      X_sql_str := X_sql_str || ' pov.vendor_name = :v_name and';
      X_vendor_name_null := FALSE;

  END IF;

  IF p_vendor_record.vendor_id IS NOT NULL THEN

     X_sql_str := X_sql_str || ' pov.vendor_id = :v_id and';
     X_vendor_id_null := FALSE;

  END IF;

  IF p_vendor_record.vendor_num IS NOT NULL THEN

     X_sql_str := X_sql_str || ' pov.segment1 = :v_num and';
     X_vendor_num_null := FALSE;

  END IF;

  X_sql_str := substr(X_sql_str,1,length(X_sql_str)-3);

    -- dbms_output.put_line(substr(X_sql_str,1,255));
    -- dbms_output.put_line(substr(X_sql_str,256,255));
    -- dbms_output.put_line(substr(X_sql_str,513,255));

    X_cid := dbms_sql.open_cursor;

    dbms_sql.parse(X_cid, X_sql_str , dbms_sql.native);

    dbms_sql.define_column(X_cid,1,X_start_date_active);
    dbms_sql.define_column(X_cid,2,X_end_date_active);
    dbms_sql.define_column(X_cid,3,X_enabled_flag,1);
    dbms_sql.define_column(X_cid,4,X_hold_flag,1);

    IF NOT X_vendor_name_null THEN

      dbms_sql.bind_variable(X_cid,'v_name',p_vendor_record.vendor_name);

    END IF;

    IF NOT X_vendor_id_null THEN

      dbms_sql.bind_variable(X_cid,'v_id',p_vendor_record.vendor_id);

    END IF;

    IF NOT X_vendor_num_null THEN

      dbms_sql.bind_variable(X_cid,'v_num',p_vendor_record.vendor_num);

    END IF;

    X_rows_processed := dbms_sql.execute_and_fetch(X_cid);

    IF X_rows_processed = 1 THEN

      dbms_sql.column_value(X_cid,1,X_start_date_active);
      dbms_sql.column_value(X_cid,2,X_end_date_active);
      dbms_sql.column_value(X_cid,3,X_enabled_flag);
      dbms_sql.column_value(X_cid,4,X_hold_flag);

      -- Check for whether vendor is enabled in the active date range

       IF  NOT (X_sysdate BETWEEN nvl(X_start_date_active, X_sysdate -1)
           AND                   nvl(X_end_date_active, X_sysdate + 1)
           AND nvl(X_enabled_flag,'Y') = 'Y') then

           -- dbms_output.put_line('Vendor not active');
           p_vendor_record.error_record.error_status := 'E';
           p_vendor_record.error_record.error_message := 'VEN_DISABLED';

           IF dbms_sql.is_open(X_cid) THEN
               dbms_sql.close_cursor(X_cid);
           END IF;

           RETURN;

       END IF;

      -- Check for whether vendor is on hold
       IF NOT nvl(X_hold_flag,'N') = 'N' THEN

          -- dbms_output.put_line('Vendor is on hold');
          p_vendor_record.error_record.error_status := 'E';
          p_vendor_record.error_record.error_message := 'VEN_HOLD';

          IF dbms_sql.is_open(X_cid) THEN
             dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

       p_vendor_record.error_record.error_status := 'S';
       p_vendor_record.error_record.error_message := null;

    ELSIF X_rows_processed = 0 THEN -- No rows found so not a valid Vendor

       p_vendor_record.error_record.error_status := 'E';
       p_vendor_record.error_record.error_message := 'VEN_ID';

    ELSE -- More then 1 row.

       p_vendor_record.error_record.error_status := 'E';
       p_vendor_record.error_record.error_message := 'TOOMANYROWS';

    END IF;

    IF dbms_sql.is_open(X_cid) THEN
       dbms_sql.close_cursor(X_cid);
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;
       p_vendor_record.error_record.error_message := sqlerrm;
       p_vendor_record.error_record.error_status := 'U';
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_vendor_record.error_record.error_message);
       END IF;
       -- raise;

 END validate_vendor_info;

END PO_VENDORS_SV;

/
