--------------------------------------------------------
--  DDL for Package Body OTA_EVT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVT_SHD" as
/* $Header: otevt01t.pkb 120.13.12010000.5 2009/07/29 07:12:13 shwnayak ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_evt_shd.';  -- Global package name
--
--	Working records within procedures
--
G_FETCHED_REC				ota_evt_shd.g_rec_type;
G_NULL_REC				ota_evt_shd.g_rec_type;
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
Procedure CONSTRAINT_ERROR (
	p_constraint_name		      in varchar2
	) Is
--
	W_PROC					varchar2 (72)
		:= g_package || 'CONSTRAINT_ERROR';
	--
Begin
	--
	hr_utility.set_location ('Entering:' || W_PROC, 5);
	hr_utility.set_location ('Constrint Name = '||p_constraint_name,5);
	--
	--	Key constraints
	--
	If (p_constraint_name = 'OTA_EVENTS_FK1') Then
                FND_MESSAGE.SET_NAME('OTA','OTA_13429_EVT_NO_TAV');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVENTS_FK2') Then
                FND_MESSAGE.SET_NAME('OTA','OTA_13430_EVT_NO_BUS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVENTS_FK3') Then
                FND_MESSAGE.SET_NAME('OTA','OTA_13431_EVT_NO_BUD');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVENTS_FK4') Then
                FND_MESSAGE.SET_NAME('OTA','OTA_13432_EVT_NO_ORG');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVENTS_FK5') Then
                FND_MESSAGE.SET_NAME('OTA','OTA_13433_EVT_NO_PAR');
                fnd_message.raise_error;
       /*  3803613 */
       ElsIf (p_constraint_name = 'OTA_PROGRAM_MEMBERSHIPS_FK1') Then
                FND_MESSAGE.SET_NAME('OTA','OTA_13681_EVT_PMM_EXISTS');
                fnd_message.raise_error;
       /*  3803613 */
	ElsIf (p_constraint_name = 'OTA_EVENTS_PK') Then
		hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
		hr_utility.set_message_token('PROCEDURE', W_PROC);
		hr_utility.set_message_token('STEP','30');
		hr_utility.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVENTS_UK2') Then
	          fnd_message.set_name('OTA','OTA_13471_SES_EXISTS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVENT_UK3') Then
                fnd_message.set_name('OTA','OTA_13889_EVT_LINE_DUPLICATE');
                fnd_message.raise_error;
	--
	--	Check constraints
	--
	ElsIf (p_constraint_name = 'OTA_EVT_ACTIVITY_BASED') Then
                fnd_message.set_name('OTA','OTA_13434_EVT_ACTIVITY_BASED');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_ATTENDANCE') Then
                fnd_message.set_name('OTA','OTA_13435_EVT_ATTENDEES');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_CATEGORY_NOT_NULL') Then
                fnd_message.set_name('OTA','OTA_13437_EVT_CATEGORY_NULL');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_CATEGORY_NULL') Then
                fnd_message.set_name('OTA','OTA_13437_EVT_CATEGORY_NULL');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_COURSE_END_DATE') Then
                fnd_message.set_name('OTA','OTA_13438_EVT_COURSE_END_DATE');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_COURSE_START_END_ORDER') Then
                fnd_message.set_name('OTA','OTA_13439_EVT_COURSE_DATES');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_COURSE_TIMES_ORDER') Then
                fnd_message.set_name('OTA','OTA_13439_EVT_COURSE_DATES');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_CURRENCY') Then
		fnd_message.set_name('OTA', 'OTA_13440_EVT_CURR_PB');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_DEVELOPMENT_TYPE') Then
                fnd_message.set_name('OTA','OTA_13441_EVT_DEV_TYPE');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_DURATION') Then
                fnd_message.set_name('OTA','OTA_13442_EVT_DURATION');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_DURATION_AND_UNITS') Then
                fnd_message.set_name('OTA','OTA_13442_EVT_DURATION');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_DURATION_MORE_THAN_0') Then
                fnd_message.set_name('OTA','OTA_13443_EVT_DURATION_NOT_0');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_END_TIME_FORMAT') Then
                fnd_message.set_name('OTA','OTA_13444_EVT_TIME_FORMAT');
                fnd_message.raise_error;
