--------------------------------------------------------
--  DDL for Package Body IRC_POSTING_CONTENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_POSTING_CONTENT_API" as
/* $Header: iripcapi.pkb 120.2 2006/02/16 07:22:04 mmillmor noship $ */
--
-- Package Variables
--
g_package  varchar2(33)    := 'IRC_POSTING_CONTENT_API.';
g_full_mode varchar2(30)   := 'FULL';
g_online_mode varchar2(30) := 'ONLINE';
g_none_mode varchar(30) :='NONE';
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< synchronize_index >-----------------------
-- ----------------------------------------------------------------------------
Procedure synchronize_index(p_mode in varchar2)
is
  l_proc varchar2(72)    := g_package||'synchronize_index';
  l_hr_username fnd_oracle_userid.oracle_username%TYPE :=null ;
  cursor csr_user is
    select oracle_username
      from fnd_oracle_userid
     where oracle_id = 800;
begin
 hr_utility.set_location('Entering:'|| l_proc, 10);
  open csr_user;
  fetch csr_user into l_hr_username;
  close csr_user;
  If l_hr_username is not null
  then
    If p_mode = g_full_mode
    then
      hr_utility.set_location(l_proc, 20);
      ad_ctx_ddl.optimize_index
      (idx_name=>l_hr_username||'.IRC_POSTING_CON_TL_CTX'
      ,optlevel=>'FULL'
      ,maxtime=>null
      ,token=>null);
    elsif p_mode = g_online_mode
    then
      hr_utility.set_location(l_proc, 30);
      ad_ctx_ddl.sync_index
      (idx_name=>l_hr_username||'.IRC_POSTING_CON_TL_CTX');
    elsif p_mode = g_none_mode
    then
      hr_utility.set_location(l_proc, 35);
    end if;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 40);
exception
  when others then
    If csr_user%isopen
    then
      close csr_user;
    End if;
    raise;
