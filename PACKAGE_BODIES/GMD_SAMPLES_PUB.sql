--------------------------------------------------------
--  DDL for Package Body GMD_SAMPLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SAMPLES_PUB" AS
/*  $Header: GMDPSMPB.pls 120.15.12010000.3 2009/11/17 20:48:41 plowe ship $
 *****************************************************************
 *                                                               *
 * Package  GMD_SAMPLES_PUB                                      *
 *                                                               *
 * Contents CREATE_SAMPLES                                       *
 *          DELETE_SAMPLES                                       *
 *                                                               *
 *                                                               *
 * Use      This is the public layer for the QC SAMPLES          *
 *                                                               *
 * History                                                       *
 *         Written by H Verdding, OPM Development (EMEA)         *
 *                                                               *
 * Updated By              For                                   *
 *                                                               *
 * HVerddin B2711643: Added call to set user_context             *
 *                                                               *
 * 10-APR-2003  H.Verdding  -- Added the following Validation    *
 *                          -- Validate_item_controls            *
 *                          -- Validate_inv_sample               *
 *                          -- Validate_wip_sample               *
 *                          -- Validate_cust_sample              *
 *                          -- Validate_supp_sample              *
 *                          -- Validate_sample                   *
 *                                                               *
 * 20-Mar-2003 Chetan Nagar In error message GMD_SAMPLE_SOURCE_INVALID
 *	pass proper column SOURCE                                *
 *
 * 19-NOV-2003 M. Anil Kumar Bug#3256248                         *
 * Modified cursor c_batch in validate_wip_sample procedure to   *
 * consider completed batches also.                              *
 *
 * 27-JAN-2004 S. Feinstein Bug #3401377
 *       Updated for Mini Pack K (API Version 2.0)
 *       Added the following Validations
 *                 -- Validate_stability_sample
 *                 -- Validate_resource_sample
 *                 -- Validate_location_sample
 *
 * 03-JUN-2004   Saikiran Vankadari   Bug# 3576573. added
 *                              validations for receipt information
 *                              in 'VALIDATE_SUPP_SAMPLE' procedure
 *
 * 20-MAY-2005   Susan Feinstein Bug 4165704 Inventory Convergence
 * 18-OCT-2005   Susan Feinstein Bug 4640143 Added material detail id to gmd_wip_spec_vrs table
 * 05-JAN-2006   Joe DiIorio Bug#4691545 Removed profile reference to
 *                 NVL(fnd_profile.value('QC$EXACTSPECMATCH'),'N');
 *                 and replaced with call to gmd_quality_config.
 *                 Added FUNCTION GET_CONF_MATCH_VALUE as
 *                 profile needs to be retrieved for each org that
 *                 is passed.
 * 18-Jan-2006    Saikiran Fixed bug# 4916871
 * 23-MAR-2006    Peter Lowe FP of 4359797  - 4619570 added code so
 *        that samples are now created for Closed batches
 *        depending upon the profile option but inv is not updated
 * 07-JUN-2006    Peter Lowe - bug 5291723 - check for plant code is obsolete - replace
 *                organization  5291495
 * 09-JUN-2006    Peter Lowe - bug 5291495 - Make sure that the input UOM for the sample qty is validated
 *                for spec type of 'I' (not 'M')
 * 14-JUN-2006    Peter Lowe - bug 5283854 various API creation item sample errors
 * 16-Jun-2006    PLOWE Fixed bug# 5335008 in PROCEDURE VALIDATE_CUST_SAMPLE
 * 		  CURSOR c_order rewritten as part of bug# 5335008
 * 19-May-2008    PLOWE 7027149 added support for LPN
 * 23 Feb-2009    PLOWE 8276017 - make sure SVR lot optional ind is taken into account at correct place in validation
 *
 *************************************************************************************************
*/

--   Global variables

G_PKG_NAME           CONSTANT  VARCHAR2(30):='GMD_SAMPLES_PUB';

-- 5283854
G_LOT_CTL   VARCHAR2(1);
G_CHILD_LOT_FLAG VARCHAR2(1);


-- bug# 2995114
-- create new local function to fetch inventory indicator

FUNCTION get_inventory_ind_from_vr( p_spec_type		IN   VARCHAR2,
				    p_spec_vr_id  	IN   NUMBER )
RETURN VARCHAR2 IS

l_sample_inv_trans_ind	VARCHAR2(1);

BEGIN

	IF p_spec_vr_id IS NULL THEN
	    RETURN (NULL) ;
	END IF;


	-- get spec_type if it is null
	IF p_spec_type IS NULL THEN
 	    /*SELECT s.sample_inv_trans_ind INTO l_sample_inv_trans_ind
 	    FROM gmd_all_spec_vrs WHERE spec_vr_id  = p_spec_vr_id ;*/
	    --Query rewritten as part of bug# 4916871
 	    select s.sample_inv_trans_ind INTO l_sample_inv_trans_ind
 	    FROM  (select spec_vr_id, sample_inv_trans_ind from gmd_inventory_spec_vrs
        union all
        select spec_vr_id, sample_inv_trans_ind from gmd_wip_spec_vrs
        union all
        select spec_vr_id, sample_inv_trans_ind from gmd_customer_spec_vrs
        union all
        select spec_vr_id, sample_inv_trans_ind from gmd_supplier_spec_vrs
        union all
        select spec_vr_id, NULL sample_inv_trans_ind from gmd_monitoring_spec_vrs
        union all
        select spec_vr_id, NULL sample_inv_trans_ind from gmd_stability_spec_vrs) s
 	    WHERE  s.spec_vr_id  = p_spec_vr_id ;
	ELSE
	    IF p_spec_type = 'I' THEN
                SELECT SAMPLE_INV_TRANS_IND INTO  l_sample_inv_trans_ind
    	        FROM   gmd_inventory_spec_vrs
    	        WHERE  spec_vr_id = p_spec_vr_id ;
    	    ELSIF p_spec_type = 'C' THEN
                SELECT SAMPLE_INV_TRANS_IND INTO  l_sample_inv_trans_ind
    	        FROM   gmd_customer_spec_vrs
    	        WHERE  spec_vr_id = p_spec_vr_id ;
    	    ELSIF p_spec_type = 'W' THEN
                SELECT SAMPLE_INV_TRANS_IND INTO  l_sample_inv_trans_ind
    	        FROM   gmd_wip_spec_vrs
    	        WHERE  spec_vr_id = p_spec_vr_id ;
	        ELSIF p_spec_type = 'S' THEN
                SELECT SAMPLE_INV_TRANS_IND INTO  l_sample_inv_trans_ind
    	        FROM   gmd_supplier_spec_vrs
    	        WHERE  spec_vr_id = p_spec_vr_id ;
    	    END IF;

    	END IF; -- IF p_spec_type IS NULL

    	RETURN (l_sample_inv_trans_ind);

EXCEPTION WHEN OTHERS THEN
    RETURN(NULL);

END   get_inventory_ind_from_vr ;



PROCEDURE CREATE_SAMPLES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  NUMBER
, p_qc_samples_rec       IN  GMD_SAMPLES%ROWTYPE
, p_user_name            IN  VARCHAR2
, p_find_matching_spec   IN  VARCHAR2
, p_grade                IN  VARCHAR2 DEFAULT NULL --3431884
, p_lpn                  IN  VARCHAR2 DEFAULT NULL -- 7027149
, x_qc_samples_rec       OUT NOCOPY GMD_SAMPLES%ROWTYPE
, x_sampling_events_rec  OUT NOCOPY GMD_SAMPLING_EVENTS%ROWTYPE
, x_sample_spec_disp     OUT NOCOPY GMD_SAMPLE_SPEC_DISP%ROWTYPE
, x_event_spec_disp_rec  OUT NOCOPY GMD_EVENT_SPEC_DISP%ROWTYPE
, x_results_tab          OUT NOCOPY GMD_API_PUB.gmd_results_tab
, x_spec_results_tab     OUT NOCOPY GMD_API_PUB.gmd_spec_results_tab
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'CREATE_SAMPLES';
  l_api_version           CONSTANT NUMBER        := 3.0;
  l_msg_count             NUMBER  :=0;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_samples_val_rec       GMD_SAMPLES%ROWTYPE;
  l_qc_samples_rec        GMD_SAMPLES%ROWTYPE;
  l_qc_samples_out_rec    GMD_SAMPLES%ROWTYPE;
  l_sample_spec_disp      GMD_SAMPLE_SPEC_DISP%ROWTYPE;
  l_event_spec_disp_rec   GMD_EVENT_SPEC_DISP%ROWTYPE;
  l_sampling_events       GMD_SAMPLING_EVENTS%ROWTYPE;
  l_sampling_events_out   GMD_SAMPLING_EVENTS%ROWTYPE;
  l_results_tab           GMD_API_PUB.gmd_results_tab;
  l_spec_results_tab      GMD_API_PUB.gmd_spec_results_tab;
  l_user_id               NUMBER(15);
  l_assign_type           NUMBER;
  l_sampling_event_id     NUMBER;
  l_sample_req_cnt        NUMBER;
  l_sample_active_cnt     NUMBER;
  l_spec_vr_id            NUMBER;
  l_spec_id               NUMBER;
  l_sampling_plan_id      NUMBER;
  l_date                  DATE := SYSDATE;
  l_spec_type             GMD_SPECIFICATIONS.SPEC_TYPE%TYPE;
  l_sampling_event_exist  VARCHAR2(1);

  -- Bug 4165704: needed to fetch values from quality config table
  quality_config GMD_QUALITY_CONFIG%ROWTYPE;
  found          BOOLEAN;
  l_batch_status        NUMBER; -- Bug # 4619570
  l_sample_inv_trans_ind VARCHAR2(1); -- Bug # 4619570
  L_LOT_OPTIONAL_ON_SAMPLE VARCHAR2(1) := 'N';   -- 5283854
  l_wms_enabled_flag VARCHAR2(1) := 'N';   -- 7027149
  dummy              NUMBER;
-- Cursor Definitions
      -- Bug 4165704: no longer required
      --CURSOR c_doc_numbering ( l_orgn_code VARCHAR2) IS
      --SELECT assignment_type
      --FROM   sy_docs_seq
      --WHERE  orgn_code = l_orgn_code
      --AND    doc_type = 'SMPL';

/*CURSOR c_get_sample_cnt (p_spec_vr_id NUMBER)
IS
SELECT b.sample_cnt_req
FROM   gmd_all_spec_vrs s, gmd_sampling_plans b
WHERE  s.spec_vr_id = p_spec_vr_id
AND    s.sampling_plan_id = b.sampling_plan_id;*/

--CURSOR c_get_sample_cnt rewritten as part of bug# 4916871
CURSOR c_get_sample_cnt (p_spec_vr_id NUMBER)
IS
SELECT b.sample_cnt_req
FROM
(select spec_vr_id, sampling_plan_id from gmd_inventory_spec_vrs
union all
select spec_vr_id, sampling_plan_id from gmd_wip_spec_vrs
union all
select spec_vr_id, sampling_plan_id from gmd_customer_spec_vrs
union all
select spec_vr_id, sampling_plan_id from gmd_supplier_spec_vrs
union all
select spec_vr_id, sampling_plan_id from gmd_monitoring_spec_vrs
union all
select spec_vr_id, sampling_plan_id from gmd_stability_spec_vrs) s, gmd_sampling_plans b
WHERE  s.spec_vr_id = p_spec_vr_id
AND    s.sampling_plan_id = b.sampling_plan_id;

-- Cursors
/*  CURSOR Cur_replenish_whse (replenish_item_id NUMBER) IS
     SELECT whse_code
     FROM   ps_whse_eff
     WHERE  plant_code   = l_qc_samples_out_rec.orgn_code
       AND  whse_item_id = replenish_item_id
       AND  replen_ind   = 1
       AND  delete_mark  = 0;

  CURSOR Cur_replenish_whse_plant IS
     SELECT whse_code
     FROM   ps_whse_eff
     WHERE  plant_code = l_qc_samples_out_rec.orgn_code
       AND  replen_ind = 1
       AND  delete_mark = 0;
*/

CURSOR Cur_batch_status IS  --  Bug # 4619570 Need to know if batch is closed
      SELECT batch_status
      FROM gme_batch_header
      WHERE batch_id =  l_qc_samples_out_rec.batch_id;

-- 5283854
CURSOR c_get_lot_optional (p_spec_vr_id NUMBER)
IS
SELECT LOT_OPTIONAL_ON_SAMPLE
FROM
(select spec_vr_id, LOT_OPTIONAL_ON_SAMPLE from gmd_inventory_spec_vrs
union all
select spec_vr_id, LOT_OPTIONAL_ON_SAMPLE from gmd_wip_spec_vrs
union all
select spec_vr_id, LOT_OPTIONAL_ON_SAMPLE from gmd_customer_spec_vrs
union all
select spec_vr_id, LOT_OPTIONAL_ON_SAMPLE from gmd_supplier_spec_vrs
)
WHERE  spec_vr_id = p_spec_vr_id;

 --  7027149
cursor get_lpn_no(p_lpn VARCHAR2) is
SELECT lpn_id
FROM
WMS_LICENSE_PLATE_NUMBERS WHERE LICENSE_PLATE_NUMBER = p_lpn;

CURSOR get_wms_flag IS
    SELECT wms_enabled_flag
    FROM mtl_parameters
    WHERE organization_id = p_qc_samples_rec.organization_id;

--  7027149
cursor get_lpn is
SELECT 1
FROM
WMS_LICENSE_PLATE_NUMBERS WHERE lpn_id = p_qc_samples_rec.lpn_id;

