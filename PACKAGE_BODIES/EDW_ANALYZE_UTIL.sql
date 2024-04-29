--------------------------------------------------------
--  DDL for Package Body EDW_ANALYZE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ANALYZE_UTIL" AS
/* $Header: EDWARSTB.pls 115.6 2003/11/19 09:19:34 smulye noship $  */
VERSION	CONSTANT CHAR(80) := '$Header: EDWARSTB.pls 115.6 2003/11/19 09:19:34 smulye noship $';

-- ------------------------
-- Global Variables
-- ------------------------

-- ------------------------
-- Public Procedures
-- ------------------------


Procedure analyze_table( p_table_name  in Varchar2) IS
  l_bis_schema          VARCHAR2(30);
  l_stmt  		VARCHAR2(200);
  l_status		VARCHAR2(30);
  l_industry		VARCHAR2(30);
  errbuf                varchar2(2000):=null;
  retcode               varchar2(200):=null;
 BEGIN

      IF (FND_INSTALLATION.GET_APP_INFO('BIS', l_status, l_industry, l_bis_schema)) THEN
         FND_STATS.GATHER_TABLE_STATS(errbuf,retcode, l_bis_schema, p_table_name ) ;
      END IF;

 END;


Procedure analyze_wh_tables(Errbuf      	in out nocopy  Varchar2,
                Retcode     	in out nocopy Varchar2) IS
 BEGIN
    analyze_table('EDW_PUSH_DETAIL_LOG');
    analyze_table('EDW_COLLECTION_DETAIL_LOG');
    analyze_table('EDW_LOAD_PROGRESS_LOG');
 END;

END;


/
