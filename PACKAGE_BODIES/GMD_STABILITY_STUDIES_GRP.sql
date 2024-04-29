--------------------------------------------------------
--  DDL for Package Body GMD_STABILITY_STUDIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_STABILITY_STUDIES_GRP" AS
/* $Header: GMDGSSTB.pls 120.2 2005/09/02 01:55:35 svankada noship $ */

FUNCTION Stability_Study_Exist(p_stability_study_no IN VARCHAR2 )
RETURN BOOLEAN IS
    CURSOR Cur_get_stability_study IS
      SELECT '1'
      FROM  gmd_stability_studies_b
      WHERE ss_no = p_stability_study_no;
      l_temp	VARCHAR2(1);
  BEGIN
    IF (p_stability_study_no IS NOT NULL) THEN
      OPEN Cur_get_stability_study;
      FETCH Cur_get_stability_study INTO l_temp;
      IF (Cur_get_stability_study%FOUND) THEN
        CLOSE Cur_get_stability_study;
        RETURN TRUE;
      ELSE
        CLOSE Cur_get_stability_study;
        RETURN FALSE;
      END IF;
    ELSE
    	RETURN FALSE;
    END IF;
  END Stability_Study_Exist;

FUNCTION calculate_end_date
( p_storage_plan_id	IN NUMBER,
  p_start_date		IN DATE )
RETURN DATE  IS

   CURSOR cur_get_max_period IS
     SELECT MAX(tipp.simulated_date - tip.simulation_start_date) + p_start_date
     FROM  gmd_storage_plan_details spd,gmd_test_interval_plans_b tip, gmd_test_interval_plan_periods tipp
     WHERE
     	 spd.storage_plan_id 	   = p_storage_plan_id
     AND spd.test_interval_plan_id = tip.test_interval_plan_id
     AND tip.test_interval_plan_id = tipp.test_interval_plan_id ;

l_end_date	DATE ;

BEGIN
    IF p_storage_plan_id IS NULL OR p_start_date IS NULL THEN
    	RETURN NULL;
    END IF;

    OPEN  cur_get_max_period;
    FETCH cur_get_max_period INTO l_end_date ;
    CLOSE cur_get_max_period ;

    RETURN (l_end_date);

END calculate_end_date ;


PROCEDURE calculate_sample_qty( --p_ss_id		IN  NUMBER, INVCONV
			       p_source_id 	IN  NUMBER,
			       -- p_item_id	IN  NUMBER, INVCONV
			       p_sample_qty 	OUT NOCOPY NUMBER,
			       p_sample_uom 	OUT NOCOPY VARCHAR2,
			       x_return_status	OUT NOCOPY VARCHAR2)  IS

l_progress  	   	VARCHAR2(3);

CURSOR cr_all_variants IS
   SELECT variant_id , variant_no,retained_samples ,sample_qty , sample_quantity_uom , storage_organization_id -- INVCONV
   FROM   gmd_ss_variants
   WHERE  material_source_id = p_source_id
   AND    delete_mark = 0 ;

l_variant_count			NUMBER(5) := 0 ;
l_variant_no			GMD_SS_VARIANTS.VARIANT_NO%TYPE;
l_tl_samples			NUMBER(5) ;
l_tl_time_points_with_samples	NUMBER(5);
l_tl_time_points		NUMBER(5) ;

VARIANTS_MISSING 		EXCEPTION;
MISSING_RETAINED_SAMPLE		EXCEPTION;
MISSING_SAMPLE_QTY_UOM		EXCEPTION;
MISSING_TIME_POINTS		EXCEPTION;
MISSING_SAMPLE_TIME_POINT	EXCEPTION;
REQ_FIELDS_MISSING		EXCEPTION;

l_material_src_sample_qty_tl	NUMBER  := 0 ;
l_variant_sample_qty_tl		NUMBER  := 0 ;
l_item_uom			VARCHAR2(3); -- INVCONV
--l_lot_id			NUMBER; INVCONV
l_lot_number		VARCHAR2(80); -- INVCONV
l_sample_qty_item_uom		NUMBER;
l_tl_variant_samples		NUMBER(5);
l_inventory_item_id           NUMBER; -- INVCONV
l_organization_id             NUMBER;  -- INVCONV

