--------------------------------------------------------
--  DDL for Package GMI_MSCA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MSCA_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMIPMSCS.pls 120.0 2005/05/25 16:01:02 appldev noship $   */

-- PL/SQL package to support Java MSCA for GMI
/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 |===========================================================================|
 |                                                                           |
 | PL/SQL Package to support the (Java) GMI Mobile Application. Various      |
 | procedures perform lookups.                                               |
 |                                                                           |
 |                                                                           |
 | Author: Olivier Daboval, OPM Development UK, August 2004                  |
 |                                                                           |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 | Date          Who               What                                      |
 | ====          ===               ====                                      |
 | 10Sep04       odaboval          First version following TDD Review        |
 | 11Oct04       odaboval          Corrected phase to pls from plb in dbdrv  |
 |                                                                           |
 +===========================================================================*/



TYPE t_genref IS REF CURSOR;

FUNCTION get_opm_uom_code(x_apps_unit_meas_lookup_code IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE item_no_lov
( x_itemNo_cursor    OUT NOCOPY t_genref
, p_item_no          IN  VARCHAR2
, p_item_desc        IN  VARCHAR2
);

PROCEDURE loct_lov
( x_loct_cursor      OUT NOCOPY t_genref
, p_loct             IN  VARCHAR2
, p_whse_code        IN  VARCHAR2
);

PROCEDURE lot_lov
( x_lot_cursor    OUT NOCOPY t_genref
, p_lot           IN  VARCHAR2
, p_sublot        IN  VARCHAR2
, p_item_no       IN  VARCHAR2
, p_whse_code     IN  VARCHAR2
, p_location      IN  VARCHAR2
);

PROCEDURE orgn_lov
( x_orgn_cursor    OUT NOCOPY t_genref
, p_orgn           IN  VARCHAR2
, p_user_id        IN  NUMBER
);

PROCEDURE reason_lov
( x_reason_cursor  OUT NOCOPY t_genref
, p_reason         IN  VARCHAR2
, p_doc_type       IN  VARCHAR2
);

PROCEDURE sublot_lov
( x_sublot_cursor OUT NOCOPY t_genref
, p_sublot        IN  VARCHAR2
, p_lot           IN  VARCHAR2
, p_item_no       IN  VARCHAR2
);

PROCEDURE uom_lov
( x_uom_cursor      OUT NOCOPY t_genref
, p_uom             IN  VARCHAR2
, p_item_no         IN  VARCHAR2
);

PROCEDURE whse_lov
( x_subInv_cursor  OUT NOCOPY t_genref
, p_whse_code      IN  VARCHAR2
, p_orgn_code      IN  VARCHAR2
, p_user_id        IN  NUMBER
);

PROCEDURE to_whse_lov
( x_subInv_cursor    OUT NOCOPY t_genref
, p_whse_code        IN  VARCHAR2
, p_from_whse_code   IN  VARCHAR2
, p_orgn_code        IN  VARCHAR2
, p_user_id          IN  NUMBER
);

PROCEDURE to_loct_lov
( x_loct_cursor      OUT NOCOPY t_genref
, p_loct             IN  VARCHAR2
, p_whse_code        IN  VARCHAR2
, p_from_whse        IN  VARCHAR2
, p_from_loct        IN  VARCHAR2
);

PROCEDURE Create_Transaction
( p_user_name     IN VARCHAR2
, p_doc_type      IN VARCHAR2
, p_item_no       IN VARCHAR2
, p_whse_code     IN VARCHAR2
, p_orgn_code     IN VARCHAR2
, p_co_code       IN VARCHAR2
, p_location      IN VARCHAR2
, p_lot_no        IN VARCHAR2
, p_sublot_no     IN VARCHAR2
, p_qc_grade      IN VARCHAR2
, p_lot_status    IN VARCHAR2
, p_reason_code   IN VARCHAR2
, p_trans_qty1    IN NUMBER
, p_trans_UOM1    IN VARCHAR2
, p_trans_qty2    IN NUMBER
, p_trans_UOM2    IN VARCHAR2
, p_to_whse_code  IN VARCHAR2
, p_to_location   IN VARCHAR2
, x_return_value  OUT NOCOPY NUMBER
, x_message       OUT NOCOPY VARCHAR2);

PROCEDURE get_lot_status
( p_item_id          IN  NUMBER
, p_whse_code        IN  VARCHAR2
, p_location         IN  VARCHAR2
, p_lot_id           IN  NUMBER
, p_lot_status       IN  VARCHAR2
, x_lot_status       OUT NOCOPY VARCHAR2
);

END gmi_msca_pub;

 

/