BEGIN

  -- Standard Start OF API savepoint

  SAVEPOINT CREATE_SAMPLES;

      --dbms_output.put_line('Entered Procedure CREATE_SAMPLES');

  /*  Standard call to check for call compatibility.  */

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  /* Initialize message list if p_int_msg_list is set TRUE.   */
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --   Initialize API return Parameters

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  l_samples_val_rec := p_qc_samples_rec;


  -- Validate User Name Parameter
  GMA_GLOBAL_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'L_USER_NAME', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Added below for BUG 2711643. Hverddin
    GMD_API_PUB.SET_USER_CONTEXT(p_user_id       => l_user_id,
                                 x_return_status => l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_samples_val_rec.created_by      := l_user_id;
    l_samples_val_rec.last_updated_by := l_user_id;
  END IF;


  -- Validate organization_id Passed.
  IF (l_samples_val_rec.organization_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_ORGN_CODE_REQD');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Validate RETAIN_AS Passed.
  IF ((l_samples_val_rec.sample_disposition NOT IN ('0RT', '0PL'))
   AND (l_samples_val_rec.retain_as IS NOT NULL)) THEN
    GMD_API_PUB.Log_Message('GMD_PLANNED_RETAINED_SAMPLES');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Determine Type of Doc Sequencing defined for sample no.
          -- Bug 4165704: doc numbering now kept in quality parameters table
          -- OPEN c_doc_numbering(l_samples_val_rec.orgn_code);
          -- FETCH c_doc_numbering INTO l_assign_type;
          -- IF c_doc_numbering%NOTFOUND THEN
          -- GMD_API_PUB.Log_Message('GMD_ORGN_DOC_SEQ',
          --                          'ORGN_CODE', l_samples_val_rec.orgn_code,
          --                          'DOC_TYPE' , p_user_name);
          -- END IF;
          -- CLOSE c_doc_numbering;

        GMD_QUALITY_PARAMETERS_GRP.get_quality_parameters(
                               p_organization_id    => p_qc_samples_rec.organization_id
                             , x_quality_parameters => quality_config
                             , x_return_status      => l_return_status
                             , x_orgn_found         => found );

        IF (l_return_status <> 'S') THEN
              GMD_API_PUB.Log_Message('GMD_QM_ORG_PARAMETER');
              RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_assign_type   := quality_config.sample_assignment_type;

  -- Assign Sample No if Automatic Numbering Defined.
  IF NVL(l_assign_type,0)  = 2 THEN -- Then auto Sample Numbering defined.
       -- Bug 4165704: routine to get sample no is now handled by quality routine
       -- l_samples_val_rec.sample_no := GMA_GLOBAL_GRP.Get_Doc_No(
       --                            p_doc_type  => 'SMPL',
       --                            p_orgn_code => l_samples_val_rec.orgn_code);

     l_samples_val_rec.sample_no := GMD_QUALITY_PARAMETERS_GRP.get_next_sample_no(l_samples_val_rec.organization_id);
  END IF;

-- bug# 2995114
-- p_qc_samples_out_rec.sample_inv_trans_ind
-- It can have 3 values.
-- Y  - Don't go to VR and fetch the value. Just deduct inventory.
-- N  - Don't go to VR and fetch the value. Don't deduct inventory.
-- null - Fetch the value from VR and depending upon that deduct or do not deduct inventory.


      --dbms_output.put_line('b4 validate sample ');
-- 7027149
 IF ( p_lpn IS NOT NULL OR l_samples_val_rec.lpn_id IS NOT NULL ) THEN
      	OPEN get_wms_flag;
  	  	FETCH get_wms_flag INTO l_wms_enabled_flag;
      	CLOSE get_wms_flag;

  	    IF l_wms_enabled_flag = 'N' then
          GMD_API_PUB.Log_Message('WMS_ONLY_FUNCTIONALITY');
        	RAISE FND_API.G_EXC_ERROR;
      	END IF;

  END IF;  -- IF l_samples_val_rec.lpn IS NOT NULL ) THEN

  IF p_lpn IS NOT NULL THEN
    	OPEN get_lpn_no(p_lpn);
			FETCH get_lpn_no INTO l_samples_val_rec.lpn_id;
			IF get_lpn_no%NOTFOUND THEN
        CLOSE get_lpn_no;
        GMD_API_PUB.Log_Message('WMS_LPN_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
		 CLOSE get_lpn_no;
   END IF;

   IF p_qc_samples_rec.lpn_id IS NOT NULL THEN
    	OPEN get_lpn;
			FETCH get_lpn INTO dummy;
			IF get_lpn%NOTFOUND THEN
        CLOSE get_lpn;
        GMD_API_PUB.Log_Message('WMS_LPN_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
		 CLOSE get_lpn;
   END IF;






  -- Validate Sample Record
  VALIDATE_SAMPLE(
    p_sample_rec    => l_samples_val_rec,
    p_grade         => p_grade,   -- 3431884
    x_sample_rec    => l_qc_samples_rec,
    x_return_status => l_return_status
  );

      --dbms_output.put_line('after validate, before return stat check');

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
  END IF;

      --dbms_output.put_line('after validate, after return stat check');

  IF l_qc_samples_rec.sampling_event_id is NULL THEN

     -- If Sampling Event Id is not specified should we derive it
     IF p_find_matching_spec = 'Y' THEN
        -- bug 3467845
        -- the API was using different sequence for getting spec than the forms
        -- first it was looking if any sampling event exist without a VR.If it exist it will
        -- take the sampling event and won't do a spec match.
        -- changed the whole sequence.
        -- first it will look for the latest spec vr. if the spec is found , it will look for
        -- an VALID sampling event with that spec vr. If it exists , it will assign sample
        -- to that sampling event else create a new event.

         --dbms_output.put_line('FIND MAtching Spec' );

         IF NOT GMD_SAMPLES_PUB.FIND_MATCHING_SPEC
               ( p_samples_rec         => l_qc_samples_rec,
                 p_grade               => p_grade,   -- 3431884
                 x_spec_id             => l_spec_id,
                 x_spec_type           => l_spec_type,
                 x_spec_vr_id          => l_spec_vr_id,
                 x_return_status       => l_return_status,
                 x_msg_data            => l_msg_data
               )THEN
              GMD_API_PUB.Log_Message('GMD_SPEC_NOT_FOUND');
              RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_qc_samples_rec.source IN ('I','C','W','S') AND p_qc_samples_rec.sample_inv_trans_ind IS NULL THEN


         --dbms_output.put_line('b4  get_inventory_ind_from_vr');

           	l_qc_samples_rec.sample_inv_trans_ind := get_inventory_ind_from_vr(
           							 p_spec_type	=> l_spec_type ,
				    	   			 p_spec_vr_id => l_spec_vr_id );

	--dbms_output.put_line('FIND inv indicator for new sampling event=>' || l_qc_samples_rec.sample_inv_trans_ind);
    	 END IF;

-- 5283854 need check here for lot_optional on svr
    	 IF l_qc_samples_rec.source IN ('I','C','W','S')  THEN

         OPEN c_get_lot_optional(l_spec_vr_id);
           FETCH c_get_lot_optional INTO L_LOT_OPTIONAL_ON_SAMPLE;
           IF c_get_lot_optional%NOTFOUND THEN
              CLOSE c_get_lot_optional;
           END IF;
         CLOSE c_get_lot_optional;

       	 IF NVL(L_LOT_OPTIONAL_ON_SAMPLE,'N')  <> 'Y' AND NVL(G_LOT_CTL,0)   = 2 then
             IF ((l_qc_samples_rec.lot_number IS NULL)
       						 AND ((l_qc_samples_rec.parent_lot_number IS NULL) AND (NVL(G_CHILD_LOT_FLAG,'N') = 'Y'))) THEN
          					GMD_API_PUB.Log_Message('GMD_QM_LOT_REQUIRED');  -- 8276017   added this message instead.
          					--GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                     --             'WHAT', 'lot_number');
          					RAISE FND_API.G_EXC_ERROR;

     				 END IF;


         END IF; -- IF L_LOT_OPTIONAL_ON_SAMPLE <> 'Y' then

    	 END IF; --  IF l_qc_samples_rec.source IN ('I','C','W','S')  THEN

       -- find sampling event with matching spec vr id.
         IF GMD_SAMPLES_GRP.sampling_event_exist(
            p_sample             => l_qc_samples_rec,
            x_sampling_event_id  => l_sampling_events.sampling_event_id,
            p_spec_vr_id	 => l_spec_vr_id
            ) THEN

           	NULL ;

         END IF;

       ELSE -- p_find_matching_spec is N

      --dbms_output.put_line('b4  sampling_event_exist_wo_spec');

          -- Try and find a sampling event without a spec
          IF NOT GMD_SAMPLES_GRP.sampling_event_exist_wo_spec
             ( p_sample             => l_qc_samples_rec,
               x_sampling_event_id  => l_sampling_events.sampling_event_id
             ) THEN

             l_spec_vr_id := NULL;

          END IF; --For find matching SE without Spec.

      --dbms_output.put_line('after  sampling_event_exist_wo_spec');


      END IF; -- For find matching spec.
   ELSE -- Sampling event id is passed.
      -- Assign the sampling event id to local sampling event record.
      l_sampling_events.sampling_event_id := l_qc_samples_rec.sampling_event_id;

   END IF; -- sampling_event_id logic

   -- Determine value of sample active cnt
   -- Get this from sampling event.
   -- Bug 3401377: added Planned Samples for MPL and they do not add to active count
   IF (l_qc_samples_rec.sample_disposition  = '0PL')
     OR (l_qc_samples_rec.sample_disposition = '0RT') THEN
      l_sample_active_cnt := 0;
   ELSIF (l_qc_samples_rec.sample_disposition = '1P') THEN
      l_sample_active_cnt := 1;
   ELSE
      GMD_API_PUB.Log_Message('GMD_SAMPLE_DISPOSITION_INVALID');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_sampling_events.sampling_event_id is NULL THEN

       -- bug# 2995114
       l_sampling_event_exist := 'N' ;

     -- we need to create a S.E record.
     --  Only if p_matching_spec is set to Y and find_matching_spec
     -- Returns True will the l_spec_vr_id be populated.


      --dbms_output.put_line('after  get_sample_cnt');

     IF l_spec_vr_id IS NULL THEN
        l_sample_req_cnt := 1;
     ELSE
        -- Check if the validity rule has a sampling plan.
        OPEN c_get_sample_cnt(l_spec_vr_id);
           FETCH c_get_sample_cnt INTO l_sample_req_cnt;
           IF c_get_sample_cnt%NOTFOUND THEN
              l_sample_req_cnt := 1;
           END IF;
        CLOSE c_get_sample_cnt;
     END IF;


      --dbms_output.put_line('after  get sample cnt');

   l_sampling_events.original_spec_vr_id := l_spec_vr_id;
   l_sampling_events.disposition         := l_qc_samples_rec.sample_disposition;
   l_sampling_events.receipt_id          := l_qc_samples_rec.receipt_id;
   l_sampling_events.po_header_id        := l_qc_samples_rec.po_header_id;
   l_sampling_events.source              := l_qc_samples_rec.source;
   l_sampling_events.inventory_item_id   := l_qc_samples_rec.inventory_item_id;
   l_sampling_events.revision            := l_qc_samples_rec.revision;
   l_sampling_events.lot_number          := l_qc_samples_rec.lot_number;
   l_sampling_events.parent_lot_number   := l_qc_samples_rec.parent_lot_number;
   l_sampling_events.subinventory        := l_qc_samples_rec.subinventory;
   l_sampling_events.locator_id          := l_qc_samples_rec.locator_id;
   l_sampling_events.batch_id            := l_qc_samples_rec.batch_id;
   l_sampling_events.recipe_id           := l_qc_samples_rec.recipe_id;
   l_sampling_events.formula_id          := l_qc_samples_rec.formula_id;
   l_sampling_events.formulaline_id      := l_qc_samples_rec.formulaline_id;
   l_sampling_events.material_detail_id  := l_qc_samples_rec.material_detail_id;
   l_sampling_events.routing_id          := l_qc_samples_rec.routing_id;
   l_sampling_events.oprn_id             := l_qc_samples_rec.oprn_id;
   l_sampling_events.charge              := l_qc_samples_rec.charge;
   l_sampling_events.cust_id             := l_qc_samples_rec.cust_id;
   l_sampling_events.order_id            := l_qc_samples_rec.order_id;
   l_sampling_events.order_line_id       := l_qc_samples_rec.order_line_id;
   l_sampling_events.org_id              := l_qc_samples_rec.org_id;
   l_sampling_events.supplier_id         := l_qc_samples_rec.supplier_id;
   l_sampling_events.po_line_id          := l_qc_samples_rec.po_line_id;
   l_sampling_events.receipt_line_id     := l_qc_samples_rec.receipt_line_id;
   l_sampling_events.supplier_lot_no     := l_qc_samples_rec.supplier_lot_no;
   l_sampling_events.supplier_site_id    := l_qc_samples_rec.supplier_site_id;
   l_sampling_events.ship_to_site_id     := l_qc_samples_rec.ship_to_site_id;
   l_sampling_events.step_no             := l_qc_samples_rec.step_no;
   l_sampling_events.step_id             := l_qc_samples_rec.step_id;
   l_sampling_events.lot_retest_ind      := l_qc_samples_rec.lot_retest_ind;
   l_sampling_events.lot_retest_ind      := l_qc_samples_rec.lot_retest_ind;
   l_sampling_events.sample_req_cnt      := l_sample_req_cnt;
   l_sampling_events.sample_taken_cnt    := 1;
   l_sampling_events.sample_active_cnt   := l_sample_active_cnt;
   l_sampling_events.CREATION_DATE       := l_date;
   l_sampling_events.CREATED_BY          := l_user_id;
   l_sampling_events.LAST_UPDATED_BY     := l_user_id;
   l_sampling_events.LAST_UPDATE_DATE    := l_date;
   l_sampling_events.sample_type         := l_qc_samples_rec.sample_type;
   l_sampling_events.organization_id     := l_qc_samples_rec.organization_id;
    -- 7027149
   l_sampling_events.lpn_id             := l_qc_samples_rec.lpn_id;


   -- Bug 3401377: added instance_id, resources, time_point_id and variant_id to sampling event
   --              table for MPK
   l_sampling_events.instance_id         := l_qc_samples_rec.instance_id;
   l_sampling_events.resources           := l_qc_samples_rec.resources;
   l_sampling_events.time_point_id       := l_qc_samples_rec.time_point_id;
   l_sampling_events.variant_id          := l_qc_samples_rec.variant_id;


   -- Bug 3401377: added retain_as, archived_taken, reserved_taken to sampling
   --              event table for MPL

   -- bug# 3465073
   -- l_sampling_events.retain_as         := l_qc_samples_rec.retain_as;

   IF  ((l_qc_samples_rec.retain_as = ( 'A'))
    AND (l_qc_samples_rec.sample_disposition <> '0PL')) THEN
      l_sampling_events.archived_taken := 1;
      l_sampling_events.reserved_taken := 0;
   ELSIF  ((l_qc_samples_rec.retain_as = ( 'R'))
       AND (l_qc_samples_rec.sample_disposition <> '0PL')) THEN
          l_sampling_events.archived_taken := 0;
          l_sampling_events.reserved_taken := 1;
   ELSE
          l_sampling_events.archived_taken := 0;
          l_sampling_events.reserved_taken := 0;
   END IF;


      --dbms_output.put_line('before insert se row ');

   IF NOT GMD_SAMPLING_EVENTS_PVT.insert_row (
       p_sampling_events => l_sampling_events,
       x_sampling_events => l_sampling_events_out) THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

      --dbms_output.put_line('after insert se row ');


       -- Bug 2987571: make sure sample instance is saved to new sample
     l_qc_samples_rec.sample_instance    := 1;

  ELSE -- WE need to update the SE table.


      --dbms_output.put_line('WE need to update the SE table. ');

       -- bug# 2995114
       l_sampling_event_exist := 'Y' ;

     IF NOT GMD_SAMPLING_EVENTS_PVT.lock_row
          (
           p_sampling_event_id  =>  l_sampling_events.sampling_event_id
          ) THEN
          GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                     'l_table_name', 'GMD_SAMPLING_EVENTS',
                     'l_column_name','SAMPLING_EVENT_ID',
                     'l_key_value', l_sampling_events.sampling_event_id);
          RAISE FND_API.G_EXC_ERROR;
     ELSE
        -- Bug 3401377: added retain_as, archived_taken, reserved_taken to sampling
        --              event table for MPL
        IF  ((l_qc_samples_rec.retain_as = ( 'A'))
         AND (l_qc_samples_rec.sample_disposition <> '0PL')) THEN
           l_sampling_events.archived_taken := 1;
           l_sampling_events.reserved_taken := 0;
        ELSIF  ((l_qc_samples_rec.retain_as = ( 'R'))
            AND (l_qc_samples_rec.sample_disposition <> '0PL')) THEN
               l_sampling_events.archived_taken := 0;
          l_sampling_events.reserved_taken := 1;
        ELSE
          l_sampling_events.archived_taken := 0;
          l_sampling_events.reserved_taken := 0;
        END IF;

        -- Update the sampling events Table
        -- Bug 3401377: added archived_taken, reserved_taken to sampling event
        UPDATE GMD_SAMPLING_EVENTS
        SET    SAMPLE_TAKEN_CNT  = sample_taken_cnt + 1,
               SAMPLE_ACTIVE_CNT = sample_active_cnt + l_sample_active_cnt ,
               ARCHIVED_TAKEN    = NVL(ARCHIVED_TAKEN, 0) +    l_sampling_events.archived_taken ,
               RESERVED_TAKEN    = NVL(RESERVED_TAKEN, 0) +    l_sampling_events.reserved_taken ,
               LAST_UPDATED_BY   = l_user_id,
               LAST_UPDATE_DATE  = l_date
        WHERE  SAMPLING_EVENT_ID = l_sampling_events.sampling_event_id;

        IF NOT  GMD_SAMPLING_EVENTS_PVT.fetch_row(
          p_sampling_events => l_sampling_events,
          x_sampling_events => l_sampling_events_out) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

          -- Bug 2987571: make sure sample instance is saved to new sample
          -- Select from the sampling events Table
        SELECT sample_taken_cnt INTO l_qc_samples_rec.sample_instance
        FROM GMD_SAMPLING_EVENTS
        WHERE  SAMPLING_EVENT_ID = l_sampling_events.sampling_event_id;

     END IF;

  END IF;

   --dbms_output.put_line('Insert SAMPLE Row');

  l_qc_samples_rec.delete_mark       := 0;
  l_qc_samples_rec.last_update_date  := l_date;
  l_qc_samples_rec.creation_date     := l_date;
  l_qc_samples_rec.sampling_event_id := l_sampling_events_out.sampling_event_id;

    -- Bug 2987571: make sure sample remaining qty is saved to new sample
    --l_qc_samples_rec.remaining_qty     := l_qc_samples_rec.sample_qty;
  IF (l_qc_samples_rec.sample_type = 'I' ) THEN
       -- Bug 3401377: added Planned Samples for MPL and they may have null qty
     IF (l_qc_samples_rec.remaining_qty IS NULL)
      AND (l_qc_samples_rec.sample_disposition <> '0PL' ) THEN
           l_qc_samples_rec.remaining_qty := l_qc_samples_rec.sample_qty;
     END IF;
  END IF;

  -- bug# 2995114
  -- possible values in database are Y and null.


  IF p_qc_samples_rec.sample_inv_trans_ind = 'N' THEN
      l_qc_samples_rec.sample_inv_trans_ind := NULL ;
  END IF;


  IF NOT GMD_SAMPLES_PVT.insert_row (
      p_samples  => l_qc_samples_rec,
      x_samples  => l_qc_samples_out_rec) THEN
      RAISE FND_API.G_EXC_ERROR;

  END IF;


   --dbms_output.put_line('end Insert SAMPLE Row');

   -- Lets Create the Corresponding Result records.
   -- Only if the sample disposition is not RETAIN

   -- Bug 3401377: added disposition '0PL' in MPL
   --             and add 'migration' parameter to function call   (added for planned samples)
   --             and if disposition = retained, the create rslt routine still needs to be called
   --IF l_qc_samples_out_rec.sample_disposition <> '0RT' THEN

   -- bug# 3468060
   -- if a planned sample was created using public layer api and queried in forms application,
   -- it was not querying the record. Error message was shown with no rows in gmd_sample_spec_disp
   -- removed the below if condition for planned samples. Need to create event spec dispositions rows.
   --IF l_qc_samples_out_rec.sample_disposition <> '0PL' THEN
      GMD_RESULTS_GRP.create_rslt_and_spec_rslt_rows(
          p_sample            => l_qc_samples_out_rec,
          p_migration         => 'N',
          x_sample_spec_disp  => l_sample_spec_disp,
          x_event_spec_disp   => l_event_spec_disp_rec,
          x_results_tab       => l_results_tab,
          x_spec_results_tab  => l_spec_results_tab,
          x_return_status     => l_return_status);

       -- dbms_output.put_line('RES Return Status => ' || l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

        --dbms_output.put_line('end RES Return Status => ' || l_return_status);


       -- bug# 2995114
       -- if new sample is tied to existing sampling event, get_spec_match is not called and hence
       -- inventory indictor is not fetched.
       -- we need to fetch indicator whether to decrease(update) inventory for the sample for an
       -- existing sampling event.

       IF l_sampling_event_exist = 'Y' and l_qc_samples_rec.source IN ('I','C','W','S')
           AND p_qc_samples_rec.sample_inv_trans_ind IS NULL THEN

            l_qc_samples_rec.sample_inv_trans_ind := get_inventory_ind_from_vr(
        					 p_spec_type	=> NULL ,
				    	   	 p_spec_vr_id => l_event_spec_disp_rec.spec_vr_id );

	    l_qc_samples_out_rec.sample_inv_trans_ind	:= l_qc_samples_rec.sample_inv_trans_ind ;
            l_sample_inv_trans_ind := l_qc_samples_out_rec.sample_inv_trans_ind; -- Bug # 4619570

            IF l_qc_samples_out_rec.batch_id IS NOT NULL THEN -- Bug # 4619570
                  OPEN Cur_batch_status;
                  FETCH Cur_batch_status into l_batch_status;
                  CLOSE Cur_batch_status;

                   IF l_batch_status = 4 then

                   	l_sample_inv_trans_ind := NULL;
                   END IF;
            END IF;




	    UPDATE gmd_samples
	    SET SAMPLE_INV_TRANS_IND = 	l_sample_inv_trans_ind  -- Bug # 4619570
	    WHERE sample_id  = l_qc_samples_out_rec.sample_id ;

       END IF;

        --dbms_output.put_line('1');

       -- end of bug 2995114

  --END IF;


  -- Added new functionality as part of BUG 2677712.
  -- If sample  source not wip and sample_inv_trans_id
  -- is set to Y call create inv transaction.
  -- If source type is Wip then create wip transaction


  -- Bug 3401377 : if planned sample, do not generate the inventory transaction (from MPL)
  IF l_qc_samples_out_rec.source               <> 'W'   AND
     l_qc_samples_out_rec.sample_disposition   <> '0PL' AND
     l_qc_samples_out_rec.sample_inv_trans_ind  = 'Y'     THEN

     -- Bug 3516802; changed test from 'NVL' to 'is not null'
     IF (l_qc_samples_out_rec.source = 'S')  THEN
        IF (l_qc_samples_out_rec.source_subinventory IS NOT NULL ) THEN
          l_qc_samples_out_rec.subinventory := l_qc_samples_out_rec.source_subinventory;
          l_qc_samples_out_rec.locator_id := l_qc_samples_out_rec.source_locator_id;
        END IF;   -- source = 'S'

        IF (l_qc_samples_out_rec.source_subinventory IS NULL )  THEN
             GMD_API_PUB.Log_Message('GMD_QM_NO_INVENTORY_TRANS_API2');
             RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_qc_samples_out_rec.receipt_line_id IS NULL ) THEN
             GMD_API_PUB.Log_Message('GMD_QM_NO_INVENTORY_TRANS_API');
             RAISE FND_API.G_EXC_ERROR;
        END IF;

     --END IF;  -- end Bug 3516802

     -- Bug 3491783: if whse is not specified, can not generate inv trans
     ELSIF (l_qc_samples_out_rec.subinventory IS NULL) THEN
        GMD_API_PUB.Log_Message('GMD_QM_WHSE_REQ_INV');
        RAISE FND_API.G_EXC_ERROR;
     END IF; -- end bug


     GMD_SAMPLES_GRP.create_inv_txn
     ( p_sample          => l_qc_samples_out_rec,
       p_user_name       => l_user_id,
       x_return_status   => l_return_status,
       x_message_count   => l_msg_count,
       x_message_data    => l_msg_data
     );

--dbms_output.put_line('after create inv txn');

      --  dbms_output.put_line('end create inv txn Return Status => ' || l_return_status);

     IF (l_return_status <> 'S') THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
  -- Bug 3401377 : if planned sample, do not generate the inventory transaction (from MPL)
   ELSIF l_qc_samples_out_rec.source               = 'W'   AND
         l_qc_samples_out_rec.sample_disposition  <> '0PL' AND
         l_qc_samples_out_rec.sample_inv_trans_ind = 'Y'     THEN

   -- bug# 2995114
   -- added code to get whse for wip sample.
        -- bug 4165704: source subinventory is now retrieved from mtl_system_items
        --IF l_qc_samples_out_rec.source_whse IS NULL THEN
        -- Get Replenish Warehouse for item and/or plant
        --     OPEN  Cur_replenish_whse(l_qc_samples_out_rec.inventory_item_id);
        --    FETCH Cur_replenish_whse INTO l_qc_samples_out_rec.source_whse ;
        --     IF Cur_replenish_whse%NOTFOUND THEN
        --       CLOSE Cur_replenish_whse;
        --       OPEN  Cur_replenish_whse_plant;
        --       FETCH Cur_replenish_whse_plant INTO l_qc_samples_out_rec.source_whse ;
        --       IF Cur_replenish_whse_plant%NOTFOUND THEN
        --         CLOSE Cur_replenish_whse_plant;
        --         GMD_API_PUB.Log_Message('GMD_REPLENISH_WHSE_NOT_FOUND');
        --         RAISE FND_API.G_EXC_ERROR;
        --       END IF;
        --       CLOSE Cur_replenish_whse_plant;
        --     ELSE
        --       CLOSE Cur_replenish_whse;
        --     END IF;

	-- need to update source whse back to samples since insert of sample has already taken place.
             UPDATE GMD_SAMPLES
             SET source_subinventory = l_qc_samples_out_rec.source_subinventory
             WHERE sample_id = l_qc_samples_out_rec.sample_id ;

    --  END IF;

	-- Bug # 4619570 Disable create_wip_txn for wip sample against closed batch
        IF l_qc_samples_out_rec.batch_id IS NOT NULL THEN
                OPEN Cur_batch_status;
                FETCH Cur_batch_status into l_batch_status;
                CLOSE Cur_batch_status;

	        IF l_batch_status <> 4 then

			GMD_SAMPLES_GRP.create_wip_txn
     			( p_sample          => l_qc_samples_out_rec,
       			x_return_status   => l_return_status,
       			x_message_count   => l_msg_count,
       			x_message_data    => l_msg_data
     			);

     			IF (l_return_status <> 'S') THEN
       				RAISE FND_API.G_EXC_ERROR;
     			END IF;


    			GMD_SAMPLES_GRP.post_wip_txn
    			( p_batch_id      => l_qc_samples_out_rec.batch_id,
     			x_return_status => l_return_status
    			);

			IF (l_return_status <> 'S') THEN
		       		RAISE FND_API.G_EXC_ERROR;
		    	END IF;

			    -- bug# 2995114
			    -- added create_inv_txn to decrease the inventory which was increased by create_wip_txn/post_wip_txn

			    --dbms_output.put_line('create inv trans after wip');

			    GMD_SAMPLES_GRP.create_inv_txn
			     ( p_sample          => l_qc_samples_out_rec,
			       p_user_name       => p_user_name,
			       x_return_status   => l_return_status,
			       x_message_count   => l_msg_count,
			       x_message_data    => l_msg_data
			     );


			     IF (l_return_status <> 'S') THEN
			      	 RAISE FND_API.G_EXC_ERROR;
   			     END IF;

		 END IF; --   IF l_batch_status <> 4 then

 	END IF;
  END IF;
  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Set return Parameters

  x_return_status        := l_return_status;
  x_qc_samples_rec       := l_qc_samples_out_rec;
  x_sampling_events_rec  := l_sampling_events_out;
  x_results_tab          := l_results_tab;
  x_spec_results_tab     := l_spec_results_tab;
  x_event_spec_disp_rec  := l_event_spec_disp_rec;
  x_sample_spec_disp     := l_sample_spec_disp;

--dbms_output.put_line('The end');


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_SAMPLES;
      x_return_status := FND_API.G_RET_STS_ERROR;
	      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
					 , p_count => x_msg_count
					 , p_data  => x_msg_data
					);

	    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	      ROLLBACK TO CREATE_SAMPLES;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO CREATE_SAMPLES;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END CREATE_SAMPLES;

