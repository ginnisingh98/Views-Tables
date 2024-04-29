--------------------------------------------------------
--  DDL for Package Body GMP_RESOURCE_DTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_RESOURCE_DTL_PUB" AS
/* $Header: GMPRSDTB.pls 120.6.12010000.3 2010/02/24 13:30:17 vpedarla ship $ */

/* =================================================================== */
/* Procedure:                                                          */
/*   insert_resource_dtl                                               */
/*                                                                     */
/* DESCRIPTION:                                                        */
/*                                                                     */
/* API returns (x_return_code) = 'S' if the insert into resources      */
/* header  (cr_rsrc_mst ) table is successfully.                       */
/*                                                                     */
/* History :                                                           */
/* Sridhar 09-SEP-2002  Initial implementation                         */
/* =================================================================== */
 PROCEDURE insert_resource_dtl
  ( p_api_version            IN   NUMBER                :=  1
  , p_init_msg_list          IN   BOOLEAN               :=  TRUE
  , p_commit                 IN   BOOLEAN               :=  FALSE
  , p_resources              IN   cr_rsrc_dtl%ROWTYPE
  , p_rsrc_instances         IN   resource_instances_tbl
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          IN OUT  NOCOPY VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name         CONSTANT VARCHAR2(30) := 'INSERT_RESOURCE_DTL';
  l_row_id           ROWID;
  v_resource_id      number ;
  v_instance_id      number ;
  l_return_status    VARCHAR2(1);
  g_return_status    VARCHAR2(1);
  v_std_usage_uom    VARCHAR2(4);
  v_capacity_uom     VARCHAR2(4);
  v_min_capacity     NUMBER;
  v_max_capacity     NUMBER;
  l_resources_rec    cr_rsrc_dtl%ROWTYPE;
  l_rsrc_instances   resource_instances_tbl;

  /* Define Exceptions */
  resource_dtl_creation_failure   EXCEPTION;
  instance_creation_failure       EXCEPTION;
  resource_required               EXCEPTION;
  resource_id_required            EXCEPTION;
  instance_id_required            EXCEPTION;
  invalid_version                 EXCEPTION;

  CURSOR Cur_resource_id IS
  SELECT BOM_RESOURCES_S.nextval
  FROM sys.dual;

  CURSOR Cur_instance_id IS
  SELECT GMP_RESOURCE_INSTANCES_S.nextval
  FROM  sys.DUAL;

  /* B4724360 Rajesh Patangya INVCONV */
  CURSOR Cur_uom IS
  SELECT STD_USAGE_UOM,CAPACITY_UM,MIN_CAPACITY,MAX_CAPACITY
  FROM   cr_rsrc_mst
  WHERE  resources = l_resources_rec.resources
  AND    delete_mark = 0;

 BEGIN

  v_resource_id           := NULL ;
  v_instance_id           := NULL ;
  l_return_status         := FND_API.G_RET_STS_SUCCESS;
  g_return_status         := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT create_resource_dtl;

      fnd_file.put_line(fnd_file.log,'CreateResourceDtlPub');

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    l_resources_rec  := p_resources;
    l_rsrc_instances := p_rsrc_instances;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_RESOURCE_DTL_PUB.m_api_version
                                        ,p_api_version
                                        ,'INSERT_RESOURCE_DTL'
                                        ,GMP_RESOURCE_DTL_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* B4724360 Rajesh Patangya INVCONV */
    IF (l_resources_rec.resources IS NOT NULL) AND
         (l_resources_rec.organization_id IS NOT NULL) THEN
       /* Validation 1.  Check if this resources that is created does
          not exists in the database. */
       check_data(
                    l_resources_rec.organization_id,
                    l_resources_rec.resources,
                    l_resources_rec.resource_id, -- INVCONV - included resource id
                    l_resources_rec.group_resource,
                    l_resources_rec.assigned_qty,
                    l_resources_rec.daily_avail_use,
                    l_resources_rec.usage_uom, /* B4724360 - INVCONV */
                    l_resources_rec.nominal_cost,
                    l_resources_rec.inactive_ind,
                    l_resources_rec.ideal_capacity,
                    l_resources_rec.min_capacity,
                    l_resources_rec.max_capacity,
                    l_resources_rec.capacity_um,  /* B4724360 - INVCONV */
                    l_resources_rec.capacity_constraint,
                    l_resources_rec.capacity_tolerance,
                    l_resources_rec.schedule_ind,
                    l_resources_rec.utilization,
                    l_resources_rec.efficiency,
                    l_resources_rec.calendar_code,  /* B4724360 - INVCONV */
                    nvl(l_resources_rec.batchable_flag,0),  /* BUG 4157063 */
                    l_resources_rec.batch_window,      /* BUG 4157063 */
                    x_message_count,
                    x_message_list,
                    l_return_status);

      /* After Validating the data , Insert the Resource Detail rows
         only if the Return Status is 'S' else,. error Out
      */

      IF l_return_status = 'E' THEN   /* resource return value */
         RAISE resource_dtl_creation_failure;
      ELSE    /* Insert the Resource Data now */

            OPEN Cur_resource_id;
            v_resource_id := NULL ;
            FETCH Cur_resource_id INTO v_resource_id;
            CLOSE Cur_resource_id;

            OPEN Cur_uom;
            FETCH Cur_uom INTO v_std_usage_uom,
                               v_capacity_uom,
                               v_min_capacity,
                               v_max_capacity;
            CLOSE Cur_uom;

            /* the following lines will allow the User to have his own
               values, instead if duplicating from the generic resource
               values if min,max values are entered
            */

            IF l_resources_rec.min_capacity is NOT NULL
            THEN
               v_min_capacity := l_resources_rec.min_capacity;
            END IF;

            IF l_resources_rec.max_capacity is NOT NULL
            THEN
               v_max_capacity := l_resources_rec.max_capacity;
            END IF;

            /* Making the Capacity Tolerance field NULL if
               Capacity Constraint field has value = 0
            */
            IF l_resources_rec.capacity_constraint = 0
            THEN
               l_resources_rec.capacity_tolerance := NULL;
            END IF;

             insert_detail_rows
                 (
                    l_resources_rec.organization_id, /* B4724360 - INVCONV */
                    l_resources_rec.resources,
                    l_resources_rec.group_resource,
                    l_resources_rec.assigned_qty,
                    l_resources_rec.daily_avail_use,
                    v_std_usage_uom,
                    l_resources_rec.nominal_cost,
                    l_resources_rec.inactive_ind,
                    sysdate,
                    FND_GLOBAL.user_id,                 /* Bug 6412180 */
                    sysdate,
                    FND_GLOBAL.user_id,                 /* Bug 6412180 */
                    FND_GLOBAL.user_id,                 /* Bug 6412180 */
                    l_resources_rec.trans_cnt,
                    0,
                    l_resources_rec.text_code,
                    l_resources_rec.ideal_capacity,
                    v_min_capacity,
                    v_max_capacity,
                    v_capacity_uom,
                    v_resource_id,
                    l_resources_rec.capacity_constraint,
                    l_resources_rec.capacity_tolerance,
                    l_resources_rec.schedule_ind,
                    l_resources_rec.utilization,
                    l_resources_rec.efficiency,
                    l_resources_rec.planning_exception_set,  /* Bug # 6413873 */
                    l_resources_rec.calendar_code,  /* B4724360 - INVCONV */
                    l_resources_rec.sds_window,
                    nvl(l_resources_rec.batchable_flag,0),  /* BUG 4157063 */
                    l_resources_rec.batch_window      /* BUG 4157063 */
                  );
           x_return_status := l_return_status;
  /* ------------------- Resource Instances starts ------------------- */
      IF ((l_resources_rec.schedule_ind = 2 ) AND
         (l_rsrc_instances.COUNT = l_resources_rec.assigned_qty))
      THEN
          FOR j IN 1..l_rsrc_instances.COUNT
          LOOP               /* Instance loop */
              IF l_rsrc_instances(j).eff_start_date IS NULL THEN
                 l_rsrc_instances(j).eff_start_date := SYSDATE ;
              END IF;

              OPEN Cur_instance_id;
                   v_instance_id := NULL ;
              FETCH Cur_instance_id INTO v_instance_id;
              CLOSE Cur_instance_id;

              check_instance_data (
                                    v_resource_id
                                   ,v_instance_id
                                   ,l_rsrc_instances(j).vendor_id
                                   ,l_rsrc_instances(j).eff_start_date
                                   ,l_rsrc_instances(j).eff_end_date
                                   ,l_rsrc_instances(j).maintenance_interval
                                   ,l_rsrc_instances(j).inactive_ind
                                   ,l_rsrc_instances(j).calibration_frequency
                                   ,l_rsrc_instances(j).calibration_item_id
                                   ,x_message_count
                                   ,x_message_list
                                   ,g_return_status    );

              x_return_status := g_return_status;

              IF g_return_status = 'E' THEN     /* Instance return status  */
                 RAISE instance_creation_failure;
              ELSE                        /* Insert the Resource Instance row */

                  insert_resource_instance
                  (
                    v_resource_id
                   ,v_instance_id
                   ,j    /* p_instance_number */
                   ,l_rsrc_instances(j).vendor_id
                   ,l_rsrc_instances(j).model_number
                   ,l_rsrc_instances(j).serial_number
                   ,l_rsrc_instances(j).tracking_number
                   ,l_rsrc_instances(j).eff_start_date
                   ,l_rsrc_instances(j).eff_end_date
                   ,l_rsrc_instances(j).last_maintenance_date
                   ,l_rsrc_instances(j).maintenance_interval
                   ,l_rsrc_instances(j).inactive_ind
                   ,l_rsrc_instances(j).calibration_frequency
                   ,l_rsrc_instances(j).calibration_period
                   ,l_rsrc_instances(j).calibration_item_id
                   ,l_rsrc_instances(j).last_calibration_date
                   ,l_rsrc_instances(j).next_calibration_date
                   ,l_rsrc_instances(j).last_certification_date
                   ,l_rsrc_instances(j).certified_by
                   ,sysdate
                   ,FND_GLOBAL.user_id                 /* Bug 6412180 */
                   ,sysdate
                   ,FND_GLOBAL.user_id                 /* Bug 6412180 */
                   ,FND_GLOBAL.user_id                 /* Bug 6412180 */
                  ) ;
              END IF;    /* Instance return status  */
           END LOOP ;    /* Instance loop */
        END IF;          /* Insert Resource Instance only if Schedule Ind = 2 */
  /* ------------------- Resource Instances ends ------------------- */

      END IF;  /* resource return value */
    ELSE
       RAISE resource_id_required;
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
    END IF; /* p_resources.resource_id IS NOT NULL */

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
     --  x_return_status := 'S' ;
       fnd_file.put_line(fnd_file.log,'Resource Detail was created successfully');
    END IF;

   fnd_file.put_line(fnd_file.log,'Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
 EXCEPTION
    WHEN resource_dtl_creation_failure OR invalid_version
         OR instance_creation_failure THEN

         ROLLBACK TO SAVEPOINT create_resource_dtl;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN resource_id_required THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA','SY_REQUIRED');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN instance_id_required THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA','SY_REQUIRED');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_resource_dtl;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
 END insert_resource_dtl;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   check_data                                                    */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* The following Procedure checks the Record and then Inserts      */
  /* the row into cr_rsrc_mst table and Returns S code if inserted   */
  /* Successfully                                                    */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/10/2002   Initial implementation                     */
  /* Rajesh  11/28/2007   BUG 4157063 Resource batching              */
  /* =============================================================== */
 PROCEDURE  check_data
  (
    p_organization_id      IN   NUMBER, /* B4724360 - INVCONV */
    p_resources            IN   VARCHAR2,
    p_resource_id          IN   NUMBER, /* B4724360 - INVCONV */
    p_group_resource       IN   VARCHAR2,
    p_assigned_qty         IN   integer,
    p_daily_avl_use        IN   NUMBER,
    p_usage_um             IN   VARCHAR2,
    p_nominal_cost         IN   NUMBER,
    p_inactive_ind         IN   NUMBER,
    p_ideal_capacity       IN   NUMBER,
    p_min_capacity         IN   NUMBER,
    p_max_capacity         IN   NUMBER,
    p_capacity_uom         IN   VARCHAR2,
    p_capacity_constraint  IN   NUMBER,
    p_capacity_tolerance   IN   NUMBER,
    p_schedule_ind         IN   NUMBER,
    p_utilization          IN   NUMBER,
    p_efficiency           IN   NUMBER,
    p_calendar_code        IN   VARCHAR2, /* B4724360 - INVCONV */
    p_batchable_flag       IN   NUMBER,   /* BUG 4157063 */
    p_batch_window         IN   NUMBER,   /* BUG 4157063 */
    x_message_count        OUT  NOCOPY NUMBER,
    x_message_list         OUT  NOCOPY VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2
 ) IS


   /* B4724360 Rajesh Patangya -Changed the source for organizations*/
   CURSOR Cur_orgn_code IS
   SELECT COUNT(1)
   FROM   mtl_parameters
   where  organization_id = p_organization_id
   and    process_enabled_flag = 'Y';

   CURSOR Cur_resources IS
   SELECT COUNT(1)
   FROM   cr_rsrc_mst
   where  resources = p_resources
   and    delete_mark = 0;

   /* B4724360 Rajesh Patangya changed the where clause include org+id and resource_id*/
   CURSOR Cur_check_dup IS
   SELECT COUNT(1)
   FROM   cr_rsrc_dtl
   WHERE  organization_id = p_organization_id
   AND resource_id = p_resource_id;

   /* B4724360 - INVCONV */
   CURSOR Cur_usage_um IS
   SELECT COUNT(1)
   FROM   mtl_units_of_measure
   WHERE  uom_code = p_usage_um;

    /* B4724360 - INVCONV - changed the source of uom*/
   CURSOR Cur_capacity_uom IS
   SELECT COUNT(1)
   FROM   mtl_units_of_measure
   WHERE  uom_code = p_capacity_uom;

   CURSOR Cur_calendar_code IS
   SELECT COUNT(1)
   FROM   bom_calendars
   WHERE  calendar_code = p_calendar_code;

   l_return_val  varchar2(16);
   X_count       number;
   l_count1      number;
   l_count2      number;
   l_count3      number;
   l_count4      number;
   l_count5      number;
   x_temp        number;
   X_field       varchar2(2000);
   X_value       varchar2(2000);
   X_msg         varchar2(2000);

   INVALID_ORGN_CODE         EXCEPTION;
   CR_POSITIVE               EXCEPTION;
   INVALID_USAGE_UM          EXCEPTION;
   INVALID_CAPACITY_UOM      EXCEPTION;
   INVALID_UOM_TYPE          EXCEPTION;
   QC_MIN_MAX_SPEC           EXCEPTION;
   CAPACITY_NOT_IN_RANGE     EXCEPTION;
   INVALID_VALUE             EXCEPTION;
   BAD_RESOURCE              EXCEPTION;
   DUPLICATE_RECORD          EXCEPTION;
   RESOURCE_REQUIRED         EXCEPTION;
   MIN_MAX_CAPACITY_REQUIRED EXCEPTION;
   ASSIGNED_QTY_REQUIRED     EXCEPTION;

 BEGIN

   X_count       := 0;
   l_count1      := 0;
   l_count2      := 0;
   l_count3      := 0;
   l_count4      := 0;
   l_count5      := 0;

   X_field      := '';
   X_value      := '';
   X_msg        := '';

        /* Validate Orgn_code and the Resources if they already exist */

          x_return_status := 'S' ;
             OPEN  Cur_orgn_code;
             FETCH Cur_orgn_code INTO X_count;
             CLOSE Cur_orgn_code;
             IF (X_count = 0) THEN
                x_return_status := 'E';
                RAISE INVALID_ORGN_CODE;
             END IF;

          IF (p_resources IS NOT NULL) THEN
             OPEN Cur_resources;
             FETCH Cur_resources INTO l_count1;
             CLOSE Cur_resources;
             IF l_count1 = 0  then
                x_return_status := 'E';
                RAISE BAD_RESOURCE;
             END IF;
          END IF;

          IF p_resources IS NULL
          THEN
             x_return_status := 'E';
             X_msg := 'Resources';
             RAISE RESOURCE_REQUIRED;
          ELSE
            IF v_update_flag <> 'Y'  THEN
               OPEN Cur_check_dup;
               FETCH Cur_check_dup INTO l_count2;
               CLOSE Cur_check_dup;
               IF (l_count2 >0) THEN
                   x_return_status := 'E';
                   RAISE DUPLICATE_RECORD;
               END IF;
            END IF;
          END IF;


        /* Validate Assigned Qty */
           IF p_assigned_qty <= 0 THEN
             x_return_status := 'E';
             X_field := 'Assigned Qty';
             X_value := p_assigned_qty;
             RAISE INVALID_VALUE;
           END IF;

         IF (p_schedule_ind = 2) AND (v_update_flag = 'Y')  THEN
                NULL;
         ELSIF p_assigned_qty IS NULL THEN
                x_return_status := 'E';
                X_msg := 'Assigned Qty';
                RAISE ASSIGNED_QTY_REQUIRED;
         END IF;

        /* Validate Daily Avail Use */
          IF p_daily_avl_use < 0 THEN
             x_return_status := 'E';
             RAISE CR_POSITIVE;
          END IF;

        /* Check Usage_um  if they already exist */

        IF (p_usage_um is NOT NULL ) then
           x_return_status := 'S';
           OPEN Cur_usage_um;
           FETCH Cur_usage_um INTO l_count2;
           CLOSE Cur_usage_um;

           IF l_count2 = 0 then
             x_return_status := 'E';
             RAISE INVALID_USAGE_UM;
           END IF;
        END IF; /* End if for usage_um */

        /* Check Capacity UOM if they already exist */

        IF (p_capacity_uom is NOT NULL) then
           x_return_status := 'S';
           OPEN Cur_capacity_uom;
           FETCH Cur_capacity_uom INTO l_count3;
           CLOSE Cur_capacity_uom;

           IF l_count3 = 0 then
             x_return_status := 'E';
             RAISE INVALID_CAPACITY_UOM;
           END IF;
        END IF; /* End if for capacity_uom */


        IF p_nominal_cost < 0 THEN
           x_return_status := 'E';
           X_field := 'NominalCost';
           X_value := p_nominal_cost;
           RAISE INVALID_VALUE;
        END IF;

        IF p_inactive_ind NOT IN (0,1)
        THEN
           x_return_status := 'E';
           X_field := 'Inactive Indicator';
           X_value := p_inactive_ind;
           RAISE INVALID_VALUE;
        END IF;

       /* Check if Min Capacity is < 0 */

        IF (p_min_capacity < 0) THEN
           x_return_status := 'E';
           X_field := 'Minimum Capacity';
           X_value := p_min_capacity;
           RAISE INVALID_VALUE;
        END IF;

       /* Check if Min Capacity is greater than Max Capacity */
        IF (nvl(p_min_capacity,0) > nvl(p_max_capacity,999999.99)) THEN
           x_return_status := 'E';
           RAISE QC_MIN_MAX_SPEC;
        END IF;

        IF (p_max_capacity < 0) THEN
           x_return_status := 'E';
           X_field := 'Maximum Capacity';
           X_value := p_max_capacity;
           RAISE INVALID_VALUE;
        END IF;

       /* Check if Ideal Capacity falls in the range */
        IF (p_ideal_capacity > p_max_capacity) OR
           (p_ideal_capacity < p_min_capacity) THEN
           x_return_status := 'E';
           RAISE CAPACITY_NOT_IN_RANGE;
        END IF;

       /* Check if Capacity Constraint has valid values - 0 or 1 */
        IF p_capacity_constraint NOT IN (0,1)
        THEN
             x_return_status := 'E';
             X_field := 'Capacity Constraint';
             X_value := p_capacity_constraint;
             RAISE INVALID_VALUE;
        END IF ;

       /* Check if Capacity Constraint = 1,then
          Min,Max,Capacity Uom is required
       */
        IF (p_capacity_constraint = 1)
        THEN
           IF (p_min_capacity is NULL) OR
              (p_max_capacity is NULL) OR (p_capacity_uom is NULL)
           THEN
             x_return_status := 'E';
             X_msg := 'Min/Max/Capacity Uom';
             RAISE MIN_MAX_CAPACITY_REQUIRED;
           END IF ;
        END IF ;

       /* Check if Schedule Ind has Valid Values 0,1,2 */
       /* HALUTHRA Bug:7637373 DEC 12, Including schedule_ind = 3 in the IF condition so that resource with DO NOT PLAN type schedule indicator can be included */

        IF p_schedule_ind NOT IN (0,1,2,3)
        THEN
           x_return_status := 'E';
           X_field := 'Schedule Indicator';
           X_value := p_schedule_ind;
           RAISE INVALID_VALUE;
        END IF;

        /* B4724360 - INVCONV */
        IF (p_calendar_code IS NOT NULL) THEN
           OPEN Cur_calendar_code;
           FETCH Cur_calendar_code INTO l_count5;
           CLOSE Cur_calendar_code;
               IF (l_count5 = 0) THEN
                   x_return_status := 'E';
                   X_field := 'Calendar Code';
                   RAISE INVALID_VALUE;
               END IF;
        END IF;

       /* BUG 4157063 Check Resource batching */
        IF nvl(p_batchable_flag,0) NOT IN (0,1) THEN
           x_return_status := 'E';
           X_field := 'Batchable Flag';
           X_value := p_batchable_flag;
           RAISE INVALID_VALUE;
        ELSE
          IF nvl(p_batchable_flag,0) = 1 THEN
            IF (p_batch_window IS NULL) THEN
                   x_return_status := 'E';
                   X_field := 'Batch window';
                   RAISE INVALID_VALUE;
            END IF;
          ELSE
            IF (p_batch_window IS NOT NULL) THEN
                   x_return_status := 'E';
                   X_field := 'Batch window';
                   RAISE INVALID_VALUE;
            END IF;
          END IF;
        END IF;

 EXCEPTION
    WHEN INVALID_VALUE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_INVALID_VALUE');
     FND_MESSAGE.SET_TOKEN('FIELD',X_field);
     FND_MESSAGE.SET_TOKEN('VALUE',X_value);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN INVALID_ORGN_CODE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMI','IC_ORGNCODERR');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN BAD_RESOURCE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','BAD_RESOURCE');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN CR_POSITIVE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','CR_POSITIVE');
     fnd_file.put_line(fnd_file.log,'Qty Entered is < 0');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN MIN_MAX_CAPACITY_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA','SY_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN ASSIGNED_QTY_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA','SY_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN INVALID_USAGE_UM THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA','SY_INVALID_UM_CODE');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN INVALID_CAPACITY_UOM THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA','SY_INVALID_UM_CODE');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN INVALID_UOM_TYPE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA','SY_INVALID_UM_CODE');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN CAPACITY_NOT_IN_RANGE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','CR_CAPACITY_NOT_IN_RANGE');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN QC_MIN_MAX_SPEC THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD','QC_MIN_MAX_SPEC');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN RESOURCE_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN DUPLICATE_RECORD THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP', 'PS_DUP_REC');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

 END check_data;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   insert_detail_rows                                            */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* The following Procedure checks the Record and then Inserts      */
  /* the row into cr_rsrc_dtl table and Returns S code if inserted   */
  /* Successfully                                                    */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/10/2002   Initial implementation                     */
  /* Kaushek B 13/09/07 B6413873 Added parameter                     */
  /* planning_exception_set and insert value of planning_exception_set*/
  /* =============================================================== */
