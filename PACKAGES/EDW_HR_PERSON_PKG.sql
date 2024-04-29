--------------------------------------------------------
--  DDL for Package EDW_HR_PERSON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_HR_PERSON_PKG" AUTHID CURRENT_USER AS
/*$Header: hriekpsn.pkh 120.1 2005/06/07 05:40:46 anmajumd noship $*/
-- ---------------------------------------------------------
-- Regular Employee API for Person Hierarchy in PERSON DIMENSION
--
-- Function returns primary assignment level key for this regular
-- employee (past and current) with employee_id = p_person_id
--
-- Underlining View: edw_hr_person_prim_assign_fkv
-- ---------------------------------------------------------
--
  Function Regular_Employee_FK (
              p_person_id     in NUMBER,
              p_instance_code in VARCHAR2 := NULL) return VARCHAR2;
--
-- ---------------------------------------------------------
-- Planners API for Person Hierarchy in PERSON DIMENSION
-- Function returns primary assignment level key for this planner with
-- p_organization_id and p_planner_code
--
-- Underlining View: edw_mtl_planners_fkv
-- ---------------------------------------------------------
--
   Function Planner_FK (
	       p_organization_id in NUMBER,
           p_planner_code    in VARCHAR2,
           p_instance_code   in VARCHAR2 := NULL) return VARCHAR2;
--
-- ---------------------------------------------------------
-- Sales_Rep API for Person Hierarchy in PERSON DIMENSION
--
-- Function returns primary assignment level key for sales_rep with
-- sales_rep_id = p_salesrep_id and organization_id = p_organization_id
-- Underlining View: edw_ra_salesreps_fkv
-- ---------------------------------------------------------
--
  Function Sales_Rep_FK  (
	       p_salesrep_id     in NUMBER,
	       p_organization_id in NUMBER,
           p_instance_code   in VARCHAR2 :=NULL) return VARCHAR2;
  --
  PRAGMA RESTRICT_REFERENCES (Regular_Employee_FK, WNDS, WNPS, RNPS);
  --
  PRAGMA RESTRICT_REFERENCES (Planner_FK,   WNDS, WNPS, RNPS);
  --
  PRAGMA RESTRICT_REFERENCES (Sales_Rep_FK, WNDS, WNPS, RNPS);
--
-- -----------------------------------------------------------
-- API to determine if a person with person_id is a buyer
-- It returns either 'Y' or 'N'
-- -----------------------------------------------------------
--
   Function Buyer_Flag (p_person_id in NUMBER) return VARCHAR2;
--
-- -----------------------------------------------------------
-- API to determine if a person with person_id is a planner
-- It returns either 'Y' or 'N'
-- -----------------------------------------------------------
--
   Function Planner_Flag (p_person_id in NUMBER) return VARCHAR2;
--
-- -----------------------------------------------------------
-- API to determine if a person with person_id is a sales_rep
-- It returns either 'Y' or 'N'
--------------------------------------------------------------
--
  Function Sales_Rep_Flag (p_person_id in NUMBER) return VARCHAR2;
  --
  PRAGMA RESTRICT_REFERENCES (Buyer_Flag,     WNDS, WNPS, RNPS);
  --
  PRAGMA RESTRICT_REFERENCES (Planner_Flag,   WNDS, WNPS, RNPS);
  --
  PRAGMA RESTRICT_REFERENCES (Sales_Rep_Flag, WNDS, WNPS, RNPS);
  --
END EDW_HR_PERSON_PKG;

 

/
