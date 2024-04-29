--------------------------------------------------------
--  DDL for Package GHR_NOAC_REMARKS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NOAC_REMARKS_BK3" AUTHID CURRENT_USER as
/* $Header: ghnreapi.pkh 120.2 2005/10/02 01:57:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_noac_remarks_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_noac_remarks_b
  (
   p_noac_remark_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_noac_remarks_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_noac_remarks_a
  (
   p_noac_remark_id                 in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ghr_noac_remarks_bk3;

 

/
