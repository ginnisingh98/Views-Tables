--------------------------------------------------------
--  DDL for Package PER_RECRUITMENT_ACTIVITY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RECRUITMENT_ACTIVITY_BK3" AUTHID CURRENT_USER as
/* $Header: peraaapi.pkh 120.1 2005/10/02 02:23:28 aroussel $ */
--
-- -----------------------------------------------------------------------------
-- |--------------------< delete_recruitment_activity_B >----------------------|
-- -----------------------------------------------------------------------------
--
procedure delete_recruitment_activity_b
  (p_recruitment_activity_id       in   number
  ,p_object_version_number         in   number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_recruitment_activity_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_recruitment_activity_a
  (p_recruitment_activity_id       in   number
  ,p_object_version_number         in   number
  );
--
end PER_RECRUITMENT_ACTIVITY_BK3;

 

/