l_source_organization_id NUMBER;

BEGIN

     l_progress := '010';
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_source_id IS NULL THEN
     	 RAISE REQ_FIELDS_MISSING ;
     END IF;

     -- Retrieving inventory item id  INVCONV
     SELECT inventory_item_id, organization_id INTO l_inventory_item_id, l_organization_id -- INVCONV
      FROM gmd_stability_studies_b
      WHERE ss_id = (SELECT ss_id FROM gmd_ss_material_sources WHERE source_id = p_source_id);

     SELECT source_organization_id INTO l_source_organization_id
     FROM gmd_ss_material_sources
     WHERE source_id = p_source_id;

     SELECT primary_uom_code INTO l_item_uom  -- INVCONV
     FROM mtl_system_items_b
     WHERE inventory_item_id = l_inventory_item_id
     AND organization_id = l_source_organization_id;

     SELECT NVL(lot_number,0) INTO l_lot_number -- INVCONV
     FROM   gmd_ss_material_sources
     WHERE  source_id = p_source_id ;

     l_progress := '020';

     FOR cr_all_variants_rec IN cr_all_variants
     LOOP
     	 l_variant_count := l_variant_count + 1;
     	 l_variant_no := cr_all_variants_rec.variant_no ;

     	 IF cr_all_variants_rec.retained_samples IS NULL THEN
     	 	RAISE MISSING_RETAINED_SAMPLE;
     	 END IF;

     	 IF cr_all_variants_rec.sample_qty IS NULL OR cr_all_variants_rec.sample_quantity_uom IS NULL THEN -- INVCONV
     	 	l_variant_no := cr_all_variants_rec.variant_no ;
     	 	RAISE MISSING_SAMPLE_QTY_UOM;
     	 END IF;

     	 SELECT SUM(samples_per_time_point) , SUM(DECODE(samples_per_time_point,NULL,0,1)) , SUM(1)
     	 INTO   l_tl_samples , l_tl_time_points_with_samples,l_tl_time_points
    	 FROM   gmd_ss_time_points
    	 WHERE  variant_id = cr_all_variants_rec.variant_id
    	 AND    delete_mark = 0 ;

    	 IF l_tl_time_points IS NULL THEN
   	       RAISE MISSING_TIME_POINTS;
    	 END IF;

    	 IF NVL(l_tl_time_points_with_samples,-1) <> l_tl_time_points THEN
    	 	RAISE MISSING_SAMPLE_TIME_POINT;
    	 END IF;

    	 l_tl_variant_samples := l_tl_samples + cr_all_variants_rec.retained_samples ;

    	 l_progress := '030';

    	 -- convert the sample qty for the variant to the primary uom of the item.

      	 BEGIN



   	      /*GMICUOM.icuomcv(pitem_id => p_item_id, -- PAL
                  plot_id  => l_lot_id,
                  pcur_qty => l_tl_variant_samples * cr_all_variants_rec.sample_qty,
                  pcur_uom => cr_all_variants_rec.sample_qty_uom,
                  pnew_uom => l_item_uom,
                  onew_qty => l_sample_qty_item_uom); */


           l_sample_qty_item_uom := INV_CONVERT.INV_UM_CONVERT(l_inventory_item_id -- INVCONV
      			                                      , l_lot_number
      						                          ,l_source_organization_id
                                                      ,5 --NULL
                                                      ,l_tl_variant_samples * cr_all_variants_rec.sample_qty
                                                      ,cr_all_variants_rec.sample_quantity_uom
                                                      ,l_item_uom
                                                      ,NULL -- From uom name
                                                      ,NULL -- To uom name
                                                      );

      	 EXCEPTION WHEN OTHERS
         THEN
              FND_MSG_PUB.ADD;
              RAISE FND_API.G_EXC_ERROR;
      	 END ;

      	 l_material_src_sample_qty_tl := l_material_src_sample_qty_tl + l_sample_qty_item_uom ;

     END LOOP;

     l_progress := '040';

     IF l_variant_count = 0 THEN
        RAISE VARIANTS_MISSING ;
     END IF;

     p_sample_qty := l_material_src_sample_qty_tl ;
     p_sample_uom := l_item_uom ;


EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_STABILITY_STUDIES_GRP.CALCULATE_SAMPLE_QTY');
   x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN MISSING_TIME_POINTS THEN
   IF cr_all_variants%ISOPEN THEN
         CLOSE cr_all_variants;
   END IF ;
   gmd_api_pub.log_message('GMD_SS_TIME_POINTS_NOT_DEF','VARIANT_NO',to_char(l_variant_no));
   x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN MISSING_SAMPLE_TIME_POINT THEN
   IF cr_all_variants%ISOPEN THEN
         CLOSE cr_all_variants;
   END IF ;
   gmd_api_pub.log_message('GMD_SS_TIME_POINT_NO_SMPL','VARIANT_NO',to_char(l_variant_no));
   x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN VARIANTS_MISSING THEN
    IF cr_all_variants%ISOPEN THEN
         CLOSE cr_all_variants;
    END IF ;
    gmd_api_pub.log_message('GMD_SS_NO_RETAIN_SMPL','VARIANT_NO',to_char(l_variant_no));
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN MISSING_SAMPLE_QTY_UOM THEN
    IF cr_all_variants%ISOPEN THEN
         CLOSE cr_all_variants;
    END IF ;
    gmd_api_pub.log_message('GMD_SS_NO_SMPL_QTY_UOM','VARIANT_NO',to_char(l_variant_no));
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN MISSING_RETAINED_SAMPLE THEN
    IF cr_all_variants%ISOPEN THEN
         CLOSE cr_all_variants;
    END IF ;
    gmd_api_pub.log_message('GMD_SS_NO_VARIANT_MTRL_SRC');
    x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN FND_API.G_EXC_ERROR THEN
    IF cr_all_variants%ISOPEN THEN
         CLOSE cr_all_variants;
    END IF ;
    x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
    IF cr_all_variants%ISOPEN THEN
         CLOSE cr_all_variants;
    END IF ;
    gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_STABILITY_STUDIES_GRP.CALCULATE_SAMPLE_QTY','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END calculate_sample_qty ;


PROCEDURE sample_qty_available(p_ss_id   	IN NUMBER,
			       -- p_item_id	IN NUMBER, -- INVCONV
			       x_return_status	OUT NOCOPY VARCHAR2)
IS

CURSOR cr_material_sources_lot IS
SELECT source_id,source_organization_id, lot_number,sample_qty FROM gmd_ss_material_sources -- INVCONV
WHERE ss_id = p_ss_id  and lot_number IS NOT NULL ;

cr_material_sources_lot_rec 	cr_material_sources_lot%ROWTYPE ;

l_onhand_qty		NUMBER ;
l_lot_label		VARCHAR2(100);
l_lot_number		VARCHAR2(80); -- INVCONV
l_inventory_item_id        NUMBER;  -- INVCONV



BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     SELECT inventory_item_id INTO l_inventory_item_id  -- INVCONV
     FROM gmd_stability_studies_b
     WHERE  ss_id = p_ss_id;

-- check is sufficient inventory is there for the material source containing the lot.

     FOR cr_material_sources_lot_rec in cr_material_sources_lot
     LOOP

     	  /*SELECT nvl(sum(loct_onhand),0) INTO l_onhand_qty -- INVCONV
     	  FROM   ic_loct_inv
     	  WHERE  item_id = p_item_id
     	  AND    lot_id  = cr_material_sources_lot_rec.lot_id ; */

     	  SELECT nvl(sum(transaction_quantity),0) INTO l_onhand_qty --INVOCNV
				FROM mtl_onhand_quantities
				WHERE inventory_item_id = l_inventory_item_id
				AND organization_id = cr_material_sources_lot_rec.source_organization_id
				AND lot_number = cr_material_sources_lot_rec.lot_number;

     	  IF cr_material_sources_lot_rec.sample_qty > l_onhand_qty THEN
     	  	l_lot_label := l_lot_number;  -- INVCONV
     	  	gmd_api_pub.log_message('GMD_SS_SMPL_QTY_LESS','LOT',l_lot_label);
   				x_return_status := FND_API.G_RET_STS_ERROR ;
   	  	  RETURN ;
     	  END IF;
     END LOOP;