end synchronize_index;
-- ----------------------------------------------------------------------------
-- |--------------------------< create_posting_content >-----------------------
-- ----------------------------------------------------------------------------
--
procedure create_posting_content
  (
   P_VALIDATE                      in  boolean  default false
  ,P_DISPLAY_MANAGER_INFO          in  varchar2
  ,P_DISPLAY_RECRUITER_INFO        in  varchar2
  ,P_LANGUAGE_CODE                 in  varchar2	default hr_api.userenv_lang
  ,P_NAME                          in  varchar2
  ,P_ORG_NAME                      in  varchar2	default null
  ,P_ORG_DESCRIPTION               in  varchar2	default null
  ,P_JOB_TITLE                     in  varchar2	default null
  ,P_BRIEF_DESCRIPTION             in  varchar2	default null
  ,P_DETAILED_DESCRIPTION          in  varchar2	default null
  ,P_JOB_REQUIREMENTS              in  varchar2	default null
  ,P_ADDITIONAL_DETAILS            in  varchar2	default null
  ,P_HOW_TO_APPLY                  in  varchar2	default null
  ,P_BENEFIT_INFO                  in  varchar2	default null
  ,P_IMAGE_URL                     in  varchar2	default null
  ,P_ALT_IMAGE_URL                 in  varchar2	default null
  ,P_ATTRIBUTE_CATEGORY            in  varchar2 default null
  ,P_ATTRIBUTE1                    in  varchar2 default null
  ,P_ATTRIBUTE2                    in  varchar2 default null
  ,P_ATTRIBUTE3                    in  varchar2 default null
  ,P_ATTRIBUTE4                    in  varchar2 default null
  ,P_ATTRIBUTE5                    in  varchar2 default null
  ,P_ATTRIBUTE6                    in  varchar2 default null
  ,P_ATTRIBUTE7                    in  varchar2 default null
  ,P_ATTRIBUTE8                    in  varchar2 default null
  ,P_ATTRIBUTE9                    in  varchar2 default null
  ,P_ATTRIBUTE10                   in  varchar2 default null
  ,P_ATTRIBUTE11                   in  varchar2 default null
  ,P_ATTRIBUTE12                   in  varchar2 default null
  ,P_ATTRIBUTE13                   in  varchar2 default null
  ,P_ATTRIBUTE14                   in  varchar2 default null
  ,P_ATTRIBUTE15                   in  varchar2 default null
  ,P_ATTRIBUTE16                   in  varchar2 default null
  ,P_ATTRIBUTE17                   in  varchar2 default null
  ,P_ATTRIBUTE18                   in  varchar2 default null
  ,P_ATTRIBUTE19                   in  varchar2 default null
  ,P_ATTRIBUTE20                   in  varchar2 default null
  ,P_ATTRIBUTE21                   in  varchar2 default null
  ,P_ATTRIBUTE22                   in  varchar2 default null
  ,P_ATTRIBUTE23                   in  varchar2 default null
  ,P_ATTRIBUTE24                   in  varchar2 default null
  ,P_ATTRIBUTE25                   in  varchar2 default null
  ,P_ATTRIBUTE26                   in  varchar2 default null
  ,P_ATTRIBUTE27                   in  varchar2 default null
  ,P_ATTRIBUTE28                   in  varchar2 default null
  ,P_ATTRIBUTE29                   in  varchar2 default null
  ,P_ATTRIBUTE30                   in  varchar2 default null
  ,P_IPC_INFORMATION_CATEGORY      in  varchar2	default null
  ,P_IPC_INFORMATION1              in  varchar2 default null
  ,P_IPC_INFORMATION2              in  varchar2 default null
  ,P_IPC_INFORMATION3              in  varchar2 default null
  ,P_IPC_INFORMATION4              in  varchar2 default null
  ,P_IPC_INFORMATION5              in  varchar2 default null
  ,P_IPC_INFORMATION6              in  varchar2 default null
  ,P_IPC_INFORMATION7              in  varchar2 default null
  ,P_IPC_INFORMATION8              in  varchar2 default null
  ,P_IPC_INFORMATION9              in  varchar2 default null
  ,P_IPC_INFORMATION10             in  varchar2 default null
  ,P_IPC_INFORMATION11             in  varchar2 default null
  ,P_IPC_INFORMATION12             in  varchar2 default null
  ,P_IPC_INFORMATION13             in  varchar2 default null
  ,P_IPC_INFORMATION14             in  varchar2 default null
  ,P_IPC_INFORMATION15             in  varchar2 default null
  ,P_IPC_INFORMATION16             in  varchar2 default null
  ,P_IPC_INFORMATION17             in  varchar2 default null
  ,P_IPC_INFORMATION18             in  varchar2 default null
  ,P_IPC_INFORMATION19             in  varchar2 default null
  ,P_IPC_INFORMATION20             in  varchar2 default null
  ,P_IPC_INFORMATION21             in  varchar2 default null
  ,P_IPC_INFORMATION22             in  varchar2 default null
  ,P_IPC_INFORMATION23             in  varchar2 default null
  ,P_IPC_INFORMATION24             in  varchar2 default null
  ,P_IPC_INFORMATION25             in  varchar2 default null
  ,P_IPC_INFORMATION26             in  varchar2 default null
  ,P_IPC_INFORMATION27             in  varchar2 default null
  ,P_IPC_INFORMATION28             in  varchar2 default null
  ,P_IPC_INFORMATION29             in  varchar2 default null
  ,P_IPC_INFORMATION30             in  varchar2 default null
  ,P_DATE_APPROVED                 in  date     default null
  ,P_POSTING_CONTENT_ID            out nocopy number
  ,P_OBJECT_VERSION_NUMBER         out nocopy number
  )is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72)    := g_package||'create_posting_content';
  l_posting_content_id number;
  l_language_code varchar2(30);
  l_object_version_number number;
  l_date_approved date   := trunc(P_DATE_APPROVED);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_posting_content;
  --
  l_language_code:=p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_POSTING_CONTENT_BK1.create_posting_content_b
    (
     P_DISPLAY_MANAGER_INFO     =>        P_DISPLAY_MANAGER_INFO
    ,P_DISPLAY_RECRUITER_INFO  	=>	  P_DISPLAY_RECRUITER_INFO
    ,P_LANGUAGE_CODE           	=>	  l_language_code
    ,P_NAME                    	=>	  P_NAME
    ,P_ORG_NAME                	=>	  P_ORG_NAME
    ,P_ORG_DESCRIPTION         	=>	  P_ORG_DESCRIPTION
    ,P_JOB_TITLE               	=>	  P_JOB_TITLE
    ,P_BRIEF_DESCRIPTION       	=>	  P_BRIEF_DESCRIPTION
    ,P_DETAILED_DESCRIPTION    	=>	  P_DETAILED_DESCRIPTION
    ,P_JOB_REQUIREMENTS        	=>	  P_JOB_REQUIREMENTS
    ,P_ADDITIONAL_DETAILS      	=>	  P_ADDITIONAL_DETAILS
    ,P_HOW_TO_APPLY            	=>	  P_HOW_TO_APPLY
    ,P_BENEFIT_INFO            	=>	  P_BENEFIT_INFO
    ,P_IMAGE_URL               	=>	  P_IMAGE_URL
    ,P_ALT_IMAGE_URL           	=>	  P_ALT_IMAGE_URL
    ,P_ATTRIBUTE_CATEGORY      	=>	  P_ATTRIBUTE_CATEGORY
    ,P_ATTRIBUTE1              	=>	  P_ATTRIBUTE1
    ,P_ATTRIBUTE2              	=>	  P_ATTRIBUTE2
    ,P_ATTRIBUTE3              	=>	  P_ATTRIBUTE3
    ,P_ATTRIBUTE4              	=>	  P_ATTRIBUTE4
    ,P_ATTRIBUTE5              	=>	  P_ATTRIBUTE5
    ,P_ATTRIBUTE6              	=>	  P_ATTRIBUTE6
    ,P_ATTRIBUTE7              	=>	  P_ATTRIBUTE7
    ,P_ATTRIBUTE8              	=>	  P_ATTRIBUTE8
    ,P_ATTRIBUTE9              	=>	  P_ATTRIBUTE9
    ,P_ATTRIBUTE10             	=>	  P_ATTRIBUTE10
    ,P_ATTRIBUTE11             	=>	  P_ATTRIBUTE11
    ,P_ATTRIBUTE12             	=>	  P_ATTRIBUTE12
    ,P_ATTRIBUTE13             	=>	  P_ATTRIBUTE13
    ,P_ATTRIBUTE14             	=>	  P_ATTRIBUTE14
    ,P_ATTRIBUTE15             	=>	  P_ATTRIBUTE15
    ,P_ATTRIBUTE16             	=>	  P_ATTRIBUTE16
    ,P_ATTRIBUTE17             	=>	  P_ATTRIBUTE17
    ,P_ATTRIBUTE18             	=>	  P_ATTRIBUTE18
    ,P_ATTRIBUTE19             	=>	  P_ATTRIBUTE19
    ,P_ATTRIBUTE20             	=>	  P_ATTRIBUTE20
    ,P_ATTRIBUTE21             	=>	  P_ATTRIBUTE21
    ,P_ATTRIBUTE22             	=>	  P_ATTRIBUTE22
    ,P_ATTRIBUTE23             	=>	  P_ATTRIBUTE23
    ,P_ATTRIBUTE24             	=>	  P_ATTRIBUTE24
    ,P_ATTRIBUTE25             	=>	  P_ATTRIBUTE25
    ,P_ATTRIBUTE26             	=>	  P_ATTRIBUTE26
    ,P_ATTRIBUTE27             	=>	  P_ATTRIBUTE27
    ,P_ATTRIBUTE28             	=>	  P_ATTRIBUTE28
    ,P_ATTRIBUTE29             	=>	  P_ATTRIBUTE29
    ,P_ATTRIBUTE30             	=>	  P_ATTRIBUTE30
    ,P_IPC_INFORMATION_CATEGORY	=>	  P_IPC_INFORMATION_CATEGORY
    ,P_IPC_INFORMATION1        	=>	  P_IPC_INFORMATION1
    ,P_IPC_INFORMATION2        	=>	  P_IPC_INFORMATION2
    ,P_IPC_INFORMATION3        	=>	  P_IPC_INFORMATION3
    ,P_IPC_INFORMATION4        	=>	  P_IPC_INFORMATION4
    ,P_IPC_INFORMATION5        	=>	  P_IPC_INFORMATION5
    ,P_IPC_INFORMATION6        	=>	  P_IPC_INFORMATION6
    ,P_IPC_INFORMATION7        	=>	  P_IPC_INFORMATION7
    ,P_IPC_INFORMATION8        	=>	  P_IPC_INFORMATION8
    ,P_IPC_INFORMATION9        	=>	  P_IPC_INFORMATION9
    ,P_IPC_INFORMATION10       	=>	  P_IPC_INFORMATION10
    ,P_IPC_INFORMATION11       	=>	  P_IPC_INFORMATION11
    ,P_IPC_INFORMATION12       	=>	  P_IPC_INFORMATION12
    ,P_IPC_INFORMATION13       	=>	  P_IPC_INFORMATION13
    ,P_IPC_INFORMATION14       	=>	  P_IPC_INFORMATION14
    ,P_IPC_INFORMATION15       	=>	  P_IPC_INFORMATION15
    ,P_IPC_INFORMATION16       	=>	  P_IPC_INFORMATION16
    ,P_IPC_INFORMATION17       	=>	  P_IPC_INFORMATION17
    ,P_IPC_INFORMATION18       	=>	  P_IPC_INFORMATION18
    ,P_IPC_INFORMATION19       	=>	  P_IPC_INFORMATION19
    ,P_IPC_INFORMATION20       	=>	  P_IPC_INFORMATION20
    ,P_IPC_INFORMATION21       	=>	  P_IPC_INFORMATION21
    ,P_IPC_INFORMATION22       	=>	  P_IPC_INFORMATION22
    ,P_IPC_INFORMATION23       	=>	  P_IPC_INFORMATION23
    ,P_IPC_INFORMATION24       	=>	  P_IPC_INFORMATION24
    ,P_IPC_INFORMATION25       	=>	  P_IPC_INFORMATION25
    ,P_IPC_INFORMATION26       	=>	  P_IPC_INFORMATION26
    ,P_IPC_INFORMATION27       	=>	  P_IPC_INFORMATION27
    ,P_IPC_INFORMATION28       	=>	  P_IPC_INFORMATION28
    ,P_IPC_INFORMATION29       	=>	  P_IPC_INFORMATION29
    ,P_IPC_INFORMATION30       	=>	  P_IPC_INFORMATION30
    ,P_DATE_APPROVED            =>        l_date_approved
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_posting_content'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
   irc_ipc_ins.ins
    (p_display_manager_info     => P_DISPLAY_MANAGER_INFO
    ,p_display_recruiter_info   => P_DISPLAY_RECRUITER_INFO
    ,p_attribute_category       => P_ATTRIBUTE_CATEGORY
    ,p_attribute1              	=> P_ATTRIBUTE1
    ,p_attribute2              	=> P_ATTRIBUTE2
    ,p_attribute3              	=> P_ATTRIBUTE3
    ,p_attribute4              	=> P_ATTRIBUTE4
    ,p_attribute5              	=> P_ATTRIBUTE5
    ,p_attribute6              	=> P_ATTRIBUTE6
    ,p_attribute7              	=> P_ATTRIBUTE7
    ,p_attribute8              	=> P_ATTRIBUTE8
    ,p_attribute9              	=> P_ATTRIBUTE9
    ,p_attribute10             	=> P_ATTRIBUTE10
    ,p_attribute11             	=> P_ATTRIBUTE11
    ,p_attribute12             	=> P_ATTRIBUTE12
    ,p_attribute13             	=> P_ATTRIBUTE13
    ,p_attribute14             	=> P_ATTRIBUTE14
    ,p_attribute15             	=> P_ATTRIBUTE15
    ,p_attribute16             	=> P_ATTRIBUTE16
    ,p_attribute17             	=> P_ATTRIBUTE17
    ,p_attribute18             	=> P_ATTRIBUTE18
    ,p_attribute19             	=> P_ATTRIBUTE19
    ,p_attribute20             	=> P_ATTRIBUTE20
    ,p_attribute21             	=> P_ATTRIBUTE21
    ,p_attribute22             	=> P_ATTRIBUTE22
    ,p_attribute23             	=> P_ATTRIBUTE23
    ,p_attribute24             	=> P_ATTRIBUTE24
    ,p_attribute25             	=> P_ATTRIBUTE25
    ,p_attribute26             	=> P_ATTRIBUTE26
    ,p_attribute27             	=> P_ATTRIBUTE27
    ,p_attribute28             	=> P_ATTRIBUTE28
    ,p_attribute29             	=> P_ATTRIBUTE29
    ,p_attribute30             	=> P_ATTRIBUTE30
    ,p_ipc_information_category	=> P_IPC_INFORMATION_CATEGORY
    ,p_ipc_information1        	=> P_IPC_INFORMATION1
    ,p_ipc_information2        	=> P_IPC_INFORMATION2
    ,p_ipc_information3        	=> P_IPC_INFORMATION3
    ,p_ipc_information4        	=> P_IPC_INFORMATION4
    ,p_ipc_information5        	=> P_IPC_INFORMATION5
    ,p_ipc_information6        	=> P_IPC_INFORMATION6
    ,p_ipc_information7        	=> P_IPC_INFORMATION7
    ,p_ipc_information8        	=> P_IPC_INFORMATION8
    ,p_ipc_information9        	=> P_IPC_INFORMATION9
    ,p_ipc_information10       	=> P_IPC_INFORMATION10
    ,p_ipc_information11       	=> P_IPC_INFORMATION11
    ,p_ipc_information12       	=> P_IPC_INFORMATION12
    ,p_ipc_information13       	=> P_IPC_INFORMATION13
    ,p_ipc_information14       	=> P_IPC_INFORMATION14
    ,p_ipc_information15       	=> P_IPC_INFORMATION15
    ,p_ipc_information16       	=> P_IPC_INFORMATION16
    ,p_ipc_information17       	=> P_IPC_INFORMATION17
    ,p_ipc_information18       	=> P_IPC_INFORMATION18
    ,p_ipc_information19       	=> P_IPC_INFORMATION19
    ,p_ipc_information20       	=> P_IPC_INFORMATION20
    ,p_ipc_information21       	=> P_IPC_INFORMATION21
    ,p_ipc_information22       	=> P_IPC_INFORMATION22
    ,p_ipc_information23       	=> P_IPC_INFORMATION23
    ,p_ipc_information24       	=> P_IPC_INFORMATION24
    ,p_ipc_information25       	=> P_IPC_INFORMATION25
    ,p_ipc_information26       	=> P_IPC_INFORMATION26
    ,p_ipc_information27       	=> P_IPC_INFORMATION27
    ,p_ipc_information28       	=> P_IPC_INFORMATION28
    ,p_ipc_information29       	=> P_IPC_INFORMATION29
    ,p_ipc_information30       	=> P_IPC_INFORMATION30
    ,p_date_approved            => l_date_approved
    ,p_posting_content_id       => l_posting_content_id
    ,p_object_version_number    => l_object_version_number
  );
--
  irc_ipt_ins.ins_tl
  (p_language_code          => l_language_code
  ,p_posting_content_id     => l_posting_content_id
  ,p_name                   => P_NAME
  ,p_org_name               => P_ORG_NAME
  ,p_org_description        => P_ORG_DESCRIPTION
  ,p_job_title              => P_JOB_TITLE
  ,p_brief_description      => P_BRIEF_DESCRIPTION
  ,p_detailed_description   => P_DETAILED_DESCRIPTION
  ,p_job_requirements       => P_JOB_REQUIREMENTS
  ,p_additional_details     => P_ADDITIONAL_DETAILS
  ,p_how_to_apply           => P_HOW_TO_APPLY
  ,p_benefit_info           => P_BENEFIT_INFO
  ,p_image_url              => P_IMAGE_URL
  ,p_image_url_alt          => P_ALT_IMAGE_URL
  );
  --
  -- Process Logic
  --
  --
  -- Call After Process User Hook
  --
  begin
    IRC_POSTING_CONTENT_BK1.create_posting_content_a
        (
         P_DISPLAY_MANAGER_INFO         =>        P_DISPLAY_MANAGER_INFO
        ,P_DISPLAY_RECRUITER_INFO  	=>	  P_DISPLAY_RECRUITER_INFO
        ,P_LANGUAGE_CODE           	=>	  l_language_code
        ,P_NAME                    	=>	  P_NAME
        ,P_ORG_NAME                	=>	  P_ORG_NAME
        ,P_ORG_DESCRIPTION         	=>	  P_ORG_DESCRIPTION
        ,P_JOB_TITLE               	=>	  P_JOB_TITLE
        ,P_BRIEF_DESCRIPTION       	=>	  P_BRIEF_DESCRIPTION
        ,P_DETAILED_DESCRIPTION    	=>	  P_DETAILED_DESCRIPTION
        ,P_JOB_REQUIREMENTS        	=>	  P_JOB_REQUIREMENTS
        ,P_ADDITIONAL_DETAILS      	=>	  P_ADDITIONAL_DETAILS
        ,P_HOW_TO_APPLY            	=>	  P_HOW_TO_APPLY
        ,P_BENEFIT_INFO            	=>	  P_BENEFIT_INFO
        ,P_IMAGE_URL               	=>	  P_IMAGE_URL
        ,P_ALT_IMAGE_URL           	=>	  P_ALT_IMAGE_URL
        ,P_ATTRIBUTE_CATEGORY      	=>	  P_ATTRIBUTE_CATEGORY
        ,P_ATTRIBUTE1              	=>	  P_ATTRIBUTE1
        ,P_ATTRIBUTE2              	=>	  P_ATTRIBUTE2
        ,P_ATTRIBUTE3              	=>	  P_ATTRIBUTE3
        ,P_ATTRIBUTE4              	=>	  P_ATTRIBUTE4
        ,P_ATTRIBUTE5              	=>	  P_ATTRIBUTE5
        ,P_ATTRIBUTE6              	=>	  P_ATTRIBUTE6
        ,P_ATTRIBUTE7              	=>	  P_ATTRIBUTE7
        ,P_ATTRIBUTE8              	=>	  P_ATTRIBUTE8
        ,P_ATTRIBUTE9              	=>	  P_ATTRIBUTE9
        ,P_ATTRIBUTE10             	=>	  P_ATTRIBUTE10
        ,P_ATTRIBUTE11             	=>	  P_ATTRIBUTE11
        ,P_ATTRIBUTE12             	=>	  P_ATTRIBUTE12
        ,P_ATTRIBUTE13             	=>	  P_ATTRIBUTE13
        ,P_ATTRIBUTE14             	=>	  P_ATTRIBUTE14
        ,P_ATTRIBUTE15             	=>	  P_ATTRIBUTE15
        ,P_ATTRIBUTE16             	=>	  P_ATTRIBUTE16
        ,P_ATTRIBUTE17             	=>	  P_ATTRIBUTE17
        ,P_ATTRIBUTE18             	=>	  P_ATTRIBUTE18
        ,P_ATTRIBUTE19             	=>	  P_ATTRIBUTE19
        ,P_ATTRIBUTE20             	=>	  P_ATTRIBUTE20
        ,P_ATTRIBUTE21             	=>	  P_ATTRIBUTE21
        ,P_ATTRIBUTE22             	=>	  P_ATTRIBUTE22
        ,P_ATTRIBUTE23             	=>	  P_ATTRIBUTE23
        ,P_ATTRIBUTE24             	=>	  P_ATTRIBUTE24
        ,P_ATTRIBUTE25             	=>	  P_ATTRIBUTE25
        ,P_ATTRIBUTE26             	=>	  P_ATTRIBUTE26
        ,P_ATTRIBUTE27             	=>	  P_ATTRIBUTE27
        ,P_ATTRIBUTE28             	=>	  P_ATTRIBUTE28
        ,P_ATTRIBUTE29             	=>	  P_ATTRIBUTE29
        ,P_ATTRIBUTE30             	=>	  P_ATTRIBUTE30
        ,P_IPC_INFORMATION_CATEGORY	=>	  P_IPC_INFORMATION_CATEGORY
        ,P_IPC_INFORMATION1        	=>	  P_IPC_INFORMATION1
        ,P_IPC_INFORMATION2        	=>	  P_IPC_INFORMATION2
        ,P_IPC_INFORMATION3        	=>	  P_IPC_INFORMATION3
        ,P_IPC_INFORMATION4        	=>	  P_IPC_INFORMATION4
        ,P_IPC_INFORMATION5        	=>	  P_IPC_INFORMATION5
        ,P_IPC_INFORMATION6        	=>	  P_IPC_INFORMATION6
        ,P_IPC_INFORMATION7        	=>	  P_IPC_INFORMATION7
        ,P_IPC_INFORMATION8        	=>	  P_IPC_INFORMATION8
        ,P_IPC_INFORMATION9        	=>	  P_IPC_INFORMATION9
        ,P_IPC_INFORMATION10       	=>	  P_IPC_INFORMATION10
        ,P_IPC_INFORMATION11       	=>	  P_IPC_INFORMATION11
        ,P_IPC_INFORMATION12       	=>	  P_IPC_INFORMATION12
        ,P_IPC_INFORMATION13       	=>	  P_IPC_INFORMATION13
        ,P_IPC_INFORMATION14       	=>	  P_IPC_INFORMATION14
        ,P_IPC_INFORMATION15       	=>	  P_IPC_INFORMATION15
        ,P_IPC_INFORMATION16       	=>	  P_IPC_INFORMATION16
        ,P_IPC_INFORMATION17       	=>	  P_IPC_INFORMATION17
        ,P_IPC_INFORMATION18       	=>	  P_IPC_INFORMATION18
        ,P_IPC_INFORMATION19       	=>	  P_IPC_INFORMATION19
        ,P_IPC_INFORMATION20       	=>	  P_IPC_INFORMATION20
        ,P_IPC_INFORMATION21       	=>	  P_IPC_INFORMATION21
        ,P_IPC_INFORMATION22       	=>	  P_IPC_INFORMATION22
        ,P_IPC_INFORMATION23       	=>	  P_IPC_INFORMATION23
        ,P_IPC_INFORMATION24       	=>	  P_IPC_INFORMATION24
        ,P_IPC_INFORMATION25       	=>	  P_IPC_INFORMATION25
        ,P_IPC_INFORMATION26       	=>	  P_IPC_INFORMATION26
        ,P_IPC_INFORMATION27       	=>	  P_IPC_INFORMATION27
        ,P_IPC_INFORMATION28       	=>	  P_IPC_INFORMATION28
        ,P_IPC_INFORMATION29       	=>	  P_IPC_INFORMATION29
        ,P_IPC_INFORMATION30       	=>	  P_IPC_INFORMATION30
	,P_DATE_APPROVED                =>        l_date_approved
        ,P_POSTING_CONTENT_ID           =>        l_posting_content_id
    	,P_OBJECT_VERSION_NUMBER        =>        l_object_version_number
        );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_posting_content'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  P_POSTING_CONTENT_ID := l_posting_content_id;
  P_OBJECT_VERSION_NUMBER := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_posting_content;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    P_POSTING_CONTENT_ID := null;
    P_OBJECT_VERSION_NUMBER := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_posting_content;
    -- Reset IN OUT parameters and set OUT parameters
    --
    P_POSTING_CONTENT_ID := null;
    P_OBJECT_VERSION_NUMBER := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_posting_content;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_posting_content >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_posting_content
(
 P_VALIDATE                   in boolean  default false
,P_POSTING_CONTENT_ID         in number
,P_DISPLAY_MANAGER_INFO       in varchar2 default hr_api.g_varchar2
,P_DISPLAY_RECRUITER_INFO     in varchar2 default hr_api.g_varchar2
,P_LANGUAGE_CODE              in varchar2 default hr_api.userenv_lang
,P_NAME                       in varchar2 default hr_api.g_varchar2
,P_ORG_NAME                   in varchar2 default hr_api.g_varchar2
,P_ORG_DESCRIPTION            in varchar2 default hr_api.g_varchar2
,P_JOB_TITLE                  in varchar2 default hr_api.g_varchar2
,P_BRIEF_DESCRIPTION          in varchar2 default hr_api.g_varchar2
,P_DETAILED_DESCRIPTION       in varchar2 default hr_api.g_varchar2
,P_JOB_REQUIREMENTS           in varchar2 default hr_api.g_varchar2
,P_ADDITIONAL_DETAILS         in varchar2 default hr_api.g_varchar2
,P_HOW_TO_APPLY               in varchar2 default hr_api.g_varchar2
,P_BENEFIT_INFO               in varchar2 default hr_api.g_varchar2
,P_IMAGE_URL                  in varchar2 default hr_api.g_varchar2
,P_ALT_IMAGE_URL              in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE_CATEGORY         in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE1                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE2                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE3                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE4                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE5                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE6                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE7                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE8                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE9                 in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE10                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE11                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE12                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE13                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE14                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE15                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE16                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE17                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE18                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE19                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE20                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE21                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE22                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE23                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE24                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE25                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE26                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE27                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE28                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE29                in varchar2 default hr_api.g_varchar2
,P_ATTRIBUTE30                in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION_CATEGORY   in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION1           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION2           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION3           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION4           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION5           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION6           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION7           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION8           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION9           in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION10          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION11          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION12          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION13          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION14          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION15          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION16          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION17          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION18          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION19          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION20          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION21          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION22          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION23          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION24          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION25          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION26          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION27          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION28          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION29          in varchar2 default hr_api.g_varchar2
,P_IPC_INFORMATION30          in varchar2 default hr_api.g_varchar2
,P_DATE_APPROVED              in date     default hr_api.g_date
,P_OBJECT_VERSION_NUMBER      in out nocopy number
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72)    := g_package||'update_posting_content';
  l_object_version_number number := P_OBJECT_VERSION_NUMBER;
  l_date_approved date   := trunc(P_DATE_APPROVED);
  l_language_code varchar2(30);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_posting_content;
  --
  l_language_code:=p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_POSTING_CONTENT_BK2.update_posting_content_b
  (
   P_POSTING_CONTENT_ID       => P_POSTING_CONTENT_ID
  ,P_DISPLAY_MANAGER_INFO     => P_DISPLAY_MANAGER_INFO
  ,P_DISPLAY_RECRUITER_INFO   => P_DISPLAY_RECRUITER_INFO
  ,P_LANGUAGE_CODE            => l_language_code
  ,P_NAME                     => P_NAME
  ,P_ORG_NAME                 => P_ORG_NAME
  ,P_ORG_DESCRIPTION          => P_ORG_DESCRIPTION
  ,P_JOB_TITLE                => P_JOB_TITLE
  ,P_BRIEF_DESCRIPTION        => P_BRIEF_DESCRIPTION
  ,P_DETAILED_DESCRIPTION     => P_DETAILED_DESCRIPTION
  ,P_JOB_REQUIREMENTS         => P_JOB_REQUIREMENTS
  ,P_ADDITIONAL_DETAILS       => P_ADDITIONAL_DETAILS
  ,P_HOW_TO_APPLY             => P_HOW_TO_APPLY
  ,P_BENEFIT_INFO             => P_BENEFIT_INFO
  ,P_IMAGE_URL                => P_IMAGE_URL
  ,P_ALT_IMAGE_URL            => P_ALT_IMAGE_URL
  ,P_ATTRIBUTE_CATEGORY       => P_ATTRIBUTE_CATEGORY
  ,P_ATTRIBUTE1               => P_ATTRIBUTE1
  ,P_ATTRIBUTE2               => P_ATTRIBUTE2
  ,P_ATTRIBUTE3               => P_ATTRIBUTE3
  ,P_ATTRIBUTE4               => P_ATTRIBUTE4
  ,P_ATTRIBUTE5               => P_ATTRIBUTE5
  ,P_ATTRIBUTE6               => P_ATTRIBUTE6
  ,P_ATTRIBUTE7               => P_ATTRIBUTE7
  ,P_ATTRIBUTE8               => P_ATTRIBUTE8
  ,P_ATTRIBUTE9               => P_ATTRIBUTE9
  ,P_ATTRIBUTE10              => P_ATTRIBUTE10
  ,P_ATTRIBUTE11              => P_ATTRIBUTE11
  ,P_ATTRIBUTE12              => P_ATTRIBUTE12
  ,P_ATTRIBUTE13              => P_ATTRIBUTE13
  ,P_ATTRIBUTE14              => P_ATTRIBUTE14
  ,P_ATTRIBUTE15              => P_ATTRIBUTE15
  ,P_ATTRIBUTE16              => P_ATTRIBUTE16
  ,P_ATTRIBUTE17              => P_ATTRIBUTE17
  ,P_ATTRIBUTE18              => P_ATTRIBUTE18
  ,P_ATTRIBUTE19              => P_ATTRIBUTE19
  ,P_ATTRIBUTE20              => P_ATTRIBUTE20
  ,P_ATTRIBUTE21              => P_ATTRIBUTE21
  ,P_ATTRIBUTE22              => P_ATTRIBUTE22
  ,P_ATTRIBUTE23              => P_ATTRIBUTE23
  ,P_ATTRIBUTE24              => P_ATTRIBUTE24
  ,P_ATTRIBUTE25              => P_ATTRIBUTE25
  ,P_ATTRIBUTE26              => P_ATTRIBUTE26
  ,P_ATTRIBUTE27              => P_ATTRIBUTE27
  ,P_ATTRIBUTE28              => P_ATTRIBUTE28
  ,P_ATTRIBUTE29              => P_ATTRIBUTE29
  ,P_ATTRIBUTE30              => P_ATTRIBUTE30
  ,P_IPC_INFORMATION_CATEGORY => P_IPC_INFORMATION_CATEGORY
  ,P_IPC_INFORMATION1         => P_IPC_INFORMATION1
  ,P_IPC_INFORMATION2         => P_IPC_INFORMATION2
  ,P_IPC_INFORMATION3         => P_IPC_INFORMATION3
  ,P_IPC_INFORMATION4         => P_IPC_INFORMATION4
  ,P_IPC_INFORMATION5         => P_IPC_INFORMATION5
  ,P_IPC_INFORMATION6         => P_IPC_INFORMATION6
  ,P_IPC_INFORMATION7         => P_IPC_INFORMATION7
  ,P_IPC_INFORMATION8         => P_IPC_INFORMATION8
  ,P_IPC_INFORMATION9         => P_IPC_INFORMATION9
  ,P_IPC_INFORMATION10        => P_IPC_INFORMATION10
  ,P_IPC_INFORMATION11        => P_IPC_INFORMATION11
  ,P_IPC_INFORMATION12        => P_IPC_INFORMATION12
  ,P_IPC_INFORMATION13        => P_IPC_INFORMATION13
  ,P_IPC_INFORMATION14        => P_IPC_INFORMATION14
  ,P_IPC_INFORMATION15        => P_IPC_INFORMATION15
  ,P_IPC_INFORMATION16        => P_IPC_INFORMATION16
  ,P_IPC_INFORMATION17        => P_IPC_INFORMATION17
  ,P_IPC_INFORMATION18        => P_IPC_INFORMATION18
  ,P_IPC_INFORMATION19        => P_IPC_INFORMATION19
  ,P_IPC_INFORMATION20        => P_IPC_INFORMATION20
  ,P_IPC_INFORMATION21        => P_IPC_INFORMATION21
  ,P_IPC_INFORMATION22        => P_IPC_INFORMATION22
  ,P_IPC_INFORMATION23        => P_IPC_INFORMATION23
  ,P_IPC_INFORMATION24        => P_IPC_INFORMATION24
  ,P_IPC_INFORMATION25        => P_IPC_INFORMATION25
  ,P_IPC_INFORMATION26        => P_IPC_INFORMATION26
  ,P_IPC_INFORMATION27        => P_IPC_INFORMATION27
  ,P_IPC_INFORMATION28        => P_IPC_INFORMATION28
  ,P_IPC_INFORMATION29        => P_IPC_INFORMATION29
  ,P_IPC_INFORMATION30        => P_IPC_INFORMATION30
  ,P_DATE_APPROVED            => l_date_approved
  ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_posting_content'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  irc_ipc_upd.upd
  (p_posting_content_id       => P_POSTING_CONTENT_ID
  ,p_object_version_number    => l_object_version_number
  ,p_display_manager_info     => P_DISPLAY_MANAGER_INFO
  ,p_display_recruiter_info   => P_DISPLAY_RECRUITER_INFO
  ,p_attribute_category       => P_ATTRIBUTE_CATEGORY
  ,p_attribute1               => P_ATTRIBUTE1
  ,p_attribute2               => P_ATTRIBUTE2
  ,p_attribute3               => P_ATTRIBUTE3
  ,p_attribute4               => P_ATTRIBUTE4
  ,p_attribute5               => P_ATTRIBUTE5
  ,p_attribute6               => P_ATTRIBUTE6
  ,p_attribute7               => P_ATTRIBUTE7
  ,p_attribute8               => P_ATTRIBUTE8
  ,p_attribute9               => P_ATTRIBUTE9
  ,p_attribute10              => P_ATTRIBUTE10
  ,p_attribute11              => P_ATTRIBUTE11
  ,p_attribute12              => P_ATTRIBUTE12
  ,p_attribute13              => P_ATTRIBUTE13
  ,p_attribute14              => P_ATTRIBUTE14
  ,p_attribute15              => P_ATTRIBUTE15
  ,p_attribute16              => P_ATTRIBUTE16
  ,p_attribute17              => P_ATTRIBUTE17
  ,p_attribute18              => P_ATTRIBUTE18
  ,p_attribute19              => P_ATTRIBUTE19
  ,p_attribute20              => P_ATTRIBUTE20
  ,p_attribute21              => P_ATTRIBUTE21
  ,p_attribute22              => P_ATTRIBUTE22
  ,p_attribute23              => P_ATTRIBUTE23
  ,p_attribute24              => P_ATTRIBUTE24
  ,p_attribute25              => P_ATTRIBUTE25
  ,p_attribute26              => P_ATTRIBUTE26
  ,p_attribute27              => P_ATTRIBUTE27
  ,p_attribute28              => P_ATTRIBUTE28
  ,p_attribute29              => P_ATTRIBUTE29
  ,p_attribute30              => P_ATTRIBUTE30
  ,p_ipc_information_category => P_IPC_INFORMATION_CATEGORY
  ,p_ipc_information1         => P_IPC_INFORMATION1
  ,p_ipc_information2         => P_IPC_INFORMATION2
  ,p_ipc_information3         => P_IPC_INFORMATION3
  ,p_ipc_information4         => P_IPC_INFORMATION4
  ,p_ipc_information5         => P_IPC_INFORMATION5
  ,p_ipc_information6         => P_IPC_INFORMATION6
  ,p_ipc_information7         => P_IPC_INFORMATION7
  ,p_ipc_information8         => P_IPC_INFORMATION8
  ,p_ipc_information9         => P_IPC_INFORMATION9
  ,p_ipc_information10        => P_IPC_INFORMATION10
  ,p_ipc_information11        => P_IPC_INFORMATION11
  ,p_ipc_information12        => P_IPC_INFORMATION12
  ,p_ipc_information13        => P_IPC_INFORMATION13
  ,p_ipc_information14        => P_IPC_INFORMATION14
  ,p_ipc_information15        => P_IPC_INFORMATION15
  ,p_ipc_information16        => P_IPC_INFORMATION16
  ,p_ipc_information17        => P_IPC_INFORMATION17
  ,p_ipc_information18        => P_IPC_INFORMATION18
  ,p_ipc_information19        => P_IPC_INFORMATION19
  ,p_ipc_information20        => P_IPC_INFORMATION20
  ,p_ipc_information21        => P_IPC_INFORMATION21
  ,p_ipc_information22        => P_IPC_INFORMATION22
  ,p_ipc_information23        => P_IPC_INFORMATION23
  ,p_ipc_information24        => P_IPC_INFORMATION24
  ,p_ipc_information25        => P_IPC_INFORMATION25
  ,p_ipc_information26        => P_IPC_INFORMATION26
  ,p_ipc_information27        => P_IPC_INFORMATION27
  ,p_ipc_information28        => P_IPC_INFORMATION28
  ,p_ipc_information29        => P_IPC_INFORMATION29
  ,p_ipc_information30        => P_IPC_INFORMATION30
  ,p_date_approved            => l_date_approved
  );
  --
  -- Process Logic
  irc_ipt_upd.upd_tl
  (p_language_code        => l_language_code
  ,p_posting_content_id   => P_POSTING_CONTENT_ID
  ,p_name                 => P_NAME
  ,p_org_name             => P_ORG_NAME
  ,p_org_description      => P_ORG_DESCRIPTION
  ,p_job_title            => P_JOB_TITLE
  ,p_brief_description    => P_BRIEF_DESCRIPTION
  ,p_detailed_description => P_DETAILED_DESCRIPTION
  ,p_job_requirements     => P_JOB_REQUIREMENTS
  ,p_additional_details   => P_ADDITIONAL_DETAILS
  ,p_how_to_apply         => P_HOW_TO_APPLY
  ,p_benefit_info         => P_BENEFIT_INFO
  ,p_image_url            => P_IMAGE_URL
  ,p_image_url_alt        => P_ALT_IMAGE_URL
  );
  --
  --
  -- Call After Process User Hook
  --
  begin
   IRC_POSTING_CONTENT_BK2.update_posting_content_a
     (
      P_POSTING_CONTENT_ID       => P_POSTING_CONTENT_ID
     ,P_DISPLAY_MANAGER_INFO     => P_DISPLAY_MANAGER_INFO
     ,P_DISPLAY_RECRUITER_INFO   => P_DISPLAY_RECRUITER_INFO
     ,P_LANGUAGE_CODE            => l_language_code
     ,P_NAME                     => P_NAME
     ,P_ORG_NAME                 => P_ORG_NAME
     ,P_ORG_DESCRIPTION          => P_ORG_DESCRIPTION
     ,P_JOB_TITLE                => P_JOB_TITLE
     ,P_BRIEF_DESCRIPTION        => P_BRIEF_DESCRIPTION
     ,P_DETAILED_DESCRIPTION     => P_DETAILED_DESCRIPTION
     ,P_JOB_REQUIREMENTS         => P_JOB_REQUIREMENTS
     ,P_ADDITIONAL_DETAILS       => P_ADDITIONAL_DETAILS
     ,P_HOW_TO_APPLY             => P_HOW_TO_APPLY
     ,P_BENEFIT_INFO             => P_BENEFIT_INFO
     ,P_IMAGE_URL                => P_IMAGE_URL
     ,P_ALT_IMAGE_URL            => P_ALT_IMAGE_URL
     ,P_ATTRIBUTE_CATEGORY       => P_ATTRIBUTE_CATEGORY
     ,P_ATTRIBUTE1               => P_ATTRIBUTE1
     ,P_ATTRIBUTE2               => P_ATTRIBUTE2
     ,P_ATTRIBUTE3               => P_ATTRIBUTE3
     ,P_ATTRIBUTE4               => P_ATTRIBUTE4
     ,P_ATTRIBUTE5               => P_ATTRIBUTE5
     ,P_ATTRIBUTE6               => P_ATTRIBUTE6
     ,P_ATTRIBUTE7               => P_ATTRIBUTE7
     ,P_ATTRIBUTE8               => P_ATTRIBUTE8
     ,P_ATTRIBUTE9               => P_ATTRIBUTE9
     ,P_ATTRIBUTE10              => P_ATTRIBUTE10
     ,P_ATTRIBUTE11              => P_ATTRIBUTE11
     ,P_ATTRIBUTE12              => P_ATTRIBUTE12
     ,P_ATTRIBUTE13              => P_ATTRIBUTE13
     ,P_ATTRIBUTE14              => P_ATTRIBUTE14
     ,P_ATTRIBUTE15              => P_ATTRIBUTE15
     ,P_ATTRIBUTE16              => P_ATTRIBUTE16
     ,P_ATTRIBUTE17              => P_ATTRIBUTE17
     ,P_ATTRIBUTE18              => P_ATTRIBUTE18
     ,P_ATTRIBUTE19              => P_ATTRIBUTE19
     ,P_ATTRIBUTE20              => P_ATTRIBUTE20
     ,P_ATTRIBUTE21              => P_ATTRIBUTE21
     ,P_ATTRIBUTE22              => P_ATTRIBUTE22
     ,P_ATTRIBUTE23              => P_ATTRIBUTE23
     ,P_ATTRIBUTE24              => P_ATTRIBUTE24
     ,P_ATTRIBUTE25              => P_ATTRIBUTE25
     ,P_ATTRIBUTE26              => P_ATTRIBUTE26
     ,P_ATTRIBUTE27              => P_ATTRIBUTE27
     ,P_ATTRIBUTE28              => P_ATTRIBUTE28
     ,P_ATTRIBUTE29              => P_ATTRIBUTE29
     ,P_ATTRIBUTE30              => P_ATTRIBUTE30
     ,P_IPC_INFORMATION_CATEGORY => P_IPC_INFORMATION_CATEGORY
     ,P_IPC_INFORMATION1         => P_IPC_INFORMATION1
     ,P_IPC_INFORMATION2         => P_IPC_INFORMATION2
     ,P_IPC_INFORMATION3         => P_IPC_INFORMATION3
     ,P_IPC_INFORMATION4         => P_IPC_INFORMATION4
     ,P_IPC_INFORMATION5         => P_IPC_INFORMATION5
     ,P_IPC_INFORMATION6         => P_IPC_INFORMATION6
     ,P_IPC_INFORMATION7         => P_IPC_INFORMATION7
     ,P_IPC_INFORMATION8         => P_IPC_INFORMATION8
     ,P_IPC_INFORMATION9         => P_IPC_INFORMATION9
     ,P_IPC_INFORMATION10        => P_IPC_INFORMATION10
     ,P_IPC_INFORMATION11        => P_IPC_INFORMATION11
     ,P_IPC_INFORMATION12        => P_IPC_INFORMATION12
     ,P_IPC_INFORMATION13        => P_IPC_INFORMATION13
     ,P_IPC_INFORMATION14        => P_IPC_INFORMATION14
     ,P_IPC_INFORMATION15        => P_IPC_INFORMATION15
     ,P_IPC_INFORMATION16        => P_IPC_INFORMATION16
     ,P_IPC_INFORMATION17        => P_IPC_INFORMATION17
     ,P_IPC_INFORMATION18        => P_IPC_INFORMATION18
     ,P_IPC_INFORMATION19        => P_IPC_INFORMATION19
     ,P_IPC_INFORMATION20        => P_IPC_INFORMATION20
     ,P_IPC_INFORMATION21        => P_IPC_INFORMATION21
     ,P_IPC_INFORMATION22        => P_IPC_INFORMATION22
     ,P_IPC_INFORMATION23        => P_IPC_INFORMATION23
     ,P_IPC_INFORMATION24        => P_IPC_INFORMATION24
     ,P_IPC_INFORMATION25        => P_IPC_INFORMATION25
     ,P_IPC_INFORMATION26        => P_IPC_INFORMATION26
     ,P_IPC_INFORMATION27        => P_IPC_INFORMATION27
     ,P_IPC_INFORMATION28        => P_IPC_INFORMATION28
     ,P_IPC_INFORMATION29        => P_IPC_INFORMATION29
     ,P_IPC_INFORMATION30        => P_IPC_INFORMATION30
     ,P_DATE_APPROVED            => l_date_approved
     ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_posting_content'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  P_OBJECT_VERSION_NUMBER := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_posting_content;
    --
    P_OBJECT_VERSION_NUMBER    := l_object_version_number;
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_posting_content;
    -- Reset IN OUT parameters and set OUT parameters
    P_OBJECT_VERSION_NUMBER    := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_posting_content;

-- ----------------------------------------------------------------------------
-- |--------------------------< delete_posting_content >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_posting_content
(
 P_VALIDATE                 in boolean	 default false
,P_POSTING_CONTENT_ID       in number
,P_OBJECT_VERSION_NUMBER    in number
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc   varchar2(72)	:= g_package||'delete_posting_content';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_posting_content;
  --
  --
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_POSTING_CONTENT_BK3.delete_posting_content_b
    (
     P_POSTING_CONTENT_ID    => P_POSTING_CONTENT_ID
    ,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_posting_content'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  irc_ipc_shd.lck
  (P_POSTING_CONTENT_ID      => P_POSTING_CONTENT_ID
  ,P_OBJECT_VERSION_NUMBER   => P_OBJECT_VERSION_NUMBER
  );
--
  irc_ipt_del.del_tl
  (P_POSTING_CONTENT_ID      => P_POSTING_CONTENT_ID
  );
--
  irc_ipc_del.del
  (p_posting_content_id     => P_POSTING_CONTENT_ID
  ,p_object_version_number  => P_OBJECT_VERSION_NUMBER
  );
  --
  -- Call After Process User Hook
  --
  begin
     IRC_POSTING_CONTENT_BK3.delete_posting_content_a
     (
         P_POSTING_CONTENT_ID    => P_POSTING_CONTENT_ID
        ,P_OBJECT_VERSION_NUMBER => P_OBJECT_VERSION_NUMBER
     );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_posting_content'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_posting_content;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    hr_utility.set_location(' Leaving:'||l_proc, 80);

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_posting_content;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_posting_content;

-- ----------------------------------------------------------------------------
-- |----------------------< synchronize_recruiter_info >----------------------|
-- ----------------------------------------------------------------------------
procedure synchronize_recruiter_info is
  l_posting_content_ovn number;

    cursor get_recruiter_info is
    select
       ppf.full_name
     , ppf.email_address
     , pp.phone_number
     , ipc.posting_content_id
     , ipc.object_version_number
    from per_all_vacancies pv
       , per_recruitment_activity_for RAF
       , per_recruitment_activities pra
       , irc_posting_contents ipc
       , irc_all_recruiting_sites iars
       , per_all_people_f ppf
       , per_phones pp
    where pv.vacancy_id = raf.vacancy_id
          and pv.status='APPROVED'
          and raf.recruitment_activity_id = pra.recruitment_activity_id
          and pra.recruiting_site_id = iars.recruiting_site_id
          and iars.external='Y'
          and pra.posting_content_id = ipc.posting_content_id
          and pv.recruiter_id = ppf.person_id
          and sysdate between ppf.effective_start_date
          and ppf.effective_end_date
          and pv.recruiter_id = pp.parent_id(+)
          and pp.parent_table(+)='PER_ALL_PEOPLE_F'
          and pp.phone_type(+)='W1'
          and sysdate between nvl(pp.date_from, sysdate) and nvl(pp.date_to, sysdate)
          and ( nvl(ipc.recruiter_full_name,'-1') <> ppf.full_name
                OR nvl(ipc.recruiter_email,'-1') <> nvl(ppf.email_address,'-1')
                OR nvl(ipc.recruiter_work_telephone,'-1') <> nvl(pp.phone_number,'-1')
               );
    cursor get_manager_info is
    select
       ppf.full_name
     , ppf.email_address
     , pp.phone_number
     , ipc.posting_content_id
     , ipc.object_version_number
    from per_all_vacancies pv
       , per_recruitment_activity_for RAF
       , per_recruitment_activities pra
       , irc_posting_contents ipc
       , irc_all_recruiting_sites iars
       , per_all_people_f ppf
       , per_phones pp
    where pv.vacancy_id = raf.vacancy_id
          and pv.status='APPROVED'
          and raf.recruitment_activity_id = pra.recruitment_activity_id
          and pra.recruiting_site_id = iars.recruiting_site_id
          and iars.external='Y'
          and pra.posting_content_id = ipc.posting_content_id
          and pv.manager_id = ppf.person_id
          and sysdate between ppf.effective_start_date
          and ppf.effective_end_date
          and pv.recruiter_id = pp.parent_id(+)
          and pp.parent_table(+)='PER_ALL_PEOPLE_F'
          and pp.phone_type(+)='W1'
          and sysdate between nvl(pp.date_from, sysdate) and nvl(pp.date_to, sysdate)
          and ( nvl(ipc.manager_full_name,'-1') <> ppf.full_name
                OR nvl(ipc.manager_email,'-1') <> nvl(ppf.email_address,'-1')
                OR nvl(ipc.manager_work_telephone,'-1') <> nvl(pp.phone_number,'-1')
               );

begin
  for l_data in get_recruiter_info loop
    l_posting_content_ovn := l_data.object_version_number;
    irc_ipc_upd.upd(p_posting_content_id => l_data.posting_content_id,
                    p_object_version_number => l_posting_content_ovn,
                    p_recruiter_full_name => l_data.full_name,
                    p_recruiter_email => l_data.email_address,
                    p_recruiter_work_telephone => l_data.phone_number
    );
  end loop;
  for l_data in get_manager_info loop
    l_posting_content_ovn := l_data.object_version_number;
    irc_ipc_upd.upd(p_posting_content_id => l_data.posting_content_id,
                    p_object_version_number => l_posting_content_ovn,
                    p_manager_full_name => l_data.full_name,
                    p_manager_email => l_data.email_address,
                    p_manager_work_telephone => l_data.phone_number
    );
  end loop;

end synchronize_recruiter_info;
--
end IRC_POSTING_CONTENT_API;

/
