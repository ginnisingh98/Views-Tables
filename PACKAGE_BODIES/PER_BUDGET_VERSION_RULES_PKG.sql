--------------------------------------------------------
--  DDL for Package Body PER_BUDGET_VERSION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BUDGET_VERSION_RULES_PKG" as
/* $Header: pebgr01t.pkb 115.3 2002/12/09 14:37:09 raranjan ship $ */

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
g_package  varchar2(33) := '  per_budget_version_rules_pkg.';  -- Global package name


-- ----------------------------------------------------------------------------
-- |---------------------------< Delete_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2) is
    CURSOR C_Elements is
           SELECT pbe.Rowid
           FROM per_budget_elements pbe
           WHERE pbe.budget_version_id = (SELECT pbv.budget_version_id
                                          FROM per_budget_versions pbv
                                          WHERE pbv.Rowid = X_Rowid);
--
  l_ele_rowid VARCHAR2(30);
  l_budget_id NUMBER(15);
  l_proc   VARCHAR2(72) := g_package||'Delete_Row';
--
  BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
   SELECT pbv.budget_id
   INTO l_budget_id
   FROM per_budget_versions pbv
   WHERE pbv.Rowid = X_Rowid;
 --
  OPEN C_Elements;
  -- Cascade delete the appropriate child budget_elements recs if
  -- parent per_budgets budget_type_code is 'HR_BUDGET';
  -- (use budget_id in chk_ota_budget_type)
  IF per_budgets_pkg.chk_OTA_Budget_Type(l_budget_id, NULL, NULL) = FALSE THEN
    LOOP
      FETCH C_Elements into l_ele_rowid;
      EXIT when (C_Elements%NOTFOUND);
      PER_BUDGET_ELEMENTS_PKG.Delete_Row(X_Rowid => l_ele_rowid);
    END LOOP;
  ELSE
    FETCH C_Elements into l_ele_rowid;
    IF C_Elements%FOUND THEN
      CLOSE C_Elements;
      --raise error as child record has been found
      hr_utility.set_message(800,'PER_52876_BUD_VER_DELETE_FAIL');
      hr_utility.raise_error;
    END IF;
  END IF;
  CLOSE C_Elements;

  --now delete the version
  DELETE FROM per_budget_versions
  WHERE Rowid = X_Rowid;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END Delete_Row;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Vers_Exists >---------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Vers_Exists(X_Budget_Id NUMBER,
                     X_Rowid     VARCHAR2) return BOOLEAN is
-- PRIVATE FUNCTION used by Chk_Prev_Rec.
--
  l_result VARCHAR2(255);
  l_proc   VARCHAR2(72) := g_package||'Vers_Exists';
--
  Begin
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT null
  INTO l_result
  FROM per_budget_versions pbv
  WHERE pbv.budget_id = X_Budget_Id
  AND (pbv.rowid <> X_Rowid
       OR X_Rowid is Null);
  If (SQL%FOUND) then
    Return TRUE;
  End if;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  Exception
    when no_data_found then
      Return FALSE;
    when too_many_rows then
      Return TRUE;
End Vers_Exists;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Gap_Exists >---------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Gap_Exists(X_Budget_Id NUMBER,
                    X_Rowid     VARCHAR2,
                    X_Date_From DATE,
                   X_Date_To DATE) return BOOLEAN is
-- PRIVATE FUNCTION used by Chk_Prev_Rec.
--
  CURSOR Before is
         select pbv.date_to,pbv.date_from
         from per_budget_versions pbv
         where pbv.budget_id = X_Budget_Id
         and (pbv.rowid <> X_Rowid
              OR X_Rowid is null)
         and pbv.date_to = (select max(pbv2.date_to)
                            from per_budget_versions pbv2
                            where pbv2.budget_id = X_Budget_Id
                            and (pbv2.rowid <> X_Rowid
                                 OR X_Rowid is null)
                            and pbv2.date_to < X_Date_From);
