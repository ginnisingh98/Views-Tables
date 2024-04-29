--------------------------------------------------------
--  DDL for Package BEN_EXT_RSLT_ERR_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_RSLT_ERR_BK2" AUTHID CURRENT_USER as
/* $Header: bexreapi.pkh 120.0 2005/05/28 12:39:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_RSLT_ERR_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_RSLT_ERR_b
  (
   p_ext_rslt_err_id                in  number
  ,p_err_num                        in  number
  ,p_err_txt                        in  varchar2
  ,p_typ_cd                         in  varchar2
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_ext_rslt_id                    in  number
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_EXT_RSLT_ERR_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_RSLT_ERR_a
  (
   p_ext_rslt_err_id                in  number
  ,p_err_num                        in  number
  ,p_err_txt                        in  varchar2
  ,p_typ_cd                         in  varchar2
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_request_id                     in  number
  ,p_program_application_id         in  number
  ,p_program_id                     in  number
  ,p_program_update_date            in  date
  ,p_ext_rslt_id                    in  number
  ,p_effective_date                 in  date
  );
--
end ben_EXT_RSLT_ERR_bk2;

 

/
