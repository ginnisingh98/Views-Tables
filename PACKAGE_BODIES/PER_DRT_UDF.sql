--------------------------------------------------------
--  DDL for Package Body PER_DRT_UDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DRT_UDF" AS
/* $Header: pedrtudf.pkb 120.0.12010000.14 2019/03/22 07:46:37 ktithy noship $ */

  FUNCTION get_legislation_code
    (table_name IN varchar2
    ,person_id  IN number) RETURN varchar2 IS
    l_legislation_code varchar2(4);
    l_person_id varchar2(20);
    p_person_id varchar2(20);
    l_table_name varchar2(200);
    l_entity_type varchar2(20);
    CURSOR c_entity_type
      (p_table_name IN varchar2) IS
      SELECT  entity_type
      FROM    per_drt_tables
      WHERE   table_name = p_table_name;
  BEGIN
    p_person_id := person_id;

    l_table_name := table_name;

    OPEN c_entity_type (l_table_name);

    FETCH c_entity_type
      INTO    l_entity_type;

    CLOSE c_entity_type;

    IF l_entity_type = 'HR' THEN
      RETURN per_per_bus.return_legislation_code (p_person_id);
    ELSIF l_entity_type = 'TCA' THEN
      BEGIN
        SELECT  DISTINCT
                p.person_id
        INTO    l_person_id
        FROM    per_all_people_f p
        WHERE   p.party_id = p_person_id
        AND     rownum = 1;

        RETURN per_per_bus.return_legislation_code (l_person_id);
      EXCEPTION
        WHEN others THEN
          RETURN NULL;
      END;
    ELSIF l_entity_type = 'FND' THEN
      BEGIN
        SELECT  employee_id
        INTO    l_person_id
        FROM    fnd_user u
        WHERE   user_id = p_person_id;

        RETURN per_per_bus.return_legislation_code (l_person_id);
      EXCEPTION
        WHEN no_data_found THEN
          RETURN NULL;
      END;
    END IF;
  END get_legislation_code;

  FUNCTION generate_unique_string
    (p_rid         IN rowid
    ,p_table_name  IN varchar2
    ,p_column_name IN varchar2
    ,p_party_id    IN number) RETURN varchar2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_sql_stmt varchar2(2000);
    l_random_string varchar2(200);
    l_unq_str_value varchar2(200) DEFAULT '';
    l_count number;
    l_old_value varchar2(1000);
  BEGIN
    l_sql_stmt := 'SELECT '
                  || p_column_name
                  || ' FROM '
                  || p_table_name
                  || ' where rowid = :1';

    EXECUTE IMMEDIATE
      l_sql_stmt
    INTO    l_old_value
    USING p_rid;

    IF (l_old_value IS NOT NULL)
       OR (length (trim (l_old_value)) <> 0) THEN
      l_count := 1;

      WHILE l_count > 0 LOOP
        l_random_string := dbms_random.string ('x'
                                              ,7);

        BEGIN
          l_sql_stmt := ' SELECT COUNT(1) FROM '
                        || p_table_name
                        || ' WHERE '
                        || p_column_name
                        || ' =   :1 ';

          EXECUTE IMMEDIATE
            l_sql_stmt
          INTO    l_count
          USING l_random_string;
        EXCEPTION
          WHEN no_data_found THEN
            l_count := 0;
          WHEN others THEN
            l_count := 0;
        END;
      END LOOP;

      l_unq_str_value := '***'
                         || l_random_string;

      RETURN l_unq_str_value;
    ELSE
      RETURN l_unq_str_value;
    END IF;
  END generate_unique_string;

  FUNCTION overwrite_id_number
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    sql_stmt varchar2(2000);
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_legislation_code varchar2(4);
    old_column_value varchar2(240);
    l_ni_format varchar2(20);
    l_overwritten_value varchar2(20);

    CURSOR c_entity_type
      (p_table_name IN varchar2) IS
      SELECT  entity_type
      FROM    per_drt_tables
      WHERE   table_name = p_table_name;
    l_person_id varchar2(20);
    l_entity_type varchar2(20);


  BEGIN


    OPEN c_entity_type (table_name);

    FETCH c_entity_type
      INTO    l_entity_type;

    CLOSE c_entity_type;

    IF l_entity_type = 'HR' THEN
      l_person_id := person_id;
    ELSIF l_entity_type = 'TCA' THEN
      BEGIN
        SELECT  DISTINCT
                p.person_id
        INTO    l_person_id
        FROM    per_all_people_f p
        WHERE   p.party_id = person_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN trim (to_char (dbms_random.value (900000000,999999999),'000000000'));
        WHEN others THEN
          RETURN trim (to_char (dbms_random.value (900000000,999999999),'000000000'));
      END;
    ELSIF l_entity_type = 'FND' THEN
      BEGIN
        SELECT  employee_id
        INTO    l_person_id
        FROM    fnd_user u
        WHERE   user_id = person_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN trim (to_char (dbms_random.value (900000000,999999999),'000000000'));
        WHEN others THEN
          RETURN trim (to_char (dbms_random.value (900000000,999999999),'000000000'));
      END;
    END IF;
