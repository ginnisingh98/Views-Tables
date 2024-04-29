--------------------------------------------------------
--  DDL for Package Body HR_ORG_INFORMATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORG_INFORMATION_PKG" as
/* $Header: peori01t.pkb 120.2.12010000.5 2008/08/06 09:19:06 ubhat ship $ */
PROCEDURE Validate_SIRET (X_SIRET VARCHAR2) IS

l_rgeflg varchar2(10);
l_output varchar2(150);
l_siret varchar2(150);
l_total number;
l_total_impair number;
l_total_pair number;
l_total_1 number;
j number;

BEGIN

  if (length(X_SIRET) <> 14) then
      hr_utility.set_message(800,'PER_74846_ORG_INV_SIRET');
      hr_utility.raise_error;
  end if;

  l_siret := X_SIRET;
  begin
    hr_chkfmt.checkformat(value   => l_siret
                         ,format  => 'I'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok  => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
  exception
    when HR_UTILITY.HR_ERROR then
      hr_utility.set_message(800,'PER_74846_ORG_INV_SIRET');
      hr_utility.raise_error;
  end;
  l_total := 0;
  l_total_impair := 0;
  l_total_pair := 0;

  for i in 1..14 loop
  j:= i + 0.1;
   if i in (1,3,5,7,9,11,13) then
    l_total_1 := (to_number(substr(X_SIRET,j,1))*2);
      if (length(l_total_1) = 2) then
         l_total_impair := substr(l_total_1,1.1,1) + substr(l_total_1,2.1,1) + l_total_impair;
      else
         l_total_impair := l_total_1 + l_total_impair;
       end if;
   else
    l_total_pair := to_number(substr(X_SIRET,j,1)) + l_total_pair;
   end if;
  end loop;

l_total := l_total_pair + l_total_impair;

if mod (l_total,10) <> 0 then
  hr_utility.set_message(800,'PER_74846_ORG_INV_SIRET');
  hr_utility.raise_error;
end if;


END Validate_SIRET;

PROCEDURE Validate_SIREN (X_SIREN VARCHAR2) IS

l_rgeflg varchar2(10);
l_output varchar2(150);
l_siren varchar2(150);
l_total number;
l_total_impair number;
l_total_pair number;
l_total_1 number;
j number;

BEGIN

  if (length(X_SIREN) <> 9) then
      hr_utility.set_message(800,'PER_74847_ORG_INV_SIREN');
      hr_utility.raise_error;
  end if;

  l_siren := X_SIREN;
  begin
    hr_chkfmt.checkformat(value    => l_siren
                         ,format  => 'I'
                         ,output  => l_output
                         ,minimum => NULL
                         ,maximum => NULL
                         ,nullok => 'Y'
                         ,rgeflg  => l_rgeflg
                         ,curcode => NULL);
  exception
    when HR_UTILITY.HR_ERROR then
      hr_utility.set_message(800,'PER_74847_ORG_INV_SIREN');
      hr_utility.raise_error;
  end;

  l_total := 0;
  l_total_impair := 0;
  l_total_pair := 0;

  for i in 1..9 loop
  j:= i + 0.1;
   if i in (2,4,6,8) then
    l_total_1 := (to_number(substr(X_SIREN,j,1))*2);
      if (length(l_total_1) = 2) then
         l_total_pair := substr(l_total_1,1.1,1) + substr(l_total_1,2.1,1) + l_total_pair;
      else
         l_total_pair := l_total_1 + l_total_pair;
       end if;
   else
    l_total_impair := to_number(substr(X_SIREN,j,1)) + l_total_impair;
   end if;
  end loop;

l_total := l_total_pair + l_total_impair;

if mod (l_total,10) <> 0 then
  hr_utility.set_message(800,'PER_74847_ORG_INV_SIREN');
  hr_utility.raise_error;
end if;


END Validate_SIREN;

/* Bug 6809830 check_duplicate_tax_rules RLN 03/08 */

PROCEDURE check_duplicate_tax_rules
  (p_organization_id             IN     NUMBER
  ,p_org_information_context     IN     VARCHAR2
  ,p_org_information1            IN     VARCHAR2

  )
IS
  --
  CURSOR csr_tax_rules
    (p_organization_id              IN     NUMBER
    ,p_org_information_context      IN     VARCHAR2
    ,p_org_information1             IN     VARCHAR2

    )
  IS
    select 'Y'
    from hr_organization_information
        where ORG_INFORMATION_CONTEXT like p_org_information_context
         and org_information1 = p_org_information1
         and organization_id = p_organization_id
      ;

   l_found    varchar2(1);
--

BEGIN
  --
  --
  --
    l_found := 'N';
    --
    -- Check tax rule does not exist elsewhere
    --
    OPEN csr_tax_rules(p_organization_id
                       ,p_org_information_context
                       ,p_org_information1

                     );
    FETCH csr_tax_rules INTO l_found;
    IF (csr_tax_rules%FOUND) THEN
      --CLOSE csr_business_group_name;
      fnd_message.set_name  ('PAY','PAY_75262_US_TAX_RULES_EXIST');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_tax_rules;
    END IF;
  --

--
END check_duplicate_tax_rules;

PROCEDURE validate_business_group_name
  (p_organization_id             IN     NUMBER
  ,p_org_information_context     IN     VARCHAR2
  ,p_org_information1            IN     VARCHAR2
  ,p_org_information2            IN     VARCHAR2
  )
IS
  --
  CURSOR csr_business_group_name
    (p_organization_id              IN     NUMBER
    )
  IS
    SELECT 0
      FROM hr_organization_units org
          ,per_business_groups bgp
     WHERE bgp.name = org.name
       AND bgp.organization_id <> org.organization_id
       AND org.organization_id = p_organization_id;
  l_business_group_name           csr_business_group_name%ROWTYPE;
--
BEGIN
  --
  -- Determine if defining a business group
  --
  IF (   p_org_information_context = 'CLASS'
     AND p_org_information1 = 'HR_BG'
     AND p_org_information2 = 'Y') THEN
    --
    -- Check business group name does not exist elsewhere
    --
    OPEN csr_business_group_name(p_organization_id);
    FETCH csr_business_group_name INTO l_business_group_name;
    IF (csr_business_group_name%FOUND) THEN
      CLOSE csr_business_group_name;
      fnd_message.set_name('PER','HR_6556_ALL_BUS_GROUP_EXISTS');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_business_group_name;
    END IF;
  --
  END IF;
--
END validate_business_group_name;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Org_Information_Id           IN OUT NOCOPY  NUMBER,
                     X_Org_Information_Context             VARCHAR2,
                     X_Organization_Id                     NUMBER,
                     X_Org_Information1                    VARCHAR2,
                     X_Org_Information10                   VARCHAR2,
                     X_Org_Information11                   VARCHAR2,
                     X_Org_Information12                   VARCHAR2,
                     X_Org_Information13                   VARCHAR2,
                     X_Org_Information14                   VARCHAR2,
                     X_Org_Information15                   VARCHAR2,
                     X_Org_Information16                   VARCHAR2,
                     X_Org_Information17                   VARCHAR2,
                     X_Org_Information18                   VARCHAR2,
                     X_Org_Information19                   VARCHAR2,
                     X_Org_Information2                    VARCHAR2,
                     X_Org_Information20                   VARCHAR2,
                     X_Org_Information3                    VARCHAR2,
                     X_Org_Information4                    VARCHAR2,
                     X_Org_Information5                    VARCHAR2,
                     X_Org_Information6                    VARCHAR2,
                     X_Org_Information7                    VARCHAR2,
                     X_Org_Information8                    VARCHAR2,
                     X_Org_Information9                    VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2
 ) IS

   CURSOR C (p_org_info_id number)IS SELECT rowid FROM HR_ORGANIZATION_INFORMATION
             WHERE org_information_id = p_org_info_id;

    CURSOR C2 IS SELECT hr_organization_information_s.nextval FROM sys.dual;
 l_rowid varchar2(255);
 l_org_information_id  hr_organization_information.organization_id%type;
