--------------------------------------------------------
--  DDL for Package Body BEN_LEN_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LEN_SHD" as
/* $Header: belenrhi.pkb 120.1.12000000.2 2007/05/13 22:46:27 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_len_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_LEE_RSN_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_LEE_RSN_F_PK') Then
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
  (p_effective_date		in date,
   p_lee_rsn_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	lee_rsn_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	popl_enrt_typ_cycl_id,
	ler_id,
	cls_enrt_dt_to_use_cd,
	dys_aftr_end_to_dflt_num,
	enrt_cvg_end_dt_cd,
	enrt_cvg_strt_dt_cd,
	enrt_perd_strt_dt_cd,
	enrt_perd_strt_dt_rl,
	enrt_perd_end_dt_cd,
	enrt_perd_end_dt_rl,
	addl_procg_dys_num,
	dys_no_enrl_not_elig_num,
	dys_no_enrl_cant_enrl_num,
	rt_end_dt_cd,
	rt_end_dt_rl,
	rt_strt_dt_cd,
	rt_strt_dt_rl,
	enrt_cvg_end_dt_rl,
	enrt_cvg_strt_dt_rl,
	len_attribute_category,
	len_attribute1,
	len_attribute2,
	len_attribute3,
	len_attribute4,
	len_attribute5,
	len_attribute6,
	len_attribute7,
	len_attribute8,
	len_attribute9,
	len_attribute10,
	len_attribute11,
	len_attribute12,
	len_attribute13,
	len_attribute14,
	len_attribute15,
	len_attribute16,
	len_attribute17,
	len_attribute18,
	len_attribute19,
	len_attribute20,
	len_attribute21,
	len_attribute22,
	len_attribute23,
	len_attribute24,
	len_attribute25,
	len_attribute26,
	len_attribute27,
	len_attribute28,
	len_attribute29,
	len_attribute30,
	object_version_number,
	enrt_perd_det_ovrlp_bckdt_cd,
	reinstate_cd,
	reinstate_ovrdn_cd ,
	ENRT_PERD_STRT_DAYS,
	ENRT_PERD_END_DAYS,
	defer_deenrol_flag
    from	ben_lee_rsn_f
    where	lee_rsn_id = p_lee_rsn_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_lee_rsn_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_lee_rsn_id = g_old_rec.lee_rsn_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      hr_utility.set_location(l_proc, 10);
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
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
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 out nocopy boolean,
	 p_delete	 out nocopy boolean,
	 p_future_change out nocopy boolean,
	 p_delete_next_change out nocopy boolean) is
--
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
--
  l_parent_key_value1	number;
  --
  Cursor C_Sel1 Is
    select  t.popl_enrt_typ_cycl_id
    from    ben_lee_rsn_f t
    where   t.lee_rsn_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_lee_rsn_f',
	 p_base_key_column	=> 'lee_rsn_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_popl_enrt_typ_cycl_f',
	 p_parent_key_column1	=> 'popl_enrt_typ_cycl_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction	 out nocopy boolean,
	 p_update	 out nocopy boolean,
	 p_update_override out nocopy boolean,
	 p_update_change_insert out nocopy boolean) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_lee_rsn_f',
	 p_base_key_column	=> 'lee_rsn_id',
	 p_base_key_value	=> p_base_key_value,
	 p_correction		=> p_correction,
	 p_update		=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number) is
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
	(p_base_table_name	=> 'ben_lee_rsn_f',
	 p_base_key_column	=> 'lee_rsn_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_lee_rsn_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.lee_rsn_id	  = p_base_key_value
  and	  p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_lee_rsn_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	lee_rsn_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	popl_enrt_typ_cycl_id,
	ler_id,
	cls_enrt_dt_to_use_cd,
	dys_aftr_end_to_dflt_num,
	enrt_cvg_end_dt_cd,
	enrt_cvg_strt_dt_cd,
	enrt_perd_strt_dt_cd,
	enrt_perd_strt_dt_rl,
	enrt_perd_end_dt_cd,
	enrt_perd_end_dt_rl,
	addl_procg_dys_num,
	dys_no_enrl_not_elig_num,
	dys_no_enrl_cant_enrl_num,
	rt_end_dt_cd,
	rt_end_dt_rl,
	rt_strt_dt_cd,
	rt_strt_dt_rl,
	enrt_cvg_end_dt_rl,
	enrt_cvg_strt_dt_rl,
	len_attribute_category,
	len_attribute1,
	len_attribute2,
	len_attribute3,
	len_attribute4,
	len_attribute5,
	len_attribute6,
	len_attribute7,
	len_attribute8,
	len_attribute9,
	len_attribute10,
	len_attribute11,
	len_attribute12,
	len_attribute13,
	len_attribute14,
	len_attribute15,
	len_attribute16,
	len_attribute17,
	len_attribute18,
	len_attribute19,
	len_attribute20,
	len_attribute21,
	len_attribute22,
	len_attribute23,
	len_attribute24,
	len_attribute25,
	len_attribute26,
	len_attribute27,
	len_attribute28,
	len_attribute29,
	len_attribute30,
	object_version_number ,
	enrt_perd_det_ovrlp_bckdt_cd,
	reinstate_cd,
	reinstate_ovrdn_cd  ,
	ENRT_PERD_STRT_DAYS  ,
	ENRT_PERD_END_DAYS,
	defer_deenrol_flag
    from    ben_lee_rsn_f
    where   lee_rsn_id         = p_lee_rsn_id
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
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'lee_rsn_id',
                             p_argument_value => p_lee_rsn_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
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
    hr_utility.set_location(l_proc, 15);
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_lee_rsn_f',
	 p_base_key_column	   => 'lee_rsn_id',
	 p_base_key_value 	   => p_lee_rsn_id,
	 p_parent_table_name1      => 'ben_popl_enrt_typ_cycl_f',
	 p_parent_key_column1      => 'popl_enrt_typ_cycl_id',
	 p_parent_key_value1       => g_old_rec.popl_enrt_typ_cycl_id,
--	 p_child_table_name1       => 'ben_lee_rsn_cm_f',
--	 p_child_key_column1       => 'lee_rsn_cm_id',
	 p_child_table_name2       => 'ben_lee_rsn_rl_f',
	 p_child_key_column2       => 'lee_rsn_rl_id',
--	 p_child_table_name3       => 'ben_pl_lee_rsn_ctfn_f',
--	 p_child_key_column3       => 'pl_lee_rsn_ctfn_id',
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'ben_lee_rsn_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ben_lee_rsn_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_lee_rsn_id                    in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_popl_enrt_typ_cycl_id         in number,
	p_ler_id                        in number,
	p_cls_enrt_dt_to_use_cd         in varchar2,
	p_dys_aftr_end_to_dflt_num      in number,
	p_enrt_cvg_end_dt_cd            in varchar2,
	p_enrt_cvg_strt_dt_cd           in varchar2,
	p_enrt_perd_strt_dt_cd          in varchar2,
	p_enrt_perd_strt_dt_rl          in number,
	p_enrt_perd_end_dt_cd           in varchar2,
	p_enrt_perd_end_dt_rl           in number,
	p_addl_procg_dys_num            in number,
	p_dys_no_enrl_not_elig_num      in number,
	p_dys_no_enrl_cant_enrl_num     in number,
	p_rt_end_dt_cd                  in varchar2,
	p_rt_end_dt_rl                  in number,
	p_rt_strt_dt_cd                 in varchar2,
	p_rt_strt_dt_rl                 in number,
	p_enrt_cvg_end_dt_rl            in number,
	p_enrt_cvg_strt_dt_rl           in number,
	p_len_attribute_category        in varchar2,
	p_len_attribute1                in varchar2,
	p_len_attribute2                in varchar2,
	p_len_attribute3                in varchar2,
	p_len_attribute4                in varchar2,
	p_len_attribute5                in varchar2,
	p_len_attribute6                in varchar2,
	p_len_attribute7                in varchar2,
	p_len_attribute8                in varchar2,
	p_len_attribute9                in varchar2,
	p_len_attribute10               in varchar2,
	p_len_attribute11               in varchar2,
	p_len_attribute12               in varchar2,
	p_len_attribute13               in varchar2,
	p_len_attribute14               in varchar2,
	p_len_attribute15               in varchar2,
	p_len_attribute16               in varchar2,
	p_len_attribute17               in varchar2,
	p_len_attribute18               in varchar2,
	p_len_attribute19               in varchar2,
	p_len_attribute20               in varchar2,
	p_len_attribute21               in varchar2,
	p_len_attribute22               in varchar2,
	p_len_attribute23               in varchar2,
	p_len_attribute24               in varchar2,
	p_len_attribute25               in varchar2,
	p_len_attribute26               in varchar2,
	p_len_attribute27               in varchar2,
	p_len_attribute28               in varchar2,
	p_len_attribute29               in varchar2,
	p_len_attribute30               in varchar2,
	p_object_version_number         in number ,
	p_enrt_perd_det_ovrlp_bckdt_cd               in varchar2,
	p_reinstate_cd			   in varchar2,
	p_reinstate_ovrdn_cd	   in varchar2 ,
	p_ENRT_PERD_STRT_DAYS	   in number ,
	p_ENRT_PERD_END_DAYS	   in number,
	p_defer_deenrol_flag       in varchar2
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
  l_rec.lee_rsn_id                       := p_lee_rsn_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.popl_enrt_typ_cycl_id            := p_popl_enrt_typ_cycl_id;
  l_rec.ler_id                           := p_ler_id;
  l_rec.cls_enrt_dt_to_use_cd            := p_cls_enrt_dt_to_use_cd;
  l_rec.dys_aftr_end_to_dflt_num         := p_dys_aftr_end_to_dflt_num;
  l_rec.enrt_cvg_end_dt_cd               := p_enrt_cvg_end_dt_cd;
  l_rec.enrt_cvg_strt_dt_cd              := p_enrt_cvg_strt_dt_cd;
  l_rec.enrt_perd_strt_dt_cd             := p_enrt_perd_strt_dt_cd;
  l_rec.enrt_perd_strt_dt_rl             := p_enrt_perd_strt_dt_rl;
  l_rec.enrt_perd_end_dt_cd              := p_enrt_perd_end_dt_cd;
  l_rec.enrt_perd_end_dt_rl              := p_enrt_perd_end_dt_rl;
  l_rec.addl_procg_dys_num               := p_addl_procg_dys_num;
  l_rec.dys_no_enrl_not_elig_num         := p_dys_no_enrl_not_elig_num;
  l_rec.dys_no_enrl_cant_enrl_num        := p_dys_no_enrl_cant_enrl_num;
  l_rec.rt_end_dt_cd                     := p_rt_end_dt_cd;
  l_rec.rt_end_dt_rl                     := p_rt_end_dt_rl;
  l_rec.rt_strt_dt_cd                    := p_rt_strt_dt_cd;
  l_rec.rt_strt_dt_rl                    := p_rt_strt_dt_rl;
  l_rec.enrt_cvg_end_dt_rl               := p_enrt_cvg_end_dt_rl;
  l_rec.enrt_cvg_strt_dt_rl              := p_enrt_cvg_strt_dt_rl;
  l_rec.len_attribute_category           := p_len_attribute_category;
  l_rec.len_attribute1                   := p_len_attribute1;
  l_rec.len_attribute2                   := p_len_attribute2;
  l_rec.len_attribute3                   := p_len_attribute3;
  l_rec.len_attribute4                   := p_len_attribute4;
  l_rec.len_attribute5                   := p_len_attribute5;
  l_rec.len_attribute6                   := p_len_attribute6;
  l_rec.len_attribute7                   := p_len_attribute7;
  l_rec.len_attribute8                   := p_len_attribute8;
  l_rec.len_attribute9                   := p_len_attribute9;
  l_rec.len_attribute10                  := p_len_attribute10;
  l_rec.len_attribute11                  := p_len_attribute11;
  l_rec.len_attribute12                  := p_len_attribute12;
  l_rec.len_attribute13                  := p_len_attribute13;
  l_rec.len_attribute14                  := p_len_attribute14;
  l_rec.len_attribute15                  := p_len_attribute15;
  l_rec.len_attribute16                  := p_len_attribute16;
  l_rec.len_attribute17                  := p_len_attribute17;
  l_rec.len_attribute18                  := p_len_attribute18;
  l_rec.len_attribute19                  := p_len_attribute19;
  l_rec.len_attribute20                  := p_len_attribute20;
  l_rec.len_attribute21                  := p_len_attribute21;
  l_rec.len_attribute22                  := p_len_attribute22;
  l_rec.len_attribute23                  := p_len_attribute23;
  l_rec.len_attribute24                  := p_len_attribute24;
  l_rec.len_attribute25                  := p_len_attribute25;
  l_rec.len_attribute26                  := p_len_attribute26;
  l_rec.len_attribute27                  := p_len_attribute27;
  l_rec.len_attribute28                  := p_len_attribute28;
  l_rec.len_attribute29                  := p_len_attribute29;
  l_rec.len_attribute30                  := p_len_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.enrt_perd_det_ovrlp_bckdt_cd     := p_enrt_perd_det_ovrlp_bckdt_cd;
  l_rec.reinstate_cd			 := p_reinstate_cd;
  l_rec.reinstate_ovrdn_cd		 := p_reinstate_ovrdn_cd;
  l_rec.ENRT_PERD_STRT_DAYS		 := p_ENRT_PERD_STRT_DAYS;
  l_rec.ENRT_PERD_END_DAYS		 := p_ENRT_PERD_END_DAYS;
  l_rec.defer_deenrol_flag		 := p_defer_deenrol_flag;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_len_shd;

/
