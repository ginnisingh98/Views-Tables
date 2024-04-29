--------------------------------------------------------
--  DDL for Package GHR_BREAKDOWN_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_BREAKDOWN_RPT" AUTHID CURRENT_USER AS
/* $Header: ghbrkdwn.pkh 120.1 2005/07/01 02:12:40 asubrahm noship $ */
--
  PROCEDURE Set_Effective_Date(p_date IN DATE);

  FUNCTION Effective_Date RETURN DATE;

  PROCEDURE Set_Agency(p_agency IN VARCHAR2,
                       p_subelm IN VARCHAR2);

  FUNCTION Agency_Subelement RETURN VARCHAR2;

  PROCEDURE Set_By_Clause(p_name     IN VARCHAR2);

  PROCEDURE Set_within_clause(p_name IN VARCHAR2);

  PROCEDURE set_for_clause(p_value IN NUMBER);

  FUNCTION get_for_clause RETURN NUMBER;

  PROCEDURE set_extra_clause(p_name IN VARCHAR2);

  PROCEDURE set_hierarchy(p_org_strver_id IN NUMBER);

  FUNCTION get_hierarchy_level(p_position_id IN NUMBER, p_effective_date IN DATE)
  RETURN NUMBER;

  FUNCTION get_hierarchy_codes (p_ASG_rowid IN ROWID, p_effective_date IN DATE,
                                p_mode IN VARCHAR2 := 'PARENTS')
  RETURN VARCHAR2;

  PROCEDURE process(p_breakdown_criteria_id IN NUMBER := NULL);

  PROCEDURE Delete_Temp_Data;

  FUNCTION decode_lookup(p_lookup_type  IN VARCHAR2,
                         p_lookup_code  IN VARCHAR2)
  RETURN VARCHAR2;

  Procedure return_special_information
  (p_person_id       in  number
  ,p_structure_name  in  varchar2
  ,p_effective_date  in  date
  ,p_special_info    OUT NOCOPY ghr_api.special_information_type
  );

  l_effective_date      DATE   NOT NULL     := SYSDATE;

  PRAGMA RESTRICT_REFERENCES(Effective_Date,             WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(Agency_Subelement,          WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(ghr_breakdown_rpt,          WNDS, WNPS);
  -- Removed pragma (it's not needed in 8.1 according to bug# 1014743)
  -- PRAGMA RESTRICT_REFERENCES(decode_lookup,              WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(get_hierarchy_level,        WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(get_hierarchy_codes,        WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(get_for_clause,             WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(get_hierarchy_codes,        WNDS, WNPS);
  PRAGMA RESTRICT_REFERENCES(return_special_information, WNDS, WNPS);

  -- bug 657712
  FUNCTION get_org_struct_name(
                   p_org_structure_version_id      per_org_structure_versions.org_structure_version_id%TYPE)
    RETURN VARCHAR2;

END ghr_breakdown_rpt;

 

/
