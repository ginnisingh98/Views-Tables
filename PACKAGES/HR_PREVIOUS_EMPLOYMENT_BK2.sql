--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_BK2" AUTHID CURRENT_USER as
/* $Header: pepemapi.pkh 120.1.12010000.1 2008/07/28 05:11:13 appldev ship $ */
--
-- -----------------------------------------------------------------------
-- |----------------------< update_previous_employer_b >-----------------|
-- -----------------------------------------------------------------------
--
procedure update_previous_employer_b
(  p_effective_date               IN    date
  ,p_previous_employer_id         IN    number
  ,p_start_date                   IN    date
  ,p_end_date                     IN    date
  ,p_period_years                 IN    number
  ,p_period_months                IN    number
  ,p_period_days                  IN    number
  ,p_employer_name                IN    varchar2
  ,p_employer_country             IN    varchar2
  ,p_employer_address             IN    varchar2
  ,p_employer_type                IN    varchar2
  ,p_employer_subtype             IN    varchar2
  ,p_description                  IN    varchar2
  ,p_all_assignments              IN    varchar2
  ,p_pem_attribute_category       IN    varchar2
  ,p_pem_attribute1               IN    varchar2
  ,p_pem_attribute2               IN    varchar2
  ,p_pem_attribute3               IN    varchar2
  ,p_pem_attribute4               IN    varchar2
  ,p_pem_attribute5               IN    varchar2
  ,p_pem_attribute6               IN    varchar2
  ,p_pem_attribute7               IN    varchar2
  ,p_pem_attribute8               IN    varchar2
  ,p_pem_attribute9               IN    varchar2
  ,p_pem_attribute10              IN    varchar2
  ,p_pem_attribute11              IN    varchar2
  ,p_pem_attribute12              IN    varchar2
  ,p_pem_attribute13              IN    varchar2
  ,p_pem_attribute14              IN    varchar2
  ,p_pem_attribute15              IN    varchar2
  ,p_pem_attribute16              IN    varchar2
  ,p_pem_attribute17              IN    varchar2
  ,p_pem_attribute18              IN    varchar2
  ,p_pem_attribute19              IN    varchar2
  ,p_pem_attribute20              IN    varchar2
  ,p_pem_attribute21              IN    varchar2
  ,p_pem_attribute22              IN    varchar2
  ,p_pem_attribute23              IN    varchar2
  ,p_pem_attribute24              IN    varchar2
  ,p_pem_attribute25              IN    varchar2
  ,p_pem_attribute26              IN    varchar2
  ,p_pem_attribute27              IN    varchar2
  ,p_pem_attribute28              IN    varchar2
  ,p_pem_attribute29              IN    varchar2
  ,p_pem_attribute30              IN    varchar2
  ,p_pem_information_category     IN    varchar2
  ,p_pem_information1             IN    varchar2
  ,p_pem_information2             IN    varchar2
  ,p_pem_information3             IN    varchar2
  ,p_pem_information4             IN    varchar2
  ,p_pem_information5             IN    varchar2
  ,p_pem_information6             IN    varchar2
  ,p_pem_information7             IN    varchar2
  ,p_pem_information8             IN    varchar2
  ,p_pem_information9             IN    varchar2
  ,p_pem_information10            IN    varchar2
  ,p_pem_information11            IN    varchar2
  ,p_pem_information12            IN    varchar2
  ,p_pem_information13            IN    varchar2
  ,p_pem_information14            IN    varchar2
  ,p_pem_information15            IN    varchar2
  ,p_pem_information16            IN    varchar2
  ,p_pem_information17            IN    varchar2
  ,p_pem_information18            IN    varchar2
  ,p_pem_information19            IN    varchar2
  ,p_pem_information20            IN    varchar2
  ,p_pem_information21            IN    varchar2
  ,p_pem_information22            IN    varchar2
  ,p_pem_information23            IN    varchar2
  ,p_pem_information24            IN    varchar2
  ,p_pem_information25            IN    varchar2
  ,p_pem_information26            IN    varchar2
  ,p_pem_information27            IN    varchar2
  ,p_pem_information28            IN    varchar2
  ,p_pem_information29            IN    varchar2
  ,p_pem_information30            IN    varchar2
  ,p_object_version_number        IN    number
  );
