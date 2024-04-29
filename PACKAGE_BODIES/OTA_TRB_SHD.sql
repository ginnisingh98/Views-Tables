--------------------------------------------------------
--  DDL for Package Body OTA_TRB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TRB_SHD" as
/* $Header: ottrbrhi.pkb 120.6.12000000.3 2007/07/05 09:22:53 aabalakr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
-- Private package current record structure definition
--
--
g_package  varchar2(33) := '  ota_trb_shd.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated, hr_api.child_integrity_violated or
--   hr_api.unique_integrity_violated has been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--   4) A unique integrity constraint can only be violated during INSERT or
--      UPDATE dml operation.
--
-- Pre Conditions:
--   Either hr_api.check_integrity_violated, hr_api.parent_integrity_violated,
--   hr_api.child_integrity_violated or hr_api.unique_integrity_violated has
--   been raised with the subsequent stripping of the constraint name from the
--   generated error message text.
--
-- In Arguments:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Developement dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'OTA_CHECK_START_END_TIMES') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_CHK_REQ_TIMES_END_FMT') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_CHK_REQ_TIMES_START_FMT') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_RESOURCE_BOOKINGS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_RESOURCE_BOOKINGS_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_RESOURCE_BOOKINGS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TRB_PRIMARY_VENUE_FLAG_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TRB_STATUS_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','40');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to populate the g_old_rec record with the current
--   row from the database for the specified primary key provided that the
--   primary key exists and is valid and does not already match the current
--   g_old_rec.
--   The function will always return a TRUE value if the g_old_rec is
--   populated with the current row. A FALSE value will be returned if all of
--   the primary key arguments are null.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
-- Post Success:
--   A value of TRUE will be returned indiciating that the g_old_rec is
--   current.
--   A value of FALSE will be returned if all of the primary key arguments
--   have a null value (this indicates that the row has not be inserted into
--   the Schema), and therefore could never have a corresponding row.
--
-- Post Failure:
--   A failure can only occur under two circumstances:
--   1) The primary key is invalid (i.e. a row does not exist for the
--      specified primary key values).
--   2) If an object_version_number exists but is NOT the same as the current
--      g_old_rec value.
--
-- Developer Implementation Notes:
--   None.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_resource_booking_id                in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		resource_booking_id,
	supplied_resource_id,
	event_id,
	date_booking_placed,
	object_version_number,
	status,
	absolute_price,
	booking_person_id,
	comments,
	contact_name,
	contact_phone_number,
	delegates_per_unit,
	quantity,
	required_date_from,
	required_date_to,
	required_end_time,
	required_start_time,
	deliver_to,
	primary_venue_flag,
	role_to_play,
	trb_information_category,
	trb_information1,
	trb_information2,
	trb_information3,
	trb_information4,
	trb_information5,
	trb_information6,
	trb_information7,
	trb_information8,
	trb_information9,
	trb_information10,
	trb_information11,
	trb_information12,
	trb_information13,
	trb_information14,
	trb_information15,
	trb_information16,
	trb_information17,
	trb_information18,
	trb_information19,
	trb_information20
	,display_to_learner_flag
   ,book_entire_period_flag
 --   ,unbook_request_flag
      ,chat_id
      ,forum_id
      ,timezone_code
    from	ota_resource_bookings
    where	resource_booking_id = p_resource_booking_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_resource_booking_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_resource_booking_id = g_old_rec.resource_booking_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
      --
      Open C_Sel1;
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_resource_booking_id                in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	resource_booking_id,
	supplied_resource_id,
	event_id,
	date_booking_placed,
	object_version_number,
	status,
	absolute_price,
	booking_person_id,
	comments,
	contact_name,
	contact_phone_number,
	delegates_per_unit,
	quantity,
	required_date_from,
	required_date_to,
	required_end_time,
	required_start_time,
	deliver_to,
	primary_venue_flag,
	role_to_play,
	trb_information_category,
	trb_information1,
	trb_information2,
	trb_information3,
	trb_information4,
	trb_information5,
	trb_information6,
	trb_information7,
	trb_information8,
	trb_information9,
	trb_information10,
	trb_information11,
	trb_information12,
	trb_information13,
	trb_information14,
	trb_information15,
	trb_information16,
	trb_information17,
	trb_information18,
	trb_information19,
	trb_information20
	,display_to_learner_flag
   ,book_entire_period_flag
  --  ,unbook_request_flag
      ,chat_id
      ,forum_id
      ,timezone_code
    from	ota_resource_bookings
    where	resource_booking_id = p_resource_booking_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ota_resource_bookings');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--
-- Post Success:
--   A returning record structure will be returned.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_resource_booking_id           in number,
	p_supplied_resource_id          in number,
	p_event_id                      in number,
	p_date_booking_placed           in date,
	p_object_version_number         in number,
	p_status                        in varchar2,
	p_absolute_price                in number,
	p_booking_person_id             in number,
	p_comments                      in varchar2,
	p_contact_name                  in varchar2,
	p_contact_phone_number          in varchar2,
	p_delegates_per_unit            in number,
	p_quantity                      in number,
	p_required_date_from            in date,
	p_required_date_to              in date,
	p_required_end_time             in varchar2,
	p_required_start_time           in varchar2,
	p_deliver_to                    in varchar2,
	p_primary_venue_flag            in varchar2,
	p_role_to_play                  in varchar2,
	p_trb_information_category      in varchar2,
	p_trb_information1              in varchar2,
	p_trb_information2              in varchar2,
	p_trb_information3              in varchar2,
	p_trb_information4              in varchar2,
	p_trb_information5              in varchar2,
	p_trb_information6              in varchar2,
	p_trb_information7              in varchar2,
	p_trb_information8              in varchar2,
	p_trb_information9              in varchar2,
	p_trb_information10             in varchar2,
	p_trb_information11             in varchar2,
	p_trb_information12             in varchar2,
	p_trb_information13             in varchar2,
	p_trb_information14             in varchar2,
	p_trb_information15             in varchar2,
	p_trb_information16             in varchar2,
	p_trb_information17             in varchar2,
	p_trb_information18             in varchar2,
	p_trb_information19             in varchar2,
	p_trb_information20             in varchar2
	,p_display_to_learner_flag      in     varchar2
	,p_book_entire_period_flag    in     varchar2
--	,p_unbook_request_flag    in     varchar2
	,p_chat_id                      in number
	,p_forum_id                     in number
	,p_timezone_code                IN VARCHAR2
	)
	Return g_rec_type is
--
  l_rec	g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.resource_booking_id              := p_resource_booking_id;
  l_rec.supplied_resource_id             := p_supplied_resource_id;
  l_rec.event_id                         := p_event_id;
  l_rec.date_booking_placed              := p_date_booking_placed;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.status                           := p_status;
  l_rec.absolute_price                   := p_absolute_price;
  l_rec.booking_person_id                := p_booking_person_id;
  l_rec.comments                         := p_comments;
  l_rec.contact_name                     := p_contact_name;
  l_rec.contact_phone_number             := p_contact_phone_number;
  l_rec.delegates_per_unit               := p_delegates_per_unit;
  l_rec.quantity                         := p_quantity;
  l_rec.required_date_from               := p_required_date_from;
  l_rec.required_date_to                 := p_required_date_to;
  l_rec.required_end_time                := p_required_end_time;
  l_rec.required_start_time              := p_required_start_time;
  l_rec.deliver_to                       := p_deliver_to;
  l_rec.primary_venue_flag               := p_primary_venue_flag;
  l_rec.role_to_play                     := p_role_to_play;
  l_rec.trb_information_category         := p_trb_information_category;
  l_rec.trb_information1                 := p_trb_information1;
  l_rec.trb_information2                 := p_trb_information2;
  l_rec.trb_information3                 := p_trb_information3;
  l_rec.trb_information4                 := p_trb_information4;
  l_rec.trb_information5                 := p_trb_information5;
  l_rec.trb_information6                 := p_trb_information6;
  l_rec.trb_information7                 := p_trb_information7;
  l_rec.trb_information8                 := p_trb_information8;
  l_rec.trb_information9                 := p_trb_information9;
  l_rec.trb_information10                := p_trb_information10;
  l_rec.trb_information11                := p_trb_information11;
  l_rec.trb_information12                := p_trb_information12;
  l_rec.trb_information13                := p_trb_information13;
  l_rec.trb_information14                := p_trb_information14;
  l_rec.trb_information15                := p_trb_information15;
  l_rec.trb_information16                := p_trb_information16;
  l_rec.trb_information17                := p_trb_information17;
  l_rec.trb_information18                := p_trb_information18;
  l_rec.trb_information19                := p_trb_information19;
  l_rec.trb_information20                := p_trb_information20;
  l_rec.display_to_learner_flag                := p_display_to_learner_flag ;
  l_rec.book_entire_period_flag                := p_book_entire_period_flag ;
 -- l_rec.unbook_request_flag                := p_unbook_request_flag  ;
  l_rec.chat_id                          := p_chat_id;
  l_rec.forum_id                         := p_forum_id;
  l_rec.timezone_code                    := p_timezone_code;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_trb_shd;

/
