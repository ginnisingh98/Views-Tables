--------------------------------------------------------
--  DDL for Package IRC_COMMUNICATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_COMMUNICATIONS_SWI" AUTHID CURRENT_USER As
/* $Header: ircomswi.pkh 120.0.12010000.2 2008/11/13 18:44:38 amikukum ship $ */
-- ----------------------------------------------------------------------------
-- |--------------------------< close_communication >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_communications_api.close_communication
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
PROCEDURE close_communication
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_property_id    in     number
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_communication_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< close_communication >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_communications_api.close_communication
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
PROCEDURE update_communication
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_property_id    in     number
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_status                       in     varchar2
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_communication_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< define_comm_properties >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_communications_api.define_comm_properties
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
PROCEDURE define_comm_properties
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_default_comm_status          in     varchar2
  ,p_allow_attachment_flag        in     varchar2
  ,p_auto_notification_flag       in     varchar2
  ,p_allow_add_recipients         in     varchar2
  ,p_default_moderator            in     varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_communication_property_id    in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< create_communication >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_communications_api.start_communication
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
PROCEDURE create_communication
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_property_id    in     number
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_status                       in     varchar2
  ,p_start_date                   in     date
  ,p_communication_id             in      number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< update_comm_properties >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_communications_api.update_comm_properties
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
PROCEDURE update_comm_properties
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_default_comm_status          in     varchar2
  ,p_allow_attachment_flag        in     varchar2
  ,p_auto_notification_flag       in     varchar2
  ,p_allow_add_recipients         in     varchar2
  ,p_default_moderator            in     varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_information_category         in     varchar2  default hr_api.g_varchar2
  ,p_information1                 in     varchar2  default hr_api.g_varchar2
  ,p_information2                 in     varchar2  default hr_api.g_varchar2
  ,p_information3                 in     varchar2  default hr_api.g_varchar2
  ,p_information4                 in     varchar2  default hr_api.g_varchar2
  ,p_information5                 in     varchar2  default hr_api.g_varchar2
  ,p_information6                 in     varchar2  default hr_api.g_varchar2
  ,p_information7                 in     varchar2  default hr_api.g_varchar2
  ,p_information8                 in     varchar2  default hr_api.g_varchar2
  ,p_information9                 in     varchar2  default hr_api.g_varchar2
  ,p_information10                in     varchar2  default hr_api.g_varchar2
  ,p_communication_property_id    in     number
  ,p_object_version_number        in     out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_comm_properties >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: irc_communications_api.delete_comm_properties
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
PROCEDURE delete_comm_properties
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_communication_property_id    in     number
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_return_status                   out nocopy varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_comm_topic >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_comm_topic
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_id             in     number
  ,p_subject                      in     varchar2
  ,p_status                       in     varchar2
  ,p_communication_topic_id       in     number
  ,p_object_version_number        out    nocopy number
  ,p_return_status                out    nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_MESSAGE >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_communication_topic_id       in     number
  ,p_parent_id                    in     number    default hr_api.g_number
  ,p_message_subject              in     varchar2  default hr_api.g_varchar2
  ,p_message_post_date            in     date
  ,p_sender_type                  in     varchar2
  ,p_sender_id                    in     number
  ,p_message_body                 in     varchar2  default hr_api.g_varchar2
  ,p_document_type                in     varchar2  default hr_api.g_varchar2
  ,p_document_id                  in     number    default hr_api.g_number
  ,p_deleted_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_communication_message_id     in     number
  ,p_object_version_number        out    nocopy number
  ,p_return_status                out    nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_MESSAGE >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_deleted_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_communication_message_id     in     number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                out    nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< ADD_RECIPIENT >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure ADD_RECIPIENT
  (p_validate                     in     number     default hr_api.g_false_num
  ,p_effective_date                in     date
  ,p_communication_object_type     in     varchar2
  ,p_communication_object_id       in     number
  ,p_recipient_type                in     varchar2
  ,p_recipient_id                  in     number
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date      default hr_api.g_date
  ,p_primary_flag                  in     varchar2  default hr_api.g_varchar2
  ,p_communication_recipient_id    in     number
  ,p_object_version_number         out nocopy number
  ,p_return_status                 out nocopy varchar2
  );

--Save For Later Code Changes
-- ----------------------------------------------------------------------------
-- |-------------------------< process_com_api >--------------------------|
-- ----------------------------------------------------------------------------
procedure process_com_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< start_mass_communication >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE start_mass_communication
  (
   p_assignmentIdListGIn in  varchar2
  ,p_return_status                   out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< close_mass_communication >---------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE close_mass_communication
  (
   p_assignmentIdListGIn in  varchar2
  ,p_return_status                   out nocopy varchar2
  );
--
--
 end irc_communications_swi;

/
