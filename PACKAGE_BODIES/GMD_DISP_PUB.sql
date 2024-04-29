--------------------------------------------------------
--  DDL for Package Body GMD_DISP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_DISP_PUB" AS
/* $Header: GMDPDISB.pls 120.0.12010000.2 2009/06/08 17:14:42 plowe noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDPDISB.pls                                        |
--| Package Name       : GMD_DISP_PUB                                        |
--| Type               : Public                                              |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains public layer APIs for Changing the disposition  |
--|    of a Sample/Group                                                     |
--|									                                                         |
--| HISTORY                                                                  |
--|     Ravi Lingappa Nagaraja    16-Jun-2008     Created                    |
--|     P Lowe                    19-May-2009     bug 8528505                |
--|     1. increased                                                         |
--|     size of l_dummy from 4 to 150 to cover largest user of this variable |
--|     in proc validate_lot_grade_status                                    |
--|			2. NB Changed TYPE change_disp_rec IS RECORD is spec to correct size |
--|			3. In PROCEDURE validate_reason_code changed l_dummy to  varchar2(30)|						                                                         |
--+==========================================================================+
-- End of comments

FUNCTION set_debug_flag RETURN VARCHAR2;

l_debug VARCHAR2(1) := set_debug_flag;

FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
RETURN l_debug;
END set_debug_flag;

/*=============================================================================
Start Forward Declaration
=============================================================================*/

FUNCTION get_current_event_spec_disp_id
(
  p_id     IN  NUMBER
 ,p_is_sample_id  IN  VARCHAR2
) RETURN NUMBER;

PROCEDURE validate_parentlot_lot (
 p_inventory_item_id     IN NUMBER
,p_organization_id       IN NUMBER
,p_parent_lot_number     IN VARCHAR2
,p_lot_number            IN VARCHAR2
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2);

PROCEDURE validate_lpn (
 p_inventory_item_id  IN NUMBER
,p_organization_id    IN NUMBER
,p_lot_number  	      IN VARCHAR2
,p_lpn_id             IN NUMBER
,p_lpn                IN VARCHAR2
,x_lpn_id             OUT NOCOPY NUMBER
,x_lpn                OUT NOCOPY VARCHAR2
,x_return_status      OUT NOCOPY VARCHAR2
,x_msg_count          OUT NOCOPY NUMBER
,x_msg_data           OUT NOCOPY VARCHAR2);

PROCEDURE validate_reason_code (
 p_reason_code   	 IN  VARCHAR2
,x_reason_id             OUT NOCOPY NUMBER
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
);

PROCEDURE populate_hold_date (
 p_parent_lot_number IN VARCHAR2
,p_lot_number        IN VARCHAR2
,p_inventory_item_id IN NUMBER
,p_organization_id   IN NUMBER
,x_lot_created       OUT NOCOPY DATE
,x_hold_date         IN OUT NOCOPY DATE);

PROCEDURE validate_lot_grade_status (
 p_is_lot       		 IN VARCHAR2
,p_status		         IN VARCHAR2
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_disp (
 p_update_disp_rec        IN GMD_SAMPLES_GRP.update_disp_rec
,p_to_disposition	  IN VARCHAR2
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
);

/*=============================================================================
End Forward Declaration
=============================================================================*/


/*=============================================================================
Function to get the event_spec_disp_id
=============================================================================*/
FUNCTION get_current_event_spec_disp_id
(
  p_id     IN  NUMBER
 ,p_is_sample_id  IN  VARCHAR2
) RETURN NUMBER IS

  -- Cursors
  CURSOR c_event_disp_sm(p_sample_id NUMBER) IS
  SELECT event_spec_disp_id
  FROM   gmd_samples gs, gmd_event_spec_disp ge
  WHERE  gs.sampling_event_id    = ge.sampling_event_id
  AND    ge.spec_used_for_lot_attrib_ind = 'Y'
  AND    gs.sample_id      = p_id
  AND    ge.delete_mark    = 0
  ;

  CURSOR c_event_disp_se(p_sample_id NUMBER) IS
  SELECT DISTINCT event_spec_disp_id
  FROM   gmd_samples gs, gmd_event_spec_disp ge
  WHERE  gs.sampling_event_id    = ge.sampling_event_id
  AND    gs.sampling_event_id = p_id
  AND    ge.spec_used_for_lot_attrib_ind = 'Y'
  AND    ge.delete_mark    = 0
  ;
  -- Local Variables
  l_dummy                         NUMBER(15);

BEGIN

 IF p_is_sample_id = 'Y' THEN
  OPEN c_event_disp_sm(p_id);
  FETCH c_event_disp_sm INTO l_dummy;
  CLOSE c_event_disp_sm;
 ELSE
  OPEN c_event_disp_se(p_id);
  FETCH c_event_disp_se INTO l_dummy;
  CLOSE c_event_disp_se;
 END IF;

  RETURN l_dummy;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END get_current_event_spec_disp_id;

/*=============================================================================
Procedure to validate the parent lot and lot.
=============================================================================*/
PROCEDURE validate_parentlot_lot (
 p_inventory_item_id     IN NUMBER
,p_organization_id       IN NUMBER
,p_parent_lot_number     IN VARCHAR2
,p_lot_number            IN VARCHAR2
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
) IS

  ITEM_PARENTLOT_NOT_FOUND  EXCEPTION;
  ITEM_LOT_NOT_FOUND EXCEPTION;

  CURSOR c_item_parentlot IS
    SELECT 1
    FROM   mtl_lot_numbers
    WHERE  inventory_item_id = p_inventory_item_id
    AND    organization_id   = p_organization_id
    AND    parent_lot_number = p_parent_lot_number;

  CURSOR c_item_lot IS
    SELECT 1
    FROM   mtl_lot_numbers
    WHERE  inventory_item_id = p_inventory_item_id
    AND    organization_id   = p_organization_id
    AND    parent_lot_number = p_parent_lot_number
    AND    lot_number        = p_lot_number;

    l_dummy          NUMBER(15);

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_parent_lot_number IS NOT NULL) THEN
    OPEN c_item_parentlot;
    FETCH c_item_parentlot INTO l_dummy;
    IF c_item_parentlot%NOTFOUND THEN
      CLOSE c_item_parentlot;
      RAISE ITEM_PARENTLOT_NOT_FOUND;
    END IF;
    CLOSE c_item_parentlot;
  END IF;

  IF (p_lot_number IS NOT NULL) THEN
    OPEN c_item_lot;
    FETCH c_item_lot INTO l_dummy;
    IF c_item_lot%NOTFOUND THEN
      CLOSE c_item_lot;
      RAISE ITEM_LOT_NOT_FOUND;
    END IF;
    CLOSE c_item_lot;
  END IF;

EXCEPTION

WHEN ITEM_PARENTLOT_NOT_FOUND THEN
   gmd_api_pub.log_message('GMD_ITEM_PARENTLOT_NOT_FOUND');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN ITEM_LOT_NOT_FOUND THEN
   gmd_api_pub.log_message('GMD_ITEM_LOT_NOT_FOUND');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_DISP_PUB.validate_parentlot_lot','ERROR', SUBSTR(SQLERRM,1,100));
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END validate_parentlot_lot;

