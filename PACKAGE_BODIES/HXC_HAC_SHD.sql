--------------------------------------------------------
--  DDL for Package Body HXC_HAC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HAC_SHD" as
 /* $Header: hxchacrhi.pkb 120.4 2006/06/13 08:42:23 gsirigin noship $ */
 --
 -- ----------------------------------------------------------------------------
 -- |                     Private Global Definitions                           |
 -- ----------------------------------------------------------------------------
 --
 g_package  varchar2(33)	:= '  hxc_hac_shd.';  -- Global package name
 g_debug    boolean		:= hr_utility.debug_enabled;
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
   If (p_constraint_name = 'HXC_APPROVAL_COMPS_FK1') Then
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_proc);
     fnd_message.set_token('STEP','5');
     fnd_message.raise_error;
   ElsIf (p_constraint_name = 'HXC_APPROVAL_COMPS_FK2') Then
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE', l_proc);
     fnd_message.set_token('STEP','10');
     fnd_message.raise_error;
   ElsIf (p_constraint_name = 'HXC_APPROVAL_COMPS_PK') Then
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
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
   (p_approval_comp_id                     in     number
   ,p_object_version_number                in     number
   )
   Return Boolean Is
 --
   --
   -- Cursor selects the 'current' row from the HR Schema
   --
   Cursor C_Sel1 is
     select
        approval_comp_id
       ,approval_style_id
       ,time_recipient_id
       ,approval_mechanism
       ,approval_mechanism_id
       ,wf_item_type
       ,wf_name
       ,start_date
       ,end_date
       ,object_version_number
       ,approval_order
       ,time_category_id
       ,parent_comp_id
       ,parent_comp_ovn
       ,run_recipient_extensions
     from	hxc_approval_comps
     where	approval_comp_id = p_approval_comp_id;
 --
   l_fct_ret	boolean;
 --
 Begin
   --
   If (p_approval_comp_id is null and
       p_object_version_number is null
      ) Then
     --
     -- One of the primary key arguments is null therefore we must
     -- set the returning function value to false
     --
     l_fct_ret := false;
   Else
     If (p_approval_comp_id
         = hxc_hac_shd.g_old_rec.approval_comp_id and
         p_object_version_number
         = hxc_hac_shd.g_old_rec.object_version_number
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
       Fetch C_Sel1 Into hxc_hac_shd.g_old_rec;
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
           <> hxc_hac_shd.g_old_rec.object_version_number) Then
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
   (p_approval_comp_id                     in     number
   ,p_object_version_number                in     number
   ) is
 --
 -- Cursor selects the 'current' row from the HR Schema
 --
   Cursor C_Sel1 is
     select
        approval_comp_id
       ,approval_style_id
       ,time_recipient_id
       ,approval_mechanism
       ,approval_mechanism_id
       ,wf_item_type
       ,wf_name
       ,start_date
       ,end_date
       ,object_version_number
       ,approval_order
       ,time_category_id
 	  ,parent_comp_id
       ,parent_comp_ovn
       ,run_recipient_extensions
     from	hxc_approval_comps
     where	approval_comp_id = p_approval_comp_id
     for	update nowait;
 --
   l_proc	varchar2(72);
 --
 Begin
   g_debug:=hr_utility.debug_enabled;
   if g_debug then
	l_proc := g_package||'lck';
	hr_utility.set_location('Entering:'||l_proc, 5);
   end if;
   --
   hr_api.mandatory_arg_error
     (p_api_name           => l_proc
     ,p_argument           => 'APPROVAL_COMP_ID'
     ,p_argument_value     => p_approval_comp_id
     );
   --
   Open  C_Sel1;
   Fetch C_Sel1 Into hxc_hac_shd.g_old_rec;
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
       <> hxc_hac_shd.g_old_rec.object_version_number) Then
         fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
         fnd_message.raise_error;
   End If;
   --
   if g_debug then
	hr_utility.set_location(' Leaving:'||l_proc, 10);
   end if;
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
     fnd_message.set_token('TABLE_NAME', 'hxc_approval_comps');
     fnd_message.raise_error;
 End lck;
 --
 -- ----------------------------------------------------------------------------
 -- |-----------------------------< convert_args >-----------------------------|
 -- ----------------------------------------------------------------------------
 Function convert_args
   (p_approval_comp_id               in number
   ,p_approval_style_id              in number
   ,p_time_recipient_id              in number
   ,p_approval_mechanism             in varchar2
   ,p_approval_mechanism_id          in number
   ,p_wf_item_type                   in varchar2
   ,p_wf_name                        in varchar2
   ,p_start_date                     in date
   ,p_end_date                       in date
   ,p_object_version_number          in number
   ,p_approval_order                 in number
   ,p_time_category_id               in number
   ,p_parent_comp_id                 in number
   ,p_parent_comp_ovn		     in number
   ,p_run_recipient_extensions       in varchar2
   )
   Return g_rec_type is
 --
   l_rec   g_rec_type;
 --
 Begin
   --
   -- Convert arguments into local l_rec structure.
   --
   l_rec.approval_comp_id                 := p_approval_comp_id;
   l_rec.approval_style_id                := p_approval_style_id;
   l_rec.time_recipient_id                := p_time_recipient_id;
   l_rec.approval_mechanism               := p_approval_mechanism;
   l_rec.approval_mechanism_id            := p_approval_mechanism_id;
   l_rec.wf_item_type                     := p_wf_item_type;
   l_rec.wf_name                          := p_wf_name;
   l_rec.start_date                       := p_start_date;
   l_rec.end_date                         := p_end_date;
   l_rec.object_version_number            := p_object_version_number;
   l_rec.approval_order                   := p_approval_order;
   l_rec.time_category_id                 := p_time_category_id;
   l_rec.parent_comp_id                   := p_parent_comp_id;
   l_rec.parent_comp_ovn                  := p_parent_comp_ovn;
   l_rec.run_recipient_extensions         := p_run_recipient_extensions;
   --
   -- Return the plsql record structure.
   --
   Return(l_rec);
 --
 End convert_args;
 --
 end hxc_hac_shd;

/
