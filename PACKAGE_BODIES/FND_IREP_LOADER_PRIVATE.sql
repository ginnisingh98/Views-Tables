--------------------------------------------------------
--  DDL for Package Body FND_IREP_LOADER_PRIVATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_IREP_LOADER_PRIVATE" AS
/* $Header: AFIRLDRB.pls 120.5.12010000.5 2008/11/04 12:10:55 snalagan ship $ */
--
-- Function
--   COMPARE_VERSIONS
--
-- Purpose
--   Compare the version numbers of two files
--
-- RETURNS: The string "=" if p_version1 = p_version2
--          The string ">" if p_version1 > p_version2
--          The string "<" if p_version1 < p_version2

  x_rowid VARCHAR2(64);
  type t_fnd_grants IS TABLE OF fnd_grants % rowtype;
  type t_fnd_menus IS TABLE OF fnd_menus % rowtype;
  type t_fnd_menu_entries IS TABLE OF fnd_menu_entries % rowtype;
  type t_fnd_form_functions IS TABLE OF fnd_form_functions % rowtype;

  function_id fnd_form_functions.function_id%TYPE;
  menu_id fnd_menus.menu_id%TYPE;

  type t_fnd_menus_tl IS TABLE OF fnd_menus_tl % rowtype;
  type t_fnd_menu_entries_tl IS TABLE OF fnd_menu_entries_tl % rowtype;
  type t_fnd_form_functions_tl IS TABLE OF fnd_form_functions_tl % rowtype;


  -- to store existing menus and grants
  v_fnd_grants t_fnd_grants;
  v_fnd_menus t_fnd_menus;
  v_fnd_menu_entries t_fnd_menu_entries;
  v_fnd_form_functions t_fnd_form_functions;
  v_fnd_menus_tl t_fnd_menus_tl;
  v_fnd_menu_entries_tl t_fnd_menu_entries_tl;
  v_fnd_grants_new t_fnd_grants;
  v_fnd_menus_new t_fnd_menus;
  v_fnd_menu_entries_new t_fnd_menu_entries;
  v_fnd_form_functions_new t_fnd_form_functions;
  v_fnd_menus_tl_new t_fnd_menus_tl;
  v_fnd_menu_entries_tl_new t_fnd_menu_entries_tl;

  menu_entry_count number;
  menu_entry_tl_count number;
  menu_count number;
  menu_tl_count number;
  grants_count number;



FUNCTION COMPARE_VERSIONS(p_version1 IN VARCHAR2,
                          p_version2 IN VARCHAR2)
			  RETURN VARCHAR2 is

    --variables to hold the input
    version1 varchar2(30);
    version2 varchar2(30);

    --pointer to the dot(.)
    ptr number;

    --variables to hold the remaining string to be processed
    version1A varchar2(30);
    version2A varchar2(30);

    BEGIN

        version2 := p_version2;
        version1 := p_version1;

        IF(version1 is null and version2 is null) THEN
            RETURN '=';
        ELSIF (version1 is null)THEN
            RETURN '<';
        ELSIF (version2 is null)THEN
            RETURN '>';
        END IF;

        --Get the location of the dot for each version strings.
        --set the value after the dot in version1A and the value before
        --the dot in version1 so in the string 115.6.8,
        --version1A=6.8 version1=115
        ptr := INSTR(version1,'.');
        IF(ptr<>0) THEN
            version1A := substr(version1,ptr+1,length(version1));
            version1 := SUBSTR(version1,1,ptr-1);
        ELSE
             version1A := null;
        END IF;

        ptr := INSTR(version2,'.');
        IF (ptr<>0) THEN
            version2A := substr(version2,ptr+1,length(version2));
            version2 := SUBSTR(version2,1,ptr-1);
        ELSE
            version2A := null;
        END IF;
        --If both the versions are equal call the function recursively.
        --Else compare them and return the result accordingly
        IF(version1=version2) THEN
            RETURN compare_versions(version1A,version2A);
        ELSIF (to_number(version1)>to_number(version2)) THEN
            RETURN '>';
        ELSIF (to_number(version1)<to_number(version2)) THEN
            RETURN '<';
        END IF;

    EXCEPTION
        WHEN VALUE_ERROR THEN
            RAISE_APPLICATION_ERROR('-20002','Invalid String value in input: '
                                     || version1||' , '|| version2);
    END;

--
-- Function
--   OBJ_IS_OBSOLETE
--
-- Purpose
--   Compare the version numbers of file in db with current source file.
--
-- RETURNS: TRUE if current file precedes file version in DB, FALSE otherwise.
--
FUNCTION OBJ_IS_OBSOLETE(P_DEST_TABLE in VARCHAR2,
			 P_OBJECT_NAME in VARCHAR2,
			 P_SOURCE_FILE_VERSION in VARCHAR2) RETURN BOOLEAN is


   DB_Version Varchar2(150);
   key_id number;

begin
   begin
     if (P_DEST_TABLE = 'O') then
       Select object_id, IREP_SOURCE_FILE_VERSION
         into key_id, DB_Version
         from FND_OBJECTS
        where obj_name = P_OBJECT_NAME;
     else
       Select class_id, SOURCE_FILE_VERSION
         into key_id, DB_Version
         from FND_IREP_CLASSES
        where class_name = P_OBJECT_NAME;
     end if;
   exception
        when no_data_found then -- totally new object or class
            return FALSE;
   end;
   if (COMPARE_VERSIONS(P_SOURCE_FILE_VERSION, DB_Version) <> '>') then
     /* Mark flag to indicate that the file data is [O]bsolete */
     if (P_DEST_TABLE = 'O') then
       Update FND_OBJECTS
	  set IREP_LDR_INTERNAL_FLAG = 'O'
        where obj_name = P_OBJECT_NAME;
     else
       Update FND_IREP_CLASSES
          set IREP_LDR_INTERNAL_FLAG = 'O'
        where class_name = P_OBJECT_NAME;
     end if;

     return TRUE;
   else
     /* Clear flag to indicate that the file data is not [O]bsolete */
     if (P_DEST_TABLE = 'O') then
       Update FND_OBJECTS
	  set IREP_LDR_INTERNAL_FLAG = null
        where obj_name = P_OBJECT_NAME;
     else
       Update FND_IREP_CLASSES
          set IREP_LDR_INTERNAL_FLAG = null
        where class_name = P_OBJECT_NAME;
     end if;

     return FALSE;
   end if;
end;

--
-- Function
--   PARENT_IS_OBSOLETE
--
-- Purpose
--   Compare the version numbers of file in db with current source file.
--
-- RETURNS: TRUE if current file precedes the file version in DB,
--	    FALSE otherwise.
--
FUNCTION PARENT_IS_OBSOLETE(P_DEST_TABLE in VARCHAR2,
			    P_OBJECT_NAME in VARCHAR2) RETURN BOOLEAN is


   DB_age number;
   key_id number;
   LDR_Flag varchar2(1);

begin
     if (P_DEST_TABLE = 'O') then
       Select object_id, sysdate - LAST_UPDATE_DATE, IREP_LDR_INTERNAL_FLAG
         into key_id, DB_age, LDR_Flag
         from FND_OBJECTS
        where obj_name = P_OBJECT_NAME;
     else
       Select class_id, sysdate - LAST_UPDATE_DATE, IREP_LDR_INTERNAL_FLAG
         into key_id, DB_age, LDR_Flag
         from FND_IREP_CLASSES
        where class_name = P_OBJECT_NAME;
     end if;

   if (LDR_Flag = 'O') then
     return TRUE;
   else
     return FALSE;
   end if;
end;


PROCEDURE DELETE_COLLECTION  is

begin

-- Delete collections
if v_fnd_form_functions is not null then
	v_fnd_form_functions.DELETE;
end if;
if v_fnd_menu_entries is not null then
	v_fnd_menu_entries.DELETE;
end if;
if v_fnd_menu_entries_tl is not null then
	v_fnd_menu_entries_tl.DELETE;
end if;
if v_fnd_menus is not null then
	v_fnd_menus.DELETE;
end if;
if v_fnd_menus_tl is not null then
	v_fnd_menus_tl.DELETE;
end if;
if v_fnd_grants is not null then
	v_fnd_grants.DELETE;
end if;

end delete_Collection;

