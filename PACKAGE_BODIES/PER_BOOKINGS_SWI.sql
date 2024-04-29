--------------------------------------------------------
--  DDL for Package Body PER_BOOKINGS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BOOKINGS_SWI" As
/* $Header: pebkgswi.pkb 120.3 2007/12/14 11:13:30 uuddavol noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_bookings_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_per_booking >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_per_bookings
  (p_Rowid                        IN OUT NOCOPY VARCHAR2
  ,p_Booking_Id                   IN OUT NOCOPY NUMBER
  ,p_Business_Group_Id                   NUMBER
  ,p_Person_Id                           NUMBER
  ,p_Event_Id                            NUMBER
  ,p_Message                             VARCHAR2   default hr_api.g_varchar2
  ,p_Token                               VARCHAR2   default hr_api.g_varchar2
  ,p_Comments                            VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute_Category                  VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute1                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute2                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute3                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute4                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute5                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute6                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute7                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute8                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute9                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute10                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute11                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute12                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute13                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute14                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute15                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute16                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute17                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute18                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute19                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute20                         VARCHAR2   default hr_api.g_varchar2
  ,p_Primary_Interviewer_Flag            VARCHAR2   default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_interview_details_id             number;
  l_proc    varchar2(72) := g_package ||'create_per_bookings';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_per_bookings_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  -- Call API
  --
  per_bookings_pkg.Insert_Row(X_Rowid                        => p_Rowid
                             ,X_Booking_Id                   => p_Booking_Id
                             ,X_Business_Group_Id            => p_Business_Group_Id
                             ,X_Person_Id                    => p_Person_Id
                             ,X_Event_Id                     => p_Event_Id
                             ,X_Message                      => p_Message
                             ,X_Token                        => p_Token
                             ,X_Comments                     => p_Comments
                             ,X_Attribute_Category           => p_Attribute_Category
                             ,X_Attribute1                   => p_Attribute1
                             ,X_Attribute2                   => p_Attribute2
                             ,X_Attribute3                   => p_Attribute3
                             ,X_Attribute4                   => p_Attribute4
                             ,X_Attribute5                   => p_Attribute5
                             ,X_Attribute6                   => p_Attribute6
                             ,X_Attribute7                   => p_Attribute7
                             ,X_Attribute8                   => p_Attribute8
                             ,X_Attribute9                   => p_Attribute9
                             ,X_Attribute10                  => p_Attribute10
                             ,X_Attribute11                  => p_Attribute11
                             ,X_Attribute12                  => p_Attribute12
                             ,X_Attribute13                  => p_Attribute13
                             ,X_Attribute14                  => p_Attribute14
                             ,X_Attribute15                  => p_Attribute15
                             ,X_Attribute16                  => p_Attribute16
                             ,X_Attribute17                  => p_Attribute17
                             ,X_Attribute18                  => p_Attribute18
                             ,X_Attribute19                  => p_Attribute19
                             ,X_Attribute20                  => p_Attribute20
                             ,X_Primary_Interviewer_Flag     => p_Primary_Interviewer_Flag
                             );
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc, 20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_per_bookings_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to create_per_bookings_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_per_bookings;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_per_bookings ---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_per_bookings
  (p_Rowid                        IN OUT NOCOPY VARCHAR2
  ,p_Booking_Id                   IN OUT NOCOPY NUMBER
  ,p_Business_Group_Id                   NUMBER
  ,p_Person_Id                           NUMBER
  ,p_Event_Id                            NUMBER
  ,p_Message                             VARCHAR2   default hr_api.g_varchar2
  ,p_Token                               VARCHAR2   default hr_api.g_varchar2
  ,p_Comments                            VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute_Category                  VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute1                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute2                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute3                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute4                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute5                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute6                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute7                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute8                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute9                          VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute10                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute11                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute12                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute13                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute14                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute15                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute16                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute17                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute18                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute19                         VARCHAR2   default hr_api.g_varchar2
  ,p_Attribute20                         VARCHAR2   default hr_api.g_varchar2
  ,p_Primary_Interviewer_Flag            VARCHAR2   default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_interview_details_id             number;
  l_proc    varchar2(72) := g_package ||'update_per_bookings';
  --
  cursor csr_rowid is
         select rowid
           from per_bookings
          where booking_id = p_Booking_Id;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_per_bookings_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  open csr_rowid;
  fetch  csr_rowid into p_Rowid;
  if csr_rowid%found then
    close csr_rowid;
  else
    close csr_rowid;
    -- booking_id is invalid, raise error
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  --
  -- Call API
  --
  per_bookings_pkg.Update_Row(X_Rowid                        => p_Rowid
                             ,X_Booking_Id                   => p_Booking_Id
                             ,X_Business_Group_Id            => p_Business_Group_Id
                             ,X_Person_Id                    => p_Person_Id
                             ,X_Event_Id                     => p_Event_Id
                             ,X_Message                      => p_Message
                             ,X_Token                        => p_Token
                             ,X_Comments                     => p_Comments
                             ,X_Attribute_Category           => p_Attribute_Category
                             ,X_Attribute1                   => p_Attribute1
                             ,X_Attribute2                   => p_Attribute2
                             ,X_Attribute3                   => p_Attribute3
                             ,X_Attribute4                   => p_Attribute4
                             ,X_Attribute5                   => p_Attribute5
                             ,X_Attribute6                   => p_Attribute6
                             ,X_Attribute7                   => p_Attribute7
                             ,X_Attribute8                   => p_Attribute8
                             ,X_Attribute9                   => p_Attribute9
                             ,X_Attribute10                  => p_Attribute10
                             ,X_Attribute11                  => p_Attribute11
                             ,X_Attribute12                  => p_Attribute12
                             ,X_Attribute13                  => p_Attribute13
                             ,X_Attribute14                  => p_Attribute14
                             ,X_Attribute15                  => p_Attribute15
                             ,X_Attribute16                  => p_Attribute16
                             ,X_Attribute17                  => p_Attribute17
                             ,X_Attribute18                  => p_Attribute18
                             ,X_Attribute19                  => p_Attribute19
                             ,X_Attribute20                  => p_Attribute20
                             ,X_Primary_Interviewer_Flag     => p_Primary_Interviewer_Flag
                             );
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc, 20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_per_bookings_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to update_per_bookings_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_per_bookings;
-- ----------------------------------------------------------------------------
PROCEDURE delete_per_bookings
  (p_Booking_Id                   IN NUMBER
  ,p_return_status                    out nocopy varchar2
  ) is
  l_Rowid VARCHAR2(30);
  l_proc    varchar2(72) := g_package ||'delete_per_bookings';
  cursor csr_rowid is
           select rowid
             from per_bookings
	    where booking_id = p_Booking_Id;
begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_per_bookings_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  open csr_rowid;
  fetch  csr_rowid into l_Rowid;
  if csr_rowid%found then
    close csr_rowid;
  else
    close csr_rowid;
    -- booking_id is invalid, raise error
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  --
  -- Call API
  --
  per_bookings_pkg.Delete_Row(X_Rowid                        => l_Rowid);
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc, 20);
  ---
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_per_bookings_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to delete_per_bookings_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_per_bookings;

--
end PER_BOOKINGS_SWI;

/
