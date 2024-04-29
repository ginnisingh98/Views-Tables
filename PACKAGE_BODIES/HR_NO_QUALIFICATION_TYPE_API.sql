--------------------------------------------------------
--  DDL for Package Body HR_NO_QUALIFICATION_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NO_QUALIFICATION_TYPE_API" AS
/* $Header: peeqtnoi.pkb 120.0 2005/05/31 08:12 appldev noship $ */
--
-- Package Variables
--
g_package            VARCHAR2(33) := 'hr_no_qualification_type_api.';
--
-- ------------------------------------------------------------------------------------
-- |--------------------< create_no_qualification_type >-----------------------|
-- ------------------------------------------------------------------------------------
--
procedure create_no_qualification_type
  (p_validate               in  boolean default false
  ,p_effective_date         in date
  ,p_language_code          in varchar2 default hr_api.userenv_lang
  ,p_name                   in varchar2
  ,p_category               in varchar2
  ,p_rank                   in number           default null
  ,p_attribute_category     in varchar2         default null
  ,p_attribute1             in varchar2         default null
  ,p_attribute2             in varchar2         default null
  ,p_attribute3             in varchar2         default null
  ,p_attribute4             in varchar2         default null
  ,p_attribute5             in varchar2         default null
  ,p_attribute6             in varchar2         default null
  ,p_attribute7             in varchar2         default null
  ,p_attribute8             in varchar2         default null
  ,p_attribute9             in varchar2         default null
  ,p_attribute10            in varchar2         default null
  ,p_attribute11            in varchar2         default null
  ,p_attribute12            in varchar2         default null
  ,p_attribute13            in varchar2         default null
  ,p_attribute14            in varchar2         default null
  ,p_attribute15            in varchar2         default null
  ,p_attribute16            in varchar2         default null
  ,p_attribute17            in varchar2         default null
  ,p_attribute18            in varchar2         default null
  ,p_attribute19            in varchar2         default null
  ,p_attribute20            in varchar2         default null
  ,p_information_category   in varchar2         default null
  ,p_nus2000_code	    in varchar2         default null
  ,p_qual_framework_id      in number           default null
  ,p_qualification_type     in varchar2         default null
  ,p_credit_type            in varchar2         default null
  ,p_credits                in number           default null
  ,p_level_type             in varchar2         default null
  ,p_level_number           in number           default null
  ,p_field                  in varchar2         default null
  ,p_sub_field              in varchar2         default null
  ,p_provider               in varchar2         default null
  ,p_qa_organization        in varchar2         default null
  ,p_qualification_type_id  out NOCOPY number
  ,p_object_version_number  out NOCOPY number
 ) is

  -- Declare cursors and local variables
    l_proc                 VARCHAR2(72) := g_package||'create_no_qualification';
  --
  BEGIN
	    hr_utility.set_location('Entering:'|| l_proc, 10);

	    -- Check if information category is NO.

	    IF p_information_category <> 'NO' THEN
	      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
	      hr_utility.set_message_token('LEG_CODE','NO');
	      hr_utility.raise_error;
	    END IF;

	    hr_utility.set_location(l_proc, 30);

	    --
	    -- Call the qualification business process
	    --

           hr_qualification_type_api.create_qualification_type
	    (p_validate			     => p_validate
	    ,p_effective_date                => p_effective_date
	    ,p_language_code                 => p_language_code
	    ,p_name                          => p_name
	    ,p_category                      => p_category
	    ,p_rank                          => p_rank
	    ,p_attribute_category            => p_attribute_category
	    ,p_attribute1                    => p_attribute1
	    ,p_attribute2                    => p_attribute2
	    ,p_attribute3                    => p_attribute3
	    ,p_attribute4                    => p_attribute4
	    ,p_attribute5                    => p_attribute5
	    ,p_attribute6                    => p_attribute6
	    ,p_attribute7                    => p_attribute7
	    ,p_attribute8                    => p_attribute8
	    ,p_attribute9                    => p_attribute9
	    ,p_attribute10                   => p_attribute10
	    ,p_attribute11                   => p_attribute11
	    ,p_attribute12                   => p_attribute12
	    ,p_attribute13                   => p_attribute13
	    ,p_attribute14                   => p_attribute14
	    ,p_attribute15                   => p_attribute15
	    ,p_attribute16                   => p_attribute16
	    ,p_attribute17                   => p_attribute17
	    ,p_attribute18                   => p_attribute18
	    ,p_attribute19                   => p_attribute19
	    ,p_attribute20                   => p_attribute20
	    ,p_information_category          => p_information_category
	    ,p_information1                  => p_nus2000_code
 	    ,p_qual_framework_id             => p_qual_framework_id
	    ,p_qualification_type            => p_qualification_type
	    ,p_credit_type                   => p_credit_type
	    ,p_credits                       => p_credits
	    ,p_level_type                    => p_level_type
	    ,p_level_number                  => p_level_number
	    ,p_field                         => p_field
	    ,p_sub_field                     => p_sub_field
	    ,p_provider                      => p_provider
	    ,p_qa_organization               => p_qa_organization
	    ,p_qualification_type_id  => p_qualification_type_id
	    ,p_object_version_number => p_object_version_number
	  );

