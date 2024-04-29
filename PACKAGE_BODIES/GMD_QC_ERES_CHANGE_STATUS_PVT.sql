--------------------------------------------------------
--  DDL for Package Body GMD_QC_ERES_CHANGE_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QC_ERES_CHANGE_STATUS_PVT" as
/* $Header: GMDVEREB.pls 120.1 2006/02/22 15:04:06 plowe noship $ */

PROCEDURE set_spec_status(p_spec_id IN NUMBER,
                          p_from_status IN VARCHAR2,
                          p_to_status IN VARCHAR2,
                          p_signature_status IN VARCHAR2) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	VARCHAR2(40);
  l_rework_status	VARCHAR2(40);
BEGIN
  IF p_signature_status IS NOT NULL THEN
    l_signature_status := p_signature_status;
  ELSE
    l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  END IF;
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
                             p_to_status IN VARCHAR2,
                             p_signature_status IN VARCHAR2) IS
  l_signature_status	VARCHAR2(40);
  l_pending_status	VARCHAR2(40);
  l_rework_status	VARCHAR2(40);
BEGIN
  IF p_signature_status IS NOT NULL THEN
    l_signature_status := p_signature_status;
  ELSE
    l_signature_status := EDR_PSIG_PAGE_FLOW.signature_status;
  END IF;
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

  END update_vr_status ;

FUNCTION chek_spec_validity_eres (p_spec_id IN NUMBER,
                                    p_to_status IN VARCHAR2,
                                    p_event  IN VARCHAR2)
RETURN BOOLEAN IS
  CURSOR Cur_get_validity IS
-- bug 4924550  sql id 14692703
/*    SELECT spec_vr_id,spec_type
    FROM   gmd_all_spec_vrs
    WHERE  spec_id = p_spec_id
    AND    spec_vr_status  < p_to_status; */
select spec_vr_id, 'I' spec_type
    from   GMD_INVENTORY_SPEC_VRS
    where  spec_id = p_spec_id
    and    spec_vr_status  < p_to_status
UNION
select spec_vr_id,'W' spec_type
    from   GMD_WIP_SPEC_VRS
    where  spec_id = p_spec_id
    and    spec_vr_status  < p_to_status
UNION
select spec_vr_id,'C' spec_type
    from   GMD_CUSTOMER_SPEC_VRS
    where  spec_id = p_spec_id
    and    spec_vr_status  < p_to_status
UNION
select spec_vr_id,'S' spec_type
    from   GMD_SUPPLIER_SPEC_VRS
    where  spec_id = p_spec_id
    and    spec_vr_status  < p_to_status
UNION
select spec_vr_id, rule_type spec_type   -- R or L
    from   GMD_MONITORING_SPEC_VRS
    where  spec_id = p_spec_id
    and    spec_vr_status  < p_to_status
UNION
select spec_vr_id, 'T' spec_type
    from   GMD_STABILITY_SPEC_VRS
    where  spec_id = p_spec_id
    and    spec_vr_status  < p_to_status;

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
  -- PRAGMA AUTONOMOUS_TRANSACTION;
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
END esig_required;

end GMD_QC_ERES_CHANGE_STATUS_PVT;

/
