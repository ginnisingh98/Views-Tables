--------------------------------------------------------
--  DDL for Package Body HR_BUILD_NAME_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BUILD_NAME_TRG_PKG" as
/* $Header: peppftrg.pkb 115.7 2004/01/08 00:03:52 njaladi ship $ */
PROCEDURE build_trigger IS
  sql_proc_cursor INTEGER;
  sql_proc_rows   INTEGER;
  sql_str VARCHAR2(32000);
  l_full_name VARCHAR2(30);
  l_order_name VARCHAR2(30);
  l_lgsl_code VARCHAR2(2);
  l_lgsl_cd VARCHAR2(2);
  l_pkb_name VARCHAR2(13);
  l_param VARCHAR2(4000);    -- list of parameters for per_xx_full_name/per_xx_order_name
  l_text_str VARCHAR2(2100);
  l_text_inp VARCHAR2(2100);
  l_pos INTEGER := 0;

 -- Start of fix for Bug #2459815
 -- cursor instl_prod selects all the installed Legislations
  CURSOR instl_prod IS
    SELECT legislation_code
    FROM   hr_legislation_installations
    WHERE  application_short_name = 'PER'
		   AND ( (status='I' OR action IS NOT NULL)
                         or (legislation_code = 'JP') -- Added for fix of #3290184
                       )
	ORDER BY legislation_code;

  -- cursor lgsl_pkb delivers all package body names created by localization team
  CURSOR lgsl_pkb(p_lgsl_cd VARCHAR2) IS
    SELECT object_name
    FROM user_objects
    WHERE object_type='PACKAGE BODY'
      AND object_name LIKE 'HR_'||(p_lgsl_cd)||'_UTILITY'
      AND length(object_name)=13
    ORDER BY object_name;
-- End of Fix for Bug #2459815

  -- cursor text_line returns all source code lines of the package body
  CURSOR text_line(p_pkb_name VARCHAR2) IS
    SELECT text
    FROM user_source
    WHERE name = p_pkb_name
    and type = 'PACKAGE' --Bug# 2858437
    ORDER BY line;
BEGIN
  -- l_param variable contains a list of parameters for per_xx_full_name/
  -- per_xx_order_name call
  l_param := ':new.first_name,';
  l_param := l_param || ':new.middle_names,';
  l_param := l_param || ':new.last_name,';
  l_param := l_param || ':new.known_as,';
  l_param := l_param || ':new.title,';
  l_param := l_param || ':new.suffix,';
  l_param := l_param || ':new.pre_name_adjunct,';
  l_param := l_param || ':new.per_information1,';
  l_param := l_param || ':new.per_information2,';
  l_param := l_param || ':new.per_information3,';
  l_param := l_param || ':new.per_information4,';
  l_param := l_param || ':new.per_information5,';
  l_param := l_param || ':new.per_information6,';
  l_param := l_param || ':new.per_information7,';
  l_param := l_param || ':new.per_information8,';
  l_param := l_param || ':new.per_information9,';
  l_param := l_param || ':new.per_information10,';
  l_param := l_param || ':new.per_information11,';
  l_param := l_param || ':new.per_information12,';
  l_param := l_param || ':new.per_information13,';
  l_param := l_param || ':new.per_information14,';
  l_param := l_param || ':new.per_information15,';
  l_param := l_param || ':new.per_information16,';
  l_param := l_param || ':new.per_information17,';
  l_param := l_param || ':new.per_information18,';
  l_param := l_param || ':new.per_information19,';
  l_param := l_param || ':new.per_information20,';
  l_param := l_param || ':new.per_information21,';
  l_param := l_param || ':new.per_information22,';
  l_param := l_param || ':new.per_information23,';
  l_param := l_param || ':new.per_information24,';
  l_param := l_param || ':new.per_information25,';
  l_param := l_param || ':new.per_information26,';
  l_param := l_param || ':new.per_information27,';
  l_param := l_param || ':new.per_information28,';
  l_param := l_param || ':new.per_information29,';
  l_param := l_param || ':new.per_information30';
  -- constant part of sql_str that starts source code for the trigger PER_ALL_PEOPLE_F_NAME
  sql_str := 'CREATE OR REPLACE TRIGGER PER_ALL_PEOPLE_F_NAME ' ||
    'BEFORE INSERT OR UPDATE ON PER_ALL_PEOPLE_F FOR EACH ROW ' ||
    'DECLARE l_legislation_code VARCHAR2(2); BEGIN '        ||
    'if hr_general.g_data_migrator_mode <> ''Y'' then '       ||
    'l_legislation_code := HR_API.'         ||
    'return_legislation_code(:new.business_group_id);';

-- Start of fix for Bug #2459815
OPEN instl_prod;
LOOP
  FETCH instl_prod INTO l_lgsl_cd;
  IF instl_prod%NOTFOUND THEN
    CLOSE instl_prod;
    EXIT;
  END IF;

  OPEN lgsl_pkb(l_lgsl_cd);
-- End of fix for Bug #2459815
  LOOP
    FETCH lgsl_pkb INTO l_pkb_name;
    IF lgsl_pkb%NOTFOUND THEN
      CLOSE lgsl_pkb;
      EXIT;
    ELSE
      -- package body HR_XX_UTILITY found
      l_lgsl_code := SUBSTR(l_pkb_name,4,2);
      l_full_name  := 'per_' || LOWER(l_lgsl_code) || '_full_name';
      l_order_name := 'per_' || LOWER(l_lgsl_code) || '_order_name';
      -- check if legislation code of the current row is the same as
      -- in the package body name HR_XX_UTILITY created by
      -- localization team
      sql_str := sql_str || 'IF l_legislation_code = ' ||
        '''' || UPPER(l_lgsl_code) || '''' || ' THEN ';
      -- get all text lines of the package body HR_XX_UTILITY
      OPEN text_line(l_pkb_name);
      LOOP
        FETCH text_line INTO l_text_inp;
        IF text_line%NOTFOUND THEN
          CLOSE text_line;
          EXIT;
        ELSE
          -- check if the current text line has per_xx_full_name call
          l_text_str := LOWER(l_text_inp);
          l_pos := 0;
          l_pos := INSTR(l_text_str,l_full_name);
          IF l_pos>0 THEN
            -- build per_xx_full_name function call in trigger body
            sql_str := sql_str || ':new.full_name := ' || l_pkb_name ||
              '.' || l_full_name || '(';
            sql_str := sql_str || l_param || ');';
          END IF;
          -- check if the current text line has per_xx_order_name call
          l_pos := 0;
          l_pos := INSTR(l_text_str,l_order_name);
          IF l_pos>0 THEN
            -- build per_xx_order_name function call in trigger body
            sql_str := sql_str || ':new.order_name := ' || l_pkb_name ||
              '.' || l_order_name || '(';
            sql_str := sql_str || l_param || ');';
          END IF;
        END IF;
      END LOOP;
      sql_str := sql_str || 'NULL;END IF;';
    END IF;
  END LOOP;
END LOOP; -- instl_prod
  sql_str := sql_str || 'NULL;END IF;END;';
  -- Dynamic SQL processing of sql_str
  sql_proc_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(sql_proc_cursor,sql_str,dbms_sql.v7);
  sql_proc_rows := dbms_sql.execute(sql_proc_cursor);
  IF dbms_sql.is_open(sql_proc_cursor) THEN
    dbms_sql.close_cursor(sql_proc_cursor);
  END IF;
END;
END HR_BUILD_NAME_TRG_PKG;

/
