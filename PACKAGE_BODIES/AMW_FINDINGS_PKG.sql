--------------------------------------------------------
--  DDL for Package Body AMW_FINDINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_FINDINGS_PKG" as
/* $Header: amwfindb.pls 120.0 2005/05/31 19:49:54 appldev noship $ */

-------------------------------------------------------------------------
-- Function that calculates the number of open change objects for an AMW
-- objects.
-------------------------------------------------------------------------

    function calculate_open_findings ( findings_category char,
                                       self_entity_name char, self_pk1_value number,
                                       parent1_entity_name char, parent1_pk1_value number,
                                       parent2_entity_name char, parent2_pk1_value number,
                                       parent3_entity_name char, parent3_pk1_value number,
                                       parent4_entity_name char, parent4_pk1_value number )
    return number is

        ofcount number;

    begin

        select  count ( ecs_self.change_id )
        into    ofcount
        from    eng_change_subjects ecs_self, eng_engineering_changes eec
        where   ecs_self.change_id = eec.change_id
        and     ecs_self.entity_name = self_entity_name
        and     ecs_self.pk1_value = self_pk1_value
        and     ecs_self.subject_level = 1

        and    eec.organization_id = -1
        and    eec.status_type = 1
        and    eec.change_mgmt_type_code = findings_category

        and exists ( select change_id from eng_change_subjects ecs_par1
                      where ecs_par1.change_id = ecs_self.change_id
                      and ecs_par1.entity_name = nvl ( parent1_entity_name, self_entity_name )
                      and ecs_par1.pk1_value = nvl ( parent1_pk1_value, self_pk1_value )
                      and ecs_par1.subject_level = decode ( parent1_entity_name, NULL, 1, 2 ) )

        and exists ( select change_id from eng_change_subjects ecs_par2
                      where ecs_par2.change_id = ecs_self.change_id
                      and ecs_par2.entity_name = nvl ( parent2_entity_name, self_entity_name )
                      and ecs_par2.pk1_value = nvl ( parent2_pk1_value, self_pk1_value )
                      and ecs_par2.subject_level = decode ( parent2_entity_name, NULL, 1, 3 ) )

        and exists ( select change_id from eng_change_subjects ecs_par3
                      where ecs_par3.change_id = ecs_self.change_id
                      and ecs_par3.entity_name = nvl ( parent3_entity_name, self_entity_name )
                      and ecs_par3.pk1_value = nvl ( parent3_pk1_value, self_pk1_value )
                      and ecs_par3.subject_level = decode ( parent3_entity_name, NULL, 1, 4 ) )

        and exists ( select change_id from eng_change_subjects ecs_par4
                      where ecs_par4.change_id = ecs_self.change_id
                      and ecs_par4.entity_name = nvl ( parent4_entity_name, self_entity_name )
                      and ecs_par4.pk1_value = nvl ( parent4_pk1_value, self_pk1_value )
                      and ecs_par4.subject_level = decode ( parent4_entity_name, NULL, 1, 5 ) );

        return ofcount;

    end calculate_open_findings;

-------------------------------------------------------------------------
-- Function to decide whether to show create button or not.
-- Returns 1 if ok to show create button, 0 otherwise.
-------------------------------------------------------------------------

    function is_create_enabled
        ( change_category char, org_id number, myprocess_id number )

    return number is

    	respkey varchar2(100);

    begin

    	-- Always show for disclosure committees because function security is in place.

    	if ( change_category = 'AMW_DISC_COMMITTEES' ) then
            return 1;
    	end if;

    	-- Never show for remediation because we are disabling creation of remediation by itself.
    	-- Remediation can be created only from Finding summary page.

        if ( change_category = 'AMW_REMEDIATION' ) then
            return 0;
    	end if;

    	select responsibility_key
    	into respkey
    	from fnd_responsibility_vl
    	where responsibility_id = fnd_global.resp_id()
    	and application_id = fnd_global.resp_appl_id();

    	-- Always show for super user.

    	if ( respkey = 'AMW_SSW_NEW_RESP' ) then
            return 1;
    	end if;

    	-- Findings.

	if ( change_category = 'AMW_PROJ_FINDING' ) and
	   ( fnd_function.test ( 'AMW_CREATE_FINDINGS', 'Y' ) ) then
	    return 1;
	end if;

	-- Correction Requests.

	if ( change_category = 'AMW_CORRECT_REQUESTS' ) and
	   ( fnd_function.test ( 'AMW_CREATE_CORRECTREQ', 'Y' ) ) then
	    return 1;
	end if;

	-- Issues.

	if ( change_category = 'AMW_PROC_CERT_ISSUES' ) and
	   ( fnd_function.test ( 'AMW_CREATE_ISSUES', 'Y' ) ) then
	    return 1;
	end if;

--    	-- Owner based stuff.
--
--    	if ( change_category = 'AMW_PROC_CERT_ISSUES' ) then
--
--            -- Allow to create if current user is the owner of process or manager of org.
--
--            if ( AMW_WF_HIERARCHY_PKG.hasOrgAccess ( fnd_global.user_id(), org_id ) = 1 ) then
--            	return 1;
--            end if;
--
--            select count ( fnd_user.person_party_id )
--            into temp
--            from fnd_user, amw_process_all_vl proc, amw_proc_hierarchy_denorm aphd
--            where (     proc.process_id = myprocess_id
--                    	and proc.process_owner_id = fnd_user.person_party_id
--                    	and fnd_user.user_id = fnd_global.user_id()
--              	  )
--              	  or
--              	  (
--                    	aphd.process_id = myprocess_id
--                   	and aphd.up_down_ind = 'U'
--                    	and aphd.parent_child_id = proc.process_id
--                   	and proc.process_owner_id = fnd_user.person_party_id
--                    	and fnd_user.user_id = fnd_global.user_id()
--              	  );
--
--             if ( temp > 0 ) then
--            	return 1;
--             end if;
--
--    	end if;

    	return 0;

    end is_create_enabled;

end amw_findings_pkg;

/
