--------------------------------------------------------
--  DDL for Package MSC_CL_COPY_DP_FORECAST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_COPY_DP_FORECAST" AUTHID CURRENT_USER AS
/* $Header: MSCDPCPS.pls 120.1.12010000.1 2009/08/28 17:57:55 schaudha noship $ */

 -- Global variable Definition
   v_sql_stmt                    VARCHAR2(32767);

--  ================= Procedures ====================


PROCEDURE LAUNCH_MONITOR( ERRBUF       OUT NOCOPY VARCHAR2,
			      RETCODE			   OUT NOCOPY NUMBER,
			      pINSTANCE_ID         IN  NUMBER,
			      pSource_instance_id  IN NUMBER);

--PROCEDURE PURGE_ALL_FORECAST;
PROCEDURE COPY_DP_FORECAST ; -- To copy data from MSD_DP_SCN_ENTRIES_DENORM
PROCEDURE COPY_DP_SCENARIOS;
PROCEDURE COPY_DP_SCENARIO_REVISIONS;
PROCEDURE COPY_DP_DEMAND_PLANS;
PROCEDURE COPY_MSD_DP_SCENARIO_OP_LEVELS;

END MSC_CL_COPY_DP_FORECAST;

/
