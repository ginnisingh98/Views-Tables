--------------------------------------------------------
--  DDL for Package Body BIS_PMF_ALERT_REG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_ALERT_REG_PVT" AS
/* $Header: BISVARTB.pls 120.0 2005/06/01 15:54:40 appldev noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVARTB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing Alert Registration Repository
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 17-May-2000  jradhakr Creation
REM | June 2000    irchen takeover
REM | 23-JAN-03    mahrao For having different local variables for IN and OUT
REM |                     parameters.
REM | 27-Oct-2004  aguwalan Bug#3909131, added Add_Users_To_Role            |
REM | 21-MAR-2005  ankagarw   bug#4235732 - changing count(*) to count(1)   |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_PMF_ALERT_REG_PVT';
G_PERFORMANCE_ALERT_PROMPTS CONSTANT VARCHAR2(1000)
  := 'BIS_PERFORMANCE_ALERT_PROMPTS';
G_AD_HOC_ROLE_DISPLAY_NAME CONSTANT VARCHAR2(1000)
  := 'BIS_AD_HOC_ROLE_DISPLAY_NAME';

G_AMPERSAND	       CONSTANT VARCHAR2(1)    := '&';

l_debug_text VARCHAR2(32000);


PROCEDURE Create_Parameter_set
( p_api_version      IN      NUMBER
, p_commit           IN      VARCHAR2   := FND_API.G_FALSE
, p_Param_Set_Rec    IN OUT NOCOPY  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY     VARCHAR2
, x_error_Tbl        OUT NOCOPY     BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_user_id           number;
  l_login_id          number;
  l_registration_id   number;
  l_role_name         varchar2(30);
  l_null_role_name    varchar2(30) := NULL;
  l_role_display_name varchar2(32000);
  l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_role_name_p       VARCHAR2(30);
  l_null_role_name_p  VARCHAR2(30) := NULL;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Commented out NOCOPY for performance reasons.

  BIS_PMF_ALERT_REG_PVT.Validate_Parameter_set
       ( p_api_version     => p_api_version
       , p_Param_Set_Rec   => p_Param_Set_rec
       , x_return_status   => x_Return_status
       , x_error_Tbl       => x_error_tbl
       );
  IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  */

  l_user_id  := fnd_global.USER_ID;
  l_login_id := fnd_global.LOGIN_ID;

  --
  -- Selecting the Next Registion Id from Sequence Generator
  --
  select bis_alert_registration_s.NextVal into l_registration_id from dual;
  --
  --BIS_UTILITIES_PUB.put_line(p_text =>'creating paramter set. notifier code: '
  --||p_Param_Set_Rec.NOTIFIERS_CODE);

  IF p_Param_Set_Rec.NOTIFIERS_CODE IS NULL THEN
    l_role_name := G_BIS_ALERT_ROLE || to_char(l_registration_id);
    l_role_display_name := BIS_UTILITIES_PVT.getPrompt
                           ( G_PERFORMANCE_ALERT_PROMPTS
                           , G_AD_HOC_ROLE_DISPLAY_NAME
                           );
    --BIS_UTILITIES_PUB.put_line(p_text =>'role name, display name: '||l_role_name
    --||', '||l_role_display_name);

    BEGIN
		  l_role_name_p := l_role_name;
      wf_directory.CreateAdHocRole
      ( role_name          => l_role_name_p
--      , role_display_name  => l_role_display_name
      , role_display_name  => l_role_name
      , expiration_date    => NULL);
    EXCEPTION
      WHEN OTHERS THEN
       BIS_UTILITIES_PUB.put_line(p_text =>'1st error while creating role: '||l_role_name
       ||'. error: '||sqlerrm);

      BEGIN
        null;
        select '~WF_ADHOC-' ||WF_ADHOC_ROLE_S.NEXTVAL
        into l_null_role_name
        from dual;
        l_null_role_name_p := l_null_role_name;
        wf_directory.CreateAdHocRole
        ( role_name          => l_null_role_name_p
--        , role_display_name  => l_role_display_name
        , role_display_name  => l_null_role_name
        , expiration_date    => NULL);

      EXCEPTION
        WHEN OTHERS THEN
        BIS_UTILITIES_PUB.put_line(p_text =>'2st error while creating role: '||l_null_role_name
        ||'. error: '||sqlerrm);
      END;

    END;

    p_Param_Set_Rec.NOTIFIERS_CODE :=  l_role_name;
  end if;
  /*
  BIS_UTILITIES_PUB.put_line(p_text =>'ART: role: '|| p_Param_Set_Rec.NOTIFIERS_CODE);
  BIS_UTILITIES_PUB.put_line(p_text =>'target level: '||p_Param_Set_Rec.TARGET_LEVEL_ID);
  BIS_UTILITIES_PUB.put_line(p_text =>'time dim level: '
    ||p_Param_Set_Rec.TIME_DIMENSION_LEVEL_ID);
  BIS_UTILITIES_PUB.put_line(p_text =>'time dim value: '||p_Param_Set_Rec.PARAMETER2_VALUE);
  */
  --
  insert into bis_pmf_alert_parameters(
    REGISTRATION_ID
  , PERFORMANCE_MEASURE_ID
  , TARGET_LEVEL_ID
  , TIME_DIMENSION_LEVEL_ID
  , PLAN_ID
  , NOTIFIERS_CODE
  , PARAMETER1_VALUE
  , PARAMETER2_VALUE
  , PARAMETER3_VALUE
  , PARAMETER4_VALUE
  , PARAMETER5_VALUE
  , PARAMETER6_VALUE
  , PARAMETER7_VALUE
  , NOTIFY_OWNER_FLAG
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  )
  values
  ( l_registration_id
  , p_Param_Set_Rec.PERFORMANCE_MEASURE_ID
  , p_Param_Set_Rec.TARGET_LEVEL_ID
  , p_Param_Set_Rec.TIME_DIMENSION_LEVEL_ID
  , p_Param_Set_Rec.PLAN_ID
  , p_Param_Set_Rec.NOTIFIERS_CODE
  , p_Param_Set_Rec.PARAMETER1_VALUE
  , p_Param_Set_Rec.PARAMETER2_VALUE
  , p_Param_Set_Rec.PARAMETER3_VALUE
  , p_Param_Set_Rec.PARAMETER4_VALUE
  , p_Param_Set_Rec.PARAMETER5_VALUE
  , p_Param_Set_Rec.PARAMETER6_VALUE
  , p_Param_Set_Rec.PARAMETER7_VALUE
  , p_Param_Set_Rec.NOTIFY_OWNER_FLAG
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  );

  if (p_commit = FND_API.G_TRUE) then
    --BIS_UTILITIES_PUB.put_line(p_text =>'committed insert. status: '||x_return_status);
    COMMIT;
  end if;

