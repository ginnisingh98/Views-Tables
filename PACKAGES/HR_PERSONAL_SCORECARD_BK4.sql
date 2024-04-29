--------------------------------------------------------
--  DDL for Package HR_PERSONAL_SCORECARD_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSONAL_SCORECARD_BK4" AUTHID CURRENT_USER as
/* $Header: pepmsapi.pkh 120.5 2006/10/24 15:51:09 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_scorecard_b >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_scorecard_b
  (p_scorecard_id                  in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_scorecard_a >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_scorecard_a
  (p_scorecard_id                  in     number
  ,p_object_version_number         in     number
  ,p_created_by_plan_warning       in     boolean
  );
--
end hr_personal_scorecard_bk4;

 

/