/*=============================================================================
Procedure to validate the lpn value.
=============================================================================*/
PROCEDURE validate_lpn (
 p_inventory_item_id  IN NUMBER
,p_organization_id    IN NUMBER
,p_lot_number  	      IN VARCHAR2
,p_lpn_id             IN NUMBER
,p_lpn                IN VARCHAR2
,x_lpn_id             OUT NOCOPY NUMBER
,x_lpn                OUT NOCOPY VARCHAR2
,x_return_status      OUT NOCOPY VARCHAR2
,x_msg_count          OUT NOCOPY NUMBER
,x_msg_data           OUT NOCOPY VARCHAR2
) IS

  ITEM_LPN_NOT_FOUND  EXCEPTION;

  CURSOR c_item_lpn_id IS
   SELECT distinct wlpn.lpn_id, wlpn.license_plate_number
   FROM  wms_license_plate_numbers wlpn,
         wms_lpn_contents wlc
   WHERE wlpn.lpn_id = wlc.parent_lpn_id
   AND   wlpn.organization_id = p_organization_id
   AND   wlpn.parent_lpn_id is null
   AND   wlc.inventory_item_id = p_inventory_item_id
   AND  (wlc.lot_number = p_lot_number or p_lot_number is null)
   AND   wlpn.lpn_id = p_lpn_id;

  CURSOR c_item_lpn IS
   SELECT distinct wlpn.lpn_id, wlpn.license_plate_number
   FROM  wms_license_plate_numbers wlpn,
         wms_lpn_contents wlc
   WHERE wlpn.lpn_id = wlc.parent_lpn_id
   AND   wlpn.organization_id = p_organization_id
   AND   wlpn.parent_lpn_id is null
   AND   wlc.inventory_item_id = p_inventory_item_id
   AND  (wlc.lot_number = p_lot_number or p_lot_number is null)
   AND   wlpn.license_plate_number = p_lpn;

    l_dummy          NUMBER(15);

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_lpn_id IS NOT NULL) THEN
    OPEN c_item_lpn_id;
    FETCH c_item_lpn_id INTO x_lpn_id, x_lpn;
    IF c_item_lpn_id%NOTFOUND THEN
      CLOSE c_item_lpn_id;
      RAISE ITEM_LPN_NOT_FOUND;
    END IF;
    CLOSE c_item_lpn_id;
  ELSIF (p_lpn IS NOT NULL) THEN
    OPEN c_item_lpn;
    FETCH c_item_lpn INTO x_lpn_id, x_lpn;
    IF c_item_lpn%NOTFOUND THEN
      CLOSE c_item_lpn;
      RAISE ITEM_LPN_NOT_FOUND;
    END IF;
    CLOSE c_item_lpn;
  END IF;

EXCEPTION

WHEN ITEM_LPN_NOT_FOUND THEN
   gmd_api_pub.log_message('GMD_ITEM_LPN_NOT_FOUND');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_DISP_PUB.validate_lpn','ERROR', SUBSTR(SQLERRM,1,100));
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END validate_lpn;

/*=============================================================================
Procedure to validate the reason_code
=============================================================================*/
PROCEDURE validate_reason_code (
 p_reason_code           IN  VARCHAR2
,x_reason_id             OUT NOCOPY NUMBER
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
) IS

CURSOR c_reason_code IS
SELECT reason_id
FROM   mtl_transaction_reasons
WHERE  NVL(disable_date, SYSDATE) >= SYSDATE
AND    reason_name = p_reason_code;

l_dummy   VARCHAR2(30);
INVALID_REASON_CODE EXCEPTION;

BEGIN

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;  --Bug#5752786
      IF p_reason_code IS NOT NULL THEN
	 OPEN c_reason_code;
	 FETCH c_reason_code INTO x_reason_id;
	 IF c_reason_code%NOTFOUND THEN
	   CLOSE c_reason_code;
	   RAISE INVALID_REASON_CODE;
	 END IF;
	 CLOSE c_reason_code;
      END IF;
EXCEPTION

WHEN INVALID_REASON_CODE THEN
   gmd_api_pub.log_message('GMD_INVALID_REASON_CODE');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_DISP_PUB.validate_reason_code','ERROR', SUBSTR(SQLERRM,1,100));
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END validate_reason_code;

/*=============================================================================
Procedure to populate the hold date
=============================================================================*/
PROCEDURE populate_hold_date (
 p_parent_lot_number IN VARCHAR2
,p_lot_number        IN VARCHAR2
,p_inventory_item_id IN NUMBER
,p_organization_id   IN NUMBER
,x_lot_created       OUT NOCOPY DATE
,x_hold_date         IN OUT NOCOPY DATE)
IS

 CURSOR Cur_lot_data IS
   SELECT creation_date, hold_date
   FROM   mtl_lot_numbers
   WHERE  inventory_item_id = p_inventory_item_id
   AND    organization_id   = p_organization_id
   AND    lot_number        = p_lot_number
   AND    ((p_parent_lot_number IS NULL)
            OR (parent_lot_number = p_parent_lot_number));

BEGIN

   IF (p_lot_number IS NOT NULL AND p_parent_lot_number IS NOT NULL) THEN
     OPEN  Cur_lot_data;
     FETCH Cur_lot_data INTO x_lot_created, x_hold_date;
     CLOSE Cur_lot_data;
   ELSIF (p_lot_number IS NOT NULL) THEN
     SELECT max(creation_date)
     INTO x_lot_created
     FROM mtl_lot_numbers
     WHERE lot_number        = p_lot_number
     AND   organization_id   = p_organization_id
     AND   inventory_item_id = p_inventory_item_id;

     SELECT max(hold_date)
     INTO   x_hold_date
     FROM   mtl_lot_numbers
     WHERE lot_number        = p_lot_number
     AND   organization_id   = p_organization_id
     AND   inventory_item_id = p_inventory_item_id;
   END IF;

EXCEPTION
       --No data found should not occur
	WHEN NO_DATA_FOUND THEN
	   NULL;
END populate_hold_date;

/*=============================================================================
Procedure to validate lot_status and grade
=============================================================================*/
PROCEDURE validate_lot_grade_status (
 p_is_lot       		 IN VARCHAR2
,p_status		         IN VARCHAR2
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
) IS

CURSOR cr_lot_status IS
SELECT status_id, status_code
FROM mtl_material_statuses
WHERE status_code = p_status
AND enabled_flag = 1;

CURSOR cr_grade IS
SELECT grade_code
FROM mtl_grades
WHERE grade_code = p_status
AND disable_flag = 'N';

l_dummy  VARCHAR2(150);   -- bug 8528505  increased size from 4 to 150 to cover largest user of this variable
l_dummy1 NUMBER;

INVALID_LOT_STATUS   EXCEPTION;
INVALID_GRADE        EXCEPTION;

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_is_lot = 'Y' THEN
   OPEN cr_lot_status;
   FETCH cr_lot_status INTO l_dummy1,l_dummy;
   IF cr_lot_status%NOTFOUND THEN
      CLOSE cr_lot_status;
      RAISE INVALID_LOT_STATUS;
    END IF;
   CLOSE cr_lot_status;
 ELSE
   OPEN cr_grade;
   FETCH cr_grade INTO l_dummy;
   IF cr_grade%NOTFOUND THEN
      CLOSE cr_grade;
      RAISE INVALID_GRADE;
    END IF;
   CLOSE cr_grade;
 END IF;

EXCEPTION
WHEN INVALID_LOT_STATUS THEN
   gmd_api_pub.log_message('GMD_INVALID_LOT_STATUS');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
WHEN INVALID_GRADE THEN
   gmd_api_pub.log_message('GMD_INVALID_GRADE');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_DISP_PUB.validate_lot_grade_status','ERROR', SUBSTR(SQLERRM,1,100));
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END validate_lot_grade_status;

