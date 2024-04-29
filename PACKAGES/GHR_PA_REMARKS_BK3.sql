--------------------------------------------------------
--  DDL for Package GHR_PA_REMARKS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PA_REMARKS_BK3" AUTHID CURRENT_USER as
/* $Header: ghpreapi.pkh 120.3 2006/07/07 12:43:15 vnarasim noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_pa_remarks_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_pa_remarks_b	(
       p_pa_remark_id                  in     number
      ,p_object_version_number         in     number
	);
--
-- |-------------------------< delete_pa_remarks_a >-------------------------|
--
Procedure delete_pa_remarks_a	(
       p_pa_remark_id                  in     number
      ,p_object_version_number         in     number
	);

end ghr_pa_remarks_bk3;

 

/
