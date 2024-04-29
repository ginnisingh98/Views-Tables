--------------------------------------------------------
--  DDL for Package MSD_LIABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_LIABILITY" AUTHID CURRENT_USER AS
/* $Header: msdliabs.pls 120.1 2005/09/09 06:16:37 sjagathe noship $ */

 C_MSC_DEBUG   VARCHAR2(1)    := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

procedure run_liability_flow(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id       IN  NUMBER);

/* This procedure is called from MSC_GET_BIS_VALUES.UI_POST_PLAN.
 * It checks to see if the user is going to run Liability for PDS plan.
 */

procedure run_liability_flow_ascp(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_plan_id       IN  NUMBER);


/* This procedure is a wrapper over the private procedure
 * 'validate_demand_plan'.
 * This procedure will be called from the procedure
 * msd_validate_demand_plan.validate_demand_plan
 * Bug# 4345323 User will now be able to validate an
 *              existing liability plan from the UI
 */
PROCEDURE validate_liability_plan (
  			       errbuf                 OUT NOCOPY VARCHAR2,
                               retcode                OUT NOCOPY VARCHAR2,
                               p_liability_plan_id    IN         NUMBER);




END MSD_LIABILITY ;

 

/
