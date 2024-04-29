--------------------------------------------------------
--  DDL for Package Body EAM_WO_NETWORK_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_NETWORK_DEFAULT_PVT" AS
/* $Header: EAMVWNDB.pls 120.4.12010000.3 2009/11/05 21:17:39 mashah ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWNDB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_NETWORK_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  11-SEP-2003    Basanth Roy     Initial Creation
--  29-Sep-2003    samjain         modified the resize_wo procedure to call the
                                   process master child procedure for updating the workorder.
***************************************************************************/



G_Pkg_Name      VARCHAR2(30) := 'EAM_WO_NETWORK_DEFAULT_PVT';

g_token_tbl     EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
g_dummy         NUMBER;


    /*******************************************************************
    * Procedure	: Add_WO_To_Network
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY:
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	:
    *********************************************************************/
    PROCEDURE Add_WO_To_Network
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_child_object_id                     IN      NUMBER,
        p_child_object_type_id                IN      NUMBER,
        p_parent_object_id              IN      NUMBER,
        p_parent_object_type_id         IN      NUMBER,
        p_adjust_parent                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_relationship_type             IN      NUMBER := 1,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2,
        x_mesg_token_tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        )


    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Add_WO_To_Network';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_work_object_id            NUMBER;
    l_work_object_type_id       NUMBER;

    l_stmt_num                  NUMBER;
    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);

    l_exception_msg             VARCHAR2(1000);

    l_count                     NUMBER;
    l_child_status_type         NUMBER;
    l_parent_status_type        NUMBER;
    l_first_constraining_parent NUMBER;
    l_first_constr_parent_type NUMBER;
    l_sched_relationship_id     NUMBER;
    l_wo_relationship_id     NUMBER;
    l_top_level_object_id       NUMBER;
    l_top_level_object_type_id  NUMBER;
    l_relationship_status       NUMBER := 0; -- pending validation

    l_parent_maint_obj_src      NUMBER := 1;
    l_child_maint_obj_src       NUMBER := 1;
    l_maint_obj_src             NUMBER := 1;
    l_rebuild_item_id           NUMBER := null;

    TYPE l_relationship_records IS REF CURSOR RETURN WIP_SCHED_RELATIONSHIPS%ROWTYPE;
    l_constraining_parents      l_relationship_records;
    l_constraining_children     l_relationship_records;
    l_relationship_record       WIP_SCHED_RELATIONSHIPS%ROWTYPE;

    l_child_object_id                 NUMBER   := p_child_object_id;
    l_child_object_type_id            NUMBER   := p_child_object_type_id;
    l_parent_object_id          NUMBER   := p_parent_object_id;
    l_parent_object_type_id     NUMBER   := p_parent_object_type_id;
    l_adjust_parent             VARCHAR2(30) := p_adjust_parent;
    l_relationship_type         NUMBER   := p_relationship_type;
    l_parent_firm_flag          NUMBER;

    invalid_values exception;

    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_other_message         VARCHAR2(20000);
        l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_old_eam_wo_rec        EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
        l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type       ;
        l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type  ;
        l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type   ;
        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
        l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type   ;

	l_parent_workorder	VARCHAR2(240);
	l_child_workorder	VARCHAR2(240);
	l_wo_relationship_exc_tbl EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type;
   BEGIN

	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WN_ADD_WO;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body


    x_return_status := l_return_status;


  SELECT wip_entity_name into l_parent_workorder
	 FROM  wip_entities we
	 WHERE we.wip_entity_id = l_parent_object_id;

  SELECT wip_entity_name into l_child_workorder
	 FROM  wip_entities we
	 WHERE we.wip_entity_id = l_child_object_id;

    -- Validations for input parameters

    -- Check for null values
    if l_child_object_id             is null or
       l_child_object_type_id        is null or
       l_parent_object_id      is null or
       l_parent_object_type_id is null then


     l_out_mesg_token_tbl  := l_mesg_token_tbl;
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
        (  p_message_name  => 'EAM_WN_NOT_NULL'
         , p_token_tbl     => l_token_tbl
         , p_mesg_token_tbl     => l_mesg_token_tbl
         , x_mesg_token_tbl     => l_out_mesg_token_tbl
      );
      l_mesg_token_tbl := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;

    -- Check that the Child and parent do not already have
    -- a relation.
    -- I am commenting this out because as per latest design
    -- on 08/26/2003, we can have 2 relationships for the same
    -- set of work orders. For eg. type 1 and 3
    /*select count(*) into l_count
      from eam_wo_relationships where
      child_object_id = l_child_object_id
      and child_object_type_id = l_child_object_type_id
      and parent_object_id = l_parent_object_id
      and parent_object_type_id = l_parent_object_type_id;
    if l_count <> 0 then
      x_return_status := 'E';
      return;
    end if;
    */

    -- Check that the parent_object_id and child_object_id are
    -- valid wip_entity_id s. And if they are, then get their sources
   begin
    select status_type into l_child_status_type
      from wip_discrete_jobs where
      wip_entity_id = l_child_object_id;
   exception
      WHEN NO_DATA_FOUND THEN

    l_token_tbl(1).token_name  := 'Child Object Id';
    l_token_tbl(1).token_value :=  l_child_object_id;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_CHILD_OBJECT_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
  end;

      select maintenance_object_source into
        l_child_maint_obj_src
        from wip_discrete_jobs where
        wip_entity_id = l_child_object_id;


  begin
    select status_type into l_parent_status_type
      from wip_discrete_jobs where
      wip_entity_id = l_parent_object_id;

   exception
      WHEN NO_DATA_FOUND THEN
    l_token_tbl(1).token_name  := 'Parent Object Id';
    l_token_tbl(1).token_value :=  l_parent_object_id;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_PARENT_OBJECT_ID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );

    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
  end ;

       select maintenance_object_source, rebuild_item_id into
        l_parent_maint_obj_src, l_rebuild_item_id
        from wip_discrete_jobs where
        wip_entity_id = l_parent_object_id;


    if l_parent_maint_obj_src <> l_child_maint_obj_src then

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_ADD_MAINT_OBJ_SRC'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl  := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;

    -- Check that the Child does not already have an existing relation
    -- of the same type that is being created currently.
    if l_parent_maint_obj_src = 1 then -- EAM
      select count(*) into l_count
        from eam_wo_relationships where
        child_object_id = l_child_object_id
        and child_object_type_id = l_child_object_type_id
        and parent_relationship_type = l_relationship_type;
    elsif l_parent_maint_obj_src = 2 then -- CMRO
      select count(*) into l_count
        from wip_sched_relationships where
        child_object_id = l_child_object_id
        and child_object_type_id = l_child_object_type_id
        and relationship_type = l_relationship_type;
    end if;

    if l_count <> 0 then

    l_token_tbl(1).token_name  := 'Child Object Id';
    l_token_tbl(1).token_value :=  l_child_object_id;
    l_token_tbl(2).token_name  := 'Rel Type';
    l_token_tbl(2).token_value :=  l_relationship_type;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_DUPLICATE_REL'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;

    --fix for 3572050.should not have cancelled workorders in any hierarchy
    IF(l_child_status_type=7 or l_parent_status_type=7) then
      EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_CANCEL_NOT_ALLOWED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

   --fix for 3433757.added validation so that relationships can't be created if either
   --the parent or the child workorders are in following statuses
   -- Closed,Pending-close,Failed-close
     IF ((l_child_status_type in (12,14,15) or
       l_parent_status_type  in (12,14,15)) and
       l_relationship_type =1) THEN


     l_token_tbl(1).token_name  := 'PARENT';
     l_token_tbl(1).token_value :=  l_parent_object_id;
     l_token_tbl(2).token_name  := 'CHILD';
     l_token_tbl(2).token_value :=  l_child_object_id;


    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_CH_PAR_INVALID'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;



    -- Get some common variables
    -- 1. top_level_object_id
    select count(*) into l_count
      from wip_sched_relationships
      where child_object_id = l_parent_object_id
      and child_object_type_id = l_parent_object_type_id
      and relationship_type = 1;
    IF l_count = 0 THEN -- Adding directly to topmost node
      l_top_level_object_id      := l_parent_object_id;
      l_top_level_object_type_id := l_parent_object_type_id;
    ELSE
      select distinct top_level_object_id, top_level_object_type_id
        into l_top_level_object_id , l_top_level_object_type_id
        from wip_sched_relationships
        where child_object_id = l_parent_object_id
        and child_object_type_id = l_parent_object_type_id;
    END IF;


    -- Check if new relationship is type 1 or 3.
    if l_relationship_type = 3 then

      if l_parent_maint_obj_src <> 1 then -- type 3 can only be for EAM

    l_token_tbl(1).token_name  := 'Parent Object Id';
    l_token_tbl(1).token_value :=  l_parent_object_id;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_PARENT_NON_EAM'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

        x_return_status := 'E';
        return;
      end if;

      -- insert the type 3 relationship first
      select eam_wo_relationships_s.nextval
        into l_wo_relationship_id from dual;
      insert into eam_wo_relationships
        (        wo_relationship_id,
                 parent_object_id,
                 parent_object_type_id,
                 child_object_id,
                 child_object_type_id,
                 parent_relationship_type,
                 relationship_status,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 top_level_object_id,
                 top_level_object_type_id
        ) values
        (        l_wo_relationship_id,
                 l_parent_object_id,
                 l_parent_object_type_id,
                 l_child_object_id,
                 l_child_object_type_id,
                 3,
                 l_relationship_status,
                 l_created_by,
                 sysdate,
                 l_last_updated_by,
                 sysdate,
                 null,--l_top_level_object_id,
                 null--l_top_level_object_type_id
        );


    elsif l_relationship_type = 1 then

        wip_sched_relation_grp.insertRow(
                  p_parentObjectID      => l_parent_object_id,
                  p_parentObjectTypeID  => l_parent_object_type_id,
                  p_childObjectID       => l_child_object_id,
                  p_childObjectTypeID   => l_child_object_type_id,
                  p_relationshipType    => l_relationship_type,
                  p_relationshipStatus  => l_relationship_status,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data,
                  p_api_version         => 1.0,
                  p_init_msg_list       => FND_API.G_FALSE,
                  p_commit              => FND_API.G_FALSE);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then

    l_token_tbl(1).token_name  := 'Parent Object Id';
    l_token_tbl(1).token_value :=  l_parent_object_id;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_ADD_INS_FAIL'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

        x_return_status := 'E';
        return;

       end if;


      select eam_wo_relationships_s.nextval
        into l_wo_relationship_id from dual;
      insert into eam_wo_relationships
        (        wo_relationship_id,
                 parent_object_id,
                 parent_object_type_id,
                 child_object_id,
                 child_object_type_id,
                 parent_relationship_type,
                 relationship_status,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 top_level_object_id,
                 top_level_object_type_id
        ) values
        (        l_wo_relationship_id,
                 l_parent_object_id,
                 l_parent_object_type_id,
                 l_child_object_id,
                 l_child_object_type_id,
                 l_relationship_type,
                 l_relationship_status,
                 l_created_by,
                 sysdate,
                 l_last_updated_by,
                 sysdate,
                 l_top_level_object_id,
                 l_top_level_object_type_id
        );



        -- Stamp the hierarchy underneath with the new value
        -- of top level object id
     IF NOT l_constraining_children%ISOPEN THEN
       OPEN l_constraining_children FOR

        select * from wip_sched_relationships wsr
        WHERE wsr.relationship_type in (1,2)
        START WITH wsr.parent_object_id = l_parent_object_id
        CONNECT BY wsr.parent_object_id = PRIOR wsr.child_object_id;

     END IF;
     --for bug 9053183
           select sched_relationship_id
           into l_sched_relationship_id
           from wip_sched_relationships
           where parent_object_id= l_parent_object_id
           and parent_object_type_id = l_parent_object_type_id
           and child_object_id=l_child_object_id
           and child_object_type_id = l_child_object_type_id
           and relationship_type=l_relationship_type;


         update wip_sched_relationships set
         top_level_object_id = l_top_level_object_id,
         top_level_object_type_id = l_top_level_object_type_id
          where sched_relationship_id = l_sched_relationship_id;


          select maintenance_object_source into l_maint_obj_src
            from wip_discrete_jobs where wip_entity_id = l_parent_object_id;

        --   test_mesg('after update wip_sched_relationships sched rel id '||l_sched_relationship_id||' l_parent_object_id ' ||l_parent_object_id ||' l_child_object_id '||l_child_object_id );
      if l_maint_obj_src = 1 then -- EAM

        LOOP FETCH l_constraining_children into
        l_relationship_record;

        if l_relationship_record.parent_object_id is not null then
          l_relationship_record.top_level_object_id := l_top_level_object_id;
          l_relationship_record.top_level_object_type_id := l_top_level_object_type_id;

       /* update wip_sched_relationships set
            top_level_object_id = l_top_level_object_id,
            top_level_object_type_id = l_top_level_object_type_id
            where sched_relationship_id = l_relationship_record.sched_relationship_id;

          select maintenance_object_source into l_maint_obj_src
            from wip_discrete_jobs where wip_entity_id = l_relationship_record.parent_object_id;*/

            update eam_wo_relationships set
              top_level_object_id = l_top_level_object_id,
              top_level_object_type_id = l_top_level_object_type_id
              where
              parent_object_id = l_relationship_record.parent_object_id
              and parent_object_type_id = l_relationship_record.parent_object_type_id
              and child_object_id = l_relationship_record.child_object_id
              and child_object_type_id = l_relationship_record.child_object_type_id
              and parent_relationship_type = l_relationship_record.relationship_type;

        end if;

        EXIT WHEN l_constraining_children%NOTFOUND;

      END LOOP;
    end if;-- End for bug 9053183

      CLOSE l_constraining_children;

    elsif l_relationship_type = 4 then -- Follow up


      select eam_wo_relationships_s.nextval
        into l_wo_relationship_id from dual;
      insert into eam_wo_relationships
        (        wo_relationship_id,
                 parent_object_id,
                 parent_object_type_id,
                 child_object_id,
                 child_object_type_id,
                 parent_relationship_type,
                 relationship_status,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 top_level_object_id,
                 top_level_object_type_id
        ) values
        (        l_wo_relationship_id,
                 l_parent_object_id,
                 l_parent_object_type_id,
                 l_child_object_id,
                 l_child_object_type_id,
                 l_relationship_type,
                 l_relationship_status,
                 l_created_by,
                 sysdate,
                 l_last_updated_by,
                 sysdate,
                 null,
                 null
        );



    end if;


    -- See whether we need to expand parents further up the chain.
    if p_relationship_type = 1 then         -- only for constrained children

     -- find the list of subsequent constraining parents
     -- in the upward direction
     IF NOT l_constraining_parents%ISOPEN THEN
       OPEN l_constraining_parents FOR

        select * from wip_sched_relationships wsr
        WHERE wsr.relationship_type = 1
        START WITH wsr.child_object_id = l_child_object_id
        CONNECT BY PRIOR wsr.parent_object_id = wsr.child_object_id;

     END IF;

      -- Adjust durations of all subsequent parent work orders
      -- to be the maximum of it's children. Stop at first firm parent.
      LOOP FETCH l_constraining_parents into
        l_relationship_record;

        if l_relationship_record.parent_object_id is not null then

          select firm_planned_flag into l_parent_firm_flag from
            wip_discrete_jobs where wip_entity_id = l_relationship_record.parent_object_id;

          EXIT WHEN l_parent_firm_flag = 1;

          Adjust_Parent(
            p_parent_object_id => l_relationship_record.parent_object_id,
            p_parent_object_type_id => l_relationship_record.parent_object_type_id);

        end if;

        EXIT WHEN l_constraining_parents%NOTFOUND;

      END LOOP;

      CLOSE l_constraining_parents;

    end if;

    if l_parent_maint_obj_src <> 2 then -- CMRO for bug 7943516

    EAM_WO_NETWORK_VALIDATE_PVT.Validate_Structure
        (
        p_api_version                   => 1.0,
        p_init_msg_list                 => FND_API.G_FALSE,
        p_commit                        => FND_API.G_FALSE,
        p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                => l_child_object_id,
        p_work_object_type_id           => l_child_object_type_id,
        p_exception_logging             => 'Y',

        p_validate_status	        => 'N',
	p_output_errors			=> 'N',

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
        x_wo_relationship_exc_tbl       => l_wo_relationship_exc_tbl
        );

 --dbms_output.put_line('After VALIDATE_STRUCTURE:ret stat ='||l_return_status);



    IF l_return_status = FND_API.G_RET_STS_ERROR OR
       l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

    l_token_tbl(1).token_name  := 'Parent_WorkOrder';
    l_token_tbl(1).token_value :=  l_parent_workorder;
    l_token_tbl(2).token_name  := 'Child_WorkOrder';
    l_token_tbl(2).token_value :=  l_child_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_ADD_VALIDATE_STRUCT'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      ROLLBACK TO EAM_WN_ADD_WO;
    END IF;


    x_return_status := l_return_status;

    end if; --bug 7943516

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;