PROCEDURE  insert_detail_rows
  (
     p_organization_id        IN  NUMBER, /* B4724360 - INVCONV */
     p_resources              IN  varchar2,
     p_group_resource         IN  VARCHAR2,
     p_assigned_qty           IN  NUMBER,
     p_daily_avail_use        IN  NUMBER,
     p_usage_um               IN  VARCHAR2,
     p_nominal_cost           IN  NUMBER,
     p_inactive_ind           IN  NUMBER,
     p_creation_date          IN  DATE,
     p_created_by             IN  NUMBER,
     p_last_update_date       IN  DATE,
     p_last_updated_by        IN  NUMBER,
     p_last_update_login      IN  NUMBER,
     p_trans_cnt              IN  NUMBER,
     p_delete_mark            IN  NUMBER,
     p_text_code              IN  NUMBER,
     p_ideal_capacity         IN  NUMBER,
     p_min_capacity           IN  NUMBER,
     p_max_capacity           IN  NUMBER,
     p_capacity_uom           IN  VARCHAR2,
     p_resource_id            IN  NUMBER,
     p_capacity_constraint    IN  NUMBER,
     p_capacity_tolerance     IN  NUMBER,
     p_schedule_ind           IN  NUMBER,
     p_utilization            IN  NUMBER,
     p_efficiency             IN  NUMBER,
     p_planning_exception_set IN  VARCHAR2, /* Bug # 6413873 */
     p_calendar_code          IN  VARCHAR2, /* B4724360 - INVCONV */
     p_sds_window             IN  NUMBER,   /* B7637373 - VPEDARLA */
     p_batchable_flag         IN  NUMBER,   /* BUG 4157063 */
     p_batch_window           IN  NUMBER   /* BUG 4157063 */
  ) IS

