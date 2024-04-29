--------------------------------------------------------
--  DDL for Package Body EAM_WORKBENCH_TREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WORKBENCH_TREE" AS
/* $Header: EAMWBTRB.pls 120.5 2006/03/29 05:46:33 kmurthy noship $ */

  /**
   * Given the search criteria, this function finds out all the asset numbers
   * and insert those into the temp table under a group id which is returned.
   * It returns -1 if nothing found.
   */

  function find_all_asset_numbers(p_org_id number,
                                  p_instance_id number,
                                  p_location_id number,
                                  p_category_id number,
                                  p_owning_dept_id number,
                                  p_asset_group_id number,
                                  p_asset_number varchar2,
				  p_transferred_asset varchar2,
				  p_set_name_id  number) return number is
    l_group_id number;
    l_count_first number;
    l_count_second number;
    l_return_status number;
  begin
    l_return_status := 0;
    l_count_first := 0;
    l_count_second := 0;

    select eam_asset_explosion_temp_s.nextval
      into l_group_id from dual;


    INSERT INTO eam_asset_explosion_temp(
        group_id,
        asset_group_id,
        asset_number,
        low_level_code)
        SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
          FROM csi_item_instances cii, mtl_system_items msi, mtl_parameters mp,eam_org_maint_defaults  eomd
         WHERE msi.eam_item_type = 1 AND msi.inventory_item_id = cii.inventory_item_id
	   AND msi.organization_id = cii.last_vld_organization_id AND msi.serial_number_control_code <> 1
	   AND nvl(cii.active_start_date, sysdate-1) <= sysdate AND nvl(cii.active_end_date, sysdate+1) >= sysdate
	   AND msi.organization_id = mp.organization_id AND mp.maint_organization_id = p_org_id
	   AND cii.instance_id = eomd.object_id (+) AND eomd.object_type (+) = 50
           AND (p_location_id IS NULL OR eomd.area_id = p_location_id)
           AND (p_category_id IS NULL OR cii.category_id = p_category_id)
           AND (p_owning_dept_id IS NULL OR eomd.owning_department_id = p_owning_dept_id)
	   AND (p_asset_group_id IS NULL OR cii.inventory_item_id = p_asset_group_id)
	   AND (p_asset_number IS NULL OR cii.serial_number = p_asset_number)
	   AND (p_instance_id IS NULL OR cii.instance_id = p_instance_id)
	   AND eomd.organization_id(+) = p_org_id
	   AND (p_set_name_id is null OR
			(
		           (cii.instance_id,3) in
			    (select maintenance_object_id,maintenance_object_type
			     from eam_pm_schedulings where set_name_id = p_set_name_id )
			 ) );

    IF SQL%ROWCOUNT = 0 THEN
       l_count_first := 1;
    END IF;

    -- Transferred Assets
    IF (p_transferred_asset = 'Y') THEN
	    INSERT INTO eam_asset_explosion_temp(
		group_id,
		asset_group_id,
		asset_number,
		low_level_code)
		SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
		  FROM csi_item_instances cii, mtl_system_items msi, mtl_parameters mp,
		       (select * from eam_org_maint_defaults where organization_id = p_org_id) eomd
		 WHERE msi.eam_item_type = 1
		 AND msi.inventory_item_id = cii.inventory_item_id
		   AND msi.organization_id = cii.last_vld_organization_id
		   AND msi.serial_number_control_code <> 1
		   AND nvl(cii.active_start_date, sysdate-1) <= sysdate
		   AND nvl(cii.active_end_date, sysdate+1) >= sysdate
		   AND msi.organization_id = mp.organization_id
		   AND mp.maint_organization_id <> p_org_id
		   AND cii.instance_id = eomd.object_id (+)
		   AND eomd.object_type (+) = 50
		   AND (p_location_id IS NULL OR eomd.area_id = p_location_id)
		   AND (p_category_id IS NULL OR cii.category_id = p_category_id)
		   AND (p_owning_dept_id IS NULL OR eomd.owning_department_id = p_owning_dept_id)
		   AND (p_asset_group_id IS NULL OR cii.inventory_item_id = p_asset_group_id)
		   AND (p_asset_number IS NULL OR cii.serial_number = p_asset_number)
		   AND (p_instance_id IS NULL OR cii.instance_id = p_instance_id)
		   AND (p_set_name_id is null OR
			(
		           (cii.instance_id,3) in
			    (select maintenance_object_id,maintenance_object_type
			     from eam_pm_schedulings where set_name_id = p_set_name_id )
			 ) )
		   AND EXISTS (SELECT 1
				FROM wip_discrete_jobs
				WHERE organization_id = p_org_id
				  AND maintenance_object_id = cii.instance_id) ;
	    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
	       l_count_first := 1;
	    ELSE
	       l_count_first := 0;
	    END IF;
    END IF;

    IF (p_instance_id is not null) then
      	INSERT INTO eam_asset_explosion_temp(
        		group_id,
        		asset_group_id,
        		asset_number,
        		low_level_code)
                 SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
		   FROM mtl_eam_network_assets mena, csi_item_instances cii, mtl_parameters mp
		  WHERE p_instance_id = mena.network_object_id AND mena.maintenance_object_id = cii.instance_id
		    AND cii.last_vld_organization_id = mp.organization_id AND mp.maint_organization_id = p_org_id;

	    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
	       l_count_first := 1;
	    ELSE
	       l_count_first := 0;
	    END IF;

	-- Transferred Assets
	IF (p_transferred_asset = 'Y') THEN
		INSERT INTO eam_asset_explosion_temp(
				group_id,
				asset_group_id,
				asset_number,
				low_level_code)
			 SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
			   FROM mtl_eam_network_assets mena, csi_item_instances cii, mtl_parameters mp
			  WHERE p_instance_id = mena.network_object_id
			    AND mena.maintenance_object_id = cii.instance_id
			    AND cii.last_vld_organization_id = mp.organization_id
			    AND mp.maint_organization_id <> p_org_id
			    AND EXISTS (SELECT 1
				FROM wip_discrete_jobs
				WHERE organization_id = p_org_id
				  AND maintenance_object_id = cii.instance_id) ;
	END IF;
	    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
	       l_count_first := 1;
	    ELSE
	       l_count_first := 0;
	    END IF;

    ELSIF (p_asset_number IS NOT NULL AND p_asset_group_id IS NOT NULL) THEN
      	INSERT INTO eam_asset_explosion_temp(
        		group_id,
        		asset_group_id,
        		asset_number,
        		low_level_code)
                 SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
		   FROM mtl_eam_network_assets mena, csi_item_instances ciin, csi_item_instances cii, mtl_parameters mp
		  WHERE ciin.serial_number = p_asset_number AND ciin.inventory_item_id = p_asset_group_id
		    AND ciin.instance_id = mena.network_object_id AND mena.maintenance_object_id = cii.instance_id
		    AND cii.last_vld_organization_id = mp.organization_id AND mp.maint_organization_id = p_org_id;

	    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
	       l_count_first := 1;
	    ELSE
	       l_count_first := 0;
	    END IF;
	-- Transferred Assets
	IF (p_transferred_asset = 'Y') THEN
		INSERT INTO eam_asset_explosion_temp(
				group_id,
				asset_group_id,
				asset_number,
				low_level_code)
			 SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
			   FROM mtl_eam_network_assets mena, csi_item_instances ciin, csi_item_instances cii, mtl_parameters mp
			  WHERE ciin.serial_number = p_asset_number
			    AND ciin.inventory_item_id = p_asset_group_id
			    AND ciin.instance_id = mena.network_object_id
			    AND mena.maintenance_object_id = cii.instance_id
			    AND cii.last_vld_organization_id = mp.organization_id
			    AND mp.maint_organization_id <> p_org_id
			    AND EXISTS (SELECT 1
				FROM wip_discrete_jobs
				WHERE organization_id = p_org_id
				  AND maintenance_object_id = cii.instance_id) ;
	    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
	       l_count_first := 1;
	    ELSE
	       l_count_first := 0;
	    END IF;
	END IF;
    END IF;

    IF  l_count_first = 1 THEN
       l_return_status := 1;
    END IF;

    if  l_return_status = 1 then
      return -1;
    else
      return l_group_id;
    end if;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return -1;

  end find_all_asset_numbers;


  /**
   * Given the search criteria, this procedure finds out all the applicable
   * asset numbers and builds the hierarchy trees.
   */
  function construct_hierarchy_forest(p_org_id number,
                                      p_instance_id number,
                                      p_location_id number,
                                      p_category_id number,
                                      p_owning_dept_id number,
                                      p_asset_group_id number,
                                      p_asset_number varchar2,
				      p_set_name_id  number) return number as
    language java name 'oracle.apps.eam.workbench.WorkBenchTree.constructTree(
                                       java.lang.Long,
				       java.lang.Long,
                                       java.lang.Long,
                                       java.lang.Long,
                                       java.lang.Long,
                                       java.lang.Long,
                                       java.lang.String,
				       java.lang.Long) return long';


  /**
   * Procedure construct_hierarchy_forest must be called before this function can
   * be called. Otherwise, it will cause unexpected behavior.
   * Given the asset number and asset group id, this function will copy the
   * subtree of the given asset number to the temp table. It returns the group_id
   * back so the user can reference it. It returns NULL if the given asset number
   * is not found.
   */
  function copy_subtree_to_temp_table(p_asset_group_id number,
                                      p_asset_number varchar2) return number as
    language java name 'oracle.apps.eam.workbench.WorkBenchTree.getSubtree(
                                      long,
                                      java.lang.String) return long';

  /**
   * This procedure releases the resource taken explicity.
   */
  procedure clear_forest as
    language java name 'oracle.apps.eam.workbench.WorkBenchTree.clear()';

  /** added by sraval to include rebuildables in activity workbench
    */
     --p_include_rebuildable param will have a value of null from activity workbench and 'Y' from planenrs workbench
    function find_all_asset_numbers(p_org_id number,
                                    p_instance_id number,
                                    p_location_id number,
                                    p_category_id number,
                                    p_owning_dept_id number,
                                    p_asset_group_id number,
                                    p_asset_number varchar2,
                                    p_include_rebuildable varchar2,
				    p_transferred_asset varchar2,
				    p_set_name_id  number
	) return number is
        l_group_id number;
        l_count_first number;
        l_return_status number;

      begin
        l_return_status := 0;
        l_count_first := 0;
        select eam_asset_explosion_temp_s.nextval
          into l_group_id from dual;

        INSERT INTO eam_asset_explosion_temp(
            group_id,
            asset_group_id,
            asset_number,
            low_level_code)
        SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
          FROM csi_item_instances cii, mtl_system_items msi, mtl_parameters mp,eam_org_maint_defaults eomd
         WHERE msi.eam_item_type in (1,3) AND msi.inventory_item_id = cii.inventory_item_id
	   AND msi.organization_id = cii.last_vld_organization_id AND msi.serial_number_control_code <> 1
	   AND nvl(cii.active_start_date, sysdate-1) <= sysdate AND nvl(cii.active_end_date, sysdate+1) >= sysdate
	   AND msi.organization_id = mp.organization_id AND mp.maint_organization_id = p_org_id
	   AND cii.instance_id = eomd.object_id (+) AND eomd.object_type (+) = 50
           AND (p_location_id IS NULL OR eomd.area_id = p_location_id)
           AND (p_category_id IS NULL OR cii.category_id = p_category_id)
           AND (p_owning_dept_id IS NULL OR eomd.owning_department_id = p_owning_dept_id)
	   AND (p_asset_group_id IS NULL OR cii.inventory_item_id = p_asset_group_id)
	   AND (p_asset_number IS NULL OR cii.serial_number = p_asset_number)
	   AND (p_instance_id IS NULL OR cii.instance_id = p_instance_id)
	   AND (p_set_name_id is null OR
			(
		           (cii.instance_id,3) in
			    (select maintenance_object_id,maintenance_object_type
			     from eam_pm_schedulings where set_name_id = p_set_name_id )
			 ) )
	   AND eomd.organization_id(+) = p_org_id;
           -- Is this stii required, WE team please check ????
	   -- (p_include_rebuildable='Y' and msn.current_status in (1,3,4))))) --planners workbench will pass p_include_rebuildable as 'Y'

        IF SQL%ROWCOUNT = 0 THEN
           l_count_first := 1;
        END IF;

	-- Transferred Assets
	IF (p_transferred_asset = 'Y') THEN
		INSERT INTO eam_asset_explosion_temp(
		    group_id,
		    asset_group_id,
		    asset_number,
		    low_level_code)
		SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
		  FROM csi_item_instances cii, mtl_system_items msi, mtl_parameters mp,
		       (select * from eam_org_maint_defaults where organization_id = p_org_id) eomd
		 WHERE msi.eam_item_type in (1,3) AND msi.inventory_item_id = cii.inventory_item_id
		   AND msi.organization_id = cii.last_vld_organization_id AND msi.serial_number_control_code <> 1
		   AND nvl(cii.active_start_date, sysdate-1) <= sysdate AND nvl(cii.active_end_date, sysdate+1) >= sysdate
		   AND msi.organization_id = mp.organization_id AND mp.maint_organization_id <> p_org_id
		   AND cii.instance_id = eomd.object_id (+) AND eomd.object_type (+) = 50
		   AND (p_location_id IS NULL OR eomd.area_id = p_location_id)
		   AND (p_category_id IS NULL OR cii.category_id = p_category_id)
		   AND (p_owning_dept_id IS NULL OR eomd.owning_department_id = p_owning_dept_id)
		   AND (p_asset_group_id IS NULL OR cii.inventory_item_id = p_asset_group_id)
		   AND (p_asset_number IS NULL OR cii.serial_number = p_asset_number)
		   AND (p_instance_id IS NULL OR cii.instance_id = p_instance_id)
		   AND (p_set_name_id is null OR
			(
		           (cii.instance_id,3) in
			    (select maintenance_object_id,maintenance_object_type
			     from eam_pm_schedulings where set_name_id = p_set_name_id )
			 ) )
		   AND EXISTS (SELECT 1
				FROM wip_discrete_jobs
				WHERE organization_id = p_org_id
				  AND maintenance_object_id = cii.instance_id) ;
		    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
		       l_count_first := 1;
		    ELSE
		       l_count_first := 0;
		    END IF;
	END IF;

	IF (p_instance_id is not null) then
        	INSERT INTO eam_asset_explosion_temp(
        		group_id,
        		asset_group_id,
        		asset_number,
        		low_level_code)
                 SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
		   FROM mtl_eam_network_assets mena, csi_item_instances cii, mtl_parameters mp
		  WHERE p_instance_id = mena.network_object_id AND mena.maintenance_object_id = cii.instance_id
		    AND cii.last_vld_organization_id = mp.organization_id AND mp.maint_organization_id = p_org_id;

		    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
		       l_count_first := 1;
		    ELSE
		       l_count_first := 0;
		    END IF;
		-- Transferred Assets
		IF (p_transferred_asset = 'Y') THEN
			INSERT INTO eam_asset_explosion_temp(
				group_id,
				asset_group_id,
				asset_number,
				low_level_code)
			 SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
			   FROM mtl_eam_network_assets mena, csi_item_instances cii, mtl_parameters mp
			  WHERE p_instance_id = mena.network_object_id AND mena.maintenance_object_id = cii.instance_id
			    AND cii.last_vld_organization_id = mp.organization_id AND mp.maint_organization_id <> p_org_id
			   AND EXISTS (SELECT 1
					FROM wip_discrete_jobs
				WHERE organization_id = p_org_id
				  AND maintenance_object_id = cii.instance_id) ;
		    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
		       l_count_first := 1;
		    ELSE
		       l_count_first := 0;
		    END IF;
		END IF;
        ELSIF (p_asset_number is not null AND p_asset_group_id IS NOT NULL) THEN
      	         INSERT INTO eam_asset_explosion_temp(
        		group_id,
        		asset_group_id,
        		asset_number,
        		low_level_code)
                 SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
		   FROM mtl_eam_network_assets mena, csi_item_instances ciin, csi_item_instances cii, mtl_parameters mp
		  WHERE ciin.serial_number = p_asset_number AND ciin.inventory_item_id = p_asset_group_id
		    AND ciin.instance_id = mena.network_object_id AND mena.maintenance_object_id = cii.instance_id
		    AND cii.last_vld_organization_id = mp.organization_id AND mp.maint_organization_id = p_org_id;

		    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
		       l_count_first := 1;
		    ELSE
		       l_count_first := 0;
		    END IF;
		-- Transferred Assets
		IF (p_transferred_asset = 'Y') THEN
			 INSERT INTO eam_asset_explosion_temp(
				group_id,
				asset_group_id,
				asset_number,
				low_level_code)
			 SELECT eam_asset_explosion_temp_s.currval, cii.inventory_item_id, cii.serial_number, 1
			   FROM mtl_eam_network_assets mena, csi_item_instances ciin, csi_item_instances cii, mtl_parameters mp
			  WHERE ciin.serial_number = p_asset_number AND ciin.inventory_item_id = p_asset_group_id
			    AND ciin.instance_id = mena.network_object_id AND mena.maintenance_object_id = cii.instance_id
			    AND cii.last_vld_organization_id = mp.organization_id AND mp.maint_organization_id <> p_org_id
			   AND EXISTS (SELECT 1
				FROM wip_discrete_jobs
				WHERE organization_id = p_org_id
				  AND maintenance_object_id = cii.instance_id) ;
		    IF (SQL%ROWCOUNT = 0) AND (l_count_first = 1) THEN
		       l_count_first := 1;
		    ELSE
		       l_count_first := 0;
		    END IF;
		END IF;
        END IF;

        IF SQL%ROWCOUNT = 0 AND l_count_first = 1 THEN
           l_return_status := 1;
        END IF;

        if l_return_status = 1 then
          return -1;
        else
          return l_group_id ;
        end if;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
            return -1;

    end find_all_asset_numbers;

    /** added by sraval to include rebuildables in activity workbench
    */
    function construct_hierarchy_forest(p_org_id number,
                                          p_instance_id number,
                                          p_location_id number,
                                          p_category_id number,
                                          p_owning_dept_id number,
                                          p_asset_group_id number,
                                          p_asset_number varchar2,
                                          p_include_rebuildable varchar2,
					  p_set_name_id  number) return number as
        language java name 'oracle.apps.eam.workbench.WorkBenchTree.constructTree(
                                           java.lang.Long,
					   java.lang.Long,
                                           java.lang.Long,
                                           java.lang.Long,
                                           java.lang.Long,
                                           java.lang.Long,
                                           java.lang.String,
                                           java.lang.String,
					   java.lang.Long) return long';


   /* This procedure is used to delete the session data from eam_asset_explosion_temp
      table. This is added for the bug #2688078
   */
      procedure clear_eam_asset(p_group_id IN NUMBER) is
       PRAGMA AUTONOMOUS_TRANSACTION;

      begin
	   -- removed redundant IF condition for deleting the rows . Bug 3616034
           delete from eam_asset_explosion_temp where  group_id = p_group_id;
           commit;
      end;

         /* Code Added for bug 3982343 Start */
         procedure clear_eam_asset
         (
           p_global_group_ids IN global_group_ids
         )
         IS
         PRAGMA AUTONOMOUS_TRANSACTION;
         BEGIN -- Bug 4175235 replaced FOR LOOP with FORALL
           FORALL i in p_global_group_ids.FIRST..p_global_group_ids.LAST
              DELETE
              FROM eam_asset_explosion_temp
              WHERE  group_id = p_global_group_ids(i);
          COMMIT;
         END;
         /* Code Added for bug 3982343 End */

END eam_workbench_tree;

/
