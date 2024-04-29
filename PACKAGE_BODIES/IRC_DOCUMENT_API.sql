--------------------------------------------------------
--  DDL for Package Body IRC_DOCUMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_DOCUMENT_API" as
/* $Header: iridoapi.pkb 120.3.12010000.3 2009/04/21 10:41:50 avarri ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_DOCUMENT_API.';
g_full_mode varchar2(30)   := 'FULL';
g_online_mode varchar2(30) := 'ONLINE';
g_none_mode varchar(30) :='NONE';
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
    if p_mode = g_full_mode
    then
      hr_utility.set_location(l_proc, 20);
      ad_ctx_ddl.optimize_index
      (idx_name=>l_hr_username||'.IRC_DOCUMENTS_CTX1'
      ,optlevel=>'FULL'
      ,maxtime=>null
      ,token=>null);
    elsif p_mode = g_online_mode
    then
      hr_utility.set_location(l_proc, 30);
      ad_ctx_ddl.sync_index
      (idx_name=>l_hr_username||'.IRC_DOCUMENTS_CTX1');
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
-- |----------------------------< CREATE_DOCUMENT >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_type                          in     varchar2
  ,p_person_id                     in     number
  ,p_mime_type                     in     varchar2
  ,p_assignment_id                 in     number   default null
  ,p_file_name                     in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_end_date                      in     date     default null
  ,p_document_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CREATE_DOCUMENT';
  l_effective_date        date;
  l_document_id           number(15);
  l_object_version_number number(9);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_DOCUMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := TRUNC(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    IRC_DOCUMENT_BK1.CREATE_DOCUMENT_b
    (p_effective_date                => l_effective_date
    ,p_type                          => p_type
    ,p_mime_type                     => p_mime_type
    ,p_person_id                     => p_person_id
    ,p_assignment_id                 => p_assignment_id
    ,p_file_name                     => p_file_name
    ,p_description                   => p_description
    ,p_end_date                      => p_end_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_DOCUMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
    irc_ido_ins.ins
    (p_effective_date                => l_effective_date
    ,p_person_id                     => p_person_id
    ,p_mime_type                     => p_mime_type
    ,p_type                          => p_type
    ,p_assignment_id                 => p_assignment_id
    ,p_character_doc                 => empty_clob()
    ,p_file_name                     => p_file_name
    ,p_description                   => p_description
    ,p_document_id                   => l_document_id
    ,p_parsed_xml                    => empty_clob()
    ,p_object_version_number         => l_object_version_number
    ,p_end_date                      => p_end_date
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_DOCUMENT_BK1.CREATE_DOCUMENT_a
    (p_effective_date                => l_effective_date
    ,p_type                          => p_type
    ,p_mime_type                     => p_mime_type
    ,p_person_id                     => p_person_id
    ,p_assignment_id                 => p_assignment_id
    ,p_file_name                     => p_file_name
    ,p_description                   => p_description
    ,p_document_id                   => l_document_id
    ,p_object_version_number         => l_object_version_number
    ,p_end_date                      => p_end_date
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_DOCUMENT'
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
  p_document_id            := l_document_id;
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_DOCUMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_document_id            := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_DOCUMENT;
    -- Reset IN OUT Parameters and set OUT parameters
    --
    p_document_id            := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_DOCUMENT;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_DOCUMENT >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_mime_type                     in     varchar2 default HR_API.G_VARCHAR2
  ,p_type                          in     varchar2 default HR_API.G_VARCHAR2
  ,p_file_name                     in     varchar2 default HR_API.G_VARCHAR2
  ,p_description                   in     varchar2 default HR_API.G_VARCHAR2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CREATE_DOCUMENT';
  l_effective_date        date;
  l_object_version_number number(9);
  l_new_doc_id            irc_documents.document_id%type;
  l_party_id              irc_documents.party_id%type;
  l_assignment_id         irc_documents.assignment_id%type;
  l_person_id             irc_documents.person_id%type;
  l_end_date              date;


--
-- Define cursor to fetch the document record
--
  cursor csr_document_record Is
  select
        party_id,
        assignment_id,
        person_id
  from  irc_documents
  where document_id = p_document_id;

  l_doc_record  csr_document_record%ROWTYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_DOCUMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := TRUNC(p_effective_date);

  --open the cursor and fetch the document record
  open  csr_document_record;
  fetch csr_document_record into l_doc_record;
  close csr_document_record;
  --
  --
  l_party_id            := l_doc_record.party_id;
  l_assignment_id       := l_doc_record.assignment_id;
  l_person_id           := l_doc_record.person_id;
  --

  --
  -- Call Before Process User Hook
  --
  begin
    IRC_DOCUMENT_BK2.UPDATE_DOCUMENT_b
    (p_effective_date                => l_effective_date
    ,p_document_id                   => p_document_id
    ,p_type                          => p_type
    ,p_mime_type                     => p_mime_type
    ,p_file_name                     => p_file_name
    ,p_description                   => p_description
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DOCUMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
    update_document_track
    ( p_validate                =>      p_validate
     ,p_effective_date          =>      l_effective_date
     ,p_document_id             =>      p_document_id
     ,p_mime_type               =>      p_mime_type
     ,p_type                    =>      p_type
     ,p_file_name               =>      p_file_name
     ,p_description             =>      p_description
     ,p_person_id               =>      l_person_id
     ,p_party_id                =>      l_party_id
     ,p_end_date                =>      l_end_date
     ,p_assignment_id           =>      l_assignment_id
     ,p_object_version_number   =>      l_object_version_number
     ,p_new_doc_id              =>      l_new_doc_id
    );

  --
  -- Call After Process User Hook
  --
  begin
    IRC_DOCUMENT_BK2.UPDATE_DOCUMENT_a
    (p_effective_date                => l_effective_date
    ,p_document_id                   => p_document_id
    ,p_type                          => p_type
    ,p_mime_type                     => p_mime_type
    ,p_file_name                     => p_file_name
    ,p_description                   => p_description
    ,p_object_version_number         => p_object_version_number
    );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DOCUMENT'
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
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_DOCUMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_DOCUMENT;
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_DOCUMENT;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_DOCUMENT_TRACK >---------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_DOCUMENT_TRACK
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_mime_type                     in     varchar2 default HR_API.G_VARCHAR2
  ,p_type                          in     varchar2 default HR_API.G_VARCHAR2
  ,p_file_name                     in     varchar2 default HR_API.G_VARCHAR2
  ,p_description                   in     varchar2 default HR_API.G_VARCHAR2
  ,p_person_id                     in     number   default HR_API.G_NUMBER
  ,p_party_id                      in     number   default HR_API.G_NUMBER
  ,p_end_date                      in     date     default HR_API.G_DATE
  ,p_assignment_id                 in     number   default HR_API.G_NUMBER
  ,p_object_version_number         in out nocopy number
  ,p_new_doc_id                    out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_DOCUMENT';
  l_effective_date        date;
  l_object_version_number number(9);
  --
  l_job_appln   number := 0;
  --
  l_end_date    date; --to populate end_date in irc_documents table for internet applicants
  --
  l_mime_type                   irc_documents.mime_type%type    := HR_API.G_VARCHAR2;
  l_type                        irc_documents.type%type         := HR_API.G_VARCHAR2;
  l_file_name                   irc_documents.file_name%type    := HR_API.G_VARCHAR2;
  l_description                 irc_documents.description%type  := HR_API.G_VARCHAR2;
  l_new_doc_id                  irc_documents.document_id%type;
  l_doc_id                      irc_documents.document_id%type;
  l_obj_version_number          number(9);


begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_utility.set_location('call function is_internet_applicant: '|| p_party_id || ' '|| l_proc, 115);
  --
  is_internet_applicant( p_document_id  =>  p_document_id,
                         p_person_id    =>  p_person_id  ,
                         p_party_id     =>  p_party_id   ,
                         p_num_job_applications => l_job_appln);

  --
   hr_utility.set_location('leave function is_internet_applicant: job applications: '|| to_char(l_job_appln), 116);
  --
  If ((l_job_appln > 0) and (p_type In ('RESUME','AUTO_RESUME')) )  Then
  begin --begin For update when it Is an Internet Applicant

        --The Applicant Is an Internet Applicant, so first update his existing Document record with an End
        --Date And Then create a new Document record with the new Resume he has uploaded
        begin   --begin For updating End Date And creating new Document record
          --
                  -- Issue a savepoint
                  --
                  savepoint UPDATE_DOCUMENT_TRACK;
                  --
                  -- Truncate the time portion from all IN date parameters
                  --
                  l_effective_date := TRUNC(p_effective_date);
                  --
                  l_end_date    := TRUNC(sysdate);


                  --
                  -- Call Before Process User Hook
                  --
                  begin
                    IRC_DOCUMENT_BK4.UPDATE_DOCUMENT_TRACK_b
                    (p_effective_date                => l_effective_date
                    ,p_document_id                   => p_document_id
                    ,p_type                          => p_type
                    ,p_mime_type                     => p_mime_type
                    ,p_file_name                     => p_file_name
                    ,p_description                   => p_description
                    ,p_person_id                     => p_person_id
                    ,p_party_id                      => p_party_id
                    ,p_assignment_id                 => p_assignment_id
                    ,p_object_version_number         => p_object_version_number
                    ,p_end_date                      => l_end_date
                    );

                  exception
                    when hr_api.cannot_find_prog_unit then
                      hr_api.cannot_find_prog_unit_error
                        (p_module_name => 'UPDATE_DOCUMENT_TRACK'
                        ,p_hook_type   => 'BP'
                        );
                  end;
                  --
                  -- Process Logic
                  --
                  l_object_version_number := p_object_version_number;
                    irc_ido_upd.upd
                    (p_effective_date                => l_effective_date
                    ,p_mime_type                     => l_mime_type
                    ,p_type                          => l_type
                    ,p_file_name                     => l_file_name
                    ,p_description                   => l_description
                    ,p_document_id                   => p_document_id
                    ,p_object_version_number         => l_object_version_number
                    ,p_end_date                      => l_end_date
                    );
                  --
                  -- Call After Process User Hook
                  --
                  begin
                    IRC_DOCUMENT_BK4.UPDATE_DOCUMENT_TRACK_a
                    (p_effective_date                => l_effective_date
                    ,p_document_id                   => p_document_id
                    ,p_type                          => p_type
                    ,p_mime_type                     => p_mime_type
                    ,p_file_name                     => p_file_name
                    ,p_description                   => p_description
                    ,p_person_id                     => p_person_id
                    ,p_party_id                      => p_party_id
                    ,p_assignment_id                 => p_assignment_id
                    ,p_object_version_number         => p_object_version_number
                    ,p_end_date                      => l_end_date
                    );

                  exception
                    when hr_api.cannot_find_prog_unit then
                      hr_api.cannot_find_prog_unit_error
                        (p_module_name => 'UPDATE_DOCUMENT_TRACK'
                        ,p_hook_type   => 'AP'
                        );
                  end;
                  --

                  --Select the Document id from the db sequence
                  --
                  begin
                        select irc_documents_s.nextval
                        into    l_new_doc_id
                        from    dual;
                  end;
                  --
                  --Call the setbase key value procedure In the row handler
                  --
                  irc_ido_ins.set_base_key_value
                    (p_document_id => l_new_doc_id
                    );
                  --

                  hr_utility.set_location('call create_document to create new record'||l_proc,117);
                  --
                  create_document
                  (p_validate                   =>  p_validate
                  ,p_effective_date             =>  p_effective_date
                  ,p_type                       =>  p_type
                  ,p_person_id                  =>  p_person_id
                  ,p_mime_type                  =>  p_mime_type
                  ,p_assignment_id              =>  p_assignment_id
                  ,p_file_name                  =>  p_file_name
                  ,p_description                =>  p_description
                  ,p_end_date                   =>  p_end_date
                  ,p_document_id                =>  l_doc_id
                  ,p_object_version_number      =>  l_obj_version_number );
                  --
                  hr_utility.set_location('end call create_document to create new record'||l_proc,118);
                  --
                  -- When in validation only mode raise the Validate_Enabled exception
                  --
                  if p_validate then
                    raise hr_api.validate_enabled;
                  end if;
                  --
                  -- Set all output arguments
                  --
                  p_object_version_number  := l_obj_version_number;
                  p_new_doc_id             := l_new_doc_id;
                  hr_utility.set_location(' Leaving:'||l_proc, 70);
                  --
                exception
                  when hr_api.validate_enabled then
                    --
                    -- As the Validate_Enabled exception has been raised
                    -- we must rollback to the savepoint
                    --
                    rollback to UPDATE_DOCUMENT_TRACK;
                    --
                    -- Only set output warning arguments
                    -- (Any key or derived arguments must be set to null
                    -- when validation only mode is being used.)
                    --
                    p_object_version_number  := l_obj_version_number;
                    p_new_doc_id             := l_new_doc_id;
                    hr_utility.set_location(' Leaving:'||l_proc, 80);
                  when others then
                    --
                    -- A validation or unexpected error has occured
                    --
                    rollback to UPDATE_DOCUMENT_TRACK;
                    --
                    p_object_version_number  := l_obj_version_number;
                    p_new_doc_id             := l_new_doc_id;
                    hr_utility.set_location(' Leaving:'||l_proc, 90);
                    raise;
            end; --End For updating End Date And creating new Document record
            --

  End;--End For when it Is an Internet Applicant
  Else
  begin --begin when the applicant Is Not an Internet Applicant
  --
          begin --begin 1
          --
                  -- Issue a savepoint
                  --
                  savepoint UPDATE_DOCUMENT_TRACK;
                  --
                  -- Truncate the time portion from all IN date parameters
                  --
                  l_effective_date := TRUNC(p_effective_date);

                  --
                  -- Call Before Process User Hook
                  --
                  begin
                    IRC_DOCUMENT_BK4.UPDATE_DOCUMENT_TRACK_b
                    (p_effective_date                => l_effective_date
                    ,p_document_id                   => p_document_id
                    ,p_type                          => p_type
                    ,p_mime_type                     => p_mime_type
                    ,p_file_name                     => p_file_name
                    ,p_description                   => p_description
                    ,p_person_id                     => p_person_id
                    ,p_party_id                      => p_party_id
                    ,p_assignment_id                 => p_assignment_id
                    ,p_object_version_number         => p_object_version_number
                    ,p_end_date                      => p_end_date
                    );

                  exception
                    when hr_api.cannot_find_prog_unit then
                      hr_api.cannot_find_prog_unit_error
                        (p_module_name => 'UPDATE_DOCUMENT_TRACK'
                        ,p_hook_type   => 'BP'
                        );
                  end;
                  --
                  -- Process Logic
                  --
                  l_object_version_number := p_object_version_number;
                    irc_ido_upd.upd
                    (p_effective_date                => l_effective_date
                    ,p_mime_type                     => p_mime_type
                    ,p_type                          => p_type
                    ,p_file_name                     => p_file_name
                    ,p_description                   => p_description
                    ,p_document_id                   => p_document_id
                    ,p_object_version_number         => l_object_version_number
                    ,p_end_date                      => p_end_date
                    );
                  --
                  -- Call After Process User Hook
                  --
                  begin
                    IRC_DOCUMENT_BK4.UPDATE_DOCUMENT_TRACK_a
                    (p_effective_date                => l_effective_date
                    ,p_document_id                   => p_document_id
                    ,p_type                          => p_type
                    ,p_mime_type                     => p_mime_type
                    ,p_file_name                     => p_file_name
                    ,p_description                   => p_description
                    ,p_person_id                     => p_person_id
                    ,p_party_id                      => p_party_id
                    ,p_assignment_id                 => p_assignment_id
                    ,p_object_version_number         => p_object_version_number
                    ,p_end_date                      => p_end_date
                    );

                  exception
                    when hr_api.cannot_find_prog_unit then
                      hr_api.cannot_find_prog_unit_error
                        (p_module_name => 'UPDATE_DOCUMENT_TRACK'
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
                  p_object_version_number  := l_object_version_number;
                  p_new_doc_id             := p_document_id;
                  hr_utility.set_location(' Leaving:'||l_proc, 70);
                exception
                  when hr_api.validate_enabled then
                    --
                    -- As the Validate_Enabled exception has been raised
                    -- we must rollback to the savepoint
                    --
                    rollback to UPDATE_DOCUMENT_TRACK;
                    --
                    -- Only set output warning arguments
                    -- (Any key or derived arguments must be set to null
                    -- when validation only mode is being used.)
                    --
                    p_object_version_number  := l_object_version_number;
                    p_new_doc_id             := p_document_id;
                    hr_utility.set_location(' Leaving:'||l_proc, 80);
                  when others then
                    --
                    -- A validation or unexpected error has occured
                    --
                    rollback to UPDATE_DOCUMENT_TRACK;
                    --
                    p_object_version_number  := l_object_version_number;
                    p_new_doc_id             := p_document_id;
                    hr_utility.set_location(' Leaving:'||l_proc, 90);
                    raise;
            end; --End 1
            --

    end; --End For when the Applicant Is Not an Internet Applicant
    End if;
    --
end UPDATE_DOCUMENT_TRACK;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< DELETE_DOCUMENT >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_document_id                   in     number
  ,p_object_version_number         in     number
  ,p_person_id                     in     number
  ,p_party_id                      in     number
  ,p_end_date                      in     date
  ,p_type                          in     varchar2
  ,p_purge                         in     varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date        date;
  l_proc                  varchar2(72) := g_package||'DELETE_DOCUMENT';

  --
  l_end_date              date;
  --
  l_job_applications  number := 0;
  --
  l_object_version_number         number;
  --
  l_doc_id      number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Issue a savepoint
  --
    savepoint DELETE_DOCUMENT;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  --
  l_end_date       := TRUNC(sysdate);
  --
  l_object_version_number := p_object_version_number;
  --
  hr_utility.set_location('call function is_internet_applicant: '|| p_party_id || ' '|| l_proc, 111);
  --
  is_internet_applicant( p_document_id  =>  p_document_id,
                         p_person_id    =>  p_person_id  ,
                         p_party_id     =>  p_party_id   ,
                         p_num_job_applications => l_job_applications);


  --
   hr_utility.set_location('leave function is_internet_applicant: job applications: '|| to_char(l_job_applications), 112);
  --

  --
                --
                -- Call Before Process User Hook
                --
                begin
                        IRC_DOCUMENT_BK3.DELETE_DOCUMENT_b
                            (p_document_id                   => p_document_id
                            ,p_effective_date                => l_effective_date
                            ,p_object_version_number         => p_object_version_number
                            ,p_person_id                     => p_person_id
                            ,p_party_id                      => p_party_id
                            ,p_end_date                      => p_end_date
                            ,p_type                          => p_type
                            ,p_purge                         => p_purge
                            );

                          exception
                            when hr_api.cannot_find_prog_unit then
                              hr_api.cannot_find_prog_unit_error
                                (p_module_name => 'DELETE_DOCUMENT'
                                ,p_hook_type   => 'BP'
                                );
                end;
                --

                  --check If the applicant Is an Internet Applicant
                  --Active application In any of the BG which has Applicant Tracking enabled
                  --Call the Function is_internet_applicant which returns True If the above
                  --condition Is true
                If ((p_purge = 'N') and (l_job_applications > 0) and (p_type In ('RESUME','AUTO_RESUME')) )  Then
                begin
                        hr_utility.set_location('call update document: '||l_proc,113);
                        --call the update document rowhandler to update the end_date for the document
                        irc_ido_upd.upd
                        (p_effective_date                => l_effective_date
                        ,p_type                          => p_type
                        ,p_document_id                   => p_document_id
                        ,p_object_version_number         => l_object_version_number
                        ,p_end_date                      => l_end_date
                        );

                end;
                else
                begin
                        -- Process Logic
                        --
                        irc_ido_del.del
                        (p_document_id                   => p_document_id
                        ,p_object_version_number         => p_object_version_number
                        );
                --
                end;
                end if;


                -- Call After Process User Hook
                --
                begin
                        IRC_DOCUMENT_BK3.DELETE_DOCUMENT_a
                                (p_document_id                   => p_document_id
                                ,p_effective_date                => l_effective_date
                                ,p_object_version_number         => p_object_version_number
                                ,p_person_id                 => p_person_id
                                ,p_party_id                          => p_party_id
                                ,p_end_date                          => p_end_date
                                ,p_type                         =>    p_type
                                ,p_purge                             => p_purge
                                );

                          exception
                            when hr_api.cannot_find_prog_unit then
                              hr_api.cannot_find_prog_unit_error
                                (p_module_name => 'DELETE_DOCUMENT'
                                ,p_hook_type   => 'AP'
                                );

                end;

                 if p_validate then
                 raise hr_api.validate_enabled;
                 end if;

                 hr_utility.set_location(' Leaving:'||l_proc, 70);

                 exception
                  when hr_api.validate_enabled then
                    --
                    -- As the Validate_Enabled exception has been raised
                    -- we must rollback to the savepoint
                    --
                    rollback to DELETE_DOCUMENT;
                    hr_utility.set_location(' Leaving:'||l_proc, 80);
                  when others then
                    --
                    -- A validation or unexpected error has occured
                    --
                    rollback to DELETE_DOCUMENT;
                    hr_utility.set_location(' Leaving:'||l_proc, 90);
                    raise;


end DELETE_DOCUMENT;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< PROCESS_DOCUMENT >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure PROCESS_DOCUMENT
  (p_document_id                   in     number
  ) IS
--
  l_proc varchar2(72) := g_package||'PROCESS_DOCUMENT';
--
-- Cursor to ensure row exists in table.
cursor csr_doc_exists(p_document_id number) is
select rowid
from irc_documents
where document_id = p_document_id;
--
l_hr_username fnd_oracle_userid.oracle_username%TYPE :=null;
cursor csr_user is
 select oracle_username
   from fnd_oracle_userid
  where oracle_id = 800;
--
l_rowid rowid;
--
clob_doc clob;
--
l_ret varchar2(30);
begin
--
hr_utility.set_location(' Entering:'||l_proc, 10);
--
  open csr_user;
  fetch csr_user into l_hr_username;
  close csr_user;
--
  If l_hr_username is not null   -- enter if product is found
  then
    -- Ensure doc exists, if not raise error.
    open csr_doc_exists(p_document_id);
    fetch csr_doc_exists into l_rowid;
    If csr_doc_exists%found then
      close csr_doc_exists;
      --
      -- Convert document
      ctx_doc.filter(index_name => l_hr_username || '.IRC_DOCUMENTS_CTX',
                     textkey    => l_rowid,
                     restab     => clob_doc,
                     plaintext  => true);
      --
      irc_ido_shd.g_api_dml := true;  -- Set the api dml status
      --
      update irc_documents
      set character_doc = clob_doc
      where document_id = p_document_id;
      --
      irc_ido_shd.g_api_dml := false;  -- Unset the api dml status
      --
      hr_utility.set_location(l_proc||' - BLOB Conversion Complete', 20);
      --
      -- Synchronize interMedia index
      hr_utility.set_location(l_proc||' - Synchronization Complete', 30);
      --
    else
      close csr_doc_exists;
      hr_utility.set_message(800, 'IRC_412046_IDO_INV_DOC_ID');
      hr_utility.raise_error;
    end if;
  end if;  -- End if for l_hr_username is not null
  hr_utility.set_location(' Leaving:'||l_proc, 40);
--
exception
  when others then
    If csr_user%isopen
    then
      close csr_user;
    End if;
    If csr_doc_exists%isopen
    then
      close csr_doc_exists;
    End if;
    if(fnd_log.test(fnd_log.level_error,'per.irc_document_api.process_document')) then
      hr_utility.log_at_error_level('per'
      ,'irc_document_api.process_document'
      ,'unable to process'
      ,dbms_utility.format_error_stack);
    end if;
    fnd_message.set_name('PER', 'IRC_UNABLE_TO_INDEX_DOC');
    fnd_msg_pub.add_detail
    (p_message_type => 'I'
     );
end process_document;
--
function get_html_preview
  (p_document_id in number,p_highlight_string in varchar2 default null) return clob is
cursor get_schema_name is
select oracle_username
from fnd_oracle_userid
where oracle_id = 800;

cursor csr_doc_exists is
select rowid
from irc_documents
where document_id = p_document_id;
cursor csr_doc_type is
select file_name
from irc_documents
where document_id = p_document_id;

l_rowid rowid;
l_schema_name varchar2(20) := null;
l_output_clob clob := null;
l_file_name IRC_DOCUMENTS.FILE_NAME%type;
l_type varchar2(10);
begin
  --
  fnd_msg_pub.delete_msg;
  --
  open csr_doc_exists;
  fetch csr_doc_exists into l_rowid;
  if (csr_doc_exists%found) then
    close csr_doc_exists;

    open get_schema_name;
    fetch get_schema_name into l_schema_name;
    if (get_schema_name%found) then
      close get_schema_name;
           -- Highlight the keywords if highlight string is null
       if (trim(p_highlight_string) is not null) then
         CTX_DOC.MARKUP (index_name   => l_schema_name||'.IRC_DOCUMENTS_CTX' ,
                         textkey      => l_rowid,
                         text_query   => p_highlight_string,
                         restab       => l_output_clob,
                         plaintext    => FALSE,
                         tagset       => 'HTML_DEFAULT',
                         starttag     => IRC_MARKUP_STARTTAG,
                         endtag       => IRC_MARKUP_ENDTAG);

      -- IF keyword is null then generate html version without markup
      else
        ctx_doc.filter(index_name => l_schema_name||'.IRC_DOCUMENTS_CTX',
                       textkey    => l_rowid,
                       restab     => l_output_clob,
                       plaintext  => false);
     end if;
     open csr_doc_type;
     fetch csr_doc_type into l_file_name;
     if(csr_doc_type%found) then
       l_type := lower(substr(l_file_name,- 4));
       if(l_type = '.pdf') then
       ame_util.runtimeexception('IRC_DOCUMENT_API','get_html_preview',-9999,'Adding the customizations');
  l_output_clob := '<br id="pdfBr"/><div style="position:relative" id="pdfHtmlDoc">' || l_output_clob;
  l_output_clob := l_output_clob || '</div><script>
function getRealTop(mChildIn,maxTop)
{
        var childMarker=mChildIn.childCount
        if(childMarker!=undefined)
        {
                for (m=0;m<childMarker ;m++ )
                {
                        var m_ChildIn=mChildIn.childNodes[m];
                        maxTop=getRealTop(m_ChildIn);
                }
        }
        var m_Top=mChildIn.offsetTop
        if(m_Top !=undefined)
        {
        var m_Height=mChildIn.offsetHeight;
        if(m_Height!=undefined)
        {
                m_Top=m_Top+m_Height;
        }
        if(m_Top>maxTop)
        {
                maxTop=m_Top;
        }
        }
        return maxTop;
}
var divElement=document.getElementById("pdfHtmlDoc")
var brTop=document.getElementById("pdfBr").offsetTop
var brHeight=document.getElementById("pdfBr").offsetHeight
var maxTop=0
for (i=0;i<divElement.childNodes.length;i++)
        {
        var mchild=divElement.childNodes[i]
        maxTop=getRealTop(mchild,maxTop);
        }
        if(maxTop>brTop)
        {
        var mLength=Math.ceil((maxTop)/(brHeight-1));
        for (j=0;j<=mLength ;j++ )
        {
        document.writeln("<br/>")
        }
        document.writeln("<br/>")
}</script>';
  ame_util.runtimeexception('IRC_DOCUMENT_API','get_html_preview',-9999,'Added the customizations');
  end if;
  end if;
  close csr_doc_type;
    else
      close get_schema_name;
    end if;
  else
    close csr_doc_exists;
    hr_utility.set_message(800, 'IRC_412046_IDO_INV_DOC_ID');
    hr_utility.raise_error;
  end if;

  return l_output_clob;
exception
when others then
    if(fnd_log.test(fnd_log.level_error,'per.irc_document_api.get_html_preview')) then
      hr_utility.log_at_error_level('per'
      ,'irc_document_api.get_html_preview'
      ,'unable to preview'
      ,dbms_utility.format_error_stack);
    end if;
    hr_utility.log_at_error_level('per','get_html_preview','unable to preview'
    ,dbms_utility.format_error_stack);
    fnd_message.set_name('PER', 'IRC_UNABLE_TO_PREVIEW_DOC');
    fnd_msg_pub.add_detail
    (p_message_type => 'W'
     );
  return l_output_clob;

end get_html_preview;

procedure is_internet_applicant
        ( p_document_id           in          number,
          p_person_id             in          number,
          p_party_id              in          number,
          p_num_job_applications  out nocopy  number)
Is

--
l_num_job_applications number := 0;
--

cursor  csr_internet_applicant
Is
select  count(pasf.person_id)
from    per_all_people_f        paf,
        per_all_assignments_f   pasf
where
        paf.party_id    = p_party_id
and     trunc(sysdate)  between paf.effective_start_date and paf.effective_end_date
and     trunc(sysdate)  between pasf.effective_start_date and pasf.effective_end_date
and     pasf.person_id  = paf.person_id
and     pasf.business_group_id  in ( select bginfo.organization_id from hr_organization_information bginfo
                                     where bginfo.ORG_INFORMATION_CONTEXT = 'BG Recruitment'
                                     and bginfo.org_information11 = 'Y'
                                    );
begin

        open    csr_internet_applicant;
        fetch   csr_internet_applicant  into    l_num_job_applications;

        close csr_internet_applicant;


        p_num_job_applications := l_num_job_applications;


End is_internet_applicant;


end IRC_DOCUMENT_API;

/
