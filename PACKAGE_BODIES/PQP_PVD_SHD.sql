--------------------------------------------------------
--  DDL for Package Body PQP_PVD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PVD_SHD" as
/* $Header: pqpvdrhi.pkb 115.6 2003/02/17 22:14:43 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqp_pvd_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PQP_VEHICLE_DETAILS_PK') Then
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
  (p_vehicle_details_id                   in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       vehicle_details_id
      ,vehicle_type
      ,business_group_id
      ,registration_number
      ,make
      ,model
      ,date_first_registered
      ,engine_capacity_in_cc
      ,fuel_type
      ,fuel_card
      ,currency_code
      ,list_price
      ,accessory_value_at_startdate
      ,accessory_value_added_later
--      ,capital_contributions
--      ,private_use_contributions
      ,market_value_classic_car
      ,co2_emissions
      ,vehicle_provider
      ,object_version_number
      ,vehicle_identification_number
      ,vehicle_ownership
      ,vhd_attribute_category
      ,vhd_attribute1
      ,vhd_attribute2
      ,vhd_attribute3
      ,vhd_attribute4
      ,vhd_attribute5
      ,vhd_attribute6
      ,vhd_attribute7
      ,vhd_attribute8
      ,vhd_attribute9
      ,vhd_attribute10
      ,vhd_attribute11
      ,vhd_attribute12
      ,vhd_attribute13
      ,vhd_attribute14
      ,vhd_attribute15
      ,vhd_attribute16
      ,vhd_attribute17
      ,vhd_attribute18
      ,vhd_attribute19
      ,vhd_attribute20
      ,vhd_information_category
      ,vhd_information1
      ,vhd_information2
      ,vhd_information3
      ,vhd_information4
      ,vhd_information5
      ,vhd_information6
      ,vhd_information7
      ,vhd_information8
      ,vhd_information9
      ,vhd_information10
      ,vhd_information11
      ,vhd_information12
      ,vhd_information13
      ,vhd_information14
      ,vhd_information15
      ,vhd_information16
      ,vhd_information17
      ,vhd_information18
      ,vhd_information19
      ,vhd_information20
    from	pqp_vehicle_details
    where	vehicle_details_id = p_vehicle_details_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_vehicle_details_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_vehicle_details_id
        = pqp_pvd_shd.g_old_rec.vehicle_details_id and
        p_object_version_number
        = pqp_pvd_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqp_pvd_shd.g_old_rec;
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
          <> pqp_pvd_shd.g_old_rec.object_version_number) Then
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
  (p_vehicle_details_id                   in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       vehicle_details_id
      ,vehicle_type
      ,business_group_id
      ,registration_number
      ,make
      ,model
      ,date_first_registered
      ,engine_capacity_in_cc
      ,fuel_type
      ,fuel_card
      ,currency_code
      ,list_price
      ,accessory_value_at_startdate
      ,accessory_value_added_later
--      ,capital_contributions
--      ,private_use_contributions
      ,market_value_classic_car
      ,co2_emissions
      ,vehicle_provider
      ,object_version_number
      ,vehicle_identification_number
      ,vehicle_ownership
      ,vhd_attribute_category
      ,vhd_attribute1
      ,vhd_attribute2
      ,vhd_attribute3
      ,vhd_attribute4
      ,vhd_attribute5
      ,vhd_attribute6
      ,vhd_attribute7
      ,vhd_attribute8
      ,vhd_attribute9
      ,vhd_attribute10
      ,vhd_attribute11
      ,vhd_attribute12
      ,vhd_attribute13
      ,vhd_attribute14
      ,vhd_attribute15
      ,vhd_attribute16
      ,vhd_attribute17
      ,vhd_attribute18
      ,vhd_attribute19
      ,vhd_attribute20
      ,vhd_information_category
      ,vhd_information1
      ,vhd_information2
      ,vhd_information3
      ,vhd_information4
      ,vhd_information5
      ,vhd_information6
      ,vhd_information7
      ,vhd_information8
      ,vhd_information9
      ,vhd_information10
      ,vhd_information11
      ,vhd_information12
      ,vhd_information13
      ,vhd_information14
      ,vhd_information15
      ,vhd_information16
      ,vhd_information17
      ,vhd_information18
      ,vhd_information19
      ,vhd_information20
    from	pqp_vehicle_details
    where	vehicle_details_id = p_vehicle_details_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'VEHICLE_DETAILS_ID'
    ,p_argument_value     => p_vehicle_details_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqp_pvd_shd.g_old_rec;
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
      <> pqp_pvd_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'pqp_vehicle_details');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_vehicle_details_id             in number
  ,p_vehicle_type                   in varchar2
  ,p_business_group_id              in number
  ,p_registration_number            in varchar2
  ,p_make                           in varchar2
  ,p_model                          in varchar2
  ,p_date_first_registered          in date
  ,p_engine_capacity_in_cc          in number
  ,p_fuel_type                      in varchar2
  ,p_fuel_card                      in varchar2
  ,p_currency_code                  in varchar2
  ,p_list_price                     in number
  ,p_accessory_value_at_startdate   in number
  ,p_accessory_value_added_later    in number
--  ,p_capital_contributions          in number
--  ,p_private_use_contributions      in number
  ,p_market_value_classic_car       in number
  ,p_co2_emissions                  in number
  ,p_vehicle_provider               in varchar2
  ,p_object_version_number          in number
  ,p_vehicle_identification_numbe   in varchar2
  ,p_vehicle_ownership              in varchar2
  ,p_vhd_attribute_category         in varchar2
  ,p_vhd_attribute1                 in varchar2
  ,p_vhd_attribute2                 in varchar2
  ,p_vhd_attribute3                 in varchar2
  ,p_vhd_attribute4                 in varchar2
  ,p_vhd_attribute5                 in varchar2
  ,p_vhd_attribute6                 in varchar2
  ,p_vhd_attribute7                 in varchar2
  ,p_vhd_attribute8                 in varchar2
  ,p_vhd_attribute9                 in varchar2
  ,p_vhd_attribute10                in varchar2
  ,p_vhd_attribute11                in varchar2
  ,p_vhd_attribute12                in varchar2
  ,p_vhd_attribute13                in varchar2
  ,p_vhd_attribute14                in varchar2
  ,p_vhd_attribute15                in varchar2
  ,p_vhd_attribute16                in varchar2
  ,p_vhd_attribute17                in varchar2
  ,p_vhd_attribute18                in varchar2
  ,p_vhd_attribute19                in varchar2
  ,p_vhd_attribute20                in varchar2
  ,p_vhd_information_category       in varchar2
  ,p_vhd_information1               in varchar2
  ,p_vhd_information2               in varchar2
  ,p_vhd_information3               in varchar2
  ,p_vhd_information4               in varchar2
  ,p_vhd_information5               in varchar2
  ,p_vhd_information6               in varchar2
  ,p_vhd_information7               in varchar2
  ,p_vhd_information8               in varchar2
  ,p_vhd_information9               in varchar2
  ,p_vhd_information10              in varchar2
  ,p_vhd_information11              in varchar2
  ,p_vhd_information12              in varchar2
  ,p_vhd_information13              in varchar2
  ,p_vhd_information14              in varchar2
  ,p_vhd_information15              in varchar2
  ,p_vhd_information16              in varchar2
  ,p_vhd_information17              in varchar2
  ,p_vhd_information18              in varchar2
  ,p_vhd_information19              in varchar2
  ,p_vhd_information20              in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.vehicle_details_id               := p_vehicle_details_id;
  l_rec.vehicle_type                     := p_vehicle_type;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.registration_number              := p_registration_number;
  l_rec.make                             := p_make;
  l_rec.model                            := p_model;
  l_rec.date_first_registered            := p_date_first_registered;
  l_rec.engine_capacity_in_cc            := p_engine_capacity_in_cc;
  l_rec.fuel_type                        := p_fuel_type;
  l_rec.fuel_card                        := p_fuel_card;
  l_rec.currency_code                    := p_currency_code;
  l_rec.list_price                       := p_list_price;
  l_rec.accessory_value_at_startdate     := p_accessory_value_at_startdate;
  l_rec.accessory_value_added_later      := p_accessory_value_added_later;
--  l_rec.capital_contributions            := p_capital_contributions;
--  l_rec.private_use_contributions        := p_private_use_contributions;
  l_rec.market_value_classic_car         := p_market_value_classic_car;
  l_rec.co2_emissions                    := p_co2_emissions;
  l_rec.vehicle_provider                 := p_vehicle_provider;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.vehicle_identification_number    := p_vehicle_identification_numbe;
  l_rec.vehicle_ownership                := p_vehicle_ownership;
  l_rec.vhd_attribute_category           := p_vhd_attribute_category;
  l_rec.vhd_attribute1                   := p_vhd_attribute1;
  l_rec.vhd_attribute2                   := p_vhd_attribute2;
  l_rec.vhd_attribute3                   := p_vhd_attribute3;
  l_rec.vhd_attribute4                   := p_vhd_attribute4;
  l_rec.vhd_attribute5                   := p_vhd_attribute5;
  l_rec.vhd_attribute6                   := p_vhd_attribute6;
  l_rec.vhd_attribute7                   := p_vhd_attribute7;
  l_rec.vhd_attribute8                   := p_vhd_attribute8;
  l_rec.vhd_attribute9                   := p_vhd_attribute9;
  l_rec.vhd_attribute10                  := p_vhd_attribute10;
  l_rec.vhd_attribute11                  := p_vhd_attribute11;
  l_rec.vhd_attribute12                  := p_vhd_attribute12;
  l_rec.vhd_attribute13                  := p_vhd_attribute13;
  l_rec.vhd_attribute14                  := p_vhd_attribute14;
  l_rec.vhd_attribute15                  := p_vhd_attribute15;
  l_rec.vhd_attribute16                  := p_vhd_attribute16;
  l_rec.vhd_attribute17                  := p_vhd_attribute17;
  l_rec.vhd_attribute18                  := p_vhd_attribute18;
  l_rec.vhd_attribute19                  := p_vhd_attribute19;
  l_rec.vhd_attribute20                  := p_vhd_attribute20;
  l_rec.vhd_information_category         := p_vhd_information_category;
  l_rec.vhd_information1                 := p_vhd_information1;
  l_rec.vhd_information2                 := p_vhd_information2;
  l_rec.vhd_information3                 := p_vhd_information3;
  l_rec.vhd_information4                 := p_vhd_information4;
  l_rec.vhd_information5                 := p_vhd_information5;
  l_rec.vhd_information6                 := p_vhd_information6;
  l_rec.vhd_information7                 := p_vhd_information7;
  l_rec.vhd_information8                 := p_vhd_information8;
  l_rec.vhd_information9                 := p_vhd_information9;
  l_rec.vhd_information10                := p_vhd_information10;
  l_rec.vhd_information11                := p_vhd_information11;
  l_rec.vhd_information12                := p_vhd_information12;
  l_rec.vhd_information13                := p_vhd_information13;
  l_rec.vhd_information14                := p_vhd_information14;
  l_rec.vhd_information15                := p_vhd_information15;
  l_rec.vhd_information16                := p_vhd_information16;
  l_rec.vhd_information17                := p_vhd_information17;
  l_rec.vhd_information18                := p_vhd_information18;
  l_rec.vhd_information19                := p_vhd_information19;
  l_rec.vhd_information20                := p_vhd_information20;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqp_pvd_shd;

/
