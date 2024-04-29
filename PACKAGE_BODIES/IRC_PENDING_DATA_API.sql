--------------------------------------------------------
--  DDL for Package Body IRC_PENDING_DATA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PENDING_DATA_API" as
/* $Header: iripdapi.pkb 120.15 2008/01/21 14:58:20 gaukumar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_PENDING_DATA_API.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CREATE_PENDING_DATA >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_PENDING_DATA
  (p_validate                       in     boolean  default false
  ,p_email_address                  in     varchar2
  ,p_last_name                      in     varchar2
  ,p_vacancy_id                     in     number   default null
  ,p_first_name                     in     varchar2 default null
  ,p_user_password                  in     varchar2 default null
  ,p_resume_file_name               in     varchar2 default null
  ,p_resume_description             in     varchar2 default null
  ,p_resume_mime_type               in     varchar2 default null
  ,p_source_type                    in     varchar2 default null
  ,p_job_post_source_name           in     varchar2 default null
  ,p_posting_content_id             in     number   default null
  ,p_person_id                      in     number   default null
  ,p_processed                      in     varchar2 default null
  ,p_sex                            in     varchar2 default null
  ,p_date_of_birth                  in     date     default null
  ,p_per_information_category       in     varchar2 default null
  ,p_per_information1               in     varchar2 default null
  ,p_per_information2               in     varchar2 default null
  ,p_per_information3               in     varchar2 default null
  ,p_per_information4               in     varchar2 default null
  ,p_per_information5               in     varchar2 default null
  ,p_per_information6               in     varchar2 default null
  ,p_per_information7               in     varchar2 default null
  ,p_per_information8               in     varchar2 default null
  ,p_per_information9               in     varchar2 default null
  ,p_per_information10              in     varchar2 default null
  ,p_per_information11              in     varchar2 default null
  ,p_per_information12              in     varchar2 default null
  ,p_per_information13              in     varchar2 default null
  ,p_per_information14              in     varchar2 default null
  ,p_per_information15              in     varchar2 default null
  ,p_per_information16              in     varchar2 default null
  ,p_per_information17              in     varchar2 default null
  ,p_per_information18              in     varchar2 default null
  ,p_per_information19              in     varchar2 default null
  ,p_per_information20              in     varchar2 default null
  ,p_per_information21              in     varchar2 default null
  ,p_per_information22              in     varchar2 default null
  ,p_per_information23              in     varchar2 default null
  ,p_per_information24              in     varchar2 default null
  ,p_per_information25              in     varchar2 default null
  ,p_per_information26              in     varchar2 default null
  ,p_per_information27              in     varchar2 default null
  ,p_per_information28              in     varchar2 default null
  ,p_per_information29              in     varchar2 default null
  ,p_per_information30              in     varchar2 default null
  ,p_error_message                  in     varchar2 default null
  ,p_creation_date                  in     date
  ,p_last_update_date               in     date
  ,p_allow_access                   in     varchar2 default null
  ,p_user_guid                      in     raw      default null
  ,p_visitor_resp_key               in     varchar2 default null
  ,p_visitor_resp_appl_id           in     number   default null
  ,p_security_group_key             in     varchar2 default null
  ,p_pending_data_id                   out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pending_data_id    number(15);
  l_num                number;
  l_user_id            number;
  l_date_of_birth      date;
  l_creation_date      date;
  l_last_update_date   date;
  l_enc_password       fnd_user.encrypted_user_password%type;
  l_user_guid          fnd_user.user_guid%type;
  l_proc               varchar2(72) := g_package||'CREATE_PENDING_DATA';
  --
  -- cursor to get the encryptd password for new user.
  cursor csr_fnd_user_details is
  select fnd_user_pkg.GetReEncryptedPassword(user_name,'LOADER') as encrypted_user_password,
         user_guid
  from fnd_user
  where user_name = upper(p_email_address);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_PENDING_DATA;
  --
  l_date_of_birth     := trunc(p_date_of_birth);
  l_last_update_date  := trunc(p_last_update_date);
  --
  --Do not truncate the creation date.
  --
  l_creation_date     := p_creation_date;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_PENDING_DATA_BK1.CREATE_PENDING_DATA_b
     (p_email_address            =>   p_email_address
     ,p_last_name                =>   p_last_name
     ,p_vacancy_id               =>   p_vacancy_id
     ,p_first_name               =>   p_first_name
     ,p_user_password            =>   p_user_password
     ,p_resume_file_name         =>   p_resume_file_name
     ,p_resume_description       =>   p_resume_description
     ,p_resume_mime_type         =>   p_resume_mime_type
     ,p_source_type              =>   p_source_type
     ,p_job_post_source_name     =>   p_job_post_source_name
     ,p_posting_content_id       =>   p_posting_content_id
     ,p_person_id                =>   p_person_id
     ,p_processed                =>   p_processed
     ,p_sex                      =>   p_sex
     ,p_date_of_birth            =>   l_date_of_birth
     ,p_per_information_category =>   p_per_information_category
     ,p_per_information1         =>   p_per_information1
     ,p_per_information2         =>   p_per_information2
     ,p_per_information3         =>   p_per_information3
     ,p_per_information4         =>   p_per_information4
     ,p_per_information5         =>   p_per_information5
     ,p_per_information6         =>   p_per_information6
     ,p_per_information7         =>   p_per_information7
     ,p_per_information8         =>   p_per_information8
     ,p_per_information9         =>   p_per_information9
     ,p_per_information10        =>   p_per_information10
     ,p_per_information11        =>   p_per_information11
     ,p_per_information12        =>   p_per_information12
     ,p_per_information13        =>   p_per_information13
     ,p_per_information14        =>   p_per_information14
     ,p_per_information15        =>   p_per_information15
     ,p_per_information16        =>   p_per_information16
     ,p_per_information17        =>   p_per_information17
     ,p_per_information18        =>   p_per_information18
     ,p_per_information19        =>   p_per_information19
     ,p_per_information20        =>   p_per_information20
     ,p_per_information21        =>   p_per_information21
     ,p_per_information22        =>   p_per_information22
     ,p_per_information23        =>   p_per_information23
     ,p_per_information24        =>   p_per_information24
     ,p_per_information25        =>   p_per_information25
     ,p_per_information26        =>   p_per_information26
     ,p_per_information27        =>   p_per_information27
     ,p_per_information28        =>   p_per_information28
     ,p_per_information29        =>   p_per_information29
     ,p_per_information30        =>   p_per_information30
     ,p_error_message            =>   p_error_message
     ,p_creation_date            =>   l_creation_date
     ,p_last_update_date         =>   l_last_update_date
     ,p_allow_access             =>   p_allow_access
     ,p_visitor_resp_key         =>   p_visitor_resp_key
     ,p_visitor_resp_appl_id     =>   p_visitor_resp_appl_id
     ,p_security_group_key       =>   p_security_group_key
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PENDING_DATA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  if p_user_password is not null then
    l_num := irc_party_api.testusername(p_user_name=>p_email_address);
    hr_utility.set_location(l_proc,20);
    if l_num = 0 then
      --
      --Create new fnd_user
      --
      l_user_id := fnd_user_pkg.createUserId
                 (x_user_name            => p_email_address
                 ,x_owner                => 'CUST'
                 ,x_unencrypted_password => p_user_password
                 ,x_email_address        => p_email_address
                 ,x_password_date        => sysdate
                 );
      hr_utility.set_location(l_proc,30);
    else
      fnd_message.set_name('PER','IRC_EMAIL_ALREADY_REGISTERED');
      fnd_message.set_token('USER_NAME',p_email_address);
      fnd_message.raise_error;
    end if;
  end if;
  -- get the user details
  open csr_fnd_user_details;
  fetch csr_fnd_user_details into l_enc_password, l_user_guid;
  close csr_fnd_user_details;
  --
  irc_ipd_ins.ins
  (p_email_address            =>   p_email_address
  ,p_last_name                =>   p_last_name
  ,p_vacancy_id               =>   p_vacancy_id
  ,p_first_name               =>   p_first_name
  ,p_user_password            =>   l_enc_password
  ,p_resume_file_name         =>   p_resume_file_name
  ,p_resume_description       =>   p_resume_description
  ,p_resume_mime_type         =>   p_resume_mime_type
  ,p_source_type              =>   p_source_type
  ,p_job_post_source_name     =>   p_job_post_source_name
  ,p_posting_content_id       =>   p_posting_content_id
  ,p_person_id                =>   p_person_id
  ,p_processed                =>   p_processed
  ,p_sex                      =>   p_sex
  ,p_date_of_birth            =>   l_date_of_birth
  ,p_per_information_category =>   p_per_information_category
  ,p_per_information1         =>   p_per_information1
  ,p_per_information2         =>   p_per_information2
  ,p_per_information3         =>   p_per_information3
  ,p_per_information4         =>   p_per_information4
  ,p_per_information5         =>   p_per_information5
  ,p_per_information6         =>   p_per_information6
  ,p_per_information7         =>   p_per_information7
  ,p_per_information8         =>   p_per_information8
  ,p_per_information9         =>   p_per_information9
  ,p_per_information10        =>   p_per_information10
  ,p_per_information11        =>   p_per_information11
  ,p_per_information12        =>   p_per_information12
  ,p_per_information13        =>   p_per_information13
  ,p_per_information14        =>   p_per_information14
  ,p_per_information15        =>   p_per_information15
  ,p_per_information16        =>   p_per_information16
  ,p_per_information17        =>   p_per_information17
  ,p_per_information18        =>   p_per_information18
  ,p_per_information19        =>   p_per_information19
  ,p_per_information20        =>   p_per_information20
  ,p_per_information21        =>   p_per_information21
  ,p_per_information22        =>   p_per_information22
  ,p_per_information23        =>   p_per_information23
  ,p_per_information24        =>   p_per_information24
  ,p_per_information25        =>   p_per_information25
  ,p_per_information26        =>   p_per_information26
  ,p_per_information27        =>   p_per_information27
  ,p_per_information28        =>   p_per_information28
  ,p_per_information29        =>   p_per_information29
  ,p_per_information30        =>   p_per_information30
  ,p_error_message            =>   p_error_message
  ,p_creation_date            =>   l_creation_date
  ,p_last_update_date         =>   l_last_update_date
  ,p_allow_access             =>   p_allow_access
  ,p_pending_data_id          =>   l_pending_data_id
  ,p_user_guid                =>   l_user_guid
  ,p_visitor_resp_key         =>   p_visitor_resp_key
  ,p_visitor_resp_appl_id     =>   p_visitor_resp_appl_id
  ,p_security_group_key       =>   p_security_group_key
  );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_PENDING_DATA_BK1.CREATE_PENDING_DATA_a
     (p_email_address            =>   p_email_address
     ,p_last_name                =>   p_last_name
     ,p_vacancy_id               =>   p_vacancy_id
     ,p_first_name               =>   p_first_name
     ,p_user_password            =>   p_user_password
     ,p_resume_file_name         =>   p_resume_file_name
     ,p_resume_description       =>   p_resume_description
     ,p_resume_mime_type         =>   p_resume_mime_type
     ,p_source_type              =>   p_source_type
     ,p_job_post_source_name     =>   p_job_post_source_name
     ,p_posting_content_id       =>   p_posting_content_id
     ,p_person_id                =>   p_person_id
     ,p_processed                =>   p_processed
     ,p_sex                      =>   p_sex
     ,p_date_of_birth            =>   l_date_of_birth
     ,p_per_information_category =>   p_per_information_category
     ,p_per_information1         =>   p_per_information1
     ,p_per_information2         =>   p_per_information2
     ,p_per_information3         =>   p_per_information3
     ,p_per_information4         =>   p_per_information4
     ,p_per_information5         =>   p_per_information5
     ,p_per_information6         =>   p_per_information6
     ,p_per_information7         =>   p_per_information7
     ,p_per_information8         =>   p_per_information8
     ,p_per_information9         =>   p_per_information9
     ,p_per_information10        =>   p_per_information10
     ,p_per_information11        =>   p_per_information11
     ,p_per_information12        =>   p_per_information12
     ,p_per_information13        =>   p_per_information13
     ,p_per_information14        =>   p_per_information14
     ,p_per_information15        =>   p_per_information15
     ,p_per_information16        =>   p_per_information16
     ,p_per_information17        =>   p_per_information17
     ,p_per_information18        =>   p_per_information18
     ,p_per_information19        =>   p_per_information19
     ,p_per_information20        =>   p_per_information20
     ,p_per_information21        =>   p_per_information21
     ,p_per_information22        =>   p_per_information22
     ,p_per_information23        =>   p_per_information23
     ,p_per_information24        =>   p_per_information24
     ,p_per_information25        =>   p_per_information25
     ,p_per_information26        =>   p_per_information26
     ,p_per_information27        =>   p_per_information27
     ,p_per_information28        =>   p_per_information28
     ,p_per_information29        =>   p_per_information29
     ,p_per_information30        =>   p_per_information30
     ,p_error_message            =>   p_error_message
     ,p_creation_date            =>   l_creation_date
     ,p_last_update_date         =>   l_last_update_date
     ,p_allow_access             =>   p_allow_access
     ,p_visitor_resp_key         =>   p_visitor_resp_key
     ,p_visitor_resp_appl_id     =>   p_visitor_resp_appl_id
     ,p_security_group_key       =>   p_security_group_key
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PENDING_DATA'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all OUT parameters with out values
  --
  p_pending_data_id        := l_pending_data_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_PENDING_DATA;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pending_data_id        := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_PENDING_DATA;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_pending_data_id        := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_PENDING_DATA;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_PENDING_DATA >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_PENDING_DATA
  (p_validate                     in     boolean   default false
  ,p_pending_data_id              in     number
  ,p_email_address                in     varchar2  default hr_api.g_varchar2
  ,p_last_name                    in     varchar2  default hr_api.g_varchar2
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_first_name                   in     varchar2  default hr_api.g_varchar2
  ,p_user_password                in     varchar2  default hr_api.g_varchar2
  ,p_resume_file_name             in     varchar2  default hr_api.g_varchar2
  ,p_resume_description           in     varchar2  default hr_api.g_varchar2
  ,p_resume_mime_type             in     varchar2  default hr_api.g_varchar2
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_job_post_source_name         in     varchar2  default hr_api.g_varchar2
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_processed                    in     varchar2  default hr_api.g_varchar2
  ,p_sex                          in     varchar2  default hr_api.g_varchar2
  ,p_date_of_birth                in     date      default hr_api.g_date
  ,p_per_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_error_message                in     varchar2  default hr_api.g_varchar2
  ,p_creation_date                in     date      default hr_api.g_date
  ,p_last_update_date             in     date      default hr_api.g_date
  ,p_allow_access                 in     varchar2  default hr_api.g_varchar2
  ,p_user_guid                    in     raw       default null
  ,p_visitor_resp_key             in     varchar2  default hr_api.g_varchar2
  ,p_visitor_resp_appl_id         in     number    default hr_api.g_number
  ,p_security_group_key           in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_date_of_birth      date;
  l_creation_date      date;
  l_last_update_date   date;
  l_proc                varchar2(72) := g_package||'UPDATE_PENDING_DATA';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_PENDING_DATA;
  --
  --
  l_date_of_birth     := trunc(p_date_of_birth);
  l_last_update_date  := trunc(p_last_update_date);
  --
  --Do not truncate the creation date.
  --
  l_creation_date     := p_creation_date;
  --
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_PENDING_DATA_BK2.UPDATE_PENDING_DATA_b
     (p_email_address            =>   p_email_address
     ,p_last_name                =>   p_last_name
     ,p_vacancy_id               =>   p_vacancy_id
     ,p_first_name               =>   p_first_name
     ,p_user_password            =>   p_user_password
     ,p_resume_file_name         =>   p_resume_file_name
     ,p_resume_description       =>   p_resume_description
     ,p_resume_mime_type         =>   p_resume_mime_type
     ,p_source_type              =>   p_source_type
     ,p_job_post_source_name     =>   p_job_post_source_name
     ,p_posting_content_id       =>   p_posting_content_id
     ,p_person_id                =>   p_person_id
     ,p_processed                =>   p_processed
     ,p_sex                      =>   p_sex
     ,p_date_of_birth            =>   l_date_of_birth
     ,p_per_information_category =>   p_per_information_category
     ,p_per_information1         =>   p_per_information1
     ,p_per_information2         =>   p_per_information2
     ,p_per_information3         =>   p_per_information3
     ,p_per_information4         =>   p_per_information4
     ,p_per_information5         =>   p_per_information5
     ,p_per_information6         =>   p_per_information6
     ,p_per_information7         =>   p_per_information7
     ,p_per_information8         =>   p_per_information8
     ,p_per_information9         =>   p_per_information9
     ,p_per_information10        =>   p_per_information10
     ,p_per_information11        =>   p_per_information11
     ,p_per_information12        =>   p_per_information12
     ,p_per_information13        =>   p_per_information13
     ,p_per_information14        =>   p_per_information14
     ,p_per_information15        =>   p_per_information15
     ,p_per_information16        =>   p_per_information16
     ,p_per_information17        =>   p_per_information17
     ,p_per_information18        =>   p_per_information18
     ,p_per_information19        =>   p_per_information19
     ,p_per_information20        =>   p_per_information20
     ,p_per_information21        =>   p_per_information21
     ,p_per_information22        =>   p_per_information22
     ,p_per_information23        =>   p_per_information23
     ,p_per_information24        =>   p_per_information24
     ,p_per_information25        =>   p_per_information25
     ,p_per_information26        =>   p_per_information26
     ,p_per_information27        =>   p_per_information27
     ,p_per_information28        =>   p_per_information28
     ,p_per_information29        =>   p_per_information29
     ,p_per_information30        =>   p_per_information30
     ,p_error_message            =>   p_error_message
     ,p_creation_date            =>   l_creation_date
     ,p_last_update_date         =>   l_last_update_date
     ,p_allow_access             =>   p_allow_access
     ,p_visitor_resp_key         =>   p_visitor_resp_key
     ,p_visitor_resp_appl_id     =>   p_visitor_resp_appl_id
     ,p_security_group_key       =>   p_security_group_key
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PENDING_DATA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
    irc_ipd_upd.upd
     (p_pending_data_id          =>   p_pending_data_id
     ,p_email_address            =>   p_email_address
     ,p_last_name                =>   p_last_name
     ,p_first_name               =>   p_first_name
     ,p_user_password            =>   p_user_password
     ,p_resume_file_name         =>   p_resume_file_name
     ,p_resume_description       =>   p_resume_description
     ,p_resume_mime_type         =>   p_resume_mime_type
     ,p_source_type              =>   p_source_type
     ,p_job_post_source_name     =>   p_job_post_source_name
     ,p_posting_content_id       =>   p_posting_content_id
     ,p_person_id                =>   p_person_id
     ,p_processed                =>   p_processed
     ,p_sex                      =>   p_sex
     ,p_date_of_birth            =>   l_date_of_birth
     ,p_per_information_category =>   p_per_information_category
     ,p_per_information1         =>   p_per_information1
     ,p_per_information2         =>   p_per_information2
     ,p_per_information3         =>   p_per_information3
     ,p_per_information4         =>   p_per_information4
     ,p_per_information5         =>   p_per_information5
     ,p_per_information6         =>   p_per_information6
     ,p_per_information7         =>   p_per_information7
     ,p_per_information8         =>   p_per_information8
     ,p_per_information9         =>   p_per_information9
     ,p_per_information10        =>   p_per_information10
     ,p_per_information11        =>   p_per_information11
     ,p_per_information12        =>   p_per_information12
     ,p_per_information13        =>   p_per_information13
     ,p_per_information14        =>   p_per_information14
     ,p_per_information15        =>   p_per_information15
     ,p_per_information16        =>   p_per_information16
     ,p_per_information17        =>   p_per_information17
     ,p_per_information18        =>   p_per_information18
     ,p_per_information19        =>   p_per_information19
     ,p_per_information20        =>   p_per_information20
     ,p_per_information21        =>   p_per_information21
     ,p_per_information22        =>   p_per_information22
     ,p_per_information23        =>   p_per_information23
     ,p_per_information24        =>   p_per_information24
     ,p_per_information25        =>   p_per_information25
     ,p_per_information26        =>   p_per_information26
     ,p_per_information27        =>   p_per_information27
     ,p_per_information28        =>   p_per_information28
     ,p_per_information29        =>   p_per_information29
     ,p_per_information30        =>   p_per_information30
     ,p_error_message            =>   p_error_message
     ,p_last_update_date         =>   l_last_update_date
     ,p_allow_access             =>   p_allow_access
     ,p_user_guid                =>   p_user_guid
     ,p_visitor_resp_key         =>   p_visitor_resp_key
     ,p_visitor_resp_appl_id     =>   p_visitor_resp_appl_id
     ,p_security_group_key       =>   p_security_group_key
     );
  -- Call After Process User Hook
  --
  begin
    IRC_PENDING_DATA_BK2.UPDATE_PENDING_DATA_a
     (p_email_address            =>   p_email_address
     ,p_last_name                =>   p_last_name
     ,p_vacancy_id               =>   p_vacancy_id
     ,p_first_name               =>   p_first_name
     ,p_user_password            =>   p_user_password
     ,p_resume_file_name         =>   p_resume_file_name
     ,p_resume_description       =>   p_resume_description
     ,p_resume_mime_type         =>   p_resume_mime_type
     ,p_source_type              =>   p_source_type
     ,p_job_post_source_name     =>   p_job_post_source_name
     ,p_posting_content_id       =>   p_posting_content_id
     ,p_person_id                =>   p_person_id
     ,p_processed                =>   p_processed
     ,p_sex                      =>   p_sex
     ,p_date_of_birth            =>   l_date_of_birth
     ,p_per_information_category =>   p_per_information_category
     ,p_per_information1         =>   p_per_information1
     ,p_per_information2         =>   p_per_information2
     ,p_per_information3         =>   p_per_information3
     ,p_per_information4         =>   p_per_information4
     ,p_per_information5         =>   p_per_information5
     ,p_per_information6         =>   p_per_information6
     ,p_per_information7         =>   p_per_information7
     ,p_per_information8         =>   p_per_information8
     ,p_per_information9         =>   p_per_information9
     ,p_per_information10        =>   p_per_information10
     ,p_per_information11        =>   p_per_information11
     ,p_per_information12        =>   p_per_information12
     ,p_per_information13        =>   p_per_information13
     ,p_per_information14        =>   p_per_information14
     ,p_per_information15        =>   p_per_information15
     ,p_per_information16        =>   p_per_information16
     ,p_per_information17        =>   p_per_information17
     ,p_per_information18        =>   p_per_information18
     ,p_per_information19        =>   p_per_information19
     ,p_per_information20        =>   p_per_information20
     ,p_per_information21        =>   p_per_information21
     ,p_per_information22        =>   p_per_information22
     ,p_per_information23        =>   p_per_information23
     ,p_per_information24        =>   p_per_information24
     ,p_per_information25        =>   p_per_information25
     ,p_per_information26        =>   p_per_information26
     ,p_per_information27        =>   p_per_information27
     ,p_per_information28        =>   p_per_information28
     ,p_per_information29        =>   p_per_information29
     ,p_per_information30        =>   p_per_information30
     ,p_error_message            =>   p_error_message
     ,p_creation_date            =>   l_creation_date
     ,p_last_update_date         =>   l_last_update_date
     ,p_allow_access             =>   p_allow_access
     ,p_visitor_resp_key         =>   p_visitor_resp_key
     ,p_visitor_resp_appl_id     =>   p_visitor_resp_appl_id
     ,p_security_group_key       =>   p_security_group_key
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PENDING_DATA'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_PENDING_DATA;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_PENDING_DATA;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_PENDING_DATA;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_PENDING_DATA >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_PENDING_DATA
  (p_validate                     in     boolean  default false
  ,p_pending_data_id              in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'DELETE_PENDING_DATA';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_PENDING_DATA;
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_PENDING_DATA_BK3.DELETE_PENDING_DATA_b
      (p_pending_data_id               => p_pending_data_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PENDING_DATA'
        ,p_hook_type   => 'BP'
        );
  end;
  --
    irc_ipd_del.del
    (p_pending_data_id               => p_pending_data_id
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_PENDING_DATA_BK3.DELETE_PENDING_DATA_a
      (p_pending_data_id              => p_pending_data_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PENDING_DATA'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_PENDING_DATA;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_PENDING_DATA;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_PENDING_DATA;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< process_applications >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_applications
  (p_server_name         in     fnd_nodes.node_name%type
  )
  is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'process_applications';

  l_person_id            per_all_people_f.person_id%type;
  l_resp_key             fnd_responsibility.responsibility_key%type;
  l_irc_resp_id          fnd_responsibility.responsibility_id%type;
  l_irc_resp_appl_id          fnd_responsibility.application_id%type;
  l_reg_bg_id            number;

  l_resume_file_name     irc_pending_data.resume_file_name%type;
  l_resume_description   irc_pending_data.resume_description%type;
  l_resume_mime_type     irc_pending_data.resume_mime_type%type;
  l_resume               irc_pending_data.resume%type;
  l_document_id          irc_documents.document_id%type;
  l_new_doc_id		 irc_documents.document_id%type;
  l_doc_person_id	 irc_documents.person_id%type;
  l_doc_party_id	 irc_documents.party_id%type;
  l_end_date		 date := null;
  l_assignment_id	 irc_documents.assignment_id%type;
  l_doc_ovn              number;
  l_source_type          irc_pending_data.source_type%type;
  l_job_post_source_name irc_pending_data.job_post_source_name%type;

  l_applicant_person_id  per_all_people_f.person_id%type;
  l_applicant_assg_id    per_all_assignments_f.assignment_id%type;
  l_appl_ovn             per_all_people_f.object_version_number%type;
  l_emp_number           per_all_people_f.employee_number%type;

  l_effective_start_date      per_all_people_f.effective_start_date%type;
  l_effective_end_date        per_all_people_f.effective_end_date%type;
  l_full_name                 per_all_people_f.full_name%type;
  l_comment_id                per_all_people_f.comment_id%type;
  l_name_combination_warning  boolean;
  l_assign_payroll_warning    boolean;
  l_orig_hire_warning         boolean;
  l_per_ovn                   number;
  l_asg_ovn                   number;
  l_applicant_number          per_all_people_f.applicant_number%type;
  l_err_msg                   varchar2(4000);
  l_msg                       varchar2(4000);
  l_err_num                   number;
  l_allow_access              irc_pending_data.allow_access%type;
  l_password                  irc_pending_data.user_password%type;
  l_num                       number;
  l_person_type               varchar2(30);
  l_irc_profile               varchar2(30);
  l_new_user_id               number;
  --
  cursor csr_get_user_id (p_user_name varchar2) is
  select user_id
  from fnd_user
  where user_name= upper(p_user_name);
  l_user_id fnd_user.user_id%type;
  --
  cursor csr_get_employee_id (p_user_name varchar2) is
  select employee_id
  from fnd_user
  where user_name= upper(p_user_name);
  --
  cursor csr_get_resp_id(p_resp_key varchar2) is
    select responsibility_id,application_id
    from fnd_responsibility
    where responsibility_key = p_resp_key;
  l_resp_id  fnd_responsibility.responsibility_id%type;
  l_appl_id  fnd_responsibility.application_id%type;
  --
  cursor csr_get_sg_id(p_sec_group_key varchar2) is
    select security_group_id
    from fnd_security_groups
    where security_group_key = p_sec_group_key;
  l_sg_id  fnd_security_groups.security_group_id%type;
  --
  cursor csr_get_server_id is
    select node_id
    from fnd_nodes
    where lower(node_name)=lower(p_server_name);
  l_server_id  number;
  --
  cursor csr_get_resume(p_pending_data_id number) is
    select ipd.resume_file_name
          ,ipd.resume_description
          ,ipd.resume_mime_type
          ,ipd.resume
          ,ido.document_id
          ,ido.object_version_number
	  ,ido.person_id
	  ,ido.party_id
	  ,ido.assignment_id
    from  irc_pending_data ipd, irc_documents ido
    where ipd.person_id = ido.person_id(+)
      and ipd.resume_file_name = ido.file_name(+)
      and ido.type(+) = 'RESUME'
      and ido.end_date(+) is null
      and ipd.resume_file_name is not null
      and ipd.pending_data_id = p_pending_data_id;
  --
  cursor csr_get_person_id_in_vac_bg(p_person_id number, p_vacancy_id number) is
    select ppf.person_id
          ,ppf.object_version_number
          ,ppf.employee_number
    from per_all_people_f ppf
    where trunc(sysdate) between
      ppf.effective_start_date and ppf.effective_end_date
      and ppf.party_id in (select party_id from per_all_people_f
                           where person_id=p_person_id
                           and trunc(sysdate) between
                             effective_start_date and effective_end_date)
                           and ppf.business_group_id in
                             (select business_group_id from per_all_vacancies
                              where vacancy_id=p_vacancy_id);
  --
  cursor csr_get_data is
    select ipd.pending_data_id
          ,ipd.email_address
          ,ipd.vacancy_id
          ,ipd.last_name
          ,ipd.first_name
          ,ipd.user_password
          ,ipd.posting_content_id
          ,ipd.sex
          ,ipd.date_of_birth
          ,ipd.per_information_category
          ,ipd.per_information1
          ,ipd.per_information2
          ,ipd.per_information3
          ,ipd.per_information4
          ,ipd.per_information5
          ,ipd.per_information6
          ,ipd.per_information7
          ,ipd.per_information8
          ,ipd.per_information9
          ,ipd.per_information10
          ,ipd.per_information11
          ,ipd.per_information12
          ,ipd.per_information13
          ,ipd.per_information14
          ,ipd.per_information15
          ,ipd.per_information16
          ,ipd.per_information17
          ,ipd.per_information18
          ,ipd.per_information19
          ,ipd.per_information20
          ,ipd.per_information21
          ,ipd.per_information22
          ,ipd.per_information23
          ,ipd.per_information24
          ,ipd.per_information25
          ,ipd.per_information26
          ,ipd.per_information27
          ,ipd.per_information28
          ,ipd.per_information29
          ,ipd.per_information30
          ,ipd.creation_date
          ,usr.user_id
          ,usr.employee_id
          ,ipd.allow_access
          ,ipd.user_guid
          ,ipd.visitor_resp_key
          ,ipd.visitor_resp_appl_id
          ,ipd.security_group_key
    from  irc_pending_data ipd, fnd_user usr
    where upper(ipd.email_address) = usr.user_name(+)
    and ipd.processed is null
    order by ipd.creation_date asc;
    --
    --
    -- Query built similar to JobsAppliedForVO query
    --
    cursor csr_job_applied_for(p_person_id in number, p_vacancy_id in number) is
      select 1
        from per_all_assignments_f asg,
             per_assignment_status_types_v ast,
             per_all_people_f ppf,
             irc_assignment_statuses ias,
             per_all_people_f  linkppf,
             per_assignment_status_types_v ast1
      where asg.vacancy_id = p_vacancy_id
        and asg.effective_start_date=(select max(effective_start_date)
                                        from per_assignments_f asg2
                                       where asg.assignment_id=asg2.assignment_id
                                         and asg2.effective_start_date<=sysdate+1)
        and asg.person_id = ppf.person_id
        and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
        and linkppf.person_id = p_person_id
        and asg.assignment_id = ias.assignment_id
        and asg.assignment_status_type_id = ast1.assignment_status_type_id
        and (ias.assignment_status_id = (select max(inn.assignment_status_id)
                                           from irc_assignment_statuses inn
                                          where inn.assignment_id = asg.assignment_id)
            or ias.assignment_status_id is null)
        and ias.assignment_status_type_id = ast.assignment_status_type_id
        and ppf.party_id = linkppf.party_id
        and trunc(sysdate) between linkppf.effective_start_date and linkppf.effective_end_date;
    --
    -- Cursor to check if the Vacancy is an Internal vacancy
    -- to prevent it from being applied by Employees
    -- External Candidates won't be displayed Internal vacancies so we don't have
    -- to check their applications
    --
    cursor csr_is_internal_vacancy(p_vacancy_id in number, p_application_date in date) is
      select 1 from per_all_vacancies pav, per_recruitment_activities pra,
                                        per_recruitment_activity_for prf, irc_all_recruiting_sites ias
          where pav.vacancy_id = prf.vacancy_id AND
                prf.recruitment_activity_id  = pra.recruitment_activity_id AND
            trunc(p_application_date) between PRA.date_start and nvl(PRA.date_end,trunc(p_application_date))
            AND pra.recruiting_site_id = ias.recruiting_site_id and ias.internal='Y'
            and pav.vacancy_id = p_vacancy_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  for l_data in csr_get_data loop
    --
    if l_data.user_id is null then
      open csr_get_user_id(substr(FND_WEB_SEC.GET_GUEST_USERNAME_PWD()
                        ,0
                        ,instr(FND_WEB_SEC.GET_GUEST_USERNAME_PWD(),'/')-1));
      fetch csr_get_user_id into l_user_id;
      close csr_get_user_id;
    else
      l_user_id := l_data.user_id;
    end if;
    --
    open csr_get_resp_id(l_data.visitor_resp_key);
    fetch csr_get_resp_id into l_resp_id,l_appl_id;
    close csr_get_resp_id;
    --
    open csr_get_sg_id(l_data.security_group_key);
    fetch csr_get_sg_id into l_sg_id;
    close csr_get_sg_id;
    --
    open csr_get_server_id;
    fetch csr_get_server_id into l_server_id;
    close csr_get_server_id;
    --
    hr_utility.set_location('Call to apps initialise'|| l_proc, 15);
    if l_server_id is null then
      fnd_global.apps_initialize
      (user_id          => l_user_id
      ,resp_id          => l_resp_id
      ,resp_appl_id     => l_data.visitor_resp_appl_id
      ,security_group_id=> l_sg_id);
    else
      fnd_global.apps_initialize
      (user_id          => l_user_id
      ,resp_id          => l_resp_id
      ,resp_appl_id     => l_data.visitor_resp_appl_id
      ,security_group_id=> l_sg_id
      ,server_id        => l_server_id);
    end if;
    --
    --
    -- Fetch the responsibility set in IRC_REG_RESP profile
    --
    l_resp_key := fnd_profile.value_specific
                (name => 'IRC_REGISTRATION_RESP'
                ,responsibility_id => l_resp_id
                ,application_id => 800
                );
    --
    -- Get responsibility id and application id for the above profile
    --
    open csr_get_resp_id(l_resp_key);
    fetch csr_get_resp_id into l_irc_resp_id,l_irc_resp_appl_id;
    close csr_get_resp_id;
    --
    hr_utility.set_location(l_proc, 20);
    --
    -- Fetch the registration business group
    --
    l_reg_bg_id := fnd_profile.value('IRC_REGISTRATION_BG_ID');

    --
    begin
      --
      l_person_id := null;
      --
      -- If user_id is NULL, create the FND user for this user
      --
      if l_data.user_id is null then
        irc_party_api.create_ha_processed_user(p_user_name         => l_data.email_address
                                              ,p_password          => l_data.user_password
                                              ,p_email             => l_data.email_address
                                              ,p_start_date        => trunc(l_data.creation_date)
                                              ,p_last_name         => l_data.last_name
                                              ,p_first_name        => l_data.first_name
                                              ,p_user_guid         => l_data.user_guid
                                              ,p_reg_bg_id         => l_reg_bg_id
                                              ,p_responsibility_id => l_irc_resp_id
                                              ,p_resp_appl_id      => l_irc_resp_appl_id
                                              ,p_security_group_id => l_sg_id
                                              ,p_language          => null
                                              ,p_allow_access      => l_data.allow_access);
        --
        l_new_user_id := null;
        --
        select employee_id, user_id into l_person_id, l_new_user_id
        from fnd_user
        where user_name = upper(l_data.email_address);
        --
        irc_party_api.process_ha_resp_check(p_user_id => l_new_user_id,
                                        p_responsibility_id => l_irc_resp_id,
                                        p_resp_appl_id => l_irc_resp_appl_id,
                                        p_security_group_id => l_sg_id,
                                        p_start_date => trunc(l_data.creation_date),
                                        p_server_id=>l_server_id);
        --
      else
        irc_party_api.process_ha_resp_check(p_user_id => l_data.user_id,
                                        p_responsibility_id => l_irc_resp_id,
                                        p_resp_appl_id => l_irc_resp_appl_id,
                                        p_security_group_id => l_sg_id,
                                        p_start_date => trunc(l_data.creation_date),
                                        p_server_id=>l_server_id);
      end if;

      l_irc_profile := irc_party_api.irec_profile_exists(p_user_name => l_data.email_address
                                                        ,p_reg_bg_id => l_reg_bg_id
                                                        ,p_responsibility_id => l_irc_resp_id
                                                        ,p_resp_appl_id => l_irc_resp_appl_id
                                                        ,p_security_group_id => l_sg_id);
      if l_irc_profile = 'NO_PROFILE' then
         irc_party_api.create_partial_user(p_user_name         => l_data.email_address
                                          ,p_start_date        => trunc(l_data.creation_date)
                                          ,p_last_name         => l_data.last_name
                                          ,p_first_name        => l_data.first_name
                                          ,p_reg_bg_id         => l_reg_bg_id
                                          ,p_responsibility_id => l_irc_resp_id
                                          ,p_resp_appl_id      => l_irc_resp_appl_id
                                          ,p_security_group_id => l_sg_id
                                          ,p_language          => null
                                          ,p_allow_access      => l_data.allow_access
                                          );
      end if;
         select employee_id into l_person_id
         from fnd_user
         where user_name = upper(l_data.email_address);
      --
      -- update pending data row to have the person_id
      --
      hr_utility.set_location(l_proc,40);
      update irc_pending_data
      set person_id = l_person_id
         ,last_update_date = trunc(sysdate)
      where pending_data_id = l_data.pending_data_id;
      commit;
      Fnd_file.put_line(FND_FILE.LOG,'Updated irc_pending_data with person_id:'||l_person_id);
      --
      -- create/update documents for users who have uploaded their resumes
      --
      hr_utility.set_location(l_proc, 45);
      open csr_get_resume(l_data.pending_data_id);
      fetch csr_get_resume into
        l_resume_file_name
       ,l_resume_description
       ,l_resume_mime_type
       ,l_resume
       ,l_document_id
       ,l_doc_ovn
       ,l_doc_person_id
       ,l_doc_party_id
       ,l_assignment_id;
      -- Fix for bug 4183508, bug 5948412
      -- check if above cursor fetched some value otherwise set the document
      -- variables to NULL
      if csr_get_resume%notfound then
        l_resume_file_name := null;
        l_document_id := null;
        l_doc_ovn := null;
	l_new_doc_id := null;
	l_assignment_id := null;
	l_doc_person_id := null;
	l_doc_party_id := null;
      end if;
      close csr_get_resume;
      --
      hr_utility.set_location(l_proc,50);
      --
      if l_resume_file_name is not null then
        if l_document_id is not null then
          hr_utility.set_location(l_proc, 55);
           Fnd_file.put_line(FND_FILE.LOG,'Updating resume document for the Candidate: '||l_resume_file_name||': document_id='||l_document_id);
          irc_document_api.update_document_track
            (p_effective_date        =>   l_data.creation_date
            ,p_document_id           =>   l_document_id
            ,p_mime_type             =>   l_resume_mime_type
            ,p_type                  =>   'RESUME'
            ,p_file_name             =>   l_resume_file_name
            ,p_description           =>   l_resume_description
	    ,p_person_id	     =>   l_doc_person_id
	    ,p_party_id		     =>   l_doc_party_id
	    ,p_end_date		     =>   l_end_date
	    ,p_assignment_id	     =>   l_assignment_id
            ,p_object_version_number =>   l_doc_ovn
	    ,p_new_doc_id	     =>   l_new_doc_id
            );
          Fnd_file.put_line(FND_FILE.LOG,'Updated Resume document for the Candidate:'||l_document_id);
	  If l_document_id <> l_new_doc_id then
	  Fnd_file.put_line(FND_FILE.LOG,'Created Resume document for the Candidate:'||l_new_doc_id);
	  end if;
        else
          hr_utility.set_location(l_proc, 60);
          Fnd_file.put_line(FND_FILE.LOG,'Creating resume document for the Candidate: '||l_resume_file_name);
          irc_document_api.create_document
          (p_effective_date          =>   l_data.creation_date
          ,p_type                    =>   'RESUME'
          ,p_person_id               =>   l_person_id
          ,p_mime_type               =>   l_resume_mime_type
          ,p_file_name               =>   l_resume_file_name
          ,p_description             =>   l_resume_description
          ,p_document_id             =>   l_new_doc_id
          ,p_object_version_number   =>   l_doc_ovn
          );
          Fnd_file.put_line(FND_FILE.LOG,'Created new Resume document for the Candidate:'||l_resume_file_name);
        end if;
      end if;
      hr_utility.set_location(l_proc, 65);
      if l_new_doc_id is not null then
          update irc_documents set binary_doc=l_resume
          where document_id = l_new_doc_id;
          irc_document_api.process_document(l_new_doc_id);
      end if;
      --
      hr_utility.set_location(l_proc, 70);
      if l_data.vacancy_id is not null then
        -- fix for bug 4046889
        -- check if this Person is an Employee and if he is applying for an
        -- External vacancy
        Fnd_file.put_line(FND_FILE.LOG,'Checking if this applicant is an employee and is applying for an internal vacancy only:');
        l_person_type := irc_utilities_pkg.get_emp_spt_for_person(p_person_id=>l_person_id, p_eff_date=>trunc(l_data.creation_date));
        if (l_person_type = 'EMP') then
          open csr_is_internal_vacancy(l_data.vacancy_id, trunc(l_data.creation_date));
          fetch csr_is_internal_vacancy into l_num;
          if csr_is_internal_vacancy%notfound then
            hr_utility.set_location(l_proc, 72);
            close csr_is_internal_vacancy;
            Fnd_file.put_line(FND_FILE.LOG,'Employee cannot apply for External Vacancy:'||l_data.vacancy_id);
            hr_utility.set_message(800,'IRC_412140_JOB_NOT_AVAILABLE');
            hr_utility.raise_error;
          else
            close csr_is_internal_vacancy;
          end if;
        end if;
        -- check if this person has already applied in the Vacancy BG
        Fnd_file.put_line(FND_FILE.LOG,'Checking if this person has already applied for a vacancy in this BG:');
        open csr_get_person_id_in_vac_bg(l_person_id,l_data.vacancy_id);
        fetch csr_get_person_id_in_vac_bg
            into l_applicant_person_id
                ,l_appl_ovn
                ,l_emp_number;
        if csr_get_person_id_in_vac_bg%notfound then
            select per_people_s.nextval into l_applicant_person_id from dual;
            -- fix for bug 4018218
            -- make this value as NULL because we are in a loop and if in the
            -- first loop we have a valid value and in second loop we have to
            -- clear it otherwise we send the value in first loop
            l_emp_number:=null;
            hr_utility.set_location(l_proc,75);
        end if;

        /* process the vacancy application. We create a new user if needed in
         Vacancy BG and then update person record with EEO information
         after applying the processed flag is changed to 'A' so that if process
         run again 'A' rows won't be picked up.
         these API calls are present in PerAllPeopleFEOImpl.java */

        select per_assignments_s.nextval into l_applicant_assg_id from dual;

        hr_utility.set_location(l_proc, 80);

        l_per_ovn := null;
        l_asg_ovn := null;
        l_applicant_number := null;
        --
        if csr_get_person_id_in_vac_bg%found then
          --
          -- Check if Job Already Applied For
          --
          open csr_job_applied_for(l_person_id, l_data.vacancy_id);
          fetch csr_job_applied_for into l_num;
          if csr_job_applied_for%found then
            hr_utility.set_location(l_proc, 82);
            close csr_job_applied_for;
            Fnd_file.put_line(FND_FILE.LOG,'Already applied for job:'||l_data.vacancy_id);
            hr_utility.set_message(800,'IRC_APL_ALREADY_APPLIED');
            hr_utility.raise_error;
          else
            close csr_job_applied_for;
          end if;
        end if;
        Fnd_file.put_line(FND_FILE.LOG,'Applying for Job Vacancy:'||l_data.vacancy_id);
        -- call the registered_user_application API to create the Job application
        irc_party_api.registered_user_application
        (p_effective_date            => l_data.creation_date
        ,p_recruitment_person_id     => l_person_id
        ,p_person_id                 => l_applicant_person_id
        ,p_assignment_id             => l_applicant_assg_id
        ,p_application_received_date => l_data.creation_date
        ,p_vacancy_id                => l_data.vacancy_id
        ,p_posting_content_id        => l_data.posting_content_id
        ,p_per_object_version_number => l_per_ovn
        ,p_asg_object_version_number => l_asg_ovn
        ,p_applicant_number          => l_applicant_number
        );
        Fnd_file.put_line(FND_FILE.LOG,'Applied successfully for vacancy:'||l_data.vacancy_id);
        --
        hr_utility.set_location(l_proc, 83);
        hr_person_api.update_person
        (p_effective_date           => l_data.creation_date
        ,p_person_id                => l_applicant_person_id
        ,p_datetrack_update_mode    => 'CORRECTION'
        ,p_object_version_number    => l_per_ovn
        ,p_last_name                => l_data.last_name
        ,p_date_of_birth            => nvl(l_data.date_of_birth,hr_api.g_date)
        ,p_email_address            => l_data.email_address
        ,p_first_name               => l_data.first_name
        ,p_sex                      => nvl(l_data.sex,hr_api.g_varchar2)
        ,p_employee_number          => l_emp_number
        ,p_per_information_category => nvl(l_data.per_information_category,hr_api.g_varchar2)
        ,p_per_information1         => nvl(l_data.per_information1,hr_api.g_varchar2)
        ,p_per_information2         => nvl(l_data.per_information2,hr_api.g_varchar2)
        ,p_per_information3         => nvl(l_data.per_information3,hr_api.g_varchar2)
        ,p_per_information4         => nvl(l_data.per_information4,hr_api.g_varchar2)
        ,p_per_information5         => nvl(l_data.per_information5,hr_api.g_varchar2)
        ,p_per_information6         => nvl(l_data.per_information6,hr_api.g_varchar2)
        ,p_per_information7         => nvl(l_data.per_information7,hr_api.g_varchar2)
        ,p_per_information8         => nvl(l_data.per_information8,hr_api.g_varchar2)
        ,p_per_information9         => nvl(l_data.per_information9,hr_api.g_varchar2)
        ,p_per_information10        => nvl(l_data.per_information10,hr_api.g_varchar2)
        ,p_per_information11        => nvl(l_data.per_information11,hr_api.g_varchar2)
        ,p_per_information12        => nvl(l_data.per_information12,hr_api.g_varchar2)
        ,p_per_information13        => nvl(l_data.per_information13,hr_api.g_varchar2)
        ,p_per_information14        => nvl(l_data.per_information14,hr_api.g_varchar2)
        ,p_per_information15        => nvl(l_data.per_information15,hr_api.g_varchar2)
        ,p_per_information16        => nvl(l_data.per_information16,hr_api.g_varchar2)
        ,p_per_information17        => nvl(l_data.per_information17,hr_api.g_varchar2)
        ,p_per_information18        => nvl(l_data.per_information18,hr_api.g_varchar2)
        ,p_per_information19        => nvl(l_data.per_information19,hr_api.g_varchar2)
        ,p_per_information20        => nvl(l_data.per_information20,hr_api.g_varchar2)
        ,p_per_information21        => nvl(l_data.per_information21,hr_api.g_varchar2)
        ,p_per_information22        => nvl(l_data.per_information22,hr_api.g_varchar2)
        ,p_per_information23        => nvl(l_data.per_information23,hr_api.g_varchar2)
        ,p_per_information24        => nvl(l_data.per_information24,hr_api.g_varchar2)
        ,p_per_information25        => nvl(l_data.per_information25,hr_api.g_varchar2)
        ,p_per_information26        => nvl(l_data.per_information26,hr_api.g_varchar2)
        ,p_per_information27        => nvl(l_data.per_information27,hr_api.g_varchar2)
        ,p_per_information28        => nvl(l_data.per_information28,hr_api.g_varchar2)
        ,p_per_information29        => nvl(l_data.per_information29,hr_api.g_varchar2)
        ,p_per_information30        => nvl(l_data.per_information30,hr_api.g_varchar2)
        ,p_effective_start_date     => l_effective_start_date
        ,p_effective_end_date       => l_effective_end_date
        ,p_full_name                => l_full_name
        ,p_comment_id               => l_comment_id
        ,p_name_combination_warning => l_name_combination_warning
        ,p_assign_payroll_warning   => l_assign_payroll_warning
        ,p_orig_hire_warning        => l_orig_hire_warning
        );
        Fnd_file.put_line(FND_FILE.LOG,'Updated person record with EEO information');
        close csr_get_person_id_in_vac_bg;
      end if;
      hr_utility.set_location(l_proc, 90);
      --
      -- Update the processed status to 'A'
      --
      update irc_pending_data
      set processed='A'
         ,last_update_date = trunc(sysdate)
      where pending_data_id = l_data.pending_data_id;
      commit;
      --
      exception
        when others then
          rollback;
          if csr_get_person_id_in_vac_bg%isopen then
            close csr_get_person_id_in_vac_bg;
          end if;
          l_err_num := SQLCODE;
          l_err_msg := SUBSTR(SQLERRM, 1, 4000);
          l_msg := SUBSTR(l_err_msg,(INSTR(l_err_msg,':')+1),4000);
          update irc_pending_data ipd
          set ipd.processed='F'
             ,ipd.error_message=l_msg
             ,ipd.last_update_date=trunc(sysdate)
          where ipd.pending_data_id=l_data.pending_data_id;
          Fnd_file.put_line(FND_FILE.LOG,'An error occurred--'||l_err_msg);
          hr_utility.set_location('Leaving '||l_proc, 100);
          commit;
      end;
   end loop;