/*=============================================================================
Procedure to validate the to_disposition of the sample
=============================================================================*/
PROCEDURE Validate_disp (
 p_update_disp_rec        IN GMD_SAMPLES_GRP.update_disp_rec
,p_to_disposition	  IN VARCHAR2
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
) IS

  l_msg_count            NUMBER  :=0;
  l_message_data         VARCHAR2(2000);
  l_return_status        VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;

  quality_config         GMD_QUALITY_CONFIG%ROWTYPE;

  l_non_accept_w_spec    NUMBER(5);
  l_non_accept_wo_spec   NUMBER(5);
  l_non_reject_w_spec    NUMBER(5);
  l_non_reject_wo_spec   NUMBER(5);
  l_reject_w_spec_no_av  NUMBER(5);
  l_reject_wo_spec_no_av NUMBER(5);

  l_def_reject           NUMBER(1) := 0;
  l_include_optional     VARCHAR2(1);
  l_organization_id      NUMBER;
  org_found              BOOLEAN;

  l_test_count	 	 NUMBER(4) := 0;
  l_disp_count     	 NUMBER(2) := 1;
  l_in_spec_count	 NUMBER(4) := 0;
  l_out_spec_count	 NUMBER(4) := 0;

  INVALID_ORG_PARAM     EXCEPTION;
  INVALID_DISPOSITION    EXCEPTION;
  NO_TESTS_CMP	         EXCEPTION;
  INVALID_PARAMETERS     EXCEPTION;
  l_pos  		 VARCHAR2(10);

     CURSOR c_non_accept_w_spec IS
      SELECT count(1)
      FROM   gmd_event_spec_disp esd,
             gmd_results r,
             gmd_spec_results sr,
             gmd_spec_tests_b st
      WHERE  esd.event_spec_disp_id = p_update_disp_rec.event_spec_disp_id
      AND    esd.event_spec_disp_id = sr.event_spec_disp_id
      AND    sr.result_id           = r.result_id
      AND    r.sample_id            = p_update_disp_rec.sample_id
      AND    (sr.evaluation_ind IS NULL OR sr.evaluation_ind    NOT IN ('0A', '4C', '5O'))
      AND    r.delete_mark          = 0
      AND    sr.delete_mark         = 0
      AND    esd.spec_id = st.spec_id
      AND    st.test_id = r.test_id
      AND    ((l_include_optional = 'N' and st.optional_ind IS NULL) OR (l_include_optional = 'Y'));

    CURSOR c_non_accept_wo_spec IS
      SELECT count(1)
      FROM   gmd_results r, gmd_spec_results sr
      WHERE  sr.event_spec_disp_id  = p_update_disp_rec.event_spec_disp_id
      AND    sr.result_id           = r.result_id
      AND    r.sample_id            = p_update_disp_rec.sample_id
      AND    sr.additional_test_ind = 'Y'
      AND    (sr.evaluation_ind IS NULL OR sr.evaluation_ind    NOT IN ('0A', '4C', '5O'))
      AND    r.delete_mark          = 0
      AND    sr.delete_mark         = 0;

    CURSOR cr_check_comp_results_in_spec IS
	SELECT COUNT(1)
	FROM   gmd_composite_results
	WHERE  composite_spec_disp_id = p_update_disp_rec.composite_spec_disp_id
	AND    delete_mark = 0 ;

    CURSOR c_non_accept_w_spec_cr IS
        SELECT count(1)
        FROM   gmd_event_spec_disp esd, gmd_composite_spec_disp csd,
               gmd_composite_results cr, gmd_spec_tests_b st
        WHERE  csd.composite_spec_disp_id = p_update_disp_rec.composite_spec_disp_id
        AND    csd.event_spec_disp_id = esd.event_spec_disp_id
        AND    csd.latest_ind = 'Y'
        AND    csd.composite_spec_disp_id = cr.composite_spec_disp_id
        AND    cr.in_spec_ind IS NULL
        AND    st.spec_id = esd.spec_id
        AND    st.test_id = cr.test_id
        AND    (st.optional_ind IS NULL OR (l_include_optional = 'Y' and st.optional_ind = 'Y' and (cr.mean IS NOT NULL or cr.mode_char IS NOT NULL)));

    CURSOR c_non_accept_wo_spec_cr IS
        SELECT count(1)
        FROM   gmd_event_spec_disp esd, gmd_composite_spec_disp csd,
               gmd_composite_results cr
        WHERE  csd.composite_spec_disp_id = p_update_disp_rec.composite_spec_disp_id
        AND    csd.event_spec_disp_id = esd.event_spec_disp_id
        AND    csd.latest_ind = 'Y'
        AND    csd.composite_spec_disp_id = cr.composite_spec_disp_id
        AND    cr.in_spec_ind IS NULL
        AND    cr.test_id NOT IN (SELECT st.test_id FROM   gmd_spec_tests_b st WHERE  st.spec_id = esd.spec_id);

    CURSOR c_non_reject_w_spec IS
      SELECT   count(1)
      FROM   gmd_event_spec_disp esd, gmd_results r, gmd_spec_results sr,
             gmd_spec_tests_b st
      WHERE  esd.event_spec_disp_id = p_update_disp_rec.event_spec_disp_id
      AND    esd.event_spec_disp_id = sr.event_spec_disp_id
      AND    sr.result_id           = r.result_id
      AND    r.sample_id            = p_update_disp_rec.sample_id
      AND   ((sr.evaluation_ind IS NULL OR sr.evaluation_ind NOT IN ('2R')) OR sr.in_spec_ind = 'Y' )
      AND    r.delete_mark          = 0
      AND    sr.delete_mark         = 0
      AND    esd.spec_id = st.spec_id
      AND    st.test_id = r.test_id ;

    CURSOR c_non_reject_wo_spec IS
      SELECT   count(1)
      FROM   gmd_results r, gmd_spec_results sr
      WHERE  sr.event_spec_disp_id  = p_update_disp_rec.event_spec_disp_id
      AND    sr.result_id           = r.result_id
      AND    r.sample_id            = p_update_disp_rec.sample_id
      AND    sr.additional_test_ind = 'Y'
      AND    (sr.evaluation_ind IS NULL OR sr.evaluation_ind NOT IN ('2R'))
      AND    r.delete_mark          = 0
      AND    sr.delete_mark         = 0;

   CURSOR c_reject_w_spec_no_av IS
      SELECT   count(1)
      FROM   gmd_event_spec_disp esd, gmd_results r, gmd_spec_results sr,
             gmd_spec_tests_b st
      WHERE  esd.event_spec_disp_id = p_update_disp_rec.event_spec_disp_id
      AND    esd.event_spec_disp_id = sr.event_spec_disp_id
      AND    sr.result_id           = r.result_id
      AND    r.sample_id            = p_update_disp_rec.sample_id
      AND    (sr.in_spec_ind IS NULL AND (sr.evaluation_ind IS NULL))
      AND    r.delete_mark          = 0
      AND    sr.delete_mark         = 0
      AND    esd.spec_id = st.spec_id
      AND    st.test_id = r.test_id
      AND    ((l_include_optional = 'N' and st.optional_ind IS NULL) OR (l_include_optional = 'Y'));

   CURSOR c_reject_wo_spec_no_av IS
      SELECT   count(1)
      FROM   gmd_results r, gmd_spec_results sr
      WHERE  sr.event_spec_disp_id  = p_update_disp_rec.event_spec_disp_id
      AND    sr.result_id           = r.result_id
      AND    r.sample_id            = p_update_disp_rec.sample_id
      AND    sr.additional_test_ind = 'Y'
      AND    (sr.evaluation_ind IS NULL)
      AND    r.delete_mark          = 0
      AND    sr.delete_mark         = 0;

   CURSOR c_get_smpl_org_id IS
    SELECT organization_id
    FROM gmd_samples
    WHERE sample_id = p_update_disp_rec.sample_id;

   CURSOR c_get_evt_org_id IS
    SELECT organization_id
    FROM gmd_sampling_events gse,
         gmd_event_spec_disp gesd,
         gmd_composite_spec_disp gcsd
    WHERE gse.sampling_event_id = gesd.sampling_event_id
    AND   gesd.event_spec_disp_id = gcsd.event_spec_disp_id
    AND   gcsd.composite_spec_disp_id = p_update_disp_rec.composite_spec_disp_id;

   BEGIN
    l_pos :='000';

      --  Initialize API return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF p_update_disp_rec.sample_id IS NOT NULL THEN
          OPEN c_get_smpl_org_id;
	  FETCH c_get_smpl_org_id INTO l_organization_id;
	  CLOSE c_get_smpl_org_id;
       ELSE
          OPEN c_get_evt_org_id;
	  FETCH c_get_evt_org_id INTO l_organization_id;
	  CLOSE c_get_evt_org_id;
       END IF;

       GMD_QUALITY_PARAMETERS_GRP.get_quality_parameters(
                                       p_organization_id    => l_organization_id
	                             , x_quality_parameters => quality_config
                                     , x_return_status      => l_return_status
                                     , x_orgn_found         => org_found );
       IF (l_return_status <> 'S') THEN
	      RAISE INVALID_ORG_PARAM;
       END IF;

       l_include_optional :=nvl(quality_config.include_optional_test_rslt_ind,'N');

      IF  (p_update_disp_rec.sample_id IS NOT NULL AND p_update_disp_rec.composite_spec_disp_id IS NOT NULL)
      OR  (p_update_disp_rec.sample_id IS NULL AND p_update_disp_rec.composite_spec_disp_id IS NULL)
      THEN
        RAISE INVALID_PARAMETERS; --'GMD_INVALID_PARAMETERS'
      END IF;

      l_pos :='001';

      IF  p_update_disp_rec.sample_id IS NOT NULL  THEN
	      	OPEN  c_non_accept_w_spec ;
		FETCH c_non_accept_w_spec INTO l_non_accept_w_spec;
		CLOSE c_non_accept_w_spec ;

		OPEN  c_non_accept_wo_spec ;
		FETCH c_non_accept_wo_spec INTO l_non_accept_wo_spec;
		CLOSE c_non_accept_wo_spec ;

	        OPEN  c_non_reject_w_spec ;
	        FETCH c_non_reject_w_spec INTO l_non_reject_w_spec;
	        CLOSE c_non_reject_w_spec ;

                OPEN  c_non_reject_wo_spec ;
	        FETCH c_non_reject_wo_spec INTO l_non_reject_wo_spec;
	        CLOSE c_non_reject_wo_spec ;

       		OPEN  c_reject_w_spec_no_av ;
		FETCH c_reject_w_spec_no_av INTO l_reject_w_spec_no_av;
		CLOSE c_reject_w_spec_no_av ;

		OPEN  c_reject_wo_spec_no_av ;
		FETCH c_reject_wo_spec_no_av INTO l_reject_wo_spec_no_av;
		CLOSE c_reject_wo_spec_no_av ;

		IF p_update_disp_rec.curr_disposition = '1P' THEN
                    IF p_to_disposition NOT IN ('7CN') THEN
  	  	       RAISE INVALID_DISPOSITION ;
                    END IF;
		ELSIF p_update_disp_rec.curr_disposition = '2I' THEN
		    IF l_reject_w_spec_no_av + l_reject_wo_spec_no_av > 0 THEN
		       IF p_to_disposition NOT IN ('7CN','6RJ') THEN
  	  	          RAISE INVALID_DISPOSITION ;
                       END IF;
		     ELSE
		       IF p_to_disposition NOT IN ('7CN','5AV','6RJ') THEN
  	  	          RAISE INVALID_DISPOSITION ;
                       END IF;
		     END IF;
		ELSIF p_update_disp_rec.curr_disposition = '3C' THEN
   	   	    IF l_non_accept_w_spec + l_non_accept_wo_spec = 0 THEN
		       IF p_to_disposition NOT IN ('4A','6RJ') THEN
  	  	          RAISE INVALID_DISPOSITION ;
                       END IF;
		    ELSE
		       IF l_reject_w_spec_no_av + l_reject_wo_spec_no_av > 0 THEN
                          IF p_to_disposition NOT IN ('6RJ') THEN
  	  	             RAISE INVALID_DISPOSITION ;
                          END IF;
		       ELSE
                          IF p_to_disposition NOT IN ('5AV','6RJ') THEN
  	  	             RAISE INVALID_DISPOSITION ;
                          END IF;
		       END IF;
                    END IF;
		       IF l_non_reject_w_spec + l_non_reject_wo_spec = 0 THEN
		          l_def_reject := 1;
		       END IF;
		ELSIF p_update_disp_rec.curr_disposition = '4A' AND p_update_disp_rec.no_of_samples_for_event = 1 THEN
                    IF p_to_disposition NOT IN ('7CN','6RJ') THEN
                       RAISE INVALID_DISPOSITION ;
                    END IF;
		ELSIF p_update_disp_rec.curr_disposition = '5AV' AND p_update_disp_rec.no_of_samples_for_event = 1 THEN
                    IF p_to_disposition NOT IN ('7CN','6RJ') THEN
                       RAISE INVALID_DISPOSITION ;
                    END IF;
		ELSIF p_update_disp_rec.curr_disposition = '6RJ' AND p_update_disp_rec.no_of_samples_for_event = 1 THEN
                    IF p_to_disposition NOT IN ('5AV','7CN') THEN
                       RAISE INVALID_DISPOSITION ;
                    END IF;
		END IF;

		IF l_def_reject = 1 THEN
                    IF p_to_disposition NOT IN ('6RJ') THEN
                       RAISE INVALID_DISPOSITION;
                    END IF;
		END IF;

         l_pos :='002';

      ELSIF  p_update_disp_rec.composite_spec_disp_id IS NOT NULL THEN
		OPEN  cr_check_comp_results_in_spec ;
		FETCH cr_check_comp_results_in_spec INTO l_test_count;
		CLOSE cr_check_comp_results_in_spec ;

		OPEN  c_non_accept_w_spec_cr ;
		FETCH c_non_accept_w_spec_cr INTO l_non_accept_w_spec;
		CLOSE c_non_accept_w_spec_cr ;

		OPEN  c_non_accept_wo_spec_cr ;
		FETCH c_non_accept_wo_spec_cr INTO l_non_accept_wo_spec;
		CLOSE c_non_accept_wo_spec_cr ;
                l_pos :='003';
		IF NVL(l_test_count,0) = 0  AND p_update_disp_rec.curr_disposition = '3C' THEN
		   RAISE NO_TESTS_CMP;
		END IF;
                l_pos :='004';
		IF  p_update_disp_rec.curr_disposition = '3C' THEN
		  IF l_non_accept_w_spec + l_non_accept_wo_spec = 0 THEN
   	   	     IF p_to_disposition NOT IN ('4A','6RJ') THEN
		        RAISE INVALID_DISPOSITION;
		     END IF;
		  ELSE
		     IF p_to_disposition NOT IN ('5AV','6RJ') THEN
		        RAISE INVALID_DISPOSITION;
		     END IF;
		  END IF;
		ELSIF  p_update_disp_rec.curr_disposition = '2I' THEN
		  IF p_to_disposition NOT IN ('5AV','6RJ') THEN
		      RAISE INVALID_DISPOSITION;
		   END IF;
		END IF;
      END IF; -- p_update_disp_rec.sample_id IS NOT NULL

