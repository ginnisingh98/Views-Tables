--------------------------------------------------------
--  DDL for Package ICX_REQ_ACCT2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_ACCT2" AUTHID CURRENT_USER AS
/* $Header: ICXRQA2S.pls 115.1 99/07/17 03:22:17 porting ship $ */


PROCEDURE validate_charge_account(v_cart_id IN NUMBER,
				  v_cart_line_id IN NUMBER,
				  v_line_number IN NUMBER default NULL,
				  v_account_id IN NUMBER default NULL);

PROCEDURE insert_row(v_cart_line_id IN NUMBER,
		     v_oo_id IN NUMBER,
		     v_cart_id IN NUMBER,
	             v_account_id IN NUMBER default NULL,
	             v_n_segments IN NUMBER default NULL,
   		     v_segments IN fnd_flex_ext.SegmentArray,
                     v_account_num IN varchar2 default NULL,
		     v_allocation_type IN VARCHAR2 default NULL,
		     v_allocation_value IN NUMBER default NULL);

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
		     v_allocation_value IN number default NULL);

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
		         v_validate_flag IN VARCHAR2 default 'Y');

PROCEDURE update_account(v_cart_id IN NUMBER,
                         v_cart_line_id IN NUMBER,
                         v_oo_id IN NUMBER,
                         v_segments IN fnd_flex_ext.SegmentArray,
			 v_distribution_id IN NUMBER default NULL,
			 v_line_number IN NUMBER default NULL,
			 v_allocation_type IN VARCHAR2 default NULL,
			 v_allocation_value IN NUMBER default NULL,
		         v_validate_flag IN VARCHAR2 default 'Y');

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

END icx_req_acct2;

 

/
