--------------------------------------------------------
--  DDL for Package Body GMD_SPEC_VRS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SPEC_VRS_GRP" AS
/* $Header: GMDGSVRB.pls 120.11.12010000.4 2009/09/18 14:54:10 plowe ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGSVRB.pls                                        |
--| Package Name       : GMD_SPEC_VRS_GRP                                    |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains group layer APIs for Specification Validity     |
--|    Rules.                                                                |
--|                                                                          |
--| HISTORY                                                                  |
--|    Chetan Nagar	26-Jul-2002	Created.                             |
--|    Olivier Daboval  17-OCT-2002     bug 2630007, added spec_name in      |
--|                                     the VR_EXIST message                 |
--|    Olivier Daboval  14-NOV-2002     Added NVL(spec_vr_id, -1) because    |
--|                                     the API passes a NULL spec_vr_id     |
--|                                     in insert mode.                      |
--|    Olivier Daboval  02-DEC-2002     Added x_wip_vr and x_inv_vr in the   |
--|                                     validation procedures                |
--|    Olivier Daboval  01-APR-2003     Now, populate the lower levels       |
--|                     Bug 2733426   Formula/Routing when recipe is given   |
--|                                                                          |
--|    Brenda Stone     20-NOV-2003     Bug 3090290; allow duplicate spec vr |
--|                                     with "OBSOLUTE" status               |
--|                                     Bug 2984784; add Version to msg for  |
--|                                     existing spec vr.                    |
--|    Jeff Baird       30-Apr-2004     Bug #3500024  Front port os 3381762  |
--|                                                                          |
--|    SaiKiran		04-MAY-2004	Enhancement #3476560. added          |
--|                                    'delayed_lot_entry' to the call to    |
--|                                    'check_vr_controls' procedure at all  |
--|                                     places                               |
--|                                                                          |
--|    Saikiran         04-MAY-2004     Enhancement# 3476560                 |
--|	                                Added 'delayed_lot_entry' to the     |
--|                     		'c_details_null' cursor and          |
--|		                        'c_details_NOT_null' cursor. Added   |
--|		                       'x_delayed_lot_entry' to the procedure|
--|		                         signature                           |
--|                                                                          |
--|    Saikiran         04-MAY-2004     Enhancement# 3476560. Added          |
--|                               'Delayed Lot Entry' field to the signature.|
--|                             Added validation for 'Delayed Lot Entry' that|
--|                      it should be 'Y' or Null. Removed special validation|
--|                for 'Lot Optional on sample' in case of WIP Validity rule.|
--|                                                                          |
--|    Saikiran         28-MAY-2004    Bug# 3652938                          |
--|                                   Added validation for the invalid       |
--|                              combination of 'Lot Optional on Sample' and |
--|                              'Delayed Lot Entry' in 'Check_VR_controls'  |
--|                              procedure                                   |
--|                                                                          |
--|  Saikiran            28-Apr-2005 Made Convergence changes                |
--|  RLNAGARA     27-Dec-2005 Bug # 4900420                                  |
--|		    Modified the procedure check_VR_controls                 |
--|  PLOWE               22-MAR-2006    Bug # 4619570  			     |
--|                         Changed the c_batch cursor to include closed     |
--|                         batches as per the profile option.               |
--|  PLOWE		  04-Apr-2006    Bug 5117733 - added item revision to|
--|                                     match in functions inv_vr_exist,     |
--|					  wip_vr_exist,cust_vr_exist,        |
--|					and supp_vr_exist                    |
--|  PLOWE                25-MAY-2006    -- bug 5223014 sql id 17532992      |
--|                       and 17532478                                       |
--|  PLOWE                07-JUN-2006    -- bug 5223014 rework               |
--|  replace cursor with function  as check was not working as designed      |
--|  bug 5223014 rework in proc check_for_null_and_fks_in_cvr  		     |
--|  srakrish  		  15-June-2006  Bug 5276602: Checking if the Lot     |
--|					optional feild is set when  	     |
--|					lot or parent lot or entered.	     |
--|				 	This scenario exists when the 	     |
--|					api is called from the wrapper.      |
--|  srakrish 		  15-june-06    BUG 5251172: Checking if the         |
--|					responsibility is available to the   |
--|					organization in all of the 	     |
--|					check_for_null_and_fks_in_ functions.|
--|RLNAGARA LPN ME 7027149 08-May-2008  Added new function check_wms_enabled |
--|                                  and signature of check_VR_controls procedure|
--|				and also added code to check_for_null_and_fks_in_*vr |
--|==========================================================================+
-- End of comments

-- Global variables
G_PKG_NAME      CONSTANT VARCHAR2(30) := 'GMD_SPEC_VRS_GRP';

-- Global Cursors

CURSOR c_orgn ( p_organization_id NUMBER) IS
  SELECT 1
  FROM mtl_parameters m
  WHERE m.process_enabled_flag = 'Y';


CURSOR c_status (p_status_code NUMBER) IS
  SELECT 1
  FROM   gmd_qc_status
  WHERE  status_code = p_status_code
  AND    delete_mark = 0;




--Start of comments
--+========================================================================+
--| API Name    : validate_mon_vr                                          |
--| TYPE        : Group                                                    |
--| Notes       : This procedure validates all the fields of               |
--|               monitoring validity rule record. This procedure can be    |
--|               called from FORM or API and the caller need              |
--|               to specify this in p_called_from parameter               |
--|               while calling this procedure. Based on where             |
--|               it is called from certain validations will               |
--|               either be performed or skipped.                          |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Olivier Daboval  11-MAR-2003     Created                            |
--|                                                                        |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE validate_mon_vr
(
  p_mon_vr        IN  GMD_MONITORING_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2
, p_operation     IN  VARCHAR2
, x_mon_vr        OUT NOCOPY GMD_MONITORING_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Local Variables
  dummy                          NUMBER;
  l_return_status                VARCHAR2(1);

  l_spec                         GMD_SPECIFICATIONS%ROWTYPE;
  l_spec_out                     GMD_SPECIFICATIONS%ROWTYPE;
  l_mon_vr                       GMD_MONITORING_SPEC_VRS%ROWTYPE;
  l_mon_vr_tmp                   GMD_MONITORING_SPEC_VRS%ROWTYPE;
  l_item_mst                     IC_ITEM_MST%ROWTYPE;
  l_item_mst_out                 IC_ITEM_MST%ROWTYPE;
  l_sampling_plan                GMD_SAMPLING_PLANS%ROWTYPE;
  l_sampling_plan_out            GMD_SAMPLING_PLANS%ROWTYPE;

  -- Exceptions
  e_spec_fetch_error             EXCEPTION;
  e_smpl_plan_fetch_error        EXCEPTION;
  e_error_fetch_item             EXCEPTION;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT (p_operation in ('INSERT', 'UPDATE', 'DELETE')) THEN
    -- Invalid Operation
    GMD_API_PUB.Log_Message('GMD_INVALID_OPERATION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Verify that the specification exists.
  l_spec.spec_id := p_mon_vr.spec_id;
  IF NOT (GMD_Specifications_PVT.Fetch_Row(
                           p_specifications => l_spec,
                           x_specifications => l_spec_out)
          ) THEN
    -- Fetch Error
    GMD_API_PUB.Log_Message('GMD_SPEC_FETCH_ERROR');
    RAISE e_spec_fetch_error;
  END IF;

  l_spec := l_spec_out ;

  -- Verify that the Sampling Plan exists.
  --odab added this test.
  IF (p_mon_vr.sampling_plan_id IS NOT NULL)
  THEN
    l_sampling_plan.sampling_plan_id := p_mon_vr.sampling_plan_id;
    IF NOT (GMD_Sampling_Plans_PVT.Fetch_Row(
                           p_sampling_plan => l_sampling_plan,
                           x_sampling_plan => l_sampling_plan_out)
          ) THEN
      -- Fetch Error
      GMD_API_PUB.Log_Message('GMD_SAMPLING_PLAN_FETCH_ERROR');
      RAISE e_smpl_plan_fetch_error;
    END IF;
    l_sampling_plan:= l_sampling_plan_out ;
  END IF;

  -- odaboval From this point, the l_mon_vr is used
  --      and will populate the return parameter x_mon_vr
  l_mon_vr := p_mon_vr;
  IF (p_called_from = 'API') THEN
    -- Check for NULLs and Valid Foreign Keys in the input parameter
    check_for_null_and_fks_in_mvr
      (
        p_mon_vr        => p_mon_vr
      , p_spec          => l_spec
      , x_mon_vr        => l_mon_vr_tmp
      , x_return_status => l_return_status
      );
    -- No need if called from FORM since it is already
    -- done in the form
    -- All messages should be already raised
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      -- Message is alrady logged by check_for_null procedure
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      -- Message is alrady logged by check_for_null procedure
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_mon_vr := l_mon_vr_tmp;
  END IF;

  -- First Verify that the SAME VR does not exists
  --IF (p_operation IN ('INSERT')
  IF (p_operation IN ('INSERT', 'UPDATE')
     AND mon_vr_exist(l_mon_vr, l_spec))
  THEN
    -- Disaster, Trying to insert duplicate
    -- Put the message in function mon_vr_exist.
    -- GMD_API_PUB.Log_Message('GMD_MON_VR_EXIST');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- No need to check the return status because above procedure
  -- logs appropriate message on the stack and raises an exception.

  -- The Start Date must be less than the End Date
  If ( l_mon_vr.end_date IS NOT NULL AND
       l_mon_vr.start_date > l_mon_vr.end_date) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_EFF_DATE_ERROR');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Spec VR Status Must be less than Spec Status upto Appoved Stages
  IF (floor(l_spec.spec_status/100) <= 7 AND
      floor(l_mon_vr.spec_vr_status/100) <= 7 AND
      l_mon_vr.spec_vr_status > l_spec.spec_status) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_STATUS_HIGHER');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- All systems GO...
  x_mon_vr := l_mon_vr;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR     OR
       e_spec_fetch_error      OR
       e_smpl_plan_fetch_error OR
       e_error_fetch_item
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END validate_mon_vr;


--Start of comments
--+========================================================================+
--| API Name    : check_for_null_and_fks_in_mvr                            |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Spec           |
--|               Monitoring VR record.                                    |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Olivier Daboval  11-MAR-2003     Created                            |
--| Saikiran Vankadari  24-Apr-2005     Convergence Changes                |
--|    srakrish  	15-june-06      BUG 5251172: Checking if the       |
--|					responsibility is available to the |
--|					organization.			   |
--+========================================================================+
-- End of comments

PROCEDURE check_for_null_and_fks_in_mvr
(
  p_mon_vr        IN  GMD_MONITORING_SPEC_VRS%ROWTYPE
, p_spec          IN  GMD_SPECIFICATIONS%ROWTYPE
, x_mon_vr        OUT NOCOPY GMD_MONITORING_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
)
IS

l_mon_vr           GMD_MONITORING_SPEC_VRS%ROWTYPE;

CURSOR c_subinventory IS
SELECT 1
FROM   mtl_secondary_inventories
WHERE  secondary_inventory_name   = l_mon_vr.subinventory
AND organization_id = l_mon_vr.locator_organization_id;

CURSOR c_locator IS
SELECT 1
FROM   mtl_item_locations
WHERE  organization_id   = l_mon_vr.locator_organization_id
AND    inventory_location_id    = l_mon_vr.locator_id;

cursor c_resources is
select 1
from cr_rsrc_mst
where resources = l_mon_vr.resources
and delete_mark = 0;

cursor c_resource_instance is
SELECT ri.INSTANCE_NUMBER
FROM GMP_RESOURCE_INSTANCES ri, CR_RSRC_DTL rd
WHERE rd.resource_id = ri.resource_id
AND   rd.organization_id = NVL(l_mon_vr.resource_organization_id, rd.organization_id)
AND   rd.resources = NVL(l_mon_vr.resources, rd.resources)
AND   ri.INACTIVE_IND = 0
ORDER BY 1 ;

dummy              NUMBER;
l_locator_type     NUMBER;
l_return_status    VARCHAR2(1);

BEGIN

  l_mon_vr := p_mon_vr;

  check_who( p_user_id  => l_mon_vr.created_by);
  check_who( p_user_id  => l_mon_vr.last_updated_by);
  IF (l_mon_vr.creation_date IS NULL
   OR l_mon_vr.last_update_date IS NULL)
  THEN
    GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'the dates must not be NULL');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Bug 3451798
  -- In case rule type is location, all resource-related info should be nulled
  -- In case rule type is resource, all location-related info should be nulled
  if (l_mon_vr.rule_type = 'R') then
     l_mon_vr.locator_id := NULL;
     l_mon_vr.locator_organization_id := NULL;
     l_mon_vr.subinventory := NULL;
  elsif (l_mon_vr.rule_type = 'L') then
     l_mon_vr.resources := NULL;
     l_mon_vr.resource_organization_id := NULL;
     l_mon_vr.resource_instance_id := NULL;
  else
   -- Bug 3451839
   -- Invalid Rule Type
    GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'The monitoring spec rule type');
    RAISE FND_API.G_EXC_ERROR;
  end if ;


  -- Loct Organization is valid
  IF (l_mon_vr.locator_organization_id IS NOT NULL) THEN
    OPEN c_orgn( l_mon_vr.locator_organization_id);
    FETCH c_orgn INTO dummy;
    IF (c_orgn%NOTFOUND)
    THEN
      CLOSE c_orgn;
      GMD_API_PUB.Log_Message('GMD_ORGANIZATION_ID_NOT_FOUND',
                              'ORGN_ID', l_mon_vr.locator_organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn;
  END IF;

  --srakrish BUG 5251172: Checking if the responsibility is available to the Locator organization.
  IF NOT (gmd_api_grp.OrgnAccessible(l_mon_vr.locator_organization_id)) THEN
    	  RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Resource is valid (Bug 3451868)
  IF (l_mon_vr.resources IS NOT NULL) THEN
    -- Check that Resource exists
    OPEN c_resources ;
    FETCH c_resources INTO dummy;
    IF (c_resources%NOTFOUND)
    THEN
      CLOSE c_resources;
      GMD_API_PUB.Log_Message('GMD_RESOURCE_NOT_FOUND',
                              'RESOURCE', l_mon_vr.resources);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_resources;
  END IF;


  -- Resource Organization is valid
  IF (l_mon_vr.resource_organization_id IS NOT NULL) THEN
    OPEN c_orgn( l_mon_vr.resource_organization_id);
    FETCH c_orgn INTO dummy;
    IF (c_orgn%NOTFOUND)
    THEN
      CLOSE c_orgn;
      GMD_API_PUB.Log_Message('GMD_ORGANIZATION_ID_NOT_FOUND',
                              'ORGN_ID', l_mon_vr.resource_organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn;
  END IF;

  --srakrish BUG 5251172: Checking if the responsibility is available to the Resource organization.
  IF NOT (gmd_api_grp.OrgnAccessible(l_mon_vr.resource_organization_id)) THEN
    	  RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Resource Instance is valid (Bug 3451868)
  IF (l_mon_vr.resource_instance_id IS NOT NULL) THEN
    -- Check that Resource instance idexists
    OPEN c_resource_instance ;
    FETCH c_resource_instance INTO dummy;
    IF (c_resource_instance%NOTFOUND)
    THEN
      CLOSE c_resource_instance;
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'The resource instance');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_resource_instance;
  END IF;


  -- Subinventory is Valid
  IF (l_mon_vr.subinventory IS NOT NULL) THEN
    -- Check that Subinventory exist and is associated with locator organization.
    OPEN c_subinventory;
    FETCH c_subinventory INTO dummy;
    IF (c_subinventory%NOTFOUND)
    THEN
      CLOSE c_subinventory;
      GMD_API_PUB.Log_Message('GMD_SUBINVENTORY_NOT_FOUND',
                              'SUBINVENTORY', l_mon_vr.subinventory);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_subinventory;

  END IF;

  --Find out if it is locator controlled
  GMD_COMMON_GRP.item_is_locator_controlled (
                      p_organization_id => l_mon_vr.locator_organization_id
                     ,p_subinventory => l_mon_vr.subinventory
                     ,p_inventory_item_id => NULL
                     ,x_locator_type   => l_locator_type
                     ,x_return_status  => l_return_status);

  -- Location is valid
  IF (l_locator_type IN (2,3))
  THEN
    -- Here l_locator_type IN (2,3)
    IF (l_mon_vr.locator_id IS NULL)
    THEN
      -- Location can be NULL in this case.
      null;
    ELSE
      -- Check that Location exist in MTL_ITEM_LOCATIONS
      OPEN c_locator;
      FETCH c_locator INTO dummy;
      IF (c_locator%NOTFOUND)
      THEN
        CLOSE c_locator;
        GMD_API_PUB.Log_Message('GMD_LOCT_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_locator;
    END IF;   -- location IS NOT NULL
  ELSE --l_locator_type NOT IN (2,3)
    IF (l_mon_vr.locator_id IS NOT NULL)
    THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'locator should be NULL');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;   -- l_locator_type IN (2,3)

  --=========================================================================
  -- spec_vr_status :
  --=========================================================================
  -- Check that Spec VR Status exist in GMD_QC_STATUS
  OPEN c_status(l_mon_vr.spec_vr_status);
  FETCH c_status
   INTO dummy;
  IF (c_status%NOTFOUND)
  THEN
    CLOSE c_status;
    GMD_API_PUB.Log_Message('GMD_SPEC_STATUS_NOT_FOUND',
                            'STATUS', l_mon_vr.spec_vr_status);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_status;

  --=========================================================================
  -- start_date : This field is mandatory
  --=========================================================================
  IF (l_mon_vr.start_date IS NULL)
  THEN
      GMD_API_PUB.Log_Message('GMD_SPEC_VR_START_DATE_REQD');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_mon_vr := l_mon_vr;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END check_for_null_and_fks_in_mvr;





--Start of comments
--+========================================================================+
--| API Name    : mon_vr_exist                                             |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the monitoring VR already   |
--|               exists for the spcified parameter in the database, FALSE |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Olivier Daboval  17-OCT-2002     bug 2630007, added spec_name in    |
--|                                     the VR_EXIST message               |
--|    Olivier Daboval  14-NOV-2002     Added NVL(spec_vr_id, -1) because  |
--|                                     the API passes a NULL spec_vr_id   |
--|                                     in insert mode.                    |
--|    Brenda Stone     20-NOV-2003     Bug 3090290; allow duplicate spec vr |
--|                                     with "OBSOLUTE" status               |
--|                                     Bug 2984784; add Version to msg for  |
--|                                     existing spec vr.                    |
--|                                                                        |
--|  Saikiran          12-Apr-2005      Convergence Changes                |
--+========================================================================+
-- End of comments

FUNCTION mon_vr_exist(p_mon_vr GMD_MONITORING_SPEC_VRS%ROWTYPE,
                      p_spec   GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN IS

  CURSOR c_mon_vr IS
  SELECT vr.spec_vr_id, s.spec_name, s.spec_vers
  FROM   gmd_specifications_b s, gmd_monitoring_spec_vrs vr
  WHERE  s.spec_id = vr.spec_id
  AND    ((s.grade_code is NULL AND p_spec.grade_code is NULL) OR
          (s.grade_code = p_spec.grade_code)
         )
  AND    ((vr.locator_organization_id is NULL AND p_mon_vr.locator_organization_id is NULL) OR
          (vr.locator_organization_id = p_mon_vr.locator_organization_id)
         )
  AND    ((vr.subinventory is NULL AND p_mon_vr.subinventory is NULL) OR
          (vr.subinventory = p_mon_vr.subinventory)
         )
  AND    ((vr.locator_id is NULL  AND p_mon_vr.locator_id is NULL) OR
          (vr.locator_id = p_mon_vr.locator_id)
         )
  AND    ((vr.resource_organization_id is NULL AND p_mon_vr.resource_organization_id is NULL) OR
          (vr.resource_organization_id = p_mon_vr.resource_organization_id)
         )
  AND    ((vr.resources is NULL AND p_mon_vr.resources is NULL) OR
          (vr.resources = p_mon_vr.resources)
         )
  AND    ((vr.resource_instance_id is NULL AND p_mon_vr.resource_instance_id is NULL) OR
          (vr.resource_instance_id = p_mon_vr.resource_instance_id)
         )
  AND    ((vr.end_date is NULL AND (p_mon_vr.end_date IS NULL OR
                                    p_mon_vr.end_date >= vr.start_date)) OR
	  (p_mon_vr.end_date IS NULL AND
	     p_mon_vr.start_date <= nvl(vr.end_date, p_mon_vr.start_date)) OR
          (p_mon_vr.start_date <= vr.end_date AND p_mon_vr.end_date >= vr.start_date)
         )
  AND   ( floor(vr.spec_vr_status / 100) = floor(p_mon_vr.spec_vr_status/100)  AND
/*      Bug 3090290; allow duplicate spec vr with "OBSOLUTE" status   */
         p_mon_vr.spec_vr_status <> 1000 )
  AND    vr.spec_vr_status NOT IN (SELECT status_code FROM gmd_qc_status
                                   WHERE status_type = 800)
  AND    vr.delete_mark = 0
  AND    s.delete_mark = 0
  AND    vr.spec_vr_id <> NVL(p_mon_vr.spec_vr_id, -1)
  ;

  dummy    PLS_INTEGER;
  specname VARCHAR2(80);
  specvers NUMBER;