BEGIN

     INSERT INTO CR_RSRC_DTL(
	 ORGANIZATION_ID /* B4724360 - INVCONV */
	,RESOURCES
	,GROUP_RESOURCE
	,ASSIGNED_QTY
	,DAILY_AVAIL_USE
	,USAGE_UOM  /* B4724360 - INVCONV */
	,NOMINAL_COST
	,INACTIVE_IND
	,CREATION_DATE
	,CREATED_BY
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,TRANS_CNT
	,DELETE_MARK
	,TEXT_CODE
	,IDEAL_CAPACITY
	,MIN_CAPACITY
	,MAX_CAPACITY
	,CAPACITY_UM /* B4724360 - INVCONV */
	,RESOURCE_ID
	,CAPACITY_CONSTRAINT
	,CAPACITY_TOLERANCE
	,SCHEDULE_IND
	,UTILIZATION
	,EFFICIENCY
	,PLANNING_EXCEPTION_SET /* Bug # 6413873 */
	,CALENDAR_CODE  /* B4724360 - INVCONV */
        ,BATCHABLE_FLAG     /* BUG 4157063 */
        ,BATCH_WINDOW       /* BUG 4157063 */
        ,SDS_WINDOW     /* B7637373 - VPEDARLA */
	)
	values (
	p_organization_id , /* B4724360 - INVCONV */
	p_resources     ,
	nvl(p_group_resource,p_resources),
	p_assigned_qty   ,
	p_daily_avail_use,
	p_usage_um       ,
	p_nominal_cost   ,
	p_inactive_ind   ,
	p_creation_date  ,
	p_created_by     ,
	p_last_update_date    ,
	p_last_updated_by     ,
	p_last_update_login   ,
	p_trans_cnt           ,
	p_delete_mark         ,
	p_text_code           ,
	p_ideal_capacity      ,
	p_min_capacity        ,
	p_max_capacity        ,
	p_capacity_uom           ,
	p_resource_id         ,
	p_capacity_constraint ,
	p_capacity_tolerance  ,
	p_schedule_ind        ,
	p_utilization         ,
	p_efficiency          ,
	p_planning_exception_set, /* Bug # 6413873 */
	p_calendar_code  ,/* B4724360 - INVCONV */
        p_batchable_flag      , /* BUG 4157063 */
        p_batch_window      ,    /* BUG 4157063 */
        p_sds_window     /* B7637373 - VPEDARLA */
	);

