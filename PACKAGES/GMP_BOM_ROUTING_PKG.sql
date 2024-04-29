--------------------------------------------------------
--  DDL for Package GMP_BOM_ROUTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_BOM_ROUTING_PKG" AUTHID CURRENT_USER AS
/* $Header: GMPBMRTS.pls 120.4.12010000.4 2009/04/09 09:46:17 vpedarla ship $ */

  PROCEDURE extract_effectivities
            (
			  at_apps_link   IN VARCHAR2,
			  delimiter_char IN VARCHAR2,
			  instance       IN INTEGER,
			  run_date       IN DATE,
                          return_status  IN OUT NOCOPY BOOLEAN
            );

  PROCEDURE time_stamp ;

  PROCEDURE LOG_MESSAGE(pBUFF  IN  VARCHAR2) ;

  PROCEDURE gmp_debug_message(pBUFF IN VARCHAR2);  -- Bug: 8420747 Vpedarla

  FUNCTION check_formula (
                           porganization_id IN PLS_INTEGER,
                           pformula_id IN PLS_INTEGER) return BOOLEAN ;

  FUNCTION check_formula_for_organization (
                           porganization_id IN PLS_INTEGER,
                           pformula_id IN PLS_INTEGER) return BOOLEAN ;

  PROCEDURE validate_formula_for_orgn ;

  PROCEDURE validate_formula ;

  PROCEDURE invalidate_rtg_all_org (p_routing_id IN PLS_INTEGER) ;

  PROCEDURE validate_routing (prouting_id IN PLS_INTEGER ,
                             porganization_id   IN PLS_INTEGER,
                             pheader_loc  IN  PLS_INTEGER,
                             prout_valid  OUT NOCOPY BOOLEAN) ;

  -- Vpedarla 7391495
  PROCEDURE search_operation_leadtime (p_fmeff_id IN PLS_INTEGER ,
                            p_organization_id IN NUMBER,
                            top OUT NOCOPY INTEGER,
                            bottom OUT NOCOPY INTEGER);

  PROCEDURE link_routing ;

  PROCEDURE link_override_routing ;

  PROCEDURE export_effectivities
  (
    return_status            OUT NOCOPY BOOLEAN
  ) ;

  FUNCTION bsearch_routing (p_routing_id IN PLS_INTEGER ,
                            p_organization_id IN PLS_INTEGER)
                          RETURN INTEGER ;

  /* Added New Function for Sequence Dependencies - SGIDUGU  */
  FUNCTION bsearch_setupid (p_oprn_id      IN PLS_INTEGER ,
                            p_category_id  IN PLS_INTEGER)
                          RETURN INTEGER ;

  PROCEDURE write_process_effectivity
  (
    p_x_aps_fmeff_id   IN PLS_INTEGER,
    p_aps_fmeff_id     IN PLS_INTEGER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE write_bom_components
  (
    p_x_aps_fmeff_id   IN PLS_INTEGER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE write_routing
  (
    p_x_aps_fmeff_id   IN PLS_INTEGER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE write_routing_operations
  (
    p_x_aps_fmeff_id   IN PLS_INTEGER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE retrieve_effectivities
  (
    return_status  OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE write_operation_components
  (
    p_x_aps_fmeff_id   IN PLS_INTEGER,
    precipe_id         IN PLS_INTEGER,
    return_status      OUT NOCOPY BOOLEAN
  ) ;

  PROCEDURE setup
  (
    apps_link_name IN VARCHAR2,
    delimiter_char IN VARCHAR2,
    instance       IN INTEGER,
    run_date       IN DATE,
    return_status  OUT NOCOPY BOOLEAN
  ) ;

   PROCEDURE gmp_putline (
       v_text                    IN       VARCHAR2,
       v_mode                    IN       VARCHAR2 ) ;

   FUNCTION find_routing_header ( prouting_id   IN PLS_INTEGER,
                                  porganization_id   IN PLS_INTEGER)
                                  RETURN BOOLEAN ;
   FUNCTION find_routing_offsets (p_formula_id       IN PLS_INTEGER,
                                  p_organization_id   IN PLS_INTEGER)
                               RETURN NUMBER ;
   FUNCTION get_offsets( p_formula_id                IN PLS_INTEGER,
			p_organization_id	IN PLS_INTEGER,
                        p_formulaline_id        IN PLS_INTEGER )
                        RETURN NUMBER ;

   PROCEDURE msc_inserts
   (
     return_status  OUT NOCOPY BOOLEAN
   ) ;

  /* Added new procedure to write the Resource Setups and Transitions - SGIDUGU  */
  /* bug: 6710684 Vpedarla added an IN parameter at_apps_link to the procedure write_setups_and_transitions */
  PROCEDURE write_setups_and_transitions
  (
    at_apps_link    IN VARCHAR2,
    return_status   OUT NOCOPY BOOLEAN
  ) ;

PROCEDURE Report_Error
(
  i_error_id       IN VARCHAR2,
  i_error_code     IN VARCHAR2,
  i_param_1        IN VARCHAR2,
  i_param_2        IN VARCHAR2,
  i_param_3        IN VARCHAR2,
  i_param_4        IN VARCHAR2
);

PROCEDURE write_step_dependency(
  p_x_aps_fmeff_id   IN PLS_INTEGER
);

FUNCTION enh_bsearch_stpno ( l_formula_id       IN PLS_INTEGER,
                             l_recipe_id        IN PLS_INTEGER,
                             l_item_id          IN PLS_INTEGER
                           ) RETURN INTEGER ;

PROCEDURE bsearch_unique (p_resource_id   IN PLS_INTEGER ,
                          p_category_id   IN PLS_INTEGER ,
                          p_setup_id      OUT NOCOPY PLS_INTEGER
                         ) ;

PROCEDURE extract_items
(
  at_apps_link  IN VARCHAR2,
  instance      IN INTEGER,
  run_date      IN DATE,
  return_status IN OUT NOCOPY BOOLEAN
);

/* bug: 6710684 vpedarla - added new function */
FUNCTION get_profile_value(
      profile_name IN VARCHAR2,
      pdblink      IN VARCHAR2 DEFAULT NULL ) return VARCHAR2 ;


END GMP_BOM_ROUTING_PKG;

/
