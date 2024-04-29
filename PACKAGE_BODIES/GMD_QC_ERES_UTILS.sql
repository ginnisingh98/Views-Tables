--------------------------------------------------------
--  DDL for Package Body GMD_QC_ERES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_ERES_UTILS" AS
--$Header: GMDGEREB.pls 120.6.12010000.2 2009/03/18 20:52:24 plowe ship $
   --Bug 3222090, magupta removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')
   --forward decl.
   function set_debug_flag return varchar2;
   --l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;


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
--|     RLNAGARA       30-Nov-2005    Added NVL to the cursor in procedure   |
--|					GET_DECIMAL_VALUE                    |
--|   RLNAGARA         30-Jan-2006  Bug # 4918840 Modified the cursors in the|
--|				   Procedures chek_spec_validity_eres,       |
--| 				   get_orgn_name and get_orgn_code           |
--+==========================================================================+
-- End of comments


PROCEDURE set_spec_status(p_spec_id IN NUMBER,
                          p_from_status IN VARCHAR2,
                          p_to_status IN VARCHAR2) IS
  l_signature_status    VARCHAR2(40);
  l_pending_status      VARCHAR2(40);
  l_rework_status       VARCHAR2(40);
BEGIN


  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;

  IF l_signature_status = 'SUCCESS' THEN
    UPDATE gmd_specifications_b
    SET    spec_status = p_to_status
    WHERE  spec_id = p_spec_id;
  ELSIF l_signature_status = 'PENDING' THEN
    l_pending_status := GMD_QC_STATUS_NEXT_PVT.get_pending_status(p_from_status => p_from_status
                                                                 ,p_to_status => p_to_status
                                                                 ,p_entity_type => 'S');
    IF l_pending_status IS NOT NULL THEN
      UPDATE gmd_specifications_b
      SET spec_status  = l_pending_status
      WHERE spec_id    = p_spec_id;
    END IF;
  ELSIF l_signature_status = 'REJECTED' THEN
    l_rework_status := GMD_QC_STATUS_NEXT_PVT.get_rework_status(p_from_status => p_from_status
                                                               ,p_to_status => p_to_status
                                                               ,p_entity_type => 'S');
    IF l_rework_status IS NOT NULL THEN
      UPDATE gmd_specifications_b
      SET spec_status  = l_rework_status
      WHERE spec_id    = p_spec_id;
    END IF;
  END IF;
END set_spec_status;


PROCEDURE set_spec_vr_status(p_spec_vr_id IN NUMBER,
                             p_entity_type IN VARCHAR2,
                             p_from_status IN VARCHAR2,
                             p_to_status IN VARCHAR2) IS
  l_signature_status    VARCHAR2(40);
  l_pending_status      VARCHAR2(40);
  l_rework_status       VARCHAR2(40);
BEGIN

  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;

  IF l_signature_status = 'SUCCESS' THEN
    update_vr_status(p_entity_type,
                  p_spec_vr_id,
                  p_to_status);
  ELSIF l_signature_status = 'PENDING' THEN
    l_pending_status := GMD_QC_STATUS_NEXT_PVT.get_pending_status(p_from_status => p_from_status
                                                                  ,p_to_status => p_to_status
                                                                   ,p_entity_type => 'S');
    IF l_pending_status IS NOT NULL THEN
      update_vr_status(p_entity_type,
                    p_spec_vr_id,
                    l_pending_status);
    END IF;
  ELSIF l_signature_status = 'REJECTED' THEN
    l_rework_status := GMD_QC_STATUS_NEXT_PVT.get_rework_status(p_from_status => p_from_status
                                                               ,p_to_status => p_to_status
                                                               ,p_entity_type => 'S');
    IF l_rework_status IS NOT NULL THEN
      update_vr_status(p_entity_type,
                    p_spec_vr_id,
                    l_rework_status);
    END IF;
  END IF;
