--------------------------------------------------------
--  DDL for Package Body PER_ADD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ADD_SHD" as
/* $Header: peaddrhi.pkb 120.1.12010000.6 2009/04/13 08:33:06 sgundoju ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_add_shd.';  -- Global package name
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
  (p_constraint_name in all_constraints.constraint_name%TYPE
  )
Is
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
        derived_locale,
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
	add_information13,
	add_information14,
	add_information15,
	add_information16,
	add_information17,
	add_information18,
	add_information19,
	add_information20,
	object_version_number,
	party_id,            -- HR/TCA merge
	geometry
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
        derived_locale,
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
	add_information13,
	add_information14,
	add_information15,
	add_information16,
	add_information17,
	add_information18,
	add_information19,
	add_information20,
	object_version_number,
	party_id,             -- HR/TCA merge
	geometry
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
	p_add_information13             in varchar2,
	p_add_information14             in varchar2,
	p_add_information15             in varchar2,
	p_add_information16             in varchar2,
	p_add_information17             in varchar2,
	p_add_information18             in varchar2,
	p_add_information19             in varchar2,
	p_add_information20             in varchar2,
	p_object_version_number         in number,
	p_party_id                      in number default null -- HR/TCA merge
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
  l_rec.add_information13                := p_add_information13;
  l_rec.add_information14                := p_add_information14;
  l_rec.add_information15                := p_add_information15;
  l_rec.add_information16                := p_add_information16;
  l_rec.add_information17                := p_add_information17;
  l_rec.add_information18                := p_add_information18;
  l_rec.add_information19                := p_add_information19;
  l_rec.add_information20                := p_add_information20;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.party_id                         := p_party_id; -- HR/TCA merge
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< derive_locale >-----------------------------|
-- ----------------------------------------------------------------------------
procedure derive_locale(p_rec in out nocopy per_add_shd.g_rec_type)
is
--
  l_number_table dbms_describe.number_table;
  l_varchar_table dbms_describe.varchar2_table;
  l_package_exists boolean;
  l_package_name varchar2(2000);
  l_seperator varchar2(1);
--
begin
  BEGIN
    l_package_name := 'HR_'||substr(p_rec.style,1,2)||'_UTILITY.DERIVE_PER_ADD_ADDRESS';
      -- Package name will be derived using the first 2 characters of the style
      -- bug# 2803638
    hr_general.describe_procedure(
                 object_name   => l_package_name,
                 reserved1     => null,
                 reserved2     => null,
                 overload      => l_number_table,
                 position      => l_number_table,
                 level         => l_number_table,
                 argument_name => l_varchar_table,
                 datatype      => l_number_table,
                 default_value => l_number_table,
                 in_out        => l_number_table,
                 length        => l_number_table,
                 precision     => l_number_table,
                 scale         => l_number_table,
                 radix         => l_number_table,
                 spare         => l_number_table
                );
    -- If no exception raised at this point, then ready to concatenate address
    -- fields using legislative package.
    l_package_exists := true;
    EXCEPTION
      when others then
      -- Package doesn't exist.
      l_package_exists := false;
  END;
  IF l_package_exists THEN
    l_package_name := 'begin ' ||l_package_name ||
                            '(:style, '||
                             ':address_line1,'||
                             ':address_line2,'||
                             ':address_line3,'||
                             ':country,'||
                             ':date_to,'||
                             ':postal_code,'||
                             ':region_1,'||
                             ':region_2,'||
                             ':region_3,'||
                             ':telephone_number_1,'||
                             ':telephone_number_2,'||
                             ':telephone_number_3,'||
                             ':town_or_city,'||
                             ':addr_attribute_category,'||
                             ':addr_attribute1,'||
                             ':addr_attribute2,'||
                             ':addr_attribute3,'||
                             ':addr_attribute4,'||
                             ':addr_attribute5,'||
                             ':addr_attribute6,'||
                             ':addr_attribute7,'||
                             ':addr_attribute8,'||
                             ':addr_attribute9,'||
                             ':addr_attribute10,'||
                             ':addr_attribute11,'||
                             ':addr_attribute12,'||
                             ':addr_attribute13,'||
                             ':addr_attribute14,'||
                             ':addr_attribute15,'||
                             ':addr_attribute16,'||
                             ':addr_attribute17,'||
                             ':addr_attribute18,'||
                             ':addr_attribute19,'||
                             ':addr_attribute20,'||
                             ':add_information13,'||
                             ':add_information14,'||
                             ':add_information15,'||
                             ':add_information16,'||
                             ':add_information17,'||
                             ':add_information18,'||
                             ':add_information19,'||
                             ':add_information20,'||
                             ':derived_locale); '||
                             'end;';
     execute immediate l_package_name
                     using in  p_rec.style,
                           in  p_rec.address_line1,
                           in  p_rec.address_line2,
                           in  p_rec.address_line3,
                           in  p_rec.country,
                           in  p_rec.date_to,
                           in  p_rec.postal_code,
                           in  p_rec.region_1,
                           in  p_rec.region_2,
                           in  p_rec.region_3,
                           in  p_rec.telephone_number_1,
                           in  p_rec.telephone_number_2,
                           in  p_rec.telephone_number_3,
                           in  p_rec.town_or_city,
                           in  p_rec.addr_attribute_category,
                           in  p_rec.addr_attribute1,
                           in  p_rec.addr_attribute2,
                           in  p_rec.addr_attribute3,
                           in  p_rec.addr_attribute4,
                           in  p_rec.addr_attribute5,
                           in  p_rec.addr_attribute6,
                           in  p_rec.addr_attribute7,
                           in  p_rec.addr_attribute8,
                           in  p_rec.addr_attribute9,
                           in  p_rec.addr_attribute10,
                           in  p_rec.addr_attribute11,
                           in  p_rec.addr_attribute12,
                           in  p_rec.addr_attribute13,
                           in  p_rec.addr_attribute14,
                           in  p_rec.addr_attribute15,
                           in  p_rec.addr_attribute16,
                           in  p_rec.addr_attribute17,
                           in  p_rec.addr_attribute18,
                           in  p_rec.addr_attribute19,
                           in  p_rec.addr_attribute20,
                           in  p_rec.add_information13,
                           in  p_rec.add_information14,
                           in  p_rec.add_information15,
                           in  p_rec.add_information16,
                           in  p_rec.add_information17,
                           in  p_rec.add_information18,
                           in  p_rec.add_information19,
                           in  p_rec.add_information20,
                           out p_rec.derived_locale;
  ELSE
    if (ltrim(p_rec.town_or_city) is null) OR
       (ltrim(p_rec.country) is null) then
      l_seperator := '';
    else
      l_seperator := ',';
    end if;
    p_rec.derived_locale := ltrim(p_rec.town_or_city) || l_seperator || ltrim(p_rec.country);
  END IF;
end;


--
end per_add_shd;

/
