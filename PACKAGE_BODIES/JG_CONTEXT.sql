--------------------------------------------------------
--  DDL for Package Body JG_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_CONTEXT" AS
/* $Header: jgzzscxb.pls 120.4 2005/07/29 23:06:09 appradha ship $ */
PROCEDURE initialize IS

  BEGIN
    dbms_session.set_context(
                 'JG'
                ,'JGZZ_APPL_SHORT_NAME'
                , fnd_profile.value('JGZZ_APPL_SHORT_NAME'));

    dbms_session.set_context(
                 'JG'
                ,'JGZZ_PRODUCT_CODE'
                , fnd_profile.value('JGZZ_PRODUCT_CODE'));

    dbms_session.set_context(
                 'JG'
                ,'JGZZ_COUNTRY_CODE'
                , fnd_profile.value('JGZZ_COUNTRY_CODE'));

  END initialize;

  procedure name_value(name varchar2, value varchar2) as
  begin
    -- can only be called within the package to which it belongs
    -- If you try to execute DBMS_SESSION.SET_CONTEXT you'll get an error, as shown here:
    -- ORA-01031: insufficient privileges
    dbms_session.set_context('JG',name,value);
   end;
  end jg_context;

/
