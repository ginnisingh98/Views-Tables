--------------------------------------------------------
--  DDL for Package Body CSD_DEPOT_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_DEPOT_UPDATE_PVT" as
/* $Header: csddrupb.pls 115.10 2002/11/12 21:27:49 sangigup noship $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------

G_PKG_NAME  CONSTANT VARCHAR2(30)  := 'CSD_DEPOT_UPDATE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(30)  := 'csddrupb.pls';
g_debug number := csd_gen_utility_pvt.g_debug_level;
-----------------------------------
-- Convert to primary uom
-----------------------------------
procedure convert_to_primary_uom
          (p_item_id  in number,
           p_organization_id in number,
           p_from_uom in varchar2,
           p_from_quantity in number,
           p_result_quantity OUT NOCOPY number)
is

v_primary_uom_code varchar2(30);
p_from_uom_code varchar2(3);

Begin

    Begin
    select uom_code
    into p_from_uom_code
    from mtl_units_of_measure
    where unit_of_measure = p_from_uom;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('no_data_found error for unit_of_measure ='||p_from_uom);
END IF;

     WHEN OTHERS THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('More than one row found for unit_of_measure ='||p_from_uom);
END IF;

    End;

    Begin
    select primary_uom_code
    into v_primary_uom_code
    from mtl_system_items
    where organization_id   = p_organization_id
    and   inventory_item_id = p_item_id;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('no_data_found error(primary UOM) for inventory_item_id ='||TO_CHAR(p_item_id));
END IF;

     WHEN OTHERS THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('More than one row found(Primary UOM) for inventory_item_id ='||TO_CHAR(p_item_id));
END IF;

    End;

    BEGIN
       p_result_quantity :=inv_convert.inv_um_convert(
                         p_item_id ,2,
                         p_from_quantity,p_from_uom_code,v_primary_uom_code,null,null);
    EXCEPTION
     WHEN OTHERS THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('inv_convert returned with error message');
END IF;

    END;
End convert_to_primary_uom;

-- ---------------------------------------------------------
-- procedure name: Group_wip_update                       --
-- description   : procedure that updates depot           --
--                 with qty once wip job is complete      --
--                                                        --
-- ---------------------------------------------------------

PROCEDURE group_wip_update
( p_api_version           IN   NUMBER,
  p_commit                IN   VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN   VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN   NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN   NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2
  )
 IS
  l_api_name                 CONSTANT VARCHAR2(30)   := 'group_wip_update';
  l_api_version              CONSTANT NUMBER         := 1.0;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(100);
  l_msg_index                NUMBER;
  l_validate_flag            BOOLEAN;
  v_total_rec                NUMBER;
  p_rep_hist_id              NUMBER;
  v_remaining_qty            NUMBER;
  v_transaction_quantity     NUMBER;
  v_old_wip_entity_id        NUMBER;
  v_wip_entity_name          VARCHAR2(100);
  p_wip_entity_id            NUMBER;
  p_quantity_completed       NUMBER;
  p_completion_subinventory  VARCHAR2(30);
  p_date_completed           DATE;
  p_organization_id          NUMBER;
  p_routing_reference_id     NUMBER;
  p_last_updated_by          NUMBER;
  l_return_status            VARCHAR2(1);
  v_new_completion_quantity  NUMBER;

  v_quantity_completed           number;
  p_old_complete                 number;
  v_wip_entity_id                number;

-- travi new 2501113
  v_weid                         number;
CURSOR get_grp_id (p_inc_id in number) IS
SELECT repair_group_id
  FROM csd_repair_order_groups
 WHERE incident_id = p_inc_id;

CURSOR get_xref_id (p_rep_grp_id in number) IS
SELECT x.repair_job_xref_id, x.group_id, x.object_version_number
  FROM csd_repair_job_xref x
 WHERE x.repair_line_id in ( select r.repair_line_id
                              from csd_repairs r
                             where r.repair_group_id = p_rep_grp_id)
   AND x.wip_entity_id = x.group_id;
-- end travi new 2501113

-- Cursor to get wip entity id
CURSOR get_wip_entity (p_inc_id in number) IS
SELECT distinct crog.wip_entity_id
FROM   csd_repair_order_groups crog,
       wip_discrete_jobs wdj
WHERE  crog.wip_entity_id = wdj.wip_entity_id
 AND   wdj.status_type    in ( 4,12,5)
 AND   crog.incident_id    = p_inc_id;

-------------------------
--      WIP Job Statuses
-- Complete Status  : 4
-- Closed           : 12
-- Complete No Charge : 5
-------------------------

-- Cursor to get repair group id
CURSOR get_rep_group (p_wip_ent_id in number) IS
SELECT crog.repair_group_id
FROM   csd_repair_order_groups crog
WHERE  crog.wip_entity_id = p_wip_ent_id;

-- Cursor to get repair line id
CURSOR get_repair_lines(p_rep_group_id in number,
                    p_wip_ent_id in number ) IS
SELECT
      crj.repair_job_xref_id,
      crj.wip_entity_id,
      crj.repair_line_id,
      csr.repair_number,
      crj.quantity_completed,
      crj.quantity,
      csr.promise_date
FROM  csd_repair_job_xref crj,
     csd_repairs csr
WHERE repair_group_id = p_rep_group_id
AND   csr.repair_line_id            = crj.repair_line_id
AND   nvl(crj.quantity_completed,0) < crj.quantity
AND   crj.wip_entity_id  = p_wip_ent_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT  group_wip_update;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME    )
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Api body starts
   if (g_debug > 0) then
   csd_gen_utility_pvt.dump_api_info
   ( p_pkg_name  => G_PKG_NAME,
     p_api_name  => l_api_name );
end if;
  -- Validate the incident_id

IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('Incident Id ='||p_incident_id);
END IF;

  l_validate_flag := csd_process_util.validate_incident_id(p_incident_id );

  IF NOT(l_validate_flag) then
IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('The Incident Id is invalid ');
END IF;

     Raise  FND_API.G_EXC_ERROR;
  END IF;

  -- travi new code 2501113 update with wip_entity_id
  -- BEGIN LOOPS
  -- Get the groups for wip_entity_id update
  FOR C5 in get_grp_id (p_incident_id )
  LOOP

    -- Get the xref for wip_entity_id update
    FOR C6 in get_xref_id (C5.repair_group_id)
    LOOP
IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD('In C6 get_xref_id');
END IF;


     BEGIN
      SELECT wip_entity_id
        INTO v_weid
        FROM wip_entities
       WHERE wip_entity_name = 'CSD'||C6.group_id;
     Exception
       When no_data_found then
IF (g_debug > 0 ) THEN
           csd_gen_utility_pvt.add('Invalid WIP_ENTITY_NAME : CSD'||C6.group_id);
END IF;

       when others then
IF (g_debug > 0 ) THEN
           csd_gen_utility_pvt.add('Others exception WIP_ENTITY_NAME : CSD'||C6.group_id);
END IF;

     End;

IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD('Updating the xref table repair_job_xref_id = '|| C6.repair_job_xref_id);
END IF;


     if( v_weid is not null) then
     Begin
IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD('In C6 updating xref : '||C6.repair_job_xref_id||' for wip_entity_id');
END IF;

      -- updating xref for wip_entity_id
      UPDATE csd_repair_job_xref
         SET wip_entity_id   = v_weid
       WHERE repair_job_xref_id = C6.repair_job_xref_id
         AND group_id = C6.group_id
         AND object_version_number = C6.object_version_number;
     Exception
       when others then
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('Others exception repair_job_xref_id : '||C6.repair_job_xref_id);
END IF;

     End;
     end if;

    END LOOP; -- END LOOP FOR C6

     if( v_weid is not null) then
     Begin
IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.ADD('In C5 updating group : '||C5.repair_group_id||' for wip_entity_id');
END IF;

      -- update group level csd_repair_order_groups
      UPDATE csd_repair_order_groups
         SET wip_entity_id   = v_weid
       WHERE repair_group_id = C5.repair_group_id;
     Exception
       when others then
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('Others exception repair_group_id : '||C5.repair_group_id);
END IF;

     End;
     end if;


  END LOOP; -- END LOOP FOR C5
  -- end travi code

  -- BEGIN LOOPS
  FOR C1 in get_wip_entity(p_incident_id )
  LOOP

    -- Get the actual quantity completed
    BEGIN
        -- Get the qty completed from wip_discrete_jobs based on the wip_entity_id
        -- Only if the wip job that is completed will be processed
       -- and the partial completed qty will not be processed

       SELECT  wip_entity_id,
              quantity_completed,
                completion_subinventory,
                date_completed,
              organization_id,
              routing_reference_id,
              last_updated_by
        INTO    v_wip_entity_id,
                v_quantity_completed,
                p_completion_subinventory,
                p_date_completed,
              p_organization_id,
              p_routing_reference_id,
              p_last_updated_by
        FROM    wip_discrete_jobs
        WHERE   wip_entity_id = C1.wip_entity_id
          AND   status_type    in ( 4,12,5);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('No WIP Job found for the wip_entity_id '||TO_CHAR(p_WIP_ENTITY_ID));
END IF;

      v_quantity_completed := 0;
      -- Raise  FND_API.G_EXC_ERROR;
      WHEN OTHERS THEN
IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('when other exception at - get_wip_job_completed_qty_gr');
END IF;

       Raise  FND_API.G_EXC_ERROR;
    END;

    -- Get the original qty completed from csd_repair_job_xref based on the wip_entity_id
    SELECT nvl(sum(quantity_completed),0)
    INTO p_old_complete
    FROM csd_repair_job_xref
    WHERE wip_entity_id = C1.wip_entity_id;

    -- Get the actual qty completed, (qty completed - old qty completed)
    p_quantity_completed := nvl(v_quantity_completed,0) - nvl(p_old_complete,0);

      IF p_quantity_completed <> 0 THEN

        -- Getting all the repair_group_id for the wip_entity_id
        FOR C2 in get_rep_group(C1.wip_entity_id)
        LOOP

         -- Getting all the repair_lines for the repair_group_id
          FOR C3 in get_repair_lines(C2.repair_group_id,C1.wip_entity_id)
          LOOP

            -- Update csd_repair_job_xref
            update csd_repair_job_xref
            set quantity_completed = quantity
            where repair_line_id = C3.repair_line_id;

IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('Updated qty completed in csd_repair_job_xref for :'||C1.wip_entity_id);
END IF;


          -- Update csd_repairs
            update csd_repairs
            set ro_txn_status  = 'WIP_COMPLETED'
            where repair_line_id = C3.repair_line_id;

IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('Updated txn status in csd_repairs :'||C3.repair_line_id);
END IF;


              v_total_rec := v_total_rec + 1;

             -- Call API to Validate and Write to history
IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.add('Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write');
END IF;

               CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
                P_Api_Version_Number      => 1.0,
                P_Init_Msg_List           => 'T',
                P_Commit                  => 'F',
                p_validation_level        => null,
                p_action_code             => 0  ,
                px_REPAIR_HISTORY_ID      => p_rep_hist_id,
                p_OBJECT_VERSION_NUMBER   => null,
                p_REQUEST_ID              => null,
                p_PROGRAM_ID              => null,
                p_PROGRAM_APPLICATION_ID  => null,
                p_PROGRAM_UPDATE_DATE     => null,
                p_CREATED_BY              => FND_GLOBAL.USER_ID,
                p_CREATION_DATE           => sysdate,
                p_LAST_UPDATED_BY         =>  FND_GLOBAL.USER_ID,
                p_LAST_UPDATE_DATE        => sysdate,
                p_REPAIR_LINE_ID          => C3.repair_line_id,
                p_EVENT_CODE  => 'JC',
                p_EVENT_DATE  => nvl(p_date_completed,sysdate),
                p_QUANTITY    => v_transaction_quantity,
                p_PARAMN1     => p_organization_id,
                p_PARAMN2     => p_routing_reference_id,
                p_PARAMN3     => null,
                p_PARAMN4     => C3.wip_entity_id,
                p_PARAMN5     => null,
                p_PARAMN6     => null,
                p_PARAMN7     => null,
                p_PARAMN8     => null,
                p_PARAMN9     => null,
                p_PARAMN10    => null,
                p_PARAMC1     => p_completion_subinventory,
                p_PARAMC2     => v_wip_entity_name,
                p_PARAMC3     => null,
                p_PARAMC4     => null,
                p_PARAMC5     => null,
                p_PARAMC6     => null,
                p_PARAMC7     => null,
                p_PARAMC8     => null,
                p_PARAMC9     => null,
                p_PARAMC10    => null,
                p_PARAMD1     => p_date_completed,
                p_PARAMD2     => null,
                p_PARAMD3     => null,
                p_PARAMD4     => null,
                p_PARAMD5     => null,
                p_PARAMD6     => null,
                p_PARAMD7     => null,
                p_PARAMD8     => null,
                p_PARAMD9     => null,
                p_PARAMD10    => null,
                p_ATTRIBUTE_CATEGORY  => null,
                p_ATTRIBUTE1    => null,
                p_ATTRIBUTE2    => null,
                p_ATTRIBUTE3    => null,
                p_ATTRIBUTE4    => null,
                p_ATTRIBUTE5    => null,
                p_ATTRIBUTE6    => null,
                p_ATTRIBUTE7    => null,
                p_ATTRIBUTE8    => null,
                p_ATTRIBUTE9    => null,
                p_ATTRIBUTE10   => null,
                p_ATTRIBUTE11   => null,
                p_ATTRIBUTE12   => null,
                p_ATTRIBUTE13   => null,
                p_ATTRIBUTE14   => null,
                p_ATTRIBUTE15   => null,
                p_LAST_UPDATE_LOGIN  => FND_GLOBAL.LOGIN_ID,
                X_Return_Status      => l_return_status  ,
                X_Msg_Count          => l_msg_count,
                X_Msg_Data           => l_msg_data  );

           IF NOT(l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
                csd_gen_utility_pvt.ADD('validate_and_write failed ');
END IF;

               RAISE FND_API.G_EXC_ERROR;
           END IF;

          END LOOP; -- END LOOP FOR C3

         -- update group level csd_repair_order_groups
          UPDATE csd_repair_order_groups
          SET    group_txn_status   = 'WIP_COMPLETED',
                 completed_quantity = submitted_quantity
          WHERE  repair_group_id    = C2.repair_group_id;

        END LOOP; -- END LOOP FOR C2
IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('Successfully completed Depot Repair WIP Job Update');
END IF;


      END IF; -- END IF for  p_quantity_completed <> 0 T

  END LOOP; -- END LOOP FOR C1

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
  END IF;

  -- Standard call to get message count and IF count is  get message info.
  FND_MSG_PUB.Count_And_Get
       (p_count  =>  x_msg_count,
        p_data   =>  x_msg_data );

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Group_Wip_update;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Group_Wip_update;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Group_Wip_update ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
          FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

END Group_Wip_update;

/*-------------------------------------------------------*/
/* procedure name: Pre_process_update                    */
/* description   : procedure that updates the depot table*/
/*                 once the pre-process is completed     */
/*-------------------------------------------------------*/

