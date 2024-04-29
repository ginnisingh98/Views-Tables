--------------------------------------------------------
--  DDL for Package Body GL_ELIM_ACCOUNTS_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ELIM_ACCOUNTS_MAP_PKG" As
/* $Header: glieacmb.pls 120.4 2005/05/05 01:06:45 kvora ship $ */

  --
  -- Procedure
  --   unique_line_number
  -- Purpose
  --   Make sure line number within each journal is unique
  -- Parameters
  --   None
  -- History
  --   11-06-1998  W Wong    Created
  -- Notes
  --   Raises GL_DUPLICATE_JE_LINE_NUM on failure
  --
  PROCEDURE unique_line_number (
		X_journal_id IN NUMBER,
		X_lineno     IN NUMBER,
		X_rowid      IN VARCHAR2 ) IS

    counter NUMBER;

    CURSOR line_count IS
      SELECT 1
      FROM DUAL
      WHERE EXISTS (SELECT 1
                    FROM   GL_ELIM_ACCOUNTS_MAP
                    WHERE  journal_id   = X_journal_id
                    AND    line_number  = X_lineno
                    AND   (rowid <> X_rowid OR X_rowid IS NULL));
 BEGIN
   OPEN line_count;
   FETCH line_count INTO counter;

   IF line_count%FOUND THEN
     CLOSE line_count;
     FND_MESSAGE.set_name('SQLGL', 'GL_DUPLICATE_JE_LINE_NUM');
     APP_EXCEPTION.raise_exception;

   ELSE
     CLOSE line_count;
   END IF;

 EXCEPTION
   WHEN app_exceptions.application_exception THEN
     RAISE;

   WHEN OTHERS THEN
     fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
     fnd_message.set_token(
         'PROCEDURE',
         'gl_elim_accounts_map_pkg.unique_line_number');
     RAISE;

 END unique_line_number;


 --
 -- PROCEDURE source_spec_is_unique
 --
 PROCEDURE source_spec_is_unique (
    X_journal_id IN NUMBER, X_row_id IN CHAR,
    X_ss1     IN VARCHAR2,   X_ss2    IN VARCHAR2,
    X_ss3     IN VARCHAR2,   X_ss4    IN VARCHAR2,
    X_ss5     IN VARCHAR2,   X_ss6    IN VARCHAR2,
    X_ss7     IN VARCHAR2,   X_ss8    IN VARCHAR2,
    X_ss9     IN VARCHAR2,   X_ss10   IN VARCHAR2,
    X_ss11    IN VARCHAR2,   X_ss12   IN VARCHAR2,
    X_ss13    IN VARCHAR2,   X_ss14   IN VARCHAR2,
    X_ss15    IN VARCHAR2,   X_ss16   IN VARCHAR2,
    X_ss17    IN VARCHAR2,   X_ss18   IN VARCHAR2,
    X_ss19    IN VARCHAR2,   X_ss20   IN VARCHAR2,
    X_ss21    IN VARCHAR2,   X_ss22   IN VARCHAR2,
    X_ss23    IN VARCHAR2,   X_ss24   IN VARCHAR2,
    X_ss25    IN VARCHAR2,   X_ss26   IN VARCHAR2,
    X_ss27    IN VARCHAR2,   X_ss28   IN VARCHAR2,
    X_ss29    IN VARCHAR2,   X_ss30   IN VARCHAR2
 ) IS

   counter NUMBER;

   CURSOR source_count IS
     SELECT 1
     FROM DUAL
     WHERE EXISTS (SELECT 1
                   FROM   GL_ELIM_ACCOUNTS_MAP
                   WHERE  journal_id         = X_journal_id
                   AND   (rowid <> X_row_id OR X_row_id IS NULL)
                   AND   nvl(source_segment1, ' ') = nvl(X_ss1, ' ')
                   AND   nvl(source_segment2, ' ') = nvl(X_ss2, ' ')
                   AND   nvl(source_segment3, ' ') = nvl(X_ss3, ' ')
                   AND   nvl(source_segment4, ' ') = nvl(X_ss4, ' ')
                   AND   nvl(source_segment5, ' ') = nvl(X_ss5, ' ')
                   AND   nvl(source_segment6, ' ') = nvl(X_ss6, ' ')
                   AND   nvl(source_segment7, ' ') = nvl(X_ss7, ' ')
                   AND   nvl(source_segment8, ' ') = nvl(X_ss8, ' ')
                   AND   nvl(source_segment9, ' ') = nvl(X_ss9, ' ')
                   AND   nvl(source_segment10,' ') = nvl(X_ss10,' ')
                   AND   nvl(source_segment11,' ') = nvl(X_ss11,' ')
                   AND   nvl(source_segment12,' ') = nvl(X_ss12,' ')
                   AND   nvl(source_segment13,' ') = nvl(X_ss13,' ')
                   AND   nvl(source_segment14,' ') = nvl(X_ss14,' ')
                   AND   nvl(source_segment15,' ') = nvl(X_ss15,' ')
                   AND   nvl(source_segment16,' ') = nvl(X_ss16,' ')
                   AND   nvl(source_segment17,' ') = nvl(X_ss17,' ')
                   AND   nvl(source_segment18,' ') = nvl(X_ss18,' ')
                   AND   nvl(source_segment19,' ') = nvl(X_ss19,' ')
                   AND   nvl(source_segment20,' ') = nvl(X_ss20,' ')
                   AND   nvl(source_segment21,' ') = nvl(X_ss21,' ')
                   AND   nvl(source_segment22,' ') = nvl(X_ss22,' ')
                   AND   nvl(source_segment23,' ') = nvl(X_ss23,' ')
                   AND   nvl(source_segment24,' ') = nvl(X_ss24,' ')
                   AND   nvl(source_segment25,' ') = nvl(X_ss25,' ')
                   AND   nvl(source_segment26,' ') = nvl(X_ss26,' ')
                   AND   nvl(source_segment27,' ') = nvl(X_ss27,' ')
                   AND   nvl(source_segment28,' ') = nvl(X_ss28,' ')
                   AND   nvl(source_segment29,' ') = nvl(X_ss29,' ')
                   AND   nvl(source_segment30,' ') = nvl(X_ss30,' '));
 BEGIN
   OPEN source_count;
   FETCH source_count INTO counter;
   IF source_count%FOUND THEN
     CLOSE source_count;
     FND_MESSAGE.set_name('SQLGL', 'GL_ELIM_SOURCE_NOT_UNIQUE');
     APP_EXCEPTION.raise_exception;
   ELSE
     CLOSE source_count;
   END IF;
 EXCEPTION
   WHEN app_exceptions.application_exception THEN
     RAISE;
   WHEN OTHERS THEN
     fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
     fnd_message.set_token(
         'PROCEDURE',
         'gl_elim_accounts_map_pkg.source_spec_is_unique');
     RAISE;
 END source_spec_is_unique;

  --
  -- Procedure
  --   get_bal_seg_num
  -- Purpose
  --   Get the balancing segment number
  -- History
  --   12-17-1998  W Wong    Created
  -- Notes
  --
  PROCEDURE get_bal_seg_num (
    X_coa_id        IN		NUMBER,
    X_company_value IN OUT NOCOPY 	NUMBER ) IS

    return_code	  	BOOLEAN;

  BEGIN

   /* get number of the company segment in the segments array */
   return_code := fnd_flex_apis.get_qualifier_segnum(
    	    	    	101,
			'GL#',
			X_coa_id,
			'GL_BALANCING',
			X_company_value);

   IF (NOT return_code) THEN
      app_exception.raise_exception;
   END IF;

  END get_bal_seg_num;


End gl_elim_accounts_map_pkg;

/
