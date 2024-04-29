--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_WIP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_WIP_PVT" AS
-- $Header: JMFVSKWB.pls 120.12.12010000.3 2010/03/17 13:34:54 abhissri ship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFVSKWB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   This package contains WIP related calls that the Interlock          |
--|   accesses when processing SHIKYU transactions                        |
--| HISTORY                                                               |
--|   05/09/2005 pseshadr Created                                         |
--|   12/14/2005 vchu     Modified Get_Component_Quantity to return       |
--|                       required_quantity from                          |
--|                       wip_requirement_operations instead of           |
--|                       wro.required_quantity - wro.quantity_issued     |
--|   03/27/2006 vchu     Fixed bug 5090721: Set last_update_date,        |
--|                       last_updated_by and last_update_login in the    |
--|                       update statements.                              |
--|   05/12/2006 vchu     Fixed bug 5199024: Modified Compute_Start_Date  |
--|                       to skip non working days to the previous        |
--|                       working day if the initial calculation for      |
--|                       x_start_date (need by date - intransit lead time|
--|                       - item lead time - number of off days between   |
--|                       the estimated start date and the need by date)  |
--|                       actually landed on a non working day.           |
--+=======================================================================+

G_PKG_NAME CONSTANT    VARCHAR2(30) := 'JMF_SHIKYU_WIP_PVT';
g_log_enabled          VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

--===================
-- PROCEDURES AND FUNCTIONS
--===================
--========================================================================
-- PROCEDURE : Compute_Start_Date    PUBLIC
-- PARAMETERS:
--             p_need_by_Date      Need By Date
--             p_item_id           Item
--             p_organization      Organization
--             p_quantity          Quantity
-- COMMENT   : This procedure computes the planned start date for the WIP job
--             based on the need_by_date
--========================================================================
PROCEDURE Compute_Start_Date
( p_need_by_date             IN   DATE
, p_item_id                  IN   NUMBER
, p_oem_organization         IN   NUMBER
, p_tp_organization          IN   NUMBER
, p_quantity                 IN   NUMBER
, x_start_date               OUT NOCOPY  DATE
)
IS
  l_fixed_time   NUMBER;
  l_var_time     NUMBER;
  l_intransit_time NUMBER;
  l_program      CONSTANT VARCHAR2(30) := 'Compute_Start_Date';
  l_start_date   DATE;
  l_off_days     NUMBER;
  l_ct_off_days  NUMBER;
  l_cal_date     DATE;

  l_seq_num      NUMBER;
  l_prior_date   DATE;

  CURSOR c_interorg IS
  SELECT NVL(intransit_time,0)
  FROM   mtl_interorg_ship_methods
  WHERE  from_organization_id = p_tp_organization
  AND    to_organization_id   = p_oem_organization
  AND    default_flag         =1;