procedure Pre_process_update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     number,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Pre_process_update';
  l_api_version            CONSTANT NUMBER         := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;
  l_validate_flag          Boolean;
  x_update_count           Number;

CURSOR get_rep_group (p_inc_id in number) IS
Select crog.repair_group_id,
       crt.repair_type_ref,
       crog.group_txn_status,
      crog.repair_order_quantity,
      crog.received_quantity,
      crog.shipped_quantity
from csd_repair_order_groups crog,
     csd_repair_types_vl crt
where crog.repair_type_id   = crt.repair_type_id
 and  crog.incident_id      = p_inc_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT  Pre_process_update;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME    )
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Api body starts
   if (g_debug > 0) then
   csd_gen_utility_pvt.dump_api_info
   ( p_pkg_name  => G_PKG_NAME,
     p_api_name  => l_api_name );
end if;
  -- Validate the incident_id
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('Incident Id ='||p_incident_id);
END IF;


  l_validate_flag := csd_process_util.validate_incident_id(p_incident_id );

  IF NOT(l_validate_flag) then
IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('The Incident Id is invalid ');
END IF;

     Raise  FND_API.G_EXC_ERROR;
  END IF;

  FOR grp in get_rep_group (p_incident_id )
  LOOP

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('grp.repair_type_ref  ='||grp.repair_type_ref );
END IF;

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('grp.group_txn_status ='||grp.group_txn_status);
END IF;


    IF grp.repair_type_ref in ('RR','E','WR') THEN

      --IF grp.group_txn_status = 'OM_BOOKED' then

IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('grp.recd qty    ='||grp.received_quantity );
END IF;

         -- Calling Group_Rma_Update to update
         -- all the RO that have been recd
         Group_Rma_Update
          ( p_api_version         => p_api_version,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_repair_group_id     => grp.repair_group_id,
            x_update_count        => x_update_count,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data );

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('x_update_count  ='||x_update_count );
END IF;


        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Group_ship_update failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (nvl(grp.received_quantity,0) + nvl(x_update_count,0) = nvl(grp.repair_order_quantity,0)) then

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('Updating group txn status and qty ');
END IF;

            -- Update txn_status and rcvd qty
            Update csd_repair_order_groups
            set received_quantity = nvl(repair_order_quantity,0) ,
                group_txn_status  = 'OM_RECEIVED'
            where repair_group_id = grp.repair_group_id ;
         ELSIF nvl(x_update_count,0) > 0 then
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('Updating recd qty');
END IF;

            -- Update only the rcvd qty
            Update csd_repair_order_groups
            set received_quantity = nvl(received_quantity,0)+ x_update_count
            where repair_group_id = grp.repair_group_id ;

        END IF;
    --END IF;

    ELSIF grp.repair_type_ref in ('ARR','WRL') THEN

     --IF grp.group_txn_status = 'OM_BOOKED' then

         -- Calling Group_Rma_Update to update
         -- all the RO that have been recd
         Group_Rma_Update
          ( p_api_version         => p_api_version,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_repair_group_id     => grp.repair_group_id,
            x_update_count        => x_update_count,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data );

IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('grp.recd qty    ='||grp.received_quantity );
END IF;

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('x_update_count  ='||x_update_count );
END IF;


        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Group_rma_update failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (nvl(grp.received_quantity,0) + nvl(x_update_count,0) = nvl(grp.repair_order_quantity,0)) then

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('Updating group txn status and qty ');
END IF;

            -- Update txn_status and rcvd qty
            Update csd_repair_order_groups
            set received_quantity = nvl(repair_order_quantity,0) ,
                group_txn_status  = 'OM_RECEIVED'
            where repair_group_id = grp.repair_group_id ;
         ELSIF nvl(x_update_count,0) > 0 then
IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('Updating recd qty');
END IF;

            -- Update only the rcvd qty
            Update csd_repair_order_groups
            set received_quantity = nvl(received_quantity,0)+ x_update_count
            where repair_group_id = grp.repair_group_id ;

        END IF;

        -- Calling Group_ship_update to update
         -- all the loaner that have been shipped
         Group_ship_update
          ( p_api_version         => p_api_version,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_repair_group_id     => grp.repair_group_id,
            x_update_count        => x_update_count,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data );

          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Group_ship_update failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

    --END IF;

    ELSIF grp.repair_type_ref in ('AE','AL','R') THEN

      --IF grp.group_txn_status = 'OM_RELEASED' then

         -- Calling Group_ship_update to update
         -- all the RO that have been shipped
         Group_ship_update
          ( p_api_version         => p_api_version,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_repair_group_id     => grp.repair_group_id,
            x_update_count        => x_update_count,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data );

IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('grp.shipped qty ='||grp.shipped_quantity );
END IF;

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('x_update_count  ='||x_update_count );
END IF;


        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Group_ship_update failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

      IF (nvl(grp.shipped_quantity,0) + nvl(x_update_count,0)) = nvl(grp.repair_order_quantity,0) then
IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('Updating group status and qty ');
END IF;

         -- Update txn_status and rcvd qty
         Update csd_repair_order_groups
         set shipped_quantity = nvl(repair_order_quantity,0) ,
             group_txn_status  = 'OM_SHIPPED'
         where repair_group_id = grp.repair_group_id ;
       ELSIF nvl(x_update_count,0) > 0 then
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('updating shipped qty  ='||x_update_count );
END IF;

         -- Update only rcvd qty
         Update csd_repair_order_groups
         set shipped_quantity = nvl(shipped_quantity,0)+x_update_count
         where repair_group_id = grp.repair_group_id ;

      END IF;

     --END IF;

    END IF; -- end if repair_type_ref

  END LOOP; -- end of all groups
 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Pre_process_update;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Pre_process_update ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Pre_process_update ;
          IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
                  FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
          END IF;
                  FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END Pre_process_update;

/*--------------------------------------------------*/
/* procedure name: Post_process_update              */
/* description   : procedure that updates depot     */
/*                after post-process is complete    */
/*--------------------------------------------------*/

procedure Post_process_update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_incident_id           IN     number,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 ) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Post_process_update';
  l_api_version            CONSTANT NUMBER         := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;
  l_validate_flag          Boolean;
  x_update_count           number;

CURSOR get_rep_group (p_inc_id in number) IS
Select crog.repair_group_id,
       crt.repair_type_ref,
       crog.group_txn_status,
      crog.repair_order_quantity,
      crog.received_quantity,
      crog.shipped_quantity
from csd_repair_order_groups crog,
     csd_repair_types_vl crt
where crog.repair_type_id   = crt.repair_type_id
 and  crog.incident_id      = p_inc_id;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT  Post_process_update;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME    )
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Api body starts
   if (g_debug > 0 ) then
   csd_gen_utility_pvt.dump_api_info
   ( p_pkg_name  => G_PKG_NAME,
     p_api_name  => l_api_name );
end if;
  -- Validate the incident_id
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add('Incident Id ='||p_incident_id);
END IF;

  l_validate_flag := csd_process_util.validate_incident_id(p_incident_id );

  IF NOT(l_validate_flag) then
IF (g_debug > 0 ) THEN
     csd_gen_utility_pvt.add('The Incident Id is invalid ');
END IF;

     Raise FND_API.G_EXC_ERROR ;
  END IF;

  FOR grp in get_rep_group (p_incident_id )
  LOOP

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('grp.repair_type_ref  ='||grp.repair_type_ref );
END IF;

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('grp.group_txn_status ='||grp.group_txn_status);
END IF;


    IF grp.repair_type_ref in ('AE','AL') THEN

      --IF grp.group_txn_status = 'OM_BOOKED' then

         -- Calling Group_Rma_Update to update
         -- all the RO that have been recd
         Group_Rma_Update
          ( p_api_version         => p_api_version,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_repair_group_id     => grp.repair_group_id,
            x_update_count        => x_update_count,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data );

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('grp.recd qty  ='||grp.received_quantity );
END IF;

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('x_update_count ='||x_update_count );
END IF;


        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Group_ship_update failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

     IF nvl(grp.received_quantity,0)+nvl(x_update_count,0) = nvl(grp.repair_order_quantity,0) then
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('Updating the group txn status ');
END IF;

         -- Update txn_status and rcvd qty
         Update csd_repair_order_groups
         set received_quantity = nvl(received_quantity ,0) + nvl(x_update_count,0),
             group_txn_status  = 'OM_RECEIVED'
         where repair_group_id = grp.repair_group_id ;
      ELSIF  nvl(x_update_count,0) > 0 then
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('Updating the recd qty ');
END IF;

         -- Update only rcvd qty
         Update csd_repair_order_groups
         set received_quantity = nvl(received_quantity ,0) + nvl(x_update_count,0)
         where repair_group_id = grp.repair_group_id ;

     END IF;

    --END IF;

    ELSIF grp.repair_type_ref in ('RR','E','WR') THEN

      --IF grp.group_txn_status = 'OM_RELEASED' then

         -- Calling Group_ship_update to update
         -- all the RO that have been recd
         Group_ship_update
          ( p_api_version         => p_api_version,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_repair_group_id     => grp.repair_group_id,
            x_update_count        => x_update_count,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data );

