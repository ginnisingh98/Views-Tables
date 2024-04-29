--------------------------------------------------------
--  DDL for Package AS_INT_TYP_COD_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_INT_TYP_COD_MIGRATION" AUTHID CURRENT_USER as
/* $Header: asxmints.pls 120.1 2005/12/22 22:53:19 subabu noship $ */

/*
 This procedure migrates all the perz data and transaction data
 This is called by concurrent program 'Product Catalog Migration'
*/
PROCEDURE Migrate_All (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );

/*
This is called by concurrent program 'Product Catalog Migration for Perz Data'

This procedure migrates all the perz data
If parameter_name is 'productCategory' or 'prodCat', the parameter name is converted
to the format rep.ROW0.ProdCategory and the corresponding parameter_value is converted
to category id (mapped to the interest type id stored previously).

Here is an example:
old scheme:
parameter name              parameter value
--------------              ---------------
prodCat                     207
prodCat                     208


new scheme:
parameter name              parameter value
--------------              ---------------
rep.ROW0.ProdCategory       xxxxxx (where xxxxxx is the new category_id corresponding to interest type 207)
rep.ROW1.ProdCategory       yyyyyy (where yyyyyy is the new category_id corresponding to interest type 208)

For 'Opportunity by Products Report', the perz data is stored differently
old scheme:
parameter name              parameter value
--------------              ---------------
ROW0ProductCategory         207/434/435
ROW1ProductCategory         208
ROW2ProductCategory         208/460
ROW0.Invt                   CM18761
invItemID0                  253


new scheme:
parameter name              parameter value
--------------              ---------------
rep.ROW0.ProdCategory       xxxxxx (where xxxxxx is the  new category id corresponding to interest code 435)
rep.ROW1.ProdCategory       yyyyyy (where yyyyyy is the  new category id corresponding to interest type 208)
rep.ROW2.ProdCategory       zzzzzz (where zzzzzz is the  new category id corresponding to interest code 460)
rep.ROW0.invItemID          253
rep.ROW0.invItem            CM18761
*/
PROCEDURE Migrate_Perz_Data (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );

/*
This is called by concurrent program 'Product Catalog Migration for Opportunity Lines'

This procedure migrates product_category_id and product_cat_set_id into the
AS_LEAD_LNES_ALL table.

Note that it disables the trigger before
starting the migration. The triggers are re-enabled after the migration.
*/
PROCEDURE Migrate_AS_LEAD_LINES_ALL (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );

/*
This is called by concurrent program 'Product Catalog Migration for Forecast Categories'

This procedure migrates product_category_id and product_cat_set_id into the
AS_FST_SALES_CATEGORIES table.
*/
PROCEDURE Migrate_FST_SALES_CATEGORIES (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );

/*
This is called by concurrent program 'Product Catalog Migration for Opportunity Logs'

This procedure migrates product_category_id and product_cat_set_id into the
AS_LEAD_LINES_LOG table.
*/
PROCEDURE Migrate_AS_LEAD_LINES_LOG (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );

/*
This is called by concurrent program 'Product Catalog Migration for Product Interests'

This procedure migrates product_category_id and product_cat_set_id into the
AS_INTERESTS_ALL table.
*/
PROCEDURE Migrate_AS_INTERESTS_ALL (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );

/*
This is called by concurrent program 'Product Catalog Migration for Sales Credits'

This procedure migrates product_category_id and product_cat_set_id into the
AS_SALES_CREDITS_DENORM table.
*/
PROCEDURE Migrate_AS_SALES_C_DENORM (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );
/*
This is called by concurrent program 'Product Catalog Migration for Forecast Product Worksheet'

This procedure migrates product_category_id and product_cat_set_id into the
AS_PROD_WORKSHEET_LINES table.
*/
PROCEDURE Migrate_AS_PRODWKS_LINES (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );

/*
This is called by concurrent program 'Product Catalog Migration for Plan Element Mapping'

This procedure migrates product_category_id and product_cat_set_id into the
AS_PE_INT_CATEGORIES table.
*/
PROCEDURE Migrate_AS_PE_INT_CATEGORIES (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );



END AS_INT_TYP_COD_MIGRATION;

 

/
