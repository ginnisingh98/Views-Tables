--------------------------------------------------------
--  DDL for Package Body GHR_PRH_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PRH_SHD" as
/* $Header: ghprhrhi.pkb 120.2.12010000.2 2009/08/11 09:26:23 managarw ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_prh_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc varchar2(72);
--
Begin
  l_proc := g_package||'constraint_error';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   If (p_constraint_name = 'GHR_PA_ROUTING_HIST_FK1') Then
    hr_utility.set_message(8301,'GHR_38048_INV_PA_REQUEST_ID' );
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_ROUTING_HIST_FK2') Then
    hr_utility.set_message(8301,'GHR_38100_INV_ROUT_LIST_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PA_ROUTING_HIST_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT'); --
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (
  p_pa_routing_history_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
  select  pa_routing_history_id,
  pa_request_id,
  attachment_modified_flag,
  initiator_flag,
  approver_flag,
  reviewer_flag,
  requester_flag,
  authorizer_flag,
  personnelist_flag,
  approved_flag,
  user_name,
  user_name_employee_id ,
  user_name_emp_first_name,
  user_name_emp_last_name,
  user_name_emp_middle_names,
  notepad,
  action_taken,
  groupbox_id,
  routing_list_id,
  routing_seq_number,
  noa_family_code,
  nature_of_action_id,
  second_nature_of_action_id,
  approval_status,
  date_notification_sent,
  object_version_number  from	ghr_pa_routing_history
    where	pa_routing_history_id = p_pa_routing_history_id;
--
  l_proc varchar2(72);
  l_fct_ret	boolean;
--
Begin
  l_proc := g_package||'api_updating';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_pa_routing_history_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pa_routing_history_id = g_old_rec.pa_routing_history_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_pa_routing_history_id              in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
  select  pa_routing_history_id,
  pa_request_id,
  attachment_modified_flag,
  initiator_flag,
  approver_flag,
  reviewer_flag,
  requester_flag,
  authorizer_flag,
  personnelist_flag,
  approved_flag,
  user_name,
  user_name_employee_id ,
  user_name_emp_first_name,
  user_name_emp_last_name,
  user_name_emp_middle_names,
  notepad,
  action_taken,
  groupbox_id,
  routing_list_id,
  routing_seq_number,
  noa_family_code,
  nature_of_action_id,
  second_nature_of_action_id,
  approval_Status,
  date_notification_sent,
  object_version_number
  from	ghr_pa_routing_history
  where	pa_routing_history_id = p_pa_routing_history_id
  for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Add any mandatory argument checking here:
  -- Example:
  -- hr_api.mandatory_arg_error
  --   (p_api_name       => l_proc,
  --    p_argument       => 'object_version_number',
  --    p_argument_value => p_object_version_number);
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ghr_pa_routing_history');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pa_routing_history_id         in number,
	p_pa_request_id                 in number,
	p_attachment_modified_flag      in varchar2,
	p_initiator_flag                in varchar2,
	p_approver_flag                 in varchar2,
	p_reviewer_flag                 in varchar2,
	p_requester_flag                in varchar2,
      p_authorizer_flag               in varchar2,
      p_personnelist_flag             in varchar2,
	p_approved_flag                 in varchar2,
    	p_user_name                     in varchar2,
	p_user_name_employee_id         in number,
     	p_user_name_emp_first_name      in varchar2,
	p_user_name_emp_last_name       in varchar2,
	p_user_name_emp_middle_names    in varchar2,
	p_notepad                       in varchar2,
	p_action_taken                  in varchar2,
	p_groupbox_id                   in number,
	p_routing_list_id               in number,
	p_routing_seq_number            in number,
      p_noa_family_code               in varchar2,
	p_nature_of_action_id           in number,
      p_second_nature_of_action_id    in number,
       p_approval_status                in varchar2,
	p_date_notification_sent        in date,
	p_object_version_number         in number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) ;
--
Begin
  --
  l_proc := g_package||'convert_args';
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.pa_routing_history_id            := p_pa_routing_history_id;
  l_rec.pa_request_id                    := p_pa_request_id;
  l_rec.attachment_modified_flag         := p_attachment_modified_flag;
  l_rec.initiator_flag                   := p_initiator_flag;
  l_rec.approver_flag                    := p_approver_flag;
  l_rec.reviewer_flag                    := p_reviewer_flag;
  l_rec.requester_flag                   := p_requester_flag;
  l_rec.authorizer_flag                  := p_authorizer_flag;
  l_rec.personnelist_flag                := p_personnelist_flag;
  l_rec.approved_flag                    := p_approved_flag;
  l_rec.user_name                        := p_user_name;
  l_rec.user_name_employee_id            := p_user_name_employee_id;
  l_rec.user_name_emp_first_name         := p_user_name_emp_first_name;
  l_rec.user_name_emp_last_name          := p_user_name_emp_last_name;
  l_rec.user_name_emp_middle_names       := p_user_name_emp_middle_names;
  l_rec.notepad                          := p_notepad;
  l_rec.action_taken                     := p_action_taken;
  l_rec.groupbox_id                      := p_groupbox_id;
  l_rec.routing_list_id                  := p_routing_list_id;
  l_rec.routing_seq_number               := p_routing_seq_number;
  l_rec.noa_family_code                  := p_noa_family_code;
  l_rec.nature_of_action_id              := p_nature_of_action_id;
  l_rec.second_nature_of_action_id       := p_second_nature_of_action_id;
  l_rec.approval_status                  := p_approval_status;
  l_rec.date_notification_sent           := p_date_notification_sent;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ghr_prh_shd;

/
