--------------------------------------------------------
--  DDL for Package Body BEN_PPL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPL_SHD" as
/* $Header: bepplrhi.pkb 120.0.12000000.3 2007/02/08 07:41:23 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ppl_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PTNL_LER_FOR_PER_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_PTNL_LER_FOR_PER_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_PTNL_LER_FOR_PER_FK3') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
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
  p_ptnl_ler_for_per_id                in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		ptnl_ler_for_per_id,
		csd_by_ptnl_ler_for_per_id,
	lf_evt_ocrd_dt,
        trgr_table_pk_id,
	ptnl_ler_for_per_stat_cd,
	ptnl_ler_for_per_src_cd,
        mnl_dt,
        enrt_perd_id,
	ntfn_dt,
	dtctd_dt,
	procd_dt,
	unprocd_dt,
	voidd_dt,
	mnlo_dt,
	ler_id,
	person_id,
	business_group_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_ptnl_ler_for_per
    where	ptnl_ler_for_per_id = p_ptnl_ler_for_per_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ptnl_ler_for_per_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ptnl_ler_for_per_id = g_old_rec.ptnl_ler_for_per_id and
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
  p_ptnl_ler_for_per_id                in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	ptnl_ler_for_per_id,
         	csd_by_ptnl_ler_for_per_id,
	lf_evt_ocrd_dt,
        trgr_table_pk_id,
	ptnl_ler_for_per_stat_cd,
	ptnl_ler_for_per_src_cd,
        mnl_dt,
        enrt_perd_id,
	ntfn_dt,
	dtctd_dt,
	procd_dt,
	unprocd_dt,
	voidd_dt,
	mnlo_dt,
	ler_id,
	person_id,
	business_group_id,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_ptnl_ler_for_per
    where	ptnl_ler_for_per_id = p_ptnl_ler_for_per_id
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
--    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
--    hr_utility.set_message_token('TABLE_NAME', 'ben_ptnl_ler_for_per');
	hr_utility.set_message(805, 'BEN_93651_PPL_OBJECT_LOCKED'); -- Bug 3140549
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ptnl_ler_for_per_id           in number,
	p_csd_by_ptnl_ler_for_per_id    in number,
	p_lf_evt_ocrd_dt                in date,
        p_trgr_table_pk_id              in number,
	p_ptnl_ler_for_per_stat_cd      in varchar2,
	p_ptnl_ler_for_per_src_cd       in varchar2,
        p_mnl_dt                        in date,
        p_enrt_perd_id                  in number,
	p_ntfn_dt                       in date,
	p_dtctd_dt                      in date,
	p_procd_dt                      in date,
	p_unprocd_dt                    in date,
	p_voidd_dt                      in date,
	p_mnlo_dt                       in date,
	p_ler_id                        in number,
	p_person_id                     in number,
	p_business_group_id             in number,
	p_request_id                    in number,
	p_program_application_id        in number,
	p_program_id                    in number,
	p_program_update_date           in date,
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
  l_rec.ptnl_ler_for_per_id              := p_ptnl_ler_for_per_id;
  l_rec.csd_by_ptnl_ler_for_per_id       := p_csd_by_ptnl_ler_for_per_id;
  l_rec.lf_evt_ocrd_dt                   := p_lf_evt_ocrd_dt;
  l_rec.trgr_table_pk_id                 := p_trgr_table_pk_id;
  l_rec.ptnl_ler_for_per_stat_cd         := p_ptnl_ler_for_per_stat_cd;
  l_rec.ptnl_ler_for_per_src_cd          := p_ptnl_ler_for_per_src_cd;
  l_rec.mnl_dt                           := p_mnl_dt;
  l_rec.enrt_perd_id                     := p_enrt_perd_id;
  l_rec.ntfn_dt                          := p_ntfn_dt;
  l_rec.dtctd_dt                         := p_dtctd_dt;
  l_rec.procd_dt                         := p_procd_dt;
  l_rec.unprocd_dt                       := p_unprocd_dt;
  l_rec.voidd_dt                         := p_voidd_dt;
  l_rec.mnlo_dt                          := p_mnlo_dt;
  l_rec.ler_id                           := p_ler_id;
  l_rec.person_id                        := p_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.request_id                       := p_request_id;
  l_rec.program_application_id           := p_program_application_id;
  l_rec.program_id                       := p_program_id;
  l_rec.program_update_date              := p_program_update_date;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_ppl_shd;

/
