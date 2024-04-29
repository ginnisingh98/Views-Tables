--------------------------------------------------------
--  DDL for Package IRC_PARTY_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_PARTY_BK5" AUTHID CURRENT_USER as
/* $Header: irhzpapi.pkh 120.15.12010000.5 2010/04/16 14:57:54 vmummidi ship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_CANDIDATE_INTERNAL_B >------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_CANDIDATE_INTERNAL_B
  (
    p_business_group_id         IN     number
   ,p_last_name                 IN     varchar2
   ,p_first_name                IN     varchar2
   ,p_date_of_birth             IN     date
   ,p_title                     IN     varchar2
   ,p_email_address             IN     varchar2
   ,p_gender                    IN     varchar2
   ,p_marital_status            IN     varchar2
   ,p_previous_last_name        IN     varchar2
   ,p_middle_name               IN     varchar2
   ,p_name_suffix               IN     varchar2
   ,p_known_as                  IN     varchar2
   ,p_first_name_phonetic       IN     varchar2
   ,p_last_name_phonetic        IN     varchar2
   ,p_attribute_category        IN     varchar2
   ,p_attribute1                IN     varchar2
   ,p_attribute2                IN     varchar2
   ,p_attribute3                IN     varchar2
   ,p_attribute4                IN     varchar2
   ,p_attribute5                IN     varchar2
   ,p_attribute6                IN     varchar2
   ,p_attribute7                IN     varchar2
   ,p_attribute8                IN     varchar2
   ,p_attribute9                IN     varchar2
   ,p_attribute10               IN     varchar2
   ,p_attribute11               IN     varchar2
   ,p_attribute12               IN     varchar2
   ,p_attribute13               IN     varchar2
   ,p_attribute14               IN     varchar2
   ,p_attribute15               IN     varchar2
   ,p_attribute16               IN     varchar2
   ,p_attribute17               IN     varchar2
   ,p_attribute18               IN     varchar2
   ,p_attribute19               IN     varchar2
   ,p_attribute20               IN     varchar2
   ,p_attribute21               IN     varchar2
   ,p_attribute22               IN     varchar2
   ,p_attribute23               IN     varchar2
   ,p_attribute24               IN     varchar2
   ,p_attribute25               IN     varchar2
   ,p_attribute26               IN     varchar2
   ,p_attribute27               IN     varchar2
   ,p_attribute28               IN     varchar2
   ,p_attribute29               IN     varchar2
   ,p_attribute30               IN     varchar2
   ,p_per_information_category  IN     varchar2
   ,p_per_information1          IN     varchar2
   ,p_per_information2          IN     varchar2
   ,p_per_information3          IN     varchar2
   ,p_per_information4          IN     varchar2
   ,p_per_information5          IN     varchar2
   ,p_per_information6          IN     varchar2
   ,p_per_information7          IN     varchar2
   ,p_per_information8          IN     varchar2
   ,p_per_information9          IN     varchar2
   ,p_per_information10         IN     varchar2
   ,p_per_information11         IN     varchar2
   ,p_per_information12         IN     varchar2
   ,p_per_information13         IN     varchar2
   ,p_per_information14         IN     varchar2
   ,p_per_information15         IN     varchar2
   ,p_per_information16         IN     varchar2
   ,p_per_information17         IN     varchar2
   ,p_per_information18         IN     varchar2
   ,p_per_information19         IN     varchar2
   ,p_per_information20         IN     varchar2
   ,p_per_information21         IN     varchar2
   ,p_per_information22         IN     varchar2
   ,p_per_information23         IN     varchar2
   ,p_per_information24         IN     varchar2
   ,p_per_information25         IN     varchar2
   ,p_per_information26         IN     varchar2
   ,p_per_information27         IN     varchar2
   ,p_per_information28         IN     varchar2
   ,p_per_information29         IN     varchar2
   ,p_per_information30         IN     varchar2
   ,p_nationality               IN     varchar2
   ,p_national_identifier       IN     varchar2
   ,p_town_of_birth             IN     varchar2
   ,p_region_of_birth           IN     varchar2
   ,p_country_of_birth          IN     varchar2
   ,p_allow_access              IN     varchar2
   ,p_start_date                IN     date
   ,p_party_id                  IN     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_CANDIDATE_INTERNAL_A >------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_CANDIDATE_INTERNAL_A
  (
    p_business_group_id         IN     number
   ,p_last_name                 IN     varchar2
   ,p_first_name                IN     varchar2
   ,p_date_of_birth             IN     date
   ,p_email_address             IN     varchar2
   ,p_title                     IN     varchar2
   ,p_gender                    IN     varchar2
   ,p_marital_status            IN     varchar2
   ,p_previous_last_name        IN     varchar2
   ,p_middle_name               IN     varchar2
   ,p_name_suffix               IN     varchar2
   ,p_known_as                  IN     varchar2
   ,p_first_name_phonetic       IN     varchar2
   ,p_last_name_phonetic        IN     varchar2
   ,p_attribute_category        IN     varchar2
   ,p_attribute1                IN     varchar2
   ,p_attribute2                IN     varchar2
   ,p_attribute3                IN     varchar2
   ,p_attribute4                IN     varchar2
   ,p_attribute5                IN     varchar2
   ,p_attribute6                IN     varchar2
   ,p_attribute7                IN     varchar2
   ,p_attribute8                IN     varchar2
   ,p_attribute9                IN     varchar2
   ,p_attribute10               IN     varchar2
   ,p_attribute11               IN     varchar2
   ,p_attribute12               IN     varchar2
   ,p_attribute13               IN     varchar2
   ,p_attribute14               IN     varchar2
   ,p_attribute15               IN     varchar2
   ,p_attribute16               IN     varchar2
   ,p_attribute17               IN     varchar2
   ,p_attribute18               IN     varchar2
   ,p_attribute19               IN     varchar2
   ,p_attribute20               IN     varchar2
   ,p_attribute21               IN     varchar2
   ,p_attribute22               IN     varchar2
   ,p_attribute23               IN     varchar2
   ,p_attribute24               IN     varchar2
   ,p_attribute25               IN     varchar2
   ,p_attribute26               IN     varchar2
   ,p_attribute27               IN     varchar2
   ,p_attribute28               IN     varchar2
   ,p_attribute29               IN     varchar2
   ,p_attribute30               IN     varchar2
   ,p_per_information_category  IN     varchar2
   ,p_per_information1          IN     varchar2
   ,p_per_information2          IN     varchar2
   ,p_per_information3          IN     varchar2
   ,p_per_information4          IN     varchar2
   ,p_per_information5          IN     varchar2
   ,p_per_information6          IN     varchar2
   ,p_per_information7          IN     varchar2
   ,p_per_information8          IN     varchar2
   ,p_per_information9          IN     varchar2
   ,p_per_information10         IN     varchar2
   ,p_per_information11         IN     varchar2
   ,p_per_information12         IN     varchar2
   ,p_per_information13         IN     varchar2
   ,p_per_information14         IN     varchar2
   ,p_per_information15         IN     varchar2
   ,p_per_information16         IN     varchar2
   ,p_per_information17         IN     varchar2
   ,p_per_information18         IN     varchar2
   ,p_per_information19         IN     varchar2
   ,p_per_information20         IN     varchar2
   ,p_per_information21         IN     varchar2
   ,p_per_information22         IN     varchar2
   ,p_per_information23         IN     varchar2
   ,p_per_information24         IN     varchar2
   ,p_per_information25         IN     varchar2
   ,p_per_information26         IN     varchar2
   ,p_per_information27         IN     varchar2
   ,p_per_information28         IN     varchar2
   ,p_per_information29         IN     varchar2
   ,p_per_information30         IN     varchar2
   ,p_nationality               IN     varchar2
   ,p_national_identifier       IN     varchar2
   ,p_town_of_birth             IN     varchar2
   ,p_region_of_birth           IN     varchar2
   ,p_country_of_birth          IN     varchar2
   ,p_person_id                 IN     number
   ,p_effective_start_date      IN     date
   ,p_effective_end_date        IN     date
   ,p_allow_access              IN     varchar2
   ,p_start_date                IN     date
   ,p_party_id                  IN     varchar2
  );
end IRC_PARTY_BK5;

/
