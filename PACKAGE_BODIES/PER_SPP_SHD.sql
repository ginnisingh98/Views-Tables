--------------------------------------------------------
--  DDL for Package Body PER_SPP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SPP_SHD" as
/* $Header: pespprhi.pkb 120.2.12010000.4 2008/11/05 14:50:57 brsinha ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_spp_shd.';  -- Global package name
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
  If (p_constraint_name = 'PER_SPINAL_POINT_PLACEMENT_FK1') Then
    fnd_message.set_name('PER', 'HR_289228_SPP_FK1_BUS_GROUP');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_SPINAL_POINT_PLACEMENT_PK') Then
    fnd_message.set_name('PER', 'HR_289222_SPP_PK_PLACEMENT_ID');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_SPTPL_AUTO_INCREMENT_F_CHK') Then
    fnd_message.set_name('PER', 'HR_289223_SPP_AUTO_INC_FLG_CHK');
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
  (p_effective_date                   in date
  ,p_placement_id                     in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     placement_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,assignment_id
    ,step_id
    ,auto_increment_flag
    ,parent_spine_id
    ,reason
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,increment_number
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
    ,information_category
    ,object_version_number
    from	per_spinal_point_placements_f
    where	placement_id = p_placement_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_fct_ret	boolean;
  l_proc    	varchar2(72) := g_package|| 'api_updating';
--
Begin
  --
  hr_utility.set_location('Entering :'||l_proc, 5);
  If (p_effective_date is null or
      p_placement_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  hr_utility.set_location('Entering :'||l_proc, 10);
  Else
    hr_utility.set_location('Entering :'||l_proc, 15);

    If (p_placement_id =
        per_spp_shd.g_old_rec.placement_id and
        p_object_version_number =
        per_spp_shd.g_old_rec.object_version_number) Then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
  hr_utility.set_location('Entering :'||l_proc, 20);
      l_fct_ret := true;
    Else
  hr_utility.set_location('Entering :'||l_proc, 25);
      --
      -- Select the current row
      --
      Open C_Sel1;
      Fetch C_Sel1 Into per_spp_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
  hr_utility.set_location('Entering :'||l_proc, 30);
      If (p_object_version_number
          <> per_spp_shd.g_old_rec.object_version_number) Then
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
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_correction             out nocopy boolean
  ,p_update                 out nocopy boolean
  ,p_update_override        out nocopy boolean
  ,p_update_change_insert   out nocopy boolean
  ) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
  l_grade_id	number;

  cursor csr_future_grade_scale is
  select paa.grade_id
  from per_all_assignments_f paa,
       per_spinal_point_placements_f spp
  where paa.assignment_id = spp.assignment_id
  and spp.placement_id = p_base_key_value
  and paa.effective_start_date > p_effective_date
  and paa.grade_id <> (select paa1.grade_id
		   from per_all_assignments_f paa1
		   where paa1.assignment_id = paa.assignment_id
		   and p_effective_date between paa1.effective_start_date
					    and paa1.effective_end_date);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'per_spinal_point_placements_f'
    ,p_base_key_column       => 'placement_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    );
  --
  -- If there is a future change of grade scales then do not allow the user
  -- to replace future changes
  --
  open csr_future_grade_scale;
  fetch csr_future_grade_scale into l_grade_id;

  if csr_future_grade_scale%found then
    hr_utility.set_location('REMOVING UPDATE OVERRIDE',6);
    p_update_override := false;
  end if;

  close csr_future_grade_scale;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
  (p_effective_date        in date
  ,p_base_key_value        in number
  ,p_zap                   out nocopy boolean
  ,p_delete                out nocopy boolean
  ,p_future_change         out nocopy boolean
  ,p_delete_next_change    out nocopy boolean
  ) is
  --
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
  --
  l_parent_key_value1     number;
  l_parent_key_value2     number;
  --
  Cursor C_Sel1 Is
    select
     t.step_id
    ,t.assignment_id
    from   per_spinal_point_placements_f t
    where  t.placement_id = p_base_key_value
    and    p_effective_date
    between t.effective_start_date and t.effective_end_date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open C_sel1;
  Fetch C_Sel1 Into
     l_parent_key_value1
    ,l_parent_key_value2;
  If C_Sel1%NOTFOUND then
    Close C_Sel1;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE',l_proc);
     fnd_message.set_token('STEP','10');
     fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'per_spinal_point_placements_f'
   ,p_base_key_column               => 'placement_id'
   ,p_base_key_value                => p_base_key_value
   ,p_parent_table_name1            => 'per_spinal_point_steps_f'
   ,p_parent_key_column1            => 'step_id'
   ,p_parent_key_value1             => l_parent_key_value1
   ,p_parent_table_name2            => 'per_all_assignments_f'
   ,p_parent_key_column2            => 'assignment_id'
   ,p_parent_key_value2             => l_parent_key_value2
   ,p_zap                           => p_zap
   ,p_delete                        => p_delete
   ,p_future_change                 => p_future_change
   ,p_delete_next_change            => p_delete_next_change
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
  (p_effective_date                   in date
  ,p_base_key_value                   in number
  ,p_new_effective_end_date           in date
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ,p_object_version_number  out nocopy number
  ) is
--
  l_proc 		  varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name    => 'per_spinal_point_placements_f'
      ,p_base_key_column    => 'placement_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  hr_utility.set_location('PLacement_id: '||p_base_key_value,1);
  hr_utility.set_location('Object Version Number: '||l_object_version_number,2);
  hr_utility.set_location('Effective_Date: '||p_effective_date,3);
  hr_utility.set_location('NEW Effective_End_Date: '||p_new_effective_end_date,4);
  per_spp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  per_spinal_point_placements_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.placement_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  per_spp_shd.g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    per_spp_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_placement_id                     in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_argument		  varchar2(30);
  -- Bug 3158554 starts here.
  -- Additional local variables
  l_validation_start_date1  date;
  l_validation_start_date2  date;
  l_validation_end_date1    date;
  l_validation_end_date2    date;
  l_enforce_foreign_locking boolean;
  -- Bug 3158554 ends here.
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     placement_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,assignment_id
    ,step_id
    ,auto_increment_flag
    ,parent_spine_id
    ,reason
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,increment_number
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
    ,information_category
    ,object_version_number
    from    per_spinal_point_placements_f
    where   placement_id = p_placement_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
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
  hr_utility.set_location('Entering:'||l_proc, 6);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'datetrack_mode'
                            ,p_argument_value => p_datetrack_mode
                            );
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'placement_id'
                            ,p_argument_value => p_placement_id
                            );
  hr_utility.set_location('Entering:'||l_proc, 8);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );
  hr_utility.set_location('Entering:'||l_proc, 9);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    --
    -- We must select and lock the current row.
    --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
    Open  C_Sel1;
    Fetch C_Sel1 Into per_spp_shd.g_old_rec;

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
          <> per_spp_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    -- Bug 3158554 starts here.
    --
    -- Always perform locking for set-up data parent
    -- tables, unless this is a Data Pump session AND
    -- the 'PUMP_DT_ENFORCE_FOREIGN_LOCKS' switch
    -- has been set to no.
    if hr_pump_utils.current_session_running then
       l_enforce_foreign_locking := hr_pump_utils.dt_enforce_foreign_locks;
    else
       l_enforce_foreign_locking := true;
    end if;

    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'per_spinal_point_placements_f'
      ,p_base_key_column         => 'placement_id'
      ,p_base_key_value          => p_placement_id
      ,p_parent_table_name1      => 'per_spinal_point_steps_f'
      ,p_parent_key_column1      => 'step_id'
      ,p_parent_key_value1       => per_spp_shd.g_old_rec.step_id
     -- ,p_parent_table_name2      => 'per_all_assignments_f'
     -- ,p_parent_key_column2      => 'assignment_id'
     -- ,p_parent_key_value2       => per_spp_shd.g_old_rec.assignment_id
      ,p_enforce_foreign_locking => l_enforce_foreign_locking
      ,p_validation_start_date   => l_validation_start_date1
      ,p_validation_end_date     => l_validation_end_date1
      );
   --
   -- Always perform locking for transaction data parent tables
   --
   dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'per_spinal_point_placements_f'
      ,p_base_key_column         => 'placement_id'
      ,p_base_key_value          => p_placement_id
     --,p_parent_table_name1      => 'per_spinal_point_steps_f'
     --,p_parent_key_column1      => 'step_id'
     --,p_parent_key_value1       => per_spp_shd.g_old_rec.step_id
      ,p_parent_table_name2      => 'per_all_assignments_f'
      ,p_parent_key_column2      => 'assignment_id'
      ,p_parent_key_value2       => per_spp_shd.g_old_rec.assignment_id
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date2
      ,p_validation_end_date     => l_validation_end_date2
      );
      --
      -- bug 3158554 ends here.
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
  -- taking the most restrictive replies from the two calls
  -- to dt_api.validate_dt_mode. i.e. The latest VSD and the
  -- earliest VED.
  --
  -- bug 3158554 starts here.
  --
  if l_validation_start_date1 > l_validation_start_date2 then
    p_validation_start_date := l_validation_start_date1;
  else
    p_validation_start_date := l_validation_start_date2;
  end if;

  if l_validation_end_date1 > l_validation_end_date2 then
    p_validation_end_date := l_validation_end_date2;
  else
    p_validation_end_date := l_validation_end_date1;
  end if;
  -- p_validation_start_date := l_validation_start_date;
  -- p_validation_end_date   := l_validation_end_date;
  --
  -- bug 3158554 ends here.
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
    fnd_message.set_token('TABLE_NAME', 'per_spinal_point_placements_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_placement_id                   in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_assignment_id                  in number
  ,p_step_id                        in number
  ,p_auto_increment_flag            in varchar2
  ,p_parent_spine_id                in number
  ,p_reason                         in varchar2
  ,p_request_id                     in number
  ,p_program_application_id         in number
  ,p_program_id                     in number
  ,p_program_update_date            in date
  ,p_increment_number               in number
  ,p_information1                   in varchar2
  ,p_information2                   in varchar2
  ,p_information3                   in varchar2
  ,p_information4                   in varchar2
  ,p_information5                   in varchar2
  ,p_information6                   in varchar2
  ,p_information7                   in varchar2
  ,p_information8                   in varchar2
  ,p_information9                   in varchar2
  ,p_information10                  in varchar2
  ,p_information11                  in varchar2
  ,p_information12                  in varchar2
  ,p_information13                  in varchar2
  ,p_information14                  in varchar2
  ,p_information15                  in varchar2
  ,p_information16                  in varchar2
  ,p_information17                  in varchar2
  ,p_information18                  in varchar2
  ,p_information19                  in varchar2
  ,p_information20                  in varchar2
  ,p_information21                  in varchar2
  ,p_information22                  in varchar2
  ,p_information23                  in varchar2
  ,p_information24                  in varchar2
  ,p_information25                  in varchar2
  ,p_information26                  in varchar2
  ,p_information27                  in varchar2
  ,p_information28                  in varchar2
  ,p_information29                  in varchar2
  ,p_information30                  in varchar2
  ,p_information_category           in varchar2
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
  l_rec.placement_id                     := p_placement_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.step_id                          := p_step_id;
  l_rec.auto_increment_flag              := p_auto_increment_flag;
  l_rec.parent_spine_id                  := p_parent_spine_id;
  l_rec.reason                           := p_reason;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.increment_number                 := p_increment_number;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.information1                     := p_information1;
  l_rec.information2                     := p_information2;
  l_rec.information3                     := p_information3;
  l_rec.information4                     := p_information4;
  l_rec.information5                     := p_information5;
  l_rec.information6                     := p_information6;
  l_rec.information7                     := p_information7;
  l_rec.information8                     := p_information8;
  l_rec.information9                     := p_information9;
  l_rec.information10                    := p_information10;
  l_rec.information11                    := p_information11;
  l_rec.information12                    := p_information12;
  l_rec.information13                    := p_information13;
  l_rec.information14                    := p_information14;
  l_rec.information15                    := p_information15;
  l_rec.information16                    := p_information16;
  l_rec.information17                    := p_information17;
  l_rec.information18                    := p_information18;
  l_rec.information19                    := p_information19;
  l_rec.information20                    := p_information20;
  l_rec.information21                    := p_information21;
  l_rec.information22                    := p_information22;
  l_rec.information23                    := p_information23;
  l_rec.information24                    := p_information24;
  l_rec.information25                    := p_information25;
  l_rec.information26                    := p_information26;
  l_rec.information27                    := p_information27;
  l_rec.information28                    := p_information28;
  l_rec.information29                    := p_information29;
  l_rec.information30                    := p_information30;
  l_rec.information_category             := p_information_category;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_spp_shd;

/
