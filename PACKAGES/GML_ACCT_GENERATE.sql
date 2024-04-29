--------------------------------------------------------
--  DDL for Package GML_ACCT_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_ACCT_GENERATE" AUTHID CURRENT_USER AS
/* $Header: GMLACTGS.pls 120.1 2005/09/30 13:40:17 pbamb noship $ */

  PROCEDURE  generate_opm_acct(v_destination_type  VARCHAR2,
				v_inv_item_type VARCHAR2, v_subinv_type VARCHAR2,
				v_dest_org_id NUMBER, v_apps_item_id NUMBER,
				v_vendor_site_id NUMBER,
				v_cc_id  IN OUT NOCOPY NUMBER);

  PROCEDURE get_opm_account(v_dest_org_id NUMBER, v_apps_item_id NUMBER,
                          v_vendor_site_id NUMBER, v_opm_account_type VARCHAR2,
                          retcode  IN OUT NOCOPY NUMBER);

  PROCEDURE get_opm_account_type(v_destination_type VARCHAR2,
                                v_inv_item_type VARCHAR2, v_subinv_type VARCHAR2
,
                                v_opm_account_type  OUT NOCOPY VARCHAR2);

   PROCEDURE process_trans (retcode  IN OUT NOCOPY NUMBER);
   FUNCTION  default_mapping RETURN NUMBER;
   FUNCTION  get_acctg_unit_no  RETURN VARCHAR2;
   PROCEDURE get_acct_no(V_acct_no OUT NOCOPY VARCHAR2, V_acct_desc OUT NOCOPY VARCHAR2);


  /* Package Variables.*/
  P_itemglclass             ic_item_mst.GL_CLASS%TYPE;
  P_acctg_unit_id           NUMBER;
  P_base_currency           gl_curr_mst.CURRENCY_CODE%TYPE;
  P_vend_gl_class           po_vend_mst.VENDGL_CLASS%TYPE;
  P_whse_co_code            sy_orgn_mst.co_code%TYPE;
  P_whse_orgn_code          sy_orgn_mst.orgn_code%TYPE;
  P_cust_id                 NUMBER;
  P_reason_code             VARCHAR2(10);
  P_cust_gl_class           op_cust_mst.CUSTGL_CLASS%TYPE;
  P_routing_id              NUMBER;
  P_charge_id               NUMBER;
  P_taxauth_id              NUMBER;
  P_aqui_cost_id            NUMBER ;
  P_resources               VARCHAR2(10);
  P_cost_cmpntcls_id        NUMBER;
  P_cost_analysis_code      cm_cmpt_dtl.COST_ANALYSIS_CODE%TYPE;
  P_order_type              VARCHAR2(5);
  P_sub_event_type          NUMBER(10) DEFAULT 10010;
  P_shipvend_id             NUMBER;
  P_to_whse                 ic_whse_mst.whse_code%TYPE;
  P_item_no                 ic_item_mst.item_no%TYPE;
  P_gl_item_id              NUMBER(10);
  P_acct_id                 NUMBER (10);
  P_acctg_unit_no           gl_accu_mst.ACCTG_UNIT_NO%TYPE;
  P_acct_no                 gl_acct_mst.ACCT_NO%TYPE;
  P_acct_desc               gl_acct_mst.ACCT_DESC%TYPE;
  P_acct_ttl_num            NUMBER;
  P_cc_id		    NUMBER;
  P_gl_business_class_cat_id gl_acct_map.gl_business_class_cat_id%TYPE; /* B2312653 RVK */
  P_gl_product_line_cat_id  gl_acct_map.gl_product_line_cat_id%TYPE; /* B2312653 RVK */

  PROCEDURE set_data (retcode IN OUT NOCOPY NUMBER);

  PROCEDURE get_acct_title(
                        v_opm_account_type VARCHAR2,
                        v_gltitles OUT NOCOPY NUMBER
                        );

  PROCEDURE gen_combination_id(	v_co_code 		IN VARCHAR2,
 				v_acct_id 		IN NUMBER,
 				v_acctg_unit_id 	IN NUMBER,
   				v_combination_id 	IN OUT NOCOPY NUMBER);


  PROCEDURE parse_account(	v_co_code IN VARCHAR2,
  				v_account IN VARCHAR2,
  				v_type IN NUMBER,
  				v_offset IN NUMBER,
  				v_segment IN OUT NOCOPY fnd_flex_ext.SegmentArray,
  				V_no_of_seg IN OUT NOCOPY NUMBER );


END GML_ACCT_GENERATE;
 

/