--
-- Procedure
--
--
-- Purpose
--   Upload irep object
--
--
PROCEDURE UPLOAD_IREP_OBJECT(   P_UPLOAD_MODE IN VARCHAR2,
				P_OBJECT_NAME IN VARCHAR2,
				P_DEST_TABLE IN VARCHAR2,
				P_OWNER IN VARCHAR2,
				P_API_NAME IN VARCHAR2,
				P_OBJ_TYPE IN VARCHAR2,
				P_PRODUCT IN VARCHAR2,
				P_IMP_NAME IN VARCHAR2,
				P_COMPATABILITY IN VARCHAR2,
				P_SCOPE IN VARCHAR2,
				P_LIFECYCLE IN VARCHAR2,
				P_SOURCE_FILE_PRODUCT IN VARCHAR2,
				P_SOURCE_FILE_PATH IN VARCHAR2,
				P_SOURCE_FILE_NAME IN VARCHAR2,
				P_SOURCE_FILE_VERSION IN VARCHAR2,
				P_DESCRIPTION IN VARCHAR2,
				P_STANDARD IN VARCHAR2,
				P_STANDARD_VERSION IN VARCHAR2,
				P_STANDARD_SPEC IN VARCHAR2,
				P_DISPNAME IN VARCHAR2,
				P_SHORTDISC IN VARCHAR2,
				P_TIMESTAMP IN VARCHAR2,
				P_OI_FLAG IN VARCHAR2,
				P_MAPCODE IN VARCHAR2,
				P_PARSER_VERSION IN VARCHAR2,
				P_SDO_DEF_CLASS IN VARCHAR2,
				P_SDO_CLASS_NAME IN VARCHAR2,
				P_SDO_IS_FILTER IN VARCHAR2,
				P_SDO_FILTER_REQUIRED IN VARCHAR2,
				P_SDO_IS_EXPRESSION IN VARCHAR2,
				P_SB_INTERFACE_CLASS IN VARCHAR2,
				P_CRAWL_CRAWLABLE IN VARCHAR2,
                                P_CRAWL_VISIBILITY_LEVEL IN VARCHAR2,
                                P_CRAWL_SEARCH_PLUGIN IN VARCHAR2,
                                P_CRAWL_UI_FUNCTION IN VARCHAR2,
                                P_CRAWL_CHANGE_EVENT_NAME IN VARCHAR2,
                                P_CRAWL_CHANGE_NTF IN VARCHAR2,
                                P_CRAWL_DRIVING_TABLE IN VARCHAR2) IS

      app_id   number := 0;
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      key_id   number;

      nice_prod   varchar2(8);
      nice_compat varchar2(1);
      nice_scope  varchar2(30);
      nice_lifecy varchar2(30);
      nice_sfprod varchar2(8);
      nice_oiflag varchar2(1);
  begin
     -- Translate owner to file_last_updated_by
     f_luby := fnd_load_util.OWNER_ID(P_OWNER);

     -- Translate char last_update_date to date
     f_ludate := nvl(to_date(P_TIMESTAMP, 'YYYY/MM/DD'), sysdate);

     select application_id into app_id
     from   fnd_application
     where  application_short_name = 'FND';

     begin
        /* if source file version predates the version already in db, quit */
        if (OBJ_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME, P_SOURCE_FILE_VERSION)
           AND (P_UPLOAD_MODE IS NULL OR P_UPLOAD_MODE <> 'NLS')) then
	   		return;
        end if;

        if (P_DEST_TABLE = 'C') then
          select CLASS_ID
            into key_id
            from fnd_irep_classes
           where CLASS_NAME = P_OBJECT_NAME;
        else
          select OBJECT_ID
            into key_id
            from fnd_objects
           where OBJ_NAME = P_OBJECT_NAME;
        end if;

     exception
        when no_data_found then
            null;
     end;

     if (P_UPLOAD_MODE = 'NLS') then
        if (P_DEST_TABLE = 'C') then
          UPDATE FND_IREP_CLASSES_TL
             SET source_lang=userenv('LANG'),
                 DISPLAY_NAME = nvl(P_DISPNAME, DISPLAY_NAME),
                 SHORT_DESCRIPTION = nvl(P_SHORTDISC, SHORT_DESCRIPTION),
                 LAST_UPDATED_BY   = f_luby,
                 LAST_UPDATE_DATE  = f_ludate,
                 LAST_UPDATE_LOGIN = 0
           WHERE userenv('LANG') in (language, source_lang)
             AND CLASS_ID = key_id;
        else
          UPDATE FND_OBJECTS_TL
             SET source_lang=userenv('LANG'),
                 DISPLAY_NAME = nvl(P_DISPNAME, DISPLAY_NAME),
                 DESCRIPTION = nvl(P_SHORTDISC, DESCRIPTION),
                 LAST_UPDATED_BY   = f_luby,
                 LAST_UPDATE_DATE  = f_ludate,
                 LAST_UPDATE_LOGIN = 0
           where userenv('LANG') in (language, source_lang)
             and OBJECT_ID = key_id;
        end if;
     else
        begin
          if (P_DEST_TABLE = 'C') then
            update fnd_irep_classes
               set IREP_NAME = P_API_NAME,
                   CLASS_TYPE = P_OBJ_TYPE,
                   PRODUCT_CODE = NVL(LOWER(P_PRODUCT), 'fnd'),
                   DEPLOYED_FLAG = 'N',
                   GENERATED_FLAG = 'N',
                   IMPLEMENTATION_NAME = P_IMP_NAME,
                   COMPATIBILITY_FLAG = NVL(UPPER(P_COMPATABILITY), 'S'),
                   SCOPE_TYPE = NVL(UPPER(P_SCOPE), 'PUBLIC'),
                   LIFECYCLE_MODE = NVL(UPPER(P_LIFECYCLE), 'ACTIVE'),
                   SOURCE_FILE_PRODUCT = UPPER(P_SOURCE_FILE_PRODUCT),
                   SOURCE_FILE_PATH = P_SOURCE_FILE_PATH,
                   SOURCE_FILE_NAME = P_SOURCE_FILE_NAME,
                   SOURCE_FILE_VERSION = P_SOURCE_FILE_VERSION,
                   DESCRIPTION = P_DESCRIPTION,
                   STANDARD_TYPE = P_STANDARD,
                   STANDARD_VERSION = P_STANDARD_VERSION,
                   STANDARD_SPEC = P_STANDARD_SPEC,
                   OPEN_INTERFACE_FLAG = UPPER(NVL(P_OI_FLAG,'N')),
                   last_updated_by   = f_luby,
                   last_update_date  = sysdate,
                   last_update_login = 0,
                   LOAD_ERR = 'N',
                   LOAD_ERR_MSGS = NULL,
                   MAP_CODE = P_MAPCODE,
                   INTERFACE_CLASS = P_SB_INTERFACE_CLASS,
                   IREP_LDR_PP_FLAG = DECODE(P_OBJ_TYPE, 'SERVICEBEAN','Y',NULL),
		   XML_DESCRIPTION = NULL
             where CLASS_ID = key_id;

            if (SQL%NOTFOUND) then
              raise no_data_found;
            end if;

            -- remove class subentities (except methods)
            Delete from FND_IREP_CLASS_DATASOURCES
                where CLASS_ID = key_id;

            Delete from FND_IREP_CLASS_PARENT_ASSIGNS
                where CLASS_NAME = P_OBJECT_NAME;

            Delete from FND_LOOKUP_ASSIGNMENTS
                where obj_name = 'FND_IREP_CLASSES'
                  and INSTANCE_PK1_VALUE = to_char(key_id);

            Delete from FND_CHILD_ANNOTATIONS
                where parent_id = key_id
                  and parent_flag = 'C';

            Delete from FND_IREP_USES_TABLES
                where CLASS_ID = key_id;

            Delete from FND_IREP_USES_MAPS
                where CLASS_ID = key_id;

            -- remove method subentities
            Delete from FND_LOOKUP_ASSIGNMENTS
                where obj_name = 'FND_IREP_FUNCTION_FLAVORS'
                  and INSTANCE_PK1_VALUE in
                        (select function_id
                           from FND_FORM_FUNCTIONS
                          where irep_class_id = key_id);

            Delete from FND_CHILD_ANNOTATIONS
                where parent_flag = 'F'
                  and parent_id in
                        (select function_id
                           from FND_FORM_FUNCTIONS
                          where irep_class_id = key_id);

            Delete from FND_PARAMETERS
                where function_id in
                        (select function_id
                           from FND_FORM_FUNCTIONS
                          where irep_class_id = key_id);

            -- remove flavors
            Delete from FND_IREP_FUNCTION_FLAVORS
                where FUNCTION_ID in
                        (select function_id
                           from FND_FORM_FUNCTIONS
                          where irep_class_id = key_id);



	    -- Remove derived entries classes and functions

	    Delete from fnd_irep_classes
	         where assoc_class_id = key_id;
	    Delete from fnd_form_functions
	         where irep_class_id =
		        (select class_id
			  from fnd_irep_classes
			  where assoc_class_id = key_id);

	    --Fetch and save menus and grants
	    GET_DELETE_GRANTS(key_id);

          else
            update fnd_objects
               set IREP_NAME = P_API_NAME,
                   IREP_OBJECT_TYPE = P_OBJ_TYPE,
                   IREP_PRODUCT = LOWER(P_PRODUCT),
                   IREP_COMPATIBILITY = NVL(UPPER(P_COMPATABILITY), 'S'),
                   IREP_SCOPE = NVL(UPPER(P_SCOPE), 'PUBLIC'),
                   IREP_LIFECYCLE = NVL(UPPER(P_LIFECYCLE), 'ACTIVE'),
                   IREP_SOURCE_FILE_PRODUCT = UPPER(P_SOURCE_FILE_PRODUCT),
                   IREP_SOURCE_FILE_PATH = P_SOURCE_FILE_PATH,
                   IREP_SOURCE_FILE_NAME = P_SOURCE_FILE_NAME,
                   IREP_SOURCE_FILE_VERSION = P_SOURCE_FILE_VERSION,
                   IREP_DESCRIPTION = P_DESCRIPTION,
                   IREP_STANDARD = P_STANDARD,
                   IREP_STANDARD_VERSION = P_STANDARD_VERSION,
                   IREP_STANDARD_SPEC = P_STANDARD_SPEC,
                   PK1_COLUMN_NAME = 'DUMMY_IREP',
                   PK1_COLUMN_TYPE = 'NUMBER',
                   last_updated_by   = f_luby,
                   last_update_date  = sysdate,
                   last_update_login = 0,
                   LOAD_ERR = 'N',
                   LOAD_ERR_MSGS = NULL,
                   IREP_DEF_CLASS = P_SDO_DEF_CLASS,
                   IREP_CLASS_NAME = P_SDO_CLASS_NAME,
                   IREP_FILTER_REQUIRED = NVL(P_SDO_FILTER_REQUIRED, 'N'),
                   IREP_IS_FILTER = NVL(P_SDO_IS_FILTER, 'N'),
                   IREP_IS_EXPRESSION = NVL(P_SDO_IS_EXPRESSION, 'N'),
                   CRAWL_CRAWLABLE = P_CRAWL_CRAWLABLE,
		   CRAWL_VISIBILITY_LEVEL = P_CRAWL_VISIBILITY_LEVEL,
		   CRAWL_SEARCH_PLUGIN = P_CRAWL_SEARCH_PLUGIN,
		   CRAWL_UI_FUNCTION = P_CRAWL_UI_FUNCTION,
		   CRAWL_CHANGE_EVENT_NAME = P_CRAWL_CHANGE_EVENT_NAME,
		   CRAWL_CHANGE_NOTIFICATION = P_CRAWL_CHANGE_NTF,
		   CRAWL_DRIVING_TABLE = P_CRAWL_DRIVING_TABLE,
                   IREP_LDR_PP_FLAG =
                                DECODE(P_OBJ_TYPE, 'SERVICEDOCUMENT', 'Y', NULL),
		   IREP_XML_DESCRIPTION = NULL
             where OBJECT_ID = key_id;

            if (SQL%NOTFOUND) then
              raise no_data_found;
            end if;

            -- remove object subentities
            Delete from FND_OBJECT_KEY_SETS
                where object_id = key_id;

            Delete from FND_LOOKUP_ASSIGNMENTS
                where obj_name = 'FND_OBJECTS'
                  and INSTANCE_PK1_VALUE = to_char(key_id);

            Delete from FND_CHILD_ANNOTATIONS
                where parent_id = key_id
                  and parent_flag = 'O';

            Delete from FND_OBJECT_TYPE_MEMBERS
                where object_id = key_id;

          end if;

          if (P_DEST_TABLE = 'C') then
            UPDATE FND_IREP_CLASSES_TL
               SET SOURCE_LANG = userenv('LANG'),
                   DISPLAY_NAME = nvl(P_DISPNAME, DISPLAY_NAME),
                   SHORT_DESCRIPTION = nvl(P_SHORTDISC, SHORT_DESCRIPTION),
                   LAST_UPDATED_BY   = f_luby,
                   LAST_UPDATE_DATE  = f_ludate,
                   LAST_UPDATE_LOGIN = 0
             where userenv('LANG') in (language, source_lang)
               and CLASS_ID = key_id;

          else
            UPDATE FND_OBJECTS_TL
               SET SOURCE_LANG = userenv('LANG'),
                   DISPLAY_NAME = nvl(P_DISPNAME, DISPLAY_NAME),
                   DESCRIPTION = nvl(P_SHORTDISC, DESCRIPTION),
                   LAST_UPDATED_BY   = f_luby,
                   LAST_UPDATE_DATE  = f_ludate,
                   LAST_UPDATE_LOGIN = 0
             WHERE userenv('LANG') in (language, source_lang)
               AND OBJECT_ID = key_id;
          end if;

        exception
          when no_data_found then

          select fnd_objects_s.nextval, NVL(LOWER(P_PRODUCT), 'fnd'),
                 NVL(UPPER(P_COMPATABILITY),'S'), NVL(UPPER(P_SCOPE), 'PUBLIC'),
                 NVL(UPPER(P_LIFECYCLE),'ACTIVE'), UPPER(P_SOURCE_FILE_PRODUCT),
                 UPPER(NVL(P_OI_FLAG, 'N'))
            into key_id, nice_prod,
                 nice_compat, nice_scope,
                 nice_lifecy, nice_sfprod,
                 nice_oiflag
            from dual;

          if (P_DEST_TABLE = 'C') then
            insert into fnd_irep_classes (
                   IREP_NAME, CLASS_TYPE, PRODUCT_CODE, DEPLOYED_FLAG,
                   GENERATED_FLAG, IMPLEMENTATION_NAME, COMPATIBILITY_FLAG,
                   SCOPE_TYPE, MAP_CODE,
                   LIFECYCLE_MODE,
                   SOURCE_FILE_PRODUCT,
                   SOURCE_FILE_PATH, SOURCE_FILE_NAME, SOURCE_FILE_VERSION,
                   DESCRIPTION, STANDARD_TYPE, STANDARD_VERSION, STANDARD_SPEC,
                   OPEN_INTERFACE_FLAG, INTERFACE_CLASS, last_updated_by,
                   last_update_date, last_update_login,
                   CREATION_DATE, CREATED_BY, CLASS_ID, CLASS_NAME,
                   IREP_LDR_PP_FLAG
                  ) VALUES (
                    P_API_NAME, P_OBJ_TYPE, nice_prod, 'N',
                   'N', P_IMP_NAME, nice_compat,
                   nice_scope, P_MAPCODE,
                   nice_lifecy,
                   nice_sfprod,
                   P_SOURCE_FILE_PATH, P_SOURCE_FILE_NAME,P_SOURCE_FILE_VERSION,
                   P_DESCRIPTION, P_STANDARD,P_STANDARD_VERSION,P_STANDARD_SPEC,
                   nice_oiflag, P_SB_INTERFACE_CLASS, f_luby,
                   sysdate, 0,
                   f_ludate, f_luby, key_id, P_OBJECT_NAME,
                   DECODE(P_OBJ_TYPE, 'SERVICEBEAN', 'Y', NULL)
                  );

            INSERT INTO FND_IREP_CLASSES_TL (
                   CLASS_ID, DISPLAY_NAME, SHORT_DESCRIPTION, LANGUAGE,
                   SOURCE_LANG, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                   CREATED_BY, CREATION_DATE, LAST_UPDATE_LOGIN
                  ) SELECT
                    key_id, P_DISPNAME, P_SHORTDISC, L.LANGUAGE_CODE,
                    USERENV('LANG'), f_ludate, f_luby, f_luby, f_ludate, 0
                  FROM FND_LANGUAGES L
                 WHERE L.INSTALLED_FLAG IN ('I','B')
                   AND NOT EXISTS
                     (SELECT NULL
                        FROM FND_IREP_CLASSES_TL T
                       WHERE T.CLASS_ID = key_id
                         AND T.LANGUAGE = l.language_code);

          else
            INSERT INTO FND_OBJECTS (
                   IREP_NAME, IREP_OBJECT_TYPE, IREP_PRODUCT,
                   IREP_COMPATIBILITY,
                   IREP_SCOPE,
                   IREP_LIFECYCLE,
                   IREP_DEF_CLASS,
                   IREP_CLASS_NAME,
                   IREP_IS_FILTER,
                   IREP_FILTER_REQUIRED,
                   IREP_IS_EXPRESSION,
                   IREP_SOURCE_FILE_PRODUCT, IREP_SOURCE_FILE_PATH,
                   IREP_SOURCE_FILE_NAME, IREP_SOURCE_FILE_VERSION,
                   IREP_DESCRIPTION, IREP_STANDARD, IREP_STANDARD_VERSION,
                   IREP_STANDARD_SPEC, PK1_COLUMN_NAME, PK1_COLUMN_TYPE,
                   LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
                   CREATION_DATE, CREATED_BY, OBJECT_ID, OBJ_NAME,
                   APPLICATION_ID, DATABASE_OBJECT_NAME,
		   CRAWL_CRAWLABLE,
		   CRAWL_VISIBILITY_LEVEL,
		   CRAWL_SEARCH_PLUGIN,
		   CRAWL_UI_FUNCTION,
		   CRAWL_CHANGE_EVENT_NAME,
		   CRAWL_CHANGE_NOTIFICATION,
		   CRAWL_DRIVING_TABLE,
                   IREP_LDR_PP_FLAG
                  ) VALUES (
                   P_API_NAME, P_OBJ_TYPE, nice_prod,
                   nice_compat,
                   nice_scope,
                   nice_lifecy,
                   P_SDO_DEF_CLASS,
                   P_SDO_CLASS_NAME,
                   NVL(P_SDO_IS_FILTER,'N'),
                   NVL(P_SDO_FILTER_REQUIRED,'N'),
                   NVL(P_SDO_IS_EXPRESSION,'N'),
                   nice_sfprod, P_SOURCE_FILE_PATH,
                   P_SOURCE_FILE_NAME, P_SOURCE_FILE_VERSION,
                   P_DESCRIPTION, P_STANDARD, P_STANDARD_VERSION,
                   P_STANDARD_SPEC, 'DUMMY_IREP', 'NUMBER',
                   f_luby, sysdate, 0,
                   f_ludate, f_luby, key_id, P_OBJECT_NAME,
                   app_id, 'INTERFACE',
                   P_CRAWL_CRAWLABLE,
                   P_CRAWL_VISIBILITY_LEVEL,
                   P_CRAWL_SEARCH_PLUGIN,
                   P_CRAWL_UI_FUNCTION,
                   P_CRAWL_CHANGE_EVENT_NAME,
                   P_CRAWL_CHANGE_NTF,
                   P_CRAWL_DRIVING_TABLE,
                   DECODE(P_OBJ_TYPE, 'SERVICEDOCUMENT', 'Y', NULL)
                  );

            INSERT INTO FND_OBJECTS_TL (
                   object_id, display_name, description, LANGUAGE,
                   SOURCE_LANG, LAST_UPDATE_DATE, LAST_UPDATED_BY,
                   CREATED_BY, CREATION_DATE, LAST_UPDATE_LOGIN
                  ) SELECT
                    key_id, P_DISPNAME,P_SHORTDISC, L.LANGUAGE_CODE,
                    USERENV('LANG'), f_ludate, f_luby, f_luby, f_ludate, 0
                  FROM FND_LANGUAGES L
                 WHERE L.INSTALLED_FLAG IN ('I','B')
                   AND NOT EXISTS
                     (SELECT NULL
                        FROM FND_OBJECTS_TL T
                       WHERE T.OBJECT_ID = key_id
                         AND T.LANGUAGE = l.language_code);

          end if;
        end; -- update or insert ?
     end if; -- NLS_MODE
  end;




