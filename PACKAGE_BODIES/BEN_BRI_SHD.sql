--------------------------------------------------------
--  DDL for Package Body BEN_BRI_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BRI_SHD" as
/* $Header: bebrirhi.pkb 120.0 2005/05/28 00:51:44 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bri_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_BATCH_RATE_INFO_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BATCH_RATE_INFO_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_BATCH_RATE_INFO_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','15');
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
  p_batch_rt_id                        in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		batch_rt_id,
	benefit_action_id,
	person_id,
	pgm_id,
	pl_id,
	oipl_id,
	bnft_rt_typ_cd,
	dflt_flag,
	val,
        old_val,
	tx_typ_cd,
	acty_typ_cd,
	mn_elcn_val,
	mx_elcn_val,
	incrmt_elcn_val,
	dflt_val,
	rt_strt_dt,
	business_group_id,
	object_version_number,
	enrt_cvg_strt_dt,
	enrt_cvg_thru_dt,
	actn_cd,
	close_actn_itm_dt
    from	ben_batch_rate_info
    where	batch_rt_id = p_batch_rt_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_batch_rt_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_batch_rt_id = g_old_rec.batch_rt_id and
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
  p_batch_rt_id                        in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	batch_rt_id,
	benefit_action_id,
	person_id,
	pgm_id,
	pl_id,
	oipl_id,
	bnft_rt_typ_cd,
	dflt_flag,
	val,
        old_val,
	tx_typ_cd,
	acty_typ_cd,
	mn_elcn_val,
	mx_elcn_val,
	incrmt_elcn_val,
	dflt_val,
	rt_strt_dt,
	business_group_id,
	object_version_number,
	enrt_cvg_strt_dt,
	enrt_cvg_thru_dt,
	actn_cd,
	close_actn_itm_dt
    from	ben_batch_rate_info
    where	batch_rt_id = p_batch_rt_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_batch_rate_info');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_batch_rt_id                   in number,
	p_benefit_action_id             in number,
	p_person_id                     in number,
	p_pgm_id                        in number,
	p_pl_id                         in number,
	p_oipl_id                       in number,
	p_bnft_rt_typ_cd                in varchar2,
	p_dflt_flag                     in varchar2,
	p_val                           in number,
        p_old_val                       in number,
	p_tx_typ_cd                     in varchar2,
	p_acty_typ_cd                   in varchar2,
	p_mn_elcn_val                   in number,
	p_mx_elcn_val                   in number,
	p_incrmt_elcn_val               in number,
	p_dflt_val                      in number,
	p_rt_strt_dt                    in date,
	p_business_group_id             in number,
	p_object_version_number         in number,
	p_enrt_cvg_strt_dt              in date,
	p_enrt_cvg_thru_dt              in date,
	p_actn_cd                       in varchar2,
	p_close_actn_itm_dt             in date
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
  l_rec.batch_rt_id                      := p_batch_rt_id;
  l_rec.benefit_action_id                := p_benefit_action_id;
  l_rec.person_id                        := p_person_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.bnft_rt_typ_cd                   := p_bnft_rt_typ_cd;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.val                              := p_val;
  l_rec.old_val                          := p_old_val;
  l_rec.tx_typ_cd                        := p_tx_typ_cd;
  l_rec.acty_typ_cd                      := p_acty_typ_cd;
  l_rec.mn_elcn_val                      := p_mn_elcn_val;
  l_rec.mx_elcn_val                      := p_mx_elcn_val;
  l_rec.incrmt_elcn_val                  := p_incrmt_elcn_val;
  l_rec.dflt_val                         := p_dflt_val;
  l_rec.rt_strt_dt                       := p_rt_strt_dt;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.enrt_cvg_strt_dt                 := p_enrt_cvg_strt_dt;
  l_rec.enrt_cvg_thru_dt                 := p_enrt_cvg_thru_dt;
  l_rec.actn_cd                          := p_actn_cd;
  l_rec.close_actn_itm_dt                := p_close_actn_itm_dt;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_bri_shd;

/
