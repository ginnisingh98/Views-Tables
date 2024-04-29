--------------------------------------------------------
--  DDL for Package GCS_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: gcs_purges.pls 120.1 2007/10/04 05:18:26 rthati noship $*/
-- Procedure
--   purge_cons_runs
-- Purpose
--   An API for master to submit request to worker
-- Arguments
--   x_retcode                   Return code
--   x_errbuf                    Buffer error
--   p_consolidation_hierarchy   Consolidation hierarchy
--   p_consolidation_entity      Consolidation entity
--   p_cal_period_id             Period
--   p_balance_type_code         Balance type code
-- Modification History
--   Person           Date        Comments
--   ramesh.thati    25-09-2007   Purge Program - Bug # 6447909
-- Notes
--

   PROCEDURE purge_cons_runs
      (
       x_retcode                 OUT NOCOPY VARCHAR2,
       x_errbuf                  OUT NOCOPY VARCHAR2,
       p_consolidation_hierarchy IN NUMBER,
       p_consolidation_entity    IN NUMBER,
       p_cal_period_id           IN NUMBER,
       p_balance_type_code       IN VARCHAR2
       );

-- Procedure
--   purge_cons_runs_worker
-- Purpose
--   An API for worker to purge its own set of rows. Its to purge historical data
--   with regard to consolidation runs.It will not purge manual adjustments or
--   rules generated entries. It will purge only Automatically generated entries
-- Arguments
--   x_retcode                   Return code
--   x_errbuf                    Buffer error
--   p_batch_size                No of rows to process
--   p_Worker_Id                 Worker ID,
--   p_Num_Workers               total Number of workers
--   p_consolidation_hierarchy   Consolidation hierarchy
--   p_consolidation_entity      Consolidation entity
--   p_cal_period_id             Period
--   p_balance_type_code         Balance type code
-- Modification History
--   Person           Date        Comments
--   ramesh.thati    25-09-2007   Purge Program - Bug # 6447909
-- Notes
--

   PROCEDURE purge_cons_runs_worker
      (
       X_errbuf                  OUT NOCOPY VARCHAR2,
       X_retcode                 OUT NOCOPY VARCHAR2,
       p_batch_size              IN NUMBER,
       p_Worker_Id               IN NUMBER,
       p_Num_Workers             IN NUMBER,
       p_consolidation_hierarchy IN NUMBER,
       p_consolidation_entity    IN NUMBER,
       p_cal_period_id           IN NUMBER,
       p_balance_type_code       IN VARCHAR2
       );

END GCS_PURGE_PKG; -- Package spec


/
