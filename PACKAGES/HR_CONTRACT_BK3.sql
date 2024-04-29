--------------------------------------------------------
--  DDL for Package HR_CONTRACT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTRACT_BK3" AUTHID CURRENT_USER as
/* $Header: hrctcapi.pkh 120.1 2005/10/02 02:01:33 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_contract_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contract_b
  (
   p_contract_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode              in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_contract_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contract_a
  (
   p_contract_id                    in  number
  ,p_effective_start_date           in  date
  ,p_effective_end_date             in  date
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in varchar2
  );
--
end hr_contract_bk3;

 

/
