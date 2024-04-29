--------------------------------------------------------
--  DDL for Package Body BSC_DB_MEASURE_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DB_MEASURE_COLS_PKG" as
/* $Header: BSCMSCOB.pls 120.1 2006/01/09 23:17:11 ppandey noship $ */

-- mdamle 09/03/03 - Validate measure col
function Validate_Measure_Col
( p_measure_col IN VARCHAR2
) return boolean;


procedure INSERT_ROW (
  X_MEASURE_COL in VARCHAR2,
  X_MEASURE_GROUP_ID in NUMBER,
  X_PROJECTION_ID in NUMBER,
  X_MEASURE_TYPE in NUMBER,
  X_HELP in VARCHAR2
) is
l_count number;
l_msg_data  varchar2(2000);
l_msg_count number;
begin

    -- mdamle 09/03/03 - Validate measure col
    if not validate_measure_col(X_Measure_Col) then
      FND_MESSAGE.SET_NAME('BSC','BSC_MEASURE_INV_SOURCE_NAME');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    end if;

  -- mdamle 4/23/2003 - Measure Definer - Added default for measure_group_id and projection_id
  insert into BSC_DB_MEASURE_COLS_TL (
    MEASURE_COL,
    HELP,
    MEASURE_GROUP_ID,
    PROJECTION_ID,
    MEASURE_TYPE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_MEASURE_COL,
    nvl(X_HELP, 'Internal Column'),
    nvl(X_MEASURE_GROUP_ID, -1),
    nvl(X_PROJECTION_ID, 3),
    nvl(X_MEASURE_TYPE, 1),
    L.LANGUAGE_CODE,
    USERENV('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_DB_MEASURE_COLS_TL T
    where UPPER(T.MEASURE_COL) = UPPER(X_MEASURE_COL)
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure LOCK_ROW (
  X_MEASURE_COL in VARCHAR2,
  X_MEASURE_GROUP_ID in NUMBER,
  X_PROJECTION_ID in NUMBER,
  X_MEASURE_TYPE in NUMBER,
  X_HELP in VARCHAR2
) is
  cursor c1 is select
      MEASURE_GROUP_ID,
      PROJECTION_ID,
      MEASURE_TYPE,
      HELP,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_DB_MEASURE_COLS_TL
    where MEASURE_COL = X_MEASURE_COL
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MEASURE_COL nowait;
begin
  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.HELP = X_HELP)
          AND (tlinfo.MEASURE_GROUP_ID = X_MEASURE_GROUP_ID)
          AND (tlinfo.PROJECTION_ID = X_PROJECTION_ID)
          AND ((tlinfo.MEASURE_TYPE = X_MEASURE_TYPE)
               OR ((tlinfo.MEASURE_TYPE is null) AND (X_MEASURE_TYPE is null)))
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

procedure TRANSLATE_ROW (
  X_MEASURE_COL in VARCHAR2,
  X_HELP in VARCHAR2
) is
begin
  update BSC_DB_MEASURE_COLS_TL set
    HELP = nvl(X_HELP,HELP),
    SOURCE_LANG = userenv('LANG')
  where MEASURE_COL = X_MEASURE_COL
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

procedure UPDATE_ROW (
  X_MEASURE_COL in VARCHAR2,
  X_MEASURE_GROUP_ID in NUMBER,
  X_PROJECTION_ID in NUMBER,
  X_MEASURE_TYPE in NUMBER,
  X_HELP in VARCHAR2
) is
begin

  TRANSLATE_ROW(X_MEASURE_COL, X_HELP);

  update BSC_DB_MEASURE_COLS_TL set
      MEASURE_GROUP_ID = X_MEASURE_GROUP_ID,
      PROJECTION_ID = X_PROJECTION_ID,
      MEASURE_TYPE = X_MEASURE_TYPE
    where MEASURE_COL = X_MEASURE_COL;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MEASURE_COL in VARCHAR2
) is
begin
  delete from BSC_DB_MEASURE_COLS_TL
  where MEASURE_COL = X_MEASURE_COL;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update BSC_DB_MEASURE_COLS_TL T set (
      HELP
    ) = (select
      B.HELP
    from BSC_DB_MEASURE_COLS_TL B
    where B.MEASURE_COL = T.MEASURE_COL
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MEASURE_COL,
      T.LANGUAGE
  ) in (select
      SUBT.MEASURE_COL,
      SUBT.LANGUAGE
    from BSC_DB_MEASURE_COLS_TL SUBB, BSC_DB_MEASURE_COLS_TL SUBT
    where SUBB.MEASURE_COL = SUBT.MEASURE_COL
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.HELP <> SUBT.HELP
  ));

  insert into BSC_DB_MEASURE_COLS_TL (
    MEASURE_COL,
    HELP,
    MEASURE_GROUP_ID,
    PROJECTION_ID,
    MEASURE_TYPE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MEASURE_COL,
    B.HELP,
    B.MEASURE_GROUP_ID,
    B.PROJECTION_ID,
    B.MEASURE_TYPE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from BSC_DB_MEASURE_COLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_DB_MEASURE_COLS_TL T
    where T.MEASURE_COL = B.MEASURE_COL
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


-- mdamle 09/03/03 - Validate measure col
function validate_measure_col
(p_measure_col  IN VARCHAR2) return boolean is
l_valid         boolean := TRUE;
l_asc           number;
l_cursor        number;
BEGIN
    if p_measure_col is not null then

        -- Check if first letter is a number or an underscore
        l_asc := ascii(substr(p_measure_col, 1, 1));

        if (l_asc >= 48 and l_asc <= 57) or (l_asc = 95) then
            l_valid := false;
        else
            -- Valid values - numbers/alphabets/underscore
                for i in 1..length(p_measure_col) loop
                l_asc := ascii(substr(p_measure_col, i, 1));
                If Not (l_asc >= 48 And l_asc <= 57) And
                       Not (l_asc >= 65 And l_asc <= 90) And
                       Not (l_asc >= 97 And l_asc <= 122) and
                   Not (l_asc = 95) Then
                    l_valid := false;
                end if;
            end loop;

            if (l_valid) then
                -- Parse to check if it's not a reserved word
                l_cursor := dbms_sql.open_cursor;
                dbms_sql.parse(l_cursor, 'select null ' || p_measure_col || ' from dual', dbms_sql.native);
                dbms_sql.close_cursor(l_cursor);
            end if;

        end if;

    else
        l_valid := false;
    end if;


    return l_valid;
EXCEPTION
    when others then return false;

END validate_measure_col;


-- added for Bug#3817894 (POSCO)
/**************************************************************************
 Update_Measure_Column_Help

 This API updates the help column in BSC_DB_MEASURE_COLS_TL table
 for the appropriate session language.

 Returns 'S' on successful update else returns 'E' or 'U' in x_Return_Status
 with an appropriate error message readable from x_Msg_Data
***************************************************************************/

PROCEDURE Update_Measure_Column_Help (
    p_Measure_Col    IN VARCHAR2
  , p_Help           IN VARCHAR2
  , x_Return_Status  OUT NOCOPY VARCHAR2
  , x_Msg_Count      OUT NOCOPY NUMBER
  , x_Msg_Data       OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT UPDMEASCOLHELP;

  x_Return_Status :=  FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  UPDATE BSC_DB_MEASURE_COLS_TL
  SET    HELP        = NVL(p_Help, HELP),
         SOURCE_LANG = USERENV('LANG')
  WHERE  MEASURE_COL = p_Measure_Col
  AND    USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
    FND_MESSAGE.SET_TOKEN('TYPE', NVL(p_Measure_Col, BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'SOURCE_COLUMNS')));
    FND_MSG_PUB.ADD;
    RAISE NO_DATA_FOUND;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      ROLLBACK TO UPDMEASCOLHELP;
      FND_MSG_PUB.Count_And_Get
      (      p_encoded   =>  FND_API.G_FALSE
         ,   p_count     =>  x_msg_count
         ,   p_data      =>  x_msg_data
      );
      x_Return_Status :=  FND_API.G_RET_STS_ERROR;

   WHEN OTHERS THEN
      ROLLBACK TO UPDMEASCOLHELP;
      x_Return_Status :=  FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data      :=  'Error occured at BSC_DB_MEASURE_COLS_PKG.Update_Measure_Column_Help  - ' || SQLERRM;
END Update_Measure_Column_Help;

end BSC_DB_MEASURE_COLS_PKG;

/
