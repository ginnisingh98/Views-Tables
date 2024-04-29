--------------------------------------------------------
--  DDL for Package GMD_COA_DATA_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_COA_DATA_NEW" AUTHID CURRENT_USER AS
/* $Header: GMDCOA2S.pls 115.2 2002/12/03 22:31:42 magupta noship $ */
/*  API name: GMD_COA_DATA_NEW
 *  Type:  Group
 *  Function:   gather COA data via business rules
 *                               (customer/global/item-lot hierarchy)
 *  Pre-reqs:  Package assumes validation is done in calling program/form
 *  Parameters for main procedure (populate_coa_data):
 *    IN:  p_api_version   IN NUMBER
 *         p_init_msg_list IN VARCHAR2  optional default = FND_API.G_FALSE
 *         p_commit        IN VARCHAR2  optional default = FND_API.G_FALSE
 *         p_validation_level IN NUMBER optional
 *                                      default = FND_API.G_VALID_LEVEL_FULL
 *         rec_param       IN t_coa_parameters   record of parameters
 *    OUT: x_return_status OUT VARCHAR2(1)
 *         x_msg_count     OUT NUMBER
 *         x_msg_data      OUT VARCHAR2(2000)
 *         tbl_hdr         OUT t_coa_header_tbl
 *         tbl_dtl         OUT t_coa_detail_tbl
 *         tbl_spec_text   OUT t_coa_text_tbl
 *         tbl_rslt_text   OUT t_coa_text_tbl
 *
 *  Version:  2.1
 *  Notes:
 *  End of comments ******************************************************* */

  TYPE t_coa_hdr_rec IS RECORD
       (gmd_coa_id      BINARY_INTEGER,
        order_id        op_ordr_hdr.order_id%TYPE,
        line_id         op_ordr_dtl.line_id%TYPE,
        orgn_code       op_ordr_hdr.orgn_code%TYPE,
        order_no        op_ordr_hdr.order_no%TYPE,
        custpo_no       op_ordr_dtl.custpo_no%TYPE,
        shipdate        op_ordr_dtl.sched_shipdate%TYPE,
        cust_id         op_cust_mst.cust_id%TYPE,
        cust_no         op_cust_mst.custsort_no%TYPE,
        cust_name       op_cust_mst.cust_name%TYPE,
        bol_id          op_bill_lad.bol_id%TYPE,
        bol_no          op_bill_lad.bol_no%TYPE,
        item_id         ic_item_mst.item_id%TYPE,
        item_no         ic_item_mst.item_no%TYPE,
        item_desc       ic_item_mst.item_desc1%TYPE,
        whse_code       ic_whse_mst.whse_code%TYPE,
        whse_name       ic_whse_mst.whse_name%TYPE,
        lot_id          ic_lots_mst.lot_id%TYPE,
        lot_no          ic_lots_mst.lot_no%TYPE,
        lot_desc        ic_lots_mst.lot_desc%TYPE,
        sublot_no       ic_lots_mst.sublot_no%TYPE,
        order_qty1      op_ordr_dtl.order_qty1%TYPE,
        order_qty2      op_ordr_dtl.order_qty2%TYPE,
        order_um1       op_ordr_dtl.order_um1%TYPE,
        order_um2       op_ordr_dtl.order_um2%TYPE,
        ship_qty1       op_ordr_dtl.ship_qty1%TYPE,
        ship_qty2       op_ordr_dtl.ship_qty2%TYPE,
        report_title    VARCHAR2(4)
       );

  TYPE t_coa_dtl_rec IS RECORD
      (gmd_coa_id      BINARY_INTEGER,
       qc_result_id    gmd_results.result_id%TYPE,
       result_date     gmd_results.result_date%TYPE,
       qc_spec_id      gmd_specifications_b.spec_id%TYPE,
       assay_code      gmd_qc_tests_b.test_code%TYPE,
       assay_desc      gmd_qc_tests.test_desc%TYPE,
       result          gmd_results.result_value_char%TYPE,
       specification   gmd_spec_tests_b.target_value_char%TYPE,
       min_spec        gmd_spec_tests_b.min_value_num%TYPE,
       max_spec        gmd_spec_tests_b.max_value_num%TYPE,
       uom             gmd_spec_tests_b.test_uom%TYPE,
       spec_text_code  gmd_specifications_b.text_code%TYPE,
       rslt_text_code  gmd_results.text_code%TYPE,
       coa_sort_order  NUMBER
      );

  TYPE t_coa_text_rec IS RECORD
       (gmd_coa_id     BINARY_INTEGER,
        text_code      qc_text_tbl.text_code%TYPE,
        paragraph_code qc_text_tbl.paragraph_code%TYPE,
        line_no        qc_text_tbl.line_no%TYPE,
        text           qc_text_tbl.text%TYPE
       );

  TYPE t_coa_parameters IS RECORD
       (order_id            op_ordr_hdr.order_id%TYPE,
        orgn_code           op_ordr_hdr.orgn_code%TYPE,
        custpo_no           op_ordr_dtl.custpo_no%TYPE,
        from_shipdate       op_ordr_dtl.sched_shipdate%TYPE,
        to_shipdate         op_ordr_dtl.sched_shipdate%TYPE,
        cust_id             op_cust_mst.cust_id%TYPE,
        bol_id              op_bill_lad.bol_id%TYPE,
        item_id             ic_item_mst.item_id%TYPE,
        whse_code           ic_whse_mst.whse_code%TYPE,
        lot_id              ic_lots_mst.lot_id%TYPE
       );

  TYPE t_coa_header_tbl IS TABLE OF t_coa_hdr_rec  INDEX BY BINARY_INTEGER;

  TYPE t_coa_detail_tbl IS TABLE OF t_coa_dtl_rec  INDEX BY BINARY_INTEGER;

  TYPE t_coa_text_tbl   IS TABLE OF t_coa_text_rec  INDEX BY BINARY_INTEGER;

  /* CONTEXT: GLOBAL */
  v_report_title  VARCHAR2(4) := 'COA';
  empty_header    t_coa_header_tbl;
  empty_detail    t_coa_detail_tbl;
  empty_text      t_coa_text_tbl;

  PROCEDURE Populate_CoA_Data (
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE,
                     p_commit        IN VARCHAR2  := FND_API.G_FALSE,
                     p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                     rec_param       IN  t_coa_parameters,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2,
                     tbl_hdr         OUT NOCOPY t_coa_header_tbl,
                     tbl_dtl         OUT NOCOPY t_coa_detail_tbl,
                     tbl_spec_text   OUT NOCOPY t_coa_text_tbl,
                     tbl_rslt_text   OUT NOCOPY t_coa_text_tbl);

  PROCEDURE Dump_To_Db_Tables (
                     p_api_version   IN NUMBER,
                     p_init_msg_list IN VARCHAR2  := FND_API.G_FALSE,
                     p_commit        IN VARCHAR2  := FND_API.G_FALSE,
                     p_validation_level IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                     tbl_hdr         IN  t_coa_header_tbl,
                     tbl_dtl         IN  t_coa_detail_tbl,
                     tbl_spec_text   IN  t_coa_text_tbl,
                     tbl_rslt_text   IN  t_coa_text_tbl,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_msg_count     OUT NOCOPY NUMBER,
                     x_msg_data      OUT NOCOPY VARCHAR2);

END gmd_coa_data_new;

 

/