end create_no_qualification_type;
--------------------------------------------------------------------------------------------------------------------------

procedure update_no_qualification_type
  (p_validate                      in     boolean default false
  ,p_qualification_type_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_category                      in     varchar2 default hr_api.g_varchar2
  ,p_rank                          in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_nus2000_code                  in     varchar2 default hr_api.g_varchar2
  ,p_qual_framework_id             in     number   default hr_api.g_number
  ,p_qualification_type            in     varchar2 default hr_api.g_varchar2
  ,p_credit_type                   in     varchar2 default hr_api.g_varchar2
  ,p_credits                       in     number   default hr_api.g_number
  ,p_level_type                    in     varchar2 default hr_api.g_varchar2
  ,p_level_number                  in     number   default hr_api.g_number
  ,p_field                         in     varchar2 default hr_api.g_varchar2
  ,p_sub_field                     in     varchar2 default hr_api.g_varchar2
  ,p_provider                      in     varchar2 default hr_api.g_varchar2
  ,p_qa_organization               in     varchar2 default hr_api.g_varchar2
 ) is

-- Declare cursors and local variables
    l_proc                 VARCHAR2(72) := g_package||'create_no_qualification';
    --
   BEGIN

	    hr_utility.set_location('Entering:'|| l_proc, 10);

	   -- Check if information category is NO --

	    IF p_information_category <> 'NO' THEN
	      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
	      hr_utility.set_message_token('LEG_CODE','NO');
	      hr_utility.raise_error;
	    END IF;

	    hr_utility.set_location(l_proc, 30);

	    --
	    -- Call the qualification business process
	    --


	   hr_qualification_type_api.update_qualification_type
	    (p_validate                      => p_validate
	    ,p_qualification_type_id         => p_qualification_type_id
	    ,p_effective_date                => p_effective_date
	    ,p_language_code                 => p_language_code
	    ,p_name                          => p_name
	    ,p_category                      => p_category
	    ,p_rank                          => p_rank
	    ,p_attribute_category            => p_attribute_category
	    ,p_attribute1                    => p_attribute1
	    ,p_attribute2                    => p_attribute2
	    ,p_attribute3                    => p_attribute3
	    ,p_attribute4                    => p_attribute4
	    ,p_attribute5                    => p_attribute5
	    ,p_attribute6                    => p_attribute6
	    ,p_attribute7                    => p_attribute7
	    ,p_attribute8                    => p_attribute8
	    ,p_attribute9                    => p_attribute9
	    ,p_attribute10                   => p_attribute10
	    ,p_attribute11                   => p_attribute11
	    ,p_attribute12                   => p_attribute12
	    ,p_attribute13                   => p_attribute13
	    ,p_attribute14                   => p_attribute14
	    ,p_attribute15                   => p_attribute15
	    ,p_attribute16                   => p_attribute16
	    ,p_attribute17                   => p_attribute17
	    ,p_attribute18                   => p_attribute18
	    ,p_attribute19                   => p_attribute19
	    ,p_attribute20                   => p_attribute20
	    ,p_information_category          => p_information_category
	    ,p_information1                  => p_nus2000_code
	    ,p_qual_framework_id             => p_qual_framework_id
	    ,p_qualification_type            => p_qualification_type
	    ,p_credit_type                   => p_credit_type
	    ,p_credits                       => p_credits
	    ,p_level_type                    => p_level_type
	    ,p_level_number                  => p_level_number
	    ,p_field                         => p_field
	    ,p_sub_field                     => p_sub_field
	    ,p_provider                      => p_provider
	    ,p_qa_organization               => p_qa_organization
	    ,p_object_version_number         => p_object_version_number
	  );
	hr_utility.set_location(' Leaving:'||l_proc, 40);
	end update_no_qualification_type;
	--
end hr_no_qualification_type_api;

/