EXCEPTION

	WHEN OTHERS THEN

        rollback to EAM_WN_ADD_WO;

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_token_tbl(1).token_name  := 'Parent_WorkOrder';
    l_token_tbl(1).token_value :=  l_parent_workorder;
    l_token_tbl(2).token_name  := 'Child_WorkOrder';
    l_token_tbl(2).token_value :=  l_child_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_ADD_UNKNOWN_ERR'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

        return;

    END Add_WO_To_Network;





    PROCEDURE Adjust_Parent
        (
        p_parent_object_id              IN NUMBER,
        p_parent_object_type_id         IN NUMBER
        ) IS

        l_parent_object_id     NUMBER := p_parent_object_id;
        l_parent_object_type_id     NUMBER := p_parent_object_type_id;

        l_min_date  DATE := null;
        l_max_date  DATE := null;
        l_wo_start_date      DATE := null;
        l_wo_end_date        DATE := null;
	l_status_type  NUMBER;
	l_date_completed   DATE;

        TYPE l_relationship_records IS REF CURSOR RETURN WIP_SCHED_RELATIONSHIPS%ROWTYPE;
        l_constrained_children      l_relationship_records;
        l_relationship_record       WIP_SCHED_RELATIONSHIPS%ROWTYPE;

    BEGIN

      -- Find the min start date and max end date of all
      -- constrained children for this parent

     -- find the list of constrained children
     IF NOT l_constrained_children%ISOPEN THEN
       OPEN l_constrained_children FOR
         select * from
         wip_sched_relationships
         where relationship_type = 1
         and parent_object_id = l_parent_object_id
         and parent_object_type_id = l_parent_object_type_id;
     END IF;

      LOOP FETCH l_constrained_children into
        l_relationship_record;

        if l_relationship_record.child_object_id is not null then

		  select scheduled_start_date, scheduled_completion_date, status_type, date_completed
		  into l_wo_start_date, l_wo_end_date,l_status_type,l_date_completed
		  from wip_discrete_jobs
		  where wip_entity_id = l_relationship_record.child_object_id;

   --do not consider child workorders which are cancelled or [closed and date_completed is null](closed from cancelled status)
			       IF NOT(
			               l_status_type = 7
				       OR ((l_status_type IN (12,14,15)) AND (l_date_completed IS NULL))
				       ) THEN
							IF l_min_date is null OR
							l_min_date > l_wo_start_date THEN
							  l_min_date := l_wo_start_date;
							END IF;

							IF l_max_date is null OR
							l_max_date < l_wo_end_date THEN
							  l_max_date := l_wo_end_date;
							END IF;
                                END IF;
        end if;

        EXIT WHEN l_constrained_children%NOTFOUND;
      END LOOP;

      CLOSE l_constrained_children;

      select scheduled_start_date, scheduled_completion_date
        into l_wo_start_date, l_wo_end_date from wip_discrete_jobs
        where wip_entity_id = l_relationship_record.parent_object_id;

      if l_wo_start_date > nvl(l_min_date, l_wo_start_date + 1) then
        l_wo_start_date := l_min_date;
      end if;
      if l_wo_end_date < nvl(l_max_date, l_wo_end_date - 1) then
        l_wo_end_date := l_max_date;
      end if;

      UPDATE WIP_DISCRETE_JOBS set
        scheduled_start_date = l_wo_start_date,
        scheduled_completion_date = l_wo_end_date
        where wip_entity_id = l_parent_object_id;

    END Adjust_Parent;




/*Bug3521886: Pass requested start date and due date*/
     PROCEDURE Resize_WO
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
        p_object_id                     IN      NUMBER,
        p_object_type_id                IN      NUMBER,
        p_start_date                    IN      DATE,
        p_completion_date               IN      DATE,
	p_required_start_date           IN DATE := NULL,
	p_required_due_date             IN DATE := NULL,
	p_org_id                        IN VARCHAR2,
	p_firm                          IN NUMBER,
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        ) IS

      l_count                        NUMBER;
      l_first_constraining_parent    NUMBER;

      l_object_id                       NUMBER := p_object_id;
      l_object_type_id                  NUMBER := p_object_type_id;
      l_start_date                      DATE := p_start_date;
      l_completion_date                 DATE := p_completion_date;

    l_return_status             VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);

    l_date_chk_return_status    VARCHAR2(1);
     l_output_dir VARCHAR2(512);

    l_eam_wo_rec                eam_process_wo_pub.eam_wo_rec_type;

    l_eam_wo_relations_tbl 	EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
    l_eam_wo_tbl                EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
    l_eam_op_tbl                EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_eam_op_network_tbl    	EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_eam_res_tbl               EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_eam_res_inst_tbl          EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl       	EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl         EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl      	EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_eam_direct_items_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_tbl           EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;

    l_out_eam_wo_relations_tbl  EAM_PROCESS_WO_PUB.eam_wo_relations_tbl_type;
    l_out_eam_wo_tbl            EAM_PROCESS_WO_PUB.eam_wo_tbl_type;
    l_out_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type;
    l_out_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
    l_out_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type;
    l_out_eam_direct_items_tbl  EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_tbl           EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_out_eam_wo_quality_tbl        EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl     EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl   EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl           EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl           EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;


     BEGIN

    x_return_status := l_return_status;

	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WN_RESIZE;

EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);

       -- create the record for the workorder which needs to be shifted.

	l_eam_wo_rec.batch_id 			:=	1;
	l_eam_wo_rec.header_id			:=	p_object_id;
 	l_eam_wo_rec.wip_entity_id  		:=	p_object_id;
	l_eam_wo_rec.organization_id 		:= 	p_org_id;
	l_eam_wo_rec.scheduled_start_date	:=	p_start_date;
	l_eam_wo_rec.scheduled_completion_date	:=	p_completion_date;
	l_eam_wo_rec.transaction_type 		:= 	EAM_PROCESS_WO_PVT.G_OPR_UPDATE;
	l_eam_wo_rec.FIRM_PLANNED_FLAG          :=      p_firm;
	/*Bug3521886: Pass requested start date and due date*/
	l_eam_wo_rec.REQUESTED_START_DATE       :=      p_required_start_date;
        l_eam_wo_rec.DUE_DATE                   :=      p_required_due_date;

       -- insert into the table
	l_eam_wo_tbl(1) := l_eam_wo_rec;
	       EAM_PROCESS_WO_PUB.Process_Master_Child_WO(
		  p_bo_identifier           => 'EAM'
		 , p_init_msg_list           => TRUE
		 , p_api_version_number      => 1.0
		 , p_eam_wo_tbl              => l_eam_wo_tbl
		 , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
		 , p_eam_op_tbl              => l_eam_op_tbl
		 , p_eam_op_network_tbl      => l_eam_op_network_tbl
		 , p_eam_res_tbl             => l_eam_res_tbl
		 , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
		 , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
		 , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
		 , p_eam_direct_items_tbl    =>   l_eam_direct_items_tbl
		 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
 	         , p_eam_wo_comp_tbl         => l_eam_wo_comp_tbl
		 , p_eam_wo_quality_tbl      => l_eam_wo_quality_tbl
		 , p_eam_meter_reading_tbl   => l_eam_meter_reading_tbl
		 , p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
		 , p_eam_wo_comp_rebuild_tbl => l_eam_wo_comp_rebuild_tbl
		 , p_eam_wo_comp_mr_read_tbl => l_eam_wo_comp_mr_read_tbl
		 , p_eam_op_comp_tbl         => l_eam_op_comp_tbl
		 , p_eam_request_tbl         => l_eam_request_tbl
		 , x_eam_wo_tbl              => l_out_eam_wo_tbl
		 , x_eam_wo_relations_tbl    => l_out_eam_wo_relations_tbl
		 , x_eam_op_tbl              => l_out_eam_op_tbl
		 , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
		 , x_eam_res_tbl             => l_out_eam_res_tbl
		 , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
		 , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
		 , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
		 , x_eam_direct_items_tbl    => l_out_eam_direct_items_tbl
		 , x_eam_res_usage_tbl       => l_out_eam_res_usage_tbl
		 , x_eam_wo_comp_tbl         => l_out_eam_wo_comp_tbl
		 , x_eam_wo_quality_tbl      => l_out_eam_wo_quality_tbl
		 , x_eam_meter_reading_tbl   => l_out_eam_meter_reading_tbl
		 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
		 , x_eam_wo_comp_rebuild_tbl => l_out_eam_wo_comp_rebuild_tbl
		 , x_eam_wo_comp_mr_read_tbl => l_out_eam_wo_comp_mr_read_tbl
		 , x_eam_op_comp_tbl         => l_out_eam_op_comp_tbl
		 , x_eam_request_tbl         => l_out_eam_request_tbl
		 , x_return_status           => l_return_status
		 , x_msg_count               => l_msg_count
		 , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
		 , p_debug_filename          => 'resizewo.log'
		 , p_output_dir              =>  l_output_dir
		 , p_commit                  => p_commit
		 , p_debug_file_mode         => 'A'
		);

	/* if the status returned is sucess then commit the work in case caller wants it to be committed. Else  * raise exception
	 */
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        IF FND_API.TO_BOOLEAN(p_commit)THEN
  	  COMMIT WORK;
        END IF;
      ELSE
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    EXCEPTION
      when others then
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;


    END Resize_WO;





    PROCEDURE Delete_Dependency
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_prior_object_id               IN      NUMBER,
        p_prior_object_type_id          IN      NUMBER,
        p_next_object_id                IN      NUMBER,
        p_next_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2 ,
        x_mesg_token_tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ) IS

      l_prior_object_id       NUMBER := p_prior_object_id;
      l_prior_object_type_id  NUMBER := p_prior_object_type_id;
      l_next_object_id        NUMBER := p_next_object_id;
      l_next_object_type_id   NUMBER := p_next_object_type_id;

      l_count_prior           NUMBER := 0;
      l_count_next            NUMBER := 0;
      l_status_type           NUMBER := 0;

      l_return_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2(1000);
      l_sched_relationship_id NUMBER;


    l_err_text              VARCHAR2(2000) := NULL;
    l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
    l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_other_message         VARCHAR2(20000);
        l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_old_eam_wo_rec        EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
        l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type       ;
        l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type  ;
        l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type   ;
        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
        l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type   ;

	l_prior_workorder	VARCHAR2(240);
	l_next_workorder	VARCHAR2(240);

      BEGIN

      savepoint EAM_WN_DEL_DEP;

        x_return_status := l_return_status;

	  SELECT wip_entity_name into l_prior_workorder
		 FROM  wip_entities we
		 WHERE we.wip_entity_id = l_prior_object_id;

	  SELECT wip_entity_name into l_next_workorder
		 FROM  wip_entities we
		 WHERE we.wip_entity_id = l_next_object_id;


        -- Validate that the relationship is a leaf node
        select count(*) into l_count_prior from
          wip_sched_relationships where
          child_object_id = l_prior_object_id
          and child_object_type_id = l_prior_object_id
          and relationship_type = 2;
        select count(*) into l_count_next from
          wip_sched_relationships where
          parent_object_id = l_next_object_id
          and parent_object_type_id = l_next_object_id
          and relationship_type = 2;
        if l_count_prior <> 0 and l_count_next <> 0 then

    l_token_tbl(1).token_name  := 'Prior_WorkOrder';
    l_token_tbl(1).token_value :=  l_prior_workorder;
    l_token_tbl(2).token_name  := 'Next_WorkOrder';
    l_token_tbl(2).token_value :=  l_next_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_NOT_LEAF_NODE'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

       x_mesg_token_tbl := l_out_mesg_token_tbl;

          x_return_status := 'E';
          return;
        end if;

        -- Check that the prior work order is not completed
        select status_type into l_status_type
          from wip_discrete_jobs where
          wip_entity_id = l_prior_object_id;
        if l_status_type in (4,5,12,14,15) then

    l_token_tbl(1).token_name  := 'Prior_WorkOrder';
    l_token_tbl(1).token_value :=  l_prior_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_PRIOR_COMPLETED'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

          x_return_status := 'E';
          return;
        end if;

        -- Simple delete of type 2 relationship.
        select sched_relationship_id into l_sched_relationship_id
          from WIP_SCHED_RELATIONSHIPS
          where parent_object_id = l_prior_object_id
          and parent_object_type_id = l_prior_object_type_id
          and child_object_id = l_next_object_id
          and child_object_type_id = l_next_object_type_id
          and relationship_type = 2;

        wip_sched_relation_grp.deleteRow(
                  p_relationshipID      => l_sched_relationship_id,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data,
                  p_api_version         => 1.0,
                  p_init_msg_list       => FND_API.G_FALSE,
                  p_commit              => FND_API.G_FALSE);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then

    l_token_tbl(1).token_name  := 'Parent Object Id';
    l_token_tbl(1).token_value :=  l_prior_object_id;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_DEL_DEP_API_FAIL'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

        x_return_status := 'E';
        return;

       end if;

        DELETE from EAM_WO_RELATIONSHIPS
          where parent_object_id = l_prior_object_id
          and parent_object_type_id = l_prior_object_type_id
          and child_object_id = l_next_object_id
          and child_object_type_id = l_next_object_type_id
          and parent_relationship_type = 2;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

       EXCEPTION
         when others then

         rollback to EAM_WN_DEL_DEP;

    l_token_tbl(1).token_name  := 'Prior_WorkOrder';
    l_token_tbl(1).token_value :=  l_prior_workorder;
    l_token_tbl(2).token_name  := 'Next_WorkOrder';
    l_token_tbl(2).token_value :=  l_next_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_DEL_DEP_UNKWN_ERR'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

           x_return_status := FND_API.G_RET_STS_ERROR;
           return;

     END Delete_Dependency;




     PROCEDURE Add_Dependency
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_prior_object_id               IN      NUMBER,
        p_prior_object_type_id          IN      NUMBER,
        p_next_object_id                IN      NUMBER,
        p_next_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2 ,
        x_mesg_token_tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        ) IS

        l_prior_object_id                NUMBER := p_prior_object_id;
        l_prior_object_type_id           NUMBER := p_prior_object_type_id;
        l_next_object_id                 NUMBER := p_next_object_id;
        l_next_object_type_id            NUMBER := p_next_object_type_id;
        l_prior_status_type              NUMBER := 0;
        l_next_status_type               NUMBER := 0;
        l_prior_start_date               DATE   := SYSDATE;
        l_prior_completion_date          DATE   := SYSDATE;
        l_next_start_date                DATE   := SYSDATE;
        l_next_completion_date           DATE   := SYSDATE;

        l_sched_relationship_id          NUMBER;
        l_wo_relationship_id             NUMBER;
        l_top_level_object_id            NUMBER;
        l_top_level_object_type_id_1     NUMBER;
        l_top_level_object_id_1          NUMBER;
        l_top_level_object_type_id       NUMBER;
        l_relationship_status            NUMBER := 0; -- pending validation

        l_count                          NUMBER := 0;
        l_status_type                    NUMBER := 0;
        l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
        l_msg_count                      NUMBER;
        l_msg_data                       VARCHAR2(1000);
        l_err_text                       VARCHAR2(2000) := NULL;
        l_Mesg_Token_Tbl                 EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_out_Mesg_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_Token_Tbl                      EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;
        l_other_message                  VARCHAR2(20000);
        l_other_token_tbl                EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_eam_wo_rec                     EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_old_eam_wo_rec                 EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl                     EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
        l_eam_op_network_tbl             EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl                    EAM_PROCESS_WO_PUB.eam_res_tbl_type       ;
        l_eam_res_inst_tbl               EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type  ;
        l_eam_sub_res_tbl                EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type   ;
        l_eam_res_usage_tbl              EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
        l_eam_mat_req_tbl                EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type   ;

	l_prior_workorder	VARCHAR2(240);
	l_next_workorder	VARCHAR2(240);
	l_wo_relationship_exc_tbl	 EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type;

     BEGIN


    x_return_status := l_return_status;

    SAVEPOINT EAM_WN_ADD_DEP;

      SELECT wip_entity_name into l_prior_workorder
	 FROM  wip_entities we
	 WHERE we.wip_entity_id = l_prior_object_id;

  SELECT wip_entity_name into l_next_workorder
	 FROM  wip_entities we
	 WHERE we.wip_entity_id = l_next_object_id;


    -- Check that both work orders are part of
    -- some sched hierarchies
    select count(*) into l_count from
      wip_sched_relationships where
      child_object_id = l_prior_object_id
      and child_object_type_id = l_prior_object_type_id
      and relationship_type = 1;
    if l_count = 0 then

    l_token_tbl(1).token_name  := 'Prior_WorkOrder';
    l_token_tbl(1).token_value :=  l_prior_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_PRIOR_NOT_IN_HIER'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;

    select count(*) into l_count from
      wip_sched_relationships where
      child_object_id = l_next_object_id
      and child_object_type_id = l_next_object_type_id
      and relationship_type = 1;
    if l_count = 0 then

    l_token_tbl(1).token_name  := 'Next_WorkOrder';
    l_token_tbl(1).token_value :=  l_next_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_NEXT_NOT_IN_HIER'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;

    -- Check that the prior work order is not completed
    select status_type, scheduled_start_date,
      scheduled_completion_date
      into l_status_type, l_prior_start_date,
      l_prior_completion_date
      from wip_discrete_jobs where
      wip_entity_id = l_prior_object_id;
    l_prior_status_type := l_status_type;
    if l_status_type in (4,5,12,14,15) then

    l_token_tbl(1).token_name  := 'Prior_WorkOrder';
    l_token_tbl(1).token_value :=  l_prior_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_PRIOR_COMPL'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;


    select status_type, scheduled_start_date,
      scheduled_completion_date
      into l_status_type, l_next_start_date,
      l_next_completion_date
      from wip_discrete_jobs where
      wip_entity_id = l_next_object_id;
    l_next_status_type := l_status_type;
    if l_status_type in (4,5,12,14,15) then

    l_token_tbl(1).token_name  := 'Next_WorkOrder';
    l_token_tbl(1).token_value :=  l_next_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_NEXT_COMPL'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;


    -- Validate that we are not building a relationship
    -- between a released WO and a cancelled WO.

    if (l_prior_status_type = 3 and l_next_status_type = 7) OR
       (l_prior_status_type = 7 and l_next_status_type = 3) then

    l_token_tbl.delete;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_DEP_REL_CANCEL'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;



    -- Validate that the prior WO end date is before the
    -- next WO start date

    if l_prior_completion_date > l_next_start_date
    and l_prior_status_type IN (3,4,5,6,7,12,14,15)
    and l_next_status_type IN (3,4,5,6,7,12,14,15) THEN

    l_token_tbl(1).token_name := 'Prior Object Id';
    l_token_tbl(1).token_value := l_prior_object_id;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_DEP_REL_DATE_ERR'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := 'E';
      return;
    end if;




    -- Get some common variables
    -- 1. top_level_object_id
    select distinct top_level_object_id, top_level_object_type_id
      into l_top_level_object_id , l_top_level_object_type_id
      from wip_sched_relationships
      where child_object_id = l_prior_object_id
      and child_object_type_id = l_prior_object_type_id
      and relationship_type = 1;

    select distinct top_level_object_id, top_level_object_type_id
      into l_top_level_object_id_1 , l_top_level_object_type_id_1
      from wip_sched_relationships
      where child_object_id = l_next_object_id
      and child_object_type_id = l_next_object_type_id
      and relationship_type = 1;

    -- Validate that both objects have a common parent somewhere
    -- up the hierarchy. Just check the top_level_object_id
    IF l_top_level_object_id <> l_top_level_object_id_1 OR
       l_top_level_object_type_id <> l_top_level_object_type_id_1 THEN

    l_token_tbl(1).token_name  := 'Prior_WorkOrder';
    l_token_tbl(1).token_value :=  l_prior_workorder;
    l_token_tbl(2).token_name  := 'Next_WorkOrder';
    l_token_tbl(2).token_value :=  l_next_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_NOT_IN_SAME_HIER'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

        wip_sched_relation_grp.insertRow(
                  p_parentObjectID      => l_prior_object_id,
                  p_parentObjectTypeID  => l_prior_object_type_id,
                  p_childObjectID       => l_next_object_id,
                  p_childObjectTypeID   => l_next_object_type_id,
                  p_relationshipType    => 2,
                  p_relationshipStatus  => l_relationship_status,
                  x_return_status       => l_return_status,
                  x_msg_count           => l_msg_count,
                  x_msg_data            => l_msg_data,
                  p_api_version         => 1.0,
                  p_init_msg_list       => FND_API.G_FALSE,
                  p_commit              => FND_API.G_FALSE);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then

    l_token_tbl(1).token_name  := 'Parent Object Id';
    l_token_tbl(1).token_value :=  l_prior_object_id;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_ADD_DEP_INS_FAIL'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

        x_return_status := 'E';
        return;

       end if;


        select eam_wo_relationships_s.nextval
        into l_wo_relationship_id from dual;
      insert into eam_wo_relationships
        (        wo_relationship_id,
                 parent_object_id,
                 parent_object_type_id,
                 child_object_id,
                 child_object_type_id,
                 parent_relationship_type,
                 relationship_status,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 top_level_object_id,
                 top_level_object_type_id
        ) values
        (        l_wo_relationship_id,
                 l_prior_object_id,
                 l_prior_object_type_id,
                 l_next_object_id,
                 l_next_object_type_id,
                 2,
                 l_relationship_status,
                 l_created_by,
                 sysdate,
                 l_last_updated_by,
                 sysdate,
                 l_top_level_object_id,
                 l_top_level_object_type_id
        );


    EAM_WO_NETWORK_VALIDATE_PVT.Validate_Structure
        (
        p_api_version                   => 1.0,
        p_init_msg_list                 => FND_API.G_FALSE,
        p_commit                        => FND_API.G_FALSE,
        p_validation_level              => FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                => l_prior_object_id,
        p_work_object_type_id           => l_prior_object_type_id,
        p_exception_logging             => 'Y',

       	p_validate_status	        => 'N',
	p_output_errors			=> 'N',

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data,
        x_wo_relationship_exc_tbl       => l_wo_relationship_exc_tbl
        );


    IF l_return_status = FND_API.G_RET_STS_ERROR OR
       l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

    l_token_tbl(1).token_name  := 'Prior_WorkOrder';
    l_token_tbl(1).token_value :=  l_prior_workorder;
    l_token_tbl(2).token_name  := 'Next_WorkOrder';
    l_token_tbl(2).token_value :=  l_next_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_AD_VALIDATE_STRUC_ERR'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

      ROLLBACK TO EAM_WN_ADD_DEP;
    END IF;

    x_return_status := l_return_status;

        EXCEPTION
          when others then

           rollback to EAM_WN_ADD_DEP;

    l_token_tbl(1).token_name  := 'Prior_WorkOrder';
    l_token_tbl(1).token_value :=  l_prior_workorder;
    l_token_tbl(2).token_name  := 'Next_WorkOrder';
    l_token_tbl(2).token_value :=  l_next_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_AD_UNKNOWN_ERR'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

   END Add_Dependency;




    PROCEDURE Delink_Child_From_Parent
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_child_object_id               IN      NUMBER,
        p_child_object_type_id          IN      NUMBER,
        p_parent_object_id              IN      NUMBER,
        p_parent_object_type_id         IN      NUMBER,
        p_relationship_type             IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2 ,
        x_mesg_token_tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        )
        IS

        l_relationship_type             NUMBER := p_relationship_type;
        l_count                         NUMBER;

        l_child_object_id               NUMBER := p_child_object_id;
        l_child_object_type_id          NUMBER := p_child_object_type_id;
        l_parent_object_id              NUMBER := p_parent_object_id;
        l_parent_object_type_id         NUMBER := p_parent_object_type_id;

        l_relationship_status           NUMBER := 0;
        l_return_status                 VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

        l_sched_relationship_id         NUMBER;
        l_msg_count                     NUMBER;
        l_msg_data                      VARCHAR2(1000);

        l_err_text              VARCHAR2(2000) := NULL;
        l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_out_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
        l_Token_Tbl             EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_other_message         VARCHAR2(20000);
        l_other_token_tbl       EAM_ERROR_MESSAGE_PVT.Token_Tbl_Type;

        l_eam_wo_rec            EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_old_eam_wo_rec        EAM_PROCESS_WO_PUB.eam_wo_rec_type;
        l_eam_op_tbl            EAM_PROCESS_WO_PUB.eam_op_tbl_type ;
        l_eam_op_network_tbl    EAM_PROCESS_WO_PUB.eam_op_network_tbl_type;
        l_eam_res_tbl           EAM_PROCESS_WO_PUB.eam_res_tbl_type       ;
        l_eam_res_inst_tbl      EAM_PROCESS_WO_PUB.eam_res_inst_tbl_type  ;
        l_eam_sub_res_tbl       EAM_PROCESS_WO_PUB.eam_sub_res_tbl_type   ;
        l_eam_res_usage_tbl     EAM_PROCESS_WO_PUB.eam_res_usage_tbl_type ;
        l_eam_mat_req_tbl       EAM_PROCESS_WO_PUB.eam_mat_req_tbl_type   ;

	TYPE l_relationship_records IS REF CURSOR RETURN WIP_SCHED_RELATIONSHIPS%ROWTYPE;
        l_constraining_children     l_relationship_records;
        l_relationship_record       WIP_SCHED_RELATIONSHIPS%ROWTYPE;

        l_maint_obj_src    NUMBER;

    	l_parent_workorder	VARCHAR2(240);
	l_child_workorder	VARCHAR2(240);

	l_constraining_parents      l_relationship_records;
        l_parent_record       WIP_SCHED_RELATIONSHIPS%ROWTYPE;
	l_parent_firm_flag     NUMBER;

        BEGIN

        savepoint EAM_WN_DELINK_PAR_CH;

        x_return_status := FND_API.G_RET_STS_SUCCESS;

	 SELECT wip_entity_name into l_parent_workorder
	 FROM  wip_entities we
	 WHERE we.wip_entity_id = l_parent_object_id;

	 SELECT wip_entity_name into l_child_workorder
	 FROM  wip_entities we
	 WHERE we.wip_entity_id = l_child_object_id;


          -- See if there are dependency relationships for the child
        -- if it is a scheduling relationship that is being deleted.
        l_count := 0;
        if l_relationship_type = 1 then
          select count(*) into l_count from
            wip_sched_relationships where
            ((child_object_id = l_child_object_id and
              child_object_type_id = l_child_object_type_id) OR
             (parent_object_id = l_child_object_id and
              parent_object_type_id = l_child_object_type_id)
            ) AND
            relationship_type = 2;
        end if;

          if l_count = 0 then

			    delete from eam_wo_relationships where
			      child_object_id              = l_child_object_id
			      and child_object_type_id     = l_child_object_type_id
			      and parent_object_id         = l_parent_object_id
			      and parent_object_type_id    = l_parent_object_type_id
			      and parent_relationship_type = l_relationship_type;

			  if l_relationship_type = 1 then

				select sched_relationship_id into l_sched_relationship_id
				  from WIP_SCHED_RELATIONSHIPS
				  where parent_object_id = l_parent_object_id
				  and parent_object_type_id = l_parent_object_type_id
				  and child_object_id = l_child_object_id
				  and child_object_type_id = l_child_object_type_id
				  and relationship_type = 1;

					  wip_sched_relation_grp.deleteRow(
					  p_relationshipID      => l_sched_relationship_id,
					  x_return_status       => l_return_status,
					  x_msg_count           => l_msg_count,
					  x_msg_data            => l_msg_data,
					  p_api_version         => 1.0,
					  p_init_msg_list       => FND_API.G_FALSE,
					  p_commit              => FND_API.G_FALSE);

					  if l_return_status <> FND_API.G_RET_STS_SUCCESS then

					    l_token_tbl(1).token_name  := 'Parent Object Id';
					    l_token_tbl(1).token_value :=  l_parent_object_id;

					    l_out_mesg_token_tbl  := l_mesg_token_tbl;
					    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
					      (  p_message_name  => 'EAM_WN_DEL_REL_API_FAIL'
					       , p_token_tbl     => l_token_tbl
					       , p_mesg_token_tbl     => l_mesg_token_tbl
					       , x_mesg_token_tbl     => l_out_mesg_token_tbl
					    );
					    l_mesg_token_tbl      := l_out_mesg_token_tbl;

					      x_mesg_token_tbl := l_out_mesg_token_tbl;

						x_return_status := 'E';
						return;

					    end if;

			 end if;


          elsif l_count > 0 then

		    l_token_tbl(1).token_name  := 'Parent_WorkOrder';
		    l_token_tbl(1).token_value :=  l_parent_workorder;
		    l_token_tbl(2).token_name  := 'Child_WorkOrder';
		    l_token_tbl(2).token_value :=  l_child_workorder;

		    l_out_mesg_token_tbl  := l_mesg_token_tbl;
		    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
		      (  p_message_name  => 'EAM_WN_DELINK_DEP_EXS'
		       , p_token_tbl     => l_token_tbl
		       , p_mesg_token_tbl     => l_mesg_token_tbl
		       , x_mesg_token_tbl     => l_out_mesg_token_tbl
		    );
		    l_mesg_token_tbl      := l_out_mesg_token_tbl;

		      x_mesg_token_tbl := l_out_mesg_token_tbl;

			    x_return_status := FND_API.G_RET_STS_ERROR;
			    return;
          end if;

        IF l_relationship_type = 1 THEN
	                    select firm_planned_flag into l_parent_firm_flag from
			    wip_discrete_jobs where wip_entity_id = l_parent_object_id;

		IF(l_parent_firm_flag = 2) THEN
			     Shrink_Parent(
			       p_parent_object_id => l_parent_object_id,
			       p_parent_object_type_id => l_parent_object_type_id);

			     -- find the list of subsequent constraining parents in the upward direction
			     IF NOT l_constraining_parents%ISOPEN THEN
			       OPEN l_constraining_parents FOR

				select * from wip_sched_relationships wsr
				WHERE wsr.relationship_type = 1
				START WITH wsr.child_object_id = l_parent_object_id
				CONNECT BY PRIOR wsr.parent_object_id = wsr.child_object_id;

			     END IF;

			      -- Adjust durations of all subsequent parent work orders
			      -- to be the maximum of it's children and its operations. Stop at first firm parent.
			      LOOP FETCH l_constraining_parents into l_parent_record;

				if l_parent_record.parent_object_id is not null then

				  select firm_planned_flag into l_parent_firm_flag from
				    wip_discrete_jobs where wip_entity_id = l_parent_record.parent_object_id;

				  EXIT WHEN l_parent_firm_flag = 1;

				  Shrink_Parent(
				    p_parent_object_id => l_parent_record.parent_object_id,
				    p_parent_object_type_id => l_parent_record.parent_object_type_id);

				end if;

				EXIT WHEN l_constraining_parents%NOTFOUND;

			      END LOOP;

			      CLOSE l_constraining_parents;
		 END IF;
	END IF;

     if l_relationship_type = 1 then
        -- Stamp the hierarchy underneath with the new value
        -- of top level object id
     IF NOT l_constraining_children%ISOPEN THEN
       OPEN l_constraining_children FOR

        select * from wip_sched_relationships wsr
        WHERE wsr.relationship_type in (1,2)
        START WITH wsr.parent_object_id = l_child_object_id
        CONNECT BY wsr.parent_object_id = PRIOR wsr.child_object_id;

     END IF;

      LOOP FETCH l_constraining_children into
        l_relationship_record;

        if l_relationship_record.parent_object_id is not null then
          l_relationship_record.top_level_object_id := l_child_object_id;
          l_relationship_record.top_level_object_type_id := l_child_object_type_id;

          update wip_sched_relationships set
            top_level_object_id = l_child_object_id,
            top_level_object_type_id = l_child_object_type_id
            where sched_relationship_id = l_relationship_record.sched_relationship_id;

          select maintenance_object_source into l_maint_obj_src
            from wip_discrete_jobs where wip_entity_id = l_relationship_record.parent_object_id;
          if l_maint_obj_src = 1 then -- EAM
            update eam_wo_relationships set
              top_level_object_id = l_child_object_id,
              top_level_object_type_id = l_child_object_type_id
              where
              parent_object_id = l_relationship_record.parent_object_id
              and child_object_id = l_relationship_record.child_object_id;
          end if;
        end if;

        EXIT WHEN l_constraining_children%NOTFOUND;

      END LOOP;

      CLOSE l_constraining_children;

        end if;

        EXCEPTION
          when others then

          rollback to EAM_WN_DELINK_PAR_CH;

    l_token_tbl(1).token_name  := 'Parent_WorkOrder';
    l_token_tbl(1).token_value :=  l_parent_workorder;
    l_token_tbl(2).token_name  := 'Child_WorkOrder';
    l_token_tbl(2).token_value :=  l_child_workorder;

    l_out_mesg_token_tbl  := l_mesg_token_tbl;
    EAM_ERROR_MESSAGE_PVT.Add_Error_Token
      (  p_message_name  => 'EAM_WN_DELINK_UNKNOWN_ERR'
       , p_token_tbl     => l_token_tbl
       , p_mesg_token_tbl     => l_mesg_token_tbl
       , x_mesg_token_tbl     => l_out_mesg_token_tbl
    );
    l_mesg_token_tbl      := l_out_mesg_token_tbl;

      x_mesg_token_tbl := l_out_mesg_token_tbl;

            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

      END Delink_Child_From_Parent;





    -- This procedure will check that the workorder / operation/ resources duration wont be negative

    PROCEDURE Check_Wo_Negative_Dates
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
        p_wip_entity_id                 IN      NUMBER,
        p_organization_id               IN      NUMBER,
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        ) IS


      TYPE l_op_records IS RECORD (first_unit_start_date       DATE,
                                          last_unit_completion_date   DATE);

	l_op_record l_op_records;

       TYPE l_resource_records IS RECORD (res_start_date      DATE,
                                          res_completion_date DATE);

       l_resource_record l_resource_records;

       CURSOR l_op_resources is
         select
         wor.start_date as res_start_date,
         wor.completion_date as res_completion_date
         from wip_operation_resources wor
         where wor.wip_entity_id = p_wip_entity_id
	 and wor.organization_id  = p_organization_id;

     CURSOR l_op_records_cur is
         select
         wo.first_unit_start_date   as first_unit_start_date,
         wo.last_unit_completion_date  as last_unit_completion_date
         from wip_operations wo
         where wo.wip_entity_id = p_wip_entity_id
	 and wo.organization_id  = p_organization_id;

       TYPE l_resource_inst_records IS RECORD (
                                          resinst_start_date      DATE,
                                          resinst_completion_date DATE);

       l_resource_inst_record l_resource_inst_records;

       CURSOR l_resource_instances is
         select
         wori.start_date as resinst_start_date,
         wori.completion_date as resinst_completion_date
         from wip_op_resource_instances wori
         where wori.wip_entity_id = p_wip_entity_id;


	 TYPE l_sub_resource_records IS RECORD (
                                          res_start_date      DATE,
                                          res_completion_date DATE);
       l_sub_resource_record l_sub_resource_records;

       CURSOR l_op_sub_resources is
         select
         wor.start_date as res_start_date,
         wor.completion_date as res_completion_date
         from
         wip_sub_operation_resources wor
         where
          wor.wip_entity_id = p_wip_entity_id
  	 and wor.organization_id  = p_organization_id;


       l_wip_entity_id                    NUMBER := p_wip_entity_id;
       l_organization_id                  NUMBER := p_organization_id;
       l_wo_start_date                    DATE;
       l_wo_completion_date               DATE;

     BEGIN

      select scheduled_start_date, scheduled_completion_date
        into l_wo_start_date, l_wo_completion_date
        from wip_discrete_jobs
        where wip_entity_id = l_wip_entity_id and
	organization_id  = l_organization_id;


	-- check if work order has -ve duration
	IF l_wo_start_date > l_wo_completion_date THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    RETURN;
	END IF;