END sample_qty_available ;

PROCEDURE ss_approval_checklist_ok(p_ss_id IN NUMBER ,
				   x_return_status	OUT NOCOPY VARCHAR2)
IS

l_progress  	   	VARCHAR2(3);

REQ_FIELDS_MISSING	EXCEPTION;
l_material_sources_cnt	NUMBER(5);
l_actual_mtrl_src_cnt   NUMBER(5);
l_inventory_item_id	NUMBER ; -- INVCONV
l_organization_id 	NUMBER; -- INVCONV
l_sample_numbering	NUMBER(3);
l_sample_qty_out	NUMBER;
l_sample_uom_out	GMD_SS_MATERIAL_SOURCES.SAMPLE_QUANTITY_UOM%TYPE ;
l_source_label		VARCHAR2(200);
l_temp			NUMBER;
l_quality_parameters GMD_QUALITY_CONFIG%ROWTYPE; -- INVCONV
l_return_status VARCHAR2(1); -- INVCONV
l_orgn_found BOOLEAN; -- INVCONV
l_source_organization_code VARCHAR2(3);

CURSOR cr_material_sources IS
SELECT source_id FROM gmd_ss_material_sources
WHERE ss_id = p_ss_id ;

CURSOR cr_material_src_variant IS
SELECT source_organization_id,lot_number,recipe_no
FROM gmd_ss_material_sources -- INVCONV
WHERE ss_id = p_ss_id
and not exists
( select 'x' from gmd_ss_variants
  where material_source_id = source_id ) ;

CURSOR cr_variants_storage_spec IS
SELECT a.storage_spec_id,b.spec_name,b.spec_vers
FROM gmd_ss_variants a,gmd_specifications b
WHERE  a.ss_id = p_ss_id
and    a.storage_spec_id = b.spec_id
and    b.spec_status not in (400,700) ;

--Added for INVCONV
CURSOR cr_material_src_organization (p_organization_id NUMBER) IS
SELECT organization_code
FROM mtl_parameters
WHERE organization_id = p_organization_id;

cr_material_sources_rec 	cr_material_sources%ROWTYPE ;
cr_material_src_variant_rec 	cr_material_src_variant%ROWTYPE ;
cr_variants_storage_spec_rec	cr_variants_storage_spec%ROWTYPE ;

