--------------------------------------------------------
--  DDL for Package Body PJM_PROJTASK_DELETION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_PROJTASK_DELETION" AS
/* $Header: PJMPTDLB.pls 120.1 2005/07/01 16:39:15 jxtang noship $ */

--  Function name : Checkuse_ProjTask
--  Pre-reqs      : None.
--  Function      : Checks if project/task references are currently used
--                  in manufacturing applications.
--                  This function should be performed prior to project/task
--                  deletion from Oracle Projects
--  Parameters    :
--  IN            : p_project_id           IN       NUMBER      Optional
--                : p_task_id              IN       NUMBER      Optional
--  RETURNS       :
--               Returns -1 if both input Project/Task arguments are null.
--               Returns  1 if input Project/Task argument is still referred
--                             in MFG applications.
--               Returns  2 if input Project/Task argument is still referred
--                             in PJM Task Assignment
--
--                             This function does not check detailed status
--                             such as closed sales order line, or canceled PO
--                             line/shipments, etc.  Therefore those project/
--                             task references will prevent deletion in Oracle
--                             projects, so users should manually
--                             purge those references in mfg apps in order to
--                             delete it successfully in Oracle Projects.
--
--               Returns  0 if input Project/Task argument is not referred.
--
 FUNCTION CheckUse_ProjectTask (p_project_id IN  NUMBER,
			        p_task_id    IN  NUMBER)

	   RETURN NUMBER
 IS

 --  This function can be returns 1 if project id and task id is in use.
 --  How to indicate at least one of the parameters has to be specified?

    pjm_active      NUMBER :=0;
    l_project_id    NUMBER :=0;
    l_dummy         NUMBER :=0;
    l_not_found         BOOLEAN;

    CURSOR c1 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM pjm_project_parameters ppp
               WHERE  ppp.project_id = l_project_id
               --
               -- Bug 917915: should only return value if p_task_id is
               -- null
               AND    p_task_id is null
           );
    CURSOR c2 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM oe_order_lines_all ool
               WHERE  ool.project_id = l_project_id
               AND  ool.task_id =  NVL(p_task_id, ool.task_id)
           );
    CURSOR c3 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM wip_discrete_jobs job
               WHERE  job.project_id = l_project_id
               AND   job.task_id = NVL(p_task_id, job.task_id)
           );
    CURSOR c4 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM mtl_item_locations loc
               WHERE loc.project_id = l_project_id
               AND  loc.task_id = NVL(p_task_id, loc.task_id)
           );
    CURSOR c5 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM mtl_material_transactions mmt
               WHERE (mmt.source_project_id = l_project_id
                   AND mmt.source_task_Id = NVL(p_task_id, mmt.source_task_id)
                   ) );
    CURSOR c6 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM mrp_forecast_dates frct
               WHERE frct.project_id = l_project_id
                   AND frct.task_id = NVL(p_task_id, frct.task_id)
           );
    CURSOR c7 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM mrp_schedule_dates schd
               WHERE schd.project_id = l_project_id
                   AND schd.task_id = NVL(p_task_id, schd.task_id)
           );
    CURSOR c8 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM po_distributions_all dist
               WHERE dist.project_id = l_project_id
                 AND dist.task_id = NVL(p_task_id, dist.task_id)
              );
    CURSOR c9 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM po_req_distributions_all rdist
               WHERE rdist.project_id = l_project_id
                 AND rdist.task_id =  NVL(p_task_id, rdist.task_id)
	   );

    CURSOR c10 IS
       SELECT 1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM wip_transactions wip
               WHERE wip.project_id = l_project_id
                 AND wip.task_id = NVL(p_task_id, wip.task_id)
              );

    CURSOR c11 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM mtl_material_transactions mmt
               WHERE (mmt.project_id = l_project_id
                   AND mmt.task_id = NVL(p_task_id, mmt.task_id)
                  ));

    CURSOR c12 IS
       SELECT  1
       FROM dual
       WHERE
           EXISTS (
               SELECT 1
               FROM mtl_material_transactions mmt
               WHERE (mmt.project_id = l_project_id
                   AND mmt.to_task_id = NVL(p_task_id, mmt.to_task_id)
                  ));

 BEGIN

    SELECT decode(count(1),0,0,1)
    INTO   pjm_active
    FROM   pjm_org_parameters
    WHERE  project_reference_enabled = 'Y';

    IF ( pjm_active = 0 ) THEN
       RETURN(0);
    END IF;

    IF (p_task_id IS NOT NULL) OR  (p_project_id IS NOT NULL) THEN
       IF p_project_id IS NULL THEN
           SELECT tsk.project_id
           INTO   l_project_id
           FROM   pa_tasks tsk
           WHERE  task_id = p_task_id;
       ELSE
           l_project_id := p_project_id;
       END IF;

       OPEN c1;
       FETCH c1 INTO l_dummy;
       l_not_found := c1%NOTFOUND;
       CLOSE c1;

       IF l_not_found THEN
         OPEN c2;
         FETCH c2 INTO l_dummy;
	 l_not_found := c2%NOTFOUND;
         CLOSE c2;
       END IF;

       IF l_not_found THEN
         OPEN c3;
         FETCH c3 INTO l_dummy;
	 l_not_found := c3%NOTFOUND;
         CLOSE c3;
       END IF;

       IF l_not_found THEN
         OPEN c4;
         FETCH c4 INTO l_dummy;
	 l_not_found := c4%NOTFOUND;
         CLOSE c4;
       END IF;

       IF l_not_found THEN
         OPEN c5;
         FETCH c5 INTO l_dummy;
	 l_not_found := c5%NOTFOUND;
         CLOSE c5;
       END IF;

       IF l_not_found THEN
         OPEN c6;
         FETCH c6 INTO l_dummy;
	 l_not_found := c6%NOTFOUND;
         CLOSE c6;
       END IF;



       IF l_not_found THEN
         OPEN c7;
         FETCH c7 INTO l_dummy;
	 l_not_found := c7%NOTFOUND;
         CLOSE c7;
       END IF;

       IF l_not_found THEN
         OPEN c8;
         FETCH c8 INTO l_dummy;
	 l_not_found := c8%NOTFOUND;
         CLOSE c8;
       END IF;

       IF l_not_found THEN
         OPEN c9;
         FETCH c9 INTO l_dummy;
	 l_not_found := c9%NOTFOUND;
         CLOSE c9;
       END IF;

       IF l_not_found THEN
         OPEN c10;
         FETCH c10 INTO l_dummy;
	 l_not_found := c10%NOTFOUND;
         CLOSE c10;
       END IF;

       IF l_not_found THEN
         OPEN c11;
         FETCH c11 INTO l_dummy;
	 l_not_found := c11%NOTFOUND;
         CLOSE c11;
       END IF;

       IF l_not_found THEN
         OPEN c12;
         FETCH c12 INTO l_dummy;
	 l_not_found := c12%NOTFOUND;
         CLOSE c12;
       END IF;

       -- Bug 3600806, add pjm table reference

       IF l_not_found THEN
         SELECT 2
         INTO l_dummy
         FROM dual
         WHERE EXISTS (
               SELECT 1
               FROM pjm_default_tasks pjm
               WHERE pjm.project_id = l_project_id
                 AND pjm.task_id =  NVL(p_task_id, pjm.task_id)
           );
       END IF;
     ELSE
        l_dummy := -1;
     END IF;

     return(l_dummy);

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN(0);
 WHEN others THEN
   RAISE;

 END CheckUse_ProjectTask;

