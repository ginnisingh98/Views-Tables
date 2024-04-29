--------------------------------------------------------
--  DDL for Package Body BEN_BMN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BMN_SHD" as
/* $Header: bebmnrhi.pkb 115.7 2002/12/09 12:40:49 lakrish ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_bmn_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_REPORTING_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_REPORTING_PK') Then
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
  p_reporting_id                       in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	reporting_id,
	benefit_action_id,
	thread_id,
	sequence,
	text,
        rep_typ_cd,
        error_message_code,
        national_identifier,
        related_person_ler_id,
        temporal_ler_id,
        ler_id,
        person_id,
        pgm_id,
        pl_id,
        related_person_id,
        oipl_id,
        pl_typ_id,
        actl_prem_id                      ,
        val                               ,
        mo_num                            ,
        yr_num                            ,
	object_version_number
    from	ben_reporting
    where	reporting_id = p_reporting_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_reporting_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_reporting_id = g_old_rec.reporting_id and
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
  p_reporting_id                       in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	reporting_id,
	benefit_action_id,
	thread_id,
	sequence,
	text,
        rep_typ_cd,
        error_message_code,
        national_identifier,
        related_person_ler_id,
        temporal_ler_id,
        ler_id,
        person_id,
        pgm_id,
        pl_id,
        related_person_id,
        oipl_id,
        pl_typ_id,
        actl_prem_id                      ,
        val                               ,
        mo_num                            ,
        yr_num                            ,
	object_version_number
    from	ben_reporting
    where	reporting_id = p_reporting_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_reporting');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_reporting_id                  in number,
	p_benefit_action_id             in number,
	p_thread_id                     in number,
	p_sequence                      in number,
	p_text                          in varchar2,
        p_rep_typ_cd                    in varchar2,
        p_error_message_code            in varchar2,
        p_national_identifier           in varchar2,
        p_related_person_ler_id         in number,
        p_temporal_ler_id               in number,
        p_ler_id                        in number,
        p_person_id                     in number,
        p_pgm_id                        in number,
        p_pl_id                         in number,
        p_related_person_id             in number,
        p_oipl_id                       in number,
        p_pl_typ_id                     in number,
        p_actl_prem_id                  in    number,
        p_val                           in    number,
        p_mo_num                        in    number,
        p_yr_num                        in    number,
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
  l_rec.reporting_id                     := p_reporting_id;
  l_rec.benefit_action_id                := p_benefit_action_id;
  l_rec.thread_id                        := p_thread_id        ;
  l_rec.sequence                         := p_sequence;
  l_rec.text                             := p_text;
  l_rec.rep_typ_cd                       := p_rep_typ_cd;
  l_rec.error_message_code               := p_error_message_code;
  l_rec.national_identifier              := p_national_identifier;
  l_rec.related_person_ler_id            := p_related_person_ler_id;
  l_rec.temporal_ler_id                  := p_temporal_ler_id;
  l_rec.ler_id                           := p_ler_id;
  l_rec.person_id                        := p_person_id;
  l_rec.pgm_id                           := p_pgm_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.related_person_id                := p_related_person_id;
  l_rec.pl_typ_id                        := p_pl_typ_id;
  l_rec.actl_prem_id                  := p_actl_prem_id;
  l_rec.val                           := p_val    ;
  l_rec.mo_num                        := p_mo_num    ;
  l_rec.yr_num                        := p_yr_num    ;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_bmn_shd;

/
