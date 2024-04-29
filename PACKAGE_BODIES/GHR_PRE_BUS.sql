--------------------------------------------------------
--  DDL for Package Body GHR_PRE_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PRE_BUS" as
/* $Header: ghprerhi.pkb 120.0.12010000.2 2009/05/26 10:42:14 vmididho noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pre_bus.';  -- Global package name
--

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_non_updateable_args>----------------------------|
-- ----------------------------------------------------------------------------

Procedure chk_non_updateable_args(p_rec in  ghr_pre_shd.g_rec_type) is
   --
     l_proc          varchar2(72) := g_package || 'chk_non_updateable_args';
     l_error         exception;
     l_argument  varchar2(30);
  --
    Begin
       hr_utility.set_location( ' Entering:' ||l_proc, 10);
       --
       -- Only proceed with validation of a row exists for
       -- the current record in the HR schema
       --
       if not ghr_pre_shd.api_updating
           (p_pa_remark_id           => p_rec.pa_remark_id
           ,p_object_version_number  => p_rec.object_version_number
           ) then
           hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
           hr_utility.set_message('PROCEDURE',l_proc);
           hr_utility.set_message('STEP', '20');
      end if;
      hr_utility.set_location(l_proc,30);
      --
     if  nvl(p_rec.pa_request_id,hr_api.g_number)
               <> nvl(ghr_pre_shd.g_old_rec.pa_request_id,hr_api.g_number) then
              l_argument := 'pa_request_id';
              raise l_error;
     end if;
     if  nvl(p_rec.remark_id,hr_api.g_number)
               <> nvl(ghr_pre_shd.g_old_rec.remark_id,hr_api.g_number) then
              l_argument := 'remark_id';
              raise l_error;
     end if;

    hr_utility.set_location(l_proc,20);
     --
     exception
          when l_error then
               hr_api.argument_changed_error
                    (p_api_name  => l_proc
                     ,p_argument  => l_argument);
          when others then
              raise;
    end chk_non_updateable_args;
    --
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in ghr_pre_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in ghr_pre_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  -- call chk_non_updateable_args
     chk_non_updateable_args (p_rec => p_rec);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in ghr_pre_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ghr_pre_bus;

/