--Added for Bug 3405804
	ElsIf (p_constraint_name = 'OTA_EVT_SESSION_TIMING') Then
                fnd_message.set_name('OTA','OTA_13226_EVT_SESSION_TIMING');
                fnd_message.raise_error;
-- Added for Bug 3405804
	ElsIf (p_constraint_name = 'OTA_EVT_ENROLMENT_NOT_NULL') Then
                fnd_message.set_name('OTA','OTA_13445_EVT_ENROL_DATES');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_ENROLMENT_NULL') Then
		fnd_message.set_name('OTA', 'OTA_13445_EVT_ENROL_DATES');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_ENROL_START_END_ORDER') Then
		fnd_message.set_name('OTA', 'OTA_13445_EVT_ENROL_DATES');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_EVENT_STATUS_CHK') Then
		fnd_message.set_name('OTA', 'OTA_13446_EVT_INVALID_STATUS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_EVENT_TYPE_CHK') Then
		fnd_message.set_name('OTA', 'OTA_13447_EVT_INVALID_TYPE');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_LANGUAGE') Then
		fnd_message.set_name('OTA', 'OTA_13448_EVT_INVALID_LANGUAGE');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_MAX_ATTENDEES_POSITIVE') Then
		fnd_message.set_name('OTA', 'OTA_13449_EVT_ATTENDEES_POS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_MAX_INTERNALS_POSITIVE') Then
		fnd_message.set_name('OTA', 'OTA_13449_EVT_ATTENDEES_POS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_MAX_INTERNAL_MAX_ORDER') Then
		fnd_message.set_name('OTA', 'OTA_13449_EVT_ATTENDEES_POS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_MIN_ATTENDEES_POSITIVE') Then
		fnd_message.set_name('OTA', 'OTA_13449_EVT_ATTENDEES_POS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_MIN_MAX_ORDER') Then
		fnd_message.set_name('OTA', 'OTA_13449_EVT_ATTENDEES_POS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_NORMAL_STATUS_DATES') Then
		fnd_message.set_name('OTA', 'OTA_13218_EVT_NORMAL_STATUS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_PARENT_NOT_NULL') Then
		fnd_message.set_name('OTA', 'OTA_13450_EVT_PARENT');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_PARENT_NULL') Then
		fnd_message.set_name('OTA', 'OTA_13450_EVT_PARENT');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_PRICE_APPLICABLE') Then
		fnd_message.set_name('OTA', 'OTA_13440_EVT_CURR_PB');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_PRICE_BASIS') Then
		fnd_message.set_name('OTA', 'OTA_13440_EVT_CURR_PB');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_PRICE_BASIS_CHK') Then
		fnd_message.set_name('OTA', 'OTA_13451_EVT_INVALID_PB');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_PRICING_NULL') Then
		fnd_message.set_name('OTA', 'OTA_13440_EVT_CURR_PB');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_START_TIME_FORMAT') Then
                fnd_message.set_name('OTA','OTA_13444_EVT_TIME_FORMAT');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_STATUS_NOT_NULL') Then
                fnd_message.set_name('OTA','OTA_13452_EVT_STATUS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_STATUS_NULL') Then
                fnd_message.set_name('OTA','OTA_13452_EVT_STATUS');
                fnd_message.raise_error;
	ElsIf (p_constraint_name = 'OTA_EVT_VENDOR_NULL') Then
                fnd_message.set_name('OTA','OTA_13453_EVT_VENDOR');
                fnd_message.raise_error;
 	ElsIf (p_constraint_name = 'OTA_EVENTS_UK4') Then
    		    fnd_message.set_name('OTA', 'OTA_EVT_DUPLICATE_OFFERING');
    		    fnd_message.raise_error;
	--
	--	?
	--
	Else
		FND_MESSAGE.SET_NAME ('OTA', 'OTA_13259_GEN_UNKN_CONSTRAINT');
		FND_MESSAGE.SET_TOKEN ('PROCEDURE',  W_PROC);
		FND_MESSAGE.SET_TOKEN ('CONSTRAINT', P_CONSTRAINT_NAME);
		hr_utility.raise_error;
	End If;
	--
	hr_utility.set_location (' Leaving:' || W_PROC, 10);
	--
