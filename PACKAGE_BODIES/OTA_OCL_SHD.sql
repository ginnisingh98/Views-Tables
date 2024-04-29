--------------------------------------------------------
--  DDL for Package Body OTA_OCL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OCL_SHD" as
/* $Header: otoclrhi.pkb 120.1.12000000.2 2007/02/07 09:19:37 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_ocl_shd.';  -- Global package name
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
  If (p_constraint_name = 'OTA_COMPETENCE_LANGUAGES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'OTA_COMPETENCE_LANGUAGES_UK') Then
    fnd_message.set_name('OTA','OTA_OCL_MAPPING_EXISTS');
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
  (p_competence_language_id               in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       competence_language_id
      ,competence_id
      ,language_code
      ,min_proficiency_level_id
      ,business_group_id
      ,object_version_number
      ,ocl_information_category
      ,ocl_information1
      ,ocl_information2
      ,ocl_information3
      ,ocl_information4
      ,ocl_information5
      ,ocl_information6
      ,ocl_information7
      ,ocl_information8
      ,ocl_information9
      ,ocl_information10
      ,ocl_information11
      ,ocl_information12
      ,ocl_information13
      ,ocl_information14
      ,ocl_information15
      ,ocl_information16
      ,ocl_information17
      ,ocl_information18
      ,ocl_information19
      ,ocl_information20
    from	ota_competence_languages
    where	competence_language_id = p_competence_language_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (p_competence_language_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_competence_language_id
        = ota_ocl_shd.g_old_rec.competence_language_id and
        p_object_version_number
        = ota_ocl_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ota_ocl_shd.g_old_rec;
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
          <> ota_ocl_shd.g_old_rec.object_version_number) Then
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
  (p_competence_language_id               in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       competence_language_id
      ,competence_id
      ,language_code
      ,min_proficiency_level_id
      ,business_group_id
      ,object_version_number
      ,ocl_information_category
      ,ocl_information1
      ,ocl_information2
      ,ocl_information3
      ,ocl_information4
      ,ocl_information5
      ,ocl_information6
      ,ocl_information7
      ,ocl_information8
      ,ocl_information9
      ,ocl_information10
      ,ocl_information11
      ,ocl_information12
      ,ocl_information13
      ,ocl_information14
      ,ocl_information15
      ,ocl_information16
      ,ocl_information17
      ,ocl_information18
      ,ocl_information19
      ,ocl_information20
    from	ota_competence_languages
    where	competence_language_id = p_competence_language_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'COMPETENCE_LANGUAGE_ID'
    ,p_argument_value     => p_competence_language_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into ota_ocl_shd.g_old_rec;
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
      <> ota_ocl_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'ota_competence_languages');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_competence_language_id         in number
  ,p_competence_id                  in number
  ,p_language_code                    in varchar2
  ,p_min_proficiency_level_id       in number
  ,p_business_group_id              in number
  ,p_object_version_number          in number
  ,p_ocl_information_category       in varchar2
  ,p_ocl_information1               in varchar2
  ,p_ocl_information2               in varchar2
  ,p_ocl_information3               in varchar2
  ,p_ocl_information4               in varchar2
  ,p_ocl_information5               in varchar2
  ,p_ocl_information6               in varchar2
  ,p_ocl_information7               in varchar2
  ,p_ocl_information8               in varchar2
  ,p_ocl_information9               in varchar2
  ,p_ocl_information10              in varchar2
  ,p_ocl_information11              in varchar2
  ,p_ocl_information12              in varchar2
  ,p_ocl_information13              in varchar2
  ,p_ocl_information14              in varchar2
  ,p_ocl_information15              in varchar2
  ,p_ocl_information16              in varchar2
  ,p_ocl_information17              in varchar2
  ,p_ocl_information18              in varchar2
  ,p_ocl_information19              in varchar2
  ,p_ocl_information20              in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.competence_language_id           := p_competence_language_id;
  l_rec.competence_id                    := p_competence_id;
  l_rec.language_code                      := p_language_code;
  l_rec.min_proficiency_level_id         := p_min_proficiency_level_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.ocl_information_category         := p_ocl_information_category;
  l_rec.ocl_information1                 := p_ocl_information1;
  l_rec.ocl_information2                 := p_ocl_information2;
  l_rec.ocl_information3                 := p_ocl_information3;
  l_rec.ocl_information4                 := p_ocl_information4;
  l_rec.ocl_information5                 := p_ocl_information5;
  l_rec.ocl_information6                 := p_ocl_information6;
  l_rec.ocl_information7                 := p_ocl_information7;
  l_rec.ocl_information8                 := p_ocl_information8;
  l_rec.ocl_information9                 := p_ocl_information9;
  l_rec.ocl_information10                := p_ocl_information10;
  l_rec.ocl_information11                := p_ocl_information11;
  l_rec.ocl_information12                := p_ocl_information12;
  l_rec.ocl_information13                := p_ocl_information13;
  l_rec.ocl_information14                := p_ocl_information14;
  l_rec.ocl_information15                := p_ocl_information15;
  l_rec.ocl_information16                := p_ocl_information16;
  l_rec.ocl_information17                := p_ocl_information17;
  l_rec.ocl_information18                := p_ocl_information18;
  l_rec.ocl_information19                := p_ocl_information19;
  l_rec.ocl_information20                := p_ocl_information20;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end ota_ocl_shd;

/
