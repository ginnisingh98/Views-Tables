--------------------------------------------------------
--  DDL for Package HRI_BPL_SETUP_DIAGNOSTIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_SETUP_DIAGNOSTIC" AUTHID CURRENT_USER AS
/* $Header: hribdgsp.pkh 120.4 2006/12/11 09:44:50 msinghai noship $ */

TYPE fast_formula_rec_type IS RECORD
 (business_group_name  VARCHAR2(240),
  status               VARCHAR2(240),
  impact_msg           VARCHAR2(32000));

TYPE fast_formula_tab_type IS TABLE OF fast_formula_rec_type
                              INDEX BY BINARY_INTEGER;

TYPE job_flex_rec_type IS RECORD
 (structure_name            VARCHAR2(240),
  job_family_defined_msg    VARCHAR2(32000),
  job_function_defined_msg  VARCHAR2(32000));

TYPE job_flex_tab_type IS TABLE OF job_flex_rec_type
                          INDEX BY VARCHAR2(80);

TYPE impact_msg_rec_type IS RECORD
 (impact_msg           VARCHAR2(32000),
  doc_links_url        VARCHAR2(32000));

TYPE impact_msg_tab_type IS TABLE OF impact_msg_rec_type
                            INDEX BY VARCHAR2(240);

PROCEDURE check_profile_option
       (p_profile_name       IN VARCHAR2,
        p_functional_area    IN VARCHAR2,
        p_user_profile_name  OUT NOCOPY VARCHAR2,
        p_profile_value      OUT NOCOPY VARCHAR2,
        p_impact             OUT NOCOPY BOOLEAN,
        p_impact_msg         OUT NOCOPY VARCHAR2,
        p_doc_links_url      OUT NOCOPY VARCHAR2);

PROCEDURE check_fast_formula
       (p_ff_name          IN VARCHAR2,
        p_functional_area  IN VARCHAR2,
        p_type             IN VARCHAR2,
        p_formula_tab      OUT NOCOPY fast_formula_tab_type,
        p_impact_msg_tab   OUT NOCOPY impact_msg_tab_type);

PROCEDURE check_triggers(p_trigger_name      IN VARCHAR2,
                         p_functional_area   IN VARCHAR2,
                         p_generated         OUT NOCOPY VARCHAR2,
                         p_enabled           OUT NOCOPY VARCHAR2,
                         p_status            OUT NOCOPY VARCHAR2,
                         p_impact            OUT NOCOPY BOOLEAN,
                         p_impact_msg        OUT NOCOPY VARCHAR2,
                         p_doc_links_url     OUT NOCOPY VARCHAR2);

PROCEDURE check_dbi_tables(p_table_name       IN VARCHAR2,
                           p_functional_area  IN VARCHAR2,
                           p_status           OUT NOCOPY VARCHAR2,
                           p_impact           OUT NOCOPY BOOLEAN,
                           p_impact_msg       OUT NOCOPY VARCHAR2,
                           p_doc_links_url    OUT NOCOPY VARCHAR2);

PROCEDURE check_job(p_job_family_mode        OUT NOCOPY VARCHAR2,
                    p_job_function_mode      OUT NOCOPY VARCHAR2,
                    p_flex_structure_tab     OUT NOCOPY job_flex_tab_type,
                    p_impact                 OUT NOCOPY BOOLEAN,
                    p_impact_msg             OUT NOCOPY VARCHAR2,
                    p_doc_links_url          OUT NOCOPY VARCHAR2);

PROCEDURE check_geography(p_context_name     OUT NOCOPY VARCHAR2,
                          p_flex_column      OUT NOCOPY VARCHAR2,
                          p_status           OUT NOCOPY VARCHAR2,
                          p_impact           OUT NOCOPY BOOLEAN,
                          p_impact_msg       OUT NOCOPY VARCHAR2);

PROCEDURE check_buckets(p_bucket_name       IN VARCHAR2,
                        p_functional_area   IN VARCHAR2,
                        p_user_bucket_name  OUT NOCOPY VARCHAR2,
                        p_status            OUT NOCOPY VARCHAR2,
                        p_impact            OUT NOCOPY BOOLEAN,
                        p_impact_msg        OUT NOCOPY VARCHAR2,
                        p_doc_links_url     OUT NOCOPY VARCHAR2);

PROCEDURE pplt_obj_farea_tab;

FUNCTION get_product_name(p_object_name IN VARCHAR2)
                          RETURN VARCHAR2;

FUNCTION is_token_exist(p_message    IN   VARCHAR2,
                        p_token_name IN   VARCHAR2)
                        RETURN BOOLEAN;

END hri_bpl_setup_diagnostic;

/
