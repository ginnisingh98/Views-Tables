--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION_UNITS_PKG" as
/* $Header: peoru01t.pkb 120.0 2005/05/31 12:20:37 appldev noship $ */
--------------------------------------------------------------------------------
g_dummy    number(1);    -- Dummy for cursor returns which are not needed
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--------------------------------------------------------------------------------
PROCEDURE chk_repbody_seat_numbers
  (p_organization_id         IN hr_organization_units.organization_id%TYPE
  ,p_org_information_context IN hr_organization_information.org_information_context%TYPE
  ,p_org_information6        IN hr_organization_information.org_information6%TYPE
  ,p_org_information2        IN hr_organization_information.org_information2%TYPE
  ,p_rowid                   IN VARCHAR2) IS
  --
  CURSOR repbody_max_seats IS
  SELECT hoi.org_information6
  FROM   hr_organization_information hoi
  WHERE  hoi.organization_id         = p_organization_id
  AND    hoi.org_information_context = 'Representative Body';
  --
  CURSOR constituency_total_seats1 IS
  SELECT sum(hoi.org_information2)
  FROM   hr_organization_information hoi
  WHERE  hoi.organization_id = p_organization_id
  AND    hoi.org_information_context = 'RepBody_Constituencies'
  AND    rowid <> p_rowid;
  --
  CURSOR constituency_total_seats2 IS
  SELECT sum(hoi.org_information2)
  FROM   hr_organization_information hoi
  WHERE  hoi.organization_id = p_organization_id
  AND    hoi.org_information_context = 'RepBody_Constituencies';
  --
  l_proc                     VARCHAR2(72) := g_package||'chk_repbody_seat_numbers';
  l_repbody_max_seats        NUMBER :=NULL;
  l_constituency_total_seats NUMBER :=0;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  IF p_org_information_context = 'Representative Body' Then
    --
    l_repbody_max_seats := p_org_information6;
    --
  ELSE
    --
    OPEN  repbody_max_seats;
    FETCH repbody_max_seats INTO l_repbody_max_seats;
    CLOSE repbody_max_seats;
    --
  END IF;
  --
  hr_utility.set_location(l_proc,20);
  --
  IF l_repbody_max_seats IS NOT NULL THEN
    --
    IF p_rowid is NULL THEN
      --
      OPEN constituency_total_seats2;
      FETCH constituency_total_seats2 into l_constituency_total_seats;
      CLOSE constituency_total_seats2;
      --
    ELSE
      --
      OPEN constituency_total_seats1;
      FETCH constituency_total_seats1 into l_constituency_total_seats;
      CLOSE constituency_total_seats1;
      --
    END IF;
    --
    hr_utility.set_location(l_proc,30);
    --
    l_constituency_total_seats := NVL(l_constituency_total_seats,0) + NVL(p_org_information2,0);
    --
    IF l_constituency_total_seats > l_repbody_max_seats THEN
      --
      hr_utility.set_message(800,'HR_289048_CON_INV_SEAT_NUM');
      hr_utility.raise_error;
      --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 10);
  --
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  --
END chk_repbody_seat_numbers;
--
FUNCTION Is_Org_A_Node
  (p_search_org_id             IN hr_organization_units.organization_id%TYPE
  ,p_organization_structure_id IN per_org_structure_versions_v.organization_structure_id%TYPE)
  RETURN CHAR IS
  --
  Cursor   c_get_structure_version Is
    Select posvv.org_structure_version_id version_id
    From   per_organization_structures_v  posv,
           per_org_structure_versions_v   posvv
    Where  posvv.organization_structure_id = posv.organization_structure_id
    And    posv.organization_structure_id  = p_organization_structure_id;
  --
  Cursor   c_orgs_in_hierarchy
   (p_version_id IN per_org_structure_versions_v.organization_structure_id%TYPE) IS
    select posev.organization_id_parent org_id
    from   per_org_structure_elements_v   posev
    where  posev.org_Structure_version_id  = p_version_id
    UNION
    select posev.organization_id_child org_id
    from   per_org_structure_elements_v   posev
    where  posev.org_Structure_version_id  = p_version_id;
  --
  v_org_in_hierarchy    BOOLEAN       := FALSE;
  v_users_starting_node VARCHAR2(240) := NULL;
  v_return_message      VARCHAR2(5);
  --
  v_version_id per_org_structure_versions_v.organization_structure_id%TYPE := NULL;
  --
  l_proc VARCHAR2(72) := g_package||'Is_Org_A_Node';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  OPEN  c_get_structure_version;
  FETCH c_get_structure_version INTO v_version_id;
  CLOSE c_get_structure_version;
  --
  hr_utility.set_location(l_proc,20);
  --
  FOR c_rec IN c_orgs_in_hierarchy(v_version_id) LOOP
    --
    IF c_rec.org_id = p_search_org_id THEN
      --
      v_org_in_hierarchy := TRUE;
      --
    END IF;
    --
    EXIT WHEN v_org_in_hierarchy;
    --
  END LOOP;
  --
  hr_utility.set_location(l_proc,30);
  --
  IF v_org_in_hierarchy THEN
    --
    v_return_message := 'TRUE';
    --
    hr_utility.set_location(l_proc,40);
    --
  ELSIF NOT v_org_in_hierarchy THEN
    --
    v_return_message := 'FALSE';
    --
    hr_utility.set_location(l_proc,50);
    --
  END IF;
  --
  hr_utility.set_location('Leaving'|| l_proc, 60);
  --
  RETURN(v_return_message);
  --
