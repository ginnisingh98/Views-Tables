--------------------------------------------------------
--  DDL for Package PER_SUCCESSION_PLAN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUCCESSION_PLAN_UTILITY" AUTHID CURRENT_USER AS
/* $Header: pesucutl.pkh 120.0.12000000.1 2007/10/26 18:24:34 vkodedal noship $ */

PROCEDURE import_succession_plan
(
  p_succession_plan_id           in out nocopy  number,
  p_person_id                    in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_start_date                   in date             default hr_api.g_date,
  p_time_scale                   in varchar2         default hr_api.g_varchar2,
  p_end_date                     in date             default hr_api.g_date,
  p_available_for_promotion      in varchar2         default hr_api.g_varchar2,
  p_manager_comments             in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_effective_date               in date             default hr_api.g_date
);

END per_succession_plan_utility;

 

/