END insert_detail_rows;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   insert_resource_instance                                      */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* The following Procedure checks the Record and then Inserts      */
  /* the row into cr_rsrc_dtl table and Returns S code if inserted   */
  /* Successfully                                                    */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/10/2002   Initial implementation                     */
  /* =============================================================== */
PROCEDURE  insert_resource_instance (
     p_resource_id                     IN NUMBER
    ,p_instance_id                     IN NUMBER
    ,p_instance_number                 IN NUMBER
    ,p_vendor_id                       IN NUMBER
    ,p_model_number                    IN VARCHAR2
    ,p_serial_number                   IN VARCHAR2
    ,p_tracking_number                 IN VARCHAR2
    ,p_eff_start_date                  IN DATE
    ,p_eff_end_date                    IN DATE
    ,p_last_maintenance_date           IN DATE
    ,p_maintenance_interval            IN NUMBER
    ,p_inactive_ind                    IN NUMBER
    ,p_calibration_frequency           IN NUMBER
    ,p_calibration_period              IN VARCHAR2
    ,p_calibration_item_id             IN NUMBER
    ,p_last_calibration_date           IN DATE
    ,p_next_calibration_date           IN DATE
    ,p_last_certification_date         IN DATE
    ,p_certified_by                    IN VARCHAR2
    ,p_creation_date                   IN DATE
    ,p_created_by                      IN NUMBER
    ,p_last_update_date                IN DATE
    ,p_last_updated_by                 IN NUMBER
    ,p_last_update_login               IN NUMBER ) IS

