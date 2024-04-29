--------------------------------------------------------
--  DDL for Package GMIGAPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMIGAPI" AUTHID CURRENT_USER AS
/* $Header: GMIGAPIS.pls 115.13 2003/09/17 15:46:45 txyu ship $
 +==========================================================================+
 |                   Copyright (c) 1998 Oracle Corporation                  |
 |                          Redwood Shores, CA, USA                         |
 |                            All rights reserved.                          |
 +==========================================================================+
 | FILE NAME                                                                |
 |    GMIGAPIS.pls                                                          |
 |                                                                          |
 | PACKAGE NAME                                                             |
 |    GMIGAPI                                                               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |    This package contains 'Group' specifications for the public APIs      |
 |                                                                          |
 |                                                                          |
 | HISTORY                                                                  |
 |    13/May/2000  P.J.Schofield Bug 1294915 Major performance changes      |
 |                                                                          |
 |    01/Nov/2001  K.RajaSekhar  Bug 1962677 The field journal_comment is   |
 |                               added in qty_rec_typ record.               |
 |    21/Feb/2002  P Lowe        Bug 2233859 - Field ont_pricing_qty_source |
 |                               added in item_rec_typ record for the       |
 |  				 Pricing by Quantity 2 project.             |
 |    07/04/2002  Jalaj Srivastava Bug 2483656
 |                               Added 35 new columns to the qty_rec_typ
 |    07/25/02    Jalaj Srivastava Bug 2485879
 |                               FND_API.G_MISS_DATE should not be used now |
 |                               'coz of performance issues.
 |                               Date fields should not be defaulted to     |
 |                               Sysdate since, then the forms do not accept|
 |                               the record type as valid. Changes made in  |
 |                               lot_rec_typ. Also removed default          |
 |                               assignments of NULL. The fields of a record|
 |                               are by default NULL.
 |    11/11/2002  Joe DiIorio    Bug 2643440 11.5.1J
 |                               Added nocopy to packages.
 |    06/19/2003  Sastry         BUG 2861715
 |                               Added a new column move_entire_qty to the  |
 |                               qty_rec_typ record.                        |
 |    9/11/2003   Teresa Wong    B2378017                                   |
 |                               Added four new classes to item_rec_typ.    |
 +==========================================================================+
*/



