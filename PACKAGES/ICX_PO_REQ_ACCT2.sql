--------------------------------------------------------
--  DDL for Package ICX_PO_REQ_ACCT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_PO_REQ_ACCT2" AUTHID CURRENT_USER AS
/* $Header: ICXRQA3S.pls 115.1 99/07/17 03:22:22 porting ship $ */

TYPE custom_validate_values IS RECORD (
                employee_default_account_id   NUMBER := NULL,
                employee_org_id               NUMBER := NULL,
                employee_bus_group_id         NUMBER := NULL,
                po_org_id                     NUMBER := NULL,
                NEED_BY_DATE                  DATE := NULL,
                DESTINATION_TYPE_CODE         VARCHAR2(25) := NULL,
                DESTINATION_ORGANIZATION_ID   NUMBER := NULL,
                DELIVER_TO_LOCATION_ID        NUMBER := NULL,
                set_of_books_id               NUMBER(15) := NULL,
                ITEM_ID                       NUMBER := NULL,
                ITEM_REVISION                 VARCHAR2(3) := NULL,
                item_description              VARCHAR2(240) := NULL,
                expense_account               NUMBER := NULL,
                UNIT_MEAS_LOOKUP_CODE         VARCHAR2(25) := NULL,
                QUANTITY                      NUMBER := NULL,
                UNIT_PRICE                    NUMBER := NULL,
                CATEGORY_ID                   NUMBER := NULL,
                LINE_TYPE_ID                  NUMBER := NULL,
                SUGGESTED_VENDOR_NAME         VARCHAR2(80) := NULL,
                SUGGESTED_VENDOR_LOCATION     VARCHAR2(240) := NULL);

v_empty_custom_value_rec custom_validate_values;

PROCEDURE validate_charge_account(v_cart_id IN NUMBER,
                                  v_cart_line_id IN NUMBER,
				  v_line_number IN NUMBER default NULL,
				  v_account_id IN NUMBER default NULL,
				  v_oo_id IN NUMBER default NULL);

PROCEDURE insert_row(v_cart_line_id IN NUMBER,
		     v_oo_id IN NUMBER,
		     v_cart_id IN NUMBER,
	             v_account_id IN NUMBER default NULL,
	             v_n_segments IN NUMBER default NULL,
   		     v_segments IN fnd_flex_ext.SegmentArray,
                     v_account_num IN varchar2 default NULL,
		     v_allocation_type IN VARCHAR2 default NULL,
		     v_allocation_value IN NUMBER default NULL,
                     v_line_quantity IN NUMBER default NULL);

PROCEDURE update_row(v_cart_line_id IN NUMBER,
                     v_oo_id IN NUMBER,
                     v_cart_id IN NUMBER,
		     v_distribution_id IN NUMBER,
		     v_line_number IN NUMBER,
                     v_account_id IN NUMBER default NULL,
                     v_n_segments IN NUMBER default NULL,
                     v_segments IN fnd_flex_ext.SegmentArray,
                     v_account_num IN varchar2 default NULL,
		     v_allocation_type IN varchar2 default NULL,
		     v_allocation_value IN number default NULL,
                     v_line_quantity IN NUMBER default NULL);

PROCEDURE get_acct_by_segs(v_cart_id IN NUMBER,
                           v_line_number IN NUMBER,
                           v_segments IN fnd_flex_ext.SegmentArray,
                           v_structure  IN NUMBER,
			   v_cart_line_id IN NUMBER,
			   v_cart_line_number IN NUMBER default NULL,
                           v_n_segments OUT NUMBER,
                           v_account_num OUT VARCHAR2,
                           v_account_id OUT NUMBER);

PROCEDURE get_acct_by_con(v_cart_id IN NUMBER,
			   v_line_number IN NUMBER,
			   v_account_num IN VARCHAR2,
                           v_structure  IN NUMBER,
			   v_cart_line_id IN NUMBER,
			   v_cart_line_number IN NUMBER default NULL,
                           v_n_segments OUT NUMBER,
                           v_segments OUT fnd_flex_ext.SegmentArray,
                           v_account_id OUT NUMBER);

PROCEDURE get_account_segments(v_cart_id IN NUMBER,
			       v_line_number IN NUMBER,
			       v_account_id IN NUMBER,
                               v_structure IN NUMBER,
			       v_cart_line_id IN NUMBER,
			       v_cart_line_number IN NUMBER default NULL,
                               v_n_segments OUT NUMBER,
                               v_segments OUT fnd_flex_ext.SegmentArray,
                               v_account_num OUT VARCHAR2);

PROCEDURE update_account_num(v_cart_id IN NUMBER,
                         v_cart_line_id IN NUMBER,
                         v_oo_id IN NUMBER,
                         v_account_num IN VARCHAR2,
                         v_distribution_id IN NUMBER default NULL,
                         v_line_number IN NUMBER default NULL,
                         v_allocation_type IN VARCHAR2 default NULL,
                         v_allocation_value IN NUMBER default NULL,
		         v_validate_flag IN VARCHAR2 default 'Y',
                         v_line_quantity IN VARCHAR2 default NULL);

PROCEDURE update_account(v_cart_id IN NUMBER,
                         v_cart_line_id IN NUMBER,
                         v_oo_id IN NUMBER,
                         v_segments IN fnd_flex_ext.SegmentArray,
			 v_distribution_id IN NUMBER default NULL,
			 v_line_number IN NUMBER default NULL,
			 v_allocation_type IN VARCHAR2 default NULL,
			 v_allocation_value IN NUMBER default NULL,
		         v_validate_flag IN VARCHAR2 default 'Y',
                         v_line_quantity IN VARCHAR2 default NULL);

PROCEDURE get_default_account (v_cart_id IN NUMBER,
                               v_cart_line_id IN NUMBER,
                               v_emp_id IN NUMBER,
                               v_oo_id IN NUMBER,
                               v_account_id IN OUT NUMBER,
                               v_account_num IN OUT VARCHAR2
                              );

PROCEDURE get_default_segs (v_cart_id IN NUMBER,
			    v_cart_line_id IN NUMBER,
			    v_emp_id IN NUMBER,
			    v_oo_id IN NUMBER,
			    v_segments OUT fnd_flex_ext.SegmentArray);


PROCEDURE update_account_by_id(v_cart_id IN NUMBER,
			       v_cart_line_id IN NUMBER,
			       v_oo_id IN NUMBER,
			       v_distribution_id IN NUMBER,
			       v_line_number IN NUMBER);

END icx_po_req_acct2;

 

/
