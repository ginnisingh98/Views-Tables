--------------------------------------------------------
--  DDL for Package Body GL_MOVEMERGE_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_MOVEMERGE_REQUESTS_PKG" As
/* $Header: glimmrqb.pls 120.9 2005/08/18 06:54:43 adesu ship $ */
  --
  --
  -- PRIVATE DATA DECLARATIONS
  --

  -- Throw away number value
  dumdum NUMBER;

  --
  -- PRIVATE METHODS
  --

  --
  -- Function
  --  get_unique_id
  -- Purpose
  --  returns nextval from gl_movemerge_requests_s
  -- Parameters
  --  None
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_movemerge_requests_s.NEXTVAL
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
      fnd_message.set_token('SEQUENCE', 'GL_MOVEMERGE_REQUESTS_S');
      app_exception.raise_exception;
    END IF;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_movemerge_requests_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  --
  -- PUBLIC METHODS
  --

  PROCEDURE must_have_accounts (mm_id IN NUMBER) IS
    CURSOR count_rows IS
      SELECT 1
      FROM DUAL
      WHERE EXISTS (SELECT 1
                    FROM gl_movemerge_accounts
                    WHERE movemerge_request_id = mm_id);
  BEGIN
    OPEN count_rows;
    FETCH count_rows INTO dumdum;
    IF count_rows%NOTFOUND THEN
      CLOSE count_rows;
      FND_MESSAGE.set_name('SQLGL', 'GL_MM_REQUEST_WITHOUT_ACCOUNTS');
      APP_EXCEPTION.raise_exception;
    ELSE
      CLOSE count_rows;
    END IF;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_mmwkb_pkg.must_have_accounts');
      RAISE;
  END must_have_accounts;


  PROCEDURE delete_all_accounts (mm_id IN NUMBER) IS
  BEGIN
    DELETE FROM gl_movemerge_accounts
    WHERE movemerge_request_id = mm_id;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_movemerge_requests_pkg.delete_all_accounts');
      RAISE;
  END delete_all_accounts;

--+replace ledger_id with chart_of_accounts_id in the SQL cursor
--+in 11ix, ledger_id is null if mass creation is selected.
--+whereas, chart_of_accounts_id is not null
  PROCEDURE check_unique_name(X_rowid VARCHAR2,
			      X_coaid NUMBER,
                              X_name VARCHAR2) IS
  CURSOR name_count_new_row IS
     SELECT 1
     FROM DUAL
     WHERE EXISTS (SELECT 1
                   FROM  gl_movemerge_requests
                   WHERE name = X_name
		   AND   chart_of_accounts_id = X_coaid);

  CURSOR name_count_old_row IS
     SELECT 1
     FROM DUAL
     WHERE EXISTS (SELECT 1
                   FROM  gl_movemerge_requests r1, gl_movemerge_requests r2
                   WHERE r1.name = X_name
		   AND   r1.chart_of_accounts_id = X_coaid
		   AND   r1.rowid <> X_rowid
		   AND   r2.rowid = X_rowid
		   AND   nvl(r1.original_movemerge_request_id, -1)
                           <> nvl(r2.original_movemerge_request_id, -1)
                   AND   nvl(r1.ledger_id,-1) <> nvl(r2.ledger_id,-1));
  BEGIN
    IF (X_rowid IS NULL) THEN
      OPEN name_count_new_row;
      FETCH name_count_new_row INTO dumdum;
      IF name_count_new_row%FOUND THEN
        CLOSE name_count_new_row;
        FND_MESSAGE.set_name('SQLGL', 'GL_DUPLICATE_NAME');
        APP_EXCEPTION.raise_exception;
      ELSE
        CLOSE name_count_new_row;
      END IF;
    ELSE
      OPEN name_count_old_row;
      FETCH name_count_old_row INTO dumdum;
      IF name_count_old_row%FOUND THEN
        CLOSE name_count_old_row;
        FND_MESSAGE.set_name('SQLGL', 'GL_DUPLICATE_NAME');
        APP_EXCEPTION.raise_exception;
      ELSE
        CLOSE name_count_old_row;
      END IF;
    END IF;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_movemerge_requests_pkg.check_unique_name');
      RAISE;
  END check_unique_name;


  PROCEDURE pre_insert(X_rowid VARCHAR2,
		       X_coaid NUMBER,
                       X_name VARCHAR2) IS
  BEGIN
    check_unique_name(X_rowid, X_coaid, X_name);
  END pre_insert;

  --
  -- Function
  -- validate_segments
  -- Purpose
  -- Calls validate_segs from FND_FLEX_KEYVAL
  -- Parameters
  --  ops_string(operation to be performed)
  --  concatseg(accounting information)
  --  coaid (charts of accounts id)
  -- Notes
  --

 FUNCTION validate_segments (ops_string IN VARCHAR2,
   			     concatseg IN VARCHAR2,
    		     	     coaid IN NUMBER) RETURN VARCHAR2 IS
    retval BOOLEAN := FALSE;
  BEGIN
   retval := FND_FLEX_KEYVAL.validate_segs(
                     ops_string,
                     'SQLGL',
                     'GL#',
                     coaid,
                     concatseg,
                     'V', SYSDATE, 'ALL', '', '',
                     '', '', FALSE, FALSE, '', '', '');
    IF (retval) THEN
       RETURN('SUCCESS');
    ELSE
       RETURN('FAILURE');
    END IF;
  END ;

 PROCEDURE check_last_opened_period (ledgerid IN NUMBER)
 IS
    target_ledger_name         VARCHAR2(30);

    CURSOR ledger_id_cur IS
           SELECT rel.target_ledger_name
           FROM gl_ledgers lgr, gl_ledger_relationships rel, gl_ledgers alc
           WHERE lgr.ledger_id = ledgerid
           AND rel.source_ledger_id = lgr.ledger_id
           AND rel.target_ledger_category_code = 'ALC'
           AND  rel.relationship_type_code <> 'BALANCE'
           AND  rel.application_id = 101
           AND  alc.ledger_id = rel.target_ledger_id
           AND  nvl(alc.latest_opened_period_name,'X') <> nvl(lgr.latest_opened_period_name,'X')
           ORDER BY target_ledger_name;