BEGIN

   if (X_Org_Information_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO l_Org_Information_Id;
     CLOSE C2;
     x_org_information_id := l_org_information_id;
   end if;
   hr_utility.set_location('HR_ORGANIZATION_INFORMATION',1);

   if X_org_information_context = 'FR_ESTAB_INFO' then
      Validate_SIRET(X_SIRET => X_org_information2);
   elsif X_org_information_context = 'FR_ESTAB_PREV_INFO' then
      Validate_SIRET(X_SIRET => X_org_information1);
   end if;

   if X_org_information_context = 'FR_COMP_INFO' then
      Validate_SIREN(X_SIREN => X_org_information1);
   elsif X_org_information_context = 'FR_COMP_PREV_INFO' then
      Validate_SIREN(X_SIREN => X_org_information1);
   end if;

   validate_business_group_name
     (p_organization_id         => X_Organization_Id
     ,p_org_information_context => X_Org_Information_Context
     ,p_org_information1        => X_Org_Information1
     ,p_org_information2        => X_Org_Information2
     );
if X_Org_Information_Context in ( 'State Tax Rules', 'State Tax Rules 2', 'Local Tax Rules')
   Then
   check_duplicate_tax_rules
     (p_organization_id         => X_Organization_Id
     ,p_org_information_context => X_Org_Information_Context
     ,p_org_information1        => X_Org_Information1
      );
End if ;

   INSERT INTO HR_ORGANIZATION_INFORMATION(
          org_information_id,
          org_information_context,
          organization_id,
          org_information1,
          org_information10,
          org_information11,
          org_information12,
          org_information13,
          org_information14,
          org_information15,
          org_information16,
          org_information17,
          org_information18,
          org_information19,
          org_information2,
          org_information20,
          org_information3,
          org_information4,
          org_information5,
          org_information6,
          org_information7,
          org_information8,
          org_information9,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20
         ) VALUES (
          X_Org_Information_Id,
          X_Org_Information_Context,
          X_Organization_Id,
          X_Org_Information1,
          X_Org_Information10,
          X_Org_Information11,
          X_Org_Information12,
          X_Org_Information13,
          X_Org_Information14,
          X_Org_Information15,
          X_Org_Information16,
          X_Org_Information17,
          X_Org_Information18,
          X_Org_Information19,
          X_Org_Information2,
          X_Org_Information20,
          X_Org_Information3,
          X_Org_Information4,
          X_Org_Information5,
          X_Org_Information6,
          X_Org_Information7,
          X_Org_Information8,
          X_Org_Information9,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Attribute16,
          X_Attribute17,
          X_Attribute18,
          X_Attribute19,
          X_Attribute20

  );
  hr_utility.set_location('HR_ORGANIZATION_INFORMATION',2);
  OPEN C (l_org_information_id);
  FETCH C  INTO l_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
  x_rowid := l_rowId;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Org_Information_Id                    NUMBER,
                   X_Org_Information_Context               VARCHAR2,
                   X_Organization_Id                       NUMBER,
                   X_Org_Information1                      VARCHAR2,
                   X_Org_Information10                     VARCHAR2,
                   X_Org_Information11                     VARCHAR2,
                   X_Org_Information12                     VARCHAR2,
                   X_Org_Information13                     VARCHAR2,
                   X_Org_Information14                     VARCHAR2,
                   X_Org_Information15                     VARCHAR2,
                   X_Org_Information16                     VARCHAR2,
                   X_Org_Information17                     VARCHAR2,
                   X_Org_Information18                     VARCHAR2,
                   X_Org_Information19                     VARCHAR2,
                   X_Org_Information2                      VARCHAR2,
                   X_Org_Information20                     VARCHAR2,
                   X_Org_Information3                      VARCHAR2,
                   X_Org_Information4                      VARCHAR2,
                   X_Org_Information5                      VARCHAR2,
                   X_Org_Information6                      VARCHAR2,
                   X_Org_Information7                      VARCHAR2,
                   X_Org_Information8                      VARCHAR2,
                   X_Org_Information9                      VARCHAR2,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Attribute16                           VARCHAR2,
                   X_Attribute17                           VARCHAR2,
                   X_Attribute18                           VARCHAR2,
                   X_Attribute19                           VARCHAR2,
                   X_Attribute20                           VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   HR_ORGANIZATION_INFORMATION
      WHERE  rowid = X_Rowid
      FOR UPDATE of Org_Information_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Lock_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
  --
  Recinfo.attribute9 := rtrim(Recinfo.attribute9);
  Recinfo.attribute10 := rtrim(Recinfo.attribute10);
  Recinfo.attribute11 := rtrim(Recinfo.attribute11);
  Recinfo.attribute12 := rtrim(Recinfo.attribute12);
  Recinfo.attribute13 := rtrim(Recinfo.attribute13);
  Recinfo.attribute14 := rtrim(Recinfo.attribute14);
  Recinfo.attribute15 := rtrim(Recinfo.attribute15);
  Recinfo.attribute16 := rtrim(Recinfo.attribute16);
  Recinfo.attribute17 := rtrim(Recinfo.attribute17);
  Recinfo.attribute18 := rtrim(Recinfo.attribute18);
  Recinfo.attribute19 := rtrim(Recinfo.attribute19);
  Recinfo.attribute20 := rtrim(Recinfo.attribute20);
  Recinfo.org_information_context := rtrim(Recinfo.org_information_context);
  Recinfo.org_information1 := rtrim(Recinfo.org_information1);
  Recinfo.org_information10 := rtrim(Recinfo.org_information10);
  Recinfo.org_information11 := rtrim(Recinfo.org_information11);
  Recinfo.org_information12 := rtrim(Recinfo.org_information12);
  Recinfo.org_information13 := rtrim(Recinfo.org_information13);
  Recinfo.org_information14 := rtrim(Recinfo.org_information14);
  Recinfo.org_information15 := rtrim(Recinfo.org_information15);
  Recinfo.org_information16 := rtrim(Recinfo.org_information16);
  Recinfo.org_information17 := rtrim(Recinfo.org_information17);
  Recinfo.org_information18 := rtrim(Recinfo.org_information18);
  Recinfo.org_information19 := rtrim(Recinfo.org_information19);
  Recinfo.org_information2 := rtrim(Recinfo.org_information2);
  Recinfo.org_information20 := rtrim(Recinfo.org_information20);
  Recinfo.org_information3 := rtrim(Recinfo.org_information3);
  Recinfo.org_information4 := rtrim(Recinfo.org_information4);
  Recinfo.org_information5 := rtrim(Recinfo.org_information5);
  Recinfo.org_information6 := rtrim(Recinfo.org_information6);
  Recinfo.org_information7 := rtrim(Recinfo.org_information7);
  Recinfo.org_information8 := rtrim(Recinfo.org_information8);
  Recinfo.org_information9 := rtrim(Recinfo.org_information9);
  Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
  Recinfo.attribute1 := rtrim(Recinfo.attribute1);
  Recinfo.attribute2 := rtrim(Recinfo.attribute2);
  Recinfo.attribute3 := rtrim(Recinfo.attribute3);
  Recinfo.attribute4 := rtrim(Recinfo.attribute4);
  Recinfo.attribute5 := rtrim(Recinfo.attribute5);
  Recinfo.attribute6 := rtrim(Recinfo.attribute6);
  Recinfo.attribute7 := rtrim(Recinfo.attribute7);
  Recinfo.attribute8 := rtrim(Recinfo.attribute8);
  --
  if (
          (   (Recinfo.org_information_id = X_Org_Information_Id)
           OR (    (Recinfo.org_information_id IS NULL)
               AND (X_Org_Information_Id IS NULL)))
      AND (   (Recinfo.org_information_context = X_Org_Information_Context)
           OR (    (Recinfo.org_information_context IS NULL)
               AND (X_Org_Information_Context IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.org_information1 = X_Org_Information1)
           OR (    (Recinfo.org_information1 IS NULL)
               AND (X_Org_Information1 IS NULL)))
      AND (   (Recinfo.org_information10 = X_Org_Information10)
           OR (    (Recinfo.org_information10 IS NULL)
               AND (X_Org_Information10 IS NULL)))
      AND (   (Recinfo.org_information11 = X_Org_Information11)
           OR (    (Recinfo.org_information11 IS NULL)
               AND (X_Org_Information11 IS NULL)))
      AND (   (Recinfo.org_information12 = X_Org_Information12)
           OR (    (Recinfo.org_information12 IS NULL)
               AND (X_Org_Information12 IS NULL)))
      AND (   (Recinfo.org_information13 = X_Org_Information13)
           OR (    (Recinfo.org_information13 IS NULL)
               AND (X_Org_Information13 IS NULL)))
      AND (   (Recinfo.org_information14 = X_Org_Information14)
           OR (    (Recinfo.org_information14 IS NULL)
               AND (X_Org_Information14 IS NULL)))
      AND (   (Recinfo.org_information15 = X_Org_Information15)
           OR (    (Recinfo.org_information15 IS NULL)
               AND (X_Org_Information15 IS NULL)))
      AND (   (Recinfo.org_information16 = X_Org_Information16)
           OR (    (Recinfo.org_information16 IS NULL)
               AND (X_Org_Information16 IS NULL)))
      AND (   (Recinfo.org_information17 = X_Org_Information17)
           OR (    (Recinfo.org_information17 IS NULL)
               AND (X_Org_Information17 IS NULL)))
      AND (   (Recinfo.org_information18 = X_Org_Information18)
           OR (    (Recinfo.org_information18 IS NULL)
               AND (X_Org_Information18 IS NULL)))
      AND (   (Recinfo.org_information19 = X_Org_Information19)
           OR (    (Recinfo.org_information19 IS NULL)
               AND (X_Org_Information19 IS NULL)))
      AND (   (Recinfo.org_information2 = X_Org_Information2)
           OR (    (Recinfo.org_information2 IS NULL)
               AND (X_Org_Information2 IS NULL)))
      AND (   (Recinfo.org_information20 = X_Org_Information20)
           OR (    (Recinfo.org_information20 IS NULL)
               AND (X_Org_Information20 IS NULL)))
      AND (   (Recinfo.org_information3 = X_Org_Information3)
           OR (    (Recinfo.org_information3 IS NULL)
               AND (X_Org_Information3 IS NULL)))
      AND (   (Recinfo.org_information4 = X_Org_Information4)
           OR (    (Recinfo.org_information4 IS NULL)
               AND (X_Org_Information4 IS NULL)))
      AND (   (Recinfo.org_information5 = X_Org_Information5)
           OR (    (Recinfo.org_information5 IS NULL)
               AND (X_Org_Information5 IS NULL)))
      AND (   (Recinfo.org_information6 = X_Org_Information6)
           OR (    (Recinfo.org_information6 IS NULL)
               AND (X_Org_Information6 IS NULL)))
      AND (   (Recinfo.org_information7 = X_Org_Information7)
           OR (    (Recinfo.org_information7 IS NULL)
               AND (X_Org_Information7 IS NULL)))
      AND (   (Recinfo.org_information8 = X_Org_Information8)
           OR (    (Recinfo.org_information8 IS NULL)
               AND (X_Org_Information8 IS NULL)))
      AND (   (Recinfo.org_information9 = X_Org_Information9)
           OR (    (Recinfo.org_information9 IS NULL)
               AND (X_Org_Information9 IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.attribute16 = X_Attribute16)
           OR (    (Recinfo.attribute16 IS NULL)
               AND (X_Attribute16 IS NULL)))
      AND (   (Recinfo.attribute17 = X_Attribute17)
           OR (    (Recinfo.attribute17 IS NULL)
               AND (X_Attribute17 IS NULL)))
      AND (   (Recinfo.attribute18 = X_Attribute18)
           OR (    (Recinfo.attribute18 IS NULL)
               AND (X_Attribute18 IS NULL)))
      AND (   (Recinfo.attribute19 = X_Attribute19)
           OR (    (Recinfo.attribute19 IS NULL)
               AND (X_Attribute19 IS NULL)))
      AND (   (Recinfo.attribute20 = X_Attribute20)
           OR (    (Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Org_Information_Id                  NUMBER,
                     X_Org_Information_Context             VARCHAR2,
                     X_Organization_Id                     NUMBER,
                     X_Org_Information1                    VARCHAR2,
                     X_Org_Information10                   VARCHAR2,
                     X_Org_Information11                   VARCHAR2,
                     X_Org_Information12                   VARCHAR2,
                     X_Org_Information13                   VARCHAR2,
                     X_Org_Information14                   VARCHAR2,
                     X_Org_Information15                   VARCHAR2,
                     X_Org_Information16                   VARCHAR2,
                     X_Org_Information17                   VARCHAR2,
                     X_Org_Information18                   VARCHAR2,
                     X_Org_Information19                   VARCHAR2,
                     X_Org_Information2                    VARCHAR2,
                     X_Org_Information20                   VARCHAR2,
                     X_Org_Information3                    VARCHAR2,
                     X_Org_Information4                    VARCHAR2,
                     X_Org_Information5                    VARCHAR2,
                     X_Org_Information6                    VARCHAR2,
                     X_Org_Information7                    VARCHAR2,
                     X_Org_Information8                    VARCHAR2,
                     X_Org_Information9                    VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2
) IS
--
-- declare local variables
--
l_dummy      VARCHAR2(1);
l_state_code VARCHAR2(2);
l_carrier_id VARCHAR2(17);
--
-- declare cursors
--
CURSOR	get_orig_values IS
select
	org_information1,
	org_information8
from
	hr_organization_information
where
	org_information_id	= X_org_information_id;
--
CURSOR check_override IS
SELECT
	'x'
FROM
	pay_wc_rates wcr,
	pay_wc_funds wcf
WHERE
	wcf.carrier_id = l_carrier_id	AND
	wcf.state_code = l_state_code	AND
	wcr.fund_id	= wcf.fund_id
AND EXISTS
      (	SELECT	'code referenced in override'
	FROM	per_assignments_f a,
		fnd_id_flex_structures_vl ifs,
		hr_soft_coding_keyflex sck
	WHERE	sck.segment1	= to_char(X_organization_id) -- #1683897
	AND	segment8	= to_char(wcr.wc_code)
	AND	ifs.id_flex_structure_name = 'GREs and other data'
	AND	sck.id_flex_num = ifs.id_flex_num
	AND	a.assignment_type = 'E'
	AND	a.soft_coding_keyflex_id = sck.soft_coding_keyflex_id );
--
BEGIN
--
-- US specific validation to check that if the structure being updated is
-- 'State Tax Rules' and the segment being updated is WC Carrier then
-- check that a WC rate for this carrier is not being referenced by
-- an assignment's 'WC Override Code' on the SCL 'GREs and other data'
--
hr_utility.set_location ('hr_org_information_pkg.update_row', 1);
--
IF (X_Org_Information_Context = 'State Tax Rules')
THEN
--
hr_utility.set_location ('hr_org_information_pkg.update_row', 2);
--
-- get original values
--
 OPEN  get_orig_values;
 FETCH get_orig_values into l_state_code, l_carrier_id;
 CLOSE get_orig_values;
 --
 -- check if values have changed
 --
 IF ((l_state_code <> X_org_information1) OR
     (NVL(l_carrier_id, X_org_information8) <> X_org_information8) OR
      X_org_information8 IS NULL)
 THEN
hr_utility.set_location ('hr_org_information_pkg.update_row', 3);
  OPEN  check_override;
  FETCH check_override into l_dummy;
  IF check_override%FOUND
  THEN
      hr_utility.set_location ('hr_org_information_pkg.update_row', 4);
      hr_utility.set_message(800,'HR_51039_ORG_WC_OVRRD_RATE_REF');
      hr_utility.raise_error;
  END IF;
  CLOSE check_override;
hr_utility.set_location ('hr_org_information_pkg.update_row', 5);
 END IF;
END IF; -- end US specific validation

 if X_org_information_context = 'FR_ESTAB_INFO' then
      Validate_SIRET(X_SIRET => X_org_information2);
   elsif X_org_information_context = 'FR_ESTAB_PREV_INFO' then
      Validate_SIRET(X_SIRET => X_org_information1);
   end if;

   if X_org_information_context = 'FR_COMP_INFO' then
      Validate_SIREN(X_SIREN => X_org_information1);
   elsif X_org_information_context = 'FR_COMP_PREV_INFO' then
      Validate_SIREN(X_SIREN => X_org_information1);
   end if;

  validate_business_group_name
    (p_organization_id         => X_Organization_Id
    ,p_org_information_context => X_Org_Information_Context
    ,p_org_information1        => X_Org_Information1
    ,p_org_information2        => X_Org_Information2
    );

   if X_Org_Information_Context in ( 'State Tax Rules', 'State Tax Rules 2', 'Local Tax Rules')
    Then
    check_duplicate_tax_rules
     (p_organization_id         => X_Organization_Id
     ,p_org_information_context => X_Org_Information_Context
     ,p_org_information1        => X_Org_Information1
      );
   End if ;

--
   UPDATE HR_ORGANIZATION_INFORMATION
  SET
    org_information_id                        =    X_Org_Information_Id,
    org_information_context                   =    X_Org_Information_Context,
    organization_id                           =    X_Organization_Id,
    org_information1                          =    X_Org_Information1,
    org_information10                         =    X_Org_Information10,
    org_information11                         =    X_Org_Information11,
    org_information12                         =    X_Org_Information12,
    org_information13                         =    X_Org_Information13,
    org_information14                         =    X_Org_Information14,
    org_information15                         =    X_Org_Information15,
    org_information16                         =    X_Org_Information16,
    org_information17                         =    X_Org_Information17,
    org_information18                         =    X_Org_Information18,
    org_information19                         =    X_Org_Information19,
    org_information2                          =    X_Org_Information2,
    org_information20                         =    X_Org_Information20,
    org_information3                          =    X_Org_Information3,
    org_information4                          =    X_Org_Information4,
    org_information5                          =    X_Org_Information5,
    org_information6                          =    X_Org_Information6,
    org_information7                          =    X_Org_Information7,
    org_information8                          =    X_Org_Information8,
    org_information9                          =    X_Org_Information9,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','Update_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;

END Update_Row;



PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM HR_ORGANIZATION_INFORMATION
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','Delete_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
END Delete_Row;

END HR_ORG_INFORMATION_PKG;

/
