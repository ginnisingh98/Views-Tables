--------------------------------------------------------
--  DDL for Package HR_APPRAISAL_PERIOD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISAL_PERIOD_BK3" AUTHID CURRENT_USER as
/* $Header: pepmaapi.pkh 120.7.12010000.3 2010/02/22 06:38:33 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_appraisal_period_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_appraisal_period_b
  (p_appraisal_period_id           in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_appraisal_period_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_appraisal_period_a
  (p_appraisal_period_id           in     number
  ,p_object_version_number         in     number
  );
--
end hr_appraisal_period_bk3;

/