End CONSTRAINT_ERROR;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_event_id                           in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		event_id,
		vendor_id,
		activity_version_id,
		business_group_id,
		organization_id,
		event_type,
		object_version_number,
		title,
        budget_cost,
        actual_cost,
        budget_currency_code,
		centre,
		comments,
		course_end_date,
		course_end_time,
		course_start_date,
		course_start_time,
		duration,
		duration_units,
		enrolment_end_date,
		enrolment_start_date,
		language_id,
		user_status,
		development_event_type,
		event_status,
		price_basis,
		currency_code,
		maximum_attendees,
		maximum_internal_attendees,
		minimum_attendees,
		standard_price,
		category_code,
		parent_event_id,
        book_independent_flag,
        public_event_flag,
        secure_event_flag,
		evt_information_category,
		evt_information1,
		evt_information2,
		evt_information3,
		evt_information4,
		evt_information5,
		evt_information6,
		evt_information7,
		evt_information8,
		evt_information9,
		evt_information10,
		evt_information11,
		evt_information12,
		evt_information13,
		evt_information14,
		evt_information15,
		evt_information16,
		evt_information17,
		evt_information18,
		evt_information19,
		evt_information20,
        project_id,
        owner_id,
        line_id,
        org_id,
        training_center_id,
        location_id,
        offering_id,
        timezone,
        parent_offering_id,
        data_source,
        event_availability
    from	ota_events
    where	event_id = p_event_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
	--
	hr_utility.set_location('Entering:'||l_proc, 5);
	--
	if (    (P_EVENT_ID              is null)
	    and (P_OBJECT_VERSION_NUMBER is null)) then
		--
		-- One of the primary key arguments is null therefore we must
		-- set the returning function value to false
		--
		l_fct_ret := false;
	elsif (    (p_event_id              = g_old_rec.event_id             )
	       and (p_object_version_number = g_old_rec.object_version_number)) then
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
		Fetch C_Sel1
		  Into g_old_rec;
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
  p_event_id                           in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	event_id,
	vendor_id,
	activity_version_id,
	business_group_id,
	organization_id,
	event_type,
	object_version_number,
	title,
    budget_cost,
    actual_cost,
    budget_currency_code,
	centre,
	comments,
	course_end_date,
	course_end_time,
	course_start_date,
	course_start_time,
	duration,
	duration_units,
	enrolment_end_date,
	enrolment_start_date,
	language_id,
	user_status,
	development_event_type,
	event_status,
	price_basis,
	currency_code,
	maximum_attendees,
	maximum_internal_attendees,
	minimum_attendees,
	standard_price,
	category_code,
	parent_event_id,
    book_independent_flag,
    public_event_flag,
    secure_event_flag,
	evt_information_category,
	evt_information1,
	evt_information2,
	evt_information3,
	evt_information4,
	evt_information5,
	evt_information6,
	evt_information7,
	evt_information8,
	evt_information9,
	evt_information10,
	evt_information11,
	evt_information12,
	evt_information13,
	evt_information14,
	evt_information15,
	evt_information16,
	evt_information17,
	evt_information18,
	evt_information19,
	evt_information20,
    project_id,
    owner_id,
    line_id,
    org_id,
    training_center_id,
    location_id,
    offering_id,
    timezone,
    parent_offering_id,
    data_source,
    event_availability
    from	ota_events
    where	event_id = p_event_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ota_events');
    hr_utility.raise_error;
