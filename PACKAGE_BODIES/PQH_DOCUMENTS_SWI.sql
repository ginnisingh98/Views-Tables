--------------------------------------------------------
--  DDL for Package Body PQH_DOCUMENTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DOCUMENTS_SWI" As
/* $Header: pqdocswi.pkb 120.1 2005/09/15 14:17:33 rthiagar noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_documents_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_document >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_short_name                   in     varchar2
  ,p_document_name                in     varchar2
  ,p_file_id                      in     number
  ,p_formula_id                   in     number
  ,p_enable_flag                  in     varchar2
  ,p_document_category            in     varchar2
  ,p_document_id                     out NOCOPY number
  ,p_object_version_number           out NOCOPY number
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  /* Added for XDO changes */
  ,p_lob_code                     in     varchar2
  ,p_language                     in     varchar2
  ,p_territory                    in     varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_document_id                  number;
  l_proc    varchar2(72) := g_package ||'create_document';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_document_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
--  pqh_doc_ins.set_base_key_value
 --   (p_document_id => p_document_id
  --  );
  --
  -- Call API
  --
  pqh_documents_api.create_print_document
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_short_name                   => p_short_name
    ,p_document_name                => p_document_name
    ,p_file_id                      => p_file_id
    ,p_formula_id                   => p_formula_id
    ,p_enable_flag                  => p_enable_flag
    ,p_document_id                  => l_document_id
    ,p_document_category            => p_document_category
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    /* Added for XDO changes */
    ,p_lob_code                     => p_lob_code
    ,p_language                     => p_language
    ,p_territory                    => p_territory
    );
  --
 hr_utility.set_location(' Document Id '||l_document_id,18);
 p_document_id := l_document_id;
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_document_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_document_id                  := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_document_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_document_id                  := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_document;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_document >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_document_id                  in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_document';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_document_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  pqh_documents_api.delete_print_document
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_document_id                  => p_document_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_document_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_document_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_document;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_document >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_short_name                   in     varchar2  default hr_api.g_varchar2
  ,p_document_name                in     varchar2  default hr_api.g_varchar2
  ,p_file_id                      in     number    default hr_api.g_number
  ,p_formula_id                   in     number    default hr_api.g_number
  ,p_enable_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_document_category            in     varchar2  default hr_api.g_varchar2
  ,p_document_id                  in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  /* Added for XDO changes */
  ,p_lob_code                     in     varchar2
  ,p_language                     in     varchar2
  ,p_territory                    in     varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_document';
--
Cursor csr_get_file_id IS
Select file_id exisiting_file_id
from pqh_documents_f
where document_id = p_document_id
and p_effective_date between effective_start_date and effective_end_date;
--
--
Cursor csr_child_records_4_zap IS
Select document_attribute_id , object_version_number ,effective_start_date
from pqh_document_attributes_f
where document_id =p_document_id
and effective_start_date > p_effective_date
and document_attribute_id NOT IN (select document_attribute_id
from pqh_document_attributes_f
where document_id =p_document_id
and p_effective_date between effective_start_date and effective_end_date);
--
--
Cursor csr_child_records_4_fut_del IS
Select document_attribute_id , object_version_number
from pqh_document_attributes_f
where document_id =p_document_id
and effective_start_date > p_effective_date
and document_attribute_id IN (select document_attribute_id
from pqh_document_attributes_f
where document_id =p_document_id
and p_effective_date between effective_start_date and effective_end_date);
--
--
Cursor csr_child_records_4_del IS
Select document_attribute_id, object_version_number,effective_start_date
from pqh_document_attributes_f
where document_id = p_document_id
and p_effective_date between effective_start_date and effective_end_date
and effective_end_date = hr_general.end_of_time;

--
--
l_current_file_id number;
l_existing_file_id number;
l_document_attribute_id number;
l_ovn number;
l_esd date;
l_eed date;
l_return_status varchar2(100);
l_eff_date date;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_document_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  -- Added Code here for deletion Bug testing


  l_existing_file_id := p_file_id;

OPEN csr_get_file_id;
FETCH csr_get_file_id into l_current_file_id;
CLOSE csr_get_file_id;

if (l_current_file_id <> l_existing_file_id) then
--
-- If attached file is changed then need to remove all the dependent child records for that
-- record . Those deletions can be of following types
-- 1. Do No operation on the records which are already end-dated prior to the effective date
-- 2. Find the records which has future start date and ZAP those records
-- 3. Find the effective records , which has no future versions , DELETE
-- 4. Find the effective records, which has future versions , DO FUTURE_CHANGE delete then DELETE
--

   For l_rec in csr_child_records_4_zap loop

      l_document_attribute_id := l_rec.document_attribute_id;
      l_ovn := l_rec.object_version_number;

       pqh_document_attributes_swi.delete_document_attribute
       (
       p_validate => p_validate,
       p_effective_date => l_rec.effective_start_date,
       p_datetrack_mode => 'ZAP' ,
       p_document_attribute_id => l_document_attribute_id,
       p_object_version_number =>  l_ovn ,
       p_effective_start_date => l_esd,
       p_effective_end_date => l_esd,
       p_return_status  => l_return_status
       );
    end loop;
    --
    --
   For l_rec in csr_child_records_4_fut_del loop
      l_document_attribute_id := l_rec.document_attribute_id;
      l_ovn := l_rec.object_version_number;
       pqh_document_attributes_swi.delete_document_attribute
       (
       p_validate => p_validate,
       p_effective_date => p_effective_date,
       p_datetrack_mode => 'DELETE' ,
       p_document_attribute_id => l_document_attribute_id,
       p_object_version_number =>  l_ovn ,
       p_effective_start_date => l_esd,
       p_effective_end_date => l_esd,
       p_return_status  => l_return_status
       );
   end loop;
   --
   --

   For l_rec in csr_child_records_4_del loop
   l_document_attribute_id := l_rec.document_attribute_id;
   l_ovn := l_rec.object_version_number;
   l_eff_date := l_rec.effective_start_date;

   if (l_eff_date = p_effective_date) then

   	 pqh_document_attributes_swi.delete_document_attribute
   	 (
   	 p_validate => p_validate,
   	 p_effective_date => p_effective_date,
   	 p_datetrack_mode => 'ZAP' ,
   	 p_document_attribute_id => l_document_attribute_id,
   	 p_object_version_number =>  l_ovn ,
   	 p_effective_start_date => l_esd,
   	 p_effective_end_date => l_esd,
   	 p_return_status  => l_return_status
   	 );
    else
    	 pqh_document_attributes_swi.delete_document_attribute
       	 (
       	 p_validate => p_validate,
       	 p_effective_date => p_effective_date-1,
       	 p_datetrack_mode => 'DELETE' ,
       	 p_document_attribute_id => l_document_attribute_id,
       	 p_object_version_number =>  l_ovn ,
       	 p_effective_start_date => l_esd,
       	 p_effective_end_date => l_esd,
       	 p_return_status  => l_return_status
   	 );

   end if;


    end loop;
    --
    --
end if;
--
  --
  pqh_documents_api.update_print_document
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_short_name                   => p_short_name
    ,p_document_name                => p_document_name
    ,p_file_id                      => p_file_id
    ,p_formula_id                   => p_formula_id
    ,p_enable_flag                  => p_enable_flag
    ,p_document_category            => p_document_category
    ,p_document_id                  => p_document_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    /* Added for XDO changes */
    ,p_lob_code                     => p_lob_code
    ,p_language                     => p_language
    ,p_territory                    => p_territory
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_document_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_document_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_document;
end pqh_documents_swi;

/