BEGIN

  IF g_log_enabled = 'Y' AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || G_PKG_NAME || '.' || l_program || ': Start'
                  );
  END IF;

  IF g_log_enabled = 'Y' AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> ' || l_program || ': p_oem_organization = '
                    || p_oem_organization
                    || ', p_tp_organization = ' || p_tp_organization
                    || ', p_item_id = ' || p_item_id
                  );
  END IF;

  SELECT fixed_lead_time
       , variable_lead_time
  INTO
    l_fixed_time
  , l_var_time
  FROM mtl_system_items_b
  WHERE inventory_item_id = p_item_id
  AND   organization_id   = p_tp_organization;

  OPEN c_interorg;
  FETCH c_interorg
  INTO  l_intransit_time;
  IF c_interorg%NOTFOUND
  THEN
    l_intransit_time :=0;
  END IF;
  CLOSE c_interorg;

  l_start_date := p_need_by_date - l_intransit_time
                  - ROUND(NVL(l_fixed_time,0) + (p_quantity*NVL(l_var_time,0)));

  IF g_log_enabled = 'Y' AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> '||l_program||': l_start_date (before considering off days) = '
                    || TO_CHAR(l_start_date, 'YYYY-MON-DD HH24:MI:SS')
                  );
  END IF;

  -- To consider the workday calendars when computing WIP start dates
  -- since on/off days should be considered.

    SELECT count(1)
    INTO   l_off_days
    FROM   bom_calendar_dates bcd
       ,   mtl_parameters  mp
    WHERE  bcd.calendar_code = mp.calendar_code
    AND    mp.organization_id = p_tp_organization
    AND    bcd.calendar_date  BETWEEN TRUNC(l_start_date) AND TRUNC(p_need_by_date)
    AND    seq_num IS NULL;

  IF g_log_enabled = 'Y' AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> '||l_program||': l_off_days = '|| l_off_days
                  );
  END IF;

  l_start_date :=  p_need_by_date - l_off_days - l_intransit_time
                  - ROUND(NVL(l_fixed_time,0) + (p_quantity*NVL(l_var_time,0)));

  IF g_log_enabled = 'Y' AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> '||l_program||': l_start_date = '
                    || TO_CHAR(l_start_date, 'YYYY-MON-DD HH24:MI:SS')
                  );
  END IF;

  SELECT bcd.seq_num,
         bcd.prior_date
  INTO   l_seq_num,
         l_prior_date
  FROM   bom_calendar_dates bcd,
         mtl_parameters mp
  WHERE  bcd.calendar_code = mp.calendar_code
  AND    mp.organization_id = p_tp_organization
  AND    TRUNC(bcd.calendar_date) = TRUNC(l_start_date);

  IF g_log_enabled = 'Y' AND
     (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> '||l_program||': From bom_calendar_dates: l_seq_num = '|| NVL(TO_CHAR(l_seq_num), 'NULL')
                    || ', l_prior_date = ' || l_prior_date
                  );
  END IF;

  -- l_start_date is an off date if its seq_num is NULL
  IF l_seq_num IS NULL
    THEN

    l_start_date := l_prior_date;

  END IF;

  -- May need to skip off days if sysdate happens to be an off day?
  IF l_start_date < sysdate
  THEN
    l_start_date := sysdate;
  END IF;

  x_start_date := l_start_date;

 IF g_log_enabled = 'Y' THEN
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
 THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> '||l_program||'Planned Date is '||x_start_date
                  );
 END IF;
 END IF;

END Compute_Start_Date;


--========================================================================
-- PROCEDURE : Compute_End_Date    PUBLIC
-- PARAMETERS:
--             p_need_by_Date      Need By Date
--             p_item_id           Item
--             p_organization      Organization
--             p_quantity          Quantity
-- COMMENT   : This procedure computes the planned completion date for the WIP job
--             based on the need_by_date
--========================================================================
PROCEDURE Compute_End_Date
( p_start_date               IN   DATE
, p_item_id                  IN   NUMBER
, p_oem_organization         IN   NUMBER
, p_tp_organization          IN   NUMBER
, p_quantity                 IN   NUMBER
, x_end_date                 OUT NOCOPY  DATE
)
IS
  l_fixed_time   NUMBER;
  l_var_time     NUMBER;
  l_intransit_time NUMBER;
  l_program           CONSTANT VARCHAR2(30) := 'Compute_End_Date';

  CURSOR c_interorg IS
  SELECT NVL(intransit_time,0)
  FROM   mtl_interorg_ship_methods
  WHERE  from_organization_id = p_tp_organization
  AND    to_organization_id   = p_oem_organization
  AND    default_flag         =1;

BEGIN
  SELECT fixed_lead_time
       , variable_lead_time
  INTO
    l_fixed_time
  , l_var_time
  FROM mtl_system_items_b
  WHERE inventory_item_id = p_item_id
  AND   organization_id   = p_tp_organization;

  OPEN c_interorg;
  FETCH c_interorg
  INTO  l_intransit_time;
  IF c_interorg%NOTFOUND
  THEN
    l_intransit_time :=0;
  END IF;
  CLOSE c_interorg;

  x_end_date := p_start_date
                  + (ROUND(NVL(l_fixed_time,0) + (p_quantity*NVL(l_var_time,0))));
  IF x_end_date < sysdate
  THEN
    x_end_date := sysdate;
  END IF;

  IF g_log_enabled = 'Y' THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , '>> '||l_program||'Planned end Date is '||x_end_date
                  );
  END IF;
  END IF;

END Compute_End_Date;