/* Modifed the exception above for bug # 29337209. Added When others.*/

--    l_legislation_code := get_legislation_code (table_name
--                                               ,person_id);

    l_legislation_code := per_per_bus.return_legislation_code (l_person_id);


    IF l_legislation_code = 'US' THEN
      l_ni_format := 'NNN-NN-NNNN';

      l_overwritten_value := trim (to_char (dbms_random.value (1
                                                              ,999999)
                                           ,'000g00g0000'
                                           ,'nls_numeric_characters=.-'));
    ELSIF l_legislation_code = 'CA' THEN
      l_ni_format := 'NNN-NNN-NNN';

      l_overwritten_value := trim (to_char (dbms_random.value (900000000
                                                              ,999999999)
                                           ,'000g000g000'
                                           ,'nls_numeric_characters=.-'));
    ELSIF l_legislation_code = 'FR' THEN
      l_ni_format := 'NNNNNCCCCCCCCCC';

      SELECT  '1'
              || to_char (nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY'))
                         ,'YYMM')
              || 'XXXXXXXXXX'
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
   ELSIF l_legislation_code = 'NO' THEN
      l_ni_format := 'NNNNNNNNNNN';
      SELECT  rpad (nvl (to_char (nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY'))
                                 ,'DDMMYY')
                        ,'10000')
                   ,11
                   ,'0')
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
   ELSIF l_legislation_code = 'IE' THEN
      l_ni_format := 'NNNNNNNCC';
      select  trim (to_char (dbms_random.value (9000000
                                                              ,9999999)
                                           ,'0000000'
                                           ))
      ||'XX'
       INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
   ELSIF l_legislation_code = 'SA' THEN
      l_ni_format := 'N-N-NNNN-NNNN-N';
      l_overwritten_value := trim (to_char (dbms_random.value (900000000
                                                              ,999999999)
                                           ,'0g0g0000g0000g0'
                                           ,'nls_numeric_characters=.-'));
   ELSIF l_legislation_code = 'DK' THEN
      l_ni_format := 'NNNNNN-NNNN';
       SELECT to_char (nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY'))
                                 ,'DDMMYY')
                  || '1000'
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
   ELSIF l_legislation_code = 'SE' THEN
      l_ni_format := 'NNNNNN-NNN';
      l_overwritten_value := trim (to_char (dbms_random.value (900000000
                                                              ,999999999)
                                           ,'000000g000'
                                           ,'nls_numeric_characters=.-'));
   ELSIF l_legislation_code = 'PL' THEN
      l_ni_format := 'NNNNNNNNNNN';
       SELECT  rpad (nvl (to_char (nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY'))
                                 ,'DDMMYY')
                        ,'10000')
                   ,11
                   ,'0')
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
   ELSIF l_legislation_code = 'ES' THEN
      l_ni_format := 'CNNNNNNNC';
          SELECT  '1'
              ||trim (to_char (dbms_random.value (9000000 ,9999999)
                                           ,'0000000'
                                           ))
              || 'X'
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
   ELSIF l_legislation_code = 'KW' THEN
      l_ni_format := 'DDDDDDDDDDDD';
       SELECT  rpad (nvl (to_char (nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY'))
                                 ,'DDMMYY')
                        ,'100000')
                   ,12
                   ,'0')
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
    ELSIF l_legislation_code = 'DE' THEN
      l_ni_format := 'NNNNNNNNCNNN';
       SELECT   to_char (nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY'))
                         ,'DDMMYY')
              ||trim (to_char (dbms_random.value (90 ,99)
                                           ,'00'
                                           ))
              || 'E'
              ||trim (to_char (dbms_random.value (900 ,999)
                                           ,'00'
                                           ))
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
   ELSIF l_legislation_code = 'HU' THEN
      l_ni_format := 'NNNNNNNNN';
          l_overwritten_value := trim (to_char (dbms_random.value (900000000
                                                              ,999999999)
                                           ,'000000000'
                                    ));
   ELSIF l_legislation_code = 'NL' THEN
      l_ni_format := 'NNNNNNNNN';
         SELECT  rpad (nvl (to_char (nvl (date_of_birth
                                      ,to_date('01-01-1951','DD-MM-YYYY'))
                                 ,'DDMMYY')
                        ,'10000')
                   ,9
                   ,'0')
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
   ELSIF l_legislation_code = 'RU' THEN
      l_ni_format := 'NNNNNNNNNNNN';
          l_overwritten_value := trim (to_char (dbms_random.value (900000000000
                                                              ,999999999999)
                                           ,'000000000000'
                                    ));
   ELSIF l_legislation_code = 'BE' THEN
      l_ni_format := 'DDDDDD-DDD-DD';
			SELECT  to_char (nvl (date_of_birth
			                     ,to_date ('01-01-1951'
			                              ,'DD-MM-YYYY'))
			                ,'YYMMDD')
			        || '-100-'
			        || lpad ((97 - (mod (to_number (to_char (nvl (date_of_birth
			                                              ,to_date ('01-01-1951'
			                                                       ,'DD-MM-YYYY'))
			                                         ,'YYMMDD')
			                                 || 100)
			                     ,97)))
			                ,2
			                ,'0')
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
        AND   trunc(sysdate) between effective_start_date and effective_end_date;
    ELSIF l_legislation_code = 'ZA' THEN
      l_ni_format := 'NNN-NNN-NNN';

      SELECT  rpad (nvl (to_char (nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY'))
                                 ,'YYMMDD')
                        ,'100000')
                   ,13
                   ,'0')
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
    ELSIF l_legislation_code = 'IT' THEN
      l_ni_format := 'CCCCCCNNCNNCNNNC';

      SELECT  'NSSFLP'
              || to_char(nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY')),'YY')
              || 'E14E151F'
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
    ELSIF l_legislation_code = 'GB' THEN
      l_ni_format := 'CCNNNNNNC';

      SELECT  'TN '
              || to_char(nvl (date_of_birth
                              ,to_date('01-01-1951','DD-MM-YYYY')),'DD MM YY ')
              || sex
      INTO    l_overwritten_value
      FROM    per_all_people_f
      WHERE   person_id = l_person_id
      	AND	  trunc(sysdate) between effective_start_date and effective_end_date;
    ELSIF l_legislation_code = 'MX' THEN
    l_ni_format := 'AAAADDDDDDAAAAAAXD';

    l_overwritten_value :=
        'CURP' ||
        trim(to_char(dbms_random.value(900000, 999999), '000000')) ||
        'CURPIDX' ||
        trim(to_char(dbms_random.value(0, 9), '0'));
    ELSIF l_legislation_code = 'KR'  THEN

	l_ni_format := 'DDDDDD-DDDDDDD';

	SELECT  to_char(nvl (date_of_birth ,to_date('01-01-1951','DD-MM-YYYY')),'YYMMDD')||'-'||decode(sex,'M',1,'F',0,1)||'111111'
	INTO    l_overwritten_value
	FROM    per_all_people_f
	WHERE   person_id = l_person_id
	AND  trunc(sysdate) between effective_start_date and effective_end_date;
    ELSE
      l_overwritten_value := trim (to_char (dbms_random.value (900000000,999999999),'000000000'));
    END IF;

    RETURN l_overwritten_value;
  END overwrite_id_number;

  FUNCTION overwrite_name
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    sql_stmt varchar2(2000);
    old_value varchar2(2000);
    l_overwritten_value varchar2(2000) DEFAULT '';
  BEGIN
    sql_stmt := 'SELECT '
                || column_name
                || ' FROM '
                || table_name
                || ' where rowid = :1';

    EXECUTE IMMEDIATE
      sql_stmt
    INTO    old_value
    USING rid;

    IF (trim(old_value) IS NOT NULL) THEN
      l_overwritten_value := dbms_random.string ('a'
                                                ,length (trim (old_value)));

      RETURN l_overwritten_value;
    ELSE
      RETURN l_overwritten_value;
    END IF;
  END overwrite_name;

  FUNCTION overwrite_phone
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_phn varchar2(30);
    l_sql varchar2(1000);
    l_legislation_code varchar2(4);
  BEGIN
    l_sql := 'select '
             || column_name
             || ' from '
             || table_name
             || ' where rowid = :rid';

    EXECUTE IMMEDIATE
      l_sql
    INTO    l_phn
    USING rid;

    IF l_phn IS NOT NULL THEN
      l_legislation_code := get_legislation_code (table_name
                                                 ,person_id);

      IF l_legislation_code = 'UK' THEN
        l_phn := '+44 1632 960'
                 || trim (to_char (dbms_random.value (0
                                                     ,999)
                                  ,'000'
                                  ,'nls_numeric_characters=.-'));
      ELSIF l_legislation_code = 'US' THEN
        l_phn := '+1 503 555 01'
                 || trim (to_char (dbms_random.value (0
                                                     ,99)
                                  ,'00'
                                  ,'nls_numeric_characters=.-'));
      ELSE
        FOR i IN 1 .. length (l_phn) LOOP
          FOR j IN 0 .. 9 LOOP
            IF (substr (l_phn
                      ,i
                      ,1) = to_char (j)) THEN
              l_phn := replace (l_phn
                               ,to_char (j)
                               ,trunc (dbms_random.value (1
                                                         ,10)));
            END IF;
          END LOOP;
        END LOOP;
      END IF;
    END IF;

    RETURN (l_phn);
  END overwrite_phone;

  FUNCTION overwrite_email
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_email varchar2(240);
    l_person_id varchar2(20);
    p_person_id varchar2(20);
    l_table_name varchar2(200);
    l_entity_type varchar2(20);
    CURSOR c_entity_type
      (p_table_name IN varchar2) IS
      SELECT  entity_type
      FROM    per_drt_tables
      WHERE   table_name = p_table_name;
  BEGIN
    p_person_id := person_id;

    l_table_name := table_name;

    OPEN c_entity_type (l_table_name);

    FETCH c_entity_type
      INTO    l_entity_type;

    CLOSE c_entity_type;

    IF l_entity_type = 'HR' THEN
      l_person_id := p_person_id;
    ELSIF l_entity_type = 'TCA' THEN
      BEGIN
        SELECT  DISTINCT
                p.person_id
        INTO    l_person_id
        FROM    per_all_people_f p
        WHERE   p.party_id = p_person_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN per_drt_rules.ranstr(4,10) || '.' || per_drt_rules.ranstr(4,10) || '@example.invalid';
      END;
    ELSIF l_entity_type = 'FND' THEN
      BEGIN
        SELECT  employee_id
        INTO    l_person_id
        FROM    fnd_user u
        WHERE   user_id = p_person_id;
      EXCEPTION
        WHEN no_data_found THEN
          RETURN per_drt_rules.ranstr(4,10) || '.' || per_drt_rules.ranstr(4,10) || '@example.invalid';
      END;
    END IF;


	if l_person_id is null then
          RETURN per_drt_rules.ranstr(4,10) || '.' || per_drt_rules.ranstr(4,10) || '@example.invalid';
	end if;


    SELECT  nvl (papf.first_name
                ,per_drt_rules.ranstr (4
                                      ,10))
            || '.'
            || papf.last_name
    INTO    l_email
    FROM    per_all_people_f papf
    WHERE   papf.person_id = l_person_id
    AND     papf.effective_start_date =
                                        (
                                        SELECT  max (papf1.effective_start_date)
                                        FROM    per_all_people_f papf1
                                        WHERE   papf1.person_id = l_person_id
                                        );

    l_email := l_email
               || '@example.invalid';

    RETURN (l_email);
  END overwrite_email;

  FUNCTION overwrite_website
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    l_website varchar2(100);
  BEGIN
    l_website := dbms_random.string ('L'
                                    ,6)
                 || '.example.com';

    RETURN (l_website);
  END overwrite_website;

  FUNCTION get_check_digit
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
  BEGIN
    RETURN NULL;
  END get_check_digit;

  FUNCTION get_bank_number
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
  BEGIN
    RETURN NULL;
  END get_bank_number;

  FUNCTION get_branch_number
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
  BEGIN
    RETURN NULL;
  END get_branch_number;

  FUNCTION overwrite_account_number
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_accn varchar2(30);
    l_temp varchar2(30);
    l_sql varchar2(1000);
    l_legislation_code varchar2(4);
    l_format varchar2(20);
    l_mod number;
    l_check_digit varchar2(20);
    l_bank_number varchar2(10);
    l_branch_number varchar2(10);
    l_conversion varchar2(2);
    l_calc number;
    c_1 varchar2(1);
    c_2 number;
  BEGIN
    l_sql := 'select '
             || column_name
             || ' from '
             || table_name
             || ' where rowid = :rid';

    EXECUTE IMMEDIATE
      l_sql
    INTO    l_accn
    USING rid;

    l_check_digit := get_check_digit (rid
                                     ,table_name
                                     ,column_name
                                     ,person_id);

    l_bank_number := get_bank_number (rid
                                     ,table_name
                                     ,column_name
                                     ,person_id);

    l_branch_number := get_branch_number (rid
                                         ,table_name
                                         ,column_name
                                         ,person_id);

    l_legislation_code := get_legislation_code (table_name
                                               ,person_id);

    l_accn := replace (l_accn
                      ,' '
                      ,'');

    IF l_legislation_code <> 'BE' THEN
      l_accn := replace (l_accn
                        ,'-'
                        ,'');
    END IF;

    IF (l_legislation_code <> 'ES'
       AND l_legislation_code <> 'NL'
       AND l_legislation_code <> 'FI') THEN
      FOR i IN 1 .. length (l_accn) LOOP
        IF (ascii (substr (l_accn
                         ,i
                         ,1)) >= 48
           AND ascii (substr (l_accn
                             ,i
                             ,1)) <= 57) THEN
          l_accn := replace (l_accn
                            ,substr (l_accn
                                    ,i
                                    ,1)
                            ,trunc (dbms_random.value (1
                                                      ,10)));
        ELSIF (ascii (substr (l_accn
                            ,i
                            ,1)) >= 65
              AND ascii (substr (l_accn
                                ,i
                                ,1)) <= 90) THEN
          l_accn := replace (l_accn
                            ,substr (l_accn
                                    ,i
                                    ,1)
                            ,dbms_random.string ('U'
                                                ,1));
        ELSIF (ascii (substr (l_accn
                            ,i
                            ,1)) >= 97
              AND ascii (substr (l_accn
                                ,i
                                ,1)) <= 122) THEN
          l_accn := replace (l_accn
                            ,substr (l_accn
                                    ,i
                                    ,1)
                            ,dbms_random.string ('L'
                                                ,1));
        END IF;
      END LOOP;
    END IF;

    IF (l_legislation_code = 'BE') THEN
      l_format := 'NNN-NNNNNNN-NN';

      l_temp := replace (l_accn
                        ,'-'
                        ,'');

      l_temp := substr (l_temp
                       ,1
                       ,10);

      l_mod := lpad (mod (to_number (l_temp)
                         ,97)
                    ,2
                    ,0);

      l_accn := substr (l_temp
                       ,1
                       ,3)
                || '-'
                || substr (l_temp
                          ,4
                          ,10)
                || '-'
                || l_mod;
    ELSIF (l_legislation_code = 'DE'
          AND l_check_digit IS NOT NULL) THEN
      l_accn := substr (l_accn
                       ,1
                       ,length (l_accn) - 1)
                || l_check_digit;
    ELSIF (l_legislation_code = 'ES') THEN
      l_temp := trunc (dbms_random.value (1000000
                                         ,9999999));

      l_accn := '1'
                || substr (l_temp
                          ,1
                          ,4)
                || trunc (dbms_random.value (1
                                            ,9))
                || trunc (dbms_random.value (1
                                            ,9))
                || substr (l_temp
                          ,5
                          ,3);

      IF (length (l_check_digit) = 1) THEN
        c_2 := l_check_digit;
      ELSE
        c_2 := substr (l_check_digit
                      ,2
                      ,1);
      END IF;

      l_mod := mod ((1 + (to_number (substr (l_accn
                                          ,2
                                          ,1)) * 2) + (to_number (substr (l_accn
                                                                        ,3
                                                                        ,1)) * 4)
                       + (to_number (substr (l_accn
                                           ,4
                                           ,1)) * 8)
                       + (to_number (substr (l_accn
                                           ,5
                                           ,1)) * 5)
                       + (to_number (substr (l_accn
                                           ,6
                                           ,1)) * 10)
                       + (to_number (substr (l_accn
                                           ,7
                                           ,1)) * 9)
                       + (to_number (substr (l_accn
                                           ,8
                                           ,1)) * 7)
                       + (to_number (substr (l_accn
                                           ,9
                                           ,1)) * 3)
                       + (to_number (substr (l_accn
                                           ,10
                                           ,1)) * 6))
                   ,11);

      IF ((11 - c_2 - l_mod) >= 0) THEN
        l_calc := 11 - c_2 - l_mod;
      ELSE
        l_calc := 11 + (11 - c_2 - l_mod);
      END IF;

      IF (l_calc <> 9
         AND l_calc <> 10) THEN
        l_accn := (l_calc + 1)
                  || substr (l_accn
                            ,2);
      ELSIF (l_calc = 9) THEN
        l_accn := to_number (l_accn) + 1000;
      ELSIF (l_calc = 10) THEN
        l_accn := to_number (l_accn) + 10000;
      END IF;
    ELSIF (l_legislation_code = 'FI') THEN
      l_accn := '88'
                || trunc (dbms_random.value (power (10
                                                   ,length (l_accn) - 3)
                                            ,power (10
                                                   ,length (l_accn) - 2) - 1));

      l_check_digit := substr (l_accn
                              ,1
                              ,6)
                       || lpad (substr (l_accn
                                       ,8)
                               ,8
                               ,0);

      l_temp := (to_number (substr (l_check_digit
                                  ,8
                                  ,1)) * 1)
                   + (to_number (substr (l_check_digit
                                       ,9
                                       ,1)) * 3)
                   + (to_number (substr (l_check_digit
                                       ,10
                                       ,1)) * 7)
                   + (to_number (substr (l_check_digit
                                       ,11
                                       ,1)) * 1)
                   + (to_number (substr (l_check_digit
                                       ,12
                                       ,1)) * 3)
                   + (to_number (substr (l_check_digit
                                       ,13
                                       ,1)) * 7);

      IF (substr (l_temp
                ,length (l_temp)
                ,1) = '0') THEN
        l_accn := substr (l_accn
                         ,1
                         ,length (l_accn) - 1)
                  || '0';
      ELSE
        l_accn := substr (l_accn
                         ,1
                         ,length (l_accn) - 1)
                  || (10 - to_number (substr (l_temp
                                            ,length (l_temp)
                                            ,1)));
      END IF;
    ELSIF (l_legislation_code = 'FR') THEN
      l_format := 'NNNNNNNCNNN';

      FOR i IN 1 .. length (l_accn) LOOP
        IF (ascii (substr (upper (l_accn)
                         ,i
                         ,1)) >= 65
           AND ascii (substr (upper (l_accn)
                             ,i
                             ,1)) <= 90) THEN
          SELECT  CASE
                  WHEN    substr (l_accn
                                 ,i
                                 ,1) = 'A'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'J'
                          THEN    '1'
                  WHEN    substr (l_accn
                                 ,i
                                 ,1) = 'B'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'K'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'S'
                          THEN    '2'
                  WHEN    substr (l_accn
                                 ,i
                                 ,1) = 'C'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'L'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'T'
                          THEN    '3'
                  WHEN    substr (l_accn
                                 ,i
                                 ,1) = 'D'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'M'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'U'
                          THEN    '4'
                  WHEN    substr (l_accn
                                 ,i
                                 ,1) = 'E'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'N'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'V'
                          THEN    '5'
                  WHEN    substr (l_accn
                                 ,i
                                 ,1) = 'F'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'O'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'W'
                          THEN    '6'
                  WHEN    substr (l_accn
                                 ,i
                                 ,1) = 'H'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'Q'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'Y'
                          THEN    '8'
                  WHEN    substr (l_accn
                                 ,i
                                 ,1) = 'I'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'R'
                  OR      substr (l_accn
                                 ,i
                                 ,1) = 'Z'
                          THEN    '9' END
          INTO    l_conversion
          FROM    dual;

          c_1 := substr (l_accn
                        ,i
                        ,1);

          c_2 := i;

          l_accn := replace (l_accn
                            ,substr (l_accn
                                    ,i
                                    ,1)
                            ,l_conversion);
        END IF;
      END LOOP;

      l_calc := (97 * (3 - mod (97 - l_check_digit
                             ,3)) + (97 - l_check_digit)) / 3;

      l_temp := to_number (l_bank_number
                           || l_branch_number
                           || l_accn);

      l_mod := mod (to_number (l_temp)
                   ,97);

      l_accn := substr ((substr (l_accn
                               ,1
                               ,length (l_accn) - 3)
                        || to_char (to_number (substr (l_accn
                                                      ,length (l_accn) - 2)) + l_calc - l_mod))
                       ,1
                       ,c_2 - 1)
                || c_1
                || substr ((substr (l_accn
                                  ,1
                                  ,length (l_accn) - 3)
                           || to_char (to_number (substr (l_accn
                                                         ,length (l_accn) - 2)) + l_calc - l_mod))
                          ,c_2 + 1);
    ELSIF (l_legislation_code = 'NO') THEN
      l_format := 'NNNNNNNNNNN';

      l_accn := substr (l_accn
                       ,1
                       ,4)
                || '00'
                || substr (l_accn
                          ,7);
    ELSIF (l_legislation_code = 'NL') THEN
      IF (substr (l_accn
                ,1
                ,1) = 'P'
         OR substr (l_accn
                   ,1
                   ,1) = 'G') THEN
        l_accn := substr (l_accn
                         ,1
                         ,1)
                  || trunc (dbms_random.value (1000000
                                              ,9999999));
      ELSE
        l_accn := trunc (dbms_random.value (power (10
                                                  ,length (l_accn) - 3)
                                           ,power (10
                                                  ,length (l_accn) - 2) - 1))
                  || trunc (dbms_random.value (1
                                              ,10))
                  || '9';
      END IF;

      l_temp := lpad (l_accn
                     ,10
                     ,0);

      l_mod := mod (((to_number (substr (l_temp
                                      ,1
                                      ,1)) * 10) + (to_number (substr (l_temp
                                                                     ,2
                                                                     ,1)) * 9)
                       + (to_number (substr (l_temp
                                           ,3
                                           ,1)) * 8)
                       + (to_number (substr (l_temp
                                           ,4
                                           ,1)) * 7)
                       + (to_number (substr (l_temp
                                           ,5
                                           ,1)) * 6)
                       + (to_number (substr (l_temp
                                           ,6
                                           ,1)) * 5)
                       + (to_number (substr (l_temp
                                           ,7
                                           ,1)) * 4)
                       + (to_number (substr (l_temp
                                           ,8
                                           ,1)) * 3)
                       + (to_number (substr (l_temp
                                           ,9
                                           ,1)) * 2)
                       + (to_number (substr (l_temp
                                           ,10
                                           ,1)) * 1))
                   ,11);

      IF (l_mod <= 9) THEN
        l_accn := to_number (l_accn) - l_mod;
      ELSE
        l_accn := to_number (l_accn) - 10;
      END IF;
		ELSE
			l_accn := to_char(trunc(dbms_random.value (power(10,(length(l_accn)-1)),power(10,length(l_accn))-1)));
    END IF;

    RETURN (l_accn);
  END overwrite_account_number;
END PER_DRT_UDF;

/
