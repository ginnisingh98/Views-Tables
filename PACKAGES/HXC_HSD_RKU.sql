--------------------------------------------------------
--  DDL for Package HXC_HSD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_HSD_RKU" AUTHID CURRENT_USER as
/* $Header: hxchsdrhi.pkh 120.0 2005/05/29 05:41:12 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_object_id                    in number
  ,p_object_type                  in varchar2
  ,p_hxc_required                 in varchar2
  ,p_owner_application_id         in number
  ,p_hxc_required_o               in varchar2
  ,p_owner_application_id_o       in number
  );
--
end hxc_hsd_rku;

 

/
