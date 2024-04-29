--------------------------------------------------------
--  DDL for Package IBE_JPCV_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_JPCV_MIGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVJMGS.pls 115.2 2003/02/17 20:57:44 jshang ship $ */

PROCEDURE Migrate_Sequence
  (
   p_old_seq IN VARCHAR2,
   p_new_seq IN VARCHAR2
  );

PROCEDURE Does_Row_Exists
  (
   p_table_name       IN VARCHAR2,
   p_primary_col_name IN VARCHAR2,
   x_count            OUT NOCOPY NUMBER
  );

PROCEDURE Log_Table_Migration_Start
  (
   p_module_name          IN VARCHAR2,
   p_src_table_name       IN VARCHAR2,
   p_dst_table_name       IN VARCHAR2
  );

PROCEDURE Log_Table_Migration_Finish
  (
   p_module_name          IN VARCHAR2,
   p_src_table_name       IN VARCHAR2,
   p_dst_table_name       IN VARCHAR2
  );

END ibe_jpcv_migration_pvt;

 

/
