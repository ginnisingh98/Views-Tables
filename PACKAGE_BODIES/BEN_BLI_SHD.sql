--------------------------------------------------------
--  DDL for Package Body BEN_BLI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BLI_SHD" as
/* $Header: beblirhi.pkb 115.7 2002/12/10 15:17:02 bmanyam ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bli_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
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
  If (p_constraint_name = 'AVCON_BEN_B_CRTD__000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'AVCON_BEN_B_DLTD__000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'AVCON_BEN_B_REPLC_000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'AVCON_BEN_B_TMPRL_000') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BATCH_LER_INFO_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BATCH_LER_INFO_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BATCH_LER_INFO_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
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
  p_batch_ler_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	batch_ler_id,
	benefit_action_id,
	person_id,
	ler_id,
	lf_evt_ocrd_dt,
	replcd_flag,
	crtd_flag,
	tmprl_flag,
	dltd_flag,
        open_and_clsd_flag,
        clsd_flag,
        not_crtd_flag,
        stl_actv_flag,
        clpsd_flag,
        clsn_flag,
        no_effect_flag,
        cvrge_rt_prem_flag,
	per_in_ler_id,
	business_group_id,
	object_version_number
    from	ben_batch_ler_info
    where	batch_ler_id = p_batch_ler_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_batch_ler_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_batch_ler_id = g_old_rec.batch_ler_id and
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
  p_batch_ler_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	batch_ler_id,
	benefit_action_id,
	person_id,
	ler_id,
	lf_evt_ocrd_dt,
	replcd_flag,
	crtd_flag,
	tmprl_flag,
	dltd_flag,
        open_and_clsd_flag,
        clsd_flag,
        not_crtd_flag,
        stl_actv_flag,
        clpsd_flag,
        clsn_flag,
        no_effect_flag,
        cvrge_rt_prem_flag,
	per_in_ler_id,
	business_group_id,
	object_version_number
    from	ben_batch_ler_info
    where	batch_ler_id = p_batch_ler_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_batch_ler_info');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_batch_ler_id                  in number,
	p_benefit_action_id             in number,
	p_person_id                     in number,
	p_ler_id                        in number,
	p_lf_evt_ocrd_dt                in date,
	p_replcd_flag                   in varchar2,
	p_crtd_flag                     in varchar2,
	p_tmprl_flag                    in varchar2,
	p_dltd_flag                     in varchar2,
        p_open_and_clsd_flag            in varchar2,
        p_clsd_flag                     in varchar2,
        p_not_crtd_flag                 in varchar2,
        p_stl_actv_flag                 in varchar2,
        p_clpsd_flag                    in varchar2,
        p_clsn_flag                     in varchar2,
        p_no_effect_flag                in varchar2,
        p_cvrge_rt_prem_flag            in varchar2,
	p_per_in_ler_id                 in number,
	p_business_group_id             in number,
	p_object_version_number         in number
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
  l_rec.batch_ler_id                     := p_batch_ler_id;
  l_rec.benefit_action_id                := p_benefit_action_id;
  l_rec.person_id                        := p_person_id;
  l_rec.ler_id                           := p_ler_id;
  l_rec.lf_evt_ocrd_dt                   := p_lf_evt_ocrd_dt;
  l_rec.replcd_flag                      := p_replcd_flag;
  l_rec.crtd_flag                        := p_crtd_flag;
  l_rec.tmprl_flag                       := p_tmprl_flag;
  l_rec.dltd_flag                        := p_dltd_flag;
  l_rec.open_and_clsd_flag               := p_open_and_clsd_flag;
  l_rec.clsd_flag                        := p_clsd_flag;
  l_rec.not_crtd_flag                    := p_not_crtd_flag;
  l_rec.stl_actv_flag                    := p_stl_actv_flag;
  l_rec.clpsd_flag                       := p_clpsd_flag;
  l_rec.clsn_flag                        := p_clsn_flag;
  l_rec.no_effect_flag                   := p_no_effect_flag;
  l_rec.cvrge_rt_prem_flag               := p_cvrge_rt_prem_flag;
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_bli_shd;

/