EXCEPTION
WHEN INVALID_ORG_PARAM THEN
   gmd_api_pub.log_message('GMD_QM_ORG_PARAMETER');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_DISPOSITION THEN
   gmd_api_pub.log_message('GMD_SAMPLE_DISPOSITION_INVALID');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN NO_TESTS_CMP THEN
   gmd_api_pub.log_message('GMD_QM_NO_CMPS_RSLT');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_PARAMETERS THEN
   gmd_api_pub.log_message('GMD_INVALID_PARAMETERS');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_DISP_PUB.Validate_disp','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_pos);
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Validate_disp;


/*=============================================================================
Procedure change_disposition
  This is the public procedure which should be called to change the
  disposition of the sample/group.
=============================================================================*/
PROCEDURE change_disposition (
 p_api_version          IN  NUMBER
,p_init_msg_list        IN  VARCHAR2        DEFAULT FND_API.G_FALSE
,p_commit               IN  VARCHAR2        DEFAULT FND_API.G_FALSE
,p_validation_level     IN  NUMBER          DEFAULT FND_API.G_VALID_LEVEL_FULL
,p_change_disp_rec   	IN  CHANGE_DISP_REC
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) IS

l_api_name              CONSTANT VARCHAR2 (30) := 'CHANGE_DISPOSITION';
l_api_version           CONSTANT NUMBER        := 1.0;
l_msg_count             NUMBER  :=0;
l_message_data          VARCHAR2(2000);
l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
l_pos                   VARCHAR2(5);
l_update_disp_rec       GMD_SAMPLES_GRP.update_disp_rec;
l_change_rec            GMD_SAMPLES_GRP.update_change_disp_rec;
l_sample_req_cnt	NUMBER;
l_sample_active_cnt	NUMBER;
l_sample_taken_cnt	NUMBER;

