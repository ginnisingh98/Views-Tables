--------------------------------------------------------
--  DDL for Package Body HR_ADI_DOCUMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ADI_DOCUMENT_API" as
/* $Header: hrlobapi.pkb 115.3 2004/03/31 06:21:37 menderby noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_ADI_DOCUMENT_API.';

-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_DOCUMENT >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_mime_type                     in     varchar2
  ,p_file_name                     in     varchar2
  ,p_type                          in     varchar2
  ,p_file_id                          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'CREATE_DOCUMENT';
  l_effective_date        date;
  l_file_id           number(15);
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
  -- Process Logic
  --
    hr_adi_lob_ins.ins
    (p_effective_date                => l_effective_date
    ,p_file_content_type             => p_mime_type
    ,p_file_name                     => p_file_name
    ,p_file_type                     => p_type
    ,p_file_id                       => l_file_id
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_file_id            := l_file_id;
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
    p_file_id            := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_DOCUMENT;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_file_id            := null;

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
  ,p_file_id                       in     number
  ,p_mime_type                     in     varchar2
  ,p_file_name                     in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'UPDATE_DOCUMENT';
  l_effective_date        date;
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

  --
  -- Process Logic
  --
    hr_adi_lob_upd.upd
    (p_effective_date                => l_effective_date
    ,p_file_id                       => p_file_id
    ,p_file_content_type             => p_mime_type
    ,p_file_name                     => p_file_name
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
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
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_DOCUMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_DOCUMENT;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< DELETE_DOCUMENT >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_DOCUMENT
  (p_validate                      in     boolean  default false
  ,p_file_id                       in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'DELETE_DOCUMENT';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_DOCUMENT;

  --
  -- Process Logic
  --
    hr_adi_lob_del.del
    (p_file_id                   => p_file_id
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
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

-- ----------------------------------------------------------------------------
-- |---------------------------< DOCUMENT_TO_TEXT >---------------------------|
-- ----------------------------------------------------------------------------

-- function to convert a specified binary file in the fnd_lobs
-- table to be converted into a clob
--
function document_to_text(p_file_id in varchar2, p_text_or_html varchar2) return clob is
--
l_clob clob;
--
cursor csr_file_exists(p_file_id varchar2) is
  select rowid
  from fnd_lobs
  where file_id = p_file_id;
--
l_rowid rowid;
text boolean;
begin
  -- First check that document exists.
  open csr_file_exists(p_file_id);
  fetch csr_file_exists into l_rowid;
  if (csr_file_exists%found) then
    if (upper(p_text_or_html)='TEXT') then
      text := true;
    else
      text := false;
    end if;
    --
    -- Convert document
    --
    -- bug 3544676
    -- disabled due to schema naming used directly
    -- search feature not implemented via UI
    --
    --ctx_doc.filter(index_name => 'APPLSYS.FND_LOBS_CTX',
    --               textkey    => p_file_id,
    --               restab     => l_clob,
    --               plaintext  => text);
  end if;
  close csr_file_exists;
  return l_clob;
end;

-- ----------------------------------------------------------------------------
-- |----------------------------< SEARCH_FOR_TERM >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Procedure to search for term in binary files stored in FND_LOBS
-- the return value is a comma delimited string of the file_ids of the files
-- which contain the search term.
--
-- If no file type is specified a wildcard value is assumed.
--
function search_for_term(p_search_term   in varchar2,
                         p_document_type in varchar2 default null)
   return varchar2 is
--
 TYPE file_id   IS TABLE OF fnd_lobs.file_id%type index by binary_integer;
 l_file_id file_id;

 -- Cursors
 cursor csr_get_files(p_file_type varchar2) is
  select file_id
  from fnd_lobs
  where program_name = 'HRMS_ADI'
    and program_tag  = upper(nvl(p_file_type, program_tag));

 -- Local variables
 l_rowcount number;
 l_foundlist varchar2(1000);
 l_clob clob;
--
begin

 -- first find files relating to specified type
 open csr_get_files(p_document_type);
 fetch csr_get_files bulk collect into l_file_id;
 l_rowcount := csr_get_files%rowcount;
 close csr_get_files;

 -- for each file of the designated type, convert the binary file into
 -- plain text, then search for term.
 for i in 1..l_rowcount loop
   l_clob := hr_adi_document_api.document_to_text(l_file_id(i), 'text');
   if (dbms_lob.instr(l_clob, p_search_term, 1, 1) > 0) then
     l_foundlist := l_foundlist || l_file_id(i) || ', ';
   end if;
 end loop;

 -- trim any trailing comma and space from l_found_list
 if (length(l_foundlist)>0) then
   l_foundlist := substr(l_foundlist, 0, (length(l_foundlist)-2));
 end if;

 return l_foundlist;
end;

end HR_ADI_DOCUMENT_API;

/
