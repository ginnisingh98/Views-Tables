--------------------------------------------------------
--  DDL for Package CN_IMP_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMP_RULE_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvimrls.pls 120.2 2005/08/07 23:04:23 vensrini noship $

--
-- Package Body Name
--   CN_IMP_RULE_PVT
-- Purpose
--   This package contains the procedures to import data from the stagin tables
--   to the Ruleset, rule and rule attribute related tables
--   This method loads the rulesets before calling the load_rules procedure. Once a
--   a ruleset is loaded completely (i.e the rules and rule attributes loaded), the ruleset is
--   synchronized.
-- History
--   3/14/2002	Arvind Krishnan   Created

  -- Procedure Name
  --   Rules_Import
  -- Scope
  --   public
  -- Purpose
  --     This procedure is called by the import module to transfer data from the staging tables
  --     to the destination tables.
  -- History
  --   3/14/2002	Arvind Krishnan   Created
  --
  PROCEDURE Rules_Import
  ( errbuf                     OUT NOCOPY   VARCHAR2,
    retcode                    OUT NOCOPY   VARCHAR2,
    p_imp_header_id            IN    NUMBER,
    p_org_id                   IN NUMBER);

    -- Procedure Name
    --   load_rules
    -- Scope
    --   public
    -- Purpose
    --     Invoked by the Rules_Import procedure. Loads the data from the staging table into the rules and rules
    --     hierarchy tables
    -- History
    --   3/14/2002	Arvind Krishnan   Created
    --
  PROCEDURE load_rules
  ( p_ruleset_id         IN NUMBER,
    p_ruleset_name       IN VARCHAR2,
    p_ruleset_start_date IN VARCHAR,
    p_ruleset_end_date   IN VARCHAR,
    p_ruleset_type       IN VARCHAR,
    p_imp_header         IN cn_imp_headers_pvt.imp_headers_rec_type,
    x_err_mssg           OUT NOCOPY VARCHAR2,
    x_retcode            OUT NOCOPY VARCHAR2,
    x_imp_line_id        OUT NOCOPY NUMBER,
    x_failed_row    IN OUT NOCOPY NUMBER,
    x_processed_row IN OUT NOCOPY NUMBER,
    p_org_id             IN NUMBER);

  -- Procedure Name
  --   load_rule_attributes
  -- Scope
  --   public
  -- Purpose
  --     Invoked by the load_rules procedure. Loads the data from the staging table into the
  --      rules attribute tables
  -- History
  --   3/14/2002	Arvind Krishnan   Created
  --
  PROCEDURE load_rule_attributes
  ( p_ruleset_id         IN NUMBER,
    p_ruleset_name       IN VARCHAR2,
    p_ruleset_start_date IN VARCHAR,
    p_ruleset_end_date   IN VARCHAR,
    p_ruleset_type       IN VARCHAR,
    p_rule_id            IN NUMBER,
    p_rule_name          IN VARCHAR2,
    p_parent_rule_name   IN VARCHAR2,
    p_level_num          IN VARCHAR2,
    p_imp_header         IN cn_imp_headers_pvt.imp_headers_rec_type,
    x_err_mssg           OUT NOCOPY VARCHAR2,
    x_retcode            OUT NOCOPY VARCHAR2,
    x_imp_line_id        OUT NOCOPY NUMBER,
    x_failed_row    IN OUT NOCOPY NUMBER,
    x_processed_row IN OUT NOCOPY NUMBER,
    p_org_id             IN NUMBER);

  -- Procedure Name
  --   update_on_error
  -- Scope
  --   public
  -- Purpose
  --     Called by the loading procedures when an error occurs. This method sets the error code
  -- and error message in the cn_imp_lines tables
  -- History
  --   3/14/2002	Arvind Krishnan   Created
  --
  PROCEDURE update_on_error
            (p_line_id   IN NUMBER,
             p_err_code  IN VARCHAR2,
             p_err_mssg  IN VARCHAR2,
             p_head_id   IN NUMBER);

  -- Procedure Name
  --   update_imp_lines
  -- Scope
  --   public
  -- Purpose
  --
  -- History
  --   3/14/2002	Arvind Krishnan   Created
  --
PROCEDURE update_imp_lines
 (p_status        IN VARCHAR2,
  p_imp_line_id   IN NUMBER,
  p_ruleset_name  IN VARCHAR2,
  p_start_date    IN VARCHAR2,
  p_end_date      IN VARCHAR2,
  p_ruleset_type  IN VARCHAR2,
  p_head_id       IN NUMBER,
  p_error_code    IN VARCHAR2,
  p_error_mssg    IN VARCHAR2,
  x_failed_row    IN OUT NOCOPY NUMBER,
  x_processed_row IN OUT NOCOPY NUMBER);


END CN_IMP_RULE_PVT;

 

/
