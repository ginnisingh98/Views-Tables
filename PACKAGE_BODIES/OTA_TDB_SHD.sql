--------------------------------------------------------
--  DDL for Package Body OTA_TDB_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TDB_SHD" as
/* $Header: ottdb01t.pkb 120.26.12010000.3 2009/10/12 06:51:15 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_tdb_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc        varchar2(72) := g_package||'return_api_dml_status';
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
Procedure constraint_error
            (p_constraint_name in varchar2) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'OTA_DELEGATE_BOOKINGS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_DELEGATE_BOOKINGS_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_DELEGATE_BOOKINGS_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_DELEGATE_BOOKINGS_UK1') Then
    fnd_message.set_name('OTA','OTA_13886_TDB_LINE_DUPLICATE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_TDB_INTERNAL_BOOKING_F_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'OTA_TDB_SUCCESSFUL_ATTENDA_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'OTA_TDB_DELEGATE_CONTACT_NULL') Then
    fnd_message.set_name('OTA','OTA_13621_TDB_CON_DEL');
    fnd_message.raise_error;
  Elsif (p_constraint_name = 'OTA_TDB_PERSON_ADDRESS') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'OTA_TDB_STUDENT_PLACES') Then
     -- Modified for bug#4522799
     fnd_message.set_name('OTA','OTA_13954_TDB_MIN_NUM_PLACES');
     fnd_message.raise_error;
     -- hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     -- hr_utility.set_message_token('PROCEDURE', l_proc);
     --  hr_utility.set_message_token('STEP','40');
     -- hr_utility.raise_error;
  Elsif (p_constraint_name = 'OTA_TDB_CORRESPONDENT_ADDRESS') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','45');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'OTA_TDB_CUSTOMER_ID_NOT_NULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','50');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'OTA_TDB_ORGANIZATION_NOT_NULL') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','55');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'OTA_TDB_CORRESPONDENT_T') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','60');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','65');
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_booking_id                         in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select booking_id,
        booking_status_type_id,
        delegate_person_id,
        contact_id,
        business_group_id,
        event_id,
        customer_id,
        authorizer_person_id,
        date_booking_placed,
        corespondent,
        internal_booking_flag,
        number_of_places,
        object_version_number,
        administrator,
        booking_priority,
        comments,
        contact_address_id,
        delegate_contact_phone,
        delegate_contact_fax,
        third_party_customer_id,
        third_party_contact_id,
        third_party_address_id,
        third_party_contact_phone,
        third_party_contact_fax,
        date_status_changed,
        failure_reason,
        attendance_result,
        language_id,
        source_of_booking,
        special_booking_instructions,
        successful_attendance_flag,
        tdb_information_category,
        tdb_information1,
        tdb_information2,
        tdb_information3,
        tdb_information4,
        tdb_information5,
        tdb_information6,
        tdb_information7,
        tdb_information8,
        tdb_information9,
        tdb_information10,
        tdb_information11,
        tdb_information12,
        tdb_information13,
        tdb_information14,
        tdb_information15,
        tdb_information16,
        tdb_information17,
        tdb_information18,
        tdb_information19,
        tdb_information20,
        organization_id,
        sponsor_person_id,
        sponsor_assignment_id,
        person_address_id,
        delegate_assignment_id,
        delegate_contact_id,
        delegate_contact_email,
        third_party_email,
        person_address_type,
        line_id,
        org_id,
        daemon_flag,
        daemon_type,
        old_event_id,
        quote_line_id,
        interface_source,
      total_training_time,
      content_player_status,
      score,
      completed_content,
      total_content   ,
      booking_justification_id,
      is_history_flag,
      sign_eval_status,
      is_mandatory_enrollment
    from        ota_delegate_bookings
    where       booking_id = p_booking_id;
--
  l_proc        varchar2(72)    := g_package||'api_updating';
  l_fct_ret     boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
        p_booking_id is null and
        p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
        p_booking_id = g_old_rec.booking_id and
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
      -- Select the current row into g_old_rec
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
  p_booking_id                         in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select      booking_id,
        booking_status_type_id,
        delegate_person_id,
        contact_id,
        business_group_id,
        event_id,
        customer_id,
        authorizer_person_id,
        date_booking_placed,
        corespondent,
        internal_booking_flag,
        number_of_places,
        object_version_number,
        administrator,
        booking_priority,
        comments,
        contact_address_id,
        delegate_contact_phone,
        delegate_contact_fax,
        third_party_customer_id,
        third_party_contact_id,
        third_party_address_id,
        third_party_contact_phone,
        third_party_contact_fax,
        date_status_changed,
        failure_reason,
        attendance_result,
        language_id,
        source_of_booking,
        special_booking_instructions,
        successful_attendance_flag,
        tdb_information_category,
        tdb_information1,
        tdb_information2,
        tdb_information3,
        tdb_information4,
        tdb_information5,
        tdb_information6,
        tdb_information7,
        tdb_information8,
        tdb_information9,
        tdb_information10,
        tdb_information11,
        tdb_information12,
        tdb_information13,
        tdb_information14,
        tdb_information15,
        tdb_information16,
        tdb_information17,
        tdb_information18,
        tdb_information19,
        tdb_information20,
        organization_id,
        sponsor_person_id,
        sponsor_assignment_id,
        person_address_id,
        delegate_assignment_id,
        delegate_contact_id,
        delegate_contact_email,
        third_party_email,
        person_address_type,
        created_by,
      line_id,
        org_id,
        daemon_flag,
        daemon_type,
        old_event_id,
        quote_line_id,
        interface_source,
      total_training_time,
      content_player_status,
      score,
      completed_content,
      total_content,
      booking_justification_id,
      is_history_flag,
      sign_eval_status,
      is_mandatory_enrollment
    from        ota_delegate_bookings
    where       booking_id = p_booking_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
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
  Fetch C_Sel1 Into
        g_old_rec.booking_id,
        g_old_rec.booking_status_type_id,
        g_old_rec.delegate_person_id,
        g_old_rec.contact_id,
        g_old_rec.business_group_id,
        g_old_rec.event_id,
        g_old_rec.customer_id,
        g_old_rec.authorizer_person_id,
        g_old_rec.date_booking_placed,
        g_old_rec.corespondent,
        g_old_rec.internal_booking_flag,
        g_old_rec.number_of_places,
        g_old_rec.object_version_number,
        g_old_rec.administrator,
        g_old_rec.booking_priority,
        g_old_rec.comments,
        g_old_rec.contact_address_id,
        g_old_rec.delegate_contact_phone,
        g_old_rec.delegate_contact_fax,
        g_old_rec.third_party_customer_id,
        g_old_rec.third_party_contact_id,
        g_old_rec.third_party_address_id,
        g_old_rec.third_party_contact_phone,
        g_old_rec.third_party_contact_fax,
        g_old_rec.date_status_changed,
        g_old_rec.failure_reason,
        g_old_rec.attendance_result,
        g_old_rec.language_id,
        g_old_rec.source_of_booking,
        g_old_rec.special_booking_instructions,
        g_old_rec.successful_attendance_flag,
        g_old_rec.tdb_information_category,
        g_old_rec.tdb_information1,
        g_old_rec.tdb_information2,
        g_old_rec.tdb_information3,
        g_old_rec.tdb_information4,
        g_old_rec.tdb_information5,
        g_old_rec.tdb_information6,
        g_old_rec.tdb_information7,
        g_old_rec.tdb_information8,
        g_old_rec.tdb_information9,
        g_old_rec.tdb_information10,
        g_old_rec.tdb_information11,
        g_old_rec.tdb_information12,
        g_old_rec.tdb_information13,
        g_old_rec.tdb_information14,
        g_old_rec.tdb_information15,
        g_old_rec.tdb_information16,
        g_old_rec.tdb_information17,
        g_old_rec.tdb_information18,
        g_old_rec.tdb_information19,
        g_old_rec.tdb_information20,
        g_old_rec.organization_id,
        g_old_rec.sponsor_person_id,
        g_old_rec.sponsor_assignment_id,
        g_old_rec.person_address_id,
        g_old_rec.delegate_assignment_id,
        g_old_rec.delegate_contact_id,
        g_old_rec.delegate_contact_email,
        g_old_rec.third_party_email,
        g_old_rec.person_address_type,
        g_created_by,
      g_old_rec.line_id,
      g_old_rec.org_id,
      g_old_rec.daemon_flag,
      g_old_rec.daemon_type,
      g_old_rec.old_event_id,
      g_old_rec.quote_line_id,
      g_old_rec.interface_source,
      g_old_rec.total_training_time,
      g_old_rec.content_player_status,
      g_old_rec.score,
      g_old_rec.completed_content,
      g_old_rec.total_content,
      g_old_rec.booking_justification_id,
      g_old_rec.is_history_flag,
      g_old_rec.sign_eval_status,
      g_old_rec.is_mandatory_enrollment;
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_delegate_bookings');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
        (
        p_booking_id                    in number,
        p_booking_status_type_id        in number,
        p_delegate_person_id            in number,
        p_contact_id                    in number,
        p_business_group_id             in number,
        p_event_id                      in number,
        p_customer_id                   in number,
        p_authorizer_person_id          in number,
        p_date_booking_placed           in date,
        p_corespondent                  in varchar2,
        p_internal_booking_flag         in varchar2,
        p_number_of_places              in number,
        p_object_version_number         in number,
        p_administrator                 in number,
        p_booking_priority              in varchar2,
        p_comments                      in varchar2,
        p_contact_address_id            in number,
        p_delegate_contact_phone        in varchar2,
        p_delegate_contact_fax          in varchar2,
        p_third_party_customer_id       in number,
        p_third_party_contact_id        in number,
        p_third_party_address_id        in number,
        p_third_party_contact_phone     in varchar2,
        p_third_party_contact_fax       in varchar2,
        p_date_status_changed           in date,
        p_failure_reason                in varchar2,
        p_attendance_result             in varchar2,
        p_language_id                   in number,
        p_source_of_booking             in varchar2,
        p_special_booking_instructions  in varchar2,
        p_successful_attendance_flag    in varchar2,
        p_tdb_information_category      in varchar2,
        p_tdb_information1              in varchar2,
        p_tdb_information2              in varchar2,
        p_tdb_information3              in varchar2,
        p_tdb_information4              in varchar2,
        p_tdb_information5              in varchar2,
        p_tdb_information6              in varchar2,
        p_tdb_information7              in varchar2,
        p_tdb_information8              in varchar2,
        p_tdb_information9              in varchar2,
        p_tdb_information10             in varchar2,
        p_tdb_information11             in varchar2,
        p_tdb_information12             in varchar2,
        p_tdb_information13             in varchar2,
        p_tdb_information14             in varchar2,
        p_tdb_information15             in varchar2,
        p_tdb_information16             in varchar2,
        p_tdb_information17             in varchar2,
        p_tdb_information18             in varchar2,
        p_tdb_information19             in varchar2,
        p_tdb_information20             in varchar2,
        p_organization_id               in number,
        p_sponsor_person_id             in number,
        p_sponsor_assignment_id         in number,
        p_person_address_id             in number,
        p_delegate_assignment_id        in number,
        p_delegate_contact_id           in number,
        p_delegate_contact_email        in varchar2,
        p_third_party_email             in varchar2,
        p_person_address_type           in varchar2,
        p_line_id                                   in number,
        p_org_id                                    in number,
          p_daemon_flag                     in varchar2,
          p_daemon_type                     in varchar2,
        p_old_event_id                   in number,
        p_quote_line_id                  in number,
        p_interface_source               in varchar2,
      p_total_training_time           in varchar2 ,
        p_content_player_status         in varchar2 ,
        p_score                       in number   ,
        p_completed_content               in number   ,
        p_total_content               in number  ,
	p_booking_justification_id in number,
	p_is_history_flag in varchar2,
	p_sign_eval_status in varchar2,
	p_is_mandatory_enrollment in varchar2
  )
        Return g_rec_type is
--
  l_rec   g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.booking_id                       := p_booking_id;
  l_rec.booking_status_type_id           := p_booking_status_type_id;
  l_rec.delegate_person_id               := p_delegate_person_id;
  l_rec.contact_id                       := p_contact_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.event_id                         := p_event_id;
  l_rec.customer_id                      := p_customer_id;
  l_rec.authorizer_person_id             := p_authorizer_person_id;
  l_rec.date_booking_placed              := p_date_booking_placed;
  l_rec.corespondent                     := p_corespondent;
  l_rec.internal_booking_flag            := p_internal_booking_flag;
  l_rec.number_of_places                 := p_number_of_places;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.administrator                    := p_administrator;
  l_rec.booking_priority                 := p_booking_priority;
  l_rec.comments                         := p_comments;
  l_rec.contact_address_id               := p_contact_address_id;
  l_rec.delegate_contact_phone           := p_delegate_contact_phone;
  l_rec.delegate_contact_fax             := p_delegate_contact_fax;
  l_rec.third_party_customer_id          := p_third_party_customer_id;
  l_rec.third_party_contact_id           := p_third_party_contact_id;
  l_rec.third_party_address_id           := p_third_party_address_id;
  l_rec.third_party_contact_phone        := p_third_party_contact_phone;
  l_rec.third_party_contact_fax          := p_third_party_contact_fax;
  l_rec.date_status_changed              := p_date_status_changed;
  l_rec.failure_reason                   := p_failure_reason;
  l_rec.attendance_result                := p_attendance_result;
  l_rec.language_id                      := p_language_id;
  l_rec.source_of_booking                := p_source_of_booking;
  l_rec.special_booking_instructions     := p_special_booking_instructions;
  l_rec.successful_attendance_flag       := p_successful_attendance_flag;
  l_rec.tdb_information_category         := p_tdb_information_category;
  l_rec.tdb_information1                 := p_tdb_information1;
  l_rec.tdb_information2                 := p_tdb_information2;
  l_rec.tdb_information3                 := p_tdb_information3;
  l_rec.tdb_information4                 := p_tdb_information4;
  l_rec.tdb_information5                 := p_tdb_information5;
  l_rec.tdb_information6                 := p_tdb_information6;
  l_rec.tdb_information7                 := p_tdb_information7;
  l_rec.tdb_information8                 := p_tdb_information8;
  l_rec.tdb_information9                 := p_tdb_information9;
  l_rec.tdb_information10                := p_tdb_information10;
  l_rec.tdb_information11                := p_tdb_information11;
  l_rec.tdb_information12                := p_tdb_information12;
  l_rec.tdb_information13                := p_tdb_information13;
  l_rec.tdb_information14                := p_tdb_information14;
  l_rec.tdb_information15                := p_tdb_information15;
  l_rec.tdb_information16                := p_tdb_information16;
  l_rec.tdb_information17                := p_tdb_information17;
  l_rec.tdb_information18                := p_tdb_information18;
  l_rec.tdb_information19                := p_tdb_information19;
  l_rec.tdb_information20                := p_tdb_information20;
  l_rec.organization_id                  := p_organization_id;
  l_rec.sponsor_person_id                := p_sponsor_person_id;
  l_rec.sponsor_assignment_id            := p_sponsor_assignment_id;
  l_rec.person_address_id                := p_person_address_id;
  l_rec.delegate_assignment_id           := p_delegate_assignment_id;
  l_rec.delegate_contact_id              := p_delegate_contact_id;
  l_rec.delegate_contact_email           := p_delegate_contact_email;
  l_rec.third_party_email                := p_third_party_email;
  l_rec.person_address_type              := p_person_address_type;
  l_rec.line_id                              := p_line_id;
  l_rec.org_id                               := p_org_id;
  l_rec.daemon_flag                          := p_daemon_flag;
  l_rec.daemon_type                          := p_daemon_type;
  l_rec.old_event_id                     := p_old_event_id;
  l_rec.quote_line_id                    := p_quote_line_id;
  l_rec.interface_source                 := p_interface_source;
  l_rec.total_training_time                  := p_total_training_time;
  l_rec.content_player_status                := p_content_player_status;
  l_rec.score                          := p_score;
  l_rec.completed_content                := p_completed_content;
  l_rec.total_content                    := p_total_content;
  l_rec.booking_justification_id                 := p_booking_justification_id;
  l_rec.is_history_flag                  := p_is_history_flag;
  l_rec.is_mandatory_enrollment          := p_is_mandatory_enrollment;
  l_rec.sign_eval_status                 := p_sign_eval_status;
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ota_tdb_shd;

/
