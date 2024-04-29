--------------------------------------------------------
--  DDL for Package Body AME_APG_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APG_SHD" as
/* $Header: amapgrhi.pkb 120.6 2006/10/05 16:02:47 pvelugul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_apg_shd.';  -- Global package name
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
  If (p_constraint_name = 'AME_APPROVAL_GROUPS_PK') Then
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
  (p_effective_date                   in date
  ,p_approval_group_id                in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     approval_group_id
    ,name
    ,start_date
    ,end_date
    ,description
    ,query_string
    ,is_static
    ,security_group_id
    ,object_version_number
    from        ame_approval_groups
    where       approval_group_id = p_approval_group_id
    and         p_effective_date
    between     start_date
                  and nvl(end_date -  ame_util.oneSecond,p_effective_date);
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_approval_group_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_approval_group_id =
        ame_apg_shd.g_old_rec.approval_group_id and
        p_object_version_number =
        ame_apg_shd.g_old_rec.object_version_number) Then
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
      Fetch C_Sel1 Into ame_apg_shd.g_old_rec;
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
          <> ame_apg_shd.g_old_rec.object_version_number) Then
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
-- |----------------------------< upd_end_date >------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_end_date
  (p_effective_date                   in date
  ,p_approval_group_id                in number
  ,p_new_end_date                     in date
  ,p_object_version_number            out nocopy number
  ) is
--
  l_proc                  varchar2(72) := g_package||'upd_end_date';
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    ame_apg_shd.get_object_version_number
      (p_approval_group_id =>  p_approval_group_id
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ame_approval_groups t
  set     t.end_date    = p_new_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.approval_group_id = p_approval_group_id
  and     p_effective_date
  between t.start_date and nvl(t.end_date - ame_util.oneSecond,p_effective_date)
;
  --
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End upd_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_approval_group_id                in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_argument              varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     approval_group_id
    ,name
    ,start_date
    ,end_date
    ,description
    ,query_string
    ,is_static
    ,security_group_id
    ,object_version_number
    from    ame_approval_groups
    where   approval_group_id = p_approval_group_id
    and     p_effective_date
    between start_date and nvl(end_date - ame_util.oneSecond, p_effective_date)
    for update nowait;
  --
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'effective_date'
                            ,p_argument_value => p_effective_date
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'datetrack_mode'
                            ,p_argument_value => p_datetrack_mode
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'approval_group_id'
                            ,p_argument_value => p_approval_group_id
                            );
  --
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into ame_apg_shd.g_old_rec;
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
          <> ame_apg_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    --
    --
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  if (p_datetrack_mode = hr_api.g_update) then
    p_validation_start_date := p_effective_date;
    p_validation_end_date   := ame_apg_shd.g_old_rec.end_date;
  elsif (p_datetrack_mode = hr_api.g_delete) then
    p_validation_start_date := p_effective_date;
    p_validation_end_date   := p_effective_date;
  end if;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ame_approval_groups');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_approval_group_id              in number
  ,p_name                           in varchar2
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_description                    in varchar2
  ,p_query_string                   in varchar2
  ,p_is_static                      in varchar2
  ,p_security_group_id              in number
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
  l_rec.approval_group_id                := p_approval_group_id;
  l_rec.name                             := p_name;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.description                      := p_description;
  l_rec.query_string                     := p_query_string;
  l_rec.is_static                        := p_is_static;
  l_rec.security_group_id                := p_security_group_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_object_version_number >----------------------|
-- ----------------------------------------------------------------------------
Function get_object_version_number
  (p_approval_group_id  in  number
  )
  Return number is
--
  l_ovn   number;
--
Begin
  --
  -- get the next ovn
  --
  select nvl(max(t.object_version_number),0) + 1
    into l_ovn
    from ame_approval_groups t
   where t.approval_group_id = p_approval_group_id;
  --
  -- Return the new object_version_number.
  --
  Return(l_ovn);
--
End get_object_version_number;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< child_rows_exist >-------------------------|
-- ----------------------------------------------------------------------------
Procedure child_rows_exist
  (p_  in  number
   ,p_start_date       in date
   ,p_end_date         in date
  ) is
--
    Cursor C_Sel1 is
      select count(*)
        from ame_approval_group_items
       where  approval_group_id = p_
         and p_start_date between start_date and
         nvl(end_date - ame_util.oneSecond, p_start_date);

    Cursor C_Sel2 is
      select count(*)
        from ame_approval_group_config
       where  approval_group_id = p_
         and p_start_date between start_date and
         nvl(end_date - ame_util.oneSecond, p_start_date);
--
--
--
  l_child_count integer;
--
Begin
  --
  --
  --
  Open C_Sel1;
  Fetch C_Sel1 into l_child_count;
  Close C_Sel1;
  If l_child_count >0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_approval_group_items');
         hr_multi_message.add;
  End If;

  Open C_Sel2;
  Fetch C_Sel2 into l_child_count;
  Close C_Sel2;
  If l_child_count >0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_approval_group_config');
         hr_multi_message.add;
  End If;


 --
  --
  --
  --
--
End child_rows_exist;
--
end ame_apg_shd;

/