IF (g_debug > 0 ) THEN
       csd_gen_utility_pvt.add('grp.shipped qty  ='||grp.shipped_quantity );
END IF;

IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('x_update_count   ='||x_update_count );
END IF;


        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Group_ship_update failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;

      IF nvl(grp.shipped_quantity,0) + nvl(x_update_count,0) = grp.repair_order_quantity then
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('updating group txn status');
END IF;


         -- Update txn_status and rcvd qty
         Update csd_repair_order_groups
         set shipped_quantity = nvl(shipped_quantity ,0) + nvl(x_update_count,0),
             group_txn_status  = 'OM_SHIPPED'
         where repair_group_id = grp.repair_group_id ;

     ELSIF nvl(x_update_count,0) > 0 THEN
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('updating only shipped qty');
END IF;

         -- Update txn_status and rcvd qty
         Update csd_repair_order_groups
         set shipped_quantity = nvl(shipped_quantity ,0) + nvl(x_update_count,0)
         where repair_group_id = grp.repair_group_id ;
     END IF;

    --END IF;

    ELSIF grp.repair_type_ref in ('ARR','WRL') THEN

     -- IF grp.group_txn_status = 'OM_RELEASED' then

         -- Calling Group_ship_update to update
         -- all the RO that have been recd
         Group_ship_update
          ( p_api_version         => p_api_version,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_repair_group_id     => grp.repair_group_id,
            x_update_count        => x_update_count,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data );

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('grp.shipped qty  ='||grp.shipped_quantity );
END IF;

IF (g_debug > 0 ) THEN
           csd_gen_utility_pvt.add('x_update_count   ='||x_update_count );
END IF;


        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Group_ship_update failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
          END IF;

        IF nvl(grp.shipped_quantity,0) + nvl(x_update_count,0) = grp.repair_order_quantity then

IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('updating group txn status');
END IF;

         -- Update txn_status and rcvd qty
         Update csd_repair_order_groups
         set shipped_quantity = nvl(shipped_quantity ,0) + nvl(x_update_count,0),
             group_txn_status  = 'OM_SHIPPED'
         where repair_group_id = grp.repair_group_id ;

       ELSIF nvl(x_update_count,0) > 0 THEN
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('updating only shipped qty');
END IF;

         -- Update txn_status and rcvd qty
         Update csd_repair_order_groups
         set shipped_quantity = nvl(shipped_quantity ,0) + nvl(x_update_count,0)
         where repair_group_id = grp.repair_group_id ;

       END IF;

         -- Calling Group_Rma_Update to update
         -- all the loaner that have been recd
         Group_Rma_Update
          ( p_api_version         => p_api_version,
            p_commit              => fnd_api.g_false,
            p_init_msg_list       => fnd_api.g_true,
            p_validation_level    => fnd_api.g_valid_level_full,
            p_repair_group_id     => grp.repair_group_id,
            x_update_count        => x_update_count,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data );

        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Group_rma_update failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
          END IF;

     -- END IF;

   END IF; -- end if repair_type_ref

  END LOOP; -- end of all groups

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Post_process_update;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Post_process_update ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Post_process_update ;
              IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                  FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
              END IF;
                  FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END Post_process_update;

/*--------------------------------------------------*/
/* procedure name: Group_Rma_Update                 */
/* description   : procedure used to apply contract */
/*                                                  */
/*--------------------------------------------------*/

procedure Group_Rma_Update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_repair_group_id       IN     NUMBER,
  x_update_count          OUT NOCOPY    NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
  ) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Group_Rma_Update';
  l_api_version       CONSTANT NUMBER         := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(100);
  l_msg_index         NUMBER;

  v_repair_history_id number;
  l_return_status     varchar2(1);
  p_rep_hist_id       number;
  p_result_quantity   number;
  l_repair_number     VARCHAR2(30);
  l_repair_line_id    NUMBER;
  l_txn_billing_type_id NUMBER;
  v_total_records     number :=0;
  l_ib_flag           varchar2(1);
  l_instance_id       number := null;

  -- travi fix
  l_incident_id       number;
  l_account_id        number;
  l_customer_id       number;

CURSOR get_rma_lines (p_rep_group_id in number) IS
Select
     cr.incident_id,         -- travi
     cr.repair_group_id,
     ced.order_header_id,
     ced.order_line_id,
     ced.txn_billing_type_id,
     cpt.product_transaction_id,
     cpt.action_code,
    ooh.order_number rma_number,
     ool.line_number rma_line_number,
     ool.line_type_id,
     cr.repair_line_id,
     cr.repair_number,
     rcv.organization_id,
     cr.inventory_item_id,
     rcv.unit_of_measure,
     rcv.transaction_date received_date,
     rcv.transaction_id transaction_id,
     rcv.quantity received_quantity,
     rcv.subinventory,
     rcv.last_updated_by who_col,
     rcv.oe_order_header_id rma_header_id,
    rst.serial_num serial_number
from csd_repairs cr,
     csd_product_transactions cpt,
     cs_estimate_details ced,
     rcv_transactions rcv,
    rcv_serial_transactions rst,
     oe_order_headers_all ooh,
     oe_order_lines_all ool,
     cs_txn_billing_types ctbt,
     cs_transaction_types_b ctt
where cr.repair_line_id    = cpt.repair_line_id
 and  cpt.estimate_detail_id = ced.estimate_detail_id
 and  ced.txn_billing_type_id = ctbt.txn_billing_type_id
 and  ctbt.transaction_type_id = ctt.transaction_type_id
 and  ctt.depot_Repair_flag = 'Y'
 and  cpt.action_type in ('RMA','WALK_IN_RECEIPT')
 and  ced.original_source_code = 'DR'
 and  cr.repair_group_id = p_rep_group_id
 and  rcv.oe_order_line_id = ced.order_line_id
 and  rcv.transaction_id = rst.transaction_id(+)
 and  rcv.oe_order_line_id = ool.line_id
 and  ool.header_id = ooh.header_id
 and  rcv.transaction_type = 'DELIVER'
 and  rcv.source_document_code = 'RMA'
 and  rcv.transaction_id NOT IN
       (SELECT paramn1
         FROM csd_Repair_history crh,
              csd_repairs cra
         WHERE crh.repair_line_id = cra.repair_line_id
          AND  crh.event_code = 'RR'
          AND  cra.repair_group_id = p_rep_group_id );

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT  Group_Rma_Update;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME    )
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Api body starts
   if (g_debug > 0) then
   csd_gen_utility_pvt.dump_api_info
   ( p_pkg_name  => G_PKG_NAME,
     p_api_name  => l_api_name );
