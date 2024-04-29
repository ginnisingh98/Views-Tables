--------------------------------------------------------
--  DDL for Package Body GL_ELIMINATION_JOURNALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ELIMINATION_JOURNALS_PKG" As
/* $Header: gliejoub.pls 120.3 2005/05/05 01:06:58 kvora ship $ */

  ---
  --- PRIVATE VARIABLES
  ---

  --- Position of the balancing segment
  company_seg_num	NUMBER := null;


  -- Function
  --   get_unique_id
  -- Purpose
  --   Returns nextval from gl_elimination_journals_s
  -- Parameters
  --   None
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER IS

    CURSOR get_new_id IS
      SELECT gl_elimination_journals_s.NEXTVAL
      FROM dual;
    new_id number;

  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_ELIMINATION_JOURNALS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION

    WHEN app_exceptions.application_exception THEN
      RAISE;

    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_elimination_journals_pkg.get_unique_id');
      RAISE;
  END get_unique_id;


  --
  -- Procedure
  --   get_category_name
  --
  -- Purpose
  --   Gets the user category name for the given category
  --
  -- History
  --   05-Nov-98  W Wong 	Created
  --
  -- Arguments
  --   x_category_name		JE Category name
  --
  FUNCTION get_category_name(
	      x_category_name				VARCHAR2
	   ) RETURN VARCHAR2 IS

    user_cat_name VARCHAR2(26);

  BEGIN

    SELECT user_je_category_name
    INTO   user_cat_name
    FROM   GL_JE_CATEGORIES
    WHERE  je_category_name = x_category_name;

    RETURN(user_cat_name);

  END get_category_name;


  --
  -- Procedure
  --   Check_unique_name
  -- Purpose
  --   Unique check for name
  -- History
  --   05-Nov-98  W Wong 	Created
  -- Parameters
  --   x_rowid		Rowid
  --   x_setid		Elimination Set ID
  --   x_name  		Journal name
  --
  -- Notes
  --   None
  --
  PROCEDURE check_unique_name(X_rowid VARCHAR2,
			      X_setid NUMBER,
                              X_name  VARCHAR2) IS
    counter NUMBER;

    CURSOR name_count IS
       SELECT 1
       FROM DUAL
       WHERE EXISTS (SELECT 1
                     FROM  gl_elimination_journals
                     WHERE journal_name = X_name
		     AND   elimination_set_id = X_setid
                     AND   ((X_rowid IS NULL) OR (rowid <> X_rowid)));
  BEGIN

    OPEN name_count;
    FETCH name_count INTO counter;

    IF name_count%FOUND THEN
      CLOSE name_count;
      FND_MESSAGE.set_name('SQLGL', 'GL_DUPLICATE_NAME');
      APP_EXCEPTION.raise_exception;

    ELSE
      CLOSE name_count;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_elimination_sets_pkg.check_unique_name');
      RAISE;
  END check_unique_name;

End gl_elimination_journals_pkg;

/