--
-- Procedure
--   UPLOAD_Parents
--
-- Purpose
--   Upload parents
--
--
PROCEDURE UPLOAD_PARENTS(P_UPLOAD_MODE IN VARCHAR2,
			   P_OBJECT_NAME IN VARCHAR2,
		           P_DEST_TABLE IN VARCHAR2,
			   P_PARENT_NAME IN VARCHAR2) is

  begin  -- UPLOAD PARENTS
     if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
       return;
     end if;

     Insert into FND_IREP_CLASS_PARENT_ASSIGNS
	(CLASS_NAME, PARENT_CLASS_NAME)
	select P_OBJECT_NAME, P_PARENT_NAME from dual;
  end;




--
-- Procedure
--   UPLOAD_OBJECT_CATEGORY
--
-- Purpose
--   Upload Object Category
--
PROCEDURE UPLOAD_OBJECT_CATEGORY(  P_UPLOAD_MODE IN VARCHAR2,
				   P_OBJECT_NAME IN VARCHAR2,
				   P_DEST_TABLE IN VARCHAR2,
				   P_TYPE IN VARCHAR2,
				   P_CODE IN VARCHAR2,
				   P_SEQUENCE IN VARCHAR2) is

	key_id   number;
        f_luby    number;  -- entity owner in file
        f_ludate  date;    -- entity update date in file
  begin
     if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
       return;
     end if;

     if (P_DEST_TABLE = 'O') then
       Select object_id, last_updated_by, last_update_date
         into key_id, f_luby, f_ludate
         from FND_OBJECTS
        where obj_name = P_OBJECT_NAME;
     else
       Select class_id, last_updated_by, last_update_date
	 into key_id, f_luby, f_ludate
         from FND_IREP_CLASSES
        where class_name = P_OBJECT_NAME;
     end if;

     Insert into FND_LOOKUP_ASSIGNMENTS
        (OBJ_NAME, INSTANCE_PK1_VALUE,
	 LOOKUP_TYPE, LOOKUP_CODE, LOOKUP_ASSIGNMENT_ID,
 	 CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
	 LAST_UPDATE_LOGIN, DISPLAY_SEQUENCE)
        select DECODE(P_DEST_TABLE, 'C', 'FND_IREP_CLASSES', 'FND_OBJECTS'),
         key_id,
	 P_TYPE, P_CODE, FND_LOOKUP_ASSIGNMENTS_S.nextval,
	 f_luby, f_ludate, f_luby, f_ludate,
	 0, P_SEQUENCE
	from dual;
  end;





