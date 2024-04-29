--------------------------------------------------------
--  DDL for Package Body PQH_DOCUMENTS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DOCUMENTS_WRAPPER" As
/* $Header: pqdocwrp.pkb 120.0 2005/05/29 01:50:31 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_documents_wrapper.';
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_document >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default trunc(sysdate)
  ,p_datetrack_mode               in     varchar2
  ,p_document_id                  in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  ) is
  --
  -- Define Cursor over Here
  -- This cursor fetchs all records from child table irrespective of dates

  Cursor CurRetrieveChildRecord is
  Select document_attribute_id, object_version_number,effective_start_date
  From   pqh_document_attributes_f
  Where  document_id = p_document_id
  AND    p_effective_date between effective_start_date and effective_end_date;

  Cursor csr_child_records_for_zap IS
  Select document_attribute_id, object_version_number,effective_start_date
    From   pqh_document_attributes_f daf
    Where  daf.document_id = p_document_id
    and rowid = (select min(rowid)
                  From   pqh_document_attributes_f
                  Where  document_id = p_document_id
                and document_attribute_id = daf.document_attribute_id);

  --
  Cursor csr_child_attributes IS
  Select document_attribute_id,effective_start_date
    from pqh_document_attributes_f pdaf
    where pdaf.document_id = p_document_id
    and pdaf.effective_start_date >
    (
       select (effective_end_date) from pqh_documents_f pdf where p_effective_date between effective_start_date and effective_end_date
      and pdf.document_id = pdaf.document_id
    );

  Cursor csr_future_versions IS
  Select 'PRESENT' from pqh_documents_f
  where document_id =p_document_id
  and p_effective_date between effective_start_date and effective_end_date
  and effective_end_date <> hr_general.end_of_time;
  --
  --
  Cursor csr_future_eff_child_recs IS
  Select max(effective_start_date) from
  (
  Select effective_start_date
  from pqh_document_attributes_f
  where document_id =p_document_id
  and effective_start_date > p_effective_date
  and document_attribute_id NOT IN (select document_attribute_id
  from pqh_document_attributes_f
  where document_id =p_document_id
  and p_effective_date between effective_start_date and effective_end_date)
  );
  --
  Cursor csr_future_end_dt_child_recs IS
  Select max(effective_end_date)
  from (
  Select *
  From   pqh_document_attributes_f
  Where  document_id = p_document_id
  And  p_effective_date between effective_start_date and effective_end_date
  AND  p_effective_date < decode(effective_end_date , hr_general.end_of_time,p_effective_date-1,effective_end_date)
  );
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_document';
  l_ovn     number;
  l_effective_start_date date;
  l_future_versions VARCHAR2(100);
  l_eff_disp_date date:= null;
  l_max_future_end_dt date := null;
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
  -- Check any future versions are present in the system for the selected document
  -- as on that effective date or not.

 IF ( p_datetrack_mode = 'DELETE' ) THEN
--
    OPEN csr_future_versions;
      Fetch csr_future_versions into l_future_versions;
    CLOSE csr_future_versions;

    IF (l_future_versions = 'PRESENT') THEN
    --
    --
         fnd_message.set_name('PQH','PQH_SS_DELETE_MODE_INVALID');
         fnd_message.raise_error;

    --
    ELSE -- No Futuer versions of Record is present .
         -- Then check for child records which has Future Effective Start Date
          OPEN csr_future_eff_child_recs;
           FETCH csr_future_eff_child_recs into l_eff_disp_date;
          CLOSE csr_future_eff_child_recs;

          if (l_eff_disp_date is not null) then
           fnd_message.set_name('PQH','PQH_SS_FTR_CHLD_RECS_PRSNT');
           fnd_message.set_token('DATE_VALUE',l_eff_disp_date);
           fnd_message.raise_error;
          end if;

    END IF;

    OPEN csr_future_end_dt_child_recs;
     FETCH csr_future_end_dt_child_recs into l_max_future_end_dt;
    CLOSE csr_future_end_dt_child_recs;

    l_max_future_end_dt :=l_max_future_end_dt+1;

    IF (l_max_future_end_dt is not null) THEN
      fnd_message.set_name('PQH','PQH_SS_FTR_ENDTD_CHLD_RECS');
      fnd_message.set_token('DATE_VALUE',l_max_future_end_dt);
      fnd_message.raise_error;
    END IF;
--
--
  For  docAttributeCursorRow in CurRetrieveChildRecord
  loop
  l_ovn :=  docAttributeCursorRow.object_version_number;
  l_effective_start_date :=docAttributeCursorRow.effective_start_date;

   pqh_document_attributes_api.delete_document_attribute
      (p_validate                     => l_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_document_attribute_id        => docAttributeCursorRow.document_attribute_id
      ,p_object_version_number        => l_ovn
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      );
 hr_utility.set_location(' p_effective_start_date' ||p_effective_start_date,21);
 hr_utility.set_location(' p_effective_end_date' ||p_effective_end_date,21);
 end loop;
--
--
ELSIF ( p_datetrack_mode = 'ZAP' ) THEN
--
  For  docAttributeCursorRow in csr_child_records_for_zap
  loop
  l_ovn :=  docAttributeCursorRow.object_version_number;
  l_effective_start_date :=docAttributeCursorRow.effective_start_date;

   pqh_document_attributes_api.delete_document_attribute
      (p_validate                     => l_validate
      ,p_effective_date               => l_effective_start_date
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_document_attribute_id        => docAttributeCursorRow.document_attribute_id
      ,p_object_version_number        => l_ovn
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      );
 hr_utility.set_location(' p_effective_start_date' ||p_effective_start_date,21);
 hr_utility.set_location(' p_effective_end_date' ||p_effective_end_date,21);
 end loop;

ELSIF ( p_datetrack_mode = 'FUTURE_CHANGE' ) THEN
  For  docAttributeCsr in csr_child_attributes
  loop
   delete from pqh_document_attributes_f where
   document_attribute_id =  docAttributeCsr.document_attribute_id
   and effective_start_date >= docAttributeCsr.effective_start_date;
  end loop;

--
END IF;


  --
  -- Call API for dependent Child Records

  --
  -- Call API
  --
  pqh_documents_api.delete_document
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_document_id                  => p_document_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    );
  --
  -- If p_datetrack_mode is delete then we update the document attributes to be
  -- valid till end of time.
  --
  IF ( p_datetrack_mode = 'DELETE' ) THEN
    For  docAttributeCursor in CurRetrieveChildRecord
    loop

    update  pqh_document_attributes_f t
    set     t.effective_end_date    = hr_general.end_of_time
    where   t.document_attribute_id = docAttributeCursor.document_attribute_id
    and     effective_end_date      = p_effective_date
    and     effective_start_date    = docAttributeCursor.effective_start_date;

  end loop;
  END IF;
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
--
end pqh_documents_wrapper;

/
