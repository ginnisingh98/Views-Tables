--------------------------------------------------------
--  DDL for Package GHR_RIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_RIF_PKG" AUTHID CURRENT_USER AS
/* $Header: ghrifpkg.pkh 120.0 2005/05/29 03:36:18 appldev noship $ */

  msl_error    EXCEPTION;

PROCEDURE run_register (
                    p_rif_criteria_id          in  ghr_rif_criteria.rif_criteria_id%TYPE
                   ,p_organization_id          in  ghr_rif_criteria.organization_id%TYPE
                   ,p_org_structure_id         in  ghr_rif_criteria.org_structure_id%TYPE
                   ,p_office_symbol            in  ghr_rif_criteria.office_symbol%TYPE
                   ,p_agency_code_subelement   in  ghr_rif_criteria.agency_code_subelement%TYPE
                   ,p_comp_area                in  ghr_rif_criteria.comp_area%TYPE
                   ,p_comp_level               in  ghr_rif_criteria.comp_level%TYPE
                   ,p_effective_date           in date
                       );

FUNCTION num_of_vacancies (
                   p_organization_id          in  ghr_rif_criteria.organization_id%TYPE
                   ,p_org_structure_id         in  ghr_rif_criteria.org_structure_id%TYPE
                   ,p_office_symbol            in  ghr_rif_criteria.office_symbol%TYPE
                   ,p_agency_code_subelement   in  ghr_rif_criteria.agency_code_subelement%TYPE
                   ,p_comp_area                in  ghr_rif_criteria.comp_area%TYPE
                   ,p_comp_level               in  ghr_rif_criteria.comp_level%TYPE
                   ,p_effective_date in date
                       )
  return number;

FUNCTION get_org_name(p_organization_id IN per_organization_units.organization_id%TYPE)
  return varchar2;

PROCEDURE purge_register;

PROCEDURE check_unique_name (p_rif_criteria_id IN ghr_rif_criteria.rif_criteria_id%TYPE
                              ,p_name            IN ghr_rif_criteria.name%TYPE);

END ghr_rif_pkg;

 

/