/*     -- find the list of wo operations
     IF NOT l_wo_operations%ISOPEN THEN
       OPEN l_wo_operations FOR
         select * from
         wip_operations
         where wip_entity_id = l_wip_entity_id and
	 organization_id  = l_organization_id;
     END IF;
*/

      -- Check if any of operation has negative duration
      OPEN l_op_records_cur;
      LOOP FETCH l_op_records_cur into
        l_op_record;

        IF l_op_record.first_unit_start_date > l_op_record.last_unit_completion_date THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_op_records_cur%NOTFOUND;
      END LOOP;

      CLOSE l_op_records_cur;

      -- Check if resource has negative duration
      OPEN l_op_resources;
      LOOP FETCH l_op_resources into l_resource_record;

        IF l_resource_record.res_start_date > l_resource_record.res_completion_date THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_op_resources%NOTFOUND;
      END LOOP;

      CLOSE l_op_resources;

    -- Check if resource instance has negative duration
      OPEN l_resource_instances;
      LOOP FETCH l_resource_instances into l_resource_inst_record;

        IF l_resource_inst_record.resinst_start_date > l_resource_inst_record.resinst_completion_date THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_resource_instances%NOTFOUND;
      END LOOP;

      CLOSE l_resource_instances;

       -- Check if substitute resource has negative duration
      OPEN l_op_sub_resources;
      LOOP FETCH l_op_sub_resources into l_sub_resource_record;

        IF l_sub_resource_record.res_start_date > l_sub_resource_record.res_completion_date THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_op_sub_resources%NOTFOUND;
      END LOOP;

      CLOSE l_op_sub_resources;


      x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
          when others then
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

     END Check_Wo_Negative_Dates;


       -- This procedure will check whether the operation dates fall within the
    -- WO dates and whether the resource dates fall within the operation dates
    -- This procedure can be used while moving or resizing work orders
    PROCEDURE Check_WO_Dates
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_wip_entity_id                 IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        ) IS

       TYPE l_operation_records IS REF CURSOR RETURN WIP_OPERATIONS%ROWTYPE;
       l_wo_operations      l_operation_records;
       l_operation_record       WIP_OPERATIONS%ROWTYPE;

       TYPE l_resource_records IS RECORD (wip_entity_id       NUMBER,
                                          operation_seq_num   NUMBER,
                                          resource_seq_num    NUMBER,
                                          op_start_date       DATE,
                                          op_completion_date  DATE,
                                          res_start_date      DATE,
                                          res_completion_date DATE);
       l_resource_record l_resource_records;

       CURSOR l_op_resources is
         select p_wip_entity_id as wip_entity_id, wo.operation_seq_num,
         wor.resource_seq_num,
         wo.first_unit_start_date as op_start_date,
         wo.last_unit_completion_date as op_completion_date,
         wor.start_date as res_start_date,
         wor.completion_date as res_completion_date
         from wip_operations wo,
         wip_operation_resources wor
         where wo.wip_entity_id = p_wip_entity_id
         and wor.wip_entity_id = p_wip_entity_id
         and wo.operation_seq_num = wor.operation_seq_num;


       TYPE l_resource_inst_records IS RECORD (wip_entity_id       NUMBER,
                                          operation_seq_num   NUMBER,
                                          resource_seq_num    NUMBER,
                                          res_start_date       DATE,
                                          res_completion_date  DATE,
                                          resinst_start_date      DATE,
                                          resinst_completion_date DATE);

       l_resource_inst_record l_resource_inst_records;

       CURSOR l_resource_instances is
         select p_wip_entity_id as wip_entity_id, wor.operation_seq_num,
         wor.resource_seq_num,
         wor.start_date as res_start_date,
         wor.completion_date as res_completion_date,
         wori.start_date as resinst_start_date,
         wori.completion_date as resinst_completion_date
         from wip_op_resource_instances wori,
         wip_operation_resources wor
         where wor.wip_entity_id = p_wip_entity_id
         and wori.wip_entity_id = p_wip_entity_id
         and wori.operation_seq_num = wor.operation_seq_num
         and wori.resource_seq_num = wor.resource_seq_num;

	 CURSOR l_res_usage_instances is
         select
	 p_wip_entity_id as wip_entity_id,
	 woru.operation_seq_num,
         woru.resource_seq_num,
         woru.start_date as res_usg_start_date,
         woru.completion_date as res_usg_completion_date,
         wori.start_date as resinst_start_date,
         wori.completion_date as resinst_completion_date,
	 wori.instance_id as resinst_instance_id
         from
	 wip_op_resource_instances wori,
         wip_operation_resource_usage woru
         where
	 woru.wip_entity_id		= p_wip_entity_id
         and wori.wip_entity_id		= p_wip_entity_id
	 and wori.operation_seq_num	= woru.operation_seq_num
         and wori.resource_seq_num	= woru.resource_seq_num
	 and wori.instance_id		= woru.instance_id
	 and nvl(wori.serial_number,1)  = nvl(woru.serial_number,1);

	 CURSOR l_res_usages is
         select
	 p_wip_entity_id as wip_entity_id,
         woru.start_date as res_usg_start_date,
         woru.completion_date as res_usg_completion_date,
         wor.start_date as res_start_date,
         wor.completion_date as res_completion_date
         from
	 wip_operation_resources wor,
         wip_operation_resource_usage woru
         where
	 wor.wip_entity_id		= p_wip_entity_id
         and woru.wip_entity_id		= p_wip_entity_id
	 and wor.resource_seq_num 	= woru.resource_seq_num
	 and wor.operation_seq_num      = woru.operation_seq_num
	 and woru.instance_id is null;

       l_wip_entity_id                    NUMBER := p_wip_entity_id;
       l_wo_start_date                    DATE;
       l_wo_completion_date               DATE;

       l_res_usage_inst_record		l_res_usage_instances%rowtype;
       l_res_usages_record		l_res_usages%rowtype;

     BEGIN

      select scheduled_start_date, scheduled_completion_date
        into l_wo_start_date, l_wo_completion_date
        from wip_discrete_jobs
        where wip_entity_id = l_wip_entity_id;

     -- find the list of wo operations
     IF NOT l_wo_operations%ISOPEN THEN
       OPEN l_wo_operations FOR
         select * from
         wip_operations
         where wip_entity_id = l_wip_entity_id;
     END IF;


      -- Check whether all operations lie within WO dates.
      LOOP FETCH l_wo_operations into
        l_operation_record;

        IF l_operation_record.first_unit_start_date < l_wo_start_date OR
           l_operation_record.last_unit_completion_date > l_wo_completion_date THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_wo_operations%NOTFOUND;
      END LOOP;

      CLOSE l_wo_operations;


      OPEN l_op_resources;
      LOOP FETCH l_op_resources into l_resource_record;

        IF l_resource_record.res_start_date < l_resource_record.op_start_date OR
           l_resource_record.res_completion_date > l_resource_record.op_completion_date THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_op_resources%NOTFOUND;
      END LOOP;

      CLOSE l_op_resources;


      OPEN l_resource_instances;
      LOOP FETCH l_resource_instances into l_resource_inst_record;

        IF l_resource_inst_record.resinst_start_date < l_resource_inst_record.res_start_date OR
           l_resource_inst_record.resinst_completion_date > l_resource_inst_record.res_completion_date THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_resource_instances%NOTFOUND;
      END LOOP;

      CLOSE l_resource_instances;

	--
      OPEN l_res_usages;
       LOOP FETCH l_res_usages into l_res_usages_record;

        IF l_res_usages_record.res_start_date > l_res_usages_record.res_usg_start_date OR
           l_res_usages_record.res_usg_completion_date > l_res_usages_record.res_completion_date  THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_res_usages%NOTFOUND;
      END LOOP;

      CLOSE l_res_usages;

      --
      OPEN l_res_usage_instances;
       LOOP FETCH l_res_usage_instances into l_res_usage_inst_record;

        IF l_res_usage_inst_record.resinst_start_date > l_res_usage_inst_record.res_usg_start_date OR
           l_res_usage_inst_record.res_usg_completion_date > l_res_usage_inst_record.resinst_completion_date THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;

        EXIT WHEN l_res_usage_instances%NOTFOUND;
      END LOOP;

      CLOSE l_res_usage_instances;


      x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
          when others then
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

     END Check_WO_Dates;

	-- To check dates of wori,woru,wor
    PROCEDURE Check_Resource_Dates
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_wip_entity_id                 IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        ) IS

       CURSOR l_resource_instances is
         select
	 p_wip_entity_id as wip_entity_id,
	 wor.operation_seq_num,
         wor.resource_seq_num,
         wor.start_date as res_start_date,
         wor.completion_date as res_completion_date,
         wori.start_date as resinst_start_date,
         wori.completion_date as resinst_completion_date,
	 wori.instance_id as resinst_instance_id
         from
	 wip_op_resource_instances wori,
         wip_operation_resources wor
         where
	 wor.wip_entity_id = p_wip_entity_id
         and wori.wip_entity_id = p_wip_entity_id
         and wori.operation_seq_num = wor.operation_seq_num
         and wori.resource_seq_num = wor.resource_seq_num;

	 CURSOR l_res_usage_instances is
         select
	 p_wip_entity_id as wip_entity_id,
	 woru.operation_seq_num,
         woru.resource_seq_num,
         woru.start_date as res_usg_start_date,
         woru.completion_date as res_usg_completion_date,
         wori.start_date as resinst_start_date,
         wori.completion_date as resinst_completion_date,
	 wori.instance_id as resinst_instance_id
         from
	 wip_op_resource_instances wori,
         wip_operation_resource_usage woru
         where
	 woru.wip_entity_id		= p_wip_entity_id
         and wori.wip_entity_id		= p_wip_entity_id
	 and wori.operation_seq_num	= woru.operation_seq_num
         and wori.resource_seq_num	= woru.resource_seq_num
	 and wori.instance_id		= woru.instance_id ;

       l_resource_inst_record		l_resource_instances%rowtype;
       l_res_usage_inst_record		l_res_usage_instances%rowtype;

       l_wip_entity_id                  NUMBER := p_wip_entity_id;

     BEGIN

      OPEN l_resource_instances;
      LOOP FETCH l_resource_instances into l_resource_inst_record;

        IF l_resource_inst_record.resinst_start_date < l_resource_inst_record.res_start_date THEN

		   update wip_operation_resources wor
		   set start_date		= l_resource_inst_record.res_start_date
		 where wor.wip_entity_id	= l_resource_inst_record.wip_entity_id
		   and wor.operation_seq_num	= l_resource_inst_record.operation_seq_num
		   and wor.resource_seq_num	= l_resource_inst_record.resource_seq_num ;


        END IF;

        IF l_resource_inst_record.resinst_completion_date > l_resource_inst_record.res_completion_date THEN

		   update wip_operation_resources wor
		     set completion_date	= l_resource_inst_record.res_completion_date
		 where wor.wip_entity_id	= l_resource_inst_record.wip_entity_id
		   and wor.operation_seq_num	= l_resource_inst_record.operation_seq_num
		   and wor.resource_seq_num	= l_resource_inst_record.resource_seq_num;
        END IF;

        EXIT WHEN l_resource_instances%NOTFOUND;
      END LOOP;

      CLOSE l_resource_instances;

      OPEN l_res_usage_instances;
      LOOP FETCH l_res_usage_instances into l_res_usage_inst_record;

        IF l_res_usage_inst_record.res_usg_start_date < l_res_usage_inst_record.resinst_start_date THEN

		   update wip_op_resource_instances wori
		   set start_date		= l_res_usage_inst_record.res_usg_start_date
		 where wori.wip_entity_id	= l_res_usage_inst_record.wip_entity_id
		   and wori.operation_seq_num	= l_res_usage_inst_record.operation_seq_num
		   and wori.resource_seq_num	= l_res_usage_inst_record.resource_seq_num
		   and wori.instance_id		= l_res_usage_inst_record.resinst_instance_id
		   and wori.serial_number IS NULL;

        END IF;

	IF l_res_usage_inst_record.res_usg_completion_date > l_res_usage_inst_record.resinst_completion_date THEN

		   update wip_op_resource_instances wori
		   set completion_date		= l_res_usage_inst_record.res_usg_completion_date
		 where wori.wip_entity_id	= l_res_usage_inst_record.wip_entity_id
		   and wori.operation_seq_num	= l_res_usage_inst_record.operation_seq_num
		   and wori.resource_seq_num	= l_res_usage_inst_record.resource_seq_num
		   and wori.instance_id		= l_res_usage_inst_record.resinst_instance_id
		   and wori.serial_number IS NULL;

        END IF;

        EXIT WHEN l_res_usage_instances%NOTFOUND;
      END LOOP;

      CLOSE l_res_usage_instances;

      x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
          when others then
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

     END Check_Resource_Dates;



    /*******************************************************************
    * Procedure	: Snap_Right
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This API snap the Work Order to the right. Assumes
    *             backward scheduling
    *********************************************************************/

    PROCEDURE Snap_Right
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )


    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Snap_Right';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_work_object_type_id       NUMBER;
    l_right_snap_window         NUMBER;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);



   BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WO_NETWORK_DEFAULT_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;
    l_work_object_id        := p_work_object_id;
    l_work_object_type_id   := p_work_object_type_id;
    l_return_status         := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             := 0 ;
    l_msg_data              := NULL;


    /* Find the right snap window */
    EAM_WO_NETWORK_DEFAULT_PVT.Snap_Right_Window
        (
        p_api_version                   => 1.0,
        p_work_object_id                => l_work_object_id,
        p_work_object_type_id           => l_work_object_type_id,

        x_right_snap_window             => l_right_snap_window,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;

    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
    END IF;

    /* Initialize the local variables */
    l_stmt_num := 10;
    l_return_status         := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             := 0 ;
    l_msg_data              := NULL;


    /* Call the MOVE API with the right_snap_window to move the entire structure
       and call scheduler when necessary */
    EAM_WO_NETWORK_UTIL_PVT.Move_WO
        (
        p_api_version                   => 1.0,

        p_work_object_id                => l_work_object_id,
        p_work_object_type_id           => l_work_object_type_id,
        p_offset_days                   => l_right_snap_window,
        p_offset_direction              => 1, -- Right/Forward
        p_schedule_method               => 2, -- Backward Scheduling

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data

        );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;

    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
    END IF;



	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);


    END Snap_Right;


    /*******************************************************************
    * Procedure	: Snap_Left
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This API snap the Work Order to the left. Assumes
    *             forward scheduling
    *********************************************************************/

    PROCEDURE Snap_Left
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )


    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Snap_Left';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_work_object_type_id       NUMBER;
    l_left_snap_window          NUMBER;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);



   BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WO_NETWORK_DEFAULT_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;
    l_work_object_id        := p_work_object_id;
    l_work_object_type_id   := p_work_object_type_id;
    l_left_snap_window      := 0;
    l_return_status         := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             := 0 ;
    l_msg_data              := NULL;


    /* Find the right snap window */
    EAM_WO_NETWORK_DEFAULT_PVT.Snap_Left_Window
        (
        p_api_version                   => 1.0,
        p_work_object_id                => l_work_object_id,
        p_work_object_type_id           => l_work_object_type_id,

        x_left_snap_window              => l_left_snap_window,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;

    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
    END IF;

    /* Initialize the local variables */
    l_stmt_num := 10;
    l_return_status         := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             := 0 ;
    l_msg_data              := NULL;


    /* Call the MOVE API with the right_snap_window to move the entire structure
       and call scheduler when necessary */
    EAM_WO_NETWORK_UTIL_PVT.Move_WO
        (
        p_api_version                   => 1.0,

        p_work_object_id                => l_work_object_id,
        p_work_object_type_id           => l_work_object_type_id,
        p_offset_days                   => l_left_snap_window,
        p_offset_direction              => 2, -- Left/Backward
        p_schedule_method               => 1, -- Forward Scheduling

        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data

        );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;

    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
    END IF;



	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);


    END Snap_Left;


    /*******************************************************************
    * Procedure	: Snap_Right_Window
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This API return the Max Right Snap Window for a Work Order
    *             in number of days. The Max value of the return Variable is 1 day.
    *********************************************************************/
    PROCEDURE Snap_Right_Window
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_right_snap_window             OUT NOCOPY  NUMBER,
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )


    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Snap_Right_Window';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_work_object_type_id       NUMBER;
    l_wo_in_planning            NUMBER;

    l_this_level_min_window     NUMBER;
    l_next_level_min_window     NUMBER;
    l_min_right_snap_window     NUMBER;

    l_maintenance_object_source NUMBER;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);

    l_exception_msg             VARCHAR2(1000);

   BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WO_NETWORK_DEFAULT_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;
    l_work_object_id        := p_work_object_id;
    l_work_object_type_id   := p_work_object_type_id;
    l_wo_in_planning        := 0;
    l_maintenance_object_source := 1; --EAM


    /* Commenting this out because we have now changed the
    design to not return 1 even if WO is in planning

    If the current work order is still in planning, return 1
    l_stmt_num := 20;
    BEGIN
    SELECT  COUNT(WDJ.WIP_ENTITY_ID)
    INTO    l_wo_in_planning
    FROM    WIP_DISCRETE_JOBS WDJ
    WHERE   WDJ.WIP_ENTITY_ID       = l_work_object_id
    AND     l_work_object_type_id   = 1
    AND     WDJ.STATUS_TYPE        NOT IN (3,4,5,6,7,12,14,15);
    EXCEPTION
        WHEN OTHERS THEN
            l_wo_in_planning        := 0;
    END;
    If work order is still in planning stages, return the Max value of 1
    l_stmt_num := 30;
    IF (l_wo_in_planning = 1) THEN
        x_right_snap_window := 1.0;
        RETURN;
    END IF;
    */

    /* Find Constraining Parent Window window to the right*/
    BEGIN
    l_stmt_num := 40;

    SELECT  (WDJ1.SCHEDULED_COMPLETION_DATE - WDJ2.SCHEDULED_COMPLETION_DATE)
    INTO    l_this_level_min_window
    FROM    WIP_SCHED_RELATIONSHIPS WSR,
            WIP_DISCRETE_JOBS WDJ1,
            WIP_DISCRETE_JOBS WDJ2
    WHERE   WSR.CHILD_OBJECT_ID         = l_work_object_id
    AND     WSR.CHILD_OBJECT_TYPE_ID    = l_work_object_type_id
    AND     WSR.CHILD_OBJECT_TYPE_ID    = 1
    AND     WSR.RELATIONSHIP_TYPE       = 1
    AND     WSR.PARENT_OBJECT_TYPE_ID   = 1
    AND     WDJ1.WIP_ENTITY_ID          = WSR.PARENT_OBJECT_ID
    AND     WDJ2.WIP_ENTITY_ID          = l_work_object_id;

    -- Commented the below where clause because no status checks as per new design.
    -- AND     WDJ2.STATUS_TYPE            IN (3,4,5,6,7,12,14,15);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
