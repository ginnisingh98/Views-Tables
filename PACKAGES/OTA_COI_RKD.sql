--------------------------------------------------------
--  DDL for Package OTA_COI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_COI_RKD" AUTHID CURRENT_USER as
/* $Header: otcoirhi.pkh 120.0 2005/06/24 07:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_chat_id                      in number
  ,p_object_id                    in number
  ,p_object_type                  in varchar2
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_primary_flag_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end ota_coi_rkd;

 

/
