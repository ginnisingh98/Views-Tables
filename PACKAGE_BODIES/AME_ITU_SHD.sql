--------------------------------------------------------
--  DDL for Package Body AME_ITU_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITU_SHD" as
/* $Header: amiturhi.pkb 120.6 2006/10/05 16:11:40 pvelugul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_itu_shd.';  -- Global package name
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
  If (p_constraint_name = 'AME_ITEM_CLASS_USAGES_PK') Then
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
  ,p_application_id                   in number
  ,p_item_class_id                    in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     application_id
    ,item_class_id
    ,item_id_query
    ,item_class_order_number
    ,item_class_par_mode
    ,item_class_sublist_mode
    ,start_date
    ,end_date
    ,object_version_number
    from  ame_item_class_usages
    where item_class_id = p_item_class_id
     and  application_id = p_application_id
     and  p_effective_date
            between start_date and nvl(end_date - (1/86400),p_effective_date);
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date         is null or
      p_item_class_id          is null or
      p_application_id         is null or
      p_object_version_number  is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_item_class_id =
        ame_itu_shd.g_old_rec.item_class_id and
        p_application_id =
        ame_itu_shd.g_old_rec.application_id and
        p_object_version_number =
        ame_itu_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into ame_itu_shd.g_old_rec;
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
          <> ame_itu_shd.g_old_rec.object_version_number) Then
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
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
  (p_effective_date                   in date
  ,p_application_id                   in number
  ,p_item_class_id                    in number
  ,p_new_effective_end_date           in date
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ,p_object_version_number            out nocopy number
  ) is
--
  l_proc                  varchar2(72) := g_package||'upd_effective_end_date';
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
    ame_itu_shd.get_object_version_number
      (p_item_class_id =>  p_item_class_id
      ,p_application_id =>  p_application_id
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_current_user_id := fnd_global.user_id;
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update ame_item_class_usages t
     set t.end_date              = p_new_effective_end_date
        ,t.last_updated_by       = l_current_user_id
        ,t.last_update_date      = p_new_effective_end_date
        ,t.last_update_login     = l_current_user_id
        ,t.object_version_number = l_object_version_number
   where t.item_class_id = p_item_class_id
     and t.application_id = p_application_id
     and p_effective_date between t.start_date
          and nvl(t.end_date - (1/86400),sysdate);
  --
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_application_id                   in number
  ,p_item_class_id                    in number
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
     application_id
    ,item_class_id
    ,item_id_query
    ,item_class_order_number
    ,item_class_par_mode
    ,item_class_sublist_mode
    ,start_date
    ,end_date
    ,object_version_number
    from    ame_item_class_usages
    where   item_class_id = p_item_class_id
 and    application_id = p_application_id
    and     p_effective_date
    between start_date and nvl(end_date - (1/86400), sysdate)
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
                            ,p_argument       => 'item_class_id'
                            ,p_argument_value => p_item_class_id
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
    Fetch C_Sel1 Into ame_itu_shd.g_old_rec;
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
          <> ame_itu_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
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
    p_validation_end_date   := ame_itu_shd.g_old_rec.end_date;
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
    fnd_message.set_token('TABLE_NAME', 'ame_item_class_usages');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_application_id                 in number
  ,p_item_class_id                  in number
  ,p_item_id_query                  in varchar2
  ,p_item_class_order_number        in number
  ,p_item_class_par_mode            in varchar2
  ,p_item_class_sublist_mode        in varchar2
  ,p_start_date                     in date
  ,p_end_date                       in date
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
  l_rec.application_id                   := p_application_id;
  l_rec.item_class_id                    := p_item_class_id;
  l_rec.item_id_query                    := p_item_id_query;
  l_rec.item_class_order_number          := p_item_class_order_number;
  l_rec.item_class_par_mode              := p_item_class_par_mode;
  l_rec.item_class_sublist_mode          := p_item_class_sublist_mode;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
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
  (p_application_id  in  number
  ,p_item_class_id  in  number
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
    from ame_item_class_usages t
   where t.item_class_id = p_item_class_id
 and    t.application_id = p_application_id;
  --
  -- Return the new object_version_number.
  --
  Return(l_ovn);
--
End get_object_version_number;
  --
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< child_rows_exist >-------------------------|
-- ----------------------------------------------------------------------------
Procedure child_rows_exist
  (p_item_class_id     in number
   ,p_application_id   in number
   ,p_start_date       in date
   ,p_end_date         in date
  ) is
--
  cursor csr_in_use_by_attribute_usages is
    select count(*)
      from
        ame_attribute_usages attru,
        ame_attributes attr
    where attru.attribute_id   = attr.attribute_id
      and attru.application_id = p_application_id
      and attr.item_class_id   = p_item_class_id
      and p_start_date BETWEEN attru.start_date
             and nvl(attru.end_date -(1/86400),p_start_date)
      and p_start_date BETWEEN attr.start_date
            and nvl(attr.end_date - (1/86400),p_start_date);
--
  cursor csr_in_use_by_rule_usages is
    select count(*)
      from
        ame_rule_usages rlu,
        ame_rules rl
    where rlu.rule_id      = rl.rule_id
      and rlu.item_id      = p_application_id
      and rl.item_class_id = p_item_class_id
      and ((p_start_date between rl.start_date and nvl(rl.end_date - ame_util.oneSecond, p_start_date)) or
           (p_start_date < rl.start_date and rl.start_date < nvl(rl.end_date,rl.start_date + ame_util.oneSecond)))
      and ((p_start_date between rlu.start_date and nvl(rlu.end_date - ame_util.oneSecond, p_start_date)) or
           (p_start_date < rlu.start_date and rlu.start_date < nvl(rlu.end_date,rlu.start_date + ame_util.oneSecond)));
--
  l_attribute_count integer;
  l_rule_count      integer;
--
Begin
  --
  --
  --
  open  csr_in_use_by_attribute_usages;
  fetch csr_in_use_by_attribute_usages
  into  l_attribute_count;
  close csr_in_use_by_attribute_usages;
  --
  If l_attribute_count > 0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_attribute_usages');
    hr_multi_message.add;
  End If;

  open  csr_in_use_by_rule_usages;
  fetch csr_in_use_by_rule_usages
  into  l_rule_count;
  close csr_in_use_by_rule_usages;
  --
  If l_rule_count > 0 then
    fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME','ame_rule_usages');
    hr_multi_message.add;
  End If;
 --
--
End child_rows_exist;
--
end ame_itu_shd;

/
