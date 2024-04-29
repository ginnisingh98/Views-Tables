--------------------------------------------------------
--  DDL for Package Body PA_FC_RES_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FC_RES_MAP" AS
-- $Header: PAFCRMPB.pls 120.1 2005/08/08 15:19:49 pbandla noship $

   -- deleting the resource maps for the given resource list assignment id
   P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE delete_res_maps_on_asgn_id
           (p_resource_list_assignment_id  IN NUMBER,
            x_return_status                OUT NOCOPY VARCHAR2,
            x_error_message_code           OUT NOCOPY VARCHAR2) IS
   BEGIN
     IF P_DEBUG_MODE = 'Y' THEN
        pa_fck_util.debug_msg('delete_res_maps_on_asgn_id: ' || 'PB:Entering - Delete Resource Maps');
     END IF;
     x_return_status := fnd_api.g_ret_sts_success;

     IF (p_resource_list_assignment_id is null) THEN
       DELETE pa_resource_maps;
     ELSE
       DELETE pa_resource_maps prm
       WHERE prm.resource_list_assignment_id = p_resource_list_assignment_id;
     END IF;
     IF P_DEBUG_MODE = 'Y' THEN
        pa_fck_util.debug_msg('delete_res_maps_on_asgn_id: ' || 'PB:Exiting - Delete Resource Maps');
     END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FC_RES_MAP'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_error_message_code := SQLCODE || ' '|| SQLERRM;
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       RAISE;
   END delete_res_maps_on_asgn_id;