End lck;
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_event_id                      in number,
	p_vendor_id                     in number,
	p_activity_version_id           in number,
	p_business_group_id             in number,
	p_organization_id               in number,
	p_event_type                    in varchar2,
	p_object_version_number         in number,
	p_title                         in varchar2,
    p_budget_cost                   in number,
    p_actual_cost                   in number,
    p_budget_currency_code          in varchar2,
	p_centre                        in varchar2,
	p_comments                      in varchar2,
	p_course_end_date               in date,
	p_course_end_time               in varchar2,
	p_course_start_date             in date,
	p_course_start_time             in varchar2,
	p_duration                      in number,
	p_duration_units                in varchar2,
	p_enrolment_end_date            in date,
	p_enrolment_start_date          in date,
	p_language_id                   in number,
	p_user_status                   in varchar2,
	p_development_event_type        in varchar2,
	p_event_status                  in varchar2,
	p_price_basis                   in varchar2,
	p_currency_code                 in varchar2,
	p_maximum_attendees             in number,
	p_maximum_internal_attendees    in number,
	p_minimum_attendees             in number,
	p_standard_price                in number,
	p_category_code                 in varchar2,
	p_parent_event_id               in number,
    p_book_independent_flag         in varchar2,
    p_public_event_flag             in varchar2,
    p_secure_event_flag             in varchar2,
	p_evt_information_category      in varchar2,
	p_evt_information1              in varchar2,
	p_evt_information2              in varchar2,
	p_evt_information3              in varchar2,
	p_evt_information4              in varchar2,
	p_evt_information5              in varchar2,
	p_evt_information6              in varchar2,
	p_evt_information7              in varchar2,
	p_evt_information8              in varchar2,
	p_evt_information9              in varchar2,
	p_evt_information10             in varchar2,
	p_evt_information11             in varchar2,
	p_evt_information12             in varchar2,
	p_evt_information13             in varchar2,
	p_evt_information14             in varchar2,
	p_evt_information15             in varchar2,
	p_evt_information16             in varchar2,
	p_evt_information17             in varchar2,
	p_evt_information18             in varchar2,
	p_evt_information19             in varchar2,
	p_evt_information20             in varchar2,
    p_project_id                    in number,
    p_owner_id				        in number,
	p_line_id				        in number,
	p_org_id				        in number,
    p_training_center_id		    in number,
	p_location_id		      	    in number,
    p_offering_id			        in number,
	p_timezone				        in varchar2,
    p_parent_offering_id            in number,
    p_data_source                   in varchar2,
    p_event_availability            in varchar2
    )
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.event_id                         := p_event_id;
  l_rec.vendor_id                        := p_vendor_id;
  l_rec.activity_version_id              := p_activity_version_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.event_type                       := p_event_type;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.title                            := p_title;
  l_rec.budget_cost                      := p_budget_cost;
  l_rec.actual_cost                      := p_actual_cost;
  l_rec.budget_currency_code             := p_budget_currency_code;
  l_rec.centre                           := p_centre;
  l_rec.comments                         := p_comments;
  l_rec.course_end_date                  := p_course_end_date;
  l_rec.course_end_time                  := p_course_end_time;
  l_rec.course_start_date                := p_course_start_date;
  l_rec.course_start_time                := p_course_start_time;
  l_rec.duration                         := p_duration;
  l_rec.duration_units                   := p_duration_units;
  l_rec.enrolment_end_date               := p_enrolment_end_date;
  l_rec.enrolment_start_date             := p_enrolment_start_date;
  l_rec.language_id                      := p_language_id;
  l_rec.user_status                      := p_user_status;
  l_rec.development_event_type           := p_development_event_type;
  l_rec.event_status                     := p_event_status;
  l_rec.price_basis                      := p_price_basis;
  l_rec.currency_code                    := p_currency_code;
  l_rec.maximum_attendees                := p_maximum_attendees;
  l_rec.maximum_internal_attendees       := p_maximum_internal_attendees;
  l_rec.minimum_attendees                := p_minimum_attendees;
  l_rec.standard_price                   := p_standard_price;
  l_rec.category_code                    := p_category_code;
  l_rec.parent_event_id                  := p_parent_event_id;
  l_rec.book_independent_flag            := p_book_independent_flag;
  l_rec.public_event_flag                := p_public_event_flag;
  l_rec.secure_event_flag                := p_secure_event_flag;
  l_rec.evt_information_category         := p_evt_information_category;
  l_rec.evt_information1                 := p_evt_information1;
  l_rec.evt_information2                 := p_evt_information2;
  l_rec.evt_information3                 := p_evt_information3;
  l_rec.evt_information4                 := p_evt_information4;
  l_rec.evt_information5                 := p_evt_information5;
  l_rec.evt_information6                 := p_evt_information6;
  l_rec.evt_information7                 := p_evt_information7;
  l_rec.evt_information8                 := p_evt_information8;
  l_rec.evt_information9                 := p_evt_information9;
  l_rec.evt_information10                := p_evt_information10;
  l_rec.evt_information11                := p_evt_information11;
  l_rec.evt_information12                := p_evt_information12;
  l_rec.evt_information13                := p_evt_information13;
  l_rec.evt_information14                := p_evt_information14;
  l_rec.evt_information15                := p_evt_information15;
  l_rec.evt_information16                := p_evt_information16;
  l_rec.evt_information17                := p_evt_information17;
  l_rec.evt_information18                := p_evt_information18;
  l_rec.evt_information19                := p_evt_information19;
  l_rec.evt_information20                := p_evt_information20;
  l_rec.project_id                       := p_project_id;
  l_rec.owner_id				         := p_owner_id;
  l_rec.line_id				             := p_line_id;
  l_rec.org_id				             := p_org_id;
  l_rec.training_center_id		         := p_training_center_id;
  l_rec.location_id			             := p_location_id;
  l_rec.offering_id		     	         := p_offering_id;
  l_rec.timezone			             := p_timezone;
  l_rec.parent_offering_id		     	 := p_parent_offering_id;
  l_rec.data_source    		     	     := p_data_source;
  l_rec.event_availability               := p_event_availability;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- -------------------------< FETCH_EVENT_DETAILS >----------------------------