END Is_Org_A_Node;
--
function exists_in_hierarchy(p_org_structure_version_id NUMBER
                             ,p_organization_id NUMBER) return varchar2 is
--
l_temp VARCHAR2(1) := 'N';
begin
  select 'Y'
  into l_temp
  from sys.dual
  where exists (select null
                from    per_org_structure_elements      ose
                where   ose.org_structure_version_id    =
                                       p_org_structure_version_id
                and   (ose.organization_id_child      =  p_organization_id
                or     ose.organization_id_parent     = p_organization_id));
--
return l_temp;
--
exception
       when no_data_found then
         return l_temp;
       when others then
         raise;
end;
--
function get_parent(p_organization_id NUMBER
                   ,p_org_structure_version_id NUMBER) return NUMBER is
--
l_parent_id NUMBER :=0;
begin
  select ose.organization_id_parent
  into l_parent_id
  from per_org_structure_elements ose
  where ose.org_structure_version_id = p_org_structure_version_id
  and   ose.organization_id_child = p_organization_id;
--
--
  return l_parent_id;
  exception
    when no_data_found then
      return l_parent_id;
    when others then
      raise;
end;

procedure form_post_query(p_exists_in_hierarchy in out nocopy VARCHAR2
                         ,p_view_all_orgs VARCHAR2
                         ,p_organization_id NUMBER
                         ,p_org_structure_version_id NUMBER
                         ,p_security_profile_id NUMBER
                         ,p_number_of_subordinates in out nocopy NUMBER) is
--
begin
  p_exists_in_hierarchy:= exists_in_hierarchy(p_org_structure_version_id
                                             ,p_organization_id);
  if p_exists_in_hierarchy = 'Y' then
    p_number_of_subordinates :=
  per_org_structure_elements_pkg.get_subordinates(p_view_all_orgs
                             ,p_organization_id
                             ,p_org_structure_version_id
                             ,p_security_profile_id);
  else
    p_number_of_subordinates := 0;
  end if;
end;

procedure check_gre(p_org_id NUMBER) is
l_dummy varchar2(1);
cursor test_loc(p_type VARCHAR2) is
select 'Y'
from hr_organization_information hoi
  where hoi.org_INFORMATION_CONTEXT = 'CLASS'
  and   hoi.org_information1 = p_type
  and   hoi.org_information2 = 'Y' -- Bug 3456540
  and   hoi.organization_id = p_org_id;
begin
  open test_loc('HR_LEGAL');
  fetch test_loc into l_dummy;
  if test_loc%FOUND then
    close test_loc;
    hr_utility.set_message(801,'HR_6612_ORG_LEGAL_NO_LOCATION');
    hr_utility.raise_error;
  end if;
  close test_loc;
--
  open test_loc('HR_ESTAB');
  fetch test_loc into l_dummy;
  if test_loc%FOUND then
    close test_loc;
    hr_utility.set_message(801,'HR_7342_ORG_RE_NO_LOC');
    hr_utility.raise_error;
  end if;
  close test_loc;

