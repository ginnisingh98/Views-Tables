--------------------------------------------------------
--  DDL for Package Body EAM_UTILITY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_UTILITY_GRP" AS
/* $Header: EAMGUTLB.pls 120.0 2005/06/22 14:10:21 amondal noship $ */
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'EAM_UTILITY_GRP';
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMGUTLB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_UTILITY_GRP
--
--  NOTES
--
--  HISTORY
--
--  16-MAY-2005   Anju Gupta      Initial Creation
***************************************************************************/

--------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Get_ReplacedRebuilds                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API is used to determine the list of rebuildables that were     --
--   replaced from a  work order while executing the work order.          --
--                                                                        --
--   It can be invoked from within any product in Oracle Applications.    --
--   Currently IB team will invoke it while processing completion of      --
--   EAM work orders to build the genealogy correctly.                    --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 12                                           --
--                                                                        --
-- HISTORY:                                                               --
--    05/16/05     Anju Gupta       Created                               --
----------------------------------------------------------------------------

PROCEDURE Get_ReplacedRebuilds (

                  p_api_version      IN  NUMBER,
                  p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                  p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                  p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,

                  p_wip_entity_id   	    IN         number,
                  p_organization_id         IN         number,

                  x_replaced_rebuild_tbl    OUT nocopy EAM_UTILITY_GRP.REPLACE_REBUILD_tbl_type,
                  x_return_status           OUT nocopy varchar2,
                  x_msg_count               OUT NOCOPY  NUMBER,
                  x_msg_data                OUT NOCOPY  VARCHAR2) IS

 l_api_name    CONSTANT       VARCHAR2(30) := 'Get_ReplacedRebuilds';
 l_api_version CONSTANT       NUMBER       := 1.0;

 l_api_message                VARCHAR2(10000);

 l_msg_count                 NUMBER := 0;
 l_msg_data                  VARCHAR2(8000) := '';


 l_stmt_num                  NUMBER   := 0;
 l_entity_type               NUMBER   := 0;
 l_cnt                       NUMBER   := 0;

 l_replacerebuild_rec        EAM_UTILITY_GRP.REPLACE_REBUILD_rec_type;


    CURSOR c_rebuilds IS

            select wdj.maintenance_object_id
            from WIP_DISCRETE_JOBS wdj
            where wdj.parent_wip_entity_id = p_wip_entity_id
            and wdj.organization_id = p_organization_id
            and wdj.manual_rebuild_flag = 'N'
            and wdj.maintenance_object_type = 3;


Begin

    -------------------------------------------------------------------------
    -- Establish savepoint
    -------------------------------------------------------------------------

    SAVEPOINT ReplacedRebuild_GRP;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

   ---------------------------------------------------------------------------
   -- Initialize message list if p_init_msg_list is set to TRUE
   ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------

      l_stmt_num := 10;
      x_return_status := fnd_api.g_ret_sts_success;

    -------------------------------------------------------------------------
    -- Validate parameters passed to the API
    -------------------------------------------------------------------------

       SELECT  entity_type
       INTO    l_entity_type
       FROM    wip_entities we
       WHERE   we.wip_entity_id = p_wip_entity_id
       and     we.organization_id = p_organization_id;

       IF (l_entity_type NOT IN (6,7)) THEN

          l_api_message := l_api_message|| 'Invalid WIP entity type: '
                      ||TO_CHAR(l_entity_type)
                      ||' WIP Entity: '
                      ||TO_CHAR(p_wip_entity_id);

          FND_MSG_PUB.ADD_EXC_MSG('EAM_UTILITY_GRP', 'Get_ReplacedRebuild('
                                     ||TO_CHAR(l_stmt_num)
                                     ||'): ', l_api_message);
          RAISE FND_API.g_exc_error;
       END IF;

    -------------------------------------------------------------------------
    -- Initialize common variables
    -------------------------------------------------------------------------

     l_stmt_num := 20;


     l_cnt := 1;

    -------------------------------------------------------------------------
    -- Get the Replaced Rebuilds for the Work Order
    -------------------------------------------------------------------------

     l_stmt_num := 30;

    FOR c_rebuilds_rec IN c_rebuilds
    LOOP

           l_replacerebuild_rec.instance_id := c_rebuilds_rec.maintenance_object_id;

           x_replaced_rebuild_tbl(l_cnt) := l_replacerebuild_rec;

           l_cnt := l_cnt + 1;

    END LOOP;

        l_stmt_num := 50;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );

   EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'EAM_UTILITY_GRP'
              , 'Get_ReplacedRebuilds : l_stmt_num - '||to_char(l_stmt_num)
              );

     END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );


end Get_ReplacedRebuilds;



/********************************************
 *Get Next Maintenance Date for an Equipment*
 *based on EAM work orders in the system
 ****************************************/

FUNCTION get_next_maintenance_date( p_organization_id IN NUMBER,
				    p_resource_id IN NUMBER,
				    p_gen_object_id IN NUMBER) RETURN DATE IS

l_maint_date DATE;
BEGIN
 if (p_gen_object_id is not null) then

      	select min(wdj.scheduled_start_date) as NEXT_MAINT_DATE
        into l_maint_date
	from wip_discrete_jobs wdj, wip_entities we, csi_item_instances cii, wip_operations wo
	where we.entity_type = 6
	and wdj.wip_entity_id = we.wip_entity_id
	and wdj.organization_id = we.organization_id
	and wdj.maintenance_object_type = 3
	and wdj.maintenance_object_id = cii.instance_id
	and wdj.organization_id = cii.last_vld_organization_id
	and cii.equipment_gen_object_id = p_gen_object_id
	and wdj.organization_id = wo.organization_id (+)
	and wdj.wip_entity_id = wo.wip_entity_id (+)
	and wdj.status_type in (1,3,17)
	and (nvl(wdj.shutdown_type,1) > 1 OR  nvl(wo.shutdown_type,1) > 1 )
	and wdj.scheduled_start_date > sysdate;

 end if;

RETURN  l_maint_date;

EXCEPTION
    WHEN OTHERS THEN
      RETURN l_maint_date;


END;

END  EAM_UTILITY_GRP;

/