--
  CURSOR After is
         select pbv.date_to,pbv.date_from
         from per_budget_versions pbv
         where pbv.budget_id = X_Budget_Id
         and (pbv.rowid <> X_Rowid
              OR X_Rowid is null)
         and pbv.date_from = (select min(pbv2.date_from)
                            from per_budget_versions pbv2
                            where pbv2.budget_id = X_Budget_Id
                            and (pbv2.rowid <> X_Rowid
                                 OR X_Rowid is null)
                            and pbv2.date_from > X_Date_To);
--
  l_date_to DATE;
  l_date_from DATE;
  l_proc   VARCHAR2(72) := g_package||'Gap_Exists';
--

  Begin
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    Begin
    OPEN Before;
    FETCH Before into l_date_to,l_date_from;
    If (Before%FOUND) then
-- There is a preceding version, so is there a gap between it
-- and the present version.
      if (X_Date_From - 1 > l_date_to) then
        CLOSE Before;
        RETURN TRUE;
      end if;
    CLOSE Before;
    end if;
--
    exception
    when no_data_found then
      CLOSE Before;
    End;
--
  Begin
    OPEN After;
    FETCH After into l_date_to,l_date_from;
    If (After%FOUND) then
    If (l_date_from - 1 > X_Date_To) then
--  There is a succeeding version with a gap between it
--  and the present version
        CLOSE After;
        RETURN TRUE;
      End if;
    CLOSE After;
    End if;
--
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  exception
  when no_data_found then
    CLOSE After;
  End;
--
  RETURN FALSE;
End Gap_Exists;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Overlap_Exists >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Overlap_Exists(X_Budget_Id NUMBER,
                        X_Rowid     VARCHAR2,
                        X_Date_From DATE,
                        X_Date_To DATE) return BOOLEAN is
--
  CURSOR Before is
         select pbv.date_to,pbv.date_from
         from per_budget_versions pbv
         where pbv.budget_id = X_Budget_Id
         and (pbv.rowid <> X_Rowid
              OR X_Rowid is null)
         and pbv.date_to = (select max(pbv2.date_to)
                            from per_budget_versions pbv2
                            where pbv2.budget_id = X_Budget_Id
                            and (pbv2.rowid <> X_Rowid
                                 OR X_Rowid is null)
                            and pbv2.date_from < X_Date_From);
--
--
  CURSOR After is
         select pbv.date_to,pbv.date_from
         from per_budget_versions pbv
         where pbv.budget_id = X_Budget_Id
         and (pbv.rowid <> X_Rowid
             OR X_Rowid is null)
         and pbv.date_from = (select min(pbv2.date_from)
                            from per_budget_versions pbv2
                            where pbv2.budget_id = X_Budget_Id
                            and (pbv2.rowid <> X_Rowid
                                 OR X_Rowid is null)
                            and pbv2.date_from > X_Date_From);
--
  l_date_to DATE;
  l_date_from DATE;
  l_proc   VARCHAR2(72) := g_package||'Overlap_Exists';
--
  Begin
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  Begin
    OPEN Before;
    FETCH Before into l_date_to,l_date_from;
    If (Before%FOUND) then
      If (X_Date_From < l_date_to) then
        CLOSE Before;
        RETURN TRUE;
      End If;
      CLOSE Before;
    End if;
    Exception
    when no_data_found then
      CLOSE Before;
  End;
--
  Begin
  OPEN After;
  FETCH After into l_date_to,l_date_from;
  If (After%FOUND) then
    If (X_Date_To > l_date_from) then
      CLOSE After;
      RETURN TRUE;
    End If;
    CLOSE After;
  End if;

  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
    Exception
    when no_data_found then
      CLOSE After;
  End;
--
  RETURN FALSE;
--
End Overlap_Exists;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Update_Versions >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Update_Versions(X_Budget_Id NUMBER
                         ,X_Rowid VARCHAR2
                         ,X_Date_From DATE
                         ,X_Date_To IN OUT NOCOPY DATE) is
