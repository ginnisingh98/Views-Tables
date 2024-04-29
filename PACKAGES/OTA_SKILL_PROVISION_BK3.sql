--------------------------------------------------------
--  DDL for Package OTA_SKILL_PROVISION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_SKILL_PROVISION_BK3" AUTHID CURRENT_USER as
/* $Header: ottspapi.pkh 120.1 2005/10/02 02:08:49 aroussel $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ota_skill_provision_bk3.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_SKILL_PROVISION_B >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  Before Process User Hook.
--
-- {End Of Comments}
--
procedure Delete_Skill_provision_b
  (p_skill_provision_id             in     number
  ,p_object_version_number         in     number
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_SKILL_PROVISION_A >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--  After Process User Hook.
--
-- {End Of Comments}
--
procedure Delete_Skill_provision_a
  (  p_skill_provision_id                   in     number
  ,p_object_version_number         in     number
  );

end ota_skill_provision_bk3;

 

/
