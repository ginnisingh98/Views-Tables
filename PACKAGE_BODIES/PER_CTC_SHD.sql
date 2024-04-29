--------------------------------------------------------
--  DDL for Package Body PER_CTC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CTC_SHD" as
/* $Header: pectcrhi.pkb 115.20 2003/02/11 14:24:18 vramanai ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ctc_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_CONTRACTS_F_PK') Then

    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;

  elsif (p_constraint_name = 'PER_CONTRACTS_F_FK1') then

    hr_utility.set_message(801, 'PER_52832_CTR_INV_BG');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;

  elsif (p_constraint_name = 'PER_CONTRACTS_F_FK2') then

    hr_utility.set_message(801, 'PER_52845_CTR_INV_PID');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;

  else

    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;

  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date		in date,
   p_contract_id	   	      in number,
   p_object_version_number	in number
  ) Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	contract_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	object_version_number,
	person_id,
	reference,
	type,
	status,
	status_reason,
        doc_status,
        doc_status_change_date,
	description,
	duration,
	duration_units,
	contractual_job_title,
	parties,
	start_reason,
	end_reason,
	number_of_extensions,
	extension_reason,
	extension_period,
	extension_period_units,
	ctr_information_category,
	ctr_information1,
	ctr_information2,
	ctr_information3,
	ctr_information4,
	ctr_information5,
	ctr_information6,
	ctr_information7,
	ctr_information8,
	ctr_information9,
	ctr_information10,
	ctr_information11,
	ctr_information12,
	ctr_information13,
	ctr_information14,
	ctr_information15,
	ctr_information16,
	ctr_information17,
	ctr_information18,
	ctr_information19,
	ctr_information20,
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
	attribute20
    from	per_contracts_f
    where	contract_id = p_contract_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_contract_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_contract_id = g_old_rec.contract_id and
        p_object_version_number = g_old_rec.object_version_number) Then
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
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 out nocopy boolean,
	 p_delete	 out nocopy boolean,
	 p_future_change out nocopy boolean,
	 p_delete_next_change out nocopy boolean) is
  --
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
  --
  l_parent_key_value1   number;
  --
  Cursor C_Sel1 Is
    select  ctc.person_id
    from    per_contracts_f ctc
    where   ctc.contract_id = p_base_key_value
    and     p_effective_date  between ctc.effective_start_date
                              and     ctc.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1;
  --
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'per_contracts_f',
	 p_base_key_column	=> 'contract_id',
	 p_base_key_value	=> p_base_key_value,
         p_parent_table_name1   => 'per_people_f',
         p_parent_key_column1   => 'person_id',
         p_parent_key_value1    => l_parent_key_value1,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  --
  -- delete mode is never allowed for contracts
  --
  p_delete := False;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date   	in  date,
	 p_base_key_value	      in  number,
	 p_correction	 out nocopy boolean,
	 p_update	       out nocopy boolean,
	 p_update_override out nocopy boolean,
	 p_update_change_insert out nocopy boolean) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
	(p_effective_date 	=> p_effective_date,
	 p_base_table_name	=> 'per_contracts_f',
	 p_base_key_column	=> 'contract_id',
	 p_base_key_value	      => p_base_key_value,
	 p_correction		=> p_correction,
	 p_update	      	=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date	      	in date,
	 p_base_key_value	      	in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
       p_object_version_number      out nocopy number) is
--
  l_proc 		  varchar2(72) := g_package||'upd_effective_end_date';
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
	(p_base_table_name	=> 'per_contracts_f',
	 p_base_key_column	=> 'contract_id',
	 p_base_key_value 	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  per_contracts_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where t.contract_id	        = p_base_key_value
  and	  p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_contract_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	contract_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	object_version_number,
	person_id,
	reference,
	type,
	status,
	status_reason,
        doc_status,
        doc_status_change_date,
	description,
	duration,
	duration_units,
	contractual_job_title,
	parties,
	start_reason,
	end_reason,
	number_of_extensions,
	extension_reason,
	extension_period,
	extension_period_units,
	ctr_information_category,
	ctr_information1,
	ctr_information2,
	ctr_information3,
	ctr_information4,
	ctr_information5,
	ctr_information6,
	ctr_information7,
	ctr_information8,
	ctr_information9,
	ctr_information10,
	ctr_information11,
	ctr_information12,
	ctr_information13,
	ctr_information14,
	ctr_information15,
	ctr_information16,
	ctr_information17,
	ctr_information18,
	ctr_information19,
	ctr_information20,
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
	attribute20
    from    per_contracts_f
    where   contract_id         = p_contract_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
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
                             p_argument       => 'contract_id',
                             p_argument_value => p_contract_id);
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
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'per_contracts_f',
	 p_base_key_column	   => 'contract_id',
	 p_base_key_value 	   => p_contract_id,
         p_parent_table_name1      => 'per_people_f',
         p_parent_key_column1      => 'person_id',
         p_parent_key_value1       => g_old_rec.person_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_contracts_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'per_contracts_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lock_record >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure lock_record
  (
  p_contract_id                        in per_contracts_f.contract_id%TYPE,
  p_effective_date                     in date,
  p_object_version_number              in per_contracts_f.object_version_number%TYPE
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
	contract_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	object_version_number,
	person_id,
	reference,
	type,
	status,
	status_reason,
        doc_status,
        doc_status_change_date,
	description,
	duration,
	duration_units,
	contractual_job_title,
	parties,
	start_reason,
	end_reason,
	number_of_extensions,
	extension_reason,
	extension_period,
	extension_period_units,
	ctr_information_category,
	ctr_information1,
	ctr_information2,
	ctr_information3,
	ctr_information4,
	ctr_information5,
	ctr_information6,
	ctr_information7,
	ctr_information8,
	ctr_information9,
	ctr_information10,
	ctr_information11,
	ctr_information12,
	ctr_information13,
	ctr_information14,
	ctr_information15,
	ctr_information16,
	ctr_information17,
	ctr_information18,
	ctr_information19,
	ctr_information20,
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
	attribute20
    from    per_contracts_f
    where   contract_id         = p_contract_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  l_proc	varchar2(72) := g_package||'lock_record';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- mandatory argument checking
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'contract_id',
     p_argument_value => p_contract_id);

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'effective_date',
     p_argument_value => p_effective_date);

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);

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
    hr_utility.set_message_token('TABLE_NAME', 'per_contracts_f');
    hr_utility.raise_error;
End lock_record;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_contract_id                   in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_person_id                     in number,
	p_reference                     in varchar2,
	p_type                          in varchar2,
	p_status                        in varchar2,
	p_status_reason                 in varchar2,
        p_doc_status                    in varchar2,
        p_doc_status_change_date        in date,
	p_description                   in varchar2,
	p_duration                      in number,
	p_duration_units                in varchar2,
	p_contractual_job_title         in varchar2,
	p_parties                       in varchar2,
	p_start_reason                  in varchar2,
	p_end_reason                    in varchar2,
	p_number_of_extensions          in number,
	p_extension_reason              in varchar2,
	p_extension_period              in number,
	p_extension_period_units        in varchar2,
	p_ctr_information_category      in varchar2,
	p_ctr_information1              in varchar2,
	p_ctr_information2              in varchar2,
	p_ctr_information3              in varchar2,
	p_ctr_information4              in varchar2,
	p_ctr_information5              in varchar2,
	p_ctr_information6              in varchar2,
	p_ctr_information7              in varchar2,
	p_ctr_information8              in varchar2,
	p_ctr_information9              in varchar2,
	p_ctr_information10             in varchar2,
	p_ctr_information11             in varchar2,
	p_ctr_information12             in varchar2,
	p_ctr_information13             in varchar2,
	p_ctr_information14             in varchar2,
	p_ctr_information15             in varchar2,
	p_ctr_information16             in varchar2,
	p_ctr_information17             in varchar2,
	p_ctr_information18             in varchar2,
	p_ctr_information19             in varchar2,
	p_ctr_information20             in varchar2,
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
	p_attribute20                   in varchar2
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
  l_rec.contract_id                      := p_contract_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.person_id                        := p_person_id;
  l_rec.reference                        := p_reference;
  l_rec.type                             := p_type;
  l_rec.status                           := p_status;
  l_rec.status_reason                    := p_status_reason;
  l_rec.doc_status                       := p_doc_status;
  l_rec.doc_status_change_date           := p_doc_status_change_date;
  l_rec.description                      := p_description;
  l_rec.duration                         := p_duration;
  l_rec.duration_units                   := p_duration_units;
  l_rec.contractual_job_title            := p_contractual_job_title;
  l_rec.parties                          := p_parties;
  l_rec.start_reason                     := p_start_reason;
  l_rec.end_reason                       := p_end_reason;
  l_rec.number_of_extensions             := p_number_of_extensions;
  l_rec.extension_reason                 := p_extension_reason;
  l_rec.extension_period                 := p_extension_period;
  l_rec.extension_period_units           := p_extension_period_units;
  l_rec.ctr_information_category         := p_ctr_information_category;
  l_rec.ctr_information1                 := p_ctr_information1;
  l_rec.ctr_information2                 := p_ctr_information2;
  l_rec.ctr_information3                 := p_ctr_information3;
  l_rec.ctr_information4                 := p_ctr_information4;
  l_rec.ctr_information5                 := p_ctr_information5;
  l_rec.ctr_information6                 := p_ctr_information6;
  l_rec.ctr_information7                 := p_ctr_information7;
  l_rec.ctr_information8                 := p_ctr_information8;
  l_rec.ctr_information9                 := p_ctr_information9;
  l_rec.ctr_information10                := p_ctr_information10;
  l_rec.ctr_information11                := p_ctr_information11;
  l_rec.ctr_information12                := p_ctr_information12;
  l_rec.ctr_information13                := p_ctr_information13;
  l_rec.ctr_information14                := p_ctr_information14;
  l_rec.ctr_information15                := p_ctr_information15;
  l_rec.ctr_information16                := p_ctr_information16;
  l_rec.ctr_information17                := p_ctr_information17;
  l_rec.ctr_information18                := p_ctr_information18;
  l_rec.ctr_information19                := p_ctr_information19;
  l_rec.ctr_information20                := p_ctr_information20;
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
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_ctc_shd;

/
