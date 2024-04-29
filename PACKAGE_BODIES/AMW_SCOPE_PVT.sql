--------------------------------------------------------
--  DDL for Package Body AMW_SCOPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_SCOPE_PVT" AS
/* $Header: amwvscpb.pls 120.15 2008/02/08 14:26:09 adhulipa ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_SCOPE_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
g_pkg_name    CONSTANT VARCHAR2 (30) := 'AMW_SCOPE_PVT';
g_file_name   CONSTANT VARCHAR2 (12) := 'amwvscpb.pls';
G_USER_ID     NUMBER  := FND_GLOBAL.USER_ID;
G_LOGIN_ID    NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

PROCEDURE raise_scope_update_event(
		p_entity_type	IN VARCHAR2,
		p_entity_id	IN NUMBER,
		p_org_id	IN NUMBER := NULL,
		p_mode		IN VARCHAR2)
IS
  l_item_key         wf_items.ITEM_KEY%TYPE;
  l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
BEGIN

  SELECT to_char(amw_scope_event_s.nextval)
    INTO l_item_key
    FROM dual;

  wf_event.addParameterToList(
		p_name => 'MODE',
		p_value => p_mode,
		p_parameterlist => l_parameter_list);

  wf_event.addParameterToList(
		p_name => 'ORGANIZATION_ID',
		p_value => p_org_id,
		p_parameterlist => l_parameter_list);


  IF p_entity_type = 'BUSIPROC_CERTIFICATION' THEN
    wf_event.addParameterToList(
		p_name => 'CERTIFICATION_ID',
		p_value => p_entity_id,
		p_parameterlist => l_parameter_list);
    wf_event.raise(
	 p_event_name     => 'oracle.apps.amw.proccert.scope.update',
	 p_event_key      => l_item_key,
	 p_parameters     => l_parameter_list);
  ELSIF p_entity_type = 'PROJECT' THEN
    wf_event.addParameterToList(
		p_name => 'AUDIT_PROJECT_ID',
		p_value => p_entity_id,
		p_parameterlist => l_parameter_list);
    wf_event.raise(
	 p_event_name     => 'oracle.apps.amw.engagement.scope.update',
	 p_event_key      => l_item_key,
	 p_parameters     => l_parameter_list);
  END IF;

END raise_scope_update_event;

PROCEDURE add_scope
(
    p_api_version_number        IN   NUMBER   := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_id			IN   NUMBER,
    p_entity_type		IN   VARCHAR2,
    p_sub_vs    		IN   VARCHAR2,
    p_lob_vs			IN   VARCHAR2,
    p_subsidiary_tbl	        IN   SUB_TBL_TYPE,
    p_lob_tbl			IN   LOB_TBL_TYPE,
    p_org_tbl       		IN   ORG_TBL_TYPE,
    p_process_tbl               IN   PROCESS_TBL_TYPE,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
)
IS

l_temp_org_id NUMBER;
l_temp_parent_id NUMBER;
l_temp_new_parent_id NUMBER;
l_org_exists VARCHAR2(1);

found_parent BOOLEAN;
found_sub_parent BOOLEAN;
found_org_parent BOOLEAN;
is_root_node BOOLEAN;

l_sub_exists VARCHAR2(1);
l_sub_code amw_audit_units_v.company_code%TYPE;
l_temp_sub_id NUMBER;
l_temp_sub_parent_id NUMBER;
l_sub_recursive_parent NUMBER;

l_lob_exists VARCHAR2(1);
l_lob_code amw_audit_units_v.lob_code%TYPE;
l_lob_recursive_parent NUMBER;
l_temp_lob_id NUMBER;
l_temp_lob_parent_id NUMBER;
found_lob_parent BOOLEAN;

l_temp_id NUMBER;
hier_name VARCHAR2(32767);

p_org_new_tbl  org_tbl_type;
p_sub_new_tbl  sub_new_tbl_type;
p_lob_new_tbl  lob_new_tbl_type;

l_api_name           CONSTANT VARCHAR2(30) := 'add_scope';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

CURSOR find_parent_subsidiary(l_organization_id NUMBER) IS
SELECT flv.flex_value_id
FROM amw_audit_units_v auv,fnd_flex_values flv
WHERE auv.subsidiary_valueset = flv.flex_value_set_id
AND   auv.company_code = flv.flex_value
AND   organization_id = l_organization_id;

CURSOR find_parent_lob(l_organization_id NUMBER) IS
SELECT flv.flex_value_id
FROM amw_audit_units_v auv,fnd_flex_values flv
WHERE auv.lob_valueset = flv.flex_value_set_id
AND   auv.lob_code = flv.flex_value
AND   organization_id = l_organization_id;

CURSOR check_lob_exists (l_organization_id NUMBER) IS
SELECT 'Y'
FROM AMW_AUDIT_UNITS_V
--WHERE LOB_valueset = p_LOB_vs
WHERE LOB_valueset IS NOT NULL
AND organization_id = l_organization_id;

CURSOR find_parent_recursive (l_child_id NUMBER) IS
SELECT  nvl( flv2.flex_value_id, -1) parent_id
FROM fnd_flex_values_vl flv, FND_FLEX_VALUE_CHILDREN_V fchild,fnd_flex_values_vl flv2
WHERE flv.flex_value = fchild.flex_value (+)
AND flv.flex_value_set_id = fchild.flex_value_set_id (+)
AND flv2.flex_value(+) = fchild.parent_flex_value
AND flv2.flex_value_set_id(+) = fchild.flex_value_set_id
AND flv.flex_value_id = l_child_id;

CURSOR get_existing_objects (l_object_type VARCHAR2) IS
SELECT distinct object_id
FROM AMW_ENTITY_HIERARCHIES
WHERE entity_type = p_entity_type
AND entity_id = p_entity_id
AND delete_flag = 'Y'
AND object_type = l_object_type;

BEGIN

	hier_name := fnd_profile.value('AMW_ORG_SECURITY_HIERARCHY');
	--hier_name := 'SUHierarchy';
	SAVEPOINT POPULATE_HIERARCHIES;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Whenever there is a change to hierarchy, the system will delete the existing hierarchy and rebuild it.
	-- To begin with mark all records in the table as DELETED
	UPDATE AMW_ENTITY_HIERARCHIES
	SET DELETE_FLAG = 'Y'
	WHERE ENTITY_ID = p_entity_id
	AND ENTITY_TYPE = p_entity_type;

	-- Create a new list of organizations
	-- The new list is existing orgs UNION newly selected orgs
	generate_organization_list
	(p_entity_id    => p_entity_id,
	p_entity_type  => p_entity_type,
	p_org_tbl      => p_org_tbl,
	p_org_new_tbl  => p_org_new_tbl);

	FOR each_rec IN 1..p_org_tbl.count
	loop
		delete from amw_execution_scope where entity_type = p_entity_type
		and entity_id = p_entity_id and organization_id = p_org_tbl(each_rec).org_id;
	end loop;

	-- Create a new list of subsidiaries
	-- Based on the list of organizations, determine only those subsidiaries that have organizations
	-- with auditable units and are in the hierarchy, mapped to the subsidiaries and
	-- add object_id into p_subsidiary_tbl
	generate_subsidiary_list
	(p_entity_id      => p_entity_id,
	p_entity_type    => p_entity_type,
	p_org_new_tbl    => p_org_new_tbl,
	p_subsidiary_tbl => p_subsidiary_tbl,
	p_sub_vs         => p_sub_vs,
	p_sub_new_tbl    => p_sub_new_tbl);

	-- Create a new list of LOBs
	-- Based on the list of organizations, determine only those LOBs that have organizations
	-- with auditable units and are in the hierarchy, mapped to the LOBs and
	-- add object_id into p_lob_tbl;
	generate_lob_list
	(p_entity_id      => p_entity_id,
	p_entity_type    => p_entity_type,
	p_org_new_tbl    => p_org_new_tbl,
	p_subsidiary_tbl => p_subsidiary_tbl,
	p_sub_vs         => p_sub_vs,
	p_lob_tbl        => p_lob_tbl,
	p_lob_vs         => p_lob_vs,
	p_lob_new_tbl    => p_lob_new_tbl);

	--Populate Legal Hierarchy/Management Hierarchy/Custom Hierarchy
	--Step 1 : Find all relevant organizations
	--Step 2 : Find all parents(subsidiaries) of such organizations from Step 1
	--Step 3 : Populate table with object_type = ORGANIZATION and parent_object_type = SUBSIDIARY
	--Step 4 : Find all parents(LOBs) of such organizations from Step 1
	--Step 5 : Populate table with object_type = ORGANIZATION and parent_object_type = LINEOFBUSINESS
	--Step 6 : Find parents of Subsidiaries all the way till the root node
	--Step 7 : Populate table with Subsidiary hierarchy
	--Step 8 : Find parents of LOBs all the way till the root node
	--Step 9 : Populate table with LOB hierarchy
	--Step 10: Find CustomORGs based on HR hierarchy all the way till the root node
	--Step 11: Populate selected CustomORGS into table and build hierarchy
	--Step 12: Call to populate amw_execution_scope with processes/org relation
	--Step 13: Call to populate association tables with object_type = 'BUSIPROC_CERTIFICATION'

	--Step 1 : Find all relevant organizations
	-- loop through all organizations in the list
	FOR each_rec IN 1..p_org_new_tbl.count LOOP

		found_sub_parent := false;
		is_root_node  := false;

		--Step 2 : Find all parents(subsidiaries) of such organizations from Step 1
		OPEN  find_parent_subsidiary(p_org_new_tbl(each_rec).org_id);
		FETCH find_parent_subsidiary INTO l_temp_sub_parent_id;
		CLOSE find_parent_subsidiary;

		--Step 3(Condition A): Populate table with object_type = ORGANIZATION and parent_object_type = SUBSIDIARY
		INSERT INTO AMW_ENTITY_HIERARCHIES
			(ENTITY_HIERARCHY_ID,
			 ENTITY_TYPE,
			 ENTITY_ID,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
             		 LAST_UPDATE_LOGIN,
			 OBJECT_TYPE,
			 OBJECT_ID,
			 PARENT_OBJECT_TYPE,
			 PARENT_OBJECT_ID,
			 LEVEL_ID)
		 SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
			p_entity_type,
			p_entity_id,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.USER_ID,
			'ORGANIZATION',
			p_org_new_tbl(each_rec).org_id,
			'SUBSIDIARY',
			l_temp_sub_parent_id,
			1
		FROM dual;

        	l_lob_exists := 'N';
		found_parent := false;

		OPEN check_lob_exists (p_org_new_tbl(each_rec).org_id);
		FETCH check_lob_exists INTO l_lob_exists;
		CLOSE check_lob_exists;

		IF ((l_lob_exists IS NOT NULL)  AND (l_lob_exists ='Y'))
		THEN
			--Step 4 : Find all parents(LOBs) of such organizations from Step 1
			OPEN  find_parent_lob(p_org_new_tbl(each_rec).org_id);
			FETCH find_parent_lob INTO l_temp_parent_id;
			CLOSE find_parent_lob;

			--Step 5(Condition A) : Populate table with object_type = ORGANIZATION and parent_object_type = LINEOFBUSINESS
			INSERT INTO AMW_ENTITY_HIERARCHIES
			(ENTITY_HIERARCHY_ID,
			 ENTITY_TYPE,
			 ENTITY_ID,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
             		 LAST_UPDATE_LOGIN,
			 OBJECT_TYPE,
			 OBJECT_ID,
			 PARENT_OBJECT_TYPE,
			 PARENT_OBJECT_ID,
			 LEVEL_ID )
			SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
			p_entity_type,
			p_entity_id,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.USER_ID,
			'ORGANIZATION',
			p_org_new_tbl(each_rec).org_id,
			'LINEOFBUSINESS',
			l_temp_parent_id,
			1
			FROM dual;

		ELSE

			--Step 5(Condition B) : Populate table with object_type = ORGANIZATION and parent_object_type = DUMMYLOB
			INSERT INTO AMW_ENTITY_HIERARCHIES
				(ENTITY_HIERARCHY_ID,
				 ENTITY_TYPE,
				 ENTITY_ID,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATE_DATE,
			 	 LAST_UPDATED_BY,
                 	  	 LAST_UPDATE_LOGIN,
				 OBJECT_TYPE,
				 OBJECT_ID,
				 PARENT_OBJECT_TYPE,
				 PARENT_OBJECT_ID,
				 LEVEL_ID )
			 SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
				p_entity_type,
				p_entity_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'ORGANIZATION',
				p_org_new_tbl(each_rec).org_id,
				'DUMMYLOB',
				-999,
				1
				FROM dual;
		END IF;

	END LOOP; -- end of FOR each_rec IN p_org_new_tbl

	--Step 6 : Find parents of Subsidiaries all the way till the root node
	-- loop through all subsidiaries in the list and populate subsidiary hierarchy
	FOR each_sub IN 1..p_sub_new_tbl.count LOOP

		l_temp_sub_id := p_sub_new_tbl(each_sub).subsidiary_id;
		l_temp_sub_parent_id := -1;
		found_sub_parent := false;
		is_root_node  := false;

        	<<OUTERLOOP>>
		WHILE ((found_sub_parent=false) AND
		       (is_root_node=false))
            	LOOP
            		OPEN  find_parent_recursive(l_temp_sub_id);
			FETCH find_parent_recursive INTO l_temp_sub_parent_id;
			CLOSE find_parent_recursive;

			IF l_temp_sub_parent_id = -1
			THEN
				is_root_node := true;
                		EXIT OUTERLOOP;
			ELSE

                	<<INNERLOOP>>
				FOR i IN 1..p_sub_new_tbl.count LOOP

				IF (l_temp_sub_parent_id = p_sub_new_tbl(i).subsidiary_id)
				THEN
					found_sub_parent := true;
					EXIT INNERLOOP;
					END IF;
				END LOOP INNERLOOP;

				IF found_sub_parent = false
				THEN
					l_temp_sub_id := l_temp_sub_parent_id;
				END IF;
			END IF;

		END LOOP OUTERLOOP;

		IF found_sub_parent = true
		THEN

			--Step 7 : Populate table with Subsidiary hierarchy
			INSERT INTO AMW_ENTITY_HIERARCHIES
				(ENTITY_HIERARCHY_ID,
				 ENTITY_TYPE,
				 ENTITY_ID,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 OBJECT_TYPE,
				 OBJECT_ID,
				 PARENT_OBJECT_TYPE,
				 PARENT_OBJECT_ID,
				 LEVEL_ID )
			SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
				p_entity_type,
				p_entity_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'SUBSIDIARY',
				p_sub_new_tbl(each_sub).subsidiary_id,
				'SUBSIDIARY',
				l_temp_sub_parent_id,
				1
				FROM dual;
		ELSE

			--Step 7 : Populate table with Subsidiary hierarchy
			INSERT INTO AMW_ENTITY_HIERARCHIES
				(ENTITY_HIERARCHY_ID,
				 ENTITY_TYPE,
				 ENTITY_ID,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 OBJECT_TYPE,
				 OBJECT_ID,
				 PARENT_OBJECT_TYPE,
				 PARENT_OBJECT_ID,
				 LEVEL_ID )
			SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
				p_entity_type,
				p_entity_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'SUBSIDIARY',
				p_sub_new_tbl(each_sub).subsidiary_id,
				'ROOTNODE',
				-1,
				1
				FROM dual;

		END IF;	--found_sub_parent = true  = false

	END LOOP;-- end of FOR each_sub IN 1..p_sub_new_tbl

	--Step 8 : Find parents of LOBs all the way till the root node
	-- loop through all LOBs in the list and populate lob hierarchy
	FOR each_lob IN 1..p_lob_new_tbl.count LOOP

		l_temp_lob_id := p_lob_new_tbl(each_lob).lob_id;
		l_temp_lob_parent_id := -1;
		found_lob_parent := false;
		is_root_node  := false;

        	<<MAINLOOP>>
		WHILE ((found_lob_parent=false) AND
		       (is_root_node=false))
        	LOOP
			OPEN  find_parent_recursive(l_temp_lob_id);
			FETCH find_parent_recursive INTO l_temp_lob_parent_id;
			CLOSE find_parent_recursive;

			IF l_temp_lob_parent_id = -1
			THEN
				is_root_node := true;
                		EXIT MAINLOOP;
			ELSE

                	<<OTHERLOOP>>
			FOR i IN 1..p_lob_new_tbl.count
			LOOP
				IF l_temp_lob_parent_id = p_lob_new_tbl(i).lob_id
                    		THEN
					found_lob_parent := true;
					EXIT OTHERLOOP;
				END IF;
			END LOOP OTHERLOOP;

			IF found_lob_parent = false
			THEN
				l_temp_lob_id := l_temp_lob_parent_id;
				END IF;
			END IF;

		END LOOP MAINLOOP;

		IF found_lob_parent = true
		THEN

			--Step 9 : Populate table with LOB hierarchy
			INSERT INTO AMW_ENTITY_HIERARCHIES
				(ENTITY_HIERARCHY_ID,
				 ENTITY_TYPE,
				 ENTITY_ID,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 OBJECT_TYPE,
				 OBJECT_ID,
				 PARENT_OBJECT_TYPE,
				 PARENT_OBJECT_ID,
				 LEVEL_ID )
			SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
				p_entity_type,
				p_entity_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'LINEOFBUSINESS',
				p_lob_new_tbl(each_lob).lob_id,
				'LINEOFBUSINESS',
				l_temp_lob_parent_id,
				1
				FROM dual;
		ELSE

        		--Step 9 : Populate table with LOB hierarchy
			INSERT INTO AMW_ENTITY_HIERARCHIES
				(ENTITY_HIERARCHY_ID,
				 ENTITY_TYPE,
				 ENTITY_ID,
				 CREATED_BY,
				 CREATION_DATE,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 OBJECT_TYPE,
				 OBJECT_ID,
				 PARENT_OBJECT_TYPE,
				 PARENT_OBJECT_ID,
				 LEVEL_ID )
			SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
				p_entity_type,
				p_entity_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'LINEOFBUSINESS',
				p_lob_new_tbl(each_lob).lob_id,
				'ROOTNODE',
				-1,
				1
				FROM dual;

		END IF;	--found_lob_parent = true

	END LOOP;-- end of FOR each_lob IN 1..p_lob_new_tbl

	--Step 11: Populate selected CustomORGS into table and build hierarchy
	--Note that CUSTOM ORGS will be stored with OBJECT TYPE as 'ORG'
    	populate_custom_hierarchy
    	(
        p_org_tbl	=>  p_org_new_tbl,
        p_entity_id     =>  p_entity_id,
        p_entity_type   =>  p_entity_type
    	);

    -- the following "if" is added to make this procedure
    -- reusable in finstmt_cert.
    IF p_entity_type <> 'FINSTMT_CERTIFICATION' THEN
	--Step 12: Call to populate amw_execution_scope with processes information
   	populate_process_hierarchy
	(
        p_entity_type           =>  p_entity_type,
	p_entity_id             =>  p_entity_id,
	p_org_tbl               =>  p_org_tbl,
   	p_process_tbl           =>  p_process_tbl,
	x_return_status         =>  l_return_status,
	x_msg_count             =>  l_msg_count,
	x_msg_data              =>  l_msg_data
	);

	--Step 13: Call to populate denormalized tables and association tables
	IF p_entity_type = 'PROJECT'
	THEN
   	        populate_proj_denorm_tables
		(
		  p_audit_project_id   => p_entity_id
		);

		build_project_audit_task
		(
		  p_api_version_number    => 1.0 ,
		  p_audit_project_id	  => p_entity_id,
		  x_return_status         =>  l_return_status,
		  x_msg_count             =>  l_msg_count,
		  x_msg_data          =>  l_msg_data
		);

	ELSIF p_entity_type = 'BUSIPROC_CERTIFICATION'
	THEN
		populate_denormalized_tables
		(
		p_entity_type => p_entity_type,
		p_entity_id   => p_entity_id,
		p_org_tbl     => p_org_new_tbl,
		p_process_tbl => p_process_tbl,
		p_mode        => 'ADD'
		);

		populate_association_tables
		(
		p_entity_type           =>  p_entity_type,
		p_entity_id             =>  p_entity_id,
		x_return_status         =>  l_return_status,
		x_msg_count             =>  l_msg_count,
		x_msg_data              =>  l_msg_data
		);

	END IF;

	--Step 14: Finally remove all the old entries from the table
	DELETE FROM AMW_ENTITY_HIERARCHIES
	WHERE DELETE_FLAG = 'Y'
	AND ENTITY_ID = p_entity_id
	AND ENTITY_TYPE = p_entity_type;

        raise_scope_update_event(
		p_entity_type	=> p_entity_type,
		p_entity_id	=> p_entity_id,
		p_mode		=> 'AddToScope');

    END IF;

	EXCEPTION WHEN OTHERS THEN
	ROLLBACK TO POPULATE_HIERARCHIES;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.Add_Exc_Msg('AMW_SCOPE_PVT', 'add_scope');
	FND_MSG_PUB.Count_And_Get(
	p_encoded =>  FND_API.G_FALSE,
	p_count   =>  x_msg_count,
	p_data    =>  x_msg_data);


END add_scope;

PROCEDURE populate_custom_hierarchy
(
    p_org_tbl	    IN 	ORG_TBL_TYPE,
    p_entity_id     IN  NUMBER,
    p_entity_type   IN  VARCHAR2
)
IS

l_temp_id NUMBER;
l_temp_parent_id NUMBER;

found_parent BOOLEAN;
is_root_org BOOLEAN;
hier_name VARCHAR2(32767);

CURSOR find_parent(l_organization_id NUMBER, hiername VARCHAR2) IS
SELECT organization_id_parent
FROM per_org_structure_elements
WHERE org_structure_version_id =(SELECT org_structure_version_id
				FROM per_org_structure_versions
				WHERE organization_structure_id =(SELECT organization_structure_id
								 FROM per_organization_structures
								 WHERE name = hiername)
				and date_to is null)
AND organization_id_child = l_organization_id;

BEGIN

    hier_name := fnd_profile.value('AMW_ORG_SECURITY_HIERARCHY');
    --hier_name := 'SUHierarchy';

   -- Step 10: Find CustomORGs based on HR hierarchy all the way till the root node
	-- loop through all organizations in the list
	FOR each_rec IN 1..p_org_tbl.count LOOP

		l_temp_id := p_org_tbl(each_rec).org_id;
		l_temp_parent_id := -9999;
		found_parent := false;
		is_root_org  := false;

        	<<CHILDLOOP>>
	    	WHILE ((found_parent=false) AND
		       (is_root_org=false)
		      )
        	LOOP

	    		OPEN find_parent(l_temp_id, hier_name);
		    	FETCH find_parent INTO l_temp_parent_id;
			IF find_parent%NOTFOUND
                	THEN
                		is_root_org := true;
                		CLOSE find_parent;
                		EXIT CHILDLOOP;
                	END IF;
                	CLOSE find_parent;


                	<<CHILDLOOP2>>
	    		FOR i IN 1..p_org_tbl.count
	    		LOOP
		  		IF l_temp_parent_id = p_org_tbl(i).org_id
                    		THEN
        				found_parent := true;
                        		EXIT CHILDLOOP2;
                    		END IF;
			END LOOP CHILDLOOP2;

    			IF found_parent = false
	    		THEN
    				l_temp_id := l_temp_parent_id;
    			END IF;

		END LOOP CHILDLOOP;

		IF found_parent = TRUE
		THEN

			--Step 11: Populate selected CustomORGS into table and build hierarchy
			INSERT INTO AMW_ENTITY_HIERARCHIES
			(ENTITY_HIERARCHY_ID,
			 ENTITY_TYPE,
			 ENTITY_ID,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_LOGIN,
			 OBJECT_TYPE,
			 OBJECT_ID,
			 PARENT_OBJECT_TYPE,
			 PARENT_OBJECT_ID,
			 LEVEL_ID )
			 SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
				p_entity_type,
				p_entity_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'ORG',
				p_org_tbl(each_rec).org_id,
				'ORG',
				l_temp_parent_id,
				1
			FROM dual;

		ELSE
			--Step 11: Populate selected CustomORGS into table and build hierarchy
			INSERT INTO AMW_ENTITY_HIERARCHIES
			(ENTITY_HIERARCHY_ID,
			 ENTITY_TYPE,
			 ENTITY_ID,
			 CREATED_BY,
			 CREATION_DATE,
			 LAST_UPDATE_DATE,
			 LAST_UPDATED_BY,
			 LAST_UPDATE_LOGIN,
             		 OBJECT_TYPE,
			 OBJECT_ID,
			 PARENT_OBJECT_TYPE,
			 PARENT_OBJECT_ID,
			 LEVEL_ID )
			 SELECT AMW_ENTITY_HIERARCHIES_S.nextval,
				p_entity_type,
				p_entity_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'ORG',
				p_org_tbl(each_rec).org_id,
				'ROOTNODE',
				-1,
				1
			FROM dual;
		END IF;

	END LOOP;

END populate_custom_hierarchy;

PROCEDURE generate_organization_list
(
    p_entity_id                 IN   NUMBER,
    p_entity_type               IN   VARCHAR2,
    p_org_tbl	            	IN   ORG_TBL_TYPE,
    p_org_new_tbl               OUT  nocopy ORG_TBL_TYPE
)
IS

CURSOR get_existing_objects (l_object_type VARCHAR2) IS
SELECT distinct object_id
FROM AMW_ENTITY_HIERARCHIES
WHERE entity_type = p_entity_type
AND entity_id = p_entity_id
AND delete_flag = 'Y'
AND object_type = l_object_type;

org_exists BOOLEAN;
l_position NUMBER;

BEGIN

	l_position := 1;

	FOR each_org IN get_existing_objects('ORGANIZATION')
	LOOP
		EXIT WHEN get_existing_objects%NOTFOUND;
        	org_exists := false;

                <<INLOOP>>
		FOR i IN 1..p_org_tbl.count LOOP
			IF (each_org.object_id = p_org_tbl(i).org_id)
			THEN
				org_exists := true;
				EXIT INLOOP;
			END IF;
		END LOOP INLOOP;

                IF org_exists = false
                THEN
                	p_org_new_tbl(l_position).org_id := each_org.object_id;
                    	l_position := l_position + 1;
                END IF;
	END LOOP;

    	FOR i IN 1..p_org_tbl.count LOOP
		p_org_new_tbl(l_position).org_id := p_org_tbl(i).org_id;
		l_position := l_position + 1;
	END LOOP;

END generate_organization_list;

PROCEDURE generate_subsidiary_list
(
    p_entity_id                 IN   NUMBER,
    p_entity_type               IN   VARCHAR2,
    p_org_new_tbl            	IN   ORG_TBL_TYPE,
    p_subsidiary_tbl            IN   sub_tbl_type,
    p_sub_vs                    IN   VARCHAR2,
    p_sub_new_tbl               OUT  nocopy  sub_new_tbl_type
)
IS

l_get_subsidiary_query VARCHAR2(32767) :=
'SELECT DISTINCT flv.flex_value_id
FROM amw_audit_units_v auv,fnd_flex_values flv
WHERE auv.subsidiary_valueset = flv.flex_value_set_id
AND auv.company_code = flv.flex_value';


l_extra_query VARCHAR2(32767);
l_final_query VARCHAR2(32767);
l_subsidiary_id NUMBER;
l_position NUMBER;

hier_name VARCHAR2(32767);

TYPE subcurtype IS REF CURSOR;
subs_cursor subcurtype;

BEGIN
	l_position := 1;

	IF(p_org_new_tbl.count > 0)
	THEN
		l_extra_query := ' AND organization_id IN ( ';
	END IF;

	FOR i IN 1..p_org_new_tbl.count
	LOOP
		l_extra_query := l_extra_query || p_org_new_tbl(i).org_id;
		IF (i = p_org_new_tbl.count)
		THEN
		    l_extra_query := l_extra_query || ' )';
		ELSE
		    l_extra_query := l_extra_query || ', ';
		END IF;
	END LOOP;

	l_final_query := l_get_subsidiary_query || l_extra_query;

	OPEN subs_cursor FOR l_final_query;
	LOOP
		FETCH subs_cursor INTO l_subsidiary_id;
		EXIT WHEN subs_cursor%NOTFOUND;
		p_sub_new_tbl(l_position).subsidiary_id := l_subsidiary_id;
		l_position := l_position + 1;
	END LOOP;
	CLOSE subs_cursor;

END generate_subsidiary_list;

PROCEDURE generate_lob_list
(
    p_entity_id                 IN   NUMBER,
    p_entity_type               IN   VARCHAR2,
    p_org_new_tbl            	IN   ORG_TBL_TYPE,
    p_subsidiary_tbl            IN   sub_tbl_type,
    p_sub_vs                    IN   VARCHAR2,
    p_lob_tbl                   IN   lob_tbl_type,
    p_lob_vs                    IN   VARCHAR2,
    p_lob_new_tbl               OUT  nocopy  lob_new_tbl_type
)
IS

TYPE lobcurtype IS REF CURSOR;
lobs_cursor lobcurtype;

l_get_lob_query VARCHAR2(32767) :=
'SELECT DISTINCT flv.flex_value_id
FROM amw_audit_units_v auv,fnd_flex_values flv
WHERE auv.lob_valueset = flv.flex_value_set_id
AND auv.lob_code = flv.flex_value';

l_extra_query VARCHAR2(32767);
l_final_query VARCHAR2(32767);
l_lob_id NUMBER;
l_position NUMBER;

hier_name VARCHAR2(32767);

BEGIN

    l_position := 1;


    IF(p_org_new_tbl.count > 0)
    THEN
    l_extra_query := ' AND organization_id IN ( ';
    END IF;

    FOR i IN 1..p_org_new_tbl.count LOOP

        l_extra_query := l_extra_query || p_org_new_tbl(i).org_id;
        IF (i = p_org_new_tbl.count)
        THEN
            l_extra_query := l_extra_query || ' )';
        ELSE
            l_extra_query := l_extra_query || ', ';
        END IF;

    END LOOP;

    l_final_query := l_get_lob_query || l_extra_query;

    OPEN lobs_cursor FOR l_final_query;
    LOOP
        FETCH lobs_cursor INTO l_lob_id;

        EXIT WHEN lobs_cursor%NOTFOUND;
        p_lob_new_tbl(l_position).lob_id := l_lob_id;
        l_position := l_position + 1;
    END LOOP;
    CLOSE lobs_cursor;

END generate_lob_list;

PROCEDURE populate_process_hierarchy
(
    p_api_version_number        IN       NUMBER := 1.0,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_entity_type               IN       VARCHAR2,
    p_entity_id		        IN	 NUMBER,
    p_org_tbl                   IN       org_tbl_type,
    p_process_tbl               IN       process_tbl_type,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
)
IS
        CURSOR c_audit_unit(p_org_id NUMBER)
        IS
        SELECT audit_v.company_code,
               audit_v.subsidiary_valueset,
               audit_v.lob_code,
               audit_v.lob_valueset,
               audit_v.organization_id
        FROM amw_audit_units_v audit_v
        WHERE organization_id = p_org_id;

        CURSOR c_sub_lob_exists (l_sub_vs amw_audit_units_v.subsidiary_valueset%TYPE,
                                 l_sub_code amw_audit_units_v.company_code%TYPE,
                                 l_lob_vs amw_audit_units_v.lob_valueset%TYPE,
                                 l_lob_code amw_audit_units_v.lob_code%TYPE)
        IS
        SELECT 'Y'
        FROM amw_audit_units_v
        WHERE subsidiary_valueset = l_sub_vs
        AND   company_code        = l_sub_code
        AND   lob_valueset        = l_lob_vs
        AND   lob_code            = l_lob_code;

	l_api_name VARCHAR2(150) := 'populate_process_hierarchy';
        l_api_version_number CONSTANT NUMBER       := 1.0;

        TYPE orgprocesstype IS REF CURSOR;
        process_cursor orgprocesstype;

        l_get_processes_query VARCHAR2(32767) :=
           'SELECT org_v.child_process_id as top_process_id,
            org_v.child_process_org_rev_id as process_org_rev_id,
            org_v.child_organization_id as organization_id,
            audit_v.company_code,
            audit_v.subsidiary_valueset,
            audit_v.lob_code,
            audit_v.lob_valueset
            FROM   amw_curr_app_hierarchy_org_v org_v,amw_audit_units_v audit_v
            WHERE org_v.parent_process_id = -2
            AND audit_v.organization_id = org_v.child_organization_id
            AND audit_v.organization_id =';

       l_extra_query VARCHAR2(32767);
       l_final_query VARCHAR2(32767);

       l_process_id NUMBER;
       l_process_org_rev_id NUMBER;
       l_organization_id NUMBER;
       l_company_code amw_audit_units_v.company_code%TYPE;
       l_subsidiary_valueset amw_audit_units_v.subsidiary_valueset%TYPE;
       l_lob_code amw_audit_units_v.lob_code%TYPE;
       l_lob_valueset amw_audit_units_v.lob_valueset%TYPE;

       l_sub_lob_exists	VARCHAR2(1);

BEGIN
        SAVEPOINT populate_proc_hierarchy;
        -- Standard call to check for call compatibility.

	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

/*	DELETE FROM AMW_EXECUTION_SCOPE
	WHERE entity_id = p_entity_id
	AND entity_type = p_entity_type
	and level_id < 4;*/

	FOR each_rec IN 1..p_org_tbl.count
	LOOP
		FOR audit_rec IN c_audit_unit(p_org_tbl(each_rec).org_id)
		LOOP
			INSERT INTO AMW_EXECUTION_SCOPE (
				EXECUTION_SCOPE_ID,
				ENTITY_TYPE,
				ENTITY_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				SCOPE_CHANGED_STATUS,
				LEVEL_ID,
				SUBSIDIARY_VS,
				SUBSIDIARY_CODE,
				LOB_VS,
				LOB_CODE,
				ORGANIZATION_ID,
				PROCESS_ID,
				TOP_PROCESS_ID,
				PARENT_PROCESS_ID,
				PROCESS_ORG_REV_ID,
				SCOPE_MODIFIED_DATE)
			SELECT 	amw_execution_scope_s.nextval,
				p_entity_type,
				p_entity_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'C',
				1,
				audit_rec.subsidiary_valueset,
				audit_rec.company_code,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
				sysdate
			FROM DUAL
			WHERE not exists (SELECT 'Y'
					FROM AMW_EXECUTION_SCOPE
					WHERE entity_type=p_entity_type
					AND entity_id= p_entity_id
					AND subsidiary_vs =  audit_rec.subsidiary_valueset
					AND subsidiary_code= audit_rec.company_code
					AND level_id=1);

			l_company_code := audit_rec.company_code;
			l_lob_code := audit_rec.lob_code;
			l_sub_lob_exists := 'N';

			IF l_company_code IS NOT NULL AND l_lob_code IS NOT NULL
			THEN
			    OPEN c_sub_lob_exists (audit_rec.subsidiary_valueset,l_company_code,audit_rec.lob_valueset,l_lob_code);
			    FETCH c_sub_lob_exists INTO l_sub_lob_exists;
			    CLOSE c_sub_lob_exists;
			END IF;

			IF l_sub_lob_exists IS NOT NULL AND l_sub_lob_exists='Y'
			THEN
				INSERT INTO AMW_EXECUTION_SCOPE (
					EXECUTION_SCOPE_ID,
					ENTITY_TYPE,
					ENTITY_ID,
					CREATED_BY,
					CREATION_DATE,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN,
					SCOPE_CHANGED_STATUS,
					LEVEL_ID,
					SUBSIDIARY_VS,
					SUBSIDIARY_CODE,
					LOB_VS,
					LOB_CODE,
					ORGANIZATION_ID,
					PROCESS_ID,
					TOP_PROCESS_ID,
					PARENT_PROCESS_ID,
					PROCESS_ORG_REV_ID,
					SCOPE_MODIFIED_DATE)
				SELECT  amw_execution_scope_s.nextval,
					p_entity_type,
					p_entity_id,
					FND_GLOBAL.USER_ID,
					SYSDATE,
					SYSDATE,
					FND_GLOBAL.USER_ID,
					FND_GLOBAL.USER_ID,
					'C',
					2,
					audit_rec.subsidiary_valueset,
					audit_rec.company_code,
					audit_rec.lob_valueset,
					audit_rec.lob_code,
					null,
					null,
					null,
					null,
					null,
					SYSDATE
				FROM DUAL
				WHERE not exists (SELECT 'Y'
						FROM AMW_EXECUTION_SCOPE
						WHERE entity_type=p_entity_type
						AND entity_id= p_entity_id
						AND subsidiary_vs =  audit_rec.subsidiary_valueset
						AND subsidiary_code= audit_rec.company_code
						AND lob_vs = audit_rec.lob_valueset
						AND lob_code = audit_rec.lob_code
						AND level_id=2);

				INSERT INTO AMW_EXECUTION_SCOPE (
					EXECUTION_SCOPE_ID,
					ENTITY_TYPE,
					ENTITY_ID,
					CREATED_BY,
					CREATION_DATE,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN,
					SCOPE_CHANGED_STATUS,
					LEVEL_ID,
					SUBSIDIARY_VS,
					SUBSIDIARY_CODE,
					LOB_VS,
					LOB_CODE,
					ORGANIZATION_ID,
					PROCESS_ID,
					TOP_PROCESS_ID,
					PARENT_PROCESS_ID,
					PROCESS_ORG_REV_ID,
					SCOPE_MODIFIED_DATE				)
				SELECT  amw_execution_scope_s.nextval,
					p_entity_type,
					p_entity_id,
					FND_GLOBAL.USER_ID,
					SYSDATE,
					SYSDATE,
					FND_GLOBAL.USER_ID,
					FND_GLOBAL.USER_ID,
					'C',
					3,
					audit_rec.subsidiary_valueset,
					audit_rec.company_code,
					audit_rec.lob_valueset,
					audit_rec.lob_code,
					audit_rec.organization_id,
					null,
					null,
					null,
					null,
					SYSDATE
				FROM DUAL
				WHERE NOT EXISTS (SELECT 'Y'
						FROM AMW_EXECUTION_SCOPE
						WHERE entity_type=p_entity_type
						AND entity_id= p_entity_id
						AND subsidiary_vs =  audit_rec.subsidiary_valueset
						AND subsidiary_code= audit_rec.company_code
						AND lob_vs = audit_rec.lob_valueset
						AND lob_code = audit_rec.lob_code
						AND organization_id = audit_rec.organization_id
						AND level_id=3);
			ELSE
				INSERT INTO AMW_EXECUTION_SCOPE (
					EXECUTION_SCOPE_ID,
					ENTITY_TYPE,
					ENTITY_ID,
					CREATED_BY,
					CREATION_DATE,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN,
					SCOPE_CHANGED_STATUS,
					LEVEL_ID,
					SUBSIDIARY_VS,
					SUBSIDIARY_CODE,
					LOB_VS,
					LOB_CODE,
					ORGANIZATION_ID,
					PROCESS_ID,
					TOP_PROCESS_ID,
					PARENT_PROCESS_ID,
					PROCESS_ORG_REV_ID,
					SCOPE_MODIFIED_DATE)
				SELECT  amw_execution_scope_s.nextval,
					p_entity_type,
					p_entity_id,
					FND_GLOBAL.USER_ID,
					SYSDATE,
					SYSDATE,
					FND_GLOBAL.USER_ID,
					FND_GLOBAL.USER_ID,
					'C',
					2,
					audit_rec.subsidiary_valueset,
					audit_rec.company_code,
					'-999',
					'AMW_DUMMY_LOBCODE',
					null,
					null,
					null,
					null,
					null,
					SYSDATE
				FROM DUAL
				WHERE not exists (SELECT 'Y'
						FROM AMW_EXECUTION_SCOPE
						WHERE entity_type=p_entity_type
						AND entity_id= p_entity_id
						AND subsidiary_vs =  audit_rec.subsidiary_valueset
						AND subsidiary_code= audit_rec.company_code
						AND lob_vs = '-999'
						AND lob_code = 'AMW_DUMMY_LOBCODE'
						AND level_id=2);


				INSERT INTO AMW_EXECUTION_SCOPE (
					EXECUTION_SCOPE_ID,
					ENTITY_TYPE,
					ENTITY_ID,
					CREATED_BY,
					CREATION_DATE,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN,
					SCOPE_CHANGED_STATUS,
					LEVEL_ID,
					SUBSIDIARY_VS,
					SUBSIDIARY_CODE,
					LOB_VS,
					LOB_CODE,
					ORGANIZATION_ID,
					PROCESS_ID,
					TOP_PROCESS_ID,
					PARENT_PROCESS_ID,
					PROCESS_ORG_REV_ID,
					SCOPE_MODIFIED_DATE				)
				SELECT  amw_execution_scope_s.nextval,
					p_entity_type,
					p_entity_id,
					FND_GLOBAL.USER_ID,
					SYSDATE,
					SYSDATE,
					FND_GLOBAL.USER_ID,
					FND_GLOBAL.USER_ID,
					'C',
					3,
					audit_rec.subsidiary_valueset,
					audit_rec.company_code,
					'-999',
					'AMW_DUMMY_LOBCODE',
					audit_rec.organization_id,
					null,
					null,
					null,
					null,
					SYSDATE
				FROM DUAL
				WHERE not exists (SELECT 'Y'
						FROM AMW_EXECUTION_SCOPE
						WHERE entity_type=p_entity_type
						AND entity_id= p_entity_id
						AND subsidiary_vs =  audit_rec.subsidiary_valueset
						AND subsidiary_code= audit_rec.company_code
						AND lob_vs = '-999'
						AND lob_code = 'AMW_DUMMY_LOBCODE'
						AND organization_id = audit_rec.organization_id
						AND level_id=3);
			END IF;
		END LOOP; --audit_rec IN c_audit_unit

		IF(p_process_tbl.count > 0)
		THEN
		    l_extra_query := ' AND org_v.child_process_id IN (';
		END IF;

		FOR i IN 1..p_process_tbl.count LOOP
			l_extra_query := l_extra_query || p_process_tbl(i).process_id;
			IF (i = p_process_tbl.count)
			THEN
			    l_extra_query := l_extra_query || ' )';
			ELSE
			    l_extra_query := l_extra_query || ', ';
			END IF;
		END LOOP;

		l_final_query := l_get_processes_query || p_org_tbl(each_rec).org_id || l_extra_query;

		OPEN process_cursor FOR l_final_query;
		LOOP
			FETCH process_cursor INTO l_process_id,
			                        l_process_org_rev_id,
						l_organization_id,
						l_company_code,
						l_subsidiary_valueset,
						l_lob_code,
						l_lob_valueset;
			EXIT WHEN process_cursor%NOTFOUND;

			INSERT INTO AMW_EXECUTION_SCOPE (
				EXECUTION_SCOPE_ID,
				ENTITY_TYPE,
				ENTITY_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				SCOPE_CHANGED_STATUS,
				LEVEL_ID,
				SUBSIDIARY_VS,
				SUBSIDIARY_CODE,
				LOB_VS,
				LOB_CODE,
				ORGANIZATION_ID,
				PROCESS_ID,
				TOP_PROCESS_ID,
				PARENT_PROCESS_ID,
				PROCESS_ORG_REV_ID,
				SCOPE_MODIFIED_DATE)
			SELECT amw_execution_scope_s.nextval,
				p_entity_type,
				p_entity_id,
                                FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'C',
				4,
				l_subsidiary_valueset,
				l_company_code,
				l_lob_valueset,
				l_lob_code,
				l_organization_id,
				l_process_id,
				l_process_id,
				-1,
				l_process_org_rev_id,
				SYSDATE
			FROM DUAL
			WHERE not exists (SELECT 'Y'
					FROM AMW_EXECUTION_SCOPE
					WHERE entity_type=p_entity_type
					AND entity_id= p_entity_id
					AND subsidiary_vs =  l_subsidiary_valueset
					AND subsidiary_code= l_company_code
					AND lob_vs = l_lob_valueset
					AND lob_code = l_lob_code
					AND process_id = l_process_id
					AND process_org_rev_id = l_process_org_rev_id
					AND level_id=4);

			-- Insert All the processes in the process Hierarchy using the top_process_id's
			Insert_Process(5,
				       l_process_id,
				       l_process_id,
				       l_process_org_rev_id,
				       l_subsidiary_valueset,
				       l_company_code,
				       l_lob_valueset,
				       l_lob_code,
				       l_organization_id,
				       p_entity_type,
				       p_entity_id);

		END LOOP;
		CLOSE process_cursor;


	END LOOP;--each_rec IN 1..p_org_tbl.count

	EXCEPTION WHEN OTHERS THEN
		rollback to populate_proc_hierarchy;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		FND_MSG_PUB.Count_And_Get(
		p_encoded =>  FND_API.G_FALSE,
		p_count   =>  x_msg_count,
		p_data    =>  x_msg_data);

