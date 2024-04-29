--------------------------------------------------------
--  DDL for Package CSTPUMEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPUMEC" AUTHID CURRENT_USER AS
/* $Header: CSTPUMES.pls 115.5 2004/06/15 21:34:59 lfreyes ship $ */

   PROCEDURE CSTPECPC (
         I_ORGANIZATION_ID      IN      NUMBER,
         I_COST_TYPE_ID         IN      NUMBER,
	 I_FROM_COST_TYPE       IN      NUMBER,
         I_LIST_ID              IN      NUMBER,
         I_USER_ID              IN      NUMBER,
         I_REQ_ID               IN      NUMBER,
         I_PRGM_ID              IN      NUMBER,
         I_PRGM_APPL_ID         IN      NUMBER,
         O_RETURN_CODE          OUT NOCOPY     NUMBER);

   PROCEDURE CSTPEIIC (
         I_ORGANIZATION_ID      IN      NUMBER,
         I_COST_TYPE_ID         IN      NUMBER,
         I_LIST_ID              IN      NUMBER,
	 I_RESOURCE_ID		IN	NUMBER,
         I_USER_ID              IN      NUMBER,
         I_REQ_ID               IN      NUMBER,
         I_PRGM_ID              IN      NUMBER,
         I_PRGM_APPL_ID         IN      NUMBER,
         O_RETURN_CODE          OUT NOCOPY     NUMBER);

   PROCEDURE CSTPERIC (
         I_ORGANIZATION_ID      IN      NUMBER,
         I_COST_TYPE_ID         IN      NUMBER,
         I_LIST_ID              IN      NUMBER,
         I_USER_ID              IN      NUMBER,
         I_REQ_ID               IN      NUMBER,
         I_PRGM_ID              IN      NUMBER,
         I_PRGM_APPL_ID         IN      NUMBER,
         O_RETURN_CODE          OUT NOCOPY     NUMBER);


-- Start of comments
--
-- PROCEDURE
--  set_cost_controls       Invoked from the Mass Edit Menu as a concurrent
--                          request. This function allows the user to set
--                          the values of the following three fields in
--                          cst_item_costs:
--                          BASED_ON_ROLLUP_FLAG
--                          DEFAULTED_FLAG
--                          LOT_SIZE
--
--
--
-- PARAMETERS
--   O_Err_Num         output parameter for errors
--   O_Err_Msg         output parameter for errors
--   i_org_id          organization
--   i_cost_type       target cost type
--   i_range           All items, specific item, item range, category range
--   i_specific_item   Will contain an inventory_item_id
--   i_category_set    Contains the category set ID # for the category set the user selected
--   i_cat_strct       Contains the default category_structure assigned to the above category set
--   i_category_from   Contains the category ID for the FROM category that the user selected
--   i_category_to     Contains the category ID for the TO category that the user selected
--   i_item_from       A character string containing the flexfield concatenated segs (segment1||...)
--   i_item_to         A character string containing the flexfield concatenated segs (segment1||...)
--   i_copy_option     Choices are: 1. From system item definition - meaning copy the fields from the
--                     MSI table for the chosen item(s) and organization.
--                     2. From cost type - meaning copy the fields from the CIC table for the chosen
--                     item(s), organization, and cost type.
--   i_co_dummy        NULL unless copy option = From cost type (used to enable the src_cost_type param)
--   i_src_cost_type   Source cost type when copy option = From cost type
--   i_bor_flag        Based on rollup flag setting (flag indicating whether cost is rolled up):
--                     1 = Set to 1(YES), 2 = Set to 2(NO), 3 = Copy(from MSI or CIC), 4 = keep current
--   i_def_flag        Defaulted flag setting (flag indicating whether the cost of the item is
--                     defaulted from the default cost type during cost rollup):
--                     1 = Set to 1(YES), 2 = Set to 2(NO), 3 = Copy(from CIC), 4 = keep current
--   i_lotsz_lov       Selection made from lot size LOV: 1 = Set to #(which is provided in i_lot_size)
--                     2 = Copy (from MSI or CIC), 3 = keep current
--   i_lot_size        lot size (ignored unless the lot size selection = 1)
--
-- End of comments

procedure set_cost_controls(
  O_Err_Num         OUT NOCOPY  NUMBER,
  O_Err_Msg         OUT NOCOPY  VARCHAR2,
  i_org_id          IN          NUMBER,
  i_cost_type       IN          NUMBER,
  i_range           IN          NUMBER,
  i_item_dummy      IN          NUMBER,
  i_specific_item   IN          NUMBER,
  i_category_set    IN          NUMBER,
  i_cat_strct       IN          NUMBER,
  i_category_from   IN          VARCHAR2,
  i_category_to     IN          VARCHAR2,
  i_item_from       IN          VARCHAR2,
  i_item_to         IN          VARCHAR2,
  i_copy_option     IN          NUMBER,
  i_co_dummy        IN          NUMBER,
  i_src_cost_type   IN          NUMBER,
  i_bor_flag        IN          NUMBER,
  i_def_flag        IN          NUMBER,
  i_lotsz_lov       IN          NUMBER,
  i_lot_size        IN          NUMBER
);

END CSTPUMEC;

 

/
