--------------------------------------------------------
--  DDL for Package Body HR_NAVIGATION_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NAVIGATION_UNITS_PKG" as
/* $Header: pewfl01t.pkb 120.0 2005/05/31 23:07:49 appldev noship $ */
procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is
begin
  if X_OWNER = 'SEED' then
    X_CREATED_BY := 1;
    X_LAST_UPDATED_BY := 1;
  else
    X_CREATED_BY := 0;
    X_LAST_UPDATED_BY := 0;
  end if;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATE_LOGIN := 0;
end OWNER_TO_WHO;

PROCEDURE Insert_Row(X_Rowid                               IN OUT nocopy VARCHAR2,
                     X_Nav_Unit_Id                         IN OUT nocopy NUMBER,
                     X_Default_Workflow_Id                 NUMBER,
                     X_Application_Abbrev                  VARCHAR2,
                     X_Default_Label                       VARCHAR2,
                     X_Form_Name                           VARCHAR2,
                     X_Max_Number_Of_Nav_Buttons           NUMBER,
                     X_Block_Name                          VARCHAR2,
                     X_LANGUAGE_CODE in varchar2 default hr_api.userenv_lang
 ) IS
   CURSOR C IS SELECT rowid FROM HR_NAVIGATION_UNITS

             WHERE nav_unit_id = X_Nav_Unit_Id;

   CURSOR C2 IS SELECT hr_navigation_units_s.nextval FROM sys.dual;
l_language_code varchar2(3);
 BEGIN

-- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := x_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

   if (X_Nav_Unit_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Nav_Unit_Id;
     CLOSE C2;
   end if;
  INSERT INTO HR_NAVIGATION_UNITS(
          nav_unit_id,
          default_workflow_id,
          application_abbrev,
          default_label,
          form_name,
          max_number_of_nav_buttons,
          block_name
          ) VALUES (
          X_Nav_Unit_Id,
          X_Default_Workflow_Id,
          X_Application_Abbrev,
          X_Default_Label,
          X_Form_Name,
          X_Max_Number_Of_Nav_Buttons,
          X_Block_Name
         );

INSERT INTO HR_NAVIGATION_UNITS_TL(
          nav_unit_id,
          default_label,
          language,
          source_lang)
          select
          X_Nav_Unit_Id,
	      x_default_label,
          l.language_code,
          userenv('LANG')
          from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HR_NAVIGATION_UNITS_TL T
    where T.NAV_UNIT_ID = X_NAV_UNIT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','INSERT_ROW');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
END Insert_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Nav_Unit_Id                           NUMBER,
                   X_Default_Workflow_Id                   NUMBER,
                   X_Application_Abbrev                    VARCHAR2,
                   X_Default_Label                         VARCHAR2,
                   X_Form_Name                             VARCHAR2,
                   X_Max_Number_Of_Nav_Buttons             NUMBER,
                   X_Block_Name                            VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   HR_NAVIGATION_UNITS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Nav_Unit_Id NOWAIT;
  Recinfo C%ROWTYPE;

    cursor CSR_HR_NAVIGATION_UNITS_TL is
    select DEFAULT_LABEL,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HR_NAVIGATION_UNITS_TL TL
    where nav_unit_id = x_nav_unit_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of nav_unit_id nowait;

BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','LOCK_ROW');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;

  Recinfo.default_label := rtrim(Recinfo.default_label);
  Recinfo.form_name := rtrim(Recinfo.form_name);
  Recinfo.block_name := rtrim(Recinfo.block_name);

  if (
          (   (Recinfo.nav_unit_id = X_Nav_Unit_Id)
           OR (    (Recinfo.nav_unit_id IS NULL)
               AND (X_Nav_Unit_Id IS NULL)))
      AND (   (Recinfo.default_workflow_id = X_Default_Workflow_Id)
           OR (    (Recinfo.default_workflow_id IS NULL)
               AND (X_Default_Workflow_Id IS NULL)))
      AND (   (Recinfo.application_abbrev = X_Application_Abbrev)
           OR (    (Recinfo.application_abbrev IS NULL)
               AND (X_Application_Abbrev IS NULL)))
           AND (   (Recinfo.form_name = X_Form_Name)
           OR (    (Recinfo.form_name IS NULL)
               AND (X_Form_Name IS NULL)))
      AND (   (Recinfo.max_number_of_nav_buttons = X_Max_Number_Of_Nav_Buttons)
           OR (    (Recinfo.max_number_of_nav_buttons IS NULL)
               AND (X_Max_Number_Of_Nav_Buttons IS NULL)))
      AND (   (Recinfo.block_name = X_Block_Name)
           OR (    (Recinfo.block_name IS NULL)
               AND (X_Block_Name IS NULL)))
          ) then
    null;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

  for tlinfo in CSR_HR_NAVIGATION_UNITS_TL loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DEFAULT_LABEL = X_DEFAULT_LABEL)
             OR ((tlinfo.DEFAULT_LABEL is null) AND (X_DEFAULT_LABEL is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
END Lock_Row;

-- This one is used by the form

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Nav_Unit_Id                         NUMBER,
                     X_Default_Workflow_Id                 NUMBER,
                     X_Application_Abbrev                  VARCHAR2,
                     X_Default_Label                       VARCHAR2,
                     X_Form_Name                           VARCHAR2,
                     X_Max_Number_Of_Nav_Buttons           NUMBER,
                     X_Block_Name                          VARCHAR2,
                     X_Language_Code varchar2 default hr_api.userenv_lang
                     )
                     IS
l_language_code varchar2(3);
BEGIN

  -- Validate the language parameter. l_language_code should be passed
  -- instead of x_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := x_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  UPDATE HR_NAVIGATION_UNITS
  SET
    nav_unit_id                               =    X_Nav_Unit_Id,
    default_workflow_id                       =    X_Default_Workflow_Id,
    application_abbrev                        =    X_Application_Abbrev,
    default_label                             =    X_Default_Label,
    form_name                                 =    X_Form_Name,
    max_number_of_nav_buttons                 =    X_Max_Number_Of_Nav_Buttons,
    block_name                                =    X_Block_Name
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
   hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
   hr_utility.set_message_token('PROCEDURE','UPDATE_ROW');
   hr_utility.set_message_token('STEP','1');
   hr_utility.raise_error;
  end if;

    update HR_NAVIGATION_UNITS_TL
    set
    DEFAULT_LABEL = X_DEFAULT_LABEL,
    SOURCE_LANG = userenv('LANG')
  where NAV_UNIT_ID = X_NAV_UNIT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
   hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
   hr_utility.set_message_token('PROCEDURE','UPDATE_ROW');
   hr_utility.set_message_token('STEP','1');
   hr_utility.raise_error;
  end if;

END Update_Row;

-- Overloaded procedure
-- This one is used by loader configuration file

Procedure UPDATE_ROW (X_NAV_UNIT_ID                      NUMBER,
  		X_DEFAULT_WORKFLOW_ID  	                		 NUMBER,
  		X_APPLICATION_ABBREV  		                	 VARCHAR2,
  		X_DEFAULT_LABEL  		                    	 VARCHAR2,
  		X_FORM_NAME  			                    	 VARCHAR2,
  		X_MAX_NUMBER_OF_NAV_BUTTONS  	            	 NUMBER,
  		X_BLOCK_NAME  				                     VARCHAR2,
        X_LANGUAGE_CODE	 in varchar2 default hr_api.userenv_lang
) is
l_language_code varchar2(3);
begin

  -- Validate the language parameter. l_language_code should be passed
  -- instead of x_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := x_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);


  update HR_NAVIGATION_UNITS set
    DEFAULT_WORKFLOW_ID = X_DEFAULT_WORKFLOW_ID,
    APPLICATION_ABBREV = X_APPLICATION_ABBREV,
    DEFAULT_LABEL = X_DEFAULT_LABEL,
    FORM_NAME = X_FORM_NAME,
    MAX_NUMBER_OF_NAV_BUTTONS = X_MAX_NUMBER_OF_NAV_BUTTONS,
    BLOCK_NAME = X_BLOCK_NAME
  where NAV_UNIT_ID = X_NAV_UNIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

      update HR_NAVIGATION_UNITS_TL
    set
    DEFAULT_LABEL = X_DEFAULT_LABEL,
    SOURCE_LANG = userenv('LANG')
  where NAV_UNIT_ID = X_NAV_UNIT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

