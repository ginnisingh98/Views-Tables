--------------------------------------------------------
--  DDL for Package GHR_NOAC_LAS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NOAC_LAS_BK2" AUTHID CURRENT_USER as
/* $Header: ghnlaapi.pkh 120.2 2005/10/02 01:57:53 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_noac_las_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_noac_las_b
  (
   p_noac_la_id                     in  number
  ,p_nature_of_action_id            in  number
  ,p_lac_lookup_code                in  varchar2
  ,p_enabled_flag                   in  varchar2
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_object_version_number          in  number
  ,p_valid_first_lac_flag           in  varchar2
  ,p_valid_second_lac_flag          in  varchar2
  ,p_effective_date                 in  date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_noac_las_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure update_noac_las_a
  (
   p_noac_la_id                     in  number
  ,p_nature_of_action_id            in  number
  ,p_lac_lookup_code                in  varchar2
  ,p_enabled_flag                   in  varchar2
  ,p_date_from                      in  date
  ,p_date_to                        in  date
  ,p_object_version_number          in  number
  ,p_valid_first_lac_flag           in  varchar2
  ,p_valid_second_lac_flag          in  varchar2
  ,p_effective_date                 in  date
  );
--
end ghr_noac_las_bk2;

 

/
