--------------------------------------------------------
--  DDL for Package PER_WORK_STRUCTURE_OVERRIDE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_WORK_STRUCTURE_OVERRIDE_SS" AUTHID CURRENT_USER AS
/* $Header: perwscor.pkh 115.0 2004/03/03 08:18:21 hpandya noship $ */
--
-- |--------------------------------------------------------------------------|
-- |--< Global Variable Declarations >----------------------------------------|
-- |--------------------------------------------------------------------------|
--
   g_package       CONSTANT Varchar2(30):='HR_VIEWS_OVERIDE_GEN';
   g_job_override_flg             BOOLEAN:= FALSE;
   g_position_override_flg        BOOLEAN:= FALSE;
   g_grade_override_flg           BOOLEAN:= FALSE;
   g_organization_override_flg    BOOLEAN:= FALSE;

-- |--------------------------------------------------------------------------|
-- |--< Type Declarations >---------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- |--------------------------------------------------------------------------|
-- |--< isOverrideEnabled >---------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION isOverrideEnabled(
            p_object    IN varchar2
	 )
  return boolean;
--
-- |--------------------------------------------------------------------------|
-- |--< getObjectName >-------------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getObjectName(
            p_object    IN varchar2,
            p_object_id IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2;
--
-- |--------------------------------------------------------------------------|
-- |--< getJobName >----------------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getJobName(
            p_job_id    IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2;
--
-- |--------------------------------------------------------------------------|
-- |--< getPositionName >-----------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getPositionName(
            p_pos_id    IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2;
--
-- |--------------------------------------------------------------------------|
-- |--< getGradeName >--------------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getGradeName(
            p_grade_id  IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2;
--
-- |--------------------------------------------------------------------------|
-- |--< getGradeName >--------------------------------------------------------|
-- |--------------------------------------------------------------------------|
--
-- Description:
--
--
FUNCTION getOrganizationName(
            p_org_id    IN number,
            p_bg_id     IN number,
            p_value     IN varchar2
	 )
  return varchar2;

END PER_WORK_STRUCTURE_OVERRIDE_SS;

 

/
