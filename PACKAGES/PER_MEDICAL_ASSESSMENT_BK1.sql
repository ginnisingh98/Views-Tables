--------------------------------------------------------
--  DDL for Package PER_MEDICAL_ASSESSMENT_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MEDICAL_ASSESSMENT_BK1" AUTHID CURRENT_USER AS
/* $Header: pemeaapi.pkh 120.2 2005/10/22 01:23:54 aroussel noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_medical_assessment_b >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_medical_assessment_b
  (p_effective_date                IN     DATE
  ,p_person_id                     IN     NUMBER
  ,p_consultation_date             IN     DATE
  ,p_consultation_type             IN     VARCHAR2
  ,p_examiner_name                 IN     VARCHAR2
  ,p_organization_id               IN     NUMBER
  ,p_consultation_result           IN     VARCHAR2
  ,p_incident_id                   IN     NUMBER
  ,p_disability_id                 IN     NUMBER
  ,p_next_consultation_date        IN     DATE
  ,p_description                   IN     VARCHAR2
  ,p_attribute_category            IN     VARCHAR2
  ,p_attribute1                    IN     VARCHAR2
  ,p_attribute2                    IN     VARCHAR2
  ,p_attribute3                    IN     VARCHAR2
  ,p_attribute4                    IN     VARCHAR2
  ,p_attribute5                    IN     VARCHAR2
  ,p_attribute6                    IN     VARCHAR2
  ,p_attribute7                    IN     VARCHAR2
  ,p_attribute8                    IN     VARCHAR2
  ,p_attribute9                    IN     VARCHAR2
  ,p_attribute10                   IN     VARCHAR2
  ,p_attribute11                   IN     VARCHAR2
  ,p_attribute12                   IN     VARCHAR2
  ,p_attribute13                   IN     VARCHAR2
  ,p_attribute14                   IN     VARCHAR2
  ,p_attribute15                   IN     VARCHAR2
  ,p_attribute16                   IN     VARCHAR2
  ,p_attribute17                   IN     VARCHAR2
  ,p_attribute18                   IN     VARCHAR2
  ,p_attribute19                   IN     VARCHAR2
  ,p_attribute20                   IN     VARCHAR2
  ,p_attribute21                   IN     VARCHAR2
  ,p_attribute22                   IN     VARCHAR2
  ,p_attribute23                   IN     VARCHAR2
  ,p_attribute24                   IN     VARCHAR2
  ,p_attribute25                   IN     VARCHAR2
  ,p_attribute26                   IN     VARCHAR2
  ,p_attribute27                   IN     VARCHAR2
  ,p_attribute28                   IN     VARCHAR2
  ,p_attribute29                   IN     VARCHAR2
  ,p_attribute30                   IN     VARCHAR2
  ,p_mea_information_category      IN     VARCHAR2
  ,p_mea_information1              IN     VARCHAR2
  ,p_mea_information2              IN     VARCHAR2
  ,p_mea_information3              IN     VARCHAR2
  ,p_mea_information4              IN     VARCHAR2
  ,p_mea_information5              IN     VARCHAR2
  ,p_mea_information6              IN     VARCHAR2
  ,p_mea_information7              IN     VARCHAR2
  ,p_mea_information8              IN     VARCHAR2
  ,p_mea_information9              IN     VARCHAR2
  ,p_mea_information10             IN     VARCHAR2
  ,p_mea_information11             IN     VARCHAR2
  ,p_mea_information12             IN     VARCHAR2
  ,p_mea_information13             IN     VARCHAR2
  ,p_mea_information14             IN     VARCHAR2
  ,p_mea_information15             IN     VARCHAR2
  ,p_mea_information16             IN     VARCHAR2
  ,p_mea_information17             IN     VARCHAR2
  ,p_mea_information18             IN     VARCHAR2
  ,p_mea_information19             IN     VARCHAR2
  ,p_mea_information20             IN     VARCHAR2
  ,p_mea_information21             IN     VARCHAR2
  ,p_mea_information22             IN     VARCHAR2
  ,p_mea_information23             IN     VARCHAR2
  ,p_mea_information24             IN     VARCHAR2
  ,p_mea_information25             IN     VARCHAR2
  ,p_mea_information26             IN     VARCHAR2
  ,p_mea_information27             IN     VARCHAR2
  ,p_mea_information28             IN     VARCHAR2
  ,p_mea_information29             IN     VARCHAR2
  ,p_mea_information30             IN     VARCHAR2 );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_medical_assessment_a >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_medical_assessment_a
  (p_medical_assessment_id         IN     NUMBER
  ,p_object_version_number         IN     NUMBER
  ,p_effective_date                IN     DATE
  ,p_person_id                     IN     NUMBER
  ,p_consultation_date             IN     DATE
  ,p_consultation_type             IN     VARCHAR2
  ,p_examiner_name                 IN     VARCHAR2
  ,p_organization_id               IN     NUMBER
  ,p_consultation_result           IN     VARCHAR2
  ,p_incident_id                   IN     NUMBER
  ,p_disability_id                 IN     NUMBER
  ,p_next_consultation_date        IN     DATE
  ,p_description                   IN     VARCHAR2
  ,p_attribute_category            IN     VARCHAR2
  ,p_attribute1                    IN     VARCHAR2
  ,p_attribute2                    IN     VARCHAR2
  ,p_attribute3                    IN     VARCHAR2
  ,p_attribute4                    IN     VARCHAR2
  ,p_attribute5                    IN     VARCHAR2
  ,p_attribute6                    IN     VARCHAR2
  ,p_attribute7                    IN     VARCHAR2
  ,p_attribute8                    IN     VARCHAR2
  ,p_attribute9                    IN     VARCHAR2
  ,p_attribute10                   IN     VARCHAR2
  ,p_attribute11                   IN     VARCHAR2
  ,p_attribute12                   IN     VARCHAR2
  ,p_attribute13                   IN     VARCHAR2
  ,p_attribute14                   IN     VARCHAR2
  ,p_attribute15                   IN     VARCHAR2
  ,p_attribute16                   IN     VARCHAR2
  ,p_attribute17                   IN     VARCHAR2
  ,p_attribute18                   IN     VARCHAR2
  ,p_attribute19                   IN     VARCHAR2
  ,p_attribute20                   IN     VARCHAR2
  ,p_attribute21                   IN     VARCHAR2
  ,p_attribute22                   IN     VARCHAR2
  ,p_attribute23                   IN     VARCHAR2
  ,p_attribute24                   IN     VARCHAR2
  ,p_attribute25                   IN     VARCHAR2
  ,p_attribute26                   IN     VARCHAR2
  ,p_attribute27                   IN     VARCHAR2
  ,p_attribute28                   IN     VARCHAR2
  ,p_attribute29                   IN     VARCHAR2
  ,p_attribute30                   IN     VARCHAR2
  ,p_mea_information_category      IN     VARCHAR2
  ,p_mea_information1              IN     VARCHAR2
  ,p_mea_information2              IN     VARCHAR2
  ,p_mea_information3              IN     VARCHAR2
  ,p_mea_information4              IN     VARCHAR2
  ,p_mea_information5              IN     VARCHAR2
  ,p_mea_information6              IN     VARCHAR2
  ,p_mea_information7              IN     VARCHAR2
  ,p_mea_information8              IN     VARCHAR2
  ,p_mea_information9              IN     VARCHAR2
  ,p_mea_information10             IN     VARCHAR2
  ,p_mea_information11             IN     VARCHAR2
  ,p_mea_information12             IN     VARCHAR2
  ,p_mea_information13             IN     VARCHAR2
  ,p_mea_information14             IN     VARCHAR2
  ,p_mea_information15             IN     VARCHAR2
  ,p_mea_information16             IN     VARCHAR2
  ,p_mea_information17             IN     VARCHAR2
  ,p_mea_information18             IN     VARCHAR2
  ,p_mea_information19             IN     VARCHAR2
  ,p_mea_information20             IN     VARCHAR2
  ,p_mea_information21             IN     VARCHAR2
  ,p_mea_information22             IN     VARCHAR2
  ,p_mea_information23             IN     VARCHAR2
  ,p_mea_information24             IN     VARCHAR2
  ,p_mea_information25             IN     VARCHAR2
  ,p_mea_information26             IN     VARCHAR2
  ,p_mea_information27             IN     VARCHAR2
  ,p_mea_information28             IN     VARCHAR2
  ,p_mea_information29             IN     VARCHAR2
  ,p_mea_information30             IN     VARCHAR2 );
--
END per_medical_assessment_bk1;

 

/
