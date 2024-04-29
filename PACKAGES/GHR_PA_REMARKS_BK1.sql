--------------------------------------------------------
--  DDL for Package GHR_PA_REMARKS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PA_REMARKS_BK1" AUTHID CURRENT_USER as
/* $Header: ghpreapi.pkh 120.3 2006/07/07 12:43:15 vnarasim noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pa_remarks_b >-------------------------|
-- ----------------------------------------------------------------------------
--

Procedure create_pa_remarks_b	(
      p_pa_request_id                 in     number
     ,p_remark_id                     in     number
     ,p_description                   in     varchar2
     ,p_remark_code_information1      in     varchar2
     ,p_remark_code_information2      in     varchar2
     ,p_remark_code_information3      in     varchar2
     ,p_remark_code_information4      in     varchar2
     ,p_remark_code_information5      in     varchar2
	);

-- |-------------------------< create_pa_remarks_a >-------------------------|

Procedure create_pa_remarks_a	(
      p_pa_request_id 	              in     number
     ,p_remark_id                     in     number
     ,p_description                   in     varchar2
     ,p_remark_code_information1      in     varchar2
     ,p_remark_code_information2      in     varchar2
     ,p_remark_code_information3      in     varchar2
     ,p_remark_code_information4      in     varchar2
     ,p_remark_code_information5      in     varchar2
     ,p_pa_remark_id                  in     number
     ,p_object_version_number         in     number
	);

end ghr_pa_remarks_bk1;

 

/