END populate_process_hierarchy;

PROCEDURE Insert_Process
(
	p_level_id           IN NUMBER,
	p_parent_process_id  IN NUMBER,
	p_top_process_id     IN NUMBER,
	p_process_org_rev_id IN NUMBER,
	p_subsidiary_vs      IN VARCHAR2,
	p_subsidiary_code    IN VARCHAR2,
	p_lob_vs             IN VARCHAR2,
	p_lob_code           IN VARCHAR2,
	p_organization_id    IN NUMBER,
	p_entity_type        IN VARCHAR2,
	p_entity_id          IN NUMBER
) IS
       CURSOR c_process IS
           SELECT apv.child_process_id process_id, apv.child_process_org_rev_id process_org_rev_id
	   FROM amw_curr_app_hierarchy_org_v apv
	   WHERE apv.parent_process_id = p_parent_process_id
	   and apv.child_organization_id = p_organization_id;
BEGIN
    FOR proc_rec IN c_process LOOP
        Insert_Process (p_level_id+1,proc_rec.process_id,p_top_process_id,proc_rec.process_org_rev_id, p_subsidiary_vs,
		                p_subsidiary_code,p_lob_vs,p_lob_code,p_organization_id,p_entity_type,p_entity_id);
        INSERT INTO AMW_EXECUTION_SCOPE (
	       EXECUTION_SCOPE_ID,
		   ENTITY_TYPE,
		   ENTITY_ID,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   LAST_UPDATE_LOGIN,
		   SCOPE_CHANGED_STATUS,
		   LEVEL_ID,
		   SUBSIDIARY_VS,
		   SUBSIDIARY_CODE,
		   LOB_VS,
		   LOB_CODE,
		   ORGANIZATION_ID,
		   PROCESS_ID,
		   TOP_PROCESS_ID,
		   PARENT_PROCESS_ID,
		   PROCESS_ORG_REV_ID,
		   SCOPE_MODIFIED_DATE)
	SELECT amw_execution_scope_s.nextval,
 	       p_entity_type,
		   p_entity_id,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   'C',
		   p_level_id,
		   p_subsidiary_vs,
		   p_subsidiary_code,
		   p_lob_vs,
		   p_lob_code,
		   p_organization_id,
		   proc_rec.process_id,
		   p_top_process_id,
		   p_parent_process_id,
		   proc_rec.process_org_rev_id,
		   SYSDATE
         FROM DUAL;
    END LOOP;