EXCEPTION
   when FND_API.G_EXC_ERROR then
     x_return_status := FND_API.G_RET_STS_ERROR ;
     BIS_UTILITIES_PUB.put_line(p_text =>'exception 1 in Create_Parameter_set'||sqlerrm);
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     BIS_UTILITIES_PUB.put_line(p_text =>'exception 2 in Create_Parameter_set'||sqlerrm);
   when others then
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     BIS_UTILITIES_PUB.put_line(p_text =>'exception 3 in Create_Parameter_set'||sqlerrm);
     l_error_tbl := x_error_Tbl;
		 BIS_UTILITIES_PVT.Add_Error_Message
     ( p_error_msg_id      => SQLCODE
     , p_error_description => SQLERRM
     , p_error_proc_name   => G_PKG_NAME||'.Create_Parameter_set'
     , p_error_table       => l_error_tbl
     , x_error_table       => x_error_tbl
     );

END Create_Parameter_set;

--
-- Delete one parameter set.
--

PROCEDURE Delete_Parameter_set
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_Param_Set_Rec.registration_id IS NOT NULL THEN
    Delete_Parameter_Set(p_Param_Set_Rec.registration_id,x_return_status);
  ELSE
    BIS_UTILITIES_PUB.put_line(p_text =>'Cannot delete parameter set without Registeration ID.');
  END IF;
  IF p_commit = FND_API.G_TRUE THEN
    commit;
  END IF;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 1 in delete parameter set: '||sqlerrm);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 2 in delete parameter set: '||sqlerrm);
  when others then
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 3 in delete parameter set: '||sqlerrm);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Delete_Parameter_set'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

END Delete_Parameter_set;

PROCEDURE Delete_Parameter_Set
( p_registration_ID  IN NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
)
IS

  l_count_1 number := 0;
  l_count_2 number := 0;
  l_debug VARCHAR2(32000);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- BIS_UTILITIES_PUB.put_line(p_text =>'Deleting parameter set: '||p_registration_ID);

  -- select count(1) into l_count_1 from bis_pmf_alert_parameters;
  --  where registration_id = p_registration_id;

  delete from bis_pmf_alert_parameters
    where registration_id = p_registration_id;
  commit;

  --select count(1) into l_count_2 from bis_pmf_alert_parameters;
  --  where registration_id = p_registration_id;

  BIS_UTILITIES_PUB.put_line(p_text =>'before delete: '||l_count_1||', after delete: '||l_count_2);
  l_debug := 'before delete: '||l_count_1||', after delete: '||l_count_2;

  x_return_status := x_return_status ||'--delete debug--'||l_debug;

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception in delete parameter set: '||sqlerrm);
END Delete_Parameter_Set;

