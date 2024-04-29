--------------------------------------------------------
--  DDL for Package HXC_HDP_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HDP_RKI" AUTHID CURRENT_USER as
/* $Header: hxchdprhi.pkh 120.0 2005/05/29 05:35:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_deposit_process_id           in number
  ,p_name                         in varchar2
  ,p_time_source_id               in number
  ,p_mapping_id                   in number
  ,p_object_version_number        in number
  );
end hxc_hdp_rki;

 

/
