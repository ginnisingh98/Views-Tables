--------------------------------------------------------
--  DDL for Package GHR_PDC_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDC_BK2" AUTHID CURRENT_USER as
/* $Header: ghpdcapi.pkh 120.2 2005/10/02 01:58:10 aroussel $ */
--
--
-- update_pdc_b
--
Procedure update_pdc_b	(
	p_pd_classification_id      IN  number,
	p_position_description_id   IN  number,
	p_class_grade_by            IN  varchar2,
        p_official_title            IN  varchar2,
	p_pay_plan                  IN  varchar2,
	p_occupational_code         IN  varchar2,
	p_grade_level	            IN  varchar2,
	p_pdc_object_version_number IN  number
	);
--
-- update_pdc_a
--
Procedure update_pdc_a	(
	p_pd_classification_id      IN  number,
	p_position_description_id   IN  number,
	p_class_grade_by            IN  varchar2,
        p_official_title            IN  varchar2,
	p_pay_plan                  IN  varchar2,
	p_occupational_code         IN  varchar2,
	p_grade_level	            IN  varchar2,
	p_pdc_object_version_number IN  number
	);

end ghr_pdc_bk2;

 

/
