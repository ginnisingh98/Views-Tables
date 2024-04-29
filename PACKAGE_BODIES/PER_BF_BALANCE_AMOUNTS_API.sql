--------------------------------------------------------
--  DDL for Package Body PER_BF_BALANCE_AMOUNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BF_BALANCE_AMOUNTS_API" as
/* $Header: pebbaapi.pkb 115.10 2002/11/29 14:31:02 apholt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_BF_BALANCE_AMOUNTS_API.';
--
Procedure chk_currency_code (p_currency_code   in varchar2
                            ,p_balance_type_id in varchar2
                            ,p_effective_date  in DATE)
  --
IS
  -- Cursor to retrieve the currency code and input_value_id from bbt
  CURSOR csr_bbt_currency IS
  SELECT input_value_id, currency, uom
   FROM  per_bf_balance_types
   WHERE balance_type_id = p_balance_type_id;
  --
  -- Cursor to retrieve the currency code from element type.
  CURSOR csr_et_currency_code (p_input_value_id  NUMBER )IS
  SELECT et.input_currency_code
       , iv.uom
  FROM pay_element_types_f et
     , pay_input_values_f iv
  WHERE iv.input_value_id = p_input_value_id
    AND iv.element_type_id = et.element_type_id
    AND p_effective_date BETWEEN
        iv.effective_start_date AND iv.effective_end_date
    AND p_effective_date BETWEEN
        et.effective_start_date AND et.effective_end_date;
--
  l_input_value_id  NUMBER;
  l_currency        VARCHAR2(20);
  l_uom             VARCHAR2(20);
BEGIN
  --
  OPEN csr_bbt_currency;
  FETCH csr_bbt_currency INTO l_input_value_id, l_currency, l_uom;
  CLOSE csr_bbt_currency;
  --
  IF l_input_value_id IS NOT NULL THEN
    -- The balance type is attached to an element which will contain
    -- the currency, and the input_value will contain the UOM.
    --
    OPEN csr_et_currency_code(l_input_value_id);
    FETCH csr_et_currency_code INTO l_currency , l_uom;
    CLOSE csr_et_currency_code;
    --
  END IF;
  --
  -- Now check if the UOM is money, and if so check that the currency is
  -- the same.
  IF l_uom = 'M' THEN
    -- The UOM is Money, so need to ensure the currency is the same
    --
    IF p_currency_code IS NULL THEN
      -- Need to error, as if the type is money, as currency is required
      hr_utility.set_message(800,'HR_50401_NEED_CURR_CODE');
      hr_utility.raise_error;
    END IF;
    IF l_currency <> p_currency_code THEN
      -- The currency being passed in is different than the currency
      -- that the business group is expecting, so error!
      --
      hr_utility.set_message(800,'HR_50402_WRONG_CURR_CODE');
      hr_utility.raise_error;
      --
    END IF;
  END IF;
  --
END chk_currency_code;
-- ----------------------------------------------------------------------------
-- |---------------------< <create_balance_amount> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_amount
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_balance_type_id               in     number
  ,p_assignment_id                 in     number
  ,p_payroll_run_id                in     number
  ,p_ytd_amount                    in     number   default null
  ,p_fytd_amount                   in     number   default null
  ,p_ptd_amount                    in     number   default null
  ,p_mtd_amount                    in     number   default null
  ,p_qtd_amount                    in     number   default null
  ,p_run_amount                    in     number   default null
  ,p_currency_code                 in     varchar2 default null
  ,p_bba_attribute_category        in     varchar2 default null
  ,p_bba_attribute1                in     varchar2 default null
  ,p_bba_attribute2                in     varchar2 default null
  ,p_bba_attribute3                in     varchar2 default null
  ,p_bba_attribute4                in     varchar2 default null
  ,p_bba_attribute5                in     varchar2 default null
  ,p_bba_attribute6                in     varchar2 default null
  ,p_bba_attribute7                in     varchar2 default null
  ,p_bba_attribute8                in     varchar2 default null
  ,p_bba_attribute9                in     varchar2 default null
  ,p_bba_attribute10               in     varchar2 default null
  ,p_bba_attribute11               in     varchar2 default null
  ,p_bba_attribute12               in     varchar2 default null
  ,p_bba_attribute13               in     varchar2 default null
  ,p_bba_attribute14               in     varchar2 default null
  ,p_bba_attribute15               in     varchar2 default null
  ,p_bba_attribute16               in     varchar2 default null
  ,p_bba_attribute17               in     varchar2 default null
  ,p_bba_attribute18               in     varchar2 default null
  ,p_bba_attribute19               in     varchar2 default null
  ,p_bba_attribute20               in     varchar2 default null
  ,p_bba_attribute21               in     varchar2 default null
  ,p_bba_attribute22               in     varchar2 default null
  ,p_bba_attribute23               in     varchar2 default null
  ,p_bba_attribute24               in     varchar2 default null
  ,p_bba_attribute25               in     varchar2 default null
  ,p_bba_attribute26               in     varchar2 default null
  ,p_bba_attribute27               in     varchar2 default null
  ,p_bba_attribute28               in     varchar2 default null
  ,p_bba_attribute29               in     varchar2 default null
  ,p_bba_attribute30               in     varchar2 default null
  ,p_processed_assignment_id          out nocopy number
  ,p_processed_assignment_ovn         out nocopy number
  ,p_balance_amount_id                out nocopy number
  ,p_balance_amount_ovn               out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to retrieve the ID and OVN of the row in
  --  PER_BF_PROCESSED_ASSIGNMENTS should one exist.
  --
  CURSOR csr_get_pa_id_ovn IS
  SELECT processed_assignment_id, object_version_number
    FROM per_bf_processed_assignments
   WHERE payroll_run_id = p_payroll_run_id
     AND assignment_id = p_assignment_id;
  --
  -- Two tables are being used in this API, so two sets of OUT parameters will
  -- be created.
  --
  l_balance_amount_id        PER_BF_BALANCE_AMOUNTS.balance_amount_id%TYPE;
  l_balance_amount_ovn
      PER_BF_BALANCE_AMOUNTS.object_version_number%TYPE;
  l_processed_assignment_id
      PER_BF_PROCESSED_ASSIGNMENTS.processed_assignment_id%TYPE;
  l_processed_assignment_ovn
      PER_BF_PROCESSED_ASSIGNMENTS.object_version_number%TYPE;
  --
  l_proc                varchar2(72) := g_package||'create_balance_amount';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_balance_amount;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_BALANCE_AMOUNTS_BK1.CREATE_BALANCE_AMOUNT_B
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_balance_type_id               => p_balance_type_id
      ,p_assignment_id                 => p_assignment_id
      ,p_payroll_run_id                => p_payroll_run_id
      ,p_ytd_amount                    => p_ytd_amount
      ,p_fytd_amount                   => p_fytd_amount
      ,p_ptd_amount                    => p_ptd_amount
      ,p_mtd_amount                    => p_mtd_amount
      ,p_qtd_amount                    => p_qtd_amount
      ,p_run_amount                    => p_run_amount
      ,p_currency_code                 => p_currency_code
      ,p_bba_attribute_category           => p_bba_attribute_category
      ,p_bba_attribute1                   => p_bba_attribute1
      ,p_bba_attribute2                   => p_bba_attribute2
      ,p_bba_attribute3                   => p_bba_attribute3
      ,p_bba_attribute4                   => p_bba_attribute4
      ,p_bba_attribute5                   => p_bba_attribute5
      ,p_bba_attribute6                   => p_bba_attribute6
      ,p_bba_attribute7                   => p_bba_attribute7
      ,p_bba_attribute8                   => p_bba_attribute8
      ,p_bba_attribute9                   => p_bba_attribute9
      ,p_bba_attribute10                  => p_bba_attribute10
      ,p_bba_attribute11                  => p_bba_attribute11
      ,p_bba_attribute12                  => p_bba_attribute12
      ,p_bba_attribute13                  => p_bba_attribute13
      ,p_bba_attribute14                  => p_bba_attribute14
      ,p_bba_attribute15                  => p_bba_attribute15
      ,p_bba_attribute16                  => p_bba_attribute16
      ,p_bba_attribute17                  => p_bba_attribute17
      ,p_bba_attribute18                  => p_bba_attribute18
      ,p_bba_attribute19                  => p_bba_attribute19
      ,p_bba_attribute20                  => p_bba_attribute20
      ,p_bba_attribute21                  => p_bba_attribute21
      ,p_bba_attribute22                  => p_bba_attribute22
      ,p_bba_attribute23                  => p_bba_attribute23
      ,p_bba_attribute24                  => p_bba_attribute24
      ,p_bba_attribute25                  => p_bba_attribute25
      ,p_bba_attribute26                  => p_bba_attribute26
      ,p_bba_attribute27                  => p_bba_attribute27
      ,p_bba_attribute28                  => p_bba_attribute28
      ,p_bba_attribute29                  => p_bba_attribute29
      ,p_bba_attribute30                  => p_bba_attribute30
       );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BALANCE_AMOUNT'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  -- check to ensure that the currency code of the values being passed in
  -- (if the values are monetary) is what is being expected.
  chk_currency_code (p_currency_code   => p_currency_code
                    ,p_balance_type_id => p_balance_type_id
                    ,p_effective_date  => p_effective_date);
  --
  OPEN csr_get_pa_id_ovn ;
  FETCH csr_get_pa_id_ovn INTO l_processed_assignment_id
			     , l_processed_assignment_ovn;
  --
  IF csr_get_pa_id_ovn%NOTFOUND THEN
    --
    hr_utility.set_location(l_proc, 35);
    --
    -- This is the first balance to be associated with this assignment and
    -- payroll run, so a new row needs to be created in the table
    -- PER_BF_PROCESSED_ASSIGNMENTS.
    --
    CLOSE csr_get_pa_id_ovn ;
    --
    per_bpa_ins.ins
      (p_effective_date               => p_effective_date
      ,p_payroll_run_id               => p_payroll_run_id
      ,p_assignment_id                => p_assignment_id
      ,p_processed_assignment_id      => l_processed_assignment_id
      ,p_object_version_number        => l_processed_assignment_ovn
      );
    --
  ELSE
    --
    hr_utility.set_location(l_proc, 36);
    --
    -- A row exists in PER_BF_PROCESSED_ASSIGNMENTS for this payroll run and
    -- assignment combination, so no need to do anything as the values
    -- for the processed_assignment_id and object_version number are
    -- already in local variables.
    --
    CLOSE csr_get_pa_id_ovn ;
    --
  END IF;
  --
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  per_bba_ins.ins
    (
      p_effective_date               => p_effective_date
     ,p_balance_type_id              => p_balance_type_id
     ,p_processed_assignment_id      => l_processed_assignment_id
     ,p_business_group_id            => p_business_group_id
     ,p_ytd_amount                   => p_ytd_amount
     ,p_fytd_amount                  => p_fytd_amount
     ,p_ptd_amount                   => p_ptd_amount
     ,p_mtd_amount                   => p_mtd_amount
     ,p_qtd_amount                   => p_qtd_amount
     ,p_run_amount                   => p_run_amount
     ,p_bba_attribute_category           => p_bba_attribute_category
     ,p_bba_attribute1                   => p_bba_attribute1
     ,p_bba_attribute2                   => p_bba_attribute2
     ,p_bba_attribute3                   => p_bba_attribute3
     ,p_bba_attribute4                   => p_bba_attribute4
     ,p_bba_attribute5                   => p_bba_attribute5
     ,p_bba_attribute6                   => p_bba_attribute6
     ,p_bba_attribute7                   => p_bba_attribute7
     ,p_bba_attribute8                   => p_bba_attribute8
     ,p_bba_attribute9                   => p_bba_attribute9
     ,p_bba_attribute10                  => p_bba_attribute10
     ,p_bba_attribute11                  => p_bba_attribute11
     ,p_bba_attribute12                  => p_bba_attribute12
     ,p_bba_attribute13                  => p_bba_attribute13
     ,p_bba_attribute14                  => p_bba_attribute14
     ,p_bba_attribute15                  => p_bba_attribute15
     ,p_bba_attribute16                  => p_bba_attribute16
     ,p_bba_attribute17                  => p_bba_attribute17
     ,p_bba_attribute18                  => p_bba_attribute18
     ,p_bba_attribute19                  => p_bba_attribute19
     ,p_bba_attribute20                  => p_bba_attribute20
     ,p_bba_attribute21                  => p_bba_attribute21
     ,p_bba_attribute22                  => p_bba_attribute22
     ,p_bba_attribute23                  => p_bba_attribute23
     ,p_bba_attribute24                  => p_bba_attribute24
     ,p_bba_attribute25                  => p_bba_attribute25
     ,p_bba_attribute26                  => p_bba_attribute26
     ,p_bba_attribute27                  => p_bba_attribute27
     ,p_bba_attribute28                  => p_bba_attribute28
     ,p_bba_attribute29                  => p_bba_attribute29
     ,p_bba_attribute30                  => p_bba_attribute30
     ,p_balance_amount_id            => l_balance_amount_id
     ,p_object_version_number        => l_balance_amount_ovn

     );
  --
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_BALANCE_AMOUNTS_BK1.CREATE_BALANCE_AMOUNT_A
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_balance_type_id               => p_balance_type_id
      ,p_assignment_id                 => p_assignment_id
      ,p_payroll_run_id                => p_payroll_run_id
      ,p_ytd_amount                    => p_ytd_amount
      ,p_fytd_amount                   => p_fytd_amount
      ,p_ptd_amount                    => p_ptd_amount
      ,p_mtd_amount                    => p_mtd_amount
      ,p_qtd_amount                    => p_qtd_amount
      ,p_run_amount                    => p_run_amount
      ,p_currency_code                 => p_currency_code
      ,p_bba_attribute_category           => p_bba_attribute_category
      ,p_bba_attribute1                   => p_bba_attribute1
      ,p_bba_attribute2                   => p_bba_attribute2
      ,p_bba_attribute3                   => p_bba_attribute3
      ,p_bba_attribute4                   => p_bba_attribute4
      ,p_bba_attribute5                   => p_bba_attribute5
      ,p_bba_attribute6                   => p_bba_attribute6
      ,p_bba_attribute7                   => p_bba_attribute7
      ,p_bba_attribute8                   => p_bba_attribute8
      ,p_bba_attribute9                   => p_bba_attribute9
      ,p_bba_attribute10                  => p_bba_attribute10
      ,p_bba_attribute11                  => p_bba_attribute11
      ,p_bba_attribute12                  => p_bba_attribute12
      ,p_bba_attribute13                  => p_bba_attribute13
      ,p_bba_attribute14                  => p_bba_attribute14
      ,p_bba_attribute15                  => p_bba_attribute15
      ,p_bba_attribute16                  => p_bba_attribute16
      ,p_bba_attribute17                  => p_bba_attribute17
      ,p_bba_attribute18                  => p_bba_attribute18
      ,p_bba_attribute19                  => p_bba_attribute19
      ,p_bba_attribute20                  => p_bba_attribute20
      ,p_bba_attribute21                  => p_bba_attribute21
      ,p_bba_attribute22                  => p_bba_attribute22
      ,p_bba_attribute23                  => p_bba_attribute23
      ,p_bba_attribute24                  => p_bba_attribute24
      ,p_bba_attribute25                  => p_bba_attribute25
      ,p_bba_attribute26                  => p_bba_attribute26
      ,p_bba_attribute27                  => p_bba_attribute27
      ,p_bba_attribute28                  => p_bba_attribute28
      ,p_bba_attribute29                  => p_bba_attribute29
      ,p_bba_attribute30                  => p_bba_attribute30
      ,p_balance_amount_id             => l_balance_amount_id
      ,p_balance_amount_ovn            => l_balance_amount_ovn
      ,p_processed_assignment_id       => l_processed_assignment_id
      ,p_processed_assignment_ovn      => l_processed_assignment_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_BALANCE_AMOUNT'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_balance_amount_id       := l_balance_amount_id;
  p_balance_amount_ovn      := l_balance_amount_ovn;
  p_processed_assignment_id := l_processed_assignment_id;
  p_processed_assignment_ovn:= l_processed_assignment_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_balance_amount;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_balance_amount_id       := null;
    p_balance_amount_ovn      := null;
    p_processed_assignment_id := null;
    p_processed_assignment_ovn:= null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_balance_amount;
    --set out variables
    --
    p_balance_amount_id       := null;
    p_balance_amount_ovn      := null;
    p_processed_assignment_id := null;
    p_processed_assignment_ovn:= null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_BALANCE_AMOUNT;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< <update_balance_amount> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_balance_amount
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_ytd_amount                    in     number   default hr_api.g_number
  ,p_fytd_amount                   in     number   default hr_api.g_number
  ,p_ptd_amount                    in     number   default hr_api.g_number
  ,p_mtd_amount                    in     number   default hr_api.g_number
  ,p_qtd_amount                    in     number   default hr_api.g_number
  ,p_run_amount                    in     number   default hr_api.g_number
  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute21               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute22               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute23               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute24               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute25               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute26               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute27               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute28               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute29               in     varchar2 default hr_api.g_varchar2
  ,p_bba_attribute30               in     varchar2 default hr_api.g_varchar2
  ,p_balance_amount_id             in     number
  ,p_balance_amount_ovn            in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get the balance_type_id
  CURSOR csr_get_bbt IS
  SELECT balance_type_id
    FROM per_bf_balance_amounts
   WHERE balance_amount_id = p_balance_amount_id;
  --
  l_balance_type_id   NUMBER;
  --
  l_balance_amount_ovn
      PER_BF_BALANCE_AMOUNTS.object_version_number%TYPE;
  --
  l_proc                varchar2(72) := g_package||'update_balance_amount';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_balance_amount;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_BALANCE_AMOUNTS_BK2.UPDATE_BALANCE_AMOUNT_B
      (p_effective_date                => p_effective_date
      ,p_ytd_amount                    => p_ytd_amount
      ,p_fytd_amount                   => p_fytd_amount
      ,p_ptd_amount                    => p_ptd_amount
      ,p_mtd_amount                    => p_mtd_amount
      ,p_qtd_amount                    => p_qtd_amount
      ,p_run_amount                    => p_run_amount
      ,p_currency_code                 => p_currency_code
      ,p_bba_attribute_category           => p_bba_attribute_category
      ,p_bba_attribute1                   => p_bba_attribute1
      ,p_bba_attribute2                   => p_bba_attribute2
      ,p_bba_attribute3                   => p_bba_attribute3
      ,p_bba_attribute4                   => p_bba_attribute4
      ,p_bba_attribute5                   => p_bba_attribute5
      ,p_bba_attribute6                   => p_bba_attribute6
      ,p_bba_attribute7                   => p_bba_attribute7
      ,p_bba_attribute8                   => p_bba_attribute8
      ,p_bba_attribute9                   => p_bba_attribute9
      ,p_bba_attribute10                  => p_bba_attribute10
      ,p_bba_attribute11                  => p_bba_attribute11
      ,p_bba_attribute12                  => p_bba_attribute12
      ,p_bba_attribute13                  => p_bba_attribute13
      ,p_bba_attribute14                  => p_bba_attribute14
      ,p_bba_attribute15                  => p_bba_attribute15
      ,p_bba_attribute16                  => p_bba_attribute16
      ,p_bba_attribute17                  => p_bba_attribute17
      ,p_bba_attribute18                  => p_bba_attribute18
      ,p_bba_attribute19                  => p_bba_attribute19
      ,p_bba_attribute20                  => p_bba_attribute20
      ,p_bba_attribute21                  => p_bba_attribute21
      ,p_bba_attribute22                  => p_bba_attribute22
      ,p_bba_attribute23                  => p_bba_attribute23
      ,p_bba_attribute24                  => p_bba_attribute24
      ,p_bba_attribute25                  => p_bba_attribute25
      ,p_bba_attribute26                  => p_bba_attribute26
      ,p_bba_attribute27                  => p_bba_attribute27
      ,p_bba_attribute28                  => p_bba_attribute28
      ,p_bba_attribute29                  => p_bba_attribute29
      ,p_bba_attribute30                  => p_bba_attribute30
      ,p_balance_amount_id             => p_balance_amount_id
      ,p_balance_amount_ovn            => p_balance_amount_ovn
       );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BALANCE_AMOUNT'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  OPEN csr_get_bbt;
  FETCH csr_get_bbt INTO l_balance_type_id;
  CLOSE csr_get_bbt;
  --
  -- check to ensure that the currency code of the values being passed in
  -- (if the values are monetary) is what is being expected.
  chk_currency_code (p_currency_code   => p_currency_code
                    ,p_balance_type_id => l_balance_type_id
                    ,p_effective_date  => p_effective_date);
  --
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  l_balance_amount_ovn   := p_balance_amount_ovn;
  --
  per_bba_upd.upd
    (
      p_effective_date               => p_effective_date
     ,p_ytd_amount                   => p_ytd_amount
     ,p_fytd_amount                  => p_fytd_amount
     ,p_ptd_amount                   => p_ptd_amount
     ,p_mtd_amount                   => p_mtd_amount
     ,p_qtd_amount                   => p_qtd_amount
     ,p_run_amount                   => p_run_amount
     ,p_bba_attribute_category           => p_bba_attribute_category
     ,p_bba_attribute1                   => p_bba_attribute1
     ,p_bba_attribute2                   => p_bba_attribute2
     ,p_bba_attribute3                   => p_bba_attribute3
     ,p_bba_attribute4                   => p_bba_attribute4
     ,p_bba_attribute5                   => p_bba_attribute5
     ,p_bba_attribute6                   => p_bba_attribute6
     ,p_bba_attribute7                   => p_bba_attribute7
     ,p_bba_attribute8                   => p_bba_attribute8
     ,p_bba_attribute9                   => p_bba_attribute9
     ,p_bba_attribute10                  => p_bba_attribute10
     ,p_bba_attribute11                  => p_bba_attribute11
     ,p_bba_attribute12                  => p_bba_attribute12
     ,p_bba_attribute13                  => p_bba_attribute13
     ,p_bba_attribute14                  => p_bba_attribute14
     ,p_bba_attribute15                  => p_bba_attribute15
     ,p_bba_attribute16                  => p_bba_attribute16
     ,p_bba_attribute17                  => p_bba_attribute17
     ,p_bba_attribute18                  => p_bba_attribute18
     ,p_bba_attribute19                  => p_bba_attribute19
     ,p_bba_attribute20                  => p_bba_attribute20
     ,p_bba_attribute21                  => p_bba_attribute21
     ,p_bba_attribute22                  => p_bba_attribute22
     ,p_bba_attribute23                  => p_bba_attribute23
     ,p_bba_attribute24                  => p_bba_attribute24
     ,p_bba_attribute25                  => p_bba_attribute25
     ,p_bba_attribute26                  => p_bba_attribute26
     ,p_bba_attribute27                  => p_bba_attribute27
     ,p_bba_attribute28                  => p_bba_attribute28
     ,p_bba_attribute29                  => p_bba_attribute29
     ,p_bba_attribute30                  => p_bba_attribute30
     ,p_balance_amount_id            => p_balance_amount_id
     ,p_object_version_number        => l_balance_amount_ovn
     );
  --
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_BALANCE_AMOUNTS_BK2.UPDATE_BALANCE_AMOUNT_A
      (p_effective_date                => p_effective_date
      ,p_ytd_amount                    => p_ytd_amount
      ,p_fytd_amount                   => p_fytd_amount
      ,p_ptd_amount                    => p_ptd_amount
      ,p_mtd_amount                    => p_mtd_amount
      ,p_qtd_amount                    => p_qtd_amount
      ,p_run_amount                    => p_run_amount
      ,p_currency_code                 => p_currency_code
      ,p_bba_attribute_category           => p_bba_attribute_category
      ,p_bba_attribute1                   => p_bba_attribute1
      ,p_bba_attribute2                   => p_bba_attribute2
      ,p_bba_attribute3                   => p_bba_attribute3
      ,p_bba_attribute4                   => p_bba_attribute4
      ,p_bba_attribute5                   => p_bba_attribute5
      ,p_bba_attribute6                   => p_bba_attribute6
      ,p_bba_attribute7                   => p_bba_attribute7
      ,p_bba_attribute8                   => p_bba_attribute8
      ,p_bba_attribute9                   => p_bba_attribute9
      ,p_bba_attribute10                  => p_bba_attribute10
      ,p_bba_attribute11                  => p_bba_attribute11
      ,p_bba_attribute12                  => p_bba_attribute12
      ,p_bba_attribute13                  => p_bba_attribute13
      ,p_bba_attribute14                  => p_bba_attribute14
      ,p_bba_attribute15                  => p_bba_attribute15
      ,p_bba_attribute16                  => p_bba_attribute16
      ,p_bba_attribute17                  => p_bba_attribute17
      ,p_bba_attribute18                  => p_bba_attribute18
      ,p_bba_attribute19                  => p_bba_attribute19
      ,p_bba_attribute20                  => p_bba_attribute20
      ,p_bba_attribute21                  => p_bba_attribute21
      ,p_bba_attribute22                  => p_bba_attribute22
      ,p_bba_attribute23                  => p_bba_attribute23
      ,p_bba_attribute24                  => p_bba_attribute24
      ,p_bba_attribute25                  => p_bba_attribute25
      ,p_bba_attribute26                  => p_bba_attribute26
      ,p_bba_attribute27                  => p_bba_attribute27
      ,p_bba_attribute28                  => p_bba_attribute28
      ,p_bba_attribute29                  => p_bba_attribute29
      ,p_bba_attribute30                  => p_bba_attribute30
      ,p_balance_amount_id             => p_balance_amount_id
      ,p_balance_amount_ovn            => l_balance_amount_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_BALANCE_AMOUNT'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_balance_amount_ovn     := l_balance_amount_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_balance_amount;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_balance_amount_ovn      := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_balance_amount;
    -- set out variable
    p_balance_amount_ovn      := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_BALANCE_AMOUNT;
--
-- ----------------------------------------------------------------------------
-- |---------------------< <delete_balance_amount> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_amount
  (p_validate                      in     boolean  default false
  ,p_balance_amount_id             in     number
  ,p_balance_amount_ovn            in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  --
  CURSOR csr_get_pa_id IS
  SELECT pa.processed_assignment_id, pa.object_version_number
    FROM PER_BF_BALANCE_AMOUNTS  ba
	,PER_BF_PROCESSED_ASSIGNMENTS pa
   WHERE ba.balance_amount_id = p_balance_amount_id
     AND ba.processed_assignment_id = pa.processed_assignment_id;
  --
  CURSOR csr_chk_pa_for_del
    (p_processed_assignment_id NUMBER) IS
  SELECT 1
    FROM per_bf_balance_amounts
   WHERE processed_assignment_id = p_processed_assignment_id
     AND balance_amount_id <> p_balance_amount_id
   UNION
  SELECT 1
    FROM per_bf_payment_details
   WHERE processed_assignment_id = p_processed_assignment_id;
  --
  l_processed_assignment_id  NUMBER;
  l_processed_assignment_ovn NUMBER;
  l_temp                     VARCHAR2(1);
  l_delete_pa_row            BOOLEAN;
  l_proc                varchar2(72) := g_package||'delete_balance_amount';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_balance_amount;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  --
  -- Call Before Process User Hook
  --
  begin
    PER_BF_BALANCE_AMOUNTS_BK3.DELETE_BALANCE_AMOUNT_B
      (
       p_balance_amount_id             => p_balance_amount_id
      ,p_balance_amount_ovn            => p_balance_amount_ovn
       );
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BALANCE_AMOUNT'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  --
  -- If no other entity uses the processed_assignment row that the FK
  -- in PER_BF_BALANCE_AMOUNTS references, then the row will be removed
  -- from PER_BF_PROCESSED_ASSIGNMENTS.
  --
  -- Obtain the processed assignment ID related to this row.
  --
  OPEN csr_get_pa_id;
  FETCH csr_get_pa_id INTO l_processed_assignment_id
			 , l_processed_assignment_ovn;
  CLOSE csr_get_pa_id;
  --
  -- Check whether the processed assignment is used elsewhere.
  --
  OPEN csr_chk_pa_for_del
      (p_processed_assignment_id => l_processed_assignment_id);
  FETCH csr_chk_pa_for_del INTO l_temp;
  --
  IF csr_chk_pa_for_del%NOTFOUND THEN
    --
    CLOSE csr_chk_pa_for_del;
    --
    -- The row can be deleted from PER_BF_PROCESSED_ASSIGNMENTS
    -- so set a boolean and it will be removed later.
    --
    l_delete_pa_row := TRUE;
    --
  ELSE
    --
    CLOSE csr_chk_pa_for_del;
    --
    l_delete_pa_row := FALSE;
    --
  END IF;
  --
  -- Delete the row in per_bf_balance_amounts
  --
  PER_BBA_DEL.DEL
     (
       p_balance_amount_id             => p_balance_amount_id
      ,p_object_version_number         => p_balance_amount_ovn
      );
  --
  --
  IF l_delete_pa_row THEN
    --
    -- The processed_assignment row is to be removed, so
    -- remove it
    --
    per_bpa_del.del
      ( p_processed_assignment_id      => l_processed_assignment_id
      , p_object_version_number        => l_processed_assignment_ovn
      );
    --
  END IF;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    PER_BF_BALANCE_AMOUNTS_BK3.DELETE_BALANCE_AMOUNT_A
      (
       p_balance_amount_id             => p_balance_amount_id
      ,p_balance_amount_ovn            => p_balance_amount_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_BALANCE_AMOUNT'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_balance_amount;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_balance_amount;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_BALANCE_AMOUNT;
--
end PER_BF_BALANCE_AMOUNTS_API;

/