--
-- ------------------------------------------------------------------------
-- |----------------------< update_previous_employer_a >------------------|
-- ------------------------------------------------------------------------
--
procedure update_previous_employer_a
(  p_effective_date             IN    date
  ,p_previous_employer_id       IN    number
  ,p_start_date                 IN    date
  ,p_end_date                   IN    date
  ,p_period_years               IN    number
  ,p_period_months              IN    number
  ,p_period_days                IN    number
  ,p_employer_name              IN    varchar2
  ,p_employer_country           IN    varchar2
  ,p_employer_address           IN    varchar2
  ,p_employer_type              IN    varchar2
  ,p_employer_subtype           IN    varchar2
  ,p_description                IN    varchar2
  ,p_all_assignments            IN    varchar2
  ,p_pem_attribute_category     IN    varchar2
  ,p_pem_attribute1             IN    varchar2
  ,p_pem_attribute2             IN    varchar2
  ,p_pem_attribute3             IN    varchar2
  ,p_pem_attribute4             IN    varchar2
  ,p_pem_attribute5             IN    varchar2
  ,p_pem_attribute6             IN    varchar2
  ,p_pem_attribute7             IN    varchar2
  ,p_pem_attribute8             IN    varchar2
  ,p_pem_attribute9             IN    varchar2
  ,p_pem_attribute10            IN    varchar2
  ,p_pem_attribute11            IN    varchar2
  ,p_pem_attribute12            IN    varchar2
  ,p_pem_attribute13            IN    varchar2
  ,p_pem_attribute14            IN    varchar2
  ,p_pem_attribute15            IN    varchar2
  ,p_pem_attribute16            IN    varchar2
  ,p_pem_attribute17            IN    varchar2
  ,p_pem_attribute18            IN    varchar2
  ,p_pem_attribute19            IN    varchar2
  ,p_pem_attribute20            IN    varchar2
  ,p_pem_attribute21            IN    varchar2
  ,p_pem_attribute22            IN    varchar2
  ,p_pem_attribute23            IN    varchar2
  ,p_pem_attribute24            IN    varchar2
  ,p_pem_attribute25            IN    varchar2
  ,p_pem_attribute26            IN    varchar2
  ,p_pem_attribute27            IN    varchar2
  ,p_pem_attribute28            IN    varchar2
  ,p_pem_attribute29            IN    varchar2
  ,p_pem_attribute30            IN    varchar2
  ,p_pem_information_category   IN    varchar2
  ,p_pem_information1           IN    varchar2
  ,p_pem_information2           IN    varchar2
  ,p_pem_information3           IN    varchar2
  ,p_pem_information4           IN    varchar2
  ,p_pem_information5           IN    varchar2
  ,p_pem_information6           IN    varchar2
  ,p_pem_information7           IN    varchar2
  ,p_pem_information8           IN    varchar2
  ,p_pem_information9           IN    varchar2
  ,p_pem_information10          IN    varchar2
  ,p_pem_information11          IN    varchar2
  ,p_pem_information12          IN    varchar2
  ,p_pem_information13          IN    varchar2
  ,p_pem_information14          IN    varchar2
  ,p_pem_information15          IN    varchar2
  ,p_pem_information16          IN    varchar2
  ,p_pem_information17          IN    varchar2
  ,p_pem_information18          IN    varchar2
  ,p_pem_information19          IN    varchar2
  ,p_pem_information20          IN    varchar2
  ,p_pem_information21          IN    varchar2
  ,p_pem_information22          IN    varchar2
  ,p_pem_information23          IN    varchar2
  ,p_pem_information24          IN    varchar2
  ,p_pem_information25          IN    varchar2
  ,p_pem_information26          IN    varchar2
  ,p_pem_information27          IN    varchar2
  ,p_pem_information28          IN    varchar2
  ,p_pem_information29          IN    varchar2
  ,p_pem_information30          IN    varchar2
  ,p_object_version_number      IN    number
  );
--
end hr_previous_employment_bk2;

/