END Insert_Process;

PROCEDURE build_project_audit_task (
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_audit_project_id		IN	 NUMBER,
    l_ineff_controls        IN   BOOLEAN := false,
    p_source_project_id		IN	 NUMBER := 0,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
) IS
    CURSOR c_project IS
        SELECT 'Y' FROM AMW_AUDIT_PROJECTS
        WHERE audit_project_id = p_audit_project_id
        FOR UPDATE nowait;

    CURSOR c_project_scope_org IS
        SELECT organization_id,
	       process_id,
	       scope_changed_status
	  FROM AMW_EXECUTION_SCOPE
	 WHERE entity_type='PROJECT'
	   AND entity_id=p_audit_project_id
           AND organization_id IS NOT NULL
	   AND process_id IS NULL
	   AND SCOPE_CHANGED_STATUS = 'C';

    CURSOR c_project_scope IS
        SELECT organization_id,
	       process_id,
	       scope_changed_status
	  FROM AMW_EXECUTION_SCOPE
	 WHERE entity_type='PROJECT'
	   AND entity_id=p_audit_project_id
	   AND process_id IS NOT NULL
	   AND SCOPE_CHANGED_STATUS = 'C';

    CURSOR c_ap_attachments IS
        SELECT fad.entity_name, fad.pk1_value, fad.pk2_value, fad.pk3_value, fad.pk4_value, fad.pk5_value
          FROM fnd_attached_documents fad
         WHERE fad.entity_name = 'AMW_PROJECT_AP'
           AND fad.pk1_value = p_audit_project_id
           AND NOT EXISTS (select 'Y'
                           from amw_ap_associations ap_assoc
                           where ap_assoc.object_type='PROJECT'
                           and ap_assoc.pk1 = fad.pk1_value
                           and ap_assoc.pk2 = fad.pk2_value
                           and ap_assoc.pk4 = fad.pk3_value
                           and ap_assoc.audit_procedure_rev_id = fad.pk4_value);
    -- To fetch the new audit procedure id
    CURSOR c_apdetails IS
        select distinct audit_procedure_rev_id, pk1,pk2, pk4
        from amw_ap_associations
        where object_type = 'PROJECT_NEW'
        and pk1 = p_audit_project_id
        and audit_procedure_rev_id is not null;

    l_api_name                CONSTANT VARCHAR2(30) := 'Build_Audit_Task';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
    l_exists		 VARCHAR2(1);
    v_category_id    NUMBER;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT BUILD_AUDIT_TASK_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    OPEN c_project;
    FETCH c_project INTO l_exists;
    CLOSE c_project;


    DELETE FROM amw_risk_associations ara
     WHERE object_type='PROJECT'
       AND pk1 = p_audit_project_id
       AND pk3 IS NOT NULL
       AND not exists
		(select 'Y'
		   from amw_execution_scope
		  where entity_type='PROJECT'
		    and entity_id = p_audit_project_id
		    and organization_id = ara.pk2
		    and process_id = ara.pk3);

    DELETE FROM amw_control_associations aca
     WHERE object_type='PROJECT'
       AND pk1 = p_audit_project_id
       AND pk3 IS NOT NULL
       AND not exists
	        (select 'Y' from amw_risk_associations ara
		  where object_type = 'PROJECT'
		    and ara.pk1 = p_audit_project_id
		    and ara.pk2 = aca.pk2
		    and ara.pk3 = aca.pk3
		    and ara.risk_id = aca.pk4);

    DELETE FROM amw_ap_associations apa
     WHERE object_type='PROJECT'
       AND pk1 = p_audit_project_id
       AND not exists
	        (select 'Y' from amw_control_associations aca
		  where aca.object_type = 'PROJECT'
		    and aca.pk1 = p_audit_project_id
		    and aca.pk2 = apa.pk2
--                    and aca.pk3 IS NOT NULL --process
		    and aca.control_id = apa.pk3)
	and pk2 <> -1 and pk3 <> -1;

     DELETE FROM amw_ap_associations apa
     WHERE object_type='PROJECT'
       AND pk1 = p_audit_project_id
       AND not exists
	        (select 'Y' from amw_execution_scope aes
		   where aes.entity_type = 'PROJECT'
		    and aes.entity_id = p_audit_project_id
		    and aes.organization_id = apa.pk2)
            and pk3 = -1
            and pk2 <> -1 ;

    /* Entity risk/control/ap changes begin*/

    DELETE FROM amw_risk_associations ara
     WHERE object_type='PROJECT'
       AND pk1 = p_audit_project_id
       AND pk3 IS NULL
       AND not exists
		(select 'Y'
		   from amw_execution_scope
		  where entity_type='PROJECT'
		    and entity_id = p_audit_project_id
		    and organization_id = ara.pk2
		    and process_id IS NULL);

    DELETE FROM amw_control_associations aca
     WHERE object_type='PROJECT'
       AND pk1 = p_audit_project_id
       AND pk3 IS NULL
       AND not exists
	        (select 'Y' from amw_risk_associations ara
		  where object_type = 'PROJECT'
		    and ara.pk1 = p_audit_project_id
		    and ara.pk2 = aca.pk2
		    and ara.pk3 IS NULL
		    and ara.risk_id = aca.pk4);

    DELETE FROM amw_ap_associations apa
     WHERE object_type='PROJECT'
       AND pk1 = p_audit_project_id
       AND not exists
                (select 'Y' from amw_control_associations aca
                  where aca.object_type = 'PROJECT'
                    and aca.pk1 = p_audit_project_id
                    and aca.pk2 = apa.pk2
--                    and aca.pk3 IS NULL --process
                    and aca.control_id = apa.pk3)
	and pk2 <> -1 and pk3 <> -1;

     DELETE FROM amw_ap_associations apa
     WHERE object_type='PROJECT'
       AND pk1 = p_audit_project_id
       AND not exists
	        (select 'Y' from amw_execution_scope aes
		   where aes.entity_type = 'PROJECT'
		    and aes.entity_id = p_audit_project_id
		    and aes.organization_id = apa.pk2)
            and pk3 = -1
            and pk2 <> -1 ;
    /* Entity risk/control/ap changes end*/

    FOR scope_rec IN c_project_scope LOOP

        UPDATE AMW_RISK_ASSOCIATIONS ara
	SET ara.risk_rev_id = (SELECT risk.risk_rev_id
				FROM AMW_RISKS_B risk
				WHERE risk.risk_id = ara.risk_id
				AND risk.curr_approved_flag = 'Y')
	WHERE ara.object_type = 'PROJECT'
	AND ara.pk1           = p_audit_project_id
	AND ara.pk2           = scope_rec.organization_id
	AND ara.pk3           = scope_rec.process_id;

	INSERT INTO AMW_RISK_ASSOCIATIONS
	(
		risk_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		risk_id,
		risk_rev_id,
		pk1,
		pk2,
		pk3,
		object_type,
		object_version_number
	)
	SELECT AMW_RISK_ASSOCIATIONS_S.nextval,
		   sysdate,
		   fnd_global.user_id,
		   sysdate,
		   fnd_global.user_id,
		   fnd_global.user_id,
		   risk.risk_id,
		   risk.risk_rev_id,
		   p_audit_project_id,
		   scope_rec.organization_id,
		   scope_rec.process_id,
		   'PROJECT',
		   1
	FROM amw_risk_associations ara, amw_risks_b risk
	WHERE ara.object_type        = 'PROCESS_ORG'
	AND ara.pk1                  = scope_rec.organization_id
	AND ara.pk2                  = scope_rec.process_id
	AND ara.risk_id              = risk.risk_id
	AND risk.curr_approved_flag  = 'Y'
        AND ara.approval_date IS NOT NULL
        AND ara.deletion_approval_date IS NULL
	AND not exists
	   (select 'Y' from amw_risk_associations ara2
	    where ara2.object_type = 'PROJECT'
	      and ara2.pk1         = p_audit_project_id
	      and ara2.pk2         = scope_rec.organization_id
	      and ara2.pk3         = scope_rec.process_id
	      and ara2.risk_id     = risk.risk_id
	      and ara2.risk_rev_id = risk.risk_rev_id
           );

        UPDATE AMW_CONTROL_ASSOCIATIONS aca
		SET aca.control_rev_id = (SELECT control_rev_id
					    FROM AMW_CONTROLS_B control
					   WHERE control.control_id =  aca.control_id
					     AND control.curr_approved_flag = 'Y')
		WHERE aca.object_type = 'PROJECT'
		AND aca.pk1           = p_audit_project_id
		AND aca.pk2           = scope_rec.organization_id
		AND aca.pk3           = scope_rec.process_id;

	INSERT INTO amw_control_associations
	(
		control_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		control_id,
		control_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number
	)
	SELECT AMW_CONTROL_ASSOCIATIONS_S.nextval,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   control.control_id,
		   control.control_rev_id,
		   p_audit_project_id,
		   scope_rec.organization_id,
		   scope_rec.process_id,
		   ara.risk_id,
		   'PROJECT',
		   1
	FROM amw_control_associations aca,amw_risk_associations ara,amw_controls_b control
	WHERE aca.object_type          = 'RISK_ORG'
	AND aca.pk1                    = scope_rec.organization_id
	AND aca.pk2                    = scope_rec.process_id
	AND aca.pk3                    = ara.risk_id
	AND aca.control_id             = control.control_id
        AND aca.approval_date IS NOT NULL
        AND aca.deletion_approval_date IS NULL
	AND control.curr_approved_flag = 'Y'
	AND ara.object_type            = 'PROJECT'
	AND ara.pk1                    = p_audit_project_id
	AND ara.pk2                    = scope_rec.organization_id
	AND ara.pk3                    = scope_rec.process_id
	AND not exists
	   (SELECT 'Y' from amw_control_associations aca2
	    WHERE aca2.object_type    = 'PROJECT'
	      AND aca2.pk1            = p_audit_project_id
	      AND aca2.pk2            = scope_rec.organization_id
	      AND aca2.pk3            = scope_rec.process_id
	      AND aca2.pk4            = ara.risk_id
	      AND aca2.control_id     = control.control_id
	      AND aca2.control_rev_id = control.control_rev_id
          );


        UPDATE AMW_AP_ASSOCIATIONS apa
	SET apa.audit_procedure_rev_id = (SELECT audit_procedure_rev_id
	  			          FROM amw_audit_procedures_b aapb1
	  			          WHERE aapb1.audit_procedure_id = apa.audit_procedure_id
	  			          AND aapb1.curr_approved_flag = 'Y')
	WHERE apa.object_type = 'PROJECT'
	AND apa.pk1           = p_audit_project_id
   	AND apa.pk2           = scope_rec.organization_id;

	INSERT INTO amw_ap_associations (
		ap_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		audit_procedure_id,
		audit_procedure_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number)
	SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   ttt.audit_procedure_id,
		   ttt.audit_procedure_rev_id,
		   p_audit_project_id,
		   ttt.organization_id,
		   ttt.control_id,
		   NVL(ttt.task_id, -1),
		   'PROJECT_NEW',
		   1
	  FROM (SELECT distinct
		       aapb.audit_procedure_id,
		       aapb.audit_procedure_rev_id,
		       apa.pk1	organization_id,
		       apa.pk3  control_id,
		       pt2.task_id
		FROM amw_ap_associations apa,
		   amw_audit_procedures_b aapb,
		   amw_ap_tasks	       apt,
		   amw_control_associations aca,
		   amw_audit_projects_v pp,
		   amw_audit_tasks_v pt1,
		   amw_audit_tasks_v pt2
		WHERE apa.object_type = 'CTRL_ORG'
		  AND aca.object_type='PROJECT'
		  AND aca.pk1 = p_audit_project_id
		  AND aca.pk2 = scope_rec.organization_id
		  AND aca.pk3 = scope_rec.process_id
		  AND apa.pk1 = aca.pk2 -- organization_id
		  AND apa.pk2 = aca.pk3 -- process_id
		  AND apa.pk3 = aca.control_id
                  AND apa.association_creation_date IS NOT NULL
                  AND apa.deletion_date IS NULL
		  AND apa.audit_procedure_id = aapb.audit_procedure_id
		  AND aapb.curr_approved_flag='Y'
		  AND pp.audit_project_id = p_audit_project_id
		  AND decode(apt.source_code, 'ICM', pt1.audit_project_id,
						     pt1.project_id)
			 = pp.created_from_project_id
		  AND pt1.task_id = apt.task_id
		  AND pt1.task_number = pt2.task_number
		  and apt.audit_procedure_id = apa.audit_procedure_id
		  AND pt2.audit_project_id = p_audit_project_id) ttt
	  WHERE NOT EXISTS
		   (SELECT 'Y' from amw_ap_associations apa2
		    where apa2.object_type in ('PROJECT','PROJECT_NEW')
		      AND apa2.pk1 = p_audit_project_id
		      AND apa2.pk2 = ttt.organization_id
		      AND apa2.pk3 = ttt.control_id
		      AND apa2.pk4 = ttt.task_id
		      AND apa2.audit_procedure_id = ttt.audit_procedure_id
		      AND apa2.audit_procedure_rev_id = ttt.audit_procedure_rev_id
		   );

		INSERT INTO amw_ap_associations (
		ap_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		audit_procedure_id,
		audit_procedure_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number)
	SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   ttt.audit_procedure_id,
		   ttt.audit_procedure_rev_id,
		   p_audit_project_id,
		   ttt.organization_id,
		   ttt.control_id,
		   NVL(ttt.task_id, -1),
		   'PROJECT_NEW',
		   1
	  FROM (SELECT distinct
		       aapb.audit_procedure_id,
		       aapb.audit_procedure_rev_id,
		       apa.pk1	organization_id,
		       apa.pk3  control_id,
		       pt2.task_id
		FROM amw_ap_associations apa,
		   amw_audit_procedures_b aapb,
		   amw_ap_tasks	       apt,
		   amw_control_associations aca,
		   amw_audit_projects_v pp,
		   amw_template_tasks_v pt1,
		   amw_audit_tasks_v pt2
		WHERE apa.object_type = 'CTRL_ORG'
		  AND aca.object_type='PROJECT'
		  AND aca.pk1 = p_audit_project_id
		  AND aca.pk2 = scope_rec.organization_id
		  AND aca.pk3 = scope_rec.process_id
		  AND apa.pk1 = aca.pk2 -- organization_id
		  AND apa.pk2 = aca.pk3 -- process_id
		  AND apa.pk3 = aca.control_id
                  AND apa.association_creation_date IS NOT NULL
                  AND apa.deletion_date IS NULL
		  AND apa.audit_procedure_id = aapb.audit_procedure_id
		  AND aapb.curr_approved_flag='Y'
		  AND pp.audit_project_id = p_audit_project_id
		  AND apt.source_code = 'PA'
		  AND pt1.project_id = pp.created_from_project_id
		  AND pt1.task_id = apt.task_id
		  AND pt1.task_number = pt2.task_number
		  and apt.audit_procedure_id = apa.audit_procedure_id
		  AND pt2.audit_project_id = p_audit_project_id) ttt
	  WHERE NOT EXISTS
		   (SELECT 'Y' from amw_ap_associations apa2
		    where apa2.object_type in ('PROJECT','PROJECT_NEW')
		      AND apa2.pk1 = p_audit_project_id
		      AND apa2.pk2 = ttt.organization_id
		      AND apa2.pk3 = ttt.control_id
		      AND apa2.pk4 = ttt.task_id
		      AND apa2.audit_procedure_id = ttt.audit_procedure_id
		      AND apa2.audit_procedure_rev_id = ttt.audit_procedure_rev_id
		   );

	 INSERT INTO amw_ap_associations (
		ap_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		audit_procedure_id,
		audit_procedure_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number)
	 SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   sysdate,
		   fnd_global.user_id,
		   sysdate,
		   fnd_global.user_id,
		   fnd_global.user_id,
		   ttt.audit_procedure_id,
		   ttt.audit_procedure_rev_id,
		   p_audit_project_id,
		   ttt.organization_id,
		   ttt.control_id,
		   -1,
		   'PROJECT_NEW',
		   1
	  FROM (SELECT distinct
		       aapb.audit_procedure_id,
		       aapb.audit_procedure_rev_Id,
		       apa.pk1	organization_id,
		       apa.pk3  control_id
		FROM amw_ap_associations apa,
		   amw_audit_procedures_b aapb,
		   amw_control_associations aca
		WHERE apa.object_type = 'CTRL_ORG'
		  AND aca.object_type='PROJECT'
		  AND aca.pk1 = p_audit_project_id
		  AND aca.pk2 = scope_rec.organization_id
		  AND aca.pk3 = scope_rec.process_id
		  AND apa.pk1 = aca.pk2 -- organization_id
		  AND apa.pk2 = aca.pk3 -- process_id
		  AND apa.pk3 = aca.control_id
                  AND apa.association_creation_date IS NOT NULL
                  AND apa.deletion_date IS NULL
		  AND apa.audit_procedure_id = aapb.audit_procedure_id
		  AND aapb.curr_approved_flag='Y') ttt
	  WHERE NOT EXISTS
		   (SELECT 'Y' from amw_ap_associations apa2
		    WHERE apa2.object_type in ('PROJECT','PROJECT_NEW')
		      AND apa2.pk1 = p_audit_project_id
		      AND apa2.pk2 = ttt.organization_id
		      AND apa2.pk3 = ttt.control_id
		      AND apa2.audit_procedure_id = ttt.audit_procedure_id
		      AND apa2.audit_procedure_rev_id = ttt.audit_procedure_rev_id
	   );

    END LOOP; -- FOR scope_rec IN c_project_scope LOOP

    /* Changes for org risk/control/ap */
    FOR scope_org_rec IN c_project_scope_org LOOP

        UPDATE AMW_RISK_ASSOCIATIONS ara
	SET ara.risk_rev_id = (SELECT risk.risk_rev_id
				FROM AMW_RISKS_B risk
				WHERE risk.risk_id = ara.risk_id
				AND risk.curr_approved_flag = 'Y')
	WHERE ara.object_type = 'PROJECT'
	AND ara.pk1           = p_audit_project_id
	AND ara.pk2           = scope_org_rec.organization_id
	AND ara.pk3 IS NULL;

	INSERT INTO AMW_RISK_ASSOCIATIONS
	(
		risk_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		risk_id,
		risk_rev_id,
		pk1,
		pk2,
		pk3,
		object_type,
		object_version_number
	)
	SELECT AMW_RISK_ASSOCIATIONS_S.nextval,
		   sysdate,
		   fnd_global.user_id,
		   sysdate,
		   fnd_global.user_id,
		   fnd_global.user_id,
		   risk.risk_id,
		   risk.risk_rev_id,
		   p_audit_project_id,
		   scope_org_rec.organization_id,
		   null,
		   'PROJECT',
		   1
	FROM amw_risk_associations ara, amw_risks_b risk
	WHERE ara.object_type        = 'ENTITY_RISK'
	AND ara.pk1                  = scope_org_rec.organization_id
	AND ara.pk2 IS NULL
	AND ara.risk_id              = risk.risk_id
	AND risk.curr_approved_flag  = 'Y'
	AND not exists
	   (select 'Y' from amw_risk_associations ara2
	    where ara2.object_type = 'PROJECT'
	      and ara2.pk1         = p_audit_project_id
	      and ara2.pk2         = scope_org_rec.organization_id
	      and ara2.pk3 IS NULL
	      and ara2.risk_id     = risk.risk_id
	      and ara2.risk_rev_id = risk.risk_rev_id
           );

        UPDATE AMW_CONTROL_ASSOCIATIONS aca
		SET aca.control_rev_id = (SELECT control_rev_id
					    FROM AMW_CONTROLS_B control
					   WHERE control.control_id =  aca.control_id
					     AND control.curr_approved_flag = 'Y')
		WHERE aca.object_type = 'PROJECT'
		AND aca.pk1           = p_audit_project_id
		AND aca.pk2           = scope_org_rec.organization_id
		AND aca.pk3 IS NULL;

