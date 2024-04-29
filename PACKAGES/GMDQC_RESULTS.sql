--------------------------------------------------------
--  DDL for Package GMDQC_RESULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMDQC_RESULTS" AUTHID CURRENT_USER AS
/*$Header : $ */
function QC_FIND_SPEC (
p_item_id       qc_spec_mst.item_id%type,
p_sample_date   qc_smpl_mst.sample_date%type,
P_orgn_code     qc_spec_mst.orgn_code%type,
P_CUST_ID       qc_spec_mst.CUST_ID%type    default NULL,
P_VENDOR_ID     qc_spec_mst.VENDOR_ID%type  default NULL,
P_LOT_ID        qc_spec_mst.LOT_ID%type     default NULL,
P_WHSE_CODE     qc_spec_mst.WHSE_CODE%type  default NULL,
P_LOCATION      qc_spec_mst.LOCATION%type   default NULL,
P_BATCH_ID      qc_spec_mst.BATCH_ID%type   default NULL,
P_FORMULA_ID    qc_spec_mst.FORMULA_ID%type default NULL,
P_ROUTING_ID    qc_spec_mst.ROUTING_ID%type default NULL,
P_OPRN_ID       qc_spec_mst.OPRN_ID%type    default NULL,
p_routingstep_id qc_spec_mst.routingstep_id%type  default NULL) return varchar2;

 PRAGMA RESTRICT_REFERENCES (qc_find_spec,WNDS,WNPS,RNPS);

END gmdqc_results;

 

/
