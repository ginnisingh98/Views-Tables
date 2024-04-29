--------------------------------------------------------
--  DDL for Package Body GML_OM_MIG_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_OM_MIG_VALIDATE_PKG" AS
/* $Header: GMLOMVAB.pls 120.1 2006/09/15 19:34:24 plowe noship $ */

/*===========================================================================
|  Function Name:  VALIDATE_ORDER_NO
|
|  DESCRIPTION
|    Order_no must be numeric or it will not be converted
|
|  MODIFICATION HISTORY
|
============================================================================*/
Function VALIDATE_ORDER_NO(p_order_no in varchar2, order_id in number) return boolean is
 begin
   null;
END validate_order_no;

/*===========================================================================
|  Procedure Name:  VALIDATE_CUSTOMER
|
|  DESCRIPTION
|  validation of the customer id ,check if present in  opm and om
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE VALIDATE_CUSTOMER(p_cust_id in number,
                            v_cust_id out Nocopy number, -- GSCC b4403407 NCOPY
                            order_id in number) IS
  begin
   null;
End validate_customer;

/*===========================================================================
|  Procedure Name:  VALIDATE_SALESREP
|
|  DESCRIPTION
|    Validation of the salesrep id ,check if present in  opm and om
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE validate_salesrep(slsrep_code     IN  VARCHAR2,
                            salesrep_number OUT NOCOPY NUMBER, -- GSCC b4403407 NCOPY
                            order_id        IN  NUMBER) IS
  begin
   null;
 End validate_salesrep;

/*===========================================================================
|  Procedure Name:  VALIDATE_SHIPPER
|
|  DESCRIPTION
|    Validation of the shipper code ,check if present in  opm and om
|
|  MODIFICATION HISTORY
============================================================================*/
PROCEDURE validate_shipper(p_shipper_code       IN  VARCHAR2,
                           p_organization_id    IN  NUMBER,
                           freight_carrier_code OUT NOCOPY VARCHAR2, -- GSCC b4403407 NCOPY
                           p_ship_method_code   IN  VARCHAR2,
                           shipping_method_code OUT NOCOPY VARCHAR2, -- GSCC b4403407 NCOPY
                           order_id             IN  NUMBER) IS

 begin
   null;
END validate_shipper;

/*===========================================================================
|  Procedure Name:  FETCH_FREIGHT_TERMS_CODE
|
|  DESCRIPTION
|    Validation of the frtbill_mthd
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE fetch_freight_terms_code(p_frtbill_mthd in varchar2,
                                   p_freight_terms_code out Nocopy varchar2,
                                   order_id in number) IS
 begin
   null;
END FETCH_FREIGHT_TERMS_CODE;



/*===========================================================================
|  Function Name:  VALIDATE_PAYMENT_TERM
|
|  DESCRIPTION
|    validation of terms code, check if present in opm and om
|
|  MODIFICATION HISTORY
|
============================================================================*/
FUNCTION validate_payment_term(p_terms_code in varchar2,
                               p_term_id out Nocopy number, -- GSCC b4403407 NCOPY
                               order_id in number) RETURN BOOLEAN IS
 begin
   null;

End validate_payment_term;


/*===========================================================================
|  Function Name:  VALIDATE_CURR_CODE
|
|  DESCRIPTION
|    Check that currency code is only 3 characters or it can not be converted
|
|  MODIFICATION HISTORY
|
============================================================================*/
FUNCTION validate_curr_code(currency in varchar2) RETURN BOOLEAN IS
 begin
   null;

End VALIDATE_CURR_CODE;

/*===========================================================================
|  Function Name:  ORGANIZATION_ID
|
|  DESCRIPTION
|    This function gets the organization_id and set of books id
|    from  gl_plcy_mst table
|
|  MODIFICATION HISTORY
|
|  27-DEC-00  NC  getting the org_id from gl_plcy_mst based on the co_code
|		  from sy_orgn_mst for the orgn_code passed. Modified the
|		  parameters.
|
============================================================================*/
PROCEDURE get_org_id(p_orgn_code IN  VARCHAR2,
                     p_order_id  IN  NUMBER,
                     p_sob_id  OUT  NOCOPY NUMBER, -- GSCC b4403407 NCOPY
                     p_org_id    OUT NOCOPY NUMBER ) AS
 begin
   null;
End get_org_id;

/*===========================================================================
|  Procedure Name: ORIG_SYS_DOCUMENT_REF
|
|  DESCRIPTION
|    This function sets the value to 'orgn_code'-'order_number'
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE  orig_sys_document_ref(p_orgn_code in varchar,
        p_orig_sys_document_ref out Nocopy varchar2, -- GSCC b4403407 NCOPY
        p_order_no in varchar2) IS

 begin
   null;


End ORIG_SYS_DOCUMENT_REF;


/*===========================================================================
|  Procedure Name: PRICE_LIST_ID
|
|  DESCRIPTION
|    This Procedure is just a shell for the header
|
|  MODIFICATION HISTORY
|
============================================================================*/
Procedure PRICE_LIST_ID (billing_currency in varchar2, order_id in number, price_list out Nocopy number) is -- GSCC b4403407 NOCOPY
  begin
   null;
