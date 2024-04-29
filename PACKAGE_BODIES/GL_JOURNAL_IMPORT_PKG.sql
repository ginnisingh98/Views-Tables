--------------------------------------------------------
--  DDL for Package Body GL_JOURNAL_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JOURNAL_IMPORT_PKG" as
/* $Header: glujimnb.pls 120.5.12010000.2 2011/09/28 10:01:59 sommukhe ship $ */

  -- Indicates the point in which a create_table statement failed.
  failpoint  NUMBER := 0;

  -- Buffer used for the create table and create index statements
  cre_tab    VARCHAR2(2000);


  PROCEDURE create_table(table_name 			VARCHAR2,
                         tablespace 			VARCHAR2 DEFAULT NULL,
                         physical_attributes 		VARCHAR2 DEFAULT NULL,
			 create_n1_index		BOOLEAN DEFAULT TRUE,
			 n1_tablespace			VARCHAR2 DEFAULT NULL,
			 n1_physical_attributes		VARCHAR2 DEFAULT NULL,
			 create_n2_index		BOOLEAN DEFAULT TRUE,
			 n2_tablespace			VARCHAR2 DEFAULT NULL,
			 n2_physical_attributes		VARCHAR2 DEFAULT NULL,
			 create_n3_index		BOOLEAN DEFAULT FALSE,
			 n3_tablespace			VARCHAR2 DEFAULT NULL,
			 n3_physical_attributes		VARCHAR2 DEFAULT NULL
                        ) IS
    ind_name  VARCHAR2(30);
    fnd_schema VARCHAR2(30);
    dummy1    VARCHAR2(30);
    dummy2    VARCHAR2(30);
  BEGIN
    failpoint := 1;
    cre_tab :=
      'CREATE TABLE ' || table_name;

    IF (tablespace IS NOT NULL) THEN
      cre_tab := cre_tab ||
        ' TABLESPACE ' || tablespace;
    END IF;

    IF (physical_attributes IS NOT NULL) THEN
      cre_tab := cre_tab || ' ' || physical_attributes;
    END IF;

    cre_tab := cre_tab ||
      ' AS SELECT * FROM GL_INTERFACE WHERE ROWNUM < 1';

    failpoint := 2;
    IF (NOT fnd_installation.get_app_info('FND',
              dummy1,dummy2,fnd_schema)) THEN
      RAISE CANNOT_GET_APPLSYS_SCHEMA;
    END IF;

    IF (fnd_schema IS NULL) THEN
      RAISE CANNOT_GET_APPLSYS_SCHEMA;
    END IF;

    failpoint := 1;
    ad_ddl.do_ddl( fnd_schema,
                   'SQLGL',
                   AD_DDL.CREATE_TABLE,
                   cre_tab,
                   table_name );

    failpoint := 3;
    IF (create_n1_index) THEN
      ind_name := substrb(table_name, 1, 27) || '_n1';
      cre_tab :=
        'CREATE INDEX ' || ind_name || ' ON ' || table_name ||
        '  (user_je_source_name, group_id) ';

      IF (n1_tablespace IS NOT NULL) THEN
        cre_tab := cre_tab ||
          ' TABLESPACE ' || n1_tablespace;
      END IF;

      IF (n1_physical_attributes IS NOT NULL) THEN
        cre_tab := cre_tab ||
          ' ' || n1_physical_attributes;
      END IF;

      ad_ddl.do_ddl( fnd_schema,
                     'SQLGL',
                     AD_DDL.CREATE_INDEX,
                     cre_tab,
                     ind_name );

    END IF;

    failpoint := 4;
    IF (create_n2_index) THEN
      ind_name := substrb(table_name, 1, 27) || '_n2';

      cre_tab :=
        'CREATE INDEX ' || ind_name || ' ON ' || table_name ||
        '  (request_id, je_header_id, status, code_combination_id) ';

      IF (n2_tablespace IS NOT NULL) THEN
        cre_tab := cre_tab ||
          ' TABLESPACE ' || n2_tablespace;
      END IF;

      IF (n2_physical_attributes IS NOT NULL) THEN
        cre_tab := cre_tab ||
          ' ' || n2_physical_attributes;
      END IF;

      ad_ddl.do_ddl( fnd_schema,
                     'SQLGL',
                     AD_DDL.CREATE_INDEX,
                     cre_tab,
                     ind_name );

    END IF;

    failpoint := 5;

    IF (create_n3_index) THEN

      ind_name := substrb(table_name, 1, 27) || '_n3';

      cre_tab :=
        'CREATE INDEX ' || ind_name || ' ON ' || table_name ||
        '  (je_header_id) ';

      IF (n3_tablespace IS NOT NULL) THEN
        cre_tab := cre_tab ||
          ' TABLESPACE ' || n3_tablespace;
      END IF;

      IF (n3_physical_attributes IS NOT NULL) THEN
        cre_tab := cre_tab ||
          ' ' || n3_physical_attributes;
      END IF;

      ad_ddl.do_ddl( fnd_schema,
                     'SQLGL',
                     AD_DDL.CREATE_INDEX,
                     cre_tab,
                     ind_name );

    END IF;

    failpoint := 0;
  END create_table;

  PROCEDURE drop_table(table_name 			VARCHAR2) IS
    fnd_schema VARCHAR2(30);
    dummy1    VARCHAR2(30);
    dummy2    VARCHAR2(30);
  BEGIN
    failpoint := 2;
    IF (NOT fnd_installation.get_app_info('FND',
              dummy1,dummy2,fnd_schema)) THEN
      RAISE CANNOT_GET_APPLSYS_SCHEMA;
    END IF;

    IF (fnd_schema IS NULL) THEN
      RAISE CANNOT_GET_APPLSYS_SCHEMA;
    END IF;

    failpoint := 1;
    cre_tab :=
      'DROP TABLE ' || table_name;

    ad_ddl.do_ddl( fnd_schema,
                   'SQLGL',
                   AD_DDL.DROP_TABLE,
                   cre_tab,
                   table_name );

  END drop_table;

  PROCEDURE populate_interface_control(
              user_je_source_name	VARCHAR2,
	      group_id			IN OUT NOCOPY 	NUMBER,
              set_of_books_id           NUMBER,
              interface_run_id 		IN OUT NOCOPY  NUMBER,
	      table_name 	       	VARCHAR2 DEFAULT NULL,
              processed_data_action   	VARCHAR2 DEFAULT NULL) IS
    je_source_name VARCHAR2(25);
  BEGIN

    BEGIN
      SELECT je_source_name
      INTO je_source_name
      FROM gl_je_sources
      WHERE user_je_source_name
        = populate_interface_control.user_je_source_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE INVALID_JE_SOURCE;
    END;

    IF (processed_data_action NOT IN (SAVE_DATA, DELETE_DATA,
                                      DROP_INTERFACE_TABLE, NULL)) THEN
      RAISE INVALID_PROCESSED_ACTION;
    END IF;

    IF (    (processed_data_action = DROP_INTERFACE_TABLE)
        AND (nvl(upper(table_name),'GL_INTERFACE') = 'GL_INTERFACE')) THEN
      RAISE CANNOT_DROP_GL_INTERFACE;
    END IF;

    IF (group_id IS NULL) THEN
      SELECT gl_interface_control_s.NEXTVAL
      INTO group_id
      FROM DUAL;
    END IF;

    IF (interface_run_id IS NULL) THEN
      SELECT gl_journal_import_s.NEXTVAL
      INTO interface_run_id
      FROM DUAL;
    END IF;

    INSERT INTO gl_interface_control
    (status, je_source_name,
     group_id, set_of_books_id,
     interface_run_id, interface_table_name, processed_table_code)
    VALUES
    ('S', populate_interface_control.je_source_name,
     populate_interface_control.group_id,
     populate_interface_control.set_of_books_id,
     populate_interface_control.interface_run_id,
     table_name, processed_data_action);

  END populate_interface_control;

  FUNCTION get_last_sql RETURN VARCHAR2 IS
  BEGIN
    RETURN (cre_tab);
  END get_last_sql;

  FUNCTION get_error_msg RETURN VARCHAR2 IS
  BEGIN
    RETURN(ad_ddl.error_buf);
  END get_error_msg;

END GL_JOURNAL_IMPORT_PKG;

/
