--------------------------------------------------------
--  DDL for Package MSD_PLAN_TYPE_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_PLAN_TYPE_VIEWS_PKG" AUTHID CURRENT_USER as
/* $Header: msdptvps.pls 120.0 2005/05/25 19:25:46 appldev noship $ */

PROCEDURE LOAD_ROW(
          X_plan_type    varchar2,
          X_view_type  varchar2,
          X_view_name     varchar2,
          x_last_update_date in varchar2,
          x_lob_flag in varchar2,
          x_owner in varchar2,
          x_custom_mode in varchar2);

end MSD_PLAN_TYPE_VIEWS_PKG;

 

/
