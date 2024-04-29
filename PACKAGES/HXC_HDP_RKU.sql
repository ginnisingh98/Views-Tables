--------------------------------------------------------
--  DDL for Package HXC_HDP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HDP_RKU" AUTHID CURRENT_USER as
/* $Header: hxchdprhi.pkh 120.0 2005/05/29 05:35:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_deposit_process_id           in number
  ,p_name                         in varchar2
  ,p_time_source_id               in number
  ,p_mapping_id                   in number
  ,p_object_version_number        in number
  ,p_name_o                       in varchar2
  ,p_time_source_id_o             in number
  ,p_mapping_id_o                 in number
  ,p_object_version_number_o      in number
  );
--
end hxc_hdp_rku;

 

/
