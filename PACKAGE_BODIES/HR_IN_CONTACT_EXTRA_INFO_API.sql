--------------------------------------------------------
--  DDL for Package Body HR_IN_CONTACT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_CONTACT_EXTRA_INFO_API" AS
/* $Header: pereiini.pkb 115.0 2004/05/25 03:57 gaugupta noship $ */
g_package  VARCHAR2(33) := 'hr_in_contact_rel_api.';
g_trace boolean;

-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_contact_extra_info >----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE create_in_contact_extra_info
 (p_validate                    IN      boolean  default false,
  p_effective_date              IN      date,
  p_contact_relationship_id	IN	NUMBER,
  p_information_type		IN	VARCHAR2,
  p_nomination_type             IN	VARCHAR2,
  p_percent_share		IN	VARCHAR2,
  p_nomination_change_reason    IN	VARCHAR2	DEFAULT NULL,
  p_cei_attribute_category      IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute1              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute2              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute3              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute4              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute5              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute6              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute7              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute8              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute9              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute10             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute11             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute12             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute13             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute14             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute15             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute16             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute17             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute18             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute19             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute20             IN      VARCHAR2        DEFAULT NULL,
  p_contact_extra_info_id       OUT NOCOPY number,
  p_object_version_number       OUT NOCOPY number,
  p_effective_start_date        OUT NOCOPY DATE,
  p_effective_end_date	        OUT NOCOPY DATE
  )
AS
--
-- Declare cursors and local variables
--
  l_proc VARCHAR2(72);
BEGIN
  l_proc  := g_package||'create_in_contact_extra_info';
  g_trace := hr_utility.debug_enabled ;

  IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF ;

  hr_contact_extra_info_api.create_contact_extra_info(
  p_validate                    => p_validate,
  p_effective_date              => p_effective_date,
  p_contact_relationship_id	=> p_contact_relationship_id,
  p_information_type		=> P_information_type,
  p_cei_information_category	=> 'IN_NOMINATION_DETAILS',
  p_cei_information3		=> p_nomination_type,
  p_cei_information2		=> p_percent_share,
  p_cei_information4		=> p_nomination_change_reason ,
  p_cei_attribute_category      => p_cei_attribute_category,
  p_cei_attribute1              => p_cei_attribute1 ,
  p_cei_attribute2              => p_cei_attribute2,
  p_cei_attribute3              => p_cei_attribute3,
  p_cei_attribute4              => p_cei_attribute4,
  p_cei_attribute5              => p_cei_attribute5,
  p_cei_attribute6              => p_cei_attribute6,
  p_cei_attribute7              => p_cei_attribute7,
  p_cei_attribute8              => p_cei_attribute8,
  p_cei_attribute9              => p_cei_attribute9,
  p_cei_attribute10             => p_cei_attribute10,
  p_cei_attribute11             => p_cei_attribute11,
  p_cei_attribute12             => p_cei_attribute12,
  p_cei_attribute13             => p_cei_attribute13,
  p_cei_attribute14             => p_cei_attribute14,
  p_cei_attribute15             => p_cei_attribute15,
  p_cei_attribute16             => p_cei_attribute16,
  p_cei_attribute17             => p_cei_attribute17,
  p_cei_attribute18             => p_cei_attribute18,
  p_cei_attribute19             => p_cei_attribute19,
  p_cei_attribute20             => p_cei_attribute20,
  p_contact_extra_info_id       => p_contact_extra_info_id,
  p_object_version_number       => p_object_version_number,
  p_effective_start_date        => p_effective_start_date,
  p_effective_end_date	        => p_effective_end_date);

  if g_trace then
        hr_utility.set_location('Leaving: '||l_proc, 20);
  end if ;

END create_in_contact_extra_info;

-- ----------------------------------------------------------------------------
-- |-----------------------< update_in_contact_extra_info >----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE update_in_contact_extra_info
 (p_validate                    IN      boolean        DEFAULT false,
  p_effective_date              IN      date,
  p_datetrack_update_mode	IN	VARCHAR2,
  p_contact_relationship_id	IN	NUMBER          DEFAULT hr_api.g_number,
  p_information_type		IN	VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_nomination_type             IN	VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_percent_share		IN	VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_nomination_change_reason    IN	VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_cei_attribute_category      IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute1              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute2              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute3              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute4              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute5              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute6              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute7              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute8              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute9              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute10             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute11             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute12             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute13             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute14             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute15             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute16             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute17             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute18             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute19             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute20             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_contact_extra_info_id       IN      number,
  p_object_version_number       IN OUT NOCOPY number,
  p_effective_start_date        OUT NOCOPY DATE,
  p_effective_end_date	        OUT NOCOPY DATE
  )
AS
--
-- Declare cursors and local variables
--
  l_proc  VARCHAR2(72);
BEGIN
  l_proc  := g_package||'update_in_contact_extra_info';
  g_trace := hr_utility.debug_enabled ;

  if g_trace then
    hr_utility.set_location('Entering: '||l_proc, 10);
  end if ;

  hr_contact_extra_info_api.update_contact_extra_info(
  p_validate                    => p_validate,
  p_effective_date              => p_effective_date,
  p_contact_relationship_id	=> p_contact_relationship_id,
  p_datetrack_update_mode       => p_datetrack_update_mode,
  p_information_type		=> p_information_type,
  p_cei_information_category	=> 'IN_NOMINATION_DETAILS',
  p_cei_information3		=> p_nomination_type,
  p_cei_information2		=> p_percent_share,
  p_cei_information4		=> p_nomination_change_reason ,
  p_cei_attribute_category      => p_cei_attribute_category,
  p_cei_attribute1              => p_cei_attribute1 ,
  p_cei_attribute2              => p_cei_attribute2,
  p_cei_attribute3              => p_cei_attribute3,
  p_cei_attribute4              => p_cei_attribute4,
  p_cei_attribute5              => p_cei_attribute5,
  p_cei_attribute6              => p_cei_attribute6,
  p_cei_attribute7              => p_cei_attribute7,
  p_cei_attribute8              => p_cei_attribute8,
  p_cei_attribute9              => p_cei_attribute9,
  p_cei_attribute10             => p_cei_attribute10,
  p_cei_attribute11             => p_cei_attribute11,
  p_cei_attribute12             => p_cei_attribute12,
  p_cei_attribute13             => p_cei_attribute13,
  p_cei_attribute14             => p_cei_attribute14,
  p_cei_attribute15             => p_cei_attribute15,
  p_cei_attribute16             => p_cei_attribute16,
  p_cei_attribute17             => p_cei_attribute17,
  p_cei_attribute18             => p_cei_attribute18,
  p_cei_attribute19             => p_cei_attribute19,
  p_cei_attribute20             => p_cei_attribute20,
  p_contact_extra_info_id       => p_contact_extra_info_id,
  p_object_version_number       => p_object_version_number,
  p_effective_start_date        => p_effective_start_date,
  p_effective_end_date	        => p_effective_end_date);
  if g_trace then
        hr_utility.set_location('Leaving: '||l_proc, 20);
  end if ;
END update_in_contact_extra_info;
END hr_in_contact_extra_info_api;

/
