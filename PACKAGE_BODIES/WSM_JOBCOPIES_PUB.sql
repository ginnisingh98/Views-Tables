--------------------------------------------------------
--  DDL for Package Body WSM_JOBCOPIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_JOBCOPIES_PUB" AS
/* $Header: WSMPCPYB.pls 120.3 2007/12/14 12:54:07 adasa ship $ */



/****************************
*                           *
*   Refresh_JobCopies       *
*                           *
/***************************/

PROCEDURE Refresh_JobCopies (x_err_buf              OUT NOCOPY VARCHAR2,
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
                                                        -- Added to fix bug #3483253 --
                            p_org_id                IN  NUMBER,
                            p_rout_rev_basis        IN  NUMBER,  /* 1= Job revision Date,2=New revision Date-All jobs,3=New revision Date-Job Revision date less than new date ; Added for Refresh Bom/Routing Revision Date Project */
	                    p_dummy                 IN  NUMBER,  ---- this dummy parameter is added to conditionally enable and disable New Routing Revision Date Parameter
			    p_new_rev_date_rou      IN  VARCHAR2,-- Added for 12.1 Refresh Bom/Routing Revision Date Project
                            p_bom_rev_basis         IN  NUMBER,  /* 1= Job revision Date,2=New revision Date-All jobs,3=New revision Date-Job Revision date less than new date ; Added for Refresh Bom/Routing Revision Date Project */
	                    p_dummy2                IN  NUMBER, -- Added for 12.1 Refresh Bom/Routing Revision Date Project to enable/disable the New BOM Revision Date parameter dynamically.
			    p_new_rev_date_bom      IN  VARCHAR2 -- Added for 12.1 Refresh Bom/Routing Revision Date Project
			   )
