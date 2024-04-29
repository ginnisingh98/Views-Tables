--------------------------------------------------------
--  DDL for Package HXC_HTS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HTS_RKI" AUTHID CURRENT_USER as
/* $Header: hxchtsrhi.pkh 120.0 2005/05/29 05:44:35 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_time_source_id               in number
  ,p_name                         in varchar2
  ,p_object_version_number        in number
  );
end hxc_hts_rki;

 

/