l_sample_spec_disp      VARCHAR2(3);
l_event_spec_disp_id    NUMBER(15);
l_comp_spec_disp	VARCHAR2(3);
l_sampling_event_id	NUMBER(15) ;

l_organization_id       NUMBER;
l_source_subinventory   VARCHAR2(10);
l_source_locator        VARCHAR2(16);
l_source_locator_id     NUMBER;
l_subinventory          VARCHAR2(10);
l_locator               VARCHAR2(16);
l_locator_id            NUMBER;
l_inventory_item_id     NUMBER;
l_parent_lot_number     VARCHAR2(80);
l_lot_number            VARCHAR2(80);
l_lpn_id                NUMBER;
l_lpn                   VARCHAR2(32);

l_wms_enabled_flag      VARCHAR2(1);
l_lot_control_code      NUMBER;
l_grade_control_flag    VARCHAR2(1);
l_child_lot_flag        VARCHAR2(1);
l_lot_status_enabled    VARCHAR2(1);

l_sample_type		VARCHAR2(1);
l_source		VARCHAR2(1);

l_spec_id		NUMBER;
l_spec_vr_id		NUMBER;
l_spec_name		VARCHAR2(30);
l_spec_vers		NUMBER;
l_ctrl_lot_attrib_ind   VARCHAR2(1) ;
l_in_spec_lot_sts_id    VARCHAR2(4) ;
l_out_spec_lot_sts_id   VARCHAR2(4) ;
l_ctrl_batch_step_ind   VARCHAR2(1) ;
l_to_qc_status		NUMBER;
l_to_lot_status_id      NUMBER;
l_to_grade_code		VARCHAR2(4);
l_lot_created		DATE;
l_hold_date		DATE := SYSDATE;
l_sampling_event_date   DATE;
l_from_lot_status_id    NUMBER;
l_from_grade_code       VARCHAR2(4);
l_reason_id             NUMBER;
l_delayed_lot_entry     VARCHAR2(1);
l_delayed_lpn_entry     VARCHAR2(1);

INVALID_SAMPLE          EXCEPTION;
GMD_QC_LESS_LOT_DATE	EXCEPTION;
INVALID_PARAMETERS      EXCEPTION;
LOT_MUST_BE_SPECIFIED   EXCEPTION;
INVALID_DISPOSITION     EXCEPTION;

CURSOR samples_for_event IS
 SELECT sample_req_cnt, sample_active_cnt, sample_taken_cnt
 FROM gmd_sampling_events
 WHERE sampling_event_id = p_change_disp_rec.sampling_event_id;

--Get sample id for single sample group if sampling event is passed
CURSOR get_sample_id IS
 SELECT sample_id
 FROM gmd_samples
 WHERE sampling_event_id = p_change_disp_rec.sampling_event_id;

CURSOR composite_spec_disp(l_event_spec_disp_id NUMBER) IS
 SELECT composite_spec_disp_id
 FROM gmd_composite_spec_disp
 WHERE event_spec_disp_id = l_event_spec_disp_id;

 CURSOR cr_get_lot_status IS
   SELECT control_lot_attrib_ind,
          in_spec_lot_status_id,
          out_of_spec_lot_status_id,
          null
   FROM   gmd_inventory_spec_vrs
   WHERE  spec_vr_id = l_spec_vr_id
   UNION ALL
   SELECT control_lot_attrib_ind,
          in_spec_lot_status_id,
          out_of_spec_lot_status_id,
	  control_batch_step_ind
   FROM   gmd_wip_spec_vrs
   WHERE  spec_vr_id = l_spec_vr_id
   UNION ALL
   SELECT control_lot_attrib_ind,
          in_spec_lot_status_id,
          out_of_spec_lot_status_id,
	  null
   FROM   gmd_supplier_spec_vrs
   WHERE  spec_vr_id = l_spec_vr_id ;

   CURSOR cr_get_delayed_lot_entry IS
	SELECT  delayed_lot_entry
	FROM    GMD_INVENTORY_SPEC_VRS
	WHERE   spec_vr_id = l_spec_vr_id
	UNION ALL
	SELECT  delayed_lot_entry
	FROM    GMD_WIP_SPEC_VRS
	WHERE   spec_vr_id = l_spec_vr_id
	UNION ALL
	SELECT  delayed_lot_entry
	FROM    GMD_SUPPLIER_SPEC_VRS
	WHERE   spec_vr_id = l_spec_vr_id ;

   CURSOR cr_get_delayed_lpn_entry IS
	SELECT  delayed_lpn_entry
	FROM    GMD_INVENTORY_SPEC_VRS
	WHERE   spec_vr_id = l_spec_vr_id
	UNION ALL
	SELECT  delayed_lpn_entry
	FROM    GMD_WIP_SPEC_VRS
	WHERE   spec_vr_id = l_spec_vr_id
	UNION ALL
	SELECT  delayed_lpn_entry
	FROM    GMD_SUPPLIER_SPEC_VRS
	WHERE   spec_vr_id = l_spec_vr_id ;