--  Function name : Checkuse_ProjOrg
--  Pre-reqs      : None.
--  Function      : Checks if project references are currently present
--                  in the given organization
--  Parameters    :
--  IN            : p_project_id           IN       NUMBER      Required
--                : p_org_id               IN       NUMBER      Required
--  RETURNS       :
--               Returns -1 if either argument is null.
--               Returns  1 if input Project argument is still referred
--                             in input Org
--
--                             This function does not check detailed status
--                             such as closed sales order line, or canceled PO
--                             line/shipments, etc.
--
--               Returns  0 if input Project argument is not referred in
--                             the given org.
--
 FUNCTION CheckUse_ProjOrg (p_project_id IN  NUMBER,
                            p_org_id     IN  NUMBER)
 RETURN NUMBER IS

  retcode         NUMBER :=0;

 BEGIN

  IF (p_org_id IS NOT NULL) AND (p_project_id IS NOT NULL) THEN

     SELECT  1
     INTO    retcode
     FROM    dual
     WHERE
         EXISTS (
             SELECT 1
             FROM oe_order_lines_all ool
             WHERE  ool.project_id = p_project_id
             AND    ool.ship_from_org_id = p_org_id
         ) OR
         EXISTS (
             SELECT 1
             FROM wip_discrete_jobs job
             WHERE  job.project_id = p_project_id
             AND    job.organization_id = p_org_id
         ) OR
         EXISTS (
             SELECT 1
             FROM mtl_item_locations loc
             WHERE loc.project_id = p_project_id
             AND   loc.organization_id = p_org_id
         ) OR
         EXISTS (
             SELECT 1
             FROM mtl_material_transactions mmt
             WHERE (mmt.project_id = p_project_id
                   AND mmt.organization_id = p_org_id
                )
             OR (mmt.to_project_id = p_project_id
                 AND mmt.transfer_organization_id = p_org_id
                 )
             OR (mmt.source_project_id = p_project_id
                 AND mmt.organization_id = p_org_id
                 )
         ) OR
         EXISTS (
             SELECT 1
             FROM mrp_forecast_dates frct
             WHERE frct.project_id = p_project_id
             AND   frct.organization_id = p_org_id
         ) OR
         EXISTS (
             SELECT 1
             FROM mrp_schedule_dates schd
             WHERE schd.project_id = p_project_id
             AND   schd.organization_id = p_org_id
         ) OR
         EXISTS (
             SELECT 1
             FROM po_distributions_all dist
             WHERE dist.project_id = p_project_id
             AND   dist.destination_organization_id = p_org_id
            ) OR
         EXISTS (
             SELECT 1
             FROM po_req_distributions_all rdist
             ,    po_requisition_lines_all rline
             WHERE rdist.project_id = p_project_id
             AND   rline.requisition_line_id = rdist.requisition_line_id
             AND   rline.destination_organization_id = p_org_id
         );
   ELSE
      retcode := -1;
   END IF;

   return(retcode);

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN(0);
 WHEN others THEN
   RAISE;

 END CheckUse_ProjOrg;

END PJM_PROJTASK_DELETION;

/
