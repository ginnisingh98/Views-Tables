--------------------------------------------------------
--  DDL for Package Body BEN_PRC_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRC_SHD" as
/* $Header: beprcrhi.pkb 120.7.12010000.2 2008/08/05 15:19:06 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prc_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PRTT_REIMBMT_RQST_F_DT6') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PRTT_REIMBMT_RQST_F_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PRTT_REIMBMT_RQST_F_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_PRTT_REIMBMT_RQST_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
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
   p_prtt_reimbmt_rqst_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	prtt_reimbmt_rqst_id,
	effective_start_date,
	effective_end_date,
	incrd_from_dt,
	incrd_to_dt,
	rqst_num,
	rqst_amt,
	rqst_amt_uom,
	rqst_btch_num,
	prtt_reimbmt_rqst_stat_cd,
	reimbmt_ctfn_typ_prvdd_cd,
	rcrrg_cd,
	submitter_person_id,
	recipient_person_id,
	provider_person_id,
	provider_ssn_person_id,
	pl_id,
	gd_or_svc_typ_id,
	contact_relationship_id,
	business_group_id,
        opt_id,
        popl_yr_perd_id_1,
        popl_yr_perd_id_2 ,
        amt_year1 ,
        amt_year2,
	prc_attribute_category,
	prc_attribute1,
	prc_attribute2,
	prc_attribute3,
	prc_attribute4,
	prc_attribute5,
	prc_attribute6,
	prc_attribute7,
	prc_attribute8,
	prc_attribute9,
	prc_attribute10,
	prc_attribute11,
	prc_attribute12,
	prc_attribute13,
	prc_attribute14,
	prc_attribute15,
	prc_attribute16,
	prc_attribute17,
	prc_attribute18,
	prc_attribute19,
	prc_attribute20,
	prc_attribute21,
	prc_attribute22,
	prc_attribute23,
	prc_attribute24,
	prc_attribute25,
	prc_attribute26,
	prc_attribute27,
	prc_attribute28,
	prc_attribute29,
	prc_attribute30,
        prtt_enrt_rslt_id ,
        comment_id  ,
	object_version_number	,
        stat_rsn_cd                    ,
        pymt_stat_cd                   ,
        pymt_stat_rsn_cd               ,
        stat_ovrdn_flag                ,
        stat_ovrdn_rsn_cd              ,
        stat_prr_to_ovrd               ,
        pymt_stat_ovrdn_flag           ,
        pymt_stat_ovrdn_rsn_cd         ,
        pymt_stat_prr_to_ovrd          ,
        adjmt_flag                     ,
        submtd_dt                      ,
        ttl_rqst_amt                   ,
        aprvd_for_pymt_amt             ,
        null,
        exp_incurd_dt
    from	ben_prtt_reimbmt_rqst_f
    where	prtt_reimbmt_rqst_id = p_prtt_reimbmt_rqst_id
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
      p_prtt_reimbmt_rqst_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_prtt_reimbmt_rqst_id = g_old_rec.prtt_reimbmt_rqst_id and
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
  --
  Cursor C_Sel1 Is
    select  t.pl_id
    from    ben_prtt_reimbmt_rqst_f t
    where   t.prtt_reimbmt_rqst_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1;
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
	 p_base_table_name	=> 'ben_prtt_reimbmt_rqst_f',
	 p_base_key_column	=> 'prtt_reimbmt_rqst_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_pl_f',
	 p_parent_key_column1	=> 'pl_id',
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
	 p_base_table_name	=> 'ben_prtt_reimbmt_rqst_f',
	 p_base_key_column	=> 'prtt_reimbmt_rqst_id',
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
	(p_base_table_name	=> 'ben_prtt_reimbmt_rqst_f',
	 p_base_key_column	=> 'prtt_reimbmt_rqst_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_prtt_reimbmt_rqst_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.prtt_reimbmt_rqst_id	  = p_base_key_value
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
	 p_prtt_reimbmt_rqst_id	 in  number,
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
	prtt_reimbmt_rqst_id,
	effective_start_date,
	effective_end_date,
	incrd_from_dt,
	incrd_to_dt,
	rqst_num,
	rqst_amt,
	rqst_amt_uom,
	rqst_btch_num,
	prtt_reimbmt_rqst_stat_cd,
	reimbmt_ctfn_typ_prvdd_cd,
	rcrrg_cd,
	submitter_person_id,
	recipient_person_id,
	provider_person_id,
	provider_ssn_person_id,
	pl_id,
	gd_or_svc_typ_id,
	contact_relationship_id,
	business_group_id,
        opt_id,
        popl_yr_perd_id_1,
        popl_yr_perd_id_2 ,
        amt_year1 ,
        amt_year2,
	prc_attribute_category,
	prc_attribute1,
	prc_attribute2,
	prc_attribute3,
	prc_attribute4,
	prc_attribute5,
	prc_attribute6,
	prc_attribute7,
	prc_attribute8,
	prc_attribute9,
	prc_attribute10,
	prc_attribute11,
	prc_attribute12,
	prc_attribute13,
	prc_attribute14,
	prc_attribute15,
	prc_attribute16,
	prc_attribute17,
	prc_attribute18,
	prc_attribute19,
	prc_attribute20,
	prc_attribute21,
	prc_attribute22,
	prc_attribute23,
	prc_attribute24,
	prc_attribute25,
	prc_attribute26,
	prc_attribute27,
	prc_attribute28,
	prc_attribute29,
	prc_attribute30,
        prtt_enrt_rslt_id,
        comment_id ,
	object_version_number ,
        stat_rsn_cd                    ,
        pymt_stat_cd                   ,
        pymt_stat_rsn_cd               ,
        stat_ovrdn_flag                ,
        stat_ovrdn_rsn_cd              ,
        stat_prr_to_ovrd               ,
        pymt_stat_ovrdn_flag           ,
        pymt_stat_ovrdn_rsn_cd         ,
        pymt_stat_prr_to_ovrd          ,
        adjmt_flag                     ,
        submtd_dt                      ,
        ttl_rqst_amt                   ,
        aprvd_for_pymt_amt             ,
        null ,
        exp_incurd_dt
    from    ben_prtt_reimbmt_rqst_f
    where   prtt_reimbmt_rqst_id         = p_prtt_reimbmt_rqst_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('reimb rq id :'||p_prtt_reimbmt_rqst_id, 5);
  hr_utility.set_location('effct dt '||p_effective_date, 5);
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
                             p_argument       => 'prtt_reimbmt_rqst_id',
                             p_argument_value => p_prtt_reimbmt_rqst_id);
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
	 p_base_table_name	   => 'ben_prtt_reimbmt_rqst_f',
	 p_base_key_column	   => 'prtt_reimbmt_rqst_id',
	 p_base_key_value 	   => p_prtt_reimbmt_rqst_id,
	 p_parent_table_name1      => 'ben_pl_f',
	 p_parent_key_column1      => 'pl_id',
	 p_parent_key_value1       => g_old_rec.pl_id,
         p_enforce_foreign_locking => false , --true,
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
    fnd_message.set_token('TABLE_NAME', 'ben_prtt_reimbmt_rqst_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_prtt_reimbmt_rqst_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_prtt_reimbmt_rqst_id          in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_incrd_from_dt                 in date,
	p_incrd_to_dt                   in date,
	p_rqst_num                      in number,
	p_rqst_amt                      in number,
	p_rqst_amt_uom                  in varchar2,
	p_rqst_btch_num                 in number,
	p_prtt_reimbmt_rqst_stat_cd     in varchar2,
	p_reimbmt_ctfn_typ_prvdd_cd     in varchar2,
	p_rcrrg_cd                      in varchar2,
	p_submitter_person_id           in number,
	p_recipient_person_id           in number,
	p_provider_person_id            in number,
	p_provider_ssn_person_id        in number,
	p_pl_id                         in number,
	p_gd_or_svc_typ_id              in number,
	p_contact_relationship_id       in number,
	p_business_group_id             in number,
        p_opt_id                        in number,
        p_popl_yr_perd_id_1             in number,
        p_popl_yr_perd_id_2             in number,
        p_amt_year1                     in number ,
        p_amt_year2                     in number,
	p_prc_attribute_category        in varchar2,
	p_prc_attribute1                in varchar2,
	p_prc_attribute2                in varchar2,
	p_prc_attribute3                in varchar2,
	p_prc_attribute4                in varchar2,
	p_prc_attribute5                in varchar2,
	p_prc_attribute6                in varchar2,
	p_prc_attribute7                in varchar2,
	p_prc_attribute8                in varchar2,
	p_prc_attribute9                in varchar2,
	p_prc_attribute10               in varchar2,
	p_prc_attribute11               in varchar2,
	p_prc_attribute12               in varchar2,
	p_prc_attribute13               in varchar2,
	p_prc_attribute14               in varchar2,
	p_prc_attribute15               in varchar2,
	p_prc_attribute16               in varchar2,
	p_prc_attribute17               in varchar2,
	p_prc_attribute18               in varchar2,
	p_prc_attribute19               in varchar2,
	p_prc_attribute20               in varchar2,
	p_prc_attribute21               in varchar2,
	p_prc_attribute22               in varchar2,
	p_prc_attribute23               in varchar2,
	p_prc_attribute24               in varchar2,
	p_prc_attribute25               in varchar2,
	p_prc_attribute26               in varchar2,
	p_prc_attribute27               in varchar2,
	p_prc_attribute28               in varchar2,
	p_prc_attribute29               in varchar2,
	p_prc_attribute30               in varchar2,
        p_prtt_enrt_rslt_id             in number ,
        p_comment_id                    in number ,
        p_object_version_number         in number ,
        p_stat_rsn_cd                    in varchar2  ,
        p_pymt_stat_cd                   in varchar2  ,
        p_pymt_stat_rsn_cd               in varchar2  ,
        p_stat_ovrdn_flag                in varchar2  ,
        p_stat_ovrdn_rsn_cd              in varchar2  ,
        p_stat_prr_to_ovrd               in varchar2  ,
        p_pymt_stat_ovrdn_flag           in varchar2  ,
        p_pymt_stat_ovrdn_rsn_cd         in varchar2  ,
        p_pymt_stat_prr_to_ovrd          in varchar2  ,
        p_adjmt_flag                     in varchar2  ,
        p_submtd_dt                      in date  ,
        p_ttl_rqst_amt                   in  number    ,
        p_aprvd_for_pymt_amt             in  number    ,
        p_pymt_amount                    in  number    ,
        p_exp_incurd_dt			 in date
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
  l_rec.prtt_reimbmt_rqst_id             := p_prtt_reimbmt_rqst_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.incrd_from_dt                    := p_incrd_from_dt;
  l_rec.incrd_to_dt                      := p_incrd_to_dt;
  l_rec.rqst_num                         := p_rqst_num;
  l_rec.rqst_amt                         := p_rqst_amt;
  l_rec.rqst_amt_uom                     := p_rqst_amt_uom;
  l_rec.rqst_btch_num                    := p_rqst_btch_num;
  l_rec.prtt_reimbmt_rqst_stat_cd        := p_prtt_reimbmt_rqst_stat_cd;
  l_rec.reimbmt_ctfn_typ_prvdd_cd        := p_reimbmt_ctfn_typ_prvdd_cd;
  l_rec.rcrrg_cd                         := p_rcrrg_cd;
  l_rec.submitter_person_id              := p_submitter_person_id;
  l_rec.recipient_person_id              := p_recipient_person_id;
  l_rec.provider_person_id               := p_provider_person_id;
  l_rec.provider_ssn_person_id           := p_provider_ssn_person_id;
  l_rec.pl_id                            := p_pl_id;
  l_rec.gd_or_svc_typ_id                 := p_gd_or_svc_typ_id;
  l_rec.contact_relationship_id          := p_contact_relationship_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.opt_id                         :=  p_opt_id;
  l_rec.popl_yr_perd_id_1              :=  p_popl_yr_perd_id_1;
  l_rec.popl_yr_perd_id_2              :=  p_popl_yr_perd_id_2;
  l_rec.amt_year1                      :=  p_amt_year1;
  l_rec.amt_year2                      :=  p_amt_year2;
  l_rec.prc_attribute_category           := p_prc_attribute_category;
  l_rec.prc_attribute1                   := p_prc_attribute1;
  l_rec.prc_attribute2                   := p_prc_attribute2;
  l_rec.prc_attribute3                   := p_prc_attribute3;
  l_rec.prc_attribute4                   := p_prc_attribute4;
  l_rec.prc_attribute5                   := p_prc_attribute5;
  l_rec.prc_attribute6                   := p_prc_attribute6;
  l_rec.prc_attribute7                   := p_prc_attribute7;
  l_rec.prc_attribute8                   := p_prc_attribute8;
  l_rec.prc_attribute9                   := p_prc_attribute9;
  l_rec.prc_attribute10                  := p_prc_attribute10;
  l_rec.prc_attribute11                  := p_prc_attribute11;
  l_rec.prc_attribute12                  := p_prc_attribute12;
  l_rec.prc_attribute13                  := p_prc_attribute13;
  l_rec.prc_attribute14                  := p_prc_attribute14;
  l_rec.prc_attribute15                  := p_prc_attribute15;
  l_rec.prc_attribute16                  := p_prc_attribute16;
  l_rec.prc_attribute17                  := p_prc_attribute17;
  l_rec.prc_attribute18                  := p_prc_attribute18;
  l_rec.prc_attribute19                  := p_prc_attribute19;
  l_rec.prc_attribute20                  := p_prc_attribute20;
  l_rec.prc_attribute21                  := p_prc_attribute21;
  l_rec.prc_attribute22                  := p_prc_attribute22;
  l_rec.prc_attribute23                  := p_prc_attribute23;
  l_rec.prc_attribute24                  := p_prc_attribute24;
  l_rec.prc_attribute25                  := p_prc_attribute25;
  l_rec.prc_attribute26                  := p_prc_attribute26;
  l_rec.prc_attribute27                  := p_prc_attribute27;
  l_rec.prc_attribute28                  := p_prc_attribute28;
  l_rec.prc_attribute29                  := p_prc_attribute29;
  l_rec.prc_attribute30                  := p_prc_attribute30;
  l_rec.prtt_enrt_rslt_id                := p_prtt_enrt_rslt_id ;
  l_rec.comment_id                       := p_comment_id        ;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.stat_rsn_cd                    := p_stat_rsn_cd ;
  l_rec.pymt_stat_cd                   := p_pymt_stat_cd ;
  l_rec.pymt_stat_rsn_cd               := p_pymt_stat_rsn_cd ;
  l_rec.stat_ovrdn_flag                := p_stat_ovrdn_flag ;
  l_rec.stat_ovrdn_rsn_cd              := p_stat_ovrdn_rsn_cd ;
  l_rec.stat_prr_to_ovrd               := p_stat_prr_to_ovrd ;
  l_rec.pymt_stat_ovrdn_flag           := p_pymt_stat_ovrdn_flag ;
  l_rec.pymt_stat_ovrdn_rsn_cd         := p_pymt_stat_ovrdn_rsn_cd ;
  l_rec.pymt_stat_prr_to_ovrd          := p_pymt_stat_prr_to_ovrd ;
  l_rec.adjmt_flag                     := p_adjmt_flag ;
  l_rec.submtd_dt                      := p_submtd_dt ;
  l_rec.ttl_rqst_amt                   := p_ttl_rqst_amt ;
  l_rec.aprvd_for_pymt_amt             := p_aprvd_for_pymt_amt ;
  l_rec.pymt_amount                    := p_pymt_amount ;
  l_rec.exp_incurd_dt                    := p_exp_incurd_dt ;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_prc_shd;

/
