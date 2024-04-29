--------------------------------------------------------
--  DDL for Package Body BEN_PSQ_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PSQ_SHD" as
/* $Header: bepsqrhi.pkb 120.0 2005/05/28 11:20:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_psq_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_PYMT_SCHED_PY_FREQ_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
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
  (
  p_pymt_sched_py_freq_id              in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
		pymt_sched_py_freq_id,
	py_freq_cd,
	dflt_flag,
	business_group_id,
	acty_rt_pymt_sched_id,
	psq_attribute_category,
	psq_attribute1,
	psq_attribute2,
	psq_attribute3,
	psq_attribute4,
	psq_attribute5,
	psq_attribute6,
	psq_attribute7,
	psq_attribute8,
	psq_attribute9,
	psq_attribute10,
	psq_attribute11,
	psq_attribute12,
	psq_attribute13,
	psq_attribute14,
	psq_attribute15,
	psq_attribute16,
	psq_attribute17,
	psq_attribute18,
	psq_attribute19,
	psq_attribute20,
	psq_attribute21,
	psq_attribute22,
	psq_attribute23,
	psq_attribute24,
	psq_attribute25,
	psq_attribute26,
	psq_attribute27,
	psq_attribute28,
	psq_attribute29,
	psq_attribute30,
	object_version_number
    from	ben_pymt_sched_py_freq
    where	pymt_sched_py_freq_id = p_pymt_sched_py_freq_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_pymt_sched_py_freq_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_pymt_sched_py_freq_id = g_old_rec.pymt_sched_py_freq_id and
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
  p_pymt_sched_py_freq_id              in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select 	pymt_sched_py_freq_id,
	py_freq_cd,
	dflt_flag,
	business_group_id,
	acty_rt_pymt_sched_id,
	psq_attribute_category,
	psq_attribute1,
	psq_attribute2,
	psq_attribute3,
	psq_attribute4,
	psq_attribute5,
	psq_attribute6,
	psq_attribute7,
	psq_attribute8,
	psq_attribute9,
	psq_attribute10,
	psq_attribute11,
	psq_attribute12,
	psq_attribute13,
	psq_attribute14,
	psq_attribute15,
	psq_attribute16,
	psq_attribute17,
	psq_attribute18,
	psq_attribute19,
	psq_attribute20,
	psq_attribute21,
	psq_attribute22,
	psq_attribute23,
	psq_attribute24,
	psq_attribute25,
	psq_attribute26,
	psq_attribute27,
	psq_attribute28,
	psq_attribute29,
	psq_attribute30,
	object_version_number
    from	ben_pymt_sched_py_freq
    where	pymt_sched_py_freq_id = p_pymt_sched_py_freq_id
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
    fnd_message.set_token('TABLE_NAME', 'ben_pymt_sched_py_freq');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_pymt_sched_py_freq_id         in number,
	p_py_freq_cd                    in varchar2,
	p_dflt_flag                     in varchar2,
	p_business_group_id             in number,
	p_acty_rt_pymt_sched_id         in number,
	p_psq_attribute_category        in varchar2,
	p_psq_attribute1                in varchar2,
	p_psq_attribute2                in varchar2,
	p_psq_attribute3                in varchar2,
	p_psq_attribute4                in varchar2,
	p_psq_attribute5                in varchar2,
	p_psq_attribute6                in varchar2,
	p_psq_attribute7                in varchar2,
	p_psq_attribute8                in varchar2,
	p_psq_attribute9                in varchar2,
	p_psq_attribute10               in varchar2,
	p_psq_attribute11               in varchar2,
	p_psq_attribute12               in varchar2,
	p_psq_attribute13               in varchar2,
	p_psq_attribute14               in varchar2,
	p_psq_attribute15               in varchar2,
	p_psq_attribute16               in varchar2,
	p_psq_attribute17               in varchar2,
	p_psq_attribute18               in varchar2,
	p_psq_attribute19               in varchar2,
	p_psq_attribute20               in varchar2,
	p_psq_attribute21               in varchar2,
	p_psq_attribute22               in varchar2,
	p_psq_attribute23               in varchar2,
	p_psq_attribute24               in varchar2,
	p_psq_attribute25               in varchar2,
	p_psq_attribute26               in varchar2,
	p_psq_attribute27               in varchar2,
	p_psq_attribute28               in varchar2,
	p_psq_attribute29               in varchar2,
	p_psq_attribute30               in varchar2,
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
  l_rec.pymt_sched_py_freq_id            := p_pymt_sched_py_freq_id;
  l_rec.py_freq_cd                       := p_py_freq_cd;
  l_rec.dflt_flag                        := p_dflt_flag;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.acty_rt_pymt_sched_id            := p_acty_rt_pymt_sched_id;
  l_rec.psq_attribute_category           := p_psq_attribute_category;
  l_rec.psq_attribute1                   := p_psq_attribute1;
  l_rec.psq_attribute2                   := p_psq_attribute2;
  l_rec.psq_attribute3                   := p_psq_attribute3;
  l_rec.psq_attribute4                   := p_psq_attribute4;
  l_rec.psq_attribute5                   := p_psq_attribute5;
  l_rec.psq_attribute6                   := p_psq_attribute6;
  l_rec.psq_attribute7                   := p_psq_attribute7;
  l_rec.psq_attribute8                   := p_psq_attribute8;
  l_rec.psq_attribute9                   := p_psq_attribute9;
  l_rec.psq_attribute10                  := p_psq_attribute10;
  l_rec.psq_attribute11                  := p_psq_attribute11;
  l_rec.psq_attribute12                  := p_psq_attribute12;
  l_rec.psq_attribute13                  := p_psq_attribute13;
  l_rec.psq_attribute14                  := p_psq_attribute14;
  l_rec.psq_attribute15                  := p_psq_attribute15;
  l_rec.psq_attribute16                  := p_psq_attribute16;
  l_rec.psq_attribute17                  := p_psq_attribute17;
  l_rec.psq_attribute18                  := p_psq_attribute18;
  l_rec.psq_attribute19                  := p_psq_attribute19;
  l_rec.psq_attribute20                  := p_psq_attribute20;
  l_rec.psq_attribute21                  := p_psq_attribute21;
  l_rec.psq_attribute22                  := p_psq_attribute22;
  l_rec.psq_attribute23                  := p_psq_attribute23;
  l_rec.psq_attribute24                  := p_psq_attribute24;
  l_rec.psq_attribute25                  := p_psq_attribute25;
  l_rec.psq_attribute26                  := p_psq_attribute26;
  l_rec.psq_attribute27                  := p_psq_attribute27;
  l_rec.psq_attribute28                  := p_psq_attribute28;
  l_rec.psq_attribute29                  := p_psq_attribute29;
  l_rec.psq_attribute30                  := p_psq_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_psq_shd;

/
