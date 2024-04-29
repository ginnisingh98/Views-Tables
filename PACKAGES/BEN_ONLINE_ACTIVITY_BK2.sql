--------------------------------------------------------
--  DDL for Package BEN_ONLINE_ACTIVITY_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ONLINE_ACTIVITY_BK2" AUTHID CURRENT_USER as
/* $Header: beolaapi.pkh 120.0 2005/05/28 09:50:53 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_online_activity_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_online_activity_b
  (
   p_csr_activities_id              in  number
  ,p_ordr_num                       in  number
  ,p_function_name                  in  varchar2
  ,p_user_function_name             in  varchar2
  ,p_function_type                  in  varchar2
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_online_activity_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_online_activity_a
  (
   p_csr_activities_id              in  number
  ,p_ordr_num                       in  number
  ,p_function_name                  in  varchar2
  ,p_user_function_name             in  varchar2
  ,p_function_type                  in  varchar2
  ,p_business_group_id              in  number
  ,p_object_version_number          in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  );
--
end ben_online_activity_bk2;

 

/