BEGIN

  OPEN c_mon_vr;
  FETCH c_mon_vr INTO dummy, specname, specvers;
  IF c_mon_vr%FOUND THEN
    CLOSE c_mon_vr;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_MON_VR_EXIST');
    FND_MESSAGE.SET_TOKEN('spec', specname);
    FND_MESSAGE.SET_TOKEN('vers', specvers);
    FND_MSG_PUB.ADD;
    RETURN TRUE;
  ELSE
    CLOSE c_mon_vr;
    RETURN FALSE;
  END IF;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PACKAGE', 'GMD_SPEC_VRS_GRP.MON_VR_EXIST' );
    FND_MESSAGE.SET_TOKEN('ERROR', SUBSTR(SQLERRM,1,200));
    FND_MSG_PUB.ADD;

    RETURN TRUE;

END mon_vr_exist;


--Start of comments
--+========================================================================+
--| API Name    : validate_inv_vr                                          |
--| TYPE        : Group                                                    |
--| Notes       : This procedure validates all the fields of               |
--|               inventory validity rule record. This procedure can be    |
--|               called from FORM or API and the caller need              |
--|               to specify this in p_called_from parameter               |
--|               while calling this procedure. Based on where             |
--|               it is called from certain validations will               |
--|               either be performed or skipped.                          |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Olivier Daboval  02-DEC-2002     Added x_inv_vr as out parameter    |
--|    srakrish  	15-June-2006  Bug 5276602: Checking if the Lot     |
--|					optionalfeild is  set to yes when  |
--|					lot or parent lot or entered.	   |
--|				 	This scenario exists when the 	   |
--|					api is called from the wrapper.    |
--|                                                                        |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE validate_inv_vr
(
  p_inv_vr        IN  GMD_INVENTORY_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2
, p_operation     IN  VARCHAR2
, x_inv_vr        OUT NOCOPY GMD_INVENTORY_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Local Variables
  dummy                          NUMBER;
  l_return_status                VARCHAR2(1);

  l_spec                         GMD_SPECIFICATIONS%ROWTYPE;
  l_spec_out                     GMD_SPECIFICATIONS%ROWTYPE;
  l_inv_vr                       GMD_INVENTORY_SPEC_VRS%ROWTYPE;
  l_inv_vr_tmp                   GMD_INVENTORY_SPEC_VRS%ROWTYPE;
  l_item_mst                     MTL_SYSTEM_ITEMS_B%ROWTYPE;
  l_sampling_plan                GMD_SAMPLING_PLANS%ROWTYPE;
  l_sampling_plan_out            GMD_SAMPLING_PLANS%ROWTYPE;
  l_inventory_item_id            NUMBER;
  l_organization_id              NUMBER;
  l_uom_rate                     NUMBER;

  -- Exceptions
  e_spec_fetch_error             EXCEPTION;
  e_smpl_plan_fetch_error        EXCEPTION;
  e_error_fetch_item               EXCEPTION;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT (p_operation in ('INSERT', 'UPDATE', 'DELETE')) THEN
    -- Invalid Operation
    GMD_API_PUB.Log_Message('GMD_INVALID_OPERATION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Verify that the specification exists.
  l_spec.spec_id := p_inv_vr.spec_id;
  IF NOT (GMD_Specifications_PVT.Fetch_Row(
                           p_specifications => l_spec,
                           x_specifications => l_spec_out)
          ) THEN
    -- Fetch Error
    GMD_API_PUB.Log_Message('GMD_SPEC_FETCH_ERROR');
    RAISE e_spec_fetch_error;
  END IF;

  l_spec := l_spec_out ;

  -- Verify that the Sampling Plan exists.
  --odab added this test.
  IF (p_inv_vr.sampling_plan_id IS NOT NULL)
  THEN
    l_sampling_plan.sampling_plan_id := p_inv_vr.sampling_plan_id;
    IF NOT (GMD_Sampling_Plans_PVT.Fetch_Row(
                           p_sampling_plan => l_sampling_plan,
                           x_sampling_plan => l_sampling_plan_out)
          ) THEN
      -- Fetch Error
      GMD_API_PUB.Log_Message('GMD_SAMPLING_PLAN_FETCH_ERROR');
      RAISE e_smpl_plan_fetch_error;
    END IF;
    l_sampling_plan:= l_sampling_plan_out ;
  END IF;

  -- bug 2691994  02-DEC-02:
  -- odaboval From this point, the l_inv_vr is used
  --      and will populate the return parameter x_inv_vr
  l_inv_vr := p_inv_vr;
  IF (p_called_from = 'API') THEN
    --For mini pack L, bug 3439865
    IF ( nvl(p_inv_vr.auto_sample_ind,'N') not in ('N','Y')) THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'INVALID_AUTO_SAMPLE_IND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- end 3439865
    -- Check for NULLs and Valid Foreign Keys in the input parameter
    check_for_null_and_fks_in_ivr
      (
        p_inv_vr        => p_inv_vr
      , p_spec          => l_spec
      , x_inv_vr        => l_inv_vr_tmp
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

    l_inv_vr := l_inv_vr_tmp;
  END IF;

  -- First Verify that the SAME VR does not exists
  -- bug 2691994  02-DEC-02, odaboval changed p_inv_vr by l_inv_vr
  --IF (p_operation IN ('INSERT')
  IF (p_operation IN ('INSERT', 'UPDATE')
     AND inv_vr_exist(l_inv_vr, l_spec))
  THEN
    -- Disaster, Trying to insert duplicate
    -- bug 2630007, odaboval put the message in function inv_vr_exist.
    -- GMD_API_PUB.Log_Message('GMD_INV_VR_EXIST');
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- Check to make sure that a samplingplan exists
  -- if auto sample flag on
  IF ((p_inv_vr.sampling_plan_id IS NULL) and
       (p_inv_vr.auto_sample_ind = 'Y'))
  THEN
      GMD_API_PUB.Log_Message('GMD_NEED_SAMPLE_PLAN');
      RAISE e_smpl_plan_fetch_error;
  END IF;


  -- Sample Quantity UOM must be convertible to Item's UOM
  BEGIN
    SELECT inventory_item_id INTO l_inventory_item_id FROM
    gmd_specifications WHERE spec_id = p_inv_vr.spec_id;
    SELECT owner_organization_id INTO l_organization_id FROM
    gmd_specifications WHERE spec_id = p_inv_vr.spec_id;
    SELECT * INTO l_item_mst
    FROM mtl_system_items_b
    WHERE inventory_item_id = l_inventory_item_id
    AND organization_id = l_organization_id;
  EXCEPTION
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_ITEM_FETCH_ERROR');
    RAISE e_error_fetch_item;
  END;

  IF (l_inv_vr.sampling_plan_id IS NOT NULL)
  THEN
    --As part of Convergence, the following call is replaced with new one.
    /*GMICUOM.icuomcv(pitem_id => l_item_mst.item_id,
                      plot_id  => 0,
                      pcur_qty => 1,
                      pcur_uom => l_sampling_plan.sample_uom,
                      pnew_uom => l_item_mst.item_um,
                      onew_qty => dummy);*/
    inv_convert.inv_um_conversion (
      from_unit  => l_sampling_plan.sample_qty_uom,
      to_unit    =>  l_item_mst.primary_uom_code,
      item_id    =>  l_inventory_item_id,
      lot_number => NULL,
      organization_id => l_organization_id  ,
      uom_rate   => l_uom_rate );

    IF l_uom_rate = -99999 THEN
      GMD_API_PUB.Log_Message('GMD_UOM_CONVERSION_ERROR');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- No need to check the return status because above procedure
  -- logs appropriate message on the stack and raises an exception.

  -- The Start Date must be less than the End Date
  -- bug 2691994  02-DEC-02, odaboval changed p_inv_vr by l_inv_vr
  If ( l_inv_vr.end_date IS NOT NULL AND
       l_inv_vr.start_date > l_inv_vr.end_date) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_EFF_DATE_ERROR');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Spec VR Status Must be less than Spec Status upto Appoved Stages
  IF (floor(l_spec.spec_status/100) <= 7 AND
      floor(l_inv_vr.spec_vr_status/100) <= 7 AND
      l_inv_vr.spec_vr_status > l_spec.spec_status) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_STATUS_HIGHER');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- srakrish Bug 5276602: Checking if the Lot optionalfeild is set to yes when lot or parent lot or entered.
  -- This scenario exists when the api is called from the wrapper.
  IF l_inv_vr.lot_number IS NOT NULL or l_inv_vr.parent_lot_number IS NOT NULL then
   IF l_inv_vr.lot_optional_on_sample = 'Y'  THEN
     GMD_API_PUB.Log_Message('GMD_SPEC_VR_LOT_CNTRL_INVALID');
     RAISE FND_API.G_EXC_ERROR;
   END IF;
  END IF;

  -- All systems GO...
  x_inv_vr := l_inv_vr;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR     OR
       e_spec_fetch_error      OR
       e_smpl_plan_fetch_error OR
       e_error_fetch_item
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END validate_inv_vr;


--Start of comments
--+========================================================================+
--| API Name    : check_for_null_and_fks_in_ivr                            |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Spec           |
--|               Inventory VR record.                                     |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Olivier Daboval  02-DEC-2002     Added x_inv_vr as out parameter    |
--|    Jeff Baird       30-Apr-2004     Bug #3500024                       |
--|                     Three following fixes ported to L.                 |
--|    P.Raghu          23-JAN-2004     Bug#3381762                        |
--|                     Modified the existing logic for Validation of      |
--|                     lot_id and lot_no and sublot as suggested          |
--|    Jeff Baird       05-Mar-2004     Bug #3476572                       |
--|                     Added update to lot_id if lot_no / sublot_no passed|
--|    Jeff Baird       20-Apr-2004     Bug #3582010                       |
--|                     Added l_sublot_no where it was left out.           |
--|                                                                        |
--|    SaiKiran		04-MAY-2004	Enhancement #3476560. added        |
--|                  'delayed_lot_entry' to the call to 'check_vr_controls'|
--|                   procedure.                                           |
--|                                                                        |
--|  Saikiran          24-Apr-2005  Convergence Changes                    |
--|  srakrish 	       15-june-06    BUG 5251172: Checking if the          |
--|					responsibility is available to the |
--|					organization			   |
--+========================================================================+
-- End of comments

PROCEDURE check_for_null_and_fks_in_ivr
(
  p_inv_vr        IN  GMD_INVENTORY_SPEC_VRS%ROWTYPE
, p_spec          IN  GMD_SPECIFICATIONS%ROWTYPE
, x_inv_vr        OUT NOCOPY GMD_INVENTORY_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
)
IS

l_inv_vr           GMD_INVENTORY_SPEC_VRS%ROWTYPE;
l_spec             GMD_SPECIFICATIONS%ROWTYPE;

CURSOR c_item_lot_number IS
SELECT 1
FROM mtl_lot_numbers
WHERE organization_id = l_inv_vr.organization_id
AND inventory_item_id = l_spec.inventory_item_id
AND lot_number = l_inv_vr.lot_number;

CURSOR c_item_parent_lot IS
SELECT 1
FROM mtl_lot_numbers
WHERE organization_id = l_inv_vr.organization_id
AND inventory_item_id = l_spec.inventory_item_id
AND parent_lot_number = l_inv_vr.parent_lot_number;


CURSOR c_subinventory IS
SELECT 1
FROM   mtl_secondary_inventories
WHERE  secondary_inventory_name   = l_inv_vr.subinventory
AND organization_id = l_inv_vr.organization_id;

CURSOR c_locator IS
SELECT 1
FROM   mtl_item_locations
WHERE  organization_id   = l_inv_vr.organization_id
AND    inventory_location_id    = l_inv_vr.locator_id;



l_sample_display   GMD_SAMPLES_GRP.sample_display_rec;
dummy              NUMBER;
l_status_ctl       VARCHAR2(1);
l_lot_ctl          NUMBER;
l_child_lot_ctl       VARCHAR2(1);
l_locator_type     NUMBER;
l_return_status    VARCHAR2(1);

BEGIN
  l_inv_vr := p_inv_vr;
  l_spec := p_spec;

  check_who( p_user_id  => l_inv_vr.created_by);
  check_who( p_user_id  => l_inv_vr.last_updated_by);
  IF (l_inv_vr.creation_date IS NULL
   OR l_inv_vr.last_update_date IS NULL)
  THEN
    GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'the dates must not be NULL');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Organization is valid
  IF (l_inv_vr.organization_id IS NOT NULL) THEN
    -- Check that Organization is a valid one.
    OPEN c_orgn( l_inv_vr.organization_id);
    FETCH c_orgn INTO dummy;
    IF (c_orgn%NOTFOUND)
    THEN
      CLOSE c_orgn;
      GMD_API_PUB.Log_Message('GMD_ORGANIZATION_ID_NOT_FOUND',
                              'ORGN_ID', l_inv_vr.organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn;
  END IF;

  --srakrish BUG 5251172: Checking if the responsibility is available to the organization.
  IF NOT (gmd_api_grp.OrgnAccessible(l_inv_vr.organization_id)) THEN
   	  RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- Get Item Controls
  --=========================================================================

  l_sample_display.organization_id := l_inv_vr.organization_id;
  l_sample_display.inventory_item_id := l_spec.inventory_item_id;
  GMD_SAMPLES_GRP.get_item_values (p_sample_display => l_sample_display);
  l_lot_ctl := l_sample_display.lot_control_code;
  l_status_ctl := l_sample_display.lot_status_enabled;
  l_child_lot_ctl := l_sample_display.child_lot_flag;

  GMD_COMMON_GRP.item_is_locator_controlled (
                      p_organization_id   => l_inv_vr.organization_id
                     ,p_subinventory      => l_inv_vr.subinventory
                     ,p_inventory_item_id => l_spec.inventory_item_id
                     ,x_locator_type      => l_locator_type
                     ,x_return_status     => l_return_status);

  IF (l_inv_vr.lot_number IS NOT NULL)
  THEN
      IF (l_lot_ctl = 2) THEN --Item is lot controlled
        OPEN c_item_lot_number;
        FETCH c_item_lot_number INTO dummy;
        IF (c_item_lot_number%NOTFOUND)
        THEN
          CLOSE c_item_lot_number;
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'lot_number');
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE c_item_lot_number;
      ELSE --Item is not lot controlled
         FND_MESSAGE.SET_NAME('GMD','GMD_ITEM_NOT_LOT_CONTROL');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  IF (l_inv_vr.parent_lot_number IS NOT NULL)
  THEN
      IF (l_child_lot_ctl = 'Y') THEN --Item is child lot controlled
        OPEN c_item_parent_lot;
        FETCH c_item_parent_lot INTO dummy;
        IF (c_item_parent_lot%NOTFOUND)
        THEN
          CLOSE c_item_parent_lot;
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'parent_lot_number');
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE c_item_parent_lot;
      ELSE --Item is not child lot controlled
         FND_MESSAGE.SET_NAME('GMD','GMD_ITEM_NOT_CHILD_LOT_CONTROL');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  -- Subinventory is Valid
  IF (l_inv_vr.subinventory IS NOT NULL) THEN
    OPEN c_subinventory;
    FETCH c_subinventory INTO dummy;
    IF (c_subinventory%NOTFOUND)
    THEN
      CLOSE c_subinventory;
      GMD_API_PUB.Log_Message('GMD_SUBINVENTORY_NOT_FOUND',
                              'SUBINVENTORY', l_inv_vr.subinventory);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_subinventory;
  END IF;

  -- Location is valid
  IF (l_locator_type IN (2,3))
  THEN
    -- Here l_locator_type IN (2,3)
    IF (l_inv_vr.locator_id IS NULL)
    THEN
      -- Location can be NULL in this case.
      null;
    ELSE
      -- Check that Location exist in MTL_ITEM_LOCATIONS
      OPEN c_locator;
      FETCH c_locator INTO dummy;
      IF (c_locator%NOTFOUND)
      THEN
        CLOSE c_locator;
        GMD_API_PUB.Log_Message('GMD_LOCT_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_locator;
    END IF;   -- location IS NOT NULL
  ELSE     -- Here l_locator_type not IN (2,3)
    IF (l_inv_vr.locator_id IS NOT NULL)
    THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'locator should be NULL');
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;   -- l_locator_type IN (2,3)
  --=========================================================================
  -- lot_optional_on_sample :
  -- When this field is NOT NULL, all the following fields must be null :
  -- sample_inv_trans_ind, control_lot_attrib_ind, in_spec_lot_status, out_of_spec_lot_status
  --=========================================================================
  --Enhancement #3476560. added 'delayed_lot_entry' to the call to 'check_vr_controls' procedure
  check_VR_Controls( p_VR_type                  => 'INVENTORY'
                   , p_lot_optional_on_sample   => l_inv_vr.lot_optional_on_sample
		   , p_delayed_lot_entry        => l_inv_vr.delayed_lot_entry
                   , p_sample_inv_trans_ind     => l_inv_vr.sample_inv_trans_ind
                   , p_lot_ctl                  => l_lot_ctl
                   , p_status_ctl               => l_status_ctl
                   , p_control_lot_attrib_ind   => l_inv_vr.control_lot_attrib_ind
                   , p_in_spec_lot_status_id    => l_inv_vr.in_spec_lot_status_id
                   , p_out_of_spec_lot_status_id=> l_inv_vr.out_of_spec_lot_status_id
                   , p_control_batch_step_ind   => NULL
		   , p_delayed_lpn_entry        => l_inv_vr.delayed_lpn_entry);    --RLNAGARA LPN ME 7027149


  --RLNAGARA LPN ME 7027149 start  Check for WMS enabled organization.
  IF (l_inv_vr.organization_id IS NOT NULL) THEN
    IF NOT check_wms_enabled(l_inv_vr.organization_id) THEN  -- If the Org is not a wms enabled then delayed_lpn_entry should be NULL
      IF l_inv_vr.delayed_lpn_entry IS NOT NULL THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Delayed_LPN_Entry should be NULL for Non-WMS Enabled Organization.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;
  --RLNAGARA LPN ME 7027149 end

  --=========================================================================
  -- spec_vr_status :
  --=========================================================================
  -- Check that Spec VR Status exist in GMD_QC_STATUS
  OPEN c_status(l_inv_vr.spec_vr_status);
  FETCH c_status
   INTO dummy;
  IF (c_status%NOTFOUND)
  THEN
    CLOSE c_status;
    GMD_API_PUB.Log_Message('GMD_SPEC_STATUS_NOT_FOUND',
                            'STATUS', l_inv_vr.spec_vr_status);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_status;

  --=========================================================================
  -- start_date : This field is mandatory
  --=========================================================================
  IF (l_inv_vr.start_date IS NULL)
  THEN
      GMD_API_PUB.Log_Message('GMD_SPEC_VR_START_DATE_REQD');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- COA section :
  --=========================================================================
  check_COA( p_coa_type              => l_inv_vr.coa_type
           , p_coa_at_ship_ind       => l_inv_vr.coa_at_ship_ind
           , p_coa_at_invoice_ind    => l_inv_vr.coa_at_invoice_ind
           , p_coa_req_from_supl_ind => l_inv_vr.coa_req_from_supl_ind);

  x_inv_vr := l_inv_vr;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END check_for_null_and_fks_in_ivr;





--Start of comments
--+========================================================================+
--| API Name    : inv_vr_exist                                             |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the inventory VR already   |
--|               exists for the spcified parameter in the database, FALSE |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Olivier Daboval  17-OCT-2002     bug 2630007, added spec_name in    |
--|                                     the VR_EXIST message               |
--|    Olivier Daboval  14-NOV-2002     Added NVL(spec_vr_id, -1) because  |
--|                                     the API passes a NULL spec_vr_id   |
--|                                     in insert mode.                    |
--|    Brenda Stone     20-NOV-2003     Bug 3090290; allow duplicate spec vr |
--|                                     with "OBSOLUTE" status               |
--|                                     Bug 2984784; add Version to msg for  |
--|                                     existing spec vr.                    |
--|                                                                        |
--|  Saikiran          12-Apr-2005      Convergence Changes                |
--|  Plowe						 04-Apr-2006      Bug 5117733 - added item revision to match
--+========================================================================+
-- End of comments

FUNCTION inv_vr_exist(p_inv_vr GMD_INVENTORY_SPEC_VRS%ROWTYPE,
                      p_spec   GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN IS

  CURSOR c_inv_vr IS
  SELECT vr.spec_vr_id, s.spec_name, s.spec_vers
  FROM   gmd_specifications_b s, gmd_inventory_spec_vrs vr
  WHERE  s.spec_id = vr.spec_id
  AND    s.owner_organization_id = p_spec.owner_organization_id
  AND    s.inventory_item_id = p_spec.inventory_item_id
  AND   ( (s.revision is null and p_spec.revision is NULL ) OR -- handle item revision 5117733
          (s.revision  = p_spec.revision )
  			 )
  AND    ((s.grade_code is NULL AND p_spec.grade_code is NULL) OR
          (s.grade_code = p_spec.grade_code)
         )

  AND    ((vr.organization_id is NULL AND p_inv_vr.organization_id is NULL) OR
          (vr.organization_id = p_inv_vr.organization_id)
         )
  AND    ((vr.lot_number is NULL AND p_inv_vr.lot_number is NULL) OR
          (vr.lot_number = p_inv_vr.lot_number)
         )
  AND    ((vr.parent_lot_number is NULL AND p_inv_vr.parent_lot_number is NULL) OR
          (vr.parent_lot_number = p_inv_vr.parent_lot_number)
         )
  AND    ((vr.subinventory is NULL AND p_inv_vr.subinventory is NULL) OR
          (vr.subinventory = p_inv_vr.subinventory)
         )
  AND    ((vr.locator_id is NULL  AND p_inv_vr.locator_id is NULL) OR
          (vr.locator_id = p_inv_vr.locator_id)
         )
  AND    ((vr.end_date is NULL AND (p_inv_vr.end_date IS NULL OR
                                    p_inv_vr.end_date >= vr.start_date)) OR
	  (p_inv_vr.end_date IS NULL AND
	     p_inv_vr.start_date <= nvl(vr.end_date, p_inv_vr.start_date)) OR
          (p_inv_vr.start_date <= vr.end_date AND p_inv_vr.end_date >= vr.start_date)
         )
  AND   ( floor(vr.spec_vr_status / 100) = floor(p_inv_vr.spec_vr_status/100)  AND
/*      Bug 3090290; allow duplicate spec vr with "OBSOLUTE" status   */
         p_inv_vr.spec_vr_status <> 1000 )
  AND    vr.spec_vr_status NOT IN (SELECT status_code FROM gmd_qc_status
                                   WHERE status_type = 800)
  AND    vr.delete_mark = 0
  AND    s.delete_mark = 0
  AND    vr.spec_vr_id <> NVL(p_inv_vr.spec_vr_id, -1)
  ;

  dummy    PLS_INTEGER;
  specname VARCHAR2(80);
  specvers NUMBER;

BEGIN

  OPEN c_inv_vr;
  FETCH c_inv_vr INTO dummy, specname, specvers;
  IF c_inv_vr%FOUND THEN
    CLOSE c_inv_vr;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_INV_VR_EXIST');
    FND_MESSAGE.SET_TOKEN('spec', specname);
    FND_MESSAGE.SET_TOKEN('vers', specvers);
    FND_MSG_PUB.ADD;
    RETURN TRUE;
  ELSE
    CLOSE c_inv_vr;
    RETURN FALSE;
  END IF;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PACKAGE', 'GMD_SPEC_VRS_GRP.INV_VR_EXIST' );
    FND_MESSAGE.SET_TOKEN('ERROR', SUBSTR(SQLERRM,1,200));
    FND_MSG_PUB.ADD;

    RETURN TRUE;

END inv_vr_exist;


--Start of comments
--+========================================================================+
--| API Name    : validate_wip_vr                                          |
--| TYPE        : Group                                                    |
--| Notes       : This procedure validates all the fields of               |
--|               WIP       validity rule record. This procedure can be    |
--|               called from FORM or API and the caller need              |
--|               to specify this in p_called_from parameter               |
--|               while calling this procedure. Based on where             |
--|               it is called from certain validations will               |
--|               either be performed or skipped.                          |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Olivier Daboval  02-DEC-2002     Added x_wip_vr as out parameter    |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE validate_wip_vr
(
  p_wip_vr        IN  GMD_WIP_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2
, p_operation     IN  VARCHAR2
, x_wip_vr        OUT NOCOPY GMD_WIP_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Local Variables
  dummy                          NUMBER;
  l_return_status                VARCHAR2(1);

  l_spec                         GMD_SPECIFICATIONS%ROWTYPE;
  l_spec_out                     GMD_SPECIFICATIONS%ROWTYPE;
  l_wip_vr                       GMD_WIP_SPEC_VRS%ROWTYPE;
  l_wip_vr_tmp                   GMD_WIP_SPEC_VRS%ROWTYPE;
  l_item_mst                     MTL_SYSTEM_ITEMS_B%ROWTYPE;
  l_sampling_plan                GMD_SAMPLING_PLANS%ROWTYPE;
  l_sampling_plan_out            GMD_SAMPLING_PLANS%ROWTYPE;
  l_inventory_item_id            NUMBER;
  l_organization_id              NUMBER;
  l_uom_rate                     NUMBER;

  -- Exceptions
  e_spec_fetch_error             EXCEPTION;
  e_smpl_plan_fetch_error        EXCEPTION;
  e_error_fetch_item             EXCEPTION;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT (p_operation in ('INSERT', 'UPDATE', 'DELETE')) THEN
    -- Invalid Operation
    GMD_API_PUB.Log_Message('GMD_INVALID_OPERATION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Verify that the specification exists.
  l_spec.spec_id := p_wip_vr.spec_id;
  IF NOT (GMD_Specifications_PVT.Fetch_Row(
                           p_specifications => l_spec,
                           x_specifications => l_spec_out)
          ) THEN
    -- Fetch Error
    GMD_API_PUB.Log_Message('GMD_SPEC_FETCH_ERROR');
    RAISE e_spec_fetch_error;
  END IF;

  l_spec := l_spec_out ;

  -- Verify that the Sampling Plan exists.
  --odab added this test.
  IF (p_wip_vr.sampling_plan_id IS NOT NULL)
  THEN
    l_sampling_plan.sampling_plan_id := p_wip_vr.sampling_plan_id;
    IF NOT (GMD_Sampling_Plans_PVT.Fetch_Row(
                           p_sampling_plan => l_sampling_plan,
                           x_sampling_plan => l_sampling_plan_out)
          ) THEN
      -- Fetch Error
      GMD_API_PUB.Log_Message('GMD_SAMPLING_PLAN_FETCH_ERROR');
      RAISE e_smpl_plan_fetch_error;
    END IF;
    l_sampling_plan := l_sampling_plan_out ;
  END IF;

  -- Check to make sure that a samplingplan exists
  -- if auto sample flag on

  IF ((p_wip_vr.sampling_plan_id IS NULL) and
       (p_wip_vr.auto_sample_ind = 'Y'))
  THEN
      GMD_API_PUB.Log_Message('GMD_NEED_SAMPLE_PLAN');
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- bug 2691994  02-DEC-02:
  -- odaboval From this point, the l_wip_vr is used
  --      and will populate the return parameter x_wip_vr
  l_wip_vr := p_wip_vr;
  IF (p_called_from = 'API') THEN
    --For mini pack L, bug 3439865
    IF (nvl(p_wip_vr.auto_sample_ind,'N') not in ('N','Y')) THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'INVALID_AUTO_SAMPLE_IND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- end 3439865
    -- Check for NULLs and Valid Foreign Keys in the input parameter
    GMD_SPEC_VRS_GRP.check_for_null_and_fks_in_wvr
      (
        p_wip_vr        => p_wip_vr
      , p_spec          => l_spec
      , x_wip_vr        => l_wip_vr_tmp
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

    l_wip_vr := l_wip_vr_tmp;
  END IF;

  -- First Verify that the SAME VR does not exists
  -- bug 2691994  02-DEC-02, odaboval changed p_wip_vr by l_wip_vr
  IF (p_operation IN ('INSERT', 'UPDATE')
   AND wip_vr_exist(l_wip_vr, l_spec))
  THEN
    -- Disaster, Trying to insert duplicate
    -- bug 2630007, odaboval put the message in function wip_vr_exist.
    -- GMD_API_PUB.Log_Message('GMD_WIP_VR_EXIST');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Sample Quantity UOM must be convertible to Item's UOM
  BEGIN
    SELECT inventory_item_id INTO l_inventory_item_id FROM
    gmd_specifications WHERE spec_id = p_wip_vr.spec_id;
    SELECT owner_organization_id INTO l_organization_id FROM
    gmd_specifications WHERE spec_id = p_wip_vr.spec_id;
    SELECT * INTO l_item_mst
    FROM mtl_system_items_b
    WHERE inventory_item_id = l_inventory_item_id
    AND organization_id = l_organization_id;
  EXCEPTION
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_ITEM_FETCH_ERROR');
    RAISE e_error_fetch_item;
  END;


  --odab added this test.
  -- bug 2691994  02-DEC-02, odaboval changed p_wip_vr by l_wip_vr
  IF (l_wip_vr.sampling_plan_id IS NOT NULL)
  THEN

    inv_convert.inv_um_conversion (
      from_unit  => l_sampling_plan.sample_qty_uom,
      to_unit    =>  l_item_mst.primary_uom_code,
      item_id    =>  l_inventory_item_id,
      lot_number => NULL,
      organization_id => l_organization_id,
      uom_rate   => l_uom_rate );

    IF l_uom_rate = -99999 THEN
      GMD_API_PUB.Log_Message('GMD_UOM_CONVERSION_ERROR');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- No need to check the return status because above procedure
  -- logs appropriate message on the stack and raises an exception.

  -- The Start Date must be less than the End Date
  -- bug 2691994  02-DEC-02, odaboval changed p_wip_vr by l_wip_vr
  If ( l_wip_vr.end_date IS NOT NULL AND
       l_wip_vr.start_date > l_wip_vr.end_date) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_EFF_DATE_ERROR');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Spec VR Status Must be less than Spec Status upto Appoved Stages
  -- bug 2691994  02-DEC-02, odaboval changed p_wip_vr by l_wip_vr
  IF (floor(l_spec.spec_status/100) <= 7 AND
      floor(l_wip_vr.spec_vr_status/100) <= 7 AND
      l_wip_vr.spec_vr_status > l_spec.spec_status) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_STATUS_HIGHER');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- All systems GO...
  x_wip_vr := l_wip_vr;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR     OR
       e_spec_fetch_error      OR
       e_smpl_plan_fetch_error OR
       e_error_fetch_item

  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END validate_wip_vr;




--Start of comments
--+========================================================================+
--| API Name    : check_for_null_and_fks_in_wvr                            |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Spec           |
--|               WIP       VR record.                                     |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Olivier Daboval  02-DEC-2002     Added x_wip_vr as out parameter    |
--|    Olivier Daboval  01-APR-2003     Now, populate the lower levels     |
--|                     Bug 2733426   Formula/Routing when recipe is given |
--|    SaiKiran		04-MAY-2004	Enhancement #3476560. added        |
--|                  'delayed_lot_entry' to the call to 'check_vr_controls'|
--|                   procedure.                                           |
--|									   |
--|    Saikiran         11-Apr-05      Convergence changes                 |
--|    srakrish 	15-june-06     BUG 5251172: Checking if the        |
--|				       responsibility is available to the  |
--|				       organization			   |
--|                                                                        |
--|    Kishore    -       30-Sep-2008     -       Bug No.7419838    |
--|      Changed the cursor c_orgn_plant, as Spec VR can be created for plant also |
--+========================================================================+
-- End of comments

PROCEDURE check_for_null_and_fks_in_wvr
(
  p_wip_vr        IN  GMD_WIP_SPEC_VRS%ROWTYPE
, p_spec          IN  GMD_SPECIFICATIONS%ROWTYPE
, x_wip_vr        OUT NOCOPY GMD_WIP_SPEC_VRS%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
)
IS

l_wip_vr           GMD_WIP_SPEC_VRS%ROWTYPE;
l_spec             GMD_SPECIFICATIONS%ROWTYPE;

-- bug 4924483   sql id 14687134 MJC take out org_access_view as not used in query
-- bug 5223014 - sql id 17532478 NO change required as added created an index on Organization_Id
-- to stop FTS on gmd_parameters_hdr
CURSOR c_orgn_plant ( p_organization_id IN NUMBER) IS
SELECT 1
FROM
-- org_access_view o,
     mtl_parameters m,
     gmd_parameters_hdr h
WHERE h.organization_id = m.organization_id
  AND m.process_enabled_flag = 'Y'
  AND m.organization_id = p_organization_id;
 -- AND h.lab_ind = 1; /* Commented in Bug No. 7419838 */


-- bug 4924483 sql id 14687160 (shared mem > 1 mill)   use base tables
CURSOR c_batch IS
SELECT gr.recipe_id, gr.recipe_no, gr.recipe_version
, ffm.formula_id, ffm.formula_no, ffm.formula_vers
, rout.routing_id, rout.routing_no, rout.routing_vers
FROM gme_batch_header bh
, gme_material_details md
, gmd_recipes_b gr  -- just need base table here not view
, gmd_recipe_validity_rules rvr
, gmd_status gs
, fm_matl_dtl fmd
, fm_form_mst_b ffm -- just need base table here not view
, gmd_routings_b rout -- just need base table here not view
WHERE rout.routing_id(+) = bh.routing_id
AND rvr.recipe_validity_rule_id = bh.recipe_validity_rule_id
AND rvr.recipe_id = gr.recipe_id
AND ffm.formula_id = bh.formula_id
AND ffm.formula_id = fmd.formula_id
AND fmd.formula_id = bh.formula_id
AND rout.delete_mark = 0
AND gs.delete_mark = 0
AND rvr.delete_mark = 0
AND gr.delete_mark = 0
AND bh.delete_mark = 0
AND ffm.delete_mark = 0
AND fmd.formula_id = gr.formula_id
AND fmd.inventory_item_id = p_spec.inventory_item_id
AND gr.recipe_status = gs.status_code
AND gs.status_code <> '1000'
AND gr.formula_id = bh.formula_id
AND bh.batch_id = md.batch_id
AND bh.batch_type = 0   -- Only BATCH, no FPO
--AND bh.batch_status IN (1, 2)   -- PENDING or WIP BATCH only.
AND ( (  bh.batch_status IN (1,2, 3)     and     ( NVL(fnd_profile.value('GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'N') )
or  ( bh.batch_status IN (1,2, 3,4 )   and  ( NVL(fnd_profile.value('GMD_SAMPLE_CLOSED_BATCHES'),'N') = 'Y') )  )  -- Bug # 4619570
AND md.inventory_item_id = p_spec.inventory_item_id
AND bh.organization_id = l_wip_vr.organization_id
AND bh.batch_id = l_wip_vr.batch_id
AND NVL( l_wip_vr.recipe_id, gr.recipe_id) = gr.recipe_id
AND NVL( l_wip_vr.formula_id, bh.formula_id) = bh.formula_id
AND NVL( l_wip_vr.routing_id, bh.routing_id) = bh.routing_id;

CURSOR c_recipe_id IS
SELECT r.recipe_no, r.recipe_version
, ffm.formula_id, ffm.formula_no, ffm.formula_vers
, rout.routing_id, rout.routing_no, rout.routing_vers
FROM gmd_recipes r
, gmd_status s
, gmd_recipe_validity_rules rvr
, gmd_routings rout
, fm_form_mst ffm
, fm_matl_dtl fmd
WHERE rout.routing_id(+) = r.routing_id
AND ffm.formula_id = r.formula_id
AND rvr.recipe_id = r.recipe_id
AND (NVL( l_wip_vr.organization_id, rvr.organization_id) = rvr.organization_id OR rvr.organization_id IS NULL)
AND r.recipe_status = s.status_code
AND r.formula_id = fmd.formula_id
AND fmd.inventory_item_id = p_spec.inventory_item_id
AND NVL(rout.delete_mark, 0) = 0
AND rout.delete_mark = 0
AND rvr.delete_mark = 0
AND s.delete_mark = 0
AND r.delete_mark = 0
AND ffm.delete_mark = 0
AND s.status_type <> '1000'
AND r.recipe_id = l_wip_vr.recipe_id
AND NVL( l_wip_vr.formula_id, r.formula_id) = r.formula_id
AND NVL( l_wip_vr.routing_id, rout.routing_id) = rout.routing_id;

CURSOR c_recipe_no IS
SELECT r.recipe_id, r.recipe_version
FROM gmd_recipes r
, gmd_status s
, gmd_recipe_validity_rules rvr
, gmd_routings rout
, fm_form_mst ffm
, fm_matl_dtl fmd
WHERE rout.routing_id(+) = r.routing_id
AND ffm.formula_id = r.formula_id
AND rvr.recipe_id = r.recipe_id
AND (NVL( l_wip_vr.organization_id, rvr.organization_id) = rvr.organization_id OR rvr.organization_id IS NULL)
AND r.recipe_status = s.status_code
AND r.formula_id = fmd.formula_id
AND fmd.inventory_item_id = p_spec.inventory_item_id
AND NVL(rout.delete_mark, 0) = 0
AND rout.delete_mark = 0
AND rvr.delete_mark = 0
AND s.delete_mark = 0
AND r.delete_mark = 0
AND ffm.delete_mark = 0
AND s.status_type <> '1000'
AND r.recipe_no = l_wip_vr.recipe_no
AND NVL( l_wip_vr.recipe_version, r.recipe_version) = r.recipe_version
AND NVL( l_wip_vr.formula_id, r.formula_id) = r.formula_id
AND NVL( l_wip_vr.routing_id, rout.routing_id) = rout.routing_id;

CURSOR c_formula_id IS
SELECT ffm.formula_no, ffm.formula_vers
FROM gmd_recipes grec
, fm_form_mst ffm
, fm_matl_dtl fmd
, gem_lookups gl
, gmd_status s
WHERE s.status_code = ffm.formula_status
AND gl.lookup_code = fmd.line_type
AND gl.lookup_type = 'LINE_TYPE'
AND grec.formula_id(+) = ffm.formula_id
AND fmd.formula_id = ffm.formula_id
AND fmd.inventory_item_id = p_spec.inventory_item_id
AND s.delete_mark = 0
AND grec.delete_mark = 0
AND ffm.delete_mark = 0
AND NVL( l_wip_vr.recipe_id, grec.recipe_id) = grec.recipe_id
AND NVL( l_wip_vr.formulaline_id, fmd.formulaline_id) = fmd.formulaline_id
AND ffm.formula_id = l_wip_vr.formula_id;

CURSOR c_formula_no IS
SELECT ffm.formula_id, ffm.formula_vers
FROM gmd_recipes grec
, fm_form_mst ffm
, fm_matl_dtl fmd
, gem_lookups gl
, gmd_status s
WHERE s.status_code = ffm.formula_status
AND gl.lookup_code = fmd.line_type
AND gl.lookup_type = 'LINE_TYPE'
AND grec.formula_id(+) = ffm.formula_id
AND fmd.formula_id = ffm.formula_id
AND fmd.inventory_item_id = p_spec.inventory_item_id
AND s.delete_mark = 0
AND grec.delete_mark = 0
AND ffm.delete_mark = 0
AND NVL( l_wip_vr.recipe_id, grec.recipe_id) = grec.recipe_id
AND NVL( l_wip_vr.formulaline_id, fmd.formulaline_id) = fmd.formulaline_id
AND NVL( l_wip_vr.formula_vers, ffm.formula_vers) = ffm.formula_vers
AND ffm.formula_no = l_wip_vr.formula_no;


CURSOR c_formulaline_id IS
SELECT 1
FROM fm_matl_dtl fmd
WHERE fmd.inventory_item_id = p_spec.inventory_item_id
AND fmd.formula_id = l_wip_vr.formula_id
AND fmd.formulaline_id = l_wip_vr.formulaline_id;


-- Bug 4640143: added this cursor
CURSOR c_material_detail_id IS
SELECT 1
FROM gme_material_details
WHERE inventory_item_id   = p_spec.inventory_item_id
  AND batch_id            = l_wip_vr.batch_id
  AND organization_id     = l_wip_vr.organization_id
  AND material_detail_id  = l_wip_vr.material_detail_id;


CURSOR c_routing_id IS
SELECT r.routing_no, r.routing_vers
FROM gmd_recipes grec
, gmd_status s
, gmd_routings r
WHERE grec.routing_id(+) = r.routing_id
AND s.status_code = r.routing_status
AND NVL( l_wip_vr.recipe_id, grec.recipe_id) = grec.recipe_id
AND NVL( l_wip_vr.formula_id, grec.formula_id) = grec.formula_id
AND s.delete_mark = 0
AND grec.delete_mark = 0
AND r.delete_mark = 0
AND r.routing_id = l_wip_vr.routing_id;

CURSOR c_routing_no IS
SELECT r.routing_id, r.routing_vers
FROM gmd_recipes grec
, gmd_status s
, gmd_routings r
WHERE grec.routing_id(+) = r.routing_id
AND s.status_code = r.routing_status
AND NVL( l_wip_vr.recipe_id, grec.recipe_id) = grec.recipe_id
AND NVL( l_wip_vr.formula_id, grec.formula_id) = grec.formula_id
AND s.delete_mark = 0
AND grec.delete_mark = 0
AND r.delete_mark = 0
AND NVL( l_wip_vr.routing_vers, r.routing_vers) = r.routing_vers
AND r.routing_no = l_wip_vr.routing_no;

CURSOR c_batchstep IS
SELECT bs.batchstep_no
FROM gme_batch_steps bs
, gmd_operations o
WHERE bs.oprn_id = o.oprn_id
AND o.delete_mark = 0
AND bs.delete_mark = 0
AND NVL( l_wip_vr.oprn_id, o.oprn_id) = o.oprn_id
AND NVL( l_wip_vr.oprn_no, o.oprn_no) = o.oprn_no
AND NVL( l_wip_vr.step_no, bs.batchstep_no) = bs.batchstep_no
AND bs.batchstep_id = l_wip_vr.step_id
AND bs.batch_id = l_wip_vr.batch_id;

CURSOR c_routingstep IS
SELECT rd.routingstep_no
FROM fm_rout_dtl rd
, gmd_operations o
WHERE rd.oprn_id = o.oprn_id
AND o.delete_mark = 0
AND NVL( l_wip_vr.oprn_id, o.oprn_id) = o.oprn_id
AND NVL( l_wip_vr.oprn_no, o.oprn_no) = o.oprn_no
AND NVL( l_wip_vr.step_no, rd.routingstep_no) = rd.routingstep_no
AND rd.routingstep_id = l_wip_vr.step_id
AND rd.routing_id = l_wip_vr.routing_id;


CURSOR c_oprn IS
SELECT oprn_no, oprn_vers
FROM gmd_operations o
WHERE o.delete_mark = 0
AND o.oprn_id = l_wip_vr.oprn_id;

-- 8901257 start
CURSOR c_recipe_id_no_route IS
SELECT r.recipe_no, r.recipe_version
, ffm.formula_id, ffm.formula_no, ffm.formula_vers
FROM gmd_recipes r
, gmd_status s
, gmd_recipe_validity_rules rvr
, fm_form_mst ffm
, fm_matl_dtl fmd
WHERE ffm.formula_id = r.formula_id
AND rvr.recipe_id = r.recipe_id
AND (NVL( l_wip_vr.organization_id, rvr.organization_id) = rvr.organization_id OR rvr.organization_id IS NULL)
AND r.recipe_status = s.status_code
AND r.formula_id = fmd.formula_id
AND fmd.inventory_item_id = p_spec.inventory_item_id
AND rvr.delete_mark = 0
AND s.delete_mark = 0
AND r.delete_mark = 0
AND ffm.delete_mark = 0
AND s.status_type <> '1000'
AND r.recipe_id = l_wip_vr.recipe_id
AND NVL( l_wip_vr.formula_id, r.formula_id) = r.formula_id;

CURSOR c_recipe_no_no_route IS
SELECT r.recipe_id, r.recipe_version
FROM gmd_recipes r
, gmd_status s
, gmd_recipe_validity_rules rvr
, fm_form_mst ffm
, fm_matl_dtl fmd
WHERE ffm.formula_id = r.formula_id
AND rvr.recipe_id = r.recipe_id
AND (NVL( l_wip_vr.organization_id, rvr.organization_id) = rvr.organization_id OR rvr.organization_id IS NULL)
AND r.recipe_status = s.status_code
AND r.formula_id = fmd.formula_id
AND fmd.inventory_item_id = p_spec.inventory_item_id
AND rvr.delete_mark = 0
AND s.delete_mark = 0
AND r.delete_mark = 0
AND ffm.delete_mark = 0
AND s.status_type <> '1000'
AND r.recipe_no = l_wip_vr.recipe_no
AND NVL( l_wip_vr.recipe_version, r.recipe_version) = r.recipe_version
AND NVL( l_wip_vr.formula_id, r.formula_id) = r.formula_id;

-- 8901257 end




dummy              PLS_INTEGER;
l_status_ctl       VARCHAR2(1);
l_lot_ctl          NUMBER;

l_recipe_id        GMD_RECIPES.RECIPE_ID%TYPE;
l_recipe_no        GMD_RECIPES.RECIPE_NO%TYPE;
l_recipe_version   GMD_RECIPES.RECIPE_VERSION%TYPE;
l_formula_id       FM_FORM_MST.FORMULA_ID%TYPE;
l_formula_no       FM_FORM_MST.FORMULA_NO%TYPE;
l_formula_vers     FM_FORM_MST.FORMULA_VERS%TYPE;
l_routing_id       GMD_ROUTINGS.ROUTING_ID%TYPE;
l_routing_no       GMD_ROUTINGS.ROUTING_NO%TYPE;
l_routing_vers     GMD_ROUTINGS.ROUTING_VERS%TYPE;
l_step_no          GMD_WIP_SPEC_VRS.STEP_NO%TYPE;
l_oprn_no          GMD_OPERATIONS.OPRN_NO%TYPE;
l_oprn_vers        GMD_OPERATIONS.OPRN_VERS%TYPE;
l_sample_display   GMD_SAMPLES_GRP.sample_display_rec;

BEGIN
  l_wip_vr := p_wip_vr;
  l_spec := p_spec;

  -- At least one parameter is required for the WIP VR.
  IF (l_wip_vr.batch_id IS NULL AND
      l_wip_vr.recipe_id IS NULL AND
      l_wip_vr.recipe_no IS NULL AND
      l_wip_vr.formula_id IS NULL AND
      l_wip_vr.formula_no IS NULL AND
      l_wip_vr.routing_id IS NULL AND
      l_wip_vr.routing_no IS NULL AND
      l_wip_vr.oprn_id IS NULL AND
      l_wip_vr.oprn_no IS NULL) THEN
    GMD_API_PUB.Log_Message('GMD_WIP_VR_ALL_NULL');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- WHO section :
  --=========================================================================
  check_who( p_user_id  => l_wip_vr.created_by);
  check_who( p_user_id  => l_wip_vr.last_updated_by);
  IF (l_wip_vr.creation_date IS NULL
   OR l_wip_vr.last_update_date IS NULL)
  THEN
    GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'the dates must not be NULL');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- Organization : must be a PLANT and belong to the USER
  --=========================================================================
  IF (l_wip_vr.organization_id IS NOT NULL)
  THEN
    -- Check that Owner Organization id exist in ORG_ACCESS_VIEW
    OPEN c_orgn_plant( l_wip_vr.organization_id);
    FETCH c_orgn_plant INTO dummy;
    IF (c_orgn_plant%NOTFOUND)
    THEN
      CLOSE c_orgn_plant;
      GMD_API_PUB.Log_Message('GMD_ORGANIZATION_ID_NOT_FOUND',
                              'ORGN_ID', l_wip_vr.organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn_plant;
  END IF;

  --srakrish BUG 5251172: Checking if the responsibility is available to the organization.
  IF NOT (gmd_api_grp.OrgnAccessible(l_wip_vr.organization_id)) THEN
      	  RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- Get Item Controls
  --=========================================================================

  l_sample_display.organization_id := l_wip_vr.organization_id;
  l_sample_display.inventory_item_id := l_spec.inventory_item_id;
  GMD_SAMPLES_GRP.get_item_values (p_sample_display => l_sample_display);
  l_lot_ctl := l_sample_display.lot_control_code;
  l_status_ctl := l_sample_display.lot_status_enabled;

  --=========================================================================
  -- lot_optional_on_sample :
  -- When this field is NOT NULL, all the following fields must be null :
  -- sample_inv_trans_ind, control_lot_attrib_ind, in_spec_lot_status, out_of_spec_lot_status
  -- and control_batch_step_ind
  --=========================================================================
  --Enhancement #3476560. added 'delayed_lot_entry' to the call to 'check_vr_controls' procedure
  check_VR_Controls( p_VR_type                  => 'WIP'
                   , p_lot_optional_on_sample   => l_wip_vr.lot_optional_on_sample
		   , p_delayed_lot_entry        => l_wip_vr.delayed_lot_entry
                   , p_sample_inv_trans_ind     => l_wip_vr.sample_inv_trans_ind
                   , p_lot_ctl                  => l_lot_ctl
                   , p_status_ctl               => l_status_ctl
                   , p_control_lot_attrib_ind   => l_wip_vr.control_lot_attrib_ind
                   , p_in_spec_lot_status_id       => l_wip_vr.in_spec_lot_status_id
                   , p_out_of_spec_lot_status_id   => l_wip_vr.out_of_spec_lot_status_id
                   , p_control_batch_step_ind   => l_wip_vr.control_batch_step_ind
		   , p_auto_complete_batch_step => l_wip_vr.auto_complete_batch_step   -- Bug# 5440347
		   , p_delayed_lpn_entry        => l_wip_vr.delayed_lpn_entry);    --RLNAGARA LPN ME 7027149

  --RLNAGARA LPN ME 7027149 start  Check for WMS enabled organization.
  IF (l_wip_vr.organization_id IS NOT NULL) THEN
    IF NOT check_wms_enabled(l_wip_vr.organization_id) THEN  -- If the Org is not a wms enabled then delayed_lpn_entry should be NULL
      IF l_wip_vr.delayed_lpn_entry IS NOT NULL THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Delayed_LPN_Entry should be NULL for Non-WMS Enabled Organization.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;
  --RLNAGARA LPN ME 7027149 end

  --=========================================================================
  -- spec_vr_status :
  --=========================================================================
  OPEN c_status(l_wip_vr.spec_vr_status);
  FETCH c_status
   INTO dummy;
  IF (c_status%NOTFOUND)
  THEN
    CLOSE c_status;
    GMD_API_PUB.Log_Message('GMD_SPEC_STATUS_NOT_FOUND',
                            'STATUS', l_wip_vr.spec_vr_status);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_status;

  --=========================================================================
  -- start_date : This field is mandatory
  --=========================================================================
  IF (l_wip_vr.start_date IS NULL)
  THEN
      GMD_API_PUB.Log_Message('GMD_SPEC_VR_START_DATE_REQD');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- COA section :
  --=========================================================================
  check_COA( p_coa_type              => l_wip_vr.coa_type
           , p_coa_at_ship_ind       => l_wip_vr.coa_at_ship_ind
           , p_coa_at_invoice_ind    => l_wip_vr.coa_at_invoice_ind
           , p_coa_req_from_supl_ind => l_wip_vr.coa_req_from_supl_ind);

  --=========================================================================
  -- Batch ID is valid
  -- When batch_id is NOT NULL, then orgn_code must be MOT NULL
  --=========================================================================
  IF (l_wip_vr.batch_id IS NOT NULL)
  THEN
    IF (l_wip_vr.organization_id IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'the organization id must not be NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_batch;
    FETCH c_batch
     INTO l_recipe_id, l_recipe_no, l_recipe_version
        , l_formula_id, l_formula_no, l_formula_vers
        , l_routing_id, l_routing_no, l_routing_vers;
    IF (c_batch%NOTFOUND)
    THEN
      CLOSE c_batch;
      GMD_API_PUB.Log_Message('GMD_BATCH_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_batch;

    --=========================================================================
    -- Check the entered values with the one retrieved by cursor c_batch :
    -- recipe_id, recipe_no, recipe_version
    -- formula_id, formula_no, formula_vers
    -- routing_id, routing_no, routing_vers
    --=========================================================================
    -- 1: recipe_id
    IF ( NVL(l_wip_vr.recipe_id, l_recipe_id) <> l_recipe_id)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed recipe_id doesn''t match the batch''s recipe_id.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- 2: recipe_no
    IF ( NVL(l_wip_vr.recipe_no, l_recipe_no) <> l_recipe_no)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed recipe_no doesn''t match the batch''s recipe_no.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- 3: recipe_version
    IF ( NVL(l_wip_vr.recipe_version, l_recipe_version) <> l_recipe_version)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed recipe_version doesn''t match the batch''s recipe_version.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 4: formula_id
    IF ( NVL(l_wip_vr.formula_id, l_formula_id) <> l_formula_id)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed formula_id doesn''t match the batch''s formula_id.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- 5: formula_no
    IF ( NVL(l_wip_vr.formula_no,  l_formula_no) <> l_formula_no)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed formula_no doesn''t match the batch''s formula_no.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- 6: formula_vers
    IF ( NVL(l_wip_vr.formula_vers, l_formula_vers) <> l_formula_vers)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed formula_vers doesn''t match the batch''s formula_vers.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 7: routing_id
    IF ( NVL(l_wip_vr.routing_id, l_routing_id) <> l_routing_id)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed routing_id doesn''t match the batch''s routing_id.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- 8: routing_no
    IF ( NVL(l_wip_vr.routing_no, l_routing_no) <> l_routing_no)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed routing_no doesn''t match the batch''s routing_no.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- 9: routing_vers
    IF ( NVL(l_wip_vr.routing_vers, l_routing_vers) <> l_routing_vers)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Passed routing_vers doesn''t match the batch''s routing_vers.');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- At this stage, either l_wip_vr.recipe.... are NULL
    --   or they are equal to the local variables. I re-populate the fields (when they are NULL)
    l_wip_vr.recipe_id := l_recipe_id;
    l_wip_vr.recipe_no := l_recipe_no;
    l_wip_vr.recipe_version := l_recipe_version;
    l_wip_vr.formula_id := l_formula_id;
    l_wip_vr.formula_no := l_formula_no;
    l_wip_vr.formula_vers := l_formula_vers;
    l_wip_vr.routing_id := l_routing_id;
    l_wip_vr.routing_no := l_routing_no;
    l_wip_vr.routing_vers := l_routing_vers;
  ELSE
    -- In this part, batch_id is NULL...

    --=========================================================================
    -- Recipe is valid
    -- If recipe_id NOT NULL, then recipe_no AND recipe_version populated
    --                      And formula and routing (bug 2733426)
    -- If recipe_no NOT NULL, and recipe_version NOT NULL, then recipe_id populated
    -- If recipe_no NOT NULL, and recipe_version NULL, then nothing else populated
    --=========================================================================
    IF (l_wip_vr.recipe_id IS NOT NULL)
    THEN

    -- 8901257   allow creation of a wip svr even if no routing info is input by using a dfferent cursor
      IF l_wip_vr.routing_id IS NOT NULL THEN

		      OPEN c_recipe_id;
		      FETCH c_recipe_id
		       INTO l_recipe_no, l_recipe_version
		          , l_formula_id, l_formula_no, l_formula_vers
		          , l_routing_id, l_routing_no, l_routing_vers;
		      IF (c_recipe_id%NOTFOUND)
		      THEN
		        CLOSE c_recipe_id;
		        GMD_API_PUB.Log_Message('GMD_RECIPE_NOT_FOUND');
		        RAISE FND_API.G_EXC_ERROR;
		      END IF;
		      CLOSE c_recipe_id;
      ELSE
          OPEN c_recipe_id_no_route;
		      FETCH c_recipe_id_no_route
		       INTO l_recipe_no, l_recipe_version
		          , l_formula_id, l_formula_no, l_formula_vers;

		      IF (c_recipe_id_no_route%NOTFOUND)
		      THEN
		        CLOSE c_recipe_id_no_route;
		        GMD_API_PUB.Log_Message('GMD_RECIPE_NOT_FOUND');
		        RAISE FND_API.G_EXC_ERROR;
		      END IF;
		      CLOSE c_recipe_id_no_route;
		      l_routing_id := NULL;   -- 8901257
		      l_routing_no := NULL;   -- 8901257
		      l_routing_vers := NULL;   -- 8901257

      END IF;
      -- 4: formula_id
      IF ( NVL(l_wip_vr.formula_id, l_formula_id) <> l_formula_id)
      THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Passed formula_id doesn''t match the batch''s formula_id.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- 5: formula_no
      IF ( NVL(l_wip_vr.formula_no,  l_formula_no) <> l_formula_no)
      THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Passed formula_no doesn''t match the batch''s formula_no.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- 6: formula_vers
      IF ( NVL(l_wip_vr.formula_vers, l_formula_vers) <> l_formula_vers)
      THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Passed formula_vers doesn''t match the batch''s formula_vers.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- 7: routing_id
      IF ( NVL(l_wip_vr.routing_id, l_routing_id) <> l_routing_id)
      THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Passed routing_id doesn''t match the batch''s routing_id.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- 8: routing_no
      IF ( NVL(l_wip_vr.routing_no, l_routing_no) <> l_routing_no)
      THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Passed routing_no doesn''t match the batch''s routing_no.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- 9: routing_vers
      IF ( NVL(l_wip_vr.routing_vers, l_routing_vers) <> l_routing_vers)
      THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Passed routing_vers doesn''t match the batch''s routing_vers.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- At this stage, either l_wip_vr.formula/routing.... are NULL
      --   or they are equal to the local variables.
      -- Populated the defaults, ignoring the passed values :
      l_wip_vr.recipe_no := l_recipe_no;
      l_wip_vr.recipe_version := l_recipe_version;
      l_wip_vr.formula_id := l_formula_id;
      l_wip_vr.formula_no := l_formula_no;
      l_wip_vr.formula_vers := l_formula_vers;
      l_wip_vr.routing_id := l_routing_id;
      l_wip_vr.routing_no := l_routing_no;
      l_wip_vr.routing_vers := l_routing_vers;

    ELSIF (l_wip_vr.recipe_no IS NOT NULL)
    THEN
      -- 8901257  allow creation of a wip svr even if no routing info is input by using a dfferent cursor
      IF l_wip_vr.routing_id IS NOT NULL THEN

			      OPEN c_recipe_no;
			      FETCH c_recipe_no
			       INTO l_recipe_id, l_recipe_version;
			      IF (c_recipe_no%NOTFOUND)
			      THEN
			        CLOSE c_recipe_no;
			        GMD_API_PUB.Log_Message('GMD_RECIPE_NOT_FOUND');
			        RAISE FND_API.G_EXC_ERROR;
			      END IF;
			      CLOSE c_recipe_no;

			ELSE
			    OPEN c_recipe_no_no_route;
		      FETCH c_recipe_no_no_route
		       INTO l_recipe_no, l_recipe_version;

		      IF (c_recipe_no_no_route%NOTFOUND)
		      THEN
		        CLOSE c_recipe_no_no_route;
		        GMD_API_PUB.Log_Message('GMD_RECIPE_NOT_FOUND');
		        RAISE FND_API.G_EXC_ERROR;
		      END IF;
		      CLOSE c_recipe_no_no_route;

			END IF; --  IF l_wip_vr.routing_id IS NOT NULL THEN

      -- Populated the defaults :
      IF (l_wip_vr.recipe_version IS NOT NULL)
      THEN
          -- In that case : recipe_no, and recipe_version were given,
          -- So, I populate recipe_id
          l_wip_vr.recipe_id := l_recipe_id;
      END IF;
    END IF;

    --=========================================================================
    -- Formula is valid
    -- If formula_id NOT NULL, then formula_no AND formula_vers populated
    -- If formula_no NOT NULL, and formula_vers NOT NULL, then formula_id populated
    -- If formula_no NOT NULL, and formula_vers NULL, then nothing else populated
    --=========================================================================
    IF (l_wip_vr.formula_id IS NOT NULL)
    THEN
      OPEN c_formula_id;
      FETCH c_formula_id
       INTO l_formula_no, l_formula_vers;

      IF (c_formula_id%NOTFOUND)
      THEN
        CLOSE c_formula_id;
        GMD_API_PUB.Log_Message('GMD_FORMULA_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_formula_id;

      -- Populated the defaults, ignoring the passed values :
      l_wip_vr.formula_no := l_formula_no;
      l_wip_vr.formula_vers := l_formula_vers;

    ELSIF (l_wip_vr.formula_no IS NOT NULL)
    THEN

      OPEN c_formula_no;
      FETCH c_formula_no
       INTO l_formula_id, l_formula_vers;

      IF (c_formula_no%NOTFOUND)
      THEN
        CLOSE c_formula_no;
        GMD_API_PUB.Log_Message('GMD_FORMULA_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_formula_no;

      -- Populated the defaults :
      IF (l_wip_vr.formula_vers IS NOT NULL)
      THEN
          -- In that case : formula_no, and formula_vers were given,
          -- So, I populate formula_id
          l_wip_vr.formula_id := l_formula_id;
      END IF;
    END IF;

    --=========================================================================
    -- Routing is valid
    -- If routing_id NOT NULL, then routing_no AND routing_version populated
    -- If routing_no NOT NULL, and routing_vers NOT NULL, then routing_id populated
    -- If routing_no NOT NULL, and routing_vers NULL, then nothing else populated
    --=========================================================================
    IF (l_wip_vr.routing_id IS NOT NULL)
    THEN
      OPEN c_routing_id;
      FETCH c_routing_id
       INTO l_routing_no, l_routing_vers;

      IF (c_routing_id%NOTFOUND)
      THEN
        CLOSE c_routing_id;
        GMD_API_PUB.Log_Message('GMD_ROUTING_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_routing_id;

      -- Populated the defaults, ignoring the passed values :
      l_wip_vr.routing_no := l_routing_no;
      l_wip_vr.routing_vers := l_routing_vers;

    ELSIF (l_wip_vr.routing_no IS NOT NULL)
    THEN

      OPEN c_routing_no;
      FETCH c_routing_no
       INTO l_routing_id, l_routing_vers;
      IF (c_routing_no%NOTFOUND)
      THEN
        CLOSE c_routing_no;
        GMD_API_PUB.Log_Message('GMD_ROUTING_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_routing_no;

      -- Populated the defaults :
      IF (l_wip_vr.routing_vers IS NOT NULL)
      THEN
          -- In that case : routing_no, and routing_vers were given,
          -- So, I populate routing_id
          l_wip_vr.routing_id := l_routing_id;
      END IF;
    END IF;
  END IF;     -- batch_id NULL

  --=========================================================================
  -- Formula Line is valid
  -- If formulaline_id is NOT NULL, then formula_id must be NOT NULL
  --=========================================================================
  IF (l_wip_vr.formulaline_id IS NOT NULL)
   AND (l_wip_vr.material_detail_id IS NULL)
  THEN
    IF (l_wip_vr.formula_id IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Formula id must be NOT NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_formulaline_id;
    FETCH c_formulaline_id
     INTO dummy;
    IF (c_formulaline_id%NOTFOUND)
    THEN
      CLOSE c_formulaline_id;
      GMD_API_PUB.Log_Message('GMD_FORMULA_LINE_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_formulaline_id;
  END IF;


  --=========================================================================
  -- Batch Line (material detail id) is valid
  -- If material_detail_id is NOT NULL, then batch_id must be NOT NULL
  --=========================================================================
  IF (l_wip_vr.material_detail_id IS NOT NULL)
  THEN
    IF (l_wip_vr.batch_id IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Batch id must be NOT NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_material_detail_id;
    FETCH c_material_detail_id
     INTO dummy;
    IF (c_material_detail_id%NOTFOUND)
    THEN
      CLOSE c_material_detail_id;
      GMD_API_PUB.Log_Message('GMD_MATERIAL_DTL_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_material_detail_id;
  END IF;


  --=========================================================================
  -- Step is valid
  -- A step can be either a batch step or a routing step
  -- If step_no NULL and step_id NOT NULL, then populate step_no
  -- If step_no NOT NULL and step_id NULL, then error.
  --=========================================================================
  IF (l_wip_vr.step_id IS NULL AND l_wip_vr.step_no IS NOT NULL)
  THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'Step id must be populated');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_wip_vr.batch_id IS NOT NULL AND l_wip_vr.step_id IS NOT NULL)
  THEN
    -- Step No is from Batch
    OPEN c_batchstep;
    FETCH c_batchstep
     INTO l_step_no;
    IF (c_batchstep%NOTFOUND)
    THEN
      CLOSE c_batchstep;
      GMD_API_PUB.Log_Message('GMD_BATCH_STEP_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_batchstep;

    -- Populated the defaults, ignoring the passed values :
    l_wip_vr.step_no := l_step_no;

  ELSIF (l_wip_vr.routing_id IS NOT NULL AND l_wip_vr.step_id IS NOT NULL)
  THEN
    -- Step No is from Routing
    OPEN c_routingstep;
    FETCH c_routingstep
     INTO l_step_no;
    IF (c_routingstep%NOTFOUND)
    THEN
      CLOSE c_routingstep;
      GMD_API_PUB.Log_Message('GMD_ROUTING_STEP_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_routingstep;

    -- Populated the defaults, ignoring the passed values :
    l_wip_vr.step_no := l_step_no;

  END IF;

  -- Operation is valid (check only if step is not specified, because
  --                     otherwise it will default from the step chosen.)
  IF (l_wip_vr.step_id IS NULL AND l_wip_vr.oprn_id IS NOT NULL)
  THEN
    OPEN c_oprn;
    FETCH c_oprn
     INTO l_oprn_no, l_oprn_vers;
    IF (c_oprn%NOTFOUND)
    THEN
      CLOSE c_oprn;
      GMD_API_PUB.Log_Message('GMD_BATCH_STEP_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_oprn;

    -- Populated the defaults, ignoring the passed values :
    l_wip_vr.oprn_no   := l_oprn_no;
    l_wip_vr.oprn_vers := l_oprn_vers;

  END IF;


  -- All Systems Go...
  x_wip_vr := l_wip_vr;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END check_for_null_and_fks_in_wvr;




--Start of comments
--+========================================================================+
--| API Name    : wip_vr_exist                                             |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the WIP VR already         |
--|               exists for the spcified parameter in the database, FALSE |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Olivier Daboval  17-OCT-2002     bug 2630007, added spec_name in    |
--|                                     the VR_EXIST message               |
--|    Olivier Daboval  14-NOV-2002     Added NVL(spec_vr_id, -1) because  |
--|                                     the API passes a NULL spec_vr_id   |
--|                                     in insert mode.                    |
--|    Brenda Stone     20-NOV-2003     Bug 3090290; allow duplicate spec vr
--|                                     with "OBSOLUTE" status             |
--|                                     Bug 2984784; add Version to msg for|
--|                                     existing spec vr.                  |
--|                                                                        |
--|  Saikiran          12-Apr-2005      Convergence Changes                |
--|  Feinstein         18-Oct-2005      Added material detail id to samples|
--|  Plowe						 04-Apr-2006      Bug 5117733 - added item revision to match
--+========================================================================+
-- End of comments

FUNCTION wip_vr_exist(p_wip_vr GMD_WIP_SPEC_VRS%ROWTYPE,
                      p_spec   GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN IS

    -- added material detail to cursor
  CURSOR c_wip_vr IS
  SELECT vr.spec_vr_id, s.spec_name, s.spec_vers
  FROM   gmd_specifications_b s,
         gmd_wip_spec_vrs vr
  WHERE  s.spec_id = vr.spec_id
  AND    s.owner_organization_id = p_spec.owner_organization_id
  AND    s.inventory_item_id = p_spec.inventory_item_id
  AND   ( (s.revision is null and p_spec.revision is NULL ) OR -- handle item revision 5117733
          (s.revision  = p_spec.revision )
  			 )
  AND    ((s.grade_code is NULL AND p_spec.grade_code is NULL) OR
          (s.grade_code = p_spec.grade_code)
         )
  AND    ((vr.organization_id is NULL AND p_wip_vr.organization_id is NULL) OR
          (vr.organization_id = p_wip_vr.organization_id)
         )
  AND    ((vr.batch_id is NULL AND p_wip_vr.batch_id is NULL) OR
          (vr.batch_id = p_wip_vr.batch_id)
         )
  AND    ((vr.recipe_id is NULL AND p_wip_vr.recipe_id is NULL) OR
          (vr.recipe_id = p_wip_vr.recipe_id)
         )
  AND    ((vr.recipe_no is NULL AND p_wip_vr.recipe_no is NULL) OR
          (vr.recipe_no = p_wip_vr.recipe_no)
         )
  AND    ((vr.formula_id is NULL AND p_wip_vr.formula_id is NULL) OR
          (vr.formula_id = p_wip_vr.formula_id)
         )
  AND    ((vr.formula_no is NULL AND p_wip_vr.formula_no is NULL) OR
          (vr.formula_no = p_wip_vr.formula_no)
         )
  AND    ((vr.formulaline_id is NULL AND p_wip_vr.formulaline_id is NULL) OR
          (vr.formulaline_id = p_wip_vr.formulaline_id) OR
          (vr.batch_id IS NOT NULL)                          -- added for new Material detail field
         )
  AND    ((vr.material_detail_id is NULL AND p_wip_vr.material_detail_id is NULL) OR
          (vr.material_detail_id = p_wip_vr.material_detail_id)
         )
  AND    ((vr.routing_id is NULL AND p_wip_vr.routing_id is NULL) OR
          (vr.routing_id = p_wip_vr.routing_id)
         )
  AND    ((vr.routing_no is NULL AND p_wip_vr.routing_no is NULL) OR
          (vr.routing_no = p_wip_vr.routing_no)
         )
  AND    ((vr.step_id is NULL AND p_wip_vr.step_id is NULL) OR
          (vr.step_id = p_wip_vr.step_id)
         )
  AND    ((vr.oprn_id is NULL AND p_wip_vr.oprn_id is NULL) OR
          (vr.oprn_id = p_wip_vr.oprn_id)
         )
  AND    ((vr.oprn_no is NULL AND p_wip_vr.oprn_no is NULL) OR
          (vr.oprn_no = p_wip_vr.oprn_no)
         )
  AND    ((vr.charge is NULL AND p_wip_vr.charge is NULL) OR
          (vr.charge = p_wip_vr.charge)
         )
  AND    ((vr.end_date is NULL AND (p_wip_vr.end_date IS NULL OR
                                    p_wip_vr.end_date >= vr.start_date)) OR
	  (p_wip_vr.end_date IS NULL AND
	     p_wip_vr.start_date <= nvl(vr.end_date, p_wip_vr.start_date)) OR
          (p_wip_vr.start_date <= vr.end_date AND p_wip_vr.end_date >= vr.start_date)
         )
  AND  (floor(vr.spec_vr_status/100) = floor(p_wip_vr.spec_vr_status/100)  AND
/*      Bug 3090290; allow duplicate spec vr with "OBSOLUTE" status   */
        p_wip_vr.spec_vr_status <> 1000 )

/* Bug 3090290 - Here's the problem - Both spec vr's have the same status 1000  */
/* obsolete                                                                     */
  AND    vr.spec_vr_status NOT IN (SELECT status_code FROM gmd_qc_status
                                   WHERE status_type = 800)
  AND    vr.delete_mark = 0
  AND    s.delete_mark = 0
  AND    vr.spec_vr_id <> NVL(p_wip_vr.spec_vr_id, -1)
  ;

  dummy    PLS_INTEGER;
  specname VARCHAR2(80);
  specvers NUMBER;

BEGIN

  OPEN c_wip_vr;
  FETCH c_wip_vr INTO dummy, specname, specvers;
  IF c_wip_vr%FOUND THEN
    CLOSE c_wip_vr;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_WIP_VR_EXIST');
    FND_MESSAGE.SET_TOKEN('spec', specname);
    FND_MESSAGE.SET_TOKEN('vers', specvers);
    FND_MSG_PUB.ADD;
    RETURN TRUE;
  ELSE
    CLOSE c_wip_vr;
    RETURN FALSE;
  END IF;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PACKAGE', 'GMD_SPEC_VRS_GRP.WIP_VR_EXIST' );
    FND_MESSAGE.SET_TOKEN('ERROR', SUBSTR(SQLERRM,1,200));
    RETURN TRUE;

END wip_vr_exist;



--Start of comments
--+========================================================================+
--| API Name    : validate_cust_vr                                         |
--| TYPE        : Group                                                    |
--| Notes       : This procedure validates all the fields of               |
--|               Customer  validity rule record. This procedure can be    |
--|               called from FORM or API and the caller need              |
--|               to specify this in p_called_from parameter               |
--|               while calling this procedure. Based on where             |
--|               it is called from certain validations will               |
--|               either be performed or skipped.                          |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE validate_cust_vr
(
  p_cust_vr       IN  GMD_CUSTOMER_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2
, p_operation     IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Local Variables
  dummy                          NUMBER;
  l_return_status                VARCHAR2(1);

  l_spec                         GMD_SPECIFICATIONS%ROWTYPE;
  l_spec_out                     GMD_SPECIFICATIONS%ROWTYPE;
  l_item_mst                     MTL_SYSTEM_ITEMS_B%ROWTYPE;
  l_sampling_plan                GMD_SAMPLING_PLANS%ROWTYPE;
  l_sampling_plan_out            GMD_SAMPLING_PLANS%ROWTYPE;
  l_inventory_item_id            NUMBER;
  l_organization_id              NUMBER;
  l_uom_rate                     NUMBER;

  -- Exceptions
  e_spec_fetch_error             EXCEPTION;
  e_smpl_plan_fetch_error        EXCEPTION;
  e_error_fetch_item             EXCEPTION;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT (p_operation in ('INSERT', 'UPDATE', 'DELETE')) THEN
    -- Invalid Operation
    GMD_API_PUB.Log_Message('GMD_INVALID_OPERATION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Verify that the specification exists.
  l_spec.spec_id := p_cust_vr.spec_id;
  IF NOT (GMD_Specifications_PVT.Fetch_Row(
                           p_specifications => l_spec,
                           x_specifications => l_spec_out)
          ) THEN
    -- Fetch Error
    GMD_API_PUB.Log_Message('GMD_SPEC_FETCH_ERROR');
    RAISE e_spec_fetch_error;
  END IF;

  l_spec := l_spec_out ;

  -- Verify that the Sampling Plan exists.
  --odab added this test.
  IF (p_cust_vr.sampling_plan_id IS NOT NULL)
  THEN
    l_sampling_plan.sampling_plan_id := p_cust_vr.sampling_plan_id;
    IF NOT (GMD_Sampling_Plans_PVT.Fetch_Row(
                           p_sampling_plan => l_sampling_plan,
                           x_sampling_plan => l_sampling_plan_out)
          ) THEN
      -- Fetch Error
      GMD_API_PUB.Log_Message('GMD_SAMPLING_PLAN_FETCH_ERROR');
      RAISE e_smpl_plan_fetch_error;
    END IF;
    l_sampling_plan := l_sampling_plan_out;
  END IF;

  IF (p_called_from = 'API') THEN
    -- Check for NULLs and Valid Foreign Keys in the input parameter
    GMD_SPEC_VRS_GRP.check_for_null_and_fks_in_cvr
      (
        p_cust_vr       => p_cust_vr
      , p_spec          => l_spec
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

  -- First Verify that the SAME VR does not exists
  IF (p_operation IN ('INSERT', 'UPDATE')
    AND cust_vr_exist(p_cust_vr, l_spec))
  THEN
    -- Disaster, Trying to insert duplicate
    -- bug 2630007, odaboval put the message in function cust_vr_exist.
    -- GMD_API_PUB.Log_Message('GMD_CUST_VR_EXIST');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Sample Quantity UOM must be convertible to Item's UOM
  BEGIN
    SELECT inventory_item_id INTO l_inventory_item_id FROM
    gmd_specifications WHERE spec_id = p_cust_vr.spec_id;
    SELECT owner_organization_id INTO l_organization_id FROM
    gmd_specifications WHERE spec_id = p_cust_vr.spec_id;
    SELECT * INTO l_item_mst
    FROM mtl_system_items_b
    WHERE inventory_item_id = l_inventory_item_id
    AND organization_id = l_organization_id;
  EXCEPTION
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_ITEM_FETCH_ERROR');
    RAISE e_error_fetch_item;
  END;

  --odab added this test.
  IF (p_cust_vr.sampling_plan_id IS NOT NULL)
  THEN
    inv_convert.inv_um_conversion (
      from_unit  => l_sampling_plan.sample_qty_uom,
      to_unit    =>  l_item_mst.primary_uom_code,
      item_id    =>  l_inventory_item_id,
      lot_number => NULL,
      organization_id => l_organization_id  ,
      uom_rate   => l_uom_rate );

    IF l_uom_rate = -99999 THEN
      GMD_API_PUB.Log_Message('GMD_UOM_CONVERSION_ERROR');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- No need to check the return status because above procedure
  -- logs appropriate message on the stack and raises an exception.

  -- The Start Date must be less than the End Date
  If ( p_cust_vr.end_date IS NOT NULL AND
       p_cust_vr.start_date > p_cust_vr.end_date) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_EFF_DATE_ERROR');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Spec VR Status Must be less than Spec Status upto Appoved Stages
  IF (floor(l_spec.spec_status/100) <= 7 AND
      floor(p_cust_vr.spec_vr_status/100) <= 7 AND
      p_cust_vr.spec_vr_status > l_spec.spec_status) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_STATUS_HIGHER');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- All systems GO...

EXCEPTION
  WHEN FND_API.G_EXC_ERROR     OR
       e_spec_fetch_error      OR
       e_smpl_plan_fetch_error OR
       e_error_fetch_item
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END validate_cust_vr;




--Start of comments
--+========================================================================+
--| API Name    : check_for_null_and_fks_in_cvr                            |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Spec           |
--|               Customer  VR record.                                     |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--|    SaiKiran		04-MAY-2004	Enhancement #3476560. added        |
--|                  'delayed_lot_entry' to the call to 'check_vr_controls'|
--|                   procedure.                                           |
--|                                                                        |
--|    Saikiran        11-Apr-2005      Convergence Changes                |
--|  PLOWE             07-JUN-2006    -- bug 5223014 rework                |
--|  replace cursor with function  as check was not working as designed    |
--|  bug 5223014 rework in proc check_for_null_and_fks_in_cvr              |
--|========================================================================+
-- End of comments

PROCEDURE check_for_null_and_fks_in_cvr
(
  p_cust_vr       IN  gmd_customer_spec_vrs%ROWTYPE
, p_spec          IN  gmd_specifications%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
)
IS

CURSOR c_cust IS
SELECT 1
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
  AND NVL( p_cust_vr.org_id, csua.org_id) = csua.org_id
  AND hzca.cust_account_id = p_cust_vr.cust_id;

-- bug 4924483 sql id 14687576 (MJC)  don't use view
CURSOR c_org IS
/*SELECT 1
FROM hr_operating_units
WHERE organization_id = p_cust_vr.org_id; */
-- bug 5223014 sql id 17532992 (MJC)  don't need 2nd HR_ORGANIZATION_INFORMATION O3 for identification
-- (takes out MJC)
SELECT 1
FROM HR_ALL_ORGANIZATION_UNITS O,
HR_ORGANIZATION_INFORMATION O2
--HR_ORGANIZATION_INFORMATION O3
WHERE o.organization_id = p_cust_vr.org_id
and O2.ORGANIZATION_ID = o.organization_id
AND O2.ORG_INFORMATION_CONTEXT||'' = 'CLASS'
AND O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
AND O2.ORG_INFORMATION2 = 'Y';
--and O3.ORGANIZATION_ID = O2.ORGANIZATION_ID
--AND O3.ORG_INFORMATION_CONTEXT = 'Operating Unit Information';


CURSOR c_orgn_check ( p_organization_id NUMBER) IS
  SELECT 1
  FROM GMD_ORG_ACCESS_VW;

CURSOR c_ship_to IS
SELECT 1
FROM hz_cust_acct_sites_all casa
   , hz_cust_site_uses_all csua
   , hz_cust_accounts_all caa
WHERE casa.cust_acct_site_id = csua.cust_acct_site_id
  AND casa.org_id = csua.org_id
  AND casa.cust_account_id = caa.cust_account_id
  AND csua.site_use_code = 'SHIP_TO'
  AND NVL( p_cust_vr.org_id, csua.org_id) = csua.org_id
  AND caa.cust_account_id = p_cust_vr.cust_id
  AND csua.site_use_id = p_cust_vr.ship_to_site_id;

CURSOR c_order IS
SELECT 1
FROM oe_order_headers_all oha
   , oe_order_lines_all oola
   , oe_transaction_types_tl ttt
WHERE oola.header_id = oha.header_id
  AND oola.inventory_item_id = p_spec.inventory_item_id
  AND oha.order_type_id = ttt.transaction_type_id
  AND NVL( p_cust_vr.ship_to_site_id, oola.ship_to_org_id) = oola.ship_to_org_id
  AND NVL( p_cust_vr.org_id, oha.org_id) = oha.org_id
  AND NVL( p_cust_vr.cust_id, oha.sold_to_org_id) = oha.sold_to_org_id
  AND oha.header_id = p_cust_vr.order_id
  AND oha.cancelled_flag <> 'Y'
  AND ttt.language = USERENV('LANG');


CURSOR c_order_line IS
SELECT 1
FROM oe_order_lines_all oola
WHERE oola.header_id = p_cust_vr.order_id
  AND NVL( p_cust_vr.ship_to_site_id, oola.ship_to_org_id) = oola.ship_to_org_id
  AND oola.inventory_item_id = p_spec.inventory_item_id
  AND oola.header_id = p_cust_vr.order_id
  AND (oola.line_number + (oola.shipment_number / 10)) = p_cust_vr.order_line
  AND oola.line_id = p_cust_vr.order_line_id;

  -- Local Variables
dummy              PLS_INTEGER;
l_lot_ctl          NUMBER;
l_sample_display   GMD_SAMPLES_GRP.sample_display_rec;

BEGIN

  --=========================================================================
  -- WHO section :
  --=========================================================================
  check_who( p_user_id  => p_cust_vr.created_by);
  check_who( p_user_id  => p_cust_vr.last_updated_by);
  IF (p_cust_vr.creation_date IS NULL
   OR p_cust_vr.last_update_date IS NULL)
  THEN
    GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'the dates must not be NULL');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- Organization : must belong to the USER
  --=========================================================================


  IF (p_cust_vr.organization_id IS NOT NULL)
   -- Check that Organization is a valid one
  THEN
       /*
    OPEN c_orgn( p_cust_vr.organization_id);
    FETCH c_orgn INTO dummy;
    IF (c_orgn%NOTFOUND)
    THEN
      CLOSE c_orgn;
      GMD_API_PUB.Log_Message('GMD_ORGANIZATION_ID_NOT_FOUND',
                              'ORGN_ID', p_cust_vr.organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn;*/

  --  replace above with function  as above check was not working as designed  - bug 5223014 rework

    IF NOT (gmd_api_grp.OrgnAccessible(p_cust_vr.organization_id)) THEN
    	  RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  --=========================================================================
  -- Get Item Controls
  --=========================================================================
  l_sample_display.organization_id := p_cust_vr.organization_id;
  l_sample_display.inventory_item_id := p_spec.inventory_item_id;
  GMD_SAMPLES_GRP.get_item_values (p_sample_display => l_sample_display);
  l_lot_ctl := l_sample_display.lot_control_code;


  --=========================================================================
  -- lot_optional_on_sample :
  -- When this field is NOT NULL, all the following fields must be null :
  -- sample_inv_trans_ind
  --=========================================================================
  --Enhancement #3476560. added 'delayed_lot_entry' to the call to 'check_vr_controls' procedure
  check_VR_Controls( p_VR_type                  => 'CUSTOMER'
                   , p_lot_optional_on_sample   => p_cust_vr.lot_optional_on_sample
		   , p_delayed_lot_entry        => NULL
                   , p_sample_inv_trans_ind     => p_cust_vr.sample_inv_trans_ind
                   , p_lot_ctl                  => l_lot_ctl
                   , p_status_ctl               => NULL
                   , p_control_lot_attrib_ind   => NULL
                   , p_in_spec_lot_status_id    => NULL
                   , p_out_of_spec_lot_status_id=> NULL
                   , p_control_batch_step_ind   => NULL
		   , p_delayed_lpn_entry        => NULL);    --RLNAGARA LPN ME 7027149

  --=========================================================================
  -- spec_vr_status :
  --=========================================================================
  OPEN c_status(p_cust_vr.spec_vr_status);
  FETCH c_status
   INTO dummy;
  IF (c_status%NOTFOUND)
  THEN
    CLOSE c_status;
    GMD_API_PUB.Log_Message('GMD_SPEC_STATUS_NOT_FOUND',
                            'STATUS', p_cust_vr.spec_vr_status);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_status;


  --=========================================================================
  -- start_date : This field is mandatory
  --=========================================================================
  IF (p_cust_vr.start_date IS NULL)
  THEN
      GMD_API_PUB.Log_Message('GMD_SPEC_VR_START_DATE_REQD');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- COA section :
  --=========================================================================
  check_COA( p_coa_type              => p_cust_vr.coa_type
           , p_coa_at_ship_ind       => p_cust_vr.coa_at_ship_ind
           , p_coa_at_invoice_ind    => p_cust_vr.coa_at_invoice_ind
           , p_coa_req_from_supl_ind => p_cust_vr.coa_req_from_supl_ind);

  --=========================================================================
  -- cust_id : This field is mandatory
  --=========================================================================
  IF (p_cust_vr.cust_id IS NULL)
  THEN
    GMD_API_PUB.Log_Message('GMD_CUSTOMER_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    OPEN c_cust;
    FETCH c_cust
     INTO dummy;
    IF (c_cust%NOTFOUND)
    THEN
      CLOSE c_cust;
      GMD_API_PUB.Log_Message('GMD_CUSTOMER_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_cust;
  END IF;

  --=========================================================================
  -- Org ID
  --=========================================================================
  IF (p_cust_vr.org_id IS NOT NULL)
  THEN
    OPEN c_org;
    FETCH c_org
     INTO dummy;
    IF (c_org%NOTFOUND)
    THEN
      CLOSE c_org;
      GMD_API_PUB.Log_Message('GMD_ORG_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_org;
  END IF;

  --=========================================================================
  -- Ship To
  --=========================================================================
  IF (p_cust_vr.ship_to_site_id IS NOT NULL)
  THEN
    IF (p_cust_vr.cust_id IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'the customer number must not be NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_ship_to;
    FETCH c_ship_to
     INTO dummy;
    IF (c_ship_to%NOTFOUND)
    THEN
      CLOSE c_ship_to;
      GMD_API_PUB.Log_Message('GMD_SHIP_TO_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_ship_to;
  END IF;

  --=========================================================================
  -- Order ID
  --=========================================================================
  IF (p_cust_vr.order_id IS NOT NULL)
  THEN
    OPEN c_order;
    FETCH c_order
     INTO dummy;
    IF (c_order%NOTFOUND)
    THEN
      CLOSE c_order;
      GMD_API_PUB.Log_Message('GMD_ORDER_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_order;
  END IF;

  --=========================================================================
  -- Order Line ID
  -- Both order_line AND order_line_id are mandatory
  -- Also order_id must be NOT NULL
  --=========================================================================
  IF (p_cust_vr.order_line_id IS NOT NULL
     OR p_cust_vr.order_line IS NOT NULL)
  THEN
    IF (p_cust_vr.order_id IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'the order number must not be NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_cust_vr.order_line_id IS NULL
      OR p_cust_vr.order_line IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'the order line AND id must not be NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_order_line;
    FETCH c_order_line
     INTO dummy;
    IF (c_order_line%NOTFOUND)
    THEN
      CLOSE c_order_line;
      GMD_API_PUB.Log_Message('GMD_ORDER_LINE_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_order_line;
  END IF;

  -- All Systems Go...

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END check_for_null_and_fks_in_cvr;




--Start of comments
--+========================================================================+
--| API Name    : cust_vr_exist                                            |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the customer VR already    |
--|               exists for the spcified parameter in the database, FALSE |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|    Olivier Daboval  17-OCT-2002     bug 2630007, added spec_name in    |
--|                                     the VR_EXIST message               |
--|    Olivier Daboval  14-NOV-2002     Added NVL(spec_vr_id, -1) because  |
--|                                     the API passes a NULL spec_vr_id   |
--|                                     in insert mode.                    |
--|    Brenda Stone     20-NOV-2003     Bug 3090290; allow duplicate spec vr |
--|                                     with "OBSOLUTE" status               |
--|                                     Bug 2984784; add Version to msg for  |
--|                                     existing spec vr.                    |
--|                                                                        |
--|  Saikiran          12-Apr-2005      Convergence Changes                |
--|  Plowe						 04-Apr-2006      Bug 5117733 - added item revision to match
--+========================================================================+
-- End of comments

FUNCTION cust_vr_exist(p_cust_vr GMD_CUSTOMER_SPEC_VRS%ROWTYPE,
                       p_spec    GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN IS

  CURSOR c_cust_vr IS
  SELECT vr.spec_vr_id, s.spec_name, s.spec_vers
  FROM   gmd_specifications_b s, gmd_customer_spec_vrs vr
  WHERE  s.spec_id = vr.spec_id
  AND    s.owner_organization_id = p_spec.owner_organization_id
  AND    s.inventory_item_id = p_spec.inventory_item_id
  AND   ( (s.revision is null and p_spec.revision is NULL ) OR -- handle item revision 5117733
          (s.revision  = p_spec.revision )
  			 )
  AND    ((s.grade_code is NULL AND p_spec.grade_code is NULL) OR
          (s.grade_code = p_spec.grade_code)
         )
  AND    ((vr.organization_id is NULL AND p_cust_vr.organization_id is NULL) OR
          (vr.organization_id = p_cust_vr.organization_id)
         )
  AND    ((vr.cust_id is NULL AND p_cust_vr.cust_id is NULL) OR
          (vr.cust_id = p_cust_vr.cust_id)
         )
  AND    ((vr.org_id is NULL AND p_cust_vr.org_id is NULL) OR
          (vr.org_id = p_cust_vr.org_id)
         )
  AND    ((vr.order_id is NULL AND p_cust_vr.order_id is NULL) OR
          (vr.order_id = p_cust_vr.order_id)
         )
  AND    ((vr.order_line is NULL AND p_cust_vr.order_line is NULL) OR
          (vr.order_line = p_cust_vr.order_line)
         )
  AND    ((vr.order_line_id is NULL AND p_cust_vr.order_line_id is NULL) OR
          (vr.order_line_id = p_cust_vr.order_line_id)
         )
  AND    ((vr.ship_to_site_id is NULL AND p_cust_vr.ship_to_site_id is NULL) OR
          (vr.ship_to_site_id = p_cust_vr.ship_to_site_id)
         )
  AND    ((vr.end_date is NULL AND (p_cust_vr.end_date IS NULL OR
                                    p_cust_vr.end_date >= vr.start_date)) OR
	  (p_cust_vr.end_date IS NULL AND
	     p_cust_vr.start_date <= nvl(vr.end_date, p_cust_vr.start_date)) OR
          (p_cust_vr.start_date <= vr.end_date AND p_cust_vr.end_date >= vr.start_date)
         )
  AND   ( floor(vr.spec_vr_status/100) = floor(p_cust_vr.spec_vr_status/100) AND
/*      Bug 3090290; allow duplicate spec vr with "OBSOLUTE" status   */
         p_cust_vr.spec_vr_status <> 1000 )
  AND    vr.spec_vr_status NOT IN (SELECT status_code FROM gmd_qc_status
                                   WHERE status_type = 800)
  AND    vr.delete_mark = 0
  AND    s.delete_mark = 0
  AND    vr.spec_vr_id <> NVL(p_cust_vr.spec_vr_id, -1)
  ;

  dummy    PLS_INTEGER;
  specname VARCHAR2(80);
  specvers NUMBER;

BEGIN

  OPEN c_cust_vr;
  FETCH c_cust_vr INTO dummy, specname, specvers;
  IF c_cust_vr%FOUND THEN
    CLOSE c_cust_vr;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_CUST_VR_EXIST');
    FND_MESSAGE.SET_TOKEN('spec', specname);
    FND_MESSAGE.SET_TOKEN('vers', specvers);
    FND_MSG_PUB.ADD;
    RETURN TRUE;
  ELSE
    CLOSE c_cust_vr;
    RETURN FALSE;
  END IF;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PACKAGE', 'GMD_SPEC_VRS_GRP.CUST_VR_EXIST' );
    FND_MESSAGE.SET_TOKEN('ERROR', SUBSTR(SQLERRM,1,200));
    RETURN TRUE;

END cust_vr_exist;






--Start of comments
--+========================================================================+
--| API Name    : validate_supp_vr                                         |
--| TYPE        : Group                                                    |
--| Notes       : This procedure validates all the fields of               |
--|               Supplier  validity rule record. This procedure can be    |
--|               called from FORM or API and the caller need              |
--|               to specify this in p_called_from parameter               |
--|               while calling this procedure. Based on where             |
--|               it is called from certain validations will               |
--|               either be performed or skipped.                          |
--|                                                                        |
--|               If everything is fine then OUT parameter                 |
--|               x_return_status is set to 'S' else appropriate           |
--|               error message is put on the stack and error              |
--|               is returned.                                             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar	26-Jul-2002	Created.                           |
--|                                                                        |
--+========================================================================+
-- End of comments

PROCEDURE validate_supp_vr
(
  p_supp_vr       IN  GMD_SUPPLIER_SPEC_VRS%ROWTYPE
, p_called_from   IN  VARCHAR2
, p_operation     IN  VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
) IS

  -- Local Variables
  dummy                          NUMBER;
  l_return_status                VARCHAR2(1);

  l_spec                         GMD_SPECIFICATIONS%ROWTYPE;
  l_spec_out                     GMD_SPECIFICATIONS%ROWTYPE;
  l_item_mst                     MTL_SYSTEM_ITEMS_B%ROWTYPE;
  l_sampling_plan                GMD_SAMPLING_PLANS%ROWTYPE;
  l_sampling_plan_out            GMD_SAMPLING_PLANS%ROWTYPE;
  l_inventory_item_id            NUMBER;
  l_organization_id              NUMBER;
  l_uom_rate                     NUMBER;

  -- Exceptions
  e_spec_fetch_error             EXCEPTION;
  e_smpl_plan_fetch_error        EXCEPTION;
  e_error_fetch_item             EXCEPTION;

BEGIN
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT (p_operation in ('INSERT', 'UPDATE', 'DELETE')) THEN
    -- Invalid Operation
    GMD_API_PUB.Log_Message('GMD_INVALID_OPERATION');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Verify that the specification exists.
  l_spec.spec_id := p_supp_vr.spec_id;
  IF NOT (GMD_Specifications_PVT.Fetch_Row(
                           p_specifications => l_spec,
                           x_specifications => l_spec_out)
          ) THEN
    -- Fetch Error
    GMD_API_PUB.Log_Message('GMD_SPEC_FETCH_ERROR');
    RAISE e_spec_fetch_error;
  END IF;

  l_spec := l_spec_out ;

  -- Verify that the Sampling Plan exists.
  --odab added this test.
  IF (p_supp_vr.sampling_plan_id IS NOT NULL)
  THEN
    l_sampling_plan.sampling_plan_id := p_supp_vr.sampling_plan_id;
    IF NOT (GMD_Sampling_Plans_PVT.Fetch_Row(
                           p_sampling_plan => l_sampling_plan,
                           x_sampling_plan => l_sampling_plan_out)
          ) THEN
      -- Fetch Error
      GMD_API_PUB.Log_Message('GMD_SAMPLING_PLAN_FETCH_ERROR');
      RAISE e_smpl_plan_fetch_error;
    END IF;
    l_sampling_plan := l_sampling_plan_out ;
  END IF;

  IF (p_called_from = 'API') THEN
    --For mini pack L, bug 3439865
    IF (nvl(p_supp_vr.auto_sample_ind,'N') not in ('N','Y')) THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'INVALID_AUTO_SAMPLE_IND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- end 3439865
    -- Check for NULLs and Valid Foreign Keys in the input parameter
    GMD_SPEC_VRS_GRP.check_for_null_and_fks_in_svr
      (
        p_supp_vr       => p_supp_vr
      , p_spec          => l_spec
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

  -- First Verify that the SAME VR does not exists
  IF (p_operation IN ('INSERT', 'UPDATE')
    AND supp_vr_exist(p_supp_vr, l_spec))
  THEN
    -- Disaster, Trying to insert duplicate
    -- bug 2630007, odaboval put the message in function supp_vr_exist.
    -- GMD_API_PUB.Log_Message('GMD_SUPP_VR_EXIST');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Check to make sure that a samplingplan exists
  -- if auto sample flag on
  IF ((p_supp_vr.sampling_plan_id IS NULL) and
       (p_supp_vr.auto_sample_ind = 'Y'))
  THEN
      GMD_API_PUB.Log_Message('GMD_NEED_SAMPLE_PLAN');
      RAISE e_smpl_plan_fetch_error;
  END IF;

  -- Sample Quantity UOM must be convertible to Item's UOM
  BEGIN
    SELECT inventory_item_id INTO l_inventory_item_id FROM
    gmd_specifications WHERE spec_id = p_supp_vr.spec_id;
    SELECT owner_organization_id INTO l_organization_id FROM
    gmd_specifications WHERE spec_id = p_supp_vr.spec_id;
    SELECT * INTO l_item_mst
    FROM mtl_system_items_b
    WHERE inventory_item_id = l_inventory_item_id
    AND organization_id = l_organization_id;
  EXCEPTION
  WHEN OTHERS THEN
    GMD_API_PUB.Log_Message('GMD_ITEM_FETCH_ERROR');
    RAISE e_error_fetch_item;
  END;

  --odab added this test.
  IF (p_supp_vr.sampling_plan_id IS NOT NULL)
  THEN
    inv_convert.inv_um_conversion (
      from_unit  => l_sampling_plan.sample_qty_uom,
      to_unit    =>  l_item_mst.primary_uom_code,
      item_id    =>  l_inventory_item_id,
      lot_number => NULL,
      organization_id => l_organization_id  ,
      uom_rate   => l_uom_rate );

    IF l_uom_rate = -99999 THEN
      GMD_API_PUB.Log_Message('GMD_UOM_CONVERSION_ERROR');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- No need to check the return status because above procedure
  -- logs appropriate message on the stack and raises an exception.

  -- The Start Date must be less than the End Date
  If ( p_supp_vr.end_date IS NOT NULL AND
       p_supp_vr.start_date > p_supp_vr.end_date) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_EFF_DATE_ERROR');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Spec VR Status Must be less than Spec Status upto Appoved Stages
  IF (floor(l_spec.spec_status/100) <= 7 AND
      floor(p_supp_vr.spec_vr_status/100) <= 7 AND
      p_supp_vr.spec_vr_status > l_spec.spec_status) THEN
    GMD_API_PUB.Log_Message('GMD_SPEC_VR_STATUS_HIGHER');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- All systems GO...

EXCEPTION
  WHEN FND_API.G_EXC_ERROR     OR
       e_spec_fetch_error      OR
       e_smpl_plan_fetch_error OR
       e_error_fetch_item
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END validate_supp_vr;




--Start of comments
--+========================================================================+
--| API Name    : check_for_null_and_fks_in_svr                            |
--| TYPE        : Group                                                    |
--| Notes       : This procedure checks for NULL and Foreign Key           |
--|               constraints for the required filed in the Spec           |
--|               Supplier  VR record.                                     |
--|                                                                        |
--|               If everything is fine then 'S' is returned in the        |
--|               parameter - x_return_status otherwise error message      |
--|               is logged and error status - E or U returned             |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar     26-Jul-2002     Created.                           |
--|                                                                        |
--|    SaiKiran		04-MAY-2004	Enhancement #3476560. added        |
--|                  'delayed_lot_entry' to the call to 'check_vr_controls'|
--|                   procedure.                                           |
--|                                                                        |
--|    Saikiran        11-Apr-2005      Convergence Changes                |
--|    srakrish        15-june-06    BUG 5251172: Checking if the          |
--|					responsibility is available to the |
--|					organization			   |
--+========================================================================+
-- End of comments

PROCEDURE check_for_null_and_fks_in_svr
(
  p_supp_vr       IN  gmd_supplier_spec_vrs%ROWTYPE
, p_spec          IN  gmd_specifications%ROWTYPE
, x_return_status OUT NOCOPY VARCHAR2
)
IS

CURSOR c_item_controls IS
SELECT lot_control_code
FROM   mtl_system_items_b
WHERE  inventory_item_id = p_spec.inventory_item_id
AND organization_id = p_spec.owner_organization_id;

CURSOR c_supplier IS
SELECT 1
FROM po_vendors v
WHERE v.vendor_id = p_supp_vr.supplier_id
  AND v.enabled_flag = 'Y'
  AND sysdate between nvl(v.start_date_active, sysdate-1)
               AND     nvl(v.end_date_active, sysdate+1);

CURSOR c_supplier_site IS
SELECT 1
FROM po_vendor_sites_all v
WHERE (v.purchasing_site_flag = 'Y'
   OR v.rfq_only_site_flag = 'Y')
  AND sysdate < NVL(inactive_date, sysdate + 1)
  AND v.vendor_id = p_supp_vr.supplier_id
  AND v.vendor_site_id = p_supp_vr.supplier_site_id;

-- bug 4924483 sql id 14687791 - cost is down from 4,380,562   to 6  - no IN

/*CURSOR c_po IS
SELECT 1
FROM po_headers_all pha
WHERE pha.po_header_id IN
  (SELECT pla.po_header_id
   FROM po_lines_all pla
   WHERE pla.po_header_id = pha.po_header_id
   AND pla.item_id = p_spec.inventory_item_id
  AND pha.vendor_id      = p_supp_vr.supplier_id
  AND pha.vendor_site_id = p_supp_vr.supplier_site_id
  AND pha.po_header_id   = p_supp_vr.po_header_id); */

-- fix
CURSOR c_po IS
SELECT 1
FROM po_headers_all pha, po_lines_all pla
WHERE pha.po_header_id   = p_supp_vr.po_header_id
AND pha.vendor_id      = p_supp_vr.supplier_id
AND pha.vendor_site_id = p_supp_vr.supplier_site_id
AND pha.po_header_id  = pla.po_header_id
AND pla.item_id = p_spec.inventory_item_id;






CURSOR c_po_line IS
SELECT 1
FROM po_lines_all pla
WHERE pla.item_id = p_spec.inventory_item_id
  AND pla.po_header_id = p_supp_vr.po_header_id
  AND pla.po_line_id   = p_Supp_vr.po_line_id;

-- Local variables
dummy              PLS_INTEGER;
l_lot_ctl          NUMBER;

BEGIN

  --=========================================================================
  -- WHO section :
  --=========================================================================
  check_who( p_user_id  => p_supp_vr.created_by);
  check_who( p_user_id  => p_supp_vr.last_updated_by);
  IF (p_supp_vr.creation_date IS NULL
   OR p_supp_vr.last_update_date IS NULL)
  THEN
    GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                            'WHAT', 'the dates must not be NULL');
    RAISE FND_API.G_EXC_ERROR;
  END IF;



  -- Organization is valid
  IF (p_supp_vr.organization_id IS NOT NULL) THEN
    -- Check that organization is accessible to the user's responsibility
    OPEN c_orgn( p_supp_vr.organization_id);
    FETCH c_orgn INTO dummy;
    IF c_orgn%NOTFOUND THEN
      CLOSE c_orgn;
      GMD_API_PUB.Log_Message('GMD_ORGANIZATION_ID_NOT_FOUND',
                              'ORGN_ID', p_supp_vr.organization_id);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_orgn;
  END IF;

  --srakrish BUG 5251172: Checking if the responsibility is available to the organization.
  IF NOT (gmd_api_grp.OrgnAccessible(p_supp_vr.organization_id)) THEN
    	  RAISE FND_API.G_EXC_ERROR;
  END IF;





  --=========================================================================
  -- Get Item Controls
  --=========================================================================
  OPEN c_item_controls;
  FETCH c_item_controls
   INTO l_lot_ctl;
  IF (c_item_controls%NOTFOUND)
  THEN
      CLOSE c_item_controls;
      FND_MESSAGE.SET_NAME('GMD','GMD_NOTFOUND');
      FND_MESSAGE.SET_TOKEN('WHAT', 'INVENTORY_ITEM_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', p_spec.inventory_item_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_item_controls;

  --=========================================================================
  -- lot_optional_on_sample :
  -- When this field is NOT NULL, all the following fields must be null :
  -- sample_inv_trans_ind
  --=========================================================================
  --Enhancement #3476560. added 'delayed_lot_entry' to the call to 'check_vr_controls' procedure
  check_VR_Controls( p_VR_type                  => 'SUPPLIER'
                   , p_lot_optional_on_sample   => p_supp_vr.lot_optional_on_sample
		   , p_delayed_lot_entry        => p_supp_vr.delayed_lot_entry
                   , p_sample_inv_trans_ind     => p_supp_vr.sample_inv_trans_ind
                   , p_lot_ctl                  => l_lot_ctl
                   , p_status_ctl               => NULL
                   , p_control_lot_attrib_ind   => p_supp_vr.CONTROL_LOT_ATTRIB_IND
                   , p_in_spec_lot_status_id    => p_supp_vr.in_spec_lot_status_id
                   , p_out_of_spec_lot_status_id => p_supp_vr.out_of_spec_lot_status_id
                   , p_control_batch_step_ind   => NULL
		   , p_delayed_lpn_entry        => p_supp_vr.delayed_lpn_entry);    --RLNAGARA LPN ME 7027149

  --RLNAGARA LPN ME 7027149 start  Check for WMS enabled organization.
  IF (p_supp_vr.organization_id IS NOT NULL) THEN
    IF NOT check_wms_enabled(p_supp_vr.organization_id) THEN  -- If the Org is not a wms enabled then delayed_lpn_entry should be NULL
      IF p_supp_vr.delayed_lpn_entry IS NOT NULL THEN
        GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'Delayed_LPN_Entry should be NULL for Non-WMS Enabled Organization.');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END IF;
  --RLNAGARA LPN ME 7027149 end

  --=========================================================================
  -- spec_vr_status :
  --=========================================================================
  OPEN c_status(p_supp_vr.spec_vr_status);
  FETCH c_status
   INTO dummy;
  IF (c_status%NOTFOUND)
  THEN
    CLOSE c_status;
    GMD_API_PUB.Log_Message('GMD_SPEC_STATUS_NOT_FOUND',
                            'STATUS', p_supp_vr.spec_vr_status);
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_status;

  --=========================================================================
  -- start_date : This field is mandatory
  --=========================================================================
  IF (p_supp_vr.start_date IS NULL)
  THEN
      GMD_API_PUB.Log_Message('GMD_SPEC_VR_START_DATE_REQD');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  --=========================================================================
  -- COA section :
  --=========================================================================
  check_COA( p_coa_type              => p_supp_vr.coa_type
           , p_coa_at_ship_ind       => p_supp_vr.coa_at_ship_ind
           , p_coa_at_invoice_ind    => p_supp_vr.coa_at_invoice_ind
           , p_coa_req_from_supl_ind => p_supp_vr.coa_req_from_supl_ind);

  --=========================================================================
  -- supplier_id : This field is mandatory
  --=========================================================================
  IF (p_supp_vr.supplier_id IS NULL)
  THEN
    GMD_API_PUB.Log_Message('GMD_SUPPLIER_REQD');
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    OPEN c_supplier;
    FETCH c_supplier INTO dummy;
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
  IF ( p_supp_vr.supplier_site_id IS NOT NULL)
  THEN
    OPEN c_supplier_site;
    FETCH c_supplier_site
     INTO dummy;
    IF (c_supplier_site%NOTFOUND)
    THEN
      CLOSE c_supplier_site;
      FND_MESSAGE.SET_NAME('GMD','GMD_NOTFOUND');
      FND_MESSAGE.SET_TOKEN('WHAT', 'SUPPLIER_SITE_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', p_supp_vr.supplier_site_id);
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
  IF (p_supp_vr.po_header_id IS NOT NULL)
  THEN
    IF (p_supp_vr.supplier_site_id IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'supplier_site_id must not be NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_po;
    FETCH c_po INTO dummy;
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
  IF (p_supp_vr.po_line_id IS NOT NULL)
  THEN
    IF (p_supp_vr.po_header_id IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'po_header_id must not be NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_supp_vr.supplier_site_id IS NULL)
    THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'supplier site must not be NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_po_line;
    FETCH c_po_line INTO dummy;
    IF (c_po_line%NOTFOUND)
    THEN
      CLOSE c_po_line;
      GMD_API_PUB.Log_Message('GMD_PO_LINE_NOT_FOUND');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_po_line;
  END IF;

  -- All Systems Go...

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END check_for_null_and_fks_in_svr;




--Start of comments
--+========================================================================+
--| API Name    : supp_vr_exist                                            |
--| TYPE        : Group                                                    |
--| Notes       : This function returns TRUE if the supplier VR already    |
--|               exists for the spcified parameter in the database, FALSE |
--|               otherwise.                                               |
--|                                                                        |
--| HISTORY                                                                |
--|    Chetan Nagar     26-Jul-2002     Created.                           |
--|    Olivier Daboval  17-OCT-2002     bug 2630007, added spec_name in    |
--|                                     the VR_EXIST message               |
--|    Olivier Daboval  14-NOV-2002     Added NVL(spec_vr_id, -1) because  |
--|                                     the API passes a NULL spec_vr_id   |
--|                                     in insert mode.                    |
--|    Brenda Stone     20-NOV-2003     Bug 3090290; allow duplicate spec vr |
--|                                     with "OBSOLUTE" status               |
--|                                     Bug 2984784; add Version to msg for  |
--|                                     existing spec vr.                    |
--|                                                                        |
--|  Saikiran          12-Apr-2005      Convergence Changes                |
--|  Plowe						 04-Apr-2006      Bug 5117733 - added item revision to match
--+========================================================================+
-- End of comments

FUNCTION supp_vr_exist(p_supp_vr GMD_SUPPLIER_SPEC_VRS%ROWTYPE,
                       p_spec    GMD_SPECIFICATIONS%ROWTYPE)
RETURN BOOLEAN IS

  CURSOR c_supp_vr IS
  SELECT vr.spec_vr_id, s.spec_name, s.spec_vers
  FROM   gmd_specifications_b s, gmd_supplier_spec_vrs vr
  WHERE  s.spec_id = vr.spec_id
  AND    s.owner_organization_id = p_spec.owner_organization_id
  AND    s.inventory_item_id = p_spec.inventory_item_id
  AND   ( (s.revision is null and p_spec.revision is NULL ) OR -- handle item revision 5117733
          (s.revision  = p_spec.revision )
  			 )
  AND    ((s.grade_code is NULL AND p_spec.grade_code is NULL) OR
          (s.grade_code = p_spec.grade_code)
         )
  AND    ((vr.organization_id is NULL AND p_supp_vr.organization_id is NULL) OR
          (vr.organization_id = p_supp_vr.organization_id)
         )
  AND    ((vr.supplier_id is NULL AND p_supp_vr.supplier_id is NULL) OR
          (vr.supplier_id = p_supp_vr.supplier_id)
         )
  AND    ((vr.supplier_site_id is NULL AND p_supp_vr.supplier_site_id is NULL) OR
          (vr.supplier_site_id = p_supp_vr.supplier_site_id)
         )
  AND    ((vr.po_header_id is NULL AND p_supp_vr.po_header_id is NULL) OR
          (vr.po_header_id = p_supp_vr.po_header_id)
         )
  AND    ((vr.po_line_id is NULL AND p_supp_vr.po_line_id is NULL) OR
          (vr.po_line_id = p_supp_vr.po_line_id)
         )
  AND    ((vr.end_date is NULL AND (p_supp_vr.end_date IS NULL OR
                                    p_supp_vr.end_date >= vr.start_date)) OR
	  (p_supp_vr.end_date IS NULL AND
	     p_supp_vr.start_date <= nvl(vr.end_date, p_supp_vr.start_date)) OR
          (p_supp_vr.start_date <= vr.end_date AND p_supp_vr.end_date >= vr.start_date)
         )
  AND   ( floor(vr.spec_vr_status/100) = floor(p_supp_vr.spec_vr_status/100) AND
/*      Bug 3090290; allow duplicate spec vr with "OBSOLUTE" status   */
         p_supp_vr.spec_vr_status <> 1000 )
  AND    vr.spec_vr_status NOT IN (SELECT status_code FROM gmd_qc_status
                                   WHERE status_type = 800)
  AND    vr.delete_mark = 0
  AND    s.delete_mark = 0
  AND    vr.spec_vr_id <> NVL(p_supp_vr.spec_vr_id, -1)
  ;

  dummy    PLS_INTEGER;
  specname VARCHAR2(80);
  specvers NUMBER;

BEGIN

  OPEN c_supp_vr;
  FETCH c_supp_vr INTO dummy, specname, specvers;
  IF c_supp_vr%FOUND THEN
    CLOSE c_supp_vr;
    FND_MESSAGE.SET_NAME('GMD', 'GMD_SUPP_VR_EXIST');
    FND_MESSAGE.SET_TOKEN('spec', specname);
    FND_MESSAGE.SET_TOKEN('vers', specvers);
    FND_MSG_PUB.ADD;
    RETURN TRUE;
  ELSE
    CLOSE c_supp_vr;
    RETURN FALSE;
  END IF;

EXCEPTION
  -- Though there is no reason the program can reach
  -- here, this is coded just for the reasons we can
  -- not think of!
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_API_ERROR');
    FND_MESSAGE.SET_TOKEN('PACKAGE', 'GMD_SPEC_VRS_GRP.SUPP_VR_EXIST' );
    FND_MESSAGE.SET_TOKEN('ERROR', SUBSTR(SQLERRM,1,200));
    RETURN TRUE;

END supp_vr_exist;

/*===========================================================================
  PROCEDURE  NAME:	validate_before_delete_inv_vrs

  DESCRIPTION:		This procedure validates:
                        a) Primary key supplied
                        b) Inventory Spec VRS is not already delete_marked

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	KYH
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_DELETE_INV_VRS(
	p_spec_id          IN NUMBER,
	p_spec_vr_id       IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress           VARCHAR2(3);
l_temp               VARCHAR2(1);
l_inventory_spec_vrs GMD_INVENTORY_SPEC_VRS%ROWTYPE;
l_inventory_spec_vrs_out GMD_INVENTORY_SPEC_VRS%ROWTYPE;

BEGIN
	l_progress := '010';
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

        -- validate for primary key
        -- ========================
	IF p_spec_id IS NULL THEN
             GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_inventory_spec_vrs.spec_id := p_spec_id;
	END IF;

	IF p_spec_vr_id IS NULL THEN
             GMD_API_PUB.Log_Message('GMD_SPEC_VR_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_inventory_spec_vrs.spec_vr_id := p_spec_vr_id;
	END IF;

        -- Fetch the row
        -- =============
        IF  NOT GMD_Inventory_Spec_VRS_PVT.Fetch_Row(l_inventory_spec_vrs,l_inventory_spec_vrs_out)
        THEN
          GMD_API_PUB.Log_Message('GMD_FAILED_TO_FETCH_ROW',
                              'l_table_name', 'GMD_INVENTORY_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_inventory_spec_vrs.spec_vr_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_inventory_spec_vrs := l_inventory_spec_vrs_out ;

        -- Terminate if the row is already delete marked
        -- =============================================
        IF l_inventory_spec_vrs.delete_mark <> 0
        THEN
          GMD_API_PUB.Log_Message('GMD_RECORD_DELETE_MARKED',
                              'l_table_name', 'GMD_INVENTORY_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_inventory_spec_vrs.spec_vr_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_SPEC_GRP.VALIDATE_BEFORE_DELETE');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_BEFORE_DELETE_INV_VRS ;

/*===========================================================================
  PROCEDURE  NAME:	validate_before_delete_wip_vrs

  DESCRIPTION:		This procedure validates:
                        a) Primary key supplied
                        b) WIP Spec VRS is not already delete_marked

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	KYH
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_DELETE_WIP_VRS(
	p_spec_id          IN NUMBER,
	p_spec_vr_id       IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress           VARCHAR2(3);
l_temp               VARCHAR2(1);
l_wip_spec_vrs GMD_WIP_SPEC_VRS%ROWTYPE;
l_wip_spec_vrs_out GMD_WIP_SPEC_VRS%ROWTYPE;

BEGIN
	l_progress := '010';
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

        -- validate for primary key
        -- ========================
	IF p_spec_id IS NULL THEN
             GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_wip_spec_vrs.spec_id := p_spec_id;
	END IF;

	IF p_spec_vr_id IS NULL THEN
             GMD_API_PUB.Log_Message('GMD_SPEC_VR_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_wip_spec_vrs.spec_vr_id := p_spec_vr_id;
	END IF;

        -- Fetch the row
        -- =============
        IF  NOT GMD_WIP_Spec_VRS_PVT.Fetch_Row(l_wip_spec_vrs,l_wip_spec_vrs_out)
        THEN
          GMD_API_PUB.Log_Message('GMD_FAILED_TO_FETCH_ROW',
                              'l_table_name', 'GMD_WIP_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_wip_spec_vrs.spec_vr_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_wip_spec_vrs := l_wip_spec_vrs_out ;

        -- Terminate if the row is already delete marked
        -- =============================================
        IF l_wip_spec_vrs.delete_mark <> 0
        THEN
          GMD_API_PUB.Log_Message('GMD_RECORD_DELETE_MARKED',
                              'l_table_name', 'GMD_WIP_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_wip_spec_vrs.spec_vr_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_SPEC_GRP.VALIDATE_BEFORE_DELETE');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_BEFORE_DELETE_WIP_VRS ;

/*===========================================================================
  PROCEDURE  NAME:	validate_before_delete_cst_vrs

  DESCRIPTION:		This procedure validates:
                        a) Primary key supplied
                        b) Customer Spec VRS is not already delete_marked

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	KYH
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_DELETE_CST_VRS(
	p_spec_id          IN NUMBER,
	p_spec_vr_id       IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress           VARCHAR2(3);
l_customer_spec_vrs GMD_CUSTOMER_SPEC_VRS%ROWTYPE;
l_customer_spec_vrs_out GMD_CUSTOMER_SPEC_VRS%ROWTYPE;

BEGIN
	l_progress := '010';
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

        -- validate for primary key
        -- ========================
	IF p_spec_id IS NULL THEN
             GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_customer_spec_vrs.spec_id := p_spec_id;
	END IF;

	IF p_spec_vr_id IS NULL THEN
             GMD_API_PUB.Log_Message('GMD_SPEC_VR_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_customer_spec_vrs.spec_vr_id := p_spec_vr_id;
	END IF;

        -- Fetch the row
        -- =============
        IF  NOT GMD_Customer_Spec_VRS_PVT.Fetch_Row(l_customer_spec_vrs,l_customer_spec_vrs_out)
        THEN
          GMD_API_PUB.Log_Message('GMD_FAILED_TO_FETCH_ROW',
                              'l_table_name', 'GMD_CUSTOMER_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_customer_spec_vrs.spec_vr_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_customer_spec_vrs := l_customer_spec_vrs_out ;

        -- Terminate if the row is already delete marked
        -- =============================================
        IF l_customer_spec_vrs.delete_mark <> 0
        THEN
          GMD_API_PUB.Log_Message('GMD_RECORD_DELETE_MARKED',
                              'l_table_name', 'GMD_CUSTOMER_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_customer_spec_vrs.spec_vr_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_SPEC_GRP.VALIDATE_BEFORE_DELETE');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_BEFORE_DELETE_CST_VRS ;

/*===========================================================================
  PROCEDURE  NAME:	validate_before_delete_sup_vrs

  DESCRIPTION:		This procedure validates:
                        a) Primary key supplied
                        b) Supplier Spec VRS is not already delete_marked

  PARAMETERS:

  CHANGE HISTORY:	Created		09-JUL-02	KYH
===========================================================================*/

PROCEDURE VALIDATE_BEFORE_DELETE_SUP_VRS(
	p_spec_id          IN NUMBER,
	p_spec_vr_id       IN NUMBER,
	x_return_status    OUT NOCOPY VARCHAR2,
        x_message_data     OUT NOCOPY VARCHAR2) IS

l_progress           VARCHAR2(3);
l_supplier_spec_vrs  GMD_SUPPLIER_SPEC_VRS%ROWTYPE;
l_supplier_spec_vrs_out  GMD_SUPPLIER_SPEC_VRS%ROWTYPE;

BEGIN
	l_progress := '010';
	x_return_status := FND_API.G_RET_STS_SUCCESS ;

        -- validate for primary key
        -- ========================
	IF p_spec_id IS NULL THEN
             GMD_API_PUB.Log_Message('GMD_SPEC_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_supplier_spec_vrs.spec_id := p_spec_id;
	END IF;

	IF p_spec_vr_id IS NULL THEN
             GMD_API_PUB.Log_Message('GMD_SPEC_VR_ID_REQUIRED');
	     RAISE FND_API.G_EXC_ERROR;
        ELSE
             l_supplier_spec_vrs.spec_vr_id := p_spec_vr_id;
	END IF;

        -- Fetch the row
        -- =============
        IF  NOT GMD_Supplier_Spec_VRS_PVT.Fetch_Row(l_supplier_spec_vrs,l_supplier_spec_vrs_out)
        THEN
          GMD_API_PUB.Log_Message('GMD_FAILED_TO_FETCH_ROW',
                              'l_table_name', 'GMD_SUPPLIER_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_supplier_spec_vrs.spec_vr_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_supplier_spec_vrs := l_supplier_spec_vrs_out ;

        -- Terminate if the row is already delete marked
        -- =============================================
        IF l_supplier_spec_vrs.delete_mark <> 0
        THEN
          GMD_API_PUB.Log_Message('GMD_RECORD_DELETE_MARKED',
                              'l_table_name', 'GMD_SUPPLIER_SPEC_VRS',
                              'l_column_name', 'SPEC_VR_ID',
                              'l_key_value', l_supplier_spec_vrs.spec_vr_id);
          RAISE FND_API.G_EXC_ERROR;
        END IF;


EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);

WHEN OTHERS THEN
      FND_MESSAGE.Set_Name('GMD','GMD_API_ERROR');
      FND_MESSAGE.Set_Token('PACKAGE','GMD_SPEC_GRP.VALIDATE_BEFORE_DELETE');
      FND_MESSAGE.Set_Token('ERROR', substr(sqlerrm,1,100));
      FND_MESSAGE.Set_Token('POSITION',l_progress );
      FND_MSG_PUB.ADD;
      x_message_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_LAST,FND_API.G_FALSE);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END VALIDATE_BEFORE_DELETE_SUP_VRS ;

/*===========================================================================
  PROCEDURE  NAME:	check_who

  DESCRIPTION:		This procedure validates the user_id

  PARAMETERS:

  CHANGE HISTORY:	Created		13-NOV-02	odaboval
===========================================================================*/
PROCEDURE check_who( p_user_id  IN  NUMBER)
IS

CURSOR c_who (userid IN NUMBER) IS
SELECT 1
FROM fnd_user
WHERE  user_id = userid;

dummy    PLS_INTEGER;

BEGIN

  IF (p_user_id IS NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMD','GMD_WRONG_VALUE');
    FND_MESSAGE.SET_TOKEN('WHAT', 'USER_ID');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    OPEN c_who( p_user_id);
    FETCH c_who
     INTO dummy;

    IF (c_who%NOTFOUND)
    THEN
      CLOSE c_who;
      FND_MESSAGE.SET_NAME('GMD','GMD_NOTFOUND');
      FND_MESSAGE.SET_TOKEN('WHAT', 'USER_ID');
      FND_MESSAGE.SET_TOKEN('VALUE', p_user_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_who;
  END IF;

END check_who;


/*===========================================================================
  PROCEDURE  NAME:	check_COA

  DESCRIPTION:		This procedure validates the Certificate Of Analysis fields

  PARAMETERS:

  CHANGE HISTORY:	Created		13-NOV-02	odaboval
===========================================================================*/
PROCEDURE check_COA( p_coa_type              IN  VARCHAR2
                   , p_coa_at_ship_ind       IN VARCHAR2
                   , p_coa_at_invoice_ind    IN VARCHAR2
                   , p_coa_req_from_supl_ind IN VARCHAR2)
IS

CURSOR c_coa_type IS
SELECT 1
FROM gem_lookups
WHERE lookup_type = 'GMD_QC_CERTIFICATE_TYPE'
AND lookup_code = p_coa_type;

dummy    PLS_INTEGER;

BEGIN

-- Value Check :
-- The only value for these controls are (NULL, 'Y')
IF (p_coa_at_ship_ind IS NOT NULL)
  AND (p_coa_at_ship_ind <> 'Y')
THEN
   GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                  'WHAT', 'coa_at_ship_ind value must be either NULL or Y');
   RAISE FND_API.G_EXC_ERROR;
END IF;
IF (p_coa_at_invoice_ind IS NOT NULL)
  AND (p_coa_at_invoice_ind <> 'Y')
THEN
   GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                  'WHAT', 'coa_at_invoice_ind value must be either NULL or Y');
   RAISE FND_API.G_EXC_ERROR;
END IF;
IF (p_coa_req_from_supl_ind IS NOT NULL)
  AND (p_coa_req_from_supl_ind <> 'Y')
THEN
   GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                  'WHAT', 'coa_req_from_supl_ind value must be either NULL or Y');
   RAISE FND_API.G_EXC_ERROR;
END IF;
IF (p_coa_type IS NOT NULL)
THEN
  OPEN c_coa_type;
  FETCH c_coa_type
   INTO dummy;
  IF (c_coa_type%NOTFOUND)
  THEN
    CLOSE c_coa_type;
    FND_MESSAGE.Set_Name('GMD','GMD_NOTFOUND');
    FND_MESSAGE.Set_Token('WHAT', 'COA_TYPE');
    FND_MESSAGE.Set_Token('VALUE', p_coa_type);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_coa_type;
END IF;


-- Functional Check :
--=========================================================================
-- COA :
-- When COA_TYPE is NULL, then these following fields MUST be NULL :
-- coa_at_ship_ind, coa_at_invoice_ind, coa_req_from_supl_ind
--=========================================================================
IF (p_coa_type IS NULL)
THEN
   IF (p_coa_at_ship_ind IS NOT NULL)
   THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'coa_at_ship_ind must be NULL');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_coa_at_invoice_ind IS NOT NULL)
   THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'coa_at_invoice_ind must be NULL');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_coa_req_from_supl_ind IS NOT NULL)
   THEN
      GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                              'WHAT', 'coa_req_from_supl_ind must be NULL');
      RAISE FND_API.G_EXC_ERROR;
   END IF;
END IF;  -- coa_type is NULL

END check_COA;

/*===========================================================================
  PROCEDURE  NAME:	check_VR_controls

  DESCRIPTION:		This procedure validates the entries in the Controls group

  PARAMETERS:

  CHANGE HISTORY:	Created		13-NOV-02	odaboval

  Enhancement# 3476560. Added           04-MAY-04       Saikiran vankadari
  'Delayed Lot Entry' field to the signature.
   Added validation for 'Delayed Lot Entry' that
   it should be 'Y' or Null. Removed special validation
   for 'Lot Optional on sample' in case of WIP Validity rule.

  Bug# 3652938.                         28-MAY-04       Saikiran vankadari
 Added validation for the invalid combination of
 'Lot Optional on Sample' and 'Delayed Lot Entry'.

 Convergence changes                11-Apr-05           Saikiran Vankadari

 Bug # 4900420                         27-DEC-05  RLNAGARA
  Removed the code which was validating the control_lot_attributes when lot_optional_on_sample was not NULL
===========================================================================*/
PROCEDURE check_VR_Controls
                   ( p_VR_type                  IN VARCHAR2
                   , p_lot_optional_on_sample   IN VARCHAR2
		   , p_delayed_lot_entry        IN VARCHAR2 DEFAULT NULL
                   , p_sample_inv_trans_ind     IN VARCHAR2
                   , p_lot_ctl                  IN NUMBER
                   , p_status_ctl               IN VARCHAR2
                   , p_control_lot_attrib_ind   IN VARCHAR2
                   , p_in_spec_lot_status_id    IN NUMBER
                   , p_out_of_spec_lot_status_id IN NUMBER
                   , p_control_batch_step_ind   IN VARCHAR2
		   , p_auto_complete_batch_step IN VARCHAR2 DEFAULT NULL  -- Bug# 5440347
		   , p_delayed_lpn_entry        IN VARCHAR2 DEFAULT NULL) IS  --RLNAGARA LPN ME 7027149

CURSOR c_lot_status (lot_status_id IN VARCHAR2) IS
SELECT 1
FROM mtl_material_statuses
WHERE NVL(enabled_flag,0) = 1
AND   status_id = lot_status_id;

dummy              PLS_INTEGER;

BEGIN

-- Value Check :
-- The only value for these controls are (NULL, 'Y')
IF (p_lot_optional_on_sample IS NOT NULL)
  AND (p_lot_optional_on_sample <> 'Y')
THEN
   GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                  'WHAT', 'lot_optional_on_sample value must be either NULL or Y');
   RAISE FND_API.G_EXC_ERROR;
END IF;

--Enhancement# 3476560. Added validation for 'Delayed Lot Entry' that it should be 'Y' or Null.
IF (p_delayed_lot_entry IS NOT NULL)
  AND(p_delayed_lot_entry<>'Y')
THEN
  GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                 'WHAT', 'delayed_lot_entry value must be either NULL or Y');
  RAISE FND_API.G_EXC_ERROR;
END IF;

--RLNAGARA LPN ME 7027149 start

IF (p_delayed_lpn_entry IS NOT NULL) AND (p_delayed_lpn_entry <> 'Y') THEN
  GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                 'WHAT', 'delayed_lpn_entry value must be either NULL or Y');
  RAISE FND_API.G_EXC_ERROR;
END IF;

IF (p_VR_type IN ('CUSTOMER') AND (p_delayed_lpn_entry IS NOT NULL)) THEN
  GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                 'WHAT', 'delayed_lpn_entry value must be either NULL for CUSTOMER VRs');
  RAISE FND_API.G_EXC_ERROR;
END IF;

--RLNAGARA LPN ME 7027149 end

--Bug# 3652938. Added validation for the invalid combination of 'Lot Optional on Sample' and 'Delayed Lot Entry'.
IF (p_lot_optional_on_sample IS NULL)
  AND(p_delayed_lot_entry = 'Y')
THEN
  GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                 'WHAT', 'delayed_lot_entry value cannot be Y when lot_optional_on_sample is NULL');
  RAISE FND_API.G_EXC_ERROR;
END IF;

IF (p_VR_type IN ('INVENTORY', 'WIP','SUPPLIER'))
THEN
  IF (p_control_lot_attrib_ind IS NOT NULL)
    AND (p_control_lot_attrib_ind <> 'Y')
  THEN
     GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                  'WHAT', 'control_lot_attrib_ind value must be either NULL or Y');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_sample_inv_trans_ind IS NOT NULL)
    AND (p_sample_inv_trans_ind <> 'Y')
  THEN
    GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                  'WHAT', 'sample_inv_trans_ind value must be either NULL or Y');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Extra field for WIP :
  IF (p_VR_type = 'WIP')
  THEN
    IF (p_control_batch_step_ind IS NOT NULL)
      AND (p_control_batch_step_ind <> 'Y')
    THEN
       GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                  'WHAT', 'control_batch_step_ind value must be either NULL or Y');
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Bug# 5440347 start
    IF (p_auto_complete_batch_step IS NOT NULL)
      AND (p_auto_complete_batch_step <> 'Y')
    THEN
       GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                  'WHAT', 'auto_complete_batch_step value must be either NULL or Y');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Bug# 5440347 end


    --Enhancement# 3476560. Removed special validation for 'Lot Optional on sample'.
    --IF ( p_lot_optional_on_sample IS NOT NULL)
    --THEN
    --   GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
    --                         'WHAT', 'lot_optional_on_sample must be NULL');
    --   RAISE FND_API.G_EXC_ERROR;
    --END IF;

  END IF;

END IF;

-- Functional Check :
-- Bug 2698118 : When non-lot-controlled item then lot_optional_on_sample MUST be NULL
IF (p_lot_ctl = 1) AND (p_lot_optional_on_sample IS NOT NULL)
THEN
   GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
             'WHAT', 'For a non controlled item, lot_optional_on_sample must be NULL');
   RAISE FND_API.G_EXC_ERROR;
END IF;

IF (p_VR_type IN ('INVENTORY', 'WIP','SUPPLIER'))
THEN
  IF (p_lot_optional_on_sample IS NOT NULL ) THEN
       IF (p_sample_inv_trans_ind IS NOT NULL)
       THEN
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'sample_inv_trans_ind must be NULL');
          RAISE FND_API.G_EXC_ERROR;
       END IF;

--RLNAGARA Bug # 4900420 Removed the validation code for control_lot_attributes

       -- A special extra field for WIP :
       -- Bug# 5440347
       -- control_batch_step_ind is not dependent on lot_optional_on_sample.
       /*IF (p_VR_type = 'WIP')
       THEN
         IF (p_control_batch_step_ind IS NOT NULL)
         THEN
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                  'WHAT', 'control_batch_step_ind must be NULL');
          RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;*/
  ELSE --p_lot_optional_on_sample IS NULL

    --=========================================================================
    -- status_ctl :
    -- When the item is NOT status_ctl, then these fields MUST be NULL :
    --  control_lot_attrib_ind, in_spec_lot_status_id, out_of_spec_lot_status_id
    --=========================================================================
    IF (p_status_ctl = 'N')
    THEN
       --=========================================================================
       -- In this case, these fields MUST be NULL :
       --  control_lot_attrib_ind, in_spec_lot_status_id, out_of_spec_lot_status_id
       --=========================================================================
       IF (p_control_lot_attrib_ind IS NOT NULL)
       THEN
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                'WHAT', 'control_lot_attrib_ind must be NULL');
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (p_in_spec_lot_status_id IS NOT NULL)
       THEN
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                  'WHAT', 'in_spec_lot_status_id must be NULL');
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (p_out_of_spec_lot_status_id IS NOT NULL)
       THEN
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                  'WHAT', 'out_of_spec_lot_status_id must be NULL');
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSE --p_status_ctl <> 'N'
      IF (p_control_lot_attrib_ind IS NULL)
      THEN
       --=========================================================================
       -- In this case, these fields MUST be NULL :
       --  in_spec_lot_status_id, out_of_spec_lot_status_id
       --=========================================================================
       IF (p_in_spec_lot_status_id IS NOT NULL)
       THEN
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                  'WHAT', 'in_spec_lot_status_id must be NULL');
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (p_out_of_spec_lot_status_id IS NOT NULL)
       THEN
          GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                  'WHAT', 'out_of_spec_lot_status_id must be NULL');
          RAISE FND_API.G_EXC_ERROR;
       END IF;
      ELSE
         --=========================================================================
         -- In this case, control_lot_attrib_ind IS NOT NULL,
         --   then these fields are MANDATORY :
         --       in_spec_lot_status_id, out_of_spec_lot_status_id
         --=========================================================================
         -- Check the values of in_spec_lot_status_id and out_of_spec_lot_status_id
         IF (p_in_spec_lot_status_id IS NULL)
         THEN
           GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                   'WHAT', 'in_spec_lot_status_id is MANDATORY');
           RAISE FND_API.G_EXC_ERROR;
         ELSE
           OPEN c_lot_status(p_in_spec_lot_status_id);
           FETCH c_lot_status INTO dummy;
           IF (c_lot_status%NOTFOUND)
           THEN
             CLOSE c_lot_status;
             FND_MESSAGE.SET_NAME('GMD','GMD_NOTFOUND');
             FND_MESSAGE.SET_TOKEN('WHAT', 'IN_SPEC_LOT_STATUS_ID');
             FND_MESSAGE.SET_TOKEN('VALUE', p_in_spec_lot_status_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
           CLOSE c_lot_status;
         END IF;   -- in_spec_lot_status IS NULL

         IF (p_out_of_spec_lot_status_id IS NULL)
         THEN
           GMD_API_PUB.Log_Message('GMD_WRONG_VALUE',
                                   'WHAT', 'out_of_spec_lot_status_id is MANDATORY');
           RAISE FND_API.G_EXC_ERROR;
         ELSE
           OPEN c_lot_status(p_out_of_spec_lot_status_id);
           FETCH c_lot_status INTO dummy;
           IF (c_lot_status%NOTFOUND)
           THEN
             CLOSE c_lot_status;
             FND_MESSAGE.SET_NAME('GMD','GMD_NOTFOUND');
             FND_MESSAGE.SET_TOKEN('WHAT', 'OUT_OF_SPEC_LOT_STATUS_ID');
             FND_MESSAGE.SET_TOKEN('VALUE', p_out_of_spec_lot_status_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
           END IF;
           CLOSE c_lot_status;
         END IF;   -- out_of_spec_lot_status_id IS NULL
      END IF;    -- control_lot_attrib_ind IS NOT NULL
    END IF;   -- status_ctl
  END IF;    -- lot_optional_on_sample IS NOT NULL
END IF;   --- p_VR_type IN ('INVENTORY', 'WIP')

END check_VR_controls;


--RLNAGARA LPN ME 7027149 Added this function
FUNCTION check_wms_enabled(p_organization_id IN NUMBER)
RETURN BOOLEAN IS
l_wms_enabled_flag VARCHAR2(1);
BEGIN
 SELECT NVL(wms_enabled_flag,'N')
 INTO l_wms_enabled_flag
 FROM mtl_parameters
 WHERE organization_id = p_organization_id;

 IF l_wms_enabled_flag = 'Y' THEN
   RETURN TRUE;
 ELSE
   RETURN FALSE;
 END IF;

END check_wms_enabled;

END GMD_SPEC_VRS_GRP;

/