TYPE item_rec_typ IS RECORD
( item_no             ic_item_mst.item_no%TYPE
, item_desc1          ic_item_mst.item_desc1%TYPE
, item_desc2          ic_item_mst.item_desc2%TYPE          DEFAULT NULL
, alt_itema           ic_item_mst.alt_itema%TYPE           DEFAULT NULL
, alt_itemb           ic_item_mst.alt_itemb%TYPE           DEFAULT NULL
, item_um             ic_item_mst.item_um%TYPE
, dualum_ind          ic_item_mst.dualum_ind%TYPE          DEFAULT 0
, item_um2            ic_item_mst.item_um2%TYPE            DEFAULT NULL
, deviation_lo        ic_item_mst.deviation_lo%TYPE        DEFAULT 0
, deviation_hi        ic_item_mst.deviation_hi%TYPE        DEFAULT 0
, level_code          ic_item_mst.level_code%TYPE          DEFAULT NULL
, lot_ctl             ic_item_mst.lot_ctl%TYPE             DEFAULT 0
, lot_indivisible     ic_item_mst.lot_indivisible%TYPE     DEFAULT 0
, sublot_ctl          ic_item_mst.sublot_ctl%TYPE          DEFAULT 0
, loct_ctl            ic_item_mst.loct_ctl%TYPE            DEFAULT 0
, noninv_ind          ic_item_mst.noninv_ind%TYPE          DEFAULT 0
, match_type          ic_item_mst.match_type%TYPE          DEFAULT 3
, inactive_ind        ic_item_mst.inactive_ind%TYPE        DEFAULT 0
, inv_type            ic_item_mst.inv_type%TYPE            DEFAULT NULL
, shelf_life          ic_item_mst.shelf_life%TYPE          DEFAULT 0
, retest_interval     ic_item_mst.retest_interval%TYPE     DEFAULT 0
, item_abccode        ic_item_mst.item_abccode%TYPE        DEFAULT NULL
, gl_class            ic_item_mst.gl_class%TYPE            DEFAULT NULL
, inv_class           ic_item_mst.inv_class%TYPE           DEFAULT NULL
, sales_class         ic_item_mst.sales_class%TYPE         DEFAULT NULL
, ship_class          ic_item_mst.ship_class%TYPE          DEFAULT NULL
, frt_class           ic_item_mst.frt_class%TYPE           DEFAULT NULL
, price_class         ic_item_mst.price_class%TYPE         DEFAULT NULL
, storage_class       ic_item_mst.storage_class%TYPE       DEFAULT NULL
, purch_class         ic_item_mst.purch_class%TYPE         DEFAULT NULL
, tax_class           ic_item_mst.tax_class%TYPE           DEFAULT NULL
, customs_class       ic_item_mst.customs_class%TYPE       DEFAULT NULL
, alloc_class         ic_item_mst.alloc_class%TYPE         DEFAULT NULL
, planning_class      ic_item_mst.planning_class%TYPE      DEFAULT NULL
, itemcost_class      ic_item_mst.itemcost_class%TYPE      DEFAULT NULL
, cost_mthd_code      ic_item_mst.cost_mthd_code%TYPE      DEFAULT NULL
, upc_code            ic_item_mst.upc_code%TYPE            DEFAULT NULL
, grade_ctl           ic_item_mst.grade_ctl%TYPE           DEFAULT 0
, status_ctl          ic_item_mst.status_ctl%TYPE          DEFAULT 0
, qc_grade            ic_item_mst.qc_grade%TYPE            DEFAULT NULL
, lot_status          ic_item_mst.lot_status%TYPE          DEFAULT NULL
, bulk_id             ic_item_mst.bulk_id%TYPE             DEFAULT NULL
, pkg_id              ic_item_mst.pkg_id%TYPE              DEFAULT NULL
, qcitem_no           ic_item_mst.item_no%TYPE             DEFAULT NULL
, qchold_res_code     ic_item_mst.qchold_res_code%TYPE     DEFAULT NULL
, expaction_code      ic_item_mst.expaction_code%TYPE      DEFAULT NULL
, fill_qty            ic_item_mst.fill_qty%TYPE            DEFAULT 0
, fill_um             ic_item_mst.fill_um%TYPE             DEFAULT NULL
, expaction_interval  ic_item_mst.expaction_interval%TYPE  DEFAULT 0
, phantom_type        ic_item_mst.phantom_type%TYPE        DEFAULT 0
, whse_item_no        ic_item_mst.item_no%TYPE             DEFAULT NULL
, experimental_ind    ic_item_mst.experimental_ind%TYPE    DEFAULT 0
, exported_date       ic_item_mst.exported_date%TYPE       DEFAULT TO_DATE('02011970','DDMMYYYY')
, seq_dpnd_class      ic_item_mst.seq_dpnd_class%TYPE      DEFAULT NULL
, commodity_code      ic_item_mst.commodity_code%TYPE      DEFAULT NULL
, ic_matr_days        ic_item_cpg.ic_matr_days%TYPE        DEFAULT 0
, ic_hold_days        ic_item_cpg.ic_hold_days%TYPE        DEFAULT 0
, attribute1          ic_item_mst.attribute1%TYPE          DEFAULT NULL
, attribute2          ic_item_mst.attribute2%TYPE          DEFAULT NULL
, attribute3          ic_item_mst.attribute3%TYPE          DEFAULT NULL
, attribute4          ic_item_mst.attribute4%TYPE          DEFAULT NULL
, attribute5          ic_item_mst.attribute5%TYPE          DEFAULT NULL
, attribute6          ic_item_mst.attribute6%TYPE          DEFAULT NULL
, attribute7          ic_item_mst.attribute7%TYPE          DEFAULT NULL
, attribute8          ic_item_mst.attribute8%TYPE          DEFAULT NULL
, attribute9          ic_item_mst.attribute9%TYPE          DEFAULT NULL
, attribute10         ic_item_mst.attribute10%TYPE         DEFAULT NULL
, attribute11         ic_item_mst.attribute11%TYPE         DEFAULT NULL
, attribute12         ic_item_mst.attribute12%TYPE         DEFAULT NULL
, attribute13         ic_item_mst.attribute13%TYPE         DEFAULT NULL
, attribute14         ic_item_mst.attribute14%TYPE         DEFAULT NULL
, attribute15         ic_item_mst.attribute15%TYPE         DEFAULT NULL
, attribute16         ic_item_mst.attribute16%TYPE         DEFAULT NULL
, attribute17         ic_item_mst.attribute17%TYPE         DEFAULT NULL
, attribute18         ic_item_mst.attribute18%TYPE         DEFAULT NULL
, attribute19         ic_item_mst.attribute19%TYPE         DEFAULT NULL
, attribute20         ic_item_mst.attribute20%TYPE         DEFAULT NULL
, attribute21         ic_item_mst.attribute21%TYPE         DEFAULT NULL
, attribute22         ic_item_mst.attribute22%TYPE         DEFAULT NULL
, attribute23         ic_item_mst.attribute23%TYPE         DEFAULT NULL
, attribute24         ic_item_mst.attribute24%TYPE         DEFAULT NULL
, attribute25         ic_item_mst.attribute25%TYPE         DEFAULT NULL
, attribute26         ic_item_mst.attribute26%TYPE         DEFAULT NULL
, attribute27         ic_item_mst.attribute27%TYPE         DEFAULT NULL
, attribute28         ic_item_mst.attribute28%TYPE         DEFAULT NULL
, attribute29         ic_item_mst.attribute29%TYPE         DEFAULT NULL
, attribute30         ic_item_mst.attribute30%TYPE         DEFAULT NULL
, attribute_category  ic_item_mst.attribute_category%TYPE  DEFAULT NULL
, user_name           fnd_user.user_name%TYPE              DEFAULT 'OPM'
, ont_pricing_qty_source ic_item_mst.ont_pricing_qty_source%TYPE  DEFAULT 0
, gl_business_class   mtl_categories_v.category_concat_segs%TYPE      DEFAULT NULL
, gl_prod_line        mtl_categories_v.category_concat_segs%TYPE      DEFAULT NULL
, sub_standard_class  mtl_categories_v.category_concat_segs%TYPE      DEFAULT NULL
, tech_class          mtl_categories_v.category_concat_segs%TYPE      DEFAULT NULL
);

