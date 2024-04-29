--------------------------------------------------------
--  DDL for Package GHR_PRE_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PRE_RKD" AUTHID CURRENT_USER as
/* $Header: ghprerhi.pkh 120.0.12010000.2 2009/05/26 10:43:15 vmididho noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete	(
	p_pa_remark_id                  in number  ,
	p_pa_request_id_o               in number  ,
	p_remark_id_o                   in number  ,
	p_description_o                 in varchar2,
      p_remark_code_information1_o    in varchar2,
      p_remark_code_information2_o    in varchar2,
      p_remark_code_information3_o    in varchar2,
      p_remark_code_information4_o    in varchar2,
      p_remark_code_information5_o    in varchar2,
	p_object_version_number_o       in number  );

end ghr_pre_rkd;

/
