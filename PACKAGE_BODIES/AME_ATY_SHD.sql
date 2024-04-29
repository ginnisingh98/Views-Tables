--------------------------------------------------------
--  DDL for Package Body AME_ATY_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ATY_SHD" as
/* $Header: amatyrhi.pkb 120.4 2005/11/22 03:14 santosin noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_aty_shd.';  -- Global package name
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
  If (p_constraint_name = 'AME_ACTION_TYPES_PK') Then
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
  ,p_action_type_id                   in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     action_type_id
    ,name
    ,procedure_name
    ,start_date
    ,end_date
    ,description
    ,security_group_id
    ,dynamic_description
    ,description_query
    ,object_version_number
    from        ame_action_types
    where       action_type_id = p_action_type_id
    and         p_effective_date
    between start_date and nvl(end_date - (ame_util.oneSecond), sysdate);
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_action_type_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_action_type_id =
        ame_aty_shd.g_old_rec.action_type_id and
        p_object_version_number =
        ame_aty_shd.g_old_rec.object_version_number
) Then
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
      Fetch C_Sel1 Into ame_aty_shd.g_old_rec;
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
          <> ame_aty_shd.g_old_rec.object_version_number) Then
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
-- |-----------------------< upd_end_date >-------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_end_date
  (p_effective_date                   in date
  ,p_action_type_id                   in number
  ,p_new_end_date                     in date
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ,p_object_version_number            out nocopy number
  ) is
--
  l_proc                  varchar2(72) := g_package||'upd_end_date';
  l_current_user_id       integer;
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    ame_aty_shd.get_object_version_number
      (p_action_type_id =>  p_action_type_id
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_current_user_id := fnd_global.user_id;
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update ame_action_types t
     set t.end_date              = p_new_end_date
        ,t.last_updated_by       = l_current_user_id
        ,t.last_update_date      = p_new_end_date
        ,t.last_update_login     = l_current_user_id
        ,t.object_version_number = l_object_version_number
   where t.action_type_id = p_action_type_id
     and p_effective_date between t.start_date
          and nvl(t.end_date - ame_util.oneSecond,sysdate);
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
  ,p_action_type_id                   in number
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
     action_type_id
    ,name
    ,procedure_name
    ,start_date
    ,end_date
    ,description
    ,security_group_id
    ,dynamic_description
    ,description_query
    ,object_version_number
    from    ame_action_types
    where   action_type_id = p_action_type_id
    and     p_effective_date
    between start_date and nvl(end_date - ame_util.oneSecond, sysdate)
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
                            ,p_argument       => 'action_type_id'
                            ,p_argument_value => p_action_type_id
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
    Fetch C_Sel1 Into ame_aty_shd.g_old_rec;
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
          <> ame_aty_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    /*dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'ame_action_types'
      ,p_base_key_column         => 'action_type_id'
      ,p_base_key_value          => p_action_type_id
      ,p_child_table_name1       => 'ame_actions'
      ,p_child_key_column1       => 'action_type_id'
      ,p_child_alt_base_key_column1       => 'EDIT HERE: Add base key column for
 child table'
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );*/
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
--  p_validation_start_date := l_validation_start_date;
--  p_validation_end_date   := l_validation_end_date;
-- MURTHY_CHANGES
  if (p_datetrack_mode = hr_api.g_update) then
    p_validation_start_date := p_effective_date;
    p_validation_end_date   := ame_aty_shd.g_old_rec.end_date;
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
    fnd_message.set_token('TABLE_NAME', 'ame_action_types');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_action_type_id                 in number
  ,p_name                           in varchar2
  ,p_procedure_name                 in varchar2
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_description                    in varchar2
  ,p_security_group_id              in number
  ,p_dynamic_description            in varchar2
  ,p_description_query              in varchar2
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
  l_rec.action_type_id                   := p_action_type_id;
  l_rec.name                             := p_name;
  l_rec.procedure_name                   := p_procedure_name;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.description                      := p_description;
  l_rec.security_group_id                := p_security_group_id;
  l_rec.dynamic_description              := p_dynamic_description;
  l_rec.description_query                := p_description_query;
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
  (p_action_type_id  in  number
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
    from ame_action_types t
   where t.action_type_id = p_action_type_id;
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
  (p_action_type_id  in  number
   ,p_start_date       in date
   ,p_end_date         in date
  ) is
--
    Cursor C_Sel1 is
      select count(*)
        from ame_actions
       where action_type_id = p_action_type_id and
         p_start_date between start_date and
           nvl(end_date - ame_util.oneSecond, p_start_date);
--
    Cursor C_Sel2 is
      select count(*)
        from ame_action_type_usages
       where action_type_id = p_action_type_id and
         p_start_date between start_date and
           nvl(end_date - ame_util.oneSecond, p_start_date);
--
    Cursor C_Sel3 is
      select count(*)
        from ame_approver_type_usages
       where action_type_id = p_action_type_id and
         p_start_date between start_date and
           nvl(end_date - ame_util.oneSecond, p_start_date);
--
    Cursor C_Sel4 is
      select count(*)
        from ame_mandatory_attributes
       where action_type_id = p_action_type_id and
         p_start_date between start_date and
           nvl(end_date - ame_util.oneSecond, p_start_date);
--
    Cursor C_Sel5 is
      select count(*)
        from ame_action_type_config
       where action_type_id = p_action_type_id and
         p_start_date between start_date and
           nvl(end_date - ame_util.oneSecond, p_start_date);
  l_child_count integer;
--
Begin
  --
  --
  -- ame_actions
  Open C_Sel1;
  Fetch C_Sel1 into l_child_count;
  Close C_Sel1;
  If l_child_count > 0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_actions');
    hr_multi_message.add;
  End If;
  -- ame_action_type_usages
  Open C_Sel2;
  Fetch C_Sel2 into l_child_count;
  Close C_Sel2;
  If l_child_count > 0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_action_type_usages');
    hr_multi_message.add;
  End If;
  -- ame_approver_type_usages
  Open C_Sel3;
  Fetch C_Sel3 into l_child_count;
  Close C_Sel3;
  If l_child_count > 0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_approver_type_usages');
    hr_multi_message.add;
  End If;
-- ame_mandatory_attributes
  Open C_Sel4;
  Fetch C_Sel4 into l_child_count;
  Close C_Sel4;
  If l_child_count > 0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_mandatory_attributes');
    hr_multi_message.add;
  End If;
-- ame_action_type_config
  Open C_Sel5;
  Fetch C_Sel5 into l_child_count;
  Close C_Sel5;
  If l_child_count > 0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_action_type_config');
    hr_multi_message.add;
  End If;
--
End child_rows_exist;
--
end ame_aty_shd;

/
