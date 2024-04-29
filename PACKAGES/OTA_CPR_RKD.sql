--------------------------------------------------------
--  DDL for Package OTA_CPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CPR_RKD" AUTHID CURRENT_USER as
/* $Header: otcprrhi.pkh 120.0.12000000.1 2007/01/18 04:07:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_activity_version_id          in number
  ,p_prerequisite_course_id       in number
  ,p_business_group_id_o          in number
  ,p_prerequisite_type_o          in varchar2
  ,p_enforcement_mode_o           in varchar2
  ,p_object_version_number_o      in number
  );
--
end ota_cpr_rkd;

 

/
