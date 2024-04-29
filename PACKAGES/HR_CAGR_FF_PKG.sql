--------------------------------------------------------
--  DDL for Package HR_CAGR_FF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_FF_PKG" AUTHID CURRENT_USER AS
/* $Header: hrcagrff.pkh 115.2 2002/12/09 14:33:49 hjonnala noship $ */

--
TYPE cagr_FF_record    IS RECORD
(VALUE                  per_cagr_entitlement_lines_f.VALUE%TYPE
,RANGE_FROM             per_cagr_entitlement_lines_f.RANGE_FROM%TYPE
,RANGE_TO               per_cagr_entitlement_lines_f.RANGE_TO%TYPE
,GRADE_SPINE_ID         per_cagr_entitlement_lines_f.GRADE_SPINE_ID%TYPE
,PARENT_SPINE_ID        per_cagr_entitlement_lines_f.PARENT_SPINE_ID%TYPE
,STEP_ID                per_cagr_entitlement_lines_f.STEP_ID%TYPE
,FROM_STEP_ID           per_cagr_entitlement_lines_f.FROM_STEP_ID%TYPE
,TO_STEP_ID             per_cagr_entitlement_lines_f.TO_STEP_ID%TYPE);
--
procedure cagr_entitlement_ff
( p_formula_id          IN  NUMBER,
  p_effective_date      IN  DATE,
  p_assignment_id       IN  NUMBER,
  p_category_name       IN  VARCHAR2,
  p_out_rec	 OUT NOCOPY hr_cagr_ff_pkg.cagr_FF_record);

END hr_cagr_ff_pkg;

 

/
