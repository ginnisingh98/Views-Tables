--------------------------------------------------------
--  DDL for Package MSC_ATP_REFRESH_MVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_REFRESH_MVIEW" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCATMVS.pls 120.1 2007/12/12 10:21:14 sbnaik ship $ */

/*
  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;
*/

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   --  ================= Procedures ====================
   PROCEDURE REFRESH_MVIEW(
                      ERRBUF		 OUT NoCopy VARCHAR2,
	              RETCODE		 OUT NoCopy NUMBER);
END MSC_ATP_REFRESH_MVIEW;

/
