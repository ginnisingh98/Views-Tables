--------------------------------------------------------
--  DDL for Package Body BSC_KPI_DIM_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_DIM_SETS_PKG" as
/* $Header: BSCKDSTB.pls 120.1 2007/02/08 13:19:02 akoduri ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INDICATOR in NUMBER,
  X_DIM_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from BSC_KPI_DIM_SETS_TL
    where INDICATOR = X_INDICATOR
    and DIM_SET_ID = X_DIM_SET_ID
    and LANGUAGE = userenv('LANG')
    ;
begin
  insert into BSC_KPI_DIM_SETS_TL (
    INDICATOR,
    DIM_SET_ID,
    NAME,
    LANGUAGE,
    SOURCE_LANG,
	  CREATION_DATE ,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY ,
	  LAST_UPDATE_LOGIN
  ) select
    X_INDICATOR,
    X_DIM_SET_ID,
    X_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG'),
	 X_CREATION_DATE ,
	  X_CREATED_BY,
	  X_LAST_UPDATE_DATE,
	  X_LAST_UPDATED_BY ,
	  X_LAST_UPDATE_LOGIN
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from BSC_KPI_DIM_SETS_TL T
    where T.INDICATOR = X_INDICATOR
    and T.DIM_SET_ID = X_DIM_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_INDICATOR in NUMBER,
  X_DIM_SET_ID in NUMBER,
  X_NAME in VARCHAR2
) is
  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from BSC_KPI_DIM_SETS_TL
    where INDICATOR = X_INDICATOR
    and DIM_SET_ID = X_DIM_SET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of INDICATOR nowait;
begin
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
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_INDICATOR in NUMBER,
  X_DIM_SET_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update BSC_KPI_DIM_SETS_TL set
    NAME = X_NAME,
    SOURCE_LANG = userenv('LANG'),
    LAST_UPDATE_DATE = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_DATE,LAST_UPDATE_DATE),
    LAST_UPDATED_BY = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATED_BY,LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = DECODE(LAST_UPDATED_BY,1,X_LAST_UPDATE_LOGIN,LAST_UPDATE_LOGIN)
  where INDICATOR = X_INDICATOR
  and DIM_SET_ID = X_DIM_SET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_INDICATOR in NUMBER,
  X_DIM_SET_ID in NUMBER
) is
begin
  delete from BSC_KPI_DIM_SETS_TL
  where INDICATOR = X_INDICATOR
  and DIM_SET_ID = X_DIM_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  update BSC_KPI_DIM_SETS_TL T set (
      NAME
    ) = (select
      B.NAME
    from BSC_KPI_DIM_SETS_TL B
    where B.INDICATOR = T.INDICATOR
    and B.DIM_SET_ID = T.DIM_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.INDICATOR,
      T.DIM_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.INDICATOR,
      SUBT.DIM_SET_ID,
      SUBT.LANGUAGE
    from BSC_KPI_DIM_SETS_TL SUBB, BSC_KPI_DIM_SETS_TL SUBT
    where SUBB.INDICATOR = SUBT.INDICATOR
    and SUBB.DIM_SET_ID = SUBT.DIM_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into BSC_KPI_DIM_SETS_TL (
    INDICATOR,
    DIM_SET_ID,
    NAME,
    LANGUAGE,
    SOURCE_LANG,
   CREATION_DATE ,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) select
    B.INDICATOR,
    B.DIM_SET_ID,
    B.NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.CREATION_DATE ,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY
  from BSC_KPI_DIM_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from BSC_KPI_DIM_SETS_TL T
    where T.INDICATOR = B.INDICATOR
    and T.DIM_SET_ID = B.DIM_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

FUNCTION Get_Dim_Set_Name (
  p_Indicator    IN  NUMBER
 ,p_Dim_Set_Id   IN  NUMBER
) RETURN VARCHAR2 IS
  CURSOR c_Dim_Set_Name IS
  SELECT Name
  FROM   bsc_kpi_dim_sets_vl
  WHERE  indicator = p_Indicator
  AND    dim_set_id = p_Dim_Set_Id;
  l_Dim_Set_Name  bsc_kpi_dim_sets_vl.Name%TYPE := NULL;
BEGIN

  OPEN c_Dim_Set_Name;
  FETCH c_Dim_Set_Name INTO l_Dim_Set_Name;
  CLOSE c_Dim_Set_Name;

  RETURN l_Dim_Set_Name;

EXCEPTION
  WHEN OTHERS THEN
    RETURN l_Dim_Set_Name;
END Get_Dim_Set_Name;

FUNCTION Get_Dim_Level_Names (
  p_Indicator    IN  NUMBER
 ,p_Dim_Set_Id   IN  NUMBER
) RETURN VARCHAR2 IS

  CURSOR c_dim_levels IS
  SELECT Name
  FROM   bsc_kpi_dim_levels_vl
  WHERE  indicator = p_Indicator
  AND    dim_set_id = p_Dim_Set_Id
  AND    status = 2;
  l_Dim_Level_Names  VARCHAR2(2000) := '';
BEGIN
  FOR cd in c_dim_levels LOOP
    l_Dim_Level_Names := l_Dim_Level_Names || ' / ' || cd.Name;
  END LOOP;
  IF SUBSTR(l_Dim_Level_Names,1,3) = ' / ' THEN
    l_Dim_Level_Names := SUBSTR(l_Dim_Level_Names,4);
  END IF;
  IF (l_Dim_Level_Names IS NULL) THEN
    l_Dim_Level_Names := fnd_message.get_string('BSC','BSC_NO_DIM_OBJS_IN_DIMSET');
  END IF;
  RETURN l_Dim_Level_Names;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_Dim_Level_Names;
END Get_Dim_Level_Names;

end BSC_KPI_DIM_SETS_PKG;

/