--
-- Procedure
--   UPLOAD_OBJ_CHILD_ANNOTATIONS
--
-- Purpose
--   Upload Object Child Annotations
--
PROCEDURE UPLOAD_OBJ_CHILD_ANNOTATIONS(  P_UPLOAD_MODE IN VARCHAR2,
					 P_OBJECT_NAME IN VARCHAR2,
                                         P_DEST_TABLE IN VARCHAR2,
					 P_CHILD_FLAG IN VARCHAR2,
					 P_VALUE IN VARCHAR2) is

	key_id   number;
  begin
     if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
       return;
     end if;

     if (P_DEST_TABLE = 'O') then
       Select object_id
         into key_id
         from FND_OBJECTS
        where obj_name = P_OBJECT_NAME;
     else
       Select class_id
	 into key_id
         from FND_IREP_CLASSES
        where class_name = P_OBJECT_NAME;
     end if;

     Insert into FND_CHILD_ANNOTATIONS
        (PARENT_ID, PARENT_FLAG, CHILD_FLAG, ANNOTATION_VALUE)
        select  key_id, P_DEST_TABLE, UPPER(P_CHILD_FLAG), P_VALUE
	from dual;
  end;





--
-- Procedure
--   UPLOAD_TYPE_MEMBERS
--
-- Purpose
--   Upload Type Members
--
PROCEDURE UPLOAD_TYPE_MEMBERS(   P_UPLOAD_MODE IN VARCHAR2,
				 P_OBJECT_NAME IN VARCHAR2,
                                 P_DEST_TABLE IN VARCHAR2,
				 P_SEQUENCE IN VARCHAR2,
				 P_INNERTYPE_SEQUENCE IN VARCHAR2,
				 P_MEMBER_NAME IN VARCHAR2,
				 P_TYPE IN VARCHAR2,
				 P_PRECISION IN VARCHAR2,
				 P_SIZE IN VARCHAR2,
				 P_SCALE IN VARCHAR2,
				 P_NULL_ALLOWED IN VARCHAR2,
				 P_DESCRIPTION IN VARCHAR2,
				 P_ATTR_SET IN VARCHAR2,
				 P_PRIMARY_KEY IN VARCHAR2,
				 P_TRANSLATABLE IN VARCHAR2,
				 P_COMPOSITE IN VARCHAR2,
				 P_DOMAIN_NAME IN VARCHAR2,
				 P_MEMBER_TYPE_NAME IN VARCHAR2,
				 P_SEARCH_CRITERIA_TYPE IN VARCHAR2,
				 P_ATTACHMENT IN VARCHAR2,
				 P_MIME_TYPE IN VARCHAR2,
				 P_DOMAIN_IMPLEMENTATION IN VARCHAR2,
				 P_IS_SORTABLE IN VARCHAR2,
				 P_CRAWL_IS_DATE_BASED IN VARCHAR2,
                                 P_CRAWL_MEMBER_VIS_LVL IN VARCHAR2,
                                 P_CRAWL_IS_DISPLAYED IN VARCHAR2,
                                 P_CRAWL_UI_FPARAM_NAME IN VARCHAR2,
                                 P_CRAWL_INDEXED IN VARCHAR2,
                                 P_CRAWL_STORED IN VARCHAR2,
                                 P_CRAWL_IS_SECURE IN VARCHAR2,
                                 P_CRAWL_IS_TITLE IN VARCHAR2,
                                 P_CRAWL_WEIGHT IN VARCHAR2) is

      obj_id number;

  begin
     if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
       return;
     end if;

     SELECT object_id
       INTO obj_id
       FROM FND_OBJECTS
      WHERE OBJ_NAME = P_OBJECT_NAME;

     Insert into FND_OBJECT_TYPE_MEMBERS
        (OBJECT_ID, MEMBER_SEQUENCE, INNERTYPE_SEQUENCE, MEMBER_NAME,
         MEMBER_TYPE, MEMBER_PRECISION, NULL_ALLOWED, DESCRIPTION,
	 ATTRIBUTE_SET, PRIMARY_KEY, TRANSLATABLE,
	 COMPOSITE, MEMBER_SCALE, MEMBER_TYPE_NAME, SEARCH_CRITERIA_TYPE,
	 ATTACHMENT, MIME_TYPE, DOMAIN_NAME, DOMAIN_IMPLEMENTATION,
	 IS_SORTABLE, IS_DATE_BASED, VISIBILITY_LEVEL,
	 IS_DISPLAYED, UI_FUNC_PARAMETER_NAME, CRAWL_INDEXED,
	 CRAWL_STORED, IS_SECURE, IS_TITLE, WEIGHT
        ) VALUES (
	 obj_id, P_SEQUENCE, P_INNERTYPE_SEQUENCE, P_MEMBER_NAME,
         P_TYPE, P_PRECISION, P_NULL_ALLOWED, P_DESCRIPTION,
	 P_ATTR_SET, NVL(P_PRIMARY_KEY,'N'), NVL(P_TRANSLATABLE,'N'),
	 NVL(P_COMPOSITE,'N'),P_SCALE,P_MEMBER_TYPE_NAME,P_SEARCH_CRITERIA_TYPE,
	NVL(P_ATTACHMENT,'N'),P_MIME_TYPE,P_DOMAIN_NAME,P_DOMAIN_IMPLEMENTATION,
	 NVL(P_IS_SORTABLE, 'N'), P_CRAWL_IS_DATE_BASED, P_CRAWL_MEMBER_VIS_LVL,
	 P_CRAWL_IS_DISPLAYED, P_CRAWL_UI_FPARAM_NAME, P_CRAWL_INDEXED,
	 P_CRAWL_STORED, P_CRAWL_IS_SECURE, P_CRAWL_IS_TITLE, P_CRAWL_WEIGHT
        );
  end;


--
-- Procedure
--   UPLOAD_USES_TABLE
--
-- Purpose
--   Upload Uses Table
--
PROCEDURE UPLOAD_USES_TABLE(  P_UPLOAD_MODE IN VARCHAR2,
			      P_OBJECT_NAME IN VARCHAR2,
                              P_DEST_TABLE IN VARCHAR2,
			      P_TABLE_NAME IN VARCHAR2,
  			      P_UT_SEQ IN VARCHAR2,
			      P_UT_DIRECTION IN VARCHAR2) is

  begin -- UPLOAD USES_TABLE
     if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
       return;
     end if;

     Insert into FND_IREP_USES_TABLES
	(CLASS_ID, TABLE_USED, DISPLAY_SEQUENCE,
		TABLE_DIRECTION)
	select class_id, UPPER(P_TABLE_NAME), P_UT_SEQ,
		UPPER(NVL(P_UT_DIRECTION, 'I'))
 	  from FND_IREP_CLASSES
	 where CLASS_NAME = P_OBJECT_NAME;
  end;


