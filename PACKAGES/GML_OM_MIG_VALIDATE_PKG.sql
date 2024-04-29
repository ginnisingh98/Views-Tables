--------------------------------------------------------
--  DDL for Package GML_OM_MIG_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_OM_MIG_VALIDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: GMLOMVAS.pls 120.1.12000000.2 2007/02/05 19:12:46 plowe ship $ */
-- bug  5840624
g_line_id NUMBER DEFAULT 0;
g_order_id NUMBER DEFAULT 0;
-- DEFINE FUNCTIONS THAT DERIVE THE VALUES FOR OM'S HEADER TABLE
Function VALIDATE_ORDER_NO(p_order_no in varchar2, order_id in number) return boolean;
Function VALIDATE_PAYMENT_TERM(p_terms_code in varchar2, p_term_id out Nocopy number, order_id in number) return boolean; -- GSCC b4403407 NOCOPY
Function VALIDATE_CURR_CODE(currency in varchar2) Return boolean;
Procedure ORDER_TYPE_ID(p_order_type in number, p_org_id in number, p_order_type_id out Nocopy number, -- GSCC b4403407 NOCOPY
                        p_price_list_id out Nocopy number, order_id in number);
Procedure ORIG_SYS_DOCUMENT_REF(p_orgn_code in varchar, p_orig_sys_document_ref out Nocopy varchar2, p_order_no in varchar2);
Procedure PRICE_LIST_ID (billing_currency in varchar2, order_id number, price_list out Nocopy number);
Procedure SHIP_TO_CONTACT_ID(p_contact_id in number, p_org_id IN NUMBER, ship_to_contact_id out Nocopy number,
                             order_id in number);
Procedure SHIP_FROM_ORG_ID(p_from_whse in varchar2, ship_from_org_id out Nocopy number, order_id in number);
Procedure SHIP_TO_ORG_ID(p_shipcust_id in varchar2, ship_to_org_id out Nocopy number, order_id in number);
Procedure INVOICE_TO_ORG_ID(p_billcust_id in varchar2, bill_to_org_id out Nocopy number, order_id in number);
PROCEDURE deliver_to_org_id(p_soldtocust_id IN VARCHAR2, deliver_to_org_id OUT NOCOPY NUMBER, order_id IN NUMBER);
Procedure FOB_POINT_CODE(p_fob_code in varchar2, fob_code out Nocopy varchar2, order_id in number);

-- DEFINE PROCEDURES THAT DERIVE THE VALUES FOR OM'S HEADER TABLE
Procedure VALIDATE_CUSTOMER(p_cust_id in number, v_cust_id out Nocopy number, order_id in number); -- GSCC b4403407 NCOPY
Procedure VALIDATE_SALESREP(slsrep_code in varchar2, salesrep_number out Nocopy number, order_id in number);
PROCEDURE validate_shipper(p_shipper_code in varchar2, p_organization_id IN NUMBER,
                           freight_carrier_code out Nocopy varchar2, p_ship_method_code in varchar2,
                           shipping_method_code OUT NOCOPY VARCHAR2, order_id in number); -- GSCC b4403407 NCOPY

Procedure FETCH_FREIGHT_TERMS_CODE(p_frtbill_mthd in varchar2, p_freight_terms_code out Nocopy varchar2, order_id in number);
PROCEDURE hold_reason_code(p_holdreas_code IN VARCHAR2, order_id IN NUMBER, line_id IN NUMBER, hold_id OUT NOCOPY NUMBER);
PROCEDURE migrate_ship_methods;
PROCEDURE get_rate_type_code(p_order_id IN NUMBER, p_orgn_code IN VARCHAR2, p_billing_currency IN VARCHAR2,
                             x_rate_type OUT NOCOPY VARCHAR2);
Procedure ERROR_LOG(p_header_id in  NUMBER, p_line_id in NUMBER, p_column_name in varchar2,
                    p_error_text in varchar2, p_sqlcode in number, p_sqlerr_text in varchar2);
PROCEDURE GET_ORG_ID(p_orgn_code IN VARCHAR2, p_order_id IN NUMBER, p_sob_id out NUMBER, p_org_id OUT NOCOPY NUMBER); -- GSCC b4403407 NOCOPY

END GML_OM_MIG_VALIDATE_PKG;

 

/
