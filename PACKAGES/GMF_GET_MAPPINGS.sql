--------------------------------------------------------
--  DDL for Package GMF_GET_MAPPINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GET_MAPPINGS" AUTHID CURRENT_USER AS
/* $Header: gmfactms.pls 120.2 2006/10/03 15:46:27 rseshadr noship $ */

   TYPE account_mappings IS TABLE OF gl_acct_map%ROWTYPE
        INDEX BY BINARY_INTEGER;

   TYPE my_order_by IS TABLE OF NUMBER(2)
	INDEX BY BINARY_INTEGER;

   TYPE my_opm_seg_values IS TABLE OF gl_acct_mst.acct_no%TYPE
       INDEX BY BINARY_INTEGER;
   my_accounts   account_mappings;
   no_of_rows    NUMBER  DEFAULT 0;
   opm_segment_val  my_opm_seg_values;

PROCEDURE get_account_mappings (v_co_code			VARCHAR2,
				   v_orgn_code			VARCHAR2,
				   v_whse_code			VARCHAR2,
			           v_item_id			NUMBER,
				   v_vendor_id			NUMBER,
				   v_cust_id			NUMBER,
				   v_reason_code		VARCHAR2,
                                   v_icgl_class			VARCHAR2,
				   v_vendgl_class		VARCHAR2,
				   v_custgl_class		VARCHAR2,
				   v_currency_code		VARCHAR2,
				   v_routing_id			NUMBER,
				   v_charge_id			NUMBER,
				   v_taxauth_id			NUMBER,
				   v_aqui_cost_id		NUMBER,
				   v_resources			VARCHAR2,
				   v_cost_cmpntcls_id		NUMBER,
                                   v_cost_analysis_code		VARCHAR2,
				   v_order_type			NUMBER,
				   v_sub_event_type		NUMBER,
				   v_source			NUMBER DEFAULT 0,
				   v_business_class_cat_id	NUMBER DEFAULT 0,
				   v_product_line_cat_id	NUMBER DEFAULT 0,
				   v_line_type			NUMBER DEFAULT NULL,
				   v_ar_trx_type_id		NUMBER DEFAULT 0
				 );
FUNCTION get_account_value(v_acct_ttl_type NUMBER) RETURN NUMBER;

TYPE A_segment IS TABLE OF VARCHAR(150) INDEX BY BINARY_INTEGER;

PROCEDURE parse_account(p_co_code       VARCHAR2,
			   p_acct IN       VARCHAR2,
			   p_of_seg IN OUT NOCOPY A_segment);
PROCEDURE get_of_seg(p_co_code       IN VARCHAR2,
		        p_acct_id          NUMBER,
			p_acctg_unit_id IN NUMBER,
			p_of_seg  IN OUT NOCOPY A_segment,
			rc        IN OUT NOCOPY NUMBER);

sv_gl_acct_map		gl_acct_map%ROWTYPE;
sv_acctg_unit_id		gl_accu_map.acctg_unit_id%TYPE;
sv_sub_event_type		gl_sevt_ttl.sub_event_type%TYPE;

PROCEDURE get_account_mappings ( v_co_code 		IN OUT NOCOPY  VARCHAR2,
				    v_orgn_code                 VARCHAR2,
		                    v_whse_code                 VARCHAR2,
		                    v_item_id   		NUMBER,
		                    v_vendor_id 		NUMBER,
		                    v_cust_id   		NUMBER,
				    v_reason_code 		VARCHAR2,
		                    v_icgl_class           	VARCHAR2,
		                    v_vendgl_class         	VARCHAR2,
		                    v_custgl_class         	VARCHAR2,
		                    v_currency_code        	VARCHAR2,
		                    v_routing_id           	NUMBER,
		                    v_charge_id		        NUMBER,
		                    v_taxauth_id           	NUMBER,
		                    v_aqui_cost_id		NUMBER,
		                    v_resources		        VARCHAR2,
		                    v_cost_cmpntcls_id     	NUMBER,
		                    v_cost_analysis_code   	VARCHAR2,
		                    v_order_type		NUMBER,
		                    v_sub_event_type       	NUMBER,
		                    v_acct_ttl_type		NUMBER,
		                    v_acct_id		  IN OUT NOCOPY NUMBER,
		                    v_acctg_unit_id	  IN OUT NOCOPY NUMBER,
				    v_source			NUMBER DEFAULT 0,
				    v_business_class_cat_id	NUMBER DEFAULT 0,
				    v_product_line_cat_id	NUMBER DEFAULT 0,
				    v_line_type			NUMBER DEFAULT NULL,
				    v_ar_trx_type_id		NUMBER DEFAULT 0
				    );

FUNCTION fstrcmp(p_col IN VARCHAR2, p_val IN VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(fstrcmp, WNDS, WNPS, RNPS);

FUNCTION fnumcmp(p_col IN NUMBER, p_val IN NUMBER) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(fnumcmp, WNDS, WNPS, RNPS);

FUNCTION get_opm_segment_values(p_account_value IN VARCHAR2,
                                    p_co_code IN VARCHAR2,
                                    p_type    IN NUMBER) RETURN my_opm_seg_values;

TYPE opm_account IS RECORD (
		acctg_unit_id	NUMBER,
		acct_id		NUMBER);

FUNCTION parse_ccid(
		pi_co_code IN gl_plcy_mst.co_code%TYPE,
		pi_code_combination_id IN NUMBER,
		pi_create_acct IN NUMBER DEFAULT 1)
	RETURN opm_account ;
	-- DETERMINISTIC

END GMF_GET_MAPPINGS;

 

/
