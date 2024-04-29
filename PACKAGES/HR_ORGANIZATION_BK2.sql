--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION_BK2" AUTHID CURRENT_USER as
/* $Header: hrorgapi.pkh 120.13.12010000.4 2009/04/14 09:46:26 sathkris ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_org_information >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_org_information_b
  (p_effective_date                 IN  DATE
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2
  ,p_org_information2               IN  VARCHAR2
  ,p_org_information3               IN  VARCHAR2
  ,p_org_information4               IN  VARCHAR2
  ,p_org_information5               IN  VARCHAR2
  ,p_org_information6               IN  VARCHAR2
  ,p_org_information7               IN  VARCHAR2
  ,p_org_information8               IN  VARCHAR2
  ,p_org_information9               IN  VARCHAR2
  ,p_org_information10              IN  VARCHAR2
  ,p_org_information11              IN  VARCHAR2
  ,p_org_information12              IN  VARCHAR2
  ,p_org_information13              IN  VARCHAR2
  ,p_org_information14              IN  VARCHAR2
  ,p_org_information15              IN  VARCHAR2
  ,p_org_information16              IN  VARCHAR2
  ,p_org_information17              IN  VARCHAR2
  ,p_org_information18              IN  VARCHAR2
  ,p_org_information19              IN  VARCHAR2
  ,p_org_information20              IN  VARCHAR2
  ,p_org_information_id             IN  NUMBER
  ,p_attribute_category             IN  VARCHAR2
  ,p_attribute1                     IN  VARCHAR2
  ,p_attribute2                     IN  VARCHAR2
  ,p_attribute3                     IN  VARCHAR2
  ,p_attribute4                     IN  VARCHAR2
  ,p_attribute5                     IN  VARCHAR2
  ,p_attribute6                     IN  VARCHAR2
  ,p_attribute7                     IN  VARCHAR2
  ,p_attribute8                     IN  VARCHAR2
  ,p_attribute9                     IN  VARCHAR2
  ,p_attribute10                    IN  VARCHAR2
  ,p_attribute11                    IN  VARCHAR2
  ,p_attribute12                    IN  VARCHAR2
  ,p_attribute13                    IN  VARCHAR2
  ,p_attribute14                    IN  VARCHAR2
  ,p_attribute15                    IN  VARCHAR2
  ,p_attribute16                    IN  VARCHAR2
  ,p_attribute17                    IN  VARCHAR2
  ,p_attribute18                    IN  VARCHAR2
  ,p_attribute19                    IN  VARCHAR2
  ,p_attribute20                    IN  VARCHAR2
  ,p_object_version_number          IN  NUMBER
  );


procedure update_org_information_a
  (p_effective_date                 IN  DATE
  ,p_org_info_type_code             IN  VARCHAR2
  ,p_org_information1               IN  VARCHAR2
  ,p_org_information2               IN  VARCHAR2
  ,p_org_information3               IN  VARCHAR2
  ,p_org_information4               IN  VARCHAR2
  ,p_org_information5               IN  VARCHAR2
  ,p_org_information6               IN  VARCHAR2
  ,p_org_information7               IN  VARCHAR2
  ,p_org_information8               IN  VARCHAR2
  ,p_org_information9               IN  VARCHAR2
  ,p_org_information10              IN  VARCHAR2
  ,p_org_information11              IN  VARCHAR2
  ,p_org_information12              IN  VARCHAR2
  ,p_org_information13              IN  VARCHAR2
  ,p_org_information14              IN  VARCHAR2
  ,p_org_information15              IN  VARCHAR2
  ,p_org_information16              IN  VARCHAR2
  ,p_org_information17              IN  VARCHAR2
  ,p_org_information18              IN  VARCHAR2
  ,p_org_information19              IN  VARCHAR2
  ,p_org_information20              IN  VARCHAR2
  ,p_org_information_id             IN  NUMBER
  ,p_attribute_category             IN  VARCHAR2
  ,p_attribute1                     IN  VARCHAR2
  ,p_attribute2                     IN  VARCHAR2
  ,p_attribute3                     IN  VARCHAR2
  ,p_attribute4                     IN  VARCHAR2
  ,p_attribute5                     IN  VARCHAR2
  ,p_attribute6                     IN  VARCHAR2
  ,p_attribute7                     IN  VARCHAR2
  ,p_attribute8                     IN  VARCHAR2
  ,p_attribute9                     IN  VARCHAR2
  ,p_attribute10                    IN  VARCHAR2
  ,p_attribute11                    IN  VARCHAR2
  ,p_attribute12                    IN  VARCHAR2
  ,p_attribute13                    IN  VARCHAR2
  ,p_attribute14                    IN  VARCHAR2
  ,p_attribute15                    IN  VARCHAR2
  ,p_attribute16                    IN  VARCHAR2
  ,p_attribute17                    IN  VARCHAR2
  ,p_attribute18                    IN  VARCHAR2
  ,p_attribute19                    IN  VARCHAR2
  ,p_attribute20                    IN  VARCHAR2
  ,p_object_version_number          IN  NUMBER
  );
  --
end hr_organization_bk2;

/