--dbms_output.put_line('Inside parent NO DATA FOUND');
                    l_this_level_min_window := 1; -- Max possible Value is One Day
                    l_next_level_min_window := 1; -- Max possible Value is One Day
                    x_right_snap_window     := 1; -- Max possible Value is One Day
        WHEN OTHERS THEN
            FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
    END;

    /* Commenting this out because as per new design,
    negative values are allowed.
    Reset Value to 0 if computed value is negative
    l_stmt_num := 50;
    IF (l_this_level_min_window < 0) THEN
        l_this_level_min_window := 0;
    END IF;
    */

--dbms_output.put_line('PARENT = '||l_this_level_min_window*24);

    /* Find right anp window for Dependencies with Siblings */

    BEGIN
        l_stmt_num := 60;

        SELECT  MIN(WDJ2.SCHEDULED_START_DATE - WDJ1.SCHEDULED_COMPLETION_DATE)
        INTO    l_min_right_snap_window
        FROM    WIP_SCHED_RELATIONSHIPS WSR,
                WIP_DISCRETE_JOBS WDJ1,
                WIP_DISCRETE_JOBS WDJ2
        WHERE   WSR.PARENT_OBJECT_TYPE_ID  = 1
        AND     WSR.CHILD_OBJECT_TYPE_ID   = 1
        AND     WSR.PARENT_OBJECT_ID         = l_work_object_id
        AND     WSR.PARENT_OBJECT_TYPE_ID    = l_work_object_type_id
        AND     WSR.RELATIONSHIP_TYPE           = 2
        AND     WDJ2.WIP_ENTITY_ID          = WSR.CHILD_OBJECT_ID
        -- AND     WDJ2.STATUS_TYPE            IN (3,4,5,6,7,12,14,15)
        AND     WDJ1.WIP_ENTITY_ID          = l_work_object_id;

    -- Commented the below where clause because no status checks as per new design.
        --AND     WDJ1.STATUS_TYPE            IN (3,4,5,6,7,12,14,15);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
