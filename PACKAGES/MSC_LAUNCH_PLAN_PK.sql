--------------------------------------------------------
--  DDL for Package MSC_LAUNCH_PLAN_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_LAUNCH_PLAN_PK" AUTHID CURRENT_USER AS
/* $Header: MSCPLAPS.pls 120.3.12010000.2 2010/03/23 13:51:54 skakani ship $ */
-- Modification for bug 1863615
	PROCEDURE 	msc_launch_plan (
						errbuf                  OUT NOCOPY VARCHAR2,
                                                retcode                 OUT NOCOPY NUMBER,
                                                arg_designator          IN         VARCHAR2,
                                                arg_plan_id             IN         NUMBER,
                                                arg_launch_snapshot     IN         NUMBER,
                                                arg_launch_planner      IN         NUMBER,
                                                arg_netchange_mode      IN         NUMBER,
                                                arg_anchor_date         IN         VARCHAR2,
                                                p_archive_flag          IN         number default 2,
                                                p_plan_type_dummy       IN         VARCHAR2 default null,
                                                p_24x7atp               IN         NUMBER default 2,
                                                p_reschedule_dummy      IN         VARCHAR2 default null,
						arg_release_reschedules IN         NUMBER default 2        ,
	                                        p_snap_static_entities IN NUMBER default 1                 ,
						p_calculate_liability_dummy IN    varchar2 default null ,
						p_calculate_liabilty   IN         number default 2,
                                                p_generate_fcst        IN         number default 2,
                                                p_compute_ss_eoq      IN
number default 2
					);

	/*-----------------+
	| Define constants |
	+-----------------*/

	SYS_YES               CONSTANT INTEGER := 1;
	SYS_NO                CONSTANT INTEGER := 2;
      	DP_SCN_ONLY_SNAPSHOT  CONSTANT INTEGER := 3; /* SNOP Change */
        /* Changes for DS Exception only mode */

        DS_EXP_ONLY           CONSTANT INTEGER := 3;
        DS_OLS_ONLY           CONSTANT INTEGER := 4;
	DP_SCN_ONLY_SNP_MODE  CONSTANT INTEGER := 5; /* SNOP Change */ /* New mode for SOP */
	VERSION               CONSTANT CHAR(80) :=
			 '$Header: MSCPLAPS.pls 120.3.12010000.2 2010/03/23 13:51:54 skakani ship $';
	PROCEDURE msc_switch_24_7_atp_plans(
						errbuf          OUT NOCOPY VARCHAR2,
                                                retcode         OUT NOCOPY NUMBER,
                                                P_Org_plan_id   IN         NUMBER,
                                                P_temp_plan_id  IN         NUMBER);

        /* SNOP Change  Start*/
        PROCEDURE MSC_CHECK_PLAN_COMPLETION(
                                                launch_plan_request_id IN  NUMBER,
                                                plan_id                IN  NUMBER,
                                                completion_code        OUT NOCOPY NUMBER);

        PROCEDURE MSC_WAIT_FOR_REQUEST(
                                                p_request_id IN  NUMBER,
                                                p_timeout    IN  NUMBER,
                                                o_retcode    OUT NOCOPY NUMBER);

        /* constants */

        ---- Completion codes -----
        SUCCESS            CONSTANT NUMBER := 1;
        SNAPSHOT_FAILURE   CONSTANT NUMBER := 2;
        PLANNER_FAILURE    CONSTANT NUMBER := 3;

        FAILURE_OR_TIMEOUT CONSTANT NUMBER := 2;

        --- NULL VALUE -------
        NULL_VALUE  CONSTANT NUMBER := -23453;

        /* SNOP Change End*/

 PROCEDURE msc_launch_schedule ( errbuf                    OUT  NOCOPY VARCHAR2
                                , retcode                  OUT  NOCOPY NUMBER
                                , arg_plan_id              IN   NUMBER
                                , arg_launch_snapshot      IN   NUMBER
                                , arg_launch_scheduler     IN   NUMBER
                                , arg_ols_horizon_days     IN   NUMBER default null
                                , arg_frozen_horizon_days  IN   NUMBER default null);
  Procedure purge_user_notes_data(p_plan_id number);
END MSC_LAUNCH_PLAN_PK;

/