END set_spec_vr_status;
  PROCEDURE update_vr_status(pentity_type IN VARCHAR2,
                             pspec_vr_id  IN NUMBER,
                             p_to_status IN NUMBER) IS
  BEGIN

      IF (pentity_type = 'I') THEN
        UPDATE gmd_inventory_spec_vrs
           SET spec_vr_status = p_to_status
         WHERE spec_vr_id = pspec_vr_id;
      ELSIF(pentity_type = 'W') THEN
        UPDATE gmd_wip_spec_vrs
           SET spec_vr_status = p_to_status
          WHERE spec_vr_id = pspec_vr_id;
      ELSIF(pentity_type  = 'C') THEN
        UPDATE gmd_customer_spec_vrs
           SET spec_vr_status = p_to_status
         WHERE spec_vr_id = pspec_vr_id;
       ELSIF(pentity_type = 'S') THEN
         UPDATE gmd_supplier_spec_vrs
           SET spec_vr_status = p_to_status
          WHERE spec_vr_id = pspec_vr_id;
       ELSIF(pentity_type = 'M') THEN
         UPDATE gmd_monitoring_spec_vrs
           SET spec_vr_status = p_to_status
          WHERE spec_vr_id = pspec_vr_id;
       END IF;

  END update_vr_status;

FUNCTION chek_spec_validity_eres (p_spec_id IN NUMBER,
                                    p_to_status IN VARCHAR2,
                                    p_event  IN VARCHAR2)
RETURN BOOLEAN IS
--RLNAGARA Bug # 4918840

  CURSOR Cur_get_validity IS
    SELECT v.spec_vr_id,'I' spec_type
  FROM gmd_inventory_spec_vrs v
 WHERE v.spec_id = p_spec_id
 AND   v.spec_vr_status  < p_to_status
UNION
SELECT v.spec_vr_id,'W' spec_type
  FROM gmd_wip_spec_vrs v
 WHERE v.spec_id = p_spec_id
 AND   v.spec_vr_status  < p_to_status
UNION
SELECT v.spec_vr_id,'C' spec_type
  FROM gmd_customer_spec_vrs v
 WHERE v.spec_id = p_spec_id
 AND   v.spec_vr_status  < p_to_status
UNION
SELECT v.spec_vr_id,'S' spec_type
  FROM gmd_supplier_spec_vrs v
 WHERE v.spec_id = p_spec_id
 AND   v.spec_vr_status  < p_to_status
UNION
SELECT v.spec_vr_id,v.rule_type
  FROM gmd_monitoring_spec_vrs v
 WHERE v.spec_id = p_spec_id
 AND   v.spec_vr_status  < p_to_status
UNION
SELECT v.spec_vr_id,'T' spec_type
  FROM gmd_stability_spec_vrs v
 WHERE v.spec_id = p_spec_id
 AND   v.spec_vr_status  < p_to_status;

--RLNAGARA Bug # 4918840

  l_spec_validity_rule_id  NUMBER;
  l_status  BOOLEAN;
  l_spec_type VARCHAR2(2);
  l_event_name VARCHAR2(40);
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  OPEN Cur_get_validity;
  FETCH Cur_get_validity INTO l_spec_validity_rule_id,l_spec_type;
  WHILE Cur_get_validity%FOUND LOOP
    update_vr_status(pentity_type  => l_spec_type,
                     pspec_vr_id  => l_spec_validity_rule_id,
                     p_to_status => p_to_status);
  SELECT DECODE(l_spec_type,'I','oracle.apps.gmd.qm.spec.vr.inv',
                            'W','oracle.apps.gmd.qm.spec.vr.wip',
                            'C','oracle.apps.gmd.qm.spec.vr.cus',
                            'S','oracle.apps.gmd.qm.spec.vr.sup',
                            'R','oracle.apps.gmd.qm.spec.vr.mon',
                            'L','oracle.apps.gmd.qm.spec.vr.mon')
       INTO l_event_name
   FROM sys.dual;
    EDR_STANDARD.psig_required (p_event => l_event_name
                               ,p_event_key => l_spec_validity_rule_id
                               ,p_status => l_status);

    IF l_status THEN
      ROLLBACK;
      CLOSE Cur_get_validity;
      RETURN TRUE;
    END IF;
    FETCH Cur_get_validity INTO l_spec_validity_rule_id,l_spec_type;
  END LOOP;
  ROLLBACK;
  CLOSE Cur_get_validity;
  RETURN FALSE;
END chek_spec_validity_eres;

FUNCTION esig_required (p_event IN VARCHAR2,
                        p_event_key IN VARCHAR2,
                        p_to_status IN VARCHAR2)
RETURN BOOLEAN IS
  l_status  BOOLEAN;
