--------------------------------------------------------
--  DDL for Package Body SSP_MAT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_MAT_SHD" as
/* $Header: spmatrhi.pkb 120.5.12010000.3 2008/08/13 13:27:41 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ssp_mat_shd.';  -- Global package name
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
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'SSP_MAT_NOTE_OF_BIRTH_TOO_SOON') Then
    fnd_message.set_name ('SSP', 'SSP_35012_EARLY_BIRTH_NOTIFIC');
    --
  ElsIf (p_constraint_name = 'SSP_MAT_MPP_MUST_START_SUNDAY') Then
    fnd_message.set_name ('SSP', 'SSP_35054_MPP_NOT_SUNDAY');
    --
  ElsIf (p_constraint_name = 'SSP_MAT_INTEND_TO_RETURN_DATE') Then
    fnd_message.set_name ('SSP', 'SSP_35013_INV_EVNT_RET_DATE');
    --
  ElsIf (p_constraint_name = 'SSP_MAT_STILLBIRTH_NEEDS_DATE') Then
    fnd_message.set_name ('SSP', 'SSP_35004_LIVE_BIRTH_FLAG');
    --
  ElsIf (p_constraint_name = 'SSP_MAT_MPP_SMA_START_DATES') Then
    fnd_message.set_name ('SSP', 'SSP_35014_FWD_MPP_START');
    --
  ElsIf (p_constraint_name = 'SSP_MAT_UNFIT_TO_RETURN_DATE') Then
    fnd_message.set_name ('SSP', 'SSP_35058_UNFIT_TO_RETURN');
    --
  ElsIf (p_constraint_name = 'SSP_MATERNITIES_PK') Then
    fnd_message.set_name ('SSP', 'SSP_35041_DUP_MATERNITY_PK');
    --
  ElsIf (p_constraint_name = 'SSP_MATERNITIES_UK1') Then
    fnd_message.set_name ('SSP', 'SSP_35009_DUP_DUE_DATE');
    --
  ElsIf (p_constraint_name = 'SSP_MAT_MPP_START_BIRTH_DATE') Then
    fnd_message.set_name ('SSP', 'SSP_35055_MPP_SUN_FOLLW_BIRTH');
    --
  ElsIf (p_constraint_name = 'SSP_MAT_NOTIFICATION_OF_BIRTH') Then
    fnd_message.set_name ('SSP', 'SSP_35059_NOTIF_OF_BIRTH');
    --
  ElsIf (p_constraint_name = 'SSP_MATERNITIES_FK1') Then
    fnd_message.set_name('SSP', 'SSP_35057_BAD_PERSON_ID');
    --
  Else
    fnd_message.set_name ('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
  End If;
  --
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_maternity_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
    maternity_id,
    due_date,
    person_id,
    start_date_maternity_allowance,
    notification_of_birth_date,
    unfit_for_scheduled_return,
    stated_return_date,
    intend_to_return_flag,
    start_date_with_new_employer,
    smp_must_be_paid_by_date,
    pay_smp_as_lump_sum,
    live_birth_flag,
    actual_birth_date,
    mpp_start_date,
    object_version_number,
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
    LEAVE_TYPE,
    MATCHING_DATE,
    PLACEMENT_DATE,
    DISRUPTED_PLACEMENT_DATE,
    mat_information_category,
    mat_information1,
    mat_information2,
    mat_information3,
    mat_information4,
    mat_information5,
    mat_information6,
    mat_information7,
    mat_information8,
    mat_information9,
    mat_information10,
    mat_information11,
    mat_information12,
    mat_information13,
    mat_information14,
    mat_information15,
    mat_information16,
    mat_information17,
    mat_information18,
    mat_information19,
    mat_information20,
    mat_information21,
    mat_information22,
    mat_information23,
    mat_information24,
    mat_information25,
    mat_information26,
    mat_information27,
    mat_information28,
    mat_information29,
    mat_information30
    from	ssp_maternities
    where	maternity_id = p_maternity_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_maternity_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_maternity_id = g_old_rec.maternity_id and
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
        fnd_message.set_name ('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name ('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
  p_maternity_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select maternity_id,
           due_date,
           person_id,
           start_date_maternity_allowance,
           notification_of_birth_date,
           unfit_for_scheduled_return,
           stated_return_date,
           intend_to_return_flag,
           start_date_with_new_employer,
           smp_must_be_paid_by_date,
           pay_smp_as_lump_sum,
           live_birth_flag,
           actual_birth_date,
           mpp_start_date,
           object_version_number,
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
           LEAVE_TYPE,
           MATCHING_DATE,
           PLACEMENT_DATE,
           DISRUPTED_PLACEMENT_DATE,
           mat_information_category,
           mat_information1,
           mat_information2,
           mat_information3,
           mat_information4,
           mat_information5,
           mat_information6,
           mat_information7,
           mat_information8,
           mat_information9,
           mat_information10,
           mat_information11,
           mat_information12,
           mat_information13,
           mat_information14,
           mat_information15,
           mat_information16,
           mat_information17,
           mat_information18,
           mat_information19,
           mat_information20,
           mat_information21,
           mat_information22,
           mat_information23,
           mat_information24,
           mat_information25,
           mat_information26,
           mat_information27,
           mat_information28,
           mat_information29,
           mat_information30
    from	ssp_maternities
    where	maternity_id = p_maternity_id
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
    fnd_message.set_name ('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name ('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    fnd_message.set_name ('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ssp_maternities');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_maternity_id                  in number,
	p_due_date                      in date,
	p_person_id                     in number,
	p_start_date_SMA  in date,
	p_notification_of_birth_date    in date,
	p_unfit_for_scheduled_return    in varchar2,
	p_stated_return_date            in date,
	p_intend_to_return_flag         in varchar2,
	p_start_date_with_new_employer  in date,
	p_smp_must_be_paid_by_date      in date,
	p_pay_smp_as_lump_sum           in varchar2,
	p_live_birth_flag               in varchar2,
	p_actual_birth_date             in date,
	p_mpp_start_date                in date,
	p_object_version_number         in number,
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
        p_LEAVE_TYPE                    in VARCHAR2 default 'MA',
        p_MATCHING_DATE                 in DATE default null,
        p_PLACEMENT_DATE                in DATE default null,
        p_DISRUPTED_PLACEMENT_DATE      in DATE default null,
        p_mat_information_category      in varchar2,
        p_mat_information1              in varchar2,
        p_mat_information2              in varchar2,
        p_mat_information3              in varchar2,
        p_mat_information4              in varchar2,
        p_mat_information5              in varchar2,
        p_mat_information6              in varchar2,
        p_mat_information7              in varchar2,
        p_mat_information8              in varchar2,
        p_mat_information9              in varchar2,
        p_mat_information10             in varchar2,
        p_mat_information11             in varchar2,
        p_mat_information12             in varchar2,
        p_mat_information13             in varchar2,
        p_mat_information14             in varchar2,
        p_mat_information15             in varchar2,
        p_mat_information16             in varchar2,
        p_mat_information17             in varchar2,
        p_mat_information18             in varchar2,
        p_mat_information19             in varchar2,
        p_mat_information20             in varchar2,
        p_mat_information21             in varchar2,
        p_mat_information22             in varchar2,
        p_mat_information23             in varchar2,
        p_mat_information24             in varchar2,
        p_mat_information25             in varchar2,
        p_mat_information26             in varchar2,
        p_mat_information27             in varchar2,
        p_mat_information28             in varchar2,
        p_mat_information29             in varchar2,
        p_mat_information30             in varchar2
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
  l_rec.maternity_id                     := p_maternity_id;
  l_rec.due_date                         := p_due_date;
  l_rec.person_id                        := p_person_id;
  l_rec.start_date_maternity_allowance   := p_start_date_SMA;
  l_rec.notification_of_birth_date       := p_notification_of_birth_date;
  l_rec.unfit_for_scheduled_return       := p_unfit_for_scheduled_return;
  l_rec.stated_return_date               := p_stated_return_date;
  l_rec.intend_to_return_flag            := p_intend_to_return_flag;
  l_rec.start_date_with_new_employer     := p_start_date_with_new_employer;
  l_rec.smp_must_be_paid_by_date         := p_smp_must_be_paid_by_date;
  l_rec.pay_smp_as_lump_sum              := p_pay_smp_as_lump_sum;
  l_rec.live_birth_flag                  := p_live_birth_flag;
  l_rec.actual_birth_date                := p_actual_birth_date;
  l_rec.mpp_start_date                   := p_mpp_start_date;
  l_rec.object_version_number            := p_object_version_number;
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
  l_rec.LEAVE_TYPE                       := p_LEAVE_TYPE;
  l_rec.MATCHING_DATE                    := p_MATCHING_DATE;
  l_rec.PLACEMENT_DATE                   := p_PLACEMENT_DATE;
  l_rec.DISRUPTED_PLACEMENT_DATE         := p_DISRUPTED_PLACEMENT_DATE;
  l_rec.mat_information_category         := p_mat_information_category;
  l_rec.mat_information1                 := p_mat_information1;
  l_rec.mat_information2                 := p_mat_information2;
  l_rec.mat_information3                 := p_mat_information3;
  l_rec.mat_information4                 := p_mat_information4;
  l_rec.mat_information5                 := p_mat_information5;
  l_rec.mat_information6                 := p_mat_information6;
  l_rec.mat_information7                 := p_mat_information7;
  l_rec.mat_information8                 := p_mat_information8;
  l_rec.mat_information9                 := p_mat_information9;
  l_rec.mat_information10                := p_mat_information10;
  l_rec.mat_information11                := p_mat_information11;
  l_rec.mat_information12                := p_mat_information12;
  l_rec.mat_information13                := p_mat_information13;
  l_rec.mat_information14                := p_mat_information14;
  l_rec.mat_information15                := p_mat_information15;
  l_rec.mat_information16                := p_mat_information16;
  l_rec.mat_information17                := p_mat_information17;
  l_rec.mat_information18                := p_mat_information18;
  l_rec.mat_information19                := p_mat_information19;
  l_rec.mat_information20                := p_mat_information20;
  l_rec.mat_information21                := p_mat_information21;
  l_rec.mat_information22                := p_mat_information22;
  l_rec.mat_information23                := p_mat_information23;
  l_rec.mat_information24                := p_mat_information24;
  l_rec.mat_information25                := p_mat_information25;
  l_rec.mat_information26                := p_mat_information26;
  l_rec.mat_information27                := p_mat_information27;
  l_rec.mat_information28                := p_mat_information28;
  l_rec.mat_information29                := p_mat_information29;
  l_rec.mat_information30                := p_mat_information30;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ssp_mat_shd;

/