BEGIN

    INSERT INTO gmp_resource_instances
    (
     RESOURCE_ID
    ,INSTANCE_ID
    ,INSTANCE_NUMBER
    ,VENDOR_ID
    ,MODEL_NUMBER
    ,SERIAL_NUMBER
    ,TRACKING_NUMBER
    ,EFF_START_DATE
    ,EFF_END_DATE
    ,LAST_MAINTENANCE_DATE
    ,MAINTENANCE_INTERVAL
    ,INACTIVE_IND
    ,CALIBRATION_FREQUENCY
    ,CALIBRATION_PERIOD
    ,CALIBRATION_ITEM_ID
    ,LAST_CALIBRATION_DATE
    ,NEXT_CALIBRATION_DATE
    ,LAST_CERTIFICATION_DATE
    ,CERTIFIED_BY
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
     )
    values (
     p_resource_id
    ,p_instance_id
    ,p_instance_number
    ,p_vendor_id
    ,p_model_number
    ,p_serial_number
    ,p_tracking_number
    ,p_eff_start_date
    ,p_eff_end_date
    ,p_last_maintenance_date
    ,p_maintenance_interval
    ,p_inactive_ind
    ,p_calibration_frequency
    ,p_calibration_period
    ,p_calibration_item_id
    ,p_last_calibration_date
    ,p_next_calibration_date
    ,p_last_certification_date
    ,p_certified_by
    ,p_creation_date
    ,p_created_by
    ,p_last_update_date
    ,p_last_updated_by
    ,p_last_update_login
    ) ;

END insert_resource_instance ;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_resource_dtl                                           */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the update into Generic    */
  /* Resource Table                                                  */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/04/2002   Initial implementation                     */
  /* =============================================================== */
