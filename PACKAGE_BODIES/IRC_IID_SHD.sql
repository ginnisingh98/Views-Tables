--------------------------------------------------------
--  DDL for Package Body IRC_IID_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IID_SHD" as
/* $Header: iriidrhi.pkb 120.3.12010000.2 2008/11/06 13:49:47 mkjayara ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iid_shd.';  -- Global package name
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
  If (p_constraint_name = 'IRC_INTERVIEW_DETAILS_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'IRC_INTERVIEW_DETAILS_PK') Then
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
  ,p_interview_details_id                    in     number
  ,p_object_version_number                in     number
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
       interview_details_id
      ,status
      ,feedback
      ,notes
      ,notes_to_candidate
      ,category
      ,result
      ,iid_information_category
      ,iid_information1
      ,iid_information2
      ,iid_information3
      ,iid_information4
      ,iid_information5
      ,iid_information6
      ,iid_information7
      ,iid_information8
      ,iid_information9
      ,iid_information10
      ,iid_information11
      ,iid_information12
      ,iid_information13
      ,iid_information14
      ,iid_information15
      ,iid_information16
      ,iid_information17
      ,iid_information18
      ,iid_information19
      ,iid_information20
      ,start_date
      ,end_date
      ,event_id
      ,object_version_number
      ,created_by
    from        irc_interview_details
    where       interview_details_id = p_interview_details_id;
  --
  l_fct_ret     boolean;
  --
Begin
  --
  If (p_interview_details_id is null and
      p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_interview_details_id
        = irc_iid_shd.g_old_rec.interview_details_id and
        p_object_version_number
        = irc_iid_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into irc_iid_shd.g_old_rec;
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
          <> irc_iid_shd.g_old_rec.object_version_number) Then
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
  ,p_interview_details_id                in number
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
    irc_iid_shd.get_object_version_number
      (p_interview_details_id =>  p_interview_details_id
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  irc_interview_details t
  set     t.end_date    = p_new_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.interview_details_id = p_interview_details_id
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
  ,p_interview_details_id                in number
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
       interview_details_id
      ,status
      ,feedback
      ,notes
      ,notes_to_candidate
      ,category
      ,result
      ,iid_information_category
      ,iid_information1
      ,iid_information2
      ,iid_information3
      ,iid_information4
      ,iid_information5
      ,iid_information6
      ,iid_information7
      ,iid_information8
      ,iid_information9
      ,iid_information10
      ,iid_information11
      ,iid_information12
      ,iid_information13
      ,iid_information14
      ,iid_information15
      ,iid_information16
      ,iid_information17
      ,iid_information18
      ,iid_information19
      ,iid_information20
      ,start_date
      ,end_date
      ,event_id
      ,object_version_number
      ,created_by
    from        irc_interview_details
    where       interview_details_id = p_interview_details_id
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
                            ,p_argument       => 'interview_details_id'
                            ,p_argument_value => p_interview_details_id
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
    Fetch C_Sel1 Into irc_iid_shd.g_old_rec;
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
          <> irc_iid_shd.g_old_rec.object_version_number) Then
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
    p_validation_end_date   := irc_iid_shd.g_old_rec.end_date;
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
    fnd_message.set_token('TABLE_NAME', 'irc_interview_details');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_interview_details_id              in number
  ,p_status                         in varchar2
  ,p_feedback                       in varchar2
  ,p_notes                          in varchar2
  ,p_notes_to_candidate             in varchar2
  ,p_category                       in varchar2
  ,p_result                         in varchar2
  ,iid_information_category         in varchar2
  ,iid_information1                 in varchar2
  ,iid_information2                 in varchar2
  ,iid_information3                 in varchar2
  ,iid_information4                 in varchar2
  ,iid_information5                 in varchar2
  ,iid_information6                 in varchar2
  ,iid_information7                 in varchar2
  ,iid_information8                 in varchar2
  ,iid_information9                 in varchar2
  ,iid_information10                in varchar2
  ,iid_information11                in varchar2
  ,iid_information12                in varchar2
  ,iid_information13                in varchar2
  ,iid_information14                in varchar2
  ,iid_information15                in varchar2
  ,iid_information16                in varchar2
  ,iid_information17                in varchar2
  ,iid_information18                in varchar2
  ,iid_information19                in varchar2
  ,iid_information20                in varchar2
  ,p_start_date                     in date
  ,p_end_date                       in date
  ,p_event_id                       in number
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
  l_rec.interview_details_id             := p_interview_details_id;
  l_rec.status                           := p_status;
  l_rec.feedback                         := p_feedback;
  l_rec.notes                            := p_notes;
  l_rec.notes_to_candidate               := p_notes_to_candidate;
  l_rec.category                         := p_category;
  l_rec.result                           := p_result;
  l_rec.iid_information_category         := l_rec.iid_information_category;
  l_rec.iid_information1                 := l_rec.iid_information1;
  l_rec.iid_information2        	 := l_rec.iid_information2;
  l_rec.iid_information3        	 := l_rec.iid_information3;
  l_rec.iid_information4        	 := l_rec.iid_information4;
  l_rec.iid_information5        	 := l_rec.iid_information5;
  l_rec.iid_information6        	 := l_rec.iid_information6;
  l_rec.iid_information7        	 := l_rec.iid_information7;
  l_rec.iid_information8        	 := l_rec.iid_information8;
  l_rec.iid_information9        	 := l_rec.iid_information9;
  l_rec.iid_information10       	 := l_rec.iid_information10;
  l_rec.iid_information11       	 := l_rec.iid_information11;
  l_rec.iid_information12       	 := l_rec.iid_information12;
  l_rec.iid_information13       	 := l_rec.iid_information13;
  l_rec.iid_information14       	 := l_rec.iid_information14;
  l_rec.iid_information15       	 := l_rec.iid_information15;
  l_rec.iid_information16       	 := l_rec.iid_information16;
  l_rec.iid_information17       	 := l_rec.iid_information17;
  l_rec.iid_information18       	 := l_rec.iid_information18;
  l_rec.iid_information19       	 := l_rec.iid_information19;
  l_rec.iid_information20       	 := l_rec.iid_information20;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.event_id                         := p_event_id;
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
  (p_interview_details_id  in  number
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
    from irc_interview_details t
   where t.interview_details_id = p_interview_details_id;
  --
  -- Return the new object_version_number.
  --
  Return(l_ovn);
--
End get_object_version_number;
--
end irc_iid_shd;

/