--
  CURSOR C is select pbv1.date_from, pbv1.date_to
              from per_budget_versions pbv1
              where pbv1.budget_id = X_Budget_Id
              and (pbv1.rowid <> X_Rowid
                   OR X_Rowid is NULL)
              and pbv1.date_from = (select max(pbv2.date_from)
                               from per_budget_versions pbv2
                               where pbv2.date_from < X_Date_From
                               and   pbv2.budget_id = X_Budget_Id
                               and   (pbv2.rowid <> X_Rowid
                               OR X_Rowid is NULL))
              FOR UPDATE;
--
  CURSOR C2 is select pbv1.date_from, pbv1.date_to
              from per_budget_versions pbv1
              where pbv1.budget_id = X_Budget_Id
              and (pbv1.rowid <> X_Rowid
                   OR X_Rowid is NULL)
              and pbv1.date_from = (select min(pbv2.date_from)
                               from per_budget_versions pbv2
                               where pbv2.date_from > X_Date_From
                               and   pbv2.budget_id = X_Budget_Id
                               and   (pbv2.rowid <> X_Rowid
                               OR X_Rowid is NULL))
              FOR UPDATE;
--
  l_date_from DATE;
  l_date_to   DATE;
  l_proc   VARCHAR2(72) := g_package||'Update_Versions';
--
  Begin
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
--
  OPEN C;
  FETCH C into l_date_from,l_date_to;
  IF (C%FOUND) then
--A preceding version exists
    IF (l_date_to is null) then
  --which runs to the end of time and commences before the new version
  --so close the old version down on the day preceding the new version
  --
      UPDATE per_budget_versions
      SET date_to = X_Date_From - 1
      WHERE current of C;
--
    End if;
  CLOSE C;
  Elsif (C%NOTFOUND) then
    CLOSE C;
    OPEN C2;
    FETCH C2 into l_date_from,l_date_to;
    IF (C2%FOUND) then
-- A succeeding version exists
     if (X_Date_To is null) and (l_date_from > X_Date_From) then
-- set the date_to of the present record to the day
-- before the succeeding version
       X_Date_To := l_date_from - 1;
     end if;
     CLOSE C2;
    ELSE
     CLOSE C2;
    End if;
  end if;

  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  Exception
    when no_data_found then
    CLOSE C;
      null;
End Update_Versions;

-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_Prev_Rec >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Prev_Rec(X_Budget_Id NUMBER,
                       X_Date_From DATE,
                       X_Date_To  IN OUT NOCOPY  DATE,
                       X_Rowid     VARCHAR2,
                       X_Result IN OUT NOCOPY VARCHAR2) is
--
  l_proc   VARCHAR2(72) := g_package||'Chk_Prev_Rec';
  Begin
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
--
-- First check if there are any other versions apart from the present one.
--
  IF vers_exists(X_Budget_Id,X_Rowid) then
--
-- now check for any overlap.
--
   If Overlap_Exists(X_Budget_Id,X_Rowid,X_Date_From,X_Date_To) then
--
--  prevent the operation
--
      hr_utility.set_message('801','HR_6105_BUD_OVERLAP');
      hr_utility.raise_error;
    End if;
--
--  now update the other version if neccessary.
--
    Update_Versions(X_Budget_Id,X_Rowid,X_Date_From,X_Date_To);
--
-- check if there is a gap between them
--
--
   If Gap_Exists(X_Budget_Id,X_Rowid,X_Date_From,X_Date_To) then
--
--  then warn the user.
      X_Result := 'Warn';
   Else
      X_Result := 'Success';
   End If;
--
  End if;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
--
END Chk_Prev_Rec;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< Get_Id >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Get_Id(X_Budget_Version_Id  IN OUT NOCOPY NUMBER) IS
    l_proc   VARCHAR2(72) := g_package||'Get_Id';
  BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    SELECT per_budget_versions_s.nextval
    INTO X_Budget_Version_Id
    FROM dual;

  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End Get_Id;

