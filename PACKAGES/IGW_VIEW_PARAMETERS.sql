--------------------------------------------------------
--  DDL for Package IGW_VIEW_PARAMETERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_VIEW_PARAMETERS" AUTHID CURRENT_USER as
--$Header: igwprprs.pls 115.5 2002/03/28 19:13:46 pkm ship    $

  FUNCTION get_project_location_id (i_proposal_id   	NUMBER) return NUMBER;
  pragma restrict_references(get_project_location_id, wnds);

  FUNCTION get_project_location_name (i_organization_id   	NUMBER) return VARCHAR2;
  pragma restrict_references(get_project_location_name, wnds);

  FUNCTION get_major_goals (i_proposal_id   	NUMBER) return VARCHAR2;
  pragma restrict_references(get_major_goals, wnds);

  FUNCTION get_pi_id (i_award_id   	NUMBER,
                      i_proposal_id     NUMBER) return NUMBER;
  pragma restrict_references(get_pi_id, wnds);

  FUNCTION get_pi_name (i_award_id   	  NUMBER,
                        i_proposal_id     NUMBER) return VARCHAR2;
  pragma restrict_references(get_pi_name, wnds);

  FUNCTION get_percent_effort (i_proposal_id   	 NUMBER,
                               i_person_id     NUMBER) return NUMBER;
  pragma restrict_references(get_percent_effort, wnds);

  FUNCTION get_direct_cost (i_award_id   	NUMBER,
                            i_proposal_id     NUMBER) return NUMBER;
  pragma restrict_references(get_direct_cost, wnds);

  FUNCTION get_total_cost (i_award_id   	NUMBER,
                            i_proposal_id     NUMBER) return NUMBER;
  pragma restrict_references(get_total_cost, wnds);

 FUNCTION get_old_direct_cost (i_award_id   	NUMBER) return NUMBER;
  pragma restrict_references(get_old_direct_cost, wnds);

  FUNCTION get_old_total_cost (i_award_id   	NUMBER) return NUMBER;
  pragma restrict_references(get_old_total_cost, wnds);

END IGW_VIEW_PARAMETERS;

 

/
