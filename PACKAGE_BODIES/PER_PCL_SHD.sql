--------------------------------------------------------
--  DDL for Package Body PER_PCL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PCL_SHD" AS
/* $Header: pepclrhi.pkb 115.9 2002/12/09 15:33:43 pkakar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pcl_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< non_value_category >---------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION non_value_category
  (p_category_name IN VARCHAR2) RETURN BOOLEAN IS
  --
  -- Declare Local Variables
  --
  l_proc         VARCHAR2(72) := g_package || 'non_value_category';
  l_return_value BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- If the category is such that the value field
  -- should not be populated then return false
  --
  IF p_category_name IN ('PYS','POS','PRO') THEN
    --
	l_return_value := TRUE;
	--
	hr_utility.set_location(l_proc, 20);
	--
  ELSE
    --
	l_return_value := FALSE;
	--
	hr_utility.set_location(l_proc, 30);
	--
  END IF;
  --
  hr_utility.set_location('Leaving :'||l_proc, 999);
  --
  RETURN(l_return_value);
  --
END non_value_category;
--
-- ----------------------------------------------------------------------------
-- |----------------------< retrieve_entitlement_info >-----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE retrieve_entitlement_item_info
  (p_cagr_entitlement_id      IN     NUMBER
  ,p_cagr_entitlement_item_id    OUT NOCOPY NUMBER
  ,p_category_name               OUT NOCOPY VARCHAR2
  ,p_formula_criteria            OUT NOCOPY VARCHAR2)IS
  --
  -- Cursor to fetch the entitlement_item_id and category_name
  --
  CURSOR csr_get_entitlement_item_id IS
    SELECT pce.cagr_entitlement_item_id,
	       pci.category_name,
		   pce.formula_criteria
	FROM   per_cagr_entitlements pce,
	       per_cagr_entitlement_items pci
	WHERE  pci.cagr_entitlement_item_id = pce.cagr_entitlement_item_id
	AND    pce.cagr_entitlement_id      = p_cagr_entitlement_id;
  --
  -- Declare Local Variables
  --
  l_proc VARCHAR2(72) := g_package||'retrieve_entitlement_item_info';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	      => l_proc
    ,p_argument	      => 'CAGR_ENTITLEMENT_ID'
    ,p_argument_value => p_cagr_entitlement_id);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Retrieve the entitlement_item_id
  --
  OPEN csr_get_entitlement_item_id;
  FETCH csr_get_entitlement_item_id INTO p_cagr_entitlement_item_id,
                                         p_category_name,
										 p_formula_criteria;
  --
  IF csr_get_entitlement_item_id%NOTFOUND THEN
    --
    hr_utility.set_location(l_proc, 30);
    --
	CLOSE csr_get_entitlement_item_id;
	--
	hr_utility.set_message(800, 'HR_289330_ENT_ITEM_NOT_FOUND');
    hr_utility.raise_error;
	--
  END IF;
  --
  hr_utility.set_location(l_proc, 40);
  --
  CLOSE csr_get_entitlement_item_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 999);
  --
END retrieve_entitlement_item_info;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< retrieve_cagr_info >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE retrieve_cagr_info
  (p_cagr_entitlement_id     IN     NUMBER
  ,p_collective_agreement_id    OUT NOCOPY NUMBER
  ,p_business_group_id          OUT NOCOPY NUMBER) IS
  --
  -- Declare Local Cursors
  --
  CURSOR csr_cagr_info IS
    SELECT cag.collective_agreement_id,
               cag.business_group_id
        FROM   per_cagr_entitlements pce,
               per_collective_agreements cag
        WHERE  cag.collective_agreement_id = pce.collective_agreement_id
        AND    pce.cagr_entitlement_id     = p_cagr_entitlement_id;
  --
  -- Declare Local Variables
  --
  l_proc VARCHAR2(72) := g_package || 'retrieve_cagr_info';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'CAGR_ENTITLEMENT_ID'
    ,p_argument_value => p_cagr_entitlement_id);
  --
  OPEN csr_cagr_info;
  FETCH csr_cagr_info INTO p_collective_agreement_id, p_business_group_id;
  --
  IF csr_cagr_info%NOTFOUND THEN
    --
        CLOSE csr_cagr_info;
        --
        hr_utility.set_message(800, 'HR_289345_CAGR_REC_INV');
    hr_utility.raise_error;
        --
  ELSE
    --
        CLOSE csr_cagr_info;
        --
  END IF;
  --
  hr_utility.set_location('Leaving :'||l_proc, 999);
  --
END retrieve_cagr_info;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< retrieve_value_set_id >------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION retrieve_value_set_id
  (p_cagr_entitlement_item_id IN per_cagr_entitlements.cagr_entitlement_item_id%TYPE)
  RETURN NUMBER IS
  --
  -- Declare Local Variables
  --
  l_flex_value_set_id per_cagr_entitlement_items.flex_value_set_id%TYPE;
  l_proc VARCHAR2(72) := g_package || 'retrieve_value_set_id';
  --
  -- Cursor to fetch the entitlement_item_id
  -- that entitlement_line is for.
  --
  CURSOR csr_get_value_set_id IS
    SELECT flex_value_set_id
	FROM   per_cagr_entitlement_items cei
	WHERE  cei.cagr_entitlement_item_Id = P_cagr_entitlement_item_id
	AND    cei.flex_value_set_id IS NOT NULL;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters has been set
  --
  hr_api.mandatory_arg_error
    (p_api_name	      => l_proc
    ,p_argument	      => 'CAGR_ENTITLEMENT_ITEM_ID'
    ,p_argument_value => p_cagr_entitlement_item_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  OPEN csr_get_value_set_id;
  FETCH csr_get_value_set_id INTO l_flex_value_set_id;
  --
  hr_utility.set_location(l_proc, 30);
  --
  CLOSE csr_get_value_set_id;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  RETURN(l_flex_value_set_id);
  --
END retrieve_value_set_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PER_CAGR_ENTITLEMENT_LINES_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_CAGR_ENTITLEMENT_LINES_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PER_CAGR_ENTITLEMENT_LINES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date                   in date
  ,p_cagr_entitlement_line_id         in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     cagr_entitlement_line_id
    ,cagr_entitlement_id
    ,mandatory
    ,value
    ,range_from
    ,range_to
    ,effective_start_date
    ,effective_end_date
    ,parent_spine_id
    ,step_id
    ,from_step_id
    ,to_step_id
    ,status
    ,oipl_id
    ,object_version_number
    ,grade_spine_id
    ,eligy_prfl_id
    from        per_cagr_entitlement_lines_f
    where       cagr_entitlement_line_id = p_cagr_entitlement_line_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_cagr_entitlement_line_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cagr_entitlement_line_id =
        per_pcl_shd.g_old_rec.cagr_entitlement_line_id and
        p_object_version_number =
        per_pcl_shd.g_old_rec.object_version_number
) Then
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
      Fetch C_Sel1 Into per_pcl_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> per_pcl_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_correction             out nocopy boolean
  ,p_update                 out nocopy boolean
  ,p_update_override        out nocopy boolean
  ,p_update_change_insert   out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'per_cagr_entitlement_lines_f'
    ,p_base_key_column       => 'cagr_entitlement_line_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
  (p_effective_date        in date
  ,p_base_key_value        in number
  ,p_zap                   out nocopy boolean
  ,p_delete                out nocopy boolean
  ,p_future_change         out nocopy boolean
  ,p_delete_next_change    out nocopy boolean
  ) is
  --
  l_proc                varchar2(72)    := g_package||'find_dt_del_modes';
  --
  l_parent_key_value1     number;
  l_parent_key_value2     number;
  l_parent_key_value3     number;
  l_parent_key_value4     number;
  --
  Cursor C_Sel1 Is
    select
     t.grade_spine_id
    ,t.step_id
    ,t.from_step_id
    ,t.to_step_id
    from   per_cagr_entitlement_lines_f t
    where  t.cagr_entitlement_line_id = p_base_key_value
    and    p_effective_date
    between t.effective_start_date and t.effective_end_date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open C_sel1;
  Fetch C_Sel1 Into
     l_parent_key_value1
    ,l_parent_key_value2
    ,l_parent_key_value3
    ,l_parent_key_value4;
  If C_Sel1%NOTFOUND then
    Close C_Sel1;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE',l_proc);
     fnd_message.set_token('STEP','10');
     fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'per_cagr_entitlement_lines_f'
   ,p_base_key_column               => 'cagr_entitlement_line_id'
   ,p_base_key_value                => p_base_key_value
   ,p_parent_table_name1            => 'per_grade_spines_f'
   ,p_parent_key_column1            => 'grade_spine_id'
   ,p_parent_key_value1             => l_parent_key_value1
   ,p_parent_table_name2            => 'per_spinal_point_steps_f'
   ,p_parent_key_column2            => 'step_id'
   ,p_parent_key_value2             => l_parent_key_value2
   ,p_parent_table_name3            => 'per_spinal_point_steps_f'
   ,p_parent_key_column3            => 'step_id'
   ,p_parent_key_value3             => l_parent_key_value3
   ,p_parent_table_name4            => 'per_spinal_point_steps_f'
   ,p_parent_key_column4            => 'step_id'
   ,p_parent_key_value4             => l_parent_key_value4
   ,p_zap                           => p_zap
   ,p_delete                        => p_delete
   ,p_future_change                 => p_future_change
   ,p_delete_next_change            => p_delete_next_change
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
  (p_effective_date                   in date
  ,p_base_key_value                   in number
  ,p_new_effective_end_date           in date
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ,p_object_version_number  out nocopy number
  ) is
--
  l_proc                  varchar2(72) := g_package||'upd_effective_end_date';
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
      (p_base_table_name    => 'per_cagr_entitlement_lines_f'
      ,p_base_key_column    => 'cagr_entitlement_line_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  per_cagr_entitlement_lines_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.cagr_entitlement_line_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_cagr_entitlement_line_id         in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_argument              varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     cagr_entitlement_line_id
    ,cagr_entitlement_id
    ,mandatory
    ,value
    ,range_from
    ,range_to
    ,effective_start_date
    ,effective_end_date
    ,parent_spine_id
    ,step_id
    ,from_step_id
    ,to_step_id
    ,status
    ,oipl_id
    ,object_version_number
    ,grade_spine_id
    ,eligy_prfl_id
    from    per_cagr_entitlement_lines_f
    where   cagr_entitlement_line_id = p_cagr_entitlement_line_id
    and     p_effective_date
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
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'effective_date'
                            ,p_argument_value => p_effective_date
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'datetrack_mode'
                            ,p_argument_value => p_datetrack_mode
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'cagr_entitlement_line_id'
                            ,p_argument_value => p_cagr_entitlement_line_id
                            );
  --
    hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into per_pcl_shd.g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number
          <> per_pcl_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'per_cagr_entitlement_lines_f'
      ,p_base_key_column         => 'cagr_entitlement_line_id'
      ,p_base_key_value          => p_cagr_entitlement_line_id
      ,p_parent_table_name1      => 'per_grade_spines_f'
      ,p_parent_key_column1      => 'grade_spine_id'
      ,p_parent_key_value1       => per_pcl_shd.g_old_rec.grade_spine_id
      ,p_parent_table_name2      => 'per_spinal_point_steps_f'
      ,p_parent_key_column2      => 'step_id'
      ,p_parent_key_value2       => per_pcl_shd.g_old_rec.step_id
      ,p_parent_table_name3      => 'per_spinal_point_steps_f'
      ,p_parent_key_column3      => 'step_id'
      ,p_parent_key_value3       => per_pcl_shd.g_old_rec.from_step_id
      ,p_parent_table_name4      => 'per_spinal_point_steps_f'
      ,p_parent_key_column4      => 'step_id'
      ,p_parent_key_value4       => per_pcl_shd.g_old_rec.to_step_id
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );
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
    fnd_message.set_token('TABLE_NAME', 'per_cagr_entitlement_lines_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cagr_entitlement_line_id       in number
  ,p_cagr_entitlement_id            in number
  ,p_mandatory                      in varchar2
  ,p_value                          in varchar2
  ,p_range_from                     in varchar2
  ,p_range_to                       in varchar2
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_parent_spine_id                in number
  ,p_step_id                        in number
  ,p_from_step_id                   in number
  ,p_to_step_id                     in number
  ,p_status                         in varchar2
  ,p_oipl_id                        in number
  ,p_object_version_number          in number
  ,p_grade_spine_id                 in number
  ,p_eligy_prfl_id                  in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.cagr_entitlement_line_id         := p_cagr_entitlement_line_id;
  l_rec.cagr_entitlement_id              := p_cagr_entitlement_id;
  l_rec.mandatory                        := p_mandatory;
  l_rec.value                            := p_value;
  l_rec.range_from                       := p_range_from;
  l_rec.range_to                         := p_range_to;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.parent_spine_id                  := p_parent_spine_id;
  l_rec.step_id                          := p_step_id;
  l_rec.from_step_id                     := p_from_step_id;
  l_rec.to_step_id                       := p_to_step_id;
  l_rec.status                           := p_status;
  l_rec.oipl_id                          := p_oipl_id;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.grade_spine_id                   := p_grade_spine_id;
  l_rec.eligy_prfl_id                    := p_eligy_prfl_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end per_pcl_shd;

/
