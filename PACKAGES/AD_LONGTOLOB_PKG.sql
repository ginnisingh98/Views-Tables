--------------------------------------------------------
--  DDL for Package AD_LONGTOLOB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_LONGTOLOB_PKG" 
-- $Header: adl2lpkgs.pls 120.0 2005/09/30 06:19:19 vpalakur noship $
AUTHID CURRENT_USER AS
  -- Constants to indicate the status of the migration process
  -- Initial status of the tables before starting the migration process.
  G_INITIALIZED_STATUS    CONSTANT VARCHAR2 (30) := 'INITIALIZED';
  -- Status after adding the NEW columns
  G_ADD_NEW_COLUMN_STATUS CONSTANT VARCHAR2 (30) := 'NEW_COL_ADDED';
  -- Status after adding the triggers.
  G_ADD_TRIGGER_STATUS    CONSTANT VARCHAR2 (30) := 'TRIGGER_ADDED';
  -- Status after migrating the data.
  G_UPDATE_ROWS_STATUS    CONSTANT VARCHAR2 (30) := 'TABLE_UPDATED';
  G_DROP_OLD_COLUMN_STATUS CONSTANT VARCHAR2 (30) := 'DROP OLD COLUMN';
  G_COL_RENAMED_STATUS    CONSTANT VARCHAR2 (30) := 'LONG_LOB_RENAMED';
  G_DROP_TRIGGER_STATUS   CONSTANT VARCHAR2 (30) := 'TRIGGER_DROPPED';
  G_COMPLETE_STATUS       CONSTANT VARCHAR2 (30) := 'COMPLETED';
  G_DEFERRED_STATUS       CONSTANT VARCHAR2 (30) := 'DEFERRED';

  -- Diffrent actions to be performed on the tables.
  G_NO_ACTION             CONSTANT VARCHAR2 (10) := 'NO_ACTION';
  G_WITH_DATA             CONSTANT VARCHAR2 (10) := 'WITH_DATA';
  G_WITHOUT_DATA          CONSTANT VARCHAR2 (15) := 'WITHOUT_DATA';
  G_DROP_COLUMN           CONSTANT VARCHAR2 (15) := 'DROP_COLUMN';

  PROCEDURE initialize_process(
                           p_Specific_Table   VARCHAR2 := NULL ,
	                   p_Specific_Product VARCHAR2 := NULL ,
	                   p_Specific_Schema  VARCHAR2 := NULL );
  PROCEDURE add_new_column(
                           p_Schema               IN VARCHAR2 ,
                           p_Table_Name           IN VARCHAR2 ,
                           p_Old_Column_Name      IN VARCHAR2 ,
			   p_New_Column_Name      IN VARCHAR2 ,
                           p_New_Data_Type        IN VARCHAR2 ,
			   p_Curr_Status          IN VARCHAR2 ,
			   p_Action               IN VARCHAR2 );
  PROCEDURE write_long_rep;
  PROCEDURE write_long_rep( p_Path VARCHAR2);
  PROCEDURE create_transform_triggers(
                           p_Schema           IN VARCHAR2 ,
                           p_Table_Name       IN VARCHAR2 ,
                           p_Old_Column_Name  IN VARCHAR2 ,
                           p_New_Column_Name  IN VARCHAR2 ,
                           p_New_Data_Type    IN VARCHAR2 );
  PROCEDURE update_new_data(
                           p_Schema           IN VARCHAR2 ,
                           p_Old_Table_Name   IN VARCHAR2 ,
                           p_Old_Column_Name  IN VARCHAR2 ,
                           p_Old_Data_Type    IN VARCHAR2 ,
                           p_New_Column_Name  IN VARCHAR2 ,
                           p_Batch_Size       IN NUMBER DEFAULT 1000);
  PROCEDURE defer_table(   p_Schema           IN VARCHAR2 ,
                           p_Table_Name       IN VARCHAR2 );
  PROCEDURE re_enable_table(p_Schema          IN VARCHAR2 ,
                            p_Table_Name      IN VARCHAR2 );

END Ad_LongToLob_Pkg;

 

/