if(not l_ineff_controls) THEN
	INSERT INTO amw_control_associations
	(
		control_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		control_id,
		control_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number
	)
	SELECT AMW_CONTROL_ASSOCIATIONS_S.nextval,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   control.control_id,
		   control.control_rev_id,
		   p_audit_project_id,
		   scope_org_rec.organization_id,
		   null,
		   ara.risk_id,
		   'PROJECT',
		   1
	FROM amw_control_associations aca,amw_risk_associations ara,amw_controls_b control
	WHERE aca.object_type          = 'ENTITY_CONTROL'
	AND aca.pk1                    = scope_org_rec.organization_id
	AND aca.pk2                    = ara.risk_id
	AND aca.pk3 IS NULL
	AND aca.control_id             = control.control_id
	AND control.curr_approved_flag = 'Y'
	AND ara.object_type            = 'PROJECT'
	AND ara.pk1                    = p_audit_project_id
	AND ara.pk2                    = scope_org_rec.organization_id
	AND ara.pk3 IS NULL
	AND not exists
	   (SELECT 'Y' from amw_control_associations aca2
	    WHERE aca2.object_type    = 'PROJECT'
	      AND aca2.pk1            = p_audit_project_id
	      AND aca2.pk2            = scope_org_rec.organization_id
	      AND aca2.pk3 IS NULL
	      AND aca2.pk4            = ara.risk_id
	      AND aca2.control_id     = control.control_id
	      AND aca2.control_rev_id = control.control_rev_id
          );
    ELSE
    	INSERT INTO amw_control_associations
	(
		control_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		control_id,
		control_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number
	)
	SELECT AMW_CONTROL_ASSOCIATIONS_S.nextval,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   control.control_id,
		   control.control_rev_id,
		   p_audit_project_id,
		   scope_org_rec.organization_id,
		   null,
		   ara.risk_id,
		   'PROJECT',
		   1
	FROM amw_control_associations aca,amw_risk_associations ara,amw_controls_b control
	WHERE aca.object_type          = 'ENTITY_CONTROL'
	AND aca.pk1                    = scope_org_rec.organization_id
	AND aca.pk2                    = ara.risk_id
	AND aca.pk3 IS NULL
	AND aca.control_id             = control.control_id
	AND control.curr_approved_flag = 'Y'
	AND ara.object_type            = 'PROJECT'
	AND ara.pk1                    = p_audit_project_id
	AND ara.pk2                    = scope_org_rec.organization_id
	AND ara.pk3 IS NULL
	AND not exists
	   (SELECT 'Y' from amw_control_associations aca2
	    WHERE aca2.object_type    = 'PROJECT'
	      AND aca2.pk1            = p_audit_project_id
	      AND aca2.pk2            = scope_org_rec.organization_id
	      AND aca2.pk3 IS NULL
	      AND aca2.pk4            = ara.risk_id
	      AND aca2.control_id     = control.control_id
	      AND aca2.control_rev_id = control.control_rev_id
          )
    and aca.control_id  in
    (select distinct control_id from amw_control_associations where pk1=p_source_project_id and object_type='PROJECT'
    and control_id not in (select pk1_value from  amw_opinions_v where  pk2_value =p_source_project_id
        and audit_result_code ='EFFECTIVE' and
    object_name='AMW_ORG_CONTROL')             );
    END IF;


        UPDATE AMW_AP_ASSOCIATIONS apa
	SET apa.audit_procedure_rev_id = (SELECT audit_procedure_rev_id
	  			          FROM amw_audit_procedures_b aapb1
	  			          WHERE aapb1.audit_procedure_id = apa.audit_procedure_id
	  			          AND aapb1.curr_approved_flag = 'Y')
	WHERE apa.object_type = 'PROJECT'
	AND apa.pk1           = p_audit_project_id
   	AND apa.pk2           = scope_org_rec.organization_id;

	INSERT INTO amw_ap_associations (
		ap_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		audit_procedure_id,
		audit_procedure_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number)
	SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   ttt.audit_procedure_id,
		   ttt.audit_procedure_rev_id,
		   p_audit_project_id,
		   ttt.organization_id,
		   ttt.control_id,
		   NVL(ttt.task_id, -1),
		   'PROJECT_NEW',
		   1
	  FROM (SELECT distinct
		       aapb.audit_procedure_id,
		       aapb.audit_procedure_rev_id,
		       apa.pk1	organization_id,
		       apa.pk2  control_id,
		       pt2.task_id
		FROM amw_ap_associations apa,
		   amw_audit_procedures_b aapb,
		   amw_ap_tasks	       apt,
		   amw_control_associations aca,
		   amw_audit_projects_v pp,
		   amw_audit_tasks_v pt1,
		   amw_audit_tasks_v pt2
		WHERE apa.object_type = 'ENTITY_AP'
		  AND aca.object_type='PROJECT'
		  AND aca.pk1 = p_audit_project_id
		  AND aca.pk2 = scope_org_rec.organization_id
		  AND aca.pk3 IS NULL
		  AND apa.pk1 = aca.pk2 -- organization_id
		  AND apa.pk2 = aca.control_id -- Control_id
		  AND apa.audit_procedure_id = aapb.audit_procedure_id
                  AND apa.association_creation_date IS NOT NULL
		  AND aapb.curr_approved_flag='Y'
		  AND pp.audit_project_id = p_audit_project_id
		  AND decode(apt.source_code, 'ICM', pt1.audit_project_id,
						     pt1.project_id)
			 = pp.created_from_project_id
		  AND pt1.task_id = apt.task_id
		  AND pt1.task_number = pt2.task_number
		  and apt.audit_procedure_id = apa.audit_procedure_id
		  AND pt2.audit_project_id = p_audit_project_id) ttt
	  WHERE NOT EXISTS
		   (SELECT 'Y' from amw_ap_associations apa2
		    where apa2.object_type in ('PROJECT','PROJECT_NEW')
		      AND apa2.pk1 = p_audit_project_id
		      AND apa2.pk2 = ttt.organization_id
		      AND apa2.pk3 = ttt.control_id
		      AND apa2.pk4 = ttt.task_id
		      AND apa2.audit_procedure_id = ttt.audit_procedure_id
		      AND apa2.audit_procedure_rev_id = ttt.audit_procedure_rev_id
		   );

	INSERT INTO amw_ap_associations (
		ap_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		audit_procedure_id,
		audit_procedure_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number)
	SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   ttt.audit_procedure_id,
		   ttt.audit_procedure_rev_id,
		   p_audit_project_id,
		   ttt.organization_id,
		   ttt.control_id,
		   NVL(ttt.task_id, -1),
		   'PROJECT_NEW',
		   1
	  FROM (SELECT distinct
		       aapb.audit_procedure_id,
		       aapb.audit_procedure_rev_id,
		       apa.pk1	organization_id,
		       apa.pk2  control_id,
		       pt2.task_id
		FROM amw_ap_associations apa,
		   amw_audit_procedures_b aapb,
		   amw_ap_tasks	       apt,
		   amw_control_associations aca,
		   amw_audit_projects_v pp,
		   amw_template_tasks_v pt1,
		   amw_audit_tasks_v pt2
		WHERE apa.object_type = 'ENTITY_AP'
		  AND aca.object_type='PROJECT'
		  AND aca.pk1 = p_audit_project_id
		  AND aca.pk2 = scope_org_rec.organization_id
		  AND aca.pk3 IS NULL
		  AND apa.pk1 = aca.pk2 -- organization_id
		  AND apa.pk2 = aca.control_id -- Control_id
		  AND apa.audit_procedure_id = aapb.audit_procedure_id
                  AND apa.association_creation_date IS NOT NULL
		  AND aapb.curr_approved_flag='Y'
		  AND pp.audit_project_id = p_audit_project_id
		  AND apt.source_code = 'PA'
		  AND pt1.project_id = pp.created_from_project_id
		  AND pt1.task_id = apt.task_id
		  AND pt1.task_number = pt2.task_number
		  and apt.audit_procedure_id = apa.audit_procedure_id
		  AND pt2.audit_project_id = p_audit_project_id) ttt
	  WHERE NOT EXISTS
		   (SELECT 'Y' from amw_ap_associations apa2
		    where apa2.object_type in ('PROJECT','PROJECT_NEW')
		      AND apa2.pk1 = p_audit_project_id
		      AND apa2.pk2 = ttt.organization_id
		      AND apa2.pk3 = ttt.control_id
		      AND apa2.pk4 = ttt.task_id
		      AND apa2.audit_procedure_id = ttt.audit_procedure_id
		      AND apa2.audit_procedure_rev_id = ttt.audit_procedure_rev_id
		   );

	 INSERT INTO amw_ap_associations (
		ap_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		audit_procedure_id,
		audit_procedure_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number)
	 SELECT AMW_AP_ASSOCIATIONS_S.nextval,
		   sysdate,
		   fnd_global.user_id,
		   sysdate,
		   fnd_global.user_id,
		   fnd_global.user_id,
		   ttt.audit_procedure_id,
		   ttt.audit_procedure_rev_id,
		   p_audit_project_id,
		   ttt.organization_id,
		   ttt.control_id,
		   -1,
		   'PROJECT_NEW',
		   1
	  FROM (SELECT distinct
		       aapb.audit_procedure_id,
		       aapb.audit_procedure_rev_Id,
		       apa.pk1	organization_id,
		       apa.pk2  control_id
		FROM amw_ap_associations apa,
		   amw_audit_procedures_b aapb,
		   amw_control_associations aca
		WHERE apa.object_type = 'ENTITY_AP'
		  AND aca.object_type='PROJECT'
		  AND aca.pk1 = p_audit_project_id
		  AND aca.pk2 = scope_org_rec.organization_id
		  AND aca.pk3 IS NULL
		  AND apa.pk1 = aca.pk2 -- organization_id
		  AND apa.pk2 = aca.control_id -- control_id
		  AND apa.audit_procedure_id = aapb.audit_procedure_id
                  AND apa.association_creation_date IS NOT NULL
		  AND aapb.curr_approved_flag='Y') ttt
	  WHERE NOT EXISTS
		   (SELECT 'Y' from amw_ap_associations apa2
		    WHERE apa2.object_type in ('PROJECT','PROJECT_NEW')
		      AND apa2.pk1 = p_audit_project_id
		      AND apa2.pk2 = ttt.organization_id
		      AND apa2.pk3 = ttt.control_id
		      AND apa2.audit_procedure_id = ttt.audit_procedure_id
		      AND apa2.audit_procedure_rev_id = ttt.audit_procedure_rev_id
	   );

    END LOOP; -- FOR scope_org_rec IN c_project_scope_org LOOP

    --  To get the Category of Audit Procedure Working Papers
    select category_id into v_category_id
    from fnd_document_categories where name = 'AMW_WORK_PAPERS';
    -- To copy the attachments
    FOR apdetails_rec IN c_apdetails LOOP
        FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(X_from_entity_name => 'AMW_AUDIT_PRCD',
                                                     X_from_pk1_value => apdetails_rec.audit_procedure_rev_id,
                                                     X_to_entity_name => 'AMW_PROJECT_AP',
                                                     X_to_pk1_value => apdetails_rec.pk1,
                                                     X_to_pk2_value => apdetails_rec.pk2,
                                                     X_to_pk3_value => apdetails_rec.pk4,
                                                     X_to_pk4_value => apdetails_rec.audit_procedure_rev_id,
                                                     X_FROM_CATEGORY_ID => v_category_id,
                                                     X_TO_CATEGORY_ID => v_category_id);

     END LOOP; -- end of FOR aapdetails_rec IN c_apdetails LOOP

    -- Change entity_type 'PROJECT_NEW' to 'PROJECT'
    UPDATE AMW_AP_ASSOCIATIONS SET object_type='PROJECT' WHERE object_type = 'PROJECT_NEW';
    --- Copy Attachment ends here

    FOR ap_attachment_rec IN c_ap_attachments LOOP
      -- Delete all the attachments for the audit procedure that is not present in the project
      fnd_attached_documents2_pkg.delete_attachments(X_entity_name => ap_attachment_rec.entity_name,
                                                     X_pk1_value => ap_attachment_rec.pk1_value,
                                                     X_pk2_value => ap_attachment_rec.pk2_value,
                                                     X_pk3_value => ap_attachment_rec.pk3_value,
                                                     X_pk4_value => ap_attachment_rec.pk4_value);
    END LOOP; -- end of FOR ap_attachment_rec IN c_ap_attachments LOOP


    UPDATE AMW_EXECUTION_SCOPE
    SET SCOPE_CHANGED_STATUS = null
    WHERE entity_type='PROJECT'
      AND entity_id=p_audit_project_id
      AND SCOPE_CHANGED_STATUS = 'C';

    UPDATE AMW_AUDIT_PROJECTS
    SET scope_changed_flag = 'N'
    WHERE project_id = p_audit_project_id;


