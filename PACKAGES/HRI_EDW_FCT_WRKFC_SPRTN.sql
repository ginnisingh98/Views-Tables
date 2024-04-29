--------------------------------------------------------
--  DDL for Package HRI_EDW_FCT_WRKFC_SPRTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_EDW_FCT_WRKFC_SPRTN" AUTHID CURRENT_USER AS
/* $Header: hriefwsp.pkh 120.1 2005/06/07 05:30:26 anmajumd noship $ */
  --
  FUNCTION calc_abv(p_assignment_id     IN NUMBER,
                    p_business_group_id IN NUMBER,
                    p_budget_type       IN VARCHAR2,
                    p_effective_date    IN DATE)
                    RETURN NUMBER;
  --
  FUNCTION find_movement_fk(p_actual_termination_date    IN DATE
                           ,p_accepted_termination_date  IN DATE
                           ,p_notified_termination_date  IN DATE
                           ,p_projected_termination_date IN DATE
                           ,p_final_process_date         IN DATE
                           ,p_reason                     IN VARCHAR2)
                   RETURN VARCHAR2;
  --
  PROCEDURE populate_sep_rsns;
  --
  PROCEDURE set_update_flag( p_reason_code     IN VARCHAR2 := NULL,
                             p_update_allowed  IN VARCHAR2);
  --
  PROCEDURE populate_hri_prd_of_srvce;
  --
End hri_edw_fct_wrkfc_sprtn ;

 

/
