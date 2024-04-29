--------------------------------------------------------
--  DDL for Package Body AME_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_DRT_PKG" AS
/* $Header: amedrtpg.pkb 120.0.12010000.5 2018/04/17 06:39:08 demodak noship $ */
  l_package varchar2(33) DEFAULT 'AME_DRT_PKG.';

  PROCEDURE write_log
    (message       IN         varchar2
		,stage		 IN					varchar2) IS
	begin

				if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
					fnd_log.string(fnd_log.level_procedure,message,stage);
				end if;

	end write_log;

  PROCEDURE add_to_results
    (person_id       IN         number
		,entity_type		 IN					varchar2
		,status 				 IN					varchar2
		,msgcode				 IN					varchar2
		,msgaplid				 IN					number
    ,result_tbl    	 IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS

	n number(15);

	begin

		n := result_tbl.count + 1;

    result_tbl(n).person_id := person_id;

    result_tbl(n).entity_type := entity_type;

    result_tbl(n).status := status;

    result_tbl(n).msgcode := msgcode;

    result_tbl(n).msgaplid := msgaplid;

	end add_to_results;

  PROCEDURE ame_hr_drc
    (person_id       IN         number
     ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'ame_hr_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

  BEGIN

    write_log ('Entering:'|| l_proc,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '|| p_person_id,'20');

		BEGIN
				SELECT  count(*) into l_count
				FROM    fnd_user
				WHERE   user_name IN
				        (
				        SELECT  DISTINCT
				                parameter
				        FROM    ame_approval_group_members
				        WHERE   approval_group_id IN
				                (
				                SELECT  approval_group_id
				                FROM    ame_approval_groups
				                WHERE   is_static = 'Y'
				                )
				        )
				AND     employee_id = p_person_id;

				if l_count <> 0 then

								add_to_results(person_id => p_person_id
															,entity_type => 'HR'
															,status => 'E'
															,msgcode => 'AME_400840_PER_APPROVER_EXISTS'
															,msgaplid => 800
															,result_tbl => result_tbl);

				end if;

		END ;

    write_log ('Leaving: '|| l_proc,'80');

  END ame_hr_drc;

  PROCEDURE ame_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'ame_tca_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

  BEGIN

    write_log ('Entering:'|| l_proc,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '|| p_person_id,'20');

    write_log ('Leaving: '|| l_proc,'80');

  END ame_tca_drc;

  PROCEDURE ame_fnd_drc
    (person_id       IN         number
     ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'ame_fnd_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

  BEGIN

    write_log ('Entering:'|| l_proc,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '|| p_person_id,'20');

		BEGIN
				SELECT  count(*) into l_count
				FROM    ame_approval_group_members
				WHERE   approval_group_id IN
				        (
				        SELECT  approval_group_id
				        FROM    ame_approval_groups
				        WHERE   is_static = 'Y'
				        )
				AND     parameter IN
				        (
				        SELECT  DISTINCT
				                user_name
				        FROM    fnd_user
				        WHERE   user_id = p_person_id
				        );

				if l_count <> 0 then

								add_to_results(person_id => p_person_id
															,entity_type => 'FND'
															,status => 'E'
															,msgcode => 'AME_400841_FND_APPROVER_EXISTS'
															,msgaplid => 800
															,result_tbl => result_tbl);

				end if;

		END ;

    write_log ('Leaving: '|| l_proc,'80');

  END ame_fnd_drc;

END ame_drt_pkg;



/
