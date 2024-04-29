--------------------------------------------------------
--  DDL for Package Body PER_SUCCESSION_PLAN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUCCESSION_PLAN_UTILITY" AS
/* $Header: pesucutl.pkb 120.0.12000000.2 2007/11/21 17:37:53 kgowripe noship $ */
g_package VARCHAR2(40) := 'per_succession_plan_utility.';
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
) IS
  l_proc    VARCHAR2(80) := g_package||'import_succession_plan';
BEGIN
    hr_utility.set_location('Entering '||l_proc,10);
    hr_utility.trace('p_succession_plan_id:'||p_succession_plan_id);
    hr_utility.trace('p_person_id:'||p_person_id);
    hr_utility.trace('p_position_id:'||p_position_id);
    hr_utility.trace('p_business_group_id:'||p_business_group_id);
    hr_utility.trace('p_object_versoin_number:'||p_object_version_number);
    hr_utility.trace('p_effective_date:'||to_char(p_effective_date,'dd-mm-yyyy'));

    IF p_succession_plan_id IS NULL THEN
      hr_utility.set_location('INSERT Block '||l_proc,20);
      per_suc_ins.ins(
		      p_succession_plan_id         => p_succession_plan_id
		     ,p_person_id         	   => p_person_id
		     ,p_position_id       	   => p_position_id
		     ,p_business_group_id     	   => fnd_profile.value('PER_BUSINESS_GROUP_ID')
		     ,p_start_date        	   => p_start_date
		     ,p_time_scale                 => p_time_scale
		     ,p_end_date                   => p_end_date
		     ,p_available_for_promotion    => p_available_for_promotion
		     ,p_manager_comments           => p_manager_comments
		     ,p_object_version_number      => p_object_version_number
		     ,p_attribute_category         => NULL
		     ,p_attribute1                 => NULL
		     ,p_attribute2                 => NULL
		     ,p_attribute3                 => NULL
		     ,p_attribute4                 => NULL
		     ,p_attribute5                 => NULL
		     ,p_attribute6                 => NULL
		     ,p_attribute7                 => NULL
		     ,p_attribute8                 => NULL
		     ,p_attribute9                 => NULL
		     ,p_attribute10                => NULL
		     ,p_attribute11                => NULL
		     ,p_attribute12                => NULL
		     ,p_attribute13                => NULL
		     ,p_attribute14                => NULL
		     ,p_attribute15                => NULL
		     ,p_attribute16                => NULL
		     ,p_attribute17   		   => NULL
		     ,p_attribute18   		   => NULL
		     ,p_attribute19   		   => NULL
		     ,p_attribute20   		   => NULL
		     ,p_effective_date		   => TRUNC(SYSDATE));
       hr_utility.set_location('INSERT Complete '||l_proc,30);
    ELSE
      hr_utility.set_location('UPDATE Block '||l_proc,40);
      per_suc_upd.upd(
		      p_succession_plan_id         => p_succession_plan_id
		     ,p_person_id         	   => p_person_id
		     ,p_position_id       	   => p_position_id
		     ,p_business_group_id     	   => fnd_profile.value('PER_BUSINESS_GROUP_ID')
		     ,p_start_date        	   => p_start_date
		     ,p_time_scale                 => p_time_scale
		     ,p_end_date                   => p_end_date
		     ,p_available_for_promotion    => p_available_for_promotion
		     ,p_manager_comments           => p_manager_comments
		     ,p_object_version_number      => p_object_version_number
		     ,p_attribute_category         => NULL
		     ,p_attribute1                 => NULL
		     ,p_attribute2                 => NULL
		     ,p_attribute3                 => NULL
		     ,p_attribute4                 => NULL
		     ,p_attribute5                 => NULL
		     ,p_attribute6                 => NULL
		     ,p_attribute7                 => NULL
		     ,p_attribute8                 => NULL
		     ,p_attribute9                 => NULL
		     ,p_attribute10                => NULL
		     ,p_attribute11                => NULL
		     ,p_attribute12                => NULL
		     ,p_attribute13                => NULL
		     ,p_attribute14                => NULL
		     ,p_attribute15                => NULL
		     ,p_attribute16                => NULL
		     ,p_attribute17   		   => NULL
		     ,p_attribute18   		   => NULL
		     ,p_attribute19   		   => NULL
		     ,p_attribute20   		   => NULL
		     ,p_effective_date		   => TRUNC(SYSDATE));
       hr_utility.set_location('UPDATE Complete '||l_proc,50);
    END IF;
    hr_utility.set_location('Leaving  '||l_proc,60);
EXCEPTION
   WHEN OTHERS THEN
     hr_utility.set_location('Error: '||l_proc,70);
     RAISE;
END import_succession_plan;
END per_succession_plan_utility;

/