BEGIN
   OPEN ledger_id_cur;
   LOOP
      FETCH ledger_id_cur INTO target_ledger_name;
          EXIT WHEN ledger_id_cur%NOTFOUND;
          FND_MESSAGE.set_name('SQLGL', 'GLMM0115');
          FND_MESSAGE.set_token('ALC_NAME', target_ledger_name);
          APP_EXCEPTION.raise_exception;
          EXIT;
   END LOOP;
   CLOSE ledger_id_cur;

   EXCEPTION
      WHEN app_exceptions.application_exception THEN
         RAISE;
      WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token(
          'PROCEDURE',
          'gl_movemerge_requests_pkg.check_last_opened_period');
         RAISE;
  END ;

 PROCEDURE get_mm_ledger_id (ledgerid IN NUMBER,
                             mm_ledger_id IN OUT NOCOPY NUMBER)
 IS
    object_type         gl_ledgers.object_type_code%TYPE;
    CURSOR ledger_type IS
           SELECT  object_type_code
           FROM    gl_ledgers led
           WHERE   led.ledger_id = ledgerid;

    CURSOR ledger_id_cursor IS
           SELECT ledger_id
           FROM gl_ledger_set_assignments
           WHERE ledger_set_id = ledgerid;

BEGIN
    mm_ledger_id := 0;  --in case this ledger set contains no ledger at all
    OPEN ledger_type;
    FETCH ledger_type INTO object_type;
    IF object_type = 'S' THEN
       OPEN ledger_id_cursor;
       LOOP
          FETCH ledger_id_cursor INTO mm_ledger_id;
          EXIT WHEN ledger_id_cursor%NOTFOUND;
          IF mm_ledger_id <> 0 THEN
             EXIT;
          END IF;
       END LOOP;
       CLOSE ledger_id_cursor;
       CLOSE ledger_type;
    ELSE
       CLOSE ledger_type;
       mm_ledger_id := ledgerid;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token(
          'PROCEDURE',
          'gl_movemerge_requests_pkg.get_mm_ledger_id');
      RAISE;
  END ;

End gl_movemerge_requests_pkg;

/
