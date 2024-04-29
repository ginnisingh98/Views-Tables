--------------------------------------------------------
--  DDL for Package Body PER_CNL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNL_SHD" as
/* $Header: pecnlrhi.pkb 120.0 2005/05/31 06:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_cnl_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_RI_CONFIG_LOCATIONS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_location_id                          in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       configuration_code
      ,configuration_context
      ,location_id
      ,location_code
      ,description
      ,style
      ,address_line_1
      ,address_line_2
      ,address_line_3
      ,town_or_city
      ,country
      ,postal_code
      ,region_1
      ,region_2
      ,region_3
      ,telephone_number_1
      ,telephone_number_2
      ,telephone_number_3
      ,loc_information13
      ,loc_information14
      ,loc_information15
      ,loc_information16
      ,loc_information17
      ,loc_information18
      ,loc_information19
      ,loc_information20
      ,object_version_number
    from        per_ri_config_locations
    where       location_id = p_location_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_location_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_location_id
        = per_cnl_shd.g_old_rec.location_id and
        p_object_version_number
        = per_cnl_shd.g_old_rec.object_version_number
       ) Then
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
      Fetch C_Sel1 Into per_cnl_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> per_cnl_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_location_id                          in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       configuration_code
      ,configuration_context
      ,location_id
      ,location_code
      ,description
      ,style
      ,address_line_1
      ,address_line_2
      ,address_line_3
      ,town_or_city
      ,country
      ,postal_code
      ,region_1
      ,region_2
      ,region_3
      ,telephone_number_1
      ,telephone_number_2
      ,telephone_number_3
      ,loc_information13
      ,loc_information14
      ,loc_information15
      ,loc_information16
      ,loc_information17
      ,loc_information18
      ,loc_information19
      ,loc_information20
      ,object_version_number
    from        per_ri_config_locations
    where       location_id = p_location_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'LOCATION_ID'
    ,p_argument_value     => p_location_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_cnl_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> per_cnl_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'per_ri_config_locations');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_configuration_code             in varchar2
  ,p_configuration_context          in varchar2
  ,p_location_id                    in number
  ,p_location_code                  in varchar2
  ,p_description                    in varchar2
  ,p_style                          in varchar2
  ,p_address_line_1                 in varchar2
  ,p_address_line_2                 in varchar2
  ,p_address_line_3                 in varchar2
  ,p_town_or_city                   in varchar2
  ,p_country                        in varchar2
  ,p_postal_code                    in varchar2
  ,p_region_1                       in varchar2
  ,p_region_2                       in varchar2
  ,p_region_3                       in varchar2
  ,p_telephone_number_1             in varchar2
  ,p_telephone_number_2             in varchar2
  ,p_telephone_number_3             in varchar2
  ,p_loc_information13              in varchar2
  ,p_loc_information14              in varchar2
  ,p_loc_information15              in varchar2
  ,p_loc_information16              in varchar2
  ,p_loc_information17              in varchar2
  ,p_loc_information18              in varchar2
  ,p_loc_information19              in varchar2
  ,p_loc_information20              in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.configuration_code               := p_configuration_code;
  l_rec.configuration_context            := p_configuration_context;
  l_rec.location_id                      := p_location_id;
  l_rec.location_code                    := p_location_code;
  l_rec.description                      := p_description;
  l_rec.style                            := p_style;
  l_rec.address_line_1                   := p_address_line_1;
  l_rec.address_line_2                   := p_address_line_2;
  l_rec.address_line_3                   := p_address_line_3;
  l_rec.town_or_city                     := p_town_or_city;
  l_rec.country                          := p_country;
  l_rec.postal_code                      := p_postal_code;
  l_rec.region_1                         := p_region_1;
  l_rec.region_2                         := p_region_2;
  l_rec.region_3                         := p_region_3;
  l_rec.telephone_number_1               := p_telephone_number_1;
  l_rec.telephone_number_2               := p_telephone_number_2;
  l_rec.telephone_number_3               := p_telephone_number_3;
  l_rec.loc_information13                := p_loc_information13;
  l_rec.loc_information14                := p_loc_information14;
  l_rec.loc_information15                := p_loc_information15;
  l_rec.loc_information16                := p_loc_information16;
  l_rec.loc_information17                := p_loc_information17;
  l_rec.loc_information18                := p_loc_information18;
  l_rec.loc_information19                := p_loc_information19;
  l_rec.loc_information20                := p_loc_information20;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_cnl_shd;

/