--
-- Procedure
--   UPLOAD_USES_MAP
--
-- Purpose
--   Upload Uses Map
--
PROCEDURE UPLOAD_USES_MAP(  P_UPLOAD_MODE IN VARCHAR2,
			    P_OBJECT_NAME IN VARCHAR2,
                            P_DEST_TABLE IN VARCHAR2,
			    P_MAP_NAME IN VARCHAR2,
			    P_UM_SEQ IN VARCHAR2) is

  begin -- UPLOAD USES_MAP
     if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
       return;
     end if;

     Insert into FND_IREP_USES_MAPS
	(CLASS_ID, MAP_USED, DISPLAY_SEQ)
	select class_id, UPPER(P_MAP_NAME), P_UM_SEQ
 	  from FND_IREP_CLASSES
	 where CLASS_NAME = P_OBJECT_NAME;
  end;



--
-- Procedure
--   UPLOAD_CLASS_DATASOURCES
--
-- Purpose
--   Upload Class Datasources
--
PROCEDURE UPLOAD_CLASS_DATASOURCES(P_UPLOAD_MODE IN VARCHAR2,
			    	   P_OBJECT_NAME IN VARCHAR2,
                            	   P_DEST_TABLE IN VARCHAR2,
			    	   P_DATASOURCE_NAME IN VARCHAR2,
			    	   P_DEF_CLASS IN VARCHAR2,
			    	   P_QUERYABLE IN VARCHAR2,
			    	   P_UPDATEABLE IN VARCHAR2,
			    	   P_INSERTABLE IN VARCHAR2,
			    	   P_MERGEABLE IN VARCHAR2,
			    	   P_DELETEABLE IN VARCHAR2,
			    	   P_PROCESS_QNAME IN VARCHAR2,
			    	   P_QUERY_QNAME IN VARCHAR2) is

      key_id number;

  begin
     if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
       return;
     end if;

     Select class_id
       into key_id
       from FND_IREP_CLASSES
      where class_name = P_OBJECT_NAME;

     Insert into FND_IREP_CLASS_DATASOURCES
        (CLASS_ID, DATASOURCE_NAME, DEF_CLASS, QUERYABLE,
	 UPDATEABLE, INSERTABLE, MERGEABLE,
	 DELETEABLE, PROCESS_CTRLPROP_QNAME, QUERY_CTRLPROP_QNAME
        ) VALUES (
         key_id, P_DATASOURCE_NAME, P_DEF_CLASS, NVL(P_QUERYABLE, 'N'),
	 NVL(P_UPDATEABLE, 'N'), NVL(P_INSERTABLE, 'N'), NVL(P_MERGEABLE, 'N'),
	 NVL(P_DELETEABLE, 'N'), P_PROCESS_QNAME, P_QUERY_QNAME
        );
  end;


--
-- Procedure
--   UPLOAD_OBJ_KEY_SET
--
-- Purpose
--   Upload Object Key Set
--
PROCEDURE UPLOAD_OBJ_KEY_SET(P_UPLOAD_MODE IN VARCHAR2,
			     P_OBJECT_NAME IN VARCHAR2,
                             P_DEST_TABLE IN VARCHAR2,
			     P_KEY_SET_NAME IN VARCHAR2,
			     P_KEY_SET_SEQUENCE IN VARCHAR2,
			     P_KEY1_MBR_NAME IN VARCHAR2,
			     P_KEY2_MBR_NAME IN VARCHAR2,
			     P_KEY3_MBR_NAME IN VARCHAR2,
			     P_KEY4_MBR_NAME IN VARCHAR2,
			     P_KEY5_MBR_NAME IN VARCHAR2,
			     P_ALT1_MBR_NAME IN VARCHAR2,
			     P_ALT2_MBR_NAME IN VARCHAR2,
			     P_ALT3_MBR_NAME IN VARCHAR2,
			     P_ALT4_MBR_NAME IN VARCHAR2,
			     P_ALT5_MBR_NAME IN VARCHAR2) is

      obj_id number;

  begin
     if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
       return;
     end if;

     SELECT object_id
       INTO obj_id
       FROM FND_OBJECTS
      WHERE OBJ_NAME = P_OBJECT_NAME;

     Insert into FND_OBJECT_KEY_SETS
        (OBJECT_ID, KEY_SET_NAME, KEY_SET_SEQUENCE,
         KEY1_MEMBER_NAME, ALT1_MEMBER_NAME,
         KEY2_MEMBER_NAME, ALT2_MEMBER_NAME,
         KEY3_MEMBER_NAME, ALT3_MEMBER_NAME,
         KEY4_MEMBER_NAME, ALT4_MEMBER_NAME,
         KEY5_MEMBER_NAME, ALT5_MEMBER_NAME
        ) VALUES (
         obj_id, P_KEY_SET_NAME, P_KEY_SET_SEQUENCE,
         P_KEY1_MBR_NAME, P_ALT1_MBR_NAME,
         P_KEY2_MBR_NAME, P_ALT2_MBR_NAME,
         P_KEY3_MBR_NAME, P_ALT3_MBR_NAME,
         P_KEY4_MBR_NAME, P_ALT4_MBR_NAME,
         P_KEY5_MBR_NAME, P_ALT5_MBR_NAME
        );
  end;



