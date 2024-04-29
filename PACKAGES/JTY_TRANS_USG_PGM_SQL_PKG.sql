--------------------------------------------------------
--  DDL for Package JTY_TRANS_USG_PGM_SQL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TRANS_USG_PGM_SQL_PKG" AUTHID CURRENT_USER as
/* $Header: jtftupss.pls 120.0 2005/09/12 20:19:58 achanda noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_TRANS_USG_PGM_SQL_PKG
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to create the transaction type SQLs
--      and the corresponding TRANS tables.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      09/08/05    ACHANDA         Created
--
--    End of Comments
--

PROCEDURE Insert_Row(
   p_source_id IN NUMBER
  ,p_trans_type_id IN NUMBER
  ,p_program_name IN VARCHAR2
  ,p_version_name IN VARCHAR2
  ,p_real_time_sql IN VARCHAR2
  ,p_batch_total_sql IN VARCHAR2
  ,p_batch_incr_sql IN VARCHAR2
  ,p_batch_dea_sql IN VARCHAR2
  ,p_incr_reassign_sql IN VARCHAR2
  ,p_use_total_for_dea_flag IN VARCHAR2
  ,p_enabled_flag IN VARCHAR2
  ,retcode OUT NOCOPY VARCHAR2
  ,errbuf OUT NOCOPY VARCHAR2);

END JTY_TRANS_USG_PGM_SQL_PKG;

 

/