PROCEDURE map_trans
          ( p_project_id              		IN  NUMBER,
            p_res_list_id             		IN  NUMBER,
            p_person_id 			IN  NUMBER,
            p_job_id 				IN  NUMBER,
            p_organization_id 			IN  NUMBER,
            p_vendor_id				IN  NUMBER,
            p_expenditure_type 			IN  VARCHAR2,
            p_event_type 			IN  VARCHAR2,
            p_non_labor_resource 		IN  VARCHAR2,
            p_expenditure_category 		IN  VARCHAR2,
            p_revenue_category		 	IN  VARCHAR2,
            p_non_labor_resource_org_id	 	IN  NUMBER,
            p_event_type_classification 	IN  VARCHAR2,
            p_system_linkage_function 		IN  VARCHAR2 ,
            p_exptype                           IN  VARCHAR2 DEFAULT NULL,
            x_resource_list_member_id		OUT NOCOPY NUMBER,
            x_return_status 			OUT NOCOPY VARCHAR2,
            x_error_message_code             	OUT NOCOPY VARCHAR2) IS

     l_resource_ind                 PA_RES_ACCUMS.resource_index_tbl;
     l_resources_in                 PA_RES_ACCUMS.resources_tbl_type;
     l_no_of_resources              BINARY_INTEGER;
     l_index                        BINARY_INTEGER;
     res_count                      BINARY_INTEGER;

     -- Variable to store the attributes of the resource list

     current_rl_assignment_id       NUMBER;      -- Current resource list assignment id
     current_rl_id                  NUMBER;      -- Current resource list id
     current_rl_changed_flag        VARCHAR2(1); -- was this resource list changed?
     mapping_done                   BOOLEAN;     -- is mapping done for current resource list
     current_rl_type_code           VARCHAR2(20);-- current resource list type code

     current_rl_member_id           NUMBER;
     current_resource_id            NUMBER;
     current_resource_rank          NUMBER;
     current_member_level           NUMBER;
     group_category_found           BOOLEAN;
     attr_match_found               BOOLEAN;
     new_resource_rank              NUMBER;

     old_resource_id                NUMBER;
     old_rl_member_id               NUMBER;

     resource_map_found             BOOLEAN;

     -- member id for unclassified resources
     uncl_group_member_id           NUMBER;
     uncl_child_member_id           NUMBER;
     uncl_resource_id               NUMBER;  -- assuming one resource_id for unclassfied

     x_err_stage                    varchar2(200);
     x_err_code                     number;

   BEGIN
     pa_funds_control_utils.print_message('Entering resource mapping');
     IF P_DEBUG_MODE = 'Y' THEN
        pa_fck_util.debug_msg('map_trans: ' || 'PB:Entering - Resource Mapping');
     END IF;

     pa_funds_control_utils.print_message('Parameters '|| p_project_id ||':RL-'||
            p_res_list_id ||':P-'||
            p_person_id  ||':J-'||
            p_job_id    ||':O-'||
            p_organization_id ||':V-'||
            p_vendor_id      ||':ET-'||
            p_expenditure_type ||':ET-'||
            p_event_type      ||':NLR-'||
            p_non_labor_resource  ||':EC-'||
            p_expenditure_category ||':RC-'||
            p_revenue_category    ||':NO-'||
            p_non_labor_resource_org_id   ||':ETC-'||
            p_event_type_classification  ||':SYS-'||
            p_system_linkage_function   ||':EXP-'||
            p_exptype                );
     IF P_DEBUG_MODE = 'Y' THEN
        pa_fck_util.debug_msg('map_trans: ' || 'PB:Parameters '|| p_project_id ||':RL-'||
            p_res_list_id ||':P-'||
            p_person_id  ||':J-'||
            p_job_id    ||':O-'||
            p_organization_id ||':V-'||
            p_vendor_id      ||':ET-'||
            p_expenditure_type ||':ET-'||
            p_event_type      ||':NLR-'||
            p_non_labor_resource  ||':EC-'||
            p_expenditure_category ||':RC-'||
            p_revenue_category    ||':NO-'||
            p_non_labor_resource_org_id   ||':ETC-'||
            p_event_type_classification  ||':SYS-'||
            p_system_linkage_function   ||':EXP-'||
            p_exptype                );
     END IF;

     PA_DEBUG.init_err_stack('PA_FC_RES_MAP.map_trans');

     PA_RES_ACCUMS.get_mappable_resources
          ( x_project_id   => p_project_id,
            x_res_list_id  => p_res_list_id,
            x_resource_ind => l_resource_ind,
            x_resources_in => l_resources_in,
            x_no_of_resources => l_no_of_resources,
            x_index        => l_index,
            x_err_stage    => x_err_stage,
            x_err_code     => x_err_code);

     pa_funds_control_utils.print_message('After get mappable resources ' || l_no_of_resources);
     IF P_DEBUG_MODE = 'Y' THEN
        pa_fck_util.debug_msg('map_trans: ' || 'PB:After get mappable resources ' || l_no_of_resources);
     END IF;

     -- Now process  the  transaction
     -- Get the txns for which mapping is to be done
     mapping_done := TRUE;
     current_rl_assignment_id :=0;

     FOR res_count IN 1..l_no_of_resources LOOP
        pa_funds_control_utils.print_message('Next resource -- ' || l_resources_in(res_count).resource_list_member_id);
        IF P_DEBUG_MODE = 'Y' THEN
           pa_fck_util.debug_msg('map_trans: ' || 'PB:Next resource -- ' || l_resources_in(res_count).resource_list_member_id);
        END IF;
        IF (current_rl_assignment_id <> l_resources_in(res_count).resource_list_assignment_id) THEN

         -- Mapping to the next resource list
         -- Check if resource mapping was done for last resource_list_assigment_id or not

         IF ( NOT mapping_done ) THEN
            pa_funds_control_utils.print_message('Mapping not done');
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('map_trans: ' || 'PB:Mapping not done');
            END IF;

	    IF ( current_resource_id IS NULL ) THEN -- The last txn_accum could not be mapped

             pa_funds_control_utils.print_message('Curr resourceid null');
             IF P_DEBUG_MODE = 'Y' THEN
                pa_fck_util.debug_msg('map_trans: ' || 'PB:Curr resourceid null');
             END IF;
	     -- Map to unclassified Resource
	     -- also if the group_category_found flag is true than map to unclassfied
	     -- category within the group

             current_resource_id      := uncl_resource_id;

	     IF (group_category_found AND uncl_child_member_id <> 0) THEN
                 pa_funds_control_utils.print_message('Grp category found');
                 IF P_DEBUG_MODE = 'Y' THEN
                    pa_fck_util.debug_msg('map_trans: ' || 'PB:Grp category found');
                 END IF;
                 current_rl_member_id := uncl_child_member_id;
	     ELSE
                 current_rl_member_id := uncl_group_member_id;
                 pa_funds_control_utils.print_message('Grp category not found');
                 IF P_DEBUG_MODE = 'Y' THEN
                    pa_fck_util.debug_msg('map_trans: ' || 'PB:Grp category not found');
                 END IF;
	     END IF;

	    END IF; --- IF ( current_resource_id IS NULL )

            PA_RES_ACCUMS.create_resource_map
              (x_resource_list_id            => current_rl_id,
               x_resource_list_assignment_id => current_rl_assignment_id,
               x_resource_list_member_id     => current_rl_member_id,
               x_resource_id                 => current_resource_id,
               x_person_id                   => p_person_id,
               x_job_id                      => p_job_id,
               x_organization_id             => p_organization_id,
               x_vendor_id                   => p_vendor_id,
               x_expenditure_type            => p_expenditure_type,
               x_event_type                  => p_event_type,
               x_non_labor_resource          => p_non_labor_resource,
               x_expenditure_category        => p_expenditure_category,
               x_revenue_category            => p_revenue_category,
               x_non_labor_resource_org_id   => p_non_labor_resource_org_id,
               x_event_type_classification   => p_event_type_classification,
               x_system_linkage_function     => p_system_linkage_function,
               x_err_stage                   => x_err_stage,
               x_err_code                    => x_err_code);

               pa_funds_control_utils.print_message('Created resource map');
               IF P_DEBUG_MODE = 'Y' THEN
                  pa_fck_util.debug_msg('map_trans: ' || 'PB:Created resource map');
               END IF;
         END IF;  -- IF ( NOT mapping_done )

         --- Proceed to the next resource list now

         current_rl_assignment_id   := l_resources_in(res_count).resource_list_assignment_id;
         current_rl_id              := l_resources_in(res_count).resource_list_id;
         current_rl_changed_flag    := PA_RES_ACCUMS.get_resource_list_status(
					x_resource_list_assignment_id => current_rl_assignment_id);
         current_rl_type_code       := PA_RES_ACCUMS.get_group_resource_type_code(
					x_resource_list_id => current_rl_id);
         mapping_done               := FALSE;

         -- This variables will store the information for best match for the resource
         current_rl_member_id       := NULL;
         current_resource_id        := NULL;
         current_resource_rank      := NULL;
         current_member_level       := NULL;
         group_category_found       := FALSE;
         uncl_group_member_id       := 0;
         uncl_child_member_id       := 0;
         uncl_resource_id           := 0;

         IF ( current_rl_changed_flag = 'Y' ) THEN -- This resource list assignmnet
						   -- has been changed
	    -- delete all the old maps for this resource list assignments
	    -- for all the transactions
            pa_funds_control_utils.print_message('RList changed');
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('map_trans: ' || 'PB:RList changed');
            END IF;
	    delete_res_maps_on_asgn_id(
			p_resource_list_assignment_id => current_rl_assignment_id,
			x_return_status => x_return_status,
			x_error_message_code =>	x_error_message_code);
	    PA_RES_ACCUMS.change_resource_list_status(
			x_resource_list_assignment_id => current_rl_assignment_id,
			x_err_stage => x_err_stage,
			x_err_code => x_err_code);

         ELSIF ( current_rl_changed_flag = 'N' ) THEN
            pa_funds_control_utils.print_message('RList not changed');
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('map_trans: ' || 'PB:RList not changed');
            END IF;
            -- Get the resource map status
            PA_RES_ACCUMS.get_resource_map
               (x_resource_list_id   => current_rl_id,
                x_resource_list_assignment_id => current_rl_assignment_id,
                x_person_id          => p_person_id,
                x_job_id             => p_job_id,
                x_organization_id    => p_organization_id,
                x_vendor_id          => p_vendor_id,
                x_expenditure_type   => p_expenditure_type,
                x_event_type         => p_event_type,
                x_non_labor_resource => p_non_labor_resource,
                x_expenditure_category => p_expenditure_category,
                x_revenue_category   => p_revenue_category,
                x_non_labor_resource_org_id   => p_non_labor_resource_org_id,
                x_event_type_classification   => p_event_type_classification,
                x_system_linkage_function     => p_system_linkage_function,
                x_resource_list_member_id     => old_rl_member_id,
                x_resource_id        => old_resource_id,
                x_resource_map_found => resource_map_found,
                x_err_stage      => x_err_stage,
                x_err_code => x_err_code);

            pa_funds_control_utils.print_message('Resource map found RL:' || current_rl_id ||'P:'||
                           p_person_id || 'O:' ||
                           p_organization_id || 'RLA:' ||
                           current_rl_assignment_id || 'J:' ||
                           p_job_id || 'V:' ||
                           p_vendor_id || 'ET:' ||
                           p_expenditure_type || 'ET:' ||
                           p_event_type || 'NLR:' ||
                           p_non_labor_resource || 'EC:' ||
                           p_expenditure_category ||'RC:' ||
                           p_revenue_category || 'NLRO:'||
                           p_non_labor_resource_org_id || 'ETC:' ||
                           p_event_type_classification || 'SYS:' ||
                           p_system_linkage_function);

            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('map_trans: ' || 'Resource map found RL:' || current_rl_id ||'P:'||
                           p_person_id || 'O:' ||
                           p_organization_id || 'RLA:' ||
                           current_rl_assignment_id || 'J:' ||
                           p_job_id || 'V:' ||
                           p_vendor_id || 'ET:' ||
                           p_expenditure_type || 'ET:' ||
                           p_event_type || 'NLR:' ||
                           p_non_labor_resource || 'EC:' ||
                           p_expenditure_category ||'RC:' ||
                           p_revenue_category || 'NLRO:'||
                           p_non_labor_resource_org_id || 'ETC:' ||
                           p_event_type_classification || 'SYS:' ||
                           p_system_linkage_function);
            END IF;

            -- check if a map exist for the given attributes in the map table
	    IF (resource_map_found) THEN
                   pa_funds_control_utils.print_message('Mapping done');
                   IF P_DEBUG_MODE = 'Y' THEN
                      pa_fck_util.debug_msg('map_trans: ' || 'PB:Mapping done');
                   END IF;
	   	   mapping_done := TRUE;
		   x_resource_list_member_id := old_rl_member_id;
		   return;
	    END IF;  -- IF (resource_map_found)

	  END IF;

       END IF; -- IF (current_rl_assignment_id <> p_resource_list_assignment_id ....

       IF ( NOT mapping_done ) THEN
           pa_funds_control_utils.print_message('Mapping not done 2');
           IF P_DEBUG_MODE = 'Y' THEN
              pa_fck_util.debug_msg('map_trans: ' || 'PB:Mapping not done 2');
           END IF;
	   -- Mapping still need to be done
	   attr_match_found     := TRUE;

	   IF ((l_resources_in(res_count).resource_type_code = 'UNCLASSIFIED' OR
		l_resources_in(res_count).resource_type_code = 'UNCATEGORIZED') AND
	        l_resources_in(res_count).member_level = 1 ) THEN
                  pa_funds_control_utils.print_message('Unclassified');
                  IF P_DEBUG_MODE = 'Y' THEN
                     pa_fck_util.debug_msg('map_trans: ' || 'PB:Unclassified');
                  END IF;
	          attr_match_found := FALSE;
                  uncl_resource_id := l_resources_in(res_count).resource_id;
                  uncl_group_member_id  := l_resources_in(res_count).resource_list_member_id;
	   END IF;

	   IF ( current_rl_type_code = 'EXPENDITURE_CATEGORY') THEN
            pa_funds_control_utils.print_message('Exp cat');
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('map_trans: ' || 'PB:Exp cat');
            END IF;
	    -- The resource list is based on the expenditure category
	    IF ( l_resources_in(res_count).expenditure_category = p_expenditure_category) THEN
	      group_category_found := TRUE;
	    ELSE
	      attr_match_found := FALSE;
	    END IF; --IF ( l_expenditure_category(res_count).....

	   ELSIF ( current_rl_type_code = 'REVENUE_CATEGORY' ) THEN
            pa_funds_control_utils.print_message('Rev cat');
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('map_trans: ' || 'PB:Rev cat');
            END IF;
	    -- The resource list is based on the revenue category
	    IF (l_resources_in(res_count).revenue_category = p_revenue_category) THEN
	      group_category_found := TRUE;
	    ELSE
	      attr_match_found := FALSE;
	    END IF; -- IF (l_revenue_category(res_count) ....

	   ELSIF ( current_rl_type_code = 'ORGANIZATION' ) THEN
            pa_funds_control_utils.print_message('Organization');
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('map_trans: ' || 'PB:Organization');
            END IF;
	    -- The resource list is based on the organization
	    IF (l_resources_in(res_count).organization_id = p_organization_id) THEN
	      group_category_found := TRUE;
	    ELSE
	      attr_match_found := FALSE;
	    END IF; -- IF (l_organization_id(res_count)

	   END IF; -- IF ( current_rl_type_code = 'EXPENDITURE_CATEGORY'...

	   IF ( current_rl_type_code = 'NONE' OR attr_match_found ) THEN
            pa_funds_control_utils.print_message('None');
            IF P_DEBUG_MODE = 'Y' THEN
               pa_fck_util.debug_msg('map_trans: ' || 'PB:None');
            END IF;
	    -- The resource list is based on the none category
	    -- Now compare the txn attributes with resource attributes
	    -- The table given below determines if the resource is eligible
	    -- for accumulation or not

	    --  TXN ATTRIBUTE       RESOURCE ATTRIBUTE  ELIGIBLE
	    --     NULL                   NULL            YES
	    --     NULL                 NOT NULL           NO
	    --   NOT NULL                 NULL            YES
	    --   NOT NULL               NOT NULL          YES/NO depending on value

	    -- Do not match the attributes for an unclassified resource

	    IF (l_resources_in(res_count).resource_type_code = 'UNCLASSIFIED' ) THEN
                pa_funds_control_utils.print_message('Uncl');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Uncl');
                END IF;
	        attr_match_found := FALSE;
                uncl_resource_id := l_resources_in(res_count).resource_id;
		IF ( l_resources_in(res_count).member_level = 1 ) THEN -- group level unclassified
                    pa_funds_control_utils.print_message('Group level');
                    IF P_DEBUG_MODE = 'Y' THEN
                       pa_fck_util.debug_msg('map_trans: ' || 'PB:Group level');
                    END IF;
                    uncl_group_member_id  := l_resources_in(res_count).resource_list_member_id;
		ELSE
                    pa_funds_control_utils.print_message('Non group');
                    IF P_DEBUG_MODE = 'Y' THEN
                       pa_fck_util.debug_msg('map_trans: ' || 'PB:Non group');
                    END IF;
                    uncl_child_member_id  := l_resources_in(res_count).resource_list_member_id;
		END IF;
	    END IF;

	    IF (NOT (attr_match_found AND
	        (NVL(l_resources_in(res_count).person_id,NVL(p_person_id,-1)) =
		NVL(p_person_id, -1)))) THEN
                pa_funds_control_utils.print_message('Personid');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Personid');
                END IF;
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).job_id,NVL(p_job_id,-1)) =
		NVL(p_job_id, -1)))) THEN
                pa_funds_control_utils.print_message('Job');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Job');
                END IF;
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).organization_id,NVL(p_organization_id,-1)) =
		NVL(p_organization_id, -1)))) THEN
                pa_funds_control_utils.print_message('Org id');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Org id');
                END IF;
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).vendor_id,NVL(p_vendor_id,-1)) =
		NVL(p_vendor_id, -1)))) THEN
                pa_funds_control_utils.print_message('Vendor');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Vendor');
                END IF;
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).expenditure_type,NVL(p_expenditure_type,'X')) =
		NVL(p_expenditure_type, 'X')))) THEN
                pa_funds_control_utils.print_message('Exp type');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Exp type');
                END IF;
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).event_type,NVL(p_event_type,'X')) =
		NVL(p_event_type, 'X')))) THEN
                pa_funds_control_utils.print_message('Event type');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Event type');
                END IF;
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
	        (NVL(l_resources_in(res_count).non_labor_resource,NVL(p_non_labor_resource,'X')) =
		NVL(p_non_labor_resource, 'X')))) THEN
                pa_funds_control_utils.print_message('NLR');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:NLR');
                END IF;
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).expenditure_category,NVL(p_expenditure_category,'X')) =
		NVL(p_expenditure_category, 'X')))) THEN
                pa_funds_control_utils.print_message('Exp cat');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Exp cat');
                END IF;
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).revenue_category,NVL(p_revenue_category,'X')) =
		NVL(p_revenue_category,'X')))) THEN
		attr_match_found := FALSE;
                pa_funds_control_utils.print_message('Rev cat');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:Rev cat');
                END IF;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).non_labor_resource_org_id,NVL(p_non_labor_resource_org_id,-1)) =
		NVL(p_non_labor_resource_org_id,-1)))) THEN
		attr_match_found := FALSE;
                pa_funds_control_utils.print_message('NLR prgid ');
                IF P_DEBUG_MODE = 'Y' THEN
                   pa_fck_util.debug_msg('map_trans: ' || 'PB:NLR prgid ');
                END IF;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).event_type_classification,NVL(p_event_type_classification,'X')) =
		NVL(p_event_type_classification,'X')))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(l_resources_in(res_count).system_linkage_function,NVL(p_system_linkage_function,'X')) =
		NVL(p_system_linkage_function,'X')))) THEN
		attr_match_found := FALSE;
	    END IF;

	   END IF; --IF ( current_rl_type_code = 'NONE'......
	   IF (attr_match_found) THEN
              pa_funds_control_utils.print_message('Inside rank');
              IF P_DEBUG_MODE = 'Y' THEN
                 pa_fck_util.debug_msg('map_trans: ' || 'PB:Inside rank');
              END IF;
	      -- Get the resource rank now
	      IF ( p_event_type_classification IS NOT NULL ) THEN
		 -- determine the rank based on event_type_classification
                 new_resource_rank := PA_RES_ACCUMS.get_resource_rank(
                                    x_resource_format_id => l_resources_in(res_count).resource_format_id,
                                    x_txn_class_code     => p_event_type_classification);
	      ELSE
		 -- determine the rank based on system_linkage_function
                 new_resource_rank := PA_RES_ACCUMS.get_resource_rank(
                                    x_resource_format_id => l_resources_in(res_count).resource_format_id,
                                    x_txn_class_code     => p_system_linkage_function);
	      END IF;

	      IF (  NVL(new_resource_rank,99) < NVL(current_resource_rank,99) ) THEN

		current_resource_rank := new_resource_rank;
                current_rl_member_id  := l_resources_in(res_count).resource_list_member_id;
                current_resource_id   := l_resources_in(res_count).resource_id;
                current_member_level  := l_resources_in(res_count).member_level;

	      END IF;
	    END IF; -- IF (attr_match_found)

       END IF;  -- IF ( NOT mapping_done ) THEN

      END LOOP;

      -- Now create the map for the last resoure list assignment
      IF ( NOT mapping_done ) THEN

	IF ( current_resource_id IS NULL ) THEN -- The last txn_accum could not be mapped

	   -- Map to unclassified Resource
	   -- also if the group_category_found flag is true than map to unclassfied
	   -- category within the group

           current_resource_id      := uncl_resource_id;

	   IF (group_category_found AND uncl_child_member_id <> 0) THEN
               current_rl_member_id := uncl_child_member_id;
	   ELSE
               current_rl_member_id := uncl_group_member_id;
	   END IF;

	END IF; --- IF ( current_resource_id IS NULL )

	-- Create a map now
        PA_RES_ACCUMS.create_resource_map
              (current_rl_id,
               current_rl_assignment_id,
               current_rl_member_id,
               current_resource_id,
               p_person_id,
               p_job_id,
               p_organization_id,
               p_vendor_id,
               p_expenditure_type,
               p_event_type,
               null,--x_non_labor_resource,
               p_expenditure_category,
               p_revenue_category,
               p_non_labor_resource_org_id,
               p_event_type_classification,
               p_system_linkage_function,
               x_err_stage,
               x_err_code);

       END IF;

      x_resource_list_member_id := current_rl_member_id;

      IF P_DEBUG_MODE = 'Y' THEN
         pa_fck_util.debug_msg('map_trans: ' || 'PB:Exiting - Resource Mapping, RLMI = '|| x_resource_list_member_id);
      END IF;
      pa_funds_control_utils.print_message('End of Resource Mapping, RLMI = ' || x_resource_list_member_id);

      PA_DEBUG.reset_err_stack;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_FC_RES_MAP'
                   ,p_procedure_name => PA_DEBUG.G_Err_Stack );
      x_error_message_code := SQLCODE || ' ' || SQLERRM;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_resource_list_member_id := NULL;
      RAISE;
  END map_trans;

END PA_FC_RES_MAP;

/