end;
-- -----------------------------------------------------------------------------
-- Checks, if organization is also a business group, that another business group
-- with the same name does not already exist
-- -----------------------------------------------------------------------------
PROCEDURE validate_business_group_name
  (p_organization_id             IN     NUMBER
  ,p_name                        IN     VARCHAR2
  )
IS
  --
  CURSOR csr_business_group
    (p_organization_id              IN     NUMBER
    )
  IS
    SELECT 0
      FROM hr_organization_information ori
     WHERE ori.org_information_context = 'CLASS'
       AND ori.org_information1 = 'HR_BG'
       AND ori.org_information2 = 'Y'
       AND ori.organization_id = p_organization_id;
  l_business_group              csr_business_group%ROWTYPE;
  --
  CURSOR csr_business_group_name
    (p_organization_id              IN     NUMBER
    ,p_name                         IN     VARCHAR2
    )
  IS
    SELECT 0
      FROM hr_all_organization_units org
          ,hr_all_organization_units_tl otl
          ,hr_organization_information ori
     WHERE ori.org_information_context = 'CLASS'
       AND ori.org_information1 = 'HR_BG'
       AND ori.org_information2 = 'Y'
       AND ori.organization_id = org.organization_id
       AND otl.name = p_name
       AND otl.language = userenv('LANG')
       AND otl.organization_id = org.organization_id
       AND org.organization_id <> p_organization_id;
  l_business_group_name         csr_business_group_name%ROWTYPE;
  --
  l_is_business_group           BOOLEAN := FALSE;
--
BEGIN
  --
  -- Determine if organization is business group
  --
  OPEN csr_business_group(p_organization_id);
  FETCH csr_business_group INTO l_business_group;
  l_is_business_group := csr_business_group%FOUND;
  CLOSE csr_business_group;
  --
  -- Check business group name does not already exist elsewhere
  --
  IF (l_is_business_group) THEN
    --
    OPEN csr_business_group_name(p_organization_id,p_name);
    FETCH csr_business_group_name INTO l_business_group_name;
    IF (csr_business_group_name%FOUND) THEN
      CLOSE csr_business_group_name;
      fnd_message.set_name('PER','HR_6556_ALL_BUS_GROUP_EXISTS');
      fnd_message.raise_error;
    ELSE
      CLOSE csr_business_group_name;
    END IF;
  END IF;
--
END validate_business_group_name;
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Organization_Id                     IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Cost_Allocation_Keyflex_Id          NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Soft_Coding_Keyflex_Id              NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Internal_External_Flag              VARCHAR2,
                     X_Internal_Address_Line               VARCHAR2,
                     X_Type                                VARCHAR2,
             X_Security_Profile_Id                 NUMBER,
             X_View_All_Orgs                       VARCHAR2,
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
   CURSOR C IS SELECT rowid FROM HR_ALL_ORGANIZATION_UNITS
             WHERE organization_id = X_Organization_Id;

   CURSOR C2 IS SELECT hr_organization_units_s.nextval FROM sys.dual;

