--------------------------------------------------------
--  DDL for Package Body HR_DOCUMENT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DOCUMENT_EXTRA_INFO_API" as
/* $Header: hrdeiapi.pkb 120.2.12010000.4 2010/06/07 11:01:19 tkghosh ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_document_extra_info_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_doc_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_doc_extra_info(
   p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_document_type_id              in     number
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_document_number               in     varchar2 default null
  ,p_issued_by                     in     varchar2 default null
  ,p_issued_at                     in     varchar2 default null
  ,p_issued_date                   in     date     default null
  ,p_issuing_authority             in     varchar2 default null
  ,p_verified_by                   in     number   default null
  ,p_verified_date                 in     date     default null
  ,p_related_object_name           in     varchar2 default null
  ,p_related_object_id_col         in     varchar2 default null
  ,p_related_object_id             in     number   default null
  ,p_dei_attribute_category        in     varchar2 default null
  ,p_dei_attribute1                in     varchar2 default null
  ,p_dei_attribute2                in     varchar2 default null
  ,p_dei_attribute3                in     varchar2 default null
  ,p_dei_attribute4                in     varchar2 default null
  ,p_dei_attribute5                in     varchar2 default null
  ,p_dei_attribute6                in     varchar2 default null
  ,p_dei_attribute7                in     varchar2 default null
  ,p_dei_attribute8                in     varchar2 default null
  ,p_dei_attribute9                in     varchar2 default null
  ,p_dei_attribute10               in     varchar2 default null
  ,p_dei_attribute11               in     varchar2 default null
  ,p_dei_attribute12               in     varchar2 default null
  ,p_dei_attribute13               in     varchar2 default null
  ,p_dei_attribute14               in     varchar2 default null
  ,p_dei_attribute15               in     varchar2 default null
  ,p_dei_attribute16               in     varchar2 default null
  ,p_dei_attribute17               in     varchar2 default null
  ,p_dei_attribute18               in     varchar2 default null
  ,p_dei_attribute19               in     varchar2 default null
  ,p_dei_attribute20               in     varchar2 default null
  ,p_dei_attribute21               in     varchar2 default null
  ,p_dei_attribute22               in     varchar2 default null
  ,p_dei_attribute23               in     varchar2 default null
  ,p_dei_attribute24               in     varchar2 default null
  ,p_dei_attribute25               in     varchar2 default null
  ,p_dei_attribute26               in     varchar2 default null
  ,p_dei_attribute27               in     varchar2 default null
  ,p_dei_attribute28               in     varchar2 default null
  ,p_dei_attribute29               in     varchar2 default null
  ,p_dei_attribute30               in     varchar2 default null
  ,p_dei_information_category      in     varchar2 default null
  ,p_dei_information1              in     varchar2 default null
  ,p_dei_information2              in     varchar2 default null
  ,p_dei_information3              in     varchar2 default null
  ,p_dei_information4              in     varchar2 default null
  ,p_dei_information5              in     varchar2 default null
  ,p_dei_information6              in     varchar2 default null
  ,p_dei_information7              in     varchar2 default null
  ,p_dei_information8              in     varchar2 default null
  ,p_dei_information9              in     varchar2 default null
  ,p_dei_information10             in     varchar2 default null
  ,p_dei_information11             in     varchar2 default null
  ,p_dei_information12             in     varchar2 default null
  ,p_dei_information13             in     varchar2 default null
  ,p_dei_information14             in     varchar2 default null
  ,p_dei_information15             in     varchar2 default null
  ,p_dei_information16             in     varchar2 default null
  ,p_dei_information17             in     varchar2 default null
  ,p_dei_information18             in     varchar2 default null
  ,p_dei_information19             in     varchar2 default null
  ,p_dei_information20             in     varchar2 default null
  ,p_dei_information21             in     varchar2 default null
  ,p_dei_information22             in     varchar2 default null
  ,p_dei_information23             in     varchar2 default null
  ,p_dei_information24             in     varchar2 default null
  ,p_dei_information25             in     varchar2 default null
  ,p_dei_information26             in     varchar2 default null
  ,p_dei_information27             in     varchar2 default null
  ,p_dei_information28             in     varchar2 default null
  ,p_dei_information29             in     varchar2 default null
  ,p_dei_information30             in     varchar2 default null
  ,p_request_id                    in     number   default null
  ,p_program_application_id        in     number   default null
  ,p_program_id                    in     number   default null
  ,p_program_update_date           in     date     default null
  ,p_document_extra_info_id        out    nocopy number
  ,p_object_version_number         out    nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

    l_proc			varchar2(72) := g_package||'create_doc_extra_info';
    l_object_version_number	hr_document_extra_info.object_version_number%type;
    l_document_extra_info_id	hr_document_extra_info.document_extra_info_id%type;
    l_person_id                 hr_document_extra_info.person_id%type;
    l_document_type             varchar2(50);
    l_document_type_id          hr_document_extra_info.document_type_id%type;
    l_date_from                 hr_document_extra_info.date_from%type;
    l_date_to                   hr_document_extra_info.date_to%type;
    l_mul_flag                  hr_document_types_v.multiple_occurences_flag%type;
    l_num                       number;
    l_authorization_required varchar2(10);
    l_verified_by number := p_verified_by;
    l_verified_date date := p_verified_date;
    dummy varchar2(5);

      cursor csr_get_document_type(p_document_type_id number)
      is
      select document_type,authorization_required
      from hr_document_types_v
      where document_type_id=p_document_type_id;

        cursor csr_chk_combination(p_document_type_id number,p_person_id number,
        p_date_from DATE,p_date_to DATE) is
            select 'X'
            from   hr_document_extra_info
            where  document_type_id   = p_document_type_id
            and    person_id = p_person_id
            and    date_from = p_date_from
            and    date_to = p_date_to;


    cursor csr_chk_multiple(p_document_type_id number) is
    select MULTIPLE_OCCURENCES_FLAG
    from HR_DOCUMENT_TYPES_V
    where DOCUMENT_TYPE_ID = p_document_type_id;

    cursor csr_chk_doc_allowed(p_document_type_id number,p_person_id number) is
    select count(*) from hr_document_extra_info
    where  document_type_id  = p_document_type_id
    and    person_id = p_person_id;
  --
    begin
      hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
    savepoint create_doc_extra_info;
  --
  -- Call Before Process User Hook
  --
 begin

       hr_document_extra_info_bk1.create_doc_extra_info_b
      (p_person_id                 => p_person_id,
       p_document_type_id           => p_document_type_id,
       p_date_from                  => p_date_from,
       p_date_to                    => p_date_to,
       p_document_number            => p_document_number,
       p_issued_by                  => p_issued_by,
       p_issued_at                  => p_issued_at,
       p_issued_date                => p_issued_date,
       p_issuing_authority          => p_issuing_authority,
       p_verified_by                => p_verified_by,
       p_verified_date              => p_verified_date,
       p_related_object_name        => p_related_object_name,
       p_related_object_id_col      => p_related_object_id_col,
       p_related_object_id          => p_related_object_id,
       p_dei_attribute_category     => p_dei_attribute_category,
       p_dei_attribute1             => p_dei_attribute1,
       p_dei_attribute2             => p_dei_attribute2,
       p_dei_attribute3             => p_dei_attribute3,
       p_dei_attribute4             => p_dei_attribute4,
       p_dei_attribute5             => p_dei_attribute5,
       p_dei_attribute6             => p_dei_attribute6,
       p_dei_attribute7             => p_dei_attribute7,
       p_dei_attribute8             => p_dei_attribute8,
       p_dei_attribute9             => p_dei_attribute9,
       p_dei_attribute10            => p_dei_attribute10,
       p_dei_attribute11	           => p_dei_attribute11,
       p_dei_attribute12            => p_dei_attribute12,
       p_dei_attribute13            => p_dei_attribute13,
       p_dei_attribute14            => p_dei_attribute14,
       p_dei_attribute15            => p_dei_attribute15,
       p_dei_attribute16            => p_dei_attribute16,
       p_dei_attribute17            => p_dei_attribute17,
       p_dei_attribute18            => p_dei_attribute18,
       p_dei_attribute19            => p_dei_attribute19,
       p_dei_attribute20            => p_dei_attribute20,
       p_dei_attribute21	        => p_dei_attribute21,
       p_dei_attribute22            => p_dei_attribute22,
       p_dei_attribute23            => p_dei_attribute23,
       p_dei_attribute24            => p_dei_attribute24,
       p_dei_attribute25            => p_dei_attribute25,
       p_dei_attribute26            => p_dei_attribute26,
       p_dei_attribute27            => p_dei_attribute27,
       p_dei_attribute28            => p_dei_attribute28,
       p_dei_attribute29            => p_dei_attribute29,
       p_dei_attribute30            => p_dei_attribute30,
       p_dei_information_category   => p_dei_information_category,
       p_dei_information1           => p_dei_information1,
       p_dei_information2           => p_dei_information2,
       p_dei_information3           => p_dei_information3,
       p_dei_information4           => p_dei_information4,
       p_dei_information5           => p_dei_information5,
       p_dei_information6           => p_dei_information6,
       p_dei_information7           => p_dei_information7,
       p_dei_information8           => p_dei_information8,
       p_dei_information9           => p_dei_information9,
       p_dei_information10          => p_dei_information10,
       p_dei_information11          => p_dei_information11,
       p_dei_information12          => p_dei_information12,
       p_dei_information13          => p_dei_information13,
       p_dei_information14          => p_dei_information14,
       p_dei_information15          => p_dei_information15,
       p_dei_information16          => p_dei_information16,
       p_dei_information17          => p_dei_information17,
       p_dei_information18          => p_dei_information18,
       p_dei_information19          => p_dei_information19,
       p_dei_information20          => p_dei_information20,
       p_dei_information21          => p_dei_information21,
       p_dei_information22          => p_dei_information22,
       p_dei_information23          => p_dei_information23,
       p_dei_information24          => p_dei_information24,
       p_dei_information25          => p_dei_information25,
       p_dei_information26          => p_dei_information26,
       p_dei_information27          => p_dei_information27,
       p_dei_information28          => p_dei_information28,
       p_dei_information29          => p_dei_information29,
       p_dei_information30          => p_dei_information30,
       p_request_id                 => p_request_id,
       p_program_application_id     => p_program_application_id,
       p_program_id                 => p_program_id,
       p_program_update_date        => p_program_update_date
      );
            exception
              when hr_api.cannot_find_prog_unit then
              hr_api.cannot_find_prog_unit_error
               (p_module_name => 'CREATE_DOC_EXTRA_INFO',
                p_hook_type   => 'BP'
               );
      end;
   --
   -- End of Before Process User Hook call
   --
        hr_utility.set_location(l_proc, 7);
        open csr_get_document_type(p_document_type_id =>p_document_type_id);
        fetch csr_get_document_type into l_document_type,l_authorization_required;
        close csr_get_document_type;

      open csr_chk_multiple(p_document_type_id =>p_document_type_id);
      fetch csr_chk_multiple into l_mul_flag;
      if (l_mul_flag = 'N') then
      open csr_chk_doc_allowed(p_document_type_id =>p_document_type_id,
      p_person_id=> p_person_id);
      fetch csr_chk_doc_allowed into l_num;
      if (l_num > 0) then
      close csr_chk_doc_allowed;

        hr_utility.set_message(800, 'HR_449709_DOR_MUL_NOT_ALW');
        hr_utility.set_message_token('TYPE', l_document_type);
        hr_utility.raise_error;
      else
      close csr_chk_doc_allowed;
      hr_utility.set_location(l_proc, 8);
      end if;
      close csr_chk_multiple;
      else
      close csr_chk_multiple;
      end if;


   --
   --
    open csr_chk_combination(p_document_type_id =>p_document_type_id,
       p_person_id=>p_person_id ,p_date_from =>p_date_from,p_date_to=>p_date_to );

      fetch csr_chk_combination into dummy;
      if csr_chk_combination%found then
      close csr_chk_combination;

       hr_utility.set_message(800, 'HR_449708_DOR_UNQ_PER_DOC');
        hr_utility.set_message_token('TYPE', l_document_type);
        hr_utility.set_message_token('DATE_FROM', p_date_from);
        hr_utility.set_message_token('DATE_TO', p_date_to);
        hr_utility.raise_error;
      --
      else
      close csr_chk_combination;
      hr_utility.set_location(l_proc, 9);
      end if;

 -- Added for checking Authorization Required, If value = 'N'
 -- pass Default Values of verified by and verified date to 'ins'
  if(l_authorization_required = 'N') then
   -- l_verified_by := nvl(l_verified_by, fnd_global.USER_ID); -- Fix for bug 9780853
    l_verified_date := nvl(l_verified_date, sysdate);
  end if;



   --
  hr_dei_ins.ins
    (
          p_document_extra_info_id     => l_document_extra_info_id,
          p_person_id                  => p_person_id,
          p_document_type_id           => p_document_type_id,
          p_date_from                  => p_date_from,
          p_date_to                    => p_date_to,
          p_document_number            => p_document_number,
          p_issued_by                  => p_issued_by,
          p_issued_at                  => p_issued_at,
          p_issued_date                => p_issued_date,
          p_issuing_authority          => p_issuing_authority,
          p_verified_by                => l_verified_by,
          p_verified_date              => l_verified_date,
          p_related_object_name        => p_related_object_name,
          p_related_object_id_col      => p_related_object_id_col,
          p_related_object_id          => p_related_object_id,
          p_dei_attribute_category     => p_dei_attribute_category,
          p_dei_attribute1             => p_dei_attribute1,
          p_dei_attribute2             => p_dei_attribute2,
          p_dei_attribute3             => p_dei_attribute3,
          p_dei_attribute4             => p_dei_attribute4,
          p_dei_attribute5             => p_dei_attribute5,
          p_dei_attribute6             => p_dei_attribute6,
          p_dei_attribute7             => p_dei_attribute7,
          p_dei_attribute8             => p_dei_attribute8,
          p_dei_attribute9             => p_dei_attribute9,
          p_dei_attribute10            => p_dei_attribute10,
          p_dei_attribute11            => p_dei_attribute11,
          p_dei_attribute12            => p_dei_attribute12,
          p_dei_attribute13            => p_dei_attribute13,
          p_dei_attribute14            => p_dei_attribute14,
          p_dei_attribute15            => p_dei_attribute15,
          p_dei_attribute16            => p_dei_attribute16,
          p_dei_attribute17            => p_dei_attribute17,
          p_dei_attribute18            => p_dei_attribute18,
          p_dei_attribute19            => p_dei_attribute19,
          p_dei_attribute20            => p_dei_attribute20,
          p_dei_attribute21            => p_dei_attribute21,
          p_dei_attribute22            => p_dei_attribute22,
          p_dei_attribute23            => p_dei_attribute23,
          p_dei_attribute24            => p_dei_attribute24,
          p_dei_attribute25            => p_dei_attribute25,
          p_dei_attribute26            => p_dei_attribute26,
          p_dei_attribute27            => p_dei_attribute27,
          p_dei_attribute28            => p_dei_attribute28,
          p_dei_attribute29            => p_dei_attribute29,
          p_dei_attribute30            => p_dei_attribute30,
          p_dei_information_category   => p_dei_information_category,
          p_dei_information1           => p_dei_information1,
          p_dei_information2           => p_dei_information2,
          p_dei_information3           => p_dei_information3,
          p_dei_information4           => p_dei_information4,
          p_dei_information5           => p_dei_information5,
          p_dei_information6           => p_dei_information6,
          p_dei_information7           => p_dei_information7,
          p_dei_information8           => p_dei_information8,
          p_dei_information9           => p_dei_information9,
          p_dei_information10          => p_dei_information10,
          p_dei_information11          => p_dei_information11,
          p_dei_information12          => p_dei_information12,
          p_dei_information13          => p_dei_information13,
          p_dei_information14          => p_dei_information14,
          p_dei_information15          => p_dei_information15,
          p_dei_information16          => p_dei_information16,
          p_dei_information17          => p_dei_information17,
          p_dei_information18          => p_dei_information18,
          p_dei_information19          => p_dei_information19,
          p_dei_information20          => p_dei_information20,
          p_dei_information21          => p_dei_information21,
          p_dei_information22          => p_dei_information22,
          p_dei_information23          => p_dei_information23,
          p_dei_information24          => p_dei_information24,
          p_dei_information25          => p_dei_information25,
          p_dei_information26          => p_dei_information26,
          p_dei_information27          => p_dei_information27,
          p_dei_information28          => p_dei_information28,
          p_dei_information29          => p_dei_information29,
          p_dei_information30          => p_dei_information30,
          p_request_id                 => p_request_id,
  	      p_program_application_id     => p_program_application_id,
  	      p_program_id                 => p_program_id,
          p_program_update_date        => p_program_update_date,
          p_object_version_number      => l_object_version_number
         );


       p_object_version_number	:= l_object_version_number;
       p_document_extra_info_id	:= l_document_extra_info_id;
       --
       hr_utility.set_location(l_proc, 8);
       --
       -- Call After Process User Hook
       --
     begin
             hr_document_extra_info_bk1.create_doc_extra_info_a
                   (
                 p_document_extra_info_id     => l_document_extra_info_id,
    	         p_person_id                  => p_person_id,
    	         p_document_type_id           => p_document_type_id,
    	         p_date_from                  => p_date_from,
    	         p_date_to                    => p_date_to,
    	         p_document_number            => p_document_number,
    	         p_issued_by                  => p_issued_by,
    	         p_issued_at                  => p_issued_at,
    	         p_issued_date                => p_issued_date,
    	         p_issuing_authority          => p_issuing_authority,
    	         p_verified_by                => p_verified_by,
    	         p_verified_date              => p_verified_date,
    	         p_related_object_name        => p_related_object_name,
    	         p_related_object_id_col      => p_related_object_id_col,
    	         p_related_object_id          => p_related_object_id,
    	         p_dei_attribute_category     => p_dei_attribute_category,
    	         p_dei_attribute1             => p_dei_attribute1,
    	         p_dei_attribute2             => p_dei_attribute2,
    	         p_dei_attribute3             => p_dei_attribute3,
    	         p_dei_attribute4             => p_dei_attribute4,
    	         p_dei_attribute5             => p_dei_attribute5,
    	         p_dei_attribute6             => p_dei_attribute6,
    	         p_dei_attribute7             => p_dei_attribute7,
    	         p_dei_attribute8             => p_dei_attribute8,
    	         p_dei_attribute9             => p_dei_attribute9,
    	         p_dei_attribute10            => p_dei_attribute10,
    	         p_dei_attribute11            => p_dei_attribute11,
    	         p_dei_attribute12            => p_dei_attribute12,
    	         p_dei_attribute13            => p_dei_attribute13,
    	         p_dei_attribute14            => p_dei_attribute14,
    	         p_dei_attribute15            => p_dei_attribute15,
    	         p_dei_attribute16            => p_dei_attribute16,
    	         p_dei_attribute17            => p_dei_attribute17,
    	         p_dei_attribute18            => p_dei_attribute18,
    	         p_dei_attribute19            => p_dei_attribute19,
    	         p_dei_attribute20            => p_dei_attribute20,
    	         p_dei_attribute21            => p_dei_attribute21,
    	         p_dei_attribute22            => p_dei_attribute22,
    	         p_dei_attribute23            => p_dei_attribute23,
    	         p_dei_attribute24            => p_dei_attribute24,
    	         p_dei_attribute25            => p_dei_attribute25,
    	         p_dei_attribute26            => p_dei_attribute26,
    	         p_dei_attribute27            => p_dei_attribute27,
    	         p_dei_attribute28            => p_dei_attribute28,
    	         p_dei_attribute29            => p_dei_attribute29,
    	         p_dei_attribute30            => p_dei_attribute30,
    	         p_dei_information_category   => p_dei_information_category,
    	         p_dei_information1           => p_dei_information1,
    	         p_dei_information2           => p_dei_information2,
    	         p_dei_information3           => p_dei_information3,
    	         p_dei_information4           => p_dei_information4,
    	         p_dei_information5           => p_dei_information5,
    	         p_dei_information6           => p_dei_information6,
    	         p_dei_information7           => p_dei_information7,
    	         p_dei_information8           => p_dei_information8,
    	         p_dei_information9           => p_dei_information9,
    	         p_dei_information10          => p_dei_information10,
    	         p_dei_information11          => p_dei_information11,
    	         p_dei_information12          => p_dei_information12,
    	         p_dei_information13          => p_dei_information13,
    	         p_dei_information14          => p_dei_information14,
    	         p_dei_information15          => p_dei_information15,
    	         p_dei_information16          => p_dei_information16,
    	         p_dei_information17          => p_dei_information17,
    	         p_dei_information18          => p_dei_information18,
    	         p_dei_information19          => p_dei_information19,
    	         p_dei_information20          => p_dei_information20,
    	         p_dei_information21          => p_dei_information21,
    	         p_dei_information22          => p_dei_information22,
    	         p_dei_information23          => p_dei_information23,
    	         p_dei_information24          => p_dei_information24,
    	         p_dei_information25          => p_dei_information25,
    	         p_dei_information26          => p_dei_information26,
    	         p_dei_information27          => p_dei_information27,
    	         p_dei_information28          => p_dei_information28,
    	         p_dei_information29          => p_dei_information29,
    	         p_dei_information30          => p_dei_information30,
    	         p_request_id                 => p_request_id,
    	 	     p_program_application_id     => p_program_application_id,
    	 	     p_program_id                 => p_program_id,
    	         p_program_update_date        => p_program_update_date,
                 p_object_version_number      => l_object_version_number
                );
	     exception
	       when hr_api.cannot_find_prog_unit then
	         hr_api.cannot_find_prog_unit_error
	           (p_module_name => 'CREATE_DOC_EXTRA_INFO',
	            p_hook_type   => 'AP'
	           );
	 end;
	   --
	   -- End of After Process User Hook call
	   --
	   -- When in validation only mode raise the Validate_Enabled exception
	   --
	   if p_validate then
	     raise hr_api.validate_enabled;
	   end if;
	   --
	   hr_utility.set_location(' Leaving:'||l_proc, 11);
	 exception
	   when hr_api.validate_enabled then
	     --
	     -- As the Validate_Enabled exception has been raised
	     -- we must rollback to the savepoint
	     --
	     ROLLBACK TO create_doc_extra_info;
	     --
	     -- Only set output warning arguments
	     -- (Any key or derived arguments must be set to null
	     -- when validation only mode is being used.)
	     --
	     p_document_extra_info_id   := null;
	     p_object_version_number  := null;
	     --
	     hr_utility.set_location(' Leaving:'||l_proc, 12);
	     --
	   when others then
	     --
	     -- A validation or unexpected error has occurred
	     --
	     --
	     ROLLBACK TO create_doc_extra_info;
	     --
	     -- set in out parameters and set out parameters
	     --
	     p_document_extra_info_id   := null;
	     p_object_version_number  := null;
	     --
	     raise;
	     --
	 end create_doc_extra_info;
	 --
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_doc_extra_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_doc_extra_info
(  p_validate                      in     boolean  default false
  ,p_document_extra_info_id        in     number
  ,p_person_id                     in     number
  ,p_document_type_id              in     number
  ,p_date_from                     in     date
  ,p_date_to                       in     date
  ,p_document_number               in     varchar2 default hr_api.g_varchar2
  ,p_issued_by                     in     varchar2 default hr_api.g_varchar2
  ,p_issued_at                     in     varchar2 default hr_api.g_varchar2
  ,p_issued_date                   in     date     default hr_api.g_date
  ,p_issuing_authority             in     varchar2 default hr_api.g_varchar2
  ,p_verified_by                   in     number   default hr_api.g_number
  ,p_verified_date                 in     date     default hr_api.g_date
  ,p_related_object_name           in     varchar2 default hr_api.g_varchar2
  ,p_related_object_id_col         in     varchar2 default hr_api.g_varchar2
  ,p_related_object_id             in     number   default hr_api.g_number
  ,p_dei_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute21               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute22               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute23               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute24               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute25               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute26               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute27               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute28               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute29               in     varchar2 default hr_api.g_varchar2
  ,p_dei_attribute30               in     varchar2 default hr_api.g_varchar2
  ,p_dei_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_dei_information1              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information2              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information3              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information4              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information5              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information6              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information7              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information8              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information9              in     varchar2 default hr_api.g_varchar2
  ,p_dei_information10             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information11             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information12             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information13             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information14             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information15             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information16             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information17             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information18             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information19             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information20             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information21             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information22             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information23             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information24             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information25             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information26             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information27             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information28             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information29             in     varchar2 default hr_api.g_varchar2
  ,p_dei_information30             in     varchar2 default hr_api.g_varchar2
  ,p_request_id                    in     number   default hr_api.g_number
  ,p_program_application_id        in     number   default hr_api.g_number
  ,p_program_id                    in     number   default hr_api.g_number
  ,p_program_update_date           in     date     default hr_api.g_date
  ,p_object_version_number         in out nocopy number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_doc_extra_info';
  l_object_version_number hr_document_extra_info.object_version_number%TYPE;
  l_ovn hr_document_extra_info.object_version_number%TYPE := p_object_version_number;
  l_authorization_required varchar2(10);
  l_verified_by number := p_verified_by;
  l_verified_date date := p_verified_date;
  l_document_type             varchar2(50);
  l_mul_flag                  hr_document_types_v.multiple_occurences_flag%type;
  l_num                       number;
  dummy varchar2(5);

  cursor csr_get_document_type(p_document_type_id number)
      is
      select document_type,authorization_required
      from hr_document_types_v
      where document_type_id=p_document_type_id;

        cursor csr_chk_combination(p_document_type_id number,p_person_id number,p_date_from DATE,
        p_date_to DATE,p_document_extra_info_id number) is
            select 'X'
            from   hr_document_extra_info
            where  document_type_id   = p_document_type_id
            and    person_id = p_person_id
            and    date_from = p_date_from
            and    date_to = p_date_to
            and    document_extra_info_id <> p_document_extra_info_id;


    cursor csr_chk_multiple(p_document_type_id number) is
    select MULTIPLE_OCCURENCES_FLAG
    from HR_DOCUMENT_TYPES_V
    where DOCUMENT_TYPE_ID = p_document_type_id;

    cursor csr_chk_doc_allowed(p_document_type_id number,p_person_id number,
    p_document_extra_info_id number) is
    select count(*) from hr_document_extra_info
    where  document_type_id  = p_document_type_id
    and person_id = p_person_id
    and document_extra_info_id <> p_document_extra_info_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_doc_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_document_extra_info_bk2.update_doc_extra_info_b
     (
      p_document_extra_info_id     => p_document_extra_info_id,
      p_person_id                  => p_person_id,
      p_document_type_id           => p_document_type_id,
      p_date_from                  => p_date_from,
      p_date_to                    => p_date_to,
      p_document_number            => p_document_number,
      p_issued_by                  => p_issued_by,
      p_issued_at                  => p_issued_at,
      p_issued_date                => p_issued_date,
      p_issuing_authority          => p_issuing_authority,
      p_verified_by                => p_verified_by,
      p_verified_date              => p_verified_date,
      p_related_object_name        => p_related_object_name,
      p_related_object_id_col      => p_related_object_id_col,
      p_related_object_id          => p_related_object_id,
      p_dei_attribute_category     => p_dei_attribute_category,
      p_dei_attribute1             => p_dei_attribute1,
      p_dei_attribute2             => p_dei_attribute2,
      p_dei_attribute3             => p_dei_attribute3,
      p_dei_attribute4             => p_dei_attribute4,
      p_dei_attribute5             => p_dei_attribute5,
      p_dei_attribute6             => p_dei_attribute6,
      p_dei_attribute7             => p_dei_attribute7,
      p_dei_attribute8             => p_dei_attribute8,
      p_dei_attribute9             => p_dei_attribute9,
      p_dei_attribute10            => p_dei_attribute10,
      p_dei_attribute11            => p_dei_attribute11,
      p_dei_attribute12            => p_dei_attribute12,
      p_dei_attribute13            => p_dei_attribute13,
      p_dei_attribute14            => p_dei_attribute14,
      p_dei_attribute15            => p_dei_attribute15,
      p_dei_attribute16            => p_dei_attribute16,
      p_dei_attribute17            => p_dei_attribute17,
      p_dei_attribute18            => p_dei_attribute18,
      p_dei_attribute19            => p_dei_attribute19,
      p_dei_attribute20            => p_dei_attribute20,
      p_dei_attribute21            => p_dei_attribute21,
      p_dei_attribute22            => p_dei_attribute22,
      p_dei_attribute23            => p_dei_attribute23,
      p_dei_attribute24            => p_dei_attribute24,
      p_dei_attribute25            => p_dei_attribute25,
      p_dei_attribute26            => p_dei_attribute26,
      p_dei_attribute27            => p_dei_attribute27,
      p_dei_attribute28            => p_dei_attribute28,
      p_dei_attribute29            => p_dei_attribute29,
      p_dei_attribute30            => p_dei_attribute30,
      p_dei_information_category   => p_dei_information_category,
      p_dei_information1           => p_dei_information1,
      p_dei_information2           => p_dei_information2,
      p_dei_information3           => p_dei_information3,
      p_dei_information4           => p_dei_information4,
      p_dei_information5           => p_dei_information5,
      p_dei_information6           => p_dei_information6,
      p_dei_information7           => p_dei_information7,
      p_dei_information8           => p_dei_information8,
      p_dei_information9           => p_dei_information9,
      p_dei_information10          => p_dei_information10,
      p_dei_information11          => p_dei_information11,
      p_dei_information12          => p_dei_information12,
      p_dei_information13          => p_dei_information13,
      p_dei_information14          => p_dei_information14,
      p_dei_information15          => p_dei_information15,
      p_dei_information16          => p_dei_information16,
      p_dei_information17          => p_dei_information17,
      p_dei_information18          => p_dei_information18,
      p_dei_information19          => p_dei_information19,
      p_dei_information20          => p_dei_information20,
      p_dei_information21          => p_dei_information21,
      p_dei_information22          => p_dei_information22,
      p_dei_information23          => p_dei_information23,
      p_dei_information24          => p_dei_information24,
      p_dei_information25          => p_dei_information25,
      p_dei_information26          => p_dei_information26,
      p_dei_information27          => p_dei_information27,
      p_dei_information28          => p_dei_information28,
      p_dei_information29          => p_dei_information29,
      p_dei_information30          => p_dei_information30,
      p_request_id                 => p_request_id,
      p_program_application_id     => p_program_application_id,
      p_program_id                 => p_program_id,
      p_program_update_date        => p_program_update_date,
      p_object_version_number      => p_object_version_number
      );
      exception
              when hr_api.cannot_find_prog_unit then
                hr_api.cannot_find_prog_unit_error
                  (p_module_name => 'UPDATE_DOC_EXTRA_INFO',
                   p_hook_type   => 'BP'
                  );
      end;
          hr_utility.set_location(l_proc, 7);
        --
     open csr_get_document_type(p_document_type_id =>p_document_type_id);
        fetch csr_get_document_type into l_document_type,l_authorization_required;
        close csr_get_document_type;

      open csr_chk_multiple(p_document_type_id =>p_document_type_id);
      fetch csr_chk_multiple into l_mul_flag;
      if (l_mul_flag = 'N') then
      open csr_chk_doc_allowed(p_document_type_id =>p_document_type_id,p_person_id=>p_person_id,
      p_document_extra_info_id=>p_document_extra_info_id);
      fetch csr_chk_doc_allowed into l_num;
      if (l_num > 0) then
      close csr_chk_doc_allowed;

        hr_utility.set_message(800, 'HR_449709_DOR_MUL_NOT_ALW');
        hr_utility.set_message_token('TYPE', l_document_type);
        hr_utility.raise_error;
      else
      close csr_chk_doc_allowed;
      hr_utility.set_location(l_proc, 8);
      end if;
      close csr_chk_multiple;
      else
      close csr_chk_multiple;
      end if;


   --
   --
    open csr_chk_combination(p_document_type_id =>p_document_type_id,
       p_person_id=>p_person_id ,p_date_from =>p_date_from,p_date_to=>p_date_to,
       p_document_extra_info_id=>p_document_extra_info_id );

      fetch csr_chk_combination into dummy;
      if csr_chk_combination%found then
      close csr_chk_combination;

       hr_utility.set_message(800, 'HR_449708_DOR_UNQ_PER_DOC');
        hr_utility.set_message_token('TYPE', l_document_type);
        hr_utility.set_message_token('DATE_FROM', p_date_from);
        hr_utility.set_message_token('DATE_TO', p_date_to);
        hr_utility.raise_error;
      --
      else
      close csr_chk_combination;
      hr_utility.set_location(l_proc, 9);
      end if;

 -- Added for checking Authorization Required, If value = 'N'
 -- pass Default Values of verified by and verified date to 'ins'
  if(l_authorization_required = 'N') then
    --l_verified_by := nvl(l_verified_by, fnd_global.USER_ID); -- Fix for bug 9780853
    l_verified_date := nvl(l_verified_date, sysdate);
  end if;


        --

        --
        -- Store the original ovn in case we rollback when p_validate is true
        --
        l_object_version_number  := p_object_version_number;
        --
        -- Process Logic - Update Doc Extra Info details
  --
  hr_dei_upd.upd
       (p_document_extra_info_id     => p_document_extra_info_id,
        p_document_type_id           => p_document_type_id,
        p_date_from                  => p_date_from,
        p_date_to                    => p_date_to,
        p_document_number            => p_document_number,
        p_issued_by                  => p_issued_by,
        p_issued_at                  => p_issued_at,
        p_issued_date                => p_issued_date,
        p_issuing_authority          => p_issuing_authority,
        p_verified_by                => l_verified_by,
        p_verified_date              => l_verified_date,
        p_related_object_name        => p_related_object_name,
        p_related_object_id_col      => p_related_object_id_col,
        p_related_object_id          => p_related_object_id,
        p_dei_attribute_category     => p_dei_attribute_category,
        p_dei_attribute1             => p_dei_attribute1,
        p_dei_attribute2             => p_dei_attribute2,
        p_dei_attribute3             => p_dei_attribute3,
        p_dei_attribute4             => p_dei_attribute4,
        p_dei_attribute5             => p_dei_attribute5,
        p_dei_attribute6             => p_dei_attribute6,
        p_dei_attribute7             => p_dei_attribute7,
        p_dei_attribute8             => p_dei_attribute8,
        p_dei_attribute9             => p_dei_attribute9,
        p_dei_attribute10            => p_dei_attribute10,
        p_dei_attribute11            => p_dei_attribute11,
        p_dei_attribute12            => p_dei_attribute12,
        p_dei_attribute13            => p_dei_attribute13,
        p_dei_attribute14            => p_dei_attribute14,
        p_dei_attribute15            => p_dei_attribute15,
        p_dei_attribute16            => p_dei_attribute16,
        p_dei_attribute17            => p_dei_attribute17,
        p_dei_attribute18            => p_dei_attribute18,
        p_dei_attribute19            => p_dei_attribute19,
        p_dei_attribute20            => p_dei_attribute20,
        p_dei_attribute21            => p_dei_attribute21,
        p_dei_attribute22            => p_dei_attribute22,
        p_dei_attribute23            => p_dei_attribute23,
        p_dei_attribute24            => p_dei_attribute24,
        p_dei_attribute25            => p_dei_attribute25,
        p_dei_attribute26            => p_dei_attribute26,
        p_dei_attribute27            => p_dei_attribute27,
        p_dei_attribute28            => p_dei_attribute28,
        p_dei_attribute29            => p_dei_attribute29,
        p_dei_attribute30            => p_dei_attribute30,
        p_dei_information_category   => p_dei_information_category,
        p_dei_information1           => p_dei_information1,
        p_dei_information2           => p_dei_information2,
        p_dei_information3           => p_dei_information3,
        p_dei_information4           => p_dei_information4,
        p_dei_information5           => p_dei_information5,
        p_dei_information6           => p_dei_information6,
        p_dei_information7           => p_dei_information7,
        p_dei_information8           => p_dei_information8,
        p_dei_information9           => p_dei_information9,
        p_dei_information10          => p_dei_information10,
        p_dei_information11          => p_dei_information11,
        p_dei_information12          => p_dei_information12,
        p_dei_information13          => p_dei_information13,
        p_dei_information14          => p_dei_information14,
        p_dei_information15          => p_dei_information15,
        p_dei_information16          => p_dei_information16,
        p_dei_information17          => p_dei_information17,
        p_dei_information18          => p_dei_information18,
        p_dei_information19          => p_dei_information19,
        p_dei_information20          => p_dei_information20,
        p_dei_information21          => p_dei_information21,
        p_dei_information22          => p_dei_information22,
        p_dei_information23          => p_dei_information23,
        p_dei_information24          => p_dei_information24,
        p_dei_information25          => p_dei_information25,
        p_dei_information26          => p_dei_information26,
        p_dei_information27          => p_dei_information27,
        p_dei_information28          => p_dei_information28,
        p_dei_information29          => p_dei_information29,
        p_dei_information30          => p_dei_information30,
        p_request_id                 => p_request_id,
        p_program_application_id     => p_program_application_id,
        p_program_id                 => p_program_id,
        p_program_update_date        => p_program_update_date,
        p_object_version_number      => p_object_version_number
     );


  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    hr_document_extra_info_bk2.update_doc_extra_info_a
     (
           p_document_extra_info_id     => p_document_extra_info_id,
           p_person_id                  => p_person_id,
           p_document_type_id           => p_document_type_id,
           p_date_from                  => p_date_from,
           p_date_to                    => p_date_to,
           p_document_number            => p_document_number,
           p_issued_by                  => p_issued_by,
           p_issued_at                  => p_issued_at,
           p_issued_date                => p_issued_date,
           p_issuing_authority          => p_issuing_authority,
           p_verified_by                => p_verified_by,
           p_verified_date              => p_verified_date,
           p_related_object_name        => p_related_object_name,
           p_related_object_id_col      => p_related_object_id_col,
           p_related_object_id          => p_related_object_id,
           p_dei_attribute_category     => p_dei_attribute_category,
           p_dei_attribute1             => p_dei_attribute1,
           p_dei_attribute2             => p_dei_attribute2,
           p_dei_attribute3             => p_dei_attribute3,
           p_dei_attribute4             => p_dei_attribute4,
           p_dei_attribute5             => p_dei_attribute5,
           p_dei_attribute6             => p_dei_attribute6,
           p_dei_attribute7             => p_dei_attribute7,
           p_dei_attribute8             => p_dei_attribute8,
           p_dei_attribute9             => p_dei_attribute9,
           p_dei_attribute10            => p_dei_attribute10,
           p_dei_attribute11            => p_dei_attribute11,
           p_dei_attribute12            => p_dei_attribute12,
           p_dei_attribute13            => p_dei_attribute13,
           p_dei_attribute14            => p_dei_attribute14,
           p_dei_attribute15            => p_dei_attribute15,
           p_dei_attribute16            => p_dei_attribute16,
           p_dei_attribute17            => p_dei_attribute17,
           p_dei_attribute18            => p_dei_attribute18,
           p_dei_attribute19            => p_dei_attribute19,
           p_dei_attribute20            => p_dei_attribute20,
           p_dei_attribute21            => p_dei_attribute21,
           p_dei_attribute22            => p_dei_attribute22,
           p_dei_attribute23            => p_dei_attribute23,
           p_dei_attribute24            => p_dei_attribute24,
           p_dei_attribute25            => p_dei_attribute25,
           p_dei_attribute26            => p_dei_attribute26,
           p_dei_attribute27            => p_dei_attribute27,
           p_dei_attribute28            => p_dei_attribute28,
           p_dei_attribute29            => p_dei_attribute29,
           p_dei_attribute30            => p_dei_attribute30,
           p_dei_information_category   => p_dei_information_category,
           p_dei_information1           => p_dei_information1,
           p_dei_information2           => p_dei_information2,
           p_dei_information3           => p_dei_information3,
           p_dei_information4           => p_dei_information4,
           p_dei_information5           => p_dei_information5,
           p_dei_information6           => p_dei_information6,
           p_dei_information7           => p_dei_information7,
           p_dei_information8           => p_dei_information8,
           p_dei_information9           => p_dei_information9,
           p_dei_information10          => p_dei_information10,
           p_dei_information11          => p_dei_information11,
           p_dei_information12          => p_dei_information12,
           p_dei_information13          => p_dei_information13,
           p_dei_information14          => p_dei_information14,
           p_dei_information15          => p_dei_information15,
           p_dei_information16          => p_dei_information16,
           p_dei_information17          => p_dei_information17,
           p_dei_information18          => p_dei_information18,
           p_dei_information19          => p_dei_information19,
           p_dei_information20          => p_dei_information20,
           p_dei_information21          => p_dei_information21,
           p_dei_information22          => p_dei_information22,
           p_dei_information23          => p_dei_information23,
           p_dei_information24          => p_dei_information24,
           p_dei_information25          => p_dei_information25,
           p_dei_information26          => p_dei_information26,
           p_dei_information27          => p_dei_information27,
           p_dei_information28          => p_dei_information28,
           p_dei_information29          => p_dei_information29,
           p_dei_information30          => p_dei_information30,
           p_request_id                 => p_request_id,
           p_program_application_id     => p_program_application_id,
           p_program_id                 => p_program_id,
           p_program_update_date        => p_program_update_date,
           p_object_version_number      => p_object_version_number
     );
  exception
          when hr_api.cannot_find_prog_unit then
            hr_api.cannot_find_prog_unit_error
        	    (p_module_name => 'UPDATE_DOC_EXTRA_INFO',
               p_hook_type   => 'AP'
              );
  end;
    --
    -- End of After Process User Hook call
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 11);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      ROLLBACK TO update_doc_extra_info;
      --
      -- Only set output warning arguments
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := l_object_version_number;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 12);
      --
    when others then
      --
      -- A validation or unexpected error has occurred
      --
      --
      ROLLBACK TO update_doc_extra_info;
      --
      -- set in out parameters and set out parameters
      --
          p_object_version_number  := l_ovn;
      --
      raise;
      --
  end update_doc_extra_info;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_person_extra_info >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_doc_extra_info
  (p_validate                      in     boolean  default false
  ,p_document_extra_info_id        in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_doc_extra_info';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_doc_extra_info;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_document_extra_info_bk3.delete_doc_extra_info_b
      (p_document_extra_info_id       => p_document_extra_info_id,
       p_object_version_number      => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_DOC_EXTRA_INFO',
             p_hook_type   => 'BP'
            );
end;
  --
  -- End of Before Process User Hook call
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete Document Extra Info details
  --
  hr_dei_del.del
  (p_document_extra_info_id        => p_document_extra_info_id
  ,p_object_version_number         => p_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_document_extra_info_bk3.delete_doc_extra_info_a
      (p_document_extra_info_id    => p_document_extra_info_id,
       p_object_version_number     => p_object_version_number
      );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'DELETE_DOC_EXTRA_INFO',
             p_hook_type   => 'AP'
            );
end;
  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_doc_extra_info;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    --
    ROLLBACK TO delete_doc_extra_info;
    --
    raise;
    --
end delete_doc_extra_info;
--

  --
  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------< set_reviewer >------------------------------|
  -- ----------------------------------------------------------------------------
  --
  procedure set_reviewer (itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout out nocopy varchar2)
  is
  --
    cursor c_reviewer (p_person_id varchar2, p_eff_date date) is
    select asg.supervisor_id
    from   per_all_assignments_f asg
    where  asg.person_id = p_person_id
    and    p_eff_date between asg.effective_start_date and asg.effective_end_date
    and    asg.primary_flag = 'Y'
    and    asg.assignment_type in ('E','C');
  --
    l_person_id        number;
    l_eff_date         date;
    l_supervisor_id    number;
    l_reviewer_role    wf_roles.name%type;
    l_display_name     wf_roles.display_name%type;
  --
  begin
  --
    if ( funcmode = 'RUN' ) then
      l_person_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'DOR_PERSON_ID');
      l_eff_date := wf_engine.GetItemAttrDate(itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'EFFECTIVE_DATE');
      open c_reviewer(l_person_id, l_eff_date);
      fetch c_reviewer into l_supervisor_id;
      close c_reviewer;
      --
      if (l_supervisor_id is not null) then
        wf_directory.GetRoleName(p_orig_system    => 'PER',
                                p_orig_system_id => l_supervisor_id,
                                p_name           => l_reviewer_role,
                                p_display_name   => l_display_name);
      end if;
      --
      if (l_reviewer_role is not null) then
        WF_ENGINE.setItemAttrText(itemtype, itemkey,'REVIEWER', l_reviewer_role);
        resultout := 'COMPLETE:' || 'Y';
      else
       resultout := 'COMPLETE:' || 'N';
      end if;

    else
       resultout := 'ERROR' || 'Y';
    end if;
  --
  exception
    when others then
    WF_CORE.CONTEXT('HR_DOCUMENT_EXTRA_INFO_API'
                   ,'SET_REVIEWER'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    raise;
  end set_reviewer;


  --
  --
  -- ----------------------------------------------------------------------------
  -- |----------------------------< set_reviewee >------------------------------|
  -- ----------------------------------------------------------------------------
  --
  procedure set_reviewee (itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout out nocopy varchar2)
  is

    l_reviewee_role    wf_roles.name%type;
  --
  begin
  --
    if ( funcmode = 'RUN' ) then
      l_reviewee_role := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                   itemkey  => itemkey,
                                                   aname    => 'REVIEWEE');
      if (l_reviewee_role is not null) then
        resultout := 'COMPLETE:' || 'Y';
      else
       resultout := 'COMPLETE:' || 'N';
      end if;

    else
       resultout := 'ERROR' || 'Y';
    end if;
  --
  exception
    when others then
    WF_CORE.CONTEXT('HR_DOCUMENT_EXTRA_INFO_API'
                   ,'SET_REVIEWEE'
                   ,itemtype
                   ,itemkey
                   ,to_char(actid)
                   ,funcmode);
    raise;
  end set_reviewee;

  --
  --
  -- ----------------------------------------------------------------------------
  -- |--------------------<  get_view_pg_wf_notif_params >----------------------|
  -- ----------------------------------------------------------------------------
  --
  procedure get_view_pg_wf_notif_params (p_notification_id in number,
                                         p_dor_id          out nocopy varchar2,
                                         p_person_id       out nocopy varchar2,
                                         p_effective_date  out nocopy date)
  is
  --
    cursor c_ntf_attr (p_ntf_id number)
    is
    select name, text_value, date_value
    from   wf_notification_attributes
    where  name IN ('DOR_ID', 'DOR_PERSON_ID', 'EFFECTIVE_DATE')
    and    notification_id = p_ntf_id;

  --
  begin
  --
    FOR ntf_attr_rec in c_ntf_attr(p_notification_id)
    LOOP
      if (ntf_attr_rec.name = 'DOR_ID' )
      then
        p_dor_id := ntf_attr_rec.text_value;
      --
      elsif (ntf_attr_rec.name = 'DOR_PERSON_ID')
      then
        p_person_id := ntf_attr_rec.text_value;
      --
      elsif (ntf_attr_rec.name = 'EFFECTIVE_DATE')
      then
        p_effective_date := ntf_attr_rec.date_value;
      end if;
    END LOOP;
  --
  end get_view_pg_wf_notif_params;

end hr_document_extra_info_api;

/
