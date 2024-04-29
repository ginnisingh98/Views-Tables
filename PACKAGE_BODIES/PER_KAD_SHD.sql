--------------------------------------------------------
--  DDL for Package Body PER_KAD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KAD_SHD" as
/* $Header: pekadrhi.pkb 115.6 2002/12/06 11:27:37 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_kad_shd.';  -- Global package name
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
  -- 70.2 change d start.
  --
  If (p_constraint_name = 'PER_ADDRESSES_PK') Then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PER_ADDR_PRIMARY_FLAG_CHK') Then
    hr_utility.set_message(801, 'HR_7325_ADD_INVALID_PRIM_FLAG');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  -- 70.2 change d end.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_address_id                         in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	address_id,
	business_group_id,
	person_id,
	date_from,
	primary_flag,
	style,
	address_line1,
	address_line2,
	address_line3,
	address_type,
	comments,
	country,
	date_to,
	postal_code,
	region_1,
	region_2,
	region_3,
	telephone_number_1,
	telephone_number_2,
	telephone_number_3,
	town_or_city,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	addr_attribute_category,
	addr_attribute1,
	addr_attribute2,
	addr_attribute3,
	addr_attribute4,
	addr_attribute5,
	addr_attribute6,
	addr_attribute7,
	addr_attribute8,
	addr_attribute9,
	addr_attribute10,
	addr_attribute11,
	addr_attribute12,
	addr_attribute13,
	addr_attribute14,
	addr_attribute15,
	addr_attribute16,
	addr_attribute17,
	addr_attribute18,
	addr_attribute19,
	addr_attribute20,
	object_version_number
    from	per_addresses
    where	address_id = p_address_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_address_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_address_id = g_old_rec.address_id and
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
  p_address_id                         in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	address_id,
	business_group_id,
	person_id,
	date_from,
	primary_flag,
	style,
	address_line1,
	address_line2,
	address_line3,
	address_type,
	comments,
	country,
	date_to,
	postal_code,
	region_1,
	region_2,
	region_3,
	telephone_number_1,
	telephone_number_2,
	telephone_number_3,
	town_or_city,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	addr_attribute_category,
	addr_attribute1,
	addr_attribute2,
	addr_attribute3,
	addr_attribute4,
	addr_attribute5,
	addr_attribute6,
	addr_attribute7,
	addr_attribute8,
	addr_attribute9,
	addr_attribute10,
	addr_attribute11,
	addr_attribute12,
	addr_attribute13,
	addr_attribute14,
	addr_attribute15,
	addr_attribute16,
	addr_attribute17,
	addr_attribute18,
	addr_attribute19,
	addr_attribute20,
	object_version_number
    from	per_addresses
    where	address_id = p_address_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'address_id'
    , p_argument_value => p_address_id);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
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
    hr_utility.set_message_token('TABLE_NAME', 'per_addresses');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_address_id                    in number,
	p_business_group_id             in number,
	p_person_id                     in number,
	p_date_from                     in date,
	p_primary_flag                  in varchar2,
	p_style                         in varchar2,
	p_address_line1                 in varchar2,
	p_address_line2                 in varchar2,
	p_address_line3                 in varchar2,
	p_address_type                  in varchar2,
	p_comments                      in long,
	p_country                       in varchar2,
	p_date_to                       in date,
	p_postal_code                   in varchar2,
	p_region_1                      in varchar2,
	p_region_2                      in varchar2,
	p_region_3                      in varchar2,
	p_telephone_number_1            in varchar2,
	p_telephone_number_2            in varchar2,
	p_telephone_number_3            in varchar2,
	p_town_or_city                  in varchar2,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
	p_addr_attribute_category       in varchar2,
	p_addr_attribute1               in varchar2,
	p_addr_attribute2               in varchar2,
	p_addr_attribute3               in varchar2,
	p_addr_attribute4               in varchar2,
	p_addr_attribute5               in varchar2,
	p_addr_attribute6               in varchar2,
	p_addr_attribute7               in varchar2,
	p_addr_attribute8               in varchar2,
	p_addr_attribute9               in varchar2,
	p_addr_attribute10              in varchar2,
	p_addr_attribute11              in varchar2,
	p_addr_attribute12              in varchar2,
	p_addr_attribute13              in varchar2,
	p_addr_attribute14              in varchar2,
	p_addr_attribute15              in varchar2,
	p_addr_attribute16              in varchar2,
	p_addr_attribute17              in varchar2,
	p_addr_attribute18              in varchar2,
	p_addr_attribute19              in varchar2,
	p_addr_attribute20              in varchar2,
	p_object_version_number         in number
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
  l_rec.address_id                       := p_address_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.person_id                        := p_person_id;
  l_rec.date_from                        := p_date_from;
  l_rec.primary_flag                     := p_primary_flag;
  l_rec.style                            := p_style;
  l_rec.address_line1                    := p_address_line1;
  l_rec.address_line2                    := p_address_line2;
  l_rec.address_line3                    := p_address_line3;
  l_rec.address_type                     := p_address_type;
  l_rec.comments                         := p_comments;
  l_rec.country                          := p_country;
  l_rec.date_to                          := p_date_to;
  l_rec.postal_code                      := p_postal_code;
  l_rec.region_1                         := p_region_1;
  l_rec.region_2                         := p_region_2;
  l_rec.region_3                         := p_region_3;
  l_rec.telephone_number_1               := p_telephone_number_1;
  l_rec.telephone_number_2               := p_telephone_number_2;
  l_rec.telephone_number_3               := p_telephone_number_3;
  l_rec.town_or_city                     := p_town_or_city;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.addr_attribute_category          := p_addr_attribute_category;
  l_rec.addr_attribute1                  := p_addr_attribute1;
  l_rec.addr_attribute2                  := p_addr_attribute2;
  l_rec.addr_attribute3                  := p_addr_attribute3;
  l_rec.addr_attribute4                  := p_addr_attribute4;
  l_rec.addr_attribute5                  := p_addr_attribute5;
  l_rec.addr_attribute6                  := p_addr_attribute6;
  l_rec.addr_attribute7                  := p_addr_attribute7;
  l_rec.addr_attribute8                  := p_addr_attribute8;
  l_rec.addr_attribute9                  := p_addr_attribute9;
  l_rec.addr_attribute10                 := p_addr_attribute10;
  l_rec.addr_attribute11                 := p_addr_attribute11;
  l_rec.addr_attribute12                 := p_addr_attribute12;
  l_rec.addr_attribute13                 := p_addr_attribute13;
  l_rec.addr_attribute14                 := p_addr_attribute14;
  l_rec.addr_attribute15                 := p_addr_attribute15;
  l_rec.addr_attribute16                 := p_addr_attribute16;
  l_rec.addr_attribute17                 := p_addr_attribute17;
  l_rec.addr_attribute18                 := p_addr_attribute18;
  l_rec.addr_attribute19                 := p_addr_attribute19;
  l_rec.addr_attribute20                 := p_addr_attribute20;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end per_kad_shd;

/