BEGIN
  --
  validate_business_group_name
    (p_organization_id => X_Organization_Id
    ,p_name            => X_Name
    );
  /*
  ** Insert the main organization record into the HR_ORGANIZATION_UNITS
  ** table.
  */
   if (X_Organization_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Organization_Id;
     CLOSE C2;
   end if;
  INSERT INTO HR_ALL_ORGANIZATION_UNITS(
          organization_id,
          business_group_id,
          cost_allocation_keyflex_id,
          location_id,
          soft_coding_keyflex_id,
          date_from,
          name,
          comments,
          date_to,
          internal_external_flag,
          internal_address_line,
          type,
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
          X_Organization_Id,
          X_Business_Group_Id,
          X_Cost_Allocation_Keyflex_Id,
          X_Location_Id,
          X_Soft_Coding_Keyflex_Id,
          X_Date_From,
          X_Name,
          X_Comments,
          X_Date_To,
          X_Internal_External_Flag,
          X_Internal_Address_Line,
          X_Type,
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
--
  insert into HR_ALL_ORGANIZATION_UNITS_TL (
--    BUSINESS_GROUP_ID,
    ORGANIZATION_ID,
    NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
--    X_Business_Group_Id,
    X_Organization_Id,
    X_Name,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HR_ALL_ORGANIZATION_UNITS_TL T
    where
--  T.BUSINESS_GROUP_ID = X_Business_Group_Id
    T.ORGANIZATION_ID = X_Organization_Id
    and T.LANGUAGE = L.LANGUAGE_CODE);
--
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;

  if X_View_All_Orgs <> 'Y' then
    /*
    ** Set up the secure user information into the PER_ORGANIZATION_LIST
    ** table. This is so that the org is immediately visible.
    */
    hr_security.add_organization(X_Organization_Id,
                                 X_Security_Profile_Id);
  end if;

END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Organization_Id                       NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Cost_Allocation_Keyflex_Id            NUMBER,
                   X_Location_Id                           NUMBER,
                   X_Soft_Coding_Keyflex_Id                NUMBER,
                   X_Date_From                             DATE,
                   X_Name                                  VARCHAR2,
                   X_Comments                              VARCHAR2,
                   X_Date_To                               DATE,
                   X_Internal_External_Flag                VARCHAR2,
                   X_Internal_Address_Line                 VARCHAR2,
                   X_Type                                  VARCHAR2,
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

/*  CURSOR C IS
      SELECT *
      FROM   HR_ALL_ORGANIZATION_UNITS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Organization_Id NOWAIT;
*/
-- cursor is changed to fix the bug 2145187 (second part MLS)
-- If condition also is changed to compare name_tl, rather than name
--       (Recinfo.name_tl = X_Name)
--           OR (    (Recinfo.name_tl IS NULL)
--               AND (X_Name IS NULL)))
  CURSOR C IS
      SELECT oru.*,orutl.name name_tl
      FROM   HR_ALL_ORGANIZATION_UNITS ORU,
             HR_ALL_ORGANIZATION_UNITS_TL ORUTL
      WHERE  ORU.rowid = X_Rowid
      AND    ORU.organization_id = ORUTL.organization_id
      AND    ORUTL.language      = userenv('LANG')
      FOR UPDATE of ORU.Organization_Id NOWAIT;
  Recinfo C%ROWTYPE;
--
  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HR_ALL_ORGANIZATION_UNITS_TL
    where
--  BUSINESS_GROUP_ID = X_Business_Group_Id
    ORGANIZATION_ID = X_Organization_Id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ORGANIZATION_ID nowait;
--
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Lock_row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
  --
  Recinfo.name_tl := rtrim(Recinfo.name_tl);
  Recinfo.name := rtrim(Recinfo.name);
  Recinfo.comments := rtrim(Recinfo.comments);
  Recinfo.internal_external_flag := rtrim(Recinfo.internal_external_flag);
  Recinfo.internal_address_line := rtrim(Recinfo.internal_address_line);
  Recinfo.type := rtrim(Recinfo.type);
  Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
  Recinfo.attribute1 := rtrim(Recinfo.attribute1);
  Recinfo.attribute2 := rtrim(Recinfo.attribute2);
  Recinfo.attribute3 := rtrim(Recinfo.attribute3);
  Recinfo.attribute4 := rtrim(Recinfo.attribute4);
  Recinfo.attribute5 := rtrim(Recinfo.attribute5);
  Recinfo.attribute6 := rtrim(Recinfo.attribute6);
  Recinfo.attribute7 := rtrim(Recinfo.attribute7);
  Recinfo.attribute8 := rtrim(Recinfo.attribute8);
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
  --
  if (
          (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.cost_allocation_keyflex_id = X_Cost_Allocation_Keyflex_Id)
           OR (    (Recinfo.cost_allocation_keyflex_id IS NULL)
               AND (X_Cost_Allocation_Keyflex_Id IS NULL)))
      AND (   (Recinfo.location_id = X_Location_Id)
           OR (    (Recinfo.location_id IS NULL)
               AND (X_Location_Id IS NULL)))
      AND (   (Recinfo.soft_coding_keyflex_id = X_Soft_Coding_Keyflex_Id)
           OR (    (Recinfo.soft_coding_keyflex_id IS NULL)
               AND (X_Soft_Coding_Keyflex_Id IS NULL)))
      AND (   (Recinfo.date_from = X_Date_From)
           OR (    (Recinfo.date_from IS NULL)
               AND (X_Date_From IS NULL)))
      AND (   (Recinfo.name_tl = X_Name)
           OR (    (Recinfo.name_tl IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.date_to = X_Date_To)
           OR (    (Recinfo.date_to IS NULL)
               AND (X_Date_To IS NULL)))
      AND (   (Recinfo.internal_external_flag = X_Internal_External_Flag)
           OR (    (Recinfo.internal_external_flag IS NULL)
               AND (X_Internal_External_Flag IS NULL)))
      AND (   (Recinfo.internal_address_line = X_Internal_Address_Line)
           OR (    (Recinfo.internal_address_line IS NULL)
               AND (X_Internal_Address_Line IS NULL)))
      AND (   (Recinfo.type = X_Type)
           OR (    (Recinfo.type IS NULL)
               AND (X_Type IS NULL)))
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
    --return;
    null;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
--
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
--
return;
--
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Organization_Id                     NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Cost_Allocation_Keyflex_Id          NUMBER,
                     X_Location_Id                         NUMBER,
                     X_Soft_Coding_Keyflex_Id              NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Internal_External_Flag              VARCHAR2,
                     X_Internal_Address_Line               VARCHAR2,
                     X_Type                                VARCHAR2,
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
BEGIN
  --
  validate_business_group_name
    (p_organization_id => X_Organization_Id
    ,p_name            => X_Name
    );
  --
  UPDATE HR_ALL_ORGANIZATION_UNITS
  SET

    organization_id                           =    X_Organization_Id,
    business_group_id                         =    X_Business_Group_Id,
    cost_allocation_keyflex_id                =    X_Cost_Allocation_Keyflex_Id,
    location_id                               =    X_Location_Id,
    soft_coding_keyflex_id                    =    X_Soft_Coding_Keyflex_Id,
    date_from                                 =    X_Date_From,
    name                                      =    X_Name,
    comments                                  =    X_Comments,
    date_to                                   =    X_Date_To,
    internal_external_flag                    =    X_Internal_External_Flag,
    internal_address_line                     =    X_Internal_Address_Line,
    type                                      =    X_Type,
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
-- VT 12/14/98 restored rowid usage to create New Business Groups.
--    WHERE BUSINESS_GROUP_ID = X_Business_Group_Id
--      AND ORGANIZATION_ID   = X_Organization_Id;

  if (SQL%NOTFOUND) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','Update_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
--
  update HR_ALL_ORGANIZATION_UNITS_TL set
    NAME = X_Name,
    SOURCE_LANG = userenv('LANG')
  where
-- BUSINESS_GROUP_ID = X_Business_Group_Id
  ORGANIZATION_ID = X_Organization_Id
  and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
--
END Update_Row;




FUNCTION get_org_class (X_Organization_Id NUMBER, X_Organization_Class VARCHAR2) return boolean is

cursor csr_org_class is
                    select '1'
                    from HR_ORGANIZATION_INFORMATION
                    where organization_id = X_Organization_Id
                    and   org_information1 = X_Organization_Class
                    and   org_information_context = 'CLASS';

l_org_class varchar2(150);

begin
   open csr_org_class;
   fetch csr_org_class into l_org_class;
   if csr_org_class%found then
     return(true);
   else
     return(false);
   end if;
   close csr_org_class;

end;

PROCEDURE Validate_delete (X_Organization_Id NUMBER,
                           X_Business_Group_Id Number) IS
cursor csr_employer  is
                        select '1'
                        from per_collective_agreements_v
                        where employer_organization_id = X_Organization_Id;

cursor csr_barg_units  is
                        select '1'
                        from per_collective_agreements_v
                        where bargaining_organization_id = X_Organization_Id;

cursor csr_leg_code is
                        select legislation_code
                        from per_business_groups
                        where business_group_id = X_Business_Group_id;

--
-- Cursor removed as part of fix for bug 1858597,
--
/*cursor csr_leg_pkg(p_pkg_name varchar2) is
                        select '1'
                        from user_source
                        where name = p_pkg_name
                        and rownum < 2;*/
--
-- Cursor added as part of fix for 1858597
--
cursor csr_leg_pkg(p_pkg_name varchar2) is
                        select '1'
                        from user_objects
                        where object_name = p_pkg_name
                        and object_type = 'PACKAGE';
--
l_dummy varchar2(1);
l_leg_code varchar2(150);
l_cursor number;
l_proc_call varchar2(500);
l_package_name varchar2(50);
l_procedure_name varchar2(50);

BEGIN
  --
  if get_org_class(X_Organization_Id,'EMPLOYER') then
    --
    open csr_employer;
    fetch csr_employer into l_dummy;
   --
    if csr_employer%found then
      --
     -- Close Cursor added a part of fix for bug 1858597
     --
     close csr_employer;
     --
      hr_utility.set_message(800,'PER_52852_ORG_DEL_CAGR');
      hr_utility.raise_error;
     --
    end if;
    --
    close csr_employer;
    --
  end if;
  --
  if get_org_class(X_Organization_Id,'BARGAINING_UNIT') then
    --
    open csr_barg_units;
    fetch csr_barg_units into l_dummy;
   --
    if csr_barg_units%found then
      --
     -- Close Cursor added a part of fix for bug 1858597
     --
     close csr_barg_units;
      hr_utility.set_message(800,'PER_52852_ORG_DEL_CAGR');
      hr_utility.raise_error;
     --
    end if;
    --
    close csr_barg_units;
    --
  end if;
  --
  -- Check the leg code for the business_group
  --
  open csr_leg_code;
  fetch csr_leg_code into l_leg_code;
  --
  if csr_leg_code%found then
    --
    -- If one exists then we must check whether there exists a legislation
    -- specific Validate_Delete procedure. This should be named in the format
    -- PER_XX_VALIDATE_DELETE_PKG.VALIDATE_DELETE
    -- If it does exist then construct an anonymous PL/SQL block to call
    -- the procedure, passing the ORG_ID, otherwise do nothing.
    --

    l_package_name   := 'PER_'||l_leg_code||'_VALIDATE_DELETE_PKG';
    l_procedure_name := 'VALIDATE_DELETE';
    --
   -- Close Cursor added a part of fix for bug 1858597
   --
   close csr_leg_code;
   --
    -- Check package exists
   --
    open csr_leg_pkg(l_package_name);
    fetch csr_leg_pkg into l_dummy;
   --
    if csr_leg_pkg%found then
     --
     -- Close Cursor added a part of fix for bug 1858597
     --
     close csr_leg_pkg;
     --
     -- Added as part of fix for bug 1858597
     --
     EXECUTE IMMEDIATE 'BEGIN '||
                      l_package_name||'.'||
                       l_procedure_name||
                  '(:X_ORGANIZATION_ID); END;'
              USING X_Organization_Id;
      --
      -- Section commented out as part of fix for bug 1858597
     --
      /*l_cursor := dbms_sql.open_cursor;
     --
      -- construct an anonymous block with bind variable
     --
      l_proc_call := 'BEGIN '||
                     l_package_name||'.'||
                  l_procedure_name||
                  '(:X_ORGANIZATION_ID); END;';
     --
      dbms_sql.parse(l_cursor, l_proc_call, dbms_sql.v7);
      --
      -- Bind the Org Id into the procedure call
     --
      dbms_sql.bind_variable(l_cursor, 'X_ORGANIZATION_ID', X_Organization_id);
      --
      -- Execute the block
      --
      l_dummy := dbms_sql.execute(l_cursor);*/
      --
    end if;
     --
  end if;
  --
END Validate_delete;


PROCEDURE Delete_Row(X_Rowid           VARCHAR2,
                     X_Business_Group_Id NUMBER,
             X_Organization_Id NUMBER,
             X_View_All_Orgs   VARCHAR2) IS
BEGIN
--
-- Delete the Organization from PER_ORGANIZATION_LIST.
--
Validate_delete(X_Organization_Id => X_Organization_Id,
                X_Business_Group_Id => X_Business_Group_Id);

--
  delete from HR_ALL_ORGANIZATION_UNITS_TL
  where
-- BUSINESS_GROUP_ID = X_Business_Group_Id
  ORGANIZATION_ID = X_Organization_Id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

--
--
-- Delete the Organization from PER_ORGANIZATION_LIST.
--
  if X_View_All_Orgs <> 'Y' then
    hr_security.delete_org_from_list(X_Organization_Id);
  end if;
--
  DELETE FROM HR_ALL_ORGANIZATION_UNITS
  WHERE  BUSINESS_GROUP_ID = X_Business_Group_Id
  AND ORGANIZATION_ID = X_Organization_Id;
--
  if (SQL%NOTFOUND) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','Delete_Row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
END Delete_Row;
--
PROCEDURE zoom_forms(X_destination IN VARCHAR2
                    ,X_ORGANIZATION_ID IN NUMBER
                    ,X_SOB_ID IN OUT NOCOPY NUMBER
                    ,X_ORG_CODE IN OUT NOCOPY VARCHAR2
                    ,X_CHART_OF_ACCOUNTS IN OUT NOCOPY NUMBER) IS
--
l_sql_text VARCHAR2(2000);
l_sql_cursor NUMBER;
l_rows_fetched NUMBER;
l_out_int number;
l_out_vc CHAR(30);
l_col_error NUMBER;
l_act_length number :=3;
begin
  if X_destination in ('INV_ORGANIZATION_PARAMETERS'
                      ,'RCV_ORGANIZATION_PARAMETERS'
                      ,'MRP_ORGANIZATION_PARAMETERS'
                      ,'WIP_ORGANIZATION_PARAMETERS')
  then
    l_sql_text := 'select hoi.ORG_INFORMATION1 '
          ||'from   hr_organization_information hoi '
          ||'where  hoi.organization_id = '||to_char(X_ORGANIZATION_ID)||' '
             ||'and    hoi.org_information_context = ''Accounting Information''';
    --
    -- Open Cursor for Processing Sql statment.
    --
    l_sql_cursor := dbms_sql.open_cursor;
    --
    -- Parse SQL statement.
    -- uses 1 as NATIVE DATABASE
    dbms_sql.parse(l_sql_cursor, l_sql_text, 1);
    --
    -- Map the local variables to each returned Column
    --
    dbms_sql.define_column(l_sql_cursor, 1,X_SOB_ID);
    --
    -- Execute the SQL statement.
    --
    l_rows_fetched := dbms_sql.execute(l_sql_cursor);
    --
    if (dbms_sql.fetch_rows(l_sql_cursor) > 0)
    then
    --
    -- Extract the select list for the current row into local variables.
     --
     dbms_sql.column_value(l_sql_cursor, 1,X_SOB_ID);
     --
    else
     fnd_message.set_name('INV','INV_ACCOUNT_BEFORE_INV');
     fnd_message.raise_error;
    end if;
     dbms_sql.close_cursor(l_sql_cursor);
  if X_DESTINATION in ('RCV_ORGANIZATION_PARAMETERS'
                      ,'MRP_ORGANIZATION_PARAMETERS'
                      ,'WIP_ORGANIZATION_PARAMETERS')
  then
        l_sql_text := 'select mp.organization_code '
           ||'from mtl_parameters mp '
           ||'where mp.organization_id = '|| to_char(X_ORGANIZATION_ID);
        if X_DESTINATION = 'WIP_ORGANIZATION_PARAMETERS'
        -- add extra WIP business rule check.
        then
          l_sql_text := l_sql_text
               ||' and mp.cost_organization_id = mp.organization_id';
        end if;
    --
    -- Open Cursor for Processing Sql statment.
    --
    l_sql_cursor := dbms_sql.open_cursor;
    --
    -- Parse SQL statement.
    -- uses 1 as NATIVE DATABASE
    dbms_sql.parse(l_sql_cursor, l_sql_text, 1);
    --
    -- Map the local variables to each returned Column
    --
    dbms_sql.define_column(l_sql_cursor, 1,X_ORG_CODE,l_act_length);
    --
    -- Execute the SQL statement.
    --
    l_rows_fetched := dbms_sql.execute(l_sql_cursor);
    --
    if (dbms_sql.fetch_rows(l_sql_cursor) > 0)
    then
    --
    -- Extract the select list for the current row into local variables.
     --
     dbms_sql.column_value(l_sql_cursor, 1,X_ORG_CODE);
     --
    else
         if X_DESTINATION = 'WIP_ORGANIZATION_PARAMETERS' then
           fnd_message.set_name('WIP','WIP_PARAMETERS_NOT_ALLOWED');
         else
       fnd_message.set_name('INV','INV_ACCOUNT_BEFORE_INV');
         end if;
     fnd_message.raise_error;
     end if;
     dbms_sql.close_cursor(l_sql_cursor);
    --
    if X_DESTINATION = 'RCV_ORGANIZATION_PARAMETERS' then
    l_sql_text := 'select gsb.chart_of_accounts_id '
                    ||' from gl_sets_of_books gsb '
                    ||' where gsb.set_of_books_id = '||to_char(X_SOB_ID);
    --
    -- Open Cursor for Processing Sql statment.
    --
    l_sql_cursor := dbms_sql.open_cursor;
    --
    -- Parse SQL statement.
    -- uses 1 as NATIVE DATABASE
    dbms_sql.parse(l_sql_cursor, l_sql_text, 1);
    --
    -- Map the local variables to each returned Column
    --
    dbms_sql.define_column(l_sql_cursor, 1,X_CHART_OF_ACCOUNTS);
    --
    -- Execute the SQL statement.
    --
    l_rows_fetched := dbms_sql.execute(l_sql_cursor);
    --
    if (dbms_sql.fetch_rows(l_sql_cursor) > 0)
    then
    --
    -- Extract the select list for the current row into local variables.
     --
     dbms_sql.column_value(l_sql_cursor, 1,X_CHART_OF_ACCOUNTS);
     --
    else
     fnd_message.set_name('INV','INV_ACCOUNT_BEFORE_INV');
     fnd_message.raise_error;
     end if;
     dbms_sql.close_cursor(l_sql_cursor);
  end if;
  end if;
  end if;
end zoom_forms;
--
procedure ADD_LANGUAGE
is
begin
  delete from HR_ALL_ORGANIZATION_UNITS_TL T
  where not exists
    (select NULL
    from HR_ALL_ORGANIZATION_UNITS B
    where B.ORGANIZATION_ID = T.ORGANIZATION_ID
    );

  update HR_ALL_ORGANIZATION_UNITS_TL T set (
      NAME
    ) = (select
      B.NAME
    from HR_ALL_ORGANIZATION_UNITS_TL B
    where B.ORGANIZATION_ID = T.ORGANIZATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ORGANIZATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ORGANIZATION_ID,
      SUBT.LANGUAGE
    from HR_ALL_ORGANIZATION_UNITS_TL SUBB, HR_ALL_ORGANIZATION_UNITS_TL SUBT
    where SUBB.ORGANIZATION_ID = SUBT.ORGANIZATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into HR_ALL_ORGANIZATION_UNITS_TL (
    ORGANIZATION_ID,
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORGANIZATION_ID,
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HR_ALL_ORGANIZATION_UNITS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_ALL_ORGANIZATION_UNITS_TL T
    where T.ORGANIZATION_ID = B.ORGANIZATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
--------------------------------------------------------------------------------
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                  p_legislation_code IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
END;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure validate_translation(organization_id IN NUMBER,
                   language IN VARCHAR2,
                   name IN VARCHAR2,
                   p_business_group_id IN NUMBER DEFAULT NULL)
                   IS
/*

This procedure fails if an organization translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated organization names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_org_name IN VARCHAR2,
                     p_org_id IN NUMBER,
                     p_bus_grp_id IN NUMBER)
             IS
       SELECT  1
     FROM  hr_all_organization_units_tl orgt,
           hr_all_organization_units org
     WHERE upper(orgt.name)=upper(p_org_name)
     AND   orgt.organization_id = org.organization_id
     AND   orgt.language = p_language
     AND   (org.organization_id <> p_org_id OR p_org_id IS NULL)
     AND   (org.business_group_id = p_bus_grp_id OR p_bus_grp_id IS NULL)
     ;

       l_package_name VARCHAR2(80) := 'HR_ORGANIZATION_UNITS_PKG.VALIDATE_TRANSLATION';
       l_business_group_id NUMBER := nvl(p_business_group_id, g_business_group_id);

BEGIN
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, name,organization_id,
             l_business_group_id);
          hr_utility.set_location (l_package_name,50);
       FETCH c_translation INTO g_dummy;

       IF c_translation%NOTFOUND THEN
          hr_utility.set_location (l_package_name,60);
      CLOSE c_translation;
       ELSE
          hr_utility.set_location (l_package_name,70);
      CLOSE c_translation;
      fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
      fnd_message.raise_error;
       END IF;
          hr_utility.set_location ('Leaving:'||l_package_name,80);
END validate_translation;
--------------------------------------------------------------------------------
END HR_ORGANIZATION_UNITS_PKG;

/
