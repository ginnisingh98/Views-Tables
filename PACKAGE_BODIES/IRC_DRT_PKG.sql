--------------------------------------------------------
--  DDL for Package Body IRC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_DRT_PKG" as
/* $Header: ircdrtpg.pkb 120.0.12010000.6 2018/05/03 10:56:12 demodak noship $ */
  l_package varchar2(33) DEFAULT 'IRC_DRT_PKG.';

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

  PROCEDURE irc_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'irc_hr_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

  BEGIN

    write_log ('Entering:'|| l_proc,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '|| p_person_id,'20');

		BEGIN

				SELECT  count (*) into l_count
				FROM    per_all_vacancies
				WHERE   status = 'O'
				AND     recruiter_id IN
				        (
				        SELECT  person_id
				        FROM    per_all_people_f
				        WHERE   person_id = p_person_id
				        );

				if l_count <> 0 then

								add_to_results(person_id => p_person_id
															,entity_type => 'HR'
															,status => 'E'
															,msgcode => 'IRC_412707_HR_OPEN_VACANCY'
															,msgaplid => 800
															,result_tbl => result_tbl);

				end if;

		END;

    write_log ('Leaving: '|| l_proc,'80');

  END irc_hr_drc;

  PROCEDURE irc_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'irc_tca_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

  BEGIN

    write_log ('Entering:'|| l_proc,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '|| p_person_id,'20');

    write_log ('Leaving: '|| l_proc,'80');

  END irc_tca_drc;

  PROCEDURE irc_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS

    l_proc varchar2(72) := l_package|| 'irc_fnd_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);

  BEGIN

    write_log ('Entering:'|| l_proc,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '|| p_person_id,'20');

    write_log ('Leaving: '|| l_proc,'80');

  END irc_fnd_drc;


FUNCTION overwrite_recruiter_full_name
  (rid         IN varchar2
  ,table_name  IN varchar2
  ,column_name IN varchar2
  ,person_id   IN number) RETURN varchar2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_recruiter_full_name per_all_people_f.full_name%TYPE;
  p_person_id per_all_people_f.person_id%TYPE;
  l_posting_content_id irc_posting_contents.posting_content_id%TYPE;
  sql_stmt varchar2(2000);
  CURSOR get_posting_contents
    (p_posting_content_id IN irc_posting_contents.posting_content_id%TYPE) IS
    SELECT  1
    FROM    per_all_vacancies
    WHERE   primary_posting_id = p_posting_content_id and recruiter_id = p_person_id;
BEGIN
  p_person_id := person_id;

  IF table_name <> 'IRC_POSTING_CONTENTS' THEN
    RETURN NULL;
  END IF;

  sql_stmt := 'SELECT '
              || 'posting_content_id'
              || ',recruiter_full_name'
              || ' FROM '
              || table_name
              || ' where rowid = :1';

  EXECUTE IMMEDIATE
    sql_stmt
  INTO    l_posting_content_id
         ,l_recruiter_full_name
  USING rid;
   For count in get_posting_contents(l_posting_content_id)
    loop
     l_recruiter_full_name := per_drt_pkg.overwrite_derived_names (rid
                                                          ,table_name
                                                          ,column_name
                                                          ,person_id);
    END loop;
  RETURN (l_recruiter_full_name);
END overwrite_recruiter_full_name;



FUNCTION overwrite_recruiter_email
  (rid         IN varchar2
  ,table_name  IN varchar2
  ,column_name IN varchar2
  ,person_id   IN number) RETURN varchar2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_recruiter_email per_all_people_f.email_address%TYPE;
  p_person_id per_all_people_f.person_id%TYPE;
  l_posting_content_id irc_posting_contents.posting_content_id%TYPE;
  sql_stmt varchar2(2000);
  CURSOR get_posting_contents
    (p_posting_content_id IN irc_posting_contents.posting_content_id%TYPE) IS
    SELECT  1
    FROM    per_all_vacancies
    WHERE   primary_posting_id = p_posting_content_id and recruiter_id = p_person_id;
BEGIN
  p_person_id := person_id;

  IF table_name <> 'IRC_POSTING_CONTENTS' THEN
    RETURN NULL;
  END IF;

  sql_stmt := 'SELECT '
              || 'posting_content_id'
              || ',recruiter_email'
              || ' FROM '
              || table_name
              || ' where rowid = :1';

  EXECUTE IMMEDIATE
    sql_stmt
  INTO    l_posting_content_id
         ,l_recruiter_email
  USING rid;
   For count in get_posting_contents(l_posting_content_id)
    loop
     l_recruiter_email := per_drt_udf.overwrite_email (rid
                                                          ,table_name
                                                          ,column_name
                                                          ,person_id);
    END loop;
  RETURN (l_recruiter_email);
END overwrite_recruiter_email;


FUNCTION overwrite_recruiter_work_phone
  (rid         IN varchar2
  ,table_name  IN varchar2
  ,column_name IN varchar2
  ,person_id   IN number) RETURN varchar2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_recruiter_work_telephone per_all_people_f.work_telephone%TYPE;
  p_person_id per_all_people_f.person_id%TYPE;
  l_posting_content_id irc_posting_contents.posting_content_id%TYPE;
  sql_stmt varchar2(2000);
  CURSOR get_posting_contents
    (p_posting_content_id IN irc_posting_contents.posting_content_id%TYPE) IS
    SELECT  1
    FROM    per_all_vacancies
    WHERE   primary_posting_id = p_posting_content_id and recruiter_id = p_person_id;
BEGIN
  p_person_id := person_id;

  IF table_name <> 'IRC_POSTING_CONTENTS' THEN
    RETURN NULL;
  END IF;

  sql_stmt := 'SELECT '
              || 'posting_content_id'
              || ',recruiter_work_telephone'
              || ' FROM '
              || table_name
              || ' where rowid = :1';

  EXECUTE IMMEDIATE
    sql_stmt
  INTO    l_posting_content_id
         ,l_recruiter_work_telephone
  USING rid;
   For count in get_posting_contents(l_posting_content_id)
    loop
     l_recruiter_work_telephone := per_drt_udf.overwrite_phone (rid
                                                          ,table_name
                                                          ,column_name
                                                          ,person_id);
    END loop;
  RETURN (l_recruiter_work_telephone);
END overwrite_recruiter_work_phone;



FUNCTION overwrite_manager_full_name
  (rid         IN varchar2
  ,table_name  IN varchar2
  ,column_name IN varchar2
  ,person_id   IN number) RETURN varchar2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_manager_full_name per_all_people_f.full_name%TYPE;
  p_person_id per_all_people_f.person_id%TYPE;
  l_posting_content_id irc_posting_contents.posting_content_id%TYPE;
  sql_stmt varchar2(2000);
  CURSOR get_posting_contents
    (p_posting_content_id IN irc_posting_contents.posting_content_id%TYPE) IS
    SELECT  1
    FROM    per_all_vacancies
    WHERE   primary_posting_id = p_posting_content_id and manager_id = p_person_id;
BEGIN
  p_person_id := person_id;

  IF table_name <> 'IRC_POSTING_CONTENTS' THEN
    RETURN NULL;
  END IF;

  sql_stmt := 'SELECT '
              || 'posting_content_id'
              || ',manager_full_name'
              || ' FROM '
              || table_name
              || ' where rowid = :1';

  EXECUTE IMMEDIATE
    sql_stmt
  INTO    l_posting_content_id
         ,l_manager_full_name
  USING rid;
   For count in get_posting_contents(l_posting_content_id)
    loop
     l_manager_full_name := per_drt_pkg.overwrite_derived_names (rid
                                                          ,table_name
                                                          ,column_name
                                                          ,person_id);
    END loop;
  RETURN (l_manager_full_name);
END overwrite_manager_full_name;


FUNCTION overwrite_manager_email
  (rid         IN varchar2
  ,table_name  IN varchar2
  ,column_name IN varchar2
  ,person_id   IN number) RETURN varchar2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_manager_email per_all_people_f.email_address%TYPE;
  p_person_id per_all_people_f.person_id%TYPE;
  l_posting_content_id irc_posting_contents.posting_content_id%TYPE;
  sql_stmt varchar2(2000);
  CURSOR get_posting_contents
    (p_posting_content_id IN irc_posting_contents.posting_content_id%TYPE) IS
    SELECT  1
    FROM    per_all_vacancies
    WHERE   primary_posting_id = p_posting_content_id and manager_id = p_person_id;
BEGIN
  p_person_id := person_id;

  IF table_name <> 'IRC_POSTING_CONTENTS' THEN
    RETURN NULL;
  END IF;

  sql_stmt := 'SELECT '
              || 'posting_content_id'
              || ',manager_email'
              || ' FROM '
              || table_name
              || ' where rowid = :1';

  EXECUTE IMMEDIATE
    sql_stmt
  INTO    l_posting_content_id
         ,l_manager_email
  USING rid;
   For count in get_posting_contents(l_posting_content_id)
    loop
     l_manager_email := per_drt_udf.overwrite_email (rid
                                                          ,table_name
                                                          ,column_name
                                                          ,person_id);
    END loop;
  RETURN (l_manager_email);
END overwrite_manager_email;


FUNCTION overwrite_manager_work_phone
  (rid         IN varchar2
  ,table_name  IN varchar2
  ,column_name IN varchar2
  ,person_id   IN number) RETURN varchar2 IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_manager_work_telephone per_all_people_f.work_telephone%TYPE;
  p_person_id per_all_people_f.person_id%TYPE;
  l_posting_content_id irc_posting_contents.posting_content_id%TYPE;
  sql_stmt varchar2(2000);
  CURSOR get_posting_contents
    (p_posting_content_id IN irc_posting_contents.posting_content_id%TYPE) IS
    SELECT  1
    FROM    per_all_vacancies
    WHERE   primary_posting_id = p_posting_content_id and manager_id = p_person_id;
BEGIN
  p_person_id := person_id;

  IF table_name <> 'IRC_POSTING_CONTENTS' THEN
    RETURN NULL;
  END IF;

  sql_stmt := 'SELECT '
              || 'posting_content_id'
              || ',manager_work_telephone'
              || ' FROM '
              || table_name
              || ' where rowid = :1';

  EXECUTE IMMEDIATE
    sql_stmt
  INTO    l_posting_content_id
         ,l_manager_work_telephone
  USING rid;
   For count in get_posting_contents(l_posting_content_id)
    loop
     l_manager_work_telephone := per_drt_udf.overwrite_phone (rid
                                                          ,table_name
                                                          ,column_name
                                                          ,person_id);
    END loop;
  RETURN (l_manager_work_telephone);
END overwrite_manager_work_phone;


END IRC_DRT_PKG;


/
