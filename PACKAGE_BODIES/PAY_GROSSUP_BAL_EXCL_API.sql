--------------------------------------------------------
--  DDL for Package Body PAY_GROSSUP_BAL_EXCL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GROSSUP_BAL_EXCL_API" as
/* $Header: pygbeapi.pkb 115.1 2003/01/28 11:05:04 dsaxby noship $ */
--
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_grossup_bal_excl_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_grossup_bal >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_grossup_bal
(
   p_validate                       in            boolean default false
  ,p_start_date                     in            date
  ,p_end_date                       in            date
  ,p_source_id                      in            number
  ,p_source_type                    in            varchar2
  ,p_balance_type_id                in            number
  ,p_grossup_balances_id               out nocopy number
  ,p_object_version_number             out nocopy number
) is
 --
  l_proc varchar2(72) := g_package||'create_grossup_bal.';
  l_object_version_number pay_grossup_bal_exclusions.object_version_number%TYPE;
  l_grossup_balances_id pay_grossup_bal_exclusions.grossup_balances_id%TYPE;
 --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    savepoint create_grossup_bal;
  --
  End If;
--
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  pay_gbe_ins.ins
  (
   p_start_date         => p_start_date
  ,p_end_date           => p_end_date
  ,p_source_id          => p_source_id
  ,p_source_type        => p_source_type
  ,p_balance_type_id    => p_balance_type_id
  ,p_grossup_balances_id  => l_grossup_balances_id
  ,p_object_version_number => l_object_version_number
  );
--
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
  p_object_version_number         := l_object_version_number;
  p_grossup_balances_id           := l_object_version_number;
--
exception
  --
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_grossup_bal;
--
end create_grossup_bal;
-- ----------------------------------------------------------------------------
-- |------------------------< update_grossup_bal >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_grossup_bal
(
   p_validate                     in     boolean default false
  ,p_grossup_balances_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_source_id                    in     number    default hr_api.g_number
  ,p_source_type                  in     varchar2  default hr_api.g_varchar2
  ,p_balance_type_id              in     number    default hr_api.g_number
) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_grossup_bal.';
  l_object_version_number pay_grossup_bal_exclusions.object_version_number%TYPE;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    savepoint update_grossup_bal;
  --
  End If;
--
  l_object_version_number := p_object_version_number;
  pay_gbe_upd.upd
  (
   p_grossup_balances_id          => p_grossup_balances_id
  ,p_object_version_number        => l_object_version_number
  ,p_start_date                   => p_start_date
  ,p_end_date                     => p_end_date
  ,p_source_id                    => p_source_id
  ,p_source_type                  => p_source_type
  ,p_balance_type_id              => p_balance_type_id
  );
  hr_utility.set_location('Entering:'|| l_proc, 20);
--
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  p_object_version_number         := l_object_version_number;
--
exception
  --
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_grossup_bal;
    --
end update_grossup_bal;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_grossup_bal >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_grossup_bal
(
   p_validate                       in     boolean default false
  ,p_grossup_balances_id                  in     number
  ,p_object_version_number                in     number) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_grossup_bal.';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    savepoint delete_grossup_bal;
  --
  End If;
  --
  pay_gbe_del.del
  (
   p_grossup_balances_id          => p_grossup_balances_id
  ,p_object_version_number        => p_object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  --
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
--
exception
  when HR_Api.Validate_Enabled then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_grossup_bal;
    --
end delete_grossup_bal;
--
-- ----------------------------------------------------------------------------
-- |------------------------< lck_grossup_bal >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck_grossup_bal
(
   p_grossup_balances_id                  in     number
  ,p_object_version_number                in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  l_proc                  varchar2(72) := g_package||'update_grossup_bal.';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pay_gbe_shd.lck
  (
   p_grossup_balances_id            => p_grossup_balances_id
  ,p_object_version_number          => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck_grossup_bal;
--
end pay_grossup_bal_excl_api;

/
