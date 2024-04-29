--------------------------------------------------------
--  DDL for Package HR_PERSONAL_SCORECARD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSONAL_SCORECARD_BK3" AUTHID CURRENT_USER as
/* $Header: pepmsapi.pkh 120.5 2006/10/24 15:51:09 tpapired noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_scorecard_status_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_scorecard_status_b
  (p_effective_date                in     date
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in     number
  ,p_status_code                   in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_scorecard_status_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_scorecard_status_a
  (p_effective_date                in     date
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in     number
  ,p_status_code                   in     varchar2
  );
--
end hr_personal_scorecard_bk3;

 

/