-- ----------------------------------------------------------------------------
-- |-------------------------< Chk_Version_Number >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Version_Number(X_Version_Number IN VARCHAR2) IS
    l_proc   VARCHAR2(72) := g_package||'Chk_Version_Number';
  BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
    IF X_Version_Number <> '1' THEN
      hr_utility.set_message(800,'PER_52875_INV_VERSION_NUM');
      hr_utility.raise_error;
    END IF;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End Chk_Version_Number;

-- ----------------------------------------------------------------------------
-- |------------------------< Chk_Budget_Version_Id >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Budget_Version_Id (X_Budget_Version_Id IN NUMBER,
				 X_Rowid             IN VARCHAR2) IS

 CURSOR c_bdv IS
 SELECT null
 FROM per_budget_versions pbv
 WHERE pbv.budget_version_id = x_budget_version_id
 AND (pbv.rowid <> X_ROWID or X_Rowid IS NULL);

    l_result VARCHAR2(255);
    l_proc   VARCHAR2(72) := g_package||'Chk_Budget_Version_Id';

BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  OPEN c_bdv;
  FETCH c_bdv INTO l_result;
  IF c_bdv%FOUND THEN
    CLOSE c_bdv;
    hr_utility.set_message(801,'HR_6107_BUD_VER_EXISTS');
    hr_utility.raise_error;
  END IF;
  CLOSE c_bdv;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End Chk_Budget_Version_Id;

-- ----------------------------------------------------------------------------
-- |----------------------------< Chk_df >------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_df(x_attribute_category  varchar2
                ,x_attribute1          varchar2
                ,x_attribute2          varchar2
                ,x_attribute3          varchar2
                ,x_attribute4          varchar2
                ,x_attribute5          varchar2
                ,x_attribute6          varchar2
                ,x_attribute7          varchar2
                ,x_attribute8          varchar2
                ,x_attribute9          varchar2
                ,x_attribute10         varchar2
                ,x_attribute11         varchar2
                ,x_attribute12         varchar2
                ,x_attribute13         varchar2
                ,x_attribute14         varchar2
                ,x_attribute15         varchar2
                ,x_attribute16         varchar2
                ,x_attribute17         varchar2
                ,x_attribute18         varchar2
                ,x_attribute19         varchar2
                ,x_attribute20         varchar2) IS

     l_proc   VARCHAR2(72) := g_package||'Chk_df';

BEGIN
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_BUDGET_VERSIONS'
      ,p_attribute_category => x_attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => x_attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => x_attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => x_attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => x_attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => x_attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => x_attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => x_attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => x_attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => x_attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => x_attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => x_attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => x_attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => x_attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => x_attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => x_attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => x_attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => x_attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => x_attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => x_attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => x_attribute20);
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
END Chk_df;

-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_Unique >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Unique(X_Rowid             VARCHAR2,
                     X_Business_Group_Id NUMBER,
                     X_Version_Number    VARCHAR2,
                     X_Budget_Id         NUMBER) is
  l_result VARCHAR2(255);
  l_proc   VARCHAR2(72) := g_package||'Chk_Unique';
Begin
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT NULL
  INTO l_result
  FROM per_budget_versions bver
  WHERE UPPER(X_Version_Number) = UPPER(bver.Version_number)
  AND X_Business_group_Id = bver.Business_Group_Id
  AND X_Budget_Id = bver.Budget_Id
  AND (bver.Rowid <> X_Rowid or X_Rowid is null);

  IF (SQL%FOUND) then
    hr_utility.set_message(801,'HR_6107_BUD_VER_EXISTS');
    hr_utility.raise_error;
  end if;

  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  when NO_DATA_FOUND then
    null;
end Chk_Unique;


-- ----------------------------------------------------------------------------
-- |---------------------------< Default_Date_From >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Default_Date_From(X_Date_From  IN OUT NOCOPY DATE,
                            X_Session_Date      DATE,
                            X_Budget_Id         NUMBER) IS