--  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  /* Lets first update the status of the entity to to status */
  IF p_event = 'oracle.apps.gmd.qm.spec.vr.inv' THEN
    UPDATE gmd_inventory_spec_vrs
    SET spec_vr_status = p_to_status
    WHERE spec_vr_id = p_event_key
    AND   spec_vr_status <> p_to_status;
  ELSIF p_event = 'oracle.apps.gmd.qm.spec.vr.wip' THEN
    UPDATE gmd_wip_spec_vrs
    SET spec_vr_status = p_to_status
    WHERE spec_vr_id = p_event_key
    AND   spec_vr_status <> p_to_status;
  ELSIF p_event = 'oracle.apps.gmd.qm.spec.vr.cus' THEN

   UPDATE gmd_customer_spec_vrs
    SET spec_vr_status = p_to_status
    WHERE spec_vr_id = p_event_key
    AND   spec_vr_status <> p_to_status;
  ELSIF p_event = 'oracle.apps.gmd.qm.spec.vr.sup' THEN
    UPDATE gmd_supplier_spec_vrs
    SET spec_vr_status = p_to_status
    WHERE spec_vr_id = p_event_key
    AND   spec_vr_status <> p_to_status;
  ELSIF p_event = 'oracle.apps.gmd.qm.spec' THEN
    UPDATE gmd_specifications_b
    SET spec_status = p_to_status
    WHERE spec_id = p_event_key
    AND   spec_status <> p_to_status;
  END IF;

  GMA_STANDARD.psig_required (p_event => p_event
                             ,p_event_key => p_event_key
                             ,p_status => l_status);
  --ROLLBACK;
  IF l_status THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

  exception
  when others then
        raise;
END esig_required;

 -- INVCONV, NSRIVAST, START
  PROCEDURE get_orgn_name(p_orgn_code VARCHAR2,
                          p_orgn_name OUT NOCOPY VARCHAR2) IS