end PROCESS_APPLICATIONS;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< SEND_NOTIFICATIONS >---------------------------|
-- ----------------------------------------------------------------------------
procedure send_notifications is
  cursor csr_get_applied_vacancies is
    select ipd.pending_data_id
          ,ipd.posting_content_id
          ,ipd.email_address
          ,ipd.processed
          ,ipd.error_message
          ,ipd.resume_file_name
          ,pav.name
    from irc_pending_data ipd
        ,per_all_vacancies pav
    where ipd.vacancy_id = pav.vacancy_id(+)
    and ipd.processed in ('A','R','E','F')
    order by ipd.email_address, ipd.creation_date desc;
  --
  cursor csr_is_new_user(p_email_address in varchar2) is
   select ipd.user_password
   from irc_pending_data ipd
   where ipd.email_address = p_email_address
   and ipd.user_password is not null;
  --
  cursor csr_posting_title(p_posting_content_id in number) is
    select ipc.job_title
    from irc_posting_contents_vl ipc
    where ipc.posting_content_id = p_posting_content_id;
  --
  type vacancies_table is
    table of per_all_vacancies.name%type
    index by binary_integer;
  --
  type comments_table is
    table of varchar2(1000)
    index by binary_integer;
  --
  type postings_table is
    table of irc_posting_contents_vl.job_title%type
    index by binary_integer;
  --
  l_resume varchar2(30);
  l_curr_email irc_pending_data.email_address%type;
  l_msg_html varchar2(32000);
  l_msg_text varchar2(32000);
  l_new_user_text varchar2(240);
  l_success_vacancies_list vacancies_table;
  l_success_vac_comments_list comments_table;
  l_failed_vacancies_list vacancies_table;
  l_failed_vac_comments_list comments_table;
  l_success_postings_list postings_table;
  l_failed_postings_list postings_table;
  l_notif_id number;
  l_password irc_pending_data.user_password%type;
  l_decrypted_password irc_pending_data.user_password%type;
  l_display_name varchar2(300); -- vacancy name plus postings title
  l_proc varchar2(72) := g_package||'SEND_NOTIFICATIONS';

  vac_rows number;
  com_rows number;
  vac_rows1 number;
  com_rows1 number;
  curr_row number;
