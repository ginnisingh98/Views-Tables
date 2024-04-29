--------------------------------------------------------
--  DDL for Package Body PER_PCE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PCE_SHD" AS
/* $Header: pepcerhi.pkb 120.1 2006/10/18 09:19:34 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  per_pce_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------< retrieve_cagr_info >---------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE retrieve_cagr_info
  (p_collective_agreement_id IN     NUMBER
  ,p_business_group_id          OUT NOCOPY NUMBER) IS
  --
  -- Declare Local Cursors
  --
  CURSOR csr_cagr_info IS
    SELECT cag.business_group_id
	FROM   per_collective_agreements cag
	WHERE  cag.collective_agreement_id = p_collective_agreement_id;
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
    (p_api_name	      => l_proc
    ,p_argument	      => 'COLLECTIVE_AGREEMENT_ID'
    ,p_argument_value => p_collective_agreement_id);
  --
  OPEN csr_cagr_info;
  FETCH csr_cagr_info INTO p_business_group_id;
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
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE constraint_error
  (p_constraint_name IN all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        VARCHAR2(72) := g_package||'constraint_error';
--
BEGIN
  --
  If (p_constraint_name = 'SYS_C00118392') THEN
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  END If;
  --
END constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_cagr_entitlement_id                  IN     NUMBER
  ,p_object_version_number                IN     NUMBER
  )
  Return Boolean Is
  --
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 IS
    select
       cagr_entitlement_id
      ,cagr_entitlement_item_id
      ,collective_agreement_id
      ,start_date
      ,end_date
      ,status
      ,formula_criteria
      ,formula_id
      ,units_of_measure
	  ,message_level
      ,object_version_number
    from        per_cagr_entitlements
    where       cagr_entitlement_id = p_cagr_entitlement_id;
  --
  l_fct_ret     boolean;
  --
BEGIN
  --
  If (p_cagr_entitlement_id IS NULL and
      p_object_version_number IS NULL
     ) THEN
    --
    -- One of the primary key arguments IS NULL therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_cagr_entitlement_id
        = per_pce_shd.g_old_rec.cagr_entitlement_id and
        p_object_version_number
        = per_pce_shd.g_old_rec.object_version_number
       ) THEN
      --
      -- The g_old_rec IS current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
      --
      Open C_Sel1;
      Fetch C_Sel1 Into per_pce_shd.g_old_rec;
      If C_Sel1%notfound THEN
        Close C_Sel1;
        --
        -- The primary key IS invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      END If;
      Close C_Sel1;
      If (p_object_version_number
          <> per_pce_shd.g_old_rec.object_version_number) THEN
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      END If;
      l_fct_ret := true;
    END If;
  END If;
  Return (l_fct_ret);
--
END api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_cagr_entitlement_id                  IN     NUMBER
  ,p_object_version_number                IN     NUMBER
  ) IS
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 IS
    select
       cagr_entitlement_id
      ,cagr_entitlement_item_id
      ,collective_agreement_id
      ,start_date
      ,end_date
      ,status
      ,formula_criteria
      ,formula_id
      ,units_of_measure
	  ,message_level
      ,object_version_number
    from        per_cagr_entitlements
    where       cagr_entitlement_id = p_cagr_entitlement_id
    for update nowait;
--
  l_proc        VARCHAR2(72) := g_package||'lck';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'CAGR_ENTITLEMENT_ID'
    ,p_argument_value     => p_cagr_entitlement_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  Open  C_Sel1;
  Fetch C_Sel1 Into per_pce_shd.g_old_rec;
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key IS invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  END If;
  Close C_Sel1;
  If (p_object_version_number
      <> per_pce_shd.g_old_rec.object_version_number) THEN
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  END If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- We need to trap the ORA LOCK exception
  --
EXCEPTION
  WHEN HR_Api.Object_Locked then
    --
    -- The object IS locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'per_cagr_entitlements');
    fnd_message.raise_error;
END lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_cagr_entitlement_id            IN NUMBER
  ,p_cagr_entitlement_item_id       IN NUMBER
  ,p_collective_agreement_id        IN NUMBER
  ,p_start_date                     IN DATE
  ,p_end_date                       IN DATE
  ,p_status                         IN VARCHAR2
  ,p_formula_criteria               IN VARCHAR2
  ,p_formula_id                     IN NUMBER
  ,p_units_of_measure               IN VARCHAR2
  ,p_message_level                  IN VARCHAR2
  ,p_object_version_number          IN NUMBER
  )
  Return g_rec_type IS
--
  l_rec   g_rec_type;
--
BEGIN
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.cagr_entitlement_id              := p_cagr_entitlement_id;
  l_rec.cagr_entitlement_item_id         := p_cagr_entitlement_item_id;
  l_rec.collective_agreement_id          := p_collective_agreement_id;
  l_rec.start_date                       := p_start_date;
  l_rec.end_date                         := p_end_date;
  l_rec.status                           := p_status;
  l_rec.formula_criteria                 := p_formula_criteria;
  l_rec.formula_id                       := p_formula_id;
  l_rec.units_of_measure                 := p_units_of_measure;
  l_rec.message_level                    := p_message_level;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  RETURN(l_rec);
--
END convert_args;
--
end per_pce_shd;

/