--
-- Retrieve a Table of parmeter set for the given PM and time
-- dimension level.
--
PROCEDURE Retrieve_Parameter_set
( p_api_version              IN  NUMBER
, p_measure_id               IN  NUMBER
, p_time_dimension_level_id  IN  NUMBER
, p_current_row              IN  VARCHAR2 := NULL
, x_Param_Set_Tbl            OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Param_Set_rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

  Cursor parameter_set_list is select
    REGISTRATION_ID
  , PERFORMANCE_MEASURE_ID
  , TARGET_LEVEL_ID
  , TIME_DIMENSION_LEVEL_ID
  , PLAN_ID
  , NOTIFIERS_CODE
  , PARAMETER1_VALUE
  , PARAMETER2_VALUE
  , PARAMETER3_VALUE
  , PARAMETER4_VALUE
  , PARAMETER5_VALUE
  , PARAMETER6_VALUE
  , PARAMETER7_VALUE
  , NOTIFY_OWNER_FLAG
from
  BIS_PMF_ALERT_PARAMETERS
where PERFORMANCE_MEASURE_ID =  p_measure_id
  and TIME_DIMENSION_LEVEL_ID =  p_time_dimension_level_id;

 i number := 0;

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving parameter set by Measure');
  for p_set in parameter_set_list
  loop

    l_Param_Set_rec.REGISTRATION_ID         := p_set.REGISTRATION_ID;
    l_Param_Set_rec.PERFORMANCE_MEASURE_ID  := p_set.PERFORMANCE_MEASURE_ID;
    l_Param_Set_rec.TARGET_LEVEL_ID         := p_set.TARGET_LEVEL_ID;
    l_Param_Set_rec.TIME_DIMENSION_LEVEL_ID
      := p_set.TIME_DIMENSION_LEVEL_ID;
    l_Param_Set_rec.PLAN_ID                 := p_set.PLAN_ID;
    l_Param_Set_rec.NOTIFIERS_CODE          := p_set.NOTIFIERS_CODE;
    l_Param_Set_rec.PARAMETER1_VALUE        := p_set.PARAMETER1_VALUE;
    l_Param_Set_rec.PARAMETER2_VALUE        := p_set.PARAMETER2_VALUE;
    l_Param_Set_rec.PARAMETER3_VALUE        := p_set.PARAMETER3_VALUE;
    l_Param_Set_rec.PARAMETER4_VALUE        := p_set.PARAMETER4_VALUE;
    l_Param_Set_rec.PARAMETER5_VALUE        := p_set.PARAMETER5_VALUE;
    l_Param_Set_rec.PARAMETER6_VALUE        := p_set.PARAMETER6_VALUE;
    l_Param_Set_rec.PARAMETER7_VALUE        := p_set.PARAMETER7_VALUE;
    l_Param_Set_rec.NOTIFY_OWNER_FLAG       := p_set.NOTIFY_OWNER_FLAG;
    /*
    BIS_UTILITIES_PUB.put_line(p_text =>'Registeration id: '||l_Param_Set_rec.REGISTRATION_ID
    ||', Measure id: '||l_Param_Set_rec.PERFORMANCE_MEASURE_ID
    ||', Target Level id: '||l_Param_Set_rec.target_LEVEL_ID
    ||', Time level id: '||l_Param_Set_rec.TIME_DIMENSION_LEVEL_ID
    ||', Notifier: '||l_Param_Set_rec.NOTIFIERS_CODE
    );
    */
    x_Param_Set_Tbl(x_Param_Set_Tbl.COUNT+1) := l_Param_Set_rec;
  end loop;

  IF parameter_set_list%ISOPEN THEN close parameter_set_list; END IF;
  BIS_UTILITIES_PUB.put_line(p_text =>'Number of Parameter_sets retrieved: '||x_Param_Set_Tbl.COUNT);

EXCEPTION
  when FND_API.G_EXC_ERROR then
    IF parameter_set_list%ISOPEN THEN close parameter_set_list; END IF;
    x_return_status := FND_API.G_RET_STS_ERROR ;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    IF parameter_set_list%ISOPEN THEN close parameter_set_list; END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  when others then
    IF parameter_set_list%ISOPEN THEN close parameter_set_list; END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Parameter_set'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

END Retrieve_Parameter_set;

--
-- Retrieve a Table of parmeter set for the specified
-- values in the parameter set record.
--
PROCEDURE Retrieve_Parameter_set
( p_api_version              IN  NUMBER
, p_Param_Set_Rec            IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, p_current_row              IN  VARCHAR2 := NULL
, x_Param_Set_Tbl            OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Param_Set_rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_Param_Set_tbl BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
  l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

  Cursor parameter_set_reg is
  select
    REGISTRATION_ID
  , PERFORMANCE_MEASURE_ID
  , TARGET_LEVEL_ID
  , TIME_DIMENSION_LEVEL_ID
  , PLAN_ID
  , NOTIFIERS_CODE
  , PARAMETER1_VALUE
  , PARAMETER2_VALUE
  , PARAMETER3_VALUE
  , PARAMETER4_VALUE
  , PARAMETER5_VALUE
  , PARAMETER6_VALUE
  , PARAMETER7_VALUE
  , NOTIFY_OWNER_FLAG
from
  BIS_PMF_ALERT_PARAMETERS
where  REGISTRATION_ID = p_Param_Set_Rec.REGISTRATION_ID;

  Cursor parameter_set_tl is
  select
    REGISTRATION_ID
  , PERFORMANCE_MEASURE_ID
  , TARGET_LEVEL_ID
  , TIME_DIMENSION_LEVEL_ID
  , PLAN_ID
  , NOTIFIERS_CODE
  , PARAMETER1_VALUE
  , PARAMETER2_VALUE
  , PARAMETER3_VALUE
  , PARAMETER4_VALUE
  , PARAMETER5_VALUE
  , PARAMETER6_VALUE
  , PARAMETER7_VALUE
  , NOTIFY_OWNER_FLAG
from
  BIS_PMF_ALERT_PARAMETERS
where TARGET_LEVEL_ID = p_Param_Set_Rec.TARGET_LEVEL_ID
  and PLAN_ID = p_Param_Set_Rec.PLAN_ID
--  and ( (TIME_DIMENSION_LEVEL_ID IS NULL
--        and p_Param_Set_Rec.TIME_DIMENSION_LEVEL_ID IS NULL)
--       or (TIME_DIMENSION_LEVEL_ID = p_Param_Set_Rec.TIME_DIMENSION_LEVEL_ID))
  and ( (PARAMETER1_VALUE is NULL
         and P_Param_Set_Rec.PARAMETER1_VALUE IS NULL)
       or (PARAMETER1_VALUE = P_Param_Set_Rec.PARAMETER1_VALUE))
  and ((PARAMETER2_VALUE is NULL
        and P_Param_Set_Rec.PARAMETER2_VALUE IS NULL)
       or (PARAMETER2_VALUE = P_Param_Set_Rec.PARAMETER2_VALUE))
  and ( (PARAMETER3_VALUE is NULL
        and P_Param_Set_Rec.PARAMETER3_VALUE IS NULL)
       or(PARAMETER3_VALUE = P_Param_Set_Rec.PARAMETER3_VALUE))
  and ((PARAMETER4_VALUE is NULL
        and P_Param_Set_Rec.PARAMETER4_VALUE IS NULL)
       or (PARAMETER4_VALUE = P_Param_Set_Rec.PARAMETER4_VALUE))
  and ((PARAMETER5_VALUE is NULL
        and P_Param_Set_Rec.PARAMETER5_VALUE IS NULL)
       or (PARAMETER5_VALUE = P_Param_Set_Rec.PARAMETER5_VALUE))
  and ((PARAMETER6_VALUE is NULL
        and P_Param_Set_Rec.PARAMETER6_VALUE IS NULL)
       or (PARAMETER6_VALUE = P_Param_Set_Rec.PARAMETER6_VALUE))
  and ((PARAMETER7_VALUE is NULL
        and P_Param_Set_Rec.PARAMETER7_VALUE IS NULL)
       or (PARAMETER7_VALUE = P_Param_Set_Rec.PARAMETER7_VALUE));

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving parameter set by parameter set record');
  IF p_Param_Set_Rec.REGISTRATION_ID IS NOT NULL THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving alert parameter set based on registration id');
    FOR p_set IN parameter_set_reg
    LOOP
      l_Param_Set_rec.REGISTRATION_ID         := p_set.REGISTRATION_ID;
      l_Param_Set_rec.PERFORMANCE_MEASURE_ID  := p_set.PERFORMANCE_MEASURE_ID;
      l_Param_Set_rec.TARGET_LEVEL_ID         := p_set.TARGET_LEVEL_ID;
      l_Param_Set_rec.TIME_DIMENSION_LEVEL_ID
        := p_set.TIME_DIMENSION_LEVEL_ID;
      l_Param_Set_rec.PLAN_ID                 := p_set.PLAN_ID;
      l_Param_Set_rec.NOTIFIERS_CODE          := p_set.NOTIFIERS_CODE;
      l_Param_Set_rec.PARAMETER1_VALUE        := p_set.PARAMETER1_VALUE;
      l_Param_Set_rec.PARAMETER2_VALUE        := p_set.PARAMETER2_VALUE;
      l_Param_Set_rec.PARAMETER3_VALUE        := p_set.PARAMETER3_VALUE;
      l_Param_Set_rec.PARAMETER4_VALUE        := p_set.PARAMETER4_VALUE;
      l_Param_Set_rec.PARAMETER5_VALUE        := p_set.PARAMETER5_VALUE;
      l_Param_Set_rec.PARAMETER6_VALUE        := p_set.PARAMETER6_VALUE;
      l_Param_Set_rec.PARAMETER7_VALUE        := p_set.PARAMETER7_VALUE;
      l_Param_Set_rec.NOTIFY_OWNER_FLAG       := p_set.NOTIFY_OWNER_FLAG;
      l_Param_Set_Tbl(l_Param_Set_Tbl.COUNT+1) := l_Param_Set_rec;
    END LOOP;
    BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved '||l_Param_Set_Tbl.COUNT||' parameter sets');

  ELSIF p_Param_Set_Rec.TARGET_LEVEL_ID IS NOT NULL THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving alert parameter set based on target level');
    FOR P_set IN parameter_set_tl
    LOOP
      l_Param_Set_rec.REGISTRATION_ID         := p_set.REGISTRATION_ID;
      l_Param_Set_rec.PERFORMANCE_MEASURE_ID  := p_set.PERFORMANCE_MEASURE_ID;
      l_Param_Set_rec.TARGET_LEVEL_ID         := p_set.TARGET_LEVEL_ID;
      l_Param_Set_rec.TIME_DIMENSION_LEVEL_ID
        := p_set.TIME_DIMENSION_LEVEL_ID;
      l_Param_Set_rec.PLAN_ID                 := p_set.PLAN_ID;
      l_Param_Set_rec.NOTIFIERS_CODE          := p_set.NOTIFIERS_CODE;
      l_Param_Set_rec.PARAMETER1_VALUE        := p_set.PARAMETER1_VALUE;
      l_Param_Set_rec.PARAMETER2_VALUE        := p_set.PARAMETER2_VALUE;
      l_Param_Set_rec.PARAMETER3_VALUE        := p_set.PARAMETER3_VALUE;
      l_Param_Set_rec.PARAMETER4_VALUE        := p_set.PARAMETER4_VALUE;
      l_Param_Set_rec.PARAMETER5_VALUE        := p_set.PARAMETER5_VALUE;
      l_Param_Set_rec.PARAMETER6_VALUE        := p_set.PARAMETER6_VALUE;
      l_Param_Set_rec.PARAMETER7_VALUE        := p_set.PARAMETER7_VALUE;
      l_Param_Set_rec.NOTIFY_OWNER_FLAG       := p_set.NOTIFY_OWNER_FLAG;
      l_Param_Set_Tbl(l_Param_Set_Tbl.COUNT+1) := l_Param_Set_rec;
    END LOOP;
    BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved '||l_Param_Set_Tbl.COUNT||' parameter sets');

  ELSIF p_Param_Set_rec.PERFORMANCE_MEASURE_ID IS NOT NULL
  AND p_Param_Set_rec.TIME_DIMENSION_LEVEL_ID IS NOT NULL
  THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving alert parameter set based on performance measure');
    Retrieve_Parameter_set
    ( p_api_version      => 1.0
    , p_measure_id       => p_Param_Set_rec.PERFORMANCE_MEASURE_ID
    , p_time_dimension_level_id => p_Param_Set_rec.TIME_DIMENSION_LEVEL_ID
    , P_current_row      => p_current_row
    , x_Param_Set_tbl    => l_param_set_tbl
    , x_return_status    => x_return_status
    , x_error_Tbl        => x_error_Tbl
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved '||l_Param_Set_Tbl.COUNT||' parameter sets');
    --x_param_set_tbl := l_param_set_tbl;
    --RETURN;
  END IF;

  x_Param_Set_Tbl := l_Param_Set_tbl;

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
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Parameter_set'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

END Retrieve_Parameter_set;

PROCEDURE Retrieve_Notifiers_Code
( p_api_version              IN NUMBER
, p_performance_measure_id   IN NUMBER   := NULL
, p_target_level_id          IN NUMBER   := NULL
, p_time_dimension_level_id  IN NUMBER   := NULL
, p_plan_id                  IN NUMBER   := NULL
, p_parameter1_value         IN VARCHAR2 := NULL
, p_parameter2_value         IN VARCHAR2 := NULL
, p_parameter3_value         IN VARCHAR2 := NULL
, p_parameter4_value         IN VARCHAR2 := NULL
, p_parameter5_value         IN VARCHAR2 := NULL
, p_parameter6_value         IN VARCHAR2 := NULL
, p_parameter7_value         IN VARCHAR2 := NULL
, p_current_row              IN VARCHAR2 := NULL
, x_Notifiers_Code           OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
)
IS

  l_Param_Set_rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_Param_Set_tbl BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_error_Tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error_Tbl_p   BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_Param_Set_rec.performance_measure_id  := p_performance_measure_id;
  l_Param_Set_rec.target_level_id         := p_target_level_id;
  l_Param_Set_rec.time_dimension_level_id := p_time_dimension_level_id;
  l_Param_Set_rec.plan_id               := p_plan_id;
  l_Param_Set_rec.parameter1_value      := p_parameter1_value;
  l_Param_Set_rec.parameter2_value      := p_parameter2_value;
  l_Param_Set_rec.parameter3_value      := p_parameter3_value;
  l_Param_Set_rec.parameter4_value      := p_parameter4_value;
  l_Param_Set_rec.parameter5_value      := p_parameter5_value;
  l_Param_Set_rec.parameter6_value      := p_parameter6_value;
  l_Param_Set_rec.parameter7_value      := p_parameter7_value;

  Retrieve_Notifiers_Code
  ( p_api_version   => p_api_version
  , p_Param_Set_rec => l_Param_Set_rec
  , x_Notifiers_Code => x_Notifiers_Code
  , x_return_status  => x_return_status
  );

EXCEPTION
  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR ;
    x_return_status := 'exception 1 at Retrieve_Notifiers_Code: '||sqlerrm;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_return_status := 'exception 2 at Retrieve_Notifiers_Code: '||sqlerrm;
 when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_return_status := 'exception 3 at Retrieve_Notifiers_Code: '||sqlerrm;
    l_error_tbl_p := l_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Notifiers_Code'
    , p_error_table       => l_error_tbl_p
    , x_error_table       => l_error_tbl
    );

END Retrieve_Notifiers_Code;

PROCEDURE Retrieve_Notifiers_Code
( p_api_version              IN NUMBER
, p_Param_Set_rec            IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_Notifiers_Code           OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
)
IS

  l_Param_Set_rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_Param_Set_tbl BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_error_Tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error_Tbl_p   BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  Retrieve_Parameter_set
  ( p_api_version    => p_api_version
  , p_Param_Set_Rec  => p_param_set_rec
  , x_Param_Set_Tbl  => l_Param_Set_Tbl
  , x_return_status  => x_return_status
  , x_error_Tbl      => l_error_Tbl
  );

  IF l_Param_Set_tbl.COUNT >= 1 THEN
    x_notifiers_code := l_Param_Set_tbl(1).notifiers_code;
    BIS_UTILITIES_PUB.put_line(p_text =>'Notifier code retrieved: '||x_notifiers_code);
  ELSE
    BIS_UTILITIES_PUB.put_line(p_text =>'Notifier code not retrieved.');
    x_notifiers_code := null;
  END IF;

EXCEPTION
 when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_return_status := 'exception 1 at Retrieve_Notifiers_Code: '||sqlerrm;
    BIS_UTILITIES_PUB.put_line(p_text =>x_return_status);
    l_error_tbl_p := l_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Notifiers_Code'
    , p_error_table       => l_error_tbl_p
    , x_error_table       => l_error_tbl
    );

END Retrieve_Notifiers_Code;

--
-- Checks if request is scheduled to run again.  If not, the request
-- is deleted from the Registration table and the ad hoc workflow role
-- is removed.
--
PROCEDURE Manage_Alert_Registrations
( p_Param_Set_Tbl            IN BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type
, x_request_scheduled        OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_return_status  VARCHAR2(32000);
  l_error_Tbl      BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  FOR i IN 1..p_Param_Set_Tbl.COUNT LOOP
    Manage_Alert_Registrations
    ( p_Param_Set_rec => p_Param_Set_Tbl(i)
    , x_request_scheduled => x_request_scheduled
    , x_return_status => l_return_status
    , x_error_Tbl     => l_error_Tbl
    );
  END LOOP;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Manage_Alert_Registrations'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Manage_Alert_Registrations;

--
-- Checks if request is scheduled to run again.  If not, the request
-- is deleted from the Registration table and the ad hoc workflow role
-- is removed.
--
PROCEDURE Manage_Alert_Registrations
( p_Param_Set_rec            IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_request_scheduled        OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_error_Tbl                OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BIS_CONCURRENT_MANAGER_PVT.Manage_Alert_Registrations
  ( p_Param_Set_rec     => p_Param_Set_rec
  , x_request_scheduled => x_request_scheduled
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

EXCEPTION
  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 1 in Manage_Alert_Registrations: '||sqlerrm);
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 2 in Manage_Alert_Registrations: '||sqlerrm);
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    BIS_UTILITIES_PUB.put_line(p_text =>'exception 3 in Manage_Alert_Registrations: '||sqlerrm);
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Manage_Alert_Registrations'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
END Manage_Alert_Registrations;


PROCEDURE Manage_Alert_Registrations
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_request_scheduled     OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_Param_Set_Rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_Param_Set_Tbl BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_request_scheduled VARCHAR2(1000);

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'Managing alert registrations. ');
  BIS_UTILITIES_PUB.put_line(p_text =>'Measure: '||p_measure_instance.measure_id
  ||', target level: '||p_measure_instance.Target_Level_ID);

  Form_Param_Set_Rec
  ( p_measure_instance     => p_measure_instance
  , p_dim_level_value_tbl  => p_dim_level_value_tbl
  , x_Param_Set_Rec        => l_Param_Set_Rec
  );
  l_Param_Set_tbl(l_Param_Set_tbl.COUNT+1) := l_Param_Set_Rec;

  Manage_Alert_Registrations
  ( p_Param_Set_Tbl    => l_Param_Set_Tbl
  , x_request_scheduled => x_request_scheduled
  , x_return_status    => x_return_status
  , x_error_Tbl        => x_error_Tbl
  );

END Manage_Alert_Registrations;

Procedure Form_Param_Set_Rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, x_Param_Set_Rec         OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
)
IS

  l_Param_Set_Rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_Param_Set_Tbl BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_Target_Level_Rec    BIS_Target_Level_PUB.Target_Level_Rec_Type;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_number   NUMBER;
  l_return_status       VARCHAR2(32000);
  l_error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_Target_Level_Rec.target_level_id := p_measure_instance.target_level_id;

  BIS_TARGET_LEVEL_PVT.Retrieve_Time_level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_dimension_level_number => l_dimension_level_number
  , x_return_status       => l_return_status
  , x_error_Tbl           => l_error_Tbl
  );

  l_Param_Set_Rec.PERFORMANCE_MEASURE_ID := p_measure_instance.measure_id;
  l_Param_Set_Rec.TIME_DIMENSION_LEVEL_ID
    := l_Dimension_Level_Rec.Dimension_Level_id;

  x_Param_Set_Rec := l_Param_Set_Rec;

END Form_Param_Set_Rec;

Procedure Form_Param_Set_Rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_Param_Set_Rec         OUT NOCOPY BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
)
IS

  l_Param_Set_Rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;
  l_Param_Set_Tbl BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_Target_Level_Rec    BIS_Target_Level_PUB.Target_Level_Rec_Type;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_number NUMBER;
  l_return_status       VARCHAR2(32000);
  l_error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_Target_Level_Rec.target_level_id := p_measure_instance.target_level_id;

  BIS_TARGET_LEVEL_PVT.Retrieve_Time_level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_dimension_level_number => l_dimension_level_number
  , x_return_status       => l_return_status
  , x_error_Tbl           => l_error_Tbl
  );

  l_Param_Set_Rec.PERFORMANCE_MEASURE_ID := p_measure_instance.measure_id;
  l_Param_Set_Rec.TARGET_LEVEL_ID := p_measure_instance.target_level_id;
  l_Param_Set_Rec.TIME_DIMENSION_LEVEL_ID
    := l_Dimension_Level_Rec.Dimension_Level_id;
  l_Param_Set_Rec.PLAN_ID := p_measure_instance.plan_id;
  l_Param_Set_Rec.PARAMETER1_VALUE
    := p_dim_level_value_tbl(1).dimension_level_value_id;
  l_Param_Set_Rec.PARAMETER2_VALUE
    := p_dim_level_value_tbl(2).dimension_level_value_id;
  l_Param_Set_Rec.PARAMETER3_VALUE
    := p_dim_level_value_tbl(3).dimension_level_value_id;
  l_Param_Set_Rec.PARAMETER4_VALUE
    := p_dim_level_value_tbl(4).dimension_level_value_id;
  l_Param_Set_Rec.PARAMETER5_VALUE
    := p_dim_level_value_tbl(5).dimension_level_value_id;
  l_Param_Set_Rec.PARAMETER6_VALUE
    := p_dim_level_value_tbl(6).dimension_level_value_id;
  l_Param_Set_Rec.PARAMETER7_VALUE
    := p_dim_level_value_tbl(7).dimension_level_value_id;

  x_Param_Set_Rec := l_Param_Set_Rec;

