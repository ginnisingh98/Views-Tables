--------------------------------------------------------
--  DDL for Package OTA_SKILL_PROVISION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_SKILL_PROVISION_BK1" AUTHID CURRENT_USER as
/* $Header: ottspapi.pkh 120.1 2005/10/02 02:08:49 aroussel $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_skill_provision_bk1.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_SKILL_PROVISION_B >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure CREATE_SKILL_PROVISION_B
  (
  p_activity_version_id          in number,
  p_object_version_number        IN  number,
  p_type                         in varchar2,
  p_comments                     in varchar2       ,
  p_tsp_information_category     in varchar2 ,
  p_tsp_information1             in varchar2      ,
  p_tsp_information2             in varchar2      ,
  p_tsp_information3             in varchar2      ,
  p_tsp_information4             in varchar2      ,
  p_tsp_information5             in varchar2      ,
  p_tsp_information6             in varchar2        ,
  p_tsp_information7             in varchar2        ,
  p_tsp_information8             in varchar2        ,
  p_tsp_information9             in varchar2        ,
  p_tsp_information10            in varchar2       ,
  p_tsp_information11            in varchar2       ,
  p_tsp_information12            in varchar2       ,
  p_tsp_information13            in varchar2       ,
  p_tsp_information14            in varchar2       ,
  p_tsp_information15            in varchar2       ,
  p_tsp_information16            in varchar2       ,
  p_tsp_information17            in varchar2       ,
  p_tsp_information18            in varchar2       ,
  p_tsp_information19            in varchar2       ,
  p_tsp_information20            in varchar2       ,
  p_analysis_criteria_id         in number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_SKILL_PROVISION_A >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure Create_Skill_Provision_a
  (p_skill_provision_id           in number,
  p_activity_version_id          in number,
  p_object_version_number        IN  number,
  p_type                         in varchar2,
  p_comments                     in varchar2       ,
  p_tsp_information_category     in varchar2 ,
  p_tsp_information1             in varchar2      ,
  p_tsp_information2             in varchar2      ,
  p_tsp_information3             in varchar2      ,
  p_tsp_information4             in varchar2      ,
  p_tsp_information5             in varchar2      ,
  p_tsp_information6             in varchar2        ,
  p_tsp_information7             in varchar2        ,
  p_tsp_information8             in varchar2        ,
  p_tsp_information9             in varchar2        ,
  p_tsp_information10            in varchar2       ,
  p_tsp_information11            in varchar2       ,
  p_tsp_information12            in varchar2       ,
  p_tsp_information13            in varchar2       ,
  p_tsp_information14            in varchar2       ,
  p_tsp_information15            in varchar2       ,
  p_tsp_information16            in varchar2       ,
  p_tsp_information17            in varchar2       ,
  p_tsp_information18            in varchar2       ,
  p_tsp_information19            in varchar2       ,
  p_tsp_information20            in varchar2       ,
  p_analysis_criteria_id         in number
  );



end ota_skill_provision_bk1;

 

/
