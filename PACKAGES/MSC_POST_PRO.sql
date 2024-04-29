--------------------------------------------------------
--  DDL for Package MSC_POST_PRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_POST_PRO" 
/* $Header: MSCPOSTS.pls 120.1 2007/12/12 10:36:55 sbnaik ship $  */
AUTHID CURRENT_USER AS

G_SUCCESS                    CONSTANT NUMBER := 0;
G_WARNING                    CONSTANT NUMBER := 1;
G_ERROR                      CONSTANT NUMBER := 2;

-- For summary enhancement
G_SF_SUMMARY_NOT_RUN        CONSTANT NUMBER := 1;    -- Summary / pre-allocation was never run.
G_SF_PREALLOC_RUNNING       CONSTANT NUMBER := 2;    -- Pre-allocation is running.
G_SF_PREALLOC_COMPLETED     CONSTANT NUMBER := 3;    -- Pre-allocation is completed and is ready for use.
G_SF_SYNC_NOT_RUN           CONSTANT NUMBER := 4;    -- 24X7 synch did not run.
G_SF_SYNC_RUNNING           CONSTANT NUMBER := 5;    -- 24X7 synch is running.
G_SF_SYNC_SUCCESS           CONSTANT NUMBER := 6;    -- 24X7 synch completed successfully.
G_SF_SYNC_ERROR             CONSTANT NUMBER := 7;    -- Error occurred in 24X7 synch.
G_SF_SYNC_DOWNTIME          CONSTANT NUMBER := 8;    -- 24X7 synch plan down time.
G_SF_FULL_SUMMARY_RUNNING   CONSTANT NUMBER := 9;    -- Full summation is running.
G_SF_NET_SUMMARY_RUNNING    CONSTANT NUMBER := 10;   -- Incremental summation is running.
G_SF_SUMMARY_COMPLETED      CONSTANT NUMBER := 11;   -- Summary is completed.
G_SF_ATPPEG_RUNNING         CONSTANT NUMBER := 12;   -- ATP Pegging generation running.
G_SF_ATPPEG_COMPLETED       CONSTANT NUMBER := 13;   -- ATP Pegging generation completed.


PROCEDURE LOAD_SUPPLY_DEMAND ( ERRBUF             OUT    NoCopy VARCHAR2,
        		      RETCODE           OUT    NoCopy NUMBER,
                              P_INSTANCE_ID      IN     NUMBER,
                              P_COLLECT_TYPE     IN     NUMBER);

PROCEDURE CREATE_PARTITIONS(ERRBUF             OUT    NoCopy VARCHAR2,
                            RETCODE           OUT    NoCopy NUMBER);

PROCEDURE LOAD_PLAN_SD ( ERRBUF           OUT     NoCopy VARCHAR2,
                         RETCODE          OUT     NoCopy NUMBER,
                         p_plan_id        IN      NUMBER,
                         p_calling_module IN      NUMBER := 1); /* Bug 3478888 Added input parameter
                                                                  to identify how ATP Post Plan Processing
                                                                  has been launched */

PROCEDURE CLEAN_TABLES(p_applsys_schema IN  varchar2
                      );

PROCEDURE INSERT_SUPPLIER_DATA(p_plan_id         IN NUMBER,
                               p_share_partition IN varchar2,
                               p_applsys_schema  IN varchar2,
                               p_full_refresh    IN NUMBER, -- 1:Yes, 2:No  <-- for sumary enhancement
                               p_sys_date        IN DATE,                          -- For summary enhancement
                               p_last_refresh_number   IN NUMBER DEFAULT NULL,     -- for sumary enhancement
                               p_new_refresh_number    IN NUMBER DEFAULT NULL);    -- for sumary enhancement

FUNCTION get_tolerance_defined( p_plan_id IN NUMBER,
                                p_instance_id IN NUMBER,
                                p_organization_id IN NUMBER,
                                p_inventory_item_id IN NUMBER,
                                p_supplier_id IN NUMBER,
                                p_supplier_site_id IN NUMBER)
RETURN NUMBER;

PROCEDURE LOAD_RESOURCES (p_plan_id         IN NUMBER,
                          p_share_partition IN varchar2,
                          p_applsys_schema  IN varchar2,
                          p_full_refresh    IN NUMBER, -- 1:Yes, 2:No         -- for sumary enhancement
                          p_plan_start_date IN DATE,                      -- for summary enhancement
                          p_sys_date        IN DATE,                      -- for summary enhancement
                          p_last_refresh_number   IN NUMBER DEFAULT NULL,     -- for sumary enhancement
                          p_new_refresh_number    IN NUMBER DEFAULT NULL);    -- for sumary enhancement