/*=====================================
   Function added by Joe DiIorio
   Bug#4691545  01/05/2006
  =====================================*/
FUNCTION GET_CONF_MATCH_VALUE
( p_org_id            IN  NUMBER
)

RETURN VARCHAR2

IS

CURSOR get_match_ind IS
SELECT exact_spec_match_ind
FROM   gmd_quality_config
WHERE  organization_id = p_org_id;

l_exact_spec_match_ind    gmd_quality_config.exact_spec_match_ind%TYPE;

BEGIN
   OPEN get_match_ind;
   FETCH get_match_ind INTO l_exact_spec_match_ind;
   IF (get_match_ind%NOTFOUND) THEN
       CLOSE get_match_ind;
       RETURN 'N';
   END IF;
   CLOSE get_match_ind;
   RETURN NVL(l_exact_spec_match_ind,'N');

END GET_CONF_MATCH_VALUE;

FUNCTION FIND_MATCHING_SPEC
( p_samples_rec       IN  GMD_SAMPLES%ROWTYPE,
  p_grade             IN  VARCHAR2 DEFAULT NULL, -- 3431884
  x_spec_id           OUT NOCOPY NUMBER,
  x_spec_type         OUT NOCOPY VARCHAR2,
  x_spec_vr_id        OUT NOCOPY NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_data          OUT NOCOPY VARCHAR2
)


RETURN BOOLEAN
IS
l_inv_spec         GMD_SPEC_MATCH_GRP.INVENTORY_SPEC_REC_TYPE;
l_cust_spec        GMD_SPEC_MATCH_GRP.CUSTOMER_SPEC_REC_TYPE;
l_supp_spec        GMD_SPEC_MATCH_GRP.SUPPLIER_SPEC_REC_TYPE;
l_wip_spec         GMD_SPEC_MATCH_GRP.WIP_SPEC_REC_TYPE;
l_location_spec    GMD_SPEC_MATCH_GRP.LOCATION_SPEC_REC_TYPE;
l_resource_spec    GMD_SPEC_MATCH_GRP.RESOURCE_SPEC_REC_TYPE;

