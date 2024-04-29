--------------------------------------------------------
--  DDL for Package Body FII_AP_MV_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_MV_REFRESH" AS
/*$Header: FIIAPMVB.pls 115.1 2003/08/05 17:07:31 pslau noship $*/

g_phase VARCHAR2(50);
g_debug_flag 	VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_retcode  VARCHAR2(20) := NULL;

---------------------------------------------------------------
-- PROCEDURE AP_REFRESH
---------------------------------------------------------------
PROCEDURE AP_REFRESH(Errbuf        in out NOCOPY Varchar2,
                     Retcode       in out NOCOPY Varchar2) IS

	l_dir    VARCHAR2(50) := NULL;
        l_min              DATE;
        l_max              DATE;
        l_check_time_dim   BOOLEAN;
        l_parallel_degree   NUMBER := 0;
        l_count             NUMBER := 0;

BEGIN

   ------------------------------------------------------
   -- Set default directory in case if the profile option
   -- BIS_DEBUG_LOG_DIRECTORY is not set up
   ------------------------------------------------------
   l_dir:='/sqlcom/log';

   ----------------------------------------------------------------
   -- fii_util.initialize will get profile options FII_DEBUG_MODE
   -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
   -- the log files and output files are written to
   ----------------------------------------------------------------
  	FII_UTIL.initialize('FII_AP_MV_REFRESH.log', 'FII_AP_MV_REFRESH.out',l_dir);


	  g_phase := 'Refreshing AP MV tables - 1';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

   l_parallel_degree :=  BIS_COMMON_PARAMETERS.GET_DEGREE_OF_PARALLELISM();
   IF  (l_parallel_degree =1) THEN
       l_parallel_degree := 0;
   END IF;

   dbms_mview.refresh(
			list => 'FII_AP_HHIST_B_MV,FII_AP_LIA_B_MV,FII_AP_HCAT_B_MV,FII_AP_IVATY_B_MV,
                     FII_AP_PAID_XB_MV,FII_AP_PAYOL_XB_MV,FII_AP_LIWAG_IB_MV',
			method => '???????',
			parallelism => l_parallel_degree
	);

	  g_phase := 'Refreshing AP MV tables - 2';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

   dbms_mview.refresh(
			list => 'FII_AP_HHIST_I_MV,FII_AP_LIA_I_MV,FII_AP_HCAT_I_MV,FII_AP_IVATY_XB_MV',
			method => '????',
			parallelism => l_parallel_degree
	);

	  g_phase := 'Refreshing AP MV tables - 3';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

   dbms_mview.refresh(
			list => 'FII_AP_HHIST_IB_MV,FII_AP_LIA_IB_MV,FII_AP_HCAT_IB_MV',
			method => '???',
			parallelism => l_parallel_degree
	);

	  g_phase := 'Refreshing AP MV tables - 4';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

   dbms_mview.refresh(
			list => 'FII_AP_HATY_XB_MV,FII_AP_HLIA_IB_MV',
			method => '??',
			parallelism => l_parallel_degree
	);

	  g_phase := 'Refreshing AP MV tables - 5';
   if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(g_phase);
   	FII_UTIL.put_line('');
   end if;

   dbms_mview.refresh(
			list => 'FII_AP_HLIA_I_MV,FII_AP_HLWAG_IB_MV',
			method => '??',
			parallelism => l_parallel_degree
	);

EXCEPTION
	WHEN OTHERS THEN
 		Errbuf:= sqlerrm;
 		Retcode:=sqlcode;
 		if g_debug_flag = 'Y' then
			FII_UTIL.DEBUG_LINE(Retcode||':'||Errbuf);
		end if;

END AP_REFRESH;

END FII_AP_MV_REFRESH;

/