--RLNAGARA Bug # 4918840
    CURSOR Cur_get_organization IS
       SELECT hr.NAME
       FROM MTL_parameters mp, hr_all_organization_units hr
       WHERE mp.ORGANIZATION_CODE =p_orgn_code
       and hr.organization_id = mp.organization_id;


  BEGIN
    OPEN Cur_get_organization;
    FETCH Cur_get_organization INTO P_orgn_name;
    CLOSE Cur_get_organization;
  END get_orgn_name;
 -- INVCONV, NSRIVAST, END
  PROCEDURE get_user_name(p_user_id VARCHAR2,
                          p_user_name OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_user_name IS
      SELECT USER_NAME
      FROM FND_USER
      WHERE user_id = p_user_id;
  BEGIN
    OPEN Cur_get_user_name;
    FETCH Cur_get_user_name INTO P_user_name;
    CLOSE Cur_get_user_name;
  END get_user_name;
  PROCEDURE get_test_method_code(p_test_method_id VARCHAR2,
                          p_test_method_code OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_test_method IS
      SELECT TEST_METHOD_CODE
      FROM  gmd_test_methods
      WHERE TEST_METHOD_ID = p_test_method_id;
  BEGIN
    OPEN Cur_get_test_method;
    FETCH Cur_get_test_method INTO p_test_method_code;
    CLOSE Cur_get_test_method;
  END get_test_method_code;
  PROCEDURE get_test_method_desc(p_test_method_id VARCHAR2,
                          p_test_method_desc OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_test_method IS
      SELECT TEST_METHOD_DESC
      FROM  gmd_test_methods
      WHERE TEST_METHOD_ID = p_test_method_id;
  BEGIN
    OPEN Cur_get_test_method;
    FETCH Cur_get_test_method INTO p_test_method_desc;
    CLOSE Cur_get_test_method;
  END get_test_method_desc;


PROCEDURE get_cust_name
(
  p_cust_id   IN  NUMBER
, x_cust_name OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
    SELECT
        hzp.party_name
    FROM
        hz_parties hzp
      , hz_cust_accounts_all hzca
    WHERE   hzp.party_id = hzca.party_id
    AND     hzca.cust_account_id  = p_cust_id
    ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_cust_name;
  CLOSE c1;
END;



PROCEDURE get_org_name
(
  p_org_id   IN  NUMBER
, x_org_name OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
  SELECT name
  FROM   hr_operating_units
  WHERE  organization_id = p_org_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_org_name;
  CLOSE c1;
END;


PROCEDURE get_ship_to_site_name
(
  p_ship_to_site_id   IN  NUMBER
, x_ship_to_site_name OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
  SELECT location
  FROM   hz_cust_site_uses_all
  WHERE  site_use_id = p_ship_to_site_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_ship_to_site_name;
  CLOSE c1;
END;


PROCEDURE get_order_number
(
  p_order_id     IN  NUMBER
, x_order_number OUT NOCOPY NUMBER
) IS

  CURSOR c1 IS
  SELECT order_number
  FROM   oe_order_headers_all
  WHERE  header_id = p_order_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_order_number;
  CLOSE c1;
END;

PROCEDURE get_order_type
(
  p_order_id   IN  NUMBER
, x_order_type OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
  SELECT b.name
  FROM   oe_order_headers_all a, oe_transaction_types_tl b
  WHERE  a.order_type_id = b.transaction_type_id
  AND    a.header_id = p_order_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_order_type;
  CLOSE c1;
END;

PROCEDURE get_order_line
(
  p_order_line_id     IN  NUMBER
, x_order_line_number OUT NOCOPY NUMBER
) IS

  CURSOR c1 IS
  SELECT line_number
  FROM   oe_order_lines_all
  WHERE  line_id = p_order_line_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_order_line_number;
  CLOSE c1;
END;

PROCEDURE get_supp_code
(
  p_supp_id   IN  NUMBER
, x_supp_code OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
  SELECT segment1
  FROM   po_vendors
  WHERE  vendor_id = p_supp_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_supp_code;
  CLOSE c1;
END;


PROCEDURE get_supp_name
(
  p_supp_id   IN  NUMBER
, x_supp_name OUT NOCOPY VARCHAR2
) IS
  CURSOR c1 IS
  SELECT vendor_name
  FROM   po_vendors
  WHERE  vendor_id = p_supp_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_supp_name;
  CLOSE c1;
END;

PROCEDURE get_supp_site_name
(
  p_supp_site_id   IN  NUMBER
, x_supp_site_name OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
  SELECT vendor_site_code
  FROM   po_vendor_sites_all
  WHERE  vendor_site_id = p_supp_site_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_supp_site_name;
  CLOSE c1;
END;

PROCEDURE get_po_number
(
  p_po_id     IN  NUMBER
, x_po_number OUT NOCOPY NUMBER
) IS

  CURSOR c1 IS
  SELECT segment1
  FROM   po_headers_all
  WHERE  po_header_id = p_po_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_po_number;
  CLOSE c1;
END;

PROCEDURE get_po_line_number
(
  p_po_line_id     IN  NUMBER
, x_po_line_number OUT NOCOPY NUMBER
) IS

  CURSOR c1 IS
  SELECT line_num
  FROM   po_lines_all
  WHERE  po_line_id = p_po_line_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_po_line_number;
  CLOSE c1;
END;


PROCEDURE get_receipt_number
(
  p_receipt_id     IN  NUMBER
, x_receipt_number OUT NOCOPY NUMBER
) IS

  CURSOR c1 IS
  SELECT receipt_num
  FROM   rcv_shipment_headers
  WHERE  shipment_header_id = p_receipt_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_receipt_number;
  CLOSE c1;
END;

PROCEDURE get_receipt_line_number
(
  p_receipt_line_id     IN  NUMBER
, x_receipt_line_number OUT NOCOPY NUMBER
) IS

  CURSOR c1 IS
  SELECT line_num
  FROM   rcv_shipment_lines
  WHERE  shipment_line_id = p_receipt_line_id
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_receipt_line_number;
  CLOSE c1;
END;

PROCEDURE get_status_code_meaning
(
  p_status_code    IN  NUMBER
, p_entity_type    IN  VARCHAR2
, x_status_meaning OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
  SELECT meaning
  FROM   gmd_qc_status
  WHERE  status_code = p_status_code
  AND    entity_type = p_entity_type
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO x_status_meaning;
  CLOSE c1;
END;

-- added by mahesh to support stability study.

PROCEDURE set_stability_status( p_ss_id IN NUMBER,
                                p_from_status IN VARCHAR2,
                                p_to_status IN VARCHAR2) IS
  l_signature_status    VARCHAR2(40);
  l_pending_status      VARCHAR2(40);
  l_rework_status       VARCHAR2(40);
  l_return_status       VARCHAR2(1);

BEGIN

  l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;

  IF l_signature_status = 'SUCCESS' THEN
    UPDATE gmd_stability_studies_b
    SET    status = p_to_status
    WHERE  ss_id = p_ss_id;

    IF (p_to_status = 400) THEN
    -- We got approved, so kick off API to create sampling events
       GMD_SS_WFLOW_GRP.events_for_status_change(p_ss_id ,l_return_status) ;
    ELSIF (p_to_status = 700) THEN
    -- We need to launch; Enable the Mother workflow for testing
       GMD_API_PUB.RAISE('oracle.apps.gmd.qm.ss.test',p_ss_id);
    END IF;

  ELSIF l_signature_status = 'PENDING' THEN
    l_pending_status := GMD_QC_STATUS_NEXT_PVT.get_pending_status(p_from_status => p_from_status
                                                                 ,p_to_status => p_to_status
                                                                 ,p_entity_type => 'STABILITY');
    IF l_pending_status IS NOT NULL THEN
      UPDATE gmd_stability_studies_b
      SET    status = l_pending_status
      WHERE  ss_id = p_ss_id;
    END IF;
  ELSIF l_signature_status = 'REJECTED' THEN
    l_rework_status := GMD_QC_STATUS_NEXT_PVT.get_rework_status(p_from_status => p_from_status
                                                               ,p_to_status => p_to_status
                                                               ,p_entity_type => 'STABILITY');
    IF l_rework_status IS NOT NULL THEN
      UPDATE gmd_stability_studies_b
      SET    status = l_rework_status
      WHERE  ss_id = p_ss_id;
    END IF;
  END IF;
END set_stability_status ;




PROCEDURE get_test_desc
(
  p_test_id    IN  NUMBER
, x_test_desc OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
        select test_desc
        from gmd_qc_tests
        where test_id = p_test_id;

begin
  OPEN c1;
  FETCH c1 INTO x_test_desc;
  CLOSE c1;

end;


/* Get Stability study time unit */
PROCEDURE get_ss_time_unit
(
  p_time    IN  VARCHAR2
, x_time_unit OUT NOCOPY VARCHAR2
) IS

  CURSOR c1 IS
SELECT meaning
       FROM gem_lookups
      WHERE lookup_type = 'GMD_QC_FREQUENCY_PERIOD'
      and   lookup_code = p_time ;

begin
  OPEN c1;
  FETCH c1 INTO x_time_unit;
  CLOSE c1;

end;


 -- INVCONV, NSRIVAST, START
  PROCEDURE get_orgn_code(p_orgn_id VARCHAR2,
                          p_orgn_code OUT NOCOPY VARCHAR2) IS
-- RLNAGARA BUG # 4918840
    CURSOR Cur_get_organization IS
      SELECT ORGANIZATION_CODE
      FROM MTL_PARAMETERS
      WHERE ORGANIZATION_ID = p_orgn_id;
  BEGIN
    OPEN Cur_get_organization;
    FETCH Cur_get_organization INTO p_orgn_code;
    CLOSE Cur_get_organization;
  END get_orgn_code;

  PROCEDURE get_item_number(p_item_id VARCHAR2,
                            p_org_id VARCHAR2,
                            p_item_no OUT NOCOPY VARCHAR2) IS
    CURSOR cur_get_item_no IS
      SELECT concatenated_segments
      FROM mtl_system_items_kfv
      WHERE inventory_item_Id = p_item_id
      AND ORGANIZATION_ID = p_org_id;
  BEGIN
     OPEN cur_get_item_no;
    FETCH cur_get_item_no INTO p_item_no;
    CLOSE cur_get_item_no;
  END get_item_number;

  PROCEDURE get_item_number1(p_item_id VARCHAR2,
                            p_item_no OUT NOCOPY VARCHAR2) IS
    CURSOR cur_get_item_no IS
      SELECT distinct concatenated_segments
      FROM mtl_system_items_kfv
      WHERE inventory_item_Id = p_item_id ;
  BEGIN
     OPEN cur_get_item_no;
    FETCH cur_get_item_no INTO p_item_no;
    CLOSE cur_get_item_no;
  END get_item_number1;

  PROCEDURE get_item_desc(p_item_id VARCHAR2,
                            p_org_id VARCHAR2,
                            p_item_desc OUT NOCOPY VARCHAR2) IS
    CURSOR cur_get_item_desc IS
      SELECT description
      FROM mtl_system_items_kfv
      WHERE inventory_item_Id = p_item_id
      AND ORGANIZATION_ID = p_org_id;
  BEGIN
     OPEN cur_get_item_desc;
    FETCH cur_get_item_desc INTO p_item_desc;
    CLOSE cur_get_item_desc;
  END get_item_desc;


  PROCEDURE get_spec_name(p_spec_id VARCHAR2,
                          p_spec_name OUT NOCOPY VARCHAR2) IS
    CURSOR cur_get_spec_name IS
      SELECT SPEC_NAME
      FROM  gmd_specifications
      WHERE SPEC_ID  = p_spec_id ;
  BEGIN
     OPEN cur_get_spec_name;
    FETCH cur_get_spec_name INTO p_spec_name;
    CLOSE cur_get_spec_name;
  END get_spec_name;

  PROCEDURE get_spec_vers(p_spec_id VARCHAR2,
                          p_spec_vers OUT NOCOPY VARCHAR2) IS
    CURSOR cur_get_spec_vers IS
      SELECT  SPEC_VERS
      FROM  gmd_specifications
      WHERE SPEC_ID  = p_spec_id ;
  BEGIN
     OPEN cur_get_spec_vers;
    FETCH cur_get_spec_vers INTO p_spec_vers;
    CLOSE cur_get_spec_vers;
  END get_spec_vers;

  PROCEDURE get_item_uom (p_item_id VARCHAR2,
                          p_org_id VARCHAR2,
                          p_item_uom OUT NOCOPY VARCHAR2) IS
    CURSOR cur_item_uom IS
      SELECT primary_uom_code
      FROM mtl_system_items
      WHERE inventory_item_Id = p_item_id
      AND ORGANIZATION_ID = p_org_id;
  BEGIN
     OPEN cur_item_uom;
    FETCH cur_item_uom INTO p_item_uom;
    CLOSE cur_item_uom;
  END get_item_uom;

 PROCEDURE get_spec_type (p_spec_type_ind VARCHAR2,
                          p_spec_type OUT NOCOPY VARCHAR2) IS
  BEGIN
   IF p_spec_type_ind = 'I' THEN
     p_spec_type := 'Item' ;  --Changed from Inventory to Item --Bug # 4706847
   END IF ;
   IF p_spec_type_ind = 'M' THEN
     p_spec_type := 'Monitoring' ;
   END IF ;
  END get_spec_type;


 PROCEDURE get_loc_name (p_loc_id VARCHAR2,
                         p_loc_name OUT NOCOPY VARCHAR2) IS
      CURSOR cur_loc_name IS
      SELECT concatenated_segments
      FROM mtl_item_locations_kfv
      WHERE inventory_location_id = p_loc_id ;
  BEGIN
    OPEN cur_loc_name;
    FETCH cur_loc_name INTO p_loc_name;
    CLOSE cur_loc_name;
  END get_loc_name;


PROCEDURE GET_LOOKUP_VALUE (plookup_type       IN VARCHAR2,
			    plookup_code       IN VARCHAR2,
                            pmeaning           OUT NOCOPY VARCHAR2) IS

CURSOR get_lookup IS
  SELECT meaning
  FROM fnd_lookup_values_vl
  WHERE  lookup_type = plookup_type
  AND    lookup_code = plookup_code;

BEGIN

  OPEN get_lookup;
  FETCH get_lookup INTO pmeaning;
  IF (get_lookup%NOTFOUND) THEN
     pmeaning := ' ';
  END IF;
  CLOSE get_lookup;

END GET_LOOKUP_VALUE;

 -- INVCONV, NSRIVAST, END

/*=============================================================================+
 Procedure Name    : GET_YES_NO

 Purpose :
  This procedure is used when we need to display Yes or No for a
  particular field in the ERES document and when the fields stored
  database value is something like Y,N,1,0 or NULL.
  Input  :
          p_short -- the short forms that is stored in the database
                      like 'Y','N','0' etc.
  Output  :
           x_expanded -- 'Yes' or 'No' based on input

 HISTORY
  RLNAGARA       17-Nov-2005     Created
==============================================================================*/
PROCEDURE GET_YES_NO(p_short IN VARCHAR2 ,
                     x_expanded OUT NOCOPY VARCHAR2) IS
BEGIN
    IF p_short IS NULL OR p_short = '0' OR p_short = 'N' THEN
      x_expanded := 'No';
    END IF; --p_short = 0

    IF p_short ='1' OR p_short ='Y' THEN
      x_expanded := 'Yes';
    END IF; --p_short = 1

END GET_YES_NO;


/*=============================================================================+
 Procedure Name    : GET_ITEM_UOM_CALC

 Purpose :
  This procedure is used for the ERES in which the From_UOM field
  is to be displayed based on the calc_uom_conv_ind.

 HISTORY
  RLNAGARA       17-Nov-2005     Created
==============================================================================*/
PROCEDURE GET_ITEM_UOM_CALC ( p_item_id IN VARCHAR2
                       , p_organization_id IN VARCHAR2
                       , p_spec_id IN VARCHAR2
                       , p_test_id IN VARCHAR2
                       , x_item_uom OUT NOCOPY VARCHAR2) IS
  CURSOR calc_uom_conv_ind_cur IS
   SELECT CALC_UOM_CONV_IND
     FROM GMD_SPEC_TESTS
     WHERE SPEC_ID = p_spec_id
     AND TEST_ID = p_test_id;

  CURSOR cur_item_uom_cur IS
   SELECT primary_uom_code
      FROM mtl_system_items
      WHERE inventory_item_Id = p_item_id
      AND ORGANIZATION_ID = p_organization_id;

 l_uom_conv VARCHAR2(10) := NULL;
 x_uom_conv VARCHAR2(10) := NULL;
BEGIN
    OPEN calc_uom_conv_ind_cur;
    FETCH calc_uom_conv_ind_cur INTO l_uom_conv;
    CLOSE calc_uom_conv_ind_cur;

    GET_YES_NO(l_uom_conv,x_uom_conv);

    IF x_uom_conv = 'Yes' THEN
      OPEN cur_item_uom_cur;
      FETCH cur_item_uom_cur INTO x_item_uom;
      CLOSE cur_item_uom_cur;
    END IF; --x_uom_lov = Yes

END GET_ITEM_UOM_CALC;

/*=============================================================================+
 Procedure Name    : GET_DECIMAL_VALUE

 Purpose :
  This procedure is used for showing decimal places for any Numeric Fields
  in the ERES Document.
  Input :
         p_value -- Value stored in the database
         p_test_qty  -- 'T' for Test or 'Q' for Quantity fields
         p_test_id  -- If p_test_qty = 'T' then the test_id should be passed and
                           if test_id is not passed or passed wrong then
                           default decimal precision is taken as 9.
                       Else(p_test_qty='Q')
                          this value can be NULL as it is not used anywhere in
                          procedure as default decimal precision is taken as 5.
         x_decimal_value -- This is the final value which is returned with proper
                            decimal precision.


 HISTORY
  RLNAGARA       17-Nov-2005     Created
  RLNAGARA       30-Nov-2005    Added NVL to the cursor.
==============================================================================*/
PROCEDURE GET_DECIMAL_VALUE(p_value IN VARCHAR2
                            , p_test_qty IN VARCHAR2
                            , p_test_id IN VARCHAR2
                            , x_decimal_value OUT NOCOPY VARCHAR2 ) IS
  CURSOR get_decimal_precision IS
   SELECT NVL(REPORT_PRECISION,0)
   FROM GMD_QC_TESTS
   WHERE TEST_ID = p_test_id;
 l_value VARCHAR2(50) := NULL;
 l_decimal_precision NUMBER := 9;
 l_dot_precision NUMBER := 0;
 l_total_length NUMBER := 0;
 l_decimal_length NUMBER := 0;
 l_extra_decimal NUMBER := 0;
 l_final_length NUMBER := 0;
BEGIN

 IF p_test_qty = 'Q' THEN
   l_decimal_precision := 5;
 ELSIF p_test_qty = 'T' THEN
   OPEN get_decimal_precision;
   FETCH get_decimal_precision INTO l_decimal_precision;
   CLOSE get_decimal_precision;
 END IF;

 SELECT LENGTH(p_value) INTO l_total_length FROM DUAL;
 SELECT INSTR(p_value,'.') INTO l_dot_precision FROM DUAL;
 IF l_dot_precision > 0 THEN
   l_decimal_length := l_total_length - l_dot_precision;
 ELSE
   l_decimal_length := 0;
 END IF;
 l_extra_decimal := l_decimal_precision - l_decimal_length;
 l_value := p_value;
 IF l_dot_precision = 0 THEN
   l_total_length := l_total_length + 1;
   SELECT RPAD(p_value,l_total_length,'.') INTO l_value FROM DUAL;
 END IF;
 l_final_length := l_total_length + l_extra_decimal;
 SELECT RPAD(l_value,l_final_length,'0') INTO x_decimal_value FROM DUAL;

END GET_DECIMAL_VALUE;

/* Bug 5023089. RLNAGARA 09-Mar-2006. To display the from and to Sample's disposition  */

PROCEDURE get_disp_meaning(p_sample_id IN NUMBER,
                           p_sampling_event_id IN NUMBER,
                           p_organization_id IN NUMBER,
                           p_disp_type IN VARCHAR2,
                           psample_disposition OUT NOCOPY VARCHAR2 ) IS

CURSOR get_chng_id IS
 select max(change_disp_id)
 from GMD_CHANGE_DISPOSITION
 where sampling_event_id = p_sampling_event_id
 and organization_id = p_organization_id
 group by organization_id;

CURSOR get_chng_id_smpl IS
 select max(change_disp_id)
 from GMD_CHANGE_DISPOSITION
 where sample_id = p_sample_id
 and sampling_event_id = p_sampling_event_id
 and organization_id = p_organization_id
 group by organization_id;

CURSOR get_from_disp(p_change_disp_id IN NUMBER) IS
 select gl.meaning
 from gmd_change_disposition gcd ,gem_lookups gl
 where gl.lookup_type = 'GMD_QC_SAMPLE_DISP'
 and gl.lookup_code = gcd.disposition_from
 and gcd.change_disp_id = p_change_disp_id;

CURSOR get_to_disp(p_change_disp_id IN NUMBER) IS
 select gl.meaning
 from gmd_change_disposition gcd ,gem_lookups gl
 where gl.lookup_type = 'GMD_QC_SAMPLE_DISP'
 and gl.lookup_code = gcd.disposition_to
 and gcd.change_disp_id = p_change_disp_id;

l_chng_disp_id NUMBER;

BEGIN
 IF p_sample_id IS NULL THEN
   OPEN get_chng_id;
   FETCH get_chng_id INTO l_chng_disp_id;
   IF (get_chng_id%NOTFOUND) THEN
       l_chng_disp_id := 0;
   END IF;
   CLOSE get_chng_id;
 ELSE
   OPEN get_chng_id_smpl;
   FETCH get_chng_id_smpl INTO l_chng_disp_id;
   IF (get_chng_id_smpl%NOTFOUND) THEN
       l_chng_disp_id := 0;
   END IF;
   CLOSE get_chng_id_smpl;
 END IF;

 IF p_disp_type = 'FROM' THEN
   OPEN get_from_disp(l_chng_disp_id);
   FETCH get_from_disp INTO psample_disposition;
   IF (get_from_disp%NOTFOUND) THEN
     psample_disposition := ' ';
   END IF;
   CLOSE get_from_disp;
 ELSIF p_disp_type = 'TO' THEN
   OPEN get_to_disp(l_chng_disp_id);
   FETCH get_to_disp INTO psample_disposition;
   IF (get_to_disp%NOTFOUND) THEN
     psample_disposition := ' ';
   END IF;
   CLOSE get_to_disp;
 END IF;

END get_disp_meaning;



/*=============================================================================+
 Procedure Name    : GET_COMPOSITED

 Purpose :
  This procedure is used for knowing whether the sample is composited or not.
  Input :
         p_event_spec_disp_id -- EVENT_SPEC_DISP_ID
  Output :
	 x_composited -- This returns Yes or No based on whether sample is
	                 composited or not.


 HISTORY
  RLNAGARA       18-Apr-2006     Created
==============================================================================*/
PROCEDURE get_composited(p_event_spec_disp_id IN NUMBER,
			 x_composited OUT NOCOPY VARCHAR2) IS

 CURSOR check_composite IS
  SELECT 'Y'
  FROM gmd_composite_spec_disp
  WHERE event_spec_disp_id = p_event_spec_disp_id;

 l_composited_flag VARCHAR2(20);

BEGIN

 OPEN check_composite;
 FETCH check_composite INTO l_composited_flag;
  IF check_composite%FOUND THEN
    x_composited := 'Yes';
  ELSE
    x_composited := 'No';
  END IF;
 CLOSE check_composite;

END;

/*=============================================================================+
 Procedure Name    : get_lpn

 Purpose :
  This procedure get the LPN using LPN_ID.
  Input :
         p_lpn_id -- LPN_ID
  Output :
	 x_lpn -- LICENSE_PLATE_NUMBER

 HISTORY
  RLNAGARA LPN ME 7027149  14-May-2008     Created
==============================================================================*/
PROCEDURE get_lpn(p_lpn_id IN NUMBER,
                  x_lpn OUT NOCOPY VARCHAR2) IS

 CURSOR c_get_lpn IS
  SELECT license_plate_number
  FROM wms_license_plate_numbers
  WHERE lpn_id = p_lpn_id;

BEGIN
  IF p_lpn_id IS NOT NULL THEN
   OPEN c_get_lpn;
   FETCH c_get_lpn INTO x_lpn;
   CLOSE c_get_lpn;
  ELSE
   x_lpn := NULL;
  END IF;

END get_lpn;


end GMD_QC_ERES_UTILS;


/
