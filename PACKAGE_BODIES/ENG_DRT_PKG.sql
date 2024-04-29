--------------------------------------------------------
--  DDL for Package Body ENG_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_DRT_PKG" AS
/* $Header: ENGDRTB.pls 120.0.12010000.11 2019/12/11 11:44:08 dighosha noship $ */

  l_package varchar2(33) DEFAULT 'ENG_DRT_PKG. ';
  --
  --- Implement ENG specific DRC for HR entity type
  --
  PROCEDURE eng_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'eng_hr_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);
  BEGIN
    -- .....
    per_drt_pkg.write_log('Entering:'|| l_proc,'10');
    p_person_id := person_id;
    per_drt_pkg.write_log('p_person_id: '|| p_person_id,'20');

    --
	---- Check DRC MFG-ENG-05
	--
    BEGIN
	l_count := 0;
	    --
		--- Check whether Employee Number exists under ENG_ENG_CHANGES_INTERFACE
		--
		SELECT  1 into l_count
        FROM    ENG_ENG_CHANGES_INTERFACE eeci
		WHERE eeci.employee_number is not null
        AND exists(
					select 1 from per_all_people_f papf
					where papf.employee_number = eeci.employee_number
					and papf.person_id = p_person_id)
		AND     ROWNUM = 1;
		--
		--- If Interface table carries Employee related Information. Should not delete. Raise error.
		--
		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'ENG_DRC_INTF_REQ_EXISTS'
			  ,msgaplid => 703
			  ,result_tbl => result_tbl);
		end if;

	EXCEPTION
	WHEN no_data_found THEN
            NULL; -- --no records found corresponding to this person, check other entities

        WHEN others THEN
            per_drt_pkg.write_log('Exception ' || SQLCODE ||': '|| SQLERRM || ' in ' || l_proc, '30');
    END;
	--
	---- Check DRC MFG-ENG-01
	--
    BEGIN
	l_count := 0;
	    --
		--- Check whether Requestor exists under ENG_ENG_CHANGES_INTERFACE
		--
        SELECT  1 into l_count
        FROM    ENG_ENG_CHANGES_INTERFACE eeci
		WHERE eeci.requestor_user_name is not null
        AND exists(
					select 1 from FND_USER usr
					where usr.user_name = upper(eeci.requestor_user_name)
					and usr.EMPLOYEE_ID = p_person_id)
		AND     ROWNUM = 1;
		--
		--- If Interface table carries requestor information. Should not delete. Raise error.
		--
		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'ENG_DRC_INTF_REQ_EXISTS'
			  ,msgaplid => 703
			  ,result_tbl => result_tbl);
		end if;

	EXCEPTION
	WHEN no_data_found THEN
            NULL; -- --no records found corresponding to this person, check other entities

    WHEN others THEN
            per_drt_pkg.write_log('Exception ' || SQLCODE ||': '|| SQLERRM || ' in ' || l_proc, '30');
    END;
    --
	--- Check DRC MFG-ENG-03
	--
    BEGIN
	l_count := 0;
	    --
		--- Check whether Assignee exists under ENG_ENG_CHANGES_INTERFACE
		--
		SELECT  1 into l_count
        FROM    ENG_ENG_CHANGES_INTERFACE eeci
		WHERE eeci.assignee_name is not null
        AND exists(
					select 1 from FND_USER usr
					where usr.user_name = upper(eeci.assignee_name)
					and usr.EMPLOYEE_ID = p_person_id)
		AND     ROWNUM = 1;
		--
		--- If Interface table carries assignee_name information. Should not delete. Raise error.
		--
		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
 			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'ENG_DRC_INTF_ASGN_EXISTS'
			  ,msgaplid => 703
			  ,result_tbl => result_tbl);
		end if;

	EXCEPTION
	WHEN no_data_found THEN
            NULL; -- --no records found corresponding to this person, check other entities

    WHEN others THEN
            per_drt_pkg.write_log('Exception ' || SQLCODE ||': '|| SQLERRM || ' in ' || l_proc, '30');
    END;
	--
	---- Check DRC MFG-ENG-06
	--
    BEGIN
	l_count := 0;
	    --
		-- Check whether any Open/Released/Scheduled/Draft change order refers person as requestor
		--
        SELECT  1 into l_count
        FROM    ENG_ENGINEERING_CHANGES
        WHERE   requestor_id in(select party_id from
			per_all_people_f where person_id = p_person_id)
		AND		status_type in(1, 4, 7, 13) --(Open, Scheduled, Released, Draft)
		AND     ROWNUM = 1;
		--
		--- If any Open/Released/Scheduled chane orders exist. Raise warning.
		--
		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
  			  ,entity_type => 'HR'
			  ,status => 'W'
			  ,msgcode => 'ENG_DRC_CO_REQ_EXISTS'
			  ,msgaplid => 703
			  ,result_tbl => result_tbl);
		end if;

	EXCEPTION
	WHEN no_data_found THEN
            NULL; -- --no records found corresponding to this person, check other entities

    WHEN others THEN
            per_drt_pkg.write_log('Exception ' || SQLCODE ||': '|| SQLERRM || ' in ' || l_proc, '30');
    END;
    --
	-- Check DRC MFG-ENG-07
	--
    BEGIN
	l_count := 0;
	    --
		-- Check whether any Open/Released/Scheduled/Draft change orders refers person as assignee
		--
        SELECT  1 into l_count
        FROM    ENG_ENGINEERING_CHANGES
        WHERE   assignee_id in(select party_id from
			per_all_people_f where person_id = p_person_id)
		AND		status_type in(1, 4, 7, 13) --(Open, Scheduled, Released, Draft)
		AND     ROWNUM = 1;
		--
		-- If any Open/Released/Scheduled chane orders exist. Raise warning.
		--
		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
 			  ,entity_type => 'HR'
			  ,status => 'W'
			  ,msgcode => 'ENG_DRC_CO_ASGN_EXISTS'
			  ,msgaplid => 703
			  ,result_tbl => result_tbl);
		end if;

	EXCEPTION
	WHEN no_data_found THEN
            NULL; -- --no records found corresponding to this person, check other entities

    WHEN others THEN
            per_drt_pkg.write_log('Exception ' || SQLCODE ||': '|| SQLERRM || ' in ' || l_proc, '30');
    END;
	--
	-- Check DRC MFG-ENG-08
	--
    BEGIN
	l_count := 0;
	    --
		-- Check whether user has any open line assignments ENG_CHANGE_LINES
		--
        SELECT  1 into l_count
        FROM ENG_CHANGE_LINES
		WHERE ASSIGNEE_ID in(select party_id from
			per_all_people_f where person_id = p_person_id)
		AND STATUS_CODE IN (1, 13)  --(Open, Draft)
		AND ROWNUM = 1;
		--
		-- If any active line assignment found, raise Warning
		--
		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
 			  ,entity_type => 'HR'
			  ,status => 'W'
			  ,msgcode => 'ENG_DRC_CHLINE_EXISTS'
			  ,msgaplid => 703
			  ,result_tbl => result_tbl);
		end if;

	EXCEPTION
	WHEN no_data_found THEN
            NULL; -- --no records found corresponding to this person, check other entities

    WHEN others THEN
            per_drt_pkg.write_log('Exception ' || SQLCODE ||': '|| SQLERRM || ' in ' || l_proc, '30');
    END;
	--
	--- Check DRC MFG-ENG-02
	--- Added for Bug 30629350
	--
    BEGIN
	l_count := 0;
	    --
		--- Check whether Assignee exists under ENG_CHANGE_LINES_INTERFACE
		--
		SELECT  1 into l_count
        FROM    ENG_CHANGE_LINES_INTERFACE ecli
		WHERE ecli.ASSIGNEE_NAME is not null
        AND exists(
					select 1 from FND_USER usr
					where usr.user_name = upper(ecli.ASSIGNEE_NAME)
					and usr.EMPLOYEE_ID = p_person_id)
		AND     ROWNUM = 1;
		--
		--- If Interface table carries ASSIGNEE_NAME information. Should not delete. Raise error.
		--
		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
 			  ,entity_type => 'HR'
			  ,status => 'E'
			  ,msgcode => 'ENG_DRC_CO_INTF_ASGN_EXISTS'
			  ,msgaplid => 703
			  ,result_tbl => result_tbl);
		end if;

	EXCEPTION
	WHEN no_data_found THEN
            NULL; -- --no records found corresponding to this person, check other entities

    WHEN others THEN
            per_drt_pkg.write_log('Exception ' || SQLCODE ||': '|| SQLERRM || ' in ' || l_proc, '30');
    END;

    --
    per_drt_pkg.write_log ('Leaving:'|| l_proc,'40');
    -- .....
  END eng_hr_drc;
  -- .....
  --
  --- Implement ENG specific DRC for TCA entity type
  --
  PROCEDURE eng_tca_drc
		(person_id       IN         number
		,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
	l_proc varchar2(72) := l_package|| 'eng_tca_drc';
	p_person_id number(20);
    n number;
    l_temp varchar2(20);
    l_count number;
  BEGIN
    -- ....
    per_drt_pkg.write_log ('Entering:'|| l_proc,'50');
    p_person_id := person_id;
    per_drt_pkg.write_log ('p_person_id: '|| p_person_id,'60');
    --
	--- Check DRC MFG-ENG-04
	--
    BEGIN
	l_count := 0;
	    --
		--- Check whether user has any role assignments in interface table
		--
        SELECT 1 into l_count
		FROM ENG_CHANGE_PEOPLE_INTF
		WHERE GRANTEE_PARTY_ID = p_person_id
		AND ROWNUM = 1;
		--
		---  If any role assignment found, raise Error.
		--
		if l_count <> 0 then
			per_drt_pkg.add_to_results
			  (person_id => p_person_id
 			  ,entity_type => 'TCA'
			  ,status => 'E'
			  ,msgcode => 'ENG_DRC_PPL_INTF_EXISTS'
			  ,msgaplid => 703
			  ,result_tbl => result_tbl);
		end if;

	EXCEPTION
	WHEN no_data_found THEN
            NULL; -- --no records found corresponding to this person, check other entities

    WHEN others THEN
            per_drt_pkg.write_log('Exception ' || SQLCODE ||': '|| SQLERRM || ' in ' || l_proc, '70');
    END;
	per_drt_pkg.write_log ('Leaving:'|| l_proc,'80');
    -- .....
  END eng_tca_drc;
  -- .......
END eng_drt_pkg;

/
