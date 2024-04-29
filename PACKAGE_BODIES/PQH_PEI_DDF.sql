--------------------------------------------------------
--  DDL for Package Body PQH_PEI_DDF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PEI_DDF" as
/* $Header: pqpeiddf.pkb 115.5 2003/12/17 15:15:15 hsajja noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '   pqh_pei_ddf.';  -- Global package name
--
--
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< ddf >--------------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--    This procedure controls the validation processing required for
--    developer descriptive flexfields by calling the relevant validation
--    procedures. These are called dependant on the value of the relevant
--    entity reference field value.
--
--  Pre Conditions:
--    A fully validated entity record structure.
--
--  In Arguments:
--    p_rec (Record structure for relevant entity).
--
--  Post Success:
--    Processing of the calling api continues.
--
--  Post Failure:
--    A failure can only occur under two circumstances:
--    1) The value of reference field is not supported.
--    2) If when the reference field value is null and not all
--       the information arguments are not null(i.e. information
--       arguments cannot be set without a corresponding reference
--       field value).
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------
procedure ddf
(
                p_person_extra_info_id          in      number  ,
                p_person_id                             in      number  ,
                p_information_type              in      varchar2        ,
                p_request_id                    in      number  ,
                p_program_application_id        in      number  ,
                p_program_id                    in      number  ,
                p_program_update_date           in      date            ,
                p_pei_attribute_category        in      varchar2        ,
                p_pei_attribute1                        in      varchar2        ,
                p_pei_attribute2                        in      varchar2        ,
                p_pei_attribute3                        in      varchar2        ,
                p_pei_attribute4                        in      varchar2        ,
                p_pei_attribute5                        in      varchar2        ,
                p_pei_attribute6                        in      varchar2        ,
                p_pei_attribute7                        in      varchar2        ,
                p_pei_attribute8                        in      varchar2        ,
                p_pei_attribute9                        in      varchar2        ,
                p_pei_attribute10                       in      varchar2        ,
                p_pei_attribute11                       in      varchar2        ,
                p_pei_attribute12                       in      varchar2        ,
                p_pei_attribute13                       in      varchar2        ,
                p_pei_attribute14                       in      varchar2        ,
                p_pei_attribute15                       in      varchar2        ,
                p_pei_attribute16                       in      varchar2        ,
                p_pei_attribute17                       in      varchar2        ,
                p_pei_attribute18                       in      varchar2        ,
                p_pei_attribute19                       in      varchar2        ,
                p_pei_attribute20                       in      varchar2        ,
                p_pei_information_category      in      varchar2        ,
                p_pei_information1              in      varchar2        ,
                p_pei_information2              in      varchar2        ,
                p_pei_information3              in      varchar2        ,
                p_pei_information4              in      varchar2        ,
                p_pei_information5              in      varchar2        ,
                p_pei_information6              in      varchar2        ,
                p_pei_information7              in      varchar2        ,
                p_pei_information8              in      varchar2        ,
                p_pei_information9              in      varchar2        ,
                p_pei_information10             in      varchar2        ,
                p_pei_information11             in      varchar2        ,
                p_pei_information12             in      varchar2        ,
                p_pei_information13             in      varchar2        ,
                p_pei_information14             in      varchar2        ,
                p_pei_information15             in      varchar2        ,
                p_pei_information16             in      varchar2        ,
                p_pei_information17             in      varchar2        ,
                p_pei_information18             in      varchar2        ,
                p_pei_information19             in      varchar2        ,
                p_pei_information20             in      varchar2        ,
                p_pei_information21             in      varchar2        ,
                p_pei_information22             in      varchar2        ,
                p_pei_information23             in      varchar2        ,
                p_pei_information24             in      varchar2        ,
                p_pei_information25             in      varchar2        ,
                p_pei_information26             in      varchar2        ,
                p_pei_information27             in      varchar2        ,
                p_pei_information28             in      varchar2        ,
                p_pei_information29             in      varchar2        ,
                p_pei_information30             in      varchar2
        ) is

--
  l_proc       varchar2(72) := g_package||'ddf';
--
Cursor get_eit_name(p_information_type varchar2) is
     select descriptive_flex_context_name from FND_DESCR_FLEX_CONTEXTS_VL FLV
 WHERE FLV.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_information_type
 AND FLV.DESCRIPTIVE_FLEXFIELD_NAME = 'Extra Person Info DDF'
 AND FLV.APPLICATION_ID = 800;
 --
 l_eit_name varchar2(240);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

    if NVL(p_information_type,'X') = 'PQH_ROLE_USERS' then
     --
        chk_default_role
        (p_person_extra_info_id => p_person_extra_info_id
        ,p_information_type     => p_information_type
        ,p_person_id            => p_person_id
        ,p_pei_information3     => p_pei_information3
        ,p_pei_information4     => p_pei_information4
        );
     --
     elsif NVL(p_information_type, 'X') in ('PQH_TENURE_STATUS', 'PQH_ACADEMIC_RANK') then
     --
     if hr_general2.is_person_type(p_person_id, 'CWK', hr_general.effective_date) then
     for each_rec in get_eit_name(p_information_type) loop
        l_eit_name := each_rec.descriptive_flex_context_name;
     end loop;
     hr_utility.set_message(8302, 'PQH_CWK_EXTRA_INFO_NOT_ALLOWED');
     hr_utility.set_message_token('EIT', l_eit_name);
     hr_utility.raise_error;
     end if;
    end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

Exception
  WHEN others THEN
    raise;
End ddf;


Procedure chk_default_role
(
  p_person_extra_info_id in per_people_extra_info.person_extra_info_id%TYPE
 ,p_information_type in  per_people_extra_info.information_type%TYPE
 ,p_person_id        in  per_people_extra_info.person_id%TYPE
 ,p_pei_information3 in per_people_extra_info.pei_information3%TYPE
 ,p_pei_information4 in per_people_extra_info.pei_information4%TYPE
) is

--
  l_proc       varchar2(72) := g_package||'chk_default_role';
  l_role_id    pqh_roles.role_id%TYPE;
  l_role_name  pqh_roles.role_name%TYPE;
--
CURSOR csr_duplicate_role IS
SELECT pei_information3
FROM per_people_extra_info
WHERE person_extra_info_id <> p_person_extra_info_id
  AND NVL(information_type,'X') = 'PQH_ROLE_USERS'
  AND person_id  = p_person_id
  AND pei_information3 = p_pei_information3;

--
CURSOR csr_duplicate_default_role IS
SELECT pei_information3
FROM per_people_extra_info
WHERE person_extra_info_id <> p_person_extra_info_id
  AND NVL(information_type,'X') = 'PQH_ROLE_USERS'
  AND person_id  = p_person_id
  AND NVL(pei_information4,'N') = 'Y';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- check if the same role is being assigned more then once to the same person
  --
    OPEN csr_duplicate_role;
      FETCH csr_duplicate_role INTO l_role_id;
    CLOSE csr_duplicate_role;

     IF l_role_id IS NOT NULL THEN
      --
      -- raise error
      --
        hr_utility.set_message(8302,'PQH_DUPLICATE_ROLE');
        hr_utility.raise_error;

     END IF; -- role id is not null
  --
  -- check if the person already has a default role
  --
     IF NVL(p_pei_information4,'N') = 'Y' THEN
       --
       OPEN csr_duplicate_default_role;
         FETCH csr_duplicate_default_role INTO l_role_id;
       CLOSE csr_duplicate_default_role;

         IF l_role_id IS NOT NULL THEN
           --
           -- raise error
           --
             hr_utility.set_message(8302,'PQH_MANY_DEFAULT_ROLES');
             hr_utility.raise_error;

         END IF; -- role id is not null

     END IF; -- current role is default

  hr_utility.set_location(' Leaving:'||l_proc, 10);

Exception
  WHEN others THEN
    raise;
End chk_default_role;


--
--
end pqh_pei_ddf;

/