TYPE lot_rec_typ IS RECORD
( item_no           ic_item_mst.item_no%TYPE
, lot_no            ic_lots_mst.lot_no%TYPE
, sublot_no         ic_lots_mst.sublot_no%TYPE
, lot_desc          ic_lots_mst.lot_desc%TYPE
, qc_grade          ic_lots_mst.qc_grade%TYPE
, expaction_code    ic_lots_mst.expaction_code%TYPE
, expaction_date    ic_lots_mst.expaction_date%TYPE
, lot_created       ic_lots_mst.lot_created%TYPE
, expire_date       ic_lots_mst.expire_date%TYPE
, retest_date       ic_lots_mst.retest_date%TYPE
, strength          ic_lots_mst.strength%TYPE           DEFAULT 100
, inactive_ind      ic_lots_mst.inactive_ind%TYPE       DEFAULT 0
, origination_type  ic_lots_mst.origination_type%TYPE   DEFAULT 0
, shipvendor_no     po_vend_mst.vendor_no%TYPE
, vendor_lot_no     ic_lots_mst.vendor_lot_no%TYPE
, ic_matr_date      ic_lots_cpg.ic_matr_date%TYPE
, ic_hold_date      ic_lots_cpg.ic_hold_date%TYPE
, attribute1          ic_lots_mst.attribute1%TYPE
, attribute2          ic_lots_mst.attribute2%TYPE
, attribute3          ic_lots_mst.attribute3%TYPE
, attribute4          ic_lots_mst.attribute4%TYPE
, attribute5          ic_lots_mst.attribute5%TYPE
, attribute6          ic_lots_mst.attribute6%TYPE
, attribute7          ic_lots_mst.attribute7%TYPE
, attribute8          ic_lots_mst.attribute8%TYPE
, attribute9          ic_lots_mst.attribute9%TYPE
, attribute10         ic_lots_mst.attribute10%TYPE
, attribute11         ic_lots_mst.attribute11%TYPE
, attribute12         ic_lots_mst.attribute12%TYPE
, attribute13         ic_lots_mst.attribute13%TYPE
, attribute14         ic_lots_mst.attribute14%TYPE
, attribute15         ic_lots_mst.attribute15%TYPE
, attribute16         ic_lots_mst.attribute16%TYPE
, attribute17         ic_lots_mst.attribute17%TYPE
, attribute18         ic_lots_mst.attribute18%TYPE
, attribute19         ic_lots_mst.attribute19%TYPE
, attribute20         ic_lots_mst.attribute20%TYPE
, attribute21         ic_lots_mst.attribute21%TYPE
, attribute22         ic_lots_mst.attribute22%TYPE
, attribute23         ic_lots_mst.attribute23%TYPE
, attribute24         ic_lots_mst.attribute24%TYPE
, attribute25         ic_lots_mst.attribute25%TYPE
, attribute26         ic_lots_mst.attribute26%TYPE
, attribute27         ic_lots_mst.attribute27%TYPE
, attribute28         ic_lots_mst.attribute28%TYPE
, attribute29         ic_lots_mst.attribute29%TYPE
, attribute30         ic_lots_mst.attribute30%TYPE
, attribute_category  ic_lots_mst.attribute_category%TYPE
, user_name           fnd_user.user_name%TYPE              DEFAULT 'OPM'
);

