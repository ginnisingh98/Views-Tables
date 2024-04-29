--------------------------------------------------------
--  DDL for Package Body PQH_RLS_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RLS_SHD" as
/* $Header: pqrlsrhi.pkb 115.21 2004/02/18 12:06:25 srajakum noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rls_shd.';  -- Global package name
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
  If (p_constraint_name = 'PQH_ROLES_PK') Then
    fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PQH_ROLES_UK') Then
    fnd_message.set_name('PAY','HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY','HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.set_token('CONSTRAINT_NAME',p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_role_id                              in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  -- mvankada
  -- Added Developer DF Columns to the cursor C_Sel1
  Cursor C_Sel1 is
    select
       role_id
      ,role_name
      ,role_type_cd
      ,enable_flag
      ,object_version_number
      ,business_group_id
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
    from	pqh_roles
    where
       role_id = p_role_id;
--
  l_fct_ret	boolean;
--
Begin
  --
  If (
      p_role_id is null and p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
        p_role_id
        = pqh_rls_shd.g_old_rec.role_id and p_object_version_number
        = pqh_rls_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pqh_rls_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> pqh_rls_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY','HR_7155_OBJECT_INVALID');
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
  (p_role_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
-- mvanakda
-- Added Developer DF Columns to the Cursor C_Sel1
  Cursor C_Sel1 is
    select
       role_id
      ,role_name
      ,role_type_cd
      ,enable_flag
      ,object_version_number
      ,business_group_id
      ,information_category
      ,information1
      ,information2
      ,information3
      ,information4
      ,information5
      ,information6
      ,information7
      ,information8
      ,information9
      ,information10
      ,information11
      ,information12
      ,information13
      ,information14
      ,information15
      ,information16
      ,information17
      ,information18
      ,information19
      ,information20
      ,information21
      ,information22
      ,information23
      ,information24
      ,information25
      ,information26
      ,information27
      ,information28
      ,information29
      ,information30
    from	pqh_roles
    where
    role_id = p_role_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ROLE_ID'
    ,p_argument_value     => p_role_id
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into pqh_rls_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number
      <> pqh_rls_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY','HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc,10);
  --
  -- We need to trap the ORA LOCK exception
  --
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY','HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME','pqh_roles');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------

-- mvankada
-- Added Developer DF Columns to the function convert_args

Function convert_args
  (p_role_id                      in number
  ,p_role_name                    in varchar2
  ,p_role_type_cd                 in varchar2
  ,p_enable_flag                  in varchar2
  ,p_object_version_number        in number
  ,p_business_group_id            in number
  ,p_information_category         in varchar2
  ,p_information1                 in varchar2
  ,p_information2                 in varchar2
  ,p_information3                 in varchar2
  ,p_information4	          in varchar2
  ,p_information5                 in varchar2
  ,p_information6	          in varchar2
  ,p_information7                 in varchar2
  ,p_information8	          in varchar2
  ,p_information9                 in varchar2
  ,p_information10	          in varchar2
  ,p_information11                in varchar2
  ,p_information12	          in varchar2
  ,p_information13	          in varchar2
  ,p_information14                in varchar2
  ,p_information15	          in varchar2
  ,p_information16                in varchar2
  ,p_information17	          in varchar2
  ,p_information18                in varchar2
  ,p_information19	          in varchar2
  ,p_information20                in varchar2
  ,p_information21                in varchar2
  ,p_information22	          in varchar2
  ,p_information23	          in varchar2
  ,p_information24                in varchar2
  ,p_information25	          in varchar2
  ,p_information26                in varchar2
  ,p_information27	          in varchar2
  ,p_information28                in varchar2
  ,p_information29	          in varchar2
  ,p_information30                in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
    l_rec.role_id                          := p_role_id;
    l_rec.role_name                        := p_role_name;
    l_rec.role_type_cd                     := p_role_type_cd;
    l_rec.enable_flag                      := p_enable_flag;
    l_rec.object_version_number            := p_object_version_number;
    l_rec.business_group_id                := p_business_group_id;

    -- mvankada
    -- For DDF columns

    l_rec.information_category     := p_information_category;
    l_rec.information1	    	   := p_information1;
    l_rec.information2	  	   := p_information2;
    l_rec.information3	 	   := p_information3;
    l_rec.information4	 	   := p_information4;
    l_rec.information5	  	   := p_information5;
    l_rec.information6	  	   := p_information6;
    l_rec.information7	  	   := p_information7;
    l_rec.information8	  	   := p_information8;
    l_rec.information9	  	   := p_information9;
    l_rec.information10	  	   := p_information10;
    l_rec.information11	  	   := p_information11;
    l_rec.information12	  	   := p_information12;
    l_rec.information13	 	   := p_information13;
    l_rec.information14	  	   := p_information14;
    l_rec.information15	 	   := p_information15;
    l_rec.information16	  	   := p_information16;
    l_rec.information17	  	   := p_information17;
    l_rec.information18	 	   := p_information18;
    l_rec.information19	 	   := p_information19;
    l_rec.information20	   	   := p_information20;
    l_rec.information21	 	   := p_information21;
    l_rec.information22	   	   := p_information22;
    l_rec.information23	   	   := p_information23;
    l_rec.information24	  	   := p_information24;
    l_rec.information25	  	   := p_information25;
    l_rec.information26	  	   := p_information26;
    l_rec.information27		   := p_information27;
    l_rec.information28	  	   := p_information28;
    l_rec.information29	  	   := p_information29;
    l_rec.information30	  	   := p_information30;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pqh_rls_shd;

/
