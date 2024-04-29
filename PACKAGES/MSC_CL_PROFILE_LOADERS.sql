--------------------------------------------------------
--  DDL for Package MSC_CL_PROFILE_LOADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_PROFILE_LOADERS" AUTHID CURRENT_USER AS
/* $Header: MSCPROFLDS.pls 115.0 2003/01/19 19:00:38 rawasthi noship $ */

  ----- ARRAY DATA TYPE --------------------------------------------------

   TYPE NumTblTyp IS TABLE OF NUMBER;
   TYPE VarcharTblTyp IS TABLE OF VARCHAR2(1000);

  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   -- NULL VALUE USED IN THE WHERE CLAUSE

   NULL_DATE             CONSTANT DATE:=   SYSDATE-36500;
   NULL_VALUE            CONSTANT NUMBER:= -23453;   -- null value for positive number
   NULL_CHAR             CONSTANT VARCHAR2(6):= '-23453';

   -- ============ Task Control ================

   PIPE_TIME_OUT         CONSTANT NUMBER := 30;      -- 30 secs
   START_TIME            DATE;



   -- ================== Worker Status ===================

    OK                    		CONSTANT NUMBER := 1;
    FAIL                  		CONSTANT NUMBER := 0;

   --  ================= Procedures ====================
   PROCEDURE LAUNCH_PROFILE_MON( ERRBUF      OUT NOCOPY VARCHAR2,
	         RETCODE                     OUT NOCOPY NUMBER,
	         p_timeout                   IN  NUMBER,
                 p_path_separator            IN  VARCHAR2 DEFAULT '/',
                 p_ctl_file_path             IN  VARCHAR2,
	         p_directory_path            IN  VARCHAR2,
	         p_total_worker_num          IN  NUMBER,
                 p_get_profile_value         IN  VARCHAR2 DEFAULT NULL);



END MSC_CL_PROFILE_LOADERS;

 

/
