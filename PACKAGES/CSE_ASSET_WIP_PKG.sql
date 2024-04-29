--------------------------------------------------------
--  DDL for Package CSE_ASSET_WIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_ASSET_WIP_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEFAWPS.pls 115.1 2002/11/11 22:03:55 jpwilson noship $

---Finds the immediate children from Installed Base configuration
---For each depreciable component, perfroms unit and cost adjustment
PROCEDURE update_comp_assets(
  p_top_instance_id       IN        NUMBER
, x_return_status         OUT NOCOPY       VARCHAR2
, x_error_msg             OUT NOCOPY       VARCHAR2
  )  ;

---Insert records into FA_MASS_ADDITIONS for COST
---and UNIT adjustment
PROCEDURE adjust_fa_cost_n_unit (
  p_asset_id              IN        NUMBER
, p_book_type_code        IN        VARCHAR2
, p_location_id           IN        NUMBER
, p_expense_ccid          IN        NUMBER
, p_employee_id           IN        NUMBER
, p_unit_to_adjust        IN        NUMBER
, p_cost_to_adjust        IN        NUMBER
, p_reviewer_comments     IN        VARCHAR2
, x_return_status         OUT NOCOPY       VARCHAR2
, x_error_msg             OUT NOCOPY       VARCHAR2
  )  ;

END CSE_ASSET_WIP_PKG ;

 

/
