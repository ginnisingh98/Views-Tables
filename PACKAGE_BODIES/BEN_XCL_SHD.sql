--------------------------------------------------------
--  DDL for Package Body BEN_XCL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCL_SHD" as
/* $Header: bexclrhi.pkb 115.7 2002/12/24 21:28:21 rpillay ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xcl_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_EXT_CHG_EVT_LOG_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
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
  p_ext_chg_evt_log_id                 in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	ext_chg_evt_log_id,
	chg_evt_cd,
	chg_eff_dt,
	chg_user_id,
	prmtr_01,
	prmtr_02,
	prmtr_03,
	prmtr_04,
	prmtr_05,
	prmtr_06,
	prmtr_07,
	prmtr_08,
	prmtr_09,
	prmtr_10,
	person_id,
	business_group_id,
	object_version_number,
        chg_actl_dt,
        new_val1,
        new_val2,
        new_val3,
        new_val4,
        new_val5,
        new_val6,
        old_val1,
        old_val2,
        old_val3,
        old_val4,
        old_val5,
        old_val6
    from	ben_ext_chg_evt_log
    where	ext_chg_evt_log_id = p_ext_chg_evt_log_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ext_chg_evt_log_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ext_chg_evt_log_id = g_old_rec.ext_chg_evt_log_id and
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
  p_ext_chg_evt_log_id                 in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
	ext_chg_evt_log_id,
	chg_evt_cd,
	chg_eff_dt,
	chg_user_id,
	prmtr_01,
	prmtr_02,
	prmtr_03,
	prmtr_04,
	prmtr_05,
	prmtr_06,
	prmtr_07,
	prmtr_08,
	prmtr_09,
	prmtr_10,
	person_id,
	business_group_id,
	object_version_number,
        chg_actl_dt,
        new_val1,
        new_val2,
        new_val3,
        new_val4,
        new_val5,
        new_val6,
        old_val1,
        old_val2,
        old_val3,
        old_val4,
        old_val5,
        old_val6
    from	ben_ext_chg_evt_log
    where	ext_chg_evt_log_id = p_ext_chg_evt_log_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_ext_chg_evt_log');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ext_chg_evt_log_id            in number,
	p_chg_evt_cd                    in varchar2,
	p_chg_eff_dt                    in date,
	p_chg_user_id                   in number,
	p_prmtr_01                      in varchar2,
	p_prmtr_02                      in varchar2,
	p_prmtr_03                      in varchar2,
	p_prmtr_04                      in varchar2,
	p_prmtr_05                      in varchar2,
	p_prmtr_06                      in varchar2,
	p_prmtr_07                      in varchar2,
	p_prmtr_08                      in varchar2,
	p_prmtr_09                      in varchar2,
	p_prmtr_10                      in varchar2,
	p_person_id                     in number,
	p_business_group_id             in number,
	p_object_version_number         in number,
        p_chg_actl_dt                   in date,
        p_new_val1                      in varchar2,
        p_new_val2                      in varchar2,
        p_new_val3                      in varchar2,
        p_new_val4                      in varchar2,
        p_new_val5                      in varchar2,
        p_new_val6                      in varchar2,
        p_old_val1                      in varchar2,
        p_old_val2                      in varchar2,
        p_old_val3                      in varchar2,
        p_old_val4                      in varchar2,
        p_old_val5                      in varchar2,
        p_old_val6                      in varchar2
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
  l_rec.ext_chg_evt_log_id               := p_ext_chg_evt_log_id;
  l_rec.chg_evt_cd                       := p_chg_evt_cd;
  l_rec.chg_eff_dt                       := p_chg_eff_dt;
  l_rec.chg_user_id                      := p_chg_user_id;
  l_rec.prmtr_01                         := p_prmtr_01;
  l_rec.prmtr_02                         := p_prmtr_02;
  l_rec.prmtr_03                         := p_prmtr_03;
  l_rec.prmtr_04                         := p_prmtr_04;
  l_rec.prmtr_05                         := p_prmtr_05;
  l_rec.prmtr_06                         := p_prmtr_06;
  l_rec.prmtr_07                         := p_prmtr_07;
  l_rec.prmtr_08                         := p_prmtr_08;
  l_rec.prmtr_09                         := p_prmtr_09;
  l_rec.prmtr_10                         := p_prmtr_10;
  l_rec.person_id                        := p_person_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.chg_actl_dt                      := p_chg_actl_dt;
  l_rec.new_val1                         := p_new_val1;
  l_rec.new_val2                         := p_new_val2;
  l_rec.new_val3                         := p_new_val3;
  l_rec.new_val4                         := p_new_val4;
  l_rec.new_val5                         := p_new_val5;
  l_rec.new_val6                         := p_new_val6;
  l_rec.old_val1                         := p_old_val1;
  l_rec.old_val2                         := p_old_val2;
  l_rec.old_val3                         := p_old_val3;
  l_rec.old_val4                         := p_old_val4;
  l_rec.old_val5                         := p_old_val5;
  l_rec.old_val6                         := p_old_val6;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_xcl_shd;

/
