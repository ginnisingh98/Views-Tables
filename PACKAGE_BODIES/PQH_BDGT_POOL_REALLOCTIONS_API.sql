--------------------------------------------------------
--  DDL for Package Body PQH_BDGT_POOL_REALLOCTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDGT_POOL_REALLOCTIONS_API" as
/* $Header: pqbreapi.pkb 115.7 2003/04/02 13:22:47 ggnanagu noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_bdgt_pool_realloctions_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_realloc_txn_dtl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_realloc_txn_dtl
(
   p_validate                       in  boolean
  ,p_effective_date                 in  date
  ,p_transaction_id                 in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number
  ,p_budget_detail_id               in  number
  ,p_txn_detail_id            out nocopy number
  ,p_object_version_number          out nocopy number
) is
  --
  -- Declare cursors and local variables
  --
  l_txn_detail_id pqh_bdgt_pool_realloctions.reallocation_id%TYPE;
  l_proc varchar2(72) := g_package||'create_realloc_txn_dtl';
  l_object_version_number pqh_bdgt_pool_realloctions.object_version_number%TYPE;
  --
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_realloc_txn_dtl;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_realloc_txn_dtl
    --
    pqh_bdgt_pool_realloctions_bk1.create_realloc_txn_dtl_b
      (
       p_transaction_id              =>  p_transaction_id
      ,p_transaction_type            =>  p_transaction_type
      ,p_entity_id                   =>  p_entity_id
      ,p_budget_detail_id            =>  p_budget_detail_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_REALLOC_TXN_DTL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_realloc_txn_dtl
    --
  end;
  --
  pqh_bre_ins.ins
    (
     p_reallocation_id             => l_txn_detail_id
    ,p_effective_date              => p_effective_date
    ,p_entity_id                   => p_entity_id
    ,p_pool_id                     => p_transaction_id
    ,p_budget_detail_id            => p_budget_detail_id
    ,p_transaction_type              => p_transaction_type
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_realloc_txn_dtl
    --
    pqh_bdgt_pool_realloctions_bk1.create_realloc_txn_dtl_a
      (
       p_txn_detail_id            =>  l_txn_detail_id
      ,p_transaction_id                 =>  p_transaction_id
      ,p_transaction_type                       =>  p_transaction_type
      ,p_budget_detail_id                   =>  p_budget_detail_id
      ,p_entity_id               =>  p_entity_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REALLOC_TXN_DTL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_realloc_txn_dtl
    --
  end;
  --
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
  p_txn_detail_id := l_txn_detail_id;
  p_object_version_number := l_object_version_number;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_realloc_txn_dtl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_txn_detail_id := null;
    p_object_version_number  := null;
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_realloc_txn_dtl;
    raise;
    --
end create_realloc_txn_dtl;
-- ----------------------------------------------------------------------------
-- |------------------------< update_realloc_txn_dtl >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_realloc_txn_dtl
(
   p_validate                       in  boolean
  ,p_effective_date                 in  date
  ,p_transaction_id                 in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number
  ,p_budget_detail_id               in  number
  ,p_txn_detail_id            in  number
  ,p_object_version_number          in out nocopy number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_realloc_txn_dtl';
  l_object_version_number pqh_bdgt_pool_realloctions.object_version_number%TYPE;
  --
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_realloc_txn_dtl;
  --
    hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_realloc_txn_dtl
    --
    pqh_bdgt_pool_realloctions_bk2.update_realloc_txn_dtl_b
      (
       p_transaction_id                =>  p_transaction_id
      ,p_transaction_type              =>  p_transaction_type
      ,p_entity_id                     =>  p_entity_id
      ,p_budget_detail_id              =>  p_budget_detail_id
      ,p_txn_detail_id           =>  p_txn_detail_id
      ,p_object_version_number         =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REALLOC_TXN_DTL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_realloc_txn_dtl
    --
  end;
  --
  pqh_bre_upd.upd
    (
     p_pool_id                      => p_transaction_id
    ,p_effective_date               => p_effective_date
    ,p_transaction_type             => p_transaction_type
    ,p_entity_id                    => p_entity_id
    ,p_budget_detail_id             => p_budget_detail_id
    ,p_reallocation_id              => p_txn_detail_id
    ,p_object_version_number        => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_realloc_txn_dtl
    --
    pqh_bdgt_pool_realloctions_bk2.update_realloc_txn_dtl_a
      (
     p_transaction_id               => p_transaction_id
    ,p_transaction_type             => p_transaction_type
    ,p_entity_id                    => p_entity_id
    ,p_budget_detail_id             => p_budget_detail_id
    ,p_txn_detail_id          => p_txn_detail_id
    ,p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REALLOC_TXN_DTL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_realloc_txn_dtl
    --
  end;
  --
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
  p_object_version_number := l_object_version_number;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_realloc_txn_dtl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_realloc_txn_dtl;
    raise;
    --
end update_realloc_txn_dtl;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_realloc_txn_dtl >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_realloc_txn_dtl
  (p_validate                       in  boolean
  ,p_txn_detail_id            in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_realloc_txn_dtl';
  l_object_version_number pqh_bdgt_pool_realloctions.object_version_number%TYPE;
  --
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_realloc_txn_dtl;
  --
    hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_realloc_txn_dtl
    --
    pqh_bdgt_pool_realloctions_bk3.delete_realloc_txn_dtl_b
      (
       p_txn_detail_id            =>  p_txn_detail_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REALLOC_TXN_DTL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_realloc_txn_dtl
    --
  end;
  --
  pqh_bre_del.del
    (
     p_reallocation_id               => p_txn_detail_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_realloc_txn_dtl
    --
    pqh_bdgt_pool_realloctions_bk3.delete_realloc_txn_dtl_a
      (
       p_txn_detail_id            =>  p_txn_detail_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REALLOC_TXN_DTL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_realloc_txn_dtl
    --
  end;
  --
    hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_realloc_txn_dtl;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_realloc_txn_dtl;
    raise;
    --
end delete_realloc_txn_dtl;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_realloc_txn_period >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_realloc_txn_period
(
   p_validate                       in  boolean
  ,p_effective_date                 in  date
  ,p_txn_detail_id                  in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number
  ,p_budget_period_id               in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_reallocation_amt               in  number
  ,p_reserved_amt                   in  number
  ,p_reallocation_period_id            out nocopy  number
  ,p_object_version_number          out nocopy  number
 ) is
  --
  -- Declare cursors and local variables
  --
  l_reallocation_period_id pqh_bdgt_pool_realloctions.reallocation_id%TYPE;
  l_proc varchar2(72) := g_package||'create_realloc_txn_period';
  l_object_version_number pqh_bdgt_pool_realloctions.object_version_number%TYPE;
  --
  Cursor csr_prd_txn_id IS
   SELECT pool_id
   FROM   pqh_bdgt_pool_realloctions txndtl
   WHERE  txndtl.reallocation_id = p_txn_detail_id;
   l_transaction_id NUMBER(15);
  Cursor csr_dup_rcvr_period(p_transaction_id NUMBER) IS
   SELECT 1
   FROM   pqh_budget_pools txn,
          pqh_bdgt_pool_realloctions txndtl,
          pqh_bdgt_pool_realloctions txnprd
   WHERE  txn.pool_id = p_transaction_id
     AND  txndtl.pool_id = txn.pool_id
     AND  txndtl.reallocation_id = txnprd.txn_detail_id
     AND  NVL(txnprd.entity_id,-1) = NVL(p_entity_id,-1)
 --    AND  NVL(txnprd.start_date,sysdate) = NVL(p_start_date,sysdate)
 --    AND  NVL(txnprd.end_date,sysdate) = NVL(p_end_date,sysdate);
  AND NVL(p_end_date,sysdate) >= NVL (txnprd.start_date,sysdate)
  AND NVL(p_start_date,sysdate) <= NVL(txnprd.end_date,sysdate);
   l_dup_exist  Varchar2(10);
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_realloc_txn_period;
  --Check for duplicate receiver periods
  IF p_transaction_type = 'RD' THEN
   OPEN csr_prd_txn_id;
   FETCH csr_prd_txn_id INTO l_transaction_id;
   CLOSE csr_prd_txn_id;
   IF l_transaction_id IS NOT NULL THEN
     OPEN csr_dup_rcvr_period(l_transaction_id);
     FETCH csr_dup_rcvr_period INTO l_dup_exist;
     CLOSE csr_dup_rcvr_period;
     IF l_dup_exist IS NOT NULL THEN
        hr_utility.set_message(8302,'PQH_DUP_RCVR_PERIOD');
        hr_utility.raise_error;
     END IF;
   END IF;
  END IF;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_realloc_txn_period
    --
    pqh_bdgt_pool_realloctions_bk4.create_realloc_txn_period_b
      (
      p_txn_detail_id    => p_txn_detail_id
      ,p_transaction_type      => p_transaction_type
      ,p_entity_id             => p_entity_id
      ,p_budget_period_id      => p_budget_period_id
      ,p_start_date            => p_start_date
      ,p_end_date              => p_end_date
      ,p_reallocation_amt      => p_reallocation_amt
      ,p_reserved_amt          => p_reserved_amt
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_REALLOC_TXN_PERIOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_realloc_txn_period
    --
  end;
  --
  pqh_bre_ins.ins
    (
       p_txn_detail_id        => p_txn_detail_id
      ,p_effective_date        => p_effective_date
      ,p_transaction_type      => p_transaction_type
      ,p_entity_id             => p_entity_id
      ,p_budget_period_id      => p_budget_period_id
      ,p_start_date            => p_start_date
      ,p_end_date              => p_end_date
      ,p_reallocation_amt      => p_reallocation_amt
      ,p_reserved_amt          => p_reserved_amt
      ,p_reallocation_id       => l_reallocation_period_id
      ,p_object_version_number => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_realloc_txn_period
    --
    pqh_bdgt_pool_realloctions_bk4.create_realloc_txn_period_a
      (
       p_txn_detail_id   => p_txn_detail_id
      ,p_transaction_type      => p_transaction_type
      ,p_entity_id             => p_entity_id
      ,p_budget_period_id      => p_budget_period_id
      ,p_start_date            => p_start_date
      ,p_end_date              => p_end_date
      ,p_reallocation_amt      => p_reallocation_amt
      ,p_reserved_amt          => p_reserved_amt
      ,p_reallocation_period_id      => l_reallocation_period_id
      ,p_object_version_number => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REALLOC_TXN_PERIOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_realloc_txn_period
    --
  end;
  --
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
  p_reallocation_period_id := l_reallocation_period_id;
  p_object_version_number := l_object_version_number;
  --
   hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_realloc_txn_period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_reallocation_period_id := null;
    p_object_version_number  := null;
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_realloc_txn_period;
    raise;
    --
end create_realloc_txn_period;
-- ----------------------------------------------------------------------------
-- |------------------------< update_realloc_txn_period >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_realloc_txn_period
(
   p_validate                       in  boolean
  ,p_effective_date                 in  date
  ,p_txn_detail_id            in  number
  ,p_transaction_type               in  varchar2
  ,p_entity_id                      in  number
  ,p_budget_period_id               in  number
  ,p_start_date                     in  date
  ,p_end_date                       in  date
  ,p_reallocation_amt               in  number
  ,p_reserved_amt                   in  number
  ,p_reallocation_period_id            in  number
  ,p_object_version_number          in out nocopy number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_realloc_txn_period';
  l_object_version_number pqh_bdgt_pool_realloctions.object_version_number%TYPE;
  --
  Cursor csr_prd_txn_id IS
   SELECT pool_id
   FROM   pqh_bdgt_pool_realloctions txndtl
   WHERE  txndtl.reallocation_id = p_txn_detail_id;
   l_transaction_id NUMBER(15);
  Cursor csr_dup_rcvr_period(p_transaction_id NUMBER) IS
   SELECT 1
   FROM   pqh_budget_pools txn,
          pqh_bdgt_pool_realloctions txndtl,
          pqh_bdgt_pool_realloctions txnprd
   WHERE  txn.pool_id = p_transaction_id
     AND  txndtl.pool_id = txn.pool_id
     AND  txndtl.reallocation_id = txnprd.txn_detail_id
     AND  NVL(txnprd.entity_id,-1) = NVL(p_entity_id,-1)
 --    AND  NVL(txnprd.start_date,sysdate) = NVL(p_start_date,sysdate)
 --    AND  NVL(txnprd.end_date,sysdate) = NVL(p_end_date,sysdate);
  AND NVL(p_end_date,sysdate) >= NVL (txnprd.start_date,sysdate)
  AND NVL(p_start_date,sysdate) <= NVL(txnprd.end_date,sysdate);
   l_dup_exist varchar2(10);
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_realloc_txn_period;
  --
  --Check for duplicate receiver periods
  IF p_transaction_type = 'RD' THEN
   OPEN csr_prd_txn_id;
   FETCH csr_prd_txn_id INTO l_transaction_id;
   CLOSE csr_prd_txn_id;
   IF l_transaction_id IS NOT NULL THEN
     OPEN csr_dup_rcvr_period(l_transaction_id);
     FETCH csr_dup_rcvr_period INTO l_dup_exist;
     CLOSE csr_dup_rcvr_period;
     IF l_dup_exist IS NOT NULL THEN
        hr_utility.set_message(8302,'PQH_DUP_RCVR_PERIOD');
        hr_utility.raise_error;
     END IF;
   END IF;
  END IF;
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_realloc_txn_period
    --
    pqh_bdgt_pool_realloctions_bk5.update_realloc_txn_period_b
      (
       p_txn_detail_id   => p_txn_detail_id
      ,p_transaction_type      => p_transaction_type
      ,p_entity_id             => p_entity_id
      ,p_budget_period_id      => p_budget_period_id
      ,p_start_date            => p_start_date
      ,p_end_date              => p_end_date
      ,p_reallocation_amt      => p_reallocation_amt
      ,p_reserved_amt          => p_reserved_amt
      ,p_reallocation_period_id      => p_reallocation_period_id
      ,p_object_version_number => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REALLOC_TXN_PERIOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_realloc_txn_period
    --
  end;
  --
  pqh_bre_upd.upd
    (
       p_txn_detail_id        => p_txn_detail_id
      ,p_effective_date        => p_effective_date
      ,p_transaction_type      => p_transaction_type
      ,p_entity_id             => p_entity_id
      ,p_budget_period_id      => p_budget_period_id
      ,p_start_date            => p_start_date
      ,p_end_date              => p_end_date
      ,p_reallocation_amt      => p_reallocation_amt
      ,p_reserved_amt          => p_reserved_amt
      ,p_reallocation_id       => p_reallocation_period_id
      ,p_object_version_number => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_realloc_txn_period
    --
    pqh_bdgt_pool_realloctions_bk5.update_realloc_txn_period_a
      (
       p_txn_detail_id   => p_txn_detail_id
      ,p_transaction_type      => p_transaction_type
      ,p_entity_id             => p_entity_id
      ,p_budget_period_id      => p_budget_period_id
      ,p_start_date            => p_start_date
      ,p_end_date              => p_end_date
      ,p_reallocation_amt      => p_reallocation_amt
      ,p_reserved_amt          => p_reserved_amt
      ,p_reallocation_period_id      => p_reallocation_period_id
      ,p_object_version_number => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REALLOC_TXN_PERIOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_realloc_txn_period
    --
  end;
  --
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
  p_object_version_number := l_object_version_number;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_realloc_txn_period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_realloc_txn_period;
    raise;
    --
end update_realloc_txn_period;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_realloc_txn_period >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_realloc_txn_period
  (p_validate                       in  boolean
  ,p_reallocation_period_id            in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_realloc_txn_period';
  l_object_version_number pqh_bdgt_pool_realloctions.object_version_number%TYPE;
  --
begin
  --
    hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_realloc_txn_period;
  --
    hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_realloc_txn_period
    --
    pqh_bdgt_pool_realloctions_bk6.delete_realloc_txn_period_b
      (
       p_reallocation_period_id            =>  p_reallocation_period_id
      ,p_object_version_number       =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REALLOC_TXN_PERIOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_realloc_txn_period
    --
  end;
  --
  pqh_bre_del.del
    (
     p_reallocation_id               => p_reallocation_period_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_realloc_txn_period
    --
    pqh_bdgt_pool_realloctions_bk6.delete_realloc_txn_period_a
      (
       p_reallocation_period_id                =>  p_reallocation_period_id
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REALLOC_TXN_PERIOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_realloc_txn_period
    --
  end;
  --
    hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_realloc_txn_period;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_realloc_txn_period;
    raise;
    --
end delete_realloc_txn_period;
--
--
end pqh_bdgt_pool_realloctions_api;

/
