--------------------------------------------------------
--  DDL for Package Body EAM_WOLCOSTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WOLCOSTING_PUB" AS
/* $Header: EAMWWOHB.pls 115.7 2004/04/02 03:35:41 samjain noship $ */
   -- Start of comments
   -- API name    : insert_into_snapshot_pub
   -- Type     :  Private.
   -- Function : Insert the hierarchy into the CST_EAM_HIERARCHY_SNAPSHOT table.
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version           IN NUMBER
   --	p_init_msg_list    	 VARCHAR2:= FND_API.G_FALSE
   --	p_commit 		 VARCHAR2:= FND_API.G_FALSE
   --	p_validation_level 	 NUMBER:= FND_API.G_VALID_LEVEL_FULL
   --	p_wip_entity_id 	 NUMBER
   --	p_object_type 		 NUMBER
   --	p_parent_object_type 	 NUMBER
   --   p_org_id                 NUMBER
   -- OUT      x_group_id       NOCOPY  NUMBER,
   --	x_return_status		NOCOPY VARCHAR2
   --	x_msg_count		NOCOPY NUMBER
   --	x_msg_data		NOCOPY VARCHAR2
   -- Notes    : None
   --
   -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_wolcosting_pub';
   g_debug    CONSTANT  VARCHAR2(1):=NVL(fnd_profile.value('APPS_DEBUG'),'N');

  l_data_error_rollupCost VARCHAR2(2000);
  l_index_error_rollupCost NUMBER;
  l_msg_data VARCHAR2(2000);

--Bug3544656: Added a parameter to pass the relationship type

   PROCEDURE insert_into_snapshot_pub(
      p_api_version           IN NUMBER   ,
	p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
	p_commit 		IN VARCHAR2:= FND_API.G_FALSE,
	p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
	p_wip_entity_id 	IN NUMBER,
	p_object_type 		IN NUMBER,
	p_parent_object_type 	IN NUMBER,
	x_group_id      OUT NOCOPY  NUMBER,
	x_return_status       OUT NOCOPY   VARCHAR2,
	x_msg_count	    OUT	NOCOPY NUMBER	,
	x_msg_data	    OUT	NOCOPY VARCHAR2 ,
	p_org_id                IN NUMBER,
	p_relationship_type IN NUMBER :=3)
   IS
      l_api_name       CONSTANT VARCHAR2(30) := 'insert_into_snapshot_pub';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
      l_group_id       NUMBER(15);
      l_count_child_object_id NUMBER(15);

