--------------------------------------------------------
--  DDL for Package GHR_PRE_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PRE_RKI" AUTHID CURRENT_USER as
/* $Header: ghprerhi.pkh 120.0.12010000.2 2009/05/26 10:43:15 vmididho noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_insert >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description :
--    If the user(customer) has any packages to be executed, then those will be
--    called by this procedure. The body of this procedure will be generated.
--
procedure after_insert	(
	p_pa_remark_id                  in number  ,
	p_pa_request_id                 in number  ,
	p_remark_id                     in number  ,
	p_description                   in varchar2,
      p_remark_code_information1      in varchar2,
      p_remark_code_information2      in varchar2,
      p_remark_code_information3      in varchar2,
      p_remark_code_information4      in varchar2,
      p_remark_code_information5      in varchar2,
	p_object_version_number         in number  );

end ghr_pre_rki;

/