PROCEDURE update_resource_dtl
  ( p_api_version            IN   NUMBER               :=  1
  , p_init_msg_list          IN   BOOLEAN              :=  TRUE
  , p_commit                 IN   BOOLEAN              :=  FALSE
  , p_resources              IN   cr_rsrc_dtl%ROWTYPE
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          OUT  NOCOPY VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name         CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE_DTL';
  l_return_status    VARCHAR2(1) ;
  g_return_status    VARCHAR2(1) ;
  X_msg              varchar2(2000);

  /* Define Exceptions */
  resource_update_failure   EXCEPTION;
  invalid_version           EXCEPTION;
  RESOURCES_REQUIRED        EXCEPTION;
  RESOURCE_ID_REQUIRED      EXCEPTION;


BEGIN
  l_return_status    := FND_API.G_RET_STS_SUCCESS;
  g_return_status    := FND_API.G_RET_STS_SUCCESS;
  X_msg              := '';

    SAVEPOINT update_resource_dtl;
    fnd_file.put_line(fnd_file.log,'UpdateResourcePub');

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_RESOURCE_DTL_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMP_RESOURCE_DTL_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Set the Update Flag to Yes */
     v_update_flag := 'Y';

       IF (p_resources.resource_id IS NULL) THEN
         IF ((p_resources.resources IS NULL) AND
             (p_resources.organization_id IS NULL)) THEN
                  x_return_status := 'E';
                  X_msg := 'Resources and orgn_code OR Resource_id ';
                  RAISE resources_required;
         ELSE
                  x_return_status := 'S';
         END IF ;
       ELSE
                  x_return_status := 'S';
       END IF ;

            check_data(
                     p_resources.organization_id,  /* B4724360 - INVCONV */
                     p_resources.resources,
                     p_resources.resource_id, /* B4724360 - INVCONV */
                     p_resources.group_resource,
                     p_resources.assigned_qty,
                     p_resources.daily_avail_use,
                     p_resources.usage_uom,   /* B4724360 - INVCONV */
                     p_resources.nominal_cost,
                     p_resources.inactive_ind,
                     p_resources.ideal_capacity,
                     p_resources.min_capacity,
                     p_resources.max_capacity,
                     p_resources.capacity_um,    /* B4724360 - INVCONV */
                     p_resources.capacity_constraint,
                     p_resources.capacity_tolerance,
                     p_resources.schedule_ind,
                     p_resources.utilization,
                     p_resources.efficiency,
                     p_resources.calendar_code, /* B4724360 - INVCONV */
                     nvl(p_resources.batchable_flag,0),  /* BUG 4157063 */
                     p_resources.batch_window,      /* BUG 4157063 */
                     x_message_count,
                     x_message_list,
                     l_return_status);

           x_return_status := l_return_status ;

           IF l_return_status = 'E' THEN
              RAISE resource_update_failure;
           ELSE
           /* Update the Resource Data now */

                 update_detail_rows(
                                p_resources.organization_id,  /* B4724360 - INVCONV */
                                p_resources.resources,
                                p_resources.group_resource,
                                p_resources.assigned_qty,
                                p_resources.daily_avail_use,
                                p_resources.usage_uom,   /* B4724360 - INVCONV */
                                p_resources.nominal_cost,
                                p_resources.inactive_ind,
                                sysdate,
                                FND_GLOBAL.user_id,                 /* Bug 6412180 */
                                sysdate,
                                FND_GLOBAL.user_id,                 /* Bug 6412180 */
                                FND_GLOBAL.user_id,                 /* Bug 6412180 */
                                p_resources.trans_cnt,
                                p_resources.delete_mark,
                                p_resources.text_code,
                                p_resources.ideal_capacity,
                                p_resources.min_capacity,
                                p_resources.max_capacity,
                                p_resources.capacity_um,  /* B4724360 - INVCONV */
                                p_resources.resource_id,
                                p_resources.capacity_constraint,
                                p_resources.capacity_tolerance,
                                p_resources.schedule_ind,
                                p_resources.utilization,
                                p_resources.efficiency,
                                p_resources.sds_window,    /* B7637373 - VPEDARLA */
				p_resources.planning_exception_set, /* Bug # 6413873 */
                                p_resources.calendar_code, /* B4724360 - INVCONV */
                                nvl(p_resources.batchable_flag,0),  /* BUG 4157063 */
                                p_resources.batch_window,      /* BUG 4157063 */
                                g_return_status
                                  );
           x_return_status := g_return_status ;
           END IF; /* Return status */

    /* set the Update flag back to 'No' */
       v_update_flag := 'N';

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE resource_update_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data => x_message_list);

    IF x_message_count = 0 THEN
       fnd_file.put_line(fnd_file.log,'Resource was Updated successfullly');
    END IF;

    fnd_file.put_line(fnd_file.log,'Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

EXCEPTION

    WHEN resource_update_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT update_resource_dtl;
         fnd_file.put_line (fnd_file.log,m_pkg_name||'.'||l_api_name||':'||'API not complete');
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN RESOURCES_REQUIRED THEN
         x_return_status := 'E'  ;
        FND_MESSAGE.SET_NAME('GMA','SY_REQUIRED');
        FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_resource_dtl;
         fnd_file.put_line (fnd_file.log,m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
END update_resource_dtl;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_detail_rows                                            */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* The following Procedure checks the Record and then Inserts      */
  /* the row into cr_rsrc_mst table and Returns S code if inserted   */
  /* Successfully                                                    */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/10/2002   Initial implementation                     */
  /* Sgidugu 04/12/2002   Count is not Updated if Schedule Ind = 2   */
  /* Kaushek B 13/09/07 B6413873 Added parameter planning_exception_set */
  /* =============================================================== */

PROCEDURE  update_detail_rows
  (
     p_organization_id        IN  NUMBER, /* B4724360 - INVCONV */
     p_resources              IN  VARCHAR2,
     p_group_resource         IN  VARCHAR2,
     p_assigned_qty           IN  NUMBER,
     p_daily_avail_use        IN  NUMBER,
     p_usage_um               IN  VARCHAR2,
     p_nominal_cost           IN  NUMBER,
     p_inactive_ind           IN  NUMBER,
     p_creation_date          IN  DATE,
     p_created_by             IN  NUMBER,
     p_last_update_date       IN  DATE,
     p_last_updated_by        IN  NUMBER,
     p_last_update_login      IN  NUMBER,
     p_trans_cnt              IN  NUMBER,
     p_delete_mark            IN  NUMBER,
     p_text_code              IN  NUMBER,
     p_ideal_capacity         IN  NUMBER,
     p_min_capacity           IN  NUMBER,
     p_max_capacity           IN  NUMBER,
     p_capacity_uom           IN  VARCHAR2,
     p_resource_id            IN  NUMBER,
     p_capacity_constraint    IN  NUMBER,
     p_capacity_tolerance     IN  NUMBER,
     p_schedule_ind           IN  NUMBER,
     p_utilization            IN  NUMBER,
     p_efficiency             IN  NUMBER,
     p_sds_window             IN  NUMBER,   /* B7637373 - VPEDARLA */
     p_planning_exception_set IN  VARCHAR2, /* Bug # 6413873 */
     p_calendar_code          IN  VARCHAR2, /* B4724360 - INVCONV */
     p_batchable_flag         IN  NUMBER,   /* BUG 4157063 */
     p_batch_window           IN  NUMBER,   /* BUG 4157063 */
     x_return_status          OUT NOCOPY VARCHAR2
  ) IS

BEGIN

    IF p_schedule_ind = 2 THEN
      UPDATE cr_rsrc_dtl
      SET group_resource = p_group_resource,
          daily_avail_use = p_daily_avail_use,
          usage_uom = p_usage_um,     /* B4724360 - INVCONV */
          nominal_cost = p_nominal_cost,
          inactive_ind = p_inactive_ind,
          last_update_date = p_last_update_date,
          last_updated_by = p_last_updated_by,
          last_update_login = p_last_update_login,
          trans_cnt = p_trans_cnt,
          delete_mark = p_delete_mark,
          text_code = p_text_code,
          ideal_capacity = p_ideal_capacity,
          min_capacity = p_min_capacity,
          max_capacity = p_max_capacity,
          capacity_um = p_capacity_uom,   /* B4724360 - INVCONV */
          capacity_constraint = p_capacity_constraint,
          capacity_tolerance = p_capacity_tolerance,
          schedule_ind = p_schedule_ind,
          utilization = p_utilization,
          efficiency  = p_efficiency,
          sds_window  = p_sds_window,  /* B7637373 - VPEDARLA */
	  planning_exception_set = p_planning_exception_set, /* Bug # 6413873 */
          calendar_code = p_calendar_code , /* B4724360 - INVCONV */
          batchable_flag = nvl(p_batchable_flag,0)  ,   /* BUG 4157063 */
          batch_window = p_batch_window        /* BUG 4157063 */
         WHERE resource_id = p_resource_id
         AND organization_id = p_organization_id;
    ELSE
      UPDATE cr_rsrc_dtl
      SET group_resource = p_group_resource,
          assigned_qty = p_assigned_qty,
          daily_avail_use = p_daily_avail_use,
          usage_uom = p_usage_um,   /* B4724360 - INVCONV */
          nominal_cost = p_nominal_cost,
          inactive_ind = p_inactive_ind,
          last_update_date = p_last_update_date,
          last_updated_by = p_last_updated_by,
          last_update_login = p_last_update_login,
          trans_cnt = p_trans_cnt,
          delete_mark = p_delete_mark,
          text_code = p_text_code,
          ideal_capacity = p_ideal_capacity,
          min_capacity = p_min_capacity,
          max_capacity = p_max_capacity,
          capacity_uom = p_capacity_uom, /* B4724360 - INVCONV */
          capacity_constraint = p_capacity_constraint,
          capacity_tolerance = p_capacity_tolerance,
          schedule_ind = p_schedule_ind,
          utilization = p_utilization,
          efficiency  = p_efficiency,
          sds_window  = p_sds_window,  /* B7637373 - VPEDARLA */
	  planning_exception_set = p_planning_exception_set, /* Bug # 6413873 */
          calendar_code = p_calendar_code , /* B4724360 - INVCONV */
          batchable_flag = nvl(p_batchable_flag,0)  ,   /* BUG 4157063 */
          batch_window = p_batch_window        /* BUG 4157063 */
         WHERE resource_id = p_resource_id
         AND organization_id = p_organization_id;
    END IF ;

      if (sql%notfound) then
        raise no_data_found;
      end if;
      x_return_status := 'S' ;

EXCEPTION
   WHEN no_data_found THEN
       ROLLBACK TO SAVEPOINT update_instances;
       FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT update_resource_dtl;
       FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.g_ret_sts_unexp_error;
END update_detail_rows;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_instances                                              */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the update into Generic    */
  /* Resource Table                                                  */
  /*                                                                 */
  /* History :                                                       */
  /* Rajesh Patangya 11/27/2002   Initial implementation             */
  /* =============================================================== */
PROCEDURE update_instances
  ( p_api_version            IN   NUMBER         :=  1
  , p_init_msg_list          IN   BOOLEAN        :=  TRUE
  , p_commit                 IN   BOOLEAN        :=  FALSE
  , p_instances              IN   gmp_resource_instances%ROWTYPE
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          OUT  NOCOPY VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_INSTANCES';
  l_return_status         VARCHAR2(1) ;
  g_return_status         VARCHAR2(1) ;
  v_eff_start_date        DATE ;
  X_msg                   VARCHAR2(2000);

  /* Define Exceptions */
  instance_update_failure          EXCEPTION;
  invalid_version                  EXCEPTION;
  RESOURCES_REQUIRED               EXCEPTION;

BEGIN
  l_return_status         := FND_API.G_RET_STS_SUCCESS;
  g_return_status         := FND_API.G_RET_STS_SUCCESS;
  v_eff_start_date        := NULL ;
  X_msg                   := '';

    SAVEPOINT update_instances;
    fnd_file.put_line(fnd_file.log,'UpdateInstancePub');

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_RESOURCE_DTL_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMP_RESOURCE_DTL_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Set the Update Flag to Yes */
     v_update_flag := 'Y';

    IF ((p_instances.resource_id IS NOT NULL) AND
        (p_instances.instance_id IS NOT NULL)) THEN

            IF p_instances.eff_start_date IS NULL THEN
               v_eff_start_date := SYSDATE ;
            ELSE
               v_eff_start_date := p_instances.eff_start_date ;
            END IF;

            check_instance_data (
              p_instances.resource_id
             ,p_instances.instance_id
             ,p_instances.vendor_id
             ,v_eff_start_date
             ,p_instances.eff_end_date
             ,p_instances.maintenance_interval
             ,p_instances.inactive_ind
             ,p_instances.calibration_frequency
             ,p_instances.calibration_item_id
             ,x_message_count
             ,x_message_list
             ,x_return_status   );
       x_return_status := g_return_status ;

       IF l_return_status = 'E' THEN
          RAISE instance_update_failure;
       ELSE
           /* Update the Instance Data now */
            update_instance_row(
                 p_instances.resource_id
                ,p_instances.instance_id
                ,p_instances.instance_number
                ,p_instances.vendor_id
                ,p_instances.model_number
                ,p_instances.serial_number
                ,p_instances.tracking_number
                ,p_instances.eff_start_date
                ,p_instances.eff_end_date
                ,p_instances.last_maintenance_date
                ,p_instances.maintenance_interval
                ,p_instances.inactive_ind
                ,p_instances.calibration_frequency
                ,p_instances.calibration_period
                ,p_instances.calibration_item_id
                ,p_instances.last_calibration_date
                ,p_instances.next_calibration_date
                ,p_instances.last_certification_date
                ,p_instances.certified_by
                ,sysdate
                ,FND_GLOBAL.user_id                 /* Bug 6412180 */
                ,sysdate
                ,FND_GLOBAL.user_id                 /* Bug 6412180 */
                ,FND_GLOBAL.user_id                 /* Bug 6412180 */
                ,g_return_status
                               );
       x_return_status := g_return_status ;
       END IF;
    ELSE
       x_return_status := 'E';
       X_msg := 'Instance_id/resource_id';
       RAISE resources_required;
    END IF; /* p_resources.resource_id IS NOT NULL */

    /* set the Update flag back to 'No' */
       v_update_flag := 'N';

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE instance_update_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data => x_message_list);

    IF x_message_count = 0 THEN
       fnd_file.put_line(fnd_file.log,'Resource was Updated successfullly');
    END IF;

    fnd_file.put_line(fnd_file.log,'Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

EXCEPTION
    WHEN instance_update_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT update_instances;
         fnd_file.put_line (fnd_file.log,m_pkg_name||'.'||l_api_name||':'||'API not complete');
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN RESOURCES_REQUIRED THEN
     FND_MESSAGE.SET_NAME('GMA','SY_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_instances;
         fnd_file.put_line (fnd_file.log,m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
END update_instances;


  /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_instance_row                                            */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* The following Procedure Updates the information in              */
  /* gmp_resource_instances table and Returns S code if updated      */
  /* Successfully                                                    */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/10/2002   Initial implementation                     */
  /* =============================================================== */
PROCEDURE  update_instance_row
  (
     p_resource_id                     IN NUMBER
    ,p_instance_id                     IN NUMBER
    ,p_instance_number                 IN NUMBER
    ,p_vendor_id                       IN NUMBER
    ,p_model_number                    IN VARCHAR2
    ,p_serial_number                   IN VARCHAR2
    ,p_tracking_number                 IN VARCHAR2
    ,p_eff_start_date                  IN DATE
    ,p_eff_end_date                    IN DATE
    ,p_last_maintenance_date           IN DATE
    ,p_maintenance_interval            IN NUMBER
    ,p_inactive_ind                    IN NUMBER
    ,p_calibration_frequency           IN NUMBER
    ,p_calibration_period              IN VARCHAR2
    ,p_calibration_item_id             IN NUMBER
    ,p_last_calibration_date           IN DATE
    ,p_next_calibration_date           IN DATE
    ,p_last_certification_date         IN DATE
    ,p_certified_by                    IN VARCHAR2
    ,p_creation_date                   IN DATE
    ,p_created_by                      IN NUMBER
    ,p_last_update_date                IN DATE
    ,p_last_updated_by                 IN NUMBER
    ,p_last_update_login               IN NUMBER
    ,x_return_status                   OUT  NOCOPY VARCHAR2
  ) IS

BEGIN

      UPDATE gmp_resource_instances set
         vendor_id = p_vendor_id
        ,model_number = p_model_number
        ,serial_number = p_serial_number
        ,tracking_number = p_tracking_number
        ,eff_start_date = p_eff_start_date
        ,eff_end_date = p_eff_end_date
        ,last_maintenance_date = p_last_maintenance_date
        ,maintenance_interval = p_maintenance_interval
        ,inactive_ind = p_inactive_ind
        ,calibration_frequency = p_calibration_frequency
        ,calibration_period = p_calibration_period
        ,calibration_item_id = p_calibration_item_id
        ,last_calibration_date = p_last_calibration_date
        ,next_calibration_date = p_next_calibration_date
        ,last_certification_date = p_last_certification_date
        ,certified_by = p_certified_by
        ,creation_date = p_creation_date
        ,created_by = p_created_by
        ,last_update_date = p_last_update_date
        ,last_updated_by = p_last_updated_by
        ,last_update_login = p_last_update_login
      WHERE resource_id = p_resource_id
        AND instance_id = p_instance_id ;

      If (sql%notfound) THEN
        raise no_data_found;
      END IF;
      x_return_status  := 'S' ;

EXCEPTION
    WHEN no_data_found THEN
         ROLLBACK TO SAVEPOINT update_instances;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_instances;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.g_ret_sts_unexp_error;
END update_instance_row ;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   delete_resources                                              */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the delete Resources       */
  /* was Successful                                                  */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/04/2002   Initial implementation                     */
  /* =============================================================== */
PROCEDURE delete_resources
  ( p_api_version 	IN NUMBER 	:= 1
  , p_init_msg_list 	IN BOOLEAN 	:= TRUE
  , p_commit		IN BOOLEAN 	:= FALSE
  , p_organization_id 	IN cr_rsrc_dtl.organization_id%TYPE
  , p_resources 	IN cr_rsrc_dtl.resources%TYPE
  , x_message_count 	OUT NOCOPY NUMBER
  , x_message_list 	OUT NOCOPY VARCHAR2
  , x_return_status	OUT NOCOPY VARCHAR2
  ) IS

  /* Local variable section */
  l_counter          number ;
  v_resource_id      number ;
  l_api_name         CONSTANT VARCHAR2(30) := 'DELETE_RESOURCES';
  l_return_status    VARCHAR2(1) ;

  /* Define Exceptions */
  resource_delete_failure    EXCEPTION;
  invalid_version            EXCEPTION;


  CURSOR Cur_resource_id IS
  SELECT resource_id
  FROM cr_rsrc_dtl
  WHERE organization_id = p_organization_id
  AND   resources = p_resources;

BEGIN

  l_counter          := 0;
  v_resource_id      := 0;
  l_return_status    := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT delete_resources;
    fnd_file.put_line(fnd_file.log,'DeleteResourcePub');

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_RESOURCE_DTL_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMP_RESOURCE_DTL_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    OPEN Cur_resource_id;
    FETCH Cur_resource_id INTO v_resource_id;
    CLOSE Cur_resource_id;

    IF (v_resource_id = 0 ) then
        l_return_status := 'E';
        GMD_DEBUG.PUT_LINE('Resource to be deleted Does Not Exist ');
        FND_MSG_PUB.ADD;
        RAISE resource_delete_failure;
    ELSE
        -- Added code Rajesh Patangya
        -- Resource exception

        delete from gmp_rsrc_excp_asnmt
        WHERE resource_id = v_resource_id ;

        -- Resource unavailable time
        delete from gmp_rsrc_unavail_man
        WHERE resource_id = v_resource_id ;

        -- Resource instances
        delete from gmp_resource_instances
        where resource_id = v_resource_id;

        -- Resource available
        delete from gmp_resource_avail
        where resource_id = v_resource_id
          and organization_id = p_organization_id
          and RESOURCE_INSTANCE_ID IS NOT NULL ;

        -- Resource details
        delete from cr_rsrc_dtl
        where resource_id = v_resource_id
          and organization_id = p_organization_id;

    END IF;

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       fnd_file.put_line(fnd_file.log,'Resource was deleted successfully');
    END IF;

    fnd_file.put_line(fnd_file.log,'Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

EXCEPTION
    WHEN resource_delete_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT delete_resources;
         fnd_file.put_line(fnd_file.log,m_pkg_name||'.'||l_api_name||':'||'API not complete');
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_resources;
         fnd_file.put_line(fnd_file.log,m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
END delete_resources;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   check_instance_data                                           */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* The following Procedure checks the Record and then Inserts      */
  /* the row into cr_rsrc_mst table and Returns S code if inserted   */
  /* Successfully                                                    */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/10/2002   Initial implementation                     */
  /* =============================================================== */
PROCEDURE  check_instance_data
  (
     p_resource_id             IN NUMBER
    ,p_instance_id             IN NUMBER
    ,p_vendor_id               IN NUMBER
    ,p_eff_start_date          IN DATE
    ,p_eff_end_date            IN DATE
    ,p_maintenance_interval    IN NUMBER
    ,p_inactive_ind            IN NUMBER
    ,p_calibration_frequency   IN NUMBER
    ,p_calibration_item_id     IN NUMBER
    ,x_message_count           OUT  NOCOPY NUMBER
    ,x_message_list            OUT  NOCOPY VARCHAR2
    ,x_return_status           OUT  NOCOPY VARCHAR2
    ) IS

   CURSOR Cur_check_dup IS
   SELECT COUNT(1)
   FROM   gmp_resource_instances
   where  instance_id = p_instance_id
   and    resource_id = p_resource_id ;

   CURSOR Cur_vendor_id IS
   SELECT COUNT(1)
   FROM   po_vendors
   where  vendor_id = p_vendor_id
   and    enabled_flag = 'Y' ;

   CURSOR Cur_check_item IS
   SELECT COUNT(1)
   FROM   ic_item_mst
   where  item_id = p_calibration_item_id
   and    delete_mark = 0 ;

   INVALID_VALUE             EXCEPTION;
   BAD_RESOURCE              EXCEPTION;
   DUPLICATE_RECORD          EXCEPTION;
   RESOURCE_REQUIRED         EXCEPTION;
   INVALID_DATE_RANGE        EXCEPTION;

   X_field       varchar2(2000) ;
   X_value       varchar2(2000) ;
   X_msg         varchar2(2000) ;
   X_count       number ;
   l_count1      number ;
   l_count2      number ;
   l_count3      number ;
   l_count4      number ;
   l_sy_date     date ;

BEGIN

   X_field       := '';
   X_value       := '';
   X_msg         := '';
   X_count       := 0;
   l_count1      := 0;
   l_count2      := 0;
   l_count3      := 0;
   l_count4      := 0;
   l_sy_date     := NULL;
   x_return_status := 'S' ;

       /* Check for valid item */
          IF (p_calibration_item_id IS NOT NULL) THEN
               OPEN Cur_check_item;
               FETCH Cur_check_item INTO l_count3;
               CLOSE Cur_check_item;
               IF (l_count3 <> 1) THEN
                   x_return_status := 'E';
                   X_field := 'Calibration Item ';
                   X_value := p_calibration_item_id;
                   RAISE INVALID_VALUE;
               END IF;
          END IF;

       /* Check for valid vendor */
          IF (p_vendor_id IS NOT NULL) THEN
               OPEN Cur_vendor_id;
               FETCH Cur_vendor_id INTO l_count2;
               CLOSE Cur_vendor_id;
               IF (l_count2 <> 1) THEN
                   x_return_status := 'E';
                   X_field := 'Vendor Identification';
                   X_value := p_vendor_id;
                   RAISE INVALID_VALUE;
               END IF;
          END IF;

       /* Check for Duplicate record */
          IF (p_resource_id IS NULL) OR (p_instance_id is NULL) THEN
             x_return_status := 'E';
             X_msg := 'Resource or Instance ';
             RAISE RESOURCE_REQUIRED;
          ELSE
            x_return_status := 'S';
            IF v_update_flag <> 'Y'  THEN
               OPEN Cur_check_dup;
               FETCH Cur_check_dup INTO l_count1;
               CLOSE Cur_check_dup;
               IF (l_count1 >0) THEN
                   x_return_status := 'E';
                   RAISE DUPLICATE_RECORD;
               END IF;
            END IF;
          END IF;

       /* Check if Inactive Ind has Valid Values 0,1,2 */

        IF (p_inactive_ind = 0) OR (p_inactive_ind = 1) THEN
           x_return_status := 'S';
        ELSE
           x_return_status := 'E';
           X_field := 'Inactive Indicator';
           X_value := p_inactive_ind;
           RAISE INVALID_VALUE;
        END IF;

        IF (p_calibration_frequency < 0) THEN
           x_return_status := 'E';
           X_field := 'Calibration Frequency';
           X_value := p_calibration_frequency;
           RAISE INVALID_VALUE;
        END IF;

        IF (p_maintenance_interval < 0) THEN
           x_return_status := 'E';
           X_field := 'Maintenance Interval';
           X_value := p_maintenance_interval;
           RAISE INVALID_VALUE;
        END IF;

        BEGIN
          SELECT to_date((FND_PROFILE.VALUE('SY$MAX_DATE')),'YYYY/MM/DD')
               INTO l_sy_date FROM SYS.DUAL ;
          x_return_status := 'S';
        EXCEPTION
          WHEN OTHERS THEN
           x_return_status := 'E';
           X_field := 'System Max Date';
           X_value := l_sy_date ;
           RAISE INVALID_VALUE;
        END ;

        IF p_eff_start_date > l_sy_date THEN
           x_return_status := 'E';
           X_field := 'Effective Start Date ';
           X_value := p_eff_start_date;
           RAISE INVALID_VALUE;
        END IF;

        IF p_eff_end_date > l_sy_date THEN
           x_return_status := 'E';
           X_field := 'Effective End Date ';
           X_value := p_eff_end_date;
           RAISE INVALID_VALUE;
        END IF;

        IF p_eff_end_date < p_eff_start_date THEN
           x_return_status := 'E';
           RAISE INVALID_DATE_RANGE;
        END IF;

EXCEPTION

  WHEN INVALID_DATE_RANGE THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMP','MR_STARTENDDATEERR');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count=>x_message_count,p_data=>x_message_list);

  WHEN INVALID_VALUE THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMP','GMP_INVALID_VALUE');
    FND_MESSAGE.SET_TOKEN('FIELD',X_field);
    FND_MESSAGE.SET_TOKEN('VALUE',X_value);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count=>x_message_count,p_data=>x_message_list);

  WHEN RESOURCE_REQUIRED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count=>x_message_count,p_data=>x_message_list);

  WHEN DUPLICATE_RECORD THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMP', 'PS_DUP_REC');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get(p_count=>x_message_count,p_data=>x_message_list);

END check_instance_data ;

END GMP_RESOURCE_DTL_PUB;

/
