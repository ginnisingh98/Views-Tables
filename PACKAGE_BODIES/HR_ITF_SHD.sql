--------------------------------------------------------
--  DDL for Package Body HR_ITF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITF_SHD" as
/* $Header: hritfrhi.pkb 120.0 2005/05/31 00:58:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_itf_shd.';  -- Global package name
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
  If (p_constraint_name = 'HR_KI_USER_INTERFACES_PK') Then
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
  (p_user_interface_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       user_interface_id
      ,user_interface_key
      ,type
      ,form_name
      ,page_region_code
      ,region_code
      ,object_version_number
    from        hr_ki_user_interfaces
    where       user_interface_id = p_user_interface_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_user_interface_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_user_interface_id
        = hr_itf_shd.g_old_rec.user_interface_id and
        p_object_version_number
        = hr_itf_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into hr_itf_shd.g_old_rec;
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
          <> hr_itf_shd.g_old_rec.object_version_number) Then
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
  (p_user_interface_id                    in     number
  ,p_object_version_number                in     number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
       user_interface_id
      ,user_interface_key
      ,type
      ,form_name
      ,page_region_code
      ,region_code
      ,object_version_number
    from        hr_ki_user_interfaces
    where       user_interface_id = p_user_interface_id
    for update nowait;
--
  l_proc        varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'USER_INTERFACE_ID'
    ,p_argument_value     => p_user_interface_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into hr_itf_shd.g_old_rec;
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
      <> hr_itf_shd.g_old_rec.object_version_number) Then
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
    fnd_message.set_token('TABLE_NAME', 'hr_ki_user_interfaces');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_user_interface_id              in number
  ,p_user_interface_key             in varchar2
  ,p_type                           in varchar2
  ,p_form_name                      in varchar2
  ,p_page_region_code               in varchar2
  ,p_region_code                    in varchar2
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
  l_rec.user_interface_id                := p_user_interface_id;
  l_rec.user_interface_key               := p_user_interface_key;
  l_rec.type                             := p_type;
  l_rec.form_name                        := p_form_name;
  l_rec.page_region_code                 := p_page_region_code;
  l_rec.region_code                      := p_region_code;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
-- ----------------------------------------------------------------------------
-- --------------------< CONSTRUCT_USER_INTERFACE_KEY>-------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure derives the user_interface key.
--         if type = form -> type + :: + form_name
--        if type = self service / portal -> type + :: + page_region_code +
--        :: + region_code
--
-- Pre Conditions:
--   g_rec has been populated with details of the values
--   from the ins or the upd procedures
--
-- In Arguments:
--  p_type ,p_form_name
--  p_page_region_code , p_region_code
--
--  Out
--  p_user_interface_key
--
-- Post Success:
--   Processing continues by returning key.
--
-- Post Failure:
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure construct_user_interface_key
(
   p_type               in varchar2
  ,p_form_name          in varchar2
  ,p_page_region_code   in varchar2
  ,p_region_code        in varchar2
  ,p_user_interface_key out nocopy varchar2
)
is
  --
  -- Declare cursors and local variables
  --
  l_key_total_length    number := 150;
  --
  -- Variables for API Boolean parameters
  --
  l_proc            varchar2(72) := g_package ||'construct_user_interface_key';
  l_found           varchar2(10);
  l_form_const  varchar2(5) := 'PUI';
  l_ss_const  varchar2(5) := 'SS';
  l_portal_const  varchar2(5) := 'P';


  Begin
    hr_utility.set_location(' Entering:' || l_proc,10);

  if (p_type=l_form_const) then

    p_user_interface_key := p_type || '::' || p_form_name;

  elsif ((p_type=l_ss_const or p_type=l_portal_const) and p_region_code is null) then

    p_user_interface_key := p_type || '::' ||
                              substr(p_page_region_code
                                    ,1
                                    ,l_key_total_length - length(p_type) - 2
                                    );

  else
   p_user_interface_key :=
     p_type || '::' ||
     substr(p_page_region_code
           ,1
           ,l_key_total_length - length(p_type) - length(p_region_code) - 4
           ) || '::'||
           p_region_code;
   end if;


  --
    hr_utility.set_location(' Leaving:' || l_proc,20);

End construct_user_interface_key ;
--
end hr_itf_shd;

/