--Bug3544656: Modified the cursor definition to pick the relationship type being passed.

      CURSOR c_hierarchy (l_group_id NUMBER) IS
        SELECT
	  l_group_id,
	  CHILD_OBJECT_ID,
	  p_object_type child_object_type,
	  PARENT_OBJECT_ID,
	  p_parent_object_type parent_object_type,
	  level,
	  sysdate last_update_date,
	  FND_GLOBAL.USER_ID last_updated_by,
	  sysdate creation_date,
	  FND_GLOBAL.USER_ID created_by,
	  null request_id,
	  FND_GLOBAL.PROG_APPL_ID prog_appl_id ,
	  null last_update_login
	FROM  EAM_WO_RELATIONSHIPS ewr
	WHERE
	  ewr.parent_relationship_type = p_relationship_type
	START WITH ewr.parent_object_id = p_wip_entity_id AND ewr.parent_relationship_type = p_relationship_type
	CONNECT BY ewr.parent_object_id = PRIOR ewr.child_object_id AND ewr.parent_relationship_type = p_relationship_type ;


   BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT insert_into_snapshot_pub;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_boolean(p_init_msg_list) THEN
         FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := FND_API.g_ret_sts_success;

      -- API body

	-- Insert the data into the cst_eam_hierarchy_snapshot table

	SELECT MTL_EAM_ASSET_ACTIVITIES_S.nextval INTO x_group_id
	FROM DUAL;

	-- Insert only the top level workorder in questin as level 0 for rollup cost.


	INSERT INTO CST_EAM_HIERARCHY_SNAPSHOT(
	  GROUP_ID,
	  OBJECT_ID,
	  OBJECT_TYPE,
	  PARENT_OBJECT_ID,
	  PARENT_OBJECT_TYPE ,
	  LEVEL_NUM,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  CREATION_DATE,
	  CREATED_BY,
	  REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  LAST_UPDATE_LOGIN)
        SELECT
	  x_group_id,
	  p_wip_entity_id AS object_id,   -- the starting parent needs to be its child with level 0
	  p_object_type,
	  p_wip_entity_id AS parent_object_id,
	  p_parent_object_type,
	  0,			-- top level parent should be at level 0
	  sysdate,
	  FND_GLOBAL.USER_ID,
	  sysdate,
	  FND_GLOBAL.USER_ID,
	  null,
	  FND_GLOBAL.PROG_APPL_ID,
	  null
	FROM  DUAL;



	-- Insert the child WO and the relation with levels 1,2,3...
	FOR c_hierarchy_row IN c_hierarchy(x_group_id)
	LOOP
	    /* CHECK TO AVOID DUPLICATION OF THE SAME WORKORDER.
	     * IF NOT ALREADY INSERTED THEN ONLY IT SHOULD BE INSERTED
	     */

		  INSERT INTO CST_EAM_HIERARCHY_SNAPSHOT(
		    GROUP_ID,
		   OBJECT_ID,
		   OBJECT_TYPE,
		   PARENT_OBJECT_ID,
		   PARENT_OBJECT_TYPE ,
		   LEVEL_NUM,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   CREATION_DATE,
		   CREATED_BY,
		   REQUEST_ID,
		   PROGRAM_APPLICATION_ID,
		   LAST_UPDATE_LOGIN)
		   VALUES
		   (
		    c_hierarchy_row.l_group_id,
		    c_hierarchy_row.CHILD_OBJECT_ID,
		    c_hierarchy_row.child_object_type,
		    c_hierarchy_row.PARENT_OBJECT_ID,
		    c_hierarchy_row.parent_object_type,
		    c_hierarchy_row.level,
		    c_hierarchy_row.last_update_date,
		    c_hierarchy_row.last_updated_by,
		    c_hierarchy_row.creation_date,
		    c_hierarchy_row.created_by,
		    c_hierarchy_row.request_id,
		    c_hierarchy_row.prog_appl_id ,
		    c_hierarchy_row.last_update_login
		   );

	  END LOOP;

	FND_MSG_PUB.Add_Exc_Msg
    	    		(	p_pkg_name => G_PKG_NAME ,
    	    			p_procedure_name => l_api_name ,
				p_error_text => 'Inserted data into snapshot table. Calling the API for rollup'
	    		);

	/* Calling the API of the costing to calculate the cumulative costs */
      CST_eamCost_PUB.Rollup_WorkOrderCost(
		p_api_version => 1.0,
		p_group_id => x_group_id,
		p_organization_id => p_org_id,
		p_user_id => FND_GLOBAL.USER_ID,
		p_prog_appl_id => FND_GLOBAL.PROG_APPL_ID,
		x_return_status => x_return_status,
		p_init_msg_list => FND_API.G_TRUE,
		p_commit => FND_API.G_TRUE );

       	FND_MSG_PUB.Add_Exc_Msg
    	    		(	p_pkg_name => G_PKG_NAME ,
    	    			p_procedure_name => l_api_name ,
				p_error_text => 'Called the API'
	    		);


       -- End of API body

      -- Standard check of p_commit.
      IF FND_API.TO_BOOLEAN(p_commit) THEN
         COMMIT WORK;
	 FND_MSG_PUB.Add_Exc_Msg
    	    		(	p_pkg_name => G_PKG_NAME ,
    	    			p_procedure_name => l_api_name ,
				p_error_text => 'Committed the entry into hierarchy snapshot and rollup costs table'
	    		);
      END IF;

	-- See all the messages generated and stored into the msg table

       FND_MSG_PUB.count_and_get(
	    p_encoded => FND_API.G_FALSE,
	    p_count => x_msg_count,
	    p_data => x_msg_data
	  );

	  IF x_msg_count > 0
	  THEN
	    FOR indexCount IN 1 ..x_msg_count
	    LOOP
	      l_msg_data := FND_MSG_PUB.get(indexCount, FND_API.G_FALSE);
	      -- DBMS_OUTPUT.PUT_LINE(indexCount ||'-'||l_msg_data);
	    END LOOP;
	  END IF;


   EXCEPTION
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO insert_into_snapshot_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.count_and_get(
		    p_encoded => FND_API.G_FALSE,
		    p_count => x_msg_count,
		    p_data => x_msg_data
		  );

		  IF x_msg_count > 0
		  THEN
		    FOR indexCount IN 1 ..x_msg_count
		    LOOP
		      l_msg_data := FND_MSG_PUB.get(indexCount, FND_API.G_FALSE);
		     -- DBMS_OUTPUT.PUT_LINE(indexCount ||'-'||l_msg_data);
		    END LOOP;
		  END IF;

	WHEN OTHERS THEN
		ROLLBACK TO insert_into_snapshot_pub;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME ,
    	    			l_api_name
	    		);
		END IF;
				FND_MSG_PUB.count_and_get(
		    p_encoded => FND_API.G_FALSE,
		    p_count => x_msg_count,
		    p_data => x_msg_data
		  );
		  IF x_msg_count > 0
		  THEN
		    FOR indexCount IN 1 ..x_msg_count
		    LOOP
		      l_msg_data := FND_MSG_PUB.get(indexCount, FND_API.G_FALSE);
		      --DBMS_OUTPUT.PUT_LINE(indexCount ||'-'||l_msg_data);
		    END LOOP;
		  END IF;

   END insert_into_snapshot_pub;
END eam_wolcosting_pub;

/