BEGIN


  IF p_samples_rec.source = 'I' THEN -- Find matching inventory spec.

    -- Build inventory spec record
    l_inv_spec.inventory_item_id   := p_samples_rec.inventory_item_id;
    l_inv_spec.revision            := p_samples_rec.revision         ;
    l_inv_spec.grade_code          := p_grade;  -- 3431884
    l_inv_spec.organization_id     := p_samples_rec.organization_id ;
    l_inv_spec.lot_number          := p_samples_rec.lot_number;
    l_inv_spec.parent_lot_number   := p_samples_rec.parent_lot_number;
    l_inv_spec.subinventory        := p_samples_rec.subinventory;
    l_inv_spec.locator_id          := p_samples_rec.locator_id;
    -- Bug3151607 - Use the date drawn instead of creation date.
    -- l_inv_spec.date_effective   := NVL(p_samples_rec.creation_date,SYSDATE);
    l_inv_spec.date_effective      := NVL(p_samples_rec.date_drawn,SYSDATE);

    /*====================================================
       BUG#4691545 - get gmd_quality_config match value.
      ====================================================*/
    l_inv_spec.exact_match := get_conf_match_value(p_samples_rec.organization_id);

    -- Find Inventory Spec.


    IF GMD_SPEC_MATCH_GRP.FIND_INVENTORY_SPEC(
        p_inventory_spec_rec => l_inv_spec,
        x_spec_id            => x_spec_id,
        x_spec_vr_id         => x_spec_vr_id,
        x_return_status      => x_return_status,
        x_message_data       => x_msg_data) THEN

        RETURN TRUE;
        -- dbms_output.put_line('Return True');
    END IF;

  ELSIF p_samples_rec.source = 'C' THEN -- Find Matching Customer spec

    l_cust_spec.inventory_item_id := p_samples_rec.inventory_item_id;
    l_cust_spec.revision          := p_samples_rec.revision;
    l_cust_spec.grade_code        := p_grade; -- 3431884
    l_cust_spec.organization_id   := p_samples_rec.organization_id;
    l_cust_spec.subinventory      := p_samples_rec.subinventory;
    l_cust_spec.org_id            := p_samples_rec.org_id;
    l_cust_spec.cust_id           := p_samples_rec.cust_id;
    l_cust_spec.ship_to_site_id   := p_samples_rec.ship_to_site_id;
    l_cust_spec.order_id          := p_samples_rec.order_id;
    l_cust_spec.order_line_id     := p_samples_rec.order_line_id;
    l_cust_spec.lot_number        := p_samples_rec.lot_number;
    l_cust_spec.parent_lot_number := p_samples_rec.parent_lot_number;

    /*====================================================
       BUG#4691545 - get gmd_quality_config match value.
      ====================================================*/
    l_cust_spec.exact_match := get_conf_match_value(p_samples_rec.organization_id);
    -- Bug3151607
    l_cust_spec.date_effective   := NVL(p_samples_rec.date_drawn,SYSDATE);

    -- Find Cust Spec.

    IF GMD_SPEC_MATCH_GRP.FIND_CUST_OR_INV_SPEC(
        p_customer_spec_rec => l_cust_spec,
        x_spec_id            => x_spec_id,
        x_spec_vr_id         => x_spec_vr_id,
        x_spec_type          => x_spec_type,
        x_return_status      => x_return_status,
        x_message_data       => x_msg_data) THEN


        RETURN TRUE;
    END IF;

  ELSIF p_samples_rec.source = 'W' THEN -- Find Matching Prod Spec.

    l_wip_spec.inventory_item_id          := p_samples_rec.inventory_item_id;
    l_wip_spec.revision            := p_samples_rec.revision;
    l_wip_spec.grade_code          := p_grade; -- 3431884
    l_wip_spec.organization_id     := p_samples_rec.organization_id;
    -- l_wip_spec.whse_code        := p_samples_rec.whse_code;
    l_wip_spec.batch_id            := p_samples_rec.batch_id;
    l_wip_spec.recipe_id           := p_samples_rec.recipe_id;
    l_wip_spec.formula_id          := p_samples_rec.formula_id;
    l_wip_spec.formulaline_id      := p_samples_rec.formulaline_id;
    l_wip_spec.material_detail_id  := p_samples_rec.material_detail_id;
    l_wip_spec.routing_id          := p_samples_rec.routing_id;
    l_wip_spec.step_id             := p_samples_rec.step_id;
    l_wip_spec.step_no             := p_samples_rec.step_no;
    l_wip_spec.oprn_id             := p_samples_rec.oprn_id;
    l_wip_spec.charge              := p_samples_rec.charge;
    -- Bug 3151607 - Use the date drawn instead of creation date.
    -- l_wip_spec.date_effective   := NVL(p_samples_rec.creation_date,SYSDATE);
    l_wip_spec.date_effective      := NVL(p_samples_rec.date_drawn,SYSDATE);
    l_wip_spec.lot_number          := p_samples_rec.lot_number;
    l_wip_spec.parent_lot_number   := p_samples_rec.parent_lot_number;

    /*====================================================
       BUG#4691545 - get gmd_quality_config match value.
      ====================================================*/
    l_wip_spec.exact_match := get_conf_match_value(p_samples_rec.organization_id);


    -- Find WIP Spec.

    IF GMD_SPEC_MATCH_GRP.FIND_WIP_OR_INV_SPEC(
        p_wip_spec_rec       => l_wip_spec,
        x_spec_id            => x_spec_id,
        x_spec_vr_id         => x_spec_vr_id,
        x_spec_type          => x_spec_type,
        x_return_status      => x_return_status,
        x_message_data       => x_msg_data) THEN

        RETURN TRUE;
    END IF;


  ELSIF p_samples_rec.source= 'S' THEN -- Find Matching Supplier Spec.

   --dbms_output.put_line('CAlling Supplier Spec MAtching');

    l_supp_spec.inventory_item_id   := p_samples_rec.inventory_item_id;
    l_supp_spec.revision            := p_samples_rec.revision ;
    l_supp_spec.organization_id     := p_samples_rec.organization_id;
    l_supp_spec.subinventory        := p_samples_rec.subinventory;
    l_supp_spec.org_id              := p_samples_rec.org_id;
    l_supp_spec.supplier_id         := p_samples_rec.supplier_id;
    l_supp_spec.po_header_id        := p_samples_rec.po_header_id;
    l_supp_spec.po_line_id          := p_samples_rec.po_line_id;
    -- bug# 3447362
    -- passing supplier_site_id.was missing before
    l_supp_spec.supplier_site_id    := p_samples_rec.supplier_site_id;
    l_supp_spec.grade_code          := p_grade; -- 3431884
    -- Bug 3151607 - Use the date drawn instead of creation date.
    l_supp_spec.date_effective      := NVL(p_samples_rec.date_drawn,SYSDATE);
    l_supp_spec.lot_number          := p_samples_rec.lot_number;
    l_supp_spec.parent_lot_number   := p_samples_rec.parent_lot_number;

    /*====================================================
       BUG#4691545 - get gmd_quality_config match value.
      ====================================================*/
    l_supp_spec.exact_match := get_conf_match_value(p_samples_rec.organization_id);

    -- Bug #3401377  : added rec_whse and rec_location to form  MPL
   l_supp_spec.subinventory         := p_samples_rec.subinventory;
   l_supp_spec.locator_id           := p_samples_rec.locator_id;


    -- Find Supplier Spec.

    IF GMD_SPEC_MATCH_GRP.FIND_SUPPLIER_OR_INV_SPEC(
        p_supplier_spec_rec => l_supp_spec,
        x_spec_id           => x_spec_id,
        x_spec_vr_id        => x_spec_vr_id,
        x_spec_type         => x_spec_type,
        x_return_status     => x_return_status,
        x_message_data      => x_msg_data) THEN

        RETURN TRUE;
    END IF;

    -- Bug #3401377  : added get spec for location, resource and stability samples
  ELSIF p_samples_rec.source= 'L' THEN -- Find Matching Location Spec.

    l_location_spec.subinventory             := p_samples_rec.subinventory;
    l_location_spec.locator_id               := p_samples_rec.locator_id;
    l_location_spec.locator_organization_id  := p_samples_rec.organization_id;
    l_location_spec.date_effective           := NVL(p_samples_rec.date_drawn,sysdate);

    IF GMD_SPEC_MATCH_GRP.FIND_LOCATION_SPEC(
        p_location_spec_rec  => l_location_spec,
        x_spec_id 	     => x_spec_id,
        x_spec_vr_id         => x_spec_vr_id,
        x_return_status      => x_return_status,
        x_message_data       => x_msg_data) THEN

        RETURN TRUE;
    END IF;

  ELSIF p_samples_rec.source= 'R' THEN -- Find Matching Resource Spec.
    l_resource_spec.resources                := p_samples_rec.resources;
    l_resource_spec.resource_instance_id     := p_samples_rec.instance_id;
    l_resource_spec.resource_organization_id := p_samples_rec.organization_id;
    l_resource_spec.date_effective           := nvl(p_samples_rec.date_drawn,sysdate);


    IF GMD_SPEC_MATCH_GRP.FIND_RESOURCE_SPEC(
        p_resource_spec_rec  => l_resource_spec,
        x_spec_id            => x_spec_id,
        x_spec_vr_id         => x_spec_vr_id,
        x_return_status      => x_return_status,
        x_message_data       => x_msg_data)  THEN

        RETURN TRUE;
    END IF;

    -- end Bug #3401377  : added get spec for location, resource and stability samples
  ELSE
    GMD_API_PUB.Log_Message('GMD_SAMPLE_SOURCE_INVALID',
                             'l_source', p_samples_rec.source);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

RETURN FALSE;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
    RETURN FALSE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    RETURN FALSE;

END FIND_MATCHING_SPEC;


PROCEDURE DELETE_SAMPLES
( p_api_version          IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, p_commit               IN  VARCHAR2
, p_validation_level     IN  NUMBER
, p_qc_samples_rec       IN  GMD_SAMPLES%ROWTYPE
, p_user_name            IN  VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'DELETE_SAMPLES';
  l_api_version        CONSTANT NUMBER        := 3.0;
  l_msg_count          NUMBER  :=0;
  l_msg_data           VARCHAR2(2000);
  l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
  l_qc_samples_out_rec GMD_SAMPLES%ROWTYPE;
  l_qc_samples_rec     GMD_SAMPLES%ROWTYPE;
  l_rowid              VARCHAR2(10);
  l_test_type          VARCHAR2(10);
  l_test_id            NUMBER(10);
  l_user_id            NUMBER(15);

BEGIN


  -- Standard Start OF API savepoint

  SAVEPOINT DELETE_SAMPLES;

  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_CALL
    (l_api_version , p_api_version , l_api_name , G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --  Initialize message list if p_int_msg_list is set TRUE.
  IF FND_API.to_boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --  Initialize API return Parameters

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate User Name Parameter

  GMA_GLOBAL_GRP.Get_Who ( p_user_name => p_user_name
                          ,x_user_id   => l_user_id);

  IF NVL(l_user_id, -1) < 0
    THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_USER_NAME',
                            'l_user_name', p_user_name);
    RAISE FND_API.G_EXC_ERROR;
 END IF;

  -- Check  Required Fields  Present

  IF ( p_qc_samples_rec.sample_id is NULL) THEN
     -- Validate that composite keys are present

     IF ( p_qc_samples_rec.sample_no is NULL) THEN
      --  GMD_API_PUB.Log_Message('GMD_SAMPLE_SOURCE_INVALID');
    /*  GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'SAMPLE NO', ' IS NULL');*/
        GMD_API_PUB.Log_Message('GMD_SAMPLE_NUM_NULL');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF ( p_qc_samples_rec.organization_id is NULL) THEN
         GMD_API_PUB.Log_Message('GMD_SAMPLE_ORGN_CODE_REQD');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

  END IF; -- Key Sample values Present


  -- Fetch the Test Header Row.

  IF NOT GMD_SAMPLES_PVT.fetch_row (
      p_samples    => p_qc_samples_rec,
      x_samples    => l_qc_samples_out_rec) THEN
      -- dbms_output.put_line('Sample Record Not Found');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate that the Sample Header is Not Already Marked For Purge

  IF l_qc_samples_out_rec.delete_mark = 1 THEN
      GMD_API_PUB.Log_Message('GMD_RECORD_DELETE_MARKED',
                              'l_table_name', 'GMD_SAMPLES',
                              'l_column_name', 'SAMPLE_ID',
                              'l_key_value', l_qc_samples_out_rec.sample_id);
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Mark this record for Purge, this routine will also lock the row.

  -- dbms_output.put_line('Delete Row');
  IF NOT GMD_SAMPLES_PVT.delete_row(
         p_sample_id         => l_qc_samples_out_rec.sample_id,
         p_organization_id   => l_qc_samples_out_rec.organization_id,
         p_sample_no         => l_qc_samples_out_rec.sample_no
         ) THEN
       GMD_API_PUB.Log_Message('GMD_FAILED_TO_DELETE_ROW',
                              'l_table_name', 'GMD_SAMPLES',
                              'l_column_name','SAMPLE_ID',
                              'l_key_value', l_qc_samples_out_rec.sample_id);

       RAISE FND_API.G_EXC_ERROR;

   END IF;

  -- If the sample dispostion is not Retain or Cancel
  -- Then we must keep the active cnt on the Sampling event in synch.

     IF l_qc_samples_out_rec.sample_disposition NOT IN ('0RT','7CN') THEN

     -- Lock Sampling event row
     IF NOT GMD_SAMPLING_EVENTS_PVT.lock_row
        ( p_sampling_event_id  =>  l_qc_samples_out_rec.sampling_event_id
        ) THEN
          GMD_API_PUB.Log_Message('GMD_LOCKING_FAILURE',
                     'l_table_name', 'GMD_SAMPLING_EVENTS',
                     'l_column_name','SAMPLING_EVENT_ID',
                     'l_key_value', l_qc_samples_out_rec.sampling_event_id);
          RAISE FND_API.G_EXC_ERROR;
     ELSE

        -- Update the sampling events Table
        UPDATE GMD_SAMPLING_EVENTS
        SET    SAMPLE_ACTIVE_CNT = sample_active_cnt -1,
               LAST_UPDATED_BY   = l_user_id,
               LAST_UPDATE_DATE  = SYSDATE
        WHERE  SAMPLING_EVENT_ID = l_qc_samples_out_rec.sampling_event_id;

     END IF;

  END IF; -- Sample Disposition Not Retain OR Cancel

  -- Standard Check of p_commit.
  IF FND_API.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;


  x_return_status      := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_SAMPLES;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_SAMPLES;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );



    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO DELETE_SAMPLES;
      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END DELETE_SAMPLES;