--
-- Procedure
--   UPLOAD_IREP_METHOD
--
-- Purpose
--   Upload iRep Method
--
PROCEDURE UPLOAD_IREP_METHOD(   P_UPLOAD_MODE IN VARCHAR2,
			        P_OBJECT_NAME IN VARCHAR2,
                                P_DEST_TABLE IN VARCHAR2,
			        P_FUNCTION_NAME IN VARCHAR2,
				P_METHOD_NAME IN VARCHAR2,
				P_OVERLOAD_SEQ IN VARCHAR2,
				P_SCOPE IN VARCHAR2,
				P_LIFECYCLE IN VARCHAR2,
			        P_DESCRIPTION IN VARCHAR2,
				P_COMPATABILITY IN VARCHAR2,
				P_SYNCHRO IN VARCHAR2,
				P_DIRECTION IN VARCHAR2,
				P_CTX_DEPENDENCE IN VARCHAR2,
				P_USER_FN_NAME IN VARCHAR2,
				P_SHORT_DESCRIPTION IN VARCHAR2,
				P_PRIMARY_FLAG IN VARCHAR2,
				P_INDIRECT_OP_FLAG IN VARCHAR2) is


      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      key_id    number;
      fn_id     number;
      new_fn    number;
      primary_flavor    number;

      nice_ctx    varchar2(8);
      nice_compat varchar2(1);
      nice_scope  varchar2(30);
      nice_lifecy varchar2(30);
      nice_synch  varchar2(1);
      nice_direct varchar2(1);
      nice_sdescr varchar2(240);

  begin
     if (P_UPLOAD_MODE = 'NLS') then

       Select c.class_id, c.last_updated_by, c.last_update_date, f.function_id
         into key_id, f_luby, f_ludate, fn_id
         from FND_IREP_CLASSES c,
	      FND_FORM_FUNCTIONS f
        where c.class_name = P_OBJECT_NAME
	  and f.irep_class_id = c.class_id
          and f.function_name = P_FUNCTION_NAME;

       update FND_FORM_FUNCTIONS_TL
             set source_lang=userenv('LANG'),
                 USER_FUNCTION_NAME = nvl(P_USER_FN_NAME, USER_FUNCTION_NAME),
                 DESCRIPTION = nvl(P_SHORT_DESCRIPTION, DESCRIPTION),
                 last_updated_by   = f_luby,
                 last_update_date  = f_ludate,
                 last_update_login = 0
           where userenv('LANG') in (language, source_lang)
             and function_id = fn_id;

     else
       	begin
          if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
            return;
          end if;
          new_fn := 0;
          primary_flavor := 0;

          SELECT UPPER(NVL(P_CTX_DEPENDENCE, 'NONE')),
		 NVL(UPPER(P_SCOPE),'PUBLIC'), NVL(UPPER(P_LIFECYCLE),'ACTIVE'),
		 NVL(UPPER(P_COMPATABILITY), 'S'), UPPER(P_SYNCHRO),
		 UPPER(P_DIRECTION), NVL(P_SHORT_DESCRIPTION,' ')
	    INTO nice_ctx,
      		 nice_scope, nice_lifecy,
      		 nice_compat, nice_synch,
      		 nice_direct, nice_sdescr
	    FROM DUAL;
          SELECT C.class_id, C.last_updated_by, C.last_update_date,
	        F.FUNCTION_ID
            INTO key_id, f_luby, f_ludate, fn_id
            FROM FND_IREP_CLASSES C, FND_FORM_FUNCTIONS F
           WHERE class_name = P_OBJECT_NAME
             AND F.FUNCTION_NAME = P_FUNCTION_NAME;
       	exception
          when no_data_found then
       		Select class_id, last_updated_by, last_update_date,
	  	       FND_FORM_FUNCTIONS_S.nextval, 1, 1
                  into key_id, f_luby, f_ludate, fn_id, new_fn, primary_flavor
                  from FND_IREP_CLASSES
                  where class_name = P_OBJECT_NAME;
          Insert into FND_FORM_FUNCTIONS
  	  (FUNCTION_ID, FUNCTION_NAME, CREATION_DATE, CREATED_BY,
	   LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
	   TYPE,
	   IREP_CLASS_ID, MAINTENANCE_MODE_SUPPORT, CONTEXT_DEPENDENCE,
	   IREP_METHOD_NAME, IREP_OVERLOAD_SEQUENCE, IREP_SCOPE,
           IREP_LIFECYCLE, IREP_DESCRIPTION,
	   IREP_COMPATIBILITY, IREP_SYNCHRO, IREP_DIRECTION)
	  VALUES (fn_id, P_FUNCTION_NAME, f_ludate, f_luby,
	       f_ludate, f_luby, 0,
	       DECODE(P_INDIRECT_OP_FLAG, 'Y', 'SB_INDIRECT_OP', 'INTERFACE'),
	       key_id, 'NONE', nice_ctx,
	       P_METHOD_NAME, P_OVERLOAD_SEQ, nice_scope,
	       nice_lifecy, P_DESCRIPTION,
	       nice_compat, nice_synch, nice_direct);

          Insert into FND_FORM_FUNCTIONS_TL
  	  (FUNCTION_ID, USER_FUNCTION_NAME, DESCRIPTION, language,
                   source_lang, last_update_date, last_updated_by,
                   created_by, creation_date, last_update_login
                  ) select
		    fn_id, P_USER_FN_NAME, P_SHORT_DESCRIPTION, l.language_code,
                    USERENV('LANG'), f_ludate, f_luby, f_luby, f_ludate, 0
                  from fnd_languages l
                 where l.installed_flag in ('I','B')
                   and not exists
                     (select null
			from FND_FORM_FUNCTIONS_TL t
		       where t.FUNCTION_ID = fn_id
		   	 and t.language = l.language_code);

	    -- Restore earlier saved grants
	    RESTORE_GRANTS(fn_id, P_FUNCTION_NAME);

        end;

        if (new_fn = 0) then
           if ((P_PRIMARY_FLAG = 'Y') OR (P_OVERLOAD_SEQ = 1)) then
		primary_flavor := 1;
 	   else
                primary_flavor := 0;
           end if;

           -- update function and tl
           Update FND_FORM_FUNCTIONS
	      set FUNCTION_NAME = P_FUNCTION_NAME,
           	  LAST_UPDATE_DATE = f_ludate,
		  LAST_UPDATED_BY = f_luby,
		  LAST_UPDATE_LOGIN = 0,
           	  IREP_CLASS_ID = key_id,
		  MAINTENANCE_MODE_SUPPORT = 'NONE',
		  CONTEXT_DEPENDENCE = DECODE(primary_flavor, 1,
				       UPPER(NVL(P_CTX_DEPENDENCE, 'NONE')),
				       CONTEXT_DEPENDENCE),
		  IREP_OVERLOAD_SEQUENCE = DECODE(primary_flavor, 1,
					   P_OVERLOAD_SEQ,
					   IREP_OVERLOAD_SEQUENCE),
		  IREP_SCOPE = DECODE(primary_flavor, 1,
			       NVL(UPPER(P_SCOPE), 'PUBLIC'),
			       IREP_SCOPE),
           	  IREP_LIFECYCLE = DECODE(primary_flavor, 1,
               		           NVL(UPPER(P_LIFECYCLE), 'ACTIVE'),
				   IREP_LIFECYCLE),
           	  IREP_COMPATIBILITY = DECODE(primary_flavor, 1,
               			       NVL(UPPER(P_COMPATABILITY), 'S'),
				       IREP_COMPATIBILITY),
		  IREP_SYNCHRO = DECODE(primary_flavor, 1,
				 UPPER(P_SYNCHRO),
				 IREP_SYNCHRO),
           	  IREP_DIRECTION = DECODE(primary_flavor, 1,
               			   UPPER(P_DIRECTION),
				   IREP_DIRECTION),
		  TYPE = DECODE(P_INDIRECT_OP_FLAG, 'Y',
					'SB_INDIRECT_OP',
					'INTERFACE')
           WHERE FUNCTION_ID = fn_id;

           if (primary_flavor = 1) then
                /* try to avoid ora-01461 */
                UPDATE FND_FORM_FUNCTIONS
                   SET IREP_DESCRIPTION = P_DESCRIPTION
		 WHERE FUNCTION_ID = fn_id;

	      	UPDATE FND_FORM_FUNCTIONS_TL
                   SET USER_FUNCTION_NAME = P_USER_FN_NAME,
		       DESCRIPTION = P_SHORT_DESCRIPTION,
		       last_update_date = f_ludate,
		       last_updated_by = f_luby,
		       last_update_login = 0
                 WHERE FUNCTION_ID = fn_id
		   and source_lang = USERENV('LANG');
           end if;
        end if;

        -- insert flavor
        Insert into FND_IREP_FUNCTION_FLAVORS (
            FUNCTION_ID, OVERLOAD_SEQ, SCOPE_TYPE, LIFECYCLE_MODE, DESCRIPTION,
            COMPATIBILITY_FLAG, USER_FLAVOR_NAME, SHORT_DESCRIPTION
	  ) VALUES (
	    fn_id, P_OVERLOAD_SEQ, nice_scope, nice_lifecy, P_DESCRIPTION,
            nice_compat, P_USER_FN_NAME, nice_sdescr);

      end if;
  end;


