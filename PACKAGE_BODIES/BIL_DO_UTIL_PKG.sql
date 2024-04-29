--------------------------------------------------------
--  DDL for Package Body BIL_DO_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_DO_UTIL_PKG" AS
/* $Header: bildoutb.pls 115.8 2002/01/29 13:55:53 pkm ship      $ */



-- Write message in debug mode
PROCEDURE Write_Log (
      p_msg      VARCHAR2
     ,p_stime    DATE DEFAULT NULL
     ,p_etime    DATE DEFAULT NULL
     ,p_debug    VARCHAR2 DEFAULT 'N'
     ,p_force    VARCHAR2 DEFAULT 'N'
    ) IS
    l_msg         VARCHAR2(255);
    l_length      NUMBER;
    l_start       NUMBER    := 1;
    l_substring   VARCHAR2(234);
    l_prefix      VARCHAR2(21)  := '                     ';
  BEGIN
    -- p_force writes to log even if debug is No. Used in case of abnormal exceptions.
    IF (p_Debug='Y') OR (p_force='Y') THEN
      l_msg := TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS') || '  ' || substr(p_msg, l_start, 234);
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg);
      l_length := length(p_msg)-255;
      l_start  := l_start + 234;
      WHILE l_length > 234 LOOP
         l_substring := substr(p_msg, l_start, 234);
         --DBMS_OUTPUT.PUT_LINE(l_substring);
         FND_FILE.PUT_LINE(FND_FILE.LOG, l_prefix || l_substring);
         l_start := l_start + 234;
         l_length := l_length - 234;
       END LOOP;
          --DBMS_OUTPUT.PUT_LINE(l_substring);
         FND_FILE.PUT_LINE(FND_FILE.LOG, l_substring);
     END IF;

     EXCEPTION
      WHEN others THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception: others in Write_log');
       FND_FILE.PUT_LINE(FND_FILE.LOG,
               'SQLCODE ' || to_char(SQLCODE) ||
               ' SQLERRM ' || substr(SQLERRM, 1, 100));

  END Write_Log;


 END BIL_DO_UTIL_PKG;


/
