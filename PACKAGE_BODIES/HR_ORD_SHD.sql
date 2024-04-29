--------------------------------------------------------
--  DDL for Package Body HR_ORD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORD_SHD" as
/* $Header: hrordrhi.pkb 115.7 2002/12/04 06:20:03 hjonnala noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ord_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_DE_ORGANIZATION_LINKS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
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
  (p_organization_link_id                 in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       organization_link_id
      ,parent_organization_id
      ,child_organization_id
      ,business_group_id
      ,org_link_information_category
      ,org_link_information1
      ,org_link_information2
      ,org_link_information3
      ,org_link_information4
      ,org_link_information5
      ,org_link_information6
      ,org_link_information7
      ,org_link_information8
      ,org_link_information9
      ,org_link_information10
      ,org_link_information11
      ,org_link_information12
      ,org_link_information13
      ,org_link_information14
      ,org_link_information15
      ,org_link_information16
      ,org_link_information17
      ,org_link_information18
      ,org_link_information19
      ,org_link_information20
      ,org_link_information21
      ,org_link_information22
      ,org_link_information23
      ,org_link_information24
      ,org_link_information25
      ,org_link_information26
      ,org_link_information27
      ,org_link_information28
      ,org_link_information29
      ,org_link_information30
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,object_version_number
      ,org_link_type
    from        hr_de_organization_links
    where       organization_link_id = p_organization_link_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_organization_link_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_organization_link_id
        = hr_ord_shd.g_old_rec.organization_link_id and
        p_object_version_number
        = hr_ord_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_ord_shd.g_old_rec;
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
          <> hr_ord_shd.g_old_rec.object_version_number) Then
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
  (p_organization_link_id                 in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       organization_link_id
      ,parent_organization_id
      ,child_organization_id
      ,business_group_id
      ,org_link_information_category
      ,org_link_information1
      ,org_link_information2
      ,org_link_information3
      ,org_link_information4
      ,org_link_information5
      ,org_link_information6
      ,org_link_information7
      ,org_link_information8
      ,org_link_information9
      ,org_link_information10
      ,org_link_information11
      ,org_link_information12
      ,org_link_information13
      ,org_link_information14
      ,org_link_information15
      ,org_link_information16
      ,org_link_information17
      ,org_link_information18
      ,org_link_information19
      ,org_link_information20
      ,org_link_information21
      ,org_link_information22
      ,org_link_information23
      ,org_link_information24
      ,org_link_information25
      ,org_link_information26
      ,org_link_information27
      ,org_link_information28
      ,org_link_information29
      ,org_link_information30
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,object_version_number
      ,org_link_type
    from        hr_de_organization_links
    where       organization_link_id = p_organization_link_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ORGANIZATION_LINK_ID'
    ,p_argument_value     => p_organization_link_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_ord_shd.g_old_rec;
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
      <> hr_ord_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_de_organization_links');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_organization_link_id           in number
  ,p_parent_organization_id         in number
  ,p_child_organization_id          in number
  ,p_business_group_id              in number
  ,p_org_link_information_categor   in varchar2
  ,p_org_link_information1          in varchar2
  ,p_org_link_information2          in varchar2
  ,p_org_link_information3          in varchar2
  ,p_org_link_information4          in varchar2
  ,p_org_link_information5          in varchar2
  ,p_org_link_information6          in varchar2
  ,p_org_link_information7          in varchar2
  ,p_org_link_information8          in varchar2
  ,p_org_link_information9          in varchar2
  ,p_org_link_information10         in varchar2
  ,p_org_link_information11         in varchar2
  ,p_org_link_information12         in varchar2
  ,p_org_link_information13         in varchar2
  ,p_org_link_information14         in varchar2
  ,p_org_link_information15         in varchar2
  ,p_org_link_information16         in varchar2
  ,p_org_link_information17         in varchar2
  ,p_org_link_information18         in varchar2
  ,p_org_link_information19         in varchar2
  ,p_org_link_information20         in varchar2
  ,p_org_link_information21         in varchar2
  ,p_org_link_information22         in varchar2
  ,p_org_link_information23         in varchar2
  ,p_org_link_information24         in varchar2
  ,p_org_link_information25         in varchar2
  ,p_org_link_information26         in varchar2
  ,p_org_link_information27         in varchar2
  ,p_org_link_information28         in varchar2
  ,p_org_link_information29         in varchar2
  ,p_org_link_information30         in varchar2
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_attribute21                    in varchar2
  ,p_attribute22                    in varchar2
  ,p_attribute23                    in varchar2
  ,p_attribute24                    in varchar2
  ,p_attribute25                    in varchar2
  ,p_attribute26                    in varchar2
  ,p_attribute27                    in varchar2
  ,p_attribute28                    in varchar2
  ,p_attribute29                    in varchar2
  ,p_attribute30                    in varchar2
  ,p_object_version_number          in number
  ,p_org_link_type                  in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.organization_link_id             := p_organization_link_id;
  l_rec.parent_organization_id           := p_parent_organization_id;
  l_rec.child_organization_id            := p_child_organization_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.org_link_information_category    := p_org_link_information_categor;
  l_rec.org_link_information1            := p_org_link_information1;
  l_rec.org_link_information2            := p_org_link_information2;
  l_rec.org_link_information3            := p_org_link_information3;
  l_rec.org_link_information4            := p_org_link_information4;
  l_rec.org_link_information5            := p_org_link_information5;
  l_rec.org_link_information6            := p_org_link_information6;
  l_rec.org_link_information7            := p_org_link_information7;
  l_rec.org_link_information8            := p_org_link_information8;
  l_rec.org_link_information9            := p_org_link_information9;
  l_rec.org_link_information10           := p_org_link_information10;
  l_rec.org_link_information11           := p_org_link_information11;
  l_rec.org_link_information12           := p_org_link_information12;
  l_rec.org_link_information13           := p_org_link_information13;
  l_rec.org_link_information14           := p_org_link_information14;
  l_rec.org_link_information15           := p_org_link_information15;
  l_rec.org_link_information16           := p_org_link_information16;
  l_rec.org_link_information17           := p_org_link_information17;
  l_rec.org_link_information18           := p_org_link_information18;
  l_rec.org_link_information19           := p_org_link_information19;
  l_rec.org_link_information20           := p_org_link_information20;
  l_rec.org_link_information21           := p_org_link_information21;
  l_rec.org_link_information22           := p_org_link_information22;
  l_rec.org_link_information23           := p_org_link_information23;
  l_rec.org_link_information24           := p_org_link_information24;
  l_rec.org_link_information25           := p_org_link_information25;
  l_rec.org_link_information26           := p_org_link_information26;
  l_rec.org_link_information27           := p_org_link_information27;
  l_rec.org_link_information28           := p_org_link_information28;
  l_rec.org_link_information29           := p_org_link_information29;
  l_rec.org_link_information30           := p_org_link_information30;
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
  l_rec.object_version_number            := p_object_version_number;
  l_rec.org_link_type                    := p_org_link_type;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end hr_ord_shd;

/
