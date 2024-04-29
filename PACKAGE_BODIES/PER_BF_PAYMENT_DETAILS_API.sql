--------------------------------------------------------
--  DDL for Package Body PER_BF_PAYMENT_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BF_PAYMENT_DETAILS_API" as
/* $Header: pebpdapi.pkb 115.11 2003/09/25 03:40:32 rsahoo noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_BF_PAYMENT_DETAILS_API.';
--
--
Procedure chk_currency_code (p_currency_code IN           VARCHAR2
                            ,p_payment_detail_id          NUMBER DEFAULT NULL
                            ,p_personal_payment_method_id NUMBER DEFAULT NULL
                            ,p_amount                     NUMBER
                            ,p_effective_date             DATE)
IS
  -- Cursor to retrieve the personal payment method id
  --
  CURSOR csr_get_ppm_id IS
  SELECT pd.personal_payment_method_id
  FROM per_bf_payment_details pd
  WHERE pd.payment_detail_id = p_payment_detail_id;

  -- Cursor to retrieve the currency code from the org payment method
  --
  CURSOR csr_get_org_currency (l_ppm_id IN NUMBER) IS
  SELECT opm.currency_code
  FROM pay_org_payment_methods_f opm
      ,pay_personal_payment_methods_f ppm
  WHERE ppm.org_payment_method_id = opm.org_payment_method_id
    AND ppm.personal_payment_method_id = l_ppm_id
    AND p_effective_date BETWEEN
        opm.effective_start_date AND opm.effective_end_date
    AND p_effective_date BETWEEN
        ppm.effective_start_date AND ppm.effective_end_date;
  --
  l_currency_code VARCHAR2(20);
  l_ppm_id        NUMBER;
  --
BEGIN
  IF (p_amount IS NOT NULL AND p_amount <> 0) THEN
    --
    l_ppm_id := p_personal_payment_method_id;
    --
    IF p_payment_detail_id IS NOT NULL THEN
      --
      -- If the payment_detail_id is not null, then this is an update
      OPEN csr_get_ppm_id ;
      FETCH csr_get_ppm_id INTO l_ppm_id;
      CLOSE csr_get_ppm_id;
      --
    END IF;
    --
    OPEN csr_get_org_currency(l_ppm_id => l_ppm_id);
    FETCH csr_get_org_currency INTO l_currency_code;
    CLOSE csr_get_org_currency;
    --
    IF p_currency_code IS NULL THEN
      -- Raise an error as a currency code is required
      hr_utility.set_message(800,'HR_50403_NEED_PD_CURR');
      hr_utility.raise_error;
    END IF;
    IF p_currency_code <> l_currency_code  THEN
      -- Wrong currency has been passed.
      hr_utility.set_message(800,'HR_50404_PD_WRONG_CURR');
      hr_utility.raise_error;
    END IF;
  END IF;
END chk_currency_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <create_payment_detail> >------------------------|
-- ----------------------------------------------------------------------------
procedure create_payment_detail
  (p_validate                     in      boolean  default false
  ,p_effective_date               in      date
  ,p_business_group_id            in      number
  ,p_personal_payment_method_id   in      number
  ,p_payroll_run_id               in      number
  ,p_assignment_id                in      number
  ,p_check_number                 in      number   default null
  ,p_payment_date                   in      date     default null
  ,p_amount                       in      number   default null
  ,p_check_type                   in      varchar2 default null
  ,p_currency_code                in      varchar2 default null
  ,p_bpd_attribute_category        in     varchar2 default null
  ,p_bpd_attribute1                in     varchar2 default null
  ,p_bpd_attribute2                in     varchar2 default null
  ,p_bpd_attribute3                in     varchar2 default null
  ,p_bpd_attribute4                in     varchar2 default null
  ,p_bpd_attribute5                in     varchar2 default null
  ,p_bpd_attribute6                in     varchar2 default null
  ,p_bpd_attribute7                in     varchar2 default null
  ,p_bpd_attribute8                in     varchar2 default null
  ,p_bpd_attribute9                in     varchar2 default null
  ,p_bpd_attribute10               in     varchar2 default null
  ,p_bpd_attribute11               in     varchar2 default null
  ,p_bpd_attribute12               in     varchar2 default null
  ,p_bpd_attribute13               in     varchar2 default null
  ,p_bpd_attribute14               in     varchar2 default null
  ,p_bpd_attribute15               in     varchar2 default null
  ,p_bpd_attribute16               in     varchar2 default null
  ,p_bpd_attribute17               in     varchar2 default null
  ,p_bpd_attribute18               in     varchar2 default null
  ,p_bpd_attribute19               in     varchar2 default null
  ,p_bpd_attribute20               in     varchar2 default null
  ,p_bpd_attribute21               in     varchar2 default null
  ,p_bpd_attribute22               in     varchar2 default null
  ,p_bpd_attribute23               in     varchar2 default null
  ,p_bpd_attribute24               in     varchar2 default null
  ,p_bpd_attribute25               in     varchar2 default null
  ,p_bpd_attribute26               in     varchar2 default null
  ,p_bpd_attribute27               in     varchar2 default null
  ,p_bpd_attribute28               in     varchar2 default null
  ,p_bpd_attribute29               in     varchar2 default null
  ,p_bpd_attribute30               in     varchar2 default null
  ,p_payment_detail_id                out nocopy number
  ,p_payment_detail_ovn               out nocopy number
  ,p_processed_assignment_id          out nocopy number
  ,p_processed_assignment_ovn         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
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
  l_payment_detail_id        PER_BF_PAYMENT_DETAILS.payment_detail_id%TYPE;
  l_payment_detail_ovn
     PER_BF_PAYMENT_DETAILS.object_version_number%TYPE;
  l_processed_assignment_id
      PER_BF_PROCESSED_ASSIGNMENTS.processed_assignment_id%TYPE;
  l_processed_assignment_ovn
      PER_BF_PROCESSED_ASSIGNMENTS.object_version_number%TYPE;
  --
  --
  l_proc                varchar2(72) := g_package||'create_payment_detail';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_payment_detail;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    per_bf_payment_details_bk1.create_payment_detail_b
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_personal_payment_method_id    => p_personal_payment_method_id
      ,p_check_number                  => p_check_number
      ,p_payment_date                    => p_payment_date
      ,p_amount                        => p_amount
      ,p_check_type                    => p_check_type
      ,p_bpd_attribute_category            => p_bpd_attribute_category
      ,p_bpd_attribute1                    => p_bpd_attribute1
      ,p_bpd_attribute2                    => p_bpd_attribute2
      ,p_bpd_attribute3                    => p_bpd_attribute3
      ,p_bpd_attribute4                    => p_bpd_attribute4
      ,p_bpd_attribute5                    => p_bpd_attribute5
      ,p_bpd_attribute6                    => p_bpd_attribute6
      ,p_bpd_attribute7                    => p_bpd_attribute7
      ,p_bpd_attribute8                    => p_bpd_attribute8
      ,p_bpd_attribute9                    => p_bpd_attribute9
      ,p_bpd_attribute10                   => p_bpd_attribute10
      ,p_bpd_attribute11                   => p_bpd_attribute11
      ,p_bpd_attribute12                   => p_bpd_attribute12
      ,p_bpd_attribute13                   => p_bpd_attribute13
      ,p_bpd_attribute14                   => p_bpd_attribute14
      ,p_bpd_attribute15                   => p_bpd_attribute15
      ,p_bpd_attribute16                   => p_bpd_attribute16
      ,p_bpd_attribute17                   => p_bpd_attribute17
      ,p_bpd_attribute18                   => p_bpd_attribute18
      ,p_bpd_attribute19                   => p_bpd_attribute19
      ,p_bpd_attribute20                   => p_bpd_attribute20
      ,p_bpd_attribute21                   => p_bpd_attribute21
      ,p_bpd_attribute22                   => p_bpd_attribute22
      ,p_bpd_attribute23                   => p_bpd_attribute23
      ,p_bpd_attribute24                   => p_bpd_attribute24
      ,p_bpd_attribute25                   => p_bpd_attribute25
      ,p_bpd_attribute26                   => p_bpd_attribute26
      ,p_bpd_attribute27                   => p_bpd_attribute27
      ,p_bpd_attribute28                   => p_bpd_attribute28
      ,p_bpd_attribute29                   => p_bpd_attribute29
      ,p_bpd_attribute30                   => p_bpd_attribute30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PAYMENT_DETAIL'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  -- Validation to ensure that the currency is the same for the org payment
  -- method as the currency being passed in.
  --
  chk_currency_code
      (p_currency_code              => p_currency_code
      ,p_personal_payment_method_id => p_personal_payment_method_id
      ,p_amount                     => p_amount
      ,p_effective_date             => p_effective_date);
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
  per_bpd_ins.ins
      (p_effective_date                => p_effective_date
      ,p_processed_assignment_id       => l_processed_assignment_id
      ,p_personal_payment_method_id    => p_personal_payment_method_id
      ,p_business_group_id             => p_business_group_id
      ,p_payment_date                    => p_payment_date
      ,p_check_number                  => p_check_number
      ,p_amount                        => p_amount
      ,p_check_type                    => p_check_type
      ,p_bpd_attribute_category            => p_bpd_attribute_category
      ,p_bpd_attribute1                    => p_bpd_attribute1
      ,p_bpd_attribute2                    => p_bpd_attribute2
      ,p_bpd_attribute3                    => p_bpd_attribute3
      ,p_bpd_attribute4                    => p_bpd_attribute4
      ,p_bpd_attribute5                    => p_bpd_attribute5
      ,p_bpd_attribute6                    => p_bpd_attribute6
      ,p_bpd_attribute7                    => p_bpd_attribute7
      ,p_bpd_attribute8                    => p_bpd_attribute8
      ,p_bpd_attribute9                    => p_bpd_attribute9
      ,p_bpd_attribute10                   => p_bpd_attribute10
      ,p_bpd_attribute11                   => p_bpd_attribute11
      ,p_bpd_attribute12                   => p_bpd_attribute12
      ,p_bpd_attribute13                   => p_bpd_attribute13
      ,p_bpd_attribute14                   => p_bpd_attribute14
      ,p_bpd_attribute15                   => p_bpd_attribute15
      ,p_bpd_attribute16                   => p_bpd_attribute16
      ,p_bpd_attribute17                   => p_bpd_attribute17
      ,p_bpd_attribute18                   => p_bpd_attribute18
      ,p_bpd_attribute19                   => p_bpd_attribute19
      ,p_bpd_attribute20                   => p_bpd_attribute20
      ,p_bpd_attribute21                   => p_bpd_attribute21
      ,p_bpd_attribute22                   => p_bpd_attribute22
      ,p_bpd_attribute23                   => p_bpd_attribute23
      ,p_bpd_attribute24                   => p_bpd_attribute24
      ,p_bpd_attribute25                   => p_bpd_attribute25
      ,p_bpd_attribute26                   => p_bpd_attribute26
      ,p_bpd_attribute27                   => p_bpd_attribute27
      ,p_bpd_attribute28                   => p_bpd_attribute28
      ,p_bpd_attribute29                   => p_bpd_attribute29
      ,p_bpd_attribute30                   => p_bpd_attribute30
      ,p_payment_detail_id             => l_payment_detail_id
      ,p_object_version_number         => l_payment_detail_ovn
      );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_bf_payment_details_bk1.create_payment_detail_a
      (p_effective_date                => p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_personal_payment_method_id    => p_personal_payment_method_id
      ,p_check_number                  => p_check_number
      ,p_payment_date                    => p_payment_date
      ,p_amount                        => p_amount
      ,p_check_type                    => p_check_type
      ,p_bpd_attribute_category            => p_bpd_attribute_category
      ,p_bpd_attribute1                    => p_bpd_attribute1
      ,p_bpd_attribute2                    => p_bpd_attribute2
      ,p_bpd_attribute3                    => p_bpd_attribute3
      ,p_bpd_attribute4                    => p_bpd_attribute4
      ,p_bpd_attribute5                    => p_bpd_attribute5
      ,p_bpd_attribute6                    => p_bpd_attribute6
      ,p_bpd_attribute7                    => p_bpd_attribute7
      ,p_bpd_attribute8                    => p_bpd_attribute8
      ,p_bpd_attribute9                    => p_bpd_attribute9
      ,p_bpd_attribute10                   => p_bpd_attribute10
      ,p_bpd_attribute11                   => p_bpd_attribute11
      ,p_bpd_attribute12                   => p_bpd_attribute12
      ,p_bpd_attribute13                   => p_bpd_attribute13
      ,p_bpd_attribute14                   => p_bpd_attribute14
      ,p_bpd_attribute15                   => p_bpd_attribute15
      ,p_bpd_attribute16                   => p_bpd_attribute16
      ,p_bpd_attribute17                   => p_bpd_attribute17
      ,p_bpd_attribute18                   => p_bpd_attribute18
      ,p_bpd_attribute19                   => p_bpd_attribute19
      ,p_bpd_attribute20                   => p_bpd_attribute20
      ,p_bpd_attribute21                   => p_bpd_attribute21
      ,p_bpd_attribute22                   => p_bpd_attribute22
      ,p_bpd_attribute23                   => p_bpd_attribute23
      ,p_bpd_attribute24                   => p_bpd_attribute24
      ,p_bpd_attribute25                   => p_bpd_attribute25
      ,p_bpd_attribute26                   => p_bpd_attribute26
      ,p_bpd_attribute27                   => p_bpd_attribute27
      ,p_bpd_attribute28                   => p_bpd_attribute28
      ,p_bpd_attribute29                   => p_bpd_attribute29
      ,p_bpd_attribute30                   => p_bpd_attribute30
      ,p_payment_detail_id             => l_payment_detail_id
      ,p_payment_detail_ovn            => l_payment_detail_ovn
      ,p_processed_assignment_id       => l_processed_assignment_id
      ,p_processed_assignment_ovn      => l_processed_assignment_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PAYMENT_DETAIL'
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
  p_payment_detail_id            := l_payment_detail_id;
  p_payment_detail_ovn           := l_payment_detail_ovn;
  p_processed_assignment_id      := l_processed_assignment_id;
  p_processed_assignment_ovn     := l_processed_assignment_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_PAYMENT_DETAIL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_payment_detail_id            := null;
    p_payment_detail_ovn           := null;
    p_processed_assignment_id      := null;
    p_processed_assignment_ovn     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_PAYMENT_DETAIL;
    -- set out variables
    p_payment_detail_id            := null;
    p_payment_detail_ovn           := null;
    p_processed_assignment_id      := null;
    p_processed_assignment_ovn     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_PAYMENT_DETAIL;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< <update_payment_detail> >------------------------|
-- ----------------------------------------------------------------------------
procedure update_payment_detail
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_check_number                  in     number   default hr_api.g_number
  ,p_payment_date                  in     date     default hr_api.g_date
  ,p_amount                        in     number   default hr_api.g_number
  ,p_check_type                    in     varchar2 default hr_api.g_varchar2
  ,p_payment_detail_id             in     number
  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute21               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute22               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute23               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute24               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute25               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute26               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute27               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute28               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute29               in     varchar2 default hr_api.g_varchar2
  ,p_bpd_attribute30               in     varchar2 default hr_api.g_varchar2
  ,p_payment_detail_ovn            in     out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  l_payment_detail_ovn  PER_BF_PAYMENT_DETAILS.OBJECT_VERSION_NUMBER%TYPE;
  --
  l_proc                varchar2(72) := g_package||'update_payment_detail';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_payment_detail;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    per_bf_payment_details_bk2.update_payment_detail_b
      (p_effective_date                => p_effective_date
      ,p_check_number                  => p_check_number
      ,p_payment_date                    => p_payment_date
      ,p_amount                        => p_amount
      ,p_check_type                    => p_check_type
      ,p_bpd_attribute_category            => p_bpd_attribute_category
      ,p_bpd_attribute1                    => p_bpd_attribute1
      ,p_bpd_attribute2                    => p_bpd_attribute2
      ,p_bpd_attribute3                    => p_bpd_attribute3
      ,p_bpd_attribute4                    => p_bpd_attribute4
      ,p_bpd_attribute5                    => p_bpd_attribute5
      ,p_bpd_attribute6                    => p_bpd_attribute6
      ,p_bpd_attribute7                    => p_bpd_attribute7
      ,p_bpd_attribute8                    => p_bpd_attribute8
      ,p_bpd_attribute9                    => p_bpd_attribute9
      ,p_bpd_attribute10                   => p_bpd_attribute10
      ,p_bpd_attribute11                   => p_bpd_attribute11
      ,p_bpd_attribute12                   => p_bpd_attribute12
      ,p_bpd_attribute13                   => p_bpd_attribute13
      ,p_bpd_attribute14                   => p_bpd_attribute14
      ,p_bpd_attribute15                   => p_bpd_attribute15
      ,p_bpd_attribute16                   => p_bpd_attribute16
      ,p_bpd_attribute17                   => p_bpd_attribute17
      ,p_bpd_attribute18                   => p_bpd_attribute18
      ,p_bpd_attribute19                   => p_bpd_attribute19
      ,p_bpd_attribute20                   => p_bpd_attribute20
      ,p_bpd_attribute21                   => p_bpd_attribute21
      ,p_bpd_attribute22                   => p_bpd_attribute22
      ,p_bpd_attribute23                   => p_bpd_attribute23
      ,p_bpd_attribute24                   => p_bpd_attribute24
      ,p_bpd_attribute25                   => p_bpd_attribute25
      ,p_bpd_attribute26                   => p_bpd_attribute26
      ,p_bpd_attribute27                   => p_bpd_attribute27
      ,p_bpd_attribute28                   => p_bpd_attribute28
      ,p_bpd_attribute29                   => p_bpd_attribute29
      ,p_bpd_attribute30                   => p_bpd_attribute30
      ,p_payment_detail_id             => p_payment_detail_id
      ,p_payment_detail_ovn            => p_payment_detail_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PAYMENT_DETAIL'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_currency_code
      (p_currency_code              => p_currency_code
      ,p_payment_detail_id          => p_payment_detail_id
      ,p_amount                     => p_amount
      ,p_effective_date             => p_effective_date);
  --
  -- Process Logic
  --
  l_payment_detail_ovn := p_payment_detail_ovn;
  --
  per_bpd_upd.upd
      (p_effective_date                => p_effective_date
      ,p_payment_date                    => p_payment_date
      ,p_check_number                  => p_check_number
      ,p_amount                        => p_amount
      ,p_check_type                    => p_check_type
      ,p_bpd_attribute_category            => p_bpd_attribute_category
      ,p_bpd_attribute1                    => p_bpd_attribute1
      ,p_bpd_attribute2                    => p_bpd_attribute2
      ,p_bpd_attribute3                    => p_bpd_attribute3
      ,p_bpd_attribute4                    => p_bpd_attribute4
      ,p_bpd_attribute5                    => p_bpd_attribute5
      ,p_bpd_attribute6                    => p_bpd_attribute6
      ,p_bpd_attribute7                    => p_bpd_attribute7
      ,p_bpd_attribute8                    => p_bpd_attribute8
      ,p_bpd_attribute9                    => p_bpd_attribute9
      ,p_bpd_attribute10                   => p_bpd_attribute10
      ,p_bpd_attribute11                   => p_bpd_attribute11
      ,p_bpd_attribute12                   => p_bpd_attribute12
      ,p_bpd_attribute13                   => p_bpd_attribute13
      ,p_bpd_attribute14                   => p_bpd_attribute14
      ,p_bpd_attribute15                   => p_bpd_attribute15
      ,p_bpd_attribute16                   => p_bpd_attribute16
      ,p_bpd_attribute17                   => p_bpd_attribute17
      ,p_bpd_attribute18                   => p_bpd_attribute18
      ,p_bpd_attribute19                   => p_bpd_attribute19
      ,p_bpd_attribute20                   => p_bpd_attribute20
      ,p_bpd_attribute21                   => p_bpd_attribute21
      ,p_bpd_attribute22                   => p_bpd_attribute22
      ,p_bpd_attribute23                   => p_bpd_attribute23
      ,p_bpd_attribute24                   => p_bpd_attribute24
      ,p_bpd_attribute25                   => p_bpd_attribute25
      ,p_bpd_attribute26                   => p_bpd_attribute26
      ,p_bpd_attribute27                   => p_bpd_attribute27
      ,p_bpd_attribute28                   => p_bpd_attribute28
      ,p_bpd_attribute29                   => p_bpd_attribute29
      ,p_bpd_attribute30                   => p_bpd_attribute30
      ,p_payment_detail_id             => p_payment_detail_id
      ,p_object_version_number         => l_payment_detail_ovn
      );
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_bf_payment_details_bk2.update_payment_detail_a
      (p_effective_date                => p_effective_date
      ,p_check_number                  => p_check_number
      ,p_payment_date                    => p_payment_date
      ,p_amount                        => p_amount
      ,p_check_type                    => p_check_type
      ,p_bpd_attribute_category            => p_bpd_attribute_category
      ,p_bpd_attribute1                    => p_bpd_attribute1
      ,p_bpd_attribute2                    => p_bpd_attribute2
      ,p_bpd_attribute3                    => p_bpd_attribute3
      ,p_bpd_attribute4                    => p_bpd_attribute4
      ,p_bpd_attribute5                    => p_bpd_attribute5
      ,p_bpd_attribute6                    => p_bpd_attribute6
      ,p_bpd_attribute7                    => p_bpd_attribute7
      ,p_bpd_attribute8                    => p_bpd_attribute8
      ,p_bpd_attribute9                    => p_bpd_attribute9
      ,p_bpd_attribute10                   => p_bpd_attribute10
      ,p_bpd_attribute11                   => p_bpd_attribute11
      ,p_bpd_attribute12                   => p_bpd_attribute12
      ,p_bpd_attribute13                   => p_bpd_attribute13
      ,p_bpd_attribute14                   => p_bpd_attribute14
      ,p_bpd_attribute15                   => p_bpd_attribute15
      ,p_bpd_attribute16                   => p_bpd_attribute16
      ,p_bpd_attribute17                   => p_bpd_attribute17
      ,p_bpd_attribute18                   => p_bpd_attribute18
      ,p_bpd_attribute19                   => p_bpd_attribute19
      ,p_bpd_attribute20                   => p_bpd_attribute20
      ,p_bpd_attribute21                   => p_bpd_attribute21
      ,p_bpd_attribute22                   => p_bpd_attribute22
      ,p_bpd_attribute23                   => p_bpd_attribute23
      ,p_bpd_attribute24                   => p_bpd_attribute24
      ,p_bpd_attribute25                   => p_bpd_attribute25
      ,p_bpd_attribute26                   => p_bpd_attribute26
      ,p_bpd_attribute27                   => p_bpd_attribute27
      ,p_bpd_attribute28                   => p_bpd_attribute28
      ,p_bpd_attribute29                   => p_bpd_attribute29
      ,p_bpd_attribute30                   => p_bpd_attribute30
      ,p_payment_detail_id             => p_payment_detail_id
      ,p_payment_detail_ovn            => l_payment_detail_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PAYMENT_DETAIL'
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
  p_payment_detail_ovn           := l_payment_detail_ovn;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_PAYMENT_DETAIL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_payment_detail_ovn           := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_PAYMENT_DETAIL;
    --set out NOCOPY variables
    p_payment_detail_ovn           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_PAYMENT_DETAIL;
-- ----------------------------------------------------------------------------
-- |-----------------------< <delete_payment_detail> >------------------------|
-- ----------------------------------------------------------------------------
procedure delete_payment_detail
  (p_validate                     in      boolean  default false
  ,p_payment_detail_id            in      number
  ,p_payment_detail_ovn           in      number
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_get_pa_id IS
  SELECT pa.processed_assignment_id, pa.object_version_number
    FROM PER_BF_PAYMENT_DETAILS  pd
	,PER_BF_PROCESSED_ASSIGNMENTS pa
   WHERE pd.payment_detail_id = p_payment_detail_id
     AND pd.processed_assignment_id = pa.processed_assignment_id;
  --
  CURSOR csr_chk_pa_for_del
    (p_processed_assignment_id NUMBER) IS
  SELECT 1
    FROM per_bf_payment_details
   WHERE processed_assignment_id = p_processed_assignment_id
     AND payment_detail_id <> p_payment_detail_id
   UNION
  SELECT 1
    FROM per_bf_balance_amounts
   WHERE processed_assignment_id = p_processed_assignment_id;
  --
  l_processed_assignment_id  NUMBER;
  l_processed_assignment_ovn NUMBER;
  l_temp                     VARCHAR2(1);
  l_delete_pa_row            BOOLEAN;
  --
  l_proc                varchar2(72) := g_package||'delete_payment_detail';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_payment_detail;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    per_bf_payment_details_bk3.delete_payment_detail_b
      (p_payment_detail_id             => p_payment_detail_id
      ,p_payment_detail_ovn            => p_payment_detail_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PAYMENT_DETAIL'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 30);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  -- If no other entity uses the processed_assignment row that the FK
  -- in PER_BF_PAYMENT_DETAILS references, then the row will be removed
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
  per_bpd_del.del
    ( p_payment_detail_id             => p_payment_detail_id
    , p_object_version_number         => p_payment_detail_ovn
    );
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

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    per_bf_payment_details_bk3.delete_payment_detail_a
      (p_payment_detail_id             => p_payment_detail_id
      ,p_payment_detail_ovn            => p_payment_detail_ovn
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PAYMENT_DETAIL'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_PAYMENT_DETAIL;
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
    rollback to DELETE_PAYMENT_DETAIL;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_PAYMENT_DETAIL;

end PER_BF_PAYMENT_DETAILS_API;

/
