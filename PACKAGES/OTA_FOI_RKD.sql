--------------------------------------------------------
--  DDL for Package OTA_FOI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FOI_RKD" AUTHID CURRENT_USER as
/* $Header: otfoirhi.pkh 120.0 2005/06/24 07:56 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_forum_id                     in number
  ,p_object_id                    in number
  ,p_object_type                  in varchar2
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_primary_flag_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end ota_foi_rkd;

 

/