--
begin
  vac_rows := 1;
  com_rows := 1;
  vac_rows1 := 1;
  com_rows1 := 1;
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  Fnd_file.put_line(FND_FILE.LOG,'Sending Notifications');
  --
  /* Process the pending data records having statuses 'A','R','E' or 'F'
     and having vacancy_id populated. For each of the records build the HTML
     test and send notifications to the user.
     Successful completion would set the processed status to 'S' */
  for l_applied_data in csr_get_applied_vacancies loop
  --
    Fnd_file.put_line(FND_FILE.LOG,'Checking the row with email_address: '||l_applied_data.email_address||' and pending_data_id '||l_applied_data.pending_data_id);
    hr_utility.set_location(l_proc, 20);
    --
    if l_applied_data.email_address <> l_curr_email
      and (l_success_vacancies_list.exists(1)
           or l_failed_vacancies_list.exists(1) ) then
      --
      hr_utility.set_location(l_proc, 25);
      Fnd_file.put_line(FND_FILE.LOG,'Building the notification text for '||l_curr_email);
      --
      -- Registration confirmation message to be shown to new users only
      --
      open csr_is_new_user(l_curr_email);
      fetch csr_is_new_user into l_password;
      if csr_is_new_user%found then
        fnd_message.set_name('PER', 'IRC_HA_NOTIF_NEW_USER_BODY');
        fnd_message.set_token('NAME', upper(l_curr_email));
        l_new_user_text := fnd_message.get;
        l_msg_html := l_msg_html|| '<BR>'||l_new_user_text || '<BR>';
        l_msg_text := l_msg_text|| '\n'||l_new_user_text || '\n';
      end if;
      --
      -- construct the HTML/text body containing the successful vacancies list
      -- append comments from each application
      --
      if l_success_vacancies_list.exists(1) then
        Fnd_file.put_line(FND_FILE.LOG,'Building list of successfull applications');
        --
        -- Construct html list of successful jobs applied for
        --
        l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_VAC_APPLD')
          || '<BR>';
        l_msg_text := l_msg_text|| '\n' ||fnd_message.get_string('PER','IRC_HA_NOTIF_VAC_APPLD')
          || '\n';
        --
        curr_row := 1;
        while (curr_row <> vac_rows) loop
          fnd_message.set_name('PER', 'IRC_HA_NOTIF_VAC_NAME');
          fnd_message.set_token('VACNAME', l_success_vacancies_list(curr_row));
          fnd_message.set_token('POSTNAME',l_success_postings_list(curr_row));
          l_display_name := fnd_message.get;
          l_msg_html := l_msg_html||l_display_name|| '<BR>';
          curr_row := curr_row+1;
        end loop;
        --
        -- Construct text list of successful jobs applied for
        --
        curr_row := 1;
        while (curr_row <> vac_rows) loop
          fnd_message.set_name('PER', 'IRC_HA_NOTIF_VAC_NAME');
          fnd_message.set_token('VACNAME', l_success_vacancies_list(curr_row));
          fnd_message.set_token('POSTNAME',l_success_postings_list(curr_row));
          l_display_name := fnd_message.get;
          l_msg_text := l_msg_text||l_display_name|| '\n';
          curr_row := curr_row+1;
        end loop;
        vac_rows := 1;
        com_rows := 1;
      end if;
      --
      -- construct the HTML/text body containing the failed vacancies list
      -- append comments from each application
      --
      if l_failed_vacancies_list.exists(1) then
        Fnd_file.put_line(FND_FILE.LOG,'Building list of failed applications');
        --
        -- Construct html list of failed jobs applied for
        --
        l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_VAC_FAILED')
          || '<BR>';
        l_msg_text := l_msg_text|| '\n' ||fnd_message.get_string('PER','IRC_HA_NOTIF_VAC_FAILED')
          || '\n';
        --
        curr_row := 1;
        while (curr_row <> vac_rows1) loop
          fnd_message.set_name('PER', 'IRC_HA_NOTIF_VAC_NAME');
          fnd_message.set_token('VACNAME', l_failed_vacancies_list(curr_row));
          fnd_message.set_token('POSTNAME',l_failed_postings_list(curr_row));
          l_display_name := fnd_message.get;
          l_msg_html := l_msg_html||l_display_name|| ' - ';
          l_msg_html := l_msg_html||l_failed_vac_comments_list(curr_row)|| '<BR>';
          curr_row := curr_row+1;
        end loop;
        --
        -- Construct text list of failed jobs applied for
        --
        curr_row := 1;
        while (curr_row <> vac_rows1) loop
          fnd_message.set_name('PER', 'IRC_HA_NOTIF_VAC_NAME');
          fnd_message.set_token('VACNAME', l_failed_vacancies_list(curr_row));
          fnd_message.set_token('POSTNAME',l_failed_postings_list(curr_row));
          l_display_name := fnd_message.get;
          l_msg_text := l_msg_text||l_display_name|| ' - ';
          l_msg_text := l_msg_text||l_failed_vac_comments_list(curr_row)|| '\n';
          curr_row := curr_row+1;
        end loop;
        vac_rows1 := 1;
        com_rows1 := 1;
      end if;
      --
      --
      if l_resume = 'true' then
        Fnd_file.put_line(FND_FILE.LOG,'Resume has been uploaded by the applicant and successfully parsed');
        --
        -- add additional message to notify successful resume parsing
        --
        l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_RES_PASS')
            || '<BR>';
        l_msg_text := l_msg_text|| '\n'||fnd_message.get_string('PER','IRC_HA_NOTIF_RES_PASS')
            || '\n';
        --
      elsif l_resume = 'false' then
        Fnd_file.put_line(FND_FILE.LOG,'Resume has been uploaded by the applicant and parsing failed');
        --
        -- add additional message to indicate failed resume parsing
        --
        l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_RES_FAILED')
            || '<BR>';
        l_msg_text := l_msg_text|| '\n'||fnd_message.get_string('PER','IRC_HA_NOTIF_RES_FAILED')
            || '\n';
      end if;
      --
      --  Append a generic message
      --
      l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_MISC_TEXT')
            || '<BR>';
      l_msg_text := l_msg_text|| '\n'||fnd_message.get_string('PER','IRC_HA_NOTIF_MISC_TEXT')
            || '\n';
      --
      hr_utility.set_location(l_proc, 30);
      --
      -- Notify with different subjects for a new user and existing user
      --
      if csr_is_new_user%found then
        close csr_is_new_user;
        Fnd_file.put_line(FND_FILE.LOG,'Notifying the user with subject line about registration and job application');
        l_notif_id := irc_notification_helper_pkg.send_notification
                     (p_user_name => l_curr_email
                     ,p_subject   => fnd_message.get_string('PER','IRC_HA_NOTIF_NEW_USER_SUBJ')
                     ,p_html_body => l_msg_html
                     ,p_text_body => l_msg_text
                     ,p_from_role => 'SYSADMIN'
                     );
      else
        close csr_is_new_user;
        Fnd_file.put_line(FND_FILE.LOG,'Notifying the user with subject line about job application');
        l_notif_id := irc_notification_helper_pkg.send_notification
                     (p_user_name => l_curr_email
                     ,p_subject   => fnd_message.get_string('PER','IRC_APL_JOBAPPL_NOTIF_SUBJECT')
                     ,p_html_body => l_msg_html
                     ,p_text_body => l_msg_text
                     ,p_from_role => 'SYSADMIN'
                     );
      end if;
      commit;
      l_success_vacancies_list.delete;
      l_success_vac_comments_list.delete;
      l_failed_vacancies_list.delete;
      l_failed_vac_comments_list.delete;
      l_resume := null;
      l_msg_text := null;
      l_msg_html := null;
    end if;
    if l_applied_data.processed = 'F' then
      vac_rows1 := vac_rows1+1;
      com_rows1 := com_rows1+1;
    else
      vac_rows := vac_rows+1;
      com_rows := com_rows+1;
    end if;
    Fnd_file.put_line(FND_FILE.LOG,'Processing the row with status '||l_applied_data.processed);
    if  l_applied_data.processed = 'R' then
      l_resume := 'true';
      l_success_vacancies_list(vac_rows-1) := l_applied_data.name;
      open csr_posting_title(l_applied_data.posting_content_id);
      fetch csr_posting_title into l_success_postings_list(vac_rows-1);
      close csr_posting_title;
      l_success_vac_comments_list(com_rows-1) := fnd_message.get_string('PER','IRC_JOB_APPLY_NOTIF_SUCCESS');
    elsif l_applied_data.processed = 'A' then
      l_success_vacancies_list(vac_rows-1) := l_applied_data.name;
      open csr_posting_title(l_applied_data.posting_content_id);
      fetch csr_posting_title into l_success_postings_list(vac_rows-1);
      close csr_posting_title;
      l_success_vac_comments_list(com_rows-1) := fnd_message.get_string('PER','IRC_JOB_APPLY_NOTIF_SUCCESS');
    elsif l_applied_data.processed = 'F' then
      l_failed_vacancies_list(vac_rows1-1) := l_applied_data.name;
      open csr_posting_title(l_applied_data.posting_content_id);
      fetch csr_posting_title into l_failed_postings_list(vac_rows1-1);
      close csr_posting_title;
      l_failed_vac_comments_list(com_rows1-1) := l_applied_data.error_message;
    elsif l_applied_data.processed = 'E' then
      l_resume := 'false';
      l_success_vacancies_list(vac_rows-1) := l_applied_data.name;
      open csr_posting_title(l_applied_data.posting_content_id);
      fetch csr_posting_title into l_success_postings_list(vac_rows-1);
      close csr_posting_title;
      l_success_vac_comments_list(com_rows-1) := fnd_message.get_string('PER','IRC_JOB_APPLY_NOTIF_SUCCESS');
    end if;
    l_curr_email := l_applied_data.email_address;
    --
    --update processed to S for the current row
    --
    update irc_pending_data
    set processed='S'
       ,last_update_date=trunc(sysdate)
    where pending_data_id=l_applied_data.pending_data_id;
    Fnd_file.put_line(FND_FILE.LOG,'Updated the processed flag to S');
  end loop;
  Fnd_file.put_line(FND_FILE.LOG,'Building the message for the last user');
  --
  -- Registration confirmation message to be shown to new users only
  --
  open csr_is_new_user(l_curr_email);
  fetch csr_is_new_user into l_password;
  if csr_is_new_user%found then
    fnd_message.set_name('PER', 'IRC_HA_NOTIF_NEW_USER_BODY');
    fnd_message.set_token('NAME', upper(l_curr_email));
    l_new_user_text := fnd_message.get;
    l_msg_html := l_msg_html|| '<BR>'||l_new_user_text || '<BR>';
    l_msg_text := l_msg_text|| '\n'||l_new_user_text || '\n';
  end if;
  --
  -- Build msg for the last user and send notification
  -- also check if there are any users to be notified
  --
  if vac_rows > 1 or vac_rows1 > 1 then
    --
    -- construct the HTML/text body containing the successful vacancies list
    -- append comments from each application
    --
    if vac_rows > 1 then
      Fnd_file.put_line(FND_FILE.LOG,'Building list of successfull applications for last user');
      --
      -- Construct html list of successful jobs applied for
      --
      l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_VAC_APPLD')
          || '<BR>';
      l_msg_text := l_msg_text|| '\n' ||fnd_message.get_string('PER','IRC_HA_NOTIF_VAC_APPLD')
          || '\n';
      --
      curr_row := 1;
      while (curr_row <> vac_rows) loop
        fnd_message.set_name('PER', 'IRC_HA_NOTIF_VAC_NAME');
        fnd_message.set_token('VACNAME', l_success_vacancies_list(curr_row));
        fnd_message.set_token('POSTNAME',l_success_postings_list(curr_row));
        l_display_name := fnd_message.get;
        l_msg_html := l_msg_html||l_display_name|| '<BR>';
        curr_row := curr_row+1;
      end loop;
      --
      -- Construct text list of successful jobs applied for
      --
      curr_row := 1;
      while (curr_row <> vac_rows) loop
        fnd_message.set_name('PER', 'IRC_HA_NOTIF_VAC_NAME');
        fnd_message.set_token('VACNAME', l_success_vacancies_list(curr_row));
        fnd_message.set_token('POSTNAME',l_success_postings_list(curr_row));
        l_display_name := fnd_message.get;
        l_msg_text := l_msg_text||l_display_name|| '\n';
        curr_row := curr_row+1;
      end loop;
    end if;
    --
    if vac_rows1 > 1 then
      Fnd_file.put_line(FND_FILE.LOG,'Building list of failed applications for last user');
      --
      -- construct the HTML/text body containing the failed vacancies list
      -- append comments from each application
      --
      --
      -- Construct html list of failed jobs applied for
      --
      l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_VAC_FAILED')
          || '<BR>';
      l_msg_text := l_msg_text|| '\n' ||fnd_message.get_string('PER','IRC_HA_NOTIF_VAC_FAILED')
          || '\n';
      --
      curr_row := 1;
      while (curr_row <> vac_rows1) loop
        fnd_message.set_name('PER', 'IRC_HA_NOTIF_VAC_NAME');
        fnd_message.set_token('VACNAME', l_failed_vacancies_list(curr_row));
        fnd_message.set_token('POSTNAME',l_failed_postings_list(curr_row));
        l_display_name := fnd_message.get;
        l_msg_html := l_msg_html||l_display_name|| ' - ';
        l_msg_html := l_msg_html||l_failed_vac_comments_list(curr_row)|| '<BR>';
        curr_row := curr_row+1;
      end loop;
      --
      -- Construct text list of failed jobs applied for
      --
      curr_row := 1;
      while (curr_row <> vac_rows1) loop
        fnd_message.set_name('PER', 'IRC_HA_NOTIF_VAC_NAME');
        fnd_message.set_token('VACNAME', l_failed_vacancies_list(curr_row));
        fnd_message.set_token('POSTNAME',l_failed_postings_list(curr_row));
        l_display_name := fnd_message.get;
        l_msg_text := l_msg_text||l_display_name|| ' - ';
        l_msg_text := l_msg_text||l_failed_vac_comments_list(curr_row)|| '\n';
        curr_row := curr_row+1;
      end loop;
    end if;
    --
    if l_resume = 'true' then
      Fnd_file.put_line(FND_FILE.LOG,'Last user had a successfull resume parse');
      --
      -- add additional message to notify successful resume parsing
      --
      l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_RES_PASS')
          || '<BR>';
      l_msg_text := l_msg_text|| '\n'||fnd_message.get_string('PER','IRC_HA_NOTIF_RES_PASS')
          || '\n';
      --
    elsif l_resume = 'false' then
      Fnd_file.put_line(FND_FILE.LOG,'Last user had a unsuccessfull resume parse');
      --
      -- add additional message to indicate failed resume parsing
      --
      l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_RES_FAILED')
          || '<BR>';
      l_msg_text := l_msg_text|| '\n'||fnd_message.get_string('PER','IRC_HA_NOTIF_RES_FAILED')
          || '\n';
    end if;
    --
    --  Append a generic message
    --
    l_msg_html := l_msg_html|| '<BR>'||fnd_message.get_string('PER','IRC_HA_NOTIF_MISC_TEXT')
          || '<BR>';
    l_msg_text := l_msg_text|| '\n'||fnd_message.get_string('PER','IRC_HA_NOTIF_MISC_TEXT')
          || '\n';
    --
    if l_success_vacancies_list.exists(1) or
         l_failed_vacancies_list.exists(1) then
      hr_utility.set_location(l_proc, 70);
      --
      -- Notify with different subjects for a new user and existing user
      --
      if csr_is_new_user%found then
        close csr_is_new_user;
        Fnd_file.put_line(FND_FILE.LOG,'Notifying last user with subject line about registration and job application');
        l_notif_id := irc_notification_helper_pkg.send_notification
                     (p_user_name => l_curr_email
                     ,p_subject   => fnd_message.get_string('PER','IRC_HA_NOTIF_NEW_USER_SUBJ')
                     ,p_html_body => l_msg_html
                     ,p_text_body => l_msg_text
                     ,p_from_role => 'SYSADMIN'
                     );
      else
        close csr_is_new_user;
        Fnd_file.put_line(FND_FILE.LOG,'Notifying last user with subject line about job application');
        l_notif_id := irc_notification_helper_pkg.send_notification
                     (p_user_name => l_curr_email
                     ,p_subject   => fnd_message.get_string('PER','IRC_APL_JOBAPPL_NOTIF_SUBJECT')
                     ,p_html_body => l_msg_html
                     ,p_text_body => l_msg_text
                     ,p_from_role => 'SYSADMIN'
                     );
      end if;
      commit;
    end if;
  end if;
  hr_utility.set_location('Leaving '||l_proc, 80);
end send_notifications;
--
end IRC_PENDING_DATA_API;

/