PROCEDURE Delete_Row(x_nav_unit_id varchar2, X_Rowid VARCHAR2) IS
BEGIN
  delete from HR_NAVIGATION_UNITS_TL
  where NAV_UNIT_ID = X_NAV_UNIT_ID;

  if (sql%notfound) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','DELETE_ROW');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;

  DELETE FROM HR_NAVIGATION_UNITS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','DELETE_ROW');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
END Delete_Row;

procedure ADD_LANGUAGE
is
begin
  delete from HR_NAVIGATION_UNITS_TL T
  where not exists
    (select NULL
    from HR_NAVIGATION_UNITS B
    where B.NAV_UNIT_ID = T.NAV_UNIT_ID
    );

  update HR_NAVIGATION_UNITS_TL T set (
      DEFAULT_LABEL
    ) = (select
      B.DEFAULT_LABEL
    from HR_NAVIGATION_UNITS_TL B
    where B.NAV_UNIT_ID = T.NAV_UNIT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.NAV_UNIT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.NAV_UNIT_ID,
      SUBT.LANGUAGE
    from HR_NAVIGATION_UNITS_TL SUBB, HR_NAVIGATION_UNITS_TL SUBT
    where SUBB.NAV_UNIT_ID = SUBT.NAV_UNIT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DEFAULT_LABEL <> SUBT.DEFAULT_LABEL
      or (SUBB.DEFAULT_LABEL is null and SUBT.DEFAULT_LABEL is not null)
      or (SUBB.DEFAULT_LABEL is not null and SUBT.DEFAULT_LABEL is null)
  ));

  insert into HR_NAVIGATION_UNITS_TL (
    NAV_UNIT_ID,
    DEFAULT_LABEL,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.NAV_UNIT_ID,
    B.DEFAULT_LABEL,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HR_NAVIGATION_UNITS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HR_NAVIGATION_UNITS_TL T
    where T.NAV_UNIT_ID = B.NAV_UNIT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

procedure LOAD_ROW(
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_WORKFLOW_NAME in VARCHAR2,
  X_APPLICATION_ABBREV in VARCHAR2,
  X_DEFAULT_LABEL in VARCHAR2,
  X_MAX_NUMBER_OF_NAV_BUTTONS in VARCHAR2
) is
X_NAV_UNIT_ID NUMBER;
X_ROWID VARCHAR2(30);
X_DEFAULT_WORKFLOW_ID NUMBER;
X_LANGUAGE_CODE VARCHAR2(30);
Y_DEFAULT_WORKFLOW_ID NUMBER;
Y_APPLICATION_ABBREV VARCHAR2(3);
Y_DEFAULT_LABEL VARCHAR2(40);
Y_MAX_NUMBER_OF_NAV_BUTTONS NUMBER;
begin

  if hr_workflows_pkg.g_load_taskflow <> 'N' then

    if X_WORKFLOW_NAME is not null then

      select workflow_id
      into X_DEFAULT_WORKFLOW_ID
      from hr_workflows
      where workflow_name = X_WORKFLOW_NAME;

    else
      X_DEFAULT_WORKFLOW_ID := null;
    end if;

    begin
      select NAV_UNIT_ID,DEFAULT_WORKFLOW_ID, APPLICATION_ABBREV, DEFAULT_LABEL,MAX_NUMBER_OF_NAV_BUTTONS
      into X_NAV_UNIT_ID, Y_DEFAULT_WORKFLOW_ID, Y_APPLICATION_ABBREV,
           Y_DEFAULT_LABEL,Y_MAX_NUMBER_OF_NAV_BUTTONS
      from hr_navigation_units
      where FORM_NAME = X_FORM_NAME
      and nvl(block_name,hr_api.g_varchar2) = nvl(x_block_name,hr_api.g_varchar2);

     --
     -- Fix for bug 3274423 starts here.
     -- Before updating the record, compare the database row with the row in ldt file.
     -- If both are same skip updating.
     --

     IF X_DEFAULT_WORKFLOW_ID <> Y_DEFAULT_WORKFLOW_ID OR
       X_APPLICATION_ABBREV  <> Y_APPLICATION_ABBREV  OR
       X_DEFAULT_LABEL       <> Y_DEFAULT_LABEL       OR
       X_MAX_NUMBER_OF_NAV_BUTTONS <> Y_MAX_NUMBER_OF_NAV_BUTTONS THEN
      UPDATE_ROW(
        X_NAV_UNIT_ID,
        X_DEFAULT_WORKFLOW_ID,
        X_APPLICATION_ABBREV,
        X_DEFAULT_LABEL,
        X_FORM_NAME,
        X_MAX_NUMBER_OF_NAV_BUTTONS,
        X_BLOCK_NAME
      );
     END IF;

    exception
        when no_data_found then
          select HR_NAVIGATION_UNITS_S.NEXTVAL
          into X_NAV_UNIT_ID
          from dual;

          INSERT_ROW(
            X_ROWID,
            X_NAV_UNIT_ID,
            X_DEFAULT_WORKFLOW_ID,
            X_APPLICATION_ABBREV,
            X_DEFAULT_LABEL,
            X_FORM_NAME,
            X_MAX_NUMBER_OF_NAV_BUTTONS,
            X_BLOCK_NAME
              );
    end;
    --
    -- Fix for bug 3274423 ends here.
    --
  end if;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_FORM_NAME in VARCHAR2,
  X_BLOCK_NAME in VARCHAR2,
  X_DEFAULT_LABEL in VARCHAR2
) is
  X_NAV_UNIT_ID NUMBER;
  Y_DEFAULT_LABEL varchar2(40);
  Y_SOURCE_LANG   varchar2(4);
  --
  Cursor database_row(p_nav_unit_id number) IS
   SELECT DEFAULT_LABEL, SOURCE_LANG
   FROM   HR_NAVIGATION_UNITS_TL
   WHERE  userenv('LANG') in (LANGUAGE,SOURCE_LANG)
   AND    nav_unit_id = p_nav_unit_id;
  --
