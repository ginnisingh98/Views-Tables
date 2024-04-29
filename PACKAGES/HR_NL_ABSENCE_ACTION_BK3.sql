--------------------------------------------------------
--  DDL for Package HR_NL_ABSENCE_ACTION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_ABSENCE_ACTION_BK3" AUTHID CURRENT_USER as
/* $Header: penaaapi.pkh 120.1 2005/10/02 02:18:47 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_absence_action_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_absence_action_b
  (p_absence_action_id             in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_absence_action_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_absence_action_a
  (p_absence_action_id             in     number
  ,p_object_version_number         in     number
  );
--
end HR_NL_ABSENCE_ACTION_bk3;

 

/
