--------------------------------------------------------
--  DDL for Package HR_CONTACT_EXTRA_INFO_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTACT_EXTRA_INFO_BK2" AUTHID CURRENT_USER as
/* $Header: pereiapi.pkh 120.1 2005/10/02 02:23:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_contact_extra_info_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_contact_extra_info_b
  (p_effective_date                in     date,
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number
  p_datetrack_update_mode	IN	VARCHAR2,
  p_contact_extra_info_id	IN	NUMBER,
  p_contact_relationship_id	IN	NUMBER,
  p_information_type		IN	VARCHAR2,
  p_cei_information_category    IN      VARCHAR2,
  p_cei_information1            IN      VARCHAR2,
  p_cei_information2            IN      VARCHAR2,
  p_cei_information3            IN      VARCHAR2,
  p_cei_information4            IN      VARCHAR2,
  p_cei_information5            IN      VARCHAR2,
  p_cei_information6            IN      VARCHAR2,
  p_cei_information7            IN      VARCHAR2,
  p_cei_information8            IN      VARCHAR2,
  p_cei_information9            IN      VARCHAR2,
  p_cei_information10           IN      VARCHAR2,
  p_cei_information11           IN      VARCHAR2,
  p_cei_information12           IN      VARCHAR2,
  p_cei_information13           IN      VARCHAR2,
  p_cei_information14           IN      VARCHAR2,
  p_cei_information15           IN      VARCHAR2,
  p_cei_information16           IN      VARCHAR2,
  p_cei_information17           IN      VARCHAR2,
  p_cei_information18           IN      VARCHAR2,
  p_cei_information19           IN      VARCHAR2,
  p_cei_information20           IN      VARCHAR2,
  p_cei_information21           IN      VARCHAR2,
  p_cei_information22           IN      VARCHAR2,
  p_cei_information23           IN      VARCHAR2,
  p_cei_information24           IN      VARCHAR2,
  p_cei_information25           IN      VARCHAR2,
  p_cei_information26           IN      VARCHAR2,
  p_cei_information27           IN      VARCHAR2,
  p_cei_information28           IN      VARCHAR2,
  p_cei_information29           IN      VARCHAR2,
  p_cei_information30           IN      VARCHAR2,
  p_cei_attribute_category      IN      VARCHAR2,
  p_cei_attribute1              IN      VARCHAR2,
  p_cei_attribute2              IN      VARCHAR2,
  p_cei_attribute3              IN      VARCHAR2,
  p_cei_attribute4              IN      VARCHAR2,
  p_cei_attribute5              IN      VARCHAR2,
  p_cei_attribute6              IN      VARCHAR2,
  p_cei_attribute7              IN      VARCHAR2,
  p_cei_attribute8              IN      VARCHAR2,
  p_cei_attribute9              IN      VARCHAR2,
  p_cei_attribute10             IN      VARCHAR2,
  p_cei_attribute11             IN      VARCHAR2,
  p_cei_attribute12             IN      VARCHAR2,
  p_cei_attribute13             IN      VARCHAR2,
  p_cei_attribute14             IN      VARCHAR2,
  p_cei_attribute15             IN      VARCHAR2,
  p_cei_attribute16             IN      VARCHAR2,
  p_cei_attribute17             IN      VARCHAR2,
  p_cei_attribute18             IN      VARCHAR2,
  p_cei_attribute19             IN      VARCHAR2,
  p_cei_attribute20             IN      VARCHAR2,
  p_object_version_number	IN	NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_contact_extra_info_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_contact_extra_info_a
  (p_effective_date                in     date
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number
  ,p_contact_extra_info_id         in     number,
  p_contact_relationship_id	IN	NUMBER,
  p_information_type		IN	VARCHAR2
  ,p_object_version_number         in     number,
--  ,p_some_warning                  in     boolean
  p_datetrack_update_mode	IN	VARCHAR2,
  p_cei_information_category    IN      VARCHAR2,
  p_cei_information1            IN      VARCHAR2,
  p_cei_information2            IN      VARCHAR2,
  p_cei_information3            IN      VARCHAR2,
  p_cei_information4            IN      VARCHAR2,
  p_cei_information5            IN      VARCHAR2,
  p_cei_information6            IN      VARCHAR2,
  p_cei_information7            IN      VARCHAR2,
  p_cei_information8            IN      VARCHAR2,
  p_cei_information9            IN      VARCHAR2,
  p_cei_information10           IN      VARCHAR2,
  p_cei_information11           IN      VARCHAR2,
  p_cei_information12           IN      VARCHAR2,
  p_cei_information13           IN      VARCHAR2,
  p_cei_information14           IN      VARCHAR2,
  p_cei_information15           IN      VARCHAR2,
  p_cei_information16           IN      VARCHAR2,
  p_cei_information17           IN      VARCHAR2,
  p_cei_information18           IN      VARCHAR2,
  p_cei_information19           IN      VARCHAR2,
  p_cei_information20           IN      VARCHAR2,
  p_cei_information21           IN      VARCHAR2,
  p_cei_information22           IN      VARCHAR2,
  p_cei_information23           IN      VARCHAR2,
  p_cei_information24           IN      VARCHAR2,
  p_cei_information25           IN      VARCHAR2,
  p_cei_information26           IN      VARCHAR2,
  p_cei_information27           IN      VARCHAR2,
  p_cei_information28           IN      VARCHAR2,
  p_cei_information29           IN      VARCHAR2,
  p_cei_information30           IN      VARCHAR2,
  p_cei_attribute_category      IN      VARCHAR2,
  p_cei_attribute1              IN      VARCHAR2,
  p_cei_attribute2              IN      VARCHAR2,
  p_cei_attribute3              IN      VARCHAR2,
  p_cei_attribute4              IN      VARCHAR2,
  p_cei_attribute5              IN      VARCHAR2,
  p_cei_attribute6              IN      VARCHAR2,
  p_cei_attribute7              IN      VARCHAR2,
  p_cei_attribute8              IN      VARCHAR2,
  p_cei_attribute9              IN      VARCHAR2,
  p_cei_attribute10             IN      VARCHAR2,
  p_cei_attribute11             IN      VARCHAR2,
  p_cei_attribute12             IN      VARCHAR2,
  p_cei_attribute13             IN      VARCHAR2,
  p_cei_attribute14             IN      VARCHAR2,
  p_cei_attribute15             IN      VARCHAR2,
  p_cei_attribute16             IN      VARCHAR2,
  p_cei_attribute17             IN      VARCHAR2,
  p_cei_attribute18             IN      VARCHAR2,
  p_cei_attribute19             IN      VARCHAR2,
  p_cei_attribute20             IN      VARCHAR2
  );
--
end hr_contact_extra_info_bk2;

 

/
