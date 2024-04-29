--------------------------------------------------------
--  DDL for Package GMI_QUANTITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_QUANTITY_PUB" AUTHID CURRENT_USER AS
-- $Header: GMIPQTYS.pls 115.3 2002/10/28 20:11:29 jdiiorio gmigapib.pls $
--+=========================================================================+
--|                Copyright (c) 1998 Oracle Corporation                    |
--|                        TVP, Reading, England                            |
--|                         All rights reserved                             |
--+=========================================================================+
--| FILENAME                                                                |
--|     GMIPQTYS.pls                                                        |
--|                                                                         |
--| DESCRIPTION                                                             |
--|     This package contains public procedures relating creation of        |
--|     inventory quantity transactions.                                    |
--|                                                                         |
--| HISTORY                                                                 |
--|     01-OCT-1998  M.Godfrey       Created                                |
--|     25-FEB-1999  M.Godfrey       Upgrade to R11                         |
--|     28-OCT-2002  J.DiIorio       Bug#2643440 11.5.1J - added nocopy     |
--+=========================================================================+
-- API Name  : GMI_QUANTITY_PUB
-- Type      : Public
-- Function  : This package contains public procedures used to create
--             inventory quantity transactions.
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
TYPE trans_rec_typ IS RECORD
( trans_type      NUMBER(2)
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
, trans_qty2      ic_tran_cmp.trans_qty2%TYPE DEFAULT 0
, qc_grade        ic_tran_cmp.qc_grade%TYPE   DEFAULT NULL
, lot_status      ic_tran_cmp.lot_status%TYPE DEFAULT NULL
, co_code         ic_tran_cmp.co_code%TYPE
, orgn_code       ic_tran_cmp.orgn_code%TYPE
, trans_date      ic_tran_cmp.trans_date%TYPE DEFAULT SYSDATE
, reason_code     ic_tran_cmp.reason_code%TYPE
, user_name       fnd_user.user_name%TYPE     DEFAULT 'OPM'
);
--
PROCEDURE Inventory_Posting
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2        DEFAULT FND_API.G_FALSE
, p_commit             IN VARCHAR2        DEFAULT FND_API.G_FALSE
, p_validation_level   IN VARCHAR2        DEFAULT FND_API.G_VALID_LEVEL_FULL
, p_trans_rec          IN  trans_rec_typ
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);
--

END GMI_QUANTITY_PUB;

 

/
