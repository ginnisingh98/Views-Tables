--------------------------------------------------------
--  DDL for Package Body CSC_PROF_PARTY_SQL_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_PARTY_SQL_CUHK" AS
/* $Header: cscpphkb.pls 120.4 2005/09/02 05:24 mmadhavi noship $ */

  procedure Get_Party_Sql_Pre( p_ref_cur    OUT NOCOPY csc_utils.Party_Ref_Cur_Type) IS

  l_sql varchar2(2000);
  l_filter_condition varchar2(100);

  BEGIN

  NULL;

/*
REM	 Add your business rules here to fetch the party_id and party_type
REM      Following is a sample code
REM
REM	l_sql := 'SELECT party_id FROM hz_parties'
REM
REM	  OPEN p_ref_cur FOR l_sql;
*/

  EXCEPTION
  WHEN OTHERS THEN
    NULL;

  END Get_Party_Sql_Pre;

END CSC_PROF_PARTY_SQL_CUHK;

/
