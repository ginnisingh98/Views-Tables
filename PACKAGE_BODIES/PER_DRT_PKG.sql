--------------------------------------------------------
--  DDL for Package Body PER_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRT_PKG" AS
/* $Header: pedrtpkg.pkb 120.0.12010000.18 2020/01/21 05:41:44 ktithy noship $ */

  l_package varchar2(33) DEFAULT 'PER_DRT_PKG. ';

PROCEDURE write_log
  (message IN varchar2
  ,stage   IN varchar2) IS
BEGIN
  IF fnd_log.g_current_runtime_level <= fnd_log.level_procedure THEN
    fnd_log.string (fnd_log.level_procedure
                   ,message
                   ,stage);
  END IF;
END write_log;

PROCEDURE add_to_results
  (person_id   IN            number
  ,entity_type IN            varchar2
  ,status      IN            varchar2
  ,msgcode     IN            varchar2
  ,msgaplid    IN            number
  ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS
  n number(15);
BEGIN
  n := result_tbl.count + 1;

  result_tbl (n).person_id := person_id;

  result_tbl (n).entity_type := entity_type;

  result_tbl (n).status := status;

  result_tbl (n).msgcode := msgcode;

  result_tbl (n).msgaplid := msgaplid;
END add_to_results;

  PROCEDURE per_hr_drc
    (person_id  IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    l_proc varchar2(72) DEFAULT l_package
                                || 'per_hr_drc';
    p_person_id number(20);
    l_count number;
    l_temp varchar2(20);
	l_bg per_business_groups.business_group_id%type default null;
  BEGIN
    write_log ('Entering:'
               || l_proc
              ,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '
               || p_person_id
              ,'20');

-- added for bug#29680657 (ex-emp international bg) start
    BEGIN
			SELECT fnd_profile.value ('PER_EX_EMP_BUSINESS_GROUP') INTO l_bg FROM dual;
			IF l_bg IS NOT NULL THEN
					SELECT  count(*)
					INTO    l_count
					FROM    per_all_people_f papf
					WHERE   papf.business_group_id = l_bg
					AND     upper (papf.email_address) =
					                                     (
					                                     SELECT  upper (email_address)
					                                     FROM    per_all_people_f ppf
					                                            ,per_person_type_usages_f ppuf
					                                            ,per_person_types ppt
					                                     WHERE   ppf.person_id = ppuf.person_id
					                                     AND     sysdate BETWEEN ppf.effective_start_date
					                                                     AND     ppf.effective_end_date
					                                     AND     ppuf.person_type_id = ppt.person_type_id
					                                     AND     sysdate BETWEEN ppuf.effective_start_date
					                                                     AND     ppuf.effective_end_date
					                                     AND     ppt.system_person_type IN ('EX_EMP','EX_EMP_APL')
					                                     AND     ppt.active_flag = 'Y'
					                                     AND     ppf.person_id = p_person_id
					                                     );
			END IF;
      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500084_EX_EMP_INT_BG'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;
-- added for bug#29680657 (ex-emp international bg) end

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_periods_of_service
      WHERE   person_id = p_person_id
      AND     nvl (final_process_date
                  ,to_date ('31-12-4712'
                           ,'DD-MM-YYYY')) > trunc (sysdate) and rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500062_EMP_PDS_EXST'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_all_assignments_f
      WHERE   person_id = p_person_id
      AND     assignment_type = 'B'
      AND     nvl (effective_end_date
                  ,to_date ('31-12-4712'
                           ,'DD-MM-YYYY')) > trunc (sysdate) and rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500063_BEN_ASSG_EXISTS'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_periods_of_placement
      WHERE   person_id = p_person_id
      AND     nvl (final_process_date
                  ,to_date ('31-12-4712'
                           ,'DD-MM-YYYY')) > trunc (sysdate) and rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500062_EMP_PDS_EXST'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_periods_of_service pps
							,hr_organization_information hoi
      WHERE   pps.person_id = p_person_id
      AND hoi.organization_id(+) = pps.business_group_id
      AND hoi.ORG_INFORMATION_CONTEXT(+) = 'DATA_REMOVAL_TOOL'
      AND     (months_between (trunc (sysdate),nvl (pps.actual_termination_date
                                         ,trunc (sysdate)))) < nvl(nvl(hoi.ORG_INFORMATION1,to_number(fnd_profile.value ('HR_RECORD_RETENTION_PERIOD'))),12000)
			AND nvl(pps.pds_information29,'N') = 'N'
			AND rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500064_EMP_RTNTN_PRD'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_periods_of_placement ppp
							,hr_organization_information hoi
      WHERE   ppp.person_id = p_person_id
      AND hoi.organization_id(+) = ppp.business_group_id
      AND hoi.ORG_INFORMATION_CONTEXT(+) = 'DATA_REMOVAL_TOOL'
      AND     (months_between (trunc (sysdate),nvl (ppp.actual_termination_date
                                         ,trunc (sysdate)))) < nvl(nvl(hoi.ORG_INFORMATION1,to_number(fnd_profile.value ('HR_RECORD_RETENTION_PERIOD'))),12000)
			AND nvl(ppp.information29,'N') = 'N'
			AND rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500064_EMP_RTNTN_PRD'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_contact_relationships
      WHERE   contact_person_id = p_person_id
      AND     nvl (date_end
                  ,to_date ('31-12-4712'
                           ,'DD-MM-YYYY')) > trunc (sysdate) and rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500065_CNTCT_REL_EXTS'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

-- For Bug#29812760
    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_contact_relationships
      WHERE   person_id = p_person_id
      AND     nvl (date_end
                  ,to_date ('31-12-4712'
                           ,'DD-MM-YYYY')) > trunc (sysdate) and rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'W'
                        ,msgcode     => 'PER_500081_CNTCT_REL_EXTS'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_periods_of_service
      WHERE   person_id = p_person_id
      AND     final_process_date IS NOT NULL
      AND     pds_information30 = 'Y' and rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500066_EMP_ERSR_CNSNT'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_periods_of_placement
      WHERE   person_id = p_person_id
      AND     final_process_date IS NOT NULL
      AND     information30 = 'Y' and rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'E'
                        ,msgcode     => 'PER_500066_EMP_ERSR_CNSNT'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    BEGIN
      SELECT  count (*)
      INTO    l_count
      FROM    per_applications
      WHERE   person_id = p_person_id
      AND     nvl (date_end
                  ,to_date ('31-12-4712'
                           ,'DD-MM-YYYY')) > trunc (sysdate) and rownum = 1;

      IF l_count <> 0 THEN
        add_to_results
                        (person_id   => p_person_id
                        ,entity_type => 'HR'
                        ,status      => 'W'
                        ,msgcode     => 'PER_500067_APP_PRESENT'
                        ,msgaplid    => 800
                        ,result_tbl  => result_tbl );
      END IF;
    END;

    write_log ('Leaving:'
               || l_proc
              ,'999');
  END per_hr_drc;

  PROCEDURE per_tca_drc
    (person_id  IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    l_proc varchar2(72) DEFAULT l_package
                                || 'per_tca_drc';
    p_person_id number(20);
    n number;
    l_temp varchar2(20);
  BEGIN
    write_log ('Entering:'
               || l_proc
              ,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '
               || p_person_id
              ,'20');

    IF result_tbl.count < 1 THEN
      add_to_results
                      (person_id   => p_person_id
                      ,entity_type => 'TCA'
                      ,status      => 'S'
                      ,msgcode     => 'PER_NO_PARTY_RULES'
                      ,msgaplid    => 800
                      ,result_tbl  => result_tbl );
    END IF;

    write_log ('Leaving: '
               || l_proc
              ,'80');
  END per_tca_drc;

  PROCEDURE per_fnd_drc
    (person_id  IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS
    l_proc varchar2(72) DEFAULT l_package
                                || 'per_fnd_drc';
    p_person_id number(20);
    n number;
    l_temp varchar2(20);
  BEGIN
    write_log ('Entering:'
               || l_proc
              ,'10');

    p_person_id := person_id;

    write_log ('p_person_id: '
               || p_person_id
              ,'20');

    IF result_tbl.count < 1 THEN
      add_to_results
                      (person_id   => p_person_id
                      ,entity_type => 'FND'
                      ,status      => 'S'
                      ,msgcode     => 'PER_NO_FND_RULES'
                      ,msgaplid    => 800
                      ,result_tbl  => result_tbl );
    END IF;

    write_log ('Leaving: '
               || l_proc
              ,'80');
  END per_fnd_drc;

  FUNCTION overwrite_derived_names
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    p_person_id number;
    l_overwritten_value varchar2(240) DEFAULT '';
    l_column_name varchar2(50);
    l_full_name varchar2(240);
    l_order_name varchar2(240);
    l_global_name varchar2(240);
    l_local_name varchar2(240);
    CURSOR get_person_details IS
      SELECT  business_group_id
             ,nvl2(FIRST_NAME,per_drt_udf.overwrite_name(ROWID,'PER_ALL_PEOPLE_F','FIRST_NAME',person_id),FIRST_NAME) FIRST_NAME
             ,nvl2(MIDDLE_NAMES,per_drt_udf.overwrite_name(ROWID,'PER_ALL_PEOPLE_F','MIDDLE_NAMES',person_id),MIDDLE_NAMES) middle_names
             ,nvl2(LAST_NAME,per_drt_udf.overwrite_name(ROWID,'PER_ALL_PEOPLE_F','LAST_NAME',person_id),LAST_NAME) last_name
             ,nvl2(KNOWN_AS,per_drt_udf.overwrite_name(ROWID,'PER_ALL_PEOPLE_F','KNOWN_AS',person_id),KNOWN_AS) known_as
             ,title
             ,NULL suffix
             ,nvl2(PRE_NAME_ADJUNCT,per_drt_udf.overwrite_name(ROWID,'PER_ALL_PEOPLE_F','PRE_NAME_ADJUNCT',person_id),PRE_NAME_ADJUNCT) pre_name_adjunct
             ,date_of_birth
      FROM    per_all_people_f
      WHERE   person_id = p_person_id
      AND     rownum = 1;
  BEGIN
    p_person_id := person_id;

    l_column_name := upper (column_name);

    FOR i IN get_person_details LOOP
      hr_person_name.derive_person_names
                                          (p_format_name       => NULL
                                          ,p_business_group_id => i.business_group_id
                                          ,p_first_name        => i.first_name
                                          ,p_middle_names      => i.middle_names
                                          ,p_last_name         => i.last_name
                                          ,p_known_as          => i.known_as
                                          ,p_title             => i.title
                                          ,p_suffix            => i.suffix
                                          ,p_pre_name_adjunct  => i.pre_name_adjunct
                                          ,p_date_of_birth     => i.date_of_birth
                                          ,p_full_name         => l_full_name
                                          ,p_order_name        => l_order_name
                                          ,p_global_name       => l_global_name
                                          ,p_local_name        => l_local_name );
    END LOOP;

    IF (l_column_name = 'ORDER_NAME') THEN
      l_overwritten_value := l_order_name;
    ELSIF (l_column_name = 'GLOBAL_NAME') THEN
      l_overwritten_value := l_global_name;
    ELSIF (l_column_name = 'LOCAL_NAME') THEN
      l_overwritten_value := l_local_name;
    ELSE
      l_overwritten_value := l_full_name;
    END IF;

    RETURN (l_overwritten_value);
  END overwrite_derived_names;

  FUNCTION overwrite_gender
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    l_random_value number;
    l_overwritten_value varchar2(1) DEFAULT '';
  BEGIN
    l_random_value := trunc (dbms_random.value (1,3));
    ---
    IF l_random_value = 1 THEN
      l_overwritten_value := 'M';
    ELSE
      l_overwritten_value := 'F';
    END IF;
    ---
    RETURN (l_overwritten_value);
  END overwrite_gender;

  FUNCTION overwrite_title
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,p_person_id   IN number) RETURN varchar2
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
    l_sex per_all_people_f.sex%type;
    l_random_value number ;
    x varchar2(7) DEFAULT NULL ;
    y varchar2(7) DEFAULT NULL ;
  BEGIN
    l_random_value := trunc (dbms_random.value (1,5)) ;
    --
    -- Retrive current value of gender modified in phase 1
    --
    select sex into l_sex
      from per_all_people_f where rid=rowid;
    if l_random_value = 1 then
       if l_sex = 'M' then
          x := 'MR.' ;
       else
          x := 'MISS' ;
       end if;
    elsif l_random_value = 2 then
       if l_sex = 'M' then
          x := 'HU_PROF' ;
       else
          x := 'MS.' ;
       end if;
    elsif l_random_value = 3 then
       if l_sex='M' then
          x := 'DR.' ;
       else
          x := 'HU_PROF' ;
       end if;
    else
       if l_sex = 'F' then
          x := 'MRS.' ;
       else
          x := 'HU_PROF' ;
       end if;
    end if;
    ---
    return x;
  END overwrite_title;


  FUNCTION overwrite_nationality
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    l_overwritten_value varchar2(30) DEFAULT '';
  BEGIN
    SELECT  lookup_code
    INTO    l_overwritten_value
    FROM    (
            SELECT  hl.lookup_code
            FROM    hr_lookups hl
            WHERE   hl.lookup_type = 'NATIONALITY'
            AND     hl.enabled_flag = 'Y'
            AND     sysdate BETWEEN nvl (hl.start_date_active
                                        ,sysdate)
                            AND     nvl (end_date_active
                                        ,sysdate)
            ORDER BY dbms_random.value
            )
    WHERE   rownum < 2;

    RETURN (l_overwritten_value);
  END overwrite_nationality;

  FUNCTION overwrite_date
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN DATE IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_sql varchar2(1000);
    l_overwritten_value date DEFAULT '';
    l_date date;
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

    l_overwritten_value := l_date - trunc (dbms_random.value (1
                                                             ,365));

    RETURN (l_overwritten_value);
  END overwrite_date;

 FUNCTION check_tables_uniqueness
    (p_table_name        IN varchar2
    ,p_table_phase       IN number
    ,p_record_identifier IN varchar2) RETURN varchar2 IS
    l_temp varchar2(10);
    l_record_identifier varchar2(4000);
  BEGIN
    l_record_identifier := replace (p_record_identifier
                                   ,fnd_global.local_chr(32)
                                   ,'');

    WHILE instr (l_record_identifier
          ,'<:person_id>') <> 0 LOOP
      l_record_identifier := substr (l_record_identifier
                                    ,1
                                    ,instr (l_record_identifier
                                           ,'<:person_id>') - 1)
                             || '<person_id>'
                             || substr (l_record_identifier
                                       ,instr ('asd = <:person_id> and asd in (1,2)'
                                              ,'<:person_id>') + 12
                                       ,length (l_record_identifier));
    END LOOP;

    SELECT  NULL
    INTO    l_temp
    FROM    dual
    WHERE   EXISTS
            (
            SELECT  NULL
            FROM    per_drt_tables
            WHERE   table_name = upper (p_table_name)
            AND     table_phase = p_table_phase
            AND     replace (record_identifier,fnd_global.local_chr(32),'') = l_record_identifier
            );

    RETURN 'N';
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'Y';
  END check_tables_uniqueness;

  FUNCTION check_columns_uniqueness
    (p_table_id       IN number
    ,p_column_name    IN varchar2) RETURN varchar2 IS
    l_temp varchar2(10);
  BEGIN
    SELECT  NULL
    INTO    l_temp
    FROM    dual
    WHERE   EXISTS
            (
            SELECT  NULL
            FROM    per_drt_columns
            WHERE   table_id = p_table_id
            AND     column_name = upper (p_column_name)
            );

    RETURN 'N';
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'Y';
  END check_columns_uniqueness;

  FUNCTION check_contexts_uniqueness
    (p_column_id      IN number
    ,p_flexfield_name IN varchar2
    ,p_context_name   IN varchar2) RETURN varchar2 IS
    l_temp varchar2(10);
  BEGIN
    SELECT  NULL
    INTO    l_temp
    FROM    dual
    WHERE   EXISTS
            (
            SELECT  NULL
            FROM    per_drt_col_contexts
            WHERE   column_id = p_column_id
            AND     ff_name = p_flexfield_name
            AND     context_name = p_context_name
            );

    RETURN 'N';
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'Y';
  END check_contexts_uniqueness;

	procedure sync_gender_title(rid         IN rowid
	    ,p_person_id   IN number) is

	    l_sex per_all_people_f.sex%type;
	    l_random_value number ;
	    x varchar2(7) DEFAULT NULL ;

	begin
	    l_random_value := trunc (dbms_random.value (1,5)) ;
	    --
	    -- Retrive current value of gender modified in phase 1
	    --
	    select sex into l_sex
	      from per_all_people_f where rid=rowid;
	    if l_random_value = 1 then
	       if l_sex = 'M' then
	          x := 'MR.' ;
	       else
	          x := 'MISS' ;
	       end if;
	    elsif l_random_value = 2 then
	       if l_sex = 'M' then
	          x := 'HU_PROF' ;
	       else
	          x := 'MS.' ;
	       end if;
	    elsif l_random_value = 3 then
	       if l_sex='M' then
	          x := 'DR.' ;
	       else
	          x := 'HU_PROF' ;
	       end if;
	    else
	       if l_sex = 'F' then
	          x := 'MRS.' ;
	       else
	          x := 'HU_PROF' ;
	       end if;
	    end if;

	    update per_all_people_f set title = x where rowid = rid;

	end sync_gender_title;

   /*Start of post process for per for entity hr*/

	PROCEDURE per_hr_post
	  (person_id IN number) IS
	  l_error_code varchar2(1000) DEFAULT NULL;
	  l_sql varchar2(1000) DEFAULT NULL;
	  l_status varchar2(1000) DEFAULT NULL;
	  l_delete_document_exception EXCEPTION;

	cursor c_person(p_person_id number) is select rowid,person_id from per_all_people_f where person_id = p_person_id;

	BEGIN

	for c_rec in c_person(person_id) loop
			sync_gender_title(c_rec.rowid,c_rec.person_id);
	end loop;


	  BEGIN
	    l_sql := 'DELETE FROM PER_PERSON_DIRECTORY_TL WHERE PERSON_ID = :1';

	    EXECUTE IMMEDIATE
	      l_sql
	    USING person_id;
	  EXCEPTION
	    WHEN others THEN
	      l_error_code := sqlcode;

	      IF (l_error_code = '-942') THEN
	        NULL;
	      ELSE
	        RAISE;
	      END IF;
	  END;

	  BEGIN
	    l_sql := 'DELETE FROM PER_PERSON_DIRECTORY WHERE PERSON_ID = :1';

	    EXECUTE IMMEDIATE
	      l_sql
	    USING person_id;
	  EXCEPTION
	    WHEN others THEN
	      l_error_code := sqlcode;

	      IF (l_error_code = '-942') THEN
	        NULL;
	      ELSE
	        RAISE;
	      END IF;
	  END;

	  BEGIN
	    l_sql := 'DELETE FROM PER_MOB_ABS_ATTENDANCE_DTLS WHERE PERSON_ID = :1';

	    EXECUTE IMMEDIATE
	      l_sql
	    USING person_id;
	  EXCEPTION
	    WHEN others THEN
	      l_error_code := sqlcode;

	      IF (l_error_code = '-942') THEN
	        NULL;
	      ELSE
	        RAISE;
	      END IF;
	  END;

	  handle_attachments_prc
	                          (p_in_person_id => person_id
	                          ,status         => l_status );

          per_drt_pkg.handle_role_data( p_in_person_id => person_id,p_in_orig_system => 'PER_ROLE');
          per_drt_pkg.handle_role_data( p_in_person_id => person_id,p_in_orig_system => 'PER');

	  IF (l_status <> 'success') THEN
	    RAISE l_delete_document_exception;
	  END IF;
	EXCEPTION
	  WHEN others THEN
	    RAISE;
	END per_hr_post;

	PROCEDURE handle_attachments_prc
	  (p_in_person_id IN  number
	  ,status         OUT NOCOPY varchar2) IS
	  TYPE attach_rec IS RECORD (entity_name  varchar2(40)
	                            ,pk1_value    varchar2(100)
	                            ,pk2_value    varchar2(100)
	                            ,pk3_value    varchar2(100)
	                            ,pk4_value    varchar2(100)
	                            ,pk5_value    varchar2(100));
	  l_attach_dtls_tbl_rec attach_rec;
	  TYPE attach_dtls_tbl IS TABLE OF l_attach_dtls_tbl_rec%TYPE INDEX BY pls_integer;
	  l_attach_dtls_tbl_ret attach_dtls_tbl;

	  FUNCTION return_attach_dtls
	    (p_in_person_id IN number) RETURN attach_dtls_tbl IS
	    l_person_id number;
	    CURSOR cur_txn
	      (p_in_txn_ref_table IN varchar2
	      ,p_in_entity_name   IN varchar2) IS
	      SELECT  transaction_id
	             ,transaction_ref_id
	      FROM    hr_api_transactions hat
	      WHERE   nvl (selected_person_id
	                  ,- 1) = l_person_id
	      AND     transaction_ref_table = nvl (p_in_txn_ref_table
	                                          ,transaction_ref_table)
	      AND     status IN ('Y','E')
	      AND     EXISTS
	              (
	              SELECT  NULL
	              FROM    fnd_attached_documents
	              WHERE   entity_name = p_in_entity_name
	              AND     pk1_value = decode (p_in_entity_name
	                                         ,'PER_ABSENCE_ATTENDANCES'
	                                         ,to_char (hat.transaction_ref_id
	                                                   || '_'
	                                                   || hat.transaction_id)
	                                         ,to_char (hat.transaction_id))
	              );
	    CURSOR cur_txn_dor
	      (p_in_txn_ref_table IN varchar2
	      ,p_in_entity_name   IN varchar2) IS
	      SELECT  transaction_id
	             ,transaction_ref_id
	      FROM    hr_api_transactions hat
	      WHERE   nvl (selected_person_id
	                  ,- 1) = l_person_id
	      AND     transaction_ref_table = nvl (p_in_txn_ref_table
	                                          ,transaction_ref_table)
	      AND     status IN ('Y','E')
	      AND     EXISTS
	              (
	              SELECT  NULL
	              FROM    fnd_attached_documents
	              WHERE   entity_name = p_in_entity_name
	              AND     p_in_entity_name = 'R_DOCUMENT_EXTRA_INFO'
	              AND     pk1_value = to_char (hat.transaction_id)
	              )
	      UNION
	      SELECT  hatv1.number_value transaction_id
	             ,NULL transaction_ref_id
	      FROM    hr_api_transaction_values hatv1
	             ,hr_api_transaction_steps hats
	             ,hr_api_transactions hat
	      WHERE   hatv1.name = 'P_DOCUMENT_EXTRA_INFO_ID'
	      AND     hatv1.transaction_step_id = hats.transaction_step_id
	      AND     hats.transaction_id = hat.transaction_id
	      AND     transaction_ref_table = nvl (p_in_txn_ref_table
	                                          ,transaction_ref_table)
	      AND     nvl (selected_person_id
	                  ,- 1) = l_person_id
	      AND     status IN ('Y','E')
	      AND     EXISTS
	              (
	              SELECT  NULL
	              FROM    fnd_attached_documents
	              WHERE   entity_name = p_in_entity_name
	              AND     p_in_entity_name = 'R_DOCUMENT_EXTRA_INFO'
	              AND     pk1_value = to_char (hat.transaction_id)
	              );
	    CURSOR cur_abs IS
	      SELECT  absence_attendance_id
	      FROM    per_absence_attendances paa
	      WHERE   person_id = l_person_id
	      AND     EXISTS
	              (
	              SELECT  NULL
	              FROM    fnd_attached_documents
	              WHERE   entity_name = 'PER_ABSENCE_ATTENDANCES'
	              AND     pk1_value = to_char (paa.absence_attendance_id)
	              );
	    CURSOR cur_events IS
	      SELECT  event_id
	      FROM    per_events pe
	      WHERE   internal_contact_person_id = l_person_id
	      AND     EXISTS
	              (
	              SELECT  NULL
	              FROM    fnd_attached_documents
	              WHERE   entity_name = 'PER_EVENTS'
	              AND     pk1_value = to_char (pe.event_id)
	              );
	    CURSOR cur_dor IS
	      SELECT  document_extra_info_id
	      FROM    hr_document_extra_info hdei
	      WHERE   person_id = l_person_id
	      AND     EXISTS
	              (
	              SELECT  NULL
	              FROM    fnd_attached_documents
	              WHERE   entity_name = 'R_DOCUMENT_EXTRA_INFO'
	              AND     pk1_value = to_char (hdei.document_extra_info_id)
	              );
	    l_attach_dtls_tbl_rec attach_rec;
	    l_attach_dtls_tbl attach_dtls_tbl;
	  BEGIN
	    l_person_id := p_in_person_id;

	    FOR csr_pointer IN cur_abs LOOP
	      l_attach_dtls_tbl_rec := NULL;

	      l_attach_dtls_tbl_rec.entity_name := 'PER_ABSENCE_ATTENDANCES';

	      l_attach_dtls_tbl_rec.pk1_value := csr_pointer.absence_attendance_id;

	      l_attach_dtls_tbl_rec.pk2_value := NULL;

	      l_attach_dtls_tbl_rec.pk3_value := NULL;

	      l_attach_dtls_tbl_rec.pk4_value := NULL;

	      l_attach_dtls_tbl_rec.pk5_value := NULL;

	      IF (l_attach_dtls_tbl_rec.pk1_value IS NOT NULL) THEN
	        l_attach_dtls_tbl (l_attach_dtls_tbl.count () + 1) := l_attach_dtls_tbl_rec;
	      END IF;
	    END LOOP;

	    FOR csr_pointer IN cur_txn ('PER_ABSENCE_ATTENDANCES'
	                               ,'PER_ABSENCE_ATTENDANCES') LOOP
	      l_attach_dtls_tbl_rec := NULL;

	      l_attach_dtls_tbl_rec.entity_name := 'PER_ABSENCE_ATTENDANCES';

	      l_attach_dtls_tbl_rec.pk1_value := csr_pointer.transaction_ref_id
	                                         || '_'
	                                         || csr_pointer.transaction_id;

	      l_attach_dtls_tbl_rec.pk2_value := NULL;

	      l_attach_dtls_tbl_rec.pk3_value := NULL;

	      l_attach_dtls_tbl_rec.pk4_value := NULL;

	      l_attach_dtls_tbl_rec.pk5_value := NULL;

	      IF (l_attach_dtls_tbl_rec.pk1_value IS NOT NULL) THEN
	        l_attach_dtls_tbl (l_attach_dtls_tbl.count () + 1) := l_attach_dtls_tbl_rec;
	      END IF;
	    END LOOP;

	    FOR csr_pointer IN cur_dor LOOP
	      l_attach_dtls_tbl_rec := NULL;

	      l_attach_dtls_tbl_rec.entity_name := 'R_DOCUMENT_EXTRA_INFO';

	      l_attach_dtls_tbl_rec.pk1_value := csr_pointer.document_extra_info_id;

	      l_attach_dtls_tbl_rec.pk2_value := NULL;

	      l_attach_dtls_tbl_rec.pk3_value := NULL;

	      l_attach_dtls_tbl_rec.pk4_value := NULL;

	      l_attach_dtls_tbl_rec.pk5_value := NULL;

	      IF (l_attach_dtls_tbl_rec.pk1_value IS NOT NULL) THEN
	        l_attach_dtls_tbl (l_attach_dtls_tbl.count () + 1) := l_attach_dtls_tbl_rec;
	      END IF;
	    END LOOP;

	    FOR csr_pointer IN cur_txn_dor ('HR_DOCUMENT_EXTRA_INFO'
	                                   ,'R_DOCUMENT_EXTRA_INFO') LOOP
	      l_attach_dtls_tbl_rec := NULL;

	      l_attach_dtls_tbl_rec.entity_name := 'R_DOCUMENT_EXTRA_INFO';

	      l_attach_dtls_tbl_rec.pk1_value := csr_pointer.transaction_id;

	      l_attach_dtls_tbl_rec.pk2_value := NULL;

	      l_attach_dtls_tbl_rec.pk3_value := NULL;

	      l_attach_dtls_tbl_rec.pk4_value := NULL;

	      l_attach_dtls_tbl_rec.pk5_value := NULL;

	      IF (l_attach_dtls_tbl_rec.pk1_value IS NOT NULL) THEN
	        l_attach_dtls_tbl (l_attach_dtls_tbl.count () + 1) := l_attach_dtls_tbl_rec;
	      END IF;
	    END LOOP;

	    FOR csr_pointer IN cur_events LOOP
	      l_attach_dtls_tbl_rec := NULL;

	      l_attach_dtls_tbl_rec.entity_name := 'PER_EVENTS';

	      l_attach_dtls_tbl_rec.pk1_value := csr_pointer.event_id;

	      l_attach_dtls_tbl_rec.pk2_value := NULL;

	      l_attach_dtls_tbl_rec.pk3_value := NULL;

	      l_attach_dtls_tbl_rec.pk4_value := NULL;

	      l_attach_dtls_tbl_rec.pk5_value := NULL;

	      IF (l_attach_dtls_tbl_rec.pk1_value IS NOT NULL) THEN
	        l_attach_dtls_tbl (l_attach_dtls_tbl.count () + 1) := l_attach_dtls_tbl_rec;
	      END IF;
	    END LOOP;

	    FOR csr_pointer IN cur_txn (NULL
	                               ,'PQH_SS_ATTACHMENT') LOOP
	      l_attach_dtls_tbl_rec := NULL;

	      l_attach_dtls_tbl_rec.entity_name := 'PQH_SS_ATTACHMENT';

	      l_attach_dtls_tbl_rec.pk1_value := csr_pointer.transaction_id;

	      l_attach_dtls_tbl_rec.pk2_value := NULL;

	      l_attach_dtls_tbl_rec.pk3_value := NULL;

	      l_attach_dtls_tbl_rec.pk4_value := NULL;

	      l_attach_dtls_tbl_rec.pk5_value := NULL;

	      IF (l_attach_dtls_tbl_rec.pk1_value IS NOT NULL) THEN
	        l_attach_dtls_tbl (l_attach_dtls_tbl.count () + 1) := l_attach_dtls_tbl_rec;
	      END IF;
	    END LOOP;

	    RETURN l_attach_dtls_tbl;
	  EXCEPTION
	    WHEN others THEN
	      RETURN l_attach_dtls_tbl;
	  END return_attach_dtls;

	BEGIN
	  l_attach_dtls_tbl_ret := return_attach_dtls (p_in_person_id);

	  IF (l_attach_dtls_tbl_ret.count () > 0) THEN
	    FOR i IN l_attach_dtls_tbl_ret.first .. l_attach_dtls_tbl_ret.last LOOP
	      delete_attachments
	                          (p_in_entity_name => l_attach_dtls_tbl_ret (i).entity_name
	                          ,p_in_pk1_value   => l_attach_dtls_tbl_ret (i).pk1_value );
	    END LOOP;
	  END IF;

	  status := 'success';
	EXCEPTION
	  WHEN others THEN
	    status := sqlerrm;
	END handle_attachments_prc;


	PROCEDURE delete_attachments
	  (p_in_entity_name IN varchar2
	  ,p_in_pk1_value   IN varchar2
	  ,p_in_pk2_value   IN varchar2 DEFAULT NULL
	  ,p_in_pk3_value   IN varchar2 DEFAULT NULL
	  ,p_in_pk4_value   IN varchar2 DEFAULT NULL
	  ,p_in_pk5_value   IN varchar2 DEFAULT NULL) IS
	  CURSOR csr_attached_documents IS
	    SELECT  fad.attached_document_id
	           ,fd.document_id
	           ,fd.datatype_id
	    FROM    fnd_attached_documents fad
	           ,fnd_documents fd
	    WHERE   fd.document_id = fad.document_id
	    AND     fad.entity_name = p_in_entity_name
	    AND     fad.pk1_value = p_in_pk1_value
	    AND     (
	                    p_in_pk2_value IS NULL
	            OR      fad.pk2_value = p_in_pk2_value
	            )
	    AND     (
	                    p_in_pk3_value IS NULL
	            OR      fad.pk3_value = p_in_pk3_value
	            )
	    AND     (
	                    p_in_pk4_value IS NULL
	            OR      fad.pk4_value = p_in_pk4_value
	            )
	    AND     (
	                    p_in_pk5_value IS NULL
	            OR      fad.pk5_value = p_in_pk5_value
	            )
	  ;
	BEGIN
	  FOR csr_pointer IN csr_attached_documents LOOP
	    fnd_attached_documents3_pkg.delete_row
	                                            (x_attached_document_id => csr_pointer.attached_document_id
	                                            ,x_datatype_id          => csr_pointer.datatype_id
	                                            ,delete_document_flag   => 'Y' );
	  END LOOP;
	EXCEPTION
	  WHEN others THEN
	    NULL;
	END delete_attachments;


PROCEDURE handle_role_data( p_in_person_id in number,p_in_orig_system in varchar2) is

    l_expiration_date           date := null;
    l_name                      wf_local_roles.name%type := null;
    l_start_date                date := null;
    l_display_name              wf_local_roles.display_name%type := null;

    l_parameters                wf_parameter_list_t;

    Cursor role_exists(p_in_cur_orig_system in varchar2, p_in_cur_person_id in number) is
    select name, start_date, expiration_date
    from   wf_local_roles
    where  orig_system    = p_in_cur_orig_system
    and    orig_system_id = p_in_cur_person_id;

    Cursor per_role(p_in_cur_person_id in number) is
    select start_date, expiration_date
    from   wf_local_roles
    where  orig_system    = 'PER_ROLE'
    and    orig_system_id = p_in_cur_person_id;

    cursor languages_cursor is
      select language_code from fnd_languages
      where installed_flag in ('B','I');

BEGIN

      open role_exists(p_in_orig_system,p_in_person_id);
      fetch role_exists into l_name,l_start_date,l_expiration_date;
      if(role_exists%found)
			then

       Wf_event.addparametertolist(p_name          => 'USER_NAME',
                                p_value         => l_name,
                                p_parameterlist => l_parameters);


       l_display_name := HR_PERSON_NAME.get_person_name(p_in_person_id,
                                                     trunc(sysdate),
                                                     null);

		   wf_event.addparametertolist(p_name          => 'DISPLAYNAME',
                                p_value         => l_display_name,
                                p_parameterlist => l_parameters);

       wf_event.addparametertolist( p_name          => 'MAIL',
                                 p_value         => null,
                                  p_parameterlist => l_parameters);

	       wf_event.addparametertolist(p_name          => 'DESCRIPTION',
	                                   p_value         => l_display_name,
                                     p_parameterlist => l_parameters);


          wf_event.addparametertolist(p_name          => 'WFSYNCH_OVERWRITE',
	                                  p_value         => 'TRUE',
                                    p_parameterlist => l_parameters);

          open per_role(p_in_person_id);
          fetch per_role into l_start_date, l_expiration_date;
          close per_role;

        for lang_csr_ptr in languages_cursor
        loop

	wf_event.addparametertolist(p_name          => 'SOURCE_LANG',
	                            p_value         => lang_csr_ptr.language_code,
                                    p_parameterlist => l_parameters);

         wf_local_synch.propagate_user(
                       p_orig_system     => p_in_orig_system,
                       p_orig_system_id  => p_in_person_id,
                       p_attributes      => l_parameters,
                       p_start_date      => l_start_date,
                       p_expiration_date => l_expiration_date);

        end loop;

         close role_exists;
       else

					close role_exists;
       end if;

EXCEPTION
	WHEN others then
       NULL;
END handle_role_data;

/*End of post process for per for entity hr*/

END PER_DRT_PKG;

/
