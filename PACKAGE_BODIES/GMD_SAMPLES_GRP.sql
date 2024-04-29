--------------------------------------------------------
--  DDL for Package Body GMD_SAMPLES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SAMPLES_GRP" AS
--$Header: GMDGSMPB.pls 120.33.12010000.4 2009/11/23 22:23:37 plowe ship $
-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_SAMPLES_GRP';

   --Bug 3222090, magupta removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')
   --forward decl.
   FUNCTION set_debug_flag RETURN VARCHAR2;
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
--| File Name          : GMDGSMPB.pls                                        |
--| Package Name       : GMD_Samples_GRP                                     |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Entity       |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	26-Jul-2002	Created.                             |
--|    Chetan Nagar	05-Nov-2002	Removed logging of error message     |
--|      from sampling_event_exist and  sampling_event_exist_wo_spec         |
--|                                                                          |
--|  RLNAGARA   19-Dec-2005  Bug#4868950                                     |
--|    -- Modified the procedure sample_source_display                       |
--|  RLNAGARA   20-Dec-2005  Bug# 4880152				     |
--|    -- Modified the procedure sample_source_display
--|  J. DiIorio 25-Jan-2006  Bug# 4695552				     |
--|    -- Changed sample_source_display to handle grade_code,
--|    -- storage_subinventory, and storage_locator.
--|    -- Changed stability_study_source to not override locator.
--|  M. Grosser 28-Feb-2006  Bug 5016617 - Added retrieval of supplier name  |
--|             to procedure sample_source_display.
--|  Peter Lowe       22-Mar-2006 -Bug 4754855 changed logic for             |
--|    retrieval of Cur_formulaline in api wip_source
--|  Peter Lowe 13-MAR-2006  FP of Bug # 4359797  4619570                    |
--|              Added code so that samples are created for Closed batches   |
--|              depending upon the profile option but inv is not updated    |
--|  RLNAGARA   04-Apr-2006 B5106199 UOM Conv Changes in the procedure update_remaining_qty |
--|  Peter Lowe 14-Apr-2006 - Bug 5127352  - reversed logic of Bug 4754855   |
--|     as QA now states that we do not need formula line no or type on      |
--|     Samples Summary form  		                                     |
--|  M. Grosser 03-May-2006  Bug 5115015 - Modified procedure validate_sample|
--|             to not validate sample number when automatic sample number   |
--|             creation is in effect so that the number can be retrieved    |
--|             AFTER the sample has passed validation.  Sample numbers were |
--|             being lost.
--|    srakrish bug 5394566: Commenting the cursors as these have 	     |
--|		hardcoded values and material_detail_id is directly passed   |
--|		in create_wip_txn|					     |
--|  RAGSRIVA   01-Nov-2006 Bug 5629709 Modified procedure create_wip_txn to |
--|             Undo the fix for bug# 5394566 and pass the transaction type  |
--|             id and the lot information in the call to                    |
--|             GME_API_PUB.create_material_txn                              |
--| RLNAGARA 28-Nov-2006 B5668965 Modified the proc update_lot_grade_batch   |
--| RLNAGARA 12-Jan-2007 B5738041 Added Revisions to the cursors in the proc create_wip_txn |
--|    RLNAGARA LPN ME 7027149 09-May-2008 Added logic for lpn_id in all     |
--|                                     the necessary cursors                |
--|    PLOWE LPN ME 7027149 15-May-2008 support got LPN in group api         |
--|  KISHORE  Bug No.8679485  Dt.16-Jul-2009 |
--|     Added code to change Disposition in the tables GMD_SAMPLING_EVENTS, |
--|     GMD_EVENT_SPEC_DISP while changing disposition from final to final like Accept to Reject
--|     Reject -> Accept, Accept -> Accept With Variance etc...
--+==========================================================================+
-- End of comments



--Start of comments
--+========================================================================+
--| API Name    : sampling_event_exist                                     |

--|               event that matches with the sample supplied, otherwise   |
--|               returns FALSE.                                           |
--|                                                                        |
--|               The function also populate OUT variable -                |
--|               sampling_event_id of the GMD_SAMPLING_EVENT record if    |
--|               it is found.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Chetan Nagar	03-Dec-2002	Added checks to see if the Spec and|
--|                                     Validity Rule associated with the  |
--|                                     Sampling Event are still active.   |
--|    Chetan Nagar	24-Jan-2003	The previous check for Spec and    |
--|                                     VR should be for the latest Spec   |
--|                                     VR from the Event Spec Disp.       |
--|    Susan Feinstein  14-Apr-2003     Bug 2825696                        |
--|                                     Added orgn_code to sampling_event  |
--|                                     table.  Changed cursors in sampling|
--|                                     exist with and without spec.       |
--|                                                                        |
--|    Susan Feinstein  26-Jun-2003     Took out references to validity    |
--|       Bug #2952823                  rule tables and spec tables from   |
--|                                     the sql.  Samples will now look    |
--|                                     first for a spec id and then for   |
--|                                     a matching sampling event whereas  |
--|                                     it used to do the search in        |
--|                                     the opposite order, ie. first      |
--|                                     sampling event and then spec.      |
--|   Lakshmi Swamy 20-NOV-2003         Bug3264636                         |
--|  Created procedure sampling_event_with_vr_id. If spec_vr_id passed     |
--|  we call this new procedure from sampling_event_exist function         |
--|  Otherwise - its old code where cursors look at specifications table   |
--|    RLNAGARA LPN ME 7027149 09-May-2008 Added logic for lpn_id in all   |
--|                                     the cursors                        |
--+========================================================================+
-- End of comments