--========================================================================
-- PROCEDURE : Process_WIP_Job       PUBLIC
-- PARAMETERS: p_action              Action
--                                   'C'- Create new job
--                                   'D'- Delete Job
--                                   'U'- Update Job
--                                   'R'- Assembly Return
--            x_return_status         Return Status
-- COMMENT   : This procedure populates data in the interface table
--             to process the WIP job. The WIP load procedure is invoked
--             which creates the WIP job.
--========================================================================
PROCEDURE Process_WIP_Job
( p_action                 IN  VARCHAR2
, p_subcontract_po_shipment_id IN  NUMBER
, p_need_by_date           IN  DATE
, p_quantity               IN  NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
)
IS
  l_project_id      NUMBER;
  l_task_id         NUMBER;
  l_quantity        NUMBER;
  l_start_date      DATE;
  l_end_Date        DATE;
  l_load_type       NUMBER;
  l_group_id        NUMBER;
  l_wip_entity_id   NUMBER;
  l_return_status   VARCHAR2(1);
  l_error           VARCHAR2(2000);
  l_subcontract_orders_rec JMF_SUBCONTRACT_ORDERS%ROWTYPE;
  l_need_by_date    DATE;
  l_component_id    NUMBER;
  l_total_qty       NUMBER;
  l_issued_qty      NUMBER;
  l_interface_id    NUMBER;
  l_orig_start_date DATE;


 CURSOR c_rec IS
   SELECT *
   FROM   jmf_subcontract_orders
   WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id;

 CURSOR c_comp_rec IS
   SELECT  shikyu_component_id
        ,  quantity
   FROM   jmf_shikyu_components
   WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id;
BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: Into process_wip_job package'
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: p_subcontract_po_shipment_id => ' ||
                          p_subcontract_po_shipment_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: p_action => ' ||
                         p_action
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: p_need_by_date => '||
                          p_need_by_date
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: p_quantity => '||
                          p_quantity
                  );
  END IF;


  OPEN c_rec;
  FETCH c_rec INTO l_subcontract_orders_rec;
  CLOSE c_rec;

  l_quantity := p_quantity;

  --Debugging for bug 9315131
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: wip_entity_id => ' ||
                          l_subcontract_orders_rec.wip_entity_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: p_subcontract_po_shipment_id => ' ||
                          l_subcontract_orders_rec.subcontract_po_shipment_id
                  );
  END IF;

  IF p_action IN ('U','C')
  THEN
  Compute_Start_Date
  ( p_need_by_date       => p_need_by_date
  , p_item_id            => l_subcontract_orders_rec.osa_item_id
  , p_oem_organization   => l_subcontract_orders_rec.oem_organization_id
  , p_tp_organization    => l_subcontract_orders_rec.tp_organization_id
  , p_quantity           => l_quantity
  , x_start_date         => l_start_date
  );

  Compute_End_Date
  ( p_start_date         => l_start_date
  , p_item_id            => l_subcontract_orders_rec.osa_item_id
  , p_oem_organization   => l_subcontract_orders_rec.oem_organization_id
  , p_tp_organization    => l_subcontract_orders_rec.tp_organization_id
  , p_quantity           => l_quantity
  , x_end_date           => l_end_date
  );

  ELSE
    l_start_date := p_need_by_date;

  END IF;

  --Debugging for bug 9315131
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: l_start_date => ' ||
                          l_start_date
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: l_end_date => ' ||
                          l_end_date
                  );
  END IF;

  SELECT wip_job_schedule_interface_s.nextval
  INTO   l_group_id
  FROM   DUAL;

  SELECT wip_interface_s.nextval
  INTO   l_interface_id
  FROM   DUAL;

  --Debugging for bug 9315131
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: l_group_id => ' ||
                          l_group_id
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'JMFVSKWB: l_interface_id => ' ||
                          l_interface_id
                  );
  END IF;

  IF p_action IN ('U','D') AND
     l_subcontract_orders_rec.wip_entity_id IS NOT NULL
  THEN
    SELECT scheduled_start_date
    INTO   l_orig_start_date
    FROM   wip_discrete_jobs
    WHERE  wip_entity_id = l_subcontract_orders_rec.wip_entity_id;
  END IF;

  --Debugging for bug 9315131
  IF g_log_enabled = 'Y' THEN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'Start date passed to WIP is '||l_start_date
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'End date passed to WIP is '||l_end_date
                  );
     FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_PKG_NAME
                  , 'l_orig_start_date '||l_orig_start_date
                  );
  END IF;
  END IF;

  INSERT INTO
  WIP_JOB_SCHEDULE_INTERFACE
  ( bom_revision_date
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , created_by_name
  , last_updated_by_name
  , last_update_login
  , wip_entity_id
  , firm_planned_flag
  , first_unit_start_date
  , group_id
  , job_name
  , load_type
  , organization_id
  , primary_item_id
  , process_phase
  , process_status
  , source_code
  , start_quantity
  , status_type
  , project_id
  , task_id
  , allow_explosion
  --, last_unit_completion_date
  , net_quantity
  , header_id
  , interface_id
  , scheduling_method
  )
  VALUES
  ( DECODE(p_action,'U',to_date(null),'D',to_date(null),l_start_date) -- Bug 9244436. Used to_date for proper conversion
  , sysdate
  , FND_GLOBAL.USER_ID
  , sysdate
  , FND_GLOBAL.USER_ID
  , FND_GLOBAL.USER_NAME
  , FND_GLOBAL.USER_NAME
  , FND_GLOBAL.USER_ID
  , DECODE(p_action,'U',l_subcontract_orders_rec.wip_entity_id,
                    'D',l_subcontract_orders_rec.wip_entity_id,null)
  , 1
  , DECODE(p_action,'C',l_start_date,l_orig_start_date)
  , l_group_id
  , l_group_id||l_subcontract_orders_rec.subcontract_po_shipment_id
  , DECODE(p_action,'C',1,3)
  , l_subcontract_orders_rec.tp_organization_id
  , l_subcontract_orders_rec.osa_item_id
  , 2
  , 1
  , 'INV'
  , DECODE(p_action,'C',l_quantity,null)
  , DECODE(p_action,'D',7,'U',1,3)
  , l_subcontract_orders_rec.project_id
  , l_subcontract_orders_rec.task_id
  , 'Y'
--  , DECODE(p_action,'C',l_end_date,null)
  , DECODE(p_action,'C',l_quantity,null)
  , l_group_id
  , DECODE(p_action,'C',l_interface_id,null)
  , 1
  );

  IF p_action = 'C'
  THEN
    WIP_MASSLOAD_PUB.CreateOneJob
   ( p_interfaceID    => l_interface_id
   , p_validationLevel=> 0
   , x_wipEntityID    => l_wip_entity_id
   , x_returnStatus   => l_return_status
   , x_errorMsg       => l_error
   );

   IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
      AND l_wip_entity_id IS NOT NULL
   THEN
    -- Update JMF table with the wip job # if successful.
     UPDATE jmf_subcontract_orders
     SET    wip_entity_id = l_wip_entity_id
          , last_update_date = sysdate
          , last_updated_by = FND_GLOBAL.user_id
          , last_update_login = FND_GLOBAL.login_id
     WHERE  subcontract_po_shipment_id =
            l_subcontract_orders_rec.subcontract_po_shipment_id;

     --Debugging for bug 9315131
     IF g_log_enabled = 'Y' THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			, G_PKG_NAME
			, 'Updated jso for shipment_id =  '|| l_subcontract_orders_rec.subcontract_po_shipment_id
			||', wip_entity_id = ' || l_wip_entity_id
		      );
      END IF;
     END IF;

   ELSE
     --Debugging for bug 9315131
     IF g_log_enabled = 'Y' THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			, G_PKG_NAME
			, 'Error from Mass Load: wip_entity_id = ' || l_wip_entity_id
		      );
      END IF;
     END IF;

     FND_MESSAGE.set_name('JMF', 'JMF_SHK_WIP_CREATION_ERR');
     FND_MSG_PUB.add;
   END IF;
  ELSE
   --Update WIP job
    WIP_MASSLOAD_PUB.MassLoadJobs
    ( p_groupid         => l_group_id
    , p_validationlevel => 0
    , p_commitflag      => 0
    , x_returnStatus    => l_return_status
    , x_errorMsg        => l_error
    );
  END IF;

  IF p_action IN ('U')
  THEN

    SELECT wip_job_schedule_interface_s.nextval
    INTO   l_group_id
    FROM   DUAL;

    --Debugging for bug 9315131
     IF g_log_enabled = 'Y' THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			, G_PKG_NAME
			, 'Came inside p_status U: group_id = ' || l_group_id
		      );
      END IF;
     END IF;

    INSERT INTO
    WIP_JOB_SCHEDULE_INTERFACE
    ( bom_revision_date
    , last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , created_by_name
    , last_updated_by_name
    , last_update_login
    , wip_entity_id
    , firm_planned_flag
    , first_unit_start_date
    , group_id
    , job_name
    , load_type
    , organization_id
    , primary_item_id
    , process_phase
    , process_status
    , source_code
    , start_quantity
    , status_type
    , project_id
    , task_id
    , allow_explosion
    , last_unit_completion_date
    , net_quantity
    , header_id
    , interface_id
    , scheduling_method
    )
    VALUES
    ( l_start_date
    , sysdate
    , FND_GLOBAL.USER_ID
    , sysdate
    , FND_GLOBAL.USER_ID
    , FND_GLOBAL.USER_NAME
    , FND_GLOBAL.USER_NAME
    , FND_GLOBAL.USER_ID
    , l_subcontract_orders_rec.wip_entity_id
    , 1
    , l_start_date
    , l_group_id
    , l_group_id||l_subcontract_orders_rec.subcontract_po_shipment_id
    , 3
    , l_subcontract_orders_rec.tp_organization_id
    , l_subcontract_orders_rec.osa_item_id
    , 2
    , 1
    , 'INV'
    , l_quantity
    , 3
    , l_subcontract_orders_rec.project_id
    , l_subcontract_orders_rec.task_id
    , 'Y'
    , l_end_date
    , l_quantity
    , l_group_id
    , null
    , 1
    );

    WIP_MASSLOAD_PUB.MassLoadJobs
    ( p_groupid         => l_group_id
    , p_validationlevel => 0
    , p_commitflag      => 0
    , x_returnStatus    => l_return_status
    , x_errorMsg        => l_error
    );

    --Debugging for bug 9315131
     IF g_log_enabled = 'Y' THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			, G_PKG_NAME
			, 'Came inside p_status U: l_return_status = ' || l_return_status
			||': l_error = ' || l_error
		      );
      END IF;
     END IF;

  END IF;

  x_return_status := l_return_status;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.set_name('JMF', 'JMF_SHK_WIP_CREATION_ERR');
  FND_MSG_PUB.add;