--dbms_output.put_line('Inside Sibling NO DATA FOUND');
            l_min_right_snap_window := l_this_level_min_window;
        WHEN OTHERS THEN
            FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
    END;


    /* Commented out the check below because -ive values are allowed now.
    Reset value to 0 is computed value is negative
    l_stmt_num := 70;
    IF (l_min_right_snap_window < 0 ) THEN
        l_min_right_snap_window := 0;
    END IF;
    */


--dbms_output.put_line('SIBLINGS = '||l_min_right_snap_window*24);

    /* Find the Min of parent and siblings value */
    l_stmt_num := 80;
    IF (l_min_right_snap_window < l_this_level_min_window) THEN
        l_this_level_min_window := l_min_right_snap_window;
    END IF;

    /* Reset other variable */
    l_stmt_num := 90;
    l_next_level_min_window := l_this_level_min_window;
    x_right_snap_window     := l_this_level_min_window;

--dbms_output.put_line('THIS LEVEL = '||l_this_level_min_window);

    /* Call API to Calculate reccusively for successive levels for AHL Jobs*/
    l_stmt_num := 95;

    SELECT  NVL(WDJ.MAINTENANCE_OBJECT_SOURCE,1)
    INTO    l_maintenance_object_source
    FROM    WIP_DISCRETE_JOBS WDJ
    WHERE   WDJ.WIP_ENTITY_ID       = l_work_object_id
    AND     l_work_object_type_id   = 1;

    IF (l_maintenance_object_source = 2) THEN -- ONLY for AHL Jobs

        l_stmt_num := 100;
        EAM_WO_NETWORK_DEFAULT_PVT.Find_Right_Snap_Window
            (
            p_api_version                   => 1.0,
            p_starting_object_id            => l_work_object_id,
            p_starting_obj_type_id          => l_work_object_type_id,

            p_parent_object_id              => l_work_object_id,
            p_parent_object_type_id         => l_work_object_type_id,
            p_cur_right_snap_window         => l_this_level_min_window,

            x_right_snap_window             => l_next_level_min_window,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data
            );
    END IF;

    /* Store returned min value into the Return Variable */
    l_stmt_num := 110;
    x_right_snap_window := l_next_level_min_window;


	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);


    END Snap_Right_Window;



    /*******************************************************************
    * Procedure	: Snap_Left_Window
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This API return the Max Left Snap Window for a Work Order
    *             in number of days. The Max value of the return Variable is 1 day.
    *********************************************************************/
    PROCEDURE Snap_Left_Window
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_left_snap_window              OUT NOCOPY  NUMBER,
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        )


    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Snap_Left_Window';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_work_object_id            NUMBER;
    l_work_object_type_id       NUMBER;
    l_wo_in_planning            NUMBER;

    l_this_level_min_window     NUMBER;
    l_next_level_min_window     NUMBER;
    l_min_left_snap_window      NUMBER;

    l_maintenance_object_source NUMBER;

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);

    l_exception_msg             VARCHAR2(1000);

   BEGIN
	-- Standard Start of API savepoint
    SAVEPOINT	EAM_WO_NETWORK_DEFAULT_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;
    l_work_object_id        := p_work_object_id;
    l_work_object_type_id   := p_work_object_type_id;
    l_wo_in_planning        := 0;
    l_maintenance_object_source := 1; --EAM



    /* Commenting this out because no status checks as per new design.
    If the current work order is still in planning, return 1
    l_stmt_num := 20;
    BEGIN
    SELECT  COUNT(WDJ.WIP_ENTITY_ID)
    INTO    l_wo_in_planning
    FROM    WIP_DISCRETE_JOBS WDJ
    WHERE   WDJ.WIP_ENTITY_ID       = l_work_object_id
    AND     l_work_object_type_id   = 1
    AND     WDJ.STATUS_TYPE        NOT IN (3,4,5,6,7,12,14,15);
    EXCEPTION
        WHEN OTHERS THEN
            l_wo_in_planning        := 0;
    END;
    If work order is still in planning stages, return the Max value of 1
    l_stmt_num := 30;
    IF (l_wo_in_planning = 1) THEN
        x_left_snap_window := 1.0;
        RETURN;
    END IF;
    */



    /* Find Constraining Parent Window window to the left*/
    BEGIN
    l_stmt_num := 40;

    SELECT  (WDJ2.SCHEDULED_START_DATE - WDJ1.SCHEDULED_START_DATE)
    INTO    l_this_level_min_window
    FROM    WIP_SCHED_RELATIONSHIPS WSR,
            WIP_DISCRETE_JOBS WDJ1,
            WIP_DISCRETE_JOBS WDJ2
    WHERE   WSR.CHILD_OBJECT_ID         = l_work_object_id
    AND     WSR.CHILD_OBJECT_TYPE_ID    = l_work_object_type_id
    AND     WSR.CHILD_OBJECT_TYPE_ID    = 1
    AND     WSR.RELATIONSHIP_TYPE       = 1
    AND     WSR.PARENT_OBJECT_TYPE_ID   = 1
    AND     WDJ1.WIP_ENTITY_ID          = WSR.PARENT_OBJECT_ID
    AND     WDJ2.WIP_ENTITY_ID          = l_work_object_id;

    -- Commenting out line below bcos no status checks as per new design.
    -- AND     WDJ2.STATUS_TYPE            IN (3,4,5,6,7,12,14,15);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