TYPE conv_rec_typ IS RECORD
(
  item_no               IC_ITEM_MST.item_no%TYPE
, lot_no                IC_LOTS_MST.lot_no%TYPE       DEFAULT NULL
, sublot_no             IC_LOTS_MST.sublot_no%TYPE    DEFAULT NULL
, from_uom              SY_UOMS_MST.um_code%TYPE
, to_uom                SY_UOMS_MST.um_code%TYPE
, type_factor           IC_ITEM_CNV.type_factor%TYPE
, user_name             FND_USER.user_name%TYPE       DEFAULT 'OPM'
);

TYPE qty_rec_typ IS RECORD
(
  trans_type      NUMBER(2)
, item_no         ic_item_mst.item_no%TYPE
, journal_no      ic_jrnl_mst.journal_no%TYPE
, from_whse_code  ic_tran_cmp.whse_code%TYPE
, to_whse_code    ic_tran_cmp.whse_code%TYPE  DEFAULT NULL
, item_um         ic_item_mst.item_um%TYPE    DEFAULT NULL
, item_um2        ic_item_mst.item_um2%TYPE   DEFAULT NULL
, lot_no          ic_lots_mst.lot_no%TYPE     DEFAULT NULL
, sublot_no       ic_lots_mst.sublot_no%TYPE  DEFAULT NULL
, from_location   ic_tran_cmp.location%TYPE   DEFAULT NULL
, to_location     ic_tran_cmp.location%TYPE   DEFAULT NULL
, trans_qty       ic_tran_cmp.trans_qty%TYPE  DEFAULT 0
, trans_qty2      ic_tran_cmp.trans_qty2%TYPE DEFAULT NULL
, qc_grade        ic_tran_cmp.qc_grade%TYPE   DEFAULT NULL
, lot_status      ic_tran_cmp.lot_status%TYPE DEFAULT NULL
, co_code         ic_tran_cmp.co_code%TYPE
, orgn_code       ic_tran_cmp.orgn_code%TYPE
, trans_date      ic_tran_cmp.trans_date%TYPE DEFAULT SYSDATE
, reason_code     ic_tran_cmp.reason_code%TYPE
, user_name       fnd_user.user_name%TYPE     DEFAULT 'OPM'
, journal_comment ic_jrnl_mst.journal_comment%TYPE
, attribute1          ic_jrnl_mst.attribute1%TYPE          DEFAULT NULL
, attribute2          ic_jrnl_mst.attribute2%TYPE          DEFAULT NULL
, attribute3          ic_jrnl_mst.attribute3%TYPE          DEFAULT NULL
, attribute4          ic_jrnl_mst.attribute4%TYPE          DEFAULT NULL
, attribute5          ic_jrnl_mst.attribute5%TYPE          DEFAULT NULL
, attribute6          ic_jrnl_mst.attribute6%TYPE          DEFAULT NULL
, attribute7          ic_jrnl_mst.attribute7%TYPE          DEFAULT NULL
, attribute8          ic_jrnl_mst.attribute8%TYPE          DEFAULT NULL
, attribute9          ic_jrnl_mst.attribute9%TYPE          DEFAULT NULL
, attribute10         ic_jrnl_mst.attribute10%TYPE         DEFAULT NULL
, attribute11         ic_jrnl_mst.attribute11%TYPE         DEFAULT NULL
, attribute12         ic_jrnl_mst.attribute12%TYPE         DEFAULT NULL
, attribute13         ic_jrnl_mst.attribute13%TYPE         DEFAULT NULL
, attribute14         ic_jrnl_mst.attribute14%TYPE         DEFAULT NULL
, attribute15         ic_jrnl_mst.attribute15%TYPE         DEFAULT NULL
, attribute16         ic_jrnl_mst.attribute16%TYPE         DEFAULT NULL
, attribute17         ic_jrnl_mst.attribute17%TYPE         DEFAULT NULL
, attribute18         ic_jrnl_mst.attribute18%TYPE         DEFAULT NULL
, attribute19         ic_jrnl_mst.attribute19%TYPE         DEFAULT NULL
, attribute20         ic_jrnl_mst.attribute20%TYPE         DEFAULT NULL
, attribute21         ic_jrnl_mst.attribute21%TYPE         DEFAULT NULL
, attribute22         ic_jrnl_mst.attribute22%TYPE         DEFAULT NULL
, attribute23         ic_jrnl_mst.attribute23%TYPE         DEFAULT NULL
, attribute24         ic_jrnl_mst.attribute24%TYPE         DEFAULT NULL
, attribute25         ic_jrnl_mst.attribute25%TYPE         DEFAULT NULL
, attribute26         ic_jrnl_mst.attribute26%TYPE         DEFAULT NULL
, attribute27         ic_jrnl_mst.attribute27%TYPE         DEFAULT NULL
, attribute28         ic_jrnl_mst.attribute28%TYPE         DEFAULT NULL
, attribute29         ic_jrnl_mst.attribute29%TYPE         DEFAULT NULL
, attribute30         ic_jrnl_mst.attribute30%TYPE         DEFAULT NULL
, attribute_category  ic_jrnl_mst.attribute_category%TYPE  DEFAULT NULL
, acctg_unit_no       VARCHAR2(240)                        DEFAULT NULL
, acct_no             VARCHAR2(240)                        DEFAULT NULL
, txn_type            VARCHAR2(3)                          DEFAULT NULL
, journal_ind         VARCHAR2(1)                          DEFAULT NULL
, move_entire_qty     VARCHAR2(2)                          DEFAULT 'Y'  --BUG#2861715 Sastry
);

