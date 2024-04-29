--------------------------------------------------------
--  DDL for Package MSC_CL_PURGE_STAGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_PURGE_STAGING" AUTHID CURRENT_USER AS
/* $Header: MSCCLPSS.pls 120.2.12010000.1 2008/05/02 19:02:12 appldev ship $ */



   SYS_YES                                 CONSTANT NUMBER := 1;
   SYS_NO                                  CONSTANT NUMBER := 2;

   -- ================== Process Flag ===================
   G_NEW                                   CONSTANT NUMBER := 1;
   G_IN_PROCESS                            CONSTANT NUMBER := 2;
   G_ERROR_FLG                             CONSTANT NUMBER := 3;
   G_PROPAGATION                           CONSTANT NUMBER := 4;
   G_VALID                                 CONSTANT NUMBER := 5;


   -- ================== Staging Table Status===================
   G_ST_EMPTY                              CONSTANT NUMBER := 0;   -- no instance data exists;
   G_ST_PULLING                            CONSTANT NUMBER := 1;
   G_ST_READY                              CONSTANT NUMBER := 2;
   G_ST_COLLECTING                         CONSTANT NUMBER := 3;
   G_ST_PURGING                            CONSTANT NUMBER := 4;
   G_ST_PRE_PROCESSING                     CONSTANT NUMBER := 5;


   G_SUCCESS                               CONSTANT NUMBER := 0;
   G_WARNING                               CONSTANT NUMBER := 1;
   G_ERROR                                 CONSTANT NUMBER := 2;

-- ================== Instance Types ===================
   G_INS_DISCRETE                          CONSTANT NUMBER := 1;
   G_INS_PROCESS                           CONSTANT NUMBER := 2;
   G_INS_OTHER                             CONSTANT NUMBER := 3;
   G_INS_MIXED                             CONSTANT NUMBER := 4;
   G_INS_EXCHANGE                          CONSTANT NUMBER := 5;


PROCEDURE launch_purge ( ERRBUF  OUT NOCOPY VARCHAR2,
                         RETCODE  OUT NOCOPY NUMBER,
                         p_instance_id IN NUMBER,
                         p_del_rej_rec IN NUMBER DEFAULT SYS_YES);

PROCEDURE PURGE_STAGING_TABLES_TRNC( p_instance_id    IN  NUMBER);

PROCEDURE PURGE_STAGING_TABLES_DEL( p_instance_id     IN  NUMBER);

PROCEDURE PURGE_STAGING_TABLES_SUB( p_instance_id IN NUMBER,
                                    p_Blind_Purge IN  NUMBER:=SYS_NO);
PROCEDURE TRUNCATE_STAGING_TABLES(ERRBUF               OUT NOCOPY VARCHAR2,
                                  RETCODE              OUT NOCOPY NUMBER);


END msc_cl_purge_staging;

/