/*CURSOR C IS SELECT MAX(DATE_FROM + 1)
            FROM PER_BUDGET_VERSIONS
            WHERE BUDGET_ID = X_Budget_Id
            AND DATE_TO IS NULL;*/
CURSOR C is select pbv1.date_from,pbv1.date_to
            from per_budget_versions pbv1
            where pbv1.budget_id = X_Budget_Id
            and pbv1.date_from = (select max(pbv2.date_from)
                                  from per_budget_versions pbv2
                                  where pbv2.budget_id = X_Budget_Id);
--
  l_date_from DATE;
  l_date_to DATE;
  l_proc   VARCHAR2(72) := g_package||'Default_Date_From';
--
Begin
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  OPEN C;
  FETCH C INTO l_date_from,l_date_to;
  IF (C%NOTFOUND) then
    X_Date_From := X_Session_Date;
  ELSIF (C%FOUND) then
    if l_date_to is null then
      X_Date_From := l_date_from + 1;
    else
      X_Date_From := l_date_to + 1;
    end if;
--
  END IF;
  CLOSE C;
--
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End Default_Date_From;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Insert_Row >---------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE Insert_Row(X_Rowid                        IN  OUT NOCOPY    VARCHAR2
	            ,X_Budget_version_id            IN  OUT NOCOPY    NUMBER
	            ,X_Business_group_id                     NUMBER
                    ,X_Budget_id                             NUMBER
                    ,X_Date_from                             DATE
                    ,X_Version_number                        VARCHAR2
                    ,X_Comments                              VARCHAR2
                    ,X_Date_to                               DATE
                    ,X_Request_id                            NUMBER
                    ,X_Program_application_id                NUMBER
                    ,X_Program_id                            NUMBER
                    ,X_Program_update_date                   DATE
                    ,X_Attribute_category                    VARCHAR2
                    ,X_Attribute1                            VARCHAR2
                    ,X_Attribute2                            VARCHAR2
                    ,X_Attribute3                            VARCHAR2
                    ,X_Attribute4                            VARCHAR2
                    ,X_Attribute5                            VARCHAR2
                    ,X_Attribute6                            VARCHAR2
                    ,X_Attribute7                            VARCHAR2
                    ,X_Attribute8                            VARCHAR2
                    ,X_Attribute9                            VARCHAR2
                    ,X_Attribute10                           VARCHAR2
                    ,X_Attribute11                           VARCHAR2
                    ,X_Attribute12                           VARCHAR2
                    ,X_Attribute13                           VARCHAR2
                    ,X_Attribute14                           VARCHAR2
                    ,X_Attribute15                           VARCHAR2
                    ,X_Attribute16                           VARCHAR2
                    ,X_Attribute17                           VARCHAR2
                    ,X_Attribute18                           VARCHAR2
                    ,X_Attribute19                           VARCHAR2
                    ,X_Attribute20                           VARCHAR2
 ) IS

   CURSOR C1 IS SELECT rowid FROM PER_BUDGET_VERSIONS
             WHERE budget_version_id = X_budget_version_id;

  l_proc   VARCHAR2(72) := g_package||'Insert_Row';

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- validate mandatory business_group
    hr_api.validate_bus_grp_id(X_Business_Group_Id);

  -- validate mandatory version number
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'version_number',
       p_argument_value => X_Version_Number);

  -- validate mandatory budget_id
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'budget_id',
       p_argument_value => X_Budget_Id);

  -- If the parent record is OTA_BUDGET type, and no budget version exists
  -- for the budget_id then continue, else raise error.
    IF per_budgets_pkg.Chk_OTA_Budget_Type(X_Budget_id,NULL,NULL) THEN
      IF vers_exists(X_Budget_id,NULL) THEN
        hr_utility.set_message(800,'HR_52873_OTA_BUD_EXISTS');
        hr_utility.raise_error;
      ELSE
        -- call chk routine to validate value TP
        chk_version_number(x_version_number);
      END IF;
    ELSE
      hr_utility.set_message(800,'PER_52874_NOT_OTA_VERSION');
      hr_utility.raise_error;
    END IF;

  -- validate mandatory date_from is not null
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'date_from',
       p_argument_value => X_Date_From);


  -- validate per_budget_versions df
  Chk_df(X_Attribute_Category,
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
         X_Attribute20);

  -- Get new budget_version_id
  per_budget_version_rules_pkg.get_id(X_budget_version_id);

  INSERT INTO PER_BUDGET_VERSIONS(budget_version_id
                                 ,business_group_id
                                 ,budget_id
				 ,date_from
				 ,version_number
				 ,comments
				 ,date_to
				 ,request_id
				 ,program_application_id
				 ,program_id
				 ,program_update_date
				 ,attribute_category
                                 ,attribute1
                                 ,attribute2
                                 ,attribute3
                                 ,attribute4
                                 ,attribute5
                                 ,attribute6
                                 ,attribute7
                                 ,attribute8
                                 ,attribute9
                                 ,attribute10
                                 ,attribute11
                                 ,attribute12
                                 ,attribute13
                                 ,attribute14
                                 ,attribute15
                                 ,attribute16
                                 ,attribute17
                                 ,attribute18
                                 ,attribute19
                                 ,attribute20
                                 ) VALUES (
				  X_Budget_Version_Id
                                 ,X_Business_Group_Id
                                 ,X_Budget_Id
				 ,X_Date_from
				 ,X_Version_number
				 ,X_Comments
			  	 ,X_Date_to
			         ,X_Request_id
				 ,X_Program_application_id
				 ,X_Program_id
				 ,X_Program_update_date
                                 ,X_Attribute_Category
                                 ,X_Attribute1
                                 ,X_Attribute2
                                 ,X_Attribute3
                                 ,X_Attribute4
                                 ,X_Attribute5
                                 ,X_Attribute6
                                 ,X_Attribute7
                                 ,X_Attribute8
                                 ,X_Attribute9
                                 ,X_Attribute10
                                 ,X_Attribute11
                                 ,X_Attribute12
                                 ,X_Attribute13
                                 ,X_Attribute14
                                 ,X_Attribute15
                                 ,X_Attribute16
                                 ,X_Attribute17
                                 ,X_Attribute18
                                 ,X_Attribute19
                                 ,X_Attribute20);

  OPEN C1;
  FETCH C1 INTO X_Rowid;
  IF (C1%NOTFOUND) THEN
    CLOSE C1;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C1;