EXCEPTION WHEN OTHERS THEN
    rollback to BUILD_AUDIT_TASK_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, l_api_name);
    FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
END build_project_audit_task;

PROCEDURE populate_denormalized_tables
(
    p_entity_type IN VARCHAR2,
    p_entity_id   IN NUMBER,
    p_org_tbl     IN org_tbl_type,
    p_process_tbl IN process_tbl_type,
    p_mode        IN VARCHAR2
)
IS

BEGIN

	DELETE FROM amw_proc_cert_eval_sum pcert
	WHERE certification_id = p_entity_id
	AND NOT EXISTS (SELECT 'Y'
			FROM amw_execution_scope exec
			WHERE exec.entity_id = pcert.certification_id
			AND exec.entity_type = p_entity_type
			AND exec.process_id = pcert.process_id
			AND exec.organization_id = pcert.organization_id
			);

	INSERT INTO amw_proc_cert_eval_sum(certification_id,
					   process_id,
					   organization_id,
					   process_org_rev_id,
					   created_by,
					   creation_date,
					   last_updated_by,
					   last_update_date,
					   last_update_login)
	SELECT  DISTINCT
	        entity_id,
		process_id,
		organization_id,
		process_org_rev_id,
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id,
		SYSDATE,
		fnd_global.user_id
	FROM amw_execution_scope exec
	WHERE NOT EXISTS (SELECT 'Y'
			  FROM amw_proc_cert_eval_sum pcert
			  WHERE pcert.certification_id = exec.entity_id
			  AND pcert.organization_id = exec.organization_id
			  AND pcert.process_id = exec.process_id)
	AND entity_id     = p_entity_id
	AND entity_type   = p_entity_type
	AND scope_changed_status = 'C'
	AND level_id > 3;

	IF p_mode = 'ADD'
	THEN

		INSERT INTO amw_org_cert_eval_sum(certification_id,
						organization_id,
						created_by,
						creation_date,
						last_updated_by,
						last_update_date,
						last_update_login)
		SELECT  entity_id,
			organization_id,
			fnd_global.user_id,
			SYSDATE,
			fnd_global.user_id,
			SYSDATE,
			fnd_global.user_id
		FROM amw_execution_scope exec
		WHERE NOT EXISTS (SELECT 'Y'
				  FROM amw_org_cert_eval_sum ocert
				  WHERE ocert.certification_id = exec.entity_id
				  AND ocert.organization_id = exec.organization_id
				  )
		AND entity_id     = p_entity_id
		AND entity_type   = p_entity_type
		AND scope_changed_status = 'C'
		AND level_id = 3;
	END IF;

END populate_denormalized_tables;

PROCEDURE populate_association_tables
(
    p_api_version_number        IN       NUMBER := 1.0,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER   := fnd_api.g_valid_level_full,
    p_entity_type               IN       VARCHAR2,
    p_entity_id                 IN       NUMBER,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
) IS

	CURSOR get_records_in_scope IS
	SELECT organization_id,process_id, scope_changed_status
	FROM AMW_EXECUTION_SCOPE
	WHERE entity_type        = p_entity_type
	AND entity_id            = p_entity_id
	AND scope_changed_status = 'C'
	AND process_id IS NOT NULL
        FOR UPDATE NOWAIT;


        CURSOR c_scope_org IS
        SELECT organization_id,
	       process_id,
	       scope_changed_status
	  FROM AMW_EXECUTION_SCOPE
	 WHERE entity_type=p_entity_type
	   AND entity_id=p_entity_id
           AND organization_id IS NOT NULL
	   AND process_id IS NULL
	   AND SCOPE_CHANGED_STATUS = 'C';


	l_api_name             CONSTANT VARCHAR2(30) := 'populate_association_tables';
	l_api_version_number   CONSTANT NUMBER       := 1.0;
	l_exists           VARCHAR2(1);

