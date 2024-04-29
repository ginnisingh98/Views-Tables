--------------------------------------------------------
--  DDL for Package HR_LONG2LOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LONG2LOB" AUTHID CURRENT_USER AS
/* $Header: hrl2lmig.pkh 120.3 2005/11/17 11:45 smallina noship $ */

/******************************************
 * INIT procedure will do the following steps.
 *1. Initialize the AD tables with required data.
 *2. Adding the columns
 *3. Adding the Triggers
 ********************************************/

 PROCEDURE DO_INIT(
   p_appl_short_name      IN   VARCHAR2,
   p_table_name           IN   VARCHAR2,
   p_old_column_name      IN   VARCHAR2,
   p_new_column_data_type IN   VARCHAR2
 );

/******************************************
* MIGRATE procedure will do the following steps.
* 1. Migration of data.
* 2. Renaming the columns
* 3. Dropping the triggers.
*******************************************/

 PROCEDURE  DO_MIGRATE(
   p_appl_short_name      IN   VARCHAR2,
   p_table_name           IN   VARCHAR2,
   p_old_column_name      IN   VARCHAR2
 );

/*******************************************
* DROP procedure will do the following step.
* 1. Dropping the column
*******************************************/

 PROCEDURE DO_DROP(
   p_appl_short_name      IN   VARCHAR2,
   p_table_name           IN   VARCHAR2,
   p_old_column_name      IN   VARCHAR2
 );

/*******************************************
* UNUSED procedure will do the following step.
* 1. Marks the column as unused.
*******************************************/

 PROCEDURE DO_UNUSED(
   p_appl_short_name      IN   VARCHAR2,
   p_table_name           IN   VARCHAR2,
   p_old_column_name      IN   VARCHAR2
 );

/*******************************************
* ALL_DROP procedure will do the following steps.
* 1. Initialize the AD tables with required data.
* 2. Adding the column
* 3. Migration of data.
* 4. Renaming the column
* 5. Dropping the column
*******************************************/

 PROCEDURE DO_ALL_DROP(
    p_appl_short_name      IN   VARCHAR2,
    p_table_name           IN   VARCHAR2,
    p_old_column_name      IN   VARCHAR2,
    p_new_column_data_type IN   VARCHAR2
 );

/*******************************************
* ALL_UNUSED procedure will do the following steps.
* 1. Initialize the AD tables with required data.
* 2. Adding the column
* 3. Migration of data.
* 4. Renaming the column
* 5. Marking the column as unused.
*******************************************/

 PROCEDURE DO_ALL_UNUSED(
   p_appl_short_name      IN   VARCHAR2,
   p_table_name           IN   VARCHAR2,
   p_old_column_name      IN   VARCHAR2,
   p_new_column_data_type IN   VARCHAR2
 );
END HR_LONG2LOB;

 

/
