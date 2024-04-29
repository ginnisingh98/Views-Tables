--------------------------------------------------------
--  DDL for Package GMP_PLNG_DTL_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_PLNG_DTL_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: GMPPLDRS.pls 120.2.12010000.5 2010/02/11 09:43:23 vpedarla ship $ */

PROCEDURE create_pdr
(
   errbuf                       OUT NOCOPY VARCHAR2,
   retcode                      OUT NOCOPY VARCHAR2,
   p_inst_id                    IN NUMBER,
   p_org_id                     IN NUMBER,
   p_plan_id                    IN NUMBER,
   p_plan_org                   IN NUMBER,
   p_start_date                 IN VARCHAR2,
   p_day_bucket                 IN NUMBER,
 --  p_day_bckt_cutoff_dt         IN VARCHAR2,  Bug: 8363786 Vpedarla
   p_plan_day_bckt_cutoff_dt    IN VARCHAR2,
   p_week_bucket                IN NUMBER,
 --  p_week_bckt_cutoff_dt        IN VARCHAR2,   Bug: 8363786 Vpedarla
   p_plan_week_bckt_cutoff_dt   IN VARCHAR2,
   p_period_bucket              IN NUMBER,
   p_fsort                      IN NUMBER,
   p_ssort                      IN NUMBER,
   p_tsort                      IN NUMBER,
   p_ex_typ                     IN NUMBER,
   p_plnr_low                   IN VARCHAR2,
   p_plnr_high                  IN VARCHAR2,
   p_byr_low                    IN VARCHAR2,
   p_byr_high                   IN VARCHAR2,
   p_itm_low                    IN VARCHAR2,
   p_itm_high                   IN VARCHAR2,
   p_cat_set_id                 IN NUMBER,
   p_category_low               IN VARCHAR2,
   p_category_high              IN VARCHAR2,
   p_abc_class_low              IN VARCHAR2,
   p_abc_class_high             IN VARCHAR2,
   p_cutoff_date                IN VARCHAR2,
   p_incl_items_no_activity     IN VARCHAR2, --  Bug: 8486531 Vpedarla
   p_comb_pdr                   IN NUMBER,
   p_comb_pdr_place             IN VARCHAR2,  -- Added
   p_comb_comm_pdr              IN VARCHAR2,  -- Added
   p_comb_pdr_temp              IN VARCHAR2,
   p_comb_pdr_locale            IN VARCHAR2,
   p_horiz_pdr                  IN NUMBER,
   p_horiz_pdr_place            IN VARCHAR2,  -- Added
   p_horiz_pdr_temp             IN VARCHAR2,
   p_horiz_pdr_locale           IN VARCHAR2,
   p_vert_pdr                   IN NUMBER,
   p_vert_pdr_place             IN VARCHAR2,  -- Added
   p_vert_pdr_temp              IN VARCHAR2,
   p_vert_pdr_locale            IN VARCHAR2,
   p_excep_pdr                  IN NUMBER,
   p_excep_pdr_place            IN VARCHAR2,  -- Added
   p_excep_pdr_temp             IN VARCHAR2,
   p_excep_pdr_locale           IN VARCHAR2,
   p_act_pdr                    IN NUMBER,
   p_act_pdr_place              IN VARCHAR2,  -- Added
   p_act_pdr_temp               IN VARCHAR2,
   p_act_pdr_locale             IN VARCHAR2
);

PROCEDURE insert_items ;

PROCEDURE validate_parameters;

PROCEDURE horiz_plan_stmt;

PROCEDURE vert_plan_stmt;

PROCEDURE item_exception_stmt;

PROCEDURE item_action_stmt;

PROCEDURE generate_xml;

FUNCTION plan_name RETURN VARCHAR2;

FUNCTION plan_org ( org_id IN NUMBER) RETURN VARCHAR2;

FUNCTION category_set_name ( cat_set_id IN NUMBER) RETURN VARCHAR2;

FUNCTION lookup_meaning(l_lookup_type IN VARCHAR2, l_lookup_code IN NUMBER) RETURN VARCHAR2;

PROCEDURE ps_generate_output (p_sequence_num IN NUMBER,p_pdr_type IN NUMBER);

PROCEDURE xml_transfer (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2, p_sequence_num IN NUMBER);

PROCEDURE gmp_debug_message(pBUFF IN VARCHAR2);  -- Bug: 9366921 Vpedarla

END GMP_PLNG_DTL_REPORT_PKG;

/
