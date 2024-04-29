--------------------------------------------------------
--  DDL for Package Body GL_MOVEMERGE_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_MOVEMERGE_ACCOUNTS_PKG" AS
/* $Header: glimmacb.pls 120.3 2005/05/05 01:17:22 kvora ship $ */

 --
 -- PRIVATE DATA DECLARATIONS
 --

 -- throw away number value
 dumdum NUMBER;

 --
 -- PRIVATE METHODS
 --

 --
 -- PUBLIC METHODS
 --

 PROCEDURE line_number_is_unique  (
   mm_id  IN NUMBER,
   lineno IN NUMBER,
   row_id IN CHAR
 ) IS
   CURSOR line_count IS
     SELECT 1
     FROM DUAL
     WHERE EXISTS (SELECT 1
                   FROM gl_movemerge_accounts p
                   WHERE movemerge_request_id = mm_id
                   AND   line_number          = lineno
                   AND   (rowid <> row_id OR row_id IS NULL));
 BEGIN
   OPEN line_count;
   FETCH line_count INTO dumdum;
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
         'gl_movemerge_accounts_pkg.line_number_is_unique');
     RAISE;
 END line_number_is_unique;


 PROCEDURE source_spec_is_unique (
   mm_id IN NUMBER,     row_id IN CHAR,
   ss1   IN VARCHAR2,   ss2    IN VARCHAR2,
   ss3   IN VARCHAR2,   ss4    IN VARCHAR2,
   ss5   IN VARCHAR2,   ss6    IN VARCHAR2,
   ss7   IN VARCHAR2,   ss8    IN VARCHAR2,
   ss9   IN VARCHAR2,   ss10   IN VARCHAR2,
   ss11  IN VARCHAR2,   ss12   IN VARCHAR2,
   ss13  IN VARCHAR2,   ss14   IN VARCHAR2,
   ss15  IN VARCHAR2,   ss16   IN VARCHAR2,
   ss17  IN VARCHAR2,   ss18   IN VARCHAR2,
   ss19  IN VARCHAR2,   ss20   IN VARCHAR2,
   ss21  IN VARCHAR2,   ss22   IN VARCHAR2,
   ss23  IN VARCHAR2,   ss24   IN VARCHAR2,
   ss25  IN VARCHAR2,   ss26   IN VARCHAR2,
   ss27  IN VARCHAR2,   ss28   IN VARCHAR2,
   ss29  IN VARCHAR2,   ss30   IN VARCHAR2
 ) IS
   CURSOR source_count IS
     SELECT 1
     FROM DUAL
     WHERE EXISTS (SELECT 1
                   FROM gl_movemerge_accounts p
                   WHERE movemerge_request_id      = mm_id
                   AND   (rowid <> row_id OR row_id IS NULL)
                   AND   nvl(source_segment1, ' ') = nvl(ss1, ' ')
                   AND   nvl(source_segment2, ' ') = nvl(ss2, ' ')
                   AND   nvl(source_segment3, ' ') = nvl(ss3, ' ')
                   AND   nvl(source_segment4, ' ') = nvl(ss4, ' ')
                   AND   nvl(source_segment5, ' ') = nvl(ss5, ' ')
                   AND   nvl(source_segment6, ' ') = nvl(ss6, ' ')
                   AND   nvl(source_segment7, ' ') = nvl(ss7, ' ')
                   AND   nvl(source_segment8, ' ') = nvl(ss8, ' ')
                   AND   nvl(source_segment9, ' ') = nvl(ss9, ' ')
                   AND   nvl(source_segment10,' ') = nvl(ss10,' ')
                   AND   nvl(source_segment11,' ') = nvl(ss11,' ')
                   AND   nvl(source_segment12,' ') = nvl(ss12,' ')
                   AND   nvl(source_segment13,' ') = nvl(ss13,' ')
                   AND   nvl(source_segment14,' ') = nvl(ss14,' ')
                   AND   nvl(source_segment15,' ') = nvl(ss15,' ')
                   AND   nvl(source_segment16,' ') = nvl(ss16,' ')
                   AND   nvl(source_segment17,' ') = nvl(ss17,' ')
                   AND   nvl(source_segment18,' ') = nvl(ss18,' ')
                   AND   nvl(source_segment19,' ') = nvl(ss19,' ')
                   AND   nvl(source_segment20,' ') = nvl(ss20,' ')
                   AND   nvl(source_segment21,' ') = nvl(ss21,' ')
                   AND   nvl(source_segment22,' ') = nvl(ss22,' ')
                   AND   nvl(source_segment23,' ') = nvl(ss23,' ')
                   AND   nvl(source_segment24,' ') = nvl(ss24,' ')
                   AND   nvl(source_segment25,' ') = nvl(ss25,' ')
                   AND   nvl(source_segment26,' ') = nvl(ss26,' ')
                   AND   nvl(source_segment27,' ') = nvl(ss27,' ')
                   AND   nvl(source_segment28,' ') = nvl(ss28,' ')
                   AND   nvl(source_segment29,' ') = nvl(ss29,' ')
                   AND   nvl(source_segment30,' ') = nvl(ss30,' '));
 BEGIN
   OPEN source_count;
   FETCH source_count INTO dumdum;
   IF source_count%FOUND THEN
     CLOSE source_count;
     FND_MESSAGE.set_name('SQLGL', 'GL_MM_SOURCE_NOT_UNIQUE');
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
         'gl_movemerge_accounts_pkg.source_spec_is_unique');
     RAISE;
 END source_spec_is_unique;


 PROCEDURE pre_insert (mm_id  IN NUMBER,
  	               lineno IN NUMBER,
    		       row_id IN CHAR ) IS
 BEGIN
   line_number_is_unique(mm_id, lineno, row_id);
 END pre_insert;

END gl_movemerge_accounts_pkg;

/
