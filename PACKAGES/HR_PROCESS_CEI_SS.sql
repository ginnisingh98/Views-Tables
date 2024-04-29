--------------------------------------------------------
--  DDL for Package HR_PROCESS_CEI_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PROCESS_CEI_SS" authid current_user as
/* $Header: hrceiwrs.pkh 120.0 2005/05/30 23:10 appldev noship $ */

-- ----------------------------------------------------------------------------
-- |-----------------------------< get_row_status >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the row status for contact extra information record
--   as follows.
--    "DB_ROW"            : default
--    "FUTURE_CHANGE_ROW" : record which changed in future date
--    "FUTURE_DELETE_ROW" : record which deleted in future date
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_contact_extra_info_id number
--   p_effective_date        date
--
-- Post Success:
--   The row status will be returned.
--
-- Post Failure:
--   The row status will no be returned and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
function get_row_status
(
	p_contact_extra_info_id in number,
	p_effective_date        in date
) return varchar2;

-- ----------------------------------------------------------------------------
-- |--------------------------< set_transaction_step >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates the transaction step for contact extra information.
--
-- Pre-Requisities:
--   N/A
--
-- In Parameters:
--   p_item_type               varchar2
--   p_item_key                varchar2
--   p_activity_id             number
--   p_login_person_id         number
--   p_action                  varchar2
--   p_effective_date          date     default null
--   p_date_track_option       varchar2 default null
--   p_contact_extra_info_id   number   default null
--   p_contact_relationship_id number   default null
--   p_information_type        varchar2 default null
--   p_object_version_number   number   default null
--   p_information_category    varchar2 default null
--   p_information1 - 30       varchar2 default null
--   p_attribute_category      varchar2 default null
--   p_attribute1 - 20         varchar2 default null
--
-- Post Success:
--   The transaction step will be created.
--
-- Post Failure:
--   The transaction step will no be created and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure set_transaction_step
(
	p_item_type               in         varchar2,
	p_item_key                in         varchar2,
	p_activity_id             in         number,
	p_login_person_id         in         number,
	p_action                  in         varchar2, -- 'INSERT' or 'UPDATE' or 'DELETE'
	p_effective_date          in         date     default null,
	p_date_track_option       in         varchar2 default null,
	p_contact_extra_info_id   in         number   default null,
	p_contact_relationship_id in         number   default null,
	p_information_type        in         varchar2 default null,
	p_object_version_number   in         number   default null,
	p_information_category    in         varchar2 default null,
	p_information1            in         varchar2 default null,
	p_information2            in         varchar2 default null,
	p_information3            in         varchar2 default null,
	p_information4            in         varchar2 default null,
	p_information5            in         varchar2 default null,
	p_information6            in         varchar2 default null,
	p_information7            in         varchar2 default null,
	p_information8            in         varchar2 default null,
	p_information9            in         varchar2 default null,
	p_information10           in         varchar2 default null,
	p_information11           in         varchar2 default null,
	p_information12           in         varchar2 default null,
	p_information13           in         varchar2 default null,
	p_information14           in         varchar2 default null,
	p_information15           in         varchar2 default null,
	p_information16           in         varchar2 default null,
	p_information17           in         varchar2 default null,
	p_information18           in         varchar2 default null,
	p_information19           in         varchar2 default null,
	p_information20           in         varchar2 default null,
	p_information21           in         varchar2 default null,
	p_information22           in         varchar2 default null,
	p_information23           in         varchar2 default null,
	p_information24           in         varchar2 default null,
	p_information25           in         varchar2 default null,
	p_information26           in         varchar2 default null,
	p_information27           in         varchar2 default null,
	p_information28           in         varchar2 default null,
	p_information29           in         varchar2 default null,
	p_information30           in         varchar2 default null,
	p_attribute_category      in         varchar2 default null,
	p_attribute1              in         varchar2 default null,
	p_attribute2              in         varchar2 default null,
	p_attribute3              in         varchar2 default null,
	p_attribute4              in         varchar2 default null,
	p_attribute5              in         varchar2 default null,
	p_attribute6              in         varchar2 default null,
	p_attribute7              in         varchar2 default null,
	p_attribute8              in         varchar2 default null,
	p_attribute9              in         varchar2 default null,
	p_attribute10             in         varchar2 default null,
	p_attribute11             in         varchar2 default null,
	p_attribute12             in         varchar2 default null,
	p_attribute13             in         varchar2 default null,
	p_attribute14             in         varchar2 default null,
	p_attribute15             in         varchar2 default null,
	p_attribute16             in         varchar2 default null,
	p_attribute17             in         varchar2 default null,
	p_attribute18             in         varchar2 default null,
	p_attribute19             in         varchar2 default null,
	p_attribute20             in         varchar2 default null
);

-- ----------------------------------------------------------------------------
-- |------------------------------< process_api >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure execute create, update or delete contact extra information
--   APIs depending on the action type.
--
-- Pre-Requisities:
--   Transaction step exists in the database against transaction_step_id
--   parameter.
--
-- In Parameters:
--   p_validate            boolean  default false
--   p_transaction_step_id number   default null
--   p_effective_date      varchar2 default null
--
-- Post Success:
--   One of insert, update or delete API will be executed and the record of
--   contact extra information will be created, updated or deleted.
--
-- Post Failure:
--   The record of contact extra information will not be created, updated or
--   deleted and an error will be raised.
--
-- Developer Implementation Notes:
--   N/A
--
-- Access Status:
--   Public
--
-- {End Of Comments}
-------------------------------------------------------------------------------
procedure process_api
(
	p_validate            in boolean  default false,
	p_transaction_step_id in number   default null,
	p_effective_date      in varchar2 default null
);

end hr_process_cei_ss;

 

/