--dbms_output.put_line('Inside parent NO DATA FOUND');
                    l_this_level_min_window := 1; -- Max possible Value is One Day
                    l_next_level_min_window := 1; -- Max possible Value is One Day
                    x_left_snap_window     := 1; -- Max possible Value is One Day
        WHEN OTHERS THEN
            FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
    END;

    /* commenting out; as -ive values are allowed as per new design.
    Reset Value to 0 if computed value is negative
    l_stmt_num := 50;
    IF (l_this_level_min_window < 0) THEN
        l_this_level_min_window := 0;
    END IF;
    */

--dbms_output.put_line('LEFT PARENT = '||l_this_level_min_window*24);

    /* Find left snap window for Dependencies with Siblings */

    BEGIN
        l_stmt_num := 60;

        SELECT  MIN(WDJ1.SCHEDULED_START_DATE - WDJ2.SCHEDULED_COMPLETION_DATE)
        INTO    l_min_left_snap_window
        FROM    WIP_SCHED_RELATIONSHIPS WSR,
                WIP_DISCRETE_JOBS WDJ1,
                WIP_DISCRETE_JOBS WDJ2
        WHERE   WSR.PARENT_OBJECT_TYPE_ID  = 1
        AND     WSR.CHILD_OBJECT_TYPE_ID   = 1
        AND     WSR.CHILD_OBJECT_ID         = l_work_object_id
        AND     WSR.CHILD_OBJECT_TYPE_ID    = l_work_object_type_id
        AND     WSR.RELATIONSHIP_TYPE           = 2
        AND     WDJ2.WIP_ENTITY_ID          = WSR.PARENT_OBJECT_ID
        --AND     WDJ2.STATUS_TYPE            IN (3,4,5,6,7,12,14,15)
        AND     WDJ1.WIP_ENTITY_ID          = l_work_object_id;

        -- Commented out bcos no status checks as per new design.
        -- AND     WDJ1.STATUS_TYPE            IN (3,4,5,6,7,12,14,15);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
--dbms_output.put_line('Inside Sibling NO DATA FOUND');
            l_min_left_snap_window := l_this_level_min_window;
        WHEN OTHERS THEN
            FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
    END;

    /* Commented out; bcos -ive values are allowed per new design.
    Reset value to 0 is computed value is negative
    l_stmt_num := 70;
    IF (l_min_left_snap_window < 0 ) THEN
        l_min_left_snap_window := 0;
    END IF;
    */

--dbms_output.put_line('SIBLINGS = '||l_min_left_snap_window*24);

    /* Find the Min of parent and siblings value */
    l_stmt_num := 80;
    IF (l_min_left_snap_window < l_this_level_min_window) THEN
        l_this_level_min_window := l_min_left_snap_window;
    END IF;

    /* Reset other variable */
    l_stmt_num := 90;
    l_next_level_min_window := l_this_level_min_window;
    x_left_snap_window     := l_this_level_min_window;

--dbms_output.put_line('THIS LEVEL = '||l_this_level_min_window);

    /* Call API to Calculate reccusively for successive levels for AHL Jobs*/
    l_stmt_num := 95;

    SELECT  NVL(WDJ.MAINTENANCE_OBJECT_SOURCE,1)
    INTO    l_maintenance_object_source
    FROM    WIP_DISCRETE_JOBS WDJ
    WHERE   WDJ.WIP_ENTITY_ID       = l_work_object_id
    AND     l_work_object_type_id   = 1;

    IF (l_maintenance_object_source = 2) THEN -- ONLY for AHL Jobs

        l_stmt_num := 100;
        EAM_WO_NETWORK_DEFAULT_PVT.Find_Left_Snap_Window
            (
            p_api_version                   => 1.0,
            p_starting_object_id            => l_work_object_id,
            p_starting_obj_type_id          => l_work_object_type_id,

            p_parent_object_id              => l_work_object_id,
            p_parent_object_type_id         => l_work_object_type_id,
            p_cur_left_snap_window          => l_this_level_min_window,

            x_left_snap_window              => l_next_level_min_window,
            x_return_status                 => l_return_status,
            x_msg_count                     => l_msg_count,
            x_msg_data                      => l_msg_data
            );
    END IF;

    /* Store returned min value into the Return Variable */
    l_stmt_num := 110;
    x_left_snap_window := l_next_level_min_window;


	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);


    END Snap_Left_Window;


    /*******************************************************************
    * Procedure	: Find_Right_Snap_Window
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This function will be called resccursively to find
    *             The min allowable right snap window between dependent
    *             work orders that do not belong to the same starting parent
    *********************************************************************/


    PROCEDURE Find_Right_Snap_Window
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_starting_object_id            IN      NUMBER,
        p_starting_obj_type_id          IN      NUMBER,
        p_parent_object_id              IN      NUMBER,
        p_parent_object_type_id         IN      NUMBER,
        p_cur_right_snap_window         IN      NUMBER, -- IN  Days

        x_right_snap_window             OUT NOCOPY  NUMBER, -- In Days
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        )

    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Find_Right_Snap_Window';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_starting_object_id        NUMBER;
    l_starting_obj_type_id      NUMBER;
    l_parent_object_id          NUMBER;
    l_parent_object_type_id     NUMBER;
    l_released_rowcount         NUMBER;
    l_cur_right_snap_window     NUMBER; -- In Days
    l_min_right_snap_window     NUMBER; -- In Days
    l_this_level_min_window     NUMBER; -- In Days
    l_next_level_min_window     NUMBER; -- In Days

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);
    --l_Mesg_Token_Tbl            EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;


   CURSOR constrained_children_cur (l_p_object NUMBER, l_p_object_type NUMBER) IS
    SELECT  WSR.CHILD_OBJECT_ID,
            WSR.CHILD_OBJECT_TYPE_ID
    FROM    WIP_SCHED_RELATIONSHIPS WSR
    WHERE   WSR.PARENT_OBJECT_ID        = l_p_object
    AND     WSR.PARENT_OBJECT_TYPE_ID   = l_p_object_type
    AND     WSR.RELATIONSHIP_TYPE       = 1;


   BEGIN
	-- Standard Start of API savepoint

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;

    l_parent_object_type_id       := p_parent_object_type_id;
    l_parent_object_id            := p_parent_object_id;
    l_cur_right_snap_window       := p_cur_right_snap_window;
    l_min_right_snap_window       := p_cur_right_snap_window;
    l_this_level_min_window       := p_cur_right_snap_window;
    l_next_level_min_window       := p_cur_right_snap_window;
    x_right_snap_window           := p_cur_right_snap_window;
    l_starting_object_id          := p_starting_object_id;
    l_starting_obj_type_id        := p_starting_obj_type_id;

    /* Open Cursor for the current parent */

    FOR child IN constrained_children_cur (l_parent_object_id, l_parent_object_type_id)
    LOOP

--dbms_output.put_line('Parent ='|| l_parent_object_id);
--dbms_output.put_line('Child ='|| child.child_object_id);
--dbms_output.put_line(' ');

        l_stmt_num := 20;

     /* *****************************************************************************
       Find Min Window between Dependent released work orders that does
       not fall within the current parent.
       Stop further processing and RETURN
       Statuses are: 3- Released, 4 - Complete, 5- Complete No Charge
       6 - On Hold, 7- Cancelled, 12 - Closed, 14- Pending Close, 15 - Failed Close
       ************************************************************************** */

    BEGIN
        SELECT  MIN(WDJ2.SCHEDULED_START_DATE-WDJ1.SCHEDULED_COMPLETION_DATE)
        INTO    l_min_right_snap_window
        FROM    WIP_SCHED_RELATIONSHIPS WSR,
                WIP_DISCRETE_JOBS WDJ1,
                WIP_DISCRETE_JOBS WDJ2
        WHERE   WSR.PARENT_OBJECT_TYPE_ID  = 1
        AND     WSR.CHILD_OBJECT_TYPE_ID   = 1
        AND     WSR.PARENT_OBJECT_ID         = l_parent_object_id
        AND     WSR.PARENT_OBJECT_TYPE_ID    = l_parent_object_type_id
        AND     WSR.RELATIONSHIP_TYPE           = 2
        AND     WSR.RELATIONSHIP_STATUS         = 3
        AND     WDJ2.WIP_ENTITY_ID          = WSR.CHILD_OBJECT_ID
        -- AND     WDJ2.STATUS_TYPE            IN (3,4,5,6,7,12,14,15)
        AND     WDJ1.WIP_ENTITY_ID          = l_parent_object_id
        -- Commented out;bcos no status checks as per new design.
        -- AND     WDJ1.STATUS_TYPE            IN (3,4,5,6,7,12,14,15)
        AND     WDJ2.WIP_ENTITY_ID   NOT IN (
                        SELECT  WSR2.CHILD_OBJECT_ID CHILD_OBJECT_ID
                        FROM    WIP_SCHED_RELATIONSHIPS WSR2
                        WHERE   WSR2.RELATIONSHIP_TYPE      = 1
                        AND     l_starting_obj_type_id      = 1
                        CONNECT BY  prior WSR2.CHILD_OBJECT_ID   = WSR2.PARENT_OBJECT_ID
                        START WITH  WSR2.PARENT_OBJECT_ID   = l_starting_object_id
                        );

    EXCEPTION
        WHEN OTHERS THEN
            l_min_right_snap_window := l_cur_right_snap_window;