end if;
 v_total_records := 0;

 FOR C1 in get_rma_lines (p_repair_group_id )
 LOOP

        -- convert to primary UOM
        csd_depot_repair_cntr.convert_to_primary_uom
        (C1.inventory_item_id,
         C1.organization_id,
         C1.unit_of_measure,
         C1.received_quantity,
         p_result_quantity);

IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('p_result_quantity='|| p_result_quantity);
END IF;


      IF C1.action_code <> 'LOANER' THEN

        -- Update csd_repairs with txn_status
        -- and the rscd_qty
IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('Before update csd_repairs');
END IF;


         update csd_repairs
         set quantity_rcvd = nvl(quantity_rcvd,0)+ nvl(p_result_quantity,0),
             ro_txn_status = 'OM_RECEIVED'
         where repair_line_id = C1.repair_line_id;

IF (g_debug > 0 ) THEN
        csd_gen_utility_pvt.add('After update csd_repairs');
END IF;

        END IF;

       IF  C1.serial_number is not null then

        Begin

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('Before select ib_flag');
END IF;


          select
          comms_nl_trackable_flag
          into l_ib_flag
          from mtl_system_items
        where inventory_item_id = C1.inventory_item_id
         and  organization_id = C1.organization_id
           and rownum < 2;  -- travi

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('After select ib_flag');
END IF;


         Exception
          When No_data_found then
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Invalid Inv item Id ');
END IF;

              fnd_message.set_name('CSD','CSD_INVALID_ITEM_ID');
              fnd_message.set_token('INVENTORY_ITEM_ID',C1.inventory_item_id);
              fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
        End;

         IF l_ib_flag = 'Y' THEN

           Begin

IF (g_debug > 0 ) THEN
              csd_gen_utility_pvt.add('Serial number : '||C1.serial_number);
END IF;

IF (g_debug > 0 ) THEN
              csd_gen_utility_pvt.add('inventory_item_id : '||C1.inventory_item_id);
END IF;


              -- travi fix for muliple rows picked for inctance id problem
IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.add('Before select account_id,  customer_id');
END IF;

              select account_id,  customer_id
                into l_account_id, l_customer_id
                from csd_incidents_v
                where incident_id = C1.incident_id;

IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.add('After select account_id,  customer_id');
END IF;

              -- travi fix for muliple rows picked for inctance id problem
             Exception
            When No_data_found then
IF (g_debug > 0 ) THEN
             csd_gen_utility_pvt.ADD('No data found for the incident id');
END IF;

           End;

           Begin

IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.add('Before select instance_id');
END IF;


            Select instance_id
             into  l_instance_id
             from csi_item_instances
             where serial_number = C1.serial_number
             and  inventory_item_id = C1.inventory_item_id
             and  trunc(sysdate) between trunc(nvl(active_start_date,sysdate))
             and  trunc(nvl(active_end_date,sysdate))
                and owner_party_account_id = nvl(l_account_id, owner_party_account_id)  -- sr.account_id
                and owner_party_id = l_customer_id;  -- sr.customer_id

IF (g_debug > 0 ) THEN
               csd_gen_utility_pvt.add('After select instance_id');
END IF;


             Exception
            When No_data_found then
IF (g_debug > 0 ) THEN
             csd_gen_utility_pvt.ADD('Invalid Serial Number ');
END IF;

               fnd_message.set_name('CSD','CSD_INVALID_SERIAL_NUMBER');
               fnd_message.set_token('SERIAL_NUMBER',C1.serial_number );
               fnd_msg_pub.add;
             RAISE FND_API.G_EXC_ERROR;
           End;

         -- Update csd_repairs with txn_status
          -- and the rscd_qty
          update csd_repairs
          set serial_number = C1.serial_number ,
            customer_product_id = l_instance_id
          where repair_line_id = C1.repair_line_id;

        Else

        -- Update csd_repairs with txn_status
          -- and the rscd_qty
          update csd_repairs
          set serial_number = C1.serial_number
          where repair_line_id = C1.repair_line_id;

        End If;

        END IF;

        -- Update the prod txns withe the status
        Update csd_product_transactions
       set prod_txn_status = 'RECEIVED'
       where product_transaction_id = C1.product_transaction_id;

         fnd_message.set_name('CSD','CSD_DRC_RMA_RECEIPT');
         fnd_message.set_token('RMA_NO',C1.rma_number);
         fnd_message.set_token('REP_NO',C1.repair_number);
         fnd_message.set_token('QTY_RCVD',to_char(C1.received_quantity));
IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add(fnd_message.get);
END IF;


IF (g_debug > 0 ) THEN
         csd_gen_utility_pvt.add('Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write ');
