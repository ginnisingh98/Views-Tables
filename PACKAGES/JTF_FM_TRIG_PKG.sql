--------------------------------------------------------
--  DDL for Package JTF_FM_TRIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_TRIG_PKG" AUTHID CURRENT_USER as
   l_query_id  JTF_FM_QUERIES_ALL.QUERY_ID%TYPE;
   l_query_string JTF_FM_QUERIES_ALL.QUERY_STRING%TYPE;
   l_query_name JTF_FM_QUERIES_ALL.QUERY_NAME%TYPE;

   avoid_recursion boolean default false;


END;


 

/