--dbms_output.put_line('Inside Exception');
    END;

    /* Commented out;bcos -ive values are allowed as per new design.
    Reset value to 0 if computed value is negative
    l_stmt_num := 30;
    IF (l_min_right_snap_window < 0 ) THEN
        l_min_right_snap_window := 0;
    END IF;
    */


    /* Find the Min of input parameter and the calculated value for the current level */
    l_stmt_num := 40;
    IF (l_min_right_snap_window < l_cur_right_snap_window) THEN
        l_this_level_min_window := l_min_right_snap_window;
    END IF;


    /* Recursive Call to the Min Window Finding API */
    l_stmt_num := 50;
    EAM_WO_NETWORK_DEFAULT_PVT.Find_Right_Snap_Window
        (
        p_api_version                   => 1.0,
        p_starting_object_id            => l_starting_object_id,
        p_starting_obj_type_id          => l_starting_obj_type_id,

        p_parent_object_id              => child.child_object_id,
        p_parent_object_type_id         => child.child_object_type_id,
        p_cur_right_snap_window         => l_this_level_min_window,

        x_right_snap_window             => l_next_level_min_window,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END IF;



    END LOOP;

    /* Store Min Value in the return Variable */
    l_stmt_num := 60;
    x_right_snap_window           := l_next_level_min_window;

    /* Commented out;bcos -ive value is allowed as per new design.
    Reset value to 0 if computed value is negative
    l_stmt_num := 70;
    IF ( x_right_snap_window < 0 ) THEN
        x_right_snap_window := 0;
    END IF;
    */

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);

        RETURN;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

        RETURN;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

        RETURN;
    END Find_Right_Snap_Window;




    /*******************************************************************
    * Procedure	: Find_Left_Snap_Window
    * Returns	: None
    * Parameters IN :
    * Parameters OUT NOCOPY: Work Object ID, Work Object Type
    *                 Mesg Token Table
    *                 Return Status
    * Purpose	: This function will be called resccursively to find
    *             The min allowable left snap window between dependent
    *             work orders that do not belong to the same starting parent
    *********************************************************************/


    PROCEDURE Find_Left_Snap_Window
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_starting_object_id            IN      NUMBER,
        p_starting_obj_type_id          IN      NUMBER,
        p_parent_object_id              IN      NUMBER,
        p_parent_object_type_id         IN      NUMBER,
        p_cur_left_snap_window          IN      NUMBER, -- IN  Days

        x_left_snap_window              OUT NOCOPY  NUMBER, -- In Days
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        )

    IS
	l_api_name			      CONSTANT VARCHAR2(30)	:= 'Find_Left_Snap_Window';
	l_api_version           	CONSTANT NUMBER 	:= 1.0;

    l_stmt_num                  NUMBER;
    l_starting_object_id        NUMBER;
    l_starting_obj_type_id      NUMBER;
    l_parent_object_id          NUMBER;
    l_parent_object_type_id     NUMBER;
    l_released_rowcount         NUMBER;
    l_cur_left_snap_window      NUMBER; -- In Days
    l_min_left_snap_window      NUMBER; -- In Days
    l_this_level_min_window     NUMBER; -- In Days
    l_next_level_min_window     NUMBER; -- In Days

    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(1000);
    --l_Mesg_Token_Tbl            EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;


   CURSOR constrained_children_cur (l_p_object NUMBER, l_p_object_type NUMBER) IS
    SELECT  WSR.CHILD_OBJECT_ID,
            WSR.CHILD_OBJECT_TYPE_ID
    FROM    WIP_SCHED_RELATIONSHIPS WSR
    WHERE   WSR.PARENT_OBJECT_ID        = l_p_object
    AND     WSR.PARENT_OBJECT_TYPE_ID   = l_p_object_type
    AND     WSR.RELATIONSHIP_TYPE       = 1;


   BEGIN
	-- Standard Start of API savepoint

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	  l_api_version        	,
        	    	    	    	 	      p_api_version        	,
   	       	    	 			              l_api_name 	    	,
		    	    	    	    	      G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	-- API body

    /* Initialize the local variables */
    l_stmt_num := 10;

    l_parent_object_type_id       := p_parent_object_type_id;
    l_parent_object_id            := p_parent_object_id;
    l_cur_left_snap_window        := p_cur_left_snap_window;
    l_min_left_snap_window        := p_cur_left_snap_window;
    l_this_level_min_window       := p_cur_left_snap_window;
    l_next_level_min_window       := p_cur_left_snap_window;
    x_left_snap_window            := p_cur_left_snap_window;
    l_starting_object_id          := p_starting_object_id;
    l_starting_obj_type_id        := p_starting_obj_type_id;

    /* Open Cursor for the current parent */

    FOR child IN constrained_children_cur (l_parent_object_id, l_parent_object_type_id)
    LOOP

--dbms_output.put_line('Parent ='|| l_parent_object_id);
--dbms_output.put_line('Child ='|| child.child_object_id);
--dbms_output.put_line(' ');

        l_stmt_num := 20;

     /* *****************************************************************************
       Find Min Window between Dependent released work orders that does
       not fall within the current parent.
       Stop further processing and RETURN
       Statuses are: 3- Released, 4 - Complete, 5- Complete No Charge
       6 - On Hold, 7- Cancelled, 12 - Closed, 14- Pending Close, 15 - Failed Close
       ************************************************************************** */

    BEGIN
        SELECT  MIN(WDJ2.SCHEDULED_START_DATE-WDJ1.SCHEDULED_COMPLETION_DATE)
        INTO    l_min_left_snap_window
        FROM    WIP_SCHED_RELATIONSHIPS WSR,
                WIP_DISCRETE_JOBS WDJ1,
                WIP_DISCRETE_JOBS WDJ2
        WHERE   WSR.PARENT_OBJECT_TYPE_ID  = 1
        AND     WSR.CHILD_OBJECT_TYPE_ID   = 1
        AND     WSR.CHILD_OBJECT_ID         = l_parent_object_id
        AND     WSR.CHILD_OBJECT_TYPE_ID    = l_parent_object_type_id
        AND     WSR.RELATIONSHIP_TYPE           = 2
        AND     WSR.RELATIONSHIP_STATUS         = 3
        AND     WDJ1.WIP_ENTITY_ID          = WSR.PARENT_OBJECT_ID
        -- AND     WDJ1.STATUS_TYPE            IN (3,4,5,6,7,12,14,15)
        AND     WDJ2.WIP_ENTITY_ID          = l_parent_object_id
        -- Commented out;bcos no status checks as per new design.
        -- AND     WDJ2.STATUS_TYPE            IN (3,4,5,6,7,12,14,15)
        AND     WDJ1.WIP_ENTITY_ID   NOT IN (
                        SELECT  WSR2.CHILD_OBJECT_ID CHILD_OBJECT_ID
                        FROM    WIP_SCHED_RELATIONSHIPS WSR2
                        WHERE   WSR2.RELATIONSHIP_TYPE      = 1
                        AND     l_starting_obj_type_id      = 1
                        CONNECT BY  prior WSR2.CHILD_OBJECT_ID   = WSR2.PARENT_OBJECT_ID
                        START WITH  WSR2.PARENT_OBJECT_ID   = l_starting_object_id
                        );

    EXCEPTION
        WHEN OTHERS THEN
            l_min_left_snap_window := l_cur_left_snap_window;
--dbms_output.put_line('Inside Exception');
    END;

    /* Commented out;bcos -ive values are allowed as per new design.
    Reset value to 0 if computed value is negative
    l_stmt_num := 30;
    IF (l_min_left_snap_window < 0 ) THEN
        l_min_left_snap_window := 0;
    END IF;
    */


    /* Find the Min of input parameter and the calculated value for the current level */
    l_stmt_num := 40;
    IF (l_min_left_snap_window < l_cur_left_snap_window) THEN
        l_this_level_min_window := l_min_left_snap_window;
    END IF;


    /* Recursive Call to the Min Window Finding API */
    l_stmt_num := 50;
    EAM_WO_NETWORK_DEFAULT_PVT.Find_Left_Snap_Window
        (
        p_api_version                   => 1.0,
        p_starting_object_id            => l_starting_object_id,
        p_starting_obj_type_id          => l_starting_obj_type_id,

        p_parent_object_id              => child.child_object_id,
        p_parent_object_type_id         => child.child_object_type_id,
        p_cur_left_snap_window          => l_this_level_min_window,

        x_left_snap_window              => l_next_level_min_window,
        x_return_status                 => l_return_status,
        x_msg_count                     => l_msg_count,
        x_msg_data                      => l_msg_data
        );

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END IF;



    END LOOP;

    /* Store Min Value in the return Variable */
    l_stmt_num := 60;
    x_left_snap_window           := l_next_level_min_window;

    /* Commented out;bcos -ive values are allowed as per new design.
    Reset value to 0 if computed value is negative
    l_stmt_num := 70;
    IF ( x_left_snap_window < 0 ) THEN
        x_left_snap_window := 0;
    END IF;
    */


	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		--dbms_output.put_line('committing');
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count    	,
        		p_data          	=>      x_msg_data
    		);

        RETURN;
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(
            p_count         	=>      x_msg_count,
			p_data          	=>      x_msg_data
    		);

        RETURN;
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name||'('||l_stmt_num||')'
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count,
        		p_data          	=>      x_msg_data
    		);

        RETURN;

    END Find_Left_Snap_Window;


--This procedure is called from procedure 'Delink_Child_From_Parent'
--This sets the workorder dates to be the maximum of its operations and child workorders dates
PROCEDURE Shrink_Parent
(
	p_parent_object_id              IN NUMBER,
	p_parent_object_type_id         IN NUMBER
)
IS
	l_parent_object_id     NUMBER;
        l_parent_object_type_id     NUMBER;

        l_min_date  DATE;
        l_max_date  DATE;
        l_op_start_date      DATE;
        l_op_end_date        DATE;
	l_wo_start_date      DATE;
	l_wo_end_date        DATE;
	l_requested_start_date   DATE;
	l_requested_due_date     DATE;
	l_status_type  NUMBER;
	l_date_completed   DATE;

        TYPE l_relationship_records IS REF CURSOR RETURN WIP_SCHED_RELATIONSHIPS%ROWTYPE;
        l_constrained_children      l_relationship_records;
        l_relationship_record       WIP_SCHED_RELATIONSHIPS%ROWTYPE;

BEGIN

      l_parent_object_id := p_parent_object_id;
      l_parent_object_type_id := p_parent_object_type_id;

      -- Find the min start date and max end date of all
      -- constrained children for this parent

     -- find the list of constrained children
     IF NOT l_constrained_children%ISOPEN THEN
       OPEN l_constrained_children FOR
         select * from
         wip_sched_relationships
         where relationship_type = 1
         and parent_object_id = l_parent_object_id
         and parent_object_type_id = l_parent_object_type_id;
     END IF;

      LOOP FETCH l_constrained_children into
        l_relationship_record;

        if l_relationship_record.child_object_id is not null then

		  select scheduled_start_date, scheduled_completion_date, status_type, date_completed
		  into l_wo_start_date, l_wo_end_date,l_status_type,l_date_completed
		  from wip_discrete_jobs
		  where wip_entity_id = l_relationship_record.child_object_id;

   --do not consider child workorders which are cancelled or [closed and date_completed is null](closed from cancelled status)
			       IF NOT(
			               l_status_type = 7
				       OR ((l_status_type IN (12,14,15)) AND (l_date_completed IS NULL))
				       ) THEN
							IF l_min_date is null OR
							l_min_date > l_wo_start_date THEN
							  l_min_date := l_wo_start_date;
							END IF;

							IF l_max_date is null OR
							l_max_date < l_wo_end_date THEN
							  l_max_date := l_wo_end_date;
							END IF;
                                END IF;
        end if;

        EXIT WHEN l_constrained_children%NOTFOUND;
      END LOOP;

      CLOSE l_constrained_children;

      SELECT requested_start_date,due_date
      INTO l_requested_start_date,l_requested_due_date
      FROM WIP_DISCRETE_JOBS
      WHERE wip_entity_id=l_parent_object_id;

      select min(first_unit_start_date),max(last_unit_completion_date)
      INTO l_op_start_date,l_op_end_date
      from wip_operations
      where wip_entity_id=l_parent_object_id;

      IF(l_op_start_date IS NULL AND l_min_date IS NULL) THEN     --no op or children
         l_wo_start_date:= NVL(l_requested_start_date,l_requested_due_date);   --pick up requested_start_date or due_date
	 l_wo_end_date:=l_wo_start_date;
      ELSIF(l_op_start_date IS NULL OR l_min_date IS NULL) THEN    --either op or children present
         l_wo_start_date:= NVL(l_op_start_date,l_min_date);   --pick up dates of op or children
	 l_wo_end_date:=NVL(l_op_end_date,l_max_date);
      ELSE                                               --both op and children present
         IF(l_min_date<l_op_start_date)                  --find min and max of op and children dates
	 THEN l_wo_start_date:=l_min_date;
	 ELSE
	    l_wo_start_date:=l_op_start_date;
	 END IF;

         IF(l_max_date>l_op_end_date)
	 THEN l_wo_end_date:=l_max_date;
	 ELSE
	    l_wo_end_date := l_op_end_date;
	 END IF;
      END IF;

        UPDATE WIP_DISCRETE_JOBS set
        scheduled_start_date = l_wo_start_date,
        scheduled_completion_date = l_wo_end_date
        where wip_entity_id = l_parent_object_id;

END SHRINK_PARENT;


END EAM_WO_NETWORK_DEFAULT_PVT;

/
