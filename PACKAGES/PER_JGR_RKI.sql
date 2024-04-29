--------------------------------------------------------
--  DDL for Package PER_JGR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JGR_RKI" AUTHID CURRENT_USER as
/* $Header: pejgrrhi.pkh 120.0 2005/05/31 10:40:37 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_job_group_id                 in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_internal_name                in varchar2
  ,p_displayed_name               in varchar2
  ,p_id_flex_num                  in number
  ,p_master_flag                  in varchar2
  ,p_object_version_number        in number
  );
end per_jgr_rki;

 

/
