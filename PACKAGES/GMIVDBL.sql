--------------------------------------------------------
--  DDL for Package GMIVDBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIVDBL" AUTHID CURRENT_USER AS
/*  $Header: GMIVDBLS.pls 115.11 2003/09/17 15:51:38 txyu ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |     GMIVDBLS.pls                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | This package specification contains headers and data privately          |
 | accessible from the inventory API processing layers. No other use,      |
 | either public or private is supported.                                  |
 |                                                                         |
 | API NAME                                                                |
 |     GMIVDBL Inventory API Database Layer                                |
 |                                                                         |
 | TYPE                                                                    |
 |     Private                                                             |
 |                                                                         |
 | HISTORY                                                                 |
 |   12-May-2000   P.J.Schofield, OPM Development, Oracle UK               |
 |                 Created for Inventory API Release 3.0                   |
 |   11-Nov-2002   Joe DiIorio Bug#2643440 - 11.5.1J - added nocopy        |
 |   11-Sep-2003   Teresa Wong B2378017 - Added the p_item_rec parameter   |
 |                 to procedure gmi_item_categories in order to insert     |
 |                 categories for both existing and new classes.           |
 +=========================================================================+
*/
  FUNCTION ic_item_mst_insert (p_ic_item_mst_row  IN ic_item_mst%ROWTYPE,
                                x_ic_item_mst_row IN OUT NOCOPY ic_item_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_item_mst_select (p_ic_item_mst_row  IN ic_item_mst%ROWTYPE,
                                x_ic_item_mst_row IN OUT NOCOPY ic_item_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_lots_mst_insert (p_ic_lots_mst_row  IN ic_lots_mst%ROWTYPE,
                                x_ic_lots_mst_row IN OUT NOCOPY ic_lots_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_lots_mst_select (p_ic_lots_mst_row  IN ic_lots_mst%ROWTYPE,
                                x_ic_lots_mst_row IN OUT NOCOPY ic_lots_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_item_cpg_insert (p_ic_item_cpg_row  IN ic_item_cpg%ROWTYPE,
                                x_ic_item_cpg_row IN OUT NOCOPY ic_item_cpg%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_item_cpg_select (p_ic_item_cpg_row  IN ic_item_cpg%ROWTYPE,
                                x_ic_item_cpg_row IN OUT NOCOPY ic_item_cpg%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_lots_cpg_insert (p_ic_lots_cpg_row  IN ic_lots_cpg%ROWTYPE,
                                x_ic_lots_cpg_row IN OUT NOCOPY ic_lots_cpg%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_lots_cpg_select (p_ic_lots_cpg_row  IN ic_lots_cpg%ROWTYPE,
                                x_ic_lots_cpg_row IN OUT NOCOPY ic_lots_cpg%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_lots_sts_select (p_ic_lots_sts_row  IN ic_lots_sts%ROWTYPE,
                                x_ic_lots_sts_row IN OUT NOCOPY ic_lots_sts%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_jrnl_mst_insert (p_ic_jrnl_mst_row  IN ic_jrnl_mst%ROWTYPE,
                                x_ic_jrnl_mst_row IN OUT NOCOPY ic_jrnl_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_jrnl_mst_select (p_ic_jrnl_mst_row  IN ic_jrnl_mst%ROWTYPE,
                                x_ic_jrnl_mst_row IN OUT NOCOPY ic_jrnl_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_whse_mst_select (p_ic_whse_mst_row  IN ic_whse_mst%ROWTYPE,
                                x_ic_whse_mst_row IN OUT NOCOPY ic_whse_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_adjs_jnl_insert (p_ic_adjs_jnl_row  IN ic_adjs_jnl%ROWTYPE,
                                x_ic_adjs_jnl_row IN OUT NOCOPY ic_adjs_jnl%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION sy_reas_cds_select (p_sy_reas_cds_row  IN sy_reas_cds%ROWTYPE,
                                x_sy_reas_cds_row IN OUT NOCOPY sy_reas_cds%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_item_cnv_insert (p_ic_item_cnv_row  IN ic_item_cnv%ROWTYPE,
                                x_ic_item_cnv_row IN OUT NOCOPY ic_item_cnv%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_loct_inv_select (p_ic_loct_inv_row  IN ic_loct_inv%ROWTYPE,
                                x_ic_loct_inv_row IN OUT NOCOPY ic_loct_inv%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION sy_uoms_mst_select (p_sy_uoms_mst_row  IN sy_uoms_mst%ROWTYPE,
                                x_sy_uoms_mst_row IN OUT NOCOPY sy_uoms_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION sy_uoms_typ_select (p_sy_uoms_typ_row  IN sy_uoms_typ%ROWTYPE,
                                x_sy_uoms_typ_row IN OUT NOCOPY sy_uoms_typ%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION qc_actn_mst_select (p_qc_actn_mst_row  IN qc_actn_mst%ROWTYPE,
                                x_qc_actn_mst_row IN OUT NOCOPY qc_actn_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION qc_grad_mst_select (p_qc_grad_mst_row  IN qc_grad_mst%ROWTYPE,
                                x_qc_grad_mst_row IN OUT NOCOPY qc_grad_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION po_vend_mst_select (p_po_vend_mst_row  IN po_vend_mst%ROWTYPE,
                                x_po_vend_mst_row IN OUT NOCOPY po_vend_mst%ROWTYPE)
  RETURN BOOLEAN;

  -- TKW 9/11/2003 B2378017 Changed signature of proc below.
  PROCEDURE gmi_item_categories (p_item_rec  IN GMIGAPI.item_rec_typ, p_ic_item_mst_row  IN ic_item_mst%ROWTYPE);
  PROCEDURE gmi_item_categories_insert (p_ic_item_mst_row  IN ic_item_mst%ROWTYPE,
                                        p_category_set_id NUMBER,
                                        p_category_concat_segs mtl_categories_v.category_concat_segs%TYPE,
                                        p_structure_id NUMBER,
                                        p_category_id  IN OUT NOCOPY NUMBER);

  /*

  FUNCTION ic_xfer_mst_insert (p_ic_xfer_mst_row IN ic_xfer_mst%ROWTYPE,
                                x_ic_xfer_mst_row IN OUT NOCOPY ic_xfer_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_xfer_mst_select (p_ic_xfer_mst_row IN ic_xfer_mst%ROWTYPE,
                                x_ic_xfer_mst_row IN OUT NOCOPY ic_xfer_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_xfer_mst_update (p_ic_xfer_mst_row IN ic_xfer_mst%ROWTYPE,
                                x_ic_xfer_mst_row IN OUT NOCOPY ic_xfer_mst%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION ic_xfer_mst_lock   (p_ic_xfer_mst_row IN ic_xfer_mst%ROWTYPE,
                                x_ic_xfer_mst_row IN OUT NOCOPY ic_xfer_mst%ROWTYPE)
  RETURN BOOLEAN;
  */



  return_status NUMBER;
  error_text    VARCHAR2(512);

END GMIVDBL;

 

/
