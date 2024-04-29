--------------------------------------------------------
--  DDL for Package IRC_COMMUNICATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_COMMUNICATIONS_API" AUTHID CURRENT_USER as
/* $Header: ircomapi.pkh 120.2.12010000.4 2010/04/07 09:53:10 vmummidi ship $ */
--
--
--
--
type assoc_arr is table of number index by binary_integer;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DEFINE_COMM_PROPERTIES >------------------------|
-- ----------------------------------------------------------------------------
--
procedure DEFINE_COMM_PROPERTIES
  (p_validate                      in   boolean  default false
  ,p_effective_date                in   date
  ,p_object_type                   in   varchar2
  ,p_object_id                     in   number
  ,p_default_comm_status           in   varchar2
  ,p_allow_attachment_flag         in   varchar2
  ,p_auto_notification_flag        in   varchar2
  ,p_allow_add_recipients          in   varchar2
  ,p_default_moderator             in   varchar2
  ,p_attribute_category            in   varchar2  default null
  ,p_attribute1                    in   varchar2  default null
  ,p_attribute2                    in   varchar2  default null
  ,p_attribute3                    in   varchar2  default null
  ,p_attribute4                    in   varchar2  default null
  ,p_attribute5                    in   varchar2  default null
  ,p_attribute6                    in   varchar2  default null
  ,p_attribute7                    in   varchar2  default null
  ,p_attribute8                    in   varchar2  default null
  ,p_attribute9                    in   varchar2  default null
  ,p_attribute10                   in   varchar2  default null
  ,p_information_category          in   varchar2  default null
  ,p_information1                  in   varchar2  default null
  ,p_information2                  in   varchar2  default null
  ,p_information3                  in   varchar2  default null
  ,p_information4                  in   varchar2  default null
  ,p_information5                  in   varchar2  default null
  ,p_information6                  in   varchar2  default null
  ,p_information7                  in   varchar2  default null
  ,p_information8                  in   varchar2  default null
  ,p_information9                  in   varchar2  default null
  ,p_information10                 in   varchar2  default null
  ,p_communication_property_id        out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_COMM_PROPERTIES >--------------- -----|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_COMM_PROPERTIES
(p_validate                      in   boolean  default false
  ,p_effective_date                in   date
  ,p_object_type                   in   varchar2
  ,p_object_id                     in   number
  ,p_default_comm_status           in   varchar2
  ,p_allow_attachment_flag         in   varchar2
  ,p_auto_notification_flag        in   varchar2
  ,p_allow_add_recipients          in   varchar2
  ,p_default_moderator             in   varchar2
  ,p_attribute_category            in   varchar2  default null
  ,p_attribute1                    in   varchar2  default null
  ,p_attribute2                    in   varchar2  default null
  ,p_attribute3                    in   varchar2  default null
  ,p_attribute4                    in   varchar2  default null
  ,p_attribute5                    in   varchar2  default null
  ,p_attribute6                    in   varchar2  default null
  ,p_attribute7                    in   varchar2  default null
  ,p_attribute8                    in   varchar2  default null
  ,p_attribute9                    in   varchar2  default null
  ,p_attribute10                   in   varchar2  default null
  ,p_information_category          in   varchar2  default null
  ,p_information1                  in   varchar2  default null
  ,p_information2                  in   varchar2  default null
  ,p_information3                  in   varchar2  default null
  ,p_information4                  in   varchar2  default null
  ,p_information5                  in   varchar2  default null
  ,p_information6                  in   varchar2  default null
  ,p_information7                  in   varchar2  default null
  ,p_information8                  in   varchar2  default null
  ,p_information9                  in   varchar2  default null
  ,p_information10                 in   varchar2  default null
  ,p_communication_property_id     in   number
  ,p_object_version_number         in   out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_COMMUNICATION >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_communication
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_status                        in     varchar2
  ,p_start_date                    in     date
  ,p_object_version_number  out nocopy number
  ,p_communication_id       out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< START_COMMUNICATION >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure start_communication
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_start_date                    in     date
  ,p_object_version_number  out nocopy number
  ,p_communication_id       out nocopy number
  );
--
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CLOSE_COMMUNICATION >------------------------|
-- ----------------------------------------------------------------------------
--
procedure close_communication
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_communication_id              in     number
  ,p_object_version_number      in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_COMMUNICATION >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_communication
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_property_id     in     number
  ,p_object_type                   in     varchar2
  ,p_object_id                     in     number
  ,p_status                        in     varchar2
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_communication_id              in     number
  ,p_object_version_number      in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< DELETE_COMM_PROPERTIES >---------------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_comm_properties
  (
    p_validate                    in boolean    default false
  , p_object_version_number       in number
  , p_communication_property_id   in number
  , p_effective_date              in date       default null
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_COMM_TOPIC >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_comm_topic
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_id              in     number
  ,p_subject                       in     varchar2
  ,p_status                        in     varchar2
  ,p_communication_topic_id        out    nocopy number
  ,p_object_version_number         out    nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CREATE_MESSAGE >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_message
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_communication_topic_id       in     number
  ,p_parent_id                    in     number
  ,p_message_subject              in     varchar2
  ,p_message_post_date            in     date
  ,p_sender_type                  in     varchar2
  ,p_sender_id                    in     number
  ,p_message_body                 in     varchar2
  ,p_document_type                in     varchar2
  ,p_document_id                  in     number
  ,p_deleted_flag                 in     varchar2
  ,p_communication_message_id     out nocopy number
  ,p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< UPDATE_MESSAGE >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_message
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_deleted_flag                 in     varchar2
  ,p_communication_message_id     in     number
  ,p_object_version_number        in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< ADD_RECIPIENT >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure ADD_RECIPIENT
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_communication_object_type     in     varchar2
  ,p_communication_object_id       in     number
  ,p_recipient_type                in     varchar2
  ,p_recipient_id                  in     number
  ,p_start_date_active             in     date
  ,p_end_date_active               in     date
  ,p_primary_flag                  in     varchar2
  ,p_communication_recipient_id    out nocopy number
  ,p_object_version_number         out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< GET_RECIPIENT_LIST >---------------------|
-- ----------------------------------------------------------------------------
--
function get_rcpt_list(p_object_id IN number,filter varchar2 ) return varchar2;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< GET_LOOKUP_MEANING >---------------------|
-- ----------------------------------------------------------------------------
--
function get_lookup_meaning (
p_lookup_code hr_lookups.lookup_code%TYPE
,p_lookup_type hr_lookups.lookup_type%TYPE)
return  varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< COMMUNICATION_EXISTS>------------------------|
-- ----------------------------------------------------------------------------
--
function communication_exists
(
   p_assignmentIdIn           in number
  ,p_communicationIdOut       out nocopy number
  ,p_communicationStatusOut   out nocopy varchar2
  ,p_object_version_numberOut out nocopy number
  ,p_object_typeOut           out nocopy varchar2
  ,p_start_dateOut            out nocopy date
)  return boolean;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< START_MASS_COMMUNICATION>--------------------|
-- ----------------------------------------------------------------------------
--
procedure start_mass_communication
(
  p_assignmentIdListIn in  varchar2
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CLOSE_MASS_COMMUNICATION>--------------------|
-- ----------------------------------------------------------------------------
--
procedure close_mass_communication
(
  p_assignmentIdListIn in  varchar2
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< HANDLE_ATTACHMENTS_ON_COMMIT>---------------|
-- ----------------------------------------------------------------------------
--
procedure handle_attachments_on_commit
(
 p_message_list in varchar2
 ,p_dummy_attachment_id number
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< COPY_COMM_TO_APL_ASG>-----------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_comm_to_apl_asg
(
  p_target_asg_id in number
 ,p_source_asg_id in number
);
--
end IRC_COMMUNICATIONS_API;

/
