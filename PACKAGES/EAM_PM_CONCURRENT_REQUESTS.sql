--------------------------------------------------------
--  DDL for Package EAM_PM_CONCURRENT_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_PM_CONCURRENT_REQUESTS" AUTHID CURRENT_USER AS
/* $Header: EAMPMCRS.pls 120.2 2006/03/16 02:32:09 kmurthy noship $ */

  procedure generate_pm_schedules(
              errbuf           out NOCOPY varchar2,
              retcode          out NOCOPY varchar2,
              p_start_date     in varchar2,
              p_end_date       in varchar2,
              p_org_id         in number,
              p_user_id        in number,
              p_location_id    in number,
              p_category_structure_id    in number,
              p_category_id    in number,
              p_owning_dept_id in number,
              p_item_type_name in varchar2,
              p_item_type in number,
              p_inventory_item_name in varchar2,
              p_asset_group_id in number,
              p_asset_number   in varchar2,
 	      p_set_name       in varchar2,
	      p_set_name_id    in number,
	      p_view_only      in number,
              p_project_number  in varchar2,
              p_project_id      in number,
              p_task_number     in varchar2,
              p_task_id         in number,
              p_parent_wo       in varchar2,
              p_parent_wo_id    in number);

  procedure convert_forecast_work_orders(
              errbuf           out NOCOPY varchar2,
              retcode          out NOCOPY varchar2,
              p_group_id       in number);

END eam_pm_concurrent_requests;


 

/
