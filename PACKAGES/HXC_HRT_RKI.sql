--------------------------------------------------------
--  DDL for Package HXC_HRT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HRT_RKI" AUTHID CURRENT_USER as
/* $Header: hxchrtrhi.pkh 120.0 2005/05/29 05:40:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_retrieval_process_id         in number
  ,p_time_recipient_id            in number
  ,p_name                         in varchar2
  ,p_mapping_id                   in number
  ,p_object_version_number        in number
  );
end hxc_hrt_rki;

 

/