TYPE xfer_rec_typ IS RECORD
(
  action_code              NUMBER(2)
, transfer_no              ic_xfer_mst.transfer_no%TYPE
, orgn_code                ic_xfer_mst.orgn_code%TYPE
, item_no                  ic_item_mst.item_no%TYPE
, lot_no                   ic_lots_mst.lot_no%TYPE              DEFAULT NULL
, sublot_no                ic_lots_mst.sublot_no%TYPE           DEFAULT NULL
, release_reason_code      ic_xfer_mst.release_reason_code%TYPE DEFAULT NULL
, receive_reason_code      ic_xfer_mst.receive_reason_code%TYPE DEFAULT NULL
, cancel_reason_code       ic_xfer_mst.cancel_reason_code%TYPE  DEFAULT NULL
, from_warehouse           ic_xfer_mst.from_warehouse%TYPE      DEFAULT NULL
, from_location            ic_xfer_mst.from_location%TYPE       DEFAULT NULL
, to_warehouse             ic_xfer_mst.to_warehouse%TYPE        DEFAULT NULL
, to_location              ic_xfer_mst.to_location%TYPE         DEFAULT NULL
, release_quantity1        ic_xfer_mst.release_quantity1%TYPE   DEFAULT 0
, release_quantity2        ic_xfer_mst.release_quantity2%TYPE   DEFAULT 0
, release_uom1             ic_xfer_mst.release_uom1%TYPE
, release_uom2             ic_xfer_mst.release_uom2%TYPE
, receive_quantity1        ic_xfer_mst.receive_quantity1%TYPE   DEFAULT 0
, receive_quantity2        ic_xfer_mst.receive_quantity2%TYPE   DEFAULT 0
, scheduled_release_date   ic_xfer_mst.scheduled_release_date%TYPE
, actual_release_date      ic_xfer_mst.actual_release_date%TYPE
, scheduled_receive_date   ic_xfer_mst.scheduled_receive_date%TYPE
, actual_receive_date      ic_xfer_mst.actual_receive_date%TYPE
, cancel_date              ic_xfer_mst.cancel_date%TYPE
, comments                 ic_xfer_mst.comments%TYPE            DEFAULT NULL
, attribute1               ic_lots_mst.attribute1%TYPE          DEFAULT NULL
, attribute2               ic_lots_mst.attribute2%TYPE          DEFAULT NULL
, attribute3               ic_lots_mst.attribute3%TYPE          DEFAULT NULL
, attribute4               ic_lots_mst.attribute4%TYPE          DEFAULT NULL
, attribute5               ic_lots_mst.attribute5%TYPE          DEFAULT NULL
, attribute6               ic_lots_mst.attribute6%TYPE          DEFAULT NULL
, attribute7               ic_lots_mst.attribute7%TYPE          DEFAULT NULL
, attribute8               ic_lots_mst.attribute8%TYPE          DEFAULT NULL
, attribute9               ic_lots_mst.attribute9%TYPE          DEFAULT NULL
, attribute10              ic_lots_mst.attribute10%TYPE         DEFAULT NULL
, attribute11              ic_lots_mst.attribute11%TYPE         DEFAULT NULL
, attribute12              ic_lots_mst.attribute12%TYPE         DEFAULT NULL
, attribute13              ic_lots_mst.attribute13%TYPE         DEFAULT NULL
, attribute14              ic_lots_mst.attribute14%TYPE         DEFAULT NULL
, attribute15              ic_lots_mst.attribute15%TYPE         DEFAULT NULL
, attribute16              ic_lots_mst.attribute16%TYPE         DEFAULT NULL
, attribute17              ic_lots_mst.attribute17%TYPE         DEFAULT NULL
, attribute18              ic_lots_mst.attribute18%TYPE         DEFAULT NULL
, attribute19              ic_lots_mst.attribute19%TYPE         DEFAULT NULL
, attribute20              ic_lots_mst.attribute20%TYPE         DEFAULT NULL
, attribute21              ic_lots_mst.attribute21%TYPE         DEFAULT NULL
, attribute22              ic_lots_mst.attribute22%TYPE         DEFAULT NULL
, attribute23              ic_lots_mst.attribute23%TYPE         DEFAULT NULL
, attribute24              ic_lots_mst.attribute24%TYPE         DEFAULT NULL
, attribute25              ic_lots_mst.attribute25%TYPE         DEFAULT NULL
, attribute26              ic_lots_mst.attribute26%TYPE         DEFAULT NULL
, attribute27              ic_lots_mst.attribute27%TYPE         DEFAULT NULL
, attribute28              ic_lots_mst.attribute28%TYPE         DEFAULT NULL
, attribute29              ic_lots_mst.attribute29%TYPE         DEFAULT NULL
, attribute30              ic_lots_mst.attribute30%TYPE         DEFAULT NULL
, attribute_category       ic_lots_mst.attribute_category%TYPE  DEFAULT NULL
, user_name                fnd_user.user_name%TYPE              DEFAULT 'OPM'
);


