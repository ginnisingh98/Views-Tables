--------------------------------------------------------
--  DDL for Package GMI_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_ITEM_PUB" AUTHID CURRENT_USER AS
-- $Header: GMIPITMS.pls 115.4 2002/10/28 15:08:31 jdiiorio gmigapib.pls $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIPITMS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains public procedures relating to Inventory       |
--|     Item creation.                                                      |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     15-FEB-1999  M.Godfrey       Upgraded to R11                        |
--|     28-OCT-2002  J.DiIorio       Bug#2643440 - added nocopy.            |
--+=========================================================================+
-- API Name  : GMI_ITEM_PUB
-- Type      : Public
-- Function  : This package contains public procedures used to create an
--             inventory item.
-- Pre-reqs  : N/A
-- Parameters: Per function
--
-- Current Vers  : 2.0
--
-- Previous Vers : 1.0
--
-- Initial Vers  : 1.0
-- Notes
--
-- API specific parameters to be presented in SQL RECORD format
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
, exported_date       ic_item_mst.exported_date%TYPE
		      DEFAULT TO_DATE('02011970','DDMMYYYY')
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
);
--
PROCEDURE Create_Item
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2  DEFAULT FND_API.G_FALSE
, p_commit             IN VARCHAR2  DEFAULT FND_API.G_FALSE
, p_validation_level   IN VARCHAR2  DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_item_rec           IN  item_rec_typ
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);
--
PROCEDURE Validate_Item
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2  DEFAULT FND_API.G_FALSE
, p_validation_level   IN VARCHAR2  DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_item_rec           IN  item_rec_typ
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);

END GMI_ITEM_PUB;

 

/
