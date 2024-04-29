--------------------------------------------------------
--  DDL for Package PER_DISABILITY_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DISABILITY_API_BK3" AUTHID CURRENT_USER as
/* $Header: pedisapi.pkh 120.1 2005/10/02 02:14:49 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_disability_b >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_disability_b
  (p_effective_date                in      date
  ,p_datetrack_mode                in      varchar2
  ,p_disability_id                 in      number
  ,p_object_version_number         in      number

  );
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_disability_a >------------------------|
-- ----------------------------------------------------------------------------
--
Procedure delete_disability_a
  (p_effective_date                in      date
  ,p_datetrack_mode                in      varchar2
  ,p_disability_id                 in      number
  ,p_object_version_number         in      number
  ,p_effective_start_date          in      date
  ,p_effective_end_date            in      date
  );
--
end per_disability_api_bk3;

 

/