IS

    l_stmt_num              NUMBER := 0;
    l_cmn_bill_seq_id       NUMBER;
    l_cmn_rtg_seq_id        NUMBER;

    l_from_job_name         VARCHAR2(240);
    l_to_job_name           VARCHAR2(240);
    l_job_type              NUMBER;
    l_job_assembly_id       NUMBER;
    l_bill_item_id          NUMBER;
    l_alt_bom_designator    VARCHAR2(10);
    l_rtg_item_id           NUMBER;
    l_alt_rtg_designator    VARCHAR2(10);
    l_select_jobs_by_status NUMBER;
    l_rel_jobs              NUMBER;
    l_unrel_jobs            NUMBER;
    l_onhold_jobs           NUMBER;
    l_complete_jobs         NUMBER;
    l_closed_jobs           NUMBER;
    l_cancelled_jobs        NUMBER;
    l_temp                  NUMBER;
    l_msg                   VARCHAR2(2000);
    l_count                 NUMBER;
    l_acct_period_id        NUMBER := 0;     -- Added to fix bug #3958411
    l_rout_rev_basis        NUMBER;          -- Added for 12.1 Refresh Bom/Routing Revision Date Project
    l_new_rev_date_rou      DATE;  --  Added for 12.1 Refresh Bom/Routing Revision Date Project
    l_bom_rev_basis         NUMBER;          -- Added for 12.1 Refresh Bom/Routing Revision Date Project
    l_new_rev_date_bom      DATE;  --  Added for 12.1 Refresh Bom/Routing Revision Date Project
    l_rtg_revision          WIP_DISCRETE_JOBS.ROUTING_REVISION%TYPE; --  Added for 12.1 Refresh Bom/Routing Revision Date Project
    l_bom_revision          WIP_DISCRETE_JOBS.BOM_REVISION%TYPE; --  Added for 12.1 Refresh Bom/Routing Revision Date Project
    l_timezone_enabled      boolean := ( fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' AND
                                        fnd_profile.value('CLIENT_TIMEZONE_ID') IS NOT NULL AND
                                        fnd_profile.value('SERVER_TIMEZONE_ID') IS NOT NULL AND
                                        fnd_profile.value('CLIENT_TIMEZONE_ID') <>
                                        fnd_profile.value('SERVER_TIMEZONE_ID'));

    CURSOR refresh_jobs IS
    SELECT  wdj.wip_entity_id,
            we.wip_entity_name,
            wdj.organization_id,
            wdj.primary_item_id,
            decode(wdj.job_type, 1, wdj.primary_item_id, wdj.routing_reference_id) routing_item_id, -- Fix for bug #3347947
            wdj.alternate_routing_designator alt_rtg_desig,-- Fix for bug #3347947
            wdj.common_routing_sequence_id,
           --nvl(wdj.routing_revision_date, sysdate) routing_revision_date,
	    decode(l_rout_rev_basis,2,l_new_rev_date_rou,nvl(wdj.routing_revision_date, sysdate)) routing_revision_date,--12.1 Routing/BOM Revision Date Refresh Programme

            decode(wdj.job_type, 1, wdj.primary_item_id, wdj.bom_reference_id) bill_item_id,-- Fix for bug #3347947
            wdj.alternate_bom_designator alt_bom_desig,
            WSMPUTIL.GET_JOB_BOM_SEQ_ID(wdj.wip_entity_id) bill_sequence_id,-- Fix for bug #3286849
            wdj.common_bom_sequence_id,
            -- wdj.bom_revision_date, --commented for 12.1 refresh bom/routing revision date project
	    decode(l_bom_rev_basis,2,l_new_rev_date_bom,wdj.bom_revision_date) bom_revision_date,--12.1 Routing/BOM Revision Date Refresh Programme
            wdj.wip_supply_type,
            wdj.status_type
    FROM    wip_discrete_jobs wdj,
            wip_entities we
    WHERE   we.organization_id = p_org_id
    AND     we.organization_id = wdj.organization_id
    AND     we.wip_entity_id = wdj.wip_entity_id
    AND     we.entity_type in (5, 8)
    AND     we.wip_entity_name between
             nvl(l_from_job_name, we.wip_entity_name)
             and nvl(l_to_job_name, we.wip_entity_name)
    AND     wdj.job_type = nvl(l_job_type, wdj.job_type)
    AND     wdj.primary_item_id = nvl(l_job_assembly_id, wdj.primary_item_id)
    AND     nvl(wdj.common_bom_sequence_id, -1) =
                nvl(l_cmn_bill_seq_id, nvl(wdj.common_bom_sequence_id, -1))
    AND     wdj.common_routing_sequence_id =
                nvl(l_cmn_rtg_seq_id, wdj.common_routing_sequence_id)
    -- Start : Fix for bug #3483253 --
    -- Changed following condition to allow upgrading all statuses --
    AND     (wdj.status_type = decode (l_select_jobs_by_status,
                                        1, decode(l_unrel_jobs, 1, 1, 0),
                                        wdj.status_type)
             OR wdj.status_type = decode (l_select_jobs_by_status,
                                           1, decode(l_rel_jobs, 1, 3, 0),
                                           wdj.status_type)
             OR wdj.status_type = decode (l_select_jobs_by_status,
                                           1, decode(l_complete_jobs, 1, 4, 0),
                                           wdj.status_type)
             OR wdj.status_type = decode (l_select_jobs_by_status,
                                           1, decode(l_onhold_jobs, 1, 6, 0),
                                           wdj.status_type)
             OR wdj.status_type = decode (l_select_jobs_by_status,
                                           1, decode(l_closed_jobs, 1, 12, 0),
                                           wdj.status_type)
             OR wdj.status_type = decode (l_select_jobs_by_status,
                                           1, decode(l_cancelled_jobs, 1, 7, 0),
                                           wdj.status_type)
            )

    ;

    -- End : Fix for bug #3483253 --


