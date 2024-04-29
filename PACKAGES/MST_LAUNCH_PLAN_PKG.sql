--------------------------------------------------------
--  DDL for Package MST_LAUNCH_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MST_LAUNCH_PLAN_PKG" AUTHID CURRENT_USER AS
 /* $Header: MSTPLAPS.pls 115.5 2004/08/18 21:09:03 qlu noship $ */

  PROCEDURE   mst_launch_plan (
                     errbuf  		OUT NOCOPY VARCHAR2,
                     retcode    	OUT NOCOPY NUMBER,
		     arg_plan_id             IN         NUMBER,
                     arg_reuse_files         IN         NUMBER,
                     arg_audit_mode          IN         NUMBER ,
                     arg_launch_planner      IN         NUMBER,
	             arg_plan_start_date     IN         VARCHAR2,
                     arg_plan_cutoff_date    IN         VARCHAR2 ,
                     arg_netchange_mode      IN         NUMBER DEFAULT NULL
                     );

 SYS_YES         CONSTANT INTEGER := 1;
 SYS_NO          CONSTANT INTEGER := 2;
 G_SUCCESS                    CONSTANT NUMBER := 0;
 G_WARNING                    CONSTANT NUMBER := 1;
 G_ERROR                      CONSTANT NUMBER := 2;

PROCEDURE refresh_snapshot(
        ERRBUF             OUT NOCOPY VARCHAR2,
        RETCODE            OUT NOCOPY NUMBER,
        pSNAPName in VARCHAR2,
        pDEGREE in NUMBER DEFAULT 0);

FUNCTION FOUND_EXIST_OBJECTS   RETURN BOOLEAN;
FUNCTION SETUP_SOURCE_OBJECTS  RETURN BOOLEAN;
PROCEDURE WAIT_FOR_REQUEST(
                      p_request_id in number,
                      p_timeout      IN  NUMBER,
                      o_retcode      OUT NOCOPY NUMBER);
END mst_launch_plan_pkg;

 

/
