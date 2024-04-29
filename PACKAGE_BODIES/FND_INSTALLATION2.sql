--------------------------------------------------------
--  DDL for Package Body FND_INSTALLATION2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_INSTALLATION2" AS
/* $Header: AFINST2B.pls 115.1 99/07/16 23:22:57 porting sh $ */

  --
  -- Public Functions
  --

  FUNCTION get 	       (appl_id     IN  INTEGER,
                	dep_appl_id IN  INTEGER,
                	status      OUT VARCHAR2,
                	industry    OUT VARCHAR2)
  RETURN varchar2 IS
    l_status			varchar2(1);
    l_industry			varchar2(1);
    l_return			boolean;
  BEGIN
    status := 'N';
    industry := 'N';

    l_return := fnd_installation.get(appl_id, dep_appl_id, l_status,
                                     l_industry);
    status := l_status;
    industry := l_industry;

    if l_return then
      return('TRUE');
    else
      return('FALSE');
    end if;
  EXCEPTION
    when others then
      return('FALSE');
  END get;

  FUNCTION get_app_info  (application_short_name	in  varchar2,
			status			out varchar2,
			industry		out varchar2,
			oracle_schema		out varchar2)
  RETURN boolean IS
    l_status			varchar2(1);
    l_industry			varchar2(1);
    l_oracle_schema		varchar2(30);
    l_return			boolean;
  BEGIN
    status := 'N';
    industry := 'N';
    oracle_schema := null;

    l_return := fnd_installation.get_app_info(application_short_name,
                  l_status, l_industry, l_oracle_schema);

    status := l_status;
    industry := l_industry;
    oracle_schema := l_oracle_schema;
    return(l_return);
  EXCEPTION
    when others then
      return(FALSE);
  END get_app_info;

  FUNCTION get_app_info_other  (application_short_name	in  varchar2,
			target_schema		in  varchar2,
			status			out varchar2,
			industry		out varchar2,
			oracle_schema		out varchar2)
  RETURN boolean IS
    l_status			varchar2(1);
    l_industry			varchar2(1);
    l_oracle_schema		varchar2(30);
    l_return			boolean;
  BEGIN
    status := 'N';
    industry := 'N';
    oracle_schema := null;

    l_return := fnd_installation.get_app_info_other(application_short_name,
                  target_schema, l_status, l_industry, l_oracle_schema);

    status := l_status;
    industry := l_industry;
    oracle_schema := l_oracle_schema;
    return(l_return);
  EXCEPTION
    when others then
      return(FALSE);
  END get_app_info_other;

END FND_INSTALLATION2;

/
