--------------------------------------------------------
--  DDL for Package Body PQH_VER_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VER_BUS" as
/* $Header: pqverrhi.pkb 115.3 2002/12/05 00:30:42 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_ver_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_wrkplc_vldtn_ver_id         number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_wrkplc_vldtn_ver_id                  in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqh_de_wrkplc_vldtn_vers ver
     where ver.wrkplc_vldtn_ver_id = p_wrkplc_vldtn_ver_id
       and pbg.business_group_id = ver.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'wrkplc_vldtn_ver_id'
    ,p_argument_value     => p_wrkplc_vldtn_ver_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'WRKPLC_VLDTN_VER_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_wrkplc_vldtn_ver_id                  in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqh_de_wrkplc_vldtn_vers ver
     where ver.wrkplc_vldtn_ver_id = p_wrkplc_vldtn_ver_id
       and pbg.business_group_id = ver.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'wrkplc_vldtn_ver_id'
    ,p_argument_value     => p_wrkplc_vldtn_ver_id
    );
  --
  if ( nvl(pqh_ver_bus.g_wrkplc_vldtn_ver_id, hr_api.g_number)
       = p_wrkplc_vldtn_ver_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqh_ver_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqh_ver_bus.g_wrkplc_vldtn_ver_id         := p_wrkplc_vldtn_ver_id;
    pqh_ver_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date               in date
  ,p_rec in pqh_ver_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(200) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqh_ver_shd.api_updating
      (p_wrkplc_vldtn_ver_id               => p_rec.wrkplc_vldtn_ver_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  If p_rec.Wrkplc_Vldtn_Id <> pqh_ver_shd.g_old_rec.wrkplc_vldtn_id Then
     hr_utility.set_message(8302, 'PQH_DE_NONUPD_VALDTN_ID');
     fnd_message.raise_error;
  End If;

End chk_non_updateable_args;

Procedure Ckh_Tariff_Contract
  (p_effective_date               in date
  ,p_rec                          in pqh_ver_shd.g_rec_type) is
--
  l_proc       Varchar2(200) := g_package||'Ckh_Tariff_Contract';
  l_Emp_Type   Pqh_De_Wrkplc_Vldtns.EMPLOYMENT_TYPE%TYPE;
  l_Result     Varchar2(1);

 Cursor Tariff_Contract is
   Select '1' from
   Per_gen_Hierarchy_Nodes a, Per_gen_Hierarchy_Nodes b
   Where
   a.Node_Type = 'TARIFF_CONTRACT' and a.Entity_Id = p_rec.Tariff_Contract_Code And
   b.Node_Type = 'EMP_TYPE' and b.Entity_Id = l_Emp_Type and
   b.Hierarchy_Node_Id = a.Parent_Hierarchy_Node_Id And
   a.Hierarchy_Version_Id in (Select Hierarchy_Version_Id from
   Per_Gen_Hierarchy_versions a, Per_gen_Hierarchy b where
   Type = 'REMUNERATION_REGULATION' AND
   a.Hierarchy_Id = b.Hierarchy_Id  And
   p_effective_date between a.Date_From and Nvl(a.Date_To,Trunc(Sysdate)) and
   b.Business_Group_Id=p_rec.Business_Group_Id
   ) and
   b.Hierarchy_Version_id = a.Hierarchy_Version_id;

 Cursor Emp_Type is
 Select Employment_type from
 Pqh_De_Wrkplc_Vldtns
 Where WRKPLC_VLDTN_ID     = p_rec.WRKPLC_VLDTN_ID;

Begin

  Open  Emp_Type;
  Fetch Emp_Type into l_Emp_Type;
  Close Emp_Type;

  hr_utility.set_location(l_proc, 10);
  Open  Tariff_Contract;
  Fetch Tariff_Contract into l_Result;
  If Tariff_Contract%NOTFOUND Then
     Close Tariff_Contract;
     hr_utility.set_message(8302,'PQH_DE_TRFCNT_VALDTN_DEF');
     hr_utility.raise_error;
  End If;
  Close Tariff_Contract;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_VERS.TARIFF_CONTRACT_CODE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Ckh_Tariff_Contract;

Procedure Ckh_Tariff_Group
  (p_effective_date               in date
  ,p_rec                          in pqh_ver_shd.g_rec_type) is
--
  l_proc       Varchar2(72) := g_package||'Ckh_Tariff_Group';
  l_Reslt      Varchar2(1);

 Cursor Tariff_Group is
   Select '1' from
   Per_gen_Hierarchy_Nodes a, Per_gen_Hierarchy_Nodes b
   Where
   a.Node_Type = 'TARIFF_GROUP'    and a.Entity_Id = p_rec.Tariff_Group_Code    And
   b.Node_Type = 'TARIFF_CONTRACT' and b.Entity_Id = p_rec.Tariff_Contract_Code and
   b.Hierarchy_Node_Id = a.Parent_Hierarchy_Node_Id And
   a.Hierarchy_Version_Id in (Select Hierarchy_Version_Id from
   Per_Gen_Hierarchy_versions a, Per_gen_Hierarchy b where
   Type = 'REMUNERATION_REGULATION' AND
   a.Hierarchy_Id = b.Hierarchy_Id  And
   p_effective_date between a.Date_From and Nvl(a.Date_To,Trunc(Sysdate)) and
   b.Business_Group_Id=p_rec.Business_Group_Id ) and
   b.Hierarchy_Version_id = a.Hierarchy_Version_id;

Begin
  hr_utility.set_location(l_proc, 10);
  Open  Tariff_Group;
  Fetch Tariff_Group into l_Reslt;
  If Tariff_Group%NOTFOUND Then
     Close Tariff_Group;
     hr_utility.set_message(8302,'PQH_DE_TRFGRP_VALDTN_DEF');
     hr_utility.raise_error;
  End If;
  Close Tariff_Group;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_VERS.TARIFF_GROUP_CODE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Ckh_Tariff_Group;

Procedure Ckh_Grade
  (p_effective_date               in date
  ,p_rec                          in pqh_ver_shd.g_rec_type) is
--
  l_proc       Varchar2(72) := g_package||'Ckh_Grade';
  l_Reslt      Varchar2(5);

 Cursor Grade_Dtls(p_Grade_Id In Number) is
 Select d.Node_Type, d.Entity_Id, e.Node_type, e.Entity_Id,
        F.Node_type, f.Entity_Id, g.Node_Type, g.Entity_Id
 from
 Per_gen_Hierarchy_Nodes a, Per_gen_Hierarchy_Nodes b,
 Per_gen_Hierarchy_Nodes c, Per_gen_Hierarchy_Nodes d,
 Per_gen_Hierarchy_Nodes e, Per_gen_Hierarchy_Nodes f,
 Per_gen_Hierarchy_Nodes g
 Where
 a.Node_TYpe         = 'PAY_GRADE'                and
 a.Entity_Id         =  p_GRADE_ID                 and
 b.Hierarchy_node_Id = a.Parent_Hierarchy_Node_Id  and
 c.Hierarchy_Node_Id = b.Parent_Hierarchy_Node_Id  and
 d.Hierarchy_Node_Id = c.Parent_Hierarchy_Node_Id  and
 e.Hierarchy_Node_Id = d.Parent_Hierarchy_Node_Id  and
 f.Hierarchy_Node_Id = e.Parent_Hierarchy_Node_Id  and
 g.Hierarchy_Node_Id = f.Parent_Hierarchy_Node_Id  and
 a.Hierarchy_Version_Id in (Select Hierarchy_Version_Id from
 Per_Gen_Hierarchy_versions a, Per_gen_Hierarchy b where
 Type = 'REMUNERATION_REGULATION' AND
 a.Hierarchy_Id = b.Hierarchy_Id  And
 p_Effective_Date between
 a.Date_From and Nvl(a.Date_To,Trunc(Sysdate))and
 b.Business_Group_Id=p_rec.Business_Group_Id  ) and
 b.Hierarchy_Version_id = a.Hierarchy_Version_id and
 c.Hierarchy_Version_id = a.Hierarchy_Version_id and
 d.Hierarchy_Version_id = a.Hierarchy_Version_id and
 e.Hierarchy_Version_id = a.Hierarchy_Version_id and
 f.Hierarchy_Version_id = a.Hierarchy_Version_id and
 g.Hierarchy_Version_id = a.Hierarchy_Version_id;

 g_Node_type   Per_gen_hierarchy_Nodes.Node_Type%TYPE;
 f_Node_type   Per_gen_hierarchy_Nodes.Node_Type%TYPE;
 e_Node_type   Per_gen_hierarchy_Nodes.Node_Type%TYPE;
 d_Node_type   Per_gen_hierarchy_Nodes.Node_Type%TYPE;
 g_Entity_Id   Per_gen_hierarchy_Nodes.Entity_Id%TYPE;
 f_Entity_Id   Per_gen_hierarchy_Nodes.Entity_Id%TYPE;
 e_Entity_Id   Per_gen_hierarchy_Nodes.Entity_Id%TYPE;
 d_Entity_Id   Per_gen_hierarchy_Nodes.Entity_Id%TYPE;
 l_Grade_id    Pqh_De_Wrkplc_Vldtn_Vers.USER_ENTERABLE_GRADE_ID%TYPE := NULL;
 l_Cnt         Number(2) := 0;
Begin
  hr_utility.set_location(l_proc, 10);
  If p_rec.USER_ENTERABLE_GRADE_ID Is not Null Then
     l_Grade_Id := p_rec.USER_ENTERABLE_GRADE_ID;
  Elsif p_rec.DERIVED_GRADE_ID Is Not Null Then
     l_Grade_Id := p_rec.DERIVED_GRADE_ID;
  End If;

  If l_Grade_Id is Not Null Then
     Open Grade_dtls(L_Grade_Id);
     Loop
     Fetch Grade_dtls into d_Node_Type, d_Entity_Id, e_Node_type, e_Entity_Id,
                           F_Node_type, f_Entity_Id, g_Node_Type, g_Entity_Id;
     If g_Node_Type = 'TARIFF_CONTRACT' and g_Entity_Id = p_rec.Tariff_Contract_Code Then
        l_Cnt := l_Cnt + 1;
        Close Grade_Dtls;
        Exit;
     Elsif f_Node_Type = 'TARIFF_CONTRACT' and f_Entity_Id = p_rec.Tariff_Contract_Code Then
        l_Cnt := l_Cnt + 1;
        Close Grade_Dtls;
        Exit;
     Elsif e_Node_Type = 'TARIFF_CONTRACT' and e_Entity_Id = p_rec.Tariff_Contract_Code Then
        l_Cnt := l_Cnt + 1;
        Close Grade_Dtls;
        Exit;
     End If;
     If Grade_dtls%NOTFOUND Then
        Close Grade_Dtls;
        hr_utility.set_message(8302,'PQH_DE_PAYGRD_VALDTN_DEF');
        hr_utility.raise_error;
        Exit;
     End If;
     End Loop;
     If l_Cnt = 0 Then
        Close Grade_Dtls;
        hr_utility.set_message(8302,'PQH_DE_PAYGRD_VALDTN_DEF');
        hr_utility.raise_error;
     End If;
  End If;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_VERS.DERIVED_GRADE_ID'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Ckh_Grade;

Procedure Ckh_Freeze
  (p_rec                          in pqh_ver_shd.g_rec_type,
   P_Chk                          In Varchar2 Default 'N') is

  l_proc       Varchar2(200) := g_package||'Ckh_Freeze';
  l_Emp_Type   Pqh_De_Wrkplc_Vldtns.EMPLOYMENT_TYPE%TYPE;
  l_Result     Varchar2(1);

Begin
   If Nvl(P_Chk,'N') = 'D' and P_rec.Freeze = 'F' Then
      hr_utility.set_message(8302,'PQH_DE_FRDEL_VALDTN_VER');
      hr_utility.raise_error;
   Else
      If P_rec.Freeze = 'F' and Nvl(p_rec.USER_ENTERABLE_GRADE_ID, P_rec.DERIVED_GRADE_ID)  is NULL Then
         hr_utility.set_message(8302,'PQH_DE_FREZE_VALDTN_VER');
         hr_utility.raise_error;
      End If;
   End If;
Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_VERS.FREEZE'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
End Ckh_Freeze;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_ver_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --


  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_ver_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
   hr_multi_message.end_validation_set;


   Ckh_Tariff_Contract(p_effective_date, p_rec);


   Ckh_Tariff_Group(p_effective_date,p_rec);


   Ckh_Grade(p_effective_date,p_rec);

   Ckh_Freeze(p_rec,'N');
  --
  -- Validate Dependent Attributes
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in pqh_ver_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pqh_ver_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date     => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --

  Ckh_Tariff_Contract(p_effective_date, p_rec);

  Ckh_Tariff_Group(p_effective_date,p_rec);

  Ckh_Grade(p_effective_date,p_rec);

  Ckh_Freeze(p_rec,'N');

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pqh_ver_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
   Ckh_Freeze(p_rec,'D');
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqh_ver_bus;

/