PROCEDURE Create_Item
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_item_rec         IN  GMIGAPI.item_rec_typ
, x_ic_item_mst_row  OUT NOCOPY ic_item_mst%ROWTYPE
, x_ic_item_cpg_row  OUT NOCOPY ic_item_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Lot
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_lot_rec          IN  lot_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE
, x_ic_lots_mst_row  OUT NOCOPY ic_lots_mst%ROWTYPE
, x_ic_lots_cpg_row  OUT NOCOPY ic_lots_cpg%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Item_Lot_Conv
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_conv_rec         IN  GMIGAPI.conv_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE
, x_ic_item_cnv_row  OUT NOCOPY ic_item_cnv%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE Inventory_Posting
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_validation_level IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_qty_rec          IN  GMIGAPI.qty_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE
, p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE
, p_ic_lots_cpg_row  IN  ic_lots_cpg%ROWTYPE
, x_ic_jrnl_mst_row  OUT NOCOPY ic_jrnl_mst%ROWTYPE
, x_ic_adjs_jnl_row1 OUT NOCOPY ic_adjs_jnl%ROWTYPE
, x_ic_adjs_jnl_row2 OUT NOCOPY ic_adjs_jnl%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE Inventory_Transfer
( p_api_version      IN  NUMBER
, p_init_msg_list    IN  VARCHAR2
, p_commit           IN  VARCHAR2
, p_validation_level IN  NUMBER
, p_xfer_rec         IN  GMIGAPI.xfer_rec_typ
, p_ic_item_mst_row  IN  ic_item_mst%ROWTYPE
, p_ic_item_cpg_row  IN  ic_item_cpg%ROWTYPE
, p_ic_lots_mst_row  IN  ic_lots_mst%ROWTYPE
, p_ic_lots_cpg_row  IN  ic_lots_cpg%ROWTYPE
, p_ic_xfer_mst_row  OUT NOCOPY ic_xfer_mst%ROWTYPE
, x_ic_xfer_mst_row  OUT NOCOPY ic_xfer_mst%ROWTYPE
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
);
prev_orgn_code ic_jrnl_mst.orgn_code%TYPE DEFAULT NULL;
prev_journal_no ic_jrnl_mst.journal_no%TYPE DEFAULT NULL;

END GMIGAPI;

 

/