END Process_WIP_Job;


--========================================================================
-- FUNCTION : Get_Component_Quantity    PUBLIC
-- PARAMETERS:
--             p_item_id           Item
--             p_subcontract_po_shipment_id  Shipment Id
--             p_organization_id   Organization
-- COMMENT   : This procedure computes the quantity of the component
--             as defined in the BOM in primary UOM
--========================================================================
FUNCTION Get_Component_Quantity
( p_item_id                  IN   NUMBER
, p_organization_id          IN   NUMBER
, p_subcontract_po_shipment_id IN NUMBER
) RETURN NUMBER
IS
  l_quantity  NUMBER;
BEGIN

  IF p_subcontract_po_shipment_id IS NULL
  THEN
    SELECT bc.component_quantity
    INTO   l_quantity
    FROM   bom_bill_of_materials bom
       ,   bom_components_b bc
    WHERE  bom.bill_sequence_id = bc.bill_sequence_id
    AND    bc.operation_seq_num =1
    AND    bc.component_item_id = p_item_id
    AND    bom.organization_id = p_organization_id
    AND    sysdate BETWEEN (bc.effectivity_date)
                   AND (NVL(bc.disable_date,sysdate+1));
  ELSE
    SELECT wro.required_quantity
    INTO   l_quantity
    FROM   wip_requirement_operations wro
       ,   jmf_subcontract_orders jso
    WHERE  wro.wip_entity_id = jso.wip_entity_id
    AND    wro.inventory_item_id = p_item_id
    AND    wro.organization_id = jso.tp_organization_id
    AND    wro.organization_id  = p_organization_id
    AND    jso.subcontract_po_shipment_id = p_subcontract_po_shipment_id;

  END IF;

  --Debugging for bug 9315131
  IF g_log_enabled = 'Y' THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
	FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
			, G_PKG_NAME
			, 'Get_Component_Quantity: l_quantity = ' || l_quantity
		      );
    END IF;
  END IF;

RETURN l_quantity;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN 0;

END Get_Component_Quantity;

END JMF_SHIKYU_WIP_PVT;

/