--
-- Procedure
--   UPLOAD_METHOD_CATEGORY
--
-- Purpose
--   Upload Method Category
--
PROCEDURE UPLOAD_METHOD_CATEGORY(  P_UPLOAD_MODE IN VARCHAR2,
                                   P_OBJECT_NAME IN VARCHAR2,
                                   P_DEST_TABLE IN VARCHAR2,
                                   P_FUNCTION_NAME IN VARCHAR2,
				   P_OVERLOAD_SEQ IN VARCHAR2,
				   P_TYPE IN VARCHAR2,
				   P_CODE IN VARCHAR2,
				   P_SEQUENCE IN VARCHAR2) is

  begin -- UPLOAD METHOD_CATEGORY
      if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
        return;
      end if;
      Insert into FND_LOOKUP_ASSIGNMENTS
        (OBJ_NAME, INSTANCE_PK1_VALUE, INSTANCE_PK2_VALUE,
	 LOOKUP_TYPE, LOOKUP_CODE, LOOKUP_ASSIGNMENT_ID, DISPLAY_SEQUENCE,
	 CREATED_BY, CREATION_DATE,
	 LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
        select 'FND_IREP_FUNCTION_FLAVORS', f.function_id, P_OVERLOAD_SEQ,
	       P_TYPE, P_CODE, FND_LOOKUP_ASSIGNMENTS_S.nextval, P_SEQUENCE,
	       C.LAST_UPDATED_BY, C.LAST_UPDATE_DATE,
	       C.LAST_UPDATED_BY, C.LAST_UPDATE_DATE, 0
	from FND_IREP_CLASSES C,
	     FND_FORM_FUNCTIONS F
       where c.class_name = P_OBJECT_NAME
	 and f.irep_class_id = c.class_id
         and f.function_name = P_FUNCTION_NAME;
  end;



--
-- Procedure
--   UPLOAD_METHOD_CHILD_ANNOTATION
--
-- Purpose
--   Upload Method Child Annotation
--
PROCEDURE UPLOAD_METHOD_CHILD_ANNOTATION(P_UPLOAD_MODE IN VARCHAR2,
                                   	 P_OBJECT_NAME IN VARCHAR2,
                                   	 P_DEST_TABLE IN VARCHAR2,
                                   	 P_FUNCTION_NAME IN VARCHAR2,
                                   	 P_OVERLOAD_SEQ IN VARCHAR2,
				   	 P_CHILD_FLAG IN VARCHAR2,
				   	 P_VALUE IN VARCHAR2) is

  begin -- UPLOAD METHOD_CHILD_ANNOTATIONS
      if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
        return;
      end if;

      Insert into FND_CHILD_ANNOTATIONS
        (PARENT_ID, PARENT_ID2, PARENT_FLAG, CHILD_FLAG, ANNOTATION_VALUE)
        select f.function_id, P_OVERLOAD_SEQ, 'F', UPPER(P_CHILD_FLAG), P_VALUE
        from FND_IREP_CLASSES C,
             FND_FORM_FUNCTIONS F
       where c.class_name = P_OBJECT_NAME
         and f.irep_class_id = c.class_id
         and f.function_name = P_FUNCTION_NAME;
  end;


--
-- Procedure
--   UPLOAD_PARAMS
--
-- Purpose
--   Upload Parameters
--
PROCEDURE UPLOAD_PARAMS(   P_UPLOAD_MODE IN VARCHAR2,
                           P_OBJECT_NAME IN VARCHAR2,
                           P_DEST_TABLE IN VARCHAR2,
                           P_FUNCTION_NAME IN VARCHAR2,
                           P_OVERLOAD_SEQ IN VARCHAR2,
			   P_SEQUENCE IN VARCHAR2,
			   P_INNERTYPE_SEQUENCE IN VARCHAR2,
			   P_NAME IN VARCHAR2,
			   P_DIRECTION IN VARCHAR2,
			   P_OPTIONAL IN VARCHAR2,
			   P_TYPE IN VARCHAR2,
			   P_PRECISION IN VARCHAR2,
			   P_SIZE IN VARCHAR2,
			   P_SCALE IN VARCHAR2,
			   P_NULL_ALLOWED IN VARCHAR2,
			   P_DESCRIPTION IN VARCHAR2,
			   P_DEFAULT_VALUE IN VARCHAR2,
			   P_DISPLAYED IN VARCHAR2,
			   P_ATTRIBUTE_SET IN VARCHAR2) is

      fn_id 	  number;
      nice_direct varchar2(1);
      nice_option varchar2(1);
      nice_nullok varchar2(1);
      nice_dispfl varchar2(1);

  begin
      if PARENT_IS_OBSOLETE(P_DEST_TABLE, P_OBJECT_NAME) then
        return;
      end if;

      SELECT f.function_id, UPPER(P_DIRECTION), UPPER(NVL(P_OPTIONAL,'N')),
	     UPPER(P_NULL_ALLOWED), NVL(P_DISPLAYED, 'Y')
        INTO fn_id, nice_direct, nice_option,
	     nice_nullok, nice_dispfl
        FROM FND_IREP_CLASSES C,
             FND_FORM_FUNCTIONS F
       WHERE C.CLASS_NAME = P_OBJECT_NAME
         AND F.IREP_CLASS_ID = C.CLASS_ID
         AND F.FUNCTION_NAME = P_FUNCTION_NAME;

      Insert into FND_PARAMETERS
        (FUNCTION_ID, PARAM_SEQUENCE, INNERTYPE_SEQUENCE, PARAM_NAME,
	 PARAM_DIRECTION, PARAM_OPTIONAL, PARAMETER_TYPE, PARAM_PRECISION,
	 NULL_ALLOWED, DESCRIPTION, DEFAULT_VALUE,
	 DISPLAYED_FLAG, FN_OVERLOAD_SEQUENCE, PARAM_SCALE, ATTRIBUTE_SET
	) VALUES (
         fn_id, P_SEQUENCE, P_INNERTYPE_SEQUENCE, P_NAME,
	 nice_direct, nice_option, P_TYPE, P_PRECISION,
	 nice_nullok, P_DESCRIPTION, P_DEFAULT_VALUE,
	 nice_dispfl, P_OVERLOAD_SEQ, P_SCALE, P_ATTRIBUTE_SET
        );
  end;


--
-- Procedure
--   iRepPostProcess
--
-- Purpose
--   Do various post processing to irep data.  Currently just denormalizes
-- inherited methods into child classes.  This is called from the post
-- processing java code which does various other post processing (such as
-- updating schema entries).
--

PROCEDURE iRepPostProcess as

Begin
  /* Keep copying methods to inheriting classes until no more to copy */
  LOOP
    Insert into FND_FORM_FUNCTIONS (
        irep_class_id,
        function_id,
        function_name,
        CREATION_DATE, CREATED_BY,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
        TYPE,
        MAINTENANCE_MODE_SUPPORT, CONTEXT_DEPENDENCE,
        IREP_METHOD_NAME, IREP_OVERLOAD_SEQUENCE,
        IREP_SCOPE, IREP_LIFECYCLE,
        IREP_DESCRIPTION, IREP_COMPATIBILITY,
        IREP_SYNCHRO, IREP_DIRECTION)
        select child_c.class_id,
              fnd_form_functions_s.nextval,
              child_c.class_name || ':' || parent_m.irep_method_name,
              sysdate, parent_m.CREATED_BY,
              sysdate, parent_m.LAST_UPDATED_BY, parent_m.LAST_UPDATE_LOGIN,
              parent_m.TYPE,
              parent_m.MAINTENANCE_MODE_SUPPORT, parent_m.CONTEXT_DEPENDENCE,
              parent_m.IREP_METHOD_NAME, parent_m.IREP_OVERLOAD_SEQUENCE,
              parent_m.IREP_SCOPE, parent_m.IREP_LIFECYCLE,
              parent_m.IREP_DESCRIPTION, parent_m.IREP_COMPATIBILITY,
              parent_m.IREP_SYNCHRO, parent_m.IREP_DIRECTION
          from  fnd_irep_class_parent_assigns ass,
              fnd_irep_classes parent_c,
              fnd_irep_classes child_c,
              fnd_form_functions parent_m
            where ass.Parent_class_name = Parent_c.class_name
              and ass.Class_name =  Child_c.class_name
              and parent_m.irep_class_id = parent_c.class_id
              and not exists (
                select 1
                  from fnd_form_functions child_m
                 where child_m.irep_class_id = child_c.class_id
                   and child_m.function_name =
                      child_c.class_name || ':' || parent_m.irep_method_name);

      EXIT WHEN (SQL%ROWCOUNT=0);
  END LOOP;

  /* Insert TL shadow rows (for newly created base rows) */
  Insert into FND_FORM_FUNCTIONS_TL (
        FUNCTION_ID, USER_FUNCTION_NAME,
        DESCRIPTION, language,
        source_lang, last_update_date,
        last_updated_by, created_by,
        creation_date, last_update_login)
     select child_m.function_id, parent_tl.user_function_name,
            parent_tl.description, parent_tl.language,
            parent_tl.source_lang, sysdate,
            parent_tl.last_updated_by, parent_tl.created_by,
            sysdate, parent_tl.last_update_login
      from  fnd_irep_class_parent_assigns ass,
            fnd_irep_classes parent_c,
            fnd_irep_classes child_c,
            fnd_form_functions parent_m,
            fnd_form_functions child_m,
            fnd_form_functions_tl parent_tl
      where ass.Parent_class_name = Parent_c.class_name
        and ass.Class_name =  Child_c.class_name
        and parent_m.irep_class_id = parent_c.class_id
        and child_m.irep_class_id = child_c.class_id
        and child_m.function_name =
		child_c.class_name || ':' || parent_m.irep_method_name
        and parent_tl.function_id = parent_m.function_id
        and not exists (
              select 1
                from fnd_form_functions_tl child_tl
               where child_tl.function_id = child_m.function_id
                 and child_tl.source_lang = parent_tl.source_lang
                 and child_tl.language = parent_tl.language);

  DELETE_COLLECTION();
  end;

procedure ADD_LANGUAGE
is
begin

  insert into FND_IREP_CLASSES_TL (
    CLASS_ID,
    DISPLAY_NAME,
    SHORT_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_LOGIN
  ) select
    B.CLASS_ID,
    B.DISPLAY_NAME,
    B.SHORT_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_LOGIN
  from FND_IREP_CLASSES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_IREP_CLASSES_TL T
    where T.CLASS_ID = B.CLASS_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

PROCEDURE GET_DELETE_GRANTS(key_id IN NUMBER) IS
error1 varchar2(300);
  BEGIN
    -- Start Initialize Collections
    v_fnd_menu_entries:= t_fnd_menu_entries();
    v_fnd_menu_entries_tl := t_fnd_menu_entries_tl();
    v_fnd_menus := t_fnd_menus();
    v_fnd_menus_tl := t_fnd_menus_tl();
    v_fnd_grants := t_fnd_grants();

    SELECT *bulk collect
    INTO v_fnd_form_functions
    FROM fnd_form_functions
    WHERE irep_class_id = key_id;


    if v_fnd_form_functions is not null and v_fnd_form_functions.count > 0 then
    FOR i IN v_fnd_form_functions.FIRST .. v_fnd_form_functions.LAST
    LOOP
      function_id := v_fnd_form_functions(i).function_id;

      IF v_fnd_form_functions(i).function_id IS NOT NULL THEN


        -- temp table values are in v_fnd_menu_entries_new
        SELECT *bulk collect
        INTO v_fnd_menu_entries_new
        FROM fnd_menu_entries
        WHERE function_id = v_fnd_form_functions(i).function_id;

        -- appended table values are in v_fnd_menu_entries
        v_fnd_menu_entries.extend(1);
        menu_entry_count := v_fnd_menu_entries.last;

        if v_fnd_menu_entries_new is not null and v_fnd_menu_entries_new.count > 0 then

        FOR k IN v_fnd_menu_entries_new.FIRST .. v_fnd_menu_entries_new.LAST
        LOOP
        v_fnd_menu_entries(menu_entry_count) := v_fnd_menu_entries_new(k);
        v_fnd_menu_entries.extend(1);
        menu_entry_count :=menu_entry_count+1;
        end loop;

        end if;

        IF v_fnd_menu_entries_new.COUNT > 0 THEN
          FOR j IN v_fnd_menu_entries_new.FIRST .. v_fnd_menu_entries_new.LAST
          LOOP
            IF v_fnd_menu_entries_new(j).menu_id IS NOT NULL THEN

              SELECT *bulk collect
              INTO v_fnd_menu_entries_tl_new
              FROM fnd_menu_entries_tl
              WHERE menu_id = v_fnd_menu_entries_new(j).menu_id;

               v_fnd_menu_entries_tl.extend(1);
	       menu_entry_tl_count := v_fnd_menu_entries_tl.last;
               if v_fnd_menu_entries_tl_new is not null and v_fnd_menu_entries_tl_new.count > 0 then

               FOR k IN v_fnd_menu_entries_tl_new.FIRST .. v_fnd_menu_entries_tl_new.LAST
               LOOP
		 v_fnd_menu_entries_tl(menu_entry_tl_count) := v_fnd_menu_entries_tl_new(k);
                 v_fnd_menu_entries_tl.extend(1);
                 menu_entry_tl_count :=menu_entry_tl_count+1;
               end loop;

               end if;

              SELECT *bulk collect
              INTO v_fnd_menus_new
              FROM fnd_menus
              WHERE menu_id = v_fnd_menu_entries_new(j).menu_id;

               v_fnd_menus.extend(1);
               menu_count := v_fnd_menus.last;

               if v_fnd_menus_new is not null and v_fnd_menus_new.count > 0 then

               FOR k IN v_fnd_menus_new.FIRST .. v_fnd_menus_new.LAST
               LOOP
                 v_fnd_menus(menu_count) := v_fnd_menus_new(k);
                 v_fnd_menus.extend(1);
                 menu_count :=menu_count+1;
               end loop;

              end if;
              FOR l IN v_fnd_menus_new.FIRST .. v_fnd_menus_new.LAST
              LOOP

                IF v_fnd_menus_new(l).menu_id IS NOT NULL THEN

                  SELECT *bulk collect
                  INTO v_fnd_menus_tl_new
                  FROM fnd_menus_tl
                  WHERE menu_id = v_fnd_menus_new(l).menu_id;

                  v_fnd_menus_tl.extend(1);
                  menu_tl_count := v_fnd_menus_tl.last;

                  if v_fnd_menus_tl_new is not null and v_fnd_menus_tl_new.count > 0 then
                  FOR k IN v_fnd_menus_tl_new.FIRST .. v_fnd_menus_tl_new.LAST
                  LOOP
		    v_fnd_menus_tl(menu_tl_count) := v_fnd_menus_tl_new(k);
                    v_fnd_menus_tl.extend(1);
                    menu_tl_count :=menu_tl_count+1;
                  end loop;
                  end if ;
                  SELECT *bulk collect
                  INTO v_fnd_grants_new
                  FROM fnd_grants
                  WHERE menu_id = v_fnd_menus_new(l).menu_id;

                  v_fnd_grants.extend(1);
		  grants_count := v_fnd_grants.last;

                 if v_fnd_grants_new is not null and v_fnd_grants_new.count > 0 then
                  FOR k IN v_fnd_grants_new.FIRST .. v_fnd_grants_new.LAST
                  LOOP
                    v_fnd_grants(grants_count) := v_fnd_grants_new(k);
                    v_fnd_grants.extend(1);
                    grants_count :=grants_count+1;
                 end loop;
                 end if;

                  FOR k IN v_fnd_grants_new.FIRST .. v_fnd_grants_new.LAST
                  LOOP
                    -- remove grants
                    fnd_grants_pkg.delete_row(v_fnd_grants_new(k).grant_guid);
                  END LOOP;

                END IF;

                -- remove menus
                fnd_menus_pkg.delete_row(v_fnd_menus_new(l).menu_id);

              END LOOP;
            END IF;

            -- remove menu_entries
            fnd_menu_entries_pkg.delete_row(v_fnd_menu_entries_new(j).menu_id,   v_fnd_menu_entries(j).entry_sequence);

          END LOOP;
        END IF;

      END IF;

      -- remove fucntions
      fnd_form_functions_pkg.delete_row(v_fnd_form_functions(i).function_id);

    END LOOP;
    end if;


--EXCEPTION
--  WHEN others THEN
--    DBMS_OUTPUT.PUT_LINE(sqlerrm);
--IF sqlerrm IS NOT NULL THEN
--  ROLLBACK;
--ELSE
--  COMMIT;
--END IF;

END GET_DELETE_GRANTS;

-- Restore grants,menus, menu entries
PROCEDURE RESTORE_GRANTS(f_id IN NUMBER,   f_name IN VARCHAR) IS

  t_menu_id fnd_menus.menu_id%TYPE;
  l_grant_guid raw(16);
  error1 varchar2(300);
  BEGIN
   --t_menu_id := fnd_menus_s.nextval;
    select fnd_menus_s.nextval into t_menu_id from dual;
    IF v_fnd_form_functions is not null and v_fnd_form_functions.COUNT > 0 THEN

    FOR i IN v_fnd_form_functions.FIRST .. v_fnd_form_functions.LAST
    LOOP
      IF v_fnd_form_functions(i).function_name = f_name THEN

      IF v_fnd_menu_entries is not null and v_fnd_menu_entries.count > 0 then

        FOR k IN v_fnd_menu_entries.FIRST .. v_fnd_menu_entries.LAST
        LOOP

          IF v_fnd_menu_entries(k).function_id = v_fnd_form_functions(i).function_id THEN

	    FOR j IN v_fnd_menu_entries_tl.FIRST .. v_fnd_menu_entries_tl.LAST
            LOOP

              IF v_fnd_menu_entries_tl(j).menu_id = v_fnd_menu_entries(k).menu_id THEN

                fnd_menu_entries_pkg.insert_row(x_rowid,
		                               t_menu_id,
					       v_fnd_menu_entries(k).entry_sequence,
					       v_fnd_menu_entries(k).sub_menu_id,
					       f_id,
					       v_fnd_menu_entries(k).grant_flag,
					       v_fnd_menu_entries_tl(j).PROMPT,
					       v_fnd_menu_entries_tl(j).description,
					       v_fnd_menu_entries(k).creation_date,
					       v_fnd_menu_entries(k).created_by,
					       v_fnd_menu_entries(k).last_update_date,
					       v_fnd_menu_entries(k).last_updated_by,
					       v_fnd_menu_entries(k).last_update_login);
                EXIT
                WHEN v_fnd_menu_entries_tl(j).menu_id = v_fnd_menu_entries(k).menu_id;

              END IF;

            END LOOP;
            IF v_fnd_menus is not null and v_fnd_menus.COUNT > 0 THEN
              FOR m IN v_fnd_menus.FIRST .. v_fnd_menus.LAST
              LOOP

		    IF v_fnd_menus(m).menu_id = v_fnd_menu_entries(k).menu_id THEN

		       FOR j IN v_fnd_menus_tl.FIRST .. v_fnd_menus_tl.LAST
		       LOOP

			  IF v_fnd_menus_tl(j).menu_id = v_fnd_menus(m).menu_id THEN

			   fnd_menus_pkg.insert_row(x_rowid,
			                            t_menu_id,
						    'FND_FUNCTION_'||f_id,
						    v_fnd_menus_tl(j).user_menu_name,
						    v_fnd_menus(m).type,
						    v_fnd_menus_tl(j).description,
						    v_fnd_menus(m).creation_date,
						    v_fnd_menus(m).created_by,
						    v_fnd_menus(m).last_update_date,
						    v_fnd_menus(m).last_updated_by,
						    v_fnd_menus(m).last_update_login);

			   EXIT
			   WHEN v_fnd_menus_tl(j).menu_id = v_fnd_menus(m).menu_id;

			  END IF;

		       END LOOP;

		       IF v_fnd_grants is not null and v_fnd_grants.COUNT > 0 THEN

			       FOR l IN v_fnd_grants.FIRST .. v_fnd_grants.LAST
			       LOOP

				IF v_fnd_grants(l).menu_id = v_fnd_menus(m).menu_id THEN

				  SELECT sys_guid()
				  INTO l_grant_guid
				  FROM dual;

				  fnd_grants_pkg.insert_row(x_rowid,
				                            l_grant_guid,
							    v_fnd_grants(l).grantee_type,
							    v_fnd_grants(l).grantee_key,
							    t_menu_id,
							    v_fnd_grants(l).start_date,
							    v_fnd_grants(l).end_date,
							    v_fnd_grants(l).object_id,
							    v_fnd_grants(l).instance_type,
							    v_fnd_grants(l).instance_set_id,
							    v_fnd_grants(l).instance_pk1_value,
							    v_fnd_grants(l).instance_pk2_value,
							    v_fnd_grants(l).instance_pk3_value,
							    v_fnd_grants(l).instance_pk4_value,
							    v_fnd_grants(l).instance_pk5_value,
							    v_fnd_grants(l).program_name,
							    v_fnd_grants(l).program_tag,
							    v_fnd_grants(l).creation_date,
							    v_fnd_grants(l).created_by,
							    v_fnd_grants(l).last_update_date,
							    v_fnd_grants(l).last_updated_by,
							    v_fnd_grants(l).last_update_login,
							    v_fnd_grants(l).parameter1,
							    v_fnd_grants(l).parameter2,
							    v_fnd_grants(l).parameter3,
							    v_fnd_grants(l).parameter4,
							    v_fnd_grants(l).parameter5,
							    v_fnd_grants(l).parameter6,
							    v_fnd_grants(l).parameter7,
							    v_fnd_grants(l).parameter8,
							    v_fnd_grants(l).parameter9,
							    v_fnd_grants(l).parameter10,
							    v_fnd_grants(l).ctx_secgrp_id,
							    v_fnd_grants(l).ctx_resp_id,
							    v_fnd_grants(l).ctx_resp_appl_id,
							    v_fnd_grants(l).ctx_org_id,
							    v_fnd_grants(l).name,
							    v_fnd_grants(l).description);

				END IF;

			       END LOOP;
		       END IF;

		       -- GRANTS

		    END IF;

             END LOOP; --END MENUS
          END IF;


       END IF;

     END LOOP;  -- MENU ENTRIES
  END IF;


END IF;

END LOOP; --FUCNTION CHECK

END IF;


 -- FUNCTION

--EXCEPTION
--WHEN others THEN
--DBMS_OUTPUT.PUT_LINE(sqlerrm);
--IF sqlerrm IS NOT NULL THEN
--ROLLBACK;
--ELSE
--COMMIT;
--END IF;

END RESTORE_GRANTS;


end FND_IREP_LOADER_PRIVATE;


/
