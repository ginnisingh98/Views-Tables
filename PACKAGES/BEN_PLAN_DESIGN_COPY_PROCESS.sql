--------------------------------------------------------
--  DDL for Package BEN_PLAN_DESIGN_COPY_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PLAN_DESIGN_COPY_PROCESS" AUTHID CURRENT_USER AS
/* $Header: bepdcprc.pkh 120.1 2006/04/05 09:09:31 bmanyam noship $ */
--
-- Global type declaration
--
--
-- Global varaibles.
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< process >--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
 -- This is the main batch procedure to be called from the concurrent manager.
--
   PROCEDURE process (
      errbuf                       OUT NOCOPY      VARCHAR2,
      retcode                      OUT NOCOPY      NUMBER,
      p_validate                   IN              NUMBER DEFAULT 0,
      p_copy_entity_txn_id         IN              NUMBER,
      p_effective_date             IN              VARCHAR2,
      p_prefix_suffix_text         IN              VARCHAR2 DEFAULT NULL,
      p_reuse_object_flag          IN              VARCHAR2 DEFAULT NULL,
      p_target_business_group_id   IN              VARCHAR2 DEFAULT NULL,
      p_prefix_suffix_cd           IN              VARCHAR2 DEFAULT NULL,
      p_effective_date_to_copy     IN              VARCHAR2 DEFAULT NULL
   );
--
   -- 5097567 : Added the following procedure to compile FF
   PROCEDURE compile_modified_ff (
      errbuf                       OUT NOCOPY      VARCHAR2,
      retcode                      OUT NOCOPY      NUMBER,
      p_copy_entity_txn_id         IN              NUMBER,
      p_effective_date             IN              VARCHAR2
   );
--
END ben_plan_design_copy_process;

 

/