-- ----------------------------------------------------------------------------
--
--	Populates the g_fetched_rec record with the specified event's details.
--	These details are then used throughout the package in checks etc.
--
procedure FETCH_EVENT_DETAILS (
	P_EVENT_ID			number,
	P_EVENT_EXISTS		    out nocopy boolean
	) is
--
	W_PROC				varchar2 (72)
		:= G_PACKAGE || 'FETCH_EVENT_DETAILS';
	--
	cursor CSR_EVENT is
		select
  event_id
, vendor_id
, activity_version_id
, business_group_id
, organization_id
, event_type
, object_version_number
, title
, budget_cost
, actual_cost
, budget_currency_code
, centre
, comments
, course_end_date
, course_end_time
, course_start_date
, course_start_time
, duration
, duration_units
, enrolment_end_date
, enrolment_start_date
, language_id
, user_status
, development_event_type
, event_status
, price_basis
, currency_code
, maximum_attendees
, maximum_internal_attendees
, minimum_attendees
, standard_price
, category_code
, parent_event_id
, book_independent_flag
, public_event_flag
, secure_event_flag
, evt_information_category
, evt_information1
, evt_information2
, evt_information3
, evt_information4
, evt_information5
, evt_information6
, evt_information7
, evt_information8
, evt_information9
, evt_information10
, evt_information11
, evt_information12
, evt_information13
, evt_information14
, evt_information15
, evt_information16
, evt_information17
, evt_information18
, evt_information19
, evt_information20
, project_id
, owner_id
, line_id
, org_id
, training_center_id
, location_id
, offering_id
, timezone
, parent_offering_id
, data_source
, event_availability
		  from OTA_EVENTS_VL
		  where	EVENT_ID      =	P_EVENT_ID;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	HR_UTILITY.TRACE ('Event id: ' || to_char (P_EVENT_ID));
	--
	if (P_EVENT_ID is not null) then
		open CSR_EVENT;
		fetch CSR_EVENT
		   into G_FETCHED_REC;
		P_EVENT_EXISTS := CSR_EVENT%found;
		close CSR_EVENT;
		--
	else
		G_FETCHED_REC := G_NULL_REC;
		P_EVENT_EXISTS := false;
	end if;
	--
	HR_UTILITY.TRACE ('Fetch, start date: ' || to_char (G_FETCHED_REC.COURSE_START_DATE));
	HR_UTILITY.TRACE ('Fetch, end date:   ' || to_char (G_FETCHED_REC.COURSE_END_DATE));
	HR_UTILITY.SET_LOCATION ('Leaving:' || W_PROC, 10);
	--
end FETCH_EVENT_DETAILS;
--
-- ----------------------------------------------------------------------------
-- ---------------------------< CHECK_PROGRAMME_MEMBERS >----------------------
-- ----------------------------------------------------------------------------
--
-- Checks whether all programme members are ofnorml event status
--
function check_programme_members(p_event_id in number) return boolean is
  --
  l_proc varchar2(30) := 'Check_programme_members';
  l_dummy varchar2(1);
  l_found boolean := false;
  --
  cursor c1 is
    select null
    from   ota_program_memberships mem,
           ota_events evt
    where  mem.program_event_id = p_event_id
    and    mem.event_id = evt.event_id
    and    evt.event_status = 'P';
  --