BEGIN
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Entered Procedure GMD_DISP_PUB.change_disposition');
    END IF;

      --  Initialize API return status to success
	  x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_pos := '000';
    l_update_disp_rec.sample_id :=  p_change_disp_rec.sample_id;
    l_update_disp_rec.sampling_event_id :=  p_change_disp_rec.sampling_event_id;

    --Either one of Sample_id or Sampling_event_id should be entered
    IF (p_change_disp_rec.sample_id IS NOT NULL AND p_change_disp_rec.sampling_event_id IS NOT NULL )
	   OR (p_change_disp_rec.sample_id IS NULL AND p_change_disp_rec.sampling_event_id IS NULL ) THEN
        IF (l_debug = 'Y') THEN
	   gmd_debug.put_line('Either one of Sample_id or Sampling_event_id should be entered');
	END IF;
       RAISE INVALID_PARAMETERS;
    END IF;

    --Either one of LPN or LPN_ID should be entered and will be considered for delayed_lpn_entry
    IF (p_change_disp_rec.sample_id IS NOT NULL AND p_change_disp_rec.sampling_event_id IS NOT NULL ) THEN
        IF (l_debug = 'Y') THEN
	   gmd_debug.put_line('Either one of LPN or LPN_ID should be entered');
	END IF;
       RAISE INVALID_PARAMETERS;
    END IF;

    IF l_update_disp_rec.sample_id IS NOT NULL THEN
      	l_update_disp_rec.event_spec_disp_id  := get_current_event_spec_disp_id(l_update_disp_rec.sample_id,'Y');
    ELSE
     	 l_update_disp_rec.event_spec_disp_id  := get_current_event_spec_disp_id(l_update_disp_rec.sampling_event_id,'N');
  	 IF  l_update_disp_rec.event_spec_disp_id IS NOT NULL THEN
      	   OPEN composite_spec_disp(l_update_disp_rec.event_spec_disp_id);
      	   FETCH composite_spec_disp INTO l_update_disp_rec.composite_spec_disp_id;
      	   CLOSE composite_spec_disp;
      	 END IF;
    END IF;
    l_pos := '001';
    l_update_disp_rec.called_from_results :='N';

    OPEN samples_for_event;
    FETCH samples_for_event INTO  l_sample_req_cnt, l_sample_active_cnt,l_sample_taken_cnt;
    CLOSE samples_for_event;

    l_pos := '002';

    IF NVL(l_sample_req_cnt,1) = 1
       AND NVL(l_sample_req_cnt,1) = NVL(l_sample_active_cnt ,1) THEN
       l_update_disp_rec.no_of_samples_for_event := 1;
       IF l_update_disp_rec.sample_id IS NULL THEN
         OPEN get_sample_id;
         FETCH get_sample_id INTO l_update_disp_rec.sample_id;
         CLOSE get_sample_id;
       END IF;
    ELSE
       l_update_disp_rec.no_of_samples_for_event := 2;
    END IF;

    IF p_change_disp_rec.to_disposition NOT IN ('4A','5AV','6RJ') THEN  --correct error should be initialized
       IF (l_debug = 'Y') THEN
	gmd_debug.put_line('Not a Valid To Disposition');
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   IF l_update_disp_rec.sample_id IS NOT NULL THEN

    SELECT a.organization_id,b.lot_control_code,b.grade_control_flag,b.child_lot_flag,b.lot_status_enabled,a.sample_type,a.source,
           a.inventory_item_id,a.parent_lot_number,a.lot_number,a.lpn_id,a.subinventory,a.locator_id,c.concatenated_segments,a.lpn_id,d.license_plate_number,e.wms_enabled_flag
    INTO l_organization_id,l_lot_control_code,l_grade_control_flag,l_child_lot_flag,l_lot_status_enabled,l_sample_type,l_source,
	 l_inventory_item_id,l_parent_lot_number,l_lot_number,l_lpn_id,l_subinventory,l_locator_id,l_locator,l_lpn_id,l_lpn,l_wms_enabled_flag
    FROM  gmd_samples a,
          mtl_system_items_b b,
          mtl_item_locations_kfv c,
          wms_license_plate_numbers d,
	  mtl_parameters e
    WHERE a.sample_id = l_update_disp_rec.sample_id
    AND   a.delete_mark = 0
    AND   a.organization_id = b.organization_id(+)
    AND   a.inventory_item_id   = b.inventory_item_id(+)
    AND   a.organization_id = c.organization_id(+)
    AND   a.locator_id = c.inventory_location_id(+)
    AND   a.lpn_id = d.lpn_id(+)
    AND   a.organization_id = e.organization_id;

    l_pos := '003';

    -- Get current disposition of Sample from gmd_sample_spec_disp
    SELECT a.DISPOSITION,
           b.EVENT_SPEC_DISP_ID,
           b.spec_id,b.spec_vr_id,
	   c.spec_name,
           c.spec_vers
    INTO   l_update_disp_rec.curr_disposition,l_update_disp_rec.event_spec_disp_id,
	   l_spec_id,l_spec_vr_id,
           l_spec_name,l_spec_vers
    FROM   gmd_sample_spec_disp a,
               gmd_event_spec_disp b,
               gmd_specifications_b c
    WHERE a.sample_id = l_update_disp_rec.sample_id
    AND   a.event_spec_disp_id = b.event_spec_disp_id
    AND   a.delete_mark = 0
    AND   b.SPEC_USED_FOR_LOT_ATTRIB_IND = 'Y'
    AND   b.delete_mark = 0
    AND   b.spec_id = c.spec_id(+);

    l_pos := '004';

      IF  (l_update_disp_rec.no_of_samples_for_event = 1)
	  AND (l_sample_type <> 'M') AND (l_source <> 'T')   --Not a Monitoring Sample and Stability Study Sample
          AND (l_spec_vr_id IS NOT NULL)
          AND (l_lot_control_code = 2)       -- Lot controlled item
          AND (l_lot_number IS NULL)
          AND (l_update_disp_rec.curr_disposition = '3C') THEN

              OPEN  cr_get_delayed_lot_entry;
              FETCH cr_get_delayed_lot_entry INTO l_delayed_lot_entry;
              CLOSE cr_get_delayed_lot_entry;

              IF l_delayed_lot_entry = 'Y' THEN
                IF p_change_disp_rec.lot_number IS NULL THEN
                   RAISE LOT_MUST_BE_SPECIFIED;
                ELSE
                   validate_parentlot_lot (
		           p_inventory_item_id  => l_inventory_item_id
			  ,p_organization_id    => l_organization_id
		   	  ,p_parent_lot_number  => p_change_disp_rec.parent_lot_number
		   	  ,p_lot_number  	=> p_change_disp_rec.lot_number
		   	  ,x_return_status      => l_return_status
		   	  ,x_msg_count          => l_msg_count
		          ,x_msg_data           => l_message_data);

		   IF (l_return_status <> 'S') THEN
		     IF (l_debug = 'Y') THEN
			gmd_debug.put_line('Entered Lot/Sublot is not Valid ');
 		     END IF;
		     RAISE FND_API.G_EXC_ERROR;
       		  ELSE
                    UPDATE GMD_SAMPLES
		    SET parent_lot_number = p_change_disp_rec.parent_lot_number,
		        lot_number        = p_change_disp_rec.lot_number
        	    WHERE sample_id = l_update_disp_rec.sample_id ;

		    UPDATE GMD_SAMPLING_EVENTS
		    SET parent_lot_number = p_change_disp_rec.parent_lot_number,
		        lot_number        = p_change_disp_rec.lot_number
                    WHERE sampling_event_id = (SELECT sampling_event_id FROM gmd_samples
		                               WHERE sample_id = l_update_disp_rec.sample_id );

                    l_parent_lot_number := p_change_disp_rec.parent_lot_number;
        	    l_lot_number        := p_change_disp_rec.lot_number;
		  END IF;
		END IF;
	      END IF;
      END IF;

      IF  (l_update_disp_rec.no_of_samples_for_event = 1)
	  AND (l_sample_type <> 'M') AND (l_source <> 'T')   --Not a Monitoring Sample and Stability Study Sample
          AND (l_spec_vr_id IS NOT NULL)
          AND (l_wms_enabled_flag = 'Y')       -- Org is WMS Enabled
          AND (l_lpn_id IS NULL)
          AND (l_update_disp_rec.curr_disposition = '3C') THEN

              OPEN  cr_get_delayed_lpn_entry;
              FETCH cr_get_delayed_lpn_entry INTO l_delayed_lpn_entry;
              CLOSE cr_get_delayed_lpn_entry;

              IF l_delayed_lpn_entry = 'Y' THEN
                IF p_change_disp_rec.lpn IS NULL AND p_change_disp_rec.lpn_id IS NULL THEN
                   NULL; -- RAISE No need to raise error as LPN is not a mandatory field
                ELSE
                   validate_lpn (
		           p_inventory_item_id  => l_inventory_item_id
			  ,p_organization_id    => l_organization_id
		   	  ,p_lot_number  	=> p_change_disp_rec.lot_number
		   	  ,p_lpn_id             => p_change_disp_rec.lpn_id
		   	  ,p_lpn                => p_change_disp_rec.lpn
			  ,x_lpn_id             => l_lpn_id
			  ,x_lpn                => l_lpn
			  ,x_return_status      => l_return_status
		   	  ,x_msg_count          => l_msg_count
		          ,x_msg_data           => l_message_data);

		   IF (l_return_status <> 'S') THEN
		     IF (l_debug = 'Y') THEN
			gmd_debug.put_line('Entered LPN is not Valid ');
 		     END IF;
		     RAISE FND_API.G_EXC_ERROR;
       		  ELSE
                    UPDATE GMD_SAMPLES
		    SET lpn_id = l_lpn_id
        	    WHERE sample_id = l_update_disp_rec.sample_id ;

		    UPDATE GMD_SAMPLING_EVENTS
		    SET lpn_id = l_lpn_id
                    WHERE sampling_event_id = (SELECT sampling_event_id FROM gmd_samples
		                               WHERE sample_id = l_update_disp_rec.sample_id );

		  END IF;
		END IF;
	      END IF;
      END IF;

    l_pos := '005';

  ELSIF  l_update_disp_rec.composite_spec_disp_id IS NOT NULL THEN

     SELECT gse.organization_id,gse.inventory_item_id,gse.parent_lot_number, gse.lot_number,msi.grade_control_flag,msi.lot_control_code,msi.child_lot_flag,msi.lot_status_enabled,
            gse.creation_date,gse.subinventory,gse.locator_id,mil.concatenated_segments,gse.lpn_id,wlpn.license_plate_number,mp.wms_enabled_flag,
            NVL(gse.sample_type, 'I'),nvl(gse.source,'I'),esd.spec_id,esd.spec_vr_id,csd.disposition,gsb.spec_name,gsb.spec_vers
     INTO   l_organization_id,l_inventory_item_id,l_parent_lot_number,l_lot_number,l_grade_control_flag,l_lot_control_code,l_child_lot_flag,l_lot_status_enabled,
            l_sampling_event_date,l_subinventory,l_locator_id,l_locator,l_lpn_id,l_lpn,l_wms_enabled_flag,
            l_sample_type,l_source,l_spec_id,l_spec_vr_id,l_update_disp_rec.curr_disposition,l_spec_name,l_spec_vers
     FROM   gmd_composite_spec_disp  csd,
            gmd_event_spec_disp esd ,
            gmd_sampling_events gse,
            mtl_system_items_b msi,
            gmd_specifications_b gsb,
            mtl_item_locations_kfv mil,
            wms_license_plate_numbers wlpn,
     	  mtl_parameters mp
     WHERE  csd.composite_spec_disp_id = l_update_disp_rec.composite_spec_disp_id
     AND   csd.event_spec_disp_id = esd.event_spec_disp_id
     AND   esd.sampling_event_id  = gse.sampling_event_id
     AND   gse.organization_id = msi.organization_id(+)
     AND   gse.inventory_item_id = msi.inventory_item_id(+)
     AND   esd.spec_id = gsb.spec_id(+)
     AND   gse.organization_id = mil.organization_id(+)
     AND   gse.locator_id = mil.inventory_location_id(+)
     AND   gse.lpn_id = wlpn.lpn_id(+)
     AND   gse.organization_id = mp.organization_id;

     IF (l_sample_type <> 'M') AND (l_source <> 'T') -- Not a Monitoring and Stability Study Sample
        AND (l_spec_vr_id IS NOT NULL)
        AND (l_lot_control_code = 2)       -- Lot controlled item
        AND (l_lot_number IS NULL)
        AND (l_update_disp_rec.curr_disposition = '3C') THEN

              OPEN  cr_get_delayed_lot_entry;
              FETCH cr_get_delayed_lot_entry INTO l_delayed_lot_entry;
              CLOSE cr_get_delayed_lot_entry;

              IF l_delayed_lot_entry = 'Y' THEN
                IF p_change_disp_rec.lot_number IS NULL THEN
                   RAISE LOT_MUST_BE_SPECIFIED;
                ELSE
                   validate_parentlot_lot (
		           p_inventory_item_id  => l_inventory_item_id
			  ,p_organization_id    => l_organization_id
		   	  ,p_parent_lot_number  => p_change_disp_rec.parent_lot_number
		   	  ,p_lot_number  	=> p_change_disp_rec.lot_number
		   	  ,x_return_status      => l_return_status
		   	  ,x_msg_count          => l_msg_count
		          ,x_msg_data           => l_message_data);

		   IF (l_return_status <> 'S') THEN
		     IF (l_debug = 'Y') THEN
			gmd_debug.put_line('Entered Lot/Sublot is not Valid ');
 		     END IF;
		     RAISE FND_API.G_EXC_ERROR;
       		  ELSE
                    UPDATE GMD_SAMPLES
		    SET parent_lot_number = p_change_disp_rec.parent_lot_number,
		        lot_number        = p_change_disp_rec.lot_number
        	    WHERE sampling_event_id = l_update_disp_rec.sampling_event_id;

		    UPDATE GMD_SAMPLING_EVENTS
		    SET parent_lot_number = p_change_disp_rec.parent_lot_number,
		        lot_number        = p_change_disp_rec.lot_number
                    WHERE sampling_event_id = l_update_disp_rec.sampling_event_id;

                    l_parent_lot_number := p_change_disp_rec.parent_lot_number;
        	    l_lot_number        := p_change_disp_rec.lot_number;
		  END IF;
		END IF;
	      END IF;
     END IF;

     IF (l_sample_type <> 'M') AND (l_source <> 'T') -- Not a Monitoring and Stability Study Sample
        AND (l_spec_vr_id IS NOT NULL)
        AND (l_wms_enabled_flag = 'Y')       -- Org is WMS Enabled
        AND (l_lpn_id IS NULL)
        AND (l_update_disp_rec.curr_disposition = '3C') THEN

              OPEN  cr_get_delayed_lpn_entry;
              FETCH cr_get_delayed_lpn_entry INTO l_delayed_lpn_entry;
              CLOSE cr_get_delayed_lpn_entry;

              IF l_delayed_lpn_entry = 'Y' THEN
                IF p_change_disp_rec.lpn IS NULL AND p_change_disp_rec.lpn_id IS NULL THEN
                   NULL; -- RAISE No need to raise error as LPN is not a mandatory field
                ELSE
                   validate_lpn (
		           p_inventory_item_id  => l_inventory_item_id
			  ,p_organization_id    => l_organization_id
		   	  ,p_lot_number  	=> p_change_disp_rec.lot_number
		   	  ,p_lpn_id             => p_change_disp_rec.lpn_id
		   	  ,p_lpn                => p_change_disp_rec.lpn
			  ,x_lpn_id             => l_lpn_id
		   	  ,x_lpn                => l_lpn
			  ,x_return_status      => l_return_status
		   	  ,x_msg_count          => l_msg_count
		          ,x_msg_data           => l_message_data);

		   IF (l_return_status <> 'S') THEN
		     IF (l_debug = 'Y') THEN
			gmd_debug.put_line('Entered LPN is not Valid ');
 		     END IF;
		     RAISE FND_API.G_EXC_ERROR;
       		   ELSE
                    UPDATE GMD_SAMPLES
		    SET lpn_id = l_lpn_id
        	    WHERE sampling_event_id = l_update_disp_rec.sampling_event_id;

		    UPDATE GMD_SAMPLING_EVENTS
		    SET lpn_id = l_lpn_id
                    WHERE sampling_event_id = l_update_disp_rec.sampling_event_id;

		  END IF;
		END IF;
	      END IF;
      END IF;

   END IF; -- IF sample_id and composite_id

   l_pos := '006';

  --Cheking Current Disposition.
  IF l_update_disp_rec.curr_disposition IN ('0PL','1P','7CN','0RT') THEN
      RAISE INVALID_DISPOSITION;
  ELSIF l_update_disp_rec.curr_disposition IN ('4A','5AV','6RJ')
        AND l_update_disp_rec.sample_id IS NOT NULL THEN
      RAISE INVALID_DISPOSITION;  --Already in Final Disposition. No target disp available.
  END IF;

  IF p_change_disp_rec.reason_code IS NOT NULL THEN
     validate_reason_code (
          p_reason_code     => p_change_disp_rec.reason_code
	 ,x_reason_id       => l_reason_id
	 ,x_return_status   => l_return_status
	 ,x_msg_count       => l_msg_count
	 ,x_msg_data        => l_message_data);

     IF l_return_status <> 'S' THEN
        IF (l_debug = 'Y') THEN
	   gmd_debug.put_line('Not a Valid Reason Code ');
	END IF;
    	RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  IF (l_update_disp_rec.no_of_samples_for_event = 1  OR l_update_disp_rec.composite_spec_disp_id IS NOT NULL) THEN
    IF p_change_disp_rec.to_disposition IN ('4A','5AV','6RJ') THEN
       IF l_spec_vr_id IS NOT NULL THEN
	 OPEN  cr_get_lot_status;
	 FETCH cr_get_lot_status INTO l_ctrl_lot_attrib_ind,l_in_spec_lot_sts_id,l_out_spec_lot_sts_id,l_ctrl_batch_step_ind;
	 CLOSE cr_get_lot_status;
	 IF l_ctrl_batch_step_ind = 'Y' THEN
	    IF p_change_disp_rec.to_disposition = '6RJ' THEN
	       l_to_qc_status := 5;
	    ELSE
	       l_to_qc_status := 6;
	    END IF;
	 ELSE
	    l_to_qc_status := NULL;
	 END IF;
       END IF;

    l_pos := '007';

  IF l_lot_number IS NOT NULL THEN
	IF l_lot_status_enabled = 'Y' THEN
            populate_hold_date (
	        p_parent_lot_number => l_parent_lot_number
	       ,p_lot_number        => l_lot_number
	       ,p_inventory_item_id => l_inventory_item_id
	       ,p_organization_id   => l_organization_id
	       ,x_lot_created       => l_lot_created
	       ,x_hold_date         => l_hold_date );

	    IF l_hold_date < l_lot_created THEN
	     -- hold date cannot be lesser then lot creation date.
	       IF (l_debug = 'Y') THEN
	          gmd_debug.put_line('Hold date cannot be lesser then lot creation date. ');
  	       END IF;
	       RAISE GMD_QC_LESS_LOT_DATE;
            END IF;

	    BEGIN
	      SELECT grade_code, status_id
	      INTO   l_from_grade_code, l_from_lot_status_id
	      FROM   mtl_lot_numbers
	      WHERE  ((lot_number        = l_lot_number) OR  (l_lot_number IS NULL))
	      AND    ((parent_lot_number = l_parent_lot_number) OR  (l_parent_lot_number IS NULL))
	      AND    organization_id   = l_organization_id
	      AND    inventory_item_id = l_inventory_item_id;
	    EXCEPTION
	      WHEN OTHERS THEN
	        NULL;
	    END;

	    IF p_change_disp_rec.to_disposition = '6RJ' THEN
	       l_to_lot_status_id := l_out_spec_lot_sts_id ;
            ELSE
               l_to_lot_status_id := l_in_spec_lot_sts_id ;
            END IF;

	    IF p_change_disp_rec.to_lot_status IS NOT NULL THEN
	       validate_lot_grade_status (
 	            p_is_lot          => 'Y'
		   ,p_status	      => p_change_disp_rec.to_lot_status
		   ,x_return_status   => l_return_status
	 	   ,x_msg_count       => l_msg_count
		   ,x_msg_data        => l_message_data);
	       IF (l_return_status <> 'S') THEN
     	         IF (l_debug = 'Y') THEN
		   gmd_debug.put_line('Lot Status is not valid ');
  	         END IF;
	         RAISE FND_API.G_EXC_ERROR;
               END IF;

               SELECT status_id INTO l_to_lot_status_id
	       FROM mtl_material_statuses
	       WHERE status_code = p_change_disp_rec.to_lot_status
	       AND   enabled_flag = 1;
	    END IF;
        END IF;

    l_pos := '008';
    IF l_grade_control_flag = 'Y' THEN
       IF p_change_disp_rec.to_disposition IN ('4A','5AV') AND p_change_disp_rec.to_grade_code IS NULL THEN
          BEGIN
		SELECT grade_code INTO l_to_grade_code
		FROM  GMD_SPECIFICATIONS_B
		WHERE spec_id = l_spec_id ;
	  EXCEPTION WHEN OTHERS THEN
	    NULL ;
   	  END ;
       END IF;
       IF p_change_disp_rec.to_grade_code IS NOT NULL THEN
        	 validate_lot_grade_status (
	 			 p_is_lot          => 'N'
				,p_status  	   => p_change_disp_rec.to_grade_code
				,x_return_status   => l_return_status
 				,x_msg_count       => l_msg_count
				,x_msg_data        => l_message_data
       			);
	    	IF (l_return_status <> 'S') THEN
     	 	  IF (l_debug = 'Y') THEN
		     gmd_debug.put_line('Grade is not valid ');
  		  END IF;
    	 	  RAISE FND_API.G_EXC_ERROR;
    		END IF;
       END IF;
    END IF; --  grade_control_flag = Y
  END IF;  -- lot_number is NOT NULL

    IF l_to_lot_status_id IS NOT NULL OR l_to_grade_code IS NOT NULL THEN
       BEGIN
	   -- for composite result orgn_code is not shown and is null.
	   IF l_organization_id IS NOT NULL AND l_reason_id IS NULL THEN
	     SELECT transaction_reason_id INTO l_reason_id
	     FROM GMD_QUALITY_CONFIG
	     WHERE organization_id = l_organization_id ;
	   END IF;
	EXCEPTION WHEN OTHERS THEN
	   NULL;
	END;
    END IF; --	 p_change_disp_rec.to_lot_status_id IS NOT NULL
   END IF; --	 p_change_disp_rec.to_disposition IN ('4A','5AV','6RJ')
  END IF;  --    l_update_disp_rec.no_of_samples_for_event = 1

  l_pos := '009';

    Validate_disp (
         p_update_disp_rec => l_update_disp_rec
	,p_to_disposition  => p_change_disp_rec.to_disposition
	,x_return_status   => l_return_status
	,x_msg_count       => l_msg_count
	,x_msg_data        => l_message_data
       );

    l_pos := '010';

    IF (l_return_status <> 'S') THEN
       IF (l_debug = 'Y') THEN
	   gmd_debug.put_line('Entered to Disposition is not Valid');
       END IF;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  GMD_DISP_GRP.update_sample_comp_disp
		( p_update_disp_rec => l_update_disp_rec
		, p_to_disposition  =>  p_change_disp_rec.to_disposition
		, x_return_status   => l_return_status
		, x_message_data    => l_message_data );

   l_pos := '011';
    IF (l_return_status <> 'S') THEN
       IF (l_debug = 'Y') THEN
	  gmd_debug.put_line('Could not change the Disposition of Sample/Group');
       END IF;
       x_msg_data := l_message_data;
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_to_lot_status_id IS NOT NULL THEN
       Gmd_Disp_Grp.update_lot_grade_batch (
    	     p_sample_id              => l_update_disp_rec.sample_id
	   , p_composite_spec_disp_id => l_update_disp_rec.composite_spec_disp_id
	   , p_to_lot_status_id       => l_to_lot_status_id
	   , p_from_lot_status_id     => l_from_lot_status_id
	   , p_to_grade_code	      => NVL(p_change_disp_rec.to_grade_code,l_to_grade_code)
	   , p_from_grade_code	      => l_from_grade_code
	   , p_to_qc_status	      => l_to_qc_status
	   , p_reason_id	      => l_reason_id
	   , p_hold_date              => l_hold_date
	   , x_return_status 	      => l_return_status
	   , x_message_data	      => l_message_data );

	   l_pos := '012';
	   IF (l_return_status <> 'S') THEN
          IF (l_debug = 'Y') THEN
				gmd_debug.put_line('Could not change the lot status/grade');
     	   END IF;
    	   x_msg_data := l_message_data;
       	   RAISE FND_API.G_EXC_ERROR;
	   END IF;
    END IF;

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

EXCEPTION
WHEN INVALID_PARAMETERS THEN
   gmd_api_pub.log_message('GMD_INVALID_PARAMETERS');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN LOT_MUST_BE_SPECIFIED THEN
   gmd_api_pub.log_message('GMD_QM_NO_DELAYED_LOT');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_DISPOSITION THEN
   gmd_api_pub.log_message('GMD_SAMPLE_DISPOSITION_INVALID');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_SAMPLE THEN
   gmd_api_pub.log_message('GMD_QM_INVALID_SAMPLE');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN GMD_QC_LESS_LOT_DATE THEN
   gmd_api_pub.log_message('GMD_QC_LESS_LOT_DATE');
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN FND_API.G_EXC_ERROR THEN
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_DISP_PUB.change_disposition','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_pos);
   x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END change_disposition;

END gmd_disp_pub;

/
