--------------------------------------------------------
--  DDL for Package HXC_RTR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RTR_RKU" AUTHID CURRENT_USER as
/* $Header: hxcrtrrhi.pkh 120.0 2005/05/29 05:52:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_retrieval_rule_id            in number
  ,p_retrieval_process_id         in number
  ,p_object_version_number        in number
  ,p_name                         in varchar2
  ,p_retrieval_process_id_o       in number
  ,p_object_version_number_o      in number
  ,p_name_o                       in varchar2
  );
--
end hxc_rtr_rku;

 

/
