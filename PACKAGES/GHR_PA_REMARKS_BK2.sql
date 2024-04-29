--------------------------------------------------------
--  DDL for Package GHR_PA_REMARKS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PA_REMARKS_BK2" AUTHID CURRENT_USER as
/* $Header: ghpreapi.pkh 120.3 2006/07/07 12:43:15 vnarasim noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_pa_remarks_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_pa_remarks_b	(
         p_pa_remark_id                  in     number
        ,p_object_version_number         in     number
        ,p_remark_code_information1      in     varchar2
        ,p_remark_code_information2      in     varchar2
        ,p_remark_code_information3      in     varchar2
        ,p_remark_code_information4      in     varchar2
        ,p_remark_code_information5      in     varchar2
        ,p_description                   in     varchar2
	);
--
-- |-------------------------< update_pa_remarks_a >-------------------------|
--
Procedure update_pa_remarks_a	(
         p_pa_remark_id                  in     number
        ,p_object_version_number         in     number
        ,p_remark_code_information1      in     varchar2
        ,p_remark_code_information2      in     varchar2
        ,p_remark_code_information3      in     varchar2
        ,p_remark_code_information4      in     varchar2
        ,p_remark_code_information5      in     varchar2
        ,p_description                   in     varchar2
	);

end ghr_pa_remarks_bk2;

 

/
