--------------------------------------------------------
--  DDL for Package INVWATP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVWATP" AUTHID CURRENT_USER as
/* $Header: INVWATPS.pls 120.1 2005/06/11 07:46:08 appldev  $ */

WebAtpGroupId number;

FUNCTION WebAtpInsert
(
  x_organization_id number,
  x_inventory_item_id number,
  x_atp_rule_id number,
  x_request_quantity number,
  x_request_primary_uom_quantity number,
  x_request_date date,
  x_atp_lead_time number,
  x_uom_code varchar2,
  x_demand_class varchar2,
  x_n_column2 number
) return number
;

PROCEDURE SetAtpGroupId ( x_atp_group_id number );

FUNCTION GetAtpGroupId return number;

FUNCTION WebAtpLaunch (
  x_user_id in number,
  x_resp_id in number,
  x_resp_appl_id in number
) return number;

FUNCTION WebAtpFetch (
    x_n_column2 number,
    x_inventory_item_id OUT NOCOPY /* file.sql.39 change */ number,
    x_organization_id OUT NOCOPY /* file.sql.39 change */ number,
    x_request_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_request_primary_uom_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_request_date OUT NOCOPY /* file.sql.39 change */ date,
    x_error_code OUT NOCOPY /* file.sql.39 change */ number,
    x_group_available_date OUT NOCOPY /* file.sql.39 change */ date,
    x_request_date_atp_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_earliest_atp_date OUT NOCOPY /* file.sql.39 change */ date,
    x_earliest_atp_date_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_request_atp_date OUT NOCOPY /* file.sql.39 change */ date,
    x_request_atp_date_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_infinite_time_fence_date OUT NOCOPY /* file.sql.39 change */ date
) return number;

FUNCTION WebAtpClear return number;

END INVWATP;

 

/
