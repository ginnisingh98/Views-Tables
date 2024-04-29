--------------------------------------------------------
--  DDL for Package HXC_RTR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RTR_RKD" AUTHID CURRENT_USER as
/* $Header: hxcrtrrhi.pkh 120.0 2005/05/29 05:52:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_retrieval_rule_id            in number
  ,p_retrieval_process_id_o       in number
  ,p_object_version_number_o      in number
  ,p_name_o                       in varchar2
  );
--
end hxc_rtr_rkd;

 

/
