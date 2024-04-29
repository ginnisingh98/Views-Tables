--------------------------------------------------------
--  DDL for Package EAM_PM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PM_UTILS" AUTHID CURRENT_USER AS
/* $Header: EAMPMUTS.pls 120.1 2006/02/16 01:03:19 kmurthy noship $ */

  /**
   * This procedure should be called when completing the work order. It will update
   * the related PM rule data if applicable.
   */
  procedure update_pm_when_complete(p_org_id        in number,
                                    p_wip_entity_id in number,
                                    p_completion_date in date);

  /**
   * This procedure should be called when uncompleting the work order. It will update
   * the related PM rule data if applicable.
   */
  procedure update_pm_when_uncomplete(p_org_id        in number,
                                      p_wip_entity_id in number);

/*
* This is a function. Given an organization id and wip_entity_number,
* figures out whether this is the latest completed work order for
* its asset/activity association.
*/
  function check_is_last_wo(p_org_id number,
                            p_wip_entity_id number,
			    p_last_service_end_date OUT NOCOPY DATE )
  return boolean;


  /**
   * This procedure is called to move the forecasted work order suggestions from
   * forecast table to wip_job_schedule_interface to be uploaded. It removes the
   * records from forecast table then.
   */
  procedure transfer_to_wdj(p_group_id number);

END eam_pm_utils;

 

/