begin
  hr_utility.set_location('Entering '||l_proc,10);
  --
  open c1;
    fetch c1 into l_dummy;
    if c1%found then
      --
      l_found := true;
      --
    end if;
  close c1;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  return l_found;
  --
end check_programme_members;
-- ----------------------------------------------------------------------------
-- ---------------------------< GET_EVENT_DETAILS >----------------------------
-- ----------------------------------------------------------------------------
--
--	A public procedure for other objects to use to return a single,
--	complete event row.
--
procedure GET_EVENT_DETAILS (
	P_EVENT_ID			number,
	P_EVENT_REC		    out nocopy ota_evt_shd.g_rec_type,
	P_EVENT_EXISTS		    out nocopy boolean
	) is
--
	W_PROC				varchar2 (72)
		:= G_PACKAGE || 'GET_EVENT_DETAILS';
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
	--
	FETCH_EVENT_DETAILS (P_EVENT_ID, P_EVENT_EXISTS);
	P_EVENT_REC := G_FETCHED_REC;
	--
	HR_UTILITY.SET_LOCATION ('Leaving:' || W_PROC, 10);
	--
end GET_EVENT_DETAILS;
--
-- ----------------------------------------------------------------------------
-- ---------------------------< GET_COURSE_DATES >-----------------------------
-- ----------------------------------------------------------------------------
--
--      Returns the course dates of a specified event.
--
procedure GET_COURSE_DATES (
        P_EVENT_ID                                   in number,
        P_COURSE_START_DATE                      in out nocopy date,
        P_COURSE_END_DATE                        in out nocopy date
        ) is
--
W_PROC                                                  varchar2 (72)
        := G_PACKAGE || 'GET_COURSE_DATES';
W_EVENT_EXISTS                                          boolean;
--
begin
        --
        HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC, 5);
        --
        HR_API.MANDATORY_ARG_ERROR (
		P_API_NAME			     =>	G_PACKAGE,
		P_ARGUMENT			     =>	'P_EVENT_ID',
		P_ARGUMENT_VALUE		     =>	P_EVENT_ID);
        --
        OTA_EVT_SHD.FETCH_EVENT_DETAILS (
                P_EVENT_ID                           => P_EVENT_ID,
                P_EVENT_EXISTS                       => W_EVENT_EXISTS);
        --
        if W_EVENT_EXISTS then
		--
		P_COURSE_START_DATE := G_FETCHED_REC.COURSE_START_DATE;
		P_COURSE_END_DATE   := G_FETCHED_REC.COURSE_END_DATE;
		--
	else
		--
		FND_MESSAGE.SET_NAME (810, 'OTA_13205_GEN_PARAMETERS');
		FND_MESSAGE.SET_TOKEN ('PROCEDURE',        W_PROC);
		FND_MESSAGE.SET_TOKEN ('SPECIFIC_MESSAGE', 'P_EVENT_ID does not identify a valid event');
		FND_MESSAGE.RAISE_ERROR;
		--
        end if;
        --
        HR_UTILITY.SET_LOCATION (' Leaving:' || W_PROC, 10);
        --
end GET_COURSE_DATES;
--
-- ----------------------------------------------------------------------------
-- -----------------------< CHECK_EVENT_IS_VALID >-----------------------------
-- ----------------------------------------------------------------------------
--
--	Raises an error if the event ID used does not exist on OTA_EVENTS.
--
procedure CHECK_EVENT_IS_VALID (
	P_EVENT_ID		     in	number
	) is
--
	W_PROC				varchar2 (72)
		:= G_PACKAGE || 'CHECK_EVENT_IS_VALID';
	--
	W_EVENT_IS_VALID			boolean;
	--
begin
	--
	HR_UTILITY.SET_LOCATION ('Entering:' || W_PROC,5);
	--
	if (P_EVENT_ID is not null) then
		FETCH_EVENT_DETAILS (
			P_EVENT_ID		     =>	P_EVENT_ID,
			P_EVENT_EXISTS		     => W_EVENT_IS_VALID);
		if (not W_EVENT_IS_VALID) then
			CONSTRAINT_ERROR ('OTA_EVT_INVALID_EVENT');
		end if;
	end if;
	--
	HR_UTILITY.SET_LOCATION ('Leaving:'||W_PROC,10);
	--
