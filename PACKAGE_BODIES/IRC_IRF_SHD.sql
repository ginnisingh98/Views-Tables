--------------------------------------------------------
--  DDL for Package Body IRC_IRF_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IRF_SHD" as
/* $Header: irirfrhi.pkb 120.1 2008/04/16 07:34:32 vmummidi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_irf_shd.';  -- Global package name
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
  If (p_constraint_name = 'IRC_REFERRAL_INFO_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'IRC_REFERRAL_INFO_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
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
  (p_effective_date                       in     date
  ,p_referral_info_id                     in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	   referral_info_id
       ,object_id
       ,object_type
       ,start_date
       ,end_date
       ,source_type
       ,source_name
       ,source_criteria1
       ,source_value1
       ,source_criteria2
       ,source_value2
       ,source_criteria3
       ,source_value3
       ,source_criteria4
       ,source_value4
       ,source_criteria5
       ,source_value5
       ,source_person_id
       ,candidate_comment
       ,employee_comment
       ,irf_attribute_category
       ,irf_attribute1
       ,irf_attribute2
       ,irf_attribute3
       ,irf_attribute4
       ,irf_attribute5
       ,irf_attribute6
       ,irf_attribute7
       ,irf_attribute8
       ,irf_attribute9
       ,irf_attribute10
       ,irf_information_category
       ,irf_information1
       ,irf_information2
       ,irf_information3
       ,irf_information4
       ,irf_information5
       ,irf_information6
       ,irf_information7
       ,irf_information8
       ,irf_information9
       ,irf_information10
       ,object_created_by
       ,created_by
       ,object_version_number
    from        irc_referral_info
    where       referral_info_id = p_referral_info_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_referral_info_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_referral_info_id
        = irc_irf_shd.g_old_rec.referral_info_id and
        p_object_version_number
        = irc_irf_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into irc_irf_shd.g_old_rec;
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
          <> irc_irf_shd.g_old_rec.object_version_number) Then
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
  ,p_referral_info_id                 in number
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
    irc_irf_shd.get_object_version_number
      (p_referral_info_id =>  p_referral_info_id
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  irc_referral_info t
  set     t.end_date    = p_new_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.referral_info_id = p_referral_info_id
  and     p_effective_date
  between t.start_date and t.end_date;
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
  ,p_referral_info_id                 in number
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
       referral_info_id
       ,object_id
       ,object_type
       ,start_date
       ,end_date
       ,source_type
       ,source_name
       ,source_criteria1
       ,source_value1
       ,source_criteria2
       ,source_value2
       ,source_criteria3
       ,source_value3
       ,source_criteria4
       ,source_value4
       ,source_criteria5
       ,source_value5
       ,source_person_id
       ,candidate_comment
       ,employee_comment
       ,irf_attribute_category
       ,irf_attribute1
       ,irf_attribute2
       ,irf_attribute3
       ,irf_attribute4
       ,irf_attribute5
       ,irf_attribute6
       ,irf_attribute7
       ,irf_attribute8
       ,irf_attribute9
       ,irf_attribute10
       ,irf_information_category
       ,irf_information1
       ,irf_information2
       ,irf_information3
       ,irf_information4
       ,irf_information5
       ,irf_information6
       ,irf_information7
       ,irf_information8
       ,irf_information9
       ,irf_information10
       ,object_created_by
       ,created_by
       ,object_version_number
    from        irc_referral_info
    where       referral_info_id = p_referral_info_id
    and         sysdate between start_date and end_date
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
                            ,p_argument       => 'referral_info_id'
                            ,p_argument_value => p_referral_info_id
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
    Fetch C_Sel1 Into irc_irf_shd.g_old_rec;
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
          <> irc_irf_shd.g_old_rec.object_version_number) Then
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
    p_validation_end_date   := irc_irf_shd.g_old_rec.end_date;
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
    fnd_message.set_token('TABLE_NAME', 'irc_referral_info');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_referral_info_id               in number
  ,p_object_id                      in number
  ,p_object_type                    in varchar2
  ,p_start_date                     in date
  ,p_end_date            	        in date
  ,p_source_type            		in varchar2
  ,p_source_name            		in varchar2
  ,p_source_criteria1               in varchar2
  ,p_source_value1            	    in varchar2
  ,p_source_criteria2               in varchar2
  ,p_source_value2            	    in varchar2
  ,p_source_criteria3               in varchar2
  ,p_source_value3                  in varchar2
  ,p_source_criteria4               in varchar2
  ,p_source_value4                  in varchar2
  ,p_source_criteria5               in varchar2
  ,p_source_value5                  in varchar2
  ,p_source_person_id               in number
  ,p_candidate_comment              in varchar2
  ,p_employee_comment               in varchar2
  ,p_irf_attribute_category         in varchar2
  ,p_irf_attribute1                 in varchar2
  ,p_irf_attribute2                 in varchar2
  ,p_irf_attribute3                 in varchar2
  ,p_irf_attribute4                 in varchar2
  ,p_irf_attribute5                 in varchar2
  ,p_irf_attribute6                 in varchar2
  ,p_irf_attribute7                 in varchar2
  ,p_irf_attribute8                 in varchar2
  ,p_irf_attribute9                 in varchar2
  ,p_irf_attribute10                in varchar2
  ,p_irf_information_category       in varchar2
  ,p_irf_information1               in varchar2
  ,p_irf_information2               in varchar2
  ,p_irf_information3               in varchar2
  ,p_irf_information4               in varchar2
  ,p_irf_information5               in varchar2
  ,p_irf_information6               in varchar2
  ,p_irf_information7               in varchar2
  ,p_irf_information8               in varchar2
  ,p_irf_information9               in varchar2
  ,p_irf_information10              in varchar2
  ,p_object_created_by              in varchar2
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
  l_rec.referral_info_id             := p_referral_info_id;
  l_rec.object_id                    := p_object_id;
  l_rec.object_type                  := p_object_type;
  l_rec.start_date                   := p_start_date;
  l_rec.end_date                     := p_end_date;
  l_rec.source_type                  := p_source_type;
  l_rec.source_name                  := p_source_name;
  l_rec.source_criteria1             := p_source_criteria1;
  l_rec.source_value1                := p_source_value1;
  l_rec.source_criteria2             := p_source_criteria2;
  l_rec.source_value2                := p_source_value2;
  l_rec.source_criteria3             := p_source_criteria3;
  l_rec.source_value3                := p_source_value3;
  l_rec.source_criteria4             := p_source_criteria4;
  l_rec.source_value4                := p_source_value4;
  l_rec.source_criteria5             := p_source_criteria5;
  l_rec.source_value5                := p_source_value5;
  l_rec.source_person_id             := p_source_person_id;
  l_rec.candidate_comment            := p_candidate_comment;
  l_rec.employee_comment             := p_employee_comment;
  l_rec.irf_attribute_category       := p_irf_attribute_category;
  l_rec.irf_attribute1               := p_irf_attribute1;
  l_rec.irf_attribute2               := p_irf_attribute2;
  l_rec.irf_attribute3               := p_irf_attribute3;
  l_rec.irf_attribute4               := p_irf_attribute4;
  l_rec.irf_attribute5               := p_irf_attribute5;
  l_rec.irf_attribute6               := p_irf_attribute6;
  l_rec.irf_attribute7               := p_irf_attribute7;
  l_rec.irf_attribute8               := p_irf_attribute8;
  l_rec.irf_attribute9               := p_irf_attribute9;
  l_rec.irf_attribute10              := p_irf_attribute10;
  l_rec.irf_information_category     := p_irf_information_category;
  l_rec.irf_information1             := p_irf_information1;
  l_rec.irf_information2             := p_irf_information2;
  l_rec.irf_information3             := p_irf_information3;
  l_rec.irf_information4             := p_irf_information4;
  l_rec.irf_information5             := p_irf_information5;
  l_rec.irf_information6             := p_irf_information6;
  l_rec.irf_information7             := p_irf_information7;
  l_rec.irf_information8             := p_irf_information8;
  l_rec.irf_information9             := p_irf_information9;
  l_rec.irf_information10            := p_irf_information10;
  l_rec.object_created_by            := p_object_created_by;
  l_rec.object_version_number        := p_object_version_number;
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
  (p_referral_info_id  in  number
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
    from irc_referral_info t
   where t.referral_info_id = p_referral_info_id;
  --
  -- Return the new object_version_number.
  --
  Return(l_ovn);
--
End get_object_version_number;
--
end irc_irf_shd;

/
