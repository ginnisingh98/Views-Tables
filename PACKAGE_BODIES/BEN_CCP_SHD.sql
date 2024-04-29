--------------------------------------------------------
--  DDL for Package Body BEN_CCP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CCP_SHD" as
/* $Header: beccprhi.pkb 120.1 2005/11/21 04:51:30 rbingi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ccp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CVRD_DPNT_PVD_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_CVRD_DPNT_PVD_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
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
  (p_effective_date		in date,
   p_cvrd_dpnt_ctfn_prvdd_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	cvrd_dpnt_ctfn_prvdd_id,
	effective_start_date,
	effective_end_date,
	dpnt_dsgn_ctfn_typ_cd,
	dpnt_dsgn_ctfn_rqd_flag,
	dpnt_dsgn_ctfn_recd_dt,
	elig_cvrd_dpnt_id,
	prtt_enrt_actn_id,
	business_group_id,
	ccp_attribute_category,
	ccp_attribute1,
	ccp_attribute2,
	ccp_attribute3,
	ccp_attribute4,
	ccp_attribute5,
	ccp_attribute6,
	ccp_attribute7,
	ccp_attribute8,
	ccp_attribute9,
	ccp_attribute10,
	ccp_attribute11,
	ccp_attribute12,
	ccp_attribute13,
	ccp_attribute14,
	ccp_attribute15,
	ccp_attribute16,
	ccp_attribute17,
	ccp_attribute18,
	ccp_attribute19,
	ccp_attribute20,
	ccp_attribute21,
	ccp_attribute22,
	ccp_attribute23,
	ccp_attribute24,
	ccp_attribute25,
	ccp_attribute26,
	ccp_attribute27,
	ccp_attribute28,
	ccp_attribute29,
	ccp_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from	ben_cvrd_dpnt_ctfn_prvdd_f
    where	cvrd_dpnt_ctfn_prvdd_id = p_cvrd_dpnt_ctfn_prvdd_id
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
      p_cvrd_dpnt_ctfn_prvdd_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cvrd_dpnt_ctfn_prvdd_id = g_old_rec.cvrd_dpnt_ctfn_prvdd_id and
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
  l_parent_key_value2	number;
  --
  Cursor C_Sel1 Is
    select  t.elig_cvrd_dpnt_id,
	    t.prtt_enrt_actn_id
    from    ben_cvrd_dpnt_ctfn_prvdd_f t
    where   t.cvrd_dpnt_ctfn_prvdd_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value2;
  If C_Sel1%notfound then
    Close C_Sel1;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_cvrd_dpnt_ctfn_prvdd_f',
	 p_base_key_column	=> 'cvrd_dpnt_ctfn_prvdd_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_elig_cvrd_dpnt_f',
	 p_parent_key_column1	=> 'elig_cvrd_dpnt_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ben_prtt_enrt_actn_f',
	 p_parent_key_column2	=> 'prtt_enrt_actn_id',
	 p_parent_key_value2	=> l_parent_key_value2,
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
	 p_base_table_name	=> 'ben_cvrd_dpnt_ctfn_prvdd_f',
	 p_base_key_column	=> 'cvrd_dpnt_ctfn_prvdd_id',
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
	(p_base_table_name	=> 'ben_cvrd_dpnt_ctfn_prvdd_f',
	 p_base_key_column	=> 'cvrd_dpnt_ctfn_prvdd_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_cvrd_dpnt_ctfn_prvdd_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.cvrd_dpnt_ctfn_prvdd_id	  = p_base_key_value
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
	 p_cvrd_dpnt_ctfn_prvdd_id	 in  number,
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
	cvrd_dpnt_ctfn_prvdd_id,
	effective_start_date,
	effective_end_date,
	dpnt_dsgn_ctfn_typ_cd,
	dpnt_dsgn_ctfn_rqd_flag,
	dpnt_dsgn_ctfn_recd_dt,
	elig_cvrd_dpnt_id,
	prtt_enrt_actn_id,
	business_group_id,
	ccp_attribute_category,
	ccp_attribute1,
	ccp_attribute2,
	ccp_attribute3,
	ccp_attribute4,
	ccp_attribute5,
	ccp_attribute6,
	ccp_attribute7,
	ccp_attribute8,
	ccp_attribute9,
	ccp_attribute10,
	ccp_attribute11,
	ccp_attribute12,
	ccp_attribute13,
	ccp_attribute14,
	ccp_attribute15,
	ccp_attribute16,
	ccp_attribute17,
	ccp_attribute18,
	ccp_attribute19,
	ccp_attribute20,
	ccp_attribute21,
	ccp_attribute22,
	ccp_attribute23,
	ccp_attribute24,
	ccp_attribute25,
	ccp_attribute26,
	ccp_attribute27,
	ccp_attribute28,
	ccp_attribute29,
	ccp_attribute30,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
    from    ben_cvrd_dpnt_ctfn_prvdd_f
    where   cvrd_dpnt_ctfn_prvdd_id         = p_cvrd_dpnt_ctfn_prvdd_id
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
                             p_argument       => 'cvrd_dpnt_ctfn_prvdd_id',
                             p_argument_value => p_cvrd_dpnt_ctfn_prvdd_id);
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
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
	 p_base_table_name	   => 'ben_cvrd_dpnt_ctfn_prvdd_f',
	 p_base_key_column	   => 'cvrd_dpnt_ctfn_prvdd_id',
	 p_base_key_value 	   => p_cvrd_dpnt_ctfn_prvdd_id,
	 p_parent_table_name1      => 'ben_elig_cvrd_dpnt_f',
	 p_parent_key_column1      => 'elig_cvrd_dpnt_id',
	 p_parent_key_value1       => g_old_rec.elig_cvrd_dpnt_id,
	 p_parent_table_name2      => 'ben_prtt_enrt_actn_f',
	 p_parent_key_column2      => 'prtt_enrt_actn_id',
	 p_parent_key_value2       => g_old_rec.prtt_enrt_actn_id,
         p_enforce_foreign_locking => false,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
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
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_cvrd_dpnt_ctfn_prvdd_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_cvrd_dpnt_ctfn_prvdd_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_cvrd_dpnt_ctfn_prvdd_id       in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_dpnt_dsgn_ctfn_typ_cd         in varchar2,
	p_dpnt_dsgn_ctfn_rqd_flag       in varchar2,
	p_dpnt_dsgn_ctfn_recd_dt        in date,
	p_elig_cvrd_dpnt_id             in number,
	p_prtt_enrt_actn_id             in number,
	p_business_group_id             in number,
	p_ccp_attribute_category        in varchar2,
	p_ccp_attribute1                in varchar2,
	p_ccp_attribute2                in varchar2,
	p_ccp_attribute3                in varchar2,
	p_ccp_attribute4                in varchar2,
	p_ccp_attribute5                in varchar2,
	p_ccp_attribute6                in varchar2,
	p_ccp_attribute7                in varchar2,
	p_ccp_attribute8                in varchar2,
	p_ccp_attribute9                in varchar2,
	p_ccp_attribute10               in varchar2,
	p_ccp_attribute11               in varchar2,
	p_ccp_attribute12               in varchar2,
	p_ccp_attribute13               in varchar2,
	p_ccp_attribute14               in varchar2,
	p_ccp_attribute15               in varchar2,
	p_ccp_attribute16               in varchar2,
	p_ccp_attribute17               in varchar2,
	p_ccp_attribute18               in varchar2,
	p_ccp_attribute19               in varchar2,
	p_ccp_attribute20               in varchar2,
	p_ccp_attribute21               in varchar2,
	p_ccp_attribute22               in varchar2,
	p_ccp_attribute23               in varchar2,
	p_ccp_attribute24               in varchar2,
	p_ccp_attribute25               in varchar2,
	p_ccp_attribute26               in varchar2,
	p_ccp_attribute27               in varchar2,
	p_ccp_attribute28               in varchar2,
	p_ccp_attribute29               in varchar2,
	p_ccp_attribute30               in varchar2,
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
  l_rec.cvrd_dpnt_ctfn_prvdd_id          := p_cvrd_dpnt_ctfn_prvdd_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.dpnt_dsgn_ctfn_typ_cd            := p_dpnt_dsgn_ctfn_typ_cd;
  l_rec.dpnt_dsgn_ctfn_rqd_flag          := p_dpnt_dsgn_ctfn_rqd_flag;
  l_rec.dpnt_dsgn_ctfn_recd_dt           := p_dpnt_dsgn_ctfn_recd_dt;
  l_rec.elig_cvrd_dpnt_id                := p_elig_cvrd_dpnt_id;
  l_rec.prtt_enrt_actn_id                := p_prtt_enrt_actn_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.ccp_attribute_category           := p_ccp_attribute_category;
  l_rec.ccp_attribute1                   := p_ccp_attribute1;
  l_rec.ccp_attribute2                   := p_ccp_attribute2;
  l_rec.ccp_attribute3                   := p_ccp_attribute3;
  l_rec.ccp_attribute4                   := p_ccp_attribute4;
  l_rec.ccp_attribute5                   := p_ccp_attribute5;
  l_rec.ccp_attribute6                   := p_ccp_attribute6;
  l_rec.ccp_attribute7                   := p_ccp_attribute7;
  l_rec.ccp_attribute8                   := p_ccp_attribute8;
  l_rec.ccp_attribute9                   := p_ccp_attribute9;
  l_rec.ccp_attribute10                  := p_ccp_attribute10;
  l_rec.ccp_attribute11                  := p_ccp_attribute11;
  l_rec.ccp_attribute12                  := p_ccp_attribute12;
  l_rec.ccp_attribute13                  := p_ccp_attribute13;
  l_rec.ccp_attribute14                  := p_ccp_attribute14;
  l_rec.ccp_attribute15                  := p_ccp_attribute15;
  l_rec.ccp_attribute16                  := p_ccp_attribute16;
  l_rec.ccp_attribute17                  := p_ccp_attribute17;
  l_rec.ccp_attribute18                  := p_ccp_attribute18;
  l_rec.ccp_attribute19                  := p_ccp_attribute19;
  l_rec.ccp_attribute20                  := p_ccp_attribute20;
  l_rec.ccp_attribute21                  := p_ccp_attribute21;
  l_rec.ccp_attribute22                  := p_ccp_attribute22;
  l_rec.ccp_attribute23                  := p_ccp_attribute23;
  l_rec.ccp_attribute24                  := p_ccp_attribute24;
  l_rec.ccp_attribute25                  := p_ccp_attribute25;
  l_rec.ccp_attribute26                  := p_ccp_attribute26;
  l_rec.ccp_attribute27                  := p_ccp_attribute27;
  l_rec.ccp_attribute28                  := p_ccp_attribute28;
  l_rec.ccp_attribute29                  := p_ccp_attribute29;
  l_rec.ccp_attribute30                  := p_ccp_attribute30;
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
end ben_ccp_shd;


/
