--------------------------------------------------------
--  DDL for Package Body HR_WHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WHO" as
/* $Header: hrwhopls.pkb 115.1 2002/12/05 17:02:10 apholt ship $ */
-- ----------------------------------------------------------------------------
-- |-------------------< Global Declarations >--------------------------------|
-- ----------------------------------------------------------------------------
g_package               varchar2(33)    := '  hr_who.';
-- ----------------------------------------------------------------------------
-- |---------------------------------< who >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure who(p_new_created_by		in out nocopy number,
              p_new_creation_date	in out nocopy  date) Is
--
  l_proc	varchar2(72)	:= g_package||'who';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Test the p_new_created_by argument
  --
  If (p_new_created_by is null) Then
    p_new_created_by := fnd_global.user_id;
  End If;
  --
  -- Test the p_new_creation_date argument
  --
  If (p_new_creation_date is null) Then
    p_new_creation_date := sysdate;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End who;
-- ----------------------------------------------------------------------------
-- |---------------------------------< who >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure who(p_new_last_update_date	in out nocopy date,
              p_new_last_updated_by     in out nocopy number,
              p_new_last_update_login   in out nocopy number,
              p_old_last_update_date    in     date,
              p_old_last_updated_by     in     number,
              p_old_last_update_login   in     number) Is
--
  l_proc        varchar2(72)    := g_package||'who';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Test the p_new_last_update_date argument
  --
  If (p_new_last_update_date is null or
      p_new_last_update_date = p_old_last_update_date) Then
    p_new_last_update_date := sysdate;
  End If;
  --
  -- Test the p_new_last_updated_by argument
  --
  If (p_new_last_updated_by is null or
      p_new_last_updated_by = p_old_last_updated_by) Then
    p_new_last_updated_by := fnd_global.user_id;
  End If;
  --
  -- Test the p_new_last_update_login argument
  --
  If (p_new_last_update_login is null or
      p_new_last_update_login = p_old_last_update_login) Then
    p_new_last_update_login := fnd_global.login_id;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End who;
end hr_who;

/
