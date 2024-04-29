--------------------------------------------------------
--  DDL for Package ICX_REQ_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_CUSTOM" AUTHID CURRENT_USER as
/* $Header: ICXRQCUS.pls 115.1 99/07/17 03:23:12 porting ship $ */

  procedure add_user_error(v_cart_id number,
			   error_message varchar2);

  procedure cart_custom_build_req_account( v_cart_line_id  IN NUMBER,
                                     V_ACCOUNT_NUM      OUT VARCHAR2,
                                     V_ACCOUNT_ID       OUT NUMBER,
				     RETURN_CODE	OUT VARCHAR2);


  procedure cart_custom_build_req_account2( v_cart_line_id IN NUMBER,
                                   VARIANCE_ACCOUNT_ID         OUT NUMBER,
                                   BUDGET_ACCOUNT_ID   OUT NUMBER,
                                   ACCRUAL_ACCOUNT_ID  OUT NUMBER,
				   RETURN_CODE	OUT VARCHAR2);


   procedure po_custom_build_req_account(EMPLOYEE_ID  IN NUMBER,
				   employee_default_account_id IN NUMBER,
				   employee_org_id    IN NUMBER,
				   employee_bus_group_id NUMBER,
				   po_org_id          IN NUMBER,
                                   NEED_BY_DATE       IN DATE,
                                   DESTINATION_TYPE   IN VARCHAR2,
                                   DESTINATION_ORG_ID IN NUMBER,
                                   SITE_ID            IN NUMBER,
				   set_of_books_id    IN NUMBER,
                                   ITEM_ID            IN NUMBER,
                                   ITEM_REVISION      IN VARCHAR2,
				   ITEM_DESCRIPTION   IN VARCHAR2,
				   item_default_account_id IN NUMBER,
                                   UNIT_OF_MEASURE    IN VARCHAR2,
                                   QUANTITY           IN NUMBER,
                                   PRICE              IN NUMBER,
                                   SUPPLIER_ITEM_NUM  IN VARCHAR2,
                                   CATEGORY_ID        IN NUMBER,
                                   LINE_TYPE          IN NUMBER,
                                   SUPPLIER           IN VARCHAR2,
                                   SUPPLIER_SITE      IN VARCHAR2,
                                   SOURCE_DOC_NUM     IN VARCHAR2,
                                   SOURCE_LINE_NUM    IN NUMBER,
                                   CHARGE_ACCT_LINE_SEGMENTS IN VARCHAR2,
                                   ACCOUNT_NUM        OUT VARCHAR2,
                                   CHARGE_ACCOUNT_ID         OUT NUMBER,
				   RETURN_CODE	OUT VARCHAR2);


  procedure po_custom_build_req_account2(EMPLOYEE_ID  IN NUMBER,
				   employee_default_account_id IN NUMBER,
				   employee_org_id    IN NUMBER,
				   employee_bus_group_id NUMBER,
				   po_org_id          IN NUMBER,
                                   NEED_BY_DATE       IN DATE,
                                   DESTINATION_TYPE   IN VARCHAR2,
                                   DESTINATION_ORG_ID IN NUMBER,
                                   SITE_ID            IN NUMBER,
				   set_of_books_id    IN NUMBER,
                                   ITEM_ID            IN NUMBER,
                                   ITEM_REVISION      IN VARCHAR2,
				   ITEM_DESCRIPTION   IN VARCHAR2,
				   item_default_account_id IN NUMBER,
                                   UNIT_OF_MEASURE    IN VARCHAR2,
                                   QUANTITY           IN NUMBER,
                                   PRICE              IN NUMBER,
                                   SUPPLIER_ITEM_NUM  IN VARCHAR2,
                                   CATEGORY_ID        IN NUMBER,
                                   LINE_TYPE          IN NUMBER,
                                   SUPPLIER           IN VARCHAR2,
                                   SUPPLIER_SITE      IN VARCHAR2,
                                   SOURCE_DOC_NUM     IN VARCHAR2,
                                   SOURCE_LINE_NUM    IN NUMBER,
                                   CHARGE_ACCT_LINE_SEGMENTS IN VARCHAR2,
                                   CHARGE_ACCOUNT_ID IN NUMBER,
                                   ACCOUNT_NUM        OUT VARCHAR2,
                                   VARIANCE_ACCOUNT_ID         OUT NUMBER,
                                   BUDGET_ACCOUNT_ID   OUT NUMBER,
                                   ACCRUAL_ACCOUNT_ID  OUT NUMBER,
				   RETURN_CODE	OUT VARCHAR2);

 procedure  reqs_validate_head(p_emergency IN VARCHAR2,
                               v_cart_id   IN NUMBER);


 procedure  reqs_validate_line(p_emergency IN VARCHAR2,
                               v_cart_id number);


 procedure reqs_default_lines(p_emergency IN VARCHAR2,
			      cartId IN number);

 procedure  reqs_default_head(p_emergency in VARCHAR2,
			      v_cart_id   in NUMBER);


end icx_req_custom;

 

/