End PRICE_LIST_ID;


/*===========================================================================
|  Procedure Name:  SHIP_FROM_ORG_ID
|
|  DESCRIPTION
|    this procedure gets the ship from org_id
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE  ship_from_org_id(p_from_whse in varchar2,
                           ship_from_org_id out Nocopy number, -- GSCC b4403407 NCOPY
                           order_id in number) IS

 begin
   null;
END SHIP_FROM_ORG_ID;


/*===========================================================================
|  Procedure Name:  INVOICE_TO_ORG_ID
|
|  DESCRIPTION
|    This procedure gets the INVOICE_TO_ORG_ID
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE  INVOICE_TO_ORG_ID(p_billcust_id in varchar2,
                         bill_to_org_id out Nocopy number, -- GSCC b4403407 NCOPY
                         order_id in number)
IS
 begin
   null;

End INVOICE_TO_ORG_ID;


/*===========================================================================
|  Procedure Name:  SHIP_TO_ORG_ID
|
|  DESCRIPTION
|    This procedure gets the ship_to_org_id
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE  ship_to_org_id(p_shipcust_id in varchar2,
                         ship_to_org_id out Nocopy number, -- GSCC b4403407 NCOPY
                         order_id in number) IS
 begin
   null;

End SHIP_TO_ORG_ID;

/*===========================================================================
|  Procedure Name:  deliver_to_org_id
|
|  DESCRIPTION
|    This procedure gets the deliver_to_org_id
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE deliver_to_org_id(p_soldtocust_id IN VARCHAR2,
                            deliver_to_org_id OUT NOCOPY NUMBER, -- GSCC b4403407 NCOPY
                            order_id IN NUMBER) IS
  begin
   null;
END deliver_to_org_id;

/*===========================================================================
|  Procedure Name:  SHIP_TO_CONTACT_ID
|
|  DESCRIPTION
|
|  MODIFICATION HISTORY
|
============================================================================*/
Procedure  SHIP_TO_CONTACT_ID(p_contact_id in number,
                              p_org_id IN NUMBER,
                             ship_to_contact_id out Nocopy number, -- GSCC b4403407 NCOPY
                             order_id in number) IS
 begin
   null;

End SHIP_TO_CONTACT_ID;


/*===========================================================================
|  Procedure Name:  ORDER_TYPE_ID
|
|  DESCRIPTION
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE order_type_id(p_order_type in number,
                       p_org_id in number,
                       p_order_type_id out Nocopy number,
		       p_price_list_id out Nocopy number, -- GSCC b4403407 NCOPY
                       order_id in number) IS
 begin
   null;

END ORDER_TYPE_ID;


/*===========================================================================
|  Procedure Name:  FOB_POINT_CODE
|
|  DESCRIPTION
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE  fob_point_code(p_fob_code in varchar2,
                         fob_code out Nocopy varchar2, -- GSCC b4403407 NCOPY
                         order_id in number) IS
 begin
   null;

End FOB_POINT_CODE;

/*===========================================================================
|  Procedure Name:  hold_reason_code
|
|  DESCRIPTION
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE hold_reason_code(p_holdreas_code IN VARCHAR2,
                           order_id IN NUMBER,
                           line_id IN NUMBER,
                           hold_id OUT NOCOPY NUMBER) IS -- GSCC b4403407 NCOPY
 begin
   null;
END hold_reason_code;

/*===========================================================================
|  Procedure Name:  migrate_ship_methods
|
|  DESCRIPTION
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE migrate_ship_methods IS
 begin
   null;
END migrate_ship_methods;

/*===========================================================================
|  Procedure Name:  get_rate_type_code
|
|  DESCRIPTION
|  This procedure gets the rate type code for currency conversions.
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE get_rate_type_code(p_order_id IN NUMBER,
                             p_orgn_code IN VARCHAR2,
                             p_billing_currency IN VARCHAR2,
                             x_rate_type OUT NOCOPY VARCHAR2) IS -- GSCC b4403407 NCOPY
 begin
   null;
END get_rate_type_code;

/*===========================================================================
|  Procedure Name:  ERROR_LOG
|
|  DESCRIPTION
|  This procedure stores the error  messages in ERROR_LOG
|
|  MODIFICATION HISTORY
|
============================================================================*/
PROCEDURE error_log(p_header_id in  NUMBER,
                    p_line_id	in NUMBER,
                    p_column_name in varchar2,
                    p_error_text in varchar2,
                    p_sqlcode in number,
                    p_sqlerr_text in varchar2) IS
  PRAGMA   AUTONOMOUS_TRANSACTION;
 begin
   null;
 end error_log;
END GML_OM_MIG_VALIDATE_PKG;

/