FUNCTION sampling_event_with_vr_id
(
  p_sample            IN         gmd_samples%ROWTYPE
, x_sampling_event_id OUT NOCOPY NUMBER
, p_spec_vr_id        IN         NUMBER DEFAULT NULL
) RETURN BOOLEAN IS

  -- Bug 3086932: added source = p_sample.source to where clause because
  --              otherwise inventory sample could become part of another source
  --              group using inventory spec vr
  CURSOR c_inv_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
              --        gmd_specifications_b s,
              --        gmd_inventory_spec_vrs ivr,
	 gmd_event_spec_disp esd
              -- WHERE  s.spec_id = ivr.spec_id
              -- AND    ivr.spec_vr_id = esd.spec_vr_id
              -- AND    esd.sampling_event_id = se.sampling_event_id
  WHERE  esd.sampling_event_id = se.sampling_event_id
  AND    ( (esd.spec_vr_id = p_spec_vr_id) OR
	(esd.spec_vr_id is  null and p_spec_vr_id is null ))
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    se.source   = p_sample.source
  AND    se.organization_id = p_sample.organization_id
              -- AND    s.item_id = p_sample.inventory_item_id
  AND    ((se.subinventory IS NULL AND p_sample.subinventory IS NULL) OR
          (se.subinventory = p_sample.subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.locator_id IS NULL) OR
          (se.locator_id = p_sample.locator_id)
         )
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  AND    ((se.lot_retest_ind IS NULL AND p_sample.lot_retest_ind IS NULL) OR
          (se.lot_retest_ind = p_sample.lot_retest_ind)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  ORDER BY se.creation_date desc
  ;

  -- Bug 3086932: added source = p_sample.source to where clause because
  --              otherwise inventory sample could become part of wip source
  --              group using inventory spec vr
  -- Bug 4640143: added material detail id
  CURSOR c_wip_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
	 gmd_event_spec_disp esd
  WHERE  esd.sampling_event_id = se.sampling_event_id
  AND    ( (esd.spec_vr_id = p_spec_vr_id) OR
	 (esd.spec_vr_id is  null and p_spec_vr_id is null ))
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    se.source   = p_sample.source
  AND    se.organization_id = p_sample.organization_id
  AND    ((se.batch_id is NULL AND p_sample.batch_id is NULL) OR
          (se.batch_id = p_sample.batch_id)
         )
  AND    ((se.recipe_id is NULL AND p_sample.recipe_id is NULL) OR
          (se.recipe_id = p_sample.recipe_id)
         )
  AND    ((se.formula_id is NULL AND p_sample.formula_id is NULL) OR
          (se.formula_id = p_sample.formula_id)
         )
  AND    ((se.formulaline_id is NULL AND p_sample.formulaline_id is NULL) OR
          (se.formulaline_id = p_sample.formulaline_id
            AND p_sample.batch_id IS NULL)
         )
  AND    ((se.material_detail_id is NULL AND p_sample.material_detail_id is NULL) OR
          (se.material_detail_id = p_sample.material_detail_id)
         )
  AND    ((se.routing_id is NULL AND p_sample.routing_id is NULL) OR
          (se.routing_id = p_sample.routing_id)
         )
  AND    ((se.step_id is NULL AND p_sample.step_id is NULL) OR
          (se.step_id = p_sample.step_id)
         )
  AND    ((se.oprn_id is NULL AND p_sample.oprn_id is NULL) OR
          (se.oprn_id = p_sample.oprn_id)
         )
  AND    ((se.charge is NULL AND p_sample.charge is NULL) OR
          (se.charge = p_sample.charge)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
              -- AND    s.delete_mark = 0                         -- Spec is still active
              -- AND    ((s.spec_status between 400 and 499) OR
	              -- (s.spec_status between 700 and 799) OR
	              -- (s.spec_status between 900 and 999)
                     -- )
              -- AND    wvr.delete_mark = 0                       -- Validity rule is still active
              -- AND    ((wvr.spec_vr_status between 400 and 499) OR
	              -- (wvr.spec_vr_status between 700 and 799) OR
	              -- (wvr.spec_vr_status between 900 and 999)
                     -- )
              -- AND    wvr.start_date <= SYSDATE
              -- AND    (wvr.end_date is NULL OR wvr.end_date >= SYSDATE)
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR          --Bug# 3736716. Added Lot id
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.subinventory IS NULL AND p_sample.source_subinventory IS NULL) OR  --Bug# 3736716. Added Source warehouse
          (se.subinventory = p_sample.source_subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.source_locator_id IS NULL) OR  --Bug# 3736716. Added Source Location
          (se.locator_id = p_sample.source_locator_id)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  ORDER BY se.creation_date desc
  ;


  -- Bug 3086932: added source = p_sample.source to where clause because
  --              otherwise inventory sample could become part of cust source
  --              group using inventory spec vr
  CURSOR c_cust_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
             -- gmd_specifications_b s,
             -- gmd_customer_spec_vrs cvr,
	 gmd_event_spec_disp esd
             -- WHERE  s.spec_id = cvr.spec_id
             -- AND    cvr.spec_vr_id = esd.spec_vr_id
  WHERE  esd.sampling_event_id = se.sampling_event_id
  AND    ( (esd.spec_vr_id = p_spec_vr_id) OR
	 (esd.spec_vr_id is  null and p_spec_vr_id is null ))
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    se.source   = p_sample.source
  AND    se.organization_id = p_sample.organization_id
  AND    ((se.cust_id is NULL AND p_sample.cust_id is NULL) OR
          (se.cust_id = p_sample.cust_id)
         )
  AND    ((se.org_id is NULL AND p_sample.org_id is NULL) OR
          (se.org_id = p_sample.org_id)
         )
  AND    ((se.order_id is NULL AND p_sample.order_id is NULL) OR
          (se.order_id = p_sample.order_id)
         )
  AND    ((se.order_line_id is NULL AND p_sample.order_line_id is NULL) OR
          (se.order_line_id = p_sample.order_line_id)
         )
  AND    ((se.ship_to_site_id is NULL AND p_sample.ship_to_site_id is NULL) OR
          (se.ship_to_site_id = p_sample.ship_to_site_id)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
              -- AND    s.delete_mark = 0                         -- Spec is still active
              -- AND    ((s.spec_status between 400 and 499) OR
	              -- (s.spec_status between 700 and 799) OR
	              -- (s.spec_status between 900 and 999)
                     -- )
              -- AND    cvr.delete_mark = 0                       -- Validity rule is still active
              -- AND    ((cvr.spec_vr_status between 400 and 499) OR
	              -- (cvr.spec_vr_status between 700 and 799) OR
	              -- (cvr.spec_vr_status between 900 and 999)
                     -- )
              -- AND    cvr.start_date <= SYSDATE
              -- AND    (cvr.end_date is NULL OR cvr.end_date >= SYSDATE)
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR          --Bug# 3736716. Added Lot id
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  ORDER BY se.creation_date desc
  ;


  -- Bug 3086932: added source = p_sample.source to where clause because
  --             otherwise inventory sample could become part of supplier source
  --             group using inventory spec vr
  -- Bug 3143796: added whse, location and lot_number
  CURSOR c_supp_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
            -- gmd_specifications_b s,
            -- gmd_supplier_spec_vrs svr,
	 gmd_event_spec_disp esd
            -- WHERE  s.spec_id = svr.spec_id
            -- AND    svr.spec_vr_id = esd.spec_vr_id
  WHERE    esd.sampling_event_id = se.sampling_event_id
  AND    ( (esd.spec_vr_id = p_spec_vr_id) OR
	 (esd.spec_vr_id is  null and p_spec_vr_id is null ))
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    se.source   = p_sample.source
  AND    se.organization_id = p_sample.organization_id
  AND    ((se.supplier_id is NULL AND p_sample.supplier_id is NULL) OR
          (se.supplier_id = p_sample.supplier_id)
         )
  AND    ((se.supplier_site_id is NULL AND p_sample.supplier_site_id is NULL) OR
          (se.supplier_site_id = p_sample.supplier_site_id)
         )
  AND    ((se.po_header_id is NULL AND p_sample.po_header_id is NULL) OR
          (se.po_header_id = p_sample.po_header_id)
         )
  AND    ((se.po_line_id is NULL AND p_sample.po_line_id is NULL) OR
          (se.po_line_id = p_sample.po_line_id)
         )
  AND    ((se. subinventory is NULL AND p_sample.subinventory is NULL) OR
          (se. subinventory = p_sample. subinventory)
         )
  AND    ((se. locator_id  is NULL AND p_sample.locator_id  is NULL) OR
          (se. locator_id  = p_sample. locator_id)
         )
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
            /* AND    s.delete_mark = 0                         -- Spec is still active
            AND    ((s.spec_status between 400 and 499) OR
	            (s.spec_status between 700 and 799) OR
	            (s.spec_status between 900 and 999)
                   )
            AND    svr.delete_mark = 0                       -- Validity rule is still active
            AND    ((svr.spec_vr_status between 400 and 499) OR
	            (svr.spec_vr_status between 700 and 799) OR
	            (svr.spec_vr_status between 900 and 999)
                   )
            AND    svr.start_date <= SYSDATE
            AND    (svr.end_date is NULL OR svr.end_date >= SYSDATE)
          */
  ORDER BY se.creation_date desc
  ;

  -- Bug 2959466: added source = p_sample.source to where clause because
  --              if se.resource was null then location sampling events were
  --              attached to resource samples.
CURSOR c_res_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
           -- gmd_specifications_b s,
           -- gmd_monitoring_spec_vrs svr,
         gmd_event_spec_disp esd
           -- WHERE  s.spec_id = svr.spec_id
           -- AND    svr.spec_vr_id = esd.spec_vr_id
  WHERE  esd.sampling_event_id = se.sampling_event_id
  AND    ( (esd.spec_vr_id = p_spec_vr_id) OR
	 (esd.spec_vr_id is  null and p_spec_vr_id is null ))
  AND    ((se.organization_id is NULL AND p_sample.organization_id IS NULL) OR
          (se.organization_id = p_sample.organization_id)
         )
  AND    ((se.resources IS NULL and p_sample.resources IS NULL) OR
         ( (se.resources = p_sample.resources) AND
         ((se.instance_id IS NULL AND p_sample.instance_id IS NULL) OR
          (se.instance_id = p_sample.instance_id) ) )
         )
  AND    se.source   = p_sample.source
  AND    se.disposition IN ('1P', '2I')            -- Pending or In Process
            /* AND    s.delete_mark = 0                            -- Spec is still active
            AND    ((s.spec_status between 400 and 499) OR
	            (s.spec_status between 700 and 799) OR
	            (s.spec_status between 900 and 999)
                   )
            AND    svr.delete_mark = 0                        -- Validity rule is still active
            AND    ((svr.spec_vr_status between 400 and 499) OR
	            (svr.spec_vr_status between 700 and 799) OR
                      (svr.spec_vr_status between 900 and 999)
                   )
            AND    svr.start_date <= SYSDATE
            AND    (svr.end_date is NULL OR svr.end_date >= SYSDATE)
           */
  ORDER BY se.creation_date desc
  ;

 -- bug# 3467845
 -- changed location and whse code where clause.
 -- it was picking sampling event even if sample location was
 -- different than sampling event's location

 -- bug# 3482454
 -- sample with location L1 was getting assigned to existing sample group with "NULL" location
 -- added extra and clause that both locations should be NULL.

CURSOR c_loc_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
               --  gmd_specifications_b s,
               --  gmd_monitoring_spec_vrs svr,
	    gmd_event_spec_disp esd
               --  WHERE  s.spec_id = svr.spec_id
               --  AND    svr.spec_vr_id = esd.spec_vr_id
  WHERE  esd.sampling_event_id = se.sampling_event_id
  AND    se.source   = p_sample.source
  AND    ( (esd.spec_vr_id = p_spec_vr_id) OR
	 (esd.spec_vr_id is  null and p_spec_vr_id is null ))
  AND    ((se.organization_id is NULL) OR
          (se.organization_id = p_sample.organization_id )
         )
  AND    ((se.subinventory IS NULL AND p_sample.subinventory IS NULL) OR
          (se.subinventory = p_sample.subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.locator_id IS NULL) OR
          (se.locator_id = p_sample.locator_id)
         )
  AND    se.disposition IN ('1P', '2I')            -- Pending or In Process
               --  AND    s.delete_mark = 0                            -- Spec is still active
               --  AND    ((s.spec_status between 400 and 499) OR
	              --   (s.spec_status between 700 and 799) OR
	              --  (s.spec_status between 900 and 999)
                      --   )
               --  AND    svr.delete_mark = 0                        -- Validity rule is still active
               --  AND    ((svr.spec_vr_status between 400 and 499) OR
	               --  (svr.spec_vr_status between 700 and 799) OR
	               --  (svr.spec_vr_status between 900 and 999)
                       --  )
               --  AND    svr.start_date <= SYSDATE
               --  AND    (svr.end_date is NULL OR svr.end_date >= SYSDATE)
  ORDER BY se.creation_date desc
  ;


BEGIN
  -- Based on the Sample Source, open appropriate cursor and
  -- try to locate the sampling event record.

  IF p_sample.source = 'I' THEN
    -- Sample Source is "Inventory"
    OPEN c_inv_sampling_event;
    FETCH c_inv_sampling_event INTO x_sampling_event_id;
    IF c_inv_sampling_event%NOTFOUND THEN
      CLOSE c_inv_sampling_event;
      --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_inv_sampling_event;
  ELSIF p_sample.source = 'W' THEN
    -- Sample Source is "WIP"
    OPEN c_wip_sampling_event;
    FETCH c_wip_sampling_event INTO x_sampling_event_id;
    IF c_wip_sampling_event%NOTFOUND THEN
      CLOSE c_wip_sampling_event;
      --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_wip_sampling_event;
  ELSIF p_sample.source = 'C' THEN
    -- Sample Source is "Customer"
    OPEN c_cust_sampling_event;
    FETCH c_cust_sampling_event INTO x_sampling_event_id;
    IF c_cust_sampling_event%NOTFOUND THEN
      CLOSE c_cust_sampling_event;
      --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_cust_sampling_event;
  ELSIF p_sample.source = 'S' THEN
    -- Sample Source is "Supplier"
    OPEN c_supp_sampling_event;
    FETCH c_supp_sampling_event INTO x_sampling_event_id;
    IF c_supp_sampling_event%NOTFOUND THEN
      CLOSE c_supp_sampling_event;
      --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_supp_sampling_event;
   ELSIF p_sample.source = 'L' THEN
        -- Sample Source is "Monitor - Location"
    OPEN c_loc_sampling_event;
    FETCH c_loc_sampling_event INTO x_sampling_event_id;
    IF c_loc_sampling_event%NOTFOUND THEN
      CLOSE c_loc_sampling_event;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_loc_sampling_event;
  ELSIF p_sample.source = 'R' THEN
    -- Sample Source is "Monitor - Resource"
    OPEN c_res_sampling_event;
    FETCH c_res_sampling_event INTO x_sampling_event_id;
    IF c_res_sampling_event%NOTFOUND THEN
      CLOSE c_res_sampling_event;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_res_sampling_event;
ELSE
    --GMD_API_PUB.Log_Message('GMD_SAMPLE_SOURCE_INVALID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- If we reached here then we have found a Sampling event record
  RETURN TRUE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FALSE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    RETURN FALSE;

END sampling_event_with_vr_id;


--Start of comments
--+========================================================================+
--| API Name    : sampling_event_exist                                     |
--| TYPE        : Group                                                    |
--| Notes       : This function return TRUE if there exist a Sampling      |
--|               event with the Spec that matches with the sample         |
--|               supplied, otherwise returns FALSE.                       |
--|                                                                        |
--|               The function also populate OUT variable -                |
--|               sampling_event_id of the GMD_SAMPLING_EVENT record if    |
--|               it is found.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    RLNAGARA LPN ME 7027149 09-May-2008 Added logic for lpn_id in all   |
--|                                     the cursors                        |
--+========================================================================+
-- End of comments

FUNCTION sampling_event_exist
(
  p_sample            IN         gmd_samples%ROWTYPE
, x_sampling_event_id OUT NOCOPY NUMBER
, p_spec_vr_id        IN         NUMBER DEFAULT NULL
) RETURN BOOLEAN IS

  CURSOR c_inv_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
         gmd_specifications_b s,
         gmd_inventory_spec_vrs ivr,
	 gmd_event_spec_disp esd
  WHERE  s.spec_id = ivr.spec_id
  AND    ivr.spec_vr_id = esd.spec_vr_id
  AND    esd.sampling_event_id = se.sampling_event_id
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    se.organization_id = p_sample.organization_id
  AND    s.inventory_item_id = p_sample.inventory_item_id
  AND    ((se.subinventory IS NULL AND p_sample.subinventory IS NULL) OR
          (se.subinventory = p_sample.subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.locator_id IS NULL) OR
          (se.locator_id = p_sample.locator_id)
         )
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.lot_retest_ind IS NULL AND p_sample.lot_retest_ind IS NULL) OR
          (se.lot_retest_ind = p_sample.lot_retest_ind)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  AND    s.delete_mark = 0                         -- Spec is still active
  AND    ((s.spec_status between 400 and 499) OR
	  (s.spec_status between 700 and 799) OR
	  (s.spec_status between 900 and 999)
         )
  AND    ivr.delete_mark = 0                       -- Validity rule is still active
  AND    ((ivr.spec_vr_status between 400 and 499) OR
	  (ivr.spec_vr_status between 700 and 799) OR
	  (ivr.spec_vr_status between 900 and 999)
         )
  AND    ivr.start_date <= SYSDATE
  AND    (ivr.end_date is NULL OR ivr.end_date >= SYSDATE)
  ORDER BY se.creation_date desc
  ;

  -- Bug 4640143: added material detail id
  CURSOR c_wip_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
         gmd_specifications_b s,
         gmd_wip_spec_vrs wvr,
	 gmd_event_spec_disp esd
  WHERE  s.spec_id = wvr.spec_id
  AND    wvr.spec_vr_id = esd.spec_vr_id
  AND    esd.sampling_event_id = se.sampling_event_id
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    se.organization_id = p_sample.organization_id
  AND    s.inventory_item_id = p_sample.inventory_item_id
  AND    ((se.batch_id is NULL AND p_sample.batch_id is NULL) OR
          (se.batch_id = p_sample.batch_id)
         )
  AND    ((se.recipe_id is NULL AND p_sample.recipe_id is NULL) OR
          (se.recipe_id = p_sample.recipe_id)
         )
  AND    ((se.formula_id is NULL AND p_sample.formula_id is NULL) OR
          (se.formula_id = p_sample.formula_id)
         )
  AND    ((se.formulaline_id is NULL AND p_sample.formulaline_id is NULL) OR
          (se.formulaline_id = p_sample.formulaline_id
            AND p_sample.batch_id IS NULL)
         )
  AND    ((se.material_detail_id is NULL AND p_sample.material_detail_id is NULL) OR
          (se.material_detail_id = p_sample.material_detail_id)
         )
  AND    ((se.routing_id is NULL AND p_sample.routing_id is NULL) OR
          (se.routing_id = p_sample.routing_id)
         )
  AND    ((se.step_id is NULL AND p_sample.step_id is NULL) OR
          (se.step_id = p_sample.step_id)
         )
  AND    ((se.oprn_id is NULL AND p_sample.oprn_id is NULL) OR
          (se.oprn_id = p_sample.oprn_id)
         )
  AND    ((se.charge is NULL AND p_sample.charge is NULL) OR
          (se.charge = p_sample.charge)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  AND    s.delete_mark = 0                         -- Spec is still active
  AND    ((s.spec_status between 400 and 499) OR
	  (s.spec_status between 700 and 799) OR
	  (s.spec_status between 900 and 999)
         )
  AND    wvr.delete_mark = 0                       -- Validity rule is still active
  AND    ((wvr.spec_vr_status between 400 and 499) OR
	  (wvr.spec_vr_status between 700 and 799) OR
	  (wvr.spec_vr_status between 900 and 999)
         )
  AND    wvr.start_date <= SYSDATE
  AND    (wvr.end_date is NULL OR wvr.end_date >= SYSDATE)
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR          --Bug# 3736716. Added Lot no.
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.subinventory IS NULL AND p_sample.source_subinventory IS NULL) OR  --Bug# 3736716. Added Source warehouse
          (se.subinventory = p_sample.source_subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.source_locator_id IS NULL) OR  --Bug# 3736716. Added Source Location
          (se.locator_id = p_sample.source_locator_id)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  ORDER BY se.creation_date desc
  ;


  CURSOR c_cust_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
         gmd_specifications_b s,
         gmd_customer_spec_vrs cvr,
	 gmd_event_spec_disp esd
  WHERE  s.spec_id = cvr.spec_id
  AND    cvr.spec_vr_id = esd.spec_vr_id
  AND    esd.sampling_event_id = se.sampling_event_id
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    se.organization_id = p_sample.organization_id
  AND    s.inventory_item_id = p_sample.inventory_item_id
  AND    ((se.cust_id is NULL AND p_sample.cust_id is NULL) OR
          (se.cust_id = p_sample.cust_id)
         )
  AND    ((se.org_id is NULL AND p_sample.org_id is NULL) OR
          (se.org_id = p_sample.org_id)
         )
  AND    ((se.order_id is NULL AND p_sample.order_id is NULL) OR
          (se.order_id = p_sample.order_id)
         )
  AND    ((se.order_line_id is NULL AND p_sample.order_line_id is NULL) OR
          (se.order_line_id = p_sample.order_line_id)
         )
  AND    ((se.ship_to_site_id is NULL AND p_sample.ship_to_site_id is NULL) OR
          (se.ship_to_site_id = p_sample.ship_to_site_id)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  AND    s.delete_mark = 0                         -- Spec is still active
  AND    ((s.spec_status between 400 and 499) OR
	  (s.spec_status between 700 and 799) OR
	  (s.spec_status between 900 and 999)
         )
  AND    cvr.delete_mark = 0                       -- Validity rule is still active
  AND    ((cvr.spec_vr_status between 400 and 499) OR
	  (cvr.spec_vr_status between 700 and 799) OR
	  (cvr.spec_vr_status between 900 and 999)
         )
  AND    cvr.start_date <= SYSDATE
  AND    (cvr.end_date is NULL OR cvr.end_date >= SYSDATE)
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR          --Bug# 3736716. Added Lot no.
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  ORDER BY se.creation_date desc
  ;


  CURSOR c_supp_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
         gmd_specifications_b s,
         gmd_supplier_spec_vrs svr,
	 gmd_event_spec_disp esd
  WHERE  s.spec_id = svr.spec_id
  AND    svr.spec_vr_id = esd.spec_vr_id
  AND    esd.sampling_event_id = se.sampling_event_id
  AND    esd.spec_used_for_lot_attrib_ind = 'Y'
  AND    se.organization_id = p_sample.organization_id
  AND    s.inventory_item_id = p_sample.inventory_item_id
  AND    ((se.supplier_id is NULL AND p_sample.supplier_id is NULL) OR
          (se.supplier_id = p_sample.supplier_id)
         )
  AND    ((se.supplier_site_id is NULL AND p_sample.supplier_site_id is NULL) OR
          (se.supplier_site_id = p_sample.supplier_site_id)
         )
  AND    ((se.po_header_id is NULL AND p_sample.po_header_id is NULL) OR
          (se.po_header_id = p_sample.po_header_id)
         )
  AND    ((se.po_line_id is NULL AND p_sample.po_line_id is NULL) OR
          (se.po_line_id = p_sample.po_line_id)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  AND    s.delete_mark = 0                         -- Spec is still active
  AND    ((s.spec_status between 400 and 499) OR
	  (s.spec_status between 700 and 799) OR
	  (s.spec_status between 900 and 999)
         )
  AND    svr.delete_mark = 0                       -- Validity rule is still active
  AND    ((svr.spec_vr_status between 400 and 499) OR
	  (svr.spec_vr_status between 700 and 799) OR
	  (svr.spec_vr_status between 900 and 999)
         )
  AND    svr.start_date <= SYSDATE
  AND    (svr.end_date is NULL OR svr.end_date >= SYSDATE)
  ORDER BY se.creation_date desc
  ;

  -- Bug 2959466: added source = p_sample.source to where clause because
  --              if se.resource was null then location sampling events were
  --              attached to resource samples.
CURSOR c_res_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
         gmd_specifications_b s,
         gmd_monitoring_spec_vrs svr,
         gmd_event_spec_disp esd
  WHERE  s.spec_id = svr.spec_id
  AND    svr.spec_vr_id = esd.spec_vr_id
  AND    esd.sampling_event_id = se.sampling_event_id
  AND    ((se.organization_id is NULL AND p_sample.organization_id IS NULL) OR
          (se.organization_id = p_sample.organization_id)
         )
  AND    ((se.resources IS NULL and p_sample.resources IS NULL) OR
         ( (se.resources = p_sample.resources) AND
         ((se.instance_id IS NULL AND p_sample.instance_id IS NULL) OR
          (se.instance_id = p_sample.instance_id) ) )
         )
  AND    se.source   = p_sample.source
  AND    se.disposition IN ('1P', '2I')            -- Pending or In Process
  AND    s.delete_mark = 0                            -- Spec is still active
  AND    ((s.spec_status between 400 and 499) OR
	  (s.spec_status between 700 and 799) OR
	  (s.spec_status between 900 and 999)
         )
  AND    svr.delete_mark = 0                        -- Validity rule is still active
  AND    ((svr.spec_vr_status between 400 and 499) OR
	  (svr.spec_vr_status between 700 and 799) OR
  (svr.spec_vr_status between 900 and 999)
         )
  AND    svr.start_date <= SYSDATE
  AND    (svr.end_date is NULL OR svr.end_date >= SYSDATE)
  ORDER BY se.creation_date desc
  ;

-- bug# 3467845
-- changed location and whse code where clause.
-- also added one more condition   se.source   = p_sample.source
-- which was missed out as part of bug fix 2959466.

-- bug# 3482454
 -- sample with location L1 was getting assigned to existing sample group with "NULL" location
 -- added extra and clause that both locations should be NULL.

CURSOR c_loc_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se,
                 gmd_specifications_b s,
                gmd_monitoring_spec_vrs svr,
	    gmd_event_spec_disp esd
  WHERE  s.spec_id = svr.spec_id
  AND    svr.spec_vr_id = esd.spec_vr_id
  AND    esd.sampling_event_id = se.sampling_event_id
  AND    se.source   = p_sample.source
  AND    ((se.organization_id is NULL) OR
          (se.organization_id = p_sample.organization_id )
         )
  AND    ((se.subinventory IS NULL AND p_sample.subinventory IS NULL) OR
          (se.subinventory = p_sample.subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.locator_id IS NULL) OR
          (se.locator_id = p_sample.locator_id)
         )
  AND    se.disposition IN ('1P', '2I')            -- Pending or In Process
  AND    s.delete_mark = 0                            -- Spec is still active
  AND    ((s.spec_status between 400 and 499) OR
	  (s.spec_status between 700 and 799) OR
	  (s.spec_status between 900 and 999)
         )
  AND    svr.delete_mark = 0                        -- Validity rule is still active
  AND    ((svr.spec_vr_status between 400 and 499) OR
	  (svr.spec_vr_status between 700 and 799) OR
	  (svr.spec_vr_status between 900 and 999)
         )
  AND    svr.start_date <= SYSDATE
  AND    (svr.end_date is NULL OR svr.end_date >= SYSDATE)
  ORDER BY se.creation_date desc
  ;


BEGIN
  -- Based on the Sample Source, open appropriate cursor and
  -- try to locate the sampling event record.
  IF (p_spec_vr_id is NOT NULL) THEN
     IF (sampling_event_with_vr_id (  p_sample              => p_sample
                                  , x_sampling_event_id   => x_sampling_event_id
                                  , p_spec_vr_id          => p_spec_vr_id)) THEN
       RETURN TRUE;
     ELSE
       RETURN FALSE;
     END IF;
  ELSE
    IF p_sample.source = 'I' THEN
      -- Sample Source is "Inventory"
      OPEN c_inv_sampling_event;
      FETCH c_inv_sampling_event INTO x_sampling_event_id;
      IF c_inv_sampling_event%NOTFOUND THEN
        CLOSE c_inv_sampling_event;
        --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_inv_sampling_event;
    ELSIF p_sample.source = 'W' THEN
      -- Sample Source is "WIP"
      OPEN c_wip_sampling_event;
      FETCH c_wip_sampling_event INTO x_sampling_event_id;
      IF c_wip_sampling_event%NOTFOUND THEN
        CLOSE c_wip_sampling_event;
        --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_wip_sampling_event;
    ELSIF p_sample.source = 'C' THEN
      -- Sample Source is "Customer"
      OPEN c_cust_sampling_event;
      FETCH c_cust_sampling_event INTO x_sampling_event_id;
      IF c_cust_sampling_event%NOTFOUND THEN
        CLOSE c_cust_sampling_event;
        --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_cust_sampling_event;
    ELSIF p_sample.source = 'S' THEN
      -- Sample Source is "Supplier"
      OPEN c_supp_sampling_event;
      FETCH c_supp_sampling_event INTO x_sampling_event_id;
      IF c_supp_sampling_event%NOTFOUND THEN
        CLOSE c_supp_sampling_event;
        --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_supp_sampling_event;
    ELSIF p_sample.source = 'L' THEN
        -- Sample Source is "Monitor - Location"
       OPEN c_loc_sampling_event;
       FETCH c_loc_sampling_event INTO x_sampling_event_id;
       IF c_loc_sampling_event%NOTFOUND THEN
         CLOSE c_loc_sampling_event;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_loc_sampling_event;
    ELSIF p_sample.source = 'R' THEN
      -- Sample Source is "Monitor - Resource"
      OPEN c_res_sampling_event;
      FETCH c_res_sampling_event INTO x_sampling_event_id;
      IF c_res_sampling_event%NOTFOUND THEN
        CLOSE c_res_sampling_event;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_res_sampling_event;
    ELSE
      --GMD_API_PUB.Log_Message('GMD_SAMPLE_SOURCE_INVALID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- If we reached here then we have found a Sampling event record
    RETURN TRUE;

  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FALSE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    RETURN FALSE;

END sampling_event_exist;


--Start of comments
--+========================================================================+
--| API Name    : sampling_event_exist_wo_spec                             |
--| TYPE        : Group                                                    |
--| Notes       : This function return TRUE if there exist a Sampling      |
--|               event without the Spec that matches with the sample      |
--|               supplied, otherwise returns FALSE.                       |
--|                                                                        |
--|               The function also populate OUT variable -                |
--|               sampling_event_id of the GMD_SAMPLING_EVENT record if    |
--|               it is found.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	30-Aug-2002	Created.                           |
--|    RLNAGARA LPN ME 7027149 09-May-2008 Added logic for lpn_id in all   |
--|                                     the cursors                        |
--+========================================================================+
-- End of comments

FUNCTION sampling_event_exist_wo_spec
(
  p_sample            IN         gmd_samples%ROWTYPE
, x_sampling_event_id OUT NOCOPY NUMBER
) RETURN BOOLEAN IS

  CURSOR c_inv_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se
  WHERE  se.inventory_item_id = p_sample.inventory_item_id
  AND    se.organization_id = p_sample.organization_id
  AND    se.original_spec_vr_id IS NULL
  AND    ((se.subinventory IS NULL AND p_sample.subinventory IS NULL) OR
          (se.subinventory = p_sample.subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.locator_id IS NULL) OR
          (se.locator_id = p_sample.locator_id)
         )
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.lot_retest_ind IS NULL AND p_sample.lot_retest_ind IS NULL) OR
          (se.lot_retest_ind = p_sample.lot_retest_ind)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  ORDER BY se.creation_date desc
  ;

  -- Bug 4640143: added material detail id
  CURSOR c_wip_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se
  WHERE  se.inventory_item_id = p_sample.inventory_item_id
  AND    se.organization_id = p_sample.organization_id
  AND    se.original_spec_vr_id IS NULL
  AND    ((se.batch_id is NULL AND p_sample.batch_id is NULL) OR
          (se.batch_id = p_sample.batch_id)
         )
  AND    ((se.recipe_id is NULL AND p_sample.recipe_id is NULL) OR
          (se.recipe_id = p_sample.recipe_id)
         )
  AND    ((se.formula_id is NULL AND p_sample.formula_id is NULL) OR
          (se.formula_id = p_sample.formula_id)
         )
  AND    ((se.formulaline_id is NULL AND p_sample.formulaline_id is NULL) OR
          (se.formulaline_id = p_sample.formulaline_id
            AND p_sample.batch_id IS NULL)
         )
  AND    ((se.material_detail_id is NULL AND p_sample.material_detail_id is NULL) OR
          (se.material_detail_id = p_sample.material_detail_id)
         )
  AND    ((se.routing_id is NULL AND p_sample.routing_id is NULL) OR
          (se.routing_id = p_sample.routing_id)
         )
  AND    ((se.step_id is NULL AND p_sample.step_id is NULL) OR
          (se.step_id = p_sample.step_id)
         )
  AND    ((se.oprn_id is NULL AND p_sample.oprn_id is NULL) OR
          (se.oprn_id = p_sample.oprn_id)
         )
  AND    ((se.charge is NULL AND p_sample.charge is NULL) OR
          (se.charge = p_sample.charge)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR          --Bug# 3736716. Added lot_number id
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.subinventory IS NULL AND p_sample.source_subinventory IS NULL) OR  --Bug# 3736716. Added Source warehouse
          (se.subinventory = p_sample.source_subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.source_locator_id IS NULL) OR  --Bug# 3736716. Added Source Location
          (se.locator_id = p_sample.source_locator_id)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  ORDER BY se.creation_date desc
  ;


  CURSOR c_cust_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se
  WHERE  se.inventory_item_id = p_sample.inventory_item_id
  AND    se.organization_id = p_sample.organization_id
  AND    se.original_spec_vr_id IS NULL
  AND    ((se.cust_id is NULL AND p_sample.cust_id is NULL) OR
          (se.cust_id = p_sample.cust_id)
         )
  AND    ((se.org_id is NULL AND p_sample.org_id is NULL) OR
          (se.org_id = p_sample.org_id)
         )
  AND    ((se.order_id is NULL AND p_sample.order_id is NULL) OR
          (se.order_id = p_sample.order_id)
         )
  AND    ((se.order_line_id is NULL AND p_sample.order_line_id is NULL) OR
          (se.order_line_id = p_sample.order_line_id)
         )
  AND    ((se.ship_to_site_id is NULL AND p_sample.ship_to_site_id is NULL) OR
          (se.ship_to_site_id = p_sample.ship_to_site_id)
         )
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR          --Bug# 3736716. Added Lot no.
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  ORDER BY se.creation_date desc
  ;

  -- Bug 3143796: added whse, location and lot_id
  CURSOR c_supp_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se
  WHERE  se.inventory_item_id = p_sample.inventory_item_id
  AND    se.organization_id = p_sample.organization_id
  AND    se.original_spec_vr_id IS NULL
  AND    ((se.supplier_id is NULL AND p_sample.supplier_id is NULL) OR
          (se.supplier_id = p_sample.supplier_id)
         )
  AND    ((se.supplier_site_id is NULL AND p_sample.supplier_site_id is NULL) OR
          (se.supplier_site_id = p_sample.supplier_site_id)
         )
  AND    ((se.po_header_id is NULL AND p_sample.po_header_id is NULL) OR
          (se.po_header_id = p_sample.po_header_id)
         )
  AND    ((se.po_line_id is NULL AND p_sample.po_line_id is NULL) OR
          (se.po_line_id = p_sample.po_line_id)
         )
  AND    ((se.subinventory is NULL AND p_sample.subinventory is NULL) OR
          (se.subinventory = p_sample.subinventory)
         )
  AND    ((se.locator_id is NULL AND p_sample.locator_id is NULL) OR
          (se.locator_id = p_sample.locator_id)
         )
  AND    ((se.lot_number IS NULL AND p_sample.lot_number IS NULL) OR
          (se.lot_number = p_sample.lot_number)
         )
  AND    ((se.lpn_id IS NULL AND p_sample.lpn_id IS NULL) OR     --RLNAGARA LPN ME 7027149
          (se.lpn_id = p_sample.lpn_id)
         )
  AND    se.disposition IN ('1P', '2I')  -- Pending or In Process
  ORDER BY se.creation_date desc
  ;

  -- Bug 2959466: added source = p_sample.source to where clause because
  --              if se.resource was null then location sampling events were
  --              attached to resource samples.


CURSOR c_res_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se
  WHERE  ((se.organization_id is NULL AND p_sample.organization_id IS NULL) OR
          (se.organization_id = p_sample.organization_id)
         )
  AND    se.source  =  p_sample.source
  AND    se.original_spec_vr_id IS NULL
  AND    ((se.resources IS NULL AND p_sample.resources IS NULL) OR
         ( (se.resources = p_sample.resources) AND
         ((se.instance_id is NULL AND p_sample.instance_id is NULL) OR
          (se.instance_id = p_sample.instance_id) ) )
         )
  AND    se.disposition IN ('1P', '2I')            -- Pending or In Process
  ORDER BY se.creation_date desc
  ;

  -- bug 3467845
  -- changed whse and location code where clause.

  -- Bug 3401377: added source = p_sample.source to where clause because
  --              if se.location was null then resource sampling events were
  --              attached to location samples.

  -- bug# 3482454
 -- sample with location L1 was getting assigned to existing sample group with "NULL" location
 -- added extra and clause that both locations should be NULL.
 -- also added one more condition   se.original_spec_vr_id IS NULL which was missing here and in
 -- resource sampling event cursor.

  CURSOR c_loc_sampling_event IS
  SELECT se.sampling_event_id
  FROM   gmd_sampling_events se
  WHERE  ((se.organization_id is NULL) OR
          (se.organization_id = p_sample.organization_id )
         )
  AND    se.source  =  p_sample.source
  AND    se.original_spec_vr_id IS NULL
  AND    ((se.subinventory IS NULL AND p_sample.subinventory IS NULL) OR
          (se.subinventory = p_sample.subinventory)
         )
  AND    ((se.locator_id IS NULL AND p_sample.locator_id IS NULL) OR
          (se.locator_id = p_sample.locator_id)
         )
  AND    se.disposition IN ('1P', '2I')            -- Pending or In Process
  ORDER BY se.creation_date desc
  ;



BEGIN
  -- Based on the Sample Source, open appropriate cursor and
  -- try to locate the sampling event record without the Spec.

  IF p_sample.source = 'I' THEN
    -- Sample Source is "Inventory"
    OPEN c_inv_sampling_event;
    FETCH c_inv_sampling_event INTO x_sampling_event_id;
    IF c_inv_sampling_event%NOTFOUND THEN
      CLOSE c_inv_sampling_event;
      --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_inv_sampling_event;
  ELSIF p_sample.source = 'W' THEN
    -- Sample Source is "WIP"
    OPEN c_wip_sampling_event;
    FETCH c_wip_sampling_event INTO x_sampling_event_id;
    IF c_wip_sampling_event%NOTFOUND THEN
      CLOSE c_wip_sampling_event;
      --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_wip_sampling_event;
  ELSIF p_sample.source = 'C' THEN
    -- Sample Source is "Customer"
    OPEN c_cust_sampling_event;
    FETCH c_cust_sampling_event INTO x_sampling_event_id;
    IF c_cust_sampling_event%NOTFOUND THEN
      CLOSE c_cust_sampling_event;
      --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_cust_sampling_event;
  ELSIF p_sample.source = 'S' THEN
    -- Sample Source is "Supplier"
    OPEN c_supp_sampling_event;
    FETCH c_supp_sampling_event INTO x_sampling_event_id;
    IF c_supp_sampling_event%NOTFOUND THEN
      CLOSE c_supp_sampling_event;
      --GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_supp_sampling_event;

     ELSIF p_sample.source = 'L' THEN
        -- Sample Source is "Monitor - Location"
    OPEN c_loc_sampling_event;
    FETCH c_loc_sampling_event INTO x_sampling_event_id;
    IF c_loc_sampling_event%NOTFOUND THEN
      CLOSE c_loc_sampling_event;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_loc_sampling_event;
  ELSIF p_sample.source = 'R' THEN
    -- Sample Source is "Monitor - Resource"
    OPEN c_res_sampling_event;
    FETCH c_res_sampling_event INTO x_sampling_event_id;
    IF c_res_sampling_event%NOTFOUND THEN
      CLOSE c_res_sampling_event;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_res_sampling_event;

  ELSE
    --GMD_API_PUB.Log_Message('GMD_SAMPLE_SOURCE_INVALID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- If we reached here then we have found a Sampling event record
  RETURN TRUE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FALSE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    RETURN FALSE;

END sampling_event_exist_wo_spec;


--Start of comments
--+========================================================================+
--| API Name    : sample_exist                                             |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the Sample with given      |
--|               Sample No.  already exist in the database, FALSE         |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION sample_exist(p_organization_id NUMBER, p_sample_no VARCHAR2)
RETURN BOOLEAN IS

  CURSOR c_sample_no (p_organization_id VARCHAR2, p_sample_no VARCHAR2) IS
  SELECT 1
  FROM   gmd_samples
  WHERE  organization_id = p_organization_id
  AND    sample_no = p_sample_no
  ;

  dummy PLS_INTEGER;

BEGIN

  OPEN c_sample_no(p_organization_id, p_sample_no);
  FETCH c_sample_no INTO dummy;
  IF c_sample_no%FOUND THEN
    CLOSE c_sample_no;
    RETURN TRUE;
  ELSE
    CLOSE c_sample_no;
    RETURN FALSE;
  END IF;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    RETURN TRUE;

END sample_exist;





--Start of comments
--+========================================================================+
--| API Name    : validate_sample                                            |
--| TYPE        : Group                                                      |
--| Notes       : This procedure validates all the fields of a sample.       |
--|               This procedure can be                                      |
--|               called from FORM or API and the caller need                |
--|               to specify this in p_called_from parameter                 |
--|               while calling this procedure. Based on where               |
--|               it is called from certain validations will                 |
--|               either be performed or skipped.                            |
--|                                                                          |
--|               If everything is fine then OUT parameter                   |
--|               x_return_status is set to 'S' else appropriate             |
--|               error message is put on the stack and error                |
--|               is returned.                                               |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	26-Jul-2002	Created.                             |
--|    Susan Feinstein  Bug 4165704: updated for inventory convergence       |
--|  M. Grosser 03-May-2006  Bug 5115015 - Modified procedure validate_sample|
--|             to not validate sample number when automatic sample number   |
--|             creation is in effect so that the number can be retrieved    |
--|             AFTER the sample has passed validation.  Sample numbers were |
--|             being lost.                                                  |
--|    PLOWE LPN ME 7027149 15-May-2008 support fot LPN in group api         |
--+=======================================================================++=+
-- End of comments


PROCEDURE validate_sample
(
  p_sample        IN         gmd_samples%ROWTYPE
, p_called_from   IN         VARCHAR2
, p_operation     IN         VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
) IS

  Cursor fetch_mtl_system_items IS
   SELECT primary_uom_code
   FROM  mtl_system_items_b
   WHERE inventory_item_id = p_sample.inventory_item_id
     AND organization_id   = p_sample.organization_id;

  -- Local Variables
  l_return_status                VARCHAR2(1);
  dummy                          NUMBER;

    --l_item_mst                     MTL_SYSTEM_ITEMS_B_KFV%ROWTYPE;
    --l_in_item_mst                  MTL_SYSTEM_ITEMS_B_KFV%ROWTYPE;
  l_sampling_plan                GMD_SAMPLING_PLANS%ROWTYPE;
  l_primary_uom_code             VARCHAR2(3);
  from_name                      VARCHAR2(50);
  to_name                        VARCHAR2(50);
  l_trans_qty2                   NUMBER;

  --  M. Grosser 03-May-2006  Bug 5115015 - Modified procedure validate_sample
  --             to not validate sample number when automatic sample number
  --             creation is in effect so that the number can be retrieved
  --             AFTER the sample has passed validation.  Sample numbers were
  --             being lost.
  --
  quality_config                 GMD_QUALITY_CONFIG%ROWTYPE;
  found                          BOOLEAN;

  -- Exceptions
  e_smpl_plan_fetch_error        EXCEPTION;
  e_error_fetch_item             EXCEPTION;

BEGIN
gmd_debug.Log_Initialize('ValidateSample');
  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Entered Procedure VALIDATE SAMPLES');
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF (l_debug = 'Y') THEN
    	    gmd_debug.put_line('called_from =  ' || p_called_from);
     END IF;
  IF (p_called_from = 'API') THEN
    -- Check for NULLs and Valid Foreign Keys in the input parameter
      IF (l_debug = 'Y') THEN
    	    gmd_debug.put_line('calling  check_for_null_and_fks_in_smpl ');
   	  END IF;

    check_for_null_and_fks_in_smpl
      (
        p_sample        => p_sample
      , x_return_status => l_return_status
      );
    -- No need if called from FORM since it is already
    -- done in the form

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      -- Message is alrady logged by check_for_null procedure
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      -- Message is alrady logged by check_for_null procedure
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Perform all other business validations.

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Starting check for duplicate sample number:');
  END IF;

  --  M. Grosser 03-May-2006  Bug 5115015 - Modified procedure validate_sample
  --             to not validate sample number when automatic sample number
  --             creation is in effect so that the number can be retrieved
  --             AFTER the sample has passed validation.  Sample numbers were
  --             being lost.
  --
  GMD_QUALITY_PARAMETERS_GRP.get_quality_parameters(
                       p_organization_id    => p_sample.organization_id
	               , x_quality_parameters => quality_config
                       , x_return_status      => x_return_status
                       , x_orgn_found         => found );

  IF NOT(found) OR (x_return_status <> 'S') THEN
       GMD_API_PUB.Log_Message('GMD_QM_ORG_PARAMETER');
       RAISE FND_API.G_EXC_ERROR;
  END IF;

    -- Skip if automatic assignmnet type, so sample number can be retrived after
  -- validation
  IF quality_config.sample_assignment_type <> 2 THEN

    -- If inserting a Sample, Sample_No must be unique
    IF sample_exist(p_sample.organization_id, p_sample.sample_no) THEN
      -- Huston, we have a problem...
      GMD_API_PUB.Log_Message('GMD_SAMPLE_EXIST',
                            'ORGN_CODE', p_sample.organization_id,
                            'SAMPLE_NO', p_sample.sample_no);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF; -- Not automatic sample no assignment
  --  M. Grosser 03-May-2006  Bug 5115015 - End of changes

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('Starting uom conversion:');
  END IF;

  -- Sample Quantity UOM must be convertible to Item's UOM
  IF p_sample.sample_type = 'I' THEN
           -- Bug 4165704: got primary uom from mtl_system_items instead of ic_item_mst
           --l_in_item_mst.inventory_item_id := p_sample.inventory_item_id;
           --IF NOT gmivdbl.ic_item_mst_select (l_in_item_mst, l_item_mst) THEN
           --    RAISE e_error_fetch_item;
           --END IF;

     OPEN  fetch_mtl_system_items;
     FETCH fetch_mtl_system_items into l_primary_uom_code;
     CLOSE fetch_mtl_system_items;
  END IF;

    BEGIN
          --  UOM conversion is only needed for Material samples
          --  Bug 4165704: Changed UOM conversion for Inventory Convergence
       IF p_sample.sample_type = 'I'
        AND l_primary_uom_code IS NOT NULL THEN

          l_trans_qty2 := INV_CONVERT. inv_um_convert (
	                               item_id       => p_sample.inventory_item_id,
	                               lot_number    => NULL,
	                               organization_id => p_sample.organization_id,
	                               precision     => 5,     -- decimal point precision
	                               from_quantity => p_sample.sample_qty,
	                               from_unit     => p_sample.sample_qty_uom,
	                               to_unit       => l_primary_uom_code,
	                               from_name     => NULL	,
	                               to_name       => NULL) ;
  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('After uom conversion qty2 ='||l_trans_qty2);
  END IF;

          --GMICUOM.icuomcv(pitem_id => l_item_mst.item_id,
          --          plot_id  => 0,
          --          pcur_qty => p_sample.sample_qty,
          --          pcur_uom => p_sample.sample_qty_uom,
          --          pnew_uom => l_item_mst.item_um,
          --          onew_qty => dummy);
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- The message is already set, just put it on the stack.
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END;

  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('end validate sample');
  END IF;
  -- All systems GO...

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END validate_sample;


--Start of comments
--+========================================================================+
--| API Name    : update_sample_comp_disp                                  |
--| TYPE        : Group                                                    |
--| Notes       : This procedure updates sample or composite disposition   |
--|             depending upon whether sample_id or composite_spec_disp_id |
--|                is passed.                                              |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is returned.                               |
--|              Called_from_results set to Y in Results form.  Update     |
--|               event_spec_disp and sampling_events regardless of        |
--|                number of samples when Results form is changing the     |
--|                sample disposition to In Progress.                      |
--|                                                                        |
--| HISTORY                                                                |
--|    Mahesh Chandak	18-Sep-2002	Created.                           |
--|   Saikiran          19-Jan-2005  Fixed bug# 4951244
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE update_sample_comp_disp
(
  p_update_disp_rec           	IN         UPDATE_DISP_REC
, p_to_disposition		IN         VARCHAR2
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
) IS

l_event_spec_disp_id	NUMBER(15);
l_sampling_event_id	NUMBER(15);
l_last_updated_by	NUMBER;
l_last_update_login	NUMBER;
l_last_update_date	DATE ;
l_position		VARCHAR2(3);
l_compare_sample_disp	VARCHAR2(4);
l_sample_curr_disp      VARCHAR2(4);
req_fields_missing	EXCEPTION;
invalid_parameter	EXCEPTION;
sample_spec_changed	EXCEPTION;
sample_disp_changed	EXCEPTION;
l_active_cnt   		NUMBER(5);
l_req_cnt      		NUMBER(5);
l_curr_event_disp	VARCHAR2(4);
l_max_disposition       VARCHAR2(4);
l_min_disposition       VARCHAR2(4);
l_final_event_disp	VARCHAR2(4);
l_sample_disp_curr_flag VARCHAR2(1);
l_temp_numb		NUMBER;
-- Begin bug 4951244
l_step_id      GMD_SAMPLES.step_id%TYPE;
l_sample_type  GMD_SAMPLES.sample_type%TYPE;
l_source       GMD_SAMPLES.source%TYPE;
return_status  VARCHAR2(20);
l_dummy_cnt    NUMBER  :=0;
l_sg_disposition VARCHAR2(4); -- added for bug 8252179
l_sg_event_id	NUMBER(15); -- added for bug 8252179

l_data         VARCHAR2(2000);
l_batch_organization_id NUMBER;

Cursor cur_sample_details IS
SELECT step_id,organization_id,sample_type,source, sampling_event_id -- added sampling_event_id for bug 8252179
FROM gmd_samples
WHERE sample_id = p_update_disp_rec.sample_id;
-- End bug 4951244

--Bug# 5440347 start
--this cursor is used for single samples
CURSOR cur_auto_complete_bstep IS
SELECT NVL(wip.AUTO_COMPLETE_BATCH_STEP,'N')
FROM GMD_WIP_SPEC_VRS wip,GMD_SAMPLING_EVENTS gse,GMD_SAMPLES gs
WHERE gs.SAMPLE_ID = p_update_disp_rec.sample_id
AND gse.SAMPLING_EVENT_ID = gs.SAMPLING_EVENT_ID
AND wip.SPEC_VR_ID = gse.ORIGINAL_SPEC_VR_ID;

--the below two cursors are used for sample groups
CURSOR cur_sampling_event_details(p_sampling_event_id NUMBER) IS
SELECT step_id,organization_id,sample_type,source , disposition -- added disposition for bug 8252179
FROM gmd_sampling_events
WHERE sampling_event_id = p_sampling_event_id;

CURSOR cur_comp_auto_complete_bstep(p_sampling_event_id NUMBER) IS
SELECT NVL(wip.AUTO_COMPLETE_BATCH_STEP,'N')
FROM GMD_WIP_SPEC_VRS wip,GMD_SAMPLING_EVENTS gse
WHERE gse.SAMPLING_EVENT_ID = p_sampling_event_id
AND wip.SPEC_VR_ID = gse.ORIGINAL_SPEC_VR_ID;

-- -- 8252179 added cursor
CURSOR cur_sampling_event_disp(p_sampling_event_id NUMBER) IS
SELECT disposition
FROM gmd_sampling_events
WHERE sampling_event_id = p_sampling_event_id;
-- end 8252179

l_auto_complete_bstep     VARCHAR2(1) := NULL;
x_message_count           NUMBER;
x_message_list            VARCHAR2(2000);
xx_return_status          VARCHAR2(1);
l_exception_material_tbl  GME_COMMON_PVT.exceptions_tab;
p_batch_step_rec          GME_BATCH_STEPS%ROWTYPE;
x_batch_step_rec          GME_BATCH_STEPS%ROWTYPE;

l_ch_final_disp         VARCHAR2(4); /* Added in Bug No.8679485 */

--Bug# 5440347 end

BEGIN
gmd_debug.Log_Initialize('UPDATE_SAMPLE_COMP_DISP');

    IF (l_debug = 'Y') THEN
			gmd_debug.put_line('Entered Procedure UPDATE_SAMPLE_COMP_DISP');
    END IF;

--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_position := '010' ;

   IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Input Parameters:');
        gmd_debug.put_line('Sample ID: ' || p_update_disp_rec.sample_id);
        gmd_debug.put_line('Composite Spec Disp ID: ' || p_update_disp_rec.composite_spec_disp_id);
        gmd_debug.put_line('Event Spec Disp ID: ' || p_update_disp_rec.event_spec_disp_id);
        gmd_debug.put_line('Change Disp From: ' || p_update_disp_rec.curr_disposition);
        gmd_debug.put_line('Change Disp To: ' || p_to_disposition);
    END IF;

    IF (p_update_disp_rec.sample_id IS NULL AND p_update_disp_rec.composite_spec_disp_id IS NULL) OR (p_to_disposition IS NULL) THEN
    	raise REQ_FIELDS_MISSING;
    END IF;

    IF p_update_disp_rec.sample_id IS NOT NULL AND p_update_disp_rec.composite_spec_disp_id IS NOT NULL THEN
    	raise INVALID_PARAMETER;
    END IF;

    IF (p_update_disp_rec.curr_disposition IS NULL OR p_update_disp_rec.event_spec_disp_id IS NULL) THEN
    	raise REQ_FIELDS_MISSING;
    END IF;

    l_last_updated_by	 :=  FND_GLOBAL.USER_ID ;
    l_last_update_login  :=  FND_GLOBAL.LOGIN_ID ;
    l_last_update_date	 :=  SYSDATE ;


    IF p_update_disp_rec.sample_id IS NOT NULL THEN

        l_sample_curr_disp	 :=  p_update_disp_rec.curr_disposition;
        l_event_spec_disp_id 	 :=  p_update_disp_rec.event_spec_disp_id;

        -- check whether the passed driving spec is current.If not raise error.
	SELECT SPEC_USED_FOR_LOT_ATTRIB_IND ,sampling_event_id,disposition
	INTO   l_sample_disp_curr_flag , l_sampling_event_id , l_curr_event_disp
	FROM   gmd_event_spec_disp
	WHERE  event_spec_disp_id = l_event_spec_disp_id
	FOR UPDATE OF SPEC_USED_FOR_LOT_ATTRIB_IND NOWAIT;

	IF NVL(l_sample_disp_curr_flag,'N') = 'N' THEN
	     RAISE SAMPLE_SPEC_CHANGED;
	END IF;

        -- check whether the sample disposition has changed.if yes raise error
        SELECT disposition INTO l_compare_sample_disp
    	FROM   gmd_sample_spec_disp
    	WHERE  event_spec_disp_id = l_event_spec_disp_id
    	AND    sample_id = p_update_disp_rec.sample_id
    	FOR UPDATE OF disposition NOWAIT ;

    	IF l_compare_sample_disp <> l_sample_curr_disp THEN
    		RAISE SAMPLE_DISP_CHANGED;
    	END IF;

        l_position := '020' ;

    	-- Set the disposition of the sample spec disp
    	UPDATE gmd_sample_spec_disp
    	SET    disposition 		= p_to_disposition,
               last_updated_by  	= l_last_updated_by,
               last_update_date 	= l_last_update_date,
               last_update_login	= l_last_update_login
    	WHERE  event_spec_disp_id 	= l_event_spec_disp_id
    	AND    sample_id 		= p_update_disp_rec.sample_id    ;


        -- Begin bug 4951244
    	OPEN cur_sample_details;
		FETCH cur_sample_details INTO l_step_id, l_batch_organization_id, l_sample_type, l_source, l_sg_event_id;
		CLOSE cur_sample_details;
    	 IF ((l_sample_type = 'I') AND (l_source = 'W' )) THEN
           IF l_step_id IS NOT NULL THEN
/* Added in 8252179 - Start */
           SELECT nvl(sample_active_cnt, 0), nvl(sample_req_cnt, 1) -- peter lowe added this to get counts
            INTO l_active_cnt, l_req_cnt
            FROM gmd_sampling_events
           WHERE sampling_event_id = l_sampling_event_id;
/* Added in 8252179 - End */

             --   only do so if the sample group disposition is in 4A or 5AV  -- 8252179
             IF (p_to_disposition in ('4A', '5AV')) THEN
               --changing the quality status of batch step to 'In Spec'

            OPEN cur_sampling_event_disp(l_sg_event_id);
            FETCH cur_sampling_event_disp
              INTO l_sg_disposition;
            CLOSE cur_sampling_event_disp;

            IF Nvl(p_update_disp_rec.sample_id, 0) <> 0 AND /* Added in 8252179 */
               l_sg_event_id <> 0 AND
               (Nvl(l_active_cnt, 0) = 1 AND Nvl(l_req_cnt, 0) = 1) THEN

               --   only do so if the sample group disposition is in 4A or 5AV  -- 8252179

            --   IF (l_sg_disposition in ('4A', '5AV'))  then              -- if added for  -- 8252179
               			IF (l_debug = 'Y') THEN
                    	 gmd_debug.put_line('Before Calling gme_api_grp.update_step_quality_status(l_step_id, l_batch_organization_id, 6, BATCHSTEP_ID:'||l_step_id);
                 		END IF;
                   	gme_api_grp.update_step_quality_status(l_step_id, l_batch_organization_id, 6, return_status);
               END IF;

               -- Bug# 5440347 start
               IF (return_status <> 'S') THEN
                     FND_MSG_PUB.GET(p_msg_index     => 1,
                                     p_data          => l_data,
                                     p_encoded       => FND_API.G_FALSE,
                                     p_msg_index_out => l_dummy_cnt);
                     x_message_data := substr(x_message_data || l_data,1,2000) ;
               END IF;

               --Get the value of auto_complete_batch_step flag.
               OPEN cur_auto_complete_bstep;
               FETCH cur_auto_complete_bstep INTO l_auto_complete_bstep;
               IF cur_auto_complete_bstep%NOTFOUND THEN
                    l_auto_complete_bstep := 'N';
               END IF;
               CLOSE cur_auto_complete_bstep;

               /*If auto_complete_batch_step flag is checked in the VR which is being used
               then only call the gme API to complete the batch step.*/
               IF l_auto_complete_bstep = 'Y' THEN
                 p_batch_step_rec.batchstep_id := l_step_id;

                 IF (l_debug = 'Y') THEN
                        gmd_debug.put_line('Before Calling Batch Step Completion API for BATCHSTEP_ID:'||l_step_id);
                 END IF;
                 --call the batch step completion API.
                 GME_API_PUB.complete_step(
                           p_api_version            => 2.0
                          ,p_validation_level       => gme_common_pvt.g_max_errors
                          ,p_init_msg_list          => fnd_api.g_false
                          ,p_commit                 => fnd_api.g_false
                          ,x_message_count          => x_message_count
                          ,x_message_list           => x_message_list
                          ,x_return_status          => xx_return_status
                          ,p_batch_step_rec         => p_batch_step_rec
                          ,p_batch_no               => NULL
                          ,p_org_code               => NULL
                          ,p_ignore_exception       => fnd_api.g_false
                          ,p_override_quality       => fnd_api.g_false
                          ,p_validate_flexfields    => fnd_api.g_false
                          ,x_batch_step_rec         => x_batch_step_rec
                          ,x_exception_material_tbl => l_exception_material_tbl);
                 --After returning from the API we are not handling any exceptions. Any exceptions will be written in the Debug Log

                 IF (l_debug = 'Y') THEN
                      gmd_debug.put_line('Returned from Batch Step Completion Call');
                      gmd_debug.put_line('x_return_status = '||xx_return_status);
                      gmd_debug.put_line('x_batch_step_rec.batch_id = '||TO_CHAR(x_batch_step_rec.batch_id));
                      gmd_debug.put_line('x_batch_step_rec.batchstep_id = '||TO_CHAR(x_batch_step_rec.batchstep_id));
                      gmd_debug.put_line('x_batch_step_rec.batchstep_no = '||TO_CHAR(x_batch_step_rec.batchstep_no));
                      gmd_debug.put_line('x_batch_step_rec.actual_start_date = '||TO_CHAR(x_batch_step_rec.actual_start_date,'DD-MON-YYYY HH24:MI:SS'));
                      gmd_debug.put_line('x_batch_step_rec.actual_cmplt_date = '||TO_CHAR(x_batch_step_rec.actual_cmplt_date,'DD-MON-YYYY HH24:MI:SS'));
                      gmd_debug.put_line('x_batch_step_rec.step_status = '||TO_CHAR(x_batch_step_rec.step_status));
                 END IF;
               END IF; --l_auto_complete_bstep = 'Y'
               --Bug# 5440347 end

             ELSIF (p_to_disposition = '6RJ') THEN
               --changing the quality status of batch step to 'Action Required'
               --   only do so if the sample group disposition is 6RJ -- 8252179

           --    IF (l_sg_disposition = '6RJ' )  then              -- added for  -- 8252179

               IF Nvl(p_update_disp_rec.sample_id, 0) <> 0 AND   -- added for  -- 8252179
               l_sg_event_id <> 0 AND
               (Nvl(l_active_cnt, 0) = 1 AND Nvl(l_req_cnt, 0) = 1) THEN
               	 IF (l_debug = 'Y') THEN
                    	 gmd_debug.put_line('Before Calling gme_api_grp.update_step_quality_status(l_step_id, l_batch_organization_id, 5, BATCHSTEP_ID:'||l_step_id);
                 END IF;

               	 gme_api_grp.update_step_quality_status(l_step_id, l_batch_organization_id, 5, return_status);

	             END IF;

	       --Bug# 5440347 start
	       IF (return_status <> 'S') THEN
                     FND_MSG_PUB.GET(p_msg_index     => 1,
                                     p_data          => l_data,
                                     p_encoded       => FND_API.G_FALSE,
                                     p_msg_index_out => l_dummy_cnt);
                     x_message_data := substr(x_message_data || l_data,1,2000) ;
               END IF;
	       --Bug# 5440347 end
             END IF; -- (l_sample_type = 'I') AND (l_source = 'W' )
           END IF; --step id is not null
         END IF;    --test for WIP sample
          -- End bug 4951244


    	-- If sample disposition is changed to "retain" or "cancel" ,
    	-- decrement the sample active count
    	-- also if retain is changed to pending, increment the sample count
    	-- the above condition will happen only thru change disposition form
    	IF (l_sample_curr_disp NOT IN ('0RT','7CN') AND
	    p_to_disposition IN ('0RT','7CN'))
	THEN

    	   UPDATE gmd_sampling_events
           SET  sample_active_cnt  = sample_active_cnt - 1,
            	recomposite_ind    = 'Y',
                last_updated_by  = l_last_updated_by,
                last_update_date = l_last_update_date,
                last_update_login = l_last_update_login
           WHERE  sampling_event_id = l_sampling_event_id ;

        ELSIF (l_sample_curr_disp IN ('0RT','7CN') AND
	       p_to_disposition NOT IN ('0RT','7CN'))
        THEN

           UPDATE gmd_sampling_events
           SET  sample_active_cnt  = sample_active_cnt + 1,
           	recomposite_ind    = 'Y',
                last_updated_by  = l_last_updated_by,
                last_update_date = l_last_update_date,
                last_update_login = l_last_update_login
           WHERE  sampling_event_id = l_sampling_event_id ;
        END IF;

        l_position := '025' ;

        SELECT nvl(sample_active_cnt,0),nvl(sample_req_cnt,1)
     	INTO   l_active_cnt,l_req_cnt
     	FROM   gmd_sampling_events
     	WHERE  sampling_event_id = l_sampling_event_id
     	FOR UPDATE OF disposition NOWAIT ;

     ELSIF p_update_disp_rec.composite_spec_disp_id IS NOT NULL THEN

         l_sample_curr_disp	 :=  p_update_disp_rec.curr_disposition;
         l_event_spec_disp_id 	 :=  p_update_disp_rec.event_spec_disp_id;

         l_position := '030' ;

         -- check whether the passed driving spec is current.If not raise error.
	 SELECT esd.SPEC_USED_FOR_LOT_ATTRIB_IND ,esd.sampling_event_id,csd.disposition
	 INTO   l_sample_disp_curr_flag , l_sampling_event_id ,l_compare_sample_disp
	 FROM   gmd_composite_spec_disp csd , gmd_event_spec_disp   esd
	 WHERE  csd.composite_spec_disp_id = p_update_disp_rec.composite_spec_disp_id
	 AND    esd.event_spec_disp_id = csd.event_spec_disp_id
	 FOR UPDATE OF esd.SPEC_USED_FOR_LOT_ATTRIB_IND , csd.disposition NOWAIT;

	 IF NVL(l_sample_disp_curr_flag,'N') = 'N' THEN
	     RAISE SAMPLE_SPEC_CHANGED;
	 END IF;

         -- check whether the composite sample disposition has changed.if yes raise error
 	 IF l_compare_sample_disp <> l_sample_curr_disp THEN
    		RAISE SAMPLE_DISP_CHANGED;
    	 END IF;

    	 l_position := '035' ;

	 UPDATE gmd_composite_spec_disp
         SET disposition = p_to_disposition
         WHERE  composite_spec_disp_id = p_update_disp_rec.composite_spec_disp_id ;

         SELECT nvl(sample_active_cnt,0),nvl(sample_req_cnt,1)
     	 INTO   l_active_cnt,l_req_cnt
     	 FROM   gmd_sampling_events
     	 WHERE  sampling_event_id = l_sampling_event_id
     	 FOR UPDATE OF disposition NOWAIT ;

         --Bug# 5440347 start
         --Get the sampling event details
         OPEN cur_sampling_event_details(l_sampling_event_id);
         FETCH cur_sampling_event_details INTO l_step_id,l_batch_organization_id,l_sample_type, l_source, l_sg_disposition;
         CLOSE cur_sampling_event_details;

         IF ((l_sample_type = 'I') AND (l_source = 'W') AND l_step_id IS NOT NULL) THEN
           IF (p_to_disposition in ('4A', '5AV'))

            THEN
               --changing the quality status of batch step to 'In Spec'
           --    IF (l_sg_disposition in ('4A', '5AV'))   then             -- added for  -- 8252179
                  IF (l_debug = 'Y') THEN
                     gmd_debug.put_line('Before Calling gme_api_grp.update_step_quality_status(l_step_id, l_batch_organization_id, 6, BATCHSTEP_ID:'||l_step_id);
                 END IF;
                  gme_api_grp.update_step_quality_status(l_step_id, l_batch_organization_id, 6, return_status);   -- 8252179
         --      END IF;
               IF (return_status <> 'S') THEN
                 FND_MSG_PUB.GET(p_msg_index     => 1,
                                 p_data          => l_data,
                                 p_encoded       => FND_API.G_FALSE,
                                 p_msg_index_out => l_dummy_cnt);
                 x_message_data := substr(x_message_data || l_data,1,2000) ;
               END IF;
               --Get the value of auto_complete_batch_step flag.
               OPEN cur_comp_auto_complete_bstep(l_sampling_event_id);
               FETCH cur_comp_auto_complete_bstep INTO l_auto_complete_bstep;
               IF cur_comp_auto_complete_bstep%NOTFOUND THEN
                    l_auto_complete_bstep := 'N';
               END IF;
               CLOSE cur_comp_auto_complete_bstep;
               /*If auto_complete_batch_step flag is checked in the VR which is being used
               then only call the gme API to complete the batch step.*/
               IF l_auto_complete_bstep = 'Y' THEN
                 p_batch_step_rec.batchstep_id := l_step_id;
                 IF (l_debug = 'Y') THEN
                     gmd_debug.put_line('Before Calling Batch Step Completion API for BATCHSTEP_ID:'||l_step_id);
                 END IF;
                 --call the batch step completion API.
                 GME_API_PUB.complete_step(
                           p_api_version            => 2.0
                          ,p_validation_level       => gme_common_pvt.g_max_errors
                          ,p_init_msg_list          => fnd_api.g_false
                          ,p_commit                 => fnd_api.g_false
                          ,x_message_count          => x_message_count
                          ,x_message_list           => x_message_list
                          ,x_return_status          => xx_return_status
                          ,p_batch_step_rec         => p_batch_step_rec
                          ,p_batch_no               => NULL
                          ,p_org_code               => NULL
                          ,p_ignore_exception       => fnd_api.g_false
                          ,p_override_quality       => fnd_api.g_false
                          ,p_validate_flexfields    => fnd_api.g_false
                          ,x_batch_step_rec         => x_batch_step_rec
                          ,x_exception_material_tbl => l_exception_material_tbl);
                 --After returning from the API we are not handling any exceptions. Any exceptions will be written in the Debug Log
                 IF (l_debug = 'Y') THEN
                      gmd_debug.put_line('Returned from Batch Step Completion Call');
                      gmd_debug.put_line('x_return_status = '||xx_return_status);
                      gmd_debug.put_line('x_batch_step_rec.batch_id = '||TO_CHAR(x_batch_step_rec.batch_id));
                      gmd_debug.put_line('x_batch_step_rec.batchstep_id = '||TO_CHAR(x_batch_step_rec.batchstep_id));
                      gmd_debug.put_line('x_batch_step_rec.batchstep_no = '||TO_CHAR(x_batch_step_rec.batchstep_no));
                      gmd_debug.put_line('x_batch_step_rec.actual_start_date = '||TO_CHAR(x_batch_step_rec.actual_start_date,'DD-MON-YYYY HH24:MI:SS'));
                      gmd_debug.put_line('x_batch_step_rec.actual_cmplt_date = '||TO_CHAR(x_batch_step_rec.actual_cmplt_date,'DD-MON-YYYY HH24:MI:SS'));
                      gmd_debug.put_line('x_batch_step_rec.step_status = '||TO_CHAR(x_batch_step_rec.step_status));
                 END IF;
               END IF; --l_auto_complete_bstep = 'Y'
           ELSIF (p_to_disposition = '6RJ') THEN

               --changing the quality status of batch step to 'Action Required'

               --   only do so if the sample group disposition is 6RJ -- 8252179

         --      IF (l_sg_disposition = '6RJ' )  then              -- added IF  for  -- 8252179
               	 IF (l_debug = 'Y') THEN
                    	 gmd_debug.put_line('Before Calling gme_api_grp.update_step_quality_status(l_step_id, l_batch_organization_id, 5, BATCHSTEP_ID:'||l_step_id);
                 END IF;

               	gme_api_grp.update_step_quality_status(l_step_id, l_batch_organization_id, 5, return_status);
       --       END IF;

                IF (return_status <> 'S') THEN
                  FND_MSG_PUB.GET(p_msg_index     => 1,
                                 p_data          => l_data,
                                 p_encoded       => FND_API.G_FALSE,
                                 p_msg_index_out => l_dummy_cnt);
                  x_message_data := substr(x_message_data || l_data,1,2000) ;
                END IF;
           END IF;  --p_to_disposition in ('4A', '5AV')
         END IF;    --test for WIP sample with step
         --Bug# 5440347 end

     END IF;

    -- If calling from composite result form,update the event disposition to
    -- whatever passed.
    l_position := '040' ;

    IF p_update_disp_rec.composite_spec_disp_id IS NOT NULL THEN
        l_final_event_disp := p_to_disposition ;
    ELSE
        IF (l_debug = 'Y') THEN
	    gmd_debug.put_line('l_active_cnt=>'||l_active_cnt);
	    gmd_debug.put_line('l_req_cnt=>'||l_req_cnt);
	    gmd_debug.put_line('to_disp=>'||p_to_disposition);
	    gmd_debug.put_line('curr_event_disp=>'||l_curr_event_disp);
        END IF;

        -- if there is no active sample,update the event to 'Pending'
        -- active count can't be negative in real scenario.Just to be on safe side.
        IF  l_active_cnt <= 0 THEN
            l_final_event_disp := '1P';
        ELSIF (l_active_cnt = 1 AND l_req_cnt = 1) THEN
	    l_position := '050' ;
	    IF l_curr_event_disp in ('4A','5AV','6RJ')
	    THEN
	        IF l_curr_event_disp <> p_to_disposition THEN /* Added IF clause in Bug No.8679485 */
            l_ch_final_disp := NULL;
            l_ch_final_disp := p_to_disposition;
          ELSE
            IF (l_debug = 'Y') THEN
              gmd_debug.put_line('l_curr_event_disp in (4A,5AV,6RJ )so return  -  l_curr_event_disp  : ' ||
                                 l_curr_event_disp);
            END IF;

            RETURN;
          END IF;
	    END IF;

            IF (l_debug = 'Y') THEN
	        		gmd_debug.put_line('Sampling Event ID: '||l_sampling_event_id);
            END IF;
-- SG disp formalised here

            -- get MAXIMUM sample disposition from all the samples for that event.
	    SELECT MAX(ssd.disposition) INTO l_max_disposition
	    FROM   gmd_event_spec_disp esd, gmd_sample_spec_disp ssd
	    WHERE  esd.event_spec_disp_id = l_event_spec_disp_id
            AND    esd.event_spec_disp_id = ssd.event_spec_disp_id
            AND    esd.delete_mark = 0
            AND    ssd.delete_mark = 0
	    AND    ssd.disposition NOT IN ('0RT', '7CN');

            IF (l_debug = 'Y') THEN
	        			gmd_debug.put_line('max disp=>'||l_max_disposition);
            END IF;

            -- there could be a scenario where one has 2 samples.S1 with disp = '4A'
            -- and S2 with disp = 'In progess'.Now user tries to change the disp
            -- of S2(current sample in this case) to Cancel/Retain, then don't
            -- update the event spec to Approve.Make it Complete.
	    IF p_to_disposition IN ('0RT','7CN') AND l_max_disposition in ('4A','5AV','6RJ') THEN
	        l_final_event_disp := '3C';
           ELSIF l_ch_final_disp IS NOT NULL THEN /* Added ELSEIF clause in Bug No.8679485 */
                l_final_event_disp := l_ch_final_disp;
	    ELSE
  	        l_final_event_disp := l_max_disposition;
	    END IF;
            IF (l_debug = 'Y') THEN
	        gmd_debug.put_line('FInal disp=>'||l_final_event_disp);
            END IF;
        ELSE
            -- either required count > 1 or active count > 1
            -- if event is already approved/rejected , don't update the event .
            l_position := '060' ;

	    IF l_curr_event_disp in ('4A','5AV','6RJ') THEN
	       RETURN;
	    END IF;

	    SELECT MAX(ssd.disposition),MIN(ssd.disposition)
	    INTO l_max_disposition,l_min_disposition
	    FROM gmd_event_spec_disp esd, gmd_sample_spec_disp ssd
	    WHERE
		esd.event_spec_disp_id = l_event_spec_disp_id
            AND esd.event_spec_disp_id = ssd.event_spec_disp_id
            AND esd.delete_mark = 0
            AND ssd.delete_mark = 0
	    AND ssd.disposition NOT IN ('0RT','7CN');

	    l_position := '070' ;

	    IF l_active_cnt < l_req_cnt THEN
	        IF l_max_disposition = '1P' THEN
 		   l_final_event_disp := '1P';
  	        ELSE
	           l_final_event_disp := '2I';
  	        END IF;
	    ELSE
	        IF (l_min_disposition = '1P' AND l_max_disposition = '1P') THEN
                    l_final_event_disp := '1P';
                ELSIF (l_min_disposition IN ('3C','4A','5AV','6RJ'))
		   AND (l_max_disposition IN ('3C','4A','5AV','6RJ')) THEN
		      l_final_event_disp := '3C';
	        ELSE
		    l_final_event_disp := '2I';
	        END IF;
	    END IF;
         END IF; -- end of l_active_cnt <= 0
     END IF;

     l_position := '080' ;

     IF l_final_event_disp IS NULL THEN
       l_final_event_disp := '1P';
     END IF;

     IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Final disp last =>'||l_final_event_disp);
          gmd_debug.put_line('updating the disposition of the Sampling Event (SG)  to =>'||l_final_event_disp);
          gmd_debug.put_line('for l_sampling_event_id  =>'||l_sampling_event_id);
     END IF;

     -- Set the disposition of the Event spec disp
     UPDATE gmd_event_spec_disp
     SET    disposition       = l_final_event_disp,
            last_updated_by   = l_last_updated_by,
            last_update_date  = l_last_update_date,
            last_update_login = l_last_update_login
     WHERE  event_spec_disp_id = l_event_spec_disp_id     ;

     -- Set the disposition of the Sampling Event
     UPDATE gmd_sampling_events
     SET    disposition      = l_final_event_disp,
            last_updated_by  = l_last_updated_by,
            last_update_date = l_last_update_date,
            last_update_login = l_last_update_login
     WHERE  sampling_event_id = l_sampling_event_id ;


EXCEPTION WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SAMPLES_GRP.UPDATE_SAMPLE_COMP_DISP');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_PARAMETER THEN
   gmd_api_pub.log_message('GMD_INVALID_PARAM','PACKAGE','GMD_SAMPLES_GRP.UPDATE_SAMPLE_COMP_DISP');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN SAMPLE_SPEC_CHANGED THEN
   gmd_api_pub.log_message('GMD_SAMPLE_SPEC_CHANGED','PACKAGE','GMD_SAMPLES_GRP.UPDATE_SAMPLE_COMP_DISP');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN SAMPLE_DISP_CHANGED THEN
   gmd_api_pub.log_message('GMD_SMPL_DISP_CHANGE','PACKAGE','GMD_SAMPLES_GRP.UPDATE_SAMPLE_COMP_DISP');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN OTHERS THEN
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SAMPLES_GRP.UPDATE_SAMPLE_COMP_DISP','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END update_sample_comp_disp ;


--Start of comments
--+========================================================================+
--| API Name    : update_change_disp_table
--| TYPE        : Group                                                    |
--| Notes       : This procedure creates records in change disposition     |
--|               tables.  If everything is fine then OUT parameter        |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is returned.                               |
--|                                                                        |
--| HISTORY                                                                |
--|    S. Feinstein     05-MAY-2005     Created for Inventory Convergence  |
--+========================================================================+
-- End of comments
PROCEDURE update_change_disp_table
(
  p_update_change_disp_rec      IN         UPDATE_CHANGE_DISP_REC
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
) IS
--xxx
   CURSOR Cur_get_seq IS
      SELECT gmd_qc_change_disp_id_s.NEXTVAL
      FROM DUAL;

   CURSOR Cur_get_lot IS
       SELECT lot_number
       FROM  MTL_LOT_NUMBERS
       WHERE  inventory_item_id  =  p_update_change_disp_rec.inventory_item_id
	 AND  organization_id    =  p_update_change_disp_rec.organization_id
	 AND  parent_lot_number  =  p_update_change_disp_rec.parent_lot_number ;

   l_change_disp_id       NUMBER;
   l_lot_number           VARCHAR2(80);

	BEGIN
	    --  Initialize API return status to success
	  x_return_status := FND_API.G_RET_STS_SUCCESS;

	  OPEN  Cur_get_seq;
	  FETCH Cur_get_seq INTO l_change_disp_id;
	  CLOSE Cur_get_seq;

	  IF (l_debug = 'Y') THEN
	     gmd_debug.put_line('In Procedure update_change_disp_table and input parameters = ');
	     gmd_debug.put_line('  change_disp_id: ' ||  l_change_disp_id);
	     gmd_debug.put_line('  organization ID: ' || p_update_change_disp_rec.organization_id);
	     gmd_debug.put_line('  Sample ID: ' || p_update_change_disp_rec.sample_id);
	     gmd_debug.put_line('  sampling_event_id : ' || p_update_change_disp_rec.sampling_event_id);
	     gmd_debug.put_line('  disposition_from : ' || p_update_change_disp_rec.disposition_from);
	     gmd_debug.put_line('  disposition_to : ' || p_update_change_disp_rec.disposition_to);
	     gmd_debug.put_line('  parent lot number : ' ||  p_update_change_disp_rec.parent_lot_number);
	     gmd_debug.put_line('  lot number: ' ||  p_update_change_disp_rec.lot_number);
	     gmd_debug.put_line('  lot status id: ' ||  p_update_change_disp_rec.to_lot_status_id);
	     gmd_debug.put_line('  lot status id: ' ||  p_update_change_disp_rec.from_lot_status_id);
	     gmd_debug.put_line('  grade code: ' ||  p_update_change_disp_rec.to_grade_code);
	     gmd_debug.put_line('  grade code: ' ||  p_update_change_disp_rec.from_grade_code);
	     gmd_debug.put_line('  hold date: ' ||  p_update_change_disp_rec.hold_date);
	     gmd_debug.put_line('  reason id : ' ||  p_update_change_disp_rec.reason_id);
	  END IF;

	  INSERT INTO GMD_CHANGE_DISPOSITION
	   (
	       CHANGE_DISP_ID
	      ,ORGANIZATION_ID
	      ,SAMPLE_ID
	      ,SAMPLING_EVENT_ID
	      ,DISPOSITION_FROM
	      ,DISPOSITION_TO
	      ,PARENT_LOT_NUMBER
	      ,LOT_NUMBER
	      ,LOT_STATUS_ID
	      ,GRADE_CODE
	      ,REASON_ID
	      ,HOLD_DATE
	      ,CREATION_DATE
	      ,CREATED_BY
	      ,LAST_UPDATED_BY
	      ,LAST_UPDATE_DATE
	      ,LAST_UPDATE_LOGIN
	   )
	   VALUES
	   (
	       l_change_disp_id
	      ,p_update_change_disp_rec.ORGANIZATION_ID
	      ,p_update_change_disp_rec.SAMPLE_ID
	      ,p_update_change_disp_rec.SAMPLING_EVENT_ID
	      ,p_update_change_disp_rec.DISPOSITION_FROM
	      ,p_update_change_disp_rec.DISPOSITION_TO
	      ,p_update_change_disp_rec.PARENT_LOT_NUMBER
	      ,p_update_change_disp_rec.LOT_NUMBER
	      ,p_update_change_disp_rec.TO_LOT_STATUS_ID
	      ,p_update_change_disp_rec.TO_GRADE_CODE
	      ,p_update_change_disp_rec.REASON_ID
	      ,p_update_change_disp_rec.HOLD_DATE
	      ,SYSDATE
	      ,fnd_global.user_id
	      ,fnd_global.user_id
	      ,SYSDATE
	      ,fnd_global.user_id
	   );


	   IF SQL%NOTFOUND THEN
	      gmd_api_pub.log_message('GMD_QM_CHANGE_DISP_ERR','PACKAGE','GMD_SAMPLES_GRP.UPDATE_CHANGE_DISP_TABLE');
	      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
	      x_return_status := FND_API.G_RET_STS_ERROR ;
	   END IF;     -- SQL%NOTFOUND THEN



	   IF (p_update_change_disp_rec.LOT_NUMBER IS NOT NULL) THEN
	       -- just one lot updated
	       INSERT INTO GMD_CHANGE_LOTS
		(
		    CHANGE_DISP_ID
		   ,LOT_NUMBER
		   ,FROM_LOT_STATUS_ID
		   ,FROM_GRADE_CODE
		   ,CREATION_DATE
		   ,CREATED_BY
		   ,LAST_UPDATED_BY
		   ,LAST_UPDATE_DATE
		   ,LAST_UPDATE_LOGIN
		)
		VALUES
		(
		    l_change_disp_id
		   ,p_update_change_disp_rec.LOT_NUMBER
		   ,p_update_change_disp_rec.FROM_LOT_STATUS_ID
		   ,p_update_change_disp_rec.FROM_GRADE_CODE
		   ,SYSDATE
		   ,fnd_global.user_id
		   ,fnd_global.user_id
		   ,SYSDATE
		   ,fnd_global.user_id
		);
	   ELSIF (p_update_change_disp_rec.PARENT_LOT_NUMBER IS NOT NULL) THEN

			  OPEN cur_get_lot;

		  LOOP
		    FETCH cur_get_lot into l_lot_number ;
		    EXIT WHEN cur_get_lot%NOTFOUND ; -- exit when last row is fetched

                    INSERT INTO GMD_CHANGE_LOTS
                     (
                         CHANGE_DISP_ID
                        ,LOT_NUMBER
                        ,FROM_LOT_STATUS_ID
                        ,FROM_GRADE_CODE
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATED_BY
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATE_LOGIN
                     )
                     VALUES
                     (
                         l_change_disp_id
                        ,L_LOT_NUMBER
                        ,p_update_change_disp_rec.FROM_LOT_STATUS_ID
                        ,p_update_change_disp_rec.FROM_GRADE_CODE
                        ,SYSDATE
                        ,fnd_global.user_id
                        ,fnd_global.user_id
                        ,SYSDATE
                        ,fnd_global.user_id
                     );


		  END LOOP;
		  CLOSE cur_get_lot;

   END IF;   -- (p_update_change_disp_rec.LOT_NUMBER IS NOT NULL)

   IF SQL%NOTFOUND THEN
      gmd_api_pub.log_message('GMD_QM_CHANGE_LOT_ERR','PACKAGE','GMD_SAMPLES_GRP.UPDATE_CHANGE_DISP_TABLE');
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_ERROR ;
   END IF;     -- SQL%NOTFOUND THEN

END update_change_disp_table;


--Start of comments
--+========================================================================+
--| API Name    : update_lot_grade_batch                                   |
--| TYPE        : Group                                                    |
--| Notes       : This procedure updates lot status and/or grade           |
--|               and/or batch step status				   |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is returned.                               |
--|                                                                        |
--|                                                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    Mahesh Chandak	18-Sep-2002	Created.                                 |
--|                                                                        |
--|    S. Feinstein     28-Apr-2005     Changes for Inventory Convergence  |
--|                                     1. added Update Child lots         |
--|                                     2. calls to GMIPAPI changed        |
--|                                     3. cursor c_ic_lots modified       |
--|                                     4. added parent_lot_number         |
--|    Peter Lowe       02-Mar-2006     Bug 50061731.			                 |
--|    If the sample_id is not null then fetching the values of            |
--|     subinventory (whse_code)					                                 |
--|    and location of the sample and while changing the status of the lot,|
--|    using these subinventory and location also as part of the criteria. |
--|    Peter Lowe       22-Nov-2009    Bug 91432301.			                 |
--|               |
--|     					                                                         |
--|
--|
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE update_lot_grade_batch  -- palpal
(
  p_sample_id			IN         NUMBER  DEFAULT NULL
, p_composite_spec_disp_id  	IN         NUMBER  DEFAULT NULL
, p_to_lot_status_id	  	IN         NUMBER
, p_from_lot_status_id	  	IN         NUMBER
, p_to_grade_code		IN         VARCHAR2
, p_from_grade_code		IN         VARCHAR2    DEFAULT NULL
, p_to_qc_status		IN         NUMBER
, p_reason_id			IN         NUMBER
, p_hold_date                   IN         DATE        DEFAULT SYSDATE
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
) IS

l_position		VARCHAR2(3) := '010';
l_grade			VARCHAR2(150);
l_sampling_event_id	NUMBER(15);

   -- taken out with bug 4165704: inventory convergence
   -- l_ic_jrnl_mst_row  ic_jrnl_mst%ROWTYPE;
   -- l_ic_adjs_jnl_row1 ic_adjs_jnl%ROWTYPE;
   -- l_ic_adjs_jnl_row2 ic_adjs_jnl%ROWTYPE;
   -- l_count           	NUMBER  := 0;
   -- l_loop_cnt           	NUMBER  :=0;
   -- l_dummy_cnt          	NUMBER  :=0;
   -- l_trans_rec_grade    	GMIGAPI.qty_rec_typ;   --bug 4165704
   -- l_trans_rec_lot_status  GMIGAPI.qty_rec_typ;  --bug 4165704
   -- l_tempb		     	BOOLEAN;

l_data               	VARCHAR2(2000);
l_parent_lot_number	MTL_LOT_NUMBERS.parent_lot_number%TYPE;
l_lot_number	     	MTL_LOT_NUMBERS.lot_number%TYPE;
l_inventory_item_number	VARCHAR2(2000);
l_inventory_item_id	MTL_SYSTEM_ITEMS.inventory_item_id%TYPE;
l_organization_id	NUMBER;
l_batch_id		NUMBER(15);
l_step_no		NUMBER(10);
l_curr_qc_status	NUMBER(2);
l_rowid			ROWID;
l_locator_id        number;    -- 50061731
l_subinventory      varchar2(10); -- 50061731

l_batch_status           NUMBER ; -- Bug # 4619570

l_default_status_id      NUMBER; -- Bug 91432301
l_onhand_status_id       NUMBER;  -- Bug 91432301
l_onhand_reason_id       NUMBER;  -- Bug 91432301




req_fields_missing	EXCEPTION;
invalid_sample		EXCEPTION;
invalid_qc_status	EXCEPTION;
sample_disp_changed	EXCEPTION;

TYPE GET_CURR_GRADE_REC_TYP IS RECORD (
      lot_number VARCHAR2(80),
      grade_code VARCHAR2(150)
     );

TYPE cr_get_curr_grade IS REF CURSOR RETURN GET_CURR_GRADE_REC_TYP;

get_curr_grade_cv cr_get_curr_grade;  -- declare cursor variable
get_curr_grade_rec	GET_CURR_GRADE_REC_TYP ;

  -- Bug 4165704: Changed record type for new lot_status transaction
  --TYPE GET_CURR_LOT_STATUS_REC_TYP IS RECORD (
  --    lot_number   VARCHAR2(80)
  --   ,subinventory VARCHAR2(10)
  --   ,locator_id   NUMBER
  --   );
TYPE GET_CURR_LOT_STATUS_REC_TYP IS RECORD (
      lot_number          VARCHAR2(80)
     ,status_id           NUMBER
     );

TYPE cr_get_curr_lot_status IS REF CURSOR RETURN GET_CURR_LOT_STATUS_REC_TYP;

get_curr_lot_status_cv 		cr_get_curr_lot_status;  -- declare cursor variable
get_curr_lot_status_rec		GET_CURR_LOT_STATUS_REC_TYP ;

 -- Manish Gupta B3143795, Update hold date
 -- Bug 4165704: changed so that cursor is going against correct table
CURSOR c_mtl_lot_numbers(p_parent_lot_number IN VARCHAR2,
                         p_organization_id   IN NUMBER,
                         p_inventory_item_id IN NUMBER) IS
   SELECT hold_date
   FROM   mtl_lot_numbers
   WHERE  parent_lot_number = p_parent_lot_number
     AND  inventory_item_id = p_inventory_item_id
     AND  organization_id   = p_organization_id;

-- Bug 4165704: changed so that cursor is going against correct table
CURSOR c_lots (p_parent_lot_number IN VARCHAR2,
               p_organization_id IN NUMBER,
               p_inventory_item_id IN NUMBER) IS
   SELECT 1
   FROM mtl_lot_numbers
   WHERE parent_lot_number = p_parent_lot_number
     AND organization_id   = p_organization_id
     AND inventory_item_id = p_inventory_item_id;

CURSOR c_lot_status (
         p_lot_number IN VARCHAR2,
         p_organization_id IN NUMBER,
         p_inventory_item_id IN NUMBER) IS
   SELECT lot_number,
          status_id
   FROM  MTL_LOT_NUMBERS
  WHERE  inventory_item_id  =  l_inventory_item_id
   AND  organization_id    =  l_organization_id
   AND  lot_number  =  l_lot_number ;

CURSOR get_default_status_id IS  -- 91432301
    SELECT default_status_id
    FROM mtl_parameters
    WHERE organization_id = l_organization_id;

record_lock        EXCEPTION ;
pragma exception_init(record_lock,-00054) ;

  -- Manish Gupta B3143795, Update hold date

  --Bug# 5440347 start
  --this cursor is used for single samples
  CURSOR cur_auto_complete_bstep_smpl IS
  SELECT NVL(wip.AUTO_COMPLETE_BATCH_STEP,'N')
  FROM GMD_WIP_SPEC_VRS wip,GMD_SAMPLING_EVENTS gse,GMD_SAMPLES gs
  WHERE gs.SAMPLE_ID = p_sample_id
  AND gse.SAMPLING_EVENT_ID = gs.SAMPLING_EVENT_ID
  AND wip.SPEC_VR_ID = gse.ORIGINAL_SPEC_VR_ID;

  CURSOR cur_auto_complete_bstep_comp IS
  SELECT NVL(wip.AUTO_COMPLETE_BATCH_STEP,'N')
  FROM GMD_WIP_SPEC_VRS wip,GMD_SAMPLING_EVENTS gse,
       GMD_EVENT_SPEC_DISP esd, GMD_COMPOSITE_SPEC_DISP csd
  WHERE csd.COMPOSITE_SPEC_DISP_ID = p_composite_spec_disp_id
  AND esd.EVENT_SPEC_DISP_ID = csd.EVENT_SPEC_DISP_ID
  AND gse.SAMPLING_EVENT_ID = esd.SAMPLING_EVENT_ID
  AND wip.SPEC_VR_ID = gse.ORIGINAL_SPEC_VR_ID;

  l_bstep_id                NUMBER;
  l_auto_complete_bstep     VARCHAR2(1) := NULL;
  x_message_count           NUMBER;
  x_message_list            VARCHAR2(2000);
  xx_return_status          VARCHAR2(1);
  l_exception_material_tbl  GME_COMMON_PVT.exceptions_tab;
  p_batch_step_rec          GME_BATCH_STEPS%ROWTYPE;
  x_batch_step_rec          GME_BATCH_STEPS%ROWTYPE;
  l_step_status             NUMBER;

  --Bug# 5440347 end


BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   gmd_debug.Log_Initialize('Update_lot_grade_batch');
   IF (l_debug = 'Y') THEN
     gmd_debug.put_line('Entering update_lot_grade_batch p_sample_id :'||p_sample_id);
   END IF;

    IF (p_sample_id IS NULL AND p_composite_spec_disp_id IS NULL)
      OR (p_to_lot_status_id IS NULL AND p_to_grade_code IS NULL AND p_to_qc_status IS NULL) THEN
    	RAISE REQ_FIELDS_MISSING;
    END IF;

       -- Bug 4165704: reason code is no longer required after convergence
       --   IF (p_to_lot_status IS NOT NULL OR p_to_grade_code IS NOT NULL) AND (p_reason_code IS NULL) THEN
       --	RAISE REQ_FIELDS_MISSING;
       --   END IF;

    IF p_to_qc_status IS NOT NULL AND p_to_qc_status NOT IN (5,6) THEN
    	RAISE INVALID_QC_STATUS;
    END IF;

    IF p_sample_id IS NOT NULL THEN
         -- BUG 4165704: changed ic_item_mst to mtl_system_items, and updated field names for inventory convergence
    	SELECT gs.organization_id ,
               gs.inventory_item_id,
               iim.concatenated_segments,
               gs.parent_lot_number,
               gs.lot_number,
               gs.batch_id,
               gs.step_no,
               gs.locator_id, -- 50061731
               gs.subinventory -- 50061731
    	INTO   l_organization_id,
               l_inventory_item_id,
               l_inventory_item_number,
               l_parent_lot_number,
               l_lot_number,
               l_batch_id,
               l_step_no,
               l_locator_id, -- 50061731
               l_subinventory -- 50061731
    	FROM   GMD_SAMPLES     gs,
               MTL_SYSTEM_ITEMS_b_kfv iim
    	WHERE  gs.sample_id            = p_sample_id
    	AND    gs.inventory_item_id    = iim.inventory_item_id
        AND    gs.organization_id      = iim.organization_id;
    ELSE
         -- BUG 4165704: changed ic_item_mst to mtl_system_items, and updated field names for inventory convergence
    	SELECT gse.organization_id,
               gse.inventory_item_id,
               iim.concatenated_segments,
               gse.parent_lot_number,
               gse.lot_number,
               gse.sampling_event_id,
    	       gse.batch_id,
               gse.step_no
	INTO   l_organization_id,
               l_inventory_item_id,
               l_inventory_item_number,
               l_parent_lot_number,
               l_lot_number,
               l_sampling_event_id,
	       l_batch_id,
               l_step_no
	FROM   GMD_COMPOSITE_SPEC_DISP  csd,
               GMD_EVENT_SPEC_DISP      esd ,
	       GMD_SAMPLING_EVENTS      gse,
               MTL_SYSTEM_ITEMS_b_kfv   iim
	WHERE  csd.composite_spec_disp_id = p_composite_spec_disp_id
	and    csd.event_spec_disp_id     = esd.event_spec_disp_id
	and    esd.sampling_event_id      = gse.sampling_event_id
	and    gse.inventory_item_id      = iim.inventory_item_id
	and    gse.organization_id        = iim.organization_id ;

        	-- select the orgn_code from the first sample.
                -- Bug 4165704: took out the following code since orgn is now kept on sampling event.
                --             added organization to select statement above
	        --SELECT orgn_code INTO l_orgn_code
	        --FROM   GMD_SAMPLES
	        --WHERE  sampling_event_id = l_sampling_event_id
	        --AND    rownum = 1 ;

    END IF;

          -- Manish Gupta B3143795, Update hold date
          -- Bug 4165704: changed cursor to use lot_number, parent_lot_number and mtl_lot_numbers table
      IF l_parent_lot_number IS NOT NULL
         AND l_lot_number IS NULL  THEN
            FOR l_lots in c_lots(
                           l_parent_lot_number,
                           l_organization_id ,
                           l_inventory_item_id)
            LOOP

              --Lock the mtl_lot_numbers before updating.
              OPEN c_mtl_lot_numbers(l_parent_lot_number,
                                     l_inventory_item_id,
                                     l_organization_id);
              CLOSE c_mtl_lot_numbers;

                  -- Bug 4165704: hold date is now updated on mtl_lot_numbers
                     --UPDATE ic_lots_cpg
                     --SET ic_hold_date = p_hold_date
                     --WHERE item_id =l_lot_number.item_id
                     --AND   lot_id  = l_lot_number.lot_id;
              UPDATE mtl_lot_numbers
              SET    hold_date = p_hold_date
              WHERE  inventory_item_id = l_inventory_item_id
                AND  organization_id   = l_organization_id
		AND  ((parent_lot_number  =  l_parent_lot_number )
		    OR ( lot_number  =  l_parent_lot_number
                      AND parent_lot_number IS NULL) );
           END LOOP;

      ELSIF l_lot_number IS NOT NULL THEN
              UPDATE mtl_lot_numbers
              SET    hold_date = p_hold_date
              WHERE  inventory_item_id = l_inventory_item_id
                AND  organization_id   = l_organization_id
                AND  lot_number        = l_lot_number;

      END IF;  -- test for parent lot

    l_position	:= '015' ;

                  -- set up constants needed for the inventory API.
                  -- Bug 4165704- not needed after inventory convergence
                  --l_tempb := GMIGUTL.SETUP(FND_GLOBAL.USER_NAME);
                  --IF (NOT l_tempb) THEN
                  --    x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
                  --    x_return_status := FND_API.G_RET_STS_ERROR ;
                  --    return;
                  --END IF;

    l_position	:= '020' ;
--gml_sf_log('start 020');

    IF p_to_grade_code IS NOT NULL THEN

       IF l_parent_lot_number IS NOT NULL
          AND l_lot_number IS NULL  THEN
                   -- Bug 4165704: sublot removed from db for inventory conversion
                   -- change all lots under the parent lot
    	           -- IF l_sublot_no IS NOT NULL THEN
    	              --OPEN get_curr_grade_cv FOR
    	   	        --SELECT lot_no,sublot_no FROM IC_LOTS_MST
   		        --WHERE  item_id  =  l_item_id
   		        --AND    lot_no   =  l_lot_no
   		        --AND    sublot_no = l_sublot_no
   		        --AND    qc_grade <> p_to_grade_code;
   	           --ELSE
   	   OPEN get_curr_grade_cv FOR
    	   	SELECT lot_number,
                       grade_code
                FROM mtl_lot_numbers
   		WHERE  inventory_item_id  =  l_inventory_item_id
   		AND    organization_id    =  l_organization_id
		AND  ((parent_lot_number  =  l_parent_lot_number )
		    OR ( lot_number  =  l_parent_lot_number
                      AND parent_lot_number IS NULL) )
   	 	AND    grade_code         <> p_to_grade_code;

    	  LOOP
--gml_sf_log('in first loop for grade');
    	    FETCH get_curr_grade_cv into get_curr_grade_rec ;
    	    EXIT WHEN get_curr_grade_cv%NOTFOUND ; -- exit when last row is fetched

            --RLNAGARA B5668965 Removed the IF-ELSE cond below
            --when only parent_lot is given it means change the grade for all the child lots
            --irrespective of the current_grade(from_grade).

            -- Bug 4165704: if from_grade_code changed, return to form
--            IF (p_from_grade_code <> get_curr_grade_rec.grade_code) THEN
                 --error out020
--gml_sf_log('grade code is wrong');
--                 RAISE FND_API.G_EXC_ERROR;
--            ELSE
                  -- Bug 4165704: Changed from call to inventory posting to INV_GRADE_PKG.UPDATE_GRADE
   	          -- process data record
	          -- , p_lot_number                => l_lot_number
        	INV_GRADE_PKG.UPDATE_GRADE
	        (   p_organization_id           => l_organization_id
	          , p_update_method             => 2             -- (Manual)
        	  , p_inventory_item_id         => l_inventory_item_id
	          , p_from_grade_code           => p_from_grade_code
	          , p_to_grade_code             => p_to_grade_code
	          , p_reason_id                 => p_reason_id
	          , p_lot_number                => get_curr_grade_rec.lot_number
         	  , x_Status                    => x_return_status
	          , x_Message                   => l_data
	          , p_update_from_mobile        => 'N'                     -- default value
        	  , p_primary_quantity          => NULL                    -- not sure what this value is yet
	          , p_secondary_quantity        => NULL   );                 --xxx not sure what this value is yet

		IF x_return_status <> 'S'
  		THEN
                    RAISE FND_API.G_EXC_ERROR;
		END IF; -- x_return_status <> 'S'
--            END IF;    -- p_from_grade_code has not changed

                --   Taken out with Inventory Convergence and replaced with above code
         	--	l_trans_rec_grade.trans_type      := 5;
        	--	l_trans_rec_grade.item_no         := l_item_no ;
	        --	l_trans_rec_grade.lot_no          := get_curr_grade_rec.lot_no;
  	        --	l_trans_rec_grade.co_code         := l_co_code ;
  	        --        	l_trans_rec_grade.orgn_code       := l_orgn_code ;
  	        --	l_trans_rec_grade.qc_grade        := p_to_grade_code ;
  	        --	l_trans_rec_grade.reason_code     := p_reason_code ;
  	        --	l_trans_rec_grade.user_name       := FND_GLOBAL.USER_NAME ;
  	        --	l_trans_rec_grade.trans_date      := SYSDATE ;
  	        --	l_trans_rec_grade.trans_qty       := NULL;

            	--  	GMIPAPI.Inventory_Posting
	        --             ( p_api_version    => 3.0
  	        --             p_init_msg_list  => FND_API.G_TRUE
  	        --             p_commit         => FND_API.G_FALSE
  	        --             p_validation_level  => FND_API.G_VALID_LEVEL_FULL
  	        --             p_qty_rec  => l_trans_rec_grade
  	        --             x_ic_jrnl_mst_row => l_ic_jrnl_mst_row
  	        --             x_ic_adjs_jnl_row1 => l_ic_adjs_jnl_row1
  	        --             x_ic_adjs_jnl_row2 => l_ic_adjs_jnl_row2
  	        --             x_return_status  => x_return_status
  	        --             x_msg_count      => l_count
  	        --             x_msg_data       => l_data
  	        --             );
           END LOOP ;
           CLOSE get_curr_grade_cv;
       ELSE
             -- only update the one lot specified
   	   OPEN get_curr_grade_cv FOR
    	   	SELECT lot_number,
                       grade_code
                FROM mtl_lot_numbers
   		WHERE  inventory_item_id  =  l_inventory_item_id
   		AND    organization_id    =  l_organization_id
   		AND    lot_number         =  l_lot_number
   	 	AND    grade_code         <> p_to_grade_code;

    	  LOOP
    	    FETCH get_curr_grade_cv into get_curr_grade_rec ;
    	    EXIT WHEN get_curr_grade_cv%NOTFOUND ; -- exit when last row is fetched
            --RLNAGARA B5668965 Changed the exception from FND_API.G_EXC_ERROR to SAMPLE_DISP_CHANGED
            -- Bug 4165704: if from_grade_code changed, return to form
            IF (p_from_grade_code <> get_curr_grade_rec.grade_code) THEN
                 --xxxerror out
                 RAISE SAMPLE_DISP_CHANGED;
            ELSE
                  -- Bug 4165704: Changed from call to inventory posting to INV_GRADE_PKG.UPDATE_GRADE
   	          -- process data record
        	INV_GRADE_PKG.UPDATE_GRADE
	        (   p_organization_id           => l_organization_id
	          , p_update_method             => 2             -- (Manual)
        	  , p_inventory_item_id         => l_inventory_item_id
	          , p_from_grade_code           => p_from_grade_code
	          , p_to_grade_code             => p_to_grade_code
	          , p_reason_id                 => p_reason_id
	          , p_lot_number                => l_lot_number
         	  , x_Status                    => x_return_status
	          , x_Message                   => l_data
	          , p_update_from_mobile        => 'N'                     -- default value
        	  , p_primary_quantity          => NULL                    -- not sure what this value is yet
	          , p_secondary_quantity        => NULL   );                 --xxx not sure what this value is yet

		IF x_return_status <> 'S' THEN
                    RAISE FND_API.G_EXC_ERROR;
		END IF; -- x_return_status <> 'S'

            END IF;     -- (p_from_grade_code <> get_curr_grade_rec.grade_code) THEN
          END LOOP;
       END IF;       -- l_parent_lot_number IS NOT NULL
    END IF; -- p_to_grade_code IS NOT NULL THEN

    -- if grade update failed, then do not continue further.
    IF x_return_status <> 'S' THEN
       RETURN;
    END IF;

    l_position	:= '030' ;

 IF p_to_lot_status_id IS NOT NULL THEN
             -- Bug 4165704: For inventory convergence:
             --            1. removed sublot, lot_id
             --            2. changed lot_no to lot_number
             --            3. use mtl_lot_numbers instead of ic_lots_mst
             --            4. use parent_lot_number and changed logic so that if parent lot specified
             --               but lot number is not specified, all lots for that parent are updated

             -- IF l_sublot_no IS NOT NULL THEN
             --OPEN get_curr_lot_status_cv FOR
   	     --	SELECT b.lot_no,a.whse_code,a.location
             --      FROM IC_LOCT_INV a , IC_LOTS_MST b
   	     --	WHERE  a.item_id  =  l_inventory_item_id
   	     --	AND    b.item_id  = a.item_id
   	     --	AND    b.lot_no   =  l_lot_number
   	     --	AND    a.lot_status <> p_to_lot_status;
             --ELSE
        -- Bug 91432301
        OPEN get_default_status_id;
  	  	FETCH get_default_status_id INTO l_default_status_id;
      	CLOSE get_default_status_id;

        IF l_default_status_id is not null then
           l_onhand_status_id  := p_to_lot_status_id;
					 l_onhand_reason_id  := p_reason_id;
        ELSE
           l_onhand_status_id  := null;
					 l_onhand_reason_id  := null;
        END IF ; --  IF l_default_status_id is not null then
       -- Bug 91432301



       IF l_parent_lot_number IS NOT NULL
          AND l_lot_number IS NULL  THEN

             -- update all lots for the parent lot specified
		   /*  OPEN get_curr_lot_status_cv FOR
		       SELECT lot_number,
			      status_id
		       FROM  MTL_LOT_NUMBERS
		       WHERE  inventory_item_id  =  l_inventory_item_id
			 AND  organization_id    =  l_organization_id
			 AND  ((parent_lot_number  =  l_parent_lot_number )
			    OR ( lot_number  =  l_parent_lot_number
                               AND parent_lot_number IS NULL) )
			 AND  status_id          <> p_to_lot_status_id; */

                     --RLNAGARA B5668965 Commented the below cursor and added the next cursor by
                     --removing the fix done for the bug 5006173
                     /*

 			 OPEN get_curr_lot_status_cv FOR
		       SELECT lot_number,
			      a.status_id
		       FROM  MTL_LOT_NUMBERS a,  mtl_item_locations_kfv b  -- 50061731
		       WHERE  a.inventory_item_id  =  l_inventory_item_id
			 AND  a.organization_id    =  l_organization_id
			 AND  ((a.parent_lot_number  =  l_parent_lot_number )
			    OR ( a.lot_number  =  l_parent_lot_number
                               AND a.parent_lot_number IS NULL) )
			 AND  a.status_id          <> p_to_lot_status_id

			AND b.organization_id        = l_organization_id   -- 50061731
      			AND b.subinventory_code      = nvl(l_subinventory, b.subinventory_code ) -- 50061731
      			AND b.inventory_location_id  = nvl(l_locator_id,b.inventory_location_id ); -- 50061731
                       */
 			 OPEN get_curr_lot_status_cv FOR
		       SELECT lot_number,
			      a.status_id
		       FROM  MTL_LOT_NUMBERS a
		       WHERE  a.inventory_item_id  =  l_inventory_item_id
			 AND  a.organization_id    =  l_organization_id
			 AND  ((a.parent_lot_number  =  l_parent_lot_number )
			    OR ( a.lot_number  =  l_parent_lot_number
                               AND a.parent_lot_number IS NULL) )
			 AND  a.status_id          <> p_to_lot_status_id;


	  LOOP
		    FETCH get_curr_lot_status_cv into get_curr_lot_status_rec ;
		    EXIT WHEN get_curr_lot_status_cv%NOTFOUND ; -- exit when last row is fetched

                    --RLNAGARA B5668965 Removed the IF-ELSE cond below
                    --when only parent_lot is given it means change the lot status for all the child lots
                    --irrespective of the current_status(from_status).

		    -- Bug 4165704: if from_lot_status changed, return to form
--		    IF (p_from_lot_status_id <> get_curr_lot_status_rec.status_id ) THEN
			 --mxxxerror out
--    		       RAISE SAMPLE_DISP_CHANGED;
		       --RAISE FND_API.G_EXC_ERROR;
--		    ELSE

			  -- Bug 4165704: replaced  GMIPAPI.Inventory_Posting with Inv_Status_Pkg.update_status
			  --	l_trans_rec_lot_status.trans_type      := 4;
			  --	l_trans_rec_lot_status.item_no         := l_inventory_item_number ;
			  --	l_trans_rec_lot_status.lot_no          := get_curr_lot_status_rec.lot_no;
			  --	l_trans_rec_lot_status.from_whse_code  := get_curr_lot_status_rec.whse_code ;
			  --	l_trans_rec_lot_status.from_location   := get_curr_lot_status_rec.location;
			  --	l_trans_rec_lot_status.orgn_code       := l_orgn_code ;
			  --	l_trans_rec_lot_status.lot_status      := p_to_lot_status ;
			  ---	l_trans_rec_lot_status.reason_code     := p_reason_code ;
			  --	l_trans_rec_lot_status.user_name       := FND_GLOBAL.USER_NAME ;
			  --	l_trans_rec_lot_status.trans_date      := SYSDATE ;
			  --	l_trans_rec_lot_status.trans_qty       := NULL;
			  --GMIPAPI.Inventory_Posting
			  --( p_api_version    => 3.0
			  --, p_init_msg_list  => FND_API.G_TRUE
			  --, p_commit         => FND_API.G_FALSE
			  --, p_validation_level  => FND_API.G_VALID_LEVEL_FULL
			  --, p_qty_rec  => l_trans_rec_lot_status
			  --, x_ic_jrnl_mst_row => l_ic_jrnl_mst_row
			  --, x_ic_adjs_jnl_row1 => l_ic_adjs_jnl_row1
			  --, x_ic_adjs_jnl_row2 => l_ic_adjs_jnl_row2
			  --, x_return_status  => x_return_status
			  --, x_msg_count      => l_count
			  --, x_msg_data       => l_data );



		   Inv_Status_Pkg.update_status(
			p_update_method          => 2                                     --(Manual)
		      , p_organization_id        => l_organization_id
		      , p_inventory_item_id      => l_inventory_item_id
		      , p_sub_code               => NULL
		      , p_sub_status_id          => NULL
		      , p_sub_reason_id          => NULL
		      , p_locator_id             => NULL
		      , p_loc_status_id          => NULL
		      , p_loc_reason_id          => NULL
		      , p_from_lot_number        => get_curr_lot_status_rec.lot_number    --from_lot_number
		      , p_to_lot_number          => get_curr_lot_status_rec.lot_number   --to_lot_number
		      , p_lot_status_id          => p_to_lot_status_id
		      , p_lot_reason_id          => p_reason_id
		      , p_from_SN                => NULL
		      , p_to_SN                  => NULL
		      , p_serial_status_id       => 0  --  91432301
		      , p_serial_reason_id       => NULL
		      , x_Status                 => x_return_status
		      , x_Message                => l_data
		      , p_update_from_mobile     => 'N'      --(DEFAULT 'Y')
		      , p_grade_code             => NULL     --(DEFAULT NULL)
		      , p_primary_onhand         => NULL     --(DEFAULT NULL)
		      , p_secondary_onhand       => NULL     --(DEFAULT NULL)
		      , p_onhand_status_id      => l_onhand_status_id  -- Added for # 91432301
					, p_onhand_reason_id      => l_onhand_reason_id  -- Added for # 91432301
          );

		   IF x_return_status <> 'S'
		   THEN
		       RAISE FND_API.G_EXC_ERROR;
		   END IF;    -- x_return_status <> 'S'

--		   END IF;    -- (p_from_lot_status_id <> get_curr_lot_status_rec.status_id THEN

		 END LOOP ;
		 CLOSE get_curr_lot_status_cv;

	       ELSIF l_lot_number IS NOT NULL  THEN

                  OPEN c_lot_status(l_lot_number,
                                    l_inventory_item_id,
                                    l_organization_id);
		  FETCH c_lot_status into get_curr_lot_status_rec ;
		  CLOSE c_lot_status;

		    -- Bug 4165704: if from_lot_status changed, return to form
		  IF (p_from_lot_status_id <> get_curr_lot_status_rec.status_id ) THEN
		      --xxxerror out
    		      RAISE SAMPLE_DISP_CHANGED;
		      --RAISE FND_API.G_EXC_ERROR;
		  ELSE

		     -- update the one lot specified
		     Inv_Status_Pkg.update_status(
			p_update_method          => 2                                     --(Manual)
		      , p_organization_id        => l_organization_id
		      , p_inventory_item_id      => l_inventory_item_id
		      , p_sub_code               => NULL
		      , p_sub_status_id          => NULL
		      , p_sub_reason_id          => NULL
		      , p_locator_id             => NULL
		      , p_loc_status_id          => NULL
		      , p_loc_reason_id          => NULL
		      , p_from_lot_number        => l_lot_number    --from_lot_number
		      , p_to_lot_number          => l_lot_number    --to_lot_number
		      , p_lot_status_id          => p_to_lot_status_id
		      , p_lot_reason_id          => p_reason_id
		      , p_from_SN                => NULL
		      , p_to_SN                  => NULL
		      , p_serial_status_id       => 0 -- 91432301
		      , p_serial_reason_id       => NULL
		      , x_Status                 => x_return_status
		      , x_Message                => l_data
		      , p_update_from_mobile     => 'N'      --(DEFAULT 'Y')
		      , p_grade_code             => NULL     --(DEFAULT NULL)
		      , p_primary_onhand         => NULL     --(DEFAULT NULL)
		      , p_secondary_onhand       => NULL
		      , p_onhand_status_id      => l_onhand_status_id  -- Added for # 91432301
					, p_onhand_reason_id      => l_onhand_reason_id  -- Added for # 91432301
		       );

		   IF x_return_status <> 'S' THEN
		       GMD_API_PUB.Log_Message('GMD_QM_INV_REASON_CODE');
		       RAISE FND_API.G_EXC_ERROR;
		   END IF;    -- x_return_status <> 'S'

               END IF;    -- (p_from_lot_status_id <> get_curr_lot_status_rec.status_id THEN

	     END IF ;   -- Test for parent lot not null but lot number null
	    END IF; -- p_to_lot_status IS NOT NULL THEN

	    -- B2985070 Check if the batch id and step no is available
	    IF p_to_qc_status IS NOT NULL AND
	       l_batch_id IS NOT NULL AND
	       l_step_no IS NOT NULL   THEN

		-- Bug # 4619570 Allow update of batch step quality status if batch is not closed
        	/*SELECT batch_status INTO l_batch_status     --  Bug # 4619570 Need to know if batch is closed
		FROM gme_batch_header
       		 WHERE  batch_id =  l_batch_id; */

                -- Bug# 5440347
                SELECT step_status INTO l_step_status
                  FROM gme_batch_steps
                 WHERE batch_id = l_batch_id
                   AND batchstep_no = l_step_no;


        	 --IF l_batch_status <> 4 THEN
		 IF l_step_status < 3 THEN -- Bug# 5440347
			SELECT quality_status,rowid, batchstep_id INTO l_curr_qc_status,l_rowid, l_bstep_id -- Bug# 5440347 Added batchstep_id
			FROM   GME_BATCH_STEPS
			WHERE  BATCH_ID = l_batch_id
			AND    batchstep_no = l_step_no
			FOR UPDATE OF quality_status NOWAIT ;

      IF (l_debug = 'Y') THEN
    			 gmd_debug.put_line('about to UPDATE GME_BATCH_STEPS quality status with   p_to_qc_status :'||p_to_qc_status);
      END IF;


			IF l_curr_qc_status = 3 THEN -- Results Required
		   		UPDATE GME_BATCH_STEPS
		   		SET  quality_status = p_to_qc_status             --  NO ACTION  BUT could be here too 8252179
		       		,last_updated_by   = FND_GLOBAL.USER_ID
		       		,last_update_date  = SYSDATE
		       		,last_update_login = FND_GLOBAL.LOGIN_ID
		   		WHERE rowid = l_rowid ;

                                --Bug# 5440347 start
                                -- Dont call complete_step if the qc status is Action Required
                                IF p_to_qc_status = 5 THEN -- Action Required
                                   RETURN;
                                END IF;

                                IF p_sample_id IS NOT NULL THEN
                                   OPEN cur_auto_complete_bstep_smpl;
                                   FETCH cur_auto_complete_bstep_smpl INTO l_auto_complete_bstep;
                                   IF cur_auto_complete_bstep_smpl%NOTFOUND THEN
                                       l_auto_complete_bstep := 'N';
                                   END IF;
                                   CLOSE cur_auto_complete_bstep_smpl;
                                ELSE
                                   OPEN cur_auto_complete_bstep_comp;
                                   FETCH cur_auto_complete_bstep_comp INTO l_auto_complete_bstep;
                                   IF cur_auto_complete_bstep_comp%NOTFOUND THEN
                                        l_auto_complete_bstep := 'N';
                                   END IF;
                                  CLOSE cur_auto_complete_bstep_comp;
                                END IF;

                                /*If auto_complete_batch_step flag is checked in the VR which is being used
                                then only call the gme API to complete the batch step.*/
                                IF l_auto_complete_bstep = 'Y' THEN
                                   p_batch_step_rec.batchstep_id := l_bstep_id;

                                   IF (l_debug = 'Y') THEN
                                      gmd_debug.put_line('Before Calling Batch Step Completion API for BATCHSTEP_ID:'||l_bstep_id);
                                   END IF;

                                   --call the batch step completion API.
                                   GME_API_PUB.complete_step(
                                        p_api_version            => 2.0
                                       ,p_validation_level       => gme_common_pvt.g_max_errors
                                       ,p_init_msg_list          => fnd_api.g_false
                                       ,p_commit                 => fnd_api.g_false
                                       ,x_message_count          => x_message_count
                                       ,x_message_list           => x_message_list
                                       ,x_return_status          => xx_return_status
                                       ,p_batch_step_rec         => p_batch_step_rec
                                       ,p_batch_no               => NULL
                                       ,p_org_code               => NULL
                                       ,p_ignore_exception       => fnd_api.g_false
                                       ,p_override_quality       => fnd_api.g_false
                                       ,p_validate_flexfields    => fnd_api.g_false
                                       ,x_batch_step_rec         => x_batch_step_rec
                                       ,x_exception_material_tbl => l_exception_material_tbl);
                                   --After returning from the API we are not handling any exceptions. Any exceptions will be written in the Debug Log

                                   IF (l_debug = 'Y') THEN
                                       gmd_debug.put_line('Returned from Batch Step Completion Call');
                                       gmd_debug.put_line('x_return_status = '||xx_return_status);
                                       gmd_debug.put_line('x_batch_step_rec.batch_id = '||TO_CHAR(x_batch_step_rec.batch_id));
                                       gmd_debug.put_line('x_batch_step_rec.batchstep_id = '||TO_CHAR(x_batch_step_rec.batchstep_id));
                                       gmd_debug.put_line('x_batch_step_rec.batchstep_no = '||TO_CHAR(x_batch_step_rec.batchstep_no));
                                       gmd_debug.put_line('x_batch_step_rec.actual_start_date = '||TO_CHAR(x_batch_step_rec.actual_start_date,'DD-MON-YYYY HH24:MI:SS'));
                                       gmd_debug.put_line('x_batch_step_rec.actual_cmplt_date = '||TO_CHAR(x_batch_step_rec.actual_cmplt_date,'DD-MON-YYYY HH24:MI:SS'));
                                       gmd_debug.put_line('x_batch_step_rec.step_status = '||TO_CHAR(x_batch_step_rec.step_status));
                                   END IF;

                                END IF; --l_auto_complete_bstep = 'Y'
                                -- Bug# 5440347 end

			END IF; -- l_curr_qc_status = 3
	    	END IF; --  l_step_status < 3

	     END IF;

IF (l_debug = 'Y') THEN
     gmd_debug.put_line('exiting update_lot_grade_batch p_sample_id :'||p_sample_id);
   END IF;


EXCEPTION
WHEN SAMPLE_DISP_CHANGED THEN
--RLNAGARA B5668965 Changed the message from GMD_SMPL_DISP_CHANGE to GMD_QM_CURRENT_LOT_VALUE_CHANG
   gmd_api_pub.log_message('GMD_QM_CURRENT_LOT_VALUE_CHANG','PACKAGE','GMD_SAMPLES_GRP.UPDATE_SAMPLE_COMP_DISP');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN REQ_FIELDS_MISSING THEN
   gmd_api_pub.log_message('GMD_REQ_FIELD_MIS','PACKAGE','GMD_SAMPLES_GRP.UPDATE_LOT_GRADE_BATCH');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_SAMPLE THEN
   gmd_api_pub.log_message('GMD_QM_INVALID_SAMPLE');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN INVALID_QC_STATUS THEN
   gmd_api_pub.log_message('GME_INV_STEP_QUALITY_STATUS');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN RECORD_LOCK THEN
   GMD_API_PUB.Log_Message('GMD_IC_LOTS_CPG_LOCKED');
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_ERROR ;

WHEN OTHERS THEN
   IF get_curr_grade_cv%ISOPEN THEN
      CLOSE get_curr_grade_cv;
   END IF;
   IF get_curr_lot_status_cv%ISOPEN THEN
      CLOSE get_curr_lot_status_cv;
   END IF;
   gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE','GMD_SAMPLES_GRP.UPDATE_LOT_GRADE_BATCH','ERROR', SUBSTR(SQLERRM,1,100),'POSITION',l_position);
   x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END update_lot_grade_batch ;



--Start of comments
--+========================================================================+
--| API Name    : check_for_null_and_fks_in_smpl                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Sample         |
--|               record.                                                  |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Chetan Nagar	11-Nov-2002	                                   |
--|      Commenting code to check sampling_event_id IS NOT NULL as this    |
--|      routine gets called only from the Public API and the Public API   |
--|      has not yet determined the Samling Event ID.                      |
--|                                                                        |
--|      The check will be done by the public API itself.                  |
--|                                                                        |
--|      Uday Phadtare Bug2982490 06-Aug-2003. Close cursor c_item_lot     |
--|      instead of c_whse.                                                |
--|                                                                        |
--|      Bug 4165704: changes for inventory convergence include organization|
--|                  inventory_item_id, and lots.                          |
--|      Bug 4640143: added material_detail_id to samples                  |
--|      Peter Lowe   FP of Bug # 4359797   - 4619570                      |
--|      if profile GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'Y then allow       |
--|      retrieval of closed batches                                       |
--|      Peter Lowe   7027149  -  added support for LPN                    |
--===========================================================================+
    -- Bug 4640143: added cursor
-- End of comments

PROCEDURE check_for_null_and_fks_in_smpl
(
  p_sample        IN         gmd_samples%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
) IS

    -- Bug 4165704: changed for inventory convergence
  CURSOR c_orgn (p_organization_id NUMBER) IS
  SELECT 1
  FROM mtl_parameters m,
       org_access_view v
  WHERE v.organization_id = m.organization_id
    AND m.organization_id = p_organization_id
    AND m. process_enabled_flag = 'Y' ;

  CURSOR c_sampler (p_orgn_code VARCHAR2 , p_sampler_id NUMBER) IS
  SELECT 1
  FROM   FND_USER
  WHERE  user_id  = p_sampler_id;

    -- Bug 4165704: changed for inventory convergence
  CURSOR c_lab_orgn (p_organization_id NUMBER) IS
  SELECT 1
  FROM mtl_parameters m,
       gmd_quality_config g ,
       org_access_view v
  WHERE g.quality_lab_ind = 'Y'
    AND g.organization_id = m.organization_id
    AND v.organization_id = m.organization_id
    AND m.organization_id = p_organization_id
    AND m. process_enabled_flag = 'Y' ;

    -- Bug 4165704: changed for inventory convergence
  CURSOR c_item(p_inventory_item_id NUMBER, p_organization_id NUMBER) IS
  SELECT 1
  FROM  mtl_system_items_b_kfv
  WHERE organization_id     = p_organization_id
    AND process_quality_enabled_flag = 'Y'
    AND inventory_item_id   = p_inventory_item_id;

  CURSOR c_sampling_event(p_sampling_event_id NUMBER) IS
  SELECT 1
  FROM   gmd_sampling_events
  WHERE  sampling_event_id = p_sampling_event_id
  ;

    -- Bug 4165704: changed for inventory convergence
  CURSOR c_subinventory IS
  SELECT 1
  FROM   mtl_secondary_inventories s
  WHERE  s.organization_id          = p_sample.organization_id
    AND  s.secondary_inventory_name = p_sample.subinventory;

    -- Bug 4165704: changed for inventory convergence
  CURSOR c_locator IS
    SELECT 1
    FROM mtl_item_locations_kfv
    WHERE organization_id        = p_sample.organization_id
      AND subinventory_code      = p_sample.subinventory
      AND inventory_location_id  = p_sample.locator_id;

    -- Bug 4165704: changed for inventory convergence
  CURSOR c_item_lot IS
    SELECT 1
    FROM mtl_lot_numbers
    WHERE organization_id   = p_sample.organization_id
      AND inventory_item_id = p_sample.inventory_item_id
      AND lot_number        = p_sample.lot_number;

    -- Bug 4165704: removed for inventory convergence
         --CURSOR c_item_sublot IS

  CURSOR c_batch IS
  SELECT 1
  FROM   gme_batch_header bh
  WHERE  bh.batch_id = p_sample.batch_id
  AND    bh.batch_type = 0 -- Only Batches, No FPOs
  AND ( (  bh.batch_status IN (1,2)     and     ( NVL(fnd_profile.value('GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'N') )  -- Bug # 4619570 Pending or WIP Batches Only
 OR  ( bh.batch_status IN (1,2, 4 )   and  ( NVL(fnd_profile.value('GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'Y') )  )  -- Pending or WIP Or Closed Batches Only
 AND exists			-- Only Batches with Spec Item in it
   (SELECT 1
    FROM   gme_material_details md
    WHERE  md.batch_id = bh.batch_id
    AND    md.inventory_item_id = p_sample.inventory_item_id)
  ;

  CURSOR c_recipe_id IS
  SELECT 1
  FROM   gmd_recipes r, gmd_status s
  WHERE  r.recipe_status = s.status_code
  AND    r.recipe_id = p_sample.recipe_id
  AND    s.status_type <> '1000'
  AND    r.delete_mark = 0
  AND    exists
    (SELECT 1
    FROM   fm_matl_dtl md
    WHERE  md.formula_id = r.formula_id
    AND    md.inventory_item_id = p_sample.inventory_item_id)
  ;


  CURSOR c_formulaline_id IS
  SELECT 1
  FROM   fm_form_mst f, fm_matl_dtl md
  WHERE  f.formula_id = md.formula_id
  AND    f.formula_id = nvl(p_sample.formula_id, f.formula_id)
  AND    md.formulaline_id = p_sample.formulaline_id
  AND    md.inventory_item_id   = p_sample.inventory_item_id
  AND    f.delete_mark = 0
  ;

    -- Bug 4640143: added cursor
 CURSOR c_material_detail_id IS
 SELECT 1
 FROM gme_material_details
 WHERE inventory_item_id   = p_sample.inventory_item_id
   AND batch_id            = p_sample.batch_id
   AND organization_id     = p_sample.organization_id
   AND material_detail_id  = p_sample.material_detail_id;


  CURSOR c_batchstep IS
  SELECT 1
  FROM   gme_batch_steps
  WHERE  batch_id = p_sample.batch_id
  AND    batchstep_no = p_sample.step_no
  ;

    -- Bug 4165704: changed fm_rout_dtl for gmd_routings_b
  CURSOR c_routingstep IS
  SELECT 1
  FROM   gmd_routings_b
  WHERE  routing_id = p_sample.routing_id;
       --FROM   fm_rout_dtl
       --WHERE  routing_id = p_sample.routing_id
       --AND    routingstep_no = p_sample.step_no


  CURSOR c_oprn IS
  SELECT 1
  FROM   gmd_operations
  WHERE  oprn_id = p_sample.oprn_id
  AND    delete_mark = 0
  ;

  CURSOR c_cust IS
  SELECT 1
  FROM   hz_cust_accounts_all
  WHERE  cust_account_id = p_sample.cust_id
  ;

  -- Bug 4165704: took this check out since gl_plcy_mst no longer exists
        --CURSOR c_org IS
        --SELECT 1
        --FROM   gl_plcy_mst
        --WHERE  org_id = p_sample.org_id ;


  CURSOR c_ship_to IS
  SELECT 1
  FROM   hz_cust_acct_sites_all a,
         hz_cust_site_uses_all s,
         hz_cust_accounts_all c
  WHERE  a.cust_acct_site_id = s.cust_acct_site_id
  AND    a.org_id = s.org_id
  AND    a.cust_account_id = c.cust_account_id
  AND    c.cust_account_id = p_sample.cust_id
  AND    s.site_use_code = 'SHIP_TO'
  AND    s.org_id = p_sample.org_id
  AND    s.site_use_id = p_sample.ship_to_site_id
  ;

  CURSOR c_order IS
  SELECT 1
  FROM   oe_order_headers_all h,
         oe_transaction_types_tl t
  WHERE  h.sold_to_org_id = p_sample.cust_id
  AND    h.org_id = p_sample.org_id
  AND    h.header_id = p_sample.order_id
  AND    h.cancelled_flag <> 'Y'
  AND    h.order_type_id = t.transaction_type_id
  AND    t.language = USERENV('LANG')
  ;

  CURSOR c_order_line IS
  SELECT 1
  FROM   oe_order_lines_all l,
         mtl_system_items_b m,
         mtl_parameters mp,
         ic_item_mst i
  WHERE  l.header_id = p_sample.order_id
  AND    l.line_id   = p_sample.order_line_id
  AND    l.ship_to_org_id = p_sample.ship_to_site_id
  AND    m.inventory_item_id = l.inventory_item_id
  AND    m.organization_id = l.ship_from_org_id
  AND    mp.organization_id = m.organization_id
  AND    mp.process_enabled_flag = 'Y'
  AND    i.item_id = p_sample.inventory_item_id
  AND    m.segment1 = i.item_no
  AND    l.cancelled_flag <> 'Y'
  ;

  CURSOR c_supplier IS
  SELECT 1
  FROM   po_vendors v
  WHERE  v.vendor_id = p_sample.supplier_id
  AND    v.enabled_flag = 'Y'
  AND    sysdate between nvl(v.start_date_active, sysdate-1)
                 and     nvl(v.end_date_active, sysdate+1)
  ;

  CURSOR c_po IS
  SELECT 1
  FROM   po_headers_all
  WHERE  vendor_id      = p_sample.supplier_id
  AND    po_header_id   = p_sample.po_header_id
  ;

    -- Bug 4165704: removed ic_item_mst_b test
  CURSOR c_po_line IS
  SELECT 1
  FROM   po_lines_all l
  WHERE  l.po_header_id = p_sample.po_header_id
  AND    l.po_line_id   = p_sample.po_line_id
  AND EXISTS
     (SELECT 1
      FROM    mtl_system_items_b msi
      WHERE   msi.inventory_item_id = l.item_id
      AND     msi.inventory_item_id = p_sample.inventory_item_id) ;

 --  7027149
cursor get_lpn is
SELECT 1
FROM
WMS_LICENSE_PLATE_NUMBERS WHERE lpn_id = p_sample.lpn_id;

CURSOR get_wms_flag IS
    SELECT wms_enabled_flag
    FROM mtl_parameters
    WHERE organization_id = p_sample.organization_id;


dummy               NUMBER;

l_wms_enabled_flag varchar2(1) := NULL; -- 7027149

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Orgn Code
  IF (p_sample.organization_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_ORGN_CODE_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Check that orgn Code exist in SY_ORGN_MST
    OPEN c_orgn(p_sample.organization_id);
    FETCH c_orgn INTO dummy;
    IF c_orgn%NOTFOUND THEN
      CLOSE c_orgn;
      GMD_API_PUB.Log_Message('GMD_ORGN_CODE_NOT_FOUND',
                              'ORGN', p_sample.lab_organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn;
  END IF;

  -- Sampler Id Validation

  IF (p_sample.sampler_id IS NULL ) THEN
     GMD_API_PUB.Log_Message('GMD_SAMPLER_ID_REQD');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Check that orgn Code exist in SY_ORGN_MST
    OPEN c_sampler(p_sample.organization_id, p_sample.sampler_id);
      FETCH c_sampler INTO dummy;
      IF c_sampler%NOTFOUND THEN
        GMD_API_PUB.Log_Message('GMD_SAMPLER_ID_NOTFOUND',
                              'SAMPLER', p_sample.sampler_id);
        RAISE FND_API.G_EXC_ERROR;
        CLOSE c_sampler;
      END IF;
    CLOSE c_sampler;
 END IF;


  -- Sample No
  IF (ltrim(rtrim(p_sample.sample_no)) IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SAMPLE_NUMBER_REQD');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Sample Source
  IF (p_sample.source IS NULL OR
      (NOT (p_sample.source in ('I', 'W', 'C', 'S','L','R','T')))
     ) THEN
    -- Now, what is the source of this sample? Where did it come from?
    GMD_API_PUB.Log_Message('GMD_SAMPLE_SOURCE_INVALID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- QC Lab Orgn Code
  IF (p_sample.lab_organization_id IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_QC_LAB_ORGN_CODE_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Check that QC Lab Orgn Code exist in SY_ORGN_MST
    OPEN c_lab_orgn(p_sample.lab_organization_id);
    FETCH c_lab_orgn INTO dummy;
    IF c_lab_orgn%NOTFOUND THEN
      CLOSE c_lab_orgn;
      GMD_API_PUB.Log_Message('GMD_QC_LAB_ORGN_CODE_NOT_FOUND',
                              'ORGN', p_sample.lab_organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_lab_orgn;
  END IF;

  -- Sample Disposition
  -- Chetan Nagar 13-Nov-2002 Removed '2I', '4A', '5AV', '6RJ' from the
  -- valid sample_disposition list.
  IF (p_sample.sample_disposition IS NULL OR
      (NOT (p_sample.sample_disposition in ('0RT', '1P')))
     ) THEN
    -- Now, what is the disposition of this sample?
    GMD_API_PUB.Log_Message('GMD_SAMPLE_DISPOSITION_INVALID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Item ID
  IF (p_sample.inventory_item_id IS NULL) and
     (p_sample.sample_type = 'M' ) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_ITEM_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    -- Get the Item No
    OPEN c_item(p_sample.inventory_item_id, p_sample.organization_id);
    FETCH c_item INTO dummy;
    IF c_item%NOTFOUND THEN
      CLOSE c_item;
      GMD_API_PUB.Log_Message('GMD_SPEC_ITEM_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_item;
  END IF;

  -- Sampling Event ID
  -- Chetan Nagar 13-Nov-2002
  -- Commenting following code as this routine gets called only from
  -- the Public API and the Public API has not yet determined the
  -- Samling Event ID. The check will be done by the public API itself.
  /** COMMENT START **
  IF (p_sample.sampling_event_id IS NOT NULL) THEN
    OPEN c_sampling_event(p_sample.sampling_event_id);
    FETCH c_sampling_event INTO dummy;
    IF c_sampling_event%NOTFOUND THEN
      CLOSE c_sampling_event;
      GMD_API_PUB.Log_Message('GMD_SAMPLING_EVENT_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_sampling_event;
  END IF;
  ** COMMENT END **/

  -- Sample Qty
  IF (p_sample.sample_qty IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SAMPLE_QTY_REQD');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Sample UOM
  IF (p_sample.sample_qty_uom IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_SAMPLE_UOM_REQD');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Lot No
  IF (p_sample.lot_number IS NOT NULL) THEN
    OPEN c_item_lot;
    FETCH c_item_lot INTO dummy;
    IF c_item_lot%NOTFOUND THEN
      --Uday Phadtare Bug2982490 changed CLOSE c_whse to CLOSE c_item_lot
      CLOSE c_item_lot;
      GMD_API_PUB.Log_Message('GMD_ITEM_LOT_NOT_FOUND',
                              'LOT_NO', p_sample.lot_number);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_item_lot;
  END IF;


  IF (p_sample.source = 'I') THEN
    -- Sample is from source 'Inventory' so check only
    -- those parameters related to Inventory

    -- Whse Code
    IF (p_sample.subinventory IS NOT NULL) THEN
      -- Check that Whse Code exist in IC_WHSE_MST
      OPEN c_subinventory;
      FETCH c_subinventory INTO dummy;
      IF c_subinventory%NOTFOUND THEN
        CLOSE c_subinventory;
        GMD_API_PUB.Log_Message('GMD_SPEC_WHSE_NOT_FOUND',
                                'WHSE', p_sample.subinventory);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_subinventory;
    END IF;

    -- Location
    IF (p_sample.locator_id IS NOT NULL) THEN
      -- Check that Location exist in table
      OPEN c_locator;
      FETCH c_locator INTO dummy;
      IF c_locator%NOTFOUND THEN
        CLOSE c_locator;
        GMD_API_PUB.Log_Message('GMD_LOCT_NOT_FOUND',
                                'LOCATION', p_sample.locator_id);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_locator;
    END IF;

  END IF; -- Validation for Inventory Sample

  IF (p_sample.source = 'W') THEN
    -- Sample is from source 'WIP' so check only
    -- those parameters related to WIP

    -- For WIP sample, at least Batch No or Recipe ID is required
    IF (p_sample.batch_id IS NULL AND p_sample.recipe_id IS NULL) THEN
      GMD_API_PUB.Log_Message('GMD_NO_WIP_PARAM');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Batch ID is valid

    IF (p_sample.batch_id IS NOT NULL) THEN
      OPEN c_batch;
      FETCH c_batch INTO dummy;
      IF c_batch%NOTFOUND THEN
        CLOSE c_batch;
        GMD_API_PUB.Log_Message('GMD_BATCH_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_batch;
    END IF;

    -- Recipe is valid (Check only if Batch was not specified)
    IF (p_sample.batch_id IS NULL AND p_sample.recipe_id IS NOT NULL) THEN
      OPEN c_recipe_id;
      FETCH c_recipe_id INTO dummy;
      IF c_recipe_id%NOTFOUND THEN
        CLOSE c_recipe_id;
        GMD_API_PUB.Log_Message('GMD_RECIPE_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_recipe_id;
    END IF;

    -- Formula Line is valid
    -- Bug 4640143: added batch id to test
    IF (p_sample.formula_id IS NOT NULL AND
        p_sample.batch_id IS NULL  AND
        p_sample.formulaline_id IS NOT NULL) THEN
      OPEN c_formulaline_id;
      FETCH c_formulaline_id INTO dummy;
      IF c_formulaline_id%NOTFOUND THEN
        CLOSE c_formulaline_id;
        GMD_API_PUB.Log_Message('GMD_FORMULA_LINE_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_formulaline_id;
    END IF;

    -- Material Detail is valid
    -- Bug 4640143: added material detail id to samples
    IF (p_sample.batch_id IS NOT NULL AND
        p_sample.material_detail_id IS NOT NULL) THEN
      OPEN c_material_detail_id;
      FETCH c_material_detail_id INTO dummy;
      IF c_material_detail_id%NOTFOUND THEN
        CLOSE c_material_detail_id;
        GMD_API_PUB.Log_Message('GMD_MATERIAL_DTL_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_material_detail_id;
    END IF;

    -- Step is valid
    IF (p_sample.batch_id IS NOT NULL AND p_sample.step_no IS NOT NULL) THEN
      -- Step No is from Batch
      OPEN c_batchstep;
      FETCH c_batchstep INTO dummy;
      IF c_batchstep%NOTFOUND THEN
        CLOSE c_batchstep;
        GMD_API_PUB.Log_Message('GMD_BATCH_STEP_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_batchstep;
    ELSIF (p_sample.routing_id IS NOT NULL AND p_sample.step_no IS NOT NULL) THEN
      -- Step No is from Routing
      OPEN c_routingstep;
      FETCH c_routingstep INTO dummy;
      IF c_routingstep%NOTFOUND THEN
        CLOSE c_routingstep;
        GMD_API_PUB.Log_Message('GMD_ROUTING_STEP_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_routingstep;
    END IF;

    -- Operation is valid (check only if step is not specified, because
    --                     otherwise it will default from the step chosen.)
    IF (p_sample.step_id IS NULL AND p_sample.oprn_id IS NOT NULL) THEN
      OPEN c_oprn;
      FETCH c_oprn INTO dummy;
      IF c_oprn%NOTFOUND THEN
        CLOSE c_oprn;
        GMD_API_PUB.Log_Message('GMD_BATCH_STEP_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_oprn;
    END IF;

  END IF; -- Validation for Customer Sample

  IF (p_sample.source = 'C') THEN
    -- Sample is from source 'Customer' so check only
    -- those parameters related to Customer

    -- Customer
    IF (p_sample.cust_id IS NULL) THEN
      GMD_API_PUB.Log_Message('GMD_CUSTOMER_REQD');
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      OPEN c_cust;
      FETCH c_cust INTO dummy;
      IF c_cust%NOTFOUND THEN
        CLOSE c_cust;
        GMD_API_PUB.Log_Message('GMD_CUSTOMER_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_cust;
    END IF;

         -- Org ID
         --IF (p_sample.org_id IS NOT NULL) THEN
         --  OPEN c_org;
         --  FETCH c_org INTO dummy;
         --  IF c_cust%NOTFOUND THEN
         --    CLOSE c_org;
         --    GMD_API_PUB.Log_Message('GMD_ORG_NOT_FOUND');
         --    RAISE FND_API.G_EXC_ERROR;
         --  END IF;
         --  CLOSE c_org;
         --END IF;

    -- Ship To
    IF (p_sample.ship_to_site_id IS NOT NULL) THEN
      OPEN c_ship_to;
      FETCH c_ship_to INTO dummy;
      IF c_ship_to%NOTFOUND THEN
        CLOSE c_ship_to;
        GMD_API_PUB.Log_Message('GMD_SHIP_TO_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_ship_to;
    END IF;

    -- Order ID
    IF (p_sample.order_id IS NOT NULL) THEN
      OPEN c_order;
      FETCH c_order INTO dummy;
      IF c_order%NOTFOUND THEN
        CLOSE c_order;
        GMD_API_PUB.Log_Message('GMD_ORDER_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_order;
    END IF;

    -- Order Line ID
    IF (p_sample.order_line_id IS NOT NULL) THEN
      OPEN c_order_line;
      FETCH c_order_line INTO dummy;
      IF c_order_line%NOTFOUND THEN
        CLOSE c_order_line;
        GMD_API_PUB.Log_Message('GMD_ORDER_LINE_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_order_line;
    END IF;

  END IF; -- Validation for Customer Sample

  IF (p_sample.source = 'S') THEN
    -- Sample is from source 'Supplier' so check only
    -- those parameters related to Supplier

    -- Supplier
    IF (p_sample.supplier_id IS NULL) THEN
      GMD_API_PUB.Log_Message('GMD_SUPPLIER_REQD');
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (p_sample.supplier_id IS NOT NULL) THEN
      OPEN c_supplier;
      FETCH c_supplier INTO dummy;
      IF c_supplier%NOTFOUND THEN
        CLOSE c_supplier;
        GMD_API_PUB.Log_Message('GMD_SUPPLIER_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_supplier;
    END IF;

    -- PO
    IF (p_sample.po_header_id IS NOT NULL) THEN
      OPEN c_po;
      FETCH c_po INTO dummy;
      IF c_po%NOTFOUND THEN
        CLOSE c_po;
        GMD_API_PUB.Log_Message('GMD_PO_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_po;
    END IF;

    -- PO Line
    IF (p_sample.po_line_id IS NOT NULL) THEN
      OPEN c_po_line;
      FETCH c_po_line INTO dummy;
      IF c_po_line%NOTFOUND THEN
        CLOSE c_po_line;
        GMD_API_PUB.Log_Message('GMD_PO_LINE_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_po_line;
    END IF;


  END IF; -- Validation for Supplier Sample

-- lpn_id 7027149

  IF (p_sample.lpn_id IS NOT NULL ) THEN
      	OPEN get_wms_flag;
  	  	FETCH get_wms_flag INTO l_wms_enabled_flag;
      	CLOSE get_wms_flag;

  	    IF l_wms_enabled_flag = 'N' then
          GMD_API_PUB.Log_Message('WMS_ONLY_FUNCTIONALITY');
        	RAISE FND_API.G_EXC_ERROR;
      	END IF;

  END IF;  -- IF (p_sample.lpn_id IS NOT NULL or p_sample.lpn IS NOT NULL ) THEN

  IF p_sample.lpn_id IS NOT NULL THEN
    	OPEN get_lpn;
			FETCH get_lpn INTO dummy;
			IF get_lpn%NOTFOUND THEN
        CLOSE get_lpn;
        GMD_API_PUB.Log_Message('WMS_LPN_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
		 CLOSE get_lpn;
   END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END check_for_null_and_fks_in_smpl;


--Start of comments
--+========================================================================+
--| API Name    : GMIGAPI_format                                           |
--| TYPE        : Group                                                    |
--| Notes       : This function returns the format of GMAGAPI which        |
--|               is used by the inventory transaction in the samples      |
--|               form gmdqsmpl.fmb                                        |
--|                                                                        |
--| HISTORY                                                                |
--|    S. Feinstein     22-SEQ-2002     Created.                           |
--|    Bug 4165704: taken out for Inventory Convergence                    |
--|                                                                        |
--+========================================================================+
--FUNCTION GMIGAPI_format RETURN GMIGAPI.qty_rec_typ IS
--l_temp   GMIGAPI.qty_rec_typ;
--BEGIN
--     return  l_temp;
--END GMIGAPI_format;

--+========================================================================+
--| API Name    : create_inv_txn                                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure creates Inventory transaction for         |
--|               sample quantity for all sample types except WIP sample.  |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	13-Nov-2002	Created.                           |
--|    This procedure has been transferred from the form.                  |
--|    Bug 4165704: updated for Inventory Convergence                      |
--|                                                                        |
--| RLNAGARA 09-Mar-2006 Bug 4753039 Added IF cond.                        |
--| RAGSRIVA 29-Jun-2006 Bug 5332105 Modified cursor fetch_subinventory_loc|
--|                      and changed length of l_msg_data from 200 to 2000 |
--+========================================================================+

PROCEDURE create_inv_txn
( p_sample        IN         GMD_SAMPLES%ROWTYPE
, p_user_name     IN         NUMBER
, x_return_status OUT NOCOPY VARCHAR2
, x_message_count OUT NOCOPY NUMBER
, x_message_data  OUT NOCOPY VARCHAR2
)
IS
  -- Bug# 5332105
  -- Added additional where clause destination_type_code = 'INVENTORY' and rt.transaction_type   = 'DELIVER'
  -- since subinventory and locator information exists only for inventory transaction and not for RECEIVING
  CURSOR fetch_subinventory_loc IS
    SELECT DISTINCT subinventory,
                    locator_id
    FROM  rcv_transactions rt
    WHERE rt.shipment_header_id = p_sample.receipt_id
      AND rt.shipment_line_id   = p_sample.receipt_line_id
      AND rt.destination_type_code = 'INVENTORY'
      AND rt.transaction_type   = 'DELIVER';

  CURSOR Cur_get_seq IS
    SELECT mtl_material_transactions_s.NEXTVAL
    FROM DUAL;

  p_validation_level NUMBER := 100;

  -- 2995114
  -- add position variable for debugging.

  quality_config GMD_QUALITY_CONFIG%ROWTYPE;
  l_revision                 VARCHAR2(3);
  l_subinventory             VARCHAR2(10);
  l_locator_id               NUMBER;
  l_msg_count                NUMBER;
  processed                  NUMBER;
  l_msg_data                 VARCHAR2(2000); -- Bug# 5332105 changed length from 200 to 2000
  p_transaction_interface_id NUMBER;
  p_header_id                 NUMBER;
  l_trans_count              NUMBER;
  found                      BOOLEAN;

  l_position	             VARCHAR2(3) := '010' ;

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get the reason code
  GMD_QUALITY_PARAMETERS_GRP.get_quality_parameters(
                       p_organization_id    => p_sample.organization_id
	               , x_quality_parameters => quality_config
                       , x_return_status      => x_return_status
                       , x_orgn_found         => found );

  IF (x_return_status <> 'S') THEN
       GMD_API_PUB.Log_Message('GMD_QM_INV_REASON_CODE');
       RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_position  := '020' ;

    --IF NOT GMIGUTL.setup(FND_GLOBAL.USER_NAME)  THEN
    --  Error Message must have been logged.
    --  RAISE FND_API.G_EXC_ERROR;
    --END IF;
    --l_trans_rec.trans_type      := 2;       -- adjustment transaction

  l_position  := '030' ;

  OPEN  Cur_get_seq;
  FETCH Cur_get_seq INTO p_transaction_interface_id;
  CLOSE Cur_get_seq;

  OPEN  Cur_get_seq;
  FETCH Cur_get_seq INTO p_header_id;
  CLOSE Cur_get_seq;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('In Procedure create_inv_txn');
     gmd_debug.put_line('Input to mtl_transaction_lots_interface table=');
     gmd_debug.put_line('  transaction interface ID: ' || p_transaction_interface_id);
     gmd_debug.put_line('  header ID: ' || p_header_id);
     gmd_debug.put_line('  Sample ID: ' || p_sample.sample_id);
     gmd_debug.put_line('  user name : ' || p_user_name);
     gmd_debug.put_line('  date : ' || p_sample.date_drawn);
     gmd_debug.put_line('  qty : ' ||  -1*p_sample.sample_qty);
     gmd_debug.put_line('  lot : ' ||  p_sample.lot_number);
     gmd_debug.put_line('  reason id : ' ||  quality_config.transaction_reason_id);
  END IF;

  l_position  := '040' ;

--gml_sf_log('b4 insert');
  -- create entry in mtl_transaction_lots_interface table (MTLI)

--RLNAGARA Bug4753039 Insert into this table only for lot controlled item ie when the lot number is not null
--because from the form we are passing lot number as NULL for Non-lot controlled items.

IF p_sample.lot_number IS NOT NULL THEN
  INSERT INTO mtl_transaction_lots_interface
             ( transaction_interface_id
            ,  source_code
            ,  source_line_id
            ,  last_updated_by
            ,  last_update_date
            ,  created_by
            ,  creation_date
            ,  last_update_login
            ,  transaction_quantity
            ,  lot_number
            ,  reason_id
            ,  description         )
  VALUES
             (  p_transaction_interface_id
            ,   'SAMPLES'
            ,   p_sample.sample_id
            ,   p_user_name
            ,   p_sample.date_drawn
            ,   p_user_name
            ,   p_sample.date_drawn
            ,   p_user_name
            ,   -1*p_sample.sample_qty
            ,   p_sample.lot_number
            ,   quality_config.transaction_reason_id
            ,   'Sample creation');
END IF;



  l_position  := '050' ;

  IF p_sample.source = 'S' THEN  -- supplier samples
       IF p_sample.receipt_id is not null AND p_sample.receipt_line_id is not null THEN
          OPEN  fetch_subinventory_loc;
          FETCH fetch_subinventory_loc INTO l_subinventory,
                                            l_locator_id;
          CLOSE fetch_subinventory_loc;
       END IF;
  ELSIF p_sample.source = 'W' THEN
     l_subinventory   := p_sample.source_subinventory ;
     l_locator_id     := p_sample.source_locator_id ;
  ELSE
     l_subinventory   := p_sample.subinventory ;
     l_locator_id     := p_sample.locator_id ;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('after insert into lot table:');
     gmd_debug.put_line(' subinventory = '||l_subinventory);
     gmd_debug.put_line(' locator id = '||l_locator_id);
     gmd_debug.put_line(' sample source = '||p_sample.source);
  END IF;

         -- Bug 4165704: uom convergence not needed after inventory convergence
         --  l_item_rec.inventory_item_id := p_sample.inventory_item_id;
         --  l_item_rec.organization_id   := p_sample.organization_id;

         --  Gmd_samples_grp.Get_item_values( p_sample_display => l_item_rec);

         --   IF l_item_rec.Dual_uom_control = 3 THEN
         --       l_trans_rec.trans_qty2
         --     := INV_CONVERT.inv_um_convert(
         --    item_id       => p_sample.inventory_item_id
         --                      , precision     => 5
         --                      , from_quantity => p_sample.sample_qty
         --                      , from_unit     => p_sample.sample_qty_uom
         --                      , to_unit       => l_item_rec.primary_uom_code
         --                      , from_name     => NULL
         --                      , to_name       => NULL);

         --      IF l_trans_rec.trans_qty2 < 0) THEN
         --           GMD_API_PUB.Log_Message('FM_SCALE_BAD_UOM_CONV',
         --                                'FROM_UOM',p_sample.sample_qty_uom,
         --                                'TO_UOM',  l_item_rec.primary_uom_code ,
         --                                'ITEM_NO', item_rec.item_number);
         --
         --           RAISE FND_API.G_EXC_ERROR;
         --      END IF;
         --  ELSE
         --      l_trans_rec.trans_qty2 := NULL ;
         --  END IF;

  l_position  := '060' ;
--gml_sf_log('b4 second insert and locator_id ='||l_locator_id);

    -- Create the record for mtl_transaction_interface_table (MTI)
  INSERT INTO mtl_transactions_interface
              (transaction_interface_id
            ,  transaction_header_id
            ,  source_code
            ,  source_line_id
            ,  source_header_id
            ,  process_flag
            ,  validation_required
            ,  transaction_mode
            ,  lock_flag
            ,  last_updated_by
            ,  last_update_date
            ,  created_by
            ,  creation_date
            ,  last_update_login
            ,  organization_id
            ,  inventory_item_id
            ,  revision
            ,  transaction_quantity
            ,  transaction_uom
            ,  transaction_date
            ,  subinventory_code
	    ,  locator_id
            ,  transaction_source_id
	    ,  transaction_source_type_id
            ,  transaction_type_id
            ,  distribution_account_id
            ,  reason_id              )
  VALUES
              ( p_transaction_interface_id
            ,   p_header_id
            ,   'SAMPLES'
            ,   p_sample.sample_id
            ,   p_sample.sampling_event_id
            ,   1                                        -- process enabled
            ,   1                                        -- (full validation required)
            ,   1                                        -- (process immediate)
            ,   2                                        -- (TM will not lock the trans)
            ,   p_user_name
            ,   p_sample.date_drawn
            ,   p_user_name
            ,   p_sample.date_drawn
            ,   p_user_name
            ,   p_sample.Organization_id
            ,   p_sample.Inventory_Item_id
            ,   p_sample.revision
            ,   -1*p_sample.sample_qty
            ,   P_sample.sample_qty_uom
            ,   p_sample.date_drawn
            ,   l_subinventory
	    ,   l_locator_id
            ,   NULL
	    ,   13                                        --(Inventory)
            ,   1001                                      --(Deduct Sample Qty)
            ,   quality_config.distribution_account_id    --hardcode 23843 take this out xxx
            ,   quality_config.transaction_reason_id) ;

  l_position  := '070' ;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('after insert into transaction table:');
  END IF;

--gml_sf_log('b4 call to process transactions and header id ='|| p_header_id);
-- only to test error_code in mtl_transactions_interface uncomment the following commit
--     commit;
     --call transaction manager
  processed :=  INV_TXN_MANAGER_PUB.PROCESS_TRANSACTIONS
	(p_api_version        => 1.0
	,p_init_msg_list      => fnd_api.g_false
	,p_commit             => fnd_api.g_false
	,p_validation_level   => p_validation_level
        ,x_return_status      => x_return_status
	,x_msg_count          => l_msg_count
	,x_msg_data           => l_msg_data
	,x_trans_count        => l_trans_count
	,p_table	      => 1         -- (MTI)
	,p_header_id          => p_header_id);   -- foreign key to MTI, can be null

--gml_sf_log('after call and return value='||processed||'  and status='||x_return_status);
  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('after INV_TXN_MANAGER_PUB.PROCESS_TRANSACTIONS status ='||processed);
  END IF;

  IF processed < 0 THEN
	  -- x_message_count and x_msg_data is already populated
	RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','CREATE_INV_TXN',
                            'ERROR', SUBSTR(SQLERRM,1,100),
                            'POSITION',l_position);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END create_inv_txn;


--Start of comments
--+========================================================================+
--| API Name    : create_wip_txn                                           |
--| TYPE        : Group                                                    |
--| Notes       : This procedure creates Inventory transaction for         |
--|               WIP sample.                                              |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	13-Nov-2002	Created.                           |
--|    This procedure has been transferred from the form.                  |
--|                                                                        |
--|Saikiran Vankadari   15-JUL-2004     Bug# 3741488. Added item_um to the |
--|                           cursor Cur_material_detail_no_step. Added IF |
--|                        condition to check if replenish whse_code exists|
--|                                                                        |
--|    S Feinstein   21-MAR-2005       Inventory Convergence bug 41165704  |
--|     - batch update proc changed from gme_api_pub.insert_line_allocation|
--|       to gme_api_pub.create_material_txn                               |
--|    srakrish bug 5394566: Commenting the cursors as these have 	   |
--|		hardcoded values and material_detail_id is directly passed |
--|  RAGSRIVA   01-Nov-2006 Bug 5629709 Modified procedure create_wip_txn  |
--|             to Undo the fix for bug# 5394566 and pass the transaction  |
--|             type id and the lot information in the call to             |
--|             GME_API_PUB.create_material_txn                            |
--| RLNAGARA 12-Jan-2007 B5738041 Added Revision to the cursors Cur_material_detail_with_step |
--|                               and Cur_material_detail_no_step            |
--+========================================================================+
-- End of comments

PROCEDURE create_wip_txn
( p_sample        IN         GMD_SAMPLES%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
, x_message_count OUT NOCOPY NUMBER
, x_message_data  OUT NOCOPY VARCHAR2
)
IS

  -- bug# 2995114
  -- removed Cursors Cur_replenish_whse and  Cur_replenish_whse_plant
  -- instead moved it into public layer api

   CURSOR Cur_global_configurator IS
     SELECT transaction_reason_id
     FROM   gmd_quality_config
     WHERE  organization_id = p_sample.organization_id
     order by 1 ;

  --srakrish bug 5394566: Commenting the cursors as these have hardcoded values and material_detail_id is directly passed .
  -- Bug# 5629709 uncomment the cursor since its required to check if the sample item is defined as a byproduct in the batch
  -- with byproduct type as sample.
  CURSOR Cur_material_detail_with_step IS
     SELECT d.material_detail_id,
            d.inventory_item_id, d.revision, d.dtl_um  --RLNAGARA B5738041 Added Revision
     FROM   gme_material_details d,
            gme_batch_step_items i
     WHERE  d.material_detail_id = i.material_detail_id
       AND  d.line_type = 2
       AND  d.release_type = 1
       AND  d.by_product_type = 'S'
       AND  d.batch_id = p_sample.batch_id
       AND  d.inventory_item_id  = p_sample.inventory_item_id
       AND  (p_sample.step_id IS NULL
        OR   i.batchstep_id = p_sample.step_id);

  CURSOR Cur_material_detail_no_step IS
     SELECT d.material_detail_id,
            d.inventory_item_id, d.revision, d.dtl_um  --RLNAGARA B5738041 Added Revision
     FROM   gme_material_details d
     WHERE  d.line_type = 2
       AND  d.release_type = 1
       AND  d.by_product_type = 'S'
       AND  d.batch_id = p_sample.batch_id
       AND  d.inventory_item_id  = p_sample.inventory_item_id;

  CURSOR c_item_no(p_item_id NUMBER) IS
  SELECT concatenated_segments item_no ,
         dual_uom_control,
         primary_uom_code,
         secondary_uom_code
  FROM   mtl_system_items_b_kfv
  WHERE  inventory_item_id = p_item_id
    AND  organization_id   = p_sample.organization_id;

  -- bug 4165704: following added for new GME proc
  p_mmti_rec  	     mtl_transactions_interface%ROWTYPE;
  p_mmli_tbl 	     gme_common_pvt.mtl_trans_lots_inter_tbl;
  x_mmt_rec	     mtl_material_transactions%ROWTYPE;
  x_mmln_tbl 	     gme_common_pvt.mtl_trans_lots_num_tbl;

  --p_tran_row         gme_inventory_txns_gtmp%ROWTYPE;
  --x_material_detail  gme_material_details%ROWTYPE;
  --x_tran_row         gme_inventory_txns_gtmp%ROWTYPE;
  x_def_tran_row     gme_inventory_txns_gtmp%ROWTYPE;
  p_validation_level NUMBER := 100;      --gme_api_pub.max_errors;

  message_number     NUMBER := 0;
  dummy_cnt          NUMBER := 0;
  dummy_number       NUMBER := 0;

  p_create_lot       VARCHAR2(10) ;    --BOOLEAN := TRUE;
  temp_lot_no        VARCHAR2(32) := NULL;
  material_detail_item_um gme_material_details.dtl_um%TYPE;
  l_item_no          VARCHAR2(80);
  l_dualum_ind	     NUMBER(1);
  l_item_um2	     VARCHAR2(3);
  l_primary_uom_code VARCHAR2(3);

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- test for batch id, step id and material detail
  IF p_sample.batch_id IS NULL THEN
    GMD_API_PUB.Log_Message('GMD_INVALID_PARAMETERS');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --srakrish bug 5394566: Commenting the cursors as these have hardcoded values and material_detail_id is directly passed.

  -- Bug# 5629709 uncomment the following since its required to check if the sample item is defined as a byproduct in the batch
  -- with byproduct type as sample.
  OPEN  Cur_material_detail_with_step;
  FETCH Cur_material_detail_with_step INTO p_mmti_rec.trx_source_line_id,
                                           p_mmti_rec.inventory_item_id,
                                           p_mmti_rec.revision,           --RLNAGARA B5738041 Added Revision
                                           material_detail_item_um;
  IF  (Cur_material_detail_with_step%NOTFOUND ) THEN
      OPEN  Cur_material_detail_no_step;
      --Bug# 3741488. Added item_um to the cursor
      FETCH Cur_material_detail_no_step INTO p_mmti_rec.trx_source_line_id,
                                             p_mmti_rec.inventory_item_id,
                                             p_mmti_rec.revision,           --RLNAGARA B5738041 Added Revision
                                             material_detail_item_um;
      CLOSE Cur_material_detail_no_step;
  END IF;
  CLOSE Cur_material_detail_with_step;

   --srakrish bug 5394566: Assigning the values passed to procedure.
  -- Bug# 5629709 comment the following code since its fetched above
  /*p_mmti_rec.trx_source_line_id := p_sample.material_detail_id;
  p_mmti_rec.inventory_item_id  := p_sample.inventory_item_id;
  material_detail_item_um	:= p_sample.sample_qty_uom;*/

  -- Verify that we have the trx_source_line_id (material_detail_id)
  IF p_mmti_rec.trx_source_line_id IS NULL THEN
    GMD_API_PUB.Log_Message('GMD_MATERIAL_DTL_NOT_FOUND');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN c_item_no (p_sample.inventory_item_id);
  FETCH c_item_no INTO l_item_no ,
                       l_dualum_ind ,
                       l_primary_uom_code ,
                       l_item_um2;
  CLOSE c_item_no;

  -- When the transation is getting updated in the GME make sure it is in alloc_qty

  IF material_detail_item_um <> p_sample.sample_qty_uom THEN
                   -- bug 4165704: conversion routine changed
                   -- p_tran_row.transaction_quantity := gmicuom.uom_conversion(
                   --                                   p_sample.inventory_item_id,
                   --                                   0,
                   --                                   p_sample.sample_qty,
                   --                                   p_sample.sample_qty_uom,
                   --                                   material_detail_item_um,
                   --                                   0);

     p_mmti_rec.transaction_quantity := INV_CONVERT. inv_um_convert (
	                               item_id         => p_sample.inventory_item_id,
	                               lot_number      => 0,
	                               organization_id => p_sample.organization_id,
	                               precision       => 5,     -- decimal point precision
	                               from_quantity   => p_sample.sample_qty,
	                               from_unit       => p_sample.sample_qty_uom,
	                               to_unit         => l_primary_uom_code,
	                               from_name       => NULL	,
	                               to_name         => NULL) ;
  IF (l_debug = 'Y') THEN
    gmd_debug.put_line('After uom conversion qty2 ='|| p_mmti_rec.transaction_quantity);
  END IF;

      IF (p_mmti_rec.transaction_quantity< 0 ) THEN
        GMD_API_PUB.Log_Message('FM_SCALE_BAD_UOM_CONV',
                                'FROM_UOM',p_sample.sample_qty_uom,
                                'TO_UOM',material_detail_item_um,
                                'ITEM_NO',l_item_no);
        RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  -- Get the reason code from the global configurator
  OPEN  Cur_global_configurator;
  FETCH Cur_global_configurator INTO p_mmti_rec.reason_id ;
  IF Cur_global_configurator%NOTFOUND THEN
    CLOSE Cur_global_configurator;
    GMD_API_PUB.Log_Message('GMD_QM_INV_REASON_CODE');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE Cur_global_configurator;

 -- bug# 2995114
 -- implement fix as done in forms.refer to forms bug# 2719300 for more details.
 -- if source whse specified take that warehouse.
  p_mmti_rec.subinventory_code := p_sample.source_subinventory ;


  -- bug# 2995114
  -- API errors out if no location was passed in case item and warehouse are both location controlled.
  -- pass source location to the API
  p_mmti_rec.locator_id      := p_sample.source_locator_id;

  --Bug# 3741488. Added IF condition to check if replenish whse_code exists
  -- API call to create an inventory insert transaction
  IF p_mmti_rec.subinventory_code IS NOT NULL THEN

          IF (p_mmti_rec.transaction_quantity IS NULL ) THEN
	    p_mmti_rec.transaction_quantity     := p_sample.sample_qty;
	  END IF;

	  p_mmti_rec.transaction_uom           := p_sample.sample_qty_uom;
	  p_mmti_rec.transaction_date          := NULL;
	  p_mmti_rec.secondary_transaction_quantity := NULL;
	        -- bug 4165704 - no equivalent for the following
	        -- p_tran_row.doc_id           := p_sample.batch_id;xxx
                -- p_tran_row.alloc_um         := p_sample.sample_qty_uom;
	        -- p_tran_row.completed_ind    := 1;

	  IF l_dualum_ind = 3 THEN
                        -- bug 4165704: changed uom conversion routine for inventory convergence
	                -- p_mmti_rec.secondary_transaction_quantity := gmicuom.uom_conversion(
                        --                              p_sample.inventory_item_id,
			--			      0,
			--			      p_sample.sample_qty,
			--			      p_sample.sample_qty_uom,
			--			      l_item_um2,
			--			      0);

              p_mmti_rec.secondary_transaction_quantity := INV_CONVERT. inv_um_convert (
	                                       item_id         => p_sample.inventory_item_id,
	                                       lot_number      => 0,
	                                       organization_id => p_sample.organization_id,
	                                       precision       => 5,     -- decimal point precision
        	                               from_quantity   => p_sample.sample_qty,
	                                       from_unit       => p_sample.sample_qty_uom,
	                                       to_unit         => l_item_um2,
	                                       from_name       => NULL	,
	                                       to_name         => NULL) ;

	      IF (p_mmti_rec.secondary_transaction_quantity< 0 ) THEN
		 GMD_API_PUB.Log_Message('FM_SCALE_BAD_UOM_CONV',
					'FROM_UOM',p_sample.sample_qty_uom,
					'TO_UOM',l_item_um2,
					'ITEM_NO',l_item_no);
		 RAISE FND_API.G_EXC_ERROR;
	      END IF;
	  ELSE
	      p_mmti_rec.secondary_transaction_quantity := NULL;
	  END IF;

	  IF p_sample.lot_number IS NOT NULL THEN
	    -- lot exists
	    p_mmti_rec.source_lot_number := p_sample.lot_number;
	    p_create_lot                 := FND_API.G_FALSE;  -- FALSE;
	    temp_lot_no                  := NULL;
	  ELSE
	    -- lot does not exists and needs to be created
	    p_mmti_rec.source_lot_number := NULL;
	    p_create_lot                 := FND_API.G_TRUE;  --TRUE;
	    temp_lot_no                  := p_sample.lot_number;
	  END IF;      -- test for lot id

                 -- Bug 4165704: gme_api_pub.insert_line_allocation replaced by create_material_txns
   	          -- GME_API_PUB.insert_line_allocation(
	          --  p_api_version                     => 2.0
	          --, p_validation_level                => p_validation_level
	          --, p_init_msg_list                   => FALSE
	          --, p_commit                          => FALSE
	          --, x_message_count                   => x_message_count
	          --, x_message_list                    => x_message_data
	          --, x_return_status                   => x_return_status
	          --, p_material_transaction_inter_rec  => p_material_transaction_inter_rec
	          --, p_batch_no                        => NULL
	          --, p_org_code                        => NULL
	          --, p_line_no                         => NULL
	          --, p_line_type                       => NULL
	          --, p_create_lot                      => p_create_lot        --TRUE
	          --, p_generate_lot                    => FALSE
	          --, p_generate_parent_lot             => FALSE
	          --, p_transaction_lot_inter_tbl       => FALSE               -- lot info for lot interface table
	          --, x_material_trasaction_rec         => x_material_detail   -- contains the newly created transaction
	          --, x_transaction_lot_tbl             => x_tran_row);        -- contains info for lot transactions

          p_mmti_rec.organization_id    := p_sample.organization_id;

	  -- Bug# 5629709 Pass the transaction_type_id and lot information
	  p_mmti_rec.transaction_type_id := 1002;
	  IF p_sample.lot_number IS NOT NULL THEN
	     p_mmli_tbl(1).lot_number := p_sample.lot_number;
	     p_mmli_tbl(1).transaction_quantity := p_mmti_rec.transaction_quantity;
	     p_mmli_tbl(1).primary_quantity := p_mmti_rec.transaction_quantity;
	     p_mmli_tbl(1).secondary_transaction_quantity := p_mmti_rec.secondary_transaction_quantity;
	  END IF;

	  GME_API_PUB.create_material_txn(
	     p_api_version                     => 2.0
	   , p_validation_level                => p_validation_level
	   , p_init_msg_list                   => fnd_api.g_false   --FALSE
	   , p_commit                          => fnd_api.g_false   --FALSE
	   , x_message_count                   => x_message_count
	   , x_message_list                    => x_message_data
	   , x_return_status                   => x_return_status
           , p_org_code                        => NULL
           , p_mmti_rec		               => p_mmti_rec
	   , p_mmli_tbl                        => p_mmli_tbl
           , p_batch_no                        => NULL
           , p_line_no                         => NULL
           , p_line_type                       => NULL
           , p_create_lot                      => p_create_lot       -- TRUE
           , p_generate_lot                    => fnd_api.g_false    --FALSE
           , p_generate_parent_lot             => fnd_api.g_false    --FALSE
           , x_mmt_rec		               => x_mmt_rec           -- contains the newly created transaction
	   , x_mmln_tbl                        => x_mmln_tbl );       -- contains info for lot transactions

	  IF (X_return_status <> 'S') THEN
	    -- x_message_count and x_message_data is already populated
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
   ELSE
          -- Bug 3492053: if replenish whse is not there inventory is not generated
          GMD_API_PUB.Log_Message('GMD_QM_NO_INVENTORY_TRANS');
          RAISE FND_API.G_EXC_ERROR;
   END IF;     -- check for replenish whse code

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','INVENTORY_TRANS_INSERT',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END create_wip_txn;




--Start of comments
--+========================================================================+
--| API Name    : post_wip_txn                                             |
--| TYPE        : Group                                                    |
--| Notes       : This procedure calls GME public API - save_batch to      |
--|               write transactions from the temporary tables to actual   |
--|               tables.                                                  |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	13-Nov-2002	Created.                           |
--|    This procedure has been transferred from the form.                  |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE post_wip_txn
( p_batch_id      IN         NUMBER
, x_return_status OUT NOCOPY VARCHAR2
) IS

  l_batch_header       GME_BATCH_HEADER%ROWTYPE;
  l_return_status      VARCHAR2(1);

BEGIN

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_batch_header.batch_id := p_batch_id;

/* took this code out but must put back gme functionality
  gme_api_pub.save_batch(p_batch_header  => l_batch_header,
                         p_commit        => FALSE,
                         x_return_status => l_return_status);

  IF (l_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
*/
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','POST_WIP_TXN',
                            'ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END post_wip_txn;


--Start of comments
--+========================================================================+
--| API Name    : find_max_test_duration                                   |
--| TYPE        : Group                                                    |
--| Notes       : This procedure is called by samples to help validate     |
--|               the required date.  It gets the maximum test duration    |
--|               of all tests for the samples spec.                       |
--|                                                                        |
--|               It will return the maximum duration time and a test      |
--|               test description for a test having that duration         |
--|                                                                        |
--| HISTORY                                                                |
--|    Susan Feinstein  27-Jan-2003  Created for bug 2752102               |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE get_max_test_method_duration
( p_spec_id       IN  NUMBER
, x_test_dur      OUT NOCOPY NUMBER
, x_test_code     OUT NOCOPY VARCHAR2
) IS

  Cursor Cur_find_max_dur IS
    SELECT qc.test_code, mthd.test_duration
    FROM   gmd_qc_tests_vl qc,
           gmd_test_methods_b mthd,
           gmd_spec_tests_b spec
    WHERE  qc.test_method_id = mthd.test_method_id
      AND  qc.test_id = spec.test_id
      AND  spec.spec_id = p_spec_id
      AND ( mthd.test_duration = (SELECT MAX(test_duration)
                                  FROM   gmd_test_methods_b mthd2,
                                         gmd_spec_tests_b spec2
                                  WHERE  spec2.TEST_METHOD_ID = mthd2.test_method_id
         	                    AND  spec2.spec_id = p_spec_id));

BEGIN
   x_test_dur := 0;

   OPEN  Cur_find_max_dur;
   FETCH Cur_find_max_dur  INTO x_test_code,
                                x_test_dur ;
   CLOSE Cur_find_max_dur;


END get_max_test_method_duration;


--Start of comments
--+========================================================================+
--| API Name    : update_remaining_qty                                     |
--| TYPE        : Group                                                    |
--| Notes       : This procedure is called by results to update the        |
--|               remaining quantity on the samples table.                 |
--|                                                                        |
--| HISTORY                                                                |
--|    Susan Feinstein  05-Aug-2003  Created for bug 3088216               |
--|    RLNAGARA         04-Apr-2006  B5106199 UOM Conv Changes             |
--+========================================================================+
-- End of comments

PROCEDURE update_remaining_qty
( p_result_id     IN  NUMBER,
  p_sample_id     IN  NUMBER default 0,
  qty             IN  NUMBER,
  x_return_status OUT NOCOPY VARCHAR2
) IS

--RLNAGARA B5106191 Replaced the query in the cursor C_item_no which was using ic_item_mst.
/*  CURSOR C_item_no(item_id VARCHAR2) IS
  SELECT item_no
  FROM   ic_item_mst
  WHERE  item_id = item_id;
*/
  CURSOR C_item_no(p_inventory_item_id NUMBER,p_organization_id NUMBER) IS
  SELECT concatenated_segments item_number
  FROM   mtl_system_items_kfv
  WHERE  inventory_item_id = p_inventory_item_id
  AND    organization_id = p_organization_id;



     -- added this code to prevent locking error if sample is locked by another form.
  CURSOR C_lock_sample(samp_id NUMBER) IS
  SELECT 'x' from gmd_samples
  where sample_id = samp_id
  for update of sample_id NOWAIT ;

  record_lock        EXCEPTION ;
  pragma exception_init(record_lock,-00054) ;
     -- end update for locking error

  l_in_samples  gmd_samples%ROWTYPE;
  l_samples     gmd_samples%ROWTYPE;

  l_in_results  gmd_results%ROWTYPE;
  l_results     gmd_results%ROWTYPE;

  l_samples_item_no  VARCHAR2(32);

  converted_qty  NUMBER;

  result         BOOLEAN;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('In Procedure update_remaining_qty');
     gmd_debug.put_line('Input Parameters=');
     gmd_debug.put_line('  Result ID: ' || p_result_id);
     gmd_debug.put_line('  Sample ID: ' || p_sample_id);
     gmd_debug.put_line('  Quantity : ' || qty);
  END IF;

    -- Get the results record
  l_in_results.result_id := p_result_id;
  result := GMD_RESULTS_PVT.fetch_row(
		   p_results => l_in_results,
	   x_results => l_results);

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('after fetch row from result');
  END IF;

    -- If sample_id is specified use it.  If not, get sample_id from result
  IF (p_sample_id > 0) THEN

     IF (l_debug = 'Y') THEN
	gmd_debug.put_line('1');
     END IF;

     l_in_samples.sample_id := p_sample_id;
  ELSE

     IF (l_debug = 'Y') THEN
	gmd_debug.put_line('2');
     END IF;

       -- Get the sample id from the results record
     IF (l_results.reserve_sample_id IS NULL) THEN
	l_in_samples.sample_id := l_results.sample_id;
     ELSE
	l_in_samples.sample_id := l_results.reserve_sample_id;
     END IF;
  END IF;

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('sample id changed to: ');
     gmd_debug.put_line('  Sample ID: ' ||  l_in_samples.sample_id);
  END IF;

  result := GMD_SAMPLES_PVT.fetch_row(
		   p_samples => l_in_samples,
		   x_samples => l_samples);

  IF (l_debug = 'Y') THEN
     gmd_debug.put_line('quantities = ');
     gmd_debug.put_line('  Sample qty: ' ||  l_samples.sample_qty);
     gmd_debug.put_line('  Remaining qty: ' ||  l_samples.remaining_qty);
     gmd_debug.put_line('  other qty: ' ||  qty);
     gmd_debug.put_line('result uom: '||l_results.test_qty_uom);
     gmd_debug.put_line('sample uom: '||l_samples.sample_qty_uom);
  END IF;


    -- Bug 3251084: if sample_qty or test_qty are null, then no need
    --              to update the remaining qty. Leave this procedure.
    -- Bug 3278903: test qty should not be tested here.  Changed to qty.
  IF ((NVL(l_samples.sample_qty, 0) = 0 )
       OR (NVL(qty, 0) = 0)) THEN
    RETURN;
  END IF;

    -- Convert consumed qty to sample_qty_uom
  IF l_results.test_qty_uom <> l_samples.sample_qty_uom THEN

--RLNAGARA B5106199 Replaced the call gmicuom.uom_conversion with INV_CONVERT.inv_um_convert below
/*     converted_qty := gmicuom.uom_conversion(l_samples.inventory_item_id,
					    0,
					    qty,
					    l_results.test_qty_uom,
					    l_samples.sample_qty_uom,
					    0);
*/

  converted_qty :=  INV_CONVERT.inv_um_convert(
      item_id           => l_samples.inventory_item_id,
      lot_number        => NULL,
      organization_id   => l_samples.organization_id,
      precision	        => 5,
      from_quantity     => qty,
      from_unit         => l_results.test_qty_uom,
      to_unit           => l_samples.sample_qty_uom,
      from_name	      	=> NULL,
      to_name	        => NULL);

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('after conversion : ');
       gmd_debug.put_line('converted qty : '|| converted_qty);
    END IF;

    IF (converted_qty < 0 ) THEN

	OPEN  C_item_no(l_samples.inventory_item_id,l_samples.organization_id ); --RLNAGARA B5106191 passing organization_id also
	FETCH C_item_no INTO l_samples_item_no;
	CLOSE C_item_no;

	GMD_API_PUB.Log_Message('FM_SCALE_BAD_UOM_CONV',
				'FROM_UOM',l_results.test_qty_uom,
				'TO_UOM', l_samples.sample_qty_uom,
				'ITEM_NO',l_samples_item_no);
	RAISE FND_API.G_EXC_ERROR;

       -- Bug 3088216: update samples remaining qty
    ELSIF converted_qty <= l_samples.remaining_qty THEN

	 IF (l_debug = 'Y') THEN
	    gmd_debug.put_line('before update : ');
	 END IF;

	  -- added this code to prevent locking error if sample is locked by another form.
	 OPEN  C_lock_sample(l_samples.sample_id);
	 CLOSE C_lock_sample;

	 UPDATE gmd_samples
	 SET    remaining_qty = remaining_qty - converted_qty
	 WHERE  sample_id     = l_samples.sample_id;

    ELSE
	GMD_API_PUB.Log_Message('GMD_QM_REMAIN_QTY_NEG');
	RAISE FND_API.G_EXC_ERROR;
    END IF;    -- Bug 3088216

  ELSE     -- samples uom = test uom

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(' samples uom = test uom : ');
    END IF;

    IF qty <= l_samples.remaining_qty THEN
	-- added this code to prevent locking error if sample is locked by another form.
       OPEN  C_lock_sample(l_samples.sample_id);
       CLOSE C_lock_sample;

       UPDATE gmd_samples
       SET    remaining_qty = remaining_qty - qty
       WHERE  sample_id     = l_samples.sample_id;

    ELSE
      GMD_API_PUB.Log_Message('GMD_QM_REMAIN_QTY_NEG');
      RAISE FND_API.G_EXC_ERROR;
    END IF;    -- Bug 3088216


  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN RECORD_LOCK THEN         -- added to prevent record locking of samples
    IF (l_debug = 'Y') THEN
	gmd_debug.put_line('Reached in lock on samples');
    END IF;
    IF C_lock_sample%ISOPEN THEN
       CLOSE C_lock_sample;
    END IF;
    GMD_API_PUB.Log_Message('GMD_QM_SAMPLES_LOCKED'); -- Bug# 5463117
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END update_remaining_qty;


--+========================================================================+
--| API Name    : sample_source_display                                    |
--| TYPE        : Group                                                    |
--| Notes       : This procedure retrieves samples values for display from |
--|               the ids on the samples table                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence     |
--|       Bug 4165704                                                      |
--|  RLNAGARA  19-Dec-2005 Bug#4868950                                     |
--|     -Assigned the value of resources and subinventory to the output    |
--|  RLNAGARA  20-Dec-2005 Bug# 4880152 				   |
--|     -Added the revision variable.
--|  M. Grosser 28-Feb-2006  Bug 5016617 - Added retrieval of supplier name|
--|             to procedure sample_source_display.                        |
--|  RLANGARA 04-Apr-2006 Bug 5130051 modified the cursor parameters of Cur_disposition |
--+========================================================================+
PROCEDURE Sample_source_display  (
  p_id                 IN         NUMBER
, p_type               IN         VARCHAR2
, x_display            OUT NOCOPY        sample_display_rec
, x_return_status      OUT NOCOPY        VARCHAR2
) IS
  CURSOR   Cur_user(name_id NUMBER) IS
    SELECT user_name, description
    FROM   fnd_user
    WHERE  user_id =   name_id ;

  CURSOR Cur_organization_code(orgn_id NUMBER) IS
    SELECT organization_code
    FROM   mtl_parameters
    WHERE  organization_id = orgn_id;

  CURSOR   Cur_locator(loc_id NUMBER)  IS
    SELECT concatenated_segments
    FROM mtl_item_locations_kfv
    WHERE inventory_location_id =  loc_id;

--RLNAGARA B5130051 modified parameter from sample_id to p_sample_id
  CURSOR   Cur_disposition(p_sample_id NUMBER)  IS
    SELECT l.lookup_code,
           l.meaning
    FROM   gmd_sample_spec_disp ssd,
           gem_lookups  l
    WHERE ssd.sample_id = p_sample_id
      AND l.lookup_type = 'GMD_QC_SAMPLE_DISP'
      AND l.lookup_code = ssd.disposition ;

  --RLNAGARA LPN ME 7027149 Added cursor to get LPN from ID
  CURSOR Cur_get_lpn(p_lpn_id NUMBER) IS
   SELECT license_plate_number
   FROM wms_license_plate_numbers
   WHERE lpn_id = p_lpn_id;

  in_sample             gmd_samples%ROWTYPE;
  out_sample            gmd_samples%ROWTYPE;
  in_sampling_event     gmd_sampling_events%ROWTYPE;
  out_sampling_event    gmd_sampling_events%ROWTYPE;
  sampling_event    gmd_sampling_events%ROWTYPE;

  /*=================================
     Added for BUG#4695552.
    =================================*/
  CURSOR   get_grade(v_organization NUMBER, v_lot_number VARCHAR2) IS
    SELECT grade_code
    FROM   mtl_lot_numbers
    WHERE  organization_id = v_organization
    AND    lot_number = v_lot_number;

 -- Exceptions
  e_sampling_event_fetch_error   EXCEPTION;
  e_sample_fetch_error           EXCEPTION;

  BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- test for whether sample id or sampling event id was passed
    IF p_type = 'SAMPLE' THEN  -- sample_id is passed
       in_sample.sample_id := p_id;
       IF NOT ( gmd_samples_pvt.fetch_row(p_samples => in_sample,
                                          x_samples => out_sample))
       THEN
            -- Fetch Error.
          RAISE e_sample_fetch_error;
       END IF;

      x_display.sample_no         := out_sample.sample_no ;
      x_display.parent_lot_number := out_sample.parent_lot_number;
      x_display.lot_number        := out_sample.lot_number;
      x_display.sampling_event_id := out_sample.sampling_event_id;
      x_display.retain_as         := out_sample.retain_as        ;
      x_display.sample_type       := out_sample.sample_type        ;
      x_display.source            := out_sample.source             ;
      x_display.subinventory      := out_sample.subinventory             ;
      x_display.po_header_id      := out_sample.po_header_id             ;
      x_display.inventory_item_id  := out_sample.inventory_item_id;
      x_display.revision          := out_sample.revision    ;    --RLNAGARA Bug # 4880152
      x_display.organization_id    := out_sample.organization_id;
      x_display.creation_date      := out_sample.creation_date  ;
      x_display.resources         := out_sample.resources  ;  --RLNAGARA Bug # 4868950


        -- To Fetch Sample Disposition
        OPEN  Cur_disposition(p_id);
        FETCH Cur_disposition INTO       x_display.sample_disposition,
                                         x_display.sample_disposition_desc;
        CLOSE Cur_disposition;

        -- To Fetch Sampler Name
      IF out_sample.sampler_id IS NOT NULL THEN
        OPEN  Cur_user(out_sample.sampler_id);
        FETCH Cur_user INTO              x_display.sampler,
                                         x_display.sampler_name;
        CLOSE Cur_user;
      END IF;

        -- To Fetch Storage Organization Code
      IF out_sample.storage_organization_id IS NOT NULL THEN
        OPEN  Cur_organization_code(out_sample.storage_organization_id);
        FETCH Cur_organization_code INTO x_display.storage_organization_code ;
        CLOSE Cur_organization_code;

         x_display.storage_locator_id      := out_sample.storage_locator_id;
         IF out_sample.storage_locator_id IS NOT NULL THEN
            OPEN  Cur_locator(out_sample.storage_locator_id);
            FETCH Cur_locator INTO x_display.storage_locator ;
            CLOSE Cur_locator;
         END IF;
      END IF;

        -- To Fetch Lab Organization Code
      IF out_sample.Lab_organization_id IS NOT NULL THEN
        OPEN  Cur_organization_code(out_sample.Lab_organization_id);
        FETCH Cur_organization_code INTO x_display.Lab_organization_code ;
        CLOSE Cur_organization_code;
      END IF;

      --RLNAGARA LPN ME 7027149 Get the LPN from lpn_id
      IF out_sample.lpn_id IS NOT NULL THEN
        OPEN Cur_get_lpn(out_sample.lpn_id);
	FETCH Cur_get_lpn INTO x_display.lpn;
	CLOSE Cur_get_lpn;
      END IF;

          -- test for whether sample event id exists because then sampling event fields are needed
       IF ((NVL(out_sample.sample_id, 0) <> 0)
         AND (NVL(out_sample.sampling_event_id, 0) <> 0)) THEN
         in_sampling_event.sampling_event_id := out_sample.sampling_event_id;
         IF NOT (GMD_SAMPLING_EVENTS_PVT.fetch_row(p_sampling_events   => in_sampling_event,
    	                                           x_sampling_events   => out_sampling_event))
         THEN
              -- Fetch Error.
            RAISE e_sampling_event_fetch_error;
         END IF;

         x_display.sample_req_cnt    := out_sampling_event.sample_req_cnt;
         x_display.sample_taken_cnt  := out_sampling_event.sample_taken_cnt;
         x_display.archived_taken    := out_sampling_event.archived_taken;
         x_display.reserved_taken    := out_sampling_event.reserved_taken;
         x_display.sample_active_cnt := out_sampling_event.sample_active_cnt;

       END IF;

       Gmd_samples_grp.get_item_values(p_sample_display => x_display);

       IF out_sample.source = 'I' THEN
           Gmd_samples_grp.Inventory_source(p_locator_id      => out_sample.locator_id
                                          , p_subinventory    => out_sample.subinventory
                                          , p_organization_id => out_sample.organization_id
                                          , x_display         => x_display);
       ELSIF out_sample.source = 'C' THEN
           Gmd_samples_grp.customer_source(p_org_id          => out_sample.org_id
                                         , p_ship_to_site_id => out_sample.ship_to_site_id
                                         , p_order_id        => out_sample.order_id
                                         , p_order_line_id   => out_sample.order_line_id
                                         , p_cust_id         => out_sample.cust_id
                                         , x_display         => x_display);
       ELSIF out_sample.source = 'S' THEN
          Gmd_samples_grp.supplier_source(p_supplier_id       => out_sample.supplier_id
                                        , p_po_header_id      => out_sample.po_header_id
                                        , p_po_line_id        => out_sample.po_line_id
                                        , p_receipt_id        => out_sample.receipt_id
                                        , p_receipt_line_id   => out_sample.receipt_line_id
                                        , p_supplier_site_id  => out_sample.supplier_site_id
                                        , p_org_id            => out_sample.org_id
                                        , p_organization_id   => out_sample.organization_id
                                        , p_subinventory      => out_sample.subinventory
                                        , x_display           => x_display);
       ELSIF out_sample.source = 'W' THEN
          Gmd_samples_grp.wip_source(p_batch_id          => out_sample.batch_id
                                   , p_step_id           => out_sample.step_id
                                   , p_recipe_id         => out_sample.recipe_id
                                   , p_formula_id        => out_sample.formula_id
                                   , p_formulaline_id    => out_sample.formulaline_id
                                   , p_material_detail_id => out_sample.material_detail_id
                                   , p_routing_id        => out_sample.routing_id
                                   , p_oprn_id           => out_sample.oprn_id
                                   , p_inventory_item_id => out_sample.inventory_item_id
                                   , p_organization_id   => out_sample.organization_id
                                   , x_display           => x_display);
       ELSIF out_sample.source = 'T' THEN
          Gmd_samples_grp.stability_study_source(p_variant_id    => out_sample.variant_id
                                                ,p_time_point_id => out_sample.time_point_id
                                               , x_display       => x_display);
       ELSIF out_sample.source = 'L' THEN
           Gmd_samples_grp.physical_location_source(p_locator_id   => out_sample.locator_id
                                                  , p_subinventory => out_sample.subinventory
                                                  , p_organization_id => out_sample.organization_id
                                                  , x_display      => x_display);
       ELSIF out_sample.source = 'R' THEN
           Gmd_samples_grp.resource_source(p_instance_id   => out_sample.instance_id
                                         , x_display  => x_display);
       END IF;

    ELSIF p_type = 'EVENT' THEN  -- sampling_event_id is passed
       in_sampling_event.sampling_event_id := p_id;
       IF NOT (GMD_SAMPLING_EVENTS_PVT.fetch_row(p_sampling_events   => in_sampling_event,
                                                 x_sampling_events   => out_sampling_event))
       THEN
            -- Fetch Error.
          RAISE e_sampling_event_fetch_error;
       END IF;

       x_display.sample_req_cnt     := out_sampling_event.sample_req_cnt;
       x_display.sample_taken_cnt   := out_sampling_event.sample_taken_cnt;
       x_display.archived_taken     := out_sampling_event.archived_taken;
       x_display.reserved_taken     := out_sampling_event.reserved_taken;
       x_display.sample_active_cnt  := out_sampling_event.sample_active_cnt;

       x_display.inventory_item_id  := out_sampling_event.inventory_item_id;
       x_display.organization_id    := out_sampling_event.organization_id;
       x_display.creation_date      := out_sampling_event.creation_date  ;
       x_display.subinventory       := out_sampling_event.subinventory  ; --RLNAGARA Bug# 4868950

       --RLNAGARA LPN ME 7027149 Get the LPN from lpn_id
       IF out_sampling_event.lpn_id IS NOT NULL THEN
         OPEN Cur_get_lpn(out_sampling_event.lpn_id);
         FETCH Cur_get_lpn INTO x_display.lpn;
 	 CLOSE Cur_get_lpn;
       END IF;

       Gmd_samples_grp.get_item_values(p_sample_display => x_display);

       IF out_sampling_event.source = 'I' THEN
           Gmd_samples_grp.Inventory_source(p_locator_id   => out_sampling_event.locator_id
                                          , p_subinventory => out_sampling_event.subinventory
                                          , p_organization_id => out_sampling_event.organization_id
                                          , x_display      => x_display);
       ELSIF out_sampling_event.source = 'C' THEN
           Gmd_samples_grp.customer_source(p_org_id          => out_sampling_event.org_id
                                         , p_ship_to_site_id => out_sampling_event.ship_to_site_id
                                         , p_order_id        => out_sampling_event.order_id
                                         , p_order_line_id   => out_sampling_event.order_line_id
                                         , p_cust_id         => out_sampling_event.cust_id
                                         , x_display       => x_display);
       ELSIF out_sampling_event.source = 'S' THEN
          Gmd_samples_grp.supplier_source(p_supplier_id       => out_sampling_event.supplier_id
                                        , p_po_header_id      => out_sampling_event.po_header_id
                                        , p_po_line_id        => out_sampling_event.po_line_id
                                        , p_receipt_id        => out_sampling_event.receipt_id
                                        , p_receipt_line_id   => out_sampling_event.receipt_line_id
                                        , p_supplier_site_id  => out_sampling_event.supplier_site_id
                                        , p_org_id            => out_sampling_event.org_id
                                        , p_organization_id   => out_sampling_event.organization_id
                                        , p_subinventory      => out_sampling_event.subinventory
                                        , x_display           => x_display);
       ELSIF out_sampling_event.source = 'W' THEN
          Gmd_samples_grp.wip_source(p_batch_id          => out_sampling_event.batch_id
                                   , p_step_id           => out_sampling_event.step_id
                                   , p_recipe_id         => out_sampling_event.recipe_id
                                   , p_formula_id        => out_sampling_event.formula_id
                                   , p_formulaline_id    => out_sampling_event.formulaline_id
                                   , p_material_detail_id => out_sampling_event.material_detail_id
                                   , p_routing_id        => out_sampling_event.routing_id
                                   , p_oprn_id           => out_sampling_event.oprn_id
                                   , p_inventory_item_id => out_sampling_event.inventory_item_id
                                   , p_organization_id   => out_sample.organization_id
                                   , x_display           => x_display);
       ELSIF out_sampling_event.source = 'T' THEN
          Gmd_samples_grp.stability_study_source(p_variant_id    => out_sampling_event.variant_id
                                                ,p_time_point_id => out_sampling_event.time_point_id
                                               , x_display       => x_display);
       ELSIF out_sampling_event.source = 'L' THEN
           Gmd_samples_grp.physical_location_source(p_locator_id   => out_sampling_event.locator_id
                                                  , p_subinventory => out_sampling_event.subinventory
                                                  , p_organization_id => out_sampling_event.organization_id
                                                  , x_display      => x_display);
       ELSIF out_sampling_event.source = 'R' THEN
           Gmd_samples_grp.resource_source(p_instance_id   => out_sampling_event.instance_id
                                         , x_display  => x_display);
       END IF;
    ELSE    -- p_type parameter incorrect
        x_return_status := FND_API.G_RET_STS_ERROR ;
    END IF;       -- end p_type = 'SAMPLE'

    /*============================================
       BUG#469552
       Moved set of storage_subinventory and
       added grade retrieval.
      ============================================*/
    x_display.storage_subinventory    := out_sample.storage_subinventory;


    IF (out_sample.lot_number IS NOT NULL) THEN
       OPEN get_grade (out_sample.organization_id, out_sample.lot_number);
       FETCH get_grade INTO x_display.grade_code;
       IF (get_grade%NOTFOUND) THEN
          x_display.grade_code := NULL;
       END IF;
       CLOSE get_grade;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR OR
       e_sampling_event_fetch_error OR
       e_sample_fetch_error
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_API_ERROR',
                            'PACKAGE','SAMPLE_SOURCE_DISPLAY','ERROR', SUBSTR(SQLERRM,1,100));
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Sample_source_display ;


--+========================================================================+
--| API Name    : get_item_values                                          |
--| TYPE        : Group                                                    |
--| Notes       : This procedure gets item control values from items table |
--|                                                                        |
--| HISTORY                                                                |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence     |
--|       Bug 4165704                                                       |
--+========================================================================+
PROCEDURE Get_item_values (p_sample_display IN OUT NOCOPY sample_display_rec)
IS
  CURSOR   Cur_get_item  IS
    SELECT    concatenated_segments,    -- (Item_Number)
              description,
              Restrict_subinventories_code,
              restrict_locators_code,
              location_control_code,
              Revision_qty_control_code,       -- (revision cntrl)
              Lot_control_code,
              Lot_status_enabled,
              grade_control_flag,
              Primary_uom_code,
              Dual_uom_control,
              Eng_item_flag,                           -- (experimental item)
              Child_lot_flag,                          -- parent lot control
              Indivisible_flag,
              Serial_number_control_code,    --(must = 0 to generate inv transaction)
              process_yield_subinventory,    -- replenish subinventory
              process_yield_locator_id       -- replenish locator_id
    FROM     mtl_system_items_b_kfv
    WHERE  organization_id     = p_sample_display.organization_id
      AND  inventory_item_id = p_sample_display.inventory_item_id;


  CURSOR   Cur_source_locator  IS
    SELECT concatenated_segments
    FROM mtl_item_locations_kfv
    WHERE inventory_location_id =  p_sample_display.source_locator_id;

  BEGIN
    IF (p_sample_display.inventory_item_id IS NOT NULL
        AND p_sample_display.organization_id IS NOT NULL) THEN
        OPEN  Cur_get_item;
        FETCH Cur_get_item  INTO     p_sample_display.item_number,
                                     p_sample_display.item_description,
                                     p_sample_display.Restrict_subinventories_code,
                                     p_sample_display.restrict_locators_code,
                                     p_sample_display.location_control_code,
                                     p_sample_display.Revision_qty_control_code,
                                     p_sample_display.Lot_control_code,
                                     p_sample_display.Lot_status_enabled,
                                     p_sample_display.Grade_control_flag,
                                     p_sample_display.Primary_uom_code,
                                     p_sample_display.Dual_uom_control,
                                     p_sample_display.Eng_item_flag,
                                     p_sample_display.Child_lot_flag,
                                     p_sample_display.Indivisible_flag,
                                     p_sample_display.Serial_number_control_code,
                                     p_sample_display.source_subinventory,
                                     p_sample_display.source_locator_id ;
       CLOSE Cur_get_item;

        -- If replenish locator id was found, get source locator
       IF (p_sample_display.source_locator_id IS NOT NULL) THEN
          OPEN  Cur_source_locator;
          FETCH Cur_source_locator  INTO   p_sample_display.locator;
          CLOSE Cur_source_locator;
       END IF;

    END IF;
END Get_item_values;


--+=======================================================================9+
--| API Name    : inventory_source                                         |
--| TYPE        : Group                                                    |
--| Notes       : This procedure                                           |
--|                                                                        |
--| HISTORY                                                                |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence     |
--|       Bug 4165704                                                       |
--+========================================================================+
PROCEDURE Inventory_source (
 p_locator_id          IN        NUMBER
,p_subinventory        IN        VARCHAR2
,p_organization_id     IN        NUMBER
, x_display            IN OUT NOCOPY    sample_display_rec)

IS
  CURSOR   Cur_locator  IS
    SELECT concatenated_segments
    FROM mtl_item_locations_kfv
    WHERE inventory_location_id =  p_locator_id;

  CURSOR Cur_subinventory IS
    SELECT   Locator_type,                           -- locator control
             description
    FROM   mtl_secondary_inventories
    WHERE  secondary_inventory_name = p_subinventory
      AND  organization_id          = p_organization_id;

   BEGIN
   IF (p_subinventory IS NOT NULL) THEN
      OPEN  Cur_subinventory;
      FETCH Cur_subinventory INTO   x_display.locator_type,
                                    x_display.subinventory_desc;
      CLOSE Cur_subinventory;
   END IF;

   IF (p_locator_id IS NOT NULL) THEN
      OPEN  Cur_locator;
      FETCH Cur_locator  INTO   x_display.locator;
      CLOSE Cur_locator;
   END IF;
END Inventory_source;



--+=======================================================================9+
--| API Name    : supplier_source                                          |
--| TYPE        : Group                                                    |
--| Notes       : This procedure                                           |
--|                                                                        |
--| HISTORY                                                                |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence     |
--|       Bug 4165704                                                      |
--|  M. Grosser 28-Feb-2006  Bug 5016617 - Added retrieval of supplier name|
--+========================================================================+
PROCEDURE Supplier_source (
 p_supplier_id       IN        NUMBER
,p_po_header_id      IN        NUMBER
,p_po_line_id        IN        NUMBER
,p_receipt_id        IN        NUMBER
,p_receipt_line_id   IN        NUMBER
,p_supplier_site_id  IN        NUMBER
,p_org_id            IN        NUMBER
,p_organization_id   IN        NUMBER
,p_subinventory      IN        VARCHAR2
,x_display           IN OUT NOCOPY    sample_display_rec)

IS
   --  M. Grosser 28-Feb-2006  Bug 5016617 - Added retrieval of supplier name
   CURSOR Cur_get_supplier IS
      SELECT SEGMENT1, VENDOR_NAME
      FROM   PO_VENDORS
      WHERE  vendor_id = p_supplier_id;

   CURSOR Cur_get_po IS
      SELECT SEGMENT1
      FROM   PO_HEADERS_ALL
      WHERE  PO_HEADER_ID = p_PO_HEADER_ID;

   CURSOR Cur_get_po_line_info IS
      SELECT line_num
      FROM   po_lines_all
      WHERE  po_line_id   = p_po_line_id;

   CURSOR Cur_get_receipt_info IS
      SELECT rsh.receipt_num receipt
      FROM   rcv_shipment_headers rsh
      WHERE  rsh.shipment_header_id    = p_receipt_id;

   CURSOR Cur_get_receipt_line_info IS
      SELECT rsh.receipt_num receipt_no,
             rsl.line_num receipt_line_num
      FROM   rcv_shipment_lines rsl ,
             rcv_shipment_headers rsh
      WHERE  rsl.po_header_id        = p_po_header_id
        AND  rsl.po_line_id          = p_po_line_id
        AND  rsl.shipment_header_id  = rsh.shipment_header_id
        AND  rsh.shipment_header_id  = p_receipt_id ;

   CURSOR Cur_get_site IS
      SELECT vendor_site_code
      FROM   po_vendor_sites_all
      WHERE  vendor_site_id          = p_supplier_site_id;

   /*CURSOR Cur_operating_unit IS
      SELECT name
      FROM   HR_OPERATING_UNITS
      WHERE  organization_id        = p_org_id;*/

   -- Bug# 5226352
   -- Commented the above cursor definition and modified to fix performance issues
   CURSOR Cur_operating_unit IS
      SELECT OTL.name
        FROM HR_ALL_ORGANIZATION_UNITS_TL OTL,
             HR_ORGANIZATION_INFORMATION O2
      WHERE  OTL.organization_id = p_org_id
        AND  OTL.ORGANIZATION_ID = O2.ORGANIZATION_ID
        AND  O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
        AND  O2.ORG_INFORMATION2 = 'Y'
        AND  OTL.LANGUAGE = userenv('LANG');

   CURSOR Cur_locator_ctrl IS
      SELECT locator_type               -- locator control
      FROM   mtl_secondary_inventories
      WHERE  organization_id = p_organization_id
        AND  secondary_inventory_name    =  p_subinventory;


   BEGIN
      IF (p_SUPPLIER_ID IS NOT NULL) THEN
         OPEN Cur_get_supplier;
         --  M. Grosser 28-Feb-2006  Bug 5016617 - Added retrieval of supplier name
         FETCH Cur_get_supplier INTO x_display.supplier_no,
                                     x_display.supplier_name;
         CLOSE Cur_get_supplier;

         OPEN Cur_get_site;
         FETCH Cur_get_site INTO x_display.supplier_site;
         CLOSE Cur_get_site;

         OPEN  Cur_operating_unit;
         FETCH Cur_operating_unit INTO x_display.sup_operating_unit_name;
         CLOSE Cur_operating_unit;

      END IF;

      IF (p_po_header_id IS NOT NULL) THEN
         OPEN Cur_get_po;
         FETCH Cur_get_po INTO x_display.po_number;
         CLOSE Cur_get_po;
      END IF;

      IF p_po_line_id is not null THEN
         OPEN  Cur_get_po_line_info;
         FETCH Cur_get_po_line_info INTO  x_display.po_line_no  ;
         CLOSE Cur_get_po_line_info;
      END IF;       -- po_line_id

      IF p_receipt_line_id is not null THEN
         OPEN  Cur_get_receipt_line_info;
         FETCH Cur_get_receipt_line_info INTO  x_display.receipt,
                                               x_display.receipt_line ;
         CLOSE Cur_get_receipt_line_info;

      ELSIF p_receipt_id is not null THEN
         OPEN  Cur_get_receipt_info;
         FETCH Cur_get_receipt_info INTO   x_display.receipt ;
         CLOSE Cur_get_receipt_info;
      END IF;       -- receipt_line_id

      IF (p_subinventory IS NOT  NULL
       AND p_organization_id IS NOT NULL) THEN
         OPEN  Cur_locator_ctrl;
         FETCH Cur_locator_ctrl  INTO  x_display.locator_type;
         CLOSE Cur_locator_ctrl;
      END IF;

END Supplier_source;

--+=======================================================================9+
--| API Name    : customer_source                                          |
--| TYPE        : Group                                                    |
--| Notes       : This procedure                                           |
--|                                                                        |
--| HISTORY                                                                |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence     |
--|       Bug 4165704                                                       |
--+========================================================================+
PROCEDURE Customer_source (
  p_ship_to_site_id IN NUMBER
, p_org_id          IN NUMBER
, p_order_id        IN NUMBER
, p_order_line_id   IN NUMBER
, p_cust_id         IN NUMBER
,x_display          IN OUT NOCOPY    sample_display_rec)

IS
    /*CURSOR   Cur_operating_unit IS
      SELECT name
      FROM   HR_OPERATING_UNITS
      WHERE  organization_id  =         p_org_id;*/

    -- Bug# 5226352
    -- Commented the above cursor definition and modified to fix performance issues
    CURSOR Cur_operating_unit IS
       SELECT OTL.name
         FROM HR_ALL_ORGANIZATION_UNITS_TL OTL,
              HR_ORGANIZATION_INFORMATION O2
       WHERE  OTL.organization_id = p_org_id
         AND  OTL.ORGANIZATION_ID = O2.ORGANIZATION_ID
         AND  O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
         AND  O2.ORG_INFORMATION2 = 'Y'
         AND  OTL.LANGUAGE = userenv('LANG');

    CURSOR Cur_ship_to IS
      SELECT location
      FROM   hz_cust_site_uses_all
      WHERE  site_use_id =              p_ship_to_site_id;

    CURSOR Cur_order_number IS
      SELECT h.order_number,
             t.name
      FROM   oe_order_headers_all     h,
             oe_transaction_types_tl  t
      WHERE  h.header_id      =   p_order_id
        AND  h.order_type_id  =   t.transaction_type_id
        AND  t.language       =   USERENV('LANG');

    CURSOR Cur_order_line IS
      SELECT l.line_number||
            decode(l.shipment_number,'','','.'|| l.shipment_number) ||
            decode(l.option_number||l.component_number||l.service_number,'','','.'||l.option_number) ||
            decode(l.component_number||l.service_number,'','','.'|| l.component_number) ||
            decode(l.service_number,'','','.'|| l.service_number)
      FROM   oe_order_lines_all    l
      WHERE  line_id =  p_order_line_id ;

    CURSOR Cur_get_cust IS
      SELECT p.party_name                /* cust_name */
      FROM   hz_cust_accounts_all      a,
             hz_parties                p
      WHERE  a.cust_account_id   =     p_cust_id
        AND  a.party_id          =     p.party_id;

   BEGIN
      IF (p_cust_id IS NOT NULL) THEN
         OPEN Cur_get_cust;
         FETCH Cur_get_cust INTO         x_display.cust_name;
         CLOSE Cur_get_cust;
      END IF;

      IF p_org_id IS NOT NULL  THEN
         OPEN  Cur_operating_unit;
         FETCH Cur_operating_unit INTO     x_display.operating_unit_name;
         CLOSE Cur_operating_unit;

         IF p_ship_to_site_id IS NOT NULL THEN
            OPEN Cur_ship_to;
            FETCH Cur_ship_to INTO         x_display.ship_to_name;
            CLOSE Cur_ship_to;
         END IF;     -- cur_ship_to

         IF p_order_id IS NOT NULL THEN
            OPEN Cur_order_number;
            FETCH Cur_order_number INTO    x_display.order_number,
                                                           x_display.order_type;
            CLOSE Cur_order_number;
         END IF;   -- Cur_order_number

         IF p_order_line_id IS NOT NULL THEN
            OPEN Cur_order_line;
            FETCH Cur_order_line INTO    x_display.order_line_no;
            CLOSE Cur_order_line;
         END IF;   -- Cur_order_line

      END IF;     -- Cur_operating_unit
END Customer_Source;



--+=======================================================================9+
--| API Name    : stability_study_source                                  |
--| TYPE        : Group                                                   |
--| Notes       : This procedure                                          |
--|                                                                       |
--| HISTORY                                                               |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence    |
--|       Bug 4165704                                                      |
--+========================================================================+
PROCEDURE Stability_study_source (
 p_variant_id          IN        NUMBER
,p_time_point_id       IN        NUMBER
,x_display             IN OUT NOCOPY    sample_display_rec)
IS
   CURSOR  Cur_stability_study IS
      SELECT p.organization_code,
             ss_no,
             variant_no,
             v.storage_locator_id,     --xxx needs to changed to v.storage_locator
             v.STORAGE_subinventory,   -- needs to be changed to v.storage_subinventory,
             v.resources,
             ri.instance_number
      FROM   GMD_SS_VARIANTS v,
             GMD_STABILITY_STUDIES_B ss,
             GMP_RESOURCE_INSTANCES  ri,
             MTL_PARAMETERS p
      WHERE  variant_id        =  p_variant_id
       AND  ss.ss_id           =  v.ss_id
       AND  ri.instance_id(+)  =  v.resource_instance_id
       AND p.organization_id = ss.organization_id;

   CURSOR  Cur_timepoint IS
      SELECT tp.name ,            -- Time Point
             tp.scheduled_date
      FROM   GMD_SS_TIME_POINTS    tp
      WHERE  tp.time_point_id  = p_time_point_id;

    /*============================================
       BUG#469552 - Don't get storage locator
       again into the output area.
      ============================================*/
   l_storage_locator                     NUMBER;

   BEGIN
      IF (p_variant_id IS NOT NULL) THEN
         OPEN  Cur_stability_study;
         FETCH Cur_stability_study  INTO   x_display.ss_organization_code,
                                           x_display.ss_no,
                                           x_display.variant_no,
                                           l_storage_locator,
                                           x_display.storage_subinventory,
                                           x_display.variant_resource,
                                           x_display.instance_number;

         CLOSE Cur_stability_study;
      END IF;

       -- To Fetch Timepoint
      IF ( p_time_point_id IS NOT NULL ) THEN
        OPEN  Cur_timepoint;
        FETCH Cur_timepoint INTO x_display.time_point_name,
                                 x_display.scheduled_date;
        CLOSE Cur_timepoint;
      END IF;     -- time_point_id is not null
END  Stability_Study_Source ;


--+=======================================================================9+
--| API Name    : physical_location_source                                |
--| TYPE        : Group                                                   |
--| Notes       : This procedure                                          |
--|                                                                       |
--| HISTORY                                                               |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence    |
--|       Bug 4165704                                                     |
--|    Susan Feinstein  31-Jan-2006  Bug 4602223: added subinventory desc |
--+========================================================================+
PROCEDURE Physical_location_source (
 p_locator_id          IN        NUMBER
,p_subinventory        IN        VARCHAR2
,p_organization_id     IN        NUMBER
,x_display             IN OUT NOCOPY    sample_display_rec)

IS
  o_display  sample_display_rec;

BEGIN
      Gmd_samples_grp.Inventory_source (
                p_locator_id   => p_locator_id
              , p_subinventory => p_subinventory
              , p_organization_id => p_organization_id
              , x_display      => o_display);

       X_display.locator            := o_display.locator;
       X_display.locator_type       := o_display.locator_type;
       X_display.subinventory_desc  := o_display.subinventory_desc;

END;       -- Physical Location Source



--+=======================================================================9+
--| API Name    : resource_source                                         |
--| TYPE        : Group                                                   |
--| Notes       : This procedure gets all the resource values                                         |
--|                                                                       |
--| HISTORY                                                               |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence    |
--|       Bug 4165704                                                      |
--+========================================================================+
PROCEDURE Resource_source (
p_instance_id          IN        NUMBER
,x_display             IN OUT NOCOPY    sample_display_rec)

IS
   CURSOR  Cur_instance IS
      SELECT INSTANCE_NUMBER
      FROM   GMP_RESOURCE_INSTANCES
      WHERE  instance_id   = p_instance_id;
   BEGIN
      IF (p_instance_id IS NOT NULL) THEN
        OPEN  Cur_instance;
        FETCH Cur_instance INTO x_display.instance_number;
        CLOSE Cur_instance;
      END IF;
END  Resource_Source ;


--+=======================================================================9+
--| API Name    : wip_source                                              |
--| TYPE        : Group                                                   |
--| Notes       : This procedure gets all the wip values for the form                                         |
--|                                                                       |
--| HISTORY                                                               |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence    |
--|       Bug 4165704
--|    Peter Lowe       22-Mar-2006 -Bug 4754855 changed logic for        |
--|    retrieval of Cur_formulaline                                       |
--|  Peter Lowe 14-Apr-2006 - Bug 5127352  - reversed logic of Bug 4754855|
--|     as QA now states that we do not need formula line no or type on   |
--|     Samples Summary form  																						|
--+=======================================================================+
PROCEDURE Wip_source (
  p_batch_id          IN NUMBER
, p_step_id           IN NUMBER
, p_recipe_id         IN NUMBER
, p_formula_id        IN NUMBER
, p_formulaline_id    IN NUMBER
, p_material_detail_id IN NUMBER
, p_routing_id        IN NUMBER
, p_oprn_id           IN NUMBER
, p_inventory_item_id IN NUMBER
, p_organization_id   IN NUMBER
,x_display            IN OUT NOCOPY    sample_display_rec)


IS
    CURSOR   Cur_vbatch IS
      SELECT batch_no
      FROM   gme_batch_header
      WHERE  batch_id = P_batch_id;

    CURSOR   Cur_vstep IS
      SELECT   bs.batchstep_no,
               o.oprn_no,
               o.oprn_vers
      FROM gme_batch_steps bs,
           gmd_operations o
      WHERE bs.oprn_id = o.oprn_id
        AND bs.batch_id = p_batch_id
        AND bs.batchstep_id = p_step_id
        AND bs.delete_mark = 0;

    CURSOR   Cur_vrecipe IS
      SELECT recipe_no, recipe_version
      FROM   gmd_recipes
      WHERE  recipe_id = P_recipe_id;

    CURSOR   Cur_vformula IS
      SELECT formula_no, formula_vers
      FROM   fm_form_mst
      WHERE  formula_id = P_formula_id;

    CURSOR   Cur_vrouting IS
      SELECT routing_no, routing_vers
      FROM   fm_rout_hdr
      WHERE  routing_id = P_routing_id;


    CURSOR   Cur_voprn IS
      SELECT oprn_no,oprn_vers
      FROM   fm_oprn_mst
      WHERE  oprn_id = P_oprn_id;

		 -- Peter Lowe 14-Apr-2006 - Bug 5127352  - reversed logic of Bug 4754855 |
     -- bug 4640143: added cursors for formulaline and batch line
   /* CURSOR   Cur_formulaline IS
      SELECT fd.line_no,
             gem.meaning
      FROM   fm_matl_dtl fd,
             gem_lookups  gem
      WHERE  fd.formula_id                = P_formula_id
        AND  fd.formulaline_id            = P_formulaline_id
        AND  fd.inventory_item_id         = P_inventory_item_id
        AND  gem.lookup_type              = 'GMD_FORMULA_ITEM_TYPE'
        AND  gem.lookup_code              = fd.line_type; */

   CURSOR   Cur_batchline IS
      SELECT line_no,
             gem.meaning
      FROM   gme_material_details  md,
             gem_lookups gem
      WHERE  batch_id          = P_batch_id
        AND  material_detail_id   = P_material_detail_id
        AND  inventory_item_id = P_inventory_item_id
        AND  organization_id   = P_organization_id
        AND  gem.lookup_type   = 'GMD_FORMULA_ITEM_TYPE'
        AND  gem.lookup_code   = md.line_type;

 BEGIN
      IF ( P_batch_id IS NOT NULL ) THEN
        OPEN  Cur_vbatch;
        FETCH Cur_vbatch INTO X_DISPLAY.batch_no;
        CLOSE Cur_vbatch;

        IF (P_step_id IS NOT NULL ) THEN
           OPEN  Cur_vstep;
           FETCH Cur_vstep INTO X_DISPLAY.step_no,
                                X_DISPLAY.oprn_no,
                                X_DISPLAY.oprn_vers;
           CLOSE Cur_vstep;
        END IF;

        IF (P_material_detail_id IS NOT NULL ) THEN
           OPEN  Cur_batchline;
           FETCH Cur_batchline INTO X_DISPLAY.formula_line,
                                    X_DISPLAY.formula_type;
           CLOSE Cur_batchline;
        END IF;
      END IF;    -- batch_id is not null

		 -- Peter Lowe 14-Apr-2006 - Bug 5127352  - reversed logic of Bug 4754855 |
		 -- bug 4754855 changed logic for retrieval of Cur_formulaline

      /*IF (P_formulaline_id IS NOT NULL) THEN -- bug 4754855
           OPEN  Cur_formulaline;
           FETCH Cur_formulaline INTO X_DISPLAY.formula_line,
                                      X_DISPLAY.formula_type;
           CLOSE Cur_formulaline;
      END IF; -- bug 4754855   */


      IF ( P_recipe_id IS NOT NULL ) THEN
        OPEN  Cur_vrecipe;
        FETCH Cur_vrecipe INTO X_DISPLAY.recipe_no,
                               X_DISPLAY.recipe_version;
        CLOSE Cur_vrecipe;
      END IF;

      IF ( P_formula_id IS NOT NULL ) THEN
        OPEN  Cur_vformula;
        FETCH Cur_vformula INTO X_DISPLAY.formula_no,
                                X_DISPLAY.formula_vers;
        CLOSE Cur_vformula;
      END IF;

      IF ( P_routing_id IS NOT NULL ) THEN
        OPEN  Cur_vrouting;
        FETCH Cur_vrouting INTO X_DISPLAY.routing_no,
                                X_DISPLAY.routing_vers;
        CLOSE Cur_vrouting;
      END IF;

      IF ( P_oprn_id IS NOT NULL ) THEN
        OPEN  Cur_voprn;
        FETCH Cur_voprn INTO X_DISPLAY.oprn_no,
                             X_DISPLAY.oprn_vers;
        CLOSE Cur_voprn;
      END IF;


END WIP_Source;


--+=======================================================================9+
--| API Name    : get_sample_spec_disposition                             |
--| TYPE        : Group                                                   |
--| Notes       : This procedure                                          |
--|                                                                       |
--| HISTORY                                                               |
--|    Susan Feinstein  07-Jan-2005  Created for inventory convergence    |
--|       Bug 4165704                                                      |
--+========================================================================+
PROCEDURE get_sample_spec_disposition
( p_sample        IN  OUT NOCOPY SAMPLE_SOURCE_REC
, x_return_status OUT NOCOPY VARCHAR2
)           IS

   CURSOR Cur_get_sample_disposition IS
     SELECT b.disposition,
            d.meaning sample_disposition,
            e.meaning source
     FROM   gmd_sample_spec_disp b,
            gmd_event_spec_disp c,
            gmd_samples s,
            fnd_lookup_values_vl d,
            fnd_lookup_values_vl e
     WHERE  b.sample_id = p_sample.sample_id
       and  b.event_spec_disp_id = c.event_spec_disp_id
       and  c.spec_used_for_lot_attrib_ind = 'Y'
       and  b.disposition = d.lookup_code
       and  d.lookup_type = 'GMD_QC_SAMPLE_DISP'
       and  e.lookup_type = 'GMD_QC_SOURCE'
       and  s.sample_id   = b.sample_id
       and  e.lookup_code = s.source
     UNION
     SELECT b.disposition,
            d.meaning sample_disposition,
            e.meaning source
     FROM   gmd_sample_spec_disp b,
            gmd_event_spec_disp c,
            gmd_samples s,
            fnd_lookup_values d,
            fnd_lookup_values e
     WHERE  b.sample_id =p_sample.sample_id
       and  b.event_spec_disp_id = c.event_spec_disp_id
       and  c.spec_used_for_lot_attrib_ind = 'Y'
       and  b.disposition = d.lookup_code
       and  d.lookup_type = 'GMD_QC_SAMPLE_DISP'
       and  e.lookup_type = 'GMD_QC_MONITOR_RULE_TYPE'
       and  s.sample_id   = b.sample_id
       and  e.lookup_code = s.source ;

BEGIN
      IF (NVL(p_sample.sample_id,0) <> 0) THEN
          OPEN  Cur_get_sample_disposition;
          FETCH Cur_get_sample_disposition INTO p_sample.disposition,
                                                p_sample.sample_disposition_desc,
                                                p_sample.sample_source_desc;
          CLOSE Cur_get_sample_disposition;
      END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END get_sample_spec_disposition;


END GMD_SAMPLES_GRP;


/
