--------------------------------------------------------
--  DDL for Package Body BSC_DB_MEASURE_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DB_MEASURE_GROUPS_PKG" as
/* $Header: BSCMSGRB.pls 120.1 2005/08/02 03:09:19 ashankar noship $ */

-- mdamle 04/23/2003 - Measure Definer - Added sequence for Group Id
-- Changed x_measure_group_id to out parameter.
PROCEDURE INSERT_ROW
(
    X_MEASURE_GROUP_ID    OUT NOCOPY NUMBER
  , X_HELP                IN         VARCHAR2
  , X_SHORT_NAME          IN         VARCHAR2 := NULL
)IS
  l_count   NUMBER;
  sql_stmt  VARCHAR2(2000);
BEGIN

  -- mdamle 07/25/2003 - Added check for duplicate name
  FND_MSG_PUB.INITIALIZE;
  SELECT COUNT(1)
  INTO   l_count
  FROM   bsc_db_measure_groups_tl
  WHERE  help = x_help;

  IF (l_count > 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_D_SOURCE_EXIST');
        FND_MSG_PUB.ADD;
  ELSE
    SELECT bsc_db_measure_groups_s.nextVal
    INTO   X_MEASURE_GROUP_ID
    FROM   dual;

    BSC_DB_MEASURE_GROUPS_PKG.Insert_Row_Values
    (
        x_Measure_group_id  =>  X_MEASURE_GROUP_ID
      , x_Help              =>  X_HELP
      , x_Short_name        =>  X_SHORT_NAME
    );

  END IF;

END INSERT_ROW;

procedure LOCK_ROW (
  X_MEASURE_GROUP_ID in NUMBER,
  X_HELP in VARCHAR2
) is
  cursor c1 is select
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_DB_MEASURE_GROUPS_TL
    where MEASURE_GROUP_ID = X_MEASURE_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MEASURE_GROUP_ID nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.HELP = X_HELP)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;


PROCEDURE UPDATE_ROW
(
    X_MEASURE_GROUP_ID  IN NUMBER
  , X_HELP              IN VARCHAR2
  , X_SHORT_NAME        IN VARCHAR2:= NULL
)IS
BEGIN

 UPDATE bsc_db_measure_groups_tl
 SET    help        = X_HELP
      , short_name  = X_SHORT_NAME
      , source_lang = USERENV('LANG')
 WHERE measure_group_id = X_MEASURE_GROUP_ID
 AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

 IF (sql%notfound) THEN
   RAISE NO_DATA_FOUND;
 END IF;

END UPDATE_ROW;

procedure TRANSLATE_ROW (
  X_MEASURE_GROUP_ID in NUMBER,
  X_HELP in VARCHAR2
) is
begin
  update BSC_DB_MEASURE_GROUPS_TL set
    HELP = nvl(X_HELP,HELP),
    SOURCE_LANG = userenv('LANG')
  where MEASURE_GROUP_ID = X_MEASURE_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;


procedure DELETE_ROW (
  X_MEASURE_GROUP_ID in NUMBER
) is
begin
  delete from BSC_DB_MEASURE_GROUPS_TL
  where MEASURE_GROUP_ID = X_MEASURE_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


PROCEDURE ADD_LANGUAGE
IS
BEGIN

  UPDATE bsc_db_measure_groups_tl t
  SET (
        help
      ) = (
           SELECT b.help
           FROM   bsc_db_measure_groups_tl b
           WHERE  b.Measure_group_id = t.Measure_group_id
           AND    b.language = t.Source_lang)
  WHERE (
      t.Measure_group_id,
      t.language
  ) IN (
        SELECT subt.Measure_group_id
              ,subt.language
        FROM  bsc_db_measure_groups_tl subb
            , bsc_db_measure_groups_tl subt
        WHERE subb.Measure_group_id = subt.Measure_group_id
        AND   subb.language = subt.Source_lang
        AND   (subb.help <> subt.help));


  INSERT INTO bsc_db_measure_groups_tl
  (  help
   , measure_group_id
   , language
   , source_lang
   , short_name
  ) SELECT  b.Help
          , b.Measure_group_id
          , l.Language_code
          , b.Source_lang
          , b.Short_name
    FROM  bsc_db_measure_groups_tl b
        , fnd_languages l
    WHERE l.Installed_flag IN ('I', 'B')
    AND   b.language = USERENV('LANG')
    AND NOT EXISTS (
                    SELECT NULL
                    FROM   bsc_db_measure_groups_tl t
                    WHERE  t.Measure_group_id = b.Measure_group_id
                    AND    t.language = l.language_code);

END ADD_LANGUAGE;

/*************************************************
 Procedure    : Insert_Default_Meas_Row
 Description  : This procedure is called from bscmsgrp.lct
                file.Pls don't modify this procedure.
 Input        : Default measure group id <-1>
              : <DEFAULT> help
 Created BY   : ashankar 27-JUL-2005
/**************************************************/

PROCEDURE Insert_Default_Meas_Row
(
    x_Measure_group_id    IN    NUMBER
  , x_Help                IN    VARCHAR2
)IS
BEGIN

      BSC_DB_MEASURE_GROUPS_PKG.Insert_Row_Values
      (
          x_Measure_group_id  =>  x_Measure_group_id
        , x_Help              =>  x_Help
        , x_Short_name        =>  NULL
      );
END Insert_Default_Meas_Row;

/*************************************************************************************************
 Procedure    : Insert_Row_Values
 Description  : This procedure insert values into bsc_db_measure_groups_tl table.
 Input        : Measure group Id
              : help
              : short_name
 Created BY   : ashankar 27-JUL-2005
 Note         : Removed the dynamic SQL because BSC 5.2 MD/DD xdf files are included with BIS 4.0.9
                Verified BIS ARU 4122391 it contains bsc_db_measure_groups_tl.xdf version 115.3
                So SHORT_NAME column will always be there.
/***************************************************************************************************/

PROCEDURE Insert_Row_Values
(
    x_Measure_group_id    IN    NUMBER
  , x_Help                IN    VARCHAR2
  , x_Short_name          IN    VARCHAR2
)IS
BEGIN
    INSERT INTO bsc_db_measure_groups_tl
    ( short_name
     , help
     , measure_group_id
     ,language
     ,source_lang
    ) SELECT  x_Short_name
            , x_Help
            , x_Measure_group_id
            , l.LANGUAGE_CODE
            , USERENV('LANG')
      FROM  fnd_languages l
      WHERE l.installed_flag IN ('I', 'B')
      AND NOT EXISTS (
                      SELECT NULL
                      FROM   bsc_db_measure_groups_tl t
                      WHERE  t.measure_group_id = x_Measure_group_id
                      AND    t.language = l.language_code);

END  Insert_Row_Values;


END BSC_DB_MEASURE_GROUPS_PKG;

/