BEGIN

     l_progress := '010';
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     FND_MSG_PUB.Initialize;

     IF p_ss_id IS NULL THEN
     	 RAISE REQ_FIELDS_MISSING ;
     END IF;

     SELECT organization_id,material_sources_cnt, inventory_item_id
     INTO   l_organization_id ,l_material_sources_cnt , l_inventory_item_id -- INVCONV
     FROM   gmd_stability_studies_b
     WHERE  ss_id = p_ss_id ;

     -- Sample no. generation should be automatic and not manual.
     l_progress := '020';
     gmd_quality_parameters_grp.get_quality_parameters(p_organization_id => l_organization_id,
                                                                            x_quality_parameters => l_quality_parameters,
                                                                            x_return_status => l_return_status,
                                                                            x_orgn_found => l_orgn_found);

     l_sample_numbering := l_quality_parameters.sample_assignment_type; --INVCONV

     if l_sample_numbering < 0 then
        x_return_status := FND_API.G_RET_STS_ERROR ;
   	    RETURN ;
     elsif l_sample_numbering = 1 THEN -- manual numbering
        gmd_api_pub.log_message('GMD_SS_SMPL_MANUAL_NUM','ORGN',l_organization_id);
    	x_return_status := FND_API.G_RET_STS_ERROR ;
     	RETURN ;
     end if;

     l_progress := '030';
    -- The required number of source materials has been specified.

     SELECT count(1) into l_actual_mtrl_src_cnt
     FROM   gmd_ss_material_sources
     WHERE  ss_id = p_ss_id ;

     IF l_actual_mtrl_src_cnt < l_material_sources_cnt THEN
     	 gmd_api_pub.log_message('GMD_SS_MTRL_SRC_CNT_LESS','MTRL_CNT',to_char(l_material_sources_cnt));
         x_return_status := FND_API.G_RET_STS_ERROR ;
         RETURN;
     END IF;

     -- recalculate the sample qty before approving so that it is latest.
     -- must be able to calculate sample qty for each material source

     l_progress := '040';

     FOR cr_material_sources_rec in cr_material_sources
     LOOP
	    gmd_stability_studies_grp.calculate_sample_qty(
			       p_source_id 	=> cr_material_sources_rec.source_id,
			       p_sample_qty 	=> l_sample_qty_out,
			       p_sample_uom 	=> l_sample_uom_out,
			       x_return_status	=> l_return_status) ;

	    SELECT source_id INTO l_temp
	    FROM gmd_ss_material_sources
	    WHERE source_id = cr_material_sources_rec.source_id
	    FOR UPDATE OF sample_qty NOWAIT ;

	    IF l_return_status = 'S' then
	        UPDATE gmd_ss_material_sources
	        SET sample_qty = l_sample_qty_out,
	             sample_quantity_uom = l_sample_uom_out, -- INVCONV
	             last_updated_by  = fnd_global.user_id,
		         last_update_date  = sysdate,
		         last_update_login = fnd_global.login_id
	        WHERE source_id = cr_material_sources_rec.source_id ;
	    ELSE
	    	x_return_status := l_return_status ;
	    	RETURN;
   	    END IF;
     END LOOP ;

     l_progress := '050';
     -- check is sufficient inventory is there for the material source containing the lot.

     sample_qty_available(p_ss_id  => p_ss_id,
			  x_return_status	=> l_return_status ) ;

     IF l_return_status <> 'S' THEN
           x_return_status := l_return_status ;
           RETURN;
     END IF;

     l_progress := '060';

     -- there should be atleast one variant for every material source defined.

     FOR cr_material_src_variant_rec in cr_material_src_variant
     LOOP
          OPEN cr_material_src_organization(cr_material_src_variant_rec.source_organization_id);
          FETCH cr_material_src_organization INTO l_source_organization_code;
          CLOSE cr_material_src_organization;

          SELECT l_source_organization_code ||
             decode(l_source_organization_code,NULL,NULL,decode(cr_material_src_variant_rec.lot_number || cr_material_src_variant_rec.recipe_no,NULL,NULL,'-')) || -- INVCONV
     	  	 cr_material_src_variant_rec.lot_number || decode(cr_material_src_variant_rec.lot_number,NULL,NULL,decode(cr_material_src_variant_rec.recipe_no,NULL,NULL,'-')) ||  -- INVCONV
     	  	 cr_material_src_variant_rec.recipe_no  INTO l_source_label
     	  FROM  DUAL ;

     	  gmd_api_pub.log_message('GMD_SS_MTRL_SRC_VAR_MISSING','SOURCE',l_source_label);
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
     	  RETURN;
     END LOOP;

     l_progress := '070';
     -- Monitoring specs used for variants should be approved

     FOR cr_variants_storage_spec_rec in cr_variants_storage_spec
     LOOP
     	  gmd_api_pub.log_message('GMD_SS_VAR_STORAGE_SPEC','SPEC',cr_variants_storage_spec_rec.spec_name || '-' || cr_variants_storage_spec_rec.spec_vers);
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
     	  RETURN;
     END LOOP ;

EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_STABILITY_STUDIES_GRP.SS_APPROVAL_CHECKLIST_OK');
   x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_STABILITY_STUDIES_GRP.SS_APPROVAL_CHECKLIST_OK','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END ss_approval_checklist_ok ;

PROCEDURE ss_launch_checklist_ok(p_ss_id  		IN 	   NUMBER ,
			         x_return_status	OUT NOCOPY VARCHAR2)
IS

l_progress		VARCHAR2(3);
l_source_label		VARCHAR2(200);
l_inventory_item_id		NUMBER ; -- INVCONV
l_return_status		VARCHAR2(1);
l_source_organization_code VARCHAR2(3); --INVCONV

REQ_FIELDS_MISSING	EXCEPTION;

CURSOR cr_material_src_smpl_event IS
SELECT source_organization_id,lot_number,recipe_no,sampling_event_id
FROM gmd_ss_material_sources -- INVCONV
WHERE ss_id = p_ss_id
AND (sampling_event_id IS NULL OR lot_number IS NULL) ; -- INVCONV


--Bug#3583299. Changed a condition in the 'where' clause from 'a.ss_id = b.ss_id' to 'a.source_id = b.material_source_id'
--in 'cr_material_src_yield_date' cursor.
CURSOR cr_material_src_yield_date IS
SELECT source_organization_id,lot_number,recipe_no,yield_date,variant_no
FROM gmd_ss_material_sources a , gmd_ss_variants b -- INVCONV
WHERE a.ss_id = p_ss_id
AND   a.source_id = b.material_source_id
AND ((a.yield_date IS NULL) OR (a.yield_date > b.scheduled_start_date)) ;

CURSOR cr_variant_storage_date IS
SELECT source_organization_id,lot_number,recipe_no,variant_no
FROM gmd_ss_material_sources a , gmd_ss_variants b -- INVCONV
WHERE  a.ss_id = p_ss_id
AND    a.ss_id = b.ss_id
AND    b.storage_date IS NULL ;

--Added for INVCONV
CURSOR cr_material_src_organization (p_organization_id NUMBER) IS
SELECT organization_code
FROM mtl_parameters
WHERE organization_id = p_organization_id;

cr_material_src_smpl_event_rec 		cr_material_src_smpl_event%ROWTYPE ;
cr_material_src_yield_date_rec 		cr_material_src_yield_date%ROWTYPE ;
cr_variant_storage_date_rec 		cr_variant_storage_date%ROWTYPE ;

