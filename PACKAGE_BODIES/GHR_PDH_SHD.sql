--------------------------------------------------------
--  DDL for Package Body GHR_PDH_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDH_SHD" AS
/* $Header: ghpdhrhi.pkb 120.1 2006/01/17 06:21:22 sumarimu noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdh_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'GHR_PD_ROUTING_HIST_FK1') Then
    hr_utility.set_message(8301,'GHR_99999_INV_PD_REQUEST_ID' );
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PD_ROUTING_HIST_FK2') Then
    hr_utility.set_message(8301,'GHR_38100_INV_ROUT_LIST_ID');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'GHR_PD_ROUTING_HIST_PK') Then
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
  p_pd_routing_history_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
  select  pd_routing_history_id,
  position_description_id,
  initiator_flag,
  requester_flag,
  approver_flag,
  reviewer_flag,
  authorizer_flag,
  personnelist_flag,
  approved_flag,
  user_name,
  user_name_employee_id ,
  user_name_emp_first_name,
  user_name_emp_last_name,
  user_name_emp_middle_names,
  action_taken,
  groupbox_id,
  routing_list_id,
  routing_seq_number,
  date_notification_sent,
  object_version_number,
  item_key  from	ghr_pd_routing_history
    where	pd_routing_history_id = p_pd_routing_history_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_pd_routing_history_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pd_routing_history_id = g_old_rec.pd_routing_history_id and
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
  p_pd_routing_history_id              in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
	pd_routing_history_id,
	position_description_id,
	initiator_flag,
        requester_flag,
	approver_flag,
	reviewer_flag,
      authorizer_flag,
      personnelist_flag,
	approved_flag,
    	user_name,
	user_name_employee_id,
     	user_name_emp_first_name,
	user_name_emp_last_name,
	user_name_emp_middle_names,
	action_taken,
	groupbox_id,
	routing_list_id,
      routing_seq_number,
 	date_notification_sent,
	object_version_number,
        item_key
    from	ghr_pd_routing_history
    where	pd_routing_history_id = p_pd_routing_history_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ghr_pd_routing_history');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pd_routing_history_id         in number,
	p_position_description_id       in number,
	p_initiator_flag                in varchar2,
        p_requester_flag                in varchar2,
	p_approver_flag                 in varchar2,
	p_reviewer_flag                 in varchar2,
      p_authorizer_flag               in varchar2,
      p_personnelist_flag             in varchar2,
	p_approved_flag                 in varchar2,
    	p_user_name                     in varchar2,
	p_user_name_employee_id         in number,
     	p_user_name_emp_first_name      in varchar2,
	p_user_name_emp_last_name       in varchar2,
	p_user_name_emp_middle_names    in varchar2,
	p_action_taken                  in varchar2,
	p_groupbox_id                   in number,
	p_routing_list_id               in number,
	p_routing_seq_number            in number,
	p_date_notification_sent        in date,
	p_object_version_number         in number,
        p_item_key                      in varchar2
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.pd_routing_history_id            := p_pd_routing_history_id;
  l_rec.position_description_id          := p_position_description_id;
  l_rec.initiator_flag                   := p_initiator_flag;
  l_rec.requester_flag                   := p_requester_flag;
  l_rec.approver_flag                    := p_approver_flag;
  l_rec.reviewer_flag                    := p_reviewer_flag;
  l_rec.authorizer_flag                  := p_authorizer_flag;
  l_rec.personnelist_flag                := p_personnelist_flag;
  l_rec.approved_flag                    := p_approved_flag;
  l_rec.user_name                        := p_user_name;
  l_rec.user_name_employee_id            := p_user_name_employee_id;
  l_rec.user_name_emp_first_name         := p_user_name_emp_first_name;
  l_rec.user_name_emp_last_name          := p_user_name_emp_last_name;
  l_rec.user_name_emp_middle_names       := p_user_name_emp_middle_names;
  l_rec.action_taken                     := p_action_taken;
  l_rec.groupbox_id                      := p_groupbox_id;
  l_rec.routing_list_id                  := p_routing_list_id;
  l_rec.routing_seq_number               := p_routing_seq_number;
  l_rec.date_notification_sent           := p_date_notification_sent;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.item_key                         := p_item_key;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ghr_pdh_shd;

/