END Form_Param_Set_Rec;

--
-- Function which will return a boolean varible, if parameter set exist
-- and will also return the notifiers_code
--
FUNCTION  Parameter_set_exist
( p_api_version      IN  NUMBER
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_notifiers_code   OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) return boolean
IS

  l_Param_Set_tbl BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_p_exist boolean;
  l_error_tbl  BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

   Retrieve_Parameter_set
   ( p_api_version             => p_api_version
   , p_Param_Set_Rec           => p_param_set_rec
   , x_Param_Set_Tbl           => l_Param_Set_Tbl
   , x_return_status           => x_return_status
   , x_error_Tbl               => x_error_Tbl
   );
   IF l_Param_Set_Tbl.COUNT >= 1 THEN
    l_p_exist := TRUE;
   ELSE
    l_p_exist := FALSE;
   END IF;

   return l_p_exist;

EXCEPTION
  when FND_API.G_EXC_ERROR then
    x_return_status := FND_API.G_RET_STS_ERROR ;
    x_return_status := ' exception 1 at Parameter_set_exist '||sqlerrm;
    return FALSE;
  when FND_API.G_EXC_UNEXPECTED_ERROR then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_return_status := ' exception 2 at Parameter_set_exist '||sqlerrm;
    return FALSE;
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_return_status := ' exception 3 at Parameter_set_exist '||sqlerrm;
    return FALSE;
   	l_error_tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
     ( p_error_msg_id      => SQLCODE
     , p_error_description => SQLERRM
     , p_error_proc_name   => G_PKG_NAME||'.Parameter_set_exist'
     , p_error_table       => l_error_tbl
     , x_error_table       => x_error_tbl
     );

