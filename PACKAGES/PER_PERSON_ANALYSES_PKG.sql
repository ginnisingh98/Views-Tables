--------------------------------------------------------
--  DDL for Package PER_PERSON_ANALYSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERSON_ANALYSES_PKG" AUTHID CURRENT_USER as
/* $Header: pepea01t.pkh 115.3 2002/12/09 12:14:31 pkakar ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
--
procedure check_for_duplicates(p_bg_id number
                              ,p_id_flex_num number
                              ,p_analysis_criteria_id number
                              ,p_end_of_time date
                              ,p_date_from date
                              ,p_date_to date
                              ,p_person_id number
                              ,p_rowid varchar2);
--
function get_unique_id return number;
--
procedure single_info_type(p_bg_id number
                          ,p_person_id number
                          ,p_customized_restriction_id number
                          ,p_count_info_type IN OUT NOCOPY number  );
--
procedure unique_case_number (p_business_group_id in number,
                              p_legislation_code  in varchar2,
                              p_id_flex_num       in number,
                              p_segment1          in varchar2);
--
function populate_info_exists
  (p_id_flex_num        in per_person_analyses.id_flex_num%TYPE,
   p_person_id          in per_person_analyses.person_id%TYPE,
   p_business_group_id  in per_person_analyses.business_group_id%TYPE)
  return varchar2;
--
END PER_PERSON_ANALYSES_PKG;

 

/