END IF;


         CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
            P_Api_Version_Number       => 1.0,
            P_Init_Msg_List            => 'T',
            P_Commit                   => 'F',
            p_validation_level         => null,
            p_action_code              => 0  ,
            px_REPAIR_HISTORY_ID       => p_rep_hist_id,
            p_OBJECT_VERSION_NUMBER    => null,
            p_REQUEST_ID               => null,
            p_PROGRAM_ID               => null,
            p_PROGRAM_APPLICATION_ID   => null,
            p_PROGRAM_UPDATE_DATE      => null,
            p_CREATED_BY       =>  FND_GLOBAL.USER_ID,
            p_CREATION_DATE    => sysdate,
            p_LAST_UPDATED_BY  =>  FND_GLOBAL.USER_ID,
            p_LAST_UPDATE_DATE => sysdate,
            p_REPAIR_LINE_ID   => C1.repair_line_id,
            p_EVENT_CODE       => 'RR',
            p_EVENT_DATE       => C1.received_date,
            p_QUANTITY         => C1.received_quantity,
            p_PARAMN1          => C1.transaction_id,
            p_PARAMN2          => C1.rma_line_number,
            p_PARAMN3          => C1.line_type_id,
            p_PARAMN4          => C1.txn_billing_type_id,
            p_PARAMN5          => C1.who_col,
            p_PARAMN6          => C1.rma_header_id,
            p_PARAMN7          => null,
            p_PARAMN8          => null,
            p_PARAMN9          => null,
            p_PARAMN10         => null,
            p_PARAMC1          => C1.subinventory,
            p_PARAMC2          => C1.rma_number,
            p_PARAMC3          => null,
            p_PARAMC4          => null,
            p_PARAMC5          => null,
            p_PARAMC6          => null,
            p_PARAMC7          => null,
            p_PARAMC8          => null,
            p_PARAMC9          => null,
            p_PARAMC10         => null,
            p_PARAMD1          => null,
            p_PARAMD2          => null,
            p_PARAMD3          => null,
            p_PARAMD4          => null,
            p_PARAMD5          => null,
            p_PARAMD6          => null,
            p_PARAMD7          => null,
            p_PARAMD8          => null,
            p_PARAMD9          => null,
            p_PARAMD10         => null,
            p_ATTRIBUTE_CATEGORY => null,
            p_ATTRIBUTE1         => null,
            p_ATTRIBUTE2         => null,
            p_ATTRIBUTE3         => null,
            p_ATTRIBUTE4         => null,
            p_ATTRIBUTE5         => null,
            p_ATTRIBUTE6         => null,
            p_ATTRIBUTE7         => null,
            p_ATTRIBUTE8         => null,
            p_ATTRIBUTE9         => null,
            p_ATTRIBUTE10        => null,
            p_ATTRIBUTE11        => null,
            p_ATTRIBUTE12        => null,
            p_ATTRIBUTE13        => null,
            p_ATTRIBUTE14        => null,
            p_ATTRIBUTE15        => null,
            p_LAST_UPDATE_LOGIN  => FND_GLOBAL.LOGIN_ID,
            X_Return_Status      => l_return_status  ,
            X_Msg_Count          => l_msg_count,
            X_Msg_Data           => l_msg_data        );

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write l_return_status'||l_return_status);
END IF;

IF (g_debug > 0 ) THEN
          csd_gen_utility_pvt.add('Successfully completed Depot RMA receipt update ');
END IF;


        IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('validate_and_write failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
          END IF;

        v_total_records := v_total_records + 1;

 End loop;

 fnd_message.set_name('CSD','CSD_DRC_WIP_TOT_REC_PROC');
 fnd_message.set_token('TOT_REC',to_char(v_total_records));
IF (g_debug > 0 ) THEN
 csd_gen_utility_pvt.add(fnd_message.get);
END IF;


 -- Return the count of number of records updated
 x_update_count := v_total_records ;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Group_Rma_Update;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Group_Rma_Update ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Group_Rma_Update ;
              IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                  FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
              END IF;
                  FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );
END Group_Rma_Update;

/*--------------------------------------------------*/
/* procedure name: Group_ship_update                */
/* description   : procedure used to apply contract */
/*                                                  */
/*--------------------------------------------------*/

procedure Group_ship_update
( p_api_version           IN     NUMBER,
  p_commit                IN     VARCHAR2  := fnd_api.g_false,
  p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
  p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
  p_repair_group_id       IN     number,
  x_update_count          OUT NOCOPY    NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2

 ) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Group_ship_update';
  l_api_version            CONSTANT NUMBER         := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(100);
  l_msg_index              NUMBER;

  v_total_records number;
  v_repair_history_id number;
  l_return_status varchar2(1);
  l_rep_hist_id number;
  p_result_ship_quantity number;
  l_pt_serial_num varchar2(30);


  Cursor DEPOT_SHIPMENT_LINES ( p_rep_group_id number) is
  Select
    dd.serial_number sl_number,
    cra.quantity qty,
    cpt.product_transaction_id,
    cpt.action_code,
    oeh.order_number order_number,
    oeh.header_id sales_order_header,
    oel.line_number order_line_number,
    oel.line_type_id,
    cra.repair_number,
    cra.repair_line_id,
    ced.txn_billing_type_id,
    dd.requested_quantity,
    dd.shipped_quantity,
    dl.initial_pickup_date date_shipped,
    dd.delivery_detail_id,
    dd.requested_quantity_uom shipped_uom_code,
    mtlu.unit_of_measure shipped_uom,
    dd.inventory_item_id ,
    dd.organization_id
  from
    csd_Repairs cra,
    csd_product_transactions cpt,
    cs_estimate_details ced,
    wsh_new_deliveries  dl,
    wsh_delivery_assignments da,
    wsh_delivery_details dd ,
    oe_order_headers_all oeh,
    oe_order_lines_all oel,
    mtl_units_of_measure mtlu
  Where cra.repair_group_id = p_rep_group_id
    and cra.repair_line_id   = cpt.repair_line_id
    and cpt.estimate_detail_id = ced.estimate_detail_id
    and ced.original_source_code = 'DR'
    and dd.delivery_detail_id   = da.delivery_detail_id
    and da.delivery_id      = dl.delivery_id(+)
    and ced.order_line_id   = oel.line_id
    and oel.header_id       = oeh.header_id
    and dd.source_header_id = ced.order_header_id
    and dd.source_line_id   = ced.order_line_id
    and dd.released_status  = 'C'
    and dd.delivery_detail_id not in
     (select paramn1
      from csd_Repair_history
      where repair_line_id = cra.repair_line_id
        and event_code='PS')
    and mtlu.uom_code = dd.requested_quantity_uom;

Begin

   -- Standard Start of API savepoint
   SAVEPOINT  Group_ship_update;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name   ,
                                       G_PKG_NAME    )
   THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (g_debug > 0 ) THEN
   csd_gen_utility_pvt.add('at the begin Group_ship_update');
END IF;


   -- Api body starts
   if (g_debug > 0) then
   csd_gen_utility_pvt.dump_api_info
   ( p_pkg_name  => G_PKG_NAME,
     p_api_name  => l_api_name );
