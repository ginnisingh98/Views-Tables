--------------------------------------------------------
--  DDL for Package PER_BOOKINGS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BOOKINGS_SWI" AUTHID CURRENT_USER As
/* $Header: pebkgswi.pkh 120.4 2007/12/14 09:33:30 uuddavol noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_per_booking >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.create_ame_attribute
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
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
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_per_bookings >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: ame_attribute_api.create_ame_attribute
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_per_booking >---------------------------|
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
  );
---
PROCEDURE delete_per_bookings
  (p_Booking_Id                   IN NUMBER
  ,p_return_status                    out nocopy varchar2
  );
---
end PER_BOOKINGS_SWI;

/
