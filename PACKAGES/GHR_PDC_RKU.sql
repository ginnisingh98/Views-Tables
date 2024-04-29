--------------------------------------------------------
--  DDL for Package GHR_PDC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PDC_RKU" AUTHID CURRENT_USER as
/* $Header: ghpdcrhi.pkh 120.0.12010000.4 2009/05/27 06:33:20 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--    If the user(customer) has any packages to be executed, then those will be
--    called by this procedure. The body of this procedure will be generated.
--
procedure after_update	(
	p_pd_classification_id          in number  ,
	p_position_description_id       in number  ,
	p_class_grade_by                in varchar2,
	p_official_title                in varchar2,
	p_pay_plan                      in varchar2,
	p_occupational_code             in varchar2,
	p_grade_level                   in varchar2,
	p_object_version_number         in number  ,
	p_position_description_id_o     in number  ,
	p_class_grade_by_o              in varchar2,
	p_official_title_o              in varchar2,
	p_pay_plan_o                    in varchar2,
	p_occupational_code_o           in varchar2,
	p_grade_level_o                 in varchar2,
	p_object_version_number_o       in number
      );

end ghr_pdc_rku;

/
