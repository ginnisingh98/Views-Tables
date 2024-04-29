--------------------------------------------------------
--  DDL for Package Body BEN_XER_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XER_SHD" as
/* $Header: bexerrhi.pkb 120.1 2006/03/22 13:57:32 tjesumic noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_xer_shd.';  -- Global package name
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
  cursor c1 is
    select xfi.name
        from ben_ext_file xfi,
             ben_ext_rcd_in_file xrf,
             ben_ext_data_elmt_in_rcd xdr
    where xdr.ext_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xdr.ext_rcd_id   = xdr.ext_rcd_id
    and   xrf.sort1_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xrf.ext_file_id = xfi.ext_file_id;

  cursor c2 is
    select xfi.name
        from ben_ext_file xfi,
             ben_ext_rcd_in_file xrf,
             ben_ext_data_elmt_in_rcd xdr
    where xdr.ext_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xdr.ext_rcd_id   = xdr.ext_rcd_id
    and   xrf.sort2_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xrf.ext_file_id = xfi.ext_file_id;

  cursor c3 is
    select xfi.name
        from ben_ext_file xfi,
             ben_ext_rcd_in_file xrf,
             ben_ext_data_elmt_in_rcd xdr
    where xdr.ext_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xdr.ext_rcd_id   = xdr.ext_rcd_id
    and   xrf.sort3_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xrf.ext_file_id = xfi.ext_file_id;

  cursor c4 is
    select xfi.name
        from ben_ext_file xfi,
             ben_ext_rcd_in_file xrf,
             ben_ext_data_elmt_in_rcd xdr
    where xdr.ext_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xdr.ext_rcd_id   = xdr.ext_rcd_id
    and   xrf.sort4_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xrf.ext_file_id = xfi.ext_file_id;

  cursor c5 is
    select xfi.name
        from ben_ext_file xfi,
             ben_ext_rcd_in_file xrf,
             ben_ext_where_clause xwc
    where xwc.cond_ext_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id
    and   xwc.ext_rcd_in_file_id = xrf.ext_rcd_in_file_id
    and   xrf.ext_file_id = xfi.ext_file_id;

 l_name ben_ext_file.name%TYPE; -- UTF8 varchar2(100);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_EXT_RCD_IN_FILE_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DATA_ELMT_IN_RCD_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DATA_ELMT_IN_RCD_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_DATA_ELMT_IN_RCD_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_INCL_CHG_FK1') Then
    ben_utility.child_exists_error(p_table_name => 'BEN_EXT_INCL_CHG');
  ElsIf (p_constraint_name = 'BEN_EXT_WHERE_CLAUSE_FK3') Then
    fnd_message.set_name('BEN', 'BEN_92479_XWC_EXISTS');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RCD_IN_FILE_FK4') Then
    open c1;
    fetch c1 into l_name;
    close c1;
    fnd_message.set_name('BEN', 'BEN_92478_ELMT_REF_IN_SORT');
    fnd_message.set_token('FILE_NAME', l_name);
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RCD_IN_FILE_FK5') Then
    open c2;
    fetch c2 into l_name;
    close c2;
    fnd_message.set_name('BEN', 'BEN_92478_ELMT_REF_IN_SORT');
    fnd_message.set_token('FILE_NAME', l_name);
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RCD_IN_FILE_FK6') Then
    open c3;
    fetch c3 into l_name;
    close c3;
    fnd_message.set_name('BEN', 'BEN_92478_ELMT_REF_IN_SORT');
    fnd_message.set_token('FILE_NAME', l_name);
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_RCD_IN_FILE_FK7') Then
    open c4;
    fetch c4 into l_name;
    close c4;
    fnd_message.set_name('BEN', 'BEN_92478_ELMT_REF_IN_SORT');
    fnd_message.set_token('FILE_NAME', l_name);
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_EXT_WHERE_CLAUSE_FK6') Then
    open c5;
    fetch c5 into l_name;
    if c5%found then
      close c5;
      fnd_message.set_name('BEN', 'BEN_92480_XWC_EXISTS2');
      fnd_message.set_token('FILE_NAME', l_name);
      fnd_message.raise_error;
    else
      close c5;
      fnd_message.set_name('BEN', 'BEN_92479_XWC_EXISTS');
      fnd_message.raise_error;
    end if;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
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
  p_ext_data_elmt_in_rcd_id            in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		ext_data_elmt_in_rcd_id,
	seq_num,
	strt_pos,
	dlmtr_val,
	rqd_flag,
	sprs_cd,
	any_or_all_cd,
	ext_data_elmt_id,
	ext_rcd_id,
	business_group_id,
        legislation_code,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number,
	hide_flag
    from	ben_ext_data_elmt_in_rcd
    where	ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_ext_data_elmt_in_rcd_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_ext_data_elmt_in_rcd_id = g_old_rec.ext_data_elmt_in_rcd_id and
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
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
  p_ext_data_elmt_in_rcd_id            in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	ext_data_elmt_in_rcd_id,
	seq_num,
	strt_pos,
	dlmtr_val,
	rqd_flag,
	sprs_cd,
	any_or_all_cd,
	ext_data_elmt_id,
	ext_rcd_id,
	business_group_id,
        legislation_code,
        last_update_date,
        creation_date,
        last_updated_by,
        last_update_login,
        created_by ,
	object_version_number,
	hide_flag
    from	ben_ext_data_elmt_in_rcd
    where	ext_data_elmt_in_rcd_id = p_ext_data_elmt_in_rcd_id
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
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_ext_data_elmt_in_rcd');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ext_data_elmt_in_rcd_id       in number,
	p_seq_num                       in number,
	p_strt_pos                      in number,
	p_dlmtr_val                     in varchar2,
	p_rqd_flag                      in varchar2,
	p_sprs_cd                       in varchar2,
	p_any_or_all_cd                 in varchar2,
	p_ext_data_elmt_id              in number,
	p_ext_rcd_id                    in number,
	p_business_group_id             in number,
        p_legislation_code              in varchar2,
        p_last_update_date              in date,
        p_creation_date                 in date,
        p_last_updated_by               in number,
        p_last_update_login             in number,
        p_created_by                    in number,
	p_object_version_number         in number,
	p_hide_flag                     in varchar2
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
  l_rec.ext_data_elmt_in_rcd_id          := p_ext_data_elmt_in_rcd_id;
  l_rec.seq_num                          := p_seq_num;
  l_rec.strt_pos                         := p_strt_pos;
  l_rec.dlmtr_val                        := p_dlmtr_val;
  l_rec.rqd_flag                         := p_rqd_flag;
  l_rec.sprs_cd                          := p_sprs_cd;
  l_rec.any_or_all_cd                    := p_any_or_all_cd;
  l_rec.ext_data_elmt_id                 := p_ext_data_elmt_id;
  l_rec.ext_rcd_id                       := p_ext_rcd_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.last_update_date                 := p_last_update_date;
  l_rec.creation_date                    := p_creation_date;
  l_rec.last_updated_by                  := p_last_updated_by;
  l_rec.last_update_login                := p_last_update_login;
  l_rec.created_by                       := p_created_by;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.hide_flag                        := p_hide_flag;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_xer_shd;

/
