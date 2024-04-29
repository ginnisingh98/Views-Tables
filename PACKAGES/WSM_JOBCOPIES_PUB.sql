--------------------------------------------------------
--  DDL for Package WSM_JOBCOPIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_JOBCOPIES_PUB" AUTHID CURRENT_USER AS
/* $Header: WSMPCPYS.pls 120.1 2007/06/11 12:55:04 adasa ship $ */

g_debug      VARCHAR2(1);

PROCEDURE Refresh_JobCopies(x_err_buf               OUT NOCOPY VARCHAR2,
                            x_err_code              OUT NOCOPY NUMBER,
                            p_refresh_all_open_jobs IN  NUMBER, -- 1=Yes, 2=No, Default=2
                            p_from_job_name         IN  VARCHAR2,
                            p_to_job_name           IN  VARCHAR2,
                            p_job_assembly_id       IN  NUMBER,
                            p_job_type              IN  NUMBER,
                            p_bill_item_id          IN  NUMBER,
                            p_alt_bom_designator    IN  VARCHAR2,
                            p_rtg_item_id           IN  NUMBER,
                            p_alt_rtg_designator    IN  VARCHAR2,
                            p_select_jobs_by_status IN  NUMBER, -- 1=Yes, 2=No, Default=1
                            p_rel_jobs              IN  NUMBER, -- 1=Yes, 2=No, Default=2
                            p_unrel_jobs            IN  NUMBER, -- 1=Yes, 2=No, Default=2
                            p_onhold_jobs           IN  NUMBER, -- 1=Yes, 2=No, Default=2
                            p_complete_jobs         IN  NUMBER, -- 1=Yes, 2=No, Default=2
                            p_closed_jobs           IN  NUMBER, -- 1=Yes, 2=No, Default=2
                            p_cancelled_jobs        IN  NUMBER, -- 1=Yes, 2=No, Default=2
                            p_org_id                IN  NUMBER,
			    P_rout_rev_basis        IN  NUMBER, -- 1= Job revision Date,2=New revision Date /* last six arguments added in 12.1 refresh bom/routing revision date project */
			    p_dummy                 IN  NUMBER, -- this dummy parameter is added to conditionally enable and disable New Routing Revision Date Parameter
			    p_new_rev_date_rou      IN  VARCHAR2,
			    P_bom_rev_basis         IN  NUMBER, --1= Job revision Date,2=New revision Date
			    p_dummy2                IN  NUMBER, -- this dummy parameter is added to conditionally enable and disable New BOM Revision Date Parameter
			    p_new_rev_date_bom      IN  VARCHAR2
			  );

END WSM_JobCopies_PUB;

/
