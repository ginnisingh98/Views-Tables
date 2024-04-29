--------------------------------------------------------
--  DDL for Package Body PER_PER_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PER_SHD" as
/* $Header: peperrhi.pkb 120.14.12010000.5 2009/08/17 12:07:47 ktithy ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_per_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc    varchar2(72) := g_package||'return_api_dml_status';
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
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PER_PEOPLE_F_FK1') Then
    -- Error: The Business Group is not defined.
    hr_utility.set_message(801, 'HR_6673_PO_EMP_NO_BG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PEOPLE_F_FK2') Then
    -- Error: Invalid person type
    hr_utility.set_message(801, 'HR_7513_PER_TYPE_INVALID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PEOPLE_F_PK') Then
    -- Error: The primary key specified is invalid
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PER_EXPENSE_CHECK_SEND_CHK') Then
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PER_REGISTERED_DISABLE_CHK') Then
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PER_SEX_CHK') Then
    hr_utility.set_message(801, 'HR_7511_PER_SEX_INVALID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PER_ON_MILITARY_SRV_CHK') Then
    hr_utility.set_message(800, 'PER_52115_PER_INV_ON_MIL_SERV');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PER_RESUME_EXISTS_CHK') Then
    hr_utility.set_message(800, 'PER_52116_PER_INV_RES_EXIST');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_PER_SECOND_PASSPORT_CHK') Then
    hr_utility.set_message(800, 'PER_52117_PER_INV_SEC_PAS_EXT');
    hr_utility.raise_error;
  Elsif (p_constraint_name = 'PER_BEN_NO_CVG_F_CHK') Then
    hr_utility.set_message(800,'PER_52387_BEN_NO_CVG_F');
    hr_utility.raise_error;
 Elsif (p_constraint_name = 'PER_DPDNT_VLNTRY_SVCE_CHK') Then
    hr_utility.set_message(800,'PER_52389_DPDNT_VLNTRY_SVCE_F');
    hr_utility.raise_error;
 Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
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
  (p_effective_date     in date,
   p_person_id            in number,
   p_object_version_number in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
   person_id,
   effective_start_date,
   effective_end_date,
   business_group_id,
   person_type_id,
   last_name,
   start_date,
   applicant_number,
   comment_id,
   null,
   current_applicant_flag,
   current_emp_or_apl_flag,
   current_employee_flag,
   date_employee_data_verified,
   date_of_birth,
   email_address,
   employee_number,
   expense_check_send_to_address,
   first_name,
   full_name,
   known_as,
   marital_status,
   middle_names,
   nationality,
   national_identifier,
   previous_last_name,
   registered_disabled_flag,
   sex,
   title,
   vendor_id,
   work_telephone,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20,
   attribute21,
   attribute22,
   attribute23,
   attribute24,
   attribute25,
   attribute26,
   attribute27,
   attribute28,
   attribute29,
   attribute30,
   per_information_category,
   per_information1,
   per_information2,
   per_information3,
   per_information4,
   per_information5,
   per_information6,
   per_information7,
   per_information8,
   per_information9,
   per_information10,
   per_information11,
   per_information12,
   per_information13,
   per_information14,
   per_information15,
   per_information16,
   per_information17,
   per_information18,
   per_information19,
   per_information20,
   object_version_number,
        suffix,
        DATE_OF_DEATH                ,
        BACKGROUND_CHECK_STATUS      ,
        BACKGROUND_DATE_CHECK        ,
        BLOOD_TYPE                   ,
        CORRESPONDENCE_LANGUAGE      ,
        FAST_PATH_EMPLOYEE           ,
        FTE_CAPACITY                 ,
        HOLD_APPLICANT_DATE_UNTIL    ,
        HONORS                       ,
        INTERNAL_LOCATION            ,
        LAST_MEDICAL_TEST_BY         ,
        LAST_MEDICAL_TEST_DATE       ,
        MAILSTOP                     ,
        OFFICE_NUMBER                ,
        ON_MILITARY_SERVICE          ,
        ORDER_NAME                   ,
        PRE_NAME_ADJUNCT             ,
        PROJECTED_START_DATE         ,
        REHIRE_AUTHORIZOR            ,
        REHIRE_RECOMMENDATION        ,
        RESUME_EXISTS                ,
        RESUME_LAST_UPDATED          ,
        SECOND_PASSPORT_EXISTS       ,
        STUDENT_STATUS               ,
        WORK_SCHEDULE                ,
        PER_INFORMATION21            ,
        PER_INFORMATION22            ,
        PER_INFORMATION23            ,
        PER_INFORMATION24            ,
        PER_INFORMATION25            ,
        PER_INFORMATION26            ,
        PER_INFORMATION27            ,
        PER_INFORMATION28            ,
        PER_INFORMATION29            ,
        PER_INFORMATION30            ,
        REHIRE_REASON                ,
        BENEFIT_GROUP_ID             ,
        RECEIPT_OF_DEATH_CERT_DATE   ,
        COORD_BEN_MED_PLN_NO         ,
        COORD_BEN_NO_CVG_FLAG        ,
        COORD_BEN_MED_EXT_ER,
        COORD_BEN_MED_PL_NAME,
        COORD_BEN_MED_INSR_CRR_NAME,
        COORD_BEN_MED_INSR_CRR_IDENT,
        COORD_BEN_MED_CVG_STRT_DT,
        COORD_BEN_MED_CVG_END_DT,
        USES_TOBACCO_FLAG            ,
        DPDNT_ADOPTION_DATE          ,
        DPDNT_VLNTRY_SVCE_FLAG       ,
        ORIGINAL_DATE_OF_HIRE        ,
      town_of_birth                ,
        region_of_birth              ,
      country_of_birth             ,
        global_person_id,
        party_id,
        npw_number,
        current_npw_flag,
        global_name,
        local_name
    from per_all_people_f
    where   person_id = p_person_id
    and     p_effective_date
    between effective_start_date and effective_end_date;
--
  l_proc varchar2(72)   := g_package||'api_updating';
  l_fct_ret boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_person_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_person_id = g_old_rec.person_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Clear out the global variable which holds the previous system
      -- person type
      --
      per_per_bus.g_previous_sys_per_type := null;
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
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
   (p_effective_date in  date,
    p_base_key_value in  number,
    p_zap       out nocopy boolean,
    p_delete    out nocopy boolean,
    p_future_change out nocopy boolean,
    p_delete_next_change out nocopy boolean) is
--
  l_proc       varchar2(72)   := g_package||'find_dt_del_modes';
--
  --
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date => p_effective_date,
    p_base_table_name   => 'per_all_people_f',
    p_base_key_column   => 'person_id',
    p_base_key_value => p_base_key_value,
    p_zap         => p_zap,
    p_delete      => p_delete,
    p_future_change  => p_future_change,
    p_delete_next_change   => p_delete_next_change);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
   (p_effective_date in  date,
    p_base_key_value in  number,
    p_correction   out nocopy boolean,
    p_update    out nocopy boolean,
    p_update_override out nocopy boolean,
    p_update_change_insert out nocopy boolean) is
--
  l_proc    varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
   (p_effective_date => p_effective_date,
    p_base_table_name   => 'per_all_people_f',
    p_base_key_column   => 'person_id',
    p_base_key_value => p_base_key_value,
    p_correction     => p_correction,
    p_update      => p_update,
    p_update_override   => p_update_override,
    p_update_change_insert => p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
   (p_effective_date    in date,
    p_base_key_value    in number,
    p_new_effective_end_date  in date,
    p_validation_start_date   in date,
    p_validation_end_date     in date,
         p_object_version_number       out nocopy number) is
--
  l_proc         varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
   (p_base_table_name   => 'per_all_people_f',
    p_base_key_column   => 'person_id',
    p_base_key_value => p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  per_all_people_f t
  set   t.effective_end_date    = p_new_effective_end_date,
     t.object_version_number = l_object_version_number
  where    t.person_id    = p_base_key_value
  and   p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
   (p_effective_date  in  date,
    p_datetrack_mode  in  varchar2,
    p_person_id    in  number,
    p_object_version_number in  number,
    p_validation_start_date out nocopy date,
    p_validation_end_date   out nocopy date) is
--
  l_proc      varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_invalid     exception;
  l_argument        varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
   person_id,
   effective_start_date,
   effective_end_date,
   business_group_id,
   person_type_id,
   last_name,
   start_date,
   applicant_number,
   comment_id,
   null,
   current_applicant_flag,
   current_emp_or_apl_flag,
   current_employee_flag,
   date_employee_data_verified,
   date_of_birth,
   email_address,
   employee_number,
   expense_check_send_to_address,
   first_name,
   full_name,
   known_as,
   marital_status,
   middle_names,
   nationality,
   national_identifier,
   previous_last_name,
   registered_disabled_flag,
   sex,
   title,
   vendor_id,
   work_telephone,
   request_id,
   program_application_id,
   program_id,
   program_update_date,
   attribute_category,
   attribute1,
   attribute2,
   attribute3,
   attribute4,
   attribute5,
   attribute6,
   attribute7,
   attribute8,
   attribute9,
   attribute10,
   attribute11,
   attribute12,
   attribute13,
   attribute14,
   attribute15,
   attribute16,
   attribute17,
   attribute18,
   attribute19,
   attribute20,
   attribute21,
   attribute22,
   attribute23,
   attribute24,
   attribute25,
   attribute26,
   attribute27,
   attribute28,
   attribute29,
   attribute30,
   per_information_category,
   per_information1,
   per_information2,
   per_information3,
   per_information4,
   per_information5,
   per_information6,
   per_information7,
   per_information8,
   per_information9,
   per_information10,
   per_information11,
   per_information12,
   per_information13,
   per_information14,
   per_information15,
   per_information16,
   per_information17,
   per_information18,
   per_information19,
   per_information20,
   object_version_number,
        suffix,
        DATE_OF_DEATH                ,
        BACKGROUND_CHECK_STATUS      ,
        BACKGROUND_DATE_CHECK        ,
        BLOOD_TYPE                   ,
        CORRESPONDENCE_LANGUAGE      ,
        FAST_PATH_EMPLOYEE           ,
        FTE_CAPACITY                 ,
        HOLD_APPLICANT_DATE_UNTIL    ,
        HONORS                       ,
        INTERNAL_LOCATION            ,
        LAST_MEDICAL_TEST_BY         ,
        LAST_MEDICAL_TEST_DATE       ,
        MAILSTOP                     ,
        OFFICE_NUMBER                ,
        ON_MILITARY_SERVICE          ,
        ORDER_NAME                   ,
        PRE_NAME_ADJUNCT             ,
        PROJECTED_START_DATE         ,
        REHIRE_AUTHORIZOR            ,
        REHIRE_RECOMMENDATION        ,
        RESUME_EXISTS                ,
        RESUME_LAST_UPDATED          ,
        SECOND_PASSPORT_EXISTS       ,
        STUDENT_STATUS               ,
        WORK_SCHEDULE                ,
        PER_INFORMATION21            ,
        PER_INFORMATION22            ,
        PER_INFORMATION23            ,
        PER_INFORMATION24            ,
        PER_INFORMATION25            ,
        PER_INFORMATION26            ,
        PER_INFORMATION27            ,
        PER_INFORMATION28            ,
        PER_INFORMATION29            ,
        PER_INFORMATION30            ,
        REHIRE_REASON                ,
        BENEFIT_GROUP_ID             ,
        RECEIPT_OF_DEATH_CERT_DATE   ,
        COORD_BEN_MED_PLN_NO         ,
        COORD_BEN_NO_CVG_FLAG        ,
        COORD_BEN_MED_EXT_ER,
        COORD_BEN_MED_PL_NAME,
        COORD_BEN_MED_INSR_CRR_NAME,
        COORD_BEN_MED_INSR_CRR_IDENT,
        COORD_BEN_MED_CVG_STRT_DT,
        COORD_BEN_MED_CVG_END_DT,
        USES_TOBACCO_FLAG            ,
        DPDNT_ADOPTION_DATE          ,
        DPDNT_VLNTRY_SVCE_FLAG       ,
        ORIGINAL_DATE_OF_HIRE        ,
      town_of_birth                ,
        region_of_birth              ,
      country_of_birth             ,
        global_person_id             ,
        party_id,
        npw_number,
        current_npw_flag,
        global_name,
        local_name
    from    per_all_people_f -- for bug 7518991
    where   person_id         = p_person_id
    and      p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  -- Cursor C_Sel3 select comment text
  --
  Cursor C_Sel3 is
    select hc.comment_text
    from   hr_comments hc
    where  hc.comment_id = per_per_shd.g_old_rec.comment_id;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'person_id',
                             p_argument_value => p_person_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
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
    hr_utility.set_location(l_proc, 15);
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    If ((g_old_rec.comment_id is not null)              and
        (p_datetrack_mode = 'UPDATE'                   or
         p_datetrack_mode = 'CORRECTION'               or
         p_datetrack_mode = 'UPDATE_OVERRIDE'          or
         p_datetrack_mode = 'UPDATE_CHANGE_INSERT')) then
      Open C_Sel3;
      Fetch C_Sel3 Into per_per_shd.g_old_rec.comments;
      If C_Sel3%notfound then
        --
        -- The comments for the specified comment_id does not exist.
        -- We must error due to data integrity problems.
        --
        Close C_Sel3;
        hr_utility.set_message(801, 'HR_7202_COMMENT_TEXT_NOT_EXIST');
        hr_utility.raise_error;
      End If;
      Close C_Sel3;
    End If;
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
   (p_effective_date    => p_effective_date,
    p_datetrack_mode    => p_datetrack_mode,
    p_base_table_name      => 'per_all_people_f', -- for bug 7518991
    p_base_key_column      => 'person_id',
    p_base_key_value       => p_person_id,
    p_child_table_name1   => 'per_contracts_f',
    p_child_key_column1       => 'contract_id',
      p_enforce_foreign_locking => true,
    p_validation_start_date   => l_validation_start_date,
    p_validation_end_date     => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_all_people_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'per_all_people_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
   (
   p_person_id                     in number,
   p_effective_start_date          in date,
   p_effective_end_date            in date,
   p_business_group_id             in number,
   p_person_type_id                in number,
   p_last_name                     in varchar2,
   p_start_date                    in date,
   p_applicant_number              in varchar2,
   p_comment_id                    in number,
   p_comments                      in varchar2,
   p_current_applicant_flag        in varchar2,
   p_current_emp_or_apl_flag       in varchar2,
   p_current_employee_flag         in varchar2,
   p_date_employee_data_verified   in date,
   p_date_of_birth                 in date,
   p_email_address                 in varchar2,
   p_employee_number               in varchar2,
   p_expense_check_send_to_addres  in varchar2,
   p_first_name                    in varchar2,
   p_full_name                     in varchar2,
   p_known_as                      in varchar2,
   p_marital_status                in varchar2,
   p_middle_names                  in varchar2,
   p_nationality                   in varchar2,
   p_national_identifier           in varchar2,
   p_previous_last_name            in varchar2,
   p_registered_disabled_flag      in varchar2,
   p_sex                           in varchar2,
   p_title                         in varchar2,
   p_vendor_id                     in number,
   p_work_telephone                in varchar2,
   p_request_id                    in number,
   p_program_application_id        in number,
   p_program_id                    in number,
   p_program_update_date           in date,
   p_attribute_category            in varchar2,
   p_attribute1                    in varchar2,
   p_attribute2                    in varchar2,
   p_attribute3                    in varchar2,
   p_attribute4                    in varchar2,
   p_attribute5                    in varchar2,
   p_attribute6                    in varchar2,
   p_attribute7                    in varchar2,
   p_attribute8                    in varchar2,
   p_attribute9                    in varchar2,
   p_attribute10                   in varchar2,
   p_attribute11                   in varchar2,
   p_attribute12                   in varchar2,
   p_attribute13                   in varchar2,
   p_attribute14                   in varchar2,
   p_attribute15                   in varchar2,
   p_attribute16                   in varchar2,
   p_attribute17                   in varchar2,
   p_attribute18                   in varchar2,
   p_attribute19                   in varchar2,
   p_attribute20                   in varchar2,
   p_attribute21                   in varchar2,
   p_attribute22                   in varchar2,
   p_attribute23                   in varchar2,
   p_attribute24                   in varchar2,
   p_attribute25                   in varchar2,
   p_attribute26                   in varchar2,
   p_attribute27                   in varchar2,
   p_attribute28                   in varchar2,
   p_attribute29                   in varchar2,
   p_attribute30                   in varchar2,
   p_per_information_category      in varchar2,
   p_per_information1              in varchar2,
   p_per_information2              in varchar2,
   p_per_information3              in varchar2,
   p_per_information4              in varchar2,
   p_per_information5              in varchar2,
   p_per_information6              in varchar2,
   p_per_information7              in varchar2,
   p_per_information8              in varchar2,
   p_per_information9              in varchar2,
   p_per_information10             in varchar2,
   p_per_information11             in varchar2,
   p_per_information12             in varchar2,
   p_per_information13             in varchar2,
   p_per_information14             in varchar2,
   p_per_information15             in varchar2,
   p_per_information16             in varchar2,
   p_per_information17             in varchar2,
   p_per_information18             in varchar2,
   p_per_information19             in varchar2,
   p_per_information20             in varchar2,
   p_object_version_number         in number,
        p_suffix                        in varchar2,
        p_DATE_OF_DEATH                 in DATE,
        p_BACKGROUND_CHECK_STATUS       in varchar2,
        p_BACKGROUND_DATE_CHECK         in DATE,
        p_BLOOD_TYPE                    in varchar2,
        p_CORRESPONDENCE_LANGUAGE       in varchar2,
        p_FAST_PATH_EMPLOYEE            in varchar2,
        p_FTE_CAPACITY                  in NUMBER,
        p_HOLD_APPLICANT_DATE_UNTIL     in DATE,
        p_HONORS                        in varchar2,
        p_INTERNAL_LOCATION             in varchar2,
        p_LAST_MEDICAL_TEST_BY          in varchar2,
        p_LAST_MEDICAL_TEST_DATE        in DATE,
        p_MAILSTOP                      in varchar2,
        p_OFFICE_NUMBER                 in varchar2,
        p_ON_MILITARY_SERVICE           in varchar2,
        p_ORDER_NAME                    in varchar2,
        p_PRE_NAME_ADJUNCT              in varchar2,
        p_PROJECTED_START_DATE          in DATE,
        p_REHIRE_AUTHORIZOR             in varchar2,
        p_REHIRE_RECOMMENDATION         in varchar2,
        p_RESUME_EXISTS                 in varchar2,
        p_RESUME_LAST_UPDATED           in DATE,
        p_SECOND_PASSPORT_EXISTS        in varchar2,
        p_STUDENT_STATUS                in varchar2,
        p_WORK_SCHEDULE                 in varchar2,
        p_PER_INFORMATION21             in varchar2,
        p_PER_INFORMATION22             in varchar2,
        p_PER_INFORMATION23             in varchar2,
        p_PER_INFORMATION24             in varchar2,
        p_PER_INFORMATION25             in varchar2,
        p_PER_INFORMATION26             in varchar2,
        p_PER_INFORMATION27             in varchar2,
        p_PER_INFORMATION28             in varchar2,
        p_PER_INFORMATION29             in varchar2,
        p_PER_INFORMATION30             in varchar2,
        p_REHIRE_REASON                 in varchar2,
        p_BENEFIT_GROUP_ID              in number,
        p_RECEIPT_OF_DEATH_CERT_DATE    in DATE,
        p_COORD_BEN_MED_PLN_NO          in varchar2,
        p_COORD_BEN_NO_CVG_FLAG         in varchar2,
        p_coord_ben_med_ext_er          in varchar2,
        p_coord_ben_med_pl_name         in varchar2,
        p_coord_ben_med_insr_crr_name   in varchar2,
        p_coord_ben_med_insr_crr_ident  in varchar2,
        p_coord_ben_med_cvg_strt_dt     in date,
        p_coord_ben_med_cvg_end_dt      in date,
        p_USES_TOBACCO_FLAG             in varchar2,
        p_DPDNT_ADOPTION_DATE           in DATE,
        p_DPDNT_VLNTRY_SVCE_FLAG        in varchar2,
        p_ORIGINAL_DATE_OF_HIRE         in DATE,
      p_town_of_birth                   in varchar2,
        p_region_of_birth               in varchar2,
      p_country_of_birth                in varchar2,
        p_global_person_id              in varchar2,
        p_party_id                      in number,
        p_npw_number                    in varchar2,
        p_current_npw_flag              in varchar2,
        p_global_name                   in  varchar2,
        p_local_name                    in  varchar2
   )
   Return g_rec_type is
--
  l_rec    g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.person_id                        := p_person_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.person_type_id                   := p_person_type_id;
  l_rec.last_name                        := p_last_name;
  l_rec.start_date                       := p_start_date;
  l_rec.applicant_number                 := p_applicant_number;
  l_rec.comment_id                       := p_comment_id;
  l_rec.comments                         := p_comments;
  l_rec.current_applicant_flag           := p_current_applicant_flag;
  l_rec.current_emp_or_apl_flag          := p_current_emp_or_apl_flag;
  l_rec.current_employee_flag            := p_current_employee_flag;
  l_rec.date_employee_data_verified      := p_date_employee_data_verified;
  l_rec.date_of_birth                    := p_date_of_birth;
  l_rec.email_address                    := p_email_address;
  l_rec.employee_number                  := p_employee_number;
  l_rec.expense_check_send_to_address    := p_expense_check_send_to_addres;
  l_rec.first_name                       := p_first_name;
  l_rec.full_name                        := p_full_name;
  l_rec.known_as                         := p_known_as;
  l_rec.marital_status                   := p_marital_status;
  l_rec.middle_names                     := p_middle_names;
  l_rec.nationality                      := p_nationality;
  l_rec.national_identifier              := p_national_identifier;
  l_rec.previous_last_name               := p_previous_last_name;
  l_rec.registered_disabled_flag         := p_registered_disabled_flag;
  l_rec.sex                              := p_sex;
  l_rec.title                            := p_title;
  l_rec.vendor_id                        := p_vendor_id;
  l_rec.work_telephone                   := p_work_telephone;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.per_information_category         := p_per_information_category;
  l_rec.per_information1                 := p_per_information1;
  l_rec.per_information2                 := p_per_information2;
  l_rec.per_information3                 := p_per_information3;
  l_rec.per_information4                 := p_per_information4;
  l_rec.per_information5                 := p_per_information5;
  l_rec.per_information6                 := p_per_information6;
  l_rec.per_information7                 := p_per_information7;
  l_rec.per_information8                 := p_per_information8;
  l_rec.per_information9                 := p_per_information9;
  l_rec.per_information10                := p_per_information10;
  l_rec.per_information11                := p_per_information11;
  l_rec.per_information12                := p_per_information12;
  l_rec.per_information13                := p_per_information13;
  l_rec.per_information14                := p_per_information14;
  l_rec.per_information15                := p_per_information15;
  l_rec.per_information16                := p_per_information16;
  l_rec.per_information17                := p_per_information17;
  l_rec.per_information18                := p_per_information18;
  l_rec.per_information19                := p_per_information19;
  l_rec.per_information20                := p_per_information20;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.suffix                           := p_suffix;
  l_rec.DATE_OF_DEATH                    := p_DATE_OF_DEATH;
  l_rec.BACKGROUND_CHECK_STATUS          := p_BACKGROUND_CHECK_STATUS;
  l_rec.BACKGROUND_DATE_CHECK            := p_BACKGROUND_DATE_CHECK;
  l_rec.BLOOD_TYPE                       := p_BLOOD_TYPE;
  l_rec.CORRESPONDENCE_LANGUAGE          := p_CORRESPONDENCE_LANGUAGE;
  l_rec.FAST_PATH_EMPLOYEE               := p_FAST_PATH_EMPLOYEE;
  l_rec.FTE_CAPACITY                     := p_FTE_CAPACITY;
  l_rec.HOLD_APPLICANT_DATE_UNTIL        := p_HOLD_APPLICANT_DATE_UNTIL;
  l_rec.HONORS                           := p_HONORS;
  l_rec.INTERNAL_LOCATION                := p_INTERNAL_LOCATION;
  l_rec.LAST_MEDICAL_TEST_BY             := p_LAST_MEDICAL_TEST_BY;
  l_rec.LAST_MEDICAL_TEST_DATE           := p_LAST_MEDICAL_TEST_DATE;
  l_rec.MAILSTOP                         := p_MAILSTOP;
  l_rec.OFFICE_NUMBER                    := p_OFFICE_NUMBER;
  l_rec.ON_MILITARY_SERVICE              := p_ON_MILITARY_SERVICE;

  l_rec.ORDER_NAME                       := p_ORDER_NAME;
  l_rec.PRE_NAME_ADJUNCT                 := p_PRE_NAME_ADJUNCT;
  l_rec.PROJECTED_START_DATE             := p_PROJECTED_START_DATE;
  l_rec.REHIRE_AUTHORIZOR                := p_REHIRE_AUTHORIZOR;
  l_rec.REHIRE_RECOMMENDATION            := p_REHIRE_RECOMMENDATION;
  l_rec.RESUME_EXISTS                    := p_RESUME_EXISTS;
  l_rec.RESUME_LAST_UPDATED              := p_RESUME_LAST_UPDATED;
  l_rec.SECOND_PASSPORT_EXISTS           := p_SECOND_PASSPORT_EXISTS;
  l_rec.STUDENT_STATUS                   := p_STUDENT_STATUS;
  l_rec.WORK_SCHEDULE                    := p_WORK_SCHEDULE;
  l_rec.PER_INFORMATION21                := p_PER_INFORMATION21;
  l_rec.PER_INFORMATION22                := p_PER_INFORMATION22;
  l_rec.PER_INFORMATION23                := p_PER_INFORMATION23;
  l_rec.PER_INFORMATION24                := p_PER_INFORMATION24;
  l_rec.PER_INFORMATION25                := p_PER_INFORMATION25;
  l_rec.PER_INFORMATION26                := p_PER_INFORMATION26;
  l_rec.PER_INFORMATION27                := p_PER_INFORMATION27;
  l_rec.PER_INFORMATION28                := p_PER_INFORMATION28;
  l_rec.PER_INFORMATION29                := p_PER_INFORMATION29;
  l_rec.PER_INFORMATION30                := p_PER_INFORMATION30;
  l_rec.REHIRE_REASON                    := p_REHIRE_REASON;
  l_rec.BENEFIT_GROUP_ID                 := p_BENEFIT_GROUP_ID;
  l_rec.RECEIPT_OF_DEATH_CERT_DATE       := p_RECEIPT_OF_DEATH_CERT_DATE;
  l_rec.COORD_BEN_MED_PLN_NO             := p_COORD_BEN_MED_PLN_NO;
  l_rec.COORD_BEN_NO_CVG_FLAG            := p_COORD_BEN_NO_CVG_FLAG;
  l_rec.coord_ben_med_ext_er             := p_coord_ben_med_ext_er;
  l_rec.coord_ben_med_pl_name            := p_coord_ben_med_pl_name;
  l_rec.coord_ben_med_insr_crr_name      := p_coord_ben_med_insr_crr_name;
  l_rec.coord_ben_med_insr_crr_ident     := p_coord_ben_med_insr_crr_ident;
  l_rec.coord_ben_med_cvg_strt_dt        := p_coord_ben_med_cvg_strt_dt;
  l_rec.coord_ben_med_cvg_end_dt         := p_coord_ben_med_cvg_end_dt;
  l_rec.USES_TOBACCO_FLAG                := p_USES_TOBACCO_FLAG;
  l_rec.DPDNT_ADOPTION_DATE              := p_DPDNT_ADOPTION_DATE;
  l_rec.DPDNT_VLNTRY_SVCE_FLAG           := p_DPDNT_VLNTRY_SVCE_FLAG;
  l_rec.ORIGINAL_DATE_OF_HIRE            := p_ORIGINAL_DATE_OF_HIRE;
  l_rec.town_of_birth                    := p_town_of_birth;
  l_rec.region_of_birth                  := p_region_of_birth;
  l_rec.country_of_birth                 := p_country_of_birth;
  l_rec.global_person_id                 := p_global_person_id;
  l_rec.party_id                         := p_party_id;
  l_rec.npw_number                       := p_npw_number;
  l_rec.current_npw_flag                 := p_current_npw_flag;
  l_rec.global_name                      := p_global_name;  -- #3889584
  l_rec.local_name                       := p_local_name;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_per_shd;

/
