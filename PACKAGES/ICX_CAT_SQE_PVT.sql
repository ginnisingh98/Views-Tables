--------------------------------------------------------
--  DDL for Package ICX_CAT_SQE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_SQE_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVSQES.pls 120.2 2006/05/23 18:29:10 rwidjaja noship $*/

-- procedure to create sqes for a given content zone
-- this constructs the intermedia expression for the content zone, puts
-- it in an sqe and returns the sqe name
-- if the expression is too long, it is an error and x_return_status
-- will be set to 'E'
PROCEDURE create_sqes_for_zone
(
  p_content_zone_id IN NUMBER,
  p_supplier_attr_action_flag IN VARCHAR2,
  p_supplier_ids IN ICX_TBL_NUMBER,
  p_supplier_site_ids IN ICX_TBL_NUMBER,
  p_items_without_supplier_flag IN VARCHAR2,
  p_category_attr_action_flag IN VARCHAR2,
  p_category_ids IN ICX_TBL_NUMBER,
  p_items_without_shop_catg_flag IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_sqe_sequence IN OUT NOCOPY NUMBER
);

-- procedure to combine three expressions with the '&' operator
-- depending on which are not null
PROCEDURE combine_exprs
(
 p_expr1 IN VARCHAR2,
 p_expr2 IN VARCHAR2,
 p_expr3 IN VARCHAR2,
 x_result_expr OUT NOCOPY VARCHAR2
);

-- procedure to construct the intermedia expressions for a given zone
-- takes in all the required parameters and returns the intermedia expressions
-- it returns one intermedia expression for internal only items
-- one for purchasable only items and one for both
PROCEDURE construct_exprs_for_zone
(
  p_supplier_attr_action_flag IN VARCHAR2,
  p_supplier_ids IN ICX_TBL_NUMBER,
  p_supplier_site_ids IN ICX_TBL_NUMBER,
  p_items_without_supplier_flag IN VARCHAR2,
  p_category_attr_action_flag IN VARCHAR2,
  p_category_ids IN ICX_TBL_NUMBER,
  p_items_without_shop_catg_flag IN VARCHAR2,
  x_int_intermedia_expression OUT NOCOPY VARCHAR2,
  x_purch_intermedia_expression OUT NOCOPY VARCHAR2,
  x_both_intermedia_expression OUT NOCOPY VARCHAR2
);

-- procedure to constuct the supplier and site expression for a given zone
-- takes in the required parameters and returns the supplier and site expression
PROCEDURE construct_supp_and_site_expr
(
  p_supplier_attr_action_flag IN VARCHAR2,
  p_supplier_ids IN ICX_TBL_NUMBER,
  p_supplier_site_ids IN ICX_TBL_NUMBER,
  p_items_without_supplier_flag IN VARCHAR2,
  x_supplier_and_site_expr OUT NOCOPY VARCHAR2
);

-- procedure to constuct the category expression for a given zone
-- takes in the required parameters and returns the category expression
PROCEDURE construct_category_expr
(
  p_category_attr_action_flag IN VARCHAR2,
  p_category_ids IN ICX_TBL_NUMBER,
  p_items_without_shop_catg_flag IN VARCHAR2,
  x_category_expr OUT NOCOPY VARCHAR2
);

-- procedure to purge the deleted sqes
-- this purges all sqes that have been deleted more than a day ago
PROCEDURE purge_deleted_sqes;

-- procedure to sync sqes for all content zones
-- called for hierarchy changes from a concurrent program
-- or from the schema loader
-- this will recreate sqes for all the content zones
-- if some content zones have errors since the expression is too long
-- the job will be errored out with a message specifying which zones failed
-- the successful zones will however be updated
PROCEDURE sync_sqes_hier_change_internal
(
  x_return_status OUT NOCOPY VARCHAR2,
  x_errored_zone_name_list OUT NOCOPY VARCHAR2
);

-- procedure to sync sqes for all content zones
-- called for hierarchy changes from a concurrent program
-- this will call the main api which does the actual sync
-- this api in addition updates the failed line messages
-- and the job status
PROCEDURE sync_sqes_for_hierarchy_change
(
  x_errbuf OUT NOCOPY VARCHAR2,
  x_retcode OUT NOCOPY NUMBER
);

-- procedure to sync sqes for all content zones
-- called for hierarchy changes from the schema loader
-- this will call the main api which does the actual sync
-- this api in addition updates the failed line messages
-- and the failed lines table
PROCEDURE sync_sqes_for_hierarchy_change
(
  p_request_id IN NUMBER,
  p_line_number IN NUMBER,
  p_action IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2
);

-- procedure to sync the sqes for all the zones
-- this will only be called during upgrade
-- this is also useful for testing purposes and also useful if we
-- want to re-sync all zones on any instance
PROCEDURE sync_sqes_for_all_zones;

END ICX_CAT_SQE_PVT;

 

/