begin
select nav_unit_id
into x_nav_unit_id
from hr_navigation_units
where  FORM_NAME = X_FORM_NAME
  and    (  (BLOCK_NAME = X_BLOCK_NAME)
	    or (BLOCK_NAME is null and X_BLOCK_NAME is null));

  --
  -- Fix for bug 3326118 starts here.
  --
  open database_row(x_nav_unit_id );
  fetch database_row into Y_DEFAULT_LABEL, Y_SOURCE_LANG;
  if database_row%found then
     if X_DEFAULT_LABEL <> Y_DEFAULT_LABEL  OR
        Y_SOURCE_LANG  <> userenv('LANG')  THEN

          update HR_NAVIGATION_UNITS_TL
          set    DEFAULT_LABEL = X_DEFAULT_LABEL,
                 SOURCE_LANG = userenv('LANG')
          where  userenv('LANG') in (LANGUAGE,SOURCE_LANG)
          and    nav_unit_id = x_nav_unit_id;
     end if;
   end if;
   close database_row;
   --
   -- Fix for bug 3326118 ends here.
   --
 --
 -- Fix for bug 4132782 starts here. Added exception handler.
 --
 exception
      when no_data_found then
        null;
      when others then
        raise;
 --
 -- Fix for bug 4132782 ends here.
 --
end TRANSLATE_ROW;


END HR_NAVIGATION_UNITS_PKG;

/