BEGIN

     l_progress := '010';
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     FND_MSG_PUB.Initialize;

     IF p_ss_id IS NULL THEN
     	 RAISE REQ_FIELDS_MISSING ;
     END IF;

     l_progress := '020';

     SELECT inventory_item_id INTO l_inventory_item_id -- INVCONV
     FROM   gmd_stability_studies_b
     WHERE  ss_id = p_ss_id ;

     -- each material source must have sampling event and lot associated with it.

     l_progress := '030';

     FOR cr_material_src_smpl_event_rec in cr_material_src_smpl_event
     LOOP
          --Added for INCONV
          OPEN cr_material_src_organization(cr_material_src_smpl_event_rec.source_organization_id);
          FETCH cr_material_src_organization INTO l_source_organization_code;
          CLOSE cr_material_src_organization;

          SELECT l_source_organization_code ||
             decode(l_source_organization_code,NULL,NULL,decode(cr_material_src_smpl_event_rec.lot_number || cr_material_src_smpl_event_rec.recipe_no,NULL,NULL,'-')) || -- INVCONV
     	  	 cr_material_src_smpl_event_rec.lot_number || decode(cr_material_src_smpl_event_rec.lot_number,NULL,NULL,decode(cr_material_src_smpl_event_rec.recipe_no,NULL,NULL,'-')) || -- INVCONV
     	  	 cr_material_src_smpl_event_rec.recipe_no  INTO l_source_label
     	  FROM  DUAL ;

     	  IF cr_material_src_smpl_event_rec.lot_number IS NULL THEN
     	  	gmd_api_pub.log_message('GMD_SS_MTRL_SRC_LOT_MISSING','SOURCE',l_source_label);
     	  ELSE
     	  	gmd_api_pub.log_message('GMD_SS_MTRL_SRC_EVENT_MISSING','SOURCE',l_source_label);
     	  END IF;
      	    x_return_status := FND_API.G_RET_STS_ERROR ;
     	  RETURN;
     END LOOP;

     l_progress := '040';

    -- yield date is required for each material source and it must be before the variant schedule start date.

     FOR cr_material_src_yield_date_rec in cr_material_src_yield_date
     LOOP
          --Added for INCONV
          OPEN cr_material_src_organization(cr_material_src_yield_date_rec.source_organization_id);
          FETCH cr_material_src_organization INTO l_source_organization_code;
          CLOSE cr_material_src_organization;

          SELECT l_source_organization_code ||
             decode(l_source_organization_code,NULL,NULL,decode(cr_material_src_yield_date_rec.lot_number || cr_material_src_yield_date_rec.recipe_no,NULL,NULL,'-')) || -- INVCONV
     	  	 cr_material_src_yield_date_rec.lot_number || decode(cr_material_src_yield_date_rec.lot_number,NULL,NULL,decode(cr_material_src_yield_date_rec.recipe_no,NULL,NULL,'-')) ||
     	  	 cr_material_src_yield_date_rec.recipe_no  INTO l_source_label
     	  FROM  DUAL ;

     	  IF cr_material_src_yield_date_rec.yield_date IS NULL THEN
     	      gmd_api_pub.log_message('GMD_SS_MTRL_SRC_YIELD_MISSING','SOURCE',l_source_label);
	      ELSE
	          gmd_api_pub.log_message('GMD_SS_INVALID_VAR_SCH_DATE','SOURCE',l_source_label,'VARIANT',cr_material_src_yield_date_rec.variant_no);
    	  END IF;
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
     	  RETURN;
     END LOOP;

     l_progress := '050';

     -- check is sufficient inventory is there for the material source containing the lot.

     sample_qty_available(p_ss_id   		=> p_ss_id,
    			    x_return_status	=> l_return_status ) ;

     IF l_return_status <> 'S' THEN
           x_return_status := l_return_status ;
           RETURN;
     END IF;

     	-- Variants must have the storage date(they must be in the storage before stability study is lauched).
     l_progress := '060';

     FOR cr_variant_storage_date_rec in cr_variant_storage_date
     LOOP
          gmd_api_pub.log_message('GMD_SS_MISS_VAR_STORAGE_DATE','VARIANT',cr_variant_storage_date_rec.variant_no);
    	  x_return_status := FND_API.G_RET_STS_ERROR ;
     	  RETURN;
     END LOOP;


EXCEPTION
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_STABILITY_STUDIES_GRP.SS_LAUNCH_CHECKLIST_OK');
   x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_STABILITY_STUDIES_GRP.SS_LAUNCH_CHECKLIST_OK','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END ss_launch_checklist_ok ;

PROCEDURE change_ss_status(	p_ss_id		IN	NUMBER,
				p_start_status	IN	NUMBER,
				p_target_status	IN	NUMBER,
				x_return_status OUT NOCOPY VARCHAR2,
				x_message	OUT NOCOPY VARCHAR2 ) IS

applicationId NUMBER :=552;
transactionType VARCHAR2(50) := 'GMDQM_STABILITY_CSTS';
nextApprover ame_util.approverRecord;
l_pending_status	NUMBER(5);
l_rework_status		NUMBER(5);
l_event_status		VARCHAR2(20);
l_temp			VARCHAR2(1);
l_return_status		VARCHAR2(1);
l_event_subscription_enabled	BOOLEAN := TRUE ;
l_progress		VARCHAR2(3);
l_temp_index		NUMBER ;

CURSOR cr_subscription_enabled IS
SELECT 'X' from wf_event_subscriptions
WHERE wf_process_name = 'STABILITY_STS_CHANGE'
and status = 'ENABLED' ;


BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      FND_MSG_PUB.Initialize;

      l_progress := '010' ;

      SELECT pending_status,rework_status
      INTO   l_pending_status,l_rework_status
      FROM   gmd_qc_status_next
      WHERE  current_status = p_start_status
      AND    target_status = p_target_status
      AND    entity_type = 'STABILITY' ;

      IF l_pending_status IS NULL OR l_rework_status IS NULL THEN
          GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_STABILITY_STUDIES_B'
                                , p_id            => p_ss_id
                                , p_source_status => p_start_status
                                , p_target_status => p_target_status
                                , p_mode          => 'A'
                                , p_entity_type   => 'STABILITY'
                                , x_return_status => x_return_status
                                , x_message       => x_message );

	   RETURN ;
      ELSE
      -- check if workflow event and subscription are ENABLED or NOT ?

           l_progress := '020' ;

           SELECT status into l_event_status from wf_events where name = 'oracle.apps.gmd.qm.ss.csts' ;

      	   l_progress := '030' ;

      	   IF l_event_status = 'DISABLED' THEN
      	   -- WORKFLOW EVENT IS DISABLED.Status should be the target status which is already taken care by the forms.
      	   	l_event_subscription_enabled := FALSE ;
      	   ELSE
      	   	OPEN cr_subscription_enabled ;
      	   	FETCH cr_subscription_enabled INTO l_temp ;
      	   	IF cr_subscription_enabled%NOTFOUND THEN
      	   	-- none of the subscriptions are enabled.
    	   	      l_event_subscription_enabled := FALSE ;
       	   	END IF;
      	   	CLOSE cr_subscription_enabled ;
      	   END IF;

-- workflow event/subscription is not ACTIVE.Workflow won't get kicked off. We need to create the samples from here.

	   l_progress := '040' ;

      	   IF NOT (l_event_subscription_enabled) THEN

      	   	IF (p_target_status = 400) THEN
		-- We got approved, so kick off API to create sampling events
	 	    GMD_SS_WFLOW_GRP.events_for_status_change(p_ss_id,l_return_status) ;
		    IF l_return_status <> 'S' then
		        x_return_status := l_return_status ;
     	   	  	x_message := FND_MESSAGE.GET;
	  	    END IF;
		ELSIF (p_target_status = 700) THEN
		-- We need to launch; Enable the Mother workflow for testing
		    GMD_API_PUB.RAISE ('oracle.apps.gmd.qm.ss.test',p_ss_id);
		END IF;

		RETURN ;
	   END IF;

	   l_progress := '050' ;

	   -- mchandak. bug#3005685
	   -- as long as the subscription and event is enabled, update the stability status
	   -- to request for approval and kick off the workflow.
	   -- if no approvals are setup , workflow will send notification to the owner of stability study.
	   -- removing the call to AME api's.

           GMD_SPEC_GRP.change_status( p_table_name    => 'GMD_STABILITY_STUDIES_B'
                	                , p_id            => p_ss_id
                        	        , p_source_status => p_start_status
                                	, p_target_status => p_target_status
                                	, p_mode          => 'P'
                                	, p_entity_type   => 'STABILITY'
           			              	, x_return_status => x_return_status
                                	, x_message       => x_message );

           IF x_return_status <> 'S' THEN
          	RETURN;
           END IF;

	-- raise the workflow event
	   GMD_SS_APPROVAL_WF_PKG.RAISE_SS_APPR_EVENT(
          				p_ss_id => p_ss_id,
                                        p_start_status => p_start_status,
                                        p_target_status =>p_target_status);

      END IF ; -- end of IF l_pending_status IS NULL


EXCEPTION
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_STABILITY_STUDIES_GRP.CHANGE_SS_STATUS','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_progress);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   --x_message := FND_MESSAGE.GET;
   FND_MSG_PUB.GET(p_msg_index     => -3,
    	            p_data          => X_message,
        	    p_encoded       => 'F',
	            p_msg_index_out => l_temp_index) ;

END change_ss_status ;

END GMD_STABILITY_STUDIES_GRP;

/
