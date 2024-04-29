--------------------------------------------------------
--  DDL for Package Body PAY_PYR_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYR_SHD" AS
/* $Header: pypyrrhi.pkb 115.3 2003/09/15 04:18:59 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  pay_pyr_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION return_api_dml_status RETURN BOOLEAN IS
--
BEGIN
  --
  RETURN (NVL(g_api_dml, FALSE));
  --
END return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE constraint_error
  (p_constraint_name IN all_constraints.constraint_name%TYPE
  ) IS
  --
  l_proc        VARCHAR2(72) := g_package||'constraint_error';
  --
BEGIN
  --
  IF (p_constraint_name = 'PAY_RATESH_RATE_TYPE_CHK') THEN
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ELSIF (p_constraint_name = 'PAY_RATESH_RATE_UOM_CHK') THEN
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF (p_constraint_name = 'PAY_RATES_FK1') THEN
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ELSIF (p_constraint_name = 'PAY_RATES_FK2') THEN
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ELSIF (p_constraint_name = 'PAY_RATES_PK') THEN
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ELSE
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  END IF;
  --
END constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION api_updating
  (p_rate_id                              IN     NUMBER
  ,p_object_version_number                IN     NUMBER
  )
  RETURN Boolean IS
  --
  --
  -- Cursor selects the 'current' row FROM the HR Schema
  --
  CURSOR C_Sel1 IS
    SELECT
       rate_id
      ,business_group_id
      ,parent_spine_id
      ,name
      ,rate_type
      ,rate_uom
      ,comments
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,rate_basis
      ,asg_rate_type
      ,object_version_number
    FROM        pay_rates
    WHERE       rate_id = p_rate_id;
  --
  l_fct_ret     BOOLEAN;
  --
BEGIN
  --
  IF (p_rate_id IS NULL AND
      p_object_version_number IS NULL
     ) THEN
    --
    -- One of the primary key arguments IS NULL therefore we must
    -- set the returning function value to FALSE
    --
    l_fct_ret := FALSE;
  ELSE
    IF (p_rate_id
        = pay_pyr_shd.g_old_rec.rate_id AND
        p_object_version_number
        = pay_pyr_shd.g_old_rec.object_version_number
       ) THEN
      --
      -- The g_old_rec IS current therefore we must
      -- set the returning function to TRUE
      --
      l_fct_ret := TRUE;
    ELSE
      --
      -- Select the current row INTO g_old_rec
      --
      OPEN C_Sel1;
      FETCH C_Sel1 INTO pay_pyr_shd.g_old_rec;
      IF C_Sel1%notfound THEN
        CLOSE C_Sel1;
        --
        -- The primary key IS invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      END IF;
      CLOSE C_Sel1;
      IF (p_object_version_number
          <> pay_pyr_shd.g_old_rec.object_version_number) THEN
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      END IF;
      l_fct_ret := TRUE;
    END IF;
  END IF;
  RETURN (l_fct_ret);
--
END api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE lck
  (p_rate_id                              IN     NUMBER
  ,p_object_version_number                IN     NUMBER
  ) IS
  --
  -- CURSOR selects the 'current' row FROM the HR Schema
  --
  CURSOR C_Sel1 IS
    SELECT
       rate_id
      ,business_group_id
      ,parent_spine_id
      ,name
      ,rate_type
      ,rate_uom
      ,comments
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,rate_basis
      ,asg_rate_type
      ,object_version_number
    FROM        pay_rates
    WHERE       rate_id = p_rate_id
    FOR UPDATE NOWAIT;
  --
  l_proc        VARCHAR2(72) := g_package||'lck';
  --
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RATE_ID'
    ,p_argument_value     => p_rate_id
    );
  hr_utility.set_location(l_proc,6);
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'OBJECT_VERSION_NUMBER'
    ,p_argument_value     => p_object_version_number
    );
  --
  OPEN  C_Sel1;
  FETCH C_Sel1 INTO pay_pyr_shd.g_old_rec;
  IF C_Sel1%notfound THEN
    CLOSE C_Sel1;
    --
    -- The primary key IS invalid therefore we must error
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  END IF;
  CLOSE C_Sel1;
  IF (p_object_version_number
      <> pay_pyr_shd.g_old_rec.object_version_number) THEN
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- We need to trap the ORA LOCK exception
  --
EXCEPTION
  WHEN HR_Api.Object_Locked THEN
    --
    -- The object IS locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pay_rates');
    fnd_message.raise_error;
END lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION convert_args
  (p_rate_id                        IN NUMBER
  ,p_business_group_id              IN NUMBER
  ,p_parent_spine_id                IN NUMBER
  ,p_name                           IN VARCHAR2
  ,p_rate_type                      IN VARCHAR2
  ,p_rate_uom                       IN VARCHAR2
  ,p_comments                       IN VARCHAR2
  ,p_attribute_category             IN VARCHAR2
  ,p_attribute1                     IN VARCHAR2
  ,p_attribute2                     IN VARCHAR2
  ,p_attribute3                     IN VARCHAR2
  ,p_attribute4                     IN VARCHAR2
  ,p_attribute5                     IN VARCHAR2
  ,p_attribute6                     IN VARCHAR2
  ,p_attribute7                     IN VARCHAR2
  ,p_attribute8                     IN VARCHAR2
  ,p_attribute9                     IN VARCHAR2
  ,p_attribute10                    IN VARCHAR2
  ,p_attribute11                    IN VARCHAR2
  ,p_attribute12                    IN VARCHAR2
  ,p_attribute13                    IN VARCHAR2
  ,p_attribute14                    IN VARCHAR2
  ,p_attribute15                    IN VARCHAR2
  ,p_attribute16                    IN VARCHAR2
  ,p_attribute17                    IN VARCHAR2
  ,p_attribute18                    IN VARCHAR2
  ,p_attribute19                    IN VARCHAR2
  ,p_attribute20                    IN VARCHAR2
  ,p_rate_basis                     IN VARCHAR2
  ,p_asg_rate_type                  IN VARCHAR2
  ,p_object_version_number          IN NUMBER
  )
  RETURN g_rec_type IS
--
  l_rec   g_rec_type;
--
BEGIN
  --
  -- Convert arguments INTO local l_rec structure.
  --
  l_rec.rate_id                          := p_rate_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.parent_spine_id                  := p_parent_spine_id;
  l_rec.name                             := p_name;
  l_rec.rate_type                        := p_rate_type;
  l_rec.rate_uom                         := p_rate_uom;
  l_rec.comments                         := p_comments;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.rate_basis                       := p_rate_basis;
  l_rec.asg_rate_type                    := p_asg_rate_type;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- RETURN the plsql record structure.
  --
  RETURN(l_rec);
--
END convert_args;
--
END pay_pyr_shd;

/
