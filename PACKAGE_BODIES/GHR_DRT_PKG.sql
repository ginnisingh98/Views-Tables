--------------------------------------------------------
--  DDL for Package Body GHR_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_DRT_PKG" as
/* $Header: ghdrtdrc.pkb 120.0.12010000.4 2018/05/07 10:10:32 poswain noship $ */

l_package   VARCHAR2(32) := 'GHR_DRT_PKG.';

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

 --
-- --------------------------------------------------------------------------------------
--|-----------------------------< GHR_HR_DRC >-------------------------------------------|
-- --------------------------------------------------------------------------------------
-- Description:
-- This procedure checks for the following data removal constraint for HR person type
--
-- DRC: If a future dated RPA exists for an ex-employee, do not remove/mask the records
--      for that person.
-- If this condition satisfies for the given person_id then raise a DRC error.
-- If not, allow the records for that person_id to be processed.
--
-- ---------------------------------------------------------------------------------------
--
PROCEDURE ghr_hr_drc
		  (person_id		 IN	 number
		  ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type
		  )
IS
  --
  -- Declare cursors and local variables
  --
    l_proc varchar2(72) := l_package|| 'ghr_hr_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

BEGIN

    write_log ('Entering:'
                               || l_proc
                              ,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '
                             || p_person_id
                            ,'20');
  --
	--Check if the p_person_id passed is a valid HR Person or not.
    /* SELECT DISTINCT p.person_id INTO p_person_id FROM per_all_people_f p
    WHERE p.person_id = person_id;*/

   -- Check whether the person is a ex-employee and having any future dated RPA.
	BEGIN
					SELECT  count(*) into l_count
					FROM    per_all_people_f per
						   ,per_person_types ppt
						   ,ghr_pa_requests ghr
					WHERE   per.person_id = p_person_id
					AND     per.person_id = ghr.person_id
					AND     ghr.pa_notification_id IS NULL
					AND     ghr.effective_date >=sysdate
					AND     (
									sysdate BETWEEN per.effective_start_date
											AND     per.effective_end_date
							)
					AND     per.person_type_id = ppt.person_type_id
					AND     ppt.system_person_type = 'EX_EMP';

				if l_count <> 0 then

								add_to_results(person_id => p_person_id
															,entity_type => 'HR'
															,status => 'E'
															,msgcode => 'GHR_37762_FUTURE_RPA_EXISTS'
															,msgaplid => 8301
															,result_tbl => result_tbl);

				end if;

  END;

	hr_utility.set_location('Leaving: '||l_proc, 80);

 END ghr_hr_drc ;


--
-- --------------------------------------------------------------------------------------
--|-----------------------------< GHR_FND_DRC >-------------------------------------------|
-- --------------------------------------------------------------------------------------
-- Description:
-- This procedure checks for the following data removal constraint for FND person type
--
-- DRC: If a future dated RPA exists for an ex-employee, do not remove/mask the records
--      for that person.
-- If this condition satisfies for the given person_id then raise a DRC error.
-- If not, allow the records for that person_id to be processed.
--
-- ---------------------------------------------------------------------------------------
--
  PROCEDURE ghr_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'ghr_fnd_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

  BEGIN

    write_log ('Entering:'|| l_proc,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '|| p_person_id,'20');

		/* GHR does not use FND User ID anywhere so no DRC rules */

    write_log ('Leaving: '|| l_proc,'80');

  END ghr_fnd_drc;

 --
-- ---------------------------------------------------------------------------
-- |---------------------------< OVERWRITE_DATE>-----------------------------|
-- ---------------------------------------------------------------------------
-- Description:
--  This user-defined function overwrites DATE type PII data present in the
--  columns.
--
-- ---------------------------------------------------------------------------
--
 FUNCTION overwrite_date
			(rid         IN ROWID
			,table_name  IN VARCHAR2
			,column_name IN VARCHAR2
			,person_id   IN NUMBER)

	RETURN VARCHAR2
	IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_sql VARCHAR2(1000);
    l_overwritten_value DATE DEFAULT '';
    l_date DATE;

  BEGIN
    l_sql := 'select '
             || column_name
             || ' from '
             || table_name
             || ' where rowid = :rid';

    EXECUTE IMMEDIATE
      l_sql
    INTO    l_date
    USING rid;

    l_overwritten_value := l_date - TRUNC (dbms_random.value (1
                                                             ,365));

    RETURN (l_overwritten_value);

  END overwrite_date;

END;

/
