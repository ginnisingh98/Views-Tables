--------------------------------------------------------
--  DDL for Package GMD_SPEC_VRS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SPEC_VRS_GRP" AUTHID CURRENT_USER AS
/* $Header: GMDGSVRS.pls 120.2.12010000.2 2009/03/18 21:59:21 plowe ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSVRS.pls                                        |
--| Package Name       : GMD_SPEC_VRS_GRP                                    |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Entity       |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	26-Jul-2002	Created.                             |
--|     SaiKiran        05-May-2004	Added 'Delayed Lot Entry' to the     |
--|                                 signatures of 'get_orgn_quality_details' |
--|                                 and 'check_VR_controls' procedures       |
--|RLNAGARA LPN ME 7027149 08-May-2008  Added new function check_wms_enabled |
--|                                  and signature of check_VR_controls procedure|
--+==========================================================================+
-- End of comments

PROCEDURE validate_mon_vr
(
  p_mon_vr        IN  GMD_MONITORING_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2 DEFAULT 'API'
, p_operation     IN  VARCHAR2
, x_mon_vr        OUT NOCOPY GMD_MONITORING_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE check_for_null_and_fks_in_mvr
(
  p_mon_vr        IN  GMD_MONITORING_SPEC_VRS%ROWTYPE
, p_spec          IN  GMD_SPECIFICATIONS%ROWTYPE
, x_mon_vr        OUT NOCOPY GMD_MONITORING_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION mon_vr_exist(p_mon_vr GMD_MONITORING_SPEC_VRS%ROWTYPE,
                      p_spec   GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN;

PROCEDURE validate_inv_vr
(
  p_inv_vr        IN  GMD_INVENTORY_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2 DEFAULT 'API'
, p_operation     IN  VARCHAR2
, x_inv_vr        OUT NOCOPY GMD_INVENTORY_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE check_for_null_and_fks_in_ivr
(
  p_inv_vr        IN  GMD_INVENTORY_SPEC_VRS%ROWTYPE
, p_spec          IN  GMD_SPECIFICATIONS%ROWTYPE
, x_inv_vr        OUT NOCOPY GMD_INVENTORY_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION inv_vr_exist(p_inv_vr GMD_INVENTORY_SPEC_VRS%ROWTYPE,
                      p_spec   GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN;



PROCEDURE validate_wip_vr
(
  p_wip_vr        IN  GMD_WIP_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2 DEFAULT 'API'
, p_operation     IN  VARCHAR2
, x_wip_vr        OUT NOCOPY GMD_WIP_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE check_for_null_and_fks_in_wvr
(
  p_wip_vr        IN  GMD_WIP_SPEC_VRS%ROWTYPE
, p_spec          IN  GMD_SPECIFICATIONS%ROWTYPE
, x_wip_vr        OUT NOCOPY GMD_WIP_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION wip_vr_exist(p_wip_vr GMD_WIP_SPEC_VRS%ROWTYPE,
                      p_spec   GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN;



PROCEDURE validate_cust_vr
(
  p_cust_vr       IN  GMD_CUSTOMER_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2 DEFAULT 'API'
, p_operation     IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE check_for_null_and_fks_in_cvr
(
  p_cust_vr       IN  gmd_customer_spec_vrs%ROWTYPE
, p_spec          IN  gmd_specifications%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION cust_vr_exist(p_cust_vr GMD_CUSTOMER_SPEC_VRS%ROWTYPE,
                       p_spec    GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN;



PROCEDURE validate_supp_vr
(
  p_supp_vr       IN  GMD_SUPPLIER_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2 DEFAULT 'API'
, p_operation     IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE check_for_null_and_fks_in_svr
(
  p_supp_vr       IN  gmd_supplier_spec_vrs%ROWTYPE
, p_spec          IN  gmd_specifications%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION supp_vr_exist(p_supp_vr GMD_SUPPLIER_SPEC_VRS%ROWTYPE,
                       p_spec    GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN;

PROCEDURE VALIDATE_BEFORE_DELETE_INV_VRS(
	p_spec_id          IN NUMBER,
	p_spec_vr_id       IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_BEFORE_DELETE_WIP_VRS(
	p_spec_id          IN NUMBER,
	p_spec_vr_id       IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_BEFORE_DELETE_CST_VRS(
	p_spec_id          IN NUMBER,
	p_spec_vr_id       IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2);

PROCEDURE VALIDATE_BEFORE_DELETE_SUP_VRS(
	p_spec_id          IN NUMBER,
	p_spec_vr_id       IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2);

PROCEDURE check_who( p_user_id  IN  NUMBER);


PROCEDURE check_COA( p_coa_type              IN VARCHAR2
                   , p_coa_at_ship_ind       IN VARCHAR2
                   , p_coa_at_invoice_ind    IN VARCHAR2
                   , p_coa_req_from_supl_ind IN VARCHAR2);

PROCEDURE check_VR_Controls
                   ( p_VR_type                  IN VARCHAR2
                   , p_lot_optional_on_sample   IN VARCHAR2
		   , p_delayed_lot_entry        IN VARCHAR2 DEFAULT NULL
                   , p_sample_inv_trans_ind     IN VARCHAR2
                   , p_lot_ctl                  IN NUMBER
                   , p_status_ctl               IN VARCHAR2
                   , p_control_lot_attrib_ind   IN VARCHAR2
                   , p_in_spec_lot_status_id       IN NUMBER
                   , p_out_of_spec_lot_status_id   IN NUMBER
                   , p_control_batch_step_ind   IN VARCHAR2
		   , p_auto_complete_batch_step IN VARCHAR2 DEFAULT NULL    -- Bug# 5440347
		   , p_delayed_lpn_entry        IN VARCHAR2 DEFAULT NULL);  --RLNAGARA LPN ME 7027149

--RLNAGARA LPN ME 7027149
FUNCTION check_wms_enabled(p_organization_id IN NUMBER)
RETURN BOOLEAN;

END GMD_SPEC_VRS_GRP;


/