end CHECK_EVENT_IS_VALID;
--
-- ----------------------------------------------------------------------------
-- ---------------------< RESOURCE_BOOKING_FLAG >------------------------------
-- ----------------------------------------------------------------------------
--
--	Returns 'Y' if event has any resources booked to it.
--
--	NB: This function may be used in views so do not add code which
--	    will affect variables outside the scope of this function.
--
function RESOURCE_BOOKING_FLAG (
	P_EVENT_ID		     in	number
	) return varchar2 is
--
W_DUMMY					number (1);
W_RESOURCES_BOOKED			boolean;
--
cursor C1 is
	select 1
	  from OTA_RESOURCE_BOOKINGS	TRB
	  where TRB.EVENT_ID	      =	P_EVENT_ID;
--
begin
	--
	open C1;
	fetch C1
	  into W_DUMMY;
	W_RESOURCES_BOOKED := C1%found;
	close C1;
	--
	if (W_RESOURCES_BOOKED) then
		return ('Y');
	else
		return ('N');
	end if;
	--
end RESOURCE_BOOKING_FLAG;
--
-- ----------------------------------------------------------------------------
-- -----------------------< PUBLIC_EVENT_FLAG >--------------------------------
-- ----------------------------------------------------------------------------
--
--	Returns 'N' if the event has no event associations and thus may be
--	booked by anyone. If rows do exist in event associations for the
--	event, then only those organisations with associations may book
--	students to the event.
--
--	NB: This function may be used in views so do not add code which
--	    will affect variables outside the scope of this function.
--
function PUBLIC_EVENT_FLAG (
	P_EVENT_ID		     in	number
	) return varchar2 is
--
W_DUMMY					number (1);
W_PUBLIC_EVENT				boolean;
--
cursor C1 is
	select 1
	  from OTA_EVENT_ASSOCIATIONS	TEA
	  where TEA.EVENT_ID	      =	P_EVENT_ID;
--
begin
	--
	open C1;
	fetch C1
		into W_DUMMY;
	W_PUBLIC_EVENT := C1%notfound;
	close C1;
	--
	if (W_PUBLIC_EVENT) then
		return ('Y');
	else
		return ('N');
	end if;
	--
end PUBLIC_EVENT_FLAG;
--
-- ----------------------------------------------------------------------------
-- -----------------------< INVOICED_AMOUNT_TOTAL >----------------------------
-- ----------------------------------------------------------------------------
--
--	Returns the total invoiced amount for an event.
--
--	NB: This function may be used in views so do not add code which
--	    will affect variables outside the scope of this function.
--
function INVOICED_AMOUNT_TOTAL (
	P_EVENT_ID				     in	number
	) return number is
--
	cursor C1 is
		select sum (TFL.MONEY_AMOUNT)
		  from OTA_FINANCE_LINES		TFL,
		       OTA_DELEGATE_BOOKINGS		TDB
		  where TDB.EVENT_ID		      =	P_EVENT_ID
		    and TFL.BOOKING_ID		      = TDB.BOOKING_ID
		    and TFL.CANCELLED_FLAG	     <> 'Y';


      cursor C2 is
		select ol.unit_selling_price,
			 ol.line_id
		from ota_events evt,
		oe_order_lines_all ol
		where evt.event_id = p_event_id and
		      ol.line_id = evt.line_id;

	--
	w_line_id            ota_events.line_id%type;
	W_TOTAL	   	   number;
	--
begin
	--
	--	Fetch invoiced amount
	--
	OPEN C2;
	FETCH C2 INTO w_total,w_line_id;
      IF (C2%notfound) THEN
         null;
      END IF;
      CLOSE c2;
	IF w_line_id is null THEN
	   open C1;
	   fetch C1
	   into W_TOTAL;
	   if (C1%notfound) then
		null;
   	   end if;
	   close C1;
       END IF;
	--
	return (W_TOTAL);
	--
end INVOICED_AMOUNT_TOTAL;
--
end ota_evt_shd;

/