BEGIN

    l_stmt_num := 10;

    g_debug := FND_PROFILE.VALUE('MRP_DEBUG');

    fnd_file.put_line(fnd_file.log, 'Parameters to Refresh_JobCopies are :');
    fnd_file.put_line(fnd_file.log, '  refresh_all_open_jobs ='||p_refresh_all_open_jobs);
    fnd_file.put_line(fnd_file.log, ', from_job_name         ='||p_from_job_name        );
    fnd_file.put_line(fnd_file.log, ', to_job_name           ='||p_to_job_name          );
    fnd_file.put_line(fnd_file.log, ', job_type              ='||p_job_type             );
    fnd_file.put_line(fnd_file.log, ', job_assembly_id       ='||p_job_assembly_id      );
    fnd_file.put_line(fnd_file.log, ', bill_item_id          ='||p_bill_item_id         );
    fnd_file.put_line(fnd_file.log, ', alt_bom_designator    ='||p_alt_bom_designator   );
    fnd_file.put_line(fnd_file.log, ', rtg_item_id           ='||p_rtg_item_id          );
    fnd_file.put_line(fnd_file.log, ', alt_rtg_designator    ='||p_alt_rtg_designator   );
    fnd_file.put_line(fnd_file.log, ', select_jobs_by_status ='||p_select_jobs_by_status);
    fnd_file.put_line(fnd_file.log, ', rel_jobs              ='||p_rel_jobs             );
    fnd_file.put_line(fnd_file.log, ', unrel_jobs            ='||p_unrel_jobs           );
    fnd_file.put_line(fnd_file.log, ', onhold_jobs           ='||p_onhold_jobs          );
    fnd_file.put_line(fnd_file.log, ', complete_jobs         ='||p_complete_jobs        );
    fnd_file.put_line(fnd_file.log, ', closed_jobs           ='||p_closed_jobs          );
    fnd_file.put_line(fnd_file.log, ', cancelled_jobs        ='||p_cancelled_jobs       );
    fnd_file.put_line(fnd_file.log, ', org_id                ='||p_org_id               );
    fnd_file.put_line(fnd_file.log, ', refresh_routing_based_on ='||p_rout_rev_basis    ); --Added for 12.1 Refresh Bom/Routing Revision Date Project
    fnd_file.put_line(fnd_file.log, ', New_revision_date_rou ='|| p_new_rev_date_rou   ); --Added for 12.1 Refresh Bom/Routing Revision Date Project
    fnd_file.put_line(fnd_file.log, ', refresh_bom_based_on     ='||p_bom_rev_basis    ); --Added for 12.1 Refresh Bom/Routing Revision Date Project
    fnd_file.put_line(fnd_file.log, ', New_revision_date_bom    ='|| p_new_rev_date_bom   ); --Added for 12.1 Refresh Bom/Routing Revision Date Project





    IF (WSMPUTIL.CREATE_LBJ_COPY_RTG_PROFILE(p_org_id) = 2) THEN
        --"Profile 'WSM: Create Lot Based Jobs Copy Routing' is set to NO. Cannot refresh Job Copies. "
        fnd_message.set_name('WSM', 'WSM_USE_COPY_NOT_SET_ERR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

        return;
    ELSE
        fnd_file.put_line(fnd_file.log, 'Refreshing the jobs...'); -- VJ remove
    END IF;

    l_stmt_num := 20;

    IF (p_refresh_all_open_jobs = 2) -- No
        AND (p_from_job_name IS NULL)
        AND (p_to_job_name IS NULL)
        AND (p_job_type IS NULL)
        AND (p_job_assembly_id IS NULL)
        AND (p_bill_item_id IS NULL)
        AND (p_rtg_item_id IS NULL)
        AND ((p_select_jobs_by_status = 1) OR (p_select_jobs_by_status IS NULL))-- Yes
        AND ((p_rel_jobs = 2) OR (p_rel_jobs IS NULL)) -- No
        AND ((p_unrel_jobs = 2) OR (p_unrel_jobs IS NULL)) -- No
        AND ((p_onhold_jobs = 2) OR (p_onhold_jobs IS NULL)) -- No
        AND ((p_complete_jobs = 2) OR (p_complete_jobs IS NULL)) -- No
        AND ((p_closed_jobs = 2) OR (p_closed_jobs IS NULL)) -- No
        AND ((p_cancelled_jobs = 2) OR (p_cancelled_jobs IS NULL)) -- No
                -- Added to fix bug #3483253 --
    THEN
        --"Based on the concurrent request parameters, Job Copies for no jobs were refreshed. "
        fnd_message.set_name('WSM', 'WSM_NO_JOBS_TO_REFR');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

        return;
    END IF;


    l_from_job_name         := p_from_job_name;
    l_to_job_name           := p_to_job_name;
    l_job_type              := p_job_type;
    l_job_assembly_id       := p_job_assembly_id;
    l_bill_item_id          := p_bill_item_id;
    l_alt_bom_designator    := p_alt_bom_designator;
    l_rtg_item_id           := p_rtg_item_id;
    l_alt_rtg_designator    := p_alt_rtg_designator;
    l_select_jobs_by_status := nvl(p_select_jobs_by_status, 1);
    l_rel_jobs              := nvl(p_rel_jobs, 2);
    l_unrel_jobs            := nvl(p_unrel_jobs, 2);
    l_onhold_jobs           := nvl(p_onhold_jobs, 2);
    l_complete_jobs         := nvl(p_complete_jobs, 2);
    l_closed_jobs           := nvl(p_closed_jobs, 2);
    l_cancelled_jobs        := nvl(p_cancelled_jobs, 2);
    l_rout_rev_basis        := p_rout_rev_basis; --Added for 12.1 Refresh Bom/Routing Revision Date Project
    l_bom_rev_basis         := p_bom_rev_basis; --Added for 12.1 Refresh Bom/Routing Revision Date Project
    l_rtg_revision          := NULL; --Added for Refresh Bom/Routing Revision Date Project
    l_bom_revision          := NULL; --Added for Refresh Bom/Routing Revision Date Project


    IF (p_refresh_all_open_jobs = 1) -- Yes
    THEN
    --"Based on the concurrent request parameter 'Refresh All Open Jobs', all other parameters are ignored."
        fnd_message.set_name('WSM', 'WSM_REFR_PARAMS_IGNORED');
        fnd_file.put_line(fnd_file.log, fnd_message.get);

        -- Set parameters to their default values
        l_from_job_name         := NULL;
        l_to_job_name           := NULL;
        l_job_type              := NULL;
        l_job_assembly_id       := NULL;
        l_bill_item_id          := NULL;
        l_alt_bom_designator    := NULL;
        l_cmn_bill_seq_id       := NULL;
        l_rtg_item_id           := NULL;
        l_alt_rtg_designator    := NULL;
        l_cmn_rtg_seq_id        := NULL;
        l_select_jobs_by_status := 1;
        l_rel_jobs              := 1;
        l_unrel_jobs            := 1;
        l_onhold_jobs           := 1;
        l_complete_jobs         := 1;
        l_closed_jobs           := 1;
        l_cancelled_jobs        := 1;

    ELSE --IF (p_refresh_all_open_jobs = 0) -- No

    l_stmt_num := 30;

        IF (p_bill_item_id IS NOT NULL) THEN
            -- Get the common bill sequence id
            BEGIN
                SELECT  common_bill_sequence_id
                INTO    l_cmn_bill_seq_id
                FROM    bom_bill_of_materials
                WHERE   organization_id = p_org_id
                AND     assembly_item_id = l_bill_item_id
                AND     nvl(alternate_bom_designator, '-1') =
                        nvl(l_alt_bom_designator, '-1');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                    fnd_message.set_token('FLD_NAME', 'Alternate Bill Designator');
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    return;

                WHEN OTHERS THEN
                    fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                    fnd_message.set_token('FLD_NAME', 'Alternate Bill Designator');
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    return;
            END;
        END IF;

    l_stmt_num := 40;

        IF (p_rtg_item_id IS NOT NULL) THEN
            -- Get the common routing sequence id
            BEGIN
                SELECT  common_routing_sequence_id
                INTO    l_cmn_rtg_seq_id
                FROM    bom_operational_routings
                WHERE   organization_id = p_org_id
                AND     assembly_item_id = l_rtg_item_id
                AND     nvl(alternate_routing_designator, '-1') =
                        nvl(l_alt_rtg_designator, '-1');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                    fnd_message.set_token('FLD_NAME', 'Alternate Routing Designator');
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    return;

                WHEN OTHERS THEN
                    fnd_message.set_name('WSM', 'WSM_INVALID_FIELD');
                    fnd_message.set_token('FLD_NAME', 'Alternate Routing Designator');
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    return;
            END;
        END IF;

        IF (l_select_jobs_by_status = 2) THEN
        -- =No, this implies select all statuses
            l_rel_jobs              := 1;
            l_unrel_jobs            := 1;
            l_onhold_jobs           := 1;
            l_complete_jobs         := 1;
            l_closed_jobs           := 1;
            l_cancelled_jobs        := 1;
        END IF;
    END IF;




 --*****************************************************************
    IF(l_rout_rev_basis IN (2,3)) THEN

   /* Added for 12.1 Refresh Bom/Routing Revision Date Project  to change the  new revision date for BOM or Routing to
    Server Time Zone */
     IF (l_timezone_enabled)   THEN

    fnd_file.put_line(fnd_file.log, 'Timezone is enabled and calling HZ_TIME_ZONE_PUB API ');

     l_new_rev_date_rou := fnd_timezone_pub.adjust_datetime(date_time => fnd_date.displayDT_to_date(p_new_rev_date_rou),
						             from_tz   => fnd_timezones.get_client_timezone_code,
						             to_tz     => fnd_timezones.get_server_timezone_code);

    ELSE
          fnd_file.put_line(fnd_file.log, 'Timezone is not enabled');
	  l_new_rev_date_rou := fnd_date.displayDT_to_date(p_new_rev_date_rou);
    END IF;
 END IF;


    IF(l_bom_rev_basis IN (2,3)) THEN


     IF (l_timezone_enabled)   THEN

       l_new_rev_date_bom := fnd_timezone_pub.adjust_datetime(date_time => fnd_date.displayDT_to_date(p_new_rev_date_bom),
						                from_tz  => fnd_timezones.get_client_timezone_code,
						                 to_tz   => fnd_timezones.get_server_timezone_code);

      ELSE
       l_new_rev_date_bom := fnd_date.displayDT_to_date(p_new_rev_date_bom);

      END IF;
    END IF;

 --***************************************************************************
    l_stmt_num := 50;

    IF (g_debug = 'Y') THEN
        SELECT  count(*)
        INTO    l_count
        FROM    wip_discrete_jobs wdj,
                wip_entities we
        WHERE   we.organization_id = p_org_id
        AND     we.organization_id = wdj.organization_id
        AND     we.wip_entity_id = wdj.wip_entity_id
        AND     we.entity_type in (5, 8)
        AND     we.wip_entity_name between
                 nvl(l_from_job_name, we.wip_entity_name)
                 and nvl(l_to_job_name, we.wip_entity_name)
        AND     wdj.job_type = nvl(l_job_type, wdj.job_type)
        AND     wdj.primary_item_id = nvl(l_job_assembly_id, wdj.primary_item_id)
        AND     nvl(wdj.common_bom_sequence_id, -1) =
                    nvl(l_cmn_bill_seq_id, nvl(wdj.common_bom_sequence_id, -1))
        AND     wdj.common_routing_sequence_id =
                    nvl(l_cmn_rtg_seq_id, wdj.common_routing_sequence_id)
        AND     (wdj.status_type = decode (l_select_jobs_by_status,
                                            1, decode(l_unrel_jobs, 1, 1, 0),
                                            wdj.status_type)
                 OR wdj.status_type = decode (l_select_jobs_by_status,
                                               1, decode(l_rel_jobs, 1, 3, 0),
                                               wdj.status_type)
                 OR wdj.status_type = decode (l_select_jobs_by_status,
                                               1, decode(l_complete_jobs, 1, 4, 0),
                                               wdj.status_type)
                 OR wdj.status_type = decode (l_select_jobs_by_status,
                                               1, decode(l_onhold_jobs, 1, 6, 0),
                                               wdj.status_type)
                 OR wdj.status_type = decode (l_select_jobs_by_status,
                                               1, decode(l_closed_jobs, 1, 12, 0),
                                               wdj.status_type)
                 OR wdj.status_type = decode (l_select_jobs_by_status,
                                               1, decode(l_cancelled_jobs, 1, 7, 0),
                                               wdj.status_type)

                )

        ;
        fnd_file.put_line(fnd_file.log, l_count||' jobs will be refreshed');
    END IF;

    l_stmt_num := 60;

    IF (g_debug = 'Y') THEN
        fnd_file.put_line(fnd_file.log, 'Variables used in refresh_jobs cursor are :');
        fnd_file.put_line(fnd_file.log, '  l_from_job_name   ='||l_from_job_name);
        fnd_file.put_line(fnd_file.log, ', l_to_job_name     ='||l_to_job_name);
        fnd_file.put_line(fnd_file.log, ', l_job_type        ='||l_job_type);
        fnd_file.put_line(fnd_file.log, ', l_job_assembly_id ='||l_job_assembly_id);
        fnd_file.put_line(fnd_file.log, ', l_cmn_bill_seq_id ='||l_cmn_bill_seq_id);
        fnd_file.put_line(fnd_file.log, ', l_cmn_rtg_seq_id  ='||l_cmn_rtg_seq_id);
        fnd_file.put_line(fnd_file.log, ', l_unrel_jobs      ='||l_unrel_jobs);
        fnd_file.put_line(fnd_file.log, ', l_rel_jobs        ='||l_rel_jobs);
        fnd_file.put_line(fnd_file.log, ', l_complete_jobs   ='||l_complete_jobs);
        fnd_file.put_line(fnd_file.log, ', l_onhold_jobs     ='||l_onhold_jobs);
        fnd_file.put_line(fnd_file.log, ', l_closed_jobs     ='||l_closed_jobs);
        fnd_file.put_line(fnd_file.log, ', l_cancelled_jobs  ='||l_cancelled_jobs);
        fnd_file.put_line(fnd_file.log, ', l_rout_rev_basis  ='||l_rout_rev_basis    ); --Added for 12.1 Refresh Bom/Routing Revision Date project
        fnd_file.put_line(fnd_file.log, ', l_new_rev_date_rou ='|| to_char(l_new_rev_date_rou,'DD-MON-YYYY HH24:MI:SS') ); --Added for 12.1 Refresh Bom/Routing Revision Date project
        fnd_file.put_line(fnd_file.log, ', l_bom_rev_basis  ='||l_bom_rev_basis );  --Added for 12.1 Refresh Bom/Routing Revision Date project
        fnd_file.put_line(fnd_file.log, ', l_new_rev_date_bom ='|| to_char(l_new_rev_date_bom,'DD-MON-YYYY HH24:MI:SS')  ); --Added for 12.1 Refresh Bom/Routing Revision Date project

 END IF;

    FOR cur_refresh_jobs IN refresh_jobs
    LOOP

        x_err_code := 0;
        x_err_buf := NULL;

    l_stmt_num := 70;

--*****************************************************************************************************
    /* Added for 12.1 Refresh Bom/Routing Revision Date Project  to change the revision_date for BOM or
	      routing if user selects to apply New Revision Date to only jobs with revision date less than New Revision date */

    IF (l_rout_rev_basis = 3 AND cur_refresh_jobs.routing_revision_date <= l_new_rev_date_rou ) THEN

    cur_refresh_jobs.routing_revision_date := l_new_rev_date_rou;

    END IF;


    IF (l_bom_rev_basis = 3 AND nvl(cur_refresh_jobs.bom_revision_date,l_new_rev_date_bom) <= l_new_rev_date_bom ) THEN

    cur_refresh_jobs.bom_revision_date := l_new_rev_date_bom;

    END IF;

--*******************************************************************************************************


        -- Fix for bug #3677276 : Moved update wo.wsm_op_seq_num stmt
        -- to inside create_jobcopies.

        -- Start : Fix for bug #3958411 --
        l_acct_period_id := -1; -- A valid value

        IF (cur_refresh_jobs.status_type = 12) THEN -- Closed job
            -- Check if it is in an open accounting period.
            l_acct_period_id := 0;

            BEGIN
    l_stmt_num := 75;
                SELECT  OAP.acct_period_id
                INTO    l_acct_period_id
                FROM    ORG_ACCT_PERIODS OAP,
                        WIP_DISCRETE_JOBS WDJ
                WHERE   WDJ.WIP_ENTITY_ID = cur_refresh_jobs.wip_entity_id
                AND     WDJ.ORGANIZATION_ID = cur_refresh_jobs.organization_id
                AND     OAP.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
                AND     INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG (WDJ.DATE_CLOSED,
                                                                    wdj.organization_id)
                          BETWEEN OAP.PERIOD_START_DATE AND OAP.SCHEDULE_CLOSE_DATE
                AND     OAP.OPEN_FLAG = 'Y';

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_acct_period_id := 0;

                WHEN OTHERS THEN
                    l_acct_period_id := 0;
            END;

            IF (l_acct_period_id <> 0) THEN -- Acct period found
                l_acct_period_id := -1; -- Make it a valid value
            END IF;
        END IF;

IF (l_acct_period_id = -1) THEN -- {

    -- End : Fix for bug #3958411 --

    l_stmt_num := 80;

        WSM_JobCopies_PVT.Create_JobCopies -- Call #1
            (
             x_err_buf              => x_err_buf,
             x_err_code             => x_err_code,
             p_wip_entity_id        => cur_refresh_jobs.wip_entity_id,
             p_org_id               => cur_refresh_jobs.organization_id,
             p_primary_item_id      => cur_refresh_jobs.primary_item_id,
             p_routing_item_id      => cur_refresh_jobs.routing_item_id,-- Fix for bug #3347947
             p_alt_rtg_desig        => cur_refresh_jobs.alt_rtg_desig,-- Fix for bug #3347947
             p_rtg_seq_id           => NULL,-- Will be NULL till reqd for some functionality
             p_common_rtg_seq_id    => cur_refresh_jobs.common_routing_sequence_id,
             p_rtg_rev_date         => cur_refresh_jobs.routing_revision_date,
             p_bill_item_id         => cur_refresh_jobs.bill_item_id,-- Fix for bug #3347947
             p_alt_bom_desig        => cur_refresh_jobs.alt_bom_desig,
             p_bill_seq_id          => cur_refresh_jobs.bill_sequence_id,-- To fix bug #3286849
             p_common_bill_seq_id   => cur_refresh_jobs.common_bom_sequence_id,
             p_bom_rev_date         => cur_refresh_jobs.bom_revision_date,
             p_wip_supply_type      => cur_refresh_jobs.wip_supply_type,
             p_last_update_date     => sysdate,
             p_last_updated_by      => fnd_global.user_id,
             p_last_update_login    => fnd_global.login_id,
             p_creation_date        => sysdate,
             p_created_by           => fnd_global.user_id,
             p_request_id           => fnd_global.conc_request_id,
             p_program_app_id       => fnd_global.prog_appl_id,
             p_program_id           => fnd_global.conc_program_id,
             p_program_update_date  => sysdate,
             p_inf_sch_flag         => 'Y',
             p_inf_sch_mode         => NULL,
             p_inf_sch_date         => NULL
            );
	-- MES:Populate CURRENT_RTG_OP_SEQ_NUM
        IF (x_err_code = 0) OR (x_err_code IS NULL) OR (x_err_code = -1) THEN
	   /*update wip_operations wo
	   set    wo.operation_seq_id = NULL,
	          wo.wsm_copy_op_seq_num = NULL
	   where  wo.operation_seq_id is NOT NULL
	   and    wo.wip_entity_id = cur_refresh_jobs.wip_entity_id
	   and    not in (select wco.operation_seq_id from wsm_copy_operations wco
	   		      where  wco.operation_seq_id = nvl(wo.operation_seq_id,-1)
			      and    wco.wip_entity_id = cur_refresh_jobs.wip_entity_id);
	   IF SQL%ROWCOUNT > 0 THEN */
	       update wsm_lot_based_jobs wsm
	       set    wsm.current_rtg_op_seq_num = null
	       where  wsm.wip_entity_id = cur_refresh_jobs.wip_entity_id
	       and    not exists (select 1 from wsm_copy_operations wco
	   		      where  wco.operation_seq_num = nvl(wsm.current_job_op_seq_num,-1)
			      and    wco.wip_entity_id = cur_refresh_jobs.wip_entity_id);
	   -- END IF;
 --*************************************************************************************************************
	      /* Added for 12.1 Refresh Bom/Routing Revision Date Project  to change the revision_date for BOM or
	      routing in WDJ if user selects new revision date */

	     IF (l_rout_rev_basis IN (2,3)) OR (l_bom_rev_basis IN (2,3)) THEN

	          IF (l_rout_rev_basis IN (2,3)) THEN
                    BEGIN
		   wip_revisions.routing_revision( p_organization_id =>  cur_refresh_jobs.organization_id,
                                                      p_item_id         =>  cur_refresh_jobs.routing_item_id,
                                                   p_revision        =>  l_rtg_revision,
                                                   p_revision_date   =>  cur_refresh_jobs.routing_revision_date,
                                                   p_start_date      =>  cur_refresh_jobs.routing_revision_date
                                                        );

                   EXCEPTION
                     WHEN OTHERS THEN
                      fnd_file.put_line(fnd_file.log, 'cannot refresh job '|| cur_refresh_jobs.wip_entity_name ||' as there is no valid routing revision at new routing revision date' );
                          x_err_code := -2;

                    END;
		  END IF;

		  IF (l_bom_rev_basis IN (2,3)) THEN
                  BEGIN
		   wip_revisions.bom_revision( p_organization_id =>  cur_refresh_jobs.organization_id,
                                               p_item_id         =>  cur_refresh_jobs.bill_item_id,
                                               p_revision        =>  l_bom_revision,
                                               p_revision_date   =>  cur_refresh_jobs.bom_revision_date,
                                               p_start_date      =>  cur_refresh_jobs.bom_revision_date
                                                        );

                  EXCEPTION
                    WHEN OTHERS THEN
                     fnd_file.put_line(fnd_file.log, 'cannot refresh job '|| cur_refresh_jobs.wip_entity_name ||' as there is no valid bom revision at new bom revision date' );
                       x_err_code := -2;

                   END;
		  END IF;


		 UPDATE WIP_DISCRETE_JOBS
		 SET routing_revision_date = cur_refresh_jobs.routing_revision_date,
		     routing_revision = nvl(l_rtg_revision,routing_revision),
		     bom_revision_date = cur_refresh_jobs.bom_revision_date,
                     bom_revision = nvl(l_bom_revision,bom_revision)
		     where wip_entity_id = cur_refresh_jobs.wip_entity_id;

	    END IF;
--**************************************************************************************************************
	END IF;
        IF (x_err_code = 0) OR (x_err_code IS NULL)THEN
    l_stmt_num := 90;
            --"Organization: ORG_NAME Job: JOB_NAME"
            fnd_message.set_name('WSM', 'WSM_JOB_LIST');
            fnd_message.set_token('ORG_NAME', cur_refresh_jobs.organization_id);
            fnd_message.set_token('JOB_NAME', cur_refresh_jobs.wip_entity_name||
                                              '('||cur_refresh_jobs.wip_entity_id||')');
            l_msg := fnd_message.get;

            --"Job Copies STATUS Refreshed."
            fnd_message.set_name('WSM', 'WSM_REFR_STATUS');
            fnd_message.set_token('STATUS', NULL);
            fnd_file.put_line(fnd_file.log, l_msg||' '||fnd_message.get
                             );

            commit; -- Added to fix bug #3465125

        ELSIF (x_err_code = -1) THEN -- Warning
    l_stmt_num := 100;
            --"Organization: ORG_NAME Job: JOB_NAME"
            fnd_message.set_name('WSM', 'WSM_JOB_LIST');
            fnd_message.set_token('ORG_NAME', cur_refresh_jobs.organization_id);
            fnd_message.set_token('JOB_NAME', cur_refresh_jobs.wip_entity_name||
                                              '('||cur_refresh_jobs.wip_entity_id||')');
            l_msg := fnd_message.get;

            --"Job Copies STATUS Refreshed."
            fnd_message.set_name('WSM', 'WSM_REFR_STATUS');
            fnd_message.set_token('STATUS', NULL);
            fnd_file.put_line(fnd_file.log, l_msg||' '||fnd_message.get||' '||x_err_buf
                             );

            commit; -- Added to fix bug #3465125

        ELSE -- Error
    l_stmt_num := 110;
            --"Organization: ORG_NAME Job: JOB_NAME"
            fnd_message.set_name('WSM', 'WSM_JOB_LIST');
            fnd_message.set_token('ORG_NAME', cur_refresh_jobs.organization_id);
            fnd_message.set_token('JOB_NAME', cur_refresh_jobs.wip_entity_name||
                                              '('||cur_refresh_jobs.wip_entity_id||')');
            l_msg := fnd_message.get;

            --"Job Copies STATUS Refreshed."
            fnd_message.set_name('WSM', 'WSM_REFR_STATUS');
            fnd_message.set_token('STATUS', 'Not');
            fnd_file.put_line(fnd_file.log, l_msg||' '||fnd_message.get||' '||x_err_buf
                             );

            rollback; -- Added to fix bug #3465125

    l_stmt_num := 120;

            BEGIN
                SELECT  1
                INTO    l_temp
                FROM    WSM_LOT_BASED_JOBS
                WHERE   wip_entity_id = cur_refresh_jobs.wip_entity_id;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
    l_stmt_num := 130;
                    INSERT into WSM_LOT_BASED_JOBS
                        (WIP_ENTITY_ID,
                         ORGANIZATION_ID,
                         ON_REC_PATH,
                         INTERNAL_COPY_TYPE,
                         COPY_PARENT_WIP_ENTITY_ID,
                         INFINITE_SCHEDULE,
                         ROUTING_REFRESH_DATE,
                         LAST_UPDATE_DATE,
                         LAST_UPDATED_BY,
                         LAST_UPDATE_LOGIN,
                         CREATION_DATE,
                         CREATED_BY,
                         REQUEST_ID,
                         PROGRAM_APPLICATION_ID,
                         PROGRAM_ID,
                         PROGRAM_UPDATE_DATE
                        )
                    VALUES
                        (cur_refresh_jobs.wip_entity_id,
                         cur_refresh_jobs.organization_id,
                         'N',     -- ON_REC_PATH
                         3,       -- INTERNAL_COPY_TYPE :   -- Copies not existing due to Upgrade
                                                            -- and incorrect due to Refresh
                         NULL,    -- COPY_PARENT_WIP_ENTITY_ID
                         NULL,    -- INFINITE_SCHEDULE
                         SYSDATE, -- ROUTING_REFRESH_DATE
                         sysdate,
                         fnd_global.user_id,
                         fnd_global.login_id,
                         sysdate,
                         fnd_global.user_id,
                         fnd_global.conc_request_id,
                         fnd_global.prog_appl_id,
                         fnd_global.conc_program_id,
                         sysdate
                        );

                WHEN OTHERS THEN
                    NULL;
            END;

        END IF;

END IF;  --IF (l_acct_period_id = -1) } Added to fix bug #3958411

    END LOOP;

    l_stmt_num := 140;

    x_err_code := 0;
    x_err_buf := NULL;

EXCEPTION
    WHEN others THEN
        x_err_code := SQLCODE;
        x_err_buf := 'Refresh_JobCopies('||l_stmt_num||'): '||substrb(sqlerrm,1,1000);
        fnd_file.put_line(fnd_file.log, x_err_buf);

END Refresh_JobCopies;


END WSM_JobCopies_PUB;

/
