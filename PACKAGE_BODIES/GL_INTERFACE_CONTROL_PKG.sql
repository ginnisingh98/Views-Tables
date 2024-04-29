--------------------------------------------------------
--  DDL for Package Body GL_INTERFACE_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_INTERFACE_CONTROL_PKG" AS
/* $Header: glijictb.pls 120.8 2005/06/17 23:21:53 djogg ship $ */

--
-- PUBLIC FUNCTIONS
--

  FUNCTION get_unique_id RETURN NUMBER IS
    new_id number;
  BEGIN
    SELECT gl_interface_control_s.NEXTVAL
    INTO new_id
    FROM dual;

    return(new_id);
  END get_unique_id;

  FUNCTION get_unique_run_id RETURN NUMBER IS
    new_id number;
  BEGIN
    SELECT gl_journal_import_s.NEXTVAL
    INTO new_id
    FROM dual;

    return(new_id);
  END get_unique_run_id;

  PROCEDURE check_unique(x_interface_run_id    NUMBER,
			 x_user_je_source_name VARCHAR2,
			 x_je_source_name      VARCHAR2,
			 x_ledger_id	       NUMBER,
			 x_group_id            NUMBER DEFAULT NULL,
                         row_id                VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_INTERFACE_CONTROL ic
      WHERE  ic.interface_run_id  = x_interface_run_id
      AND    ic.je_source_name    = x_je_source_name
      AND    ic.set_of_books_id   = x_ledger_id
      AND    nvl(ic.group_id,-1)  = nvl(x_group_id, -1)
      AND    (   row_id is null
              OR ic.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      IF (x_group_id IS NULL) THEN
        fnd_message.set_name('SQLGL', 'GL_DUPLICATE_JI_SOURCE');
      ELSE
        fnd_message.set_name('SQLGL', 'GL_DUPLICATE_JI_SOURCE_COMBO');
      END IF;
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_interface_pkg.check_unique');
      RAISE;
  END check_unique;

  FUNCTION used_in_alternate_table(
             x_int_je_source_name VARCHAR2) RETURN VARCHAR2 IS
    CURSOR chk_usage is
      SELECT 'Other table'
      FROM   GL_JE_SOURCES s, GL_INTERFACE_CONTROL ic
      WHERE  (    (    s.user_je_source_name = x_int_je_source_name
                   AND s.import_using_key_flag = 'N')
               OR (    s.je_source_key = x_int_je_source_name
                   AND s.import_using_key_flag = 'Y'))
      AND    ic.je_source_name     = s.je_source_name
      AND    ic.status            <> 'S'
      AND    nvl(upper(ic.interface_table_name), 'GL_INTERFACE')
               <> 'GL_INTERFACE';
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_usage;
    FETCH chk_usage INTO dummy;

    IF chk_usage%FOUND THEN
      CLOSE chk_usage;
      RETURN('Y');
    ELSE
      CLOSE chk_usage;
      RETURN('N');
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                       'gl_interface_control_pkg.used_in_alternate_table');
      RAISE;
  END used_in_alternate_table;

  FUNCTION get_interface_table(
             x_int_je_source_name VARCHAR2,
             x_group_id            NUMBER) RETURN VARCHAR2 IS
    CURSOR get_table is
      SELECT interface_table_name
      FROM   GL_JE_SOURCES s, GL_INTERFACE_CONTROL ic
      WHERE  (    (    s.user_je_source_name = x_int_je_source_name
                   AND s.import_using_key_flag = 'N')
               OR (    s.je_source_key = x_int_je_source_name
                   AND s.import_using_key_flag = 'Y'))
      AND    ic.je_source_name     = s.je_source_name
      AND    ic.group_id           = x_group_id
      AND    ic.status            <> 'S';
    itable VARCHAR2(30);
  BEGIN

    OPEN get_table;
    FETCH get_table INTO itable;

    IF get_table%FOUND THEN
      CLOSE get_table;
      RETURN(itable);
    ELSE
      CLOSE get_table;
      RETURN('GL_INTERFACE');
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                       'gl_interface_control_pkg.get_interface_table');
      RAISE;
  END get_interface_table;

  PROCEDURE insert_row(xinterface_run_id NUMBER,
		       xje_source_name   VARCHAR2,
                       xledger_id        NUMBER,
                       xgroup_id         NUMBER,
		       xpacket_id	 NUMBER DEFAULT NULL) IS
    CURSOR C IS
           SELECT rowid
           FROM gl_interface_control
           WHERE interface_run_id  = xinterface_run_id
	   AND   je_source_name    = xje_source_name
           AND   set_of_books_id   = xledger_id
           AND   nvl(group_id, -1) = nvl(xgroup_id, -1);

    X_Rowid VARCHAR2(18);
  BEGIN

    -- Do the insert
    INSERT INTO gl_interface_control(
      interface_run_id,
      je_source_name,
      set_of_books_id,
      group_id,
      status,
      packet_id
    ) VALUES (
      xinterface_run_id,
      xje_source_name,
      xledger_id,
      xgroup_id,
      'S',
      xpacket_id
    );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;
  END insert_row;

END gl_interface_control_pkg;

/
