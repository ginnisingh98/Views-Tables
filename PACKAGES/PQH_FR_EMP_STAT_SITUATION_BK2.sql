--------------------------------------------------------
--  DDL for Package PQH_FR_EMP_STAT_SITUATION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_EMP_STAT_SITUATION_BK2" AUTHID CURRENT_USER as
/* $Header: pqpsuapi.pkh 120.0 2005/05/29 02:19:41 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_EMP_STAT_SITUATION_B >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_EMP_STAT_SITUATION_B
  (p_effective_date                IN     date
  ,P_EMP_STAT_SITUATION_ID         in     NUMBER
  ,P_STATUTORY_SITUATION_ID        IN     NUMBER
  ,P_PERSON_ID                     IN     NUMBER
  ,P_PROVISIONAL_START_DATE        IN     DATE
  ,P_PROVISIONAL_END_DATE          IN     DATE
  ,P_ACTUAL_START_DATE             IN     DATE
  ,P_ACTUAL_END_DATE               IN     DATE
  ,P_APPROVAL_FLAG                 IN     VARCHAR2
  ,P_COMMENTS                      IN     VARCHAR2
  ,P_CONTACT_PERSON_ID             IN     NUMBER
  ,P_CONTACT_RELATIONSHIP          IN     VARCHAR2
  ,P_EXTERNAL_ORGANIZATION_ID      IN     NUMBER
  ,P_RENEWAL_FLAG                  IN     VARCHAR2
  ,P_RENEW_STAT_SITUATION_ID       IN     NUMBER
  ,P_SECONDED_CAREER_ID            IN     NUMBER
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2
  ,P_ATTRIBUTE1                    IN     VARCHAR2
  ,P_ATTRIBUTE2                    IN     VARCHAR2
  ,P_ATTRIBUTE3                    IN     VARCHAR2
  ,P_ATTRIBUTE4                    IN     VARCHAR2
  ,P_ATTRIBUTE5                    IN     VARCHAR2
  ,P_ATTRIBUTE6                    IN     VARCHAR2
  ,P_ATTRIBUTE7                    IN     VARCHAR2
  ,P_ATTRIBUTE8                    IN     VARCHAR2
  ,P_ATTRIBUTE9                    IN     VARCHAR2
  ,P_ATTRIBUTE10                   IN     VARCHAR2
  ,P_ATTRIBUTE11                   IN     VARCHAR2
  ,P_ATTRIBUTE12                   IN     VARCHAR2
  ,P_ATTRIBUTE13                   IN     VARCHAR2
  ,P_ATTRIBUTE14                   IN     VARCHAR2
  ,P_ATTRIBUTE15                   IN     VARCHAR2
  ,P_ATTRIBUTE16                   IN     VARCHAR2
  ,P_ATTRIBUTE17                   IN     VARCHAR2
  ,P_ATTRIBUTE18                   IN     VARCHAR2
  ,P_ATTRIBUTE19                   IN     VARCHAR2
  ,P_ATTRIBUTE20                   IN     VARCHAR2
  ,P_ATTRIBUTE21                   IN     VARCHAR2
  ,P_ATTRIBUTE22                   IN     VARCHAR2
  ,P_ATTRIBUTE23                   IN     VARCHAR2
  ,P_ATTRIBUTE24                   IN     VARCHAR2
  ,P_ATTRIBUTE25                   IN     VARCHAR2
  ,P_ATTRIBUTE26                   IN     VARCHAR2
  ,P_ATTRIBUTE27                   IN     VARCHAR2
  ,P_ATTRIBUTE28                   IN     VARCHAR2
  ,P_ATTRIBUTE29                   IN     VARCHAR2
  ,P_ATTRIBUTE30                   IN     VARCHAR2
  ,p_object_version_number         in     number  );
--
-- ----------------------------------------------------------------------------
-- |-----------------< UPDATE_EMP_STAT_SITUATION_A >----------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_EMP_STAT_SITUATION_A
  (p_effective_date                IN     date
  ,P_STATUTORY_SITUATION_ID        IN     NUMBER
  ,P_PERSON_ID                     IN     NUMBER
  ,P_PROVISIONAL_START_DATE        IN     DATE
  ,P_PROVISIONAL_END_DATE          IN     DATE
  ,P_ACTUAL_START_DATE             IN     DATE
  ,P_ACTUAL_END_DATE               IN     DATE
  ,P_APPROVAL_FLAG                 IN     VARCHAR2
  ,P_COMMENTS                      IN     VARCHAR2
  ,P_CONTACT_PERSON_ID             IN     NUMBER
  ,P_CONTACT_RELATIONSHIP          IN     VARCHAR2
  ,P_EXTERNAL_ORGANIZATION_ID      IN     NUMBER
  ,P_RENEWAL_FLAG                  IN     VARCHAR2
  ,P_RENEW_STAT_SITUATION_ID       IN     NUMBER
  ,P_SECONDED_CAREER_ID            IN     NUMBER
  ,P_ATTRIBUTE_CATEGORY            IN     VARCHAR2
  ,P_ATTRIBUTE1                    IN     VARCHAR2
  ,P_ATTRIBUTE2                    IN     VARCHAR2
  ,P_ATTRIBUTE3                    IN     VARCHAR2
  ,P_ATTRIBUTE4                    IN     VARCHAR2
  ,P_ATTRIBUTE5                    IN     VARCHAR2
  ,P_ATTRIBUTE6                    IN     VARCHAR2
  ,P_ATTRIBUTE7                    IN     VARCHAR2
  ,P_ATTRIBUTE8                    IN     VARCHAR2
  ,P_ATTRIBUTE9                    IN     VARCHAR2
  ,P_ATTRIBUTE10                   IN     VARCHAR2
  ,P_ATTRIBUTE11                   IN     VARCHAR2
  ,P_ATTRIBUTE12                   IN     VARCHAR2
  ,P_ATTRIBUTE13                   IN     VARCHAR2
  ,P_ATTRIBUTE14                   IN     VARCHAR2
  ,P_ATTRIBUTE15                   IN     VARCHAR2
  ,P_ATTRIBUTE16                   IN     VARCHAR2
  ,P_ATTRIBUTE17                   IN     VARCHAR2
  ,P_ATTRIBUTE18                   IN     VARCHAR2
  ,P_ATTRIBUTE19                   IN     VARCHAR2
  ,P_ATTRIBUTE20                   IN     VARCHAR2
  ,P_ATTRIBUTE21                   IN     VARCHAR2
  ,P_ATTRIBUTE22                   IN     VARCHAR2
  ,P_ATTRIBUTE23                   IN     VARCHAR2
  ,P_ATTRIBUTE24                   IN     VARCHAR2
  ,P_ATTRIBUTE25                   IN     VARCHAR2
  ,P_ATTRIBUTE26                   IN     VARCHAR2
  ,P_ATTRIBUTE27                   IN     VARCHAR2
  ,P_ATTRIBUTE28                   IN     VARCHAR2
  ,P_ATTRIBUTE29                   IN     VARCHAR2
  ,P_ATTRIBUTE30                   IN     VARCHAR2
  ,p_object_version_number         in     number
  ,P_EMP_STAT_SITUATION_ID         in     NUMBER
  );
--
end PQH_FR_EMP_STAT_SITUATION_BK2;

 

/