END Parameter_set_exist;

--
-- Validates target record
--
PROCEDURE Validate_Parameter_set
( p_api_version      IN  NUMBER
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Param_Set_Rec    IN  BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_return_status      VARCHAR2(10);
l_error_Tbl          BIS_UTILITIES_PUB.Error_Tbl_Type;
l_target_rec         BIS_TARGET_PUB.Target_Rec_Type;
l_target_level_rec   BIS_TARGET_LEVEL_PUB.Target_level_Rec_Type;
l_measure_rec        BIS_MEASURE_PUB.measure_rec_type;
--
l_bisbv_target_levels BIS_TARGET_LEVEL_PUB.Target_level_Rec_Type;
l_Dim_Level_Value_Rec BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_measure_rec_p         BIS_MEASURE_PUB.measure_rec_type;
l_Dim_Level_Value_Rec_p BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Rec_Type;
l_error_Tbl_p           BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_measure_rec.measure_id := p_param_Set_Rec.performance_measure_id;

  -- Calling the retrieve_measure to validate the measure_id

  BEGIN
		 l_measure_rec_p := l_measure_rec;
     BIS_MEASURE_PUB.Retrieve_Measure
     ( p_api_version   => p_api_version
     , p_measure_rec   => l_measure_rec_p
     , p_all_info      => FND_API.G_FALSE
     , x_Measure_rec   => l_measure_rec
     , x_return_status => l_return_status
     , x_error_Tbl     => x_error_tbl
     );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
    RAISE;
  END;

  --
  -- Calling the retrieve_target_level to validate the target_level_id
  -- and the out NOCOPY rec is used for validating the dimension level values

  l_target_rec.Target_Level_ID  := p_param_Set_Rec.target_level_id;
  l_target_rec.Plan_ID          := p_param_Set_Rec.Plan_id;
  l_target_level_rec.Target_Level_ID  := p_param_Set_Rec.target_level_id;

  IF p_param_Set_Rec.Plan_id IS NOT NULL THEN
    BEGIN
      BIS_TARGET_VALIDATE_PVT.Validate_Plan_ID
      ( p_api_version     => p_api_version
      , p_Target_Rec      => l_Target_Rec
      , x_return_status   => l_return_status
      , x_error_Tbl       => l_error_Tbl
      );
    --
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status:= FND_API.G_RET_STS_ERROR;
      	l_error_tbl_p := x_error_Tbl;
        BIS_UTILITIES_PVT.concatenateErrorTables
        ( p_error_Tbl1 => l_error_Tbl_p
        , p_error_Tbl2 => l_error_Tbl
        , x_error_Tbl  => x_error_Tbl
        );
      RAISE;
    END;
  END IF;

  IF p_param_Set_Rec.target_level_id IS NOT NULL THEN
    BEGIN
      BIS_Target_Level_PUB.Retrieve_Target_Level
      ( p_api_version      => p_api_version
      , p_Target_Level_Rec => l_target_level_rec
      , p_all_info         => FND_API.G_FALSE
      , x_Target_Level_Rec => l_bisbv_target_levels
      , x_return_status    => l_return_status
      , x_error_Tbl       => x_error_Tbl
      );
      --
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status:= FND_API.G_RET_STS_ERROR;
      RAISE;
    END;
    --


  BEGIN
    IF(l_bisbv_target_levels.ORG_LEVEL_ID IS NOT NULL) THEN
      l_Dim_Level_Value_Rec.Dimension_Level_ID
                      := l_bisbv_target_levels.ORG_LEVEL_ID;

      l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
                      := p_Param_Set_Rec.parameter1_value;
      --
      l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
			BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
      ( p_api_version         => p_api_version
      , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
      , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
      , x_return_status       => l_return_status
      , x_error_Tbl           => l_error_Tbl
      );
    END IF;
  --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
     	l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    RAISE;
  END;
  --
  BEGIN
    IF(l_bisbv_target_levels.TIME_LEVEL_ID IS NOT NULL) THEN
      l_Dim_Level_Value_Rec.Dimension_Level_ID
                  := l_bisbv_target_levels.TIME_LEVEL_ID;
      l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
                  := p_Param_Set_Rec.parameter2_value;

      --
      l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
      ( p_api_version         => p_api_version
      , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
      , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
      , x_return_status       => l_return_status
      , x_error_Tbl           => l_error_Tbl
      );
    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
     	l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    RAISE;
  END;
  --
  BEGIN
    IF(l_bisbv_target_levels.DIMENSION1_LEVEL_ID IS NOT NULL) THEN

      l_Dim_Level_Value_Rec.Dimension_Level_ID
                := l_bisbv_target_levels.DIMENSION1_LEVEL_ID;

      l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
                := p_Param_Set_Rec.parameter3_value;
      --
      l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
      ( p_api_version         => p_api_version
      , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
      , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
      , x_return_status       => l_return_status
      , x_error_Tbl           => l_error_Tbl
      );
    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
     	l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    RAISE;
  END;
  --
  BEGIN
    IF(l_bisbv_target_levels.DIMENSION2_LEVEL_ID IS NOT NULL) THEN

      l_Dim_Level_Value_Rec.Dimension_Level_ID
                       := l_bisbv_target_levels.DIMENSION2_LEVEL_ID;

      l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
                       := p_Param_Set_Rec.parameter4_value;

      --
      l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
      ( p_api_version         => p_api_version
      , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
      , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
      , x_return_status       => l_return_status
      , x_error_Tbl           => l_error_Tbl
      );
    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
     	l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    RAISE;
  END;
  --
  BEGIN
    IF(l_bisbv_target_levels.DIMENSION3_LEVEL_ID IS NOT NULL) THEN

      l_Dim_Level_Value_Rec.Dimension_Level_ID
                   := l_bisbv_target_levels.DIMENSION3_LEVEL_ID;

      l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
                   := p_Param_Set_Rec.parameter5_value;
      --
      l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
      ( p_api_version         => p_api_version
      , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
      , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
      , x_return_status       => l_return_status
      , x_error_Tbl           => l_error_Tbl
      );

    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
     	l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    RAISE;
  END;
  --
  BEGIN
    IF(l_bisbv_target_levels.DIMENSION4_LEVEL_ID IS NOT NULL) THEN

      l_Dim_Level_Value_Rec.Dimension_Level_ID
        := l_bisbv_target_levels.DIMENSION4_LEVEL_ID;

      l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
        := p_Param_Set_Rec.parameter6_value;

      --
      l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
      ( p_api_version         => p_api_version
      , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
      , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
      , x_return_status       => l_return_status
      , x_error_Tbl           => l_error_Tbl
      );

    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
     	l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    RAISE;
  END;
  --
  BEGIN
    IF(l_bisbv_target_levels.DIMENSION5_LEVEL_ID IS NOT NULL) THEN

      l_Dim_Level_Value_Rec.Dimension_Level_ID
               := l_bisbv_target_levels.DIMENSION5_LEVEL_ID;

      l_Dim_Level_Value_Rec.Dimension_Level_Value_ID
               := p_Param_Set_Rec.parameter7_value;

      --
      l_Dim_Level_Value_Rec_p := l_Dim_Level_Value_Rec;
      BIS_DIM_LEVEL_VALUE_PVT.DimensionX_ID_to_Value
      ( p_api_version         => p_api_version
      , p_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec_p
      , x_Dim_Level_Value_Rec => l_Dim_Level_Value_Rec
      , x_return_status       => l_return_status
      , x_error_Tbl           => l_error_Tbl
      );
    END IF;
    --
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
     	l_error_tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables
      ( p_error_Tbl1 => l_error_Tbl_p
      , p_error_Tbl2 => l_error_Tbl
      , x_error_Tbl  => x_error_Tbl
      );
    RAISE;
  END;

  end if;
  --
  x_return_status := l_return_status;

  --
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   	l_error_tbl_p := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl_p
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Parameter_Set;
--

PROCEDURE BuildAlertRegistrationURL
( p_measure_id                 IN   NUMBER
, p_target_level_id            IN   NUMBER   := NULL
, p_plan_id		       IN   VARCHAR2 := NULL
, p_parameter1levelId	       IN   NUMBER   := NULL
, p_parameter1ValueId	       IN   VARCHAR2 := NULL
, p_parameter2levelId	       IN   NUMBER   := NULL
, p_parameter2ValueId	       IN   VARCHAR2 := NULL
, p_parameter3levelId          IN   NUMBER   := NULL
, p_parameter3ValueId          IN   VARCHAR2 := NULL
, p_parameter4levelId          IN   NUMBER   := NULL
, p_parameter4ValueId          IN   VARCHAR2 := NULL
, p_parameter5levelId          IN   NUMBER   := NULL
, p_parameter5ValueId          IN   VARCHAR2 := NULL
, p_parameter6levelId          IN   NUMBER   := NULL
, p_parameter6ValueId          IN   VARCHAR2 := NULL
, p_parameter7levelId          IN   NUMBER   := NULL
, p_parameter7ValueId          IN   VARCHAR2 := NULL
, p_viewByLevelId              IN   VARCHAR2 := NULL
, p_alertTip                   IN   VARCHAR2 := NULL
, p_returnPageUrl              IN   VARCHAR2 := NULL
, x_alert_url                  OUT NOCOPY  VARCHAR2
)
IS
  l_alert_url            VARCHAR2(32000);
  l_dbc			 VARCHAR2(10000);
  l_servlet_agent	 VARCHAR2(10000);
  l_encrypted_session_id VARCHAR2(1000);
  l_session_id		 NUMBER;

BEGIN

  l_session_id := icx_sec.getsessioncookie;
  l_encrypted_session_id
    := icx_call.encrypt3(icx_sec.getID(icx_Sec.PV_SESSION_ID));
  fnd_profile.get(name=>'APPS_SERVLET_AGENT',
  	            val => l_alert_url);
  l_alert_url := FND_WEB_CONFIG.trail_slash(l_alert_url) ||
  		   'bisalrpt.jsp?dbc=' || FND_WEB_CONFIG.DATABASE_ID
  	           || G_AMPERSAND ||'sessionid='|| l_encrypted_session_id;

  IF (p_measure_id IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'perfMeasureId='
  -- 2280993 starts
--  		      || wfa_html.conv_special_url_chars(p_measure_id);
  		      || BIS_UTILITIES_PUB.encode(p_measure_id);
  -- 2280993 ends
  END IF;
  IF (p_plan_id IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'planId='
  -- 2280993 starts
--  		      || wfa_html.conv_special_url_chars(p_plan_id);
  		      || BIS_UTILITIES_PUB.encode(p_plan_id);
  -- 2280993 ends
  END IF;
  IF (p_target_level_id IS NOT NULL) THEN
     l_Alert_url := l_alert_url || G_AMPERSAND || 'targetLevelId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_target_level_id);
  		      ||BIS_UTILITIES_PUB.encode(p_target_level_id);
  -- 2280993 ends
  END IF;
  IF (p_parameter1levelId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter1LevelId='
  -- 2280993 starts
--  	              ||wfa_html.conv_special_url_chars(p_parameter1levelId);
  	              ||BIS_UTILITIES_PUB.encode(p_parameter1levelId);
  -- 2280993 ends
  END IF;
  IF (p_parameter1ValueId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter1ValueId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_parameter1ValueId);
  		      ||BIS_UTILITIES_PUB.encode(p_parameter1ValueId);
  -- 2280993 ends
  END IF;
  IF (p_parameter2levelId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter2LevelId='
  -- 2280993 starts
--  	              ||wfa_html.conv_special_url_chars(p_parameter2levelId);
  	              ||BIS_UTILITIES_PUB.encode(p_parameter2levelId);
  -- 2280993 ends
  END IF;
  IF (p_parameter2ValueId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter2ValueId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_parameter2ValueId);
  		      ||BIS_UTILITIES_PUB.encode(p_parameter2ValueId);
  -- 2280993 ends
  END IF;
  IF (p_parameter3levelId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter3LevelId='
  -- 2280993 starts
--  	              ||wfa_html.conv_special_url_chars(p_parameter3levelId);
  	              ||BIS_UTILITIES_PUB.encode(p_parameter3levelId);
  -- 2280993 ends
  END IF;
  IF (p_parameter3ValueId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter3ValueId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_parameter3ValueId);
  		      ||BIS_UTILITIES_PUB.encode(p_parameter3ValueId);
  -- 2280993 ends
  END IF;
  IF (p_parameter4levelId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter4LevelId='
  -- 2280993 starts
--  	              ||wfa_html.conv_special_url_chars(p_parameter4levelId);
  	              ||BIS_UTILITIES_PUB.encode(p_parameter4levelId);
  -- 2280993 ends
  END IF;
  IF (p_parameter4ValueId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter4ValueId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_parameter4ValueId);
  		      ||BIS_UTILITIES_PUB.encode(p_parameter4ValueId);
  -- 2280993 ends
  END IF;
  IF (p_parameter5levelId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter5LevelId='
  -- 2280993 starts
--  	              ||wfa_html.conv_special_url_chars(p_parameter5levelId);
  	              ||BIS_UTILITIES_PUB.encode(p_parameter5levelId);
  -- 2280993 ends
  END IF;
  IF (p_parameter5ValueId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter5ValueId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_parameter5ValueId);
  		      ||BIS_UTILITIES_PUB.encode(p_parameter5ValueId);
  -- 2280993 ends
  END IF;
  IF (p_parameter6levelId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter6LevelId='
  -- 2280993 starts
--  	              ||wfa_html.conv_special_url_chars(p_parameter6levelId);
  	              ||BIS_UTILITIES_PUB.encode(p_parameter6levelId);
  -- 2280993 ends
  END IF;
  IF (p_parameter6ValueId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter6ValueId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_parameter6ValueId);
  		      ||BIS_UTILITIES_PUB.encode(p_parameter6ValueId);
  -- 2280993 ends
  END IF;
  IF (p_parameter7levelId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter7LevelId='
  -- 2280993 starts
--  	              ||wfa_html.conv_special_url_chars(p_parameter7levelId);
  	              ||BIS_UTILITIES_PUB.encode(p_parameter7levelId);
  -- 2280993 ends
  END IF;
  IF (p_parameter7ValueId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'parameter7ValueId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_parameter7ValueId);
  		      ||BIS_UTILITIES_PUB.encode(p_parameter7ValueId);
  -- 2280993 ends
  END IF;
  IF (p_viewByLevelId IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND || 'viewByLevelId='
  -- 2280993 starts
--  		      ||wfa_html.conv_special_url_chars(p_viewByLevelId);
  		      ||BIS_UTILITIES_PUB.encode(p_viewByLevelId);
  -- 2280993 ends
  END IF;

  BIS_UTILITIES_PUB.put_line(p_text =>'alert url built');
  x_alert_url := l_alert_url;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Error in BuildAlertRegistrationURL: '||SQLERRM);

END BuildAlertRegistrationURL;

PROCEDURE BuildAlertRegistrationURL
( p_measure_id	       IN   NUMBER
, p_timelevel_id       IN   NUMBER
, p_viewByLevelId      IN   VARCHAR2 := NULL
, p_alertTip           IN   VARCHAR2 := NULL
, p_returnPageUrl      IN   VARCHAR2 := NULL
, x_alert_url          OUT NOCOPY  VARCHAR2
)
IS

  l_alert_url 		       VARCHAR2(32000);
  l_dbc                        VARCHAR2(10000);
  l_servlet_agent              VARCHAR2(10000);
  l_encrypted_session_id       VARCHAR2(1000);
  l_session_id                 NUMBER;

BEGIN

  l_session_id := icx_sec.getsessioncookie;
  l_encrypted_session_id :=
                       icx_call.encrypt3(icx_sec.getID(icx_Sec.PV_SESSION_ID));
  fnd_profile.get(name => 'APPS_SERVLET_AGENT',
                  val  => l_Alert_url);
  l_alert_url := FND_WEB_CONFIG.trail_slash(l_alert_url) ||
                 'bisalrsc.jsp?dbc=' ||FND_WEB_CONFIG.DATABASE_ID
                || G_AMPERSAND||'session_id='||l_encrypted_session_id;
  IF (p_measure_id IS NOT NULL) THEN
     l_alert_url := l_alert_url || G_AMPERSAND ||'perfMeasureId='
  -- 2280993 starts
--                    ||wfa_html.conv_special_url_chars(p_measure_id);
                    ||BIS_UTILITIES_PUB.encode(p_measure_id);
  -- 2280993 ends
  END IF;
  IF (p_timelevel_id IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND||'timeDimLevelId='
  -- 2280993 starts
--                   || wfa_html.conv_special_url_chars(p_timelevel_id);
                   || BIS_UTILITIES_PUB.encode(p_timelevel_id);
  -- 2280993 ends
  END IF;
  IF (p_viewByLevelId IS NOT NULL) THEN
    l_alert_url := l_alert_url || G_AMPERSAND || 'viewByLevelId='
  -- 2280993 starts
--   	           ||wfa_html.conv_special_url_chars(p_viewByLevelId);
   	           ||BIS_UTILITIES_PUB.encode(p_viewByLevelId);
  -- 2280993 ends
  END IF;

  x_alert_url := l_alert_url;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Error in BuildAlertRegistrationURL: '||SQLERRM);

END BuildAlertRegistrationURL;

PROCEDURE BuildScheduleReportURL
( p_RegionCode                 IN   VARCHAR2
, p_FunctionName               IN   VARCHAR2
, p_ApplicationId              IN   VARCHAR2 := NULL
, p_plan_id		       IN   VARCHAR2 := NULL
, p_parameter1levelId	       IN   NUMBER   := NULL
, p_parameter1ValueId	       IN   VARCHAR2 := NULL
, p_parameter2levelId	       IN   NUMBER   := NULL
, p_parameter2ValueId	       IN   VARCHAR2 := NULL
, p_parameter3levelId          IN   NUMBER   := NULL
, p_parameter3ValueId          IN   VARCHAR2 := NULL
, p_parameter4levelId          IN   NUMBER   := NULL
, p_parameter4ValueId          IN   VARCHAR2 := NULL
, p_parameter5levelId          IN   NUMBER   := NULL
, p_parameter5ValueId          IN   VARCHAR2 := NULL
, p_parameter6levelId          IN   NUMBER   := NULL
, p_parameter6ValueId          IN   VARCHAR2 := NULL
, p_parameter7levelId          IN   NUMBER   := NULL
, p_parameter7ValueId          IN   VARCHAR2 := NULL
, p_viewByLevelId              IN   VARCHAR2 := NULL
, p_alertTip                   IN   VARCHAR2 := NULL
, p_returnPageUrl              IN   VARCHAR2 := NULL
, x_alert_url                  OUT NOCOPY  VARCHAR2
)
IS

BEGIN

Null;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Error in BuildScheduleReportURL: '||SQLERRM);

END BuildScheduleReportURL;

PROCEDURE Add_Users_To_Role
(  p_role_name      IN    VARCHAR2
,  p_user_names     IN    VARCHAR2
)

IS
  c1            PLS_INTEGER;
  l_user_names  VARCHAR2(32000);

BEGIN
  IF (p_role_name IS NOT NULL) THEN
    IF (p_user_names IS NOT NULL) THEN
      l_user_names := TRIM(',' FROM TRIM(p_user_names));
      <<UserLoop>>
      LOOP
        c1 := INSTR(l_user_names, ',');
        BEGIN
          IF (c1 = 0) THEN
            WF_LOCAL_SYNCH.propagateUserRole(P_ROLE_NAME => p_role_name, P_USER_NAME => l_user_names) ;
            EXIT;
          ELSE
            WF_LOCAL_SYNCH.propagateUserRole(P_ROLE_NAME => p_role_name, P_USER_NAME => substr(l_user_names, 1, c1-1) ) ;
          END IF;
          l_user_names := ltrim(substr(l_user_names, c1+1));
        EXCEPTION
          WHEN OTHERS THEN
            BIS_UTILITIES_PUB.put_line(p_text =>'Error in Add_Users_To_Role: '||SQLERRM);
            IF (c1 = 0) THEN
              EXIT;
            ELSE
              l_user_names := ltrim(substr(l_user_names, c1+1));
            END IF;
        END;
      END LOOP UserLoop;
    END IF;
  END IF;
END Add_Users_To_Role;

END  BIS_PMF_ALERT_REG_PVT;

/
