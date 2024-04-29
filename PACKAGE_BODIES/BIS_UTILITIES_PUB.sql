--------------------------------------------------------
--  DDL for Package Body BIS_UTILITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_UTILITIES_PUB" AS
/* $Header: BISPUTLB.pls 120.0 2005/06/01 18:06:50 appldev noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_UTILITIES_PUB';


    g_db_nls_lang    varchar2(200) := userenv('LANGUAGE');
    g_db_charset     varchar2(200) := substr(g_db_nls_lang,
                                      instr(g_db_nls_lang, '.')+1);

Tlist TimeLvlList := TimeLvlList('MONTH','QUARTER','YEAR','EDW_TIME_CAL_PERIOD','EDW_TIME_CAL_QTR','EDW_TIME_CAL_YEAR');

Olist  TimeLvlList := TimeLvlList('INV ORGANIZATION','LEGAL ENTITY','OPERATING UNIT','HR ORGANIZATION','OPM COMPANY','ORGANIZATION','SET OF BOOKS','BUSINESS GROUP'
                                 ,'HRI_ORG_HRCY_BX','HRI_ORG_HRCYVRSN_BX','HRI_ORG_HR_HX','HRI_ORG_INHV_H','HRI_ORG_SSUP_H','HRI_ORG_BGR_HX','HRI_ORG_HR_H','HRI_ORG_SRHL');

Procedure Retrieve_User
( p_user_id          IN NUMBER Default G_NULL_NUM
, p_user_name        IN VARCHAR2 Default G_NULL_CHAR
, x_user_id          OUT NOCOPY NUMBER
, x_user_name        OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF BIS_UTILITIES_PUB.Value_Not_Missing(p_user_id) = FND_API.G_TRUE THEN
     select user_id , user_name
     into x_user_id, x_user_name
     from fnd_user
     where user_id = p_user_id;
  ELSIF BIS_UTILITIES_PUB.Value_Not_Missing(p_user_name) = FND_API.G_TRUE  THEN
     select user_id , user_name
     into x_user_id, x_user_name
     from fnd_user
     where user_name = p_user_name;
  ELSE
      null;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_User'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_User;


Procedure Retrieve_Organization
( p_organization_id    IN NUMBER Default G_NULL_NUM
, p_organization_name  IN VARCHAR2 Default G_NULL_CHAR
, x_organization_id    OUT NOCOPY NUMBER
, x_organization_name  OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_organization_id) = FND_API.G_TRUE)
  THEN
     select organization_id , name
     into x_organization_id, x_organization_name
     from hr_all_organization_units
     where organization_id = p_organization_id;
  ELSIF BIS_UTILITIES_PUB.Value_Not_Missing(p_organization_name) = FND_API.G_TRUE   THEN
     select organization_id , name
     into x_organization_id, x_organization_name
     from hr_all_organization_units
     where name = p_organization_name;
  ELSE
     null;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Organization'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Organization;

-- The following where_clause functions are used for ICX pop up LOVs
-- to restrict the values returned in the list

-- Maintained for backwards compatibility (Rel 1.2)
-- Originally only Organization required special where_clauses
--
Procedure Retrieve_Where_Clause
( p_user_id          IN NUMBER Default G_NULL_NUM
, p_user_name        IN VARCHAR2 Default G_NULL_CHAR
, p_region_code      IN VARCHAR2
, x_where_clause     OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
BEGIN

    Retrieve_Where_Clause
    ( p_user_id              => p_user_id
    , p_user_name            => p_user_name
    , p_region_code          => p_region_code
    , p_dimension_short_name => 'ORGANIZATION'
    , x_where_clause         => x_where_clause
    , x_return_status        => x_return_status
    , x_error_tbl            => x_error_tbl
    );

END Retrieve_Where_Clause;

-- Not sure if this belongs in utilities pkg or in dimension values pkg
--
-- See also BIS_DIM_LVL_LOV_REG_PVT.Lookup_DimLvl_Dependency
-- for dimension to dimension dependency
--
Procedure Retrieve_Where_Clause
( p_user_id              IN NUMBER Default G_NULL_NUM
, p_user_name            IN VARCHAR2 Default G_NULL_CHAR
, p_organization_id      IN VARCHAR2 Default G_NULL_CHAR
, p_organization_type    IN VARCHAR2 Default G_NULL_CHAR
, p_region_code          IN VARCHAR2
, p_dimension_short_name IN VARCHAR2
, x_where_clause         OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_user_id            NUMBER;
l_dim_level_view     BISBV_DIMENSION_LEVELS.LEVEL_VALUES_VIEW_NAME%TYPE;
l_database_object    VARCHAR2(30);
l_dim_level_short_name BISBV_DIMENSION_LEVELS.DIMENSION_LEVEL_SHORT_NAME%TYPE;
counter              NUMBER := 0;
l_error_tbl                  BIS_UTILITIES_PUB.Error_Tbl_Type;

CURSOR c_views IS
SELECT level_values_view_name, dimension_level_short_name
FROM bisfv_dimension_levels
WHERE UPPER(level_values_view_name) = UPPER(l_database_object);

BEGIN

   SELECT DATABASE_OBJECT_NAME
   INTO l_database_object
   FROM ak_regions
   WHERE REGION_CODE = UPPER(p_region_code);


   FOR c_views_data in c_views LOOP
      l_dim_level_view:= c_views_data.level_values_view_name;
      l_dim_level_short_name:= c_views_data.dimension_level_short_name;
      counter:= counter + 1;
   END LOOP;

   IF counter > 1
   THEN
      SELECT level_values_view_name, dimension_level_short_name
      INTO l_dim_level_view, l_dim_level_short_name
      FROM bisfv_dimension_levels
      WHERE UPPER(level_values_view_name) = UPPER(l_database_object) and dimension_short_name = p_dimension_short_name;
   END IF;


   IF BIS_UTILITIES_PUB.Value_Missing(p_user_id) = FND_API.G_TRUE
   THEN
     SELECT user_id
     INTO l_user_id
     FROM fnd_user
     WHERE user_name = p_user_name;
   ELSE
     l_user_id := p_user_id;
   END IF;

  IF p_dimension_short_name = BIS_UTILITIES_PVT.GET_ORG_DIMENSION_NAME(p_DimLevelId => NULL
                                                                      ,p_DimLevelName => l_dim_level_short_name) THEN --'ORGANIZATION'
    Retrieve_Org_Where_Clause
    ( p_database_object      => l_database_object
    , p_user_id              => l_user_id
    , p_dim_level_short_name => l_dim_level_short_name
    , x_where_clause         => x_where_clause
    , x_return_status        => x_return_status
    , x_error_tbl            => x_error_tbl
    );

  ELSIF p_dimension_short_name = BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME(p_DimLevelId => NULL
                                                                          ,p_DimLevelName => l_dim_level_short_name) THEN
    IF ( BIS_UTILITIES_PUB.Value_Missing(p_organization_id) = FND_API.G_TRUE ) THEN -- 2694965
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    Retrieve_Time_Where_Clause
    ( p_database_object      => l_database_object
    , p_dim_level_short_name => l_dim_level_short_name
    , p_organization_id      => p_organization_id
    , p_organization_type    => p_organization_type
    , x_where_clause         => x_where_clause
    , x_return_status        => x_return_status
    , x_error_tbl            => x_error_tbl
    );
  ELSE
    Retrieve_DimX_Where_Clause
    ( p_database_object      => l_database_object
    , p_user_id              => l_user_id
    , p_organization_id      => p_organization_id
    , p_dim_level_short_name => l_dim_level_short_name
    , p_organization_type    => p_organization_type
    , x_where_clause         => x_where_clause
    , x_return_status        => x_return_status
    , x_error_tbl            => x_error_tbl
    );
  END IF;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Where_Clause'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Where_Clause;

Procedure Retrieve_Org_Where_Clause
( p_user_id                    IN NUMBER
, p_dimension_level_short_name IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
)
IS

l_Responsibility_tbl BIS_Responsibility_PVT.Responsibility_Tbl_Type;
l_where_clause       VARCHAR2(32000);
l_comma              VARCHAR2(2) := ',';
l_return_status      VARCHAR2(100);
l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

    FND_MSG_PUB.initialize;


  IF(p_dimension_level_short_name <> 'TOTAL_ORGANIZATION')
  AND (SUBSTR(p_dimension_level_short_name, 1, 3) <> 'OPM')
  THEN

      BIS_RESPONSIBILITY_PVT.Retrieve_User_Responsibilities
      ( p_api_version            => 1.0
      , p_user_id                => p_user_id
      , p_Responsibility_version => NULL
      , x_Responsibility_Tbl     => l_Responsibility_tbl
      , x_return_status          => l_return_status
      , x_error_tbl              => l_error_tbl
      );

      l_where_clause := '" responsibility_id IN ( ';

      FOR i IN 1..l_Responsibility_tbl.COUNT LOOP
        IF i = l_Responsibility_tbl.LAST THEN
          l_where_clause := l_where_clause
                          ||l_Responsibility_tbl(i).Responsibility_ID;
        ELSE
          l_where_clause := l_where_clause
                          ||l_Responsibility_tbl(i).Responsibility_ID||l_comma;
       END IF;
      END LOOP;

      l_where_clause := l_where_clause||' )"';
  ELSE
    l_where_clause := '""';
  END IF;

   x_where_clause := l_where_clause;

END Retrieve_Org_Where_Clause;

-- Organization is related to user
--
Procedure Retrieve_Org_Where_Clause
( p_database_object      IN VARCHAR2
, p_user_id              IN NUMBER
, p_dim_level_short_name IN VARCHAR2
, x_where_clause         OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_Responsibility_tbl BIS_Responsibility_PVT.Responsibility_Tbl_Type;
l_where_clause       VARCHAR2(32000);
l_comma              VARCHAR2(2) := ',';
l_database_object    VARCHAR2(30);
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

    FND_MSG_PUB.initialize;

  IF(p_dim_level_short_name <> 'TOTAL_ORGANIZATION')
  AND (SUBSTR(p_dim_level_short_name, 1, 3) <> 'OPM')
  THEN

      BIS_RESPONSIBILITY_PVT.Retrieve_User_Responsibilities
      ( p_api_version            => 1.0
      , p_user_id                => p_user_id
      , p_Responsibility_version => NULL
      , x_Responsibility_Tbl     => l_Responsibility_tbl
      , x_return_status          => x_return_status
      , x_error_tbl              => x_error_tbl
      );

      l_where_clause := ' 1 = 1 '
                      ||' INTERSECT SELECT DISTINCT VALUE, ID '
                      ||' FROM '||p_database_object
                      ||' WHERE responsibility_id IN ( ';

      FOR i IN 1..l_Responsibility_tbl.COUNT LOOP
        IF i = l_Responsibility_tbl.LAST THEN
          l_where_clause := l_where_clause
                          ||l_Responsibility_tbl(i).Responsibility_ID;
        ELSE
          l_where_clause := l_where_clause
                          ||l_Responsibility_tbl(i).Responsibility_ID||l_comma;
       END IF;
      END LOOP;

      l_where_clause := l_where_clause||' )';
  ELSE
    l_where_clause := '';
  END IF;

  l_where_clause := BIS_UTILITIES_PUB.encode(l_where_clause);

   x_where_clause := l_where_clause;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Org_Where_Clause'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Org_Where_Clause;

-- Time is related to organiztion
--
Procedure Retrieve_Time_Where_Clause
( p_time_dim_level_short_name  IN VARCHAR2
, p_org_dim_level_short_name   IN VARCHAR2
, p_org_form_name              IN VARCHAR2
, p_ak_org_id_var          IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
)
IS
  l_where_clause VARCHAR2(32000);
BEGIN

    FND_MSG_PUB.initialize;

  IF(p_time_dim_level_short_name <> 'TOTAL_TIME')
      AND (is_time_dependent_on_org(p_time_lvl_short_name => p_time_dim_level_short_name)
      = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
     l_where_clause :=
      '"organization_id="+'||'"''"+'||'document.'||p_org_form_name||'.'
      ||p_ak_org_id_var||'.value+'||'"''"'||'+ "%20and%20organization_type="+'
      ||'"'''||BIS_UTILITIES_PUB.encode(p_org_dim_level_short_name)||''''||'"';
  ELSE
    l_where_clause := '""';
  END IF;

  x_where_clause := l_where_clause;

END Retrieve_Time_Where_Clause;

-- Time is related to organiztion
-- New procedure to take in org_id directly
Procedure Retrieve_Time_Where_Clause
( p_time_dim_level_short_name  IN VARCHAR2
, p_org_dim_level_short_name   IN VARCHAR2
, p_org_id                 IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
)
IS
  l_where_clause VARCHAR2(32000);
BEGIN

    FND_MSG_PUB.initialize;

  IF(p_time_dim_level_short_name <> 'TOTAL_TIME')
  AND (is_time_dependent_on_org(p_time_lvl_short_name => p_time_dim_level_short_name)
  = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
      l_where_clause :=
      'organization_id = '|| '''' || p_org_id || '''' || ' and organization_type = '
      || '''' || p_org_dim_level_short_name || '''';
  ELSE
    l_where_clause := '""';
  END IF;

  x_where_clause := l_where_clause;

END Retrieve_Time_Where_Clause;

Procedure Retrieve_Time_Where_Clause
( p_database_object      IN VARCHAR2
, p_dim_level_short_name IN VARCHAR2
, p_organization_id      IN VARCHAR2
, p_organization_type    IN VARCHAR2 Default G_NULL_CHAR
, x_where_clause         OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_Responsibility_tbl BIS_Responsibility_PVT.Responsibility_Tbl_Type;
l_where_clause       VARCHAR2(32000);
l_database_object    VARCHAR2(30);
l_error_tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

    FND_MSG_PUB.initialize;

  IF(p_dim_level_short_name <> 'TOTAL_TIME') THEN

    IF (is_time_dependent_on_org(p_time_lvl_short_name => p_dim_level_short_name)
    = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
      --
      -- NULL is included because of some kludge in the AK definition
      l_where_clause := ' 1 = 1 '
                       ||' INTERSECT SELECT DISTINCT VALUE, ID'
                       || ' FROM '
                       || p_database_object
                       || ' WHERE '
                       || ' ORGANIZATION_ID = '
                       || p_organization_ID
                       || ' AND NVL(ORGANIZATION_TYPE, ''%'') LIKE '
                       || ''''
                       || p_organization_type
                       || '''';
    ELSE
      --
      -- NULL is included because of some kludge in the AK definition
      l_where_clause := ' 1 = 1 '
                       ||' INTERSECT SELECT DISTINCT VALUE, ID'
                       || ' FROM '
                       || p_database_object;
    END IF;
  END IF;

  l_where_clause := BIS_UTILITIES_PUB.encode(l_where_clause);
  x_where_clause := l_where_clause;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Time_Where_Clause'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_Time_Where_Clause;

-- no other relationship but included for future
--
Procedure Retrieve_DimX_Where_Clause
( p_database_object      IN VARCHAR2
, p_user_id              IN NUMBER Default G_NULL_NUM
, p_organization_id      IN VARCHAR2 Default G_NULL_CHAR
, p_organization_type    IN VARCHAR2 Default G_NULL_CHAR
, p_dim_level_short_name IN VARCHAR2
, x_where_clause         OUT NOCOPY VARCHAR2
, x_return_status        OUT NOCOPY VARCHAR2
, x_error_Tbl            OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_Responsibility_tbl BIS_Responsibility_PVT.Responsibility_Tbl_Type;
l_where_clause       VARCHAR2(32000);
l_database_object    VARCHAR2(30);
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  -- In the future if a where clause is really added for this
  -- please do encoding as below for Netscape issues
  -- l_where_clause := wfa_html.conv_special_url_chars(l_where_clause);

   x_where_clause := l_where_clause;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_DimX_Where_Clause'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Retrieve_DimX_Where_Clause;
--
--
Procedure Retrieve_DimX_Where_Clause
( p_dimension_level_short_name  IN VARCHAR2
, p_depend_dimension_short_name IN VARCHAR2
, p_depend_dim_column_name      IN VARCHAR2
, p_depend_form_name            IN VARCHAR2
, p_ak_depend_id_var            IN VARCHAR2
, x_where_clause                OUT NOCOPY VARCHAR2
)
IS
  l_database_object VARCHAR2(32000);
  l_where_clause    VARCHAR2(32000);

BEGIN

  IF (SUBSTR(p_dimension_level_short_name, 1, 5) <> 'TOTAL')
  THEN
      l_where_clause :=
      '"'||p_depend_dim_column_name||'="+'||'"''"+'
      ||'document.'||p_depend_form_name||'.'||p_ak_depend_id_var||'.value'
      ||' +'||'"''"';

  ELSE
    l_where_clause := '""';
  END IF;

  x_where_clause := l_where_clause;

END Retrieve_DimX_Where_Clause;

-- Function used in BIS_TARGETS view to resolve names of roles
-- from the workflow roles view
FUNCTION RESOLVE_ROLE_NAME(
               p_value      IN VARCHAR2 )
  RETURN varchar2
  IS
     l_name     varchar2(100);
BEGIN

  IF BIS_UTILITIES_PUB.Value_Not_Missing(p_value) = FND_API.G_TRUE THEN
     l_name := WF_DIRECTORY.GetRoleDisplayName(p_value);
   ELSE
     l_name := NULL;
  END IF;
  return(l_name);

END  RESOLVE_ROLE_NAME;

-- Function used in BIS_TARGETS view to resolve names of
-- workflow functions attached to a target level

FUNCTION RESOLVE_FUNCTION_NAME(
               p_value      IN VARCHAR2 )
  RETURN varchar2
  IS
     l_name     FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
BEGIN

  IF BIS_UTILITIES_PUB.Value_Not_Missing(p_value) = FND_API.G_TRUE THEN
     select FUNCTION_NAME
     into l_name
     from fnd_form_functions
       where function_id = p_value;
   ELSE
     l_name := NULL;
  END IF;
  return(l_name);
END  RESOLVE_FUNCTION_NAME;

-- Function used in BIS_TARGETS view to resolve translated full names of
-- workflow functions attached to a target level

FUNCTION RESOLVE_FULL_FUNCTION_NAME(
               p_value      IN VARCHAR2 )
  RETURN varchar2
  IS
     l_name     varchar2(100);
BEGIN

  IF BIS_UTILITIES_PUB.Value_Not_Missing(p_value) = FND_API.G_TRUE THEN
     select USER_FUNCTION_NAME
     into l_name
     from fnd_form_functions_tl
       where function_id = p_value
       and
       language = nvl(userenv('LANG'),'US');
   ELSE
     l_name := NULL;
  END IF;
  return( l_name );

END  RESOLVE_FULL_FUNCTION_NAME;



-- Function used in BIS_TARGET_LEVELS view
-- to resolve translated full names of
-- workflow activities attached to a target level

FUNCTION RESOLVE_FULL_ACTIVITY_NAME(
                      p_name      IN VARCHAR2
                    , p_type    IN VARCHAR2
                    )
  RETURN varchar2
  IS
     l_version  number;
     l_name     varchar2(100);
BEGIN

   IF BIS_UTILITIES_PUB.Value_Missing(p_name) = FND_API.G_TRUE
     OR BIS_UTILITIES_PUB.Value_Missing(p_type) = FND_API.G_TRUE
     THEN
      l_name := NULL;
    ELSE
      select version
    into l_version
    from wf_activities
    where name =p_name
    and item_type = p_type
    and nvl(begin_date, sysdate) <= sysdate
    and nvl(end_date, sysdate) >= sysdate
    and type = 'PROCESS';

      select display_name
    into l_name
    from wf_activities_tl
    where version = l_version
    and name = p_name
    and item_type = p_type
    and language = nvl(userenv('LANG'),'US');
   END IF;
   return(l_name );
END  RESOLVE_FULL_ACTIVITY_NAME;


-- First segment is segment #1
FUNCTION Retrieve_Segment
( p_string       IN VARCHAR2
, p_delimitor    IN VARCHAR2 Default BIS_UTILITIES_PUB.G_VALUE_SEPARATOR
, p_segment_num  IN NUMBER Default 1
) RETURN VARCHAR2
IS
  l_string VARCHAR2(32000);

BEGIN
  l_string := p_string || p_delimitor;

  IF p_segment_num = 1 THEN
    RETURN SUBSTR(l_string, 1, INSTR(l_string, p_delimitor, 1, 1)-1);
  ELSE
    RETURN SUBSTR(l_string, INSTR(l_string, p_delimitor, 1, p_segment_num-1)+1,
                       INSTR(l_string, p_delimitor, 1, p_segment_num) -
                       INSTR(l_string, p_delimitor, 1, p_segment_num-1) - 1 );

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Retrieve_Segment;

FUNCTION Value_Not_Missing(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Not_Missing(p_value);
END Value_Not_Missing;

FUNCTION Value_Not_Missing(
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Not_Missing(p_value);
END Value_Not_Missing;

FUNCTION Value_Not_Missing(
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Not_Missing(p_value);
END Value_Not_Missing;

FUNCTION Value_Missing(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Missing(p_value);
END Value_Missing;

FUNCTION Value_Missing(
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Missing(p_value);
END Value_Missing;

FUNCTION Value_Missing(
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Missing(p_value);
END Value_Missing;

FUNCTION Value_Not_NULL(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Not_NULL(p_value);
END Value_Not_NULL;

FUNCTION Value_Not_NULL(
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Not_NULL(p_value);
END Value_Not_NULL;

FUNCTION Value_Not_NULL(
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_Not_NULL(p_value);
END Value_Not_NULL;

FUNCTION Value_NULL(
    p_value      IN VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_NULL(p_value);
END Value_NULL;

FUNCTION Value_NULL(
    p_value      IN NUMBER )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_NULL(p_value);
END Value_NULL;

FUNCTION Value_NULL(
    p_value      IN DATE )
RETURN VARCHAR2
IS
BEGIN
  return BIS_UTILITIES_PVT.Value_NULL(p_value);
END Value_NULL;

PROCEDURE Build_HTML_Banner
( p_title            IN  VARCHAR2
, x_banner_string    OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_HTML_UTILITIES_PVT.Build_HTML_Banner( ' '
                                          , p_title
                                          , ' '
                                          , x_banner_string
                                          );


EXCEPTION

   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Build_HTML_Banner'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Build_HTML_Banner;


PROCEDURE Build_HTML_Banner
( p_title            IN  VARCHAR2
, x_banner_string    OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, icon_show          IN  BOOLEAN
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_HTML_UTILITIES_PVT.Build_HTML_Banner( ' '
                                          , p_title
                                          , ' '
                          , icon_show
                                          , x_banner_string
                           );


EXCEPTION

   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_error_tbl := x_error_Tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Build_HTML_Banner'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Build_HTML_Banner;


FUNCTION  Get_Images_Server
RETURN VARCHAR2
IS
BEGIN
    Return BIS_REPORT_UTIL_PVT.Get_Images_Server;
END Get_Images_Server;

FUNCTION  Get_NLS_Language
RETURN VARCHAR2
IS
BEGIN
    Return BIS_REPORT_UTIL_PVT.Get_NLs_Language;
END Get_NLS_Language;

FUNCTION  Get_Report_Title           (Function_Code      IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    Return BIS_REPORT_UTIL_PVT.Get_Report_Title(Function_Code);
END Get_Report_Title;


PROCEDURE Build_Report_Header
(p_javascript   IN   VARCHAR2)
IS
BEGIN
    BIS_REPORT_UTIL_PVT.Build_Report_Header(p_javascript);
END Build_Report_Header;

PROCEDURE Build_More_Info_Directory
( Rdf_Filename      IN  VARCHAR2,
   NLS_Language_Code IN  VARCHAR2,
   Help_Directory    OUT NOCOPY VARCHAR2
)
IS
BEGIN
    BIS_REPORT_UTIL_PVT.Build_More_Info_Directory(Rdf_Filename,
                          NLS_Language_Code,
                          Help_Directory);
END Build_More_Info_Directory;

PROCEDURE Get_Translated_Icon_Text
 ( Icon_Code         IN  VARCHAR2,
   Icon_Meaning      OUT NOCOPY VARCHAR2,
   Icon_Description  OUT NOCOPY VARCHAR2
)
IS
BEGIN
    BIS_REPORT_UTIL_PVT.Get_Translated_Icon_Text(Icon_code,
                         Icon_Meaning,
                         Icon_Description);
END Get_Translated_Icon_Text;

PROCEDURE Get_Image_File_Structure
( Icx_Report_Images IN  VARCHAR2,
  NLS_Language_Code IN  VARCHAR2,
  Report_Image      OUT NOCOPY VARCHAR2
)
IS
BEGIN
    BIS_REPORT_UTIL_PVT.Get_Image_File_Structure(Icx_Report_Images,
                         NLS_Language_Code,
                         Report_Image);
END Get_Image_File_Structure;

PROCEDURE Build_HTML_Banner_Reports
(  Icx_Report_Images          IN VARCHAR2,
   More_Info_Directory        IN VARCHAR2,
   NLS_Language_Code          IN VARCHAR2,
   Report_Name            IN VARCHAR2,
   Report_Link                IN VARCHAR2,
   Related_Reports_Exist      IN BOOLEAN,
   Parameter_Page             IN BOOLEAN,
   Parameter_Page_Link        IN VARCHAR2,
   p_Body_Attribs         IN VARCHAR2,
   HTML_Banner                OUT NOCOPY VARCHAR2
)
IS
BEGIN
    BIS_REPORT_UTIL_PVT.Build_HTML_Banner (Icx_Report_Images,
                    More_Info_Directory,
                    NLS_Language_Code,
                    Report_Name,
                    Report_Link,
                    Related_Reports_Exist,
                    Parameter_Page,
                    Parameter_Page_Link,
                    p_Body_Attribs,
                    HTML_Banner
                       );
END Build_HTML_Banner_Reports;

PROCEDURE Build_Report_Title
( p_Function_Code           IN VARCHAR2,
  p_Rdf_Filename        IN VARCHAR2,
  p_Body_Attribs            IN VARCHAR2
)
IS
BEGIN
    BIS_REPORT_UTIL_PVT.Build_Report_Title (p_Function_Code,
                       p_Rdf_Filename,
                       p_Body_Attribs);
END Build_Report_Title;


PROCEDURE Build_Parameter_Form
( p_Form_Action        IN     VARCHAR2,
  p_Report_Param_Table IN     BIS_UTILITIES_PUB.Report_Parameter_Tbl_Type
)
IS
BEGIN
    BIS_REPORT_UTIL_PVT.Build_Parameter_Form (p_Form_Action,
                          p_Report_Param_Table
                         );
END Build_Parameter_Form;

PROCEDURE Get_After_Form_HTML
( icx_report_images    IN  VARCHAR2,
  nls_language_code    IN  VARCHAR2,
  report_name          IN  VARCHAR2
)
IS
BEGIN
    BIS_REPORT_UTIL_PVT.Get_After_Form_HTML(Icx_Report_Images,
                        NLS_Language_Code,
                        Report_Name);
END Get_After_Form_HTML;


    function encode (p_url     in varchar2,
                     p_charset in varchar2 default null)
                     return varchar2
    is
        c_unreserved constant varchar2(72) :=
        '-_.!~*''()ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        l_client_nls_lang  varchar2(200);
        l_client_charset   varchar2(200);
        l_db_charset       varchar2(200);
        l_tmp              varchar2(32767) := '';
        l_onechar     varchar2(4);
        l_str         varchar2(48);
        l_byte_len    integer;
        l_do_convert   boolean := null;
        i             integer;
    begin
        if p_url is NULL then
           return NULL;
        end if;
      if p_charset is NULL
      then
        l_client_charset := g_db_charset;
        l_client_nls_lang := g_db_nls_lang;
      else
        i := instr(p_charset, '.');
        if i <> 0 then
           l_client_charset := substr(p_charset, i+1);
           l_client_nls_lang := p_charset;
        else
           l_client_charset := p_charset;
           l_client_nls_lang := 'AMERICAN_AMERICA.' || p_charset;
        end if;
      end if; -- this IF is Fix for 2380993

        /* check if code conversion is required or not */
        if l_client_nls_lang = NULL then
           l_do_convert := false;
        elsif l_client_charset = g_db_charset then
           l_do_convert := false;
        else
           l_do_convert := true;
        end if;

        for i in 1 .. length(p_url) loop
            l_onechar := substr(p_url,i,1);

            if instr(c_unreserved, l_onechar) > 0 then
                /* if this character is excluded from encoding */
                l_tmp := l_tmp || l_onechar;
            elsif l_onechar = ' ' then
                /* spaces are encoded using the plus "+" sign */
                l_tmp := l_tmp || '+';
            else
                if (l_do_convert) then
                 /*
                  * This code to be called ONLY in case when client and server
                  * charsets are different. The performance of this code is
                  * significantly slower than "else" portion of this statement.
                  * But in this case it is guarenteed to be working in
                  * any configuration where the byte-length of the charset
                  * is different between client and server (e.g. UTF-8 to SJIS).
                  */

                  /*
                   * utl_raw.convert only takes a qualified NLS_LANG value in
                   * <langauge>_<territory>.<charset> format for target and
                   * source charset parameters. Need to use l_client_nls_lang
                   * and g_db_nls_lang here.
                   */
                    l_str := utl_raw.convert(utl_raw.cast_to_raw(l_onechar),
                        l_client_nls_lang,
                        g_db_nls_lang);
                    l_byte_len := length(l_str);
                    if l_byte_len = 2 then
                        l_tmp := l_tmp
                            || '%' || l_str;
                    elsif l_byte_len = 4 then
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2);
                    elsif l_byte_len = 6 then
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2);
                    elsif l_byte_len = 8 then
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2)
                            || '%' || substr(l_str,7,2);
                    else /* maximum precision exceeded */
                        raise PROGRAM_ERROR;
                    end if;
                else
                 /*
                  * This is the "simple" encoding when no charset translation
                  * is needed, so it is relatively fast.
                  */
                    l_byte_len := lengthb(l_onechar);
                    if l_byte_len = 1 then
                        l_tmp := l_tmp || '%' ||
                            substr(to_char(ascii(l_onechar),'FM0X'),1,2);
                    elsif l_byte_len = 2 then
                        l_str := to_char(ascii(l_onechar),'FM0XXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2);
                    elsif l_byte_len = 3 then
                        l_str := to_char(ascii(l_onechar),'FM0XXXXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2);
                    elsif l_byte_len = 4 then
                        l_str := to_char(ascii(l_onechar),'FM0XXXXXXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2)
                            || '%' || substr(l_str,7,2);
                    else /* maximum precision exceeded */
                        raise PROGRAM_ERROR;
                    end if;
                end if;
            end if;
        end loop;
        return l_tmp;
    end encode;

    function decode (p_url     in varchar2,
                     p_charset in varchar2 default null)
                     return varchar2
    is
        l_client_nls_lang varchar2(200);
        l_raw             raw(32767);
        l_char            varchar2(4);
        l_hex             varchar2(8);
        l_len             integer;
        i                 integer := 1;
    begin
        /*
         * Set a source charset for code conversion.
         * utl_raw.convert() only accepts <lang>_<territory>.<charset> format
         * to specify source and destination charset and need to add a dummy
         * 'AMERICAN_AMERICA' string if a give charset dose not have <lang>_
         * <territory> information.
         */
        if instr(p_charset, '.') = 0 then
            l_client_nls_lang := 'AMERICAN_AMERICA.' || p_charset;
        else
            l_client_nls_lang := p_charset;
        end if;

        l_len := length(p_url);

        while i <= l_len
        loop
            l_char := substr(p_url, i, 1);
            if l_char = '+' then
                /* convert to a hex number of space characters */
                l_hex := '20';
                i := i + 1;
            elsif l_char = '%' then
                /* process hex encoded characters. just remove a % character */
                l_hex := substr(p_url, i+1, 2);
                i := i + 3;
            else
                /* convert to hex numbers for all other characters */
                l_hex := to_char(ascii(l_char), 'FM0X');
                i := i + 1;
            end if;
            /* convert a hex number to a raw datatype */
            l_raw := l_raw || hextoraw(l_hex);
         end loop;

         /*
          * convert a raw data from the source charset to the database charset,
          * then cast it to a varchar2 string.
          */
         return utl_raw.cast_to_varchar2(
                          utl_raw.convert(l_raw, g_db_nls_lang, l_client_nls_lang));
     end decode;


Procedure Retrieve_Org_Where_Clause
( p_user_id                    IN NUMBER
, p_dimension_level_short_name IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
, x_return_status                 OUT NOCOPY  VARCHAR2
, x_msg_count                  OUT NOCOPY  VARCHAR2
, x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS

l_Responsibility_tbl BIS_Responsibility_PVT.Responsibility_Tbl_Type;
l_where_clause       VARCHAR2(32000);
l_comma              VARCHAR2(2) := ',';
l_return_status      VARCHAR2(100);
l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
x_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

    FND_MSG_PUB.initialize;

  IF(p_dimension_level_short_name <> 'TOTAL_ORGANIZATION')
  AND (SUBSTR(p_dimension_level_short_name, 1, 3) <> 'OPM')
  THEN

      BIS_RESPONSIBILITY_PVT.Retrieve_User_Responsibilities
      ( p_api_version            => 1.0
      , p_user_id                => p_user_id
      , p_Responsibility_version => NULL
      , x_Responsibility_Tbl     => l_Responsibility_tbl
      , x_return_status          => l_return_status
      , x_error_tbl              => l_error_tbl
      );

      l_where_clause := '" responsibility_id IN ( ';

      FOR i IN 1..l_Responsibility_tbl.COUNT LOOP
        IF i = l_Responsibility_tbl.LAST THEN
          l_where_clause := l_where_clause
                          ||l_Responsibility_tbl(i).Responsibility_ID;
        ELSE
          l_where_clause := l_where_clause
                          ||l_Responsibility_tbl(i).Responsibility_ID||l_comma;
       END IF;
      END LOOP;

      l_where_clause := l_where_clause||' )"';
  ELSE
    l_where_clause := '""';
  END IF;

   x_where_clause := l_where_clause;

   x_return_status := 'S';
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
        l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );

END Retrieve_Org_Where_Clause;

-- Time is related to organiztion
-- New procedure to take in org_id directly
Procedure Retrieve_Time_Where_Clause
( p_time_dim_level_short_name  IN VARCHAR2
, p_org_dim_level_short_name   IN VARCHAR2
, p_org_id                 IN VARCHAR2
, x_where_clause               OUT NOCOPY VARCHAR2
, x_return_status                 OUT NOCOPY  VARCHAR2
, x_msg_count                  OUT NOCOPY  VARCHAR2
, x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
  l_where_clause VARCHAR2(32000);
  x_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error_tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

    FND_MSG_PUB.initialize;

  IF(p_time_dim_level_short_name <> 'TOTAL_TIME')
    AND (is_time_dependent_on_org(p_time_lvl_short_name => p_time_dim_level_short_name)
    = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
      l_where_clause :=
      'organization_id = '|| '''' || p_org_id || '''' || ' and organization_type = '
      || '''' || p_org_dim_level_short_name || '''';
  ELSE
    l_where_clause := '""';
  END IF;

  x_where_clause  := l_where_clause;
  x_return_status := 'S';
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
END Retrieve_Time_Where_Clause;

FUNCTION is_time_dependent_on_org
( p_time_lvl_short_name IN VARCHAR2)
RETURN NUMBER IS
BEGIN

    FOR i IN 1..Tlist.count LOOP
     IF Tlist(i) = p_time_lvl_short_name THEN
       RETURN 1;
     END IF;
    END LOOP;
    RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END is_time_dependent_on_org;


FUNCTION is_org_dependent_on_resp ( p_org_lvl_short_name IN VARCHAR2) RETURN NUMBER IS
BEGIN
  FOR i IN 1..Olist.count LOOP
    IF Olist(i) = p_org_lvl_short_name THEN
      return 1;
    END IF;
  END LOOP;
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END is_org_dependent_on_resp;

PROCEDURE get_time_where_clause(
 p_dim_level_short_name IN  VARCHAR2
,p_parent_level_short_name    IN  VARCHAR2
,p_parent_level_id            IN  VARCHAR2
,p_source                     IN  VARCHAR2
,x_where_clause               OUT NOCOPY VARCHAR2
,x_return_status               OUT NOCOPY VARCHAR2
,x_err_count                  OUT NOCOPY NUMBER
,x_errorMessage               OUT NOCOPY VARCHAR2
) IS

  l_where_clause  VARCHAR2(32000);
  l_first_quote_pos NUMBER(10);
BEGIN
IF is_time_dependent_on_org(p_dim_level_short_name) <> 1 THEN
  x_where_clause := NULL;
  x_return_status := 'S';
  x_err_count := 0;
  x_errorMessage := '';
ELSE
-- the old(non-dbc) time dimension levels now, this also includes EDW_TIME_CAL_PERIOD
  IF ( (p_parent_level_short_name IS NULL) OR (p_parent_level_id IS NULL)) THEN
    RAISE e_invalid_parent;
  ELSE
    BIS_UTILITIES_PUB.Retrieve_Time_Where_Clause(
                      P_TIME_DIM_LEVEL_SHORT_NAME => p_dim_level_short_name
                     ,P_ORG_DIM_LEVEL_SHORT_NAME  => p_parent_level_short_name
                     ,P_ORG_ID                    => p_parent_level_id
                     ,X_WHERE_CLAUSE              => l_where_clause
                     ,X_RETURN_STATUS             => x_return_status
                     ,X_MSG_COUNT                 => x_err_count
                     ,X_MSG_DATA                  => x_errorMessage
                     );

-- Strip off the ""
   IF ( (l_where_clause IS NOT NULL) AND
     (l_where_clause <> '""')) THEN
     l_where_clause := TRIM(l_where_clause);
     l_first_quote_pos := instr(l_where_clause, '"');
     IF (l_first_quote_pos <> 0) THEN -- there is "" exists
       l_where_clause := SUBSTR(l_where_clause, (l_first_quote_pos+1));
       l_where_clause := SUBSTR(l_where_clause,1,(LENGTH(l_where_clause)-1));
     END IF;
     x_where_clause := l_where_clause ;
   ELSE  -- NULL or "" now
     x_where_clause := NULL;
   END IF;
  END IF;
END IF;
RETURN;
EXCEPTION
  WHEN e_invalid_parent THEN
  null;
  WHEN OTHERS THEN
  null;
END get_time_where_clause;

PROCEDURE get_org_where_clause(
 p_usr_id                     IN  NUMBER
,p_dim_level_short_name       IN  VARCHAR2
,x_where_clause               OUT NOCOPY VARCHAR2
,x_return_status              OUT NOCOPY VARCHAR2
,x_err_count                  OUT NOCOPY NUMBER
,x_errorMessage               OUT NOCOPY VARCHAR2
) IS
  l_where_clause  VARCHAR2(32000);
  l_first_quote_pos NUMBER(10);
BEGIN
IF is_org_dependent_on_resp(p_dim_level_short_name) <> 1 THEN
  x_where_clause := NULL;
  x_return_status := 'S';
  x_err_count := 0;
  x_errorMessage := '';
ELSE
-- the old(non-dbc) time dimension levels now, this also includes EDW_TIME_CAL_PERIOD
  IF p_usr_id IS NULL THEN
    RAISE e_invalid_user;
  ELSE
    BIS_UTILITIES_PUB.Retrieve_Org_Where_Clause(
                           p_user_id                    => p_usr_id
                         , p_dimension_level_short_name => p_dim_level_short_name
                         , x_where_clause               => l_where_clause
                                       );
-- Strip off the ""
   IF ( (l_where_clause IS NOT NULL) AND
     (l_where_clause <> '""')) THEN
     l_where_clause := TRIM(l_where_clause);
     l_first_quote_pos := instr(l_where_clause, '"');
     l_where_clause := SUBSTR(l_where_clause, (l_first_quote_pos+1));

     l_where_clause := SUBSTR(l_where_clause,1,(LENGTH(l_where_clause)-1));
     x_where_clause := l_where_clause ;
   ELSE
     x_where_clause := NULL;
   END IF;
  END IF;
END IF;
RETURN;
EXCEPTION
  WHEN e_invalid_user THEN
  null;
  WHEN OTHERS THEN
  null;
END get_org_where_clause;


-- return Edw time levels from the Tlist

FUNCTION get_edw_org_dep_time_levels RETURN VARCHAR2 IS
  l_edw_org_dep_time_levels  VARCHAR2(32000) := null;
BEGIN
  FOR i IN 1..Tlist.count LOOP
    IF ( SUBSTR(Tlist(i),1,3) = 'EDW' ) THEN
      IF ( l_edw_org_dep_time_levels IS NOT NULL) THEN
        l_edw_org_dep_time_levels := l_edw_org_dep_time_levels ||','|| Tlist(i);
      ELSE
        l_edw_org_dep_time_levels := Tlist(i);
      END IF;
    END IF;
  END LOOP;
  RETURN l_edw_org_dep_time_levels ;
EXCEPTION
  WHEN OTHERS THEN
    RETURN null;
END get_edw_org_dep_time_levels ;




--
-- The following api is called (once per program) to check value of
--  the profile option 'BIS_PMF_DEBUG'. This profile will be set
--  from Jintiator Forms.
-- Will code SET_debug_mode_profile if needed.
--
PROCEDURE get_debug_mode_profile -- 2694978
( x_is_debug_mode   OUT NOCOPY BOOLEAN
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
) IS
BEGIN

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_return_msg     := NULL;
  bis_utilities_pvt.get_debug_mode_profile(
     x_is_debug_mode   => x_is_debug_mode
   , x_return_status   => x_return_status
   , x_return_msg      => x_return_msg
   );

EXCEPTION
  WHEN OTHERS THEN
    x_return_status  := FND_API.G_RET_STS_ERROR;
    x_return_msg    := 'Error in setting debug log flag in BIS_UTILITIES_PUB.get_debug_mode_profile: '|| SQLERRM;
    x_is_debug_mode    := FALSE;
END get_debug_mode_profile ;


--
-- The following api is called (once per program) to set the value of
-- debug flag value.
--
PROCEDURE set_debug_log_flag (  -- 2694978
  p_is_true         IN  BOOLEAN
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_return_status  VARCHAR2(1000) := FND_API.G_RET_STS_SUCCESS;
  l_return_msg     VARCHAR2(10000) := NULL;
BEGIN

  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_return_msg      := NULL;

  bis_utilities_pvt.set_debug_log_flag(
    p_is_true         => p_is_true
  , x_return_status   => x_return_status
  , x_return_msg      => x_return_msg );


EXCEPTION
  WHEN OTHERS THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    x_return_msg      := 'Error in setting debug log flag in BIS_UTILITIES_PUB.set_debug_log_flag: '|| SQLERRM;
END set_debug_log_flag;



FUNCTION is_debug_on -- x in varchar2) -- 2694978
RETURN BOOLEAN
IS
BEGIN

  RETURN bis_utilities_pvt.is_debug_on();

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_debug_on;



PROCEDURE open_debug_log ( -- 2694978
  p_file_name      IN  VARCHAR2,
  p_dir_name       IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_return_msg     OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_return_msg      := NULL;

  bis_utilities_pvt.open_debug_log ( -- 2694978
    p_file_name      => p_file_name ,
    p_dir_name       => p_dir_name,
    x_return_status  => x_return_status,
    x_return_msg     => x_return_msg);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    x_return_msg      := 'Error in setting debug log flag in BIS_UTILITIES_PUB.open_debug_log: '|| SQLERRM;
END open_debug_log;



PROCEDURE close_debug_log ( -- 2694978
  p_file_name      IN  VARCHAR2,
  p_dir_name       IN  VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_return_msg     OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status   := FND_API.G_RET_STS_SUCCESS;
  x_return_msg      := NULL;

  bis_utilities_pvt.close_debug_log(
    p_file_name      => p_file_name
  , p_dir_name       => p_dir_name
  , x_return_status  => x_return_status
  , x_return_msg     => x_return_msg);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status   := FND_API.G_RET_STS_ERROR;
    x_return_msg      := 'Error in setting debug log flag in BIS_UTILITIES_PUB.close_debug_log: '|| SQLERRM;
END close_debug_log;



PROCEDURE put(p_text IN VARCHAR2) -- 2694978
IS
BEGIN
  bis_utilities_pvt.put(p_text => p_text);
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END put;


PROCEDURE put_line(p_text IN VARCHAR2) -- 2694978
IS
BEGIN
  bis_utilities_pvt.put_line(p_text => p_text);
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END put_line;

-- get the oracle database version.
-- bug#3374352
FUNCTION Get_DB_Version RETURN NUMBER IS
  l_instance_role VARCHAR2(18);
  l_db_ver  NUMBER;
BEGIN
  l_instance_role := 'PRIMARY_INSTANCE';

  -- Get the db version before the first '.'
  SELECT TO_NUMBER(substr(trim(VI.version), 1, instr(trim(VI.version), '.', 1, 1) - 1)) INTO l_db_ver
  FROM v$instance VI
  WHERE VI.instance_role = l_instance_role;

  RETURN l_db_ver;

END Get_DB_Version;


/******************************************************************************
 * Function Enable_Auto_Generated() returns
 *
 *    1) "T" if profile "XXX" is set to "Yes"
 *
 *    2) "F" if profile "XXX" is set to "No" or is NULL
 *
 *    Added for Bug#3767188
 *    Modified for Bug#3788314
 *
 ******************************************************************************/

FUNCTION Enable_Auto_Generated
RETURN VARCHAR2 IS
   l_Profile_Value   VARCHAR2(255);
   l_Return_Value    VARCHAR2(1);
BEGIN
   l_Return_Value := 'F';

   l_Profile_Value := FND_PROFILE.VALUE_SPECIFIC(
                           NAME              => BIS_UTILITIES_PUB.G_ENABLE_AUTOGEN_PROFILE_NAME
                         , USER_ID           => NULL
                         , RESPONSIBILITY_ID => FND_GLOBAL.RESP_ID
                         , APPLICATION_ID    => NULL
                         , ORG_ID            => NULL
                         , SERVER_ID         => NULL
                       );

   l_Profile_Value := UPPER(NVL(l_Profile_Value, 'N'));

   IF (l_Profile_Value = 'Y') THEN
      l_Return_Value := 'T';
   ELSE
      l_Return_Value := 'F';
   END IF;

   RETURN l_Return_Value;
EXCEPTION
   WHEN OTHERS THEN
      l_Return_Value := 'F';

      RETURN l_Return_Value;
END Enable_Auto_Generated;

/******************************************************************************
 * Function Is_Func_Enabled
 *
 * 1) "T" if the user (fnd_global.user_id) has access to the function p_Function_Name.
 * 2) "F" if the user does not have access to the function p_function_name
 *
 *
 ******************************************************************************/

FUNCTION Is_Func_Enabled (
     p_Function_Name  IN VARCHAR2
) RETURN VARCHAR2 IS

  l_Function_Name FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
  l_Function_Id   FND_FORM_FUNCTIONS.FUNCTION_ID%TYPE;
  l_Menu_Id       FND_MENUS.MENU_ID%TYPE;
  l_User_Id       FND_USER.USER_ID%TYPE;

  l_Has_User_Access BOOLEAN;
  l_Return_Status   VARCHAR2(1);


  CURSOR c_Resp_Menus IS
    SELECT   R.MENU_ID
    FROM     FND_RESPONSIBILITY_VL  R,
             FND_USER_RESP_GROUPS   U
    WHERE    U.USER_ID           =  FND_GLOBAL.USER_ID
    AND      R.VERSION           =  'W'
    AND      U.RESPONSIBILITY_ID =  R.RESPONSIBILITY_ID
    AND      U.START_DATE        <= SYSDATE
    AND     (U.END_DATE IS NULL OR U.END_DATE >= SYSDATE)
    AND      R.START_DATE        <= SYSDATE
    AND     (R.END_DATE IS NULL OR R.END_DATE >= SYSDATE);

BEGIN
  l_Has_User_Access := FALSE;
  l_Return_Status   := 'F';
  l_Function_Name   := p_Function_Name;

  -- Internally manage the no-data-found issue. If Measure definer function is not available
  BEGIN

    SELECT FUNCTION_ID
    INTO   l_Function_Id
    FROM   FND_FORM_FUNCTIONS
    WHERE  FUNCTION_NAME = l_Function_Name;

  EXCEPTION
    WHEN OTHERS THEN
       l_Function_Id := NULL;
  END;

  -- Loop thro the responsibility menus
  IF (l_Function_Id IS NOT NULL) THEN
    FOR cRespMenu IN c_Resp_Menus LOOP
      IF (FND_FUNCTION.IS_FUNCTION_ON_MENU(cRespMenu.MENU_ID, l_Function_Id)) THEN
         l_Has_User_Access := TRUE;
         EXIT;
      END IF;
    END LOOP;
  END IF;

  IF (l_Has_User_Access = TRUE) THEN
    l_Return_Status := 'T';
  ELSE
    l_Return_Status := 'F';
  END IF;

  RETURN l_Return_Status;

EXCEPTION
  WHEN OTHERS THEN
     l_Return_Status   := 'F';

     RETURN l_Return_Status;
END Is_Func_Enabled;

/******************************************************************************
 *  FUNCTION Enable_Custom_Kpi()
 *
 *  1) "T" if the function Enable_Auto_Generated returns "T" (true) and
 *     the current accessing user has access to the following FND form functions
 *        - BSC_PMD_MD_SELECTMEASURE_PGE
 *        - BSC_BID_SELECTMEASURE_PGE
 *
 *  2) "F" if any of the above conditions fail
 *
 ******************************************************************************/

FUNCTION  Enable_Custom_Kpi
RETURN VARCHAR2 IS
   l_Return_Value    VARCHAR2(1);
BEGIN
   l_Return_Value := 'F';

   IF ((BIS_UTILITIES_PUB.Enable_Auto_Generated = 'T') AND
       ((BIS_UTILITIES_PUB.Is_Func_Enabled(BIS_UTILITIES_PUB.G_BIA_MEAS_DEFINER_FUNCTION) = 'T') OR
        (BIS_UTILITIES_PUB.Is_Func_Enabled(BIS_UTILITIES_PUB.G_MEAS_DEFINER_FORM_FUNCTION)= 'T'))) THEN
     l_Return_Value := 'T';
   ELSE
     l_Return_Value := 'F';
   END IF;

   RETURN l_Return_Value;
EXCEPTION
  WHEN OTHERS THEN
     l_Return_Value := 'F';

     RETURN l_Return_Value;
END Enable_Custom_Kpi;

FUNCTION  Enable_Generated_Source_Report
RETURN VARCHAR2 IS
   l_Return_Value    VARCHAR2(1);
   l_property_value  bsc_sys_init.property_value%TYPE:=NULL ;
BEGIN

    -- check bsc_sys_init for flag
    BEGIN
        SELECT property_value
        INTO l_property_value
        FROM bsc_sys_init
        WHERE property_code = G_ENABLE_GEN_SOURCE_REPORT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_property_value := NULL;
    END;

    IF (l_property_value IS NULL) THEN
     l_Return_Value := 'F';
    ELSE
     l_Return_Value := 'T';
    END IF;

    RETURN l_Return_Value;
EXCEPTION
  WHEN OTHERS THEN
     l_Return_Value := 'F';

     RETURN l_Return_Value;
END Enable_Generated_Source_Report;

/******************************************************************************/
FUNCTION Get_Owner_Id(p_name IN VARCHAR2) RETURN NUMBER IS
BEGIN
  IF p_name = BIS_UTILITIES_PUB.G_CUSTOM_OWNER THEN
    RETURN FND_GLOBAL.USER_ID;
  ELSE
    RETURN FND_LOAD_UTIL.OWNER_ID(p_name);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_GLOBAL.USER_ID;
END Get_Owner_Id;


/******************************************************************************/
FUNCTION Get_Owner_Name(p_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
  IF ((p_id = 0) OR (p_id = 1)) THEN
    RETURN 'SEED';
  ELSE
    RETURN FND_LOAD_UTIL.OWNER_NAME(p_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_LOAD_UTIL.OWNER_NAME(-1);
END Get_Owner_Name;

END BIS_UTILITIES_PUB;

/
