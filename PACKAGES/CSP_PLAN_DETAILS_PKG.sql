--------------------------------------------------------
--  DDL for Package CSP_PLAN_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_PLAN_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: csptplds.pls 120.8 2007/12/09 20:38:51 hhaugeru ship $ */

    -- Start of comments
    --
    -- API name	: create_pick
    -- Type 	: Type of API (Eg. Public, simple entity)
    -- Purpose	: This API creates picklist headers and lines for spares.
    --            It calls the auto_detail API of Oracle Inventory which
    --            creates pick based on the picking rules
    --
    -- Modification History
    -- Date        Userid    Comments
    -- ---------   ------    ------------------------------------------
    -- 12/27/99    phegde    Created
    --
    -- Note :
    -- End of comments

procedure order_automation;

procedure main(errbuf              out nocopy varchar2,
               retcode             out nocopy number,
               p_organization_id   in number default null,
               p_save_system_plan  in varchar2 default 'N',
               p_save_planner_plan in varchar2 default 'N',
               p_purge_saved_plans in number default 0,
               p_inventory_item_id in number default null,
               p_forecast_rule_id  in number default null,
               p_forecast_periods  in number default null,
               p_period_size       in number default null);

procedure regenerate(
               p_organization_id   in number default null,
               p_inventory_item_id in number default null,
               p_forecast_rule_id  in number default null,
               p_forecast_periods  in number default null,
               p_period_size       in number default null);

procedure current_onhand(
               p_organization_id   in number default null,
               p_inventory_item_id in number default null);

procedure reorders(
               p_organization_id   in number default null,
               p_inventory_item_id in number default null);

procedure copy_plan_history(
               p_organization_id   in number,
               p_inventory_item_id in number,
               p_history_date      in date);
end;

/