BEGIN
	-- Standard Start of API savepoint
	SAVEPOINT POPULATE_ASSOCIATIONS;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
				      p_api_version_number,
					 l_api_name,
					 'AMW_SCOPE_PVT')    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;


	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
	FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DELETE FROM AMW_RISK_ASSOCIATIONS ara
	WHERE object_type = p_entity_type
	AND pk1         = p_entity_id
	AND pk3 IS NOT NULL
	AND NOT EXISTS
		(SELECT 'Y'
		   FROM AMW_EXECUTION_SCOPE
		  WHERE entity_type     = p_entity_type
		    AND entity_id       = p_entity_id
		    AND organization_id = ara.pk2
		    AND process_id      = ara.pk3);

	DELETE FROM AMW_CONTROL_ASSOCIATIONS aca
	WHERE object_type = p_entity_type
	AND pk1         = p_entity_id
	AND pk3 IS NOT NULL
	AND NOT EXISTS
		(SELECT 'Y'
		   FROM AMW_RISK_ASSOCIATIONS ara
		  WHERE object_type = p_entity_type
		    AND ara.pk1     = p_entity_id
		    AND ara.pk2     = aca.pk2
		    AND ara.pk3     = aca.pk3
		    AND ara.risk_id = aca.pk4);



    /* Entity risk/control/ap changes begin*/

    DELETE FROM amw_risk_associations ara
     WHERE object_type=p_entity_type
       AND pk1 = p_entity_id
       AND pk3 IS NULL
       AND not exists
		(select 'Y'
		   from amw_execution_scope
		  where entity_type=p_entity_type
		    and entity_id = p_entity_id
		    and organization_id = ara.pk2
		    and process_id IS NULL);

    DELETE FROM amw_control_associations aca
     WHERE object_type=p_entity_type
       AND pk1 = p_entity_id
       AND pk3 IS NULL
       AND not exists
	        (select 'Y' from amw_risk_associations ara
		  where object_type = p_entity_type
		    and ara.pk1 = p_entity_id
		    and ara.pk2 = aca.pk2
		    and ara.pk3 IS NULL
		    and ara.risk_id = aca.pk4);

    /* Entity risk/control/ap changes end*/

	DELETE FROM AMW_AP_ASSOCIATIONS apa
	WHERE object_type = p_entity_type
	AND pk1         = p_entity_id
	AND NOT EXISTS
		(SELECT 'Y' FROM AMW_CONTROL_ASSOCIATIONS aca
		  WHERE aca.object_type = p_entity_type
		    AND aca.pk1         = p_entity_id
		    AND aca.pk2         = apa.pk2
		    AND aca.control_id  = apa.pk3)
	and pk2 <> -1 and pk3 <> -1;

     DELETE FROM amw_ap_associations apa
     WHERE object_type = p_entity_type
       AND pk1 = p_entity_id
       AND not exists
	        (select 'Y' from amw_execution_scope aes
		   where aes.entity_type = p_entity_type
		    and aes.entity_id = p_entity_id
		    and aes.organization_id = apa.pk2)
            and pk3 = -1
            and pk2 <> -1 ;

	FOR each_rec IN get_records_in_scope
	LOOP
		UPDATE amw_risk_associations ara
		SET ara.risk_rev_id = (SELECT risk.risk_rev_id
					FROM amw_risks_b risk
					WHERE risk.risk_id = ara.risk_id
					AND risk.curr_approved_flag = 'Y')
		WHERE ara.object_type = p_entity_type
		AND ara.pk1           = p_entity_id
		AND ara.pk2           = each_rec.organization_id
		AND ara.pk3           = each_rec.process_id;

		INSERT INTO amw_risk_associations (
			risk_association_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			risk_id,
			risk_rev_id,
			pk1,
			pk2,
			pk3,
			object_type,
			object_version_number)
		SELECT 	AMW_RISK_ASSOCIATIONS_S.nextval,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			fnd_global.user_id,
			risk.risk_id,
			risk.risk_rev_id,
			p_entity_id,
			ara.pk1,
			ara.pk2,
			p_entity_type,
			1
		FROM amw_risk_associations ara, amw_risks_b risk
		WHERE ara.object_type        = 'PROCESS_ORG'
		AND ara.pk1                  = each_rec.organization_id
		AND ara.pk2                  = each_rec.process_id
		AND ara.risk_id              = risk.risk_id
		AND ara.approval_date IS NOT NULL
		AND ara.deletion_approval_date IS NULL
		AND risk.curr_approved_flag  = 'Y'
		AND NOT EXISTS
			  (SELECT 'Y' FROM amw_risk_associations ara2
			   WHERE ara2.object_type=p_entity_type
			     AND ara2.pk1 = p_entity_id
			     AND ara2.pk2 = each_rec.organization_id
			     AND ara2.pk3 = each_rec.process_id
			     AND ara2.risk_id = risk.risk_id
			     AND ara2.risk_rev_id = risk.risk_rev_id
			     );


		UPDATE amw_control_associations aca
		SET aca.control_rev_id = (SELECT control_rev_id
					    FROM amw_controls_b control
					   WHERE control.control_id =  aca.control_id
					     AND control.curr_approved_flag = 'Y')
		WHERE aca.object_type = p_entity_type
		AND aca.pk1           = p_entity_id
		AND aca.pk2           = each_rec.organization_id
		AND aca.pk3           = each_rec.process_id;

		INSERT INTO amw_control_associations (
			control_association_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			control_id,
			control_rev_id,
			pk1,
			pk2,
			pk3,
			pk4,
			object_type,
			object_version_number)
		SELECT AMW_CONTROL_ASSOCIATIONS_S.nextval,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			fnd_global.user_id,
			control.control_id,
			control.control_rev_id,
			p_entity_id,
			each_rec.organization_id,
			each_rec.process_id,
			ara.risk_id,
			p_entity_type,
			1
		FROM amw_control_associations aca,amw_risk_associations ara,amw_controls_b control
		WHERE aca.object_type          = 'RISK_ORG'
		AND aca.pk1                    = each_rec.organization_id
		AND aca.pk2                    = each_rec.process_id
		AND aca.pk3                    = ara.risk_id
		AND aca.control_id             = control.control_id
		AND aca.approval_date IS NOT NULL
		AND aca.deletion_approval_date IS NULL
		AND control.curr_approved_flag = 'Y'
		AND ara.object_type            = 'PROCESS_ORG'
		AND ara.pk1                    = each_rec.organization_id
		AND ara.pk2                    = each_rec.process_id
		AND NOT EXISTS
			   (SELECT 'Y' FROM amw_control_associations aca2
			    WHERE aca2.object_type = p_entity_type
			      AND aca2.pk1         = p_entity_id
			      AND aca2.pk2         = each_rec.organization_id
			      AND aca2.pk3         = each_rec.process_id
			      AND aca2.pk4         = ara.risk_id
			      AND aca2.control_id  = control.control_id
			      AND aca2.control_rev_id = control.control_rev_id
			   );

		UPDATE amw_ap_associations apa
		SET apa.audit_procedure_rev_id = (SELECT audit_procedure_rev_id
						    FROM amw_audit_procedures_b aapb1
						   WHERE aapb1.audit_procedure_id = apa.audit_procedure_id
						     AND aapb1.curr_approved_flag = 'Y')
		WHERE apa.object_type = p_entity_type
		  AND apa.pk1         = p_entity_id
		  AND apa.pk2         = each_rec.organization_id;

		INSERT INTO amw_ap_associations (
			ap_association_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			audit_procedure_id,
			audit_procedure_rev_id,
			pk1,
			pk2,
			pk3,
			object_type,
			object_version_number)
		SELECT  AMW_AP_ASSOCIATIONS_S.nextval,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			fnd_global.user_id,
			auditproc.audit_procedure_id,
			auditproc.audit_procedure_rev_id,
			p_entity_id,
			auditproc.organization_id,
			auditproc.control_id,
			p_entity_type,
			1
		FROM
		(SELECT DISTINCT
		        aapb.audit_procedure_id,
			aapb.audit_procedure_rev_id,
			apa.pk1 organization_id,
			aca.control_id
		 FROM amw_ap_associations apa,amw_audit_procedures_b aapb,amw_control_associations aca
		 WHERE apa.object_type        = 'CTRL_ORG'
		   AND apa.pk1                = each_rec.organization_id
		   AND apa.pk2                = each_rec.process_id
		   AND apa.pk3                = aca.control_id
		   AND aca.object_type        = 'RISK_ORG'
		   AND apa.pk1                = aca.pk1 -- organization_id
		   AND apa.pk2                = aca.pk2 -- process_id
		   AND apa.audit_procedure_id = aapb.audit_procedure_id
		   AND aapb.curr_approved_flag='Y'
		   AND NOT EXISTS
			(SELECT 'Y' FROM amw_ap_associations apa2
			   WHERE apa2.object_type          = p_entity_type
			   AND apa2.pk1                    = p_entity_id
			   AND apa2.pk2                    = each_rec.organization_id
			   AND apa2.pk3                    = aca.control_id
			   AND apa2.audit_procedure_id     = aapb.audit_procedure_id
			   AND apa2.audit_procedure_rev_id = aapb.audit_procedure_rev_id
			)
		) auditproc;

	END LOOP; -- FOR each_rec IN get_records_in_scope LOOP

    /* Changes for org risk/control/ap */
    FOR scope_org_rec IN c_scope_org LOOP

        UPDATE AMW_RISK_ASSOCIATIONS ara
	SET ara.risk_rev_id = (SELECT risk.risk_rev_id
				FROM AMW_RISKS_B risk
				WHERE risk.risk_id = ara.risk_id
				AND risk.curr_approved_flag = 'Y')
	WHERE ara.object_type = p_entity_type
	AND ara.pk1           = p_entity_id
	AND ara.pk2           = scope_org_rec.organization_id
	AND ara.pk3 IS NULL;

	INSERT INTO AMW_RISK_ASSOCIATIONS
	(
		risk_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		risk_id,
		risk_rev_id,
		pk1,
		pk2,
		pk3,
		object_type,
		object_version_number
	)
	SELECT AMW_RISK_ASSOCIATIONS_S.nextval,
		   sysdate,
		   fnd_global.user_id,
		   sysdate,
		   fnd_global.user_id,
		   fnd_global.user_id,
		   risk.risk_id,
		   risk.risk_rev_id,
		   p_entity_id,
		   scope_org_rec.organization_id,
		   null,
		   p_entity_type,
		   1
	FROM amw_risk_associations ara, amw_risks_b risk
	WHERE ara.object_type        = 'ENTITY_RISK'
	AND ara.pk1                  = scope_org_rec.organization_id
	AND ara.pk2 IS NULL
	AND ara.risk_id              = risk.risk_id
	AND risk.curr_approved_flag  = 'Y'
	AND not exists
	   (select 'Y' from amw_risk_associations ara2
	    where ara2.object_type = p_entity_type
	      and ara2.pk1         = p_entity_id
	      and ara2.pk2         = scope_org_rec.organization_id
	      and ara2.pk3 IS NULL
	      and ara2.risk_id     = risk.risk_id
	      and ara2.risk_rev_id = risk.risk_rev_id
           );

        UPDATE AMW_CONTROL_ASSOCIATIONS aca
		SET aca.control_rev_id =
			      (SELECT control_rev_id
				 FROM AMW_CONTROLS_B control
				WHERE control.control_id =  aca.control_id
				  AND control.curr_approved_flag = 'Y')
		WHERE aca.object_type = p_entity_type
		AND aca.pk1           = p_entity_id
		AND aca.pk2           = scope_org_rec.organization_id
		AND aca.pk3 IS NULL;

	INSERT INTO amw_control_associations
	(
		control_association_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		control_id,
		control_rev_id,
		pk1,
		pk2,
		pk3,
		pk4,
		object_type,
		object_version_number
	)
	SELECT AMW_CONTROL_ASSOCIATIONS_S.nextval,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   control.control_id,
		   control.control_rev_id,
		   p_entity_id,
		   scope_org_rec.organization_id,
		   null,
		   ara.risk_id,
		   p_entity_type,
		   1
	FROM amw_control_associations aca,amw_risk_associations ara,amw_controls_b control
	WHERE aca.object_type          = 'ENTITY_CONTROL'
	AND aca.pk1                    = scope_org_rec.organization_id
	AND aca.pk2                    = ara.risk_id
	AND aca.pk3 IS NULL
	AND aca.control_id             = control.control_id
	AND control.curr_approved_flag = 'Y'
	AND ara.object_type            = p_entity_type
	AND ara.pk1                    = p_entity_id
	AND ara.pk2                    = scope_org_rec.organization_id
	AND ara.pk3 IS NULL
	AND not exists
	   (SELECT 'Y' from amw_control_associations aca2
	    WHERE aca2.object_type    = p_entity_type
	      AND aca2.pk1            = p_entity_id
	      AND aca2.pk2            = scope_org_rec.organization_id
	      AND aca2.pk3 IS NULL
	      AND aca2.pk4            = ara.risk_id
	      AND aca2.control_id     = control.control_id
	      AND aca2.control_rev_id = control.control_rev_id
          );


        UPDATE AMW_AP_ASSOCIATIONS apa
	SET apa.audit_procedure_rev_id =
		      (SELECT audit_procedure_rev_id
	  		 FROM amw_audit_procedures_b aapb1
	  		WHERE aapb1.audit_procedure_id = apa.audit_procedure_id
		          AND aapb1.curr_approved_flag = 'Y')
	WHERE apa.object_type = p_entity_type
	AND apa.pk1           = p_entity_id
   	AND apa.pk2           = scope_org_rec.organization_id;


	INSERT INTO amw_ap_associations (
			ap_association_id,
			last_update_date,
			last_updated_by,
			creation_date,
			created_by,
			last_update_login,
			audit_procedure_id,
			audit_procedure_rev_id,
			pk1,
			pk2,
			pk3,
			object_type,
			object_version_number)
	SELECT  AMW_AP_ASSOCIATIONS_S.nextval,
			sysdate,
			fnd_global.user_id,
			sysdate,
			fnd_global.user_id,
			fnd_global.user_id,
			auditproc.audit_procedure_id,
			auditproc.audit_procedure_rev_id,
			p_entity_id,
			auditproc.organization_id,
			auditproc.control_id,
			p_entity_type,
			1
	FROM
		(SELECT DISTINCT
		        aapb.audit_procedure_id,
			aapb.audit_procedure_rev_id,
			apa.pk1 organization_id,
			aca.control_id
		 FROM amw_ap_associations apa,amw_audit_procedures_b aapb,
		      amw_control_associations aca
		 WHERE apa.object_type        = 'ENTITY_AP'
		   AND aca.object_type	      = p_entity_type
		   AND aca.pk1		      = p_entity_id
		   AND aca.pk2		      = scope_org_rec.organization_id
		   AND aca.pk3		      IS NULL
		   AND apa.pk1                = aca.pk2
		   AND apa.pk2                = aca.control_id
		   AND apa.association_creation_date IS NOT NULL
		   AND apa.audit_procedure_id = aapb.audit_procedure_id
		   AND aapb.curr_approved_flag='Y'
		   AND NOT EXISTS
			(SELECT 'Y' FROM amw_ap_associations apa2
			   WHERE apa2.object_type          = p_entity_type
			   AND apa2.pk1                    = p_entity_id
			   AND apa2.pk2                    = scope_org_rec.organization_id
			   AND apa2.pk3                    = aca.control_id
			   AND apa2.audit_procedure_id     = aapb.audit_procedure_id
			   AND apa2.audit_procedure_rev_id = aapb.audit_procedure_rev_id
			)
		) auditproc;


    END LOOP; -- FOR scope_org_rec IN c_project_scope_org LOOP

	UPDATE amw_execution_scope
	SET SCOPE_CHANGED_STATUS   =  null
	WHERE entity_type          = p_entity_type
	AND entity_id              = p_entity_id
	AND SCOPE_CHANGED_STATUS   = 'C';

	EXCEPTION WHEN OTHERS THEN
	ROLLBACK TO POPULATE_ASSOCIATIONS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Add_Exc_Msg('AMW_SCOPE_PVT', l_api_name);
		FND_MSG_PUB.Count_And_Get(
		    p_encoded =>  FND_API.G_FALSE,
		    p_count   =>  x_msg_count,
		    p_data    =>  x_msg_data);
END populate_association_tables;

PROCEDURE populate_scope
(
    p_api_version_number        IN   NUMBER := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_id			IN   NUMBER,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
)
IS
	CURSOR all_auditable_units
	IS
	SELECT audit_v.company_code,audit_v.lob_code,audit_v.organization_id
	FROM amw_audit_units_v audit_v;

    	CURSOR get_all_processes(p_org_id NUMBER)
    	IS
    	SELECT DISTINCT org_v.child_process_id as process_id
    	FROM amw_curr_app_hierarchy_org_v org_v,amw_audit_units_v audit_v
    	WHERE org_v.parent_process_id = -2
    	AND audit_v.organization_id = org_v.child_organization_id
    	AND audit_v.organization_id = p_org_id;

    	l_sub_vs AMW_AUDIT_UNITS_V.subsidiary_valueset%TYPE;
	l_lob_vs AMW_AUDIT_UNITS_V.subsidiary_valueset%TYPE;
	l_sub_tbl sub_tbl_type;
	l_lob_tbl lob_tbl_type;
	l_org_tbl org_tbl_type;
	l_process_tbl process_tbl_type;

    	l_api_name           CONSTANT VARCHAR2(30) := 'populate_scope';
	l_api_version_number CONSTANT NUMBER       := 1.0;

	l_position NUMBER;
	l_temp_proc_id NUMBER;
