--------------------------------------------------------
--  DDL for Package PQH_FR_EMP_STAT_SIT_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_EMP_STAT_SIT_UTILITY" AUTHID CURRENT_USER AS
/* $Header: pqfresut.pkh 120.0 2005/05/29 01:53:09 appldev noship $ */
  --
  -- ----------------------< create_emp_stat_situation >------------------------
  -- Description:
  --  This procedure is the self-service wrapper procedure to the following
  --  API: pqh_fr_emp_stat_situation_api.create_emp_stat_situation
  -- ---------------------------------------------------------------------------
  PROCEDURE create_emp_stat_situation
  (p_validate                     IN     NUMBER    DEFAULT HR_API.g_false_num
  ,p_effective_date               IN     DATE
  ,p_statutory_situation_id       IN     NUMBER
  ,p_person_id                    IN     NUMBER
  ,p_provisional_start_date       IN     DATE
  ,p_provisional_end_date         IN     DATE
  ,p_actual_start_date            IN     DATE      DEFAULT NULL
  ,p_actual_end_date              IN     DATE      DEFAULT NULL
  ,p_approval_flag                IN     VARCHAR2  DEFAULT NULL
  ,p_comments                     IN     VARCHAR2  DEFAULT NULL
  ,p_contact_person_id            IN     NUMBER    DEFAULT NULL
  ,p_contact_relationship         IN     VARCHAR2  DEFAULT NULL
  ,p_external_organization_id     IN     NUMBER    DEFAULT NULL
  ,p_renewal_flag                 IN     VARCHAR2  DEFAULT NULL
  ,p_renew_stat_situation_id      IN     NUMBER    DEFAULT NULL
  ,p_seconded_career_id           IN     NUMBER    DEFAULT NULL
  ,p_attribute_category           IN     VARCHAR2  DEFAULT NULL
  ,p_attribute1                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute2                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute3                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute4                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute5                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute6                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute7                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute8                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute9                   IN     VARCHAR2  DEFAULT NULL
  ,p_attribute10                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute11                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute12                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute13                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute14                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute15                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute16                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute17                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute18                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute19                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute20                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute21                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute22                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute23                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute24                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute25                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute26                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute27                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute28                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute29                  IN     VARCHAR2  DEFAULT NULL
  ,p_attribute30                  IN     VARCHAR2  DEFAULT NULL
  ,p_emp_stat_situation_id    OUT nocopy NUMBER
  ,p_object_version_number    OUT nocopy NUMBER
  ,p_return_status            OUT nocopy VARCHAR2
  );
  --
  -- ----------------------< update_emp_stat_situation >------------------------
  -- Description:
  --  This procedure is the self-service wrapper procedure to the following
  --  API: pqh_fr_emp_stat_situation_api.update_emp_stat_situation
  -- ---------------------------------------------------------------------------
  PROCEDURE update_emp_stat_situation
  (p_validate                     IN     NUMBER    DEFAULT HR_API.g_false_num
  ,p_effective_date               IN     DATE
  ,p_emp_stat_situation_id        IN     NUMBER
  ,p_statutory_situation_id       IN     NUMBER    DEFAULT HR_API.g_number
  ,p_person_id                    IN     NUMBER    DEFAULT HR_API.g_number
  ,p_provisional_start_date       IN     DATE      DEFAULT HR_API.g_date
  ,p_provisional_end_date         IN     DATE      DEFAULT HR_API.g_date
  ,p_actual_start_date            IN     DATE      DEFAULT HR_API.g_date
  ,p_actual_end_date              IN     DATE      DEFAULT HR_API.g_date
  ,p_approval_flag                IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_comments                     IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_contact_person_id            IN     NUMBER    DEFAULT HR_API.g_number
  ,p_contact_relationship         IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_external_organization_id     IN     NUMBER    DEFAULT HR_API.g_number
  ,p_renewal_flag                 IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_renew_stat_situation_id      IN     NUMBER    DEFAULT HR_API.g_number
  ,p_seconded_career_id           IN     NUMBER    DEFAULT HR_API.g_number
  ,p_attribute_category           IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute1                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute2                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute3                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute4                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute5                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute6                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute7                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute8                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute9                   IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute10                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute11                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute12                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute13                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute14                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute15                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute16                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute17                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute18                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute19                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute20                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute21                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute22                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute23                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute24                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute25                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute26                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute27                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute28                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute29                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_attribute30                  IN     VARCHAR2  DEFAULT HR_API.g_varchar2
  ,p_object_version_number IN OUT nocopy NUMBER
  ,p_return_status            OUT nocopy VARCHAR2
  );
  --
  -- --------------------< reinstate_emp_stat_situation >-----------------------
  -- Description:
  --  This procedure is the self-service wrapper procedure to the following
  --  API: pqh_fr_emp_stat_situation_api.reinstate_emp_stat_situation
  -- ---------------------------------------------------------------------------
  PROCEDURE reinstate_emp_stat_situation
  (p_validate                      IN     NUMBER   DEFAULT HR_API.g_false_num
  ,p_person_id                     IN     NUMBER
  ,p_emp_stat_situation_id         IN     NUMBER
  ,p_reinstate_date                IN     DATE
  ,p_comments                      IN     VARCHAR2
  ,p_new_emp_stat_situation_id OUT nocopy NUMBER
  ,p_return_status             OUT nocopy VARCHAR2
  );
  --
  -- ----------------------< renew_emp_stat_situation >-------------------------
  -- Description:
  --  This procedure is the self-service wrapper procedure to the following
  --  API: pqh_fr_emp_stat_situation_api.renew_emp_stat_situation
  -- ---------------------------------------------------------------------------
  PROCEDURE renew_emp_stat_situation
  (p_validate                IN            NUMBER  DEFAULT HR_API.g_false_num
  ,p_emp_stat_situation_id   IN OUT nocopy NUMBER
  ,p_renew_stat_situation_id IN            NUMBER
  ,p_renewal_duration        IN            NUMBER
  ,p_duration_units          IN            VARCHAR2
  ,p_approval_flag           IN            VARCHAR2
  ,p_comments                IN            VARCHAR2
  ,p_object_version_number   IN OUT nocopy NUMBER
  ,p_return_status              OUT nocopy VARCHAR2
  );
  --
  -- ---------------------< delete_emp_stat_situation >-------------------------
  -- Description:
  --  This procedure is the self-service wrapper procedure to the following
  --  API: pqh_fr_emp_stat_situation_api.delete_emp_stat_situation
  -- ---------------------------------------------------------------------------
  PROCEDURE delete_emp_stat_situation
  (p_validate              IN     NUMBER DEFAULT HR_API.g_false_num
  ,p_emp_stat_situation_id IN     NUMBER
  ,p_object_version_number IN     NUMBER
  ,p_return_status            OUT nocopy VARCHAR2
  );
  --
  --
  -- ----------------------------< updt_assign >--------------------------------
  -- Description:
  --  This procedure is invoked to call main Update Assignments procedure
  -- ---------------------------------------------------------------------------
  PROCEDURE updt_assign
  (p_person_id              IN NUMBER
  ,p_statutory_situation_id IN NUMBER
  ,p_iand_stat_sit_id       IN NUMBER DEFAULT NULL
  ,p_start_date             IN DATE
  ,p_end_date               IN DATE
  );
  --
  --
  -- --------------------------< is_person_active >-----------------------------
  -- Description:
  --  This function returns whether person is in active situation or not.
  -- ---------------------------------------------------------------------------
  FUNCTION is_person_active
  (p_person_id      IN NUMBER,
   p_effective_date IN DATE) RETURN VARCHAR2;
  --
END PQH_FR_EMP_STAT_SIT_UTILITY;

 

/