end if;
   v_total_records := 0;

   For I in depot_shipment_lines(p_repair_group_id)
   LOOP

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('Calling the convert to primary uom ');
END IF;


    csd_depot_repair_cntr.convert_to_primary_uom
    (i.inventory_item_id,
     i.organization_id,
     i.shipped_uom,
     i.shipped_quantity,
     p_result_ship_quantity);

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add(' p_result_ship_quantity= '|| p_result_ship_quantity);
END IF;


   IF I.action_code <> 'LOANER' THEN

    -- Update the csd_repairs table
     update csd_repairs
     set quantity_shipped = nvl(quantity_shipped,0)+nvl(p_result_ship_quantity,0),
         ro_txn_status    = 'RO_SHIPPED'
     where repair_line_id = I.repair_line_id;
   END IF;

    -- Update csd_product_transactions table with the status
    update csd_product_transactions
    set prod_txn_status= 'SHIPPED'
    where product_transaction_id = I.product_transaction_id;

IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('Updated csd_repairs table');
END IF;


    fnd_message.set_name('CSD','CSD_DRC_QTY_SHIPPED');
    fnd_message.set_token('ORDER_NO',i.order_number);
    fnd_message.set_token('REP_NO',i.repair_number);
    fnd_message.set_token('QTY_SHIP',to_char(p_result_ship_quantity));
IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add(fnd_message.get);
END IF;


IF (g_debug > 0 ) THEN
    csd_gen_utility_pvt.add('Calling CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write');
END IF;


    CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write (
      P_Api_Version_Number => 1.0,
      P_Init_Msg_List      => 'T',
      P_Commit             => 'F',
      p_validation_level   => null,
      p_action_code        => 0  ,
      px_REPAIR_HISTORY_ID => l_rep_hist_id,
      p_OBJECT_VERSION_NUMBER => null,
      p_REQUEST_ID         => null,
      p_PROGRAM_ID         => null,
      p_PROGRAM_APPLICATION_ID  => null,
      p_PROGRAM_UPDATE_DATE  => null,
      p_CREATED_BY         => FND_GLOBAL.USER_ID,
      p_CREATION_DATE      => sysdate,
      p_LAST_UPDATED_BY    => FND_GLOBAL.USER_ID,
      p_LAST_UPDATE_DATE   => sysdate,
      p_REPAIR_LINE_ID     => I.repair_line_id,
      p_EVENT_CODE         => 'PS',
      p_EVENT_DATE         => I.date_shipped,
      p_QUANTITY           => p_result_ship_quantity,
      p_PARAMN1    => i.delivery_detail_id,
      p_PARAMN2    => i.order_line_number,
      p_PARAMN3    => i.line_type_id,
      p_PARAMN4    => i.txn_billing_type_id,
      p_PARAMN5    => null,
      p_PARAMN6    => null,
      p_PARAMN7    => null,
      p_PARAMN8    => null,
      p_PARAMN9    => null,
      p_PARAMN10   => null,
      p_PARAMC1    => null,
      p_PARAMC2    => i.order_number,
      p_PARAMC3    => null,
      p_PARAMC4    => null,
      p_PARAMC5    => null,
      p_PARAMC6    => null,
      p_PARAMC7    => null,
      p_PARAMC8    => null,
      p_PARAMC9    => null,
      p_PARAMC10   => null,
      p_PARAMD1    => null,
      p_PARAMD2    => null,
      p_PARAMD3    => null,
      p_PARAMD4    => null,
      p_PARAMD5    => null,
      p_PARAMD6    => null,
      p_PARAMD7    => null,
      p_PARAMD8    => null,
      p_PARAMD9    => null,
      p_PARAMD10   => null,
      p_ATTRIBUTE_CATEGORY  => null,
      p_ATTRIBUTE1    => null,
      p_ATTRIBUTE2    => null,
      p_ATTRIBUTE3    => null,
      p_ATTRIBUTE4    => null,
      p_ATTRIBUTE5    => null,
      p_ATTRIBUTE6    => null,
      p_ATTRIBUTE7    => null,
      p_ATTRIBUTE8    => null,
      p_ATTRIBUTE9    => null,
      p_ATTRIBUTE10   => null,
      p_ATTRIBUTE11   => null,
      p_ATTRIBUTE12   =>null,
      p_ATTRIBUTE13   => null,
      p_ATTRIBUTE14   => null,
      p_ATTRIBUTE15   => null,
      p_LAST_UPDATE_LOGIN  => FND_GLOBAL.LOGIN_ID,
      X_Return_Status => l_return_status  ,
      X_Msg_Count     => l_msg_count,
      X_Msg_Data      => l_msg_data   );

IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.add('after CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write l_return_status'||l_return_status);
END IF;

IF (g_debug > 0 ) THEN
      csd_gen_utility_pvt.add('Successfully completed Depot repair Shipping Update');
END IF;


      v_total_records := v_total_records + 1;
    IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Validate_and_write failed ');
END IF;

            RAISE FND_API.G_EXC_ERROR;
     END IF;

  End loop;

  fnd_message.set_name('CSD','CSD_DRC_SHIP_TOTAL_REC_PROC');
  fnd_message.set_token('TOT_REC',to_char(v_total_records));
IF (g_debug > 0 ) THEN
  csd_gen_utility_pvt.add(fnd_message.get);
END IF;


  x_update_count := v_total_records;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Group_ship_update;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get
                (p_count  =>  x_msg_count,
                 p_data   =>  x_msg_data  );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Group_ship_update ;
          FND_MSG_PUB.Count_And_Get
                ( p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO Group_ship_update ;
              IF  FND_MSG_PUB.Check_Msg_Level
                  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
              THEN
                  FND_MSG_PUB.Add_Exc_Msg
                  (G_PKG_NAME ,
                   l_api_name  );
              END IF;
                  FND_MSG_PUB.Count_And_Get
                  (p_count  =>  x_msg_count,
                   p_data   =>  x_msg_data );

 End Group_ship_update;

End CSD_DEPOT_UPDATE_PVT;

/
