--------------------------------------------------------
--  DDL for Package GMD_QC_ERES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QC_ERES_UTILS" AUTHID CURRENT_USER AS
--$Header: GMDGERES.pls 120.4.12010000.2 2009/03/18 20:56:04 plowe ship $

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDVEREB.pls                                        |
--| Package Name       : GMD_QC_ERES_UTILS                                   |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Results Entity             |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar     08-Aug-2002     Created.                             |
--|    RLNAGARA         17-Nov-2005     Created 3 Procedures                 |
--|                                     1. GET_YES_NO                        |
--|                                     2. GET_ITEM_UOM_CALC                 |
--|                                     3. GET_DECIMAL_VALUE                 |
--+==========================================================================+
-- End of comments


  PROCEDURE set_spec_status(p_spec_id IN NUMBER,
                          p_from_status IN VARCHAR2,
                          p_to_status IN VARCHAR2) ;

  PROCEDURE set_spec_vr_status(p_spec_vr_id IN NUMBER,
                             p_entity_type IN VARCHAR2,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2) ;

  PROCEDURE update_vr_status(pentity_type IN VARCHAR2,
                             pspec_vr_id  IN NUMBER,
                             p_to_status IN NUMBER) ;
  FUNCTION chek_spec_validity_eres (p_spec_id IN NUMBER,
                                    p_to_status IN VARCHAR2,
                                    p_event  IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION esig_required (p_event IN VARCHAR2,
                          p_event_key IN VARCHAR2,
                          p_to_status IN VARCHAR2) RETURN BOOLEAN;
  PROCEDURE get_orgn_name(p_orgn_code VARCHAR2,
                          p_orgn_name OUT NOCOPY VARCHAR2);
  PROCEDURE get_user_name(p_user_id VARCHAR2,
                          p_user_name OUT NOCOPY VARCHAR2);
  PROCEDURE get_test_method_code(p_test_method_id VARCHAR2,
                          p_test_method_code OUT NOCOPY VARCHAR2);
  PROCEDURE get_test_method_desc(p_test_method_id VARCHAR2,
                          p_test_method_desc OUT NOCOPY VARCHAR2);

PROCEDURE get_cust_name
(
  p_cust_id   IN  NUMBER
, x_cust_name OUT NOCOPY VARCHAR2
);

PROCEDURE get_org_name
(
  p_org_id   IN  NUMBER
, x_org_name OUT NOCOPY VARCHAR2
);


PROCEDURE get_ship_to_site_name
(
  p_ship_to_site_id   IN  NUMBER
, x_ship_to_site_name OUT NOCOPY VARCHAR2
);

PROCEDURE get_order_number
(
  p_order_id     IN  NUMBER
, x_order_number OUT NOCOPY NUMBER
);


PROCEDURE get_order_type
(
  p_order_id   IN  NUMBER
, x_order_type OUT NOCOPY VARCHAR2
);

PROCEDURE get_order_line
(
  p_order_line_id     IN  NUMBER
, x_order_line_number OUT NOCOPY NUMBER
);

PROCEDURE get_supp_code
(
  p_supp_id   IN  NUMBER
, x_supp_code OUT NOCOPY VARCHAR2
);

PROCEDURE get_supp_name
(
  p_supp_id   IN  NUMBER
, x_supp_name OUT NOCOPY VARCHAR2
);

PROCEDURE get_supp_site_name
(
  p_supp_site_id   IN  NUMBER
, x_supp_site_name OUT NOCOPY VARCHAR2
);

PROCEDURE get_po_number
(
  p_po_id     IN  NUMBER
, x_po_number OUT NOCOPY NUMBER
);

PROCEDURE get_po_line_number
(
  p_po_line_id     IN  NUMBER
, x_po_line_number OUT NOCOPY NUMBER
);


PROCEDURE get_receipt_number
(
  p_receipt_id     IN  NUMBER
, x_receipt_number OUT NOCOPY NUMBER
);

PROCEDURE get_receipt_line_number
(
  p_receipt_line_id     IN  NUMBER
, x_receipt_line_number OUT NOCOPY NUMBER
);

PROCEDURE get_status_code_meaning
(
  p_status_code    IN  NUMBER
, p_entity_type    IN  VARCHAR2
, x_status_meaning OUT NOCOPY VARCHAR2
);

-- added by mahesh to support stability study.

PROCEDURE set_stability_status( p_ss_id IN NUMBER,
                                p_from_status IN VARCHAR2,
                                p_to_status IN VARCHAR2) ;



PROCEDURE get_test_desc
(
  p_test_id    IN  NUMBER
, x_test_desc OUT NOCOPY VARCHAR2
);

PROCEDURE get_ss_time_unit
(
  p_time    IN  VARCHAR2
, x_time_unit OUT NOCOPY VARCHAR2
);

 -- INVCONV, NSRIVAST, START
  PROCEDURE get_orgn_code
  (
     p_orgn_id    VARCHAR2
   , p_orgn_code  OUT NOCOPY VARCHAR2
  );

 PROCEDURE get_item_number
 (
     p_item_id  VARCHAR2
   , p_org_id   VARCHAR2
   , p_item_no  OUT NOCOPY VARCHAR2
  );

 PROCEDURE get_item_number1
 (
     p_item_id  VARCHAR2
   , p_item_no  OUT NOCOPY VARCHAR2
  );

 PROCEDURE get_item_desc
 (
    p_item_id   VARCHAR2
  , p_org_id    VARCHAR2
  , p_item_desc OUT NOCOPY VARCHAR2
 );

 PROCEDURE get_spec_name
 (
      p_spec_id VARCHAR2
    , p_spec_name OUT NOCOPY VARCHAR2
  );

 PROCEDURE get_spec_vers
 (
     p_spec_id VARCHAR2
   , p_spec_vers OUT NOCOPY VARCHAR2
 );

 PROCEDURE get_item_uom
 (
     p_item_id VARCHAR2
   , p_org_id VARCHAR2
   , p_item_uom OUT NOCOPY VARCHAR2
  );

 PROCEDURE get_spec_type
 (   p_spec_type_ind VARCHAR2
   , p_spec_type OUT NOCOPY VARCHAR2
  ) ;

 PROCEDURE get_loc_name
 (   p_loc_id VARCHAR2
   , p_loc_name OUT NOCOPY VARCHAR2
 );

PROCEDURE GET_LOOKUP_VALUE
(    plookup_type       IN VARCHAR2
   , plookup_code       IN VARCHAR2
   , pmeaning           OUT NOCOPY VARCHAR2
) ;

 -- INVCONV, NSRIVAST, END

--RLNAGARA
PROCEDURE GET_YES_NO
(
  p_short IN VARCHAR2 ,
  x_expanded OUT NOCOPY VARCHAR2
);
--RLNAGARA


--RLNAGARA
PROCEDURE GET_ITEM_UOM_CALC
  (
     p_item_id IN VARCHAR2
   , p_organization_id IN VARCHAR2
   , p_spec_id IN VARCHAR2
   , p_test_id IN VARCHAR2
   , x_item_uom OUT NOCOPY VARCHAR2
  );
--RLNAGARA

--RLNAGARA
PROCEDURE GET_DECIMAL_VALUE
  (
     p_value IN VARCHAR2
   , p_test_qty IN VARCHAR2
   , p_test_id IN VARCHAR2
   , x_decimal_value OUT NOCOPY VARCHAR2
  );
--RLNAGARA

--RLNAGARA
PROCEDURE get_disp_meaning(p_sample_id IN NUMBER,
                           p_sampling_event_id IN NUMBER,
                           p_organization_id IN NUMBER,
                           p_disp_type IN VARCHAR2,
                           psample_disposition OUT NOCOPY VARCHAR2 );
--RLNAGARA

--RLNAGARA B3576516
PROCEDURE get_composited(p_event_spec_disp_id IN NUMBER,
			 x_composited OUT NOCOPY VARCHAR2);
--RLNAGARA B3576516

--RLNAGARA LPN ME 7027149
PROCEDURE get_lpn(p_lpn_id IN NUMBER,
                  x_lpn OUT NOCOPY VARCHAR2);

END GMD_QC_ERES_UTILS;


/
