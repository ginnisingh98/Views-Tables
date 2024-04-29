--------------------------------------------------------
--  DDL for Package HR_PERSON_TYPE_USAGE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_TYPE_USAGE_BK3" AUTHID CURRENT_USER as
/* $Header: peptuapi.pkh 120.3 2005/10/31 02:56:09 jpthomas noship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person_type_usage_b >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_type_usage_b
  (p_person_type_usage_id           in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person_type_usage_a >-----------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_type_usage_a
  (p_person_type_usage_id           in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  );
end hr_person_type_usage_bk3;

 

/
