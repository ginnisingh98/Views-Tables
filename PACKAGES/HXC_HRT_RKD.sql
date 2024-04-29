--------------------------------------------------------
--  DDL for Package HXC_HRT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HRT_RKD" AUTHID CURRENT_USER as
/* $Header: hxchrtrhi.pkh 120.0 2005/05/29 05:40:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_retrieval_process_id         in number
  ,p_time_recipient_id_o          in number
  ,p_name_o                       in varchar2
  ,p_mapping_id_o                 in number
  ,p_object_version_number_o      in number
  );
--
end hxc_hrt_rkd;

 

/
