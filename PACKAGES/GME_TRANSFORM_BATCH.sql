--------------------------------------------------------
--  DDL for Package GME_TRANSFORM_BATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_TRANSFORM_BATCH" AUTHID CURRENT_USER AS
/* $Header: GMEVTRFS.pls 120.3 2005/11/21 12:04:56 creddy noship $ */

/***********************************************************/
-- Oracle Process Manufacturing Process Execution APIs
--
-- File Name:   GMEVTRFS.pls
-- Contents:    Package spec for GME data transformation
-- Description:
--   This package transforms GME data from 11.5.10 to
--   12.

/**********************************************************/
   FUNCTION get_profile_value (v_profile_name IN VARCHAR2,
                               v_appl_id      IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE gme_migration (
      p_migration_run_id   IN              NUMBER,
      p_commit             IN              VARCHAR2,
      x_failure_count      OUT NOCOPY      NUMBER
   );

   PROCEDURE create_gme_parameters(p_migration_run_id IN NUMBER,
                                   x_exception_count  OUT NOCOPY NUMBER);

   PROCEDURE update_batch_header(p_migration_run_id IN NUMBER,
                                 x_exception_count  OUT NOCOPY NUMBER);

   PROCEDURE update_wip_entities(p_migration_run_id IN NUMBER,
                                 x_exception_count  OUT NOCOPY NUMBER);

   PROCEDURE update_from_doc_no(p_migration_run_id NUMBER);
   PROCEDURE update_reason_id(p_migration_run_id NUMBER);

END gme_transform_batch;

 

/
