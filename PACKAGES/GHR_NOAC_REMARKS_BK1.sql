--------------------------------------------------------
--  DDL for Package GHR_NOAC_REMARKS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NOAC_REMARKS_BK1" AUTHID CURRENT_USER as
/* $Header: ghnreapi.pkh 120.2 2005/10/02 01:57:59 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_noac_remarks_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_noac_remarks_b
  (
   p_nature_of_action_id            in  number
  ,p_remark_id                      in  number
  ,p_required_flag                  in  varchar2
  ,p_enabled_flag                   in  varchar2
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_noac_remarks_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure create_noac_remarks_a
  (
   p_noac_remark_id                 in  number
  ,p_nature_of_action_id            in  number
  ,p_remark_id                      in  number
  ,p_required_flag                  in  varchar2
  ,p_enabled_flag                   in  varchar2
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  );
--
end ghr_noac_remarks_bk1;

 

/
