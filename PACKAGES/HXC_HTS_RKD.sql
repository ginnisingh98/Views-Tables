--------------------------------------------------------
--  DDL for Package HXC_HTS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTS_RKD" AUTHID CURRENT_USER as
/* $Header: hxchtsrhi.pkh 120.0 2005/05/29 05:44:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_time_source_id               in number
  ,p_name_o                       in varchar2
  ,p_object_version_number_o      in number
  );
--
end hxc_hts_rkd;

 

/
