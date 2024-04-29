--------------------------------------------------------
--  DDL for Package Body GMF_GL_INSERT_JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_INSERT_JE" AS
/* $Header: gmfjcatb.pls 115.0 99/07/16 04:20:38 porting shi $ */
  PROCEDURE GMF_GL_INSERT_JE_CATEGORY(categoryname in varchar2,
                              descrip in varchar2,
                              createdby in number,
                              statuscode out number) AS
  BEGIN

      INSERT INTO GL_JE_CATEGORIES
          (  je_category_name,
            user_je_category_name,
            last_update_date,
            last_updated_by,
            description,
            creation_date,
                created_by)

      SELECT
            categoryname,
            categoryname,
            sysdate,
            nvl(user_id,0),
            descrip,
            sysdate,
            nvl(user_id,0)

      FROM    FND_USER
      WHERE    user_id=nvl(createdby,0);
      EXCEPTION
        WHEN others THEN
            statuscode := SQLCODE;
  END GMF_GL_INSERT_JE_CATEGORY;

  PROCEDURE GMF_GL_INSERT_JE_SOURCE(sourcename in varchar2,
                  descrip    in varchar2,
                  createdby  in number,
                  statuscode out number) AS
  BEGIN
    INSERT INTO GL_JE_SOURCES    (
          je_source_name,
          user_je_source_name,
          last_update_date,
          last_updated_by,
          override_edits_flag,
          journal_reference_flag,
	  effective_date_rule_code,
	  journal_approval_flag,
          description,
          creation_date,
          created_by)

    SELECT sourcename,
          sourcename,
          sysdate,
          nvl(user_id,0),
          'N',
          'N',
	  'R',
	  'N',
          descrip,
          sysdate,
          nvl(user_id,0)
    FROM  FND_USER
    WHERE user_id = nvl(createdby,0);

  EXCEPTION
    WHEN others THEN
         statuscode := SQLCODE;
  END GMF_GL_INSERT_JE_SOURCE;
END GMF_GL_INSERT_JE;

/