--
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END Insert_Row;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< Lock_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                               VARCHAR2
		  ,X_Budget_Version_id                   NUMBER
		  ,X_Business_Group_Id                   NUMBER
                  ,X_Budget_Id                           NUMBER
                  ,X_Date_from                           DATE
                  ,X_Version_number                      VARCHAR2
                  ,X_Comments                            VARCHAR2
                  ,X_Date_to                             DATE
                  ,X_Request_id                          NUMBER
                  ,X_Program_application_id              NUMBER
	          ,X_Program_id                          NUMBER
                  ,X_Program_update_date                 DATE
                  ,X_Attribute_Category                  VARCHAR2
                  ,X_Attribute1                          VARCHAR2
                  ,X_Attribute2                          VARCHAR2
                  ,X_Attribute3                          VARCHAR2
                  ,X_Attribute4                          VARCHAR2
                  ,X_Attribute5                          VARCHAR2
                  ,X_Attribute6                          VARCHAR2
                  ,X_Attribute7                          VARCHAR2
                  ,X_Attribute8                          VARCHAR2
                  ,X_Attribute9                          VARCHAR2
                  ,X_Attribute10                         VARCHAR2
                  ,X_Attribute11                         VARCHAR2
                  ,X_Attribute12                         VARCHAR2
                  ,X_Attribute13                         VARCHAR2
                  ,X_Attribute14                         VARCHAR2
                  ,X_Attribute15                         VARCHAR2
                  ,X_Attribute16                         VARCHAR2
                  ,X_Attribute17                         VARCHAR2
                  ,X_Attribute18                         VARCHAR2
                  ,X_Attribute19                         VARCHAR2
                  ,X_Attribute20                         VARCHAR2) IS
  CURSOR C IS
      SELECT *
      FROM   PER_BUDGET_VERSIONS
      WHERE  rowid = X_Rowid
      FOR UPDATE of budget_version_id  NOWAIT;
  Recinfo C%ROWTYPE;
  l_proc   VARCHAR2(72) := g_package||'Lock_Row';
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --

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
Recinfo.Budget_version_id := rtrim(Recinfo.Budget_version_id);
Recinfo.Business_group_id := rtrim(Recinfo.Business_group_id);
Recinfo.Budget_id := rtrim(Recinfo.Budget_id);
Recinfo.Date_from := rtrim(Recinfo.Date_from);
Recinfo.Version_number := rtrim(Recinfo.Version_number);
Recinfo.Comments := rtrim(Recinfo.Comments);
Recinfo.Date_to := rtrim(Recinfo.Date_to);
Recinfo.Request_id := rtrim(Recinfo.Request_id);
Recinfo.Program_application_id := rtrim(Recinfo.Program_application_id);
Recinfo.Program_id := rtrim(Recinfo.Program_id);
Recinfo.Program_update_date := rtrim(Recinfo.Program_update_date);
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
  if (
          (   (Recinfo.Budget_version_id = X_Budget_version_id)
           OR (    (Recinfo.Budget_version_id IS NULL)
               AND (X_Budget_version_id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.Budget_id = X_Budget_id)
           OR (    (Recinfo.Budget_id IS NULL)
               AND (X_Budget_id IS NULL)))
      AND (   (Recinfo.Date_from = X_Date_from)
           OR (    (Recinfo.Date_from IS NULL)
               AND (X_Date_from IS NULL)))
      AND (   (Recinfo.Version_number = X_Version_number)
           OR (    (Recinfo.Version_number IS NULL)
               AND (X_Version_number IS NULL)))
      AND (   (Recinfo.Comments = X_Comments)
           OR (    (Recinfo.Comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.Date_to = X_Date_to)
           OR (    (Recinfo.Date_to IS NULL)
               AND (X_Date_to IS NULL)))
      AND (   (Recinfo.Request_id = X_Request_id)
           OR (    (Recinfo.Request_id IS NULL)
               AND (X_Request_id IS NULL)))
      AND (   (Recinfo.Program_application_id = X_Program_application_id)
           OR (    (Recinfo.Program_application_id IS NULL)
               AND (X_Program_application_id IS NULL)))
      AND (   (Recinfo.Program_id = X_Program_id)
           OR (    (Recinfo.Program_id IS NULL)
               AND (X_Program_id IS NULL)))
      AND (   (Recinfo.Program_update_date = X_Program_update_date)
           OR (    (Recinfo.Program_update_date IS NULL)
               AND (X_Program_update_date IS NULL)))
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
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END Lock_Row;

-- ----------------------------------------------------------------------------
-- |---------------------------< Update_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2
		    ,X_Budget_Version_id                   NUMBER
		    ,X_Business_Group_Id                   NUMBER
                    ,X_Budget_Id                           NUMBER
                    ,X_Date_from                           DATE
                    ,X_Version_number                      VARCHAR2
                    ,X_Comments                            VARCHAR2
                    ,X_Date_to                             DATE
                    ,X_Request_id                          NUMBER
                    ,X_Program_application_id              NUMBER
	            ,X_Program_id                          NUMBER
                    ,X_Program_update_date                 DATE
                    ,X_Attribute_Category                  VARCHAR2
                    ,X_Attribute1                          VARCHAR2
                    ,X_Attribute2                          VARCHAR2
                    ,X_Attribute3                          VARCHAR2
                    ,X_Attribute4                          VARCHAR2
                    ,X_Attribute5                          VARCHAR2
                    ,X_Attribute6                          VARCHAR2
                    ,X_Attribute7                          VARCHAR2
                    ,X_Attribute8                          VARCHAR2
                    ,X_Attribute9                          VARCHAR2
                    ,X_Attribute10                         VARCHAR2
                    ,X_Attribute11                         VARCHAR2
                    ,X_Attribute12                         VARCHAR2
                    ,X_Attribute13                         VARCHAR2
                    ,X_Attribute14                         VARCHAR2
                    ,X_Attribute15                         VARCHAR2
                    ,X_Attribute16                         VARCHAR2
                    ,X_Attribute17                         VARCHAR2
                    ,X_Attribute18                         VARCHAR2
                    ,X_Attribute19                         VARCHAR2
                    ,X_Attribute20                         VARCHAR2) IS
  l_proc   VARCHAR2(72) := g_package||'Update_Row';
BEGIN
  --
    hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- validate mandatory business_group
    hr_api.validate_bus_grp_id(X_Business_Group_Id);

  -- validate mandatory version_number
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'version_number',
       p_argument_value => X_Version_Number);

  -- validate mandatory rowid
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'rowid',
       p_argument_value => X_Rowid);

  -- validate budget_version_id
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'budget_version_id',
       p_argument_value => X_Budget_Version_Id);

    chk_budget_version_id (X_Budget_Version_Id,X_Rowid);

  -- validate mandatory date_from is not null
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'date_from',
       p_argument_value => X_Date_From);

  -- validate mandatory date_from is not null
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'budget_id',
       p_argument_value => X_Budget_Id);

  -- If the parent record is OTA_BUDGET type, and no budget version exists
  -- for the budget_id then continue, else raise error.
    IF per_budgets_pkg.Chk_OTA_Budget_Type(X_Budget_id,NULL,NULL) THEN
      IF vers_exists(X_Budget_id,X_Rowid) THEN
        hr_utility.set_message(800,'PER_52873_OTA_BUD_EXISTS');
        hr_utility.raise_error;
      ELSE
        -- call chk routine to validate value TP
        chk_version_number(x_version_number);
      END IF;
    ELSE
      hr_utility.set_message(800,'PER_52874_NOT_OTA_VERSION');
      hr_utility.raise_error;
    END IF;

  -- validate per_budget_versions df
  Chk_df(X_Attribute_Category,
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
         X_Attribute20);


  -- Get new budget_version_id
  UPDATE PER_BUDGET_VERSIONS
  SET
    budget_version_id                         =    X_Budget_Version_id
   ,business_group_id                         =    X_Business_Group_Id
   ,budget_id                                 =    X_Budget_Id
   ,date_from                                 =    X_Date_from
   ,version_number                            =    X_Version_number
   ,comments                                  =    X_Comments
   ,date_to	                              =    X_Date_to
   ,request_id                                =    X_Request_id
   ,program_application_id                    =    X_Program_application_id
   ,program_id                                =    X_Program_id
   ,program_update_date                       =    X_Program_update_date
   ,attribute_category                        =    X_Attribute_Category
   ,attribute1                                =    X_Attribute1
   ,attribute2                                =    X_Attribute2
   ,attribute3                                =    X_Attribute3
   ,attribute4                                =    X_Attribute4
   ,attribute5                                =    X_Attribute5
   ,attribute6                                =    X_Attribute6
   ,attribute7                                =    X_Attribute7
   ,attribute8                                =    X_Attribute8
   ,attribute9                                =    X_Attribute9
   ,attribute10                               =    X_Attribute10
   ,attribute11                               =    X_Attribute11
   ,attribute12                               =    X_Attribute12
   ,attribute13                               =    X_Attribute13
   ,attribute14                               =    X_Attribute14
   ,attribute15                               =    X_Attribute15
   ,attribute16                               =    X_Attribute16
   ,attribute17                               =    X_Attribute17
   ,attribute18                               =    X_Attribute18
   ,attribute19                               =    X_Attribute19
   ,attribute20                               =    X_Attribute20
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Update_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END Update_Row;

end PER_BUDGET_VERSION_RULES_PKG;

/