Procedure Clean_Plan_Tables( p_applsys_schema IN  varchar2 );

PROCEDURE CREATE_PLAN_PARTITIONS( p_plan_id         IN   NUMBER,
                                 p_applsys_schema  IN   VARCHAR2,
                                 p_share_partition IN   VARCHAR2,
                                 p_owner           IN   VARCHAR2,
                                 p_ret_code        OUT  NoCopy NUMBER,
                                 p_err_msg         OUT  NoCopy VARCHAR2);

PROCEDURE LOAD_NET_SO (
                       ERRBUF          OUT     NoCopy VARCHAR2,
                       RETCODE         OUT     NoCopy NUMBER,
                       P_INSTANCE_ID   IN      NUMBER
                       );

PROCEDURE LOAD_NET_SD (
                       ERRBUF          OUT     NoCopy VARCHAR2,
                       RETCODE         OUT     NoCopy NUMBER,
                       P_INSTANCE_ID   IN      NUMBER
                       );

PROCEDURE CREATE_INST_PARTITIONS(p_instance_id     IN   NUMBER,
                                 p_applsys_schema  IN   VARCHAR2,
                                 p_owner           IN   VARCHAR2,
                                 p_ret_code        OUT  NoCopy NUMBER,
                                 p_err_msg         OUT  NoCopy VARCHAR2);

PROCEDURE LAUNCH_CONC_PROG(ERRBUF          IN OUT     NoCopy VARCHAR2,
                           RETCODE         IN OUT     NoCopy NUMBER,
                           P_INSTANCE_ID   IN      NUMBER,
                           P_COLLECT_TYPE  IN      NUMBER,
                           REFRESH_SO      IN      NUMBER,
                           REFRESH_SD      IN      NUMBER);


-- 2/14/2002 ngoel, added this procedure for pre-allocating demands and supplies using
-- pegging from the plan in case allocation method profile is set to "Use Planning Output".

PROCEDURE post_plan_allocation(
        ERRBUF          OUT     NoCopy VARCHAR2,
        RETCODE         OUT     NoCopy NUMBER,
        p_plan_id       IN      NUMBER);


-- ngoel 5/7/2002, added new API to be called from planning process to launch concurrent program
-- for post-plan process for summary/ pre-allocation process.

procedure atp_post_plan_proc(
        p_plan_id               IN      NUMBER,
        p_alloc_mode            IN      NUMBER DEFAULT 0,
        p_summary_mode          IN      NUMBER DEFAULT 0,
        x_retcode               OUT     NoCopy NUMBER,
        x_errbuf                OUT     NoCopy VARCHAR2);


PROCEDURE ATP_Purge_MRP_Temp(
  ERRBUF		OUT	NoCopy VARCHAR2,
  RETCODE		OUT	NoCopy NUMBER,
  p_hours		IN	NUMBER
);


-- For summary enhancement - Entry point for Incremental PDS Summary
PROCEDURE Load_Net_Plan(
        ERRBUF          OUT     NoCopy VARCHAR2,
        RETCODE         OUT     NoCopy NUMBER,
        p_plan_id       IN      NUMBER);

/* For time_phased_atp
   Made this a public procedure*/
-- Added input parameters to drop newly added temp table MSC_ALLOC_TEMP_ as well for forecast at PF
PROCEDURE clean_temp_tables(
	p_applsys_schema 	IN  	varchar2,
	p_plan_id		IN	NUMBER,
	p_plan_id2              IN      NUMBER,
	p_demand_priority       IN      VARCHAR2);

/*------------------------------------------------------------|
|New Procedure added for collection enhancement --bug3049003  |
|-------------------------------------------------------------*/
PROCEDURE atp_snapshot_hook(
	                      p_plan_id       IN 	NUMBER
                         );

-- NGOEL 1/15/2004, API to delete CTO BOM and OSS data from ATP temp tables for standalone and post 24x7 plan run plan purging
-- This API will be called by "Purge Plan" conc program.

Procedure Delete_CTO_BOM_OSS(
          p_plan_id         IN      NUMBER);


END MSC_POST_PRO;

/