BEGIN
	SAVEPOINT POPULATE_SCOPE;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

        -- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_sub_vs := FND_PROFILE.value('AMW_SUBSIDIARY_AUDIT_UNIT');
	l_lob_vs := FND_PROFILE.value('AMW_LOB_AUDIT_UNITS');

	l_position := 1;
    	FOR each_unit IN all_auditable_units
    	LOOP
    		l_sub_tbl(l_position).subsidiary_code := each_unit.company_code;
    		l_lob_tbl(l_position).lob_code 	      := each_unit.lob_code;
    		l_org_tbl(l_position).org_id          := each_unit.organization_id;

		l_position := l_position + 1;
    	END LOOP;

    	l_position := 1;
    	FOR i IN 1..l_org_tbl.count
    	LOOP
    		OPEN get_all_processes(l_org_tbl(i).org_id);
    		LOOP
    			FETCH get_all_processes INTO l_temp_proc_id;
    			EXIT WHEN get_all_processes%NOTFOUND;

    			l_process_tbl(l_position).process_id := l_temp_proc_id;
                l_position := l_position + 1;
    		END LOOP;
            CLOSE get_all_processes;
    	END LOOP;

	add_scope
	(
	    p_entity_type	=>  'BUSIPROC_CERTIFICATION',
	    p_entity_id		=>  p_entity_id,
	    p_sub_vs    	=>  l_sub_vs,
	    p_lob_vs		=>  l_lob_vs,
	    p_subsidiary_tbl	=>  l_sub_tbl,
	    p_lob_tbl		=>  l_lob_tbl,
	    p_org_tbl        	=>  l_org_tbl,
            p_process_tbl       =>  l_process_tbl,
	    x_return_status	=>  x_return_status,
	    x_msg_count         =>  x_msg_count,
	    x_msg_data          =>  x_msg_data
	);

	EXCEPTION WHEN OTHERS
	THEN
		ROLLBACK TO POPULATE_SCOPE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		FND_MSG_PUB.Count_And_Get(
		p_encoded =>  FND_API.G_FALSE,
		p_count   =>  x_msg_count,
		p_data    =>  x_msg_data);

END populate_scope;

PROCEDURE manage_processes
(
    p_api_version_number        IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_entity_type		        IN	     VARCHAR2,
    p_entity_id			        IN	     NUMBER,
    p_organization_id		    IN	     NUMBER,
    p_proc_hier_tbl		        IN	     PROC_HIER_TBL_TYPE,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
)
IS
    CURSOR c_scope_org IS
    SELECT SUBSIDIARY_VS, SUBSIDIARY_CODE,LOB_VS, LOB_CODE
    FROM AMW_EXECUTION_SCOPE
    WHERE entity_type = p_entity_type
    AND entity_id     = p_entity_id
    AND organization_id = p_organization_id
    FOR UPDATE NOWAIT;

    CURSOR get_proc_org_rev_id(p_process_id NUMBER) IS
    SELECT aorv.child_process_org_rev_id
    FROM amw_curr_app_hierarchy_org_v aorv,amw_execution_scope aes,amw_lookups lk
    WHERE aorv.child_organization_id = aes.organization_id(+)
      AND aorv.child_process_id      = aes.process_id(+)
      AND aorv.child_process_id      <> -2
      AND lk.lookup_type             = 'AMW_SCOPE_ENTITY_TYPE'
      AND lk.lookup_code             = 'PROCESS'
      AND aes.entity_type(+)         = p_entity_type
      AND aes.entity_id(+)           = p_entity_id
      AND aorv.child_organization_id = p_organization_id
      AND aorv.child_process_id      = p_process_id;

    p_process_tbl process_tbl_type;
    p_org_dummy_tbl org_tbl_type;

    l_process_org_rev_id NUMBER;

    l_subsidiary_vs	   VARCHAR2(150);
    l_sub_code		   VARCHAR2(150);
    l_lob_vs		   VARCHAR2(150);
    l_lob_code		   VARCHAR2(150);

    l_api_name                CONSTANT VARCHAR2(30) := 'Manage_Processes';
    l_api_version_number      CONSTANT NUMBER   := 1.0;
    l_exists		 VARCHAR2(1);

    l_return_status VARCHAR2(32767);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT MANAGE_PROCESSES_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME)    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_scope_org;
    FETCH c_scope_org INTO l_subsidiary_vs, l_sub_code,l_lob_vs, l_lob_code;
    CLOSE c_scope_org;

    --Step 1: Remove existing processes rows
    DELETE FROM amw_execution_scope
    WHERE entity_type = p_entity_type
      AND entity_id   = p_entity_id
      AND organization_id = p_organization_id
      AND level_id > 3;

    --Step 2: Populate new rows
    FOR i IN 1..p_proc_hier_tbl.count LOOP

        l_process_org_rev_id := null;

        OPEN get_proc_org_rev_id(p_proc_hier_tbl(i).process_id);
        FETCH get_proc_org_rev_id INTO l_process_org_rev_id;
        CLOSE get_proc_org_rev_id;

        INSERT INTO AMW_EXECUTION_SCOPE (
	       EXECUTION_SCOPE_ID,
		   ENTITY_TYPE,
		   ENTITY_ID,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   LAST_UPDATE_LOGIN,
		   SCOPE_CHANGED_STATUS,
		   LEVEL_ID,
		   SUBSIDIARY_VS,
		   SUBSIDIARY_CODE,
		   LOB_VS,
		   LOB_CODE,
		   ORGANIZATION_ID,
		   PROCESS_ID,
		   TOP_PROCESS_ID,
		   PARENT_PROCESS_ID,
		   PROCESS_ORG_REV_ID,
		   SCOPE_MODIFIED_DATE)
	SELECT amw_execution_scope_s.nextval,
 	       p_entity_type,
		   p_entity_id,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   'C',
		   p_proc_hier_tbl(i).level_id,
		   l_subsidiary_vs,
		   l_sub_code,
		   l_lob_vs,
		   l_lob_code,
		   p_organization_id,
		   p_proc_hier_tbl(i).process_id,
		   p_proc_hier_tbl(i).top_process_id,
		   p_proc_hier_tbl(i).parent_process_id,
		   l_process_org_rev_id,
		   SYSDATE
         FROM dual where not exists (select 'Y' from amw_execution_scope
         where entity_type = p_entity_type and entity_id = p_entity_id
         and organization_id = p_organization_id and process_id = p_proc_hier_tbl(i).process_id
         and top_process_id = p_proc_hier_tbl(i).top_process_id and parent_process_id = p_proc_hier_tbl(i).parent_process_id
         and level_id = p_proc_hier_tbl(i).level_id
         and subsidiary_vs =  l_subsidiary_vs and subsidiary_code= l_sub_code
	 and lob_vs = l_lob_vs and lob_code = l_lob_code
	 and process_org_rev_id = l_process_org_rev_id);

         --Move process id to a temporary PLS table
         p_process_tbl(i).process_id  := p_proc_hier_tbl(i).process_id;
    END LOOP;

    --Step 2.1: Set the scope_changed_status for the org also.
    UPDATE amw_execution_scope
       SET scope_changed_status = 'C'
     WHERE entity_type = p_entity_type
       AND entity_id   = p_entity_id
       AND organization_id = p_organization_id
       AND level_id = 3;

    --Step 3: Update rows into denormalized tables
    --Step 4: Populate appropriate risks and controls in the association tables
    IF p_entity_type = 'PROJECT'
    THEN
	populate_proj_denorm_tables
	(
	  p_audit_project_id   => p_entity_id
	);

	build_project_audit_task
	(
	  p_api_version_number    => 1.0 ,
	  p_audit_project_id	  => p_entity_id,
	  x_return_status         =>  l_return_status,
	  x_msg_count             =>  l_msg_count,
	  x_msg_data          =>  l_msg_data
	);

    ELSIF p_entity_type = 'BUSIPROC_CERTIFICATION'
    THEN
	populate_denormalized_tables
	(
	p_entity_type => p_entity_type,
	p_entity_id   => p_entity_id,
	p_org_tbl     => p_org_dummy_tbl,
	p_process_tbl => p_process_tbl,
	p_mode        => 'MANAGE'
	);

	populate_association_tables
	(
	p_entity_type 	        =>  p_entity_type,
	p_entity_id             =>  p_entity_id,
	x_return_status         =>  l_return_status,
	x_msg_count             =>  l_msg_count,
	x_msg_data              =>  l_msg_data
	);

    END IF;

    raise_scope_update_event(
		p_entity_type	=> p_entity_type,
		p_entity_id	=> p_entity_id,
		p_org_id	=> p_organization_id,
		p_mode		=> 'ManageProc');

EXCEPTION WHEN OTHERS THEN
    rollback to MANAGE_PROCESSES_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, l_api_name);
    FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
END Manage_Processes;

PROCEDURE remove_from_scope
(
    p_api_version_number        IN   NUMBER := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_type               IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_object_id			IN   NUMBER,
    p_object_type		IN   VARCHAR2,
    p_subsidiary_vs		IN   VARCHAR2,
    p_subsidiary_code	        IN   VARCHAR2,
    p_LOB_vs			IN   VARCHAR2,
    p_LOB_code			IN   VARCHAR2,
    p_organization_id		IN   NUMBER,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
)
IS
    CURSOR get_relevant_rows
    IS
    SELECT 'Y'
    FROM AMW_ENTITY_HIERARCHIES
    WHERE entity_id = p_entity_id
    FOR UPDATE NOWAIT;

    CURSOR get_object_type(l_object_id NUMBER, l_entity_id NUMBER)
    IS
    SELECT object_type
    FROM AMW_ENTITY_HIERARCHIES
    WHERE object_id = l_object_id
    AND entity_id = l_entity_id
    AND entity_type = p_entity_type;


  	l_api_name           CONSTANT VARCHAR2(30) := 'remove_from_scope';
	l_api_version_number CONSTANT NUMBER       := 1.0;

    l_exists VARCHAR2(1);
    l_object_tbl  org_tbl_type;
    l_object_type VARCHAR2(32767);

    l_return_status VARCHAR2(32767);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

-- To delete all the relevant entries from AMW_EXECUTION_SCOPE TABLE

        CURSOR c_audit_unit(p_org_id NUMBER)
        IS
        SELECT audit_v.company_code,
               audit_v.subsidiary_valueset,
               audit_v.lob_code,
               audit_v.lob_valueset,
               audit_v.organization_id
        FROM amw_audit_units_v audit_v
        WHERE organization_id = p_org_id;

BEGIN

  	SAVEPOINT REMOVE_FROM_SCOPE;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

    -- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Step 0: Lock relevant rows
    OPEN get_relevant_rows;
    FETCH get_relevant_rows INTO l_exists;
    CLOSE get_relevant_rows;

    --Step 1: Delete specified row
    DELETE FROM AMW_ENTITY_HIERARCHIES
    WHERE object_type   = p_object_type
    AND object_id       = p_object_id
    AND entity_type     = p_entity_type
    AND entity_id       = p_entity_id;

    --Step 2: Build a stack of child nodes all the way till the leaf node for object_type = 'SUBSIDIARY' or 'LINEOFBUSINESS'
    IF (p_object_type = 'SUBSIDIARY' OR p_object_type = 'LINEOFBUSINESS')
    THEN

        l_object_tbl(1).org_id := p_object_id;
        l_object_tbl := find_child_objects(p_entity_type,p_entity_id,p_object_id,p_object_type,l_object_tbl);

        --Step 3: Delete parent and child rows as found from stack
        FOR each_rec IN 1..l_object_tbl.count
        LOOP

            DELETE FROM AMW_ENTITY_HIERARCHIES
            WHERE object_id            = l_object_tbl(each_rec).org_id
            AND object_type            = p_object_type
            AND entity_id              = p_entity_id
            AND entity_type            = p_entity_type;

            DELETE FROM AMW_ENTITY_HIERARCHIES
            WHERE parent_object_id     = l_object_tbl(each_rec).org_id
            AND parent_object_type     = p_object_type
            AND entity_id              = p_entity_id
            AND entity_type            = p_entity_type;

            OPEN get_object_type(l_object_tbl(each_rec).org_id, p_entity_id);
            FETCH get_object_type INTO l_object_type;
            CLOSE get_object_type;

            IF ((l_object_type = 'ORGANIZATION') OR
                (l_object_type = 'ORG')
               )
            THEN
                remove_orgs_from_scope
                (
                    p_entity_type               => p_entity_type,
                    p_entity_id			=> p_entity_id,
                    p_object_id			=> l_object_tbl(each_rec).org_id,
                    x_return_status             => l_return_status,
                    x_msg_count                 => l_msg_count,
                    x_msg_data                  => l_msg_data
                );
		FOR audit_rec IN c_audit_unit(l_object_tbl(each_rec).org_id)
		LOOP
			If (p_object_type = 'SUBSIDIARY')
			THEN
				DELETE FROM AMW_EXECUTION_SCOPE WHERE entity_id = p_entity_id
				and entity_type = p_entity_type and subsidiary_vs = audit_rec.subsidiary_valueset
				and SUBSIDIARY_CODE = audit_rec.company_code;
			END IF;

			If (p_object_type = 'LINEOFBUSINESS')
			THEN
				DELETE FROM AMW_EXECUTION_SCOPE WHERE entity_id = p_entity_id
				and entity_type = p_entity_type and subsidiary_vs = audit_rec.subsidiary_valueset
				and SUBSIDIARY_CODE = audit_rec.company_code
 				AND NVL(lob_vs, 'AMW_NULL_CODE') = NVL(audit_rec.lob_valueset, NVL(lob_vs, 'AMW_NULL_CODE'))
    				AND NVL(lob_code, 'AMW_NULL_CODE') = NVL(audit_rec.lob_code, NVL(lob_code, 'AMW_NULL_CODE'))
    				AND level_id > 1;
			END IF;
		END LOOP;
            END IF;

        END LOOP;
    --Step 4: Delete all rows from current to leaf for object_type = 'ORGANIZATION' or 'ORG'
    ELSE
        remove_orgs_from_scope
        (
            p_entity_type               => p_entity_type,
            p_entity_id			=> p_entity_id,
            p_object_id			=> p_object_id,
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data
        );
    END IF;

    --Step 5: Delete all relevant rows in AMW_EXECUTION_SCOPE
    DELETE FROM AMW_EXECUTION_SCOPE
    WHERE entity_type = p_entity_type
    AND   entity_id   = p_entity_id
    AND subsidiary_vs = p_subsidiary_vs
    AND subsidiary_code = p_subsidiary_code
    AND NVL(lob_vs, 'AMW_NULL_CODE') = NVL(p_lob_vs, NVL(lob_vs, 'AMW_NULL_CODE'))
    AND NVL(lob_code, 'AMW_NULL_CODE') = NVL(p_lob_code, NVL(lob_code, 'AMW_NULL_CODE'))
    AND NVL(organization_id, -999) = NVL(p_organization_id, NVL(organization_id, -999));

    --Step 6: Mark relevant rows in AMW_AUDIT_PROJECTS
    IF p_entity_type = 'PROJECT'
    THEN
        UPDATE amw_audit_projects
        SET SCOPE_CHANGED_FLAG = 'Y'
        WHERE project_id = p_entity_id;
    END IF;

    --Step 7: Remove risks and controls in the association tables
    populate_association_tables
    (
	p_entity_type    =>  p_entity_type,
	p_entity_id      =>  p_entity_id,
	x_return_status  =>  l_return_status,
	x_msg_count      =>  l_msg_count,
	x_msg_data       =>  l_msg_data
    );

    raise_scope_update_event(
		p_entity_type	=> p_entity_type,
		p_entity_id	=> p_entity_id,
		p_mode		=> 'RemoveFromScope');

    EXCEPTION WHEN OTHERS
    THEN
    ROLLBACK TO REMOVE_FROM_SCOPE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    FND_MSG_PUB.Count_And_Get
        (
	p_encoded =>  FND_API.G_FALSE,
	p_count   =>  x_msg_count,
	p_data    =>  x_msg_data
	);

END remove_from_scope;

PROCEDURE remove_orgs_from_scope
(
    p_api_version_number        IN   NUMBER := 1.0,
    p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
    p_commit                    IN   VARCHAR2 := FND_API.g_false,
    p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
    p_entity_type               IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_object_id			IN   NUMBER,
    x_return_status             OUT  nocopy VARCHAR2,
    x_msg_count                 OUT  nocopy NUMBER,
    x_msg_data                  OUT  nocopy VARCHAR2
)
IS

    l_api_name           CONSTANT VARCHAR2(30) := 'remove_orgs_from_scope';
	l_api_version_number CONSTANT NUMBER       := 1.0;

    l_return_status VARCHAR2(32767);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(32767);

    l_object_tbl  org_tbl_type;