PROCEDURE VALIDATE_ITEM_CONTROLS
( p_sample_rec     IN  GMD_SAMPLES%ROWTYPE,
  p_grade         IN         VARCHAR2,      -- Bug 4165704: added to validate grade control
  x_sample_rec     OUT NOCOPY GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

    -- Bug 4165704: item controls gotten from call to Get_item_values
    -- CURSOR c_item_controls IS
    --   SELECT status_ctl
    --        , lot_ctl
    --        , sublot_ctl
    --        , loct_ctl
    --   FROM   ic_item_mst
    --   WHERE  item_id = p_sample_rec.item_id
    --   AND    inactive_ind = 0
    --   AND    delete_mark  = 0;

-- Bug 4165704: mtl_lot_numbers replaced ic_lots_mst and lot_id no longer used
    --CURSOR c_item_lot IS
    --SELECT lot_no, sublot_no
    --FROM   ic_lots_mst
    --WHERE  item_id     = p_sample_rec.item_id
    --AND    lot_id      = p_sample_rec.lot_id
    --AND    delete_mark = 0;
/*CURSOR c_item_lot IS
SELECT 1
FROM   mtl_lot_numbers
WHERE  inventory_item_id     = p_sample_rec.inventory_item_id
--AND    lot_number            = p_sample_rec.lot_number
AND    organization_id       = p_sample_rec.organization_id
AND    ((p_sample_rec.parent_lot_number IS NULL )
    OR (parent_lot_number = p_sample_rec.parent_lot_number));*/

-- srakrish bug 5687499: Implementing Child lot controlled onstraints. Replaced the above cursor with the one below.
CURSOR c_item_lot(p_child_lot_flag varchar2) IS
SELECT 1
FROM   mtl_lot_numbers
WHERE  inventory_item_id     = p_sample_rec.inventory_item_id
--AND    lot_number            = p_sample_rec.lot_number
AND((p_child_lot_flag = 'Y' and p_sample_rec.lot_number IS NOT NULL and lot_number = p_sample_rec.lot_number)
    OR (p_child_lot_flag = 'Y' and p_sample_rec.lot_number IS NULL)
    OR (p_child_lot_flag = 'N' and lot_number = p_sample_rec.lot_number))
AND    organization_id       = p_sample_rec.organization_id
AND    ((p_sample_rec.parent_lot_number IS NULL )
    OR (parent_lot_number = p_sample_rec.parent_lot_number));

-- bug# 3447280
-- get lot_id if lot/sublot is specified.
-- if lot and sublot both are specified without lot id
-- and if new sampling event is created , lot id goes as NULL in gmd_sampling_events.

-- Bug 4165704: This cursor is no longer needed
--CURSOR c_item_sublot IS
--SELECT lot_id
--FROM   ic_lots_mst
--WHERE  item_id     = p_sample_rec.item_id
--AND    lot_no      = p_sample_rec.lot_no
--AND    sublot_no   = p_sample_rec.sublot_no
--AND    delete_mark = 0;

l_dummy             NUMBER;
l_lot_ctl           NUMBER;
l_child_lot_flag    VARCHAR2(2);
l_lot_number        MTL_LOT_NUMBERS.lot_number%TYPE;
l_parent_lot_number MTL_LOT_NUMBERS.parent_lot_number%TYPE;
l_sample_rec        GMD_SAMPLES%ROWTYPE;
l_return_status     VARCHAR2(1);

l_sample_display    GMD_SAMPLES_GRP.sample_display_rec;

BEGIN

  -- Assign API local  Variables;
  l_sample_rec    := p_sample_rec;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- We should only be validating W,I,C,S source type which
  -- all reqire the ite to exist.

  IF (l_sample_rec.inventory_item_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_ITEM_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Validate that the item is valid.
    -- Bug 4165704: validation is now done with call to get_item_values
                  -- OPEN c_item_controls;
                  -- FETCH c_item_controls INTO l_status_ctl, l_lot_ctl  , l_sublot_ctl, l_item_loct_ctl;
                  -- IF (c_item_controls%NOTFOUND) THEN
                    -- CLOSE c_item_controls;
                    -- GMD_API_PUB.Log_Message('GMD_SPEC_ITEM_NOT_FOUND');
                    -- RAISE FND_API.G_EXC_ERROR;
                  -- END IF;
                  -- CLOSE c_item_controls;

     l_sample_display.organization_id   := p_sample_rec.organization_id;
     l_sample_display.inventory_item_id := p_sample_rec.inventory_item_id;

     gmd_samples_grp.get_item_values(p_sample_display => l_sample_display);

      -- test for whether an item was found
     IF l_sample_display.item_number IS NULL THEN
           GMD_API_PUB.Log_Message('GMD_SPEC_ITEM_NOT_FOUND');
           RAISE FND_API.G_EXC_ERROR;

     ELSE
         l_lot_ctl        := l_sample_display.lot_control_code ;
         G_LOT_CTL        := l_sample_display.lot_control_code ; -- 528854
         l_child_lot_flag := l_sample_display.child_lot_flag ;
         G_CHILD_LOT_FLAG := l_sample_display.child_lot_flag; -- 528854
                -- Bug 4165704: this is no longer needed; handled by 'item is locator controlled' routine
                --              and source subinventory and source locator are now retrieved here
                -- l_item_loct_ctl  := l_sample_display.location_control_code ;
         l_sample_rec.source_subinventory :=  l_sample_display.source_subinventory;
         l_sample_rec.source_locator_id  :=  l_sample_display.source_locator_id ;
     END IF ;
  END IF;  -- Validate item.

  IF (l_lot_ctl = 2) THEN                         -- item is lot controlled

-- 5283854  - move the below check to     CREATE_SAMPLE
/*     IF ((l_sample_rec.lot_number IS NULL)
        AND ((l_sample_rec.parent_lot_number IS NULL) AND (l_sample_display.child_lot_flag = 'Y'))) THEN
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                  'WHAT', 'lot_number');
          RAISE FND_API.G_EXC_ERROR;

     END IF; */

  -- Bug 4165704: Logic changed for new parent lot/lot instead of lot/sublot
  --      ELSE -- Item is not lot controlled. . Item can only be sublot controlled
    IF ((l_sample_rec.lot_number IS NOT NULL)
      OR (l_sample_rec.parent_lot_number IS NOT NULL)) THEN

      IF ( l_child_lot_flag = 'N') AND ( l_sample_rec.parent_lot_number IS NOT NULL) THEN
            GMD_API_PUB.Log_Message('GMD_QM_PARENT_LOT_NULL');
            RAISE FND_API.G_EXC_ERROR;
      END IF; -- If item is not child lot controlled parent lot shouldn't exist.


      OPEN c_item_lot(l_child_lot_flag); --srakrish bug 5687499: Passing the child lot flags to the cursor.
      FETCH c_item_lot INTO l_dummy;
      IF (c_item_lot%NOTFOUND) THEN
        CLOSE c_item_lot;
        GMD_API_PUB.Log_Message('GMD_ITEM_LOT_NOT_FOUND',
                                'LOT_NUMBER', l_sample_rec.lot_number);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_item_lot;


                -- Bug 4165704: this is handled elsewhere
                --ELSE -- Item is child controlled.
                   --IF ( l_sample_rec.parent_lot_number IS NOT NULL) THEN
                       --OPEN c_item_sublot;
                       --FETCH c_item_sublot  INTO l_lot_id;
                       --IF (c_item_sublot%NOTFOUND) THEN
                         --CLOSE c_item_sublot;
                         --GMD_API_PUB.Log_Message('GMD_ITEM_SUBLOT_NOT_FOUND',
                         --                 'SUBLOT_NO', l_sample_rec.sublot_no);
                         --RAISE FND_API.G_EXC_ERROR;
                       --END IF;
                       --CLOSE c_item_sublot;
      	               --l_sample_rec.lot_id    := l_lot_id;
                  --END IF; -- validating lot/sublot
             --END IF; -- if item is lot/sublot controlled.
    -- 8276017   - move the below check to     CREATE_SAMPLE   as we needed to check lot optional on svr - SO comment out below 3 lines
    --ELSIF ( l_child_lot_flag = 'N') THEN --srakrish bug 5687499: Included the else part to check for the lot when the item is not child lot controlled. Lot is a required field.
     -- GMD_API_PUB.Log_Message('GMD_QM_LOT_REQUIRED');
     -- RAISE FND_API.G_EXC_ERROR;
    END IF; -- If item is lot controlled an lot_id specified.
  END IF; --lot control = 2





   -- Bug 4165704: added grade control check here
  IF (l_sample_display.grade_control_flag = 'N' AND p_grade is NOT NULL) THEN
    GMD_API_PUB.Log_Message('GMD_GRADE_MUST_NULL');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

-- Bug 5283854 : added revision control check here
 IF l_sample_display.Revision_qty_control_code = 2 then
   IF (l_sample_rec.revision IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_API_REVISION_CTRL');
    RAISE FND_API.G_EXC_ERROR;

   END IF;

 END IF;
 -- end 5283854

  -- Set return parameters
  x_sample_rec    := l_sample_rec;
  x_return_status := l_return_status;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END VALIDATE_ITEM_CONTROLS;


  -- Bug 4165704: changed the way locator control was handled
PROCEDURE VALIDATE_INV_SAMPLE
( p_sample_rec       IN  GMD_SAMPLES%ROWTYPE,
  p_locator_control  IN  NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS


    -- Bug 4165704: changed for inventory convergence
  CURSOR c_subinventory_loct IS
    SELECT 1
    FROM mtl_item_locations
    WHERE organization_id        = p_sample_rec.organization_id
      AND inventory_location_id  = p_sample_rec.locator_id
      AND subinventory_code      = p_sample_rec.subinventory;
         --FROM   ic_loct_mst
         --WHERE  whse_code   = p_sample_rec.whse_code
         --AND    location    = p_sample_rec.location
         --AND    delete_mark = 0;


l_dummy            NUMBER;
l_return_status    VARCHAR2(1);

l_locator_control  NUMBER;

BEGIN

  -- Assign API local  Variables;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- This Procedure Assumes that the whse and item have been validated.




 -- Validate the location
  IF (l_locator_control = 1) THEN
    IF (p_sample_rec.locator_id IS NOT NULL) THEN
        GMD_API_PUB.Log_Message('GMD_LOCATION_MUST_NULL');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF (l_locator_control > 1 ) THEN   -- Item is location controlled.
      IF (p_sample_rec.locator_id IS NOT NULL) THEN
        -- Check that Location exist in MTL_ITEM_LOCATIONS
        OPEN c_subinventory_loct;
        FETCH c_subinventory_loct  INTO l_dummy;
        IF (c_subinventory_loct%NOTFOUND)  THEN
        --  CLOSE c_subinventory_loct;
          GMD_API_PUB.Log_Message('GMD_LOCT_NOT_FOUND',
                                  'LOCATION', p_sample_rec.locator_id);
       --   RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE c_subinventory_loct;
      ELSE   -- location CANNOT NULL
        GMD_API_PUB.Log_Message('GMD_LOCATION_MUST_NULL');
        RAISE FND_API.G_EXC_ERROR;
      END IF;   -- location IS NOT NULL
  END IF;    -- l_locator_control


  -- Set return parameters
  x_return_status := l_return_status;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END VALIDATE_INV_SAMPLE;

PROCEDURE VALIDATE_WIP_SAMPLE
( p_sample_rec     IN  GMD_SAMPLES%ROWTYPE,
  x_sample_rec     OUT NOCOPY  GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

--bug#2995114
-- batch cursor was not correct.
-- changed the batch cursor exactly as the batch Record Group in the Samples Form
-- Bug # 4619570 Changed this Cursor to allow closed batches
CURSOR c_batch
IS
SELECT DISTINCT gr.recipe_id,
       ffm.formula_id,
       rout.routing_id
FROM gme_batch_header bh
   , gme_material_details md
   , gmd_recipes_b gr/*gmd_recipes gr bug#4916871*/
   , gmd_recipe_validity_rules rvr
   , gmd_status gs
   , fm_matl_dtl fmd
   , fm_form_mst_b ffm /*fm_form_mst ffm bug# 4916871*/
   , gmd_routings_b rout /*gmd_routings rout bug#4916871*/
   , gem_lookups gl
   , gem_lookups gl2
WHERE rout.routing_id(+) = bh.routing_id
AND rvr.recipe_validity_rule_id = bh.recipe_validity_rule_id
AND rvr.recipe_id = gr.recipe_id
AND ffm.formula_id = bh.formula_id
AND ffm.formula_id = fmd.formula_id
AND fmd.formula_id = bh.formula_id
AND ffm.delete_mark = 0
AND fmd.formula_id = gr.formula_id
AND fmd.inventory_item_id = p_sample_rec.inventory_item_id
AND gr.recipe_status = gs.status_code
AND gs.status_code <> '1000'
AND gr.delete_mark = 0
AND gr.formula_id = bh.formula_id
AND bh.batch_id = md.batch_id
AND bh.batch_type = 0
AND ( (  bh.batch_status IN (2, 3)     and     ( NVL(fnd_profile.value('GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'N') )      /*-- wip or completed */
OR  ( bh.batch_status IN (2, 3,4 )   and  ( NVL(fnd_profile.value('GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'Y') )  )  /*--  4619570 wip or completed or closed */
AND md.inventory_item_id = p_sample_rec.inventory_item_id     /*--batch must be for item*/
--AND bh.plant_code = p_sample_rec.organization_id -- bug 5291723 - plant code replace with organization
AND bh.organization_id = p_sample_rec.organization_id -- bug 5291723
AND  bh.batch_status = gl.lookup_code
AND  gl.lookup_type = 'GME_BATCH_STATUS'
AND gl2.lookup_type = 'GME_YES_NO'
AND gl2.lookup_code = bh.terminated_ind
AND    bh.batch_id = p_sample_rec.batch_id
AND    NVL( p_sample_rec.recipe_id, gr.recipe_id) = gr.recipe_id
AND    NVL( p_sample_rec.formula_id, bh.formula_id) = bh.formula_id   --
AND ((p_sample_rec.routing_id IS NULL) OR (p_sample_rec.routing_id = bh.routing_id)) ;


-- 9020340 new cursor  use if p_sample_rec.recipe_id is null and p_sample_rec.formula_id is null and p_sample_rec.routing_id  is null

cursor batch_no_formula is
SELECT gr.recipe_id
     , gr.formula_id
     , gr.routing_id
  FROM gmd_recipes_b gr
     , gmd_recipe_validity_rules grvr
     , gme_batch_header gbh
WHERE gbh.batch_id = p_sample_rec.batch_id
   AND grvr.recipe_validity_rule_id = gbh.recipe_validity_rule_id
   AND gr.recipe_id = grvr.recipe_id
   AND gbh.batch_type = 0
   AND ( (  gbh.batch_status IN (2, 3)     and     (
NVL(fnd_profile.value('GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'N') )      /*--
wip or completed */
OR  ( gbh.batch_status IN (2, 3, 4 )   and  (
NVL(fnd_profile.value('GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'Y') )  )  /*-- wip
or completed or closed */
;



CURSOR c_formulaline_id ( l_formula_id In NUMBER)
IS
SELECT 1
FROM   fm_matl_dtl fmd
WHERE  fmd.inventory_item_id = p_sample_rec.inventory_item_id
AND    fmd.formula_id = l_formula_id
AND    fmd.formulaline_id = p_sample_rec.formulaline_id;


  -- Bug 4640143: added material_detail_id to samples
CURSOR c_material_detail_id ( l_batch_id In NUMBER)
IS
SELECT 1
FROM   gme_material_details
WHERE  inventory_item_id  = p_sample_rec.inventory_item_id
AND    organization_id    = p_sample_rec.organization_id
AND    batch_id           = l_batch_id
AND    material_detail_id = p_sample_rec.material_detail_id;


CURSOR c_batchstep
IS
SELECT bs.batchstep_no, bs.oprn_id
FROM   gme_batch_steps bs,
       gmd_operations o
WHERE  bs.oprn_id = o.oprn_id
AND    bs.batchstep_id = p_sample_rec.step_id
AND    bs.batch_id = p_sample_rec.batch_id
AND    NVL( p_sample_rec.step_no, bs.batchstep_no) = bs.batchstep_no
AND    o.delete_mark = 0
AND    bs.delete_mark = 0;

CURSOR c_oprn
IS
SELECT 1
FROM   gmd_operations o
WHERE  o.delete_mark = 0
AND    o.oprn_id = p_sample_rec.oprn_id;



l_dummy            NUMBER;
l_return_status    VARCHAR2(1);
l_sample_rec       GMD_SAMPLES%ROWTYPE;


BEGIN


  -- Assign API local  Variables;
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sample_rec    := p_sample_rec;


  -- For WIP sample the batch_id must be specified.
  IF (p_sample_rec.batch_id IS NULL ) THEN
     GMD_API_PUB.Log_Message('GMD_NO_WIP_PARAM');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  ----------------------------------------------
  -- Derive Values Using Batch_id
  -----------------------------------------------
-- 9020340
--use new cursor if only batch id is passed

  IF ( p_sample_rec.batch_id IS NOT NULL and p_sample_rec.recipe_id is null
       and p_sample_rec.formula_id is null and p_sample_rec.routing_id  is null  ) THEN -- get values
    OPEN batch_no_formula;
    FETCH batch_no_formula
    INTO l_sample_rec.recipe_id,
         l_sample_rec.formula_id,
         l_sample_rec.routing_id;
    IF (batch_no_formula%NOTFOUND) THEN
      CLOSE batch_no_formula;
       GMD_API_PUB.Log_Message('GMD_ORDER_NOT_FOUND');
     -- GMD_API_PUB.Log_Message('GMD_BATCH_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE batch_no_formula;

  ELSIF p_sample_rec.batch_id IS NOT NULL  then

    OPEN c_batch;
    FETCH c_batch
    INTO l_sample_rec.recipe_id,
         l_sample_rec.formula_id,
         l_sample_rec.routing_id;
    IF (c_batch%NOTFOUND) THEN
      CLOSE c_batch;
      GMD_API_PUB.Log_Message('GMD_BATCH_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_batch;

  END IF;

  ----------------------------------------------
  -- Validate derived values against Sample rec
  -----------------------------------------------

  -- Validate formula_line_id if specified.

  -- Bug 4640143: added test for batch_id
  IF ( l_sample_rec.formulaline_id IS NOT NULL)
   AND (l_sample_rec.batch_id IS NULL)         THEN
   OPEN c_formulaline_id ( l_sample_rec.formula_id);
    FETCH c_formulaline_id INTO l_dummy;
    IF (c_formulaline_id%NOTFOUND) THEN
      CLOSE c_formulaline_id;
      GMD_API_PUB.Log_Message('GMD_FORMULA_LINE_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_formulaline_id;
  END IF;

  -- Bug 4640143: Validate material_detail_id if specified.
  IF ( l_sample_rec.material_detail_id is NOT NULL) THEN
   OPEN c_material_detail_id ( l_sample_rec.batch_id);
    FETCH c_material_detail_id INTO l_dummy;
    IF (c_material_detail_id%NOTFOUND) THEN
      CLOSE c_material_detail_id;
      GMD_API_PUB.Log_Message('GMD_MATERIAL_DTL_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_material_detail_id;
  END IF;



  -- VAlidate Step_no , even though the step_id can be defined
  -- for the batch or routing, we will only validate against
  -- the batch.

  IF (l_sample_rec.step_id is NOT NULL ) THEN
    OPEN c_batchstep;
    FETCH c_batchstep
     INTO l_sample_rec.step_no,l_sample_rec.oprn_id;
    IF (c_batchstep%NOTFOUND) THEN
      CLOSE c_batchstep;
      GMD_API_PUB.Log_Message('GMD_BATCH_STEP_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_batchstep;

  END IF;

  -- Operation is valid (check only if step is not specified, because
  --                     otherwise it will default from the step chosen.)
  IF (l_sample_rec.step_id IS NULL AND l_sample_rec.oprn_id IS NOT NULL) THEN
    OPEN c_oprn;
    FETCH c_oprn
    INTO l_dummy;
    IF (c_oprn%NOTFOUND) THEN
      CLOSE c_oprn;
      GMD_API_PUB.Log_Message('GMD_BATCH_STEP_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_oprn;
  END IF;

  -- Set return parameters
  x_sample_rec    := l_sample_rec;
  x_return_status := l_return_status;


EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END VALIDATE_WIP_SAMPLE;

PROCEDURE VALIDATE_CUST_SAMPLE
( p_sample_rec     IN  GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

CURSOR c_cust IS
SELECT csua.org_id
FROM hr_operating_units ou
   , hz_cust_acct_sites_all casa
   , hz_cust_site_uses_all csua
   , hz_parties hzp
   , hz_cust_accounts_all hzca
WHERE ou.organization_id = csua.org_id
AND casa.cust_acct_site_id = csua.cust_acct_site_id
AND casa.cust_account_id = hzca.cust_account_id
AND casa.org_id = csua.org_id
AND hzp.party_id = hzca.party_id
AND NVL( p_sample_rec.org_id, csua.org_id) = csua.org_id
AND hzca.cust_account_id = p_sample_rec.cust_id;


CURSOR c_ship_to IS
SELECT 1
FROM hz_cust_acct_sites_all casa
   , hz_cust_site_uses_all csua
   , hz_cust_accounts_all caa
WHERE casa.cust_acct_site_id = csua.cust_acct_site_id
  AND casa.org_id = csua.org_id
  AND casa.cust_account_id = caa.cust_account_id
  AND csua.site_use_code = 'SHIP_TO'
  AND NVL( p_sample_rec.org_id, csua.org_id) = csua.org_id
  AND caa.cust_account_id = p_sample_rec.cust_id
  AND csua.site_use_id = p_sample_rec.ship_to_site_id;

/*CURSOR c_order IS
SELECT 1
FROM oe_order_headers_all oha
   , oe_order_lines_all oola
   , oe_transaction_types_tl ttt
WHERE oola.header_id = oha.header_id
  AND oola.inventory_item_id IN
     (SELECT msi.inventory_item_id
      FROM mtl_system_items msi
      WHERE msi.segment1 IN
         (SELECT segment1
          FROM mtl_system_items_b
          WHERE inventory_item_id = p_sample_rec.inventory_item_id))
  AND oha.order_type_id = ttt.transaction_type_id
  AND NVL( p_sample_rec.ship_to_site_id, oola.ship_to_org_id) = oola.ship_to_org_id
  AND NVL( p_sample_rec.organization_id, oha.org_id) = oha.org_id
  AND p_sample_rec.cust_id  = oha.sold_to_org_id
  AND oha.header_id = p_sample_rec.order_id
  AND oha.cancelled_flag <> 'Y'
  AND ttt.language = USERENV('LANG');*/

--CURSOR c_order rewritten as part of bug# 4916871
--CURSOR c_order rewritten as part of bug# 5335008
CURSOR c_order IS
SELECT 1
FROM oe_order_headers_all oha
   , oe_order_lines_all oola
   , oe_transaction_types_tl ttt
WHERE oola.header_id = oha.header_id
  AND oola.inventory_item_id = p_sample_rec.inventory_item_id
  AND oha.order_type_id = ttt.transaction_type_id
  AND (NVL( p_sample_rec.ship_to_site_id, oola.ship_to_org_id) = oola.ship_to_org_id -- 5335008
   OR  NVL( p_sample_rec.ship_to_site_id, oola.invoice_to_org_id) = oola.invoice_to_org_id)  -- 5335008
  AND NVL( p_sample_rec.org_id, oha.org_id) = oha.org_id -- 5335008
  AND NVL( p_sample_rec.cust_id,oha.sold_to_org_id)   = oha.sold_to_org_id  -- 5335008
  AND oha.header_id = p_sample_rec.order_id
  AND oha.cancelled_flag <> 'Y'
  AND ttt.language = USERENV('LANG');

CURSOR c_order_line IS
SELECT 1
FROM oe_order_lines_all oola
WHERE oola.header_id = p_sample_rec.order_id
  AND NVL( p_sample_rec.ship_to_site_id, oola.ship_to_org_id) = oola.ship_to_org_id
  AND oola.inventory_item_id IN
     (SELECT msi.inventory_item_id
      FROM mtl_system_items msi
      WHERE msi.segment1 IN
         (SELECT segment1
          FROM mtl_system_items_b
          WHERE inventory_item_id = p_sample_rec.inventory_item_id))
  AND oola.header_id = p_sample_rec.order_id
  AND oola.line_id = p_sample_rec.order_line_id;


l_dummy            NUMBER;
l_return_status    VARCHAR2(1);


BEGIN


  -- Assign API local  Variables;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- For A Customer Sample Source the Cust_id
  -- Must be Specified. This also validates the Org_id

  IF (p_sample_rec.cust_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_CUSTOMER_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    OPEN c_cust;
    FETCH c_cust
     INTO l_dummy;
    IF (c_cust%NOTFOUND) THEN
      CLOSE c_cust;
      GMD_API_PUB.Log_Message('GMD_CUSTOMER_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_cust;
  END IF;

  -- Validate Ship_to

  IF (p_sample_rec.ship_to_site_id IS NOT NULL) THEN
    OPEN c_ship_to;
    FETCH c_ship_to
     INTO l_dummy;
    IF (c_ship_to%NOTFOUND) THEN
      CLOSE c_ship_to;
      GMD_API_PUB.Log_Message('GMD_SHIP_TO_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_ship_to;
  END IF;

  -- Validate Order ID

  IF (p_sample_rec.order_id IS NOT NULL)
  THEN
    OPEN c_order;
    FETCH c_order
     INTO l_dummy;
    IF (c_order%NOTFOUND)
    THEN
      CLOSE c_order;
      GMD_API_PUB.Log_Message('GMD_ORDER_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_order;
  END IF;

  -- Validate Order Line ID
  -- Bug 3151607 ( modified the IF/ELSE condition below)

 /*  IF (p_sample_rec.order_line_id IS NOT NULL
      AND  p_sample_rec.order_id IS NOT NULL) THEN

      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                             'WHAT', 'the order_id must not be NULL');
      RAISE FND_API.G_EXC_ERROR;
  ELSE

    OPEN c_order_line;
    FETCH c_order_line
     INTO l_dummy;
    IF (c_order_line%NOTFOUND) THEN
      CLOSE c_order_line;
      GMD_API_PUB.Log_Message('GMD_ORDER_LINE_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_order_line;
  END IF; */

  IF (p_sample_rec.order_line_id IS NOT NULL) THEN
     IF  (p_sample_rec.order_id IS NULL) THEN
        /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                             'WHAT', 'the order_id must not be NULL');*/
          GMD_API_PUB.Log_Message('GMD_ORDER_ID_MUST_NOT_NULL');
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     OPEN c_order_line;
     FETCH c_order_line
     INTO l_dummy;

     IF (c_order_line%NOTFOUND) THEN
       CLOSE c_order_line;
       GMD_API_PUB.Log_Message('GMD_ORDER_LINE_NOT_FOUND');
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE c_order_line;

  END IF;


  -- Set return parameters
  x_return_status := l_return_status;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END VALIDATE_CUST_SAMPLE;




PROCEDURE VALIDATE_SUPP_SAMPLE
( p_sample_rec     IN  GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

CURSOR c_supplier IS
SELECT 1
FROM po_vendors v
WHERE v.vendor_id = p_sample_rec.supplier_id
  AND v.enabled_flag = 'Y';

CURSOR c_supplier_site IS
SELECT 1
FROM po_vendor_sites_all v
WHERE (v.purchasing_site_flag = 'Y'
   OR v.rfq_only_site_flag = 'Y')
  AND sysdate < NVL(inactive_date, sysdate + 1)
  AND v.vendor_id = p_sample_rec.supplier_id
  AND v.vendor_site_id = p_sample_rec.supplier_site_id;

-- Bug# 5226352
-- Changed mtl_system_items to mtl_system_items_b and added organization_id where clause for msi to fix performance issues
CURSOR c_po
IS
SELECT 1
FROM po_headers_all pha
WHERE pha.po_header_id IN
  (SELECT pla.po_header_id
   FROM   po_lines_all pla
   WHERE  pla.po_header_id = pha.po_header_id
   AND    pla.item_id IN
       (SELECT msi.inventory_item_id
        FROM mtl_system_items_b msi
        WHERE organization_id = p_sample_rec.organization_id
	  AND inventory_item_id = p_sample_rec.inventory_item_id))
  AND pha.vendor_id      = p_sample_rec.supplier_id
  AND pha.vendor_site_id = p_sample_rec.supplier_site_id
  AND pha.po_header_id   = p_sample_rec.po_header_id;

CURSOR c_po_line IS
SELECT 1
FROM po_lines_all pla
WHERE pla.item_id IN
 (SELECT msi.inventory_item_id
  FROM mtl_system_items msi
  WHERE msi.segment1 IN
     (SELECT segment1
      FROM mtl_system_items_b
      WHERE inventory_item_id = p_sample_rec.inventory_item_id))
  AND pla.po_header_id = p_sample_rec.po_header_id
  AND pla.po_line_id   = p_sample_rec.po_line_id;

--Bug# 3576573. Added cusor c_receipt_info
-- Bug 3970893: receipt line id is no longer the transaction id, it is now shipment_line_id
/*CURSOR c_receipt_info IS
SELECT 1
FROM rcv_shipment_headers rsh     , rcv_transactions rt
WHERE (p_sample_rec.receipt_id, p_sample_rec.receipt_line_id) IN
  (SELECT rsh.shipment_header_id,
   	  rsl.shipment_line_id            -- rt.transaction_id
   FROM rcv_shipment_lines rsl
   WHERE rsl.po_header_id = p_sample_rec.po_header_id
     AND rsl.item_id IN
        (SELECT msi.inventory_item_id
         FROM mtl_system_items msi
         WHERE msi.segment1 IN
            (SELECT segment1
             FROM mtl_system_items_b
             WHERE inventory_item_id = p_sample_rec.inventory_item_id))
     AND rsl.po_line_id = p_sample_rec.po_line_id
     AND rsl.shipment_header_id = rsh.shipment_header_id);*/

--CURSOR c_receipt_info rewritten as part of bug# 4916871
CURSOR c_receipt_info IS
SELECT 1
FROM rcv_shipment_headers rsh
WHERE (p_sample_rec.receipt_id, p_sample_rec.receipt_line_id) IN
  (SELECT rsh.shipment_header_id,
   	  rsl.shipment_line_id
   FROM rcv_shipment_lines rsl
   WHERE rsl.po_header_id = p_sample_rec.po_header_id
     AND rsl.item_id = p_sample_rec.inventory_item_id
     AND rsl.po_line_id = p_sample_rec.po_line_id
     AND rsl.shipment_header_id = rsh.shipment_header_id);

        -- AND rt.shipment_header_id   = rsl.shipment_header_id
        -- AND rt.shipment_line_id     = rsl.shipment_line_id
        -- AND rt.transaction_type     = 'RECEIVE');

l_dummy            NUMBER;
l_return_status    VARCHAR2(1);



BEGIN
      --dbms_output.put_line('b4 validate supplier sample ');

  -- Assign API local  Variables;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- supplier_id : This field is mandatory

  IF (p_sample_rec.supplier_id IS NULL)
  THEN
    GMD_API_PUB.Log_Message('GMD_SUPPLIER_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    OPEN c_supplier;
    FETCH c_supplier INTO l_dummy;
    IF (c_supplier%NOTFOUND)
    THEN
      CLOSE c_supplier;
      GMD_API_PUB.Log_Message('GMD_SUPPLIER_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_supplier;
  END IF;

  --=========================================================================
  -- supplier_site_id :
  --=========================================================================
  IF ( p_sample_rec.supplier_site_id IS NOT NULL)
  THEN
    OPEN c_supplier_site;
    FETCH c_supplier_site
     INTO l_dummy;
    IF (c_supplier_site%NOTFOUND)
    THEN
      CLOSE c_supplier_site;
      FND_MESSAGE.SET_NAME('GMD','GMD_NOTFOUND');
      FND_MESSAGE.SET_TOKEN('WHAT', 'SUPPLIER_SITE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', p_sample_rec.supplier_site_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_supplier_site;
  END IF;

  --=========================================================================
  -- po_header_id :
  -- When po_header_id is NOT NULL, then supplier_site_id must be NOT NULL
  --=========================================================================
  -- PO
  IF (p_sample_rec.po_header_id IS NOT NULL)
  THEN
    IF (p_sample_rec.supplier_site_id IS NULL)
    THEN
    /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'supplier_site_id must not be NULL');*/
      GMD_API_PUB.Log_Message('GMD_SUPP_SITE_MUST_NOT_NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_po;
    FETCH c_po INTO l_dummy;
    IF (c_po%NOTFOUND)
    THEN
      CLOSE c_po;
      GMD_API_PUB.Log_Message('GMD_PO_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_po;
  END IF;


  --=========================================================================
  -- po_line_id :
  -- When po_line_id is NOT NULL, then supplier_site_id AND po_header_id must be NOT NULL
  --=========================================================================
  -- PO Line
  IF (p_sample_rec.po_line_id IS NOT NULL)
  THEN
    IF (p_sample_rec.po_header_id IS NULL)
    THEN
    /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'po_header_id must not be NULL');*/
      GMD_API_PUB.Log_Message('GMD_PO_HEADER_MUST_NOT_NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_sample_rec.supplier_site_id IS NULL)
    THEN
    /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'supplier site must not be NULL');*/
      GMD_API_PUB.Log_Message('GMD_SUPP_SITE_MUST_NOT_NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_po_line;
    FETCH c_po_line INTO l_dummy;
    IF (c_po_line%NOTFOUND)
    THEN
      CLOSE c_po_line;
      GMD_API_PUB.Log_Message('GMD_PO_LINE_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_po_line;
  END IF;

  --Bug# 3576573. added validations for receipt information
  --=========================================================================================
  --receipt_id and receipt_line_id
  --when receipt information is NOT NULL po_header_id and po_line_id must not be NULL
  --=========================================================================================

    IF(p_sample_rec.receipt_id IS NOT NULL OR p_sample_rec.receipt_line_id IS NOT NULL)
    THEN
      IF (p_sample_rec.po_header_id IS NULL)
      THEN
       /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                          'WHAT', 'po_header_id must not be NULL');*/
         GMD_API_PUB.Log_Message('GMD_PO_HEADER_MUST_NOT_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_sample_rec.po_line_id IS NULL)
      THEN
       /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                         'WHAT', 'po_line_id must not be NULL');*/
         GMD_API_PUB.Log_Message('GMD_PO_LINE_MUST_NOT_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    IF (p_sample_rec.receipt_id IS NOT NULL AND p_sample_rec.receipt_line_id IS NULL)
    THEN
    /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                          'WHAT', 'receipt_line_id must not be NULL');*/
      GMD_API_PUB.Log_Message('GMD_RECEIPT_LINE_MUST_NOT_NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_sample_rec.receipt_line_id IS NOT NULL AND p_sample_rec.receipt_id IS NULL)
    THEN
    /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                          'WHAT', 'receipt_id must not be NULL');*/
      GMD_API_PUB.Log_Message('GMD_RECEIPT_MUST_NOT_NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(p_sample_rec.receipt_id IS NOT NULL AND p_sample_rec.receipt_line_id IS NOT NULL)
    THEN
      OPEN c_receipt_info;
      FETCH c_receipt_info INTO l_dummy;
      IF (c_receipt_info%NOTFOUND)
      THEN
        CLOSE c_receipt_info;
	GMD_API_PUB.Log_Message('GMD_RECEIPT_NOT_FOUND');
	RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_receipt_info;
    END IF;



  -- Set return parameters
  x_return_status := l_return_status;


EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END VALIDATE_SUPP_SAMPLE;


-- Added for MPK Bug
PROCEDURE VALIDATE_STABILITY_SAMPLE
( p_sample_rec     IN  GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

BEGIN

  -- Stability Study samples cannot be loaded through Create Private API
  x_return_status := FND_API.G_RET_STS_ERROR;

END VALIDATE_STABILITY_SAMPLE;



PROCEDURE VALIDATE_RESOURCE_SAMPLE
( p_sample_rec     IN  GMD_SAMPLES%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

-- bug# 3452384
-- cursor to validate resource
CURSOR c_resource IS
  SELECT 1
  FROM   cr_rsrc_mst
  WHERE  delete_mark = 0
  and    resources = p_sample_rec.resources ;

l_dummy            NUMBER(1);
l_return_status    VARCHAR2(1);

BEGIN
  -- Assign API local  Variables;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ((p_sample_rec.inventory_item_id IS NOT NULL)
    OR (p_sample_rec.lot_number IS NOT NULL)) THEN
    /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'Item and Lot', ' should not be specified for Monitor sample');*/
      GMD_API_PUB.Log_Message('GMD_ITEM_LOT_MONITOR_SAMPLE');
      RAISE FND_API.G_EXC_ERROR;
  END IF;          -- test item sources

  IF ((p_sample_rec.sample_qty IS NOT NULL)
    OR (p_sample_rec.sample_qty_uom IS NOT NULL)) THEN
    /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'Quantity and UOM', ' should not be specified for Monitor sample');*/
      GMD_API_PUB.Log_Message('GMD_QTY_UOM_MONITOR_SAMPLE');
      RAISE FND_API.G_EXC_ERROR;
  END IF;          -- test item sources

  IF p_sample_rec.resources IS NULL THEN
      GMD_API_PUB.Log_Message('GMD_QC_RESOURCE_REQD');
      RAISE FND_API.G_EXC_ERROR;
  END IF;          -- test item sources

  -- validate resource
  -- start of bug# 3452384

  OPEN c_resource;
  FETCH c_resource INTO l_dummy;
  IF (c_resource%NOTFOUND)
  THEN
    CLOSE c_resource;
    GMD_API_PUB.Log_Message('GMD_RESOURCE_NOT_FOUND',
                            'RESOURCE', p_sample_rec.resources);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_resource;

-- end of bug 3452384

  -- Set return parameters
  x_return_status := l_return_status;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END VALIDATE_RESOURCE_SAMPLE;



PROCEDURE VALIDATE_LOCATION_SAMPLE
( p_sample_rec     IN  GMD_SAMPLES%ROWTYPE,
  p_locator_control  IN  NUMBER,
  x_return_status  OUT NOCOPY VARCHAR2
)
IS

    -- Bug 4165704: changed for inventory convergence
  CURSOR c_subinventory_loct IS
    SELECT 1
    FROM mtl_item_locations
    WHERE organization_id        = p_sample_rec.organization_id
      AND inventory_location_id  = p_sample_rec.locator_id
      AND subinventory_code      = p_sample_rec.subinventory;
         --FROM   ic_loct_mst
         --WHERE  whse_code   = p_sample_rec.whse_code
         --AND    location    = p_sample_rec.location
         --AND    delete_mark = 0;

l_dummy            NUMBER;
l_return_status    VARCHAR2(1);


BEGIN
  -- Assign API local  Variables;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ((p_sample_rec.inventory_item_id IS NOT NULL)
    OR (p_sample_rec.lot_number IS NOT NULL)) THEN
      GMD_API_PUB.Log_Message('GMD_ITEM_LOT_MONITOR_SAMPLE');
      RAISE FND_API.G_EXC_ERROR;
  END IF;          -- test item sources

  IF ((p_sample_rec.sample_qty IS NOT NULL)
    OR (p_sample_rec.sample_qty_uom IS NOT NULL)) THEN
      GMD_API_PUB.Log_Message('GMD_QTY_UOM_MONITOR_SAMPLE');
      RAISE FND_API.G_EXC_ERROR;
  END IF;          -- test item sources

  IF p_sample_rec.subinventory IS NULL THEN
      GMD_API_PUB.Log_Message('GMD_QC_WHSE_REQD');
      RAISE FND_API.G_EXC_ERROR;
  END IF;          -- test item sources

  -- This Procedure Assumes that the whse and item have been validated.

  -- Validate the location
  --=======================================================================
  -- Location :
  -- : The locator is nullable even if locator_control > 1,
  --                    but must be checked.

  -- Bug 4165704: This table is changed with new locator control
  --              and checking for location control is up to new routine
  --              called earlier
  -- This field should follow this table :
  --  item_loct_ctl  whse_code  whse_loct_ctl  location  Possible
  --         0       NULL            -         NULL      No
  --         0       NULL            -         Checked   No
  --         0       NOTNULL         0         NULL      No
  --         0       NOTNULL         0         Checked   No
  --         0       NOTNULL         1         NULL      No
  --         0       NOTNULL         1         Checked   No
  --         1       NULL            -         NULL      Yes
  --         1       NULL            -         Checked   No
  --         1       NOTNULL         0         NULL      Yes
  --         1       NOTNULL         0         Checked   No
  --         1       NOTNULL         1         NULL      No
  --         1       NOTNULL         1         Checked   Yes
  --=========================================================================

  IF (p_locator_control = 1) THEN
    IF (p_sample_rec.locator_id IS NOT NULL)  THEN
        GMD_API_PUB.Log_Message('GMD_LOCATION_MUST_NULL');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
      -- Item is location controlled.
      IF (p_sample_rec.locator_id IS NULL) THEN
          -- Location cannot be NULL in this case.
        GMD_API_PUB.Log_Message('GMD_LOCATION_MUST_NULL');
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        -- Check that Location exist in MTL_ITEM_LOCATIONS
        OPEN c_subinventory_loct;
        FETCH c_subinventory_loct INTO l_dummy;
        IF (c_subinventory_loct%NOTFOUND) THEN
          --CLOSE c_subinventory_loct;
          GMD_API_PUB.Log_Message('GMD_LOCT_NOT_FOUND',
                                  'LOCATION', p_sample_rec.locator_id);
          --RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE c_subinventory_loct;
      END IF;   -- location IS NOT NULL
  END IF;    -- p_locator_control = 1


  -- Set return parameters
  x_return_status := l_return_status;

EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END VALIDATE_LOCATION_SAMPLE;



PROCEDURE VALIDATE_SAMPLE
( p_sample_rec    IN         GMD_SAMPLES%ROWTYPE
, p_grade         IN         VARCHAR2  --3431884
, x_sample_rec    OUT NOCOPY GMD_SAMPLES%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
)
IS
       -- Bug 4165704: organization validation changed with inventory convergence
  CURSOR c_orgn (p_organization_id NUMBER) IS
       -- SELECT 1
       -- FROM   sy_orgn_mst
       -- WHERE  orgn_code = p_orgn_code
       -- AND    delete_mark = 0;
  SELECT 1
  FROM mtl_parameters m,
       gmd_quality_config g
  WHERE g.organization_id        =  m.organization_id
    AND m.organization_id        =  p_organization_id
    AND m. process_enabled_flag = 'Y'	;

  CURSOR c_sampler (p_orgn_code VARCHAR2 , p_sampler_id NUMBER) IS
  SELECT 1
  FROM   FND_USER
  WHERE  user_id  = p_sampler_id ;
     -- bug 4165704: taken out for invconv
     --AND    user_id in
     --    ( select user_id
     --      from   sy_orgn_usr
     --      where orgn_code = p_orgn_code);


       -- Bug 4165704: organization validation changed with inventory convergence
  CURSOR c_lab_orgn (p_organization_id NUMBER) IS
       -- SELECT 1
       -- FROM   sy_orgn_mst
       -- WHERE  orgn_code = p_orgn_code
       -- AND    plant_ind <> 0
       -- AND    delete_mark = 0;
  SELECT 1
  FROM mtl_parameters m,
       gmd_quality_config g
  WHERE g.organization_id        =  m.organization_id
    AND g.quality_lab_ind        = 'Y'
    AND m.organization_id        =  p_organization_id
    AND m. process_enabled_flag = 'Y'	;

   -- Bug 4165704: This cursor is not used
       --CURSOR c_item(p_inventory_item_id NUMBER, p_organization_id NUMBER) IS
       --SELECT 1
       --FROM   ic_item_mst
       --WHERE  item_id = p_item_id
       --AND    delete_mark = 0;

  CURSOR c_sampling_event(p_sampling_event_id NUMBER) IS
  SELECT 1
  FROM   gmd_sampling_events
  WHERE  sampling_event_id = p_sampling_event_id
  ;

    -- Bug 4165704: changed for inventory convergence
  CURSOR c_subinventory IS
  SELECT 1
  FROM   mtl_secondary_inventories s
  WHERE  s.organization_id          = p_sample_rec.organization_id
    AND  s.secondary_inventory_name = p_sample_rec.subinventory;
         --CURSOR c_whse IS
         --SELECT loct_ctl
         --FROM   ic_whse_mst
         --WHERE  whse_code = p_sample_rec.whse_code
         --AND    delete_mark = 0;

    -- Bug 4165704: Updated for inventory convergence
  CURSOR c_subinventory_locator IS
  SELECT 1
  FROM   mtl_item_locations
  WHERE  subinventory_code      = p_sample_rec.subinventory
    AND  organization_id        = p_sample_rec.organization_id
    AND  inventory_location_id  = p_sample_rec.locator_id;

    -- Bug 4165704: no longer need c_orgn_whse or c_grade_ctl cursors after inventory convergence
        --  CURSOR c_orgn_whse IS
        --  SELECT 1
        --  FROM   ic_whse_mst iwm
        --       , sy_orgn_mst som
        --  WHERE  som.orgn_code   = iwm.orgn_code
        --  AND    iwm.whse_code   = p_sample_rec.whse_code
        --  AND    iwm.orgn_code   = p_sample_rec.orgn_code
        --  AND    som.delete_mark = 0
        --  AND    iwm.delete_mark = 0;

        --CURSOR c_grade_ctl IS
        --SELECT grade_ctl
        --FROM IC_ITEM_MST_B
        --WHERE ITEM_ID = p_sample_rec.inventory_item_id ;

  -- bug 5291495
   CURSOR uom is
   SELECT PRIMARY_UOM_CODE
        FROM mtl_system_items_b
        WHERE organization_id = p_sample_rec.organization_id
	  	AND inventory_item_id = p_sample_rec.inventory_item_id;
	l_uom              mtl_units_of_measure.uom_code%TYPE;
	l_test_qty	number;

-- 5283854 rework
CURSOR c_storage_subinventory_locator IS
  SELECT 1
  FROM   mtl_item_locations
  WHERE  subinventory_code      = p_sample_rec.storage_subinventory
    AND  organization_id        = p_sample_rec.storage_organization_id
    AND  inventory_location_id  = p_sample_rec.storage_locator_id;

  l_grade_ctl           NUMBER;
  l_dummy               NUMBER;
  l_sample_rec          GMD_SAMPLES%ROWTYPE;
  l_sample_out_rec      GMD_SAMPLES%ROWTYPE;
  l_locator_control     NUMBER;
  l_return_status       VARCHAR2(1);

BEGIN

  --  Initialize API return status to success
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sample_rec    := p_sample_rec;

  ----------------------------------
  -- Validate Sample Required Fields
  ----------------------------------

  -- Orgn Code
  IF (p_sample_rec.organization_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_ORGN_CODE_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Check that orgn Code exist in SY_ORGN_MST
    OPEN c_orgn(p_sample_rec.organization_id);
    FETCH c_orgn INTO l_dummy;
    IF c_orgn%NOTFOUND THEN
      CLOSE c_orgn;
      GMD_API_PUB.Log_Message('GMD_ORGN_CODE_NOT_FOUND',
                              'ORGN', p_sample_rec.organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn;
  END IF;

  -- Sampler Id Validation

  IF (p_sample_rec.sampler_id IS NULL ) THEN
     GMD_API_PUB.Log_Message('GMD_SAMPLER_ID_REQD');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Check that orgn Code exist in mtl_parameters
    OPEN c_sampler(p_sample_rec.organization_id, p_sample_rec.sampler_id);
      FETCH c_sampler INTO l_dummy;
      IF c_sampler%NOTFOUND THEN
        GMD_API_PUB.Log_Message('GMD_SAMPLER_ID_NOTFOUND',
                              'SAMPLER', p_sample_rec.sampler_id);
        RAISE FND_API.G_EXC_ERROR;
        CLOSE c_sampler;
      END IF;
    CLOSE c_sampler;
  END IF;

  -- Sample No
  IF (ltrim(rtrim(p_sample_rec.sample_no)) IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SAMPLE_NUMBER_REQD');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- QC Lab Orgn Code
  IF (p_sample_rec.lab_organization_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_QC_LAB_ORGN_CODE_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Check that QC Lab Orgn Code exist in SY_ORGN_MST
    OPEN c_lab_orgn(p_sample_rec.lab_organization_id);
    FETCH c_lab_orgn INTO l_dummy;
    IF c_lab_orgn%NOTFOUND THEN
      CLOSE c_lab_orgn;
      GMD_API_PUB.Log_Message('GMD_QC_LAB_ORGN_CODE_NOT_FOUND',
                              'ORGN', p_sample_rec.lab_organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_lab_orgn;
  END IF;

  -- Sample Disposition
    -- Bug 3401377: added planned samples to MPL
  IF ((p_sample_rec.sample_disposition IS NULL) OR
      (NOT (p_sample_rec.sample_disposition in ('0RT', '0PL', '1P')))) THEN
    -- Now, what is the disposition of this sample?
    GMD_API_PUB.Log_Message('GMD_SAMPLE_DISPOSITION_INVALID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Sample Source
    -- Bug 3401377: added Stability Study and Monitor samples to MPK
  IF (p_sample_rec.source IS NULL OR
      (NOT (p_sample_rec.source in ('I', 'W', 'C', 'S', 'T','L','R')))
     ) THEN
    -- Now, what is the source of this sample? Where did it come from?
    GMD_API_PUB.Log_Message('GMD_SAMPLE_SOURCE_INVALID');
    RAISE FND_API.G_EXC_ERROR;

  ELSE  -- VAlidate that sample type is Correct

     IF ( p_sample_rec.sample_type is NULL ) THEN
      /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'SAMPLE TYPE must be Specified');*/
        GMD_API_PUB.Log_Message('GMD_SAMPLE_TYPE');
        RAISE FND_API.G_EXC_ERROR;

     --ELSIF ( p_sample_rec.sample_type <> 'I') THEN
     ELSIF ( p_sample_rec.sample_type NOT IN ('M' , 'I')) THEN

      /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Only sample_type = M or I are Suppported');*/
        GMD_API_PUB.Log_Message('GMD_SAMPLE_TYPE_SUPPORTED');
        RAISE FND_API.G_EXC_ERROR;

     ELSIF ( p_sample_rec.sample_type = 'I')
        AND ( NOT (p_sample_rec.source in ('I', 'W', 'C', 'S', 'T'))) THEN
         /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                   'WHAT', 'SAMPLE TYPE Inventory does not match source');*/
           GMD_API_PUB.Log_Message('GMD_SAMPLE_TYPE_INVENTORY');
           RAISE FND_API.G_EXC_ERROR;

     ELSIF ( p_sample_rec.sample_type = 'M')
        AND ( NOT (p_sample_rec.source in ('R', 'L'))) THEN
         /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                   'WHAT', 'SAMPLE TYPE Monitor does not match source');*/
           GMD_API_PUB.Log_Message('GMD_SAMPLE_TYPE_MONITOR');
           RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;

  -- bug 5291495 UOM passed must be either item primary for that item or convertible for 'I' samples

 IF  p_sample_rec.sample_type <> 'M' then
 		OPEN uom;
     	FETCH uom  INTO l_uom;
    	 IF (uom%NOTFOUND)  THEN
         GMD_API_PUB.Log_Message('GMD_SAMPLE_UOM_REQD');
         RAISE FND_API.G_EXC_ERROR;
     	END IF;
  	CLOSE uom;

 		IF p_sample_rec.sample_qty_uom <> l_uom  THEN

             l_test_qty := INV_CONVERT.inv_um_convert(
                                        item_id => p_sample_rec.inventory_item_id,
                                        organization_id => p_sample_rec.organization_id,
                                        precision => NULL,
                                        from_quantity => p_sample_rec.SAMPLE_QTY,
                                        from_unit  => p_sample_rec.sample_qty_uom,
                                        to_unit  => l_uom,
                                        lot_number => 0,
                                        from_name => NULL,
                                        to_name => NULL);
             IF (l_test_qty < 0 ) THEN
                 GMD_API_PUB.Log_Message('FM_UOMMUSTCONVERT');
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

  	END IF; -- IF p_sample_rec.sample_qty_uom <> l_uom  THEN

  END IF; -- IF  p_sample_rec.sample_type <> 'M' then

-- end bug 5291495



 -- Sample Qty
   -- Bug 3401377: Monitor samples do not have a qty or uom
  IF ((p_sample_rec.sample_qty IS NULL)
   AND (p_sample_rec.sample_type = 'I' )) THEN
    GMD_API_PUB.Log_Message('GMD_SAMPLE_QTY_REQD');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Sample UOM
   -- Bug 3401377: Monitor samples do not have a qty or uom
  IF ( (p_sample_rec.sample_qty_uom IS NULL)
   AND (p_sample_rec.sample_type = 'I' )) THEN
    GMD_API_PUB.Log_Message('GMD_SAMPLE_UOM_REQD');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Validate Whse_code if passed.

  IF (p_sample_rec.subinventory IS NOT NULL) THEN
    -- Bug 4165704: changed for Inventory Convergence
    -- Check that Warehouse Code exist in MTL_SUBINVENTORIES
    -- AND Get the loct_ctl of the subinventory
    OPEN c_subinventory;
    FETCH c_subinventory   INTO l_dummy;
    IF (c_subinventory%NOTFOUND) THEN
      CLOSE c_subinventory;
      GMD_API_PUB.Log_Message('GMD_WHSE_NOT_FOUND',
                              'WHSE_CODE', p_sample_rec.subinventory);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_subinventory;

       -- Bug 4165704: taken out because it was not needed
       -- Check that Warehouse Code exist in IC_WHSE_MST linked to the organization
       --OPEN c_orgn_whse;
       --FETCH c_orgn_whse  INTO l_dummy;
       --IF (c_orgn_whse%NOTFOUND) THEN
       --   CLOSE c_orgn_whse;
       --    GMD_API_PUB.Log_Message('GMD_WHSE_AND_ORGN_CODE');
       --     RAISE FND_API.G_EXC_ERROR;
       --  END IF;
       --  CLOSE c_orgn_whse;
  END IF;

  -- Validate location

   -- 5283854   if subinv is not specified and  locator is then error out
  IF p_sample_rec.subinventory IS NULL  and p_sample_rec.locator_id is NOT NULL THEN
   			GMD_API_PUB.Log_Message('GMD_API_LOCATOR_NOT_REQD');
   		  RAISE FND_API.G_EXC_ERROR;
  END IF;
   -- end 5283854

   -- Bug 4165704: used common routine to determine location control


  GMD_COMMON_GRP.item_is_locator_controlled (
                      p_organization_id   => p_sample_rec.organization_id
                     ,p_subinventory      => p_sample_rec.subinventory
                     ,p_inventory_item_id => p_sample_rec.inventory_item_id
                     ,x_locator_type      => l_locator_control
                     ,x_return_status     => l_return_status );

  IF ( l_locator_control = 1 ) THEN -- Not location controlled.

     IF ( p_sample_rec.locator_id is NOT NULL) THEN
      /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Location should be NULL');*/
        GMD_API_PUB.Log_Message('GMD_LOCATION_MUST_NULL');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  ELSIF ( l_locator_control > 1) THEN -- Validate that location exists in whse
       -- Bug 4165704: updated for locator and subinventory

      -- 5283854   if subinv is specified and  locator is NOT then error out
  	 IF p_sample_rec.subinventory IS NOT NULL  and p_sample_rec.locator_id is NULL THEN
   			GMD_API_PUB.Log_Message('GMD_API_SUBINV_REQD');
   		  RAISE FND_API.G_EXC_ERROR;
 		 END IF;
     -- end 5283854

     IF ( p_sample_rec.locator_id is NOT NULL) THEN -- location specified

        OPEN c_subinventory_locator;
        FETCH c_subinventory_locator  INTO l_dummy;
        IF (c_subinventory_locator%NOTFOUND) THEN
          --CLOSE c_subinventory_locator;
          GMD_API_PUB.Log_Message('GMD_LOCT_NOT_FOUND',
                                  'LOCATOR', p_sample_rec.locator_id);
         RAISE FND_API.G_EXC_ERROR;    -- 5283854  rework - take out -- from this line
        END IF;
        CLOSE c_subinventory_locator;
     END IF;

  END IF;

-- 5283854 rework
-- Validate storage details and location


   IF p_sample_rec.storage_organization_id is NULL and ( p_sample_rec.storage_subinventory IS NOT NULL   or p_sample_rec.storage_locator_id is NOT NULL )
      then
       GMD_API_PUB.Log_Message('GMD_LOCATION_MUST_NULL');
        RAISE FND_API.G_EXC_ERROR;
   END IF;


  IF p_sample_rec.storage_organization_id IS NOT NULL
   and ( p_sample_rec.storage_subinventory IS NOT NULL   or p_sample_rec.storage_locator_id is NOT NULL )
   then



   --    if subinv is not specified and  locator is then error out
  IF p_sample_rec.storage_subinventory IS NULL  and p_sample_rec.storage_locator_id is NOT NULL THEN
   			GMD_API_PUB.Log_Message('GMD_API_LOCATOR_NOT_REQD');
   		  RAISE FND_API.G_EXC_ERROR;
  END IF;


  GMD_COMMON_GRP.item_is_locator_controlled (
                      p_organization_id   => p_sample_rec.storage_organization_id
                     ,p_subinventory      => p_sample_rec.storage_subinventory
                     ,p_inventory_item_id => p_sample_rec.inventory_item_id
                     ,x_locator_type      => l_locator_control
                     ,x_return_status     => l_return_status );

  IF ( l_locator_control = 1 ) THEN -- Not location controlled.

     IF ( p_sample_rec.storage_locator_id is NOT NULL) THEN
      /*GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Location should be NULL');*/
        GMD_API_PUB.Log_Message('GMD_LOCATION_MUST_NULL');
        RAISE FND_API.G_EXC_ERROR;
     END IF;

  ELSIF ( l_locator_control > 1) THEN -- Validate that locater exists in subinv


      --   if subinv is specified and  locator is NOT then error out
  	 IF p_sample_rec.storage_subinventory IS NOT NULL  and p_sample_rec.storage_locator_id is NULL THEN
   			GMD_API_PUB.Log_Message('GMD_API_SUBINV_REQD');
   		  RAISE FND_API.G_EXC_ERROR;
 	 END IF;

     	IF ( p_sample_rec.storage_locator_id is NOT NULL) THEN -- location specified

        	OPEN c_storage_subinventory_locator;
      	 	 FETCH c_storage_subinventory_locator  INTO l_dummy;
       		 IF (c_storage_subinventory_locator%NOTFOUND) THEN
          		GMD_API_PUB.Log_Message('GMD_LOCT_NOT_FOUND',
                                  'LOCATOR', p_sample_rec.storage_locator_id);
         		RAISE FND_API.G_EXC_ERROR;
       		 END IF;
        	CLOSE c_storage_subinventory_locator;
     	END IF;

  END IF; -- IF ( l_locator_control = 1 ) THEN -- Not location controlled.

END IF;   --  IF p_sample_rec.storage_organization_id IS NOT NULL


-- end 5283854 rework



  ----------------------------------
  -- Validate Item Definition
  ----------------------------------
  -- Bug 3401377: Monitor samples do not have items
  IF (p_sample_rec.sample_type = 'I') THEN
     Validate_item_controls(
        p_sample_rec     => p_sample_rec,
        p_grade          => p_grade,
        x_sample_rec     => l_sample_rec,
        x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        -- Message is alrady logged by check_for_null procedure
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        -- Message is alrady logged by check_for_null procedure
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  END IF;  -- bug 3401377

    --3431884
  ----------------------------------
  -- Validate Grade
  ----------------------------------
        -- Bug 4165704: grade control is now done in validate_item_controls procedure
        --  OPEN  c_grade_ctl;
        --  FETCH c_grade_ctl INTO l_grade_ctl;

  ----------------------------------
  -- Validate Sample Source Types
  ----------------------------------
  IF (p_sample_rec.source = 'I') THEN

     Validate_inv_sample (
       p_sample_rec             => l_sample_rec,
       p_locator_control        => l_locator_control,
       x_return_status          => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


  ELSIF ( p_sample_rec.source = 'W') THEN

     Validate_wip_sample (
       p_sample_rec     => l_sample_rec,
       x_sample_rec     => l_sample_out_rec,
       x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_sample_rec := l_sample_out_rec;

  ELSIF ( p_sample_rec.source = 'C') THEN

     Validate_cust_sample (
       p_sample_rec     => l_sample_rec,
       x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  ELSIF ( p_sample_rec.source = 'S') THEN
     -- validate_supp_sample;

      --dbms_output.put_line('Call to validate supp samples');

     Validate_supp_sample (
       p_sample_rec     => l_sample_rec,
       x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

      --dbms_output.put_line('after Call to validate supp samples');

       -- Bug 3401377: added Resource, Location and Stability Study samples to MPK
  ELSIF ( p_sample_rec.source = 'T') THEN
     -- validate_stability_study_sample;

     Validate_stability_sample (
       p_sample_rec     => l_sample_rec,
       x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

  ELSIF ( p_sample_rec.source = 'R') THEN
     -- validate_resource_sample;

     Validate_resource_sample (
       p_sample_rec     => l_sample_rec,
       x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  ELSIF ( p_sample_rec.source = 'L') THEN
     -- validate_location_sample;

     Validate_location_sample (
       p_sample_rec     => l_sample_rec,
       p_locator_control        => l_locator_control,
       x_return_status  => l_return_status);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       -- Message is alrady logged by check_for_null procedure
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  END IF; -- Validation for Supplier Sample

  --Validate Priority Field.
  IF l_sample_rec.priority IS NULL THEN
     l_sample_rec.priority := '5N';

  ELSIF (NOT GMD_QC_TESTS_GRP.validate_test_priority
           (p_test_priority => l_sample_rec.priority)
        ) THEN
       GMD_API_PUB.Log_Message('GMD_INVALID_TEST_PRIORITY');
       RAISE FND_API.G_EXC_ERROR;
  END IF;

      --dbms_output.put_line('after validate_test_priority');

  -- bug 2995114

  IF NVL(l_sample_rec.sample_inv_trans_ind ,'N') NOT IN ('N','Y') THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'SAMPLE_INV_TRANS_IND');

        RAISE FND_API.G_EXC_ERROR;
  END IF;



  -- Now Call Group Layer Validate Samples API
  -- To perform business logic validation.

      --dbms_output.put_line('b4 GMD_SAMPLES_GRP.validate_sample');


  GMD_SAMPLES_GRP.validate_sample(
    p_sample        => l_sample_rec,
    p_called_from   => 'PUBLIC',
    p_operation     => 'INSERT',
    x_return_status => l_return_status
  );

      --dbms_output.put_line('after GMD_SAMPLES_GRP.validate_sample');


  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     -- Message is alrady logged by check_for_null procedure
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     -- Message is alrady logged by check_for_null procedure
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;



  -- Set return parameters
  x_return_status := l_return_status;
  x_sample_rec    := l_sample_rec;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END VALIDATE_SAMPLE;

END GMD_SAMPLES_PUB;

/
