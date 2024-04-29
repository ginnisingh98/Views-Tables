--------------------------------------------------------
--  DDL for Package GMI_LOTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_LOTS_PUB" AUTHID CURRENT_USER AS
-- $Header: GMIPLOTS.pls 115.5 2002/10/30 20:24:20 jdiiorio gmigapib.pls $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIPLOTS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains public procedures relating to Lot creation.   |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     17-FEB-1999  M.Godfrey       Upgrade to R11                         |
--|     29-OCT-2002  J.DiIorio       Bug#2643440 11.5.1J - added nocopy     |
--|                                  Removed fnd_miss default for dates.    |
--+=========================================================================+
-- API Name  : GMI_LOTS_PUB
-- Type      : Public
-- Function  : This package contains public procedures used to create an
--             item lot/sublot.
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
TYPE lot_rec_typ IS RECORD
( item_no           ic_item_mst.item_no%TYPE
, lot_no            ic_lots_mst.lot_no%TYPE
, sublot_no         ic_lots_mst.sublot_no%TYPE          DEFAULT NULL
, lot_desc          ic_lots_mst.lot_desc%TYPE           DEFAULT NULL
, qc_grade          ic_lots_mst.qc_grade%TYPE           DEFAULT NULL
, expaction_code    ic_lots_mst.expaction_code%TYPE     DEFAULT NULL
, expaction_date    ic_lots_mst.expaction_date%TYPE     DEFAULT NULL
, lot_created       ic_lots_mst.lot_created%TYPE        DEFAULT SYSDATE
, expire_date       ic_lots_mst.expire_date%TYPE        DEFAULT NULL
, retest_date       ic_lots_mst.retest_date%TYPE        DEFAULT NULL
, strength          ic_lots_mst.strength%TYPE           DEFAULT 100
, inactive_ind      ic_lots_mst.inactive_ind%TYPE       DEFAULT 0
, origination_type  ic_lots_mst.origination_type%TYPE   DEFAULT 0
, shipvendor_no     po_vend_mst.vendor_no%TYPE          DEFAULT NULL
, vendor_lot_no     ic_lots_mst.vendor_lot_no%TYPE      DEFAULT NULL
, ic_matr_date      ic_lots_cpg.ic_matr_date%TYPE       DEFAULT NULL
, ic_hold_date      ic_lots_cpg.ic_hold_date%TYPE       DEFAULT NULL
, attribute1          ic_lots_mst.attribute1%TYPE          DEFAULT NULL
, attribute2          ic_lots_mst.attribute2%TYPE          DEFAULT NULL
, attribute3          ic_lots_mst.attribute3%TYPE          DEFAULT NULL
, attribute4          ic_lots_mst.attribute4%TYPE          DEFAULT NULL
, attribute5          ic_lots_mst.attribute5%TYPE          DEFAULT NULL
, attribute6          ic_lots_mst.attribute6%TYPE          DEFAULT NULL
, attribute7          ic_lots_mst.attribute7%TYPE          DEFAULT NULL
, attribute8          ic_lots_mst.attribute8%TYPE          DEFAULT NULL
, attribute9          ic_lots_mst.attribute9%TYPE          DEFAULT NULL
, attribute10         ic_lots_mst.attribute10%TYPE         DEFAULT NULL
, attribute11         ic_lots_mst.attribute11%TYPE         DEFAULT NULL
, attribute12         ic_lots_mst.attribute12%TYPE         DEFAULT NULL
, attribute13         ic_lots_mst.attribute13%TYPE         DEFAULT NULL
, attribute14         ic_lots_mst.attribute14%TYPE         DEFAULT NULL
, attribute15         ic_lots_mst.attribute15%TYPE         DEFAULT NULL
, attribute16         ic_lots_mst.attribute16%TYPE         DEFAULT NULL
, attribute17         ic_lots_mst.attribute17%TYPE         DEFAULT NULL
, attribute18         ic_lots_mst.attribute18%TYPE         DEFAULT NULL
, attribute19         ic_lots_mst.attribute19%TYPE         DEFAULT NULL
, attribute20         ic_lots_mst.attribute20%TYPE         DEFAULT NULL
, attribute21         ic_lots_mst.attribute21%TYPE         DEFAULT NULL
, attribute22         ic_lots_mst.attribute22%TYPE         DEFAULT NULL
, attribute23         ic_lots_mst.attribute23%TYPE         DEFAULT NULL
, attribute24         ic_lots_mst.attribute24%TYPE         DEFAULT NULL
, attribute25         ic_lots_mst.attribute25%TYPE         DEFAULT NULL
, attribute26         ic_lots_mst.attribute26%TYPE         DEFAULT NULL
, attribute27         ic_lots_mst.attribute27%TYPE         DEFAULT NULL
, attribute28         ic_lots_mst.attribute28%TYPE         DEFAULT NULL
, attribute29         ic_lots_mst.attribute29%TYPE         DEFAULT NULL
, attribute30         ic_lots_mst.attribute30%TYPE         DEFAULT NULL
, attribute_category  ic_lots_mst.attribute_category%TYPE  DEFAULT NULL
, user_name         fnd_user.user_name%TYPE             DEFAULT 'OPM'
);
--
PROCEDURE Create_Lot
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2  DEFAULT FND_API.G_FALSE
, p_commit             IN VARCHAR2  DEFAULT FND_API.G_FALSE
, p_validation_level   IN VARCHAR2  DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_lot_rec            IN  lot_rec_typ
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);
--
PROCEDURE Validate_Lot
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2     DEFAULT FND_API.G_FALSE
, p_validation_level   IN VARCHAR2     DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_lot_rec            IN  lot_rec_typ
, p_item_rec           IN  ic_item_mst%ROWTYPE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);
--

END GMI_LOTS_PUB;

 

/