BEGIN

    SAVEPOINT REMOVE_ORGS_FROM_SCOPE;

	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

    -- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Step 1: Delete the node 'ORG' AND 'ORGANIZATION' from the hierarchy table
    DELETE FROM AMW_ENTITY_HIERARCHIES
    WHERE object_id     = p_object_id
    AND entity_id       = p_entity_id
    AND entity_type     = p_entity_type;

    --Step 2: Remove the node from denormalized tables
    IF p_entity_type = 'BUSIPROC_CERTIFICATION'
    THEN
        DELETE FROM AMW_PROC_CERT_EVAL_SUM
	WHERE organization_id = p_object_id
	AND certification_id  = p_entity_id;

    	DELETE FROM AMW_ORG_CERT_EVAL_SUM
	WHERE organization_id = p_object_id
	AND certification_id  = p_entity_id;
    ELSIF p_entity_type = 'PROJECT' THEN
        DELETE FROM amw_audit_scope_processes
	WHERE organization_id = p_object_id
	AND audit_project_id  = p_entity_id;

    	DELETE FROM amw_audit_scope_organizations
	WHERE organization_id = p_object_id
	AND audit_project_id  = p_entity_id;
    END IF;

    --Step 3: Build a stack of child nodes all the way till the leaf node for object_type = 'ORG'
    l_object_tbl(1).org_id := p_object_id;
    l_object_tbl := find_child_orgs(p_entity_type,p_entity_id,p_object_id,l_object_tbl);

    --Step 4: Delete parent and child rows from hierarchy and denormalized tables as found from stack
    FOR each_rec IN 1..l_object_tbl.count
    LOOP

        DELETE FROM AMW_ENTITY_HIERARCHIES
        WHERE object_id            = l_object_tbl(each_rec).org_id
        AND object_type            = 'ORG'
        AND parent_object_type     = 'ORG'
        AND entity_id              = p_entity_id
        AND entity_type            = p_entity_type;

        DELETE FROM AMW_ENTITY_HIERARCHIES
        WHERE parent_object_id     = l_object_tbl(each_rec).org_id
        AND parent_object_type     = 'ORG'
        AND object_type            = 'ORG'
        AND entity_id              = p_entity_id
        AND entity_type            = p_entity_type;

        IF p_entity_type = 'BUSIPROC_CERTIFICATION'
	THEN
		DELETE FROM AMW_PROC_CERT_EVAL_SUM
		WHERE organization_id = l_object_tbl(each_rec).org_id
		AND certification_id  = p_entity_id;

	    	DELETE FROM AMW_ORG_CERT_EVAL_SUM
		WHERE organization_id = l_object_tbl(each_rec).org_id
		AND certification_id  = p_entity_id;
    	END IF;

    END LOOP;

	EXCEPTION WHEN OTHERS
	THEN
		ROLLBACK TO REMOVE_ORGS_FROM_SCOPE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		FND_MSG_PUB.Count_And_Get(
		p_encoded =>  FND_API.G_FALSE,
		p_count   =>  x_msg_count,
		p_data    =>  x_msg_data);

END remove_orgs_from_scope;

FUNCTION find_child_orgs
(
    p_entity_type               IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_object_id			IN   NUMBER,
    p_object_tbl                IN   org_tbl_type
)
RETURN org_tbl_type
IS

    CURSOR get_child_orgs(l_entity_id NUMBER, l_object_id NUMBER)
    IS
    SELECT object_id
    FROM AMW_ENTITY_HIERARCHIES
    WHERE parent_object_id   = l_object_id
    AND entity_id            = l_entity_id
    AND entity_type          = p_entity_type
    AND object_type          = 'ORG'
    AND parent_object_type   = 'ORG';

    l_object_tbl org_tbl_type;

BEGIN

    l_object_tbl := p_object_tbl;

    FOR each_org in get_child_orgs(p_entity_id, p_object_id)
    LOOP
        l_object_tbl(l_object_tbl.count + 1).org_id := each_org.object_id;
    	l_object_tbl := find_child_orgs(p_entity_type,p_entity_id,each_org.object_id,l_object_tbl);
	END LOOP;

    RETURN l_object_tbl;

END find_child_orgs;

FUNCTION find_child_objects
(
    p_entity_type               IN   VARCHAR2,
    p_entity_id			IN   NUMBER,
    p_object_id			IN   NUMBER,
    p_object_type               IN   VARCHAR2,
    p_object_tbl                IN   org_tbl_type
)
RETURN org_tbl_type
IS

    CURSOR get_child_objects(l_entity_id NUMBER, l_object_id NUMBER)
    IS
    SELECT object_id
    FROM AMW_ENTITY_HIERARCHIES
    WHERE parent_object_id   = l_object_id
    AND entity_id            = l_entity_id
    AND entity_type          = p_entity_type
    AND parent_object_type   = p_object_type;

    l_object_tbl org_tbl_type;
BEGIN

    l_object_tbl := p_object_tbl;

    FOR each_obj in get_child_objects(p_entity_id, p_object_id)
    LOOP
        l_object_tbl(l_object_tbl.count + 1).org_id := each_obj.object_id;
    	l_object_tbl := find_child_objects(p_entity_type,p_entity_id,each_obj.object_id,p_object_type,l_object_tbl);
	END LOOP;

    RETURN l_object_tbl;
END find_child_objects;


function get_assoc_task_id (
	       p_project_id in number,
	       p_task_id in number)
return NUMBER is
    cursor c_task_id is
        select t2.task_id
          from pa_projects_all pp,
	       pa_tasks t1,
	       pa_tasks t2
	 where pp.project_id = p_project_id
	   and t1.project_id = pp.created_from_project_id
	   and t1.task_id = p_task_id
	   and t1.task_number = t2.task_number
	   and t2.project_id = p_project_id;
    l_task_id number;
begin
    open c_task_id;
    fetch c_task_id into l_task_id;
    close c_task_id;
    return l_task_id;
end;


PROCEDURE populate_proj_denorm_tables (
		p_audit_project_id  IN NUMBER
) IS
BEGIN
  DELETE FROM amw_audit_scope_organizations
   WHERE audit_project_id = p_audit_project_id
     AND organization_id NOT IN
			(SELECT organization_id
			   FROM amw_execution_scope
			  WHERE entity_type = 'PROJECT'
			    AND entity_id = p_audit_project_id
                            AND level_id = 3);

  INSERT INTO amw_audit_scope_organizations (
	   audit_project_id,
	   subsidiary_vs,
	   subsidiary_code,
	   lob_vs,
	   lob_code,
	   organization_id,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login,
	   object_version_number)
    SELECT distinct p_audit_project_id,
	   au.subsidiary_valueset,
	   au.company_code,
	   au.lob_valueset,
	   au.lob_code,
	   au.organization_id,
	   g_user_id,
	   sysdate,
	   g_user_id,
	   sysdate,
	   g_login_id,
	   1
      FROM amw_audit_units_v au, amw_execution_scope es
     WHERE au.organization_id = es.organization_id
       AND es.entity_type = 'PROJECT'
       AND es.entity_id = p_audit_project_id
       AND es.level_id = 3
       AND es.organization_id NOT IN (
			   SELECT organization_id
			     FROM amw_audit_scope_organizations
			    WHERE audit_project_id = p_audit_project_id);

  DELETE FROM amw_audit_scope_processes
   WHERE audit_project_id = p_audit_project_id
     AND (organization_id, process_id) NOT IN
			(SELECT organization_id, process_id
			   FROM amw_execution_scope
			  WHERE entity_type = 'PROJECT'
			    AND entity_id = p_audit_project_id
                            AND process_id IS NOT NULL);

  INSERT INTO amw_audit_scope_processes (
	   audit_project_id,
	   organization_id,
	   process_id,
	   process_org_rev_id,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login,
	   object_version_number)
    SELECT distinct p_audit_project_id,
	   organization_id,
	   process_id,
	   process_org_rev_id,
	   g_user_id,
	   sysdate,
	   g_user_id,
	   sysdate,
	   g_login_id,
	   1
      FROM amw_execution_scope
     WHERE entity_type = 'PROJECT'
       AND entity_id = p_audit_project_id
       AND level_id > 3
       AND (organization_id, process_id) NOT IN (
			     SELECT organization_id, process_id
			       FROM amw_audit_scope_processes
			      WHERE audit_project_id = p_audit_project_id);


END populate_proj_denorm_tables;


PROCEDURE  get_accessible_sub_orgs(
            p_user_name		IN	VARCHAR2,
	    p_entity_id         IN      NUMBER,
   	    p_entity_type	IN	VARCHAR2,
	    p_org_id		IN	NUMBER,
	    px_org_ids		IN OUT  NOCOPY VARCHAR2)
IS
  CURSOR c_sub_orgs IS
    SELECT object_id
      FROM amw_entity_Hierarchies
     WHERE entity_id = p_entity_id
       AND entity_type = p_entity_type
       AND parent_object_type = 'ORG'
       AND parent_object_id = p_org_id;

  l_hasAccess	     VARCHAR2(15);
BEGIN
  FOR org_rec IN c_sub_orgs LOOP
    l_hasAccess :=FND_DATA_SECURITY.check_function(
		   p_api_version          => 1.0,
		   p_function             => 'AMW_CERTIFY_ORG',
		   p_object_name          => 'AMW_ORGANIZATION',
		   p_instance_pk1_value   => org_rec.object_id,
		   p_user_name            => p_user_name);
    IF l_hasAccess = 'T' THEN
      px_org_ids := px_org_ids||org_rec.object_id||',';
    ELSE
      get_accessible_sub_orgs(
            p_user_name	=> p_user_name,
	    p_entity_id	=> p_entity_id,
	    p_entity_type  => p_entity_type,
	    p_org_id	=> org_rec.object_id,
	    px_org_ids  => px_org_ids);
    END IF;
  END LOOP;
END get_accessible_sub_orgs;

PROCEDURE get_accessible_root_orgs (
	 p_entity_id		   IN  NUMBER,
	 p_entity_type		   IN  VARCHAR2,
	 x_org_ids		   OUT NOCOPY VARCHAR2)
IS
  CURSOR c_root_orgs IS
    SELECT object_id
      FROM amw_entity_Hierarchies
     WHERE entity_id = p_entity_id
       AND entity_type = p_entity_type
       AND parent_object_type = 'ROOTNODE'
       AND object_type = 'ORG';

  l_user_name	     VARCHAR2(200);
  l_hasAccess	     VARCHAR2(15);
BEGIN
      /*04.11.2006 npanandi: bug 5142733 fix -- commenting below if-else
	  because in R12, only FND_GLOBAL.user_name is allowed.
	  the rest are deprecated
	 */
  /*IF FND_GLOBAL.party_id IS NOT NULL THEN
    l_user_name := 'HZ_PARTY:'||FND_GLOBAL.party_id;
  ELSE
  */
    l_user_name := FND_GLOBAL.user_name;
  /*END IF;
 */

  FOR org_rec IN c_root_orgs LOOP
    l_hasAccess :=FND_DATA_SECURITY.check_function(
		   p_api_version          => 1.0,
		   p_function             => 'AMW_CERTIFY_ORG',
		   p_object_name          => 'AMW_ORGANIZATION',
		   p_instance_pk1_value   => org_rec.object_id,
		   p_user_name            => l_user_name);
    IF l_hasAccess = 'T' THEN
      x_org_ids := x_org_ids||org_rec.object_id||',';
    ELSE
      get_accessible_sub_orgs(
            p_user_name => l_user_name,
	    p_entity_id	=> p_entity_id,
	    p_entity_type  => p_entity_type,
	    p_org_id	=> org_rec.object_id,
	    px_org_ids  => x_org_ids);
    END IF;
  END LOOP;

END get_accessible_root_orgs;


FUNCTION Has_Org_Access_in_hier (
	 p_is_global_owner	IN VARCHAR2,
	 p_org_id		IN NUMBER)
RETURN VARCHAR2 IS

  l_user_name	     VARCHAR2(200);
  l_hasAccess	     VARCHAR2(15);

BEGIN
  IF p_is_global_owner = 'Y' THEN
--       OR fnd_profile.value('AMW_DATA_SECURITY_SWITCH') <> 'Y' THEN
     return 'Y';
  ELSE
      /*04.11.2006 npanandi: bug 5142733 fix -- commenting below if-else
	  because in R12, only FND_GLOBAL.user_name is allowed.
	  the rest are deprecated
	 */
    /*IF FND_GLOBAL.party_id IS NOT NULL THEN
      l_user_name := 'HZ_PARTY:'||FND_GLOBAL.party_id;
    ELSE*/
      l_user_name := FND_GLOBAL.user_name;
    /*END IF;
*/
    l_hasAccess :=FND_DATA_SECURITY.check_function(
		   p_api_version          => 1.0,
		   p_function             => 'AMW_CERTIFY_ORG',
		   p_object_name          => 'AMW_ORGANIZATION',
		   p_instance_pk1_value   => p_org_Id,
		   p_user_name            => l_user_name);
    IF l_hasAccess = 'T' THEN
      return 'Y';
    END IF;
  END IF;
  return 'N';
END Has_Org_Access_in_hier;


PROCEDURE  get_accessible_sub_procs(
            p_user_name		IN	VARCHAR2,
	    p_entity_id         IN      NUMBER,
   	    p_entity_type	IN	VARCHAR2,
	    p_org_id		IN	NUMBER,
	    p_proc_id		IN	NUMBER,
	    px_proc_ids		IN OUT  NOCOPY VARCHAR2)
IS
  CURSOR c_sub_procs IS
    SELECT process_id
      FROM amw_execution_scope
     WHERE entity_id = p_entity_id
       AND entity_type = p_entity_type
       AND organization_id = p_org_id
       AND parent_process_id = p_proc_id;

  l_hasAccess	     VARCHAR2(15);
BEGIN
  FOR proc_rec IN c_sub_procs LOOP
    l_hasAccess :=FND_DATA_SECURITY.check_function(
		   p_api_version          => 1.0,
		   p_function             => 'AMW_CERTIFY_ORG_PROCESS',
		   p_object_name          => 'AMW_PROCESS_ORGANIZATION',
		   p_instance_pk1_value   => p_org_id,
		   p_instance_pk2_value   => proc_rec.process_id,
		   p_user_name            => p_user_name);
    IF l_hasAccess = 'T' THEN
      px_proc_ids := px_proc_ids||proc_rec.process_id||',';
    ELSE
      get_accessible_sub_procs(
            p_user_name => p_user_name,
	    p_entity_id	=> p_entity_id,
	    p_entity_type  => p_entity_type,
	    p_org_id	=> p_org_id,
	    p_proc_id	=> proc_rec.process_id,
	    px_proc_ids  => px_proc_ids);
    END IF;
  END LOOP;
END get_accessible_sub_procs;

PROCEDURE get_accessible_root_procs (
	 p_entity_id		   IN  NUMBER,
	 p_entity_type		   IN  VARCHAR2,
	 p_org_id		   IN NUMBER,
	 x_proc_ids		   OUT NOCOPY VARCHAR2)
IS
  CURSOR c_root_procs IS
    SELECT process_id
      FROM amw_execution_scope
     WHERE entity_id = p_entity_id
       AND entity_type = p_entity_type
       AND level_id=4;

  l_user_name	     VARCHAR2(200);
  l_hasAccess	     VARCHAR2(15);
BEGIN
      /*04.11.2006 npanandi: bug 5142733 fix -- commenting below if-else
	  because in R12, only FND_GLOBAL.user_name is allowed.
	  the rest are deprecated
	 */
  /* IF FND_GLOBAL.party_id IS NOT NULL THEN
    l_user_name := 'HZ_PARTY:'||FND_GLOBAL.party_id;
  ELSE
*/
    l_user_name := FND_GLOBAL.user_name;
  /*END IF;*/

  FOR proc_rec IN c_root_procs LOOP
    l_hasAccess :=FND_DATA_SECURITY.check_function(
		   p_api_version          => 1.0,
		   p_function             => 'AMW_CERTIFY_ORG_PROCESS',
		   p_object_name          => 'AMW_PROCESS_ORGANIZATION',
		   p_instance_pk1_value   => p_org_id,
		   p_instance_pk2_value   => proc_rec.process_id,
		   p_user_name            => l_user_name);
    IF l_hasAccess = 'T' THEN
      x_proc_ids := x_proc_ids||proc_rec.process_id||',';
    ELSE
      get_accessible_sub_procs(
            p_user_name => l_user_name,
	    p_entity_id	=> p_entity_id,
	    p_entity_type  => p_entity_type,
	    p_org_id	=> p_org_id,
	    p_proc_id	=> proc_rec.process_id,
	    px_proc_ids  => x_proc_ids);
    END IF;
  END LOOP;

END get_accessible_root_procs;

END amw_scope_pvt;


/
