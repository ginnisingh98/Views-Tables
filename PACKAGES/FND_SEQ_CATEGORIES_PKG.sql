--------------------------------------------------------
--  DDL for Package FND_SEQ_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SEQ_CATEGORIES_PKG" AUTHID CURRENT_USER AS
/* $Header: AFSNCATS.pls 115.0 99/07/16 23:31:02 porting ship  $ */

    TYPE cat_rec IS RECORD (cat_code FND_DOC_SEQUENCE_CATEGORIES.code%TYPE);

  --
  -- Procedure
  --   check_unique_cat
  -- Purpose
  --   Checks before insert that the category to be inserted is unique
  --   If category code is not unique, shows error message.
  -- History
  --   08-SEP-98   H. Lankinen   Created
  -- Arguments
  --   x_application_id           The application id
  --   x_category_code            The category code
  -- Example
  --   FND_SEQ_CATEGORIES_PKG.check_unique_cat(
  --     222, 'CONS');
  --


  PROCEDURE check_unique_cat( x_application_id      IN   NUMBER,
			      x_category_code       IN   VARCHAR2);

  --
  -- Procedure
  --   insert_cat
  -- Purpose
  --   Insert into FND_DOC_SEQUENCE_CATEGORIES table for each
  --   new created category.
  -- History
  --   08-SEP-98   H. Lankinen   Created
  -- Arguments
  --   x_application_id           The application id
  --   x_category_code            The category code
  --   x_category_name            The category name
  --   x_description              The category description
  --   x_table_name               The table name
  --   x_last_updated_by          The who column
  --   x_created_by               The who column
  --   x_last_update_login        The who column
  -- Example
  --   FND_SEQ_CATEGORIES_PKG.insert_cat(
  --     222, 'CONS', 'Consulting Invoice', 'Consulting Invoice',
  --    'RA_CUSTOMER_TRX_ALL', 1,1,1 );
  -- Notes
  --


  PROCEDURE insert_cat( x_application_id         NUMBER,
			x_category_code          VARCHAR2,
                        x_category_name          VARCHAR2,
                        x_description            VARCHAR2,
			x_table_name	     VARCHAR2,
                        x_last_updated_by        NUMBER,
                        x_created_by             NUMBER,
                        x_last_update_login      NUMBER );


  --
  -- Procedure
  --   update_cat
  -- Purpose
  --   Update FND_DOC_SEQUENCE_CATEGORIES table for each
  --   new updated category.
  -- History
  --   08-SEP-98   H. Lankinen   Created
  -- Arguments
  --   x_application_id           The Application id
  --   x_category_code            The category code
  --   x_category_name            The category name
  --   x_description              The cateogrty description
  --   x_last_updated_by          The last person id who update the row
  -- Example
  --   FND_SEQ_CATEGORIES_PKG.update_cat(
  --     222, 'CONS', 'Consulting Invoice', 'Consulting Invoice',1 );
  -- Notes
  --

  PROCEDURE update_cat(  x_application_id         NUMBER,
			 x_category_code          VARCHAR2,
			 x_category_name          VARCHAR2,
                         x_description            VARCHAR2,
                         x_last_updated_by        NUMBER );

END FND_SEQ_CATEGORIES_PKG;

 

/
