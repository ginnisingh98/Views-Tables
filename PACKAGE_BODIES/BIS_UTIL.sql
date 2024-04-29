--------------------------------------------------------
--  DDL for Package Body BIS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_UTIL" as
/* $Header: BISUTILB.pls 120.32 2007/12/27 13:36:24 lbodired ship $ */

--/////////////////Added for Simulation Enhancement /////////////////

FUNCTION Is_Simulation_Report
(
  p_region_code     IN ak_regions.region_code%TYPE
)RETURN VARCHAR2 IS
 l_sim_flag       VARCHAR2(10);
 l_config_type    bsc_kpis_b.config_type%TYPE;

BEGIN

  l_sim_flag := FND_API.G_FALSE;
  IF(p_region_code IS NOT NULL) THEN
   SELECT config_type
   INTO   l_config_type
   FROM   bsc_kpis_b
   WHERE  short_name =p_region_code;

   IF(l_config_type = 7) THEN
     l_sim_flag := FND_API.G_TRUE;
   END IF;
  END IF;

  RETURN l_sim_flag;

EXCEPTION
 WHEN OTHERS THEN
 RETURN FND_API.G_FALSE;
END Is_Simulation_Report;



FUNCTION get_menu_resp_id(
  p_sub_menu_id  IN  NUMBER
, p_user_id      IN  NUMBER
, p_count        IN  NUMBER
)
RETURN NUMBER;

FUNCTION get_sec_grp_id_for_resp_role (
  p_role_resp  IN VARCHAR2
)
RETURN NUMBER;

FUNCTION get_sec_grp_id_for_user_role (
  p_resp_id   IN NUMBER
, p_user_id   IN NUMBER
)
RETURN NUMBER;

Procedure Validate_Short_Name (
   p_short_name     IN  VARCHAR2
  ,x_return_status  OUT NOCOPY  Varchar2
  ,x_msg_count          OUT NOCOPY  NUMBER
  ,x_msg_data           OUT NOCOPY     Varchar2 )
IS
  x_string  VARCHAR2(30);
  x_char    VARCHAR2(1);
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_short_name IS NULL THEN
    RETURN;
  END IF;

    -- user entered short_name, use appropriate length check
    IF length(p_short_name) > BIS_UTIL.G_SHORT_NAME_LEN THEN
       FND_MESSAGE.Set_Name('BIS','BIS_SHORT_NAME_LEN');
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  -- character checking
  --
  x_string := p_short_name;
  FOR i IN 1..length(x_string) LOOP
    x_char := SUBSTR(x_string, i, 1);
    IF (i=1) THEN
      -- first character should be an alphabet
      IF (INSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ', x_char) < 1) THEN
       FND_MESSAGE.Set_Name('BIS','BIS_SHORT_NAME_INVALID_CHAR');
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSE
      -- check all other characters
      IF (INSTR('ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_$#', x_char) < 1) THEN
       FND_MESSAGE.Set_Name('BIS','BIS_SHORT_NAME_INVALID_CHAR');
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
  END LOOP;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_Short_Name'
            );

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Validate_Short_Name;

--
-- For 11.5.1 Corrective actions with BIS Reports
--

/* Should really make wf attributes more flexible */

Procedure Start_Workflow
(p_exception_message     IN Varchar2
,p_msg_subject           IN Varchar2
,p_exception_date        IN date
,p_item_type             IN Varchar2
,p_wf_process            IN Varchar2
,p_notify_resp_name      IN Varchar2
,p_BIS_Report_Tbl        IN BIS_UTIL.BIS_Report_Tbl_Type
,p_BIS_Cached_Report_Tbl IN BIS_UTIL.BIS_Cached_Report_Tbl_Type
,x_return_status         OUT NOCOPY Varchar2
)
IS
l_live_url_tbl    BIS_UTIL.Report_URL_Tbl_Type;
l_cached_url_tbl  BIS_UTIL.Report_URL_Tbl_Type;
l_count    NUMBER := 0;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN 1..p_BIS_Report_Tbl.Count LOOP

    BIS_UTIL.Build_Report_URL
    ( p_report_type      => p_BIS_Report_Tbl(i).Report_Type
    , p_reportFn_name    => p_BIS_Report_Tbl(i).reportFN_Name
    , p_region_code      => p_BIS_Report_Tbl(i).region_code
    , p_report_resp_id   => p_BIS_Report_Tbl(i).report_resp_id
    , p_report_params    => p_BIS_Report_Tbl(i).report_params
    , x_report_url       => l_live_url_tbl(i)
    , x_return_status    => x_return_status
    );

  END LOOP;


  FOR i IN 1..p_BIS_Cached_Report_Tbl.Count LOOP

    BIS_UTIL.Build_Report_URL
    ( p_report_type       => p_BIS_Cached_Report_Tbl(i).Report_Type
    , p_report_identifier => p_BIS_Cached_Report_Tbl(i).report_identifier
    , x_report_url        => l_cached_url_tbl(i)
    , x_return_status     => x_return_status
    );
  END LOOP;


  BIS_UTIL.Start_Workflow_Engine
  ( p_exception_message => p_exception_message
  , p_msg_subject       => p_msg_subject
  , p_exception_date    => p_exception_date
  , p_item_type         => p_item_type
  , p_wf_process        => p_wf_process
  , p_notify_resp_name  => p_notify_resp_name
  , p_live_report_url_tbl   => l_live_url_tbl
  , p_cached_report_url_tbl => l_cached_url_tbl
  , x_return_status     => x_return_status
  );


EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Start_Workflow;

-- For 11.5.1 Corrective actions with Oracle Reports
--
Procedure Start_Workflow
(p_exception_message IN Varchar2
,p_msg_subject       IN Varchar2
,p_exception_date    IN date
,p_item_type         IN Varchar2
,p_wf_process        IN Varchar2
,p_notify_resp_name  IN Varchar2
,p_Oracle_Report_Tbl IN BIS_UTIL.Oracle_Report_Tbl_Type
,x_return_status    OUT NOCOPY      Varchar2
)
IS
l_url_tbl  BIS_UTIL.Report_URL_Tbl_Type;

BEGIN

  FOR i IN 1..p_Oracle_Report_Tbl.Count LOOP
    BIS_UTIL.Build_Report_URL
    ( p_report_type      => p_Oracle_Report_Tbl(i).Report_Type
    , p_report_name      => p_Oracle_Report_Tbl(i).report_name
    , p_report_params    => p_Oracle_Report_Tbl(i).report_params
    , p_report_resp_id   => p_Oracle_Report_Tbl(i).report_resp_id
    , x_report_url       => l_url_tbl(i)
    , x_return_status    => x_return_status
    );
  END LOOP;

  BIS_UTIL.Start_Workflow_Engine
  ( p_exception_message => p_exception_message
  , p_msg_subject       => p_msg_subject
  , p_exception_date    => p_exception_date
  , p_item_type         => p_item_type
  , p_wf_process        => p_wf_process
  , p_notify_resp_name  => p_notify_resp_name
  , p_live_report_url_tbl  => l_url_tbl
  , x_return_status     => x_return_status
  );

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Start_Workflow;

-- For 11.5 Corrective actions with Oracle Reports
-- Added resp_application_id for bug#3756093
-- Added new parameters at last to support old code calling this
-- API by numbers
Procedure Strt_Wf_Process
   (p_exception_message Varchar2
   ,p_msg_subject       Varchar2
   ,p_exception_date    date
   ,p_item_type         Varchar2
   ,p_wf_process        Varchar2
   ,p_notify_resp_name  Varchar2
   ,p_report_name1      Varchar2 default null
   ,p_report_param1     Varchar2 default null
   ,p_report_resp1_id   number   default null
   ,p_report_name2      Varchar2 default null
   ,p_report_param2     Varchar2 default null
   ,p_report_resp2_id   number   default null
   ,p_report_name3      Varchar2 default null
   ,p_report_param3     Varchar2 default null
   ,p_report_resp3_id   number   default null
   ,p_report_name4      Varchar2 default null
   ,p_report_param4     Varchar2 default null
   ,p_report_resp4_id   number   default null
   ,x_return_status OUT NOCOPY      Varchar2
   ,p_report_app1_id    NUMBER default null
   ,p_report_app2_id    NUMBER default null
   ,p_report_app3_id    NUMBER default null
   ,p_report_app4_id    NUMBER default null
)
IS
  l_url_tbl  BIS_UTIL.Report_URL_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- 11.5 only excepted up to 4 report URLs
  --
  BIS_UTIL.Build_Report_URL
  ( p_report_type      => BIS_UTIL.G_ORACLE_REPORT_TYPE
  , p_report_name      => p_report_name1
  , p_report_params    => p_report_param1
  , p_report_resp_id   => p_report_resp1_id
  , p_report_app_id    => p_report_app1_id
  , x_report_url       => l_url_tbl(1)
  , x_return_status    => x_return_status
  );
  BIS_UTIL.Build_Report_URL
  ( p_report_type      => BIS_UTIL.G_ORACLE_REPORT_TYPE
  , p_report_name      => p_report_name2
  , p_report_params    => p_report_param2
  , p_report_resp_id   => p_report_resp2_id
  , p_report_app_id    => p_report_app2_id
  , x_report_url       => l_url_tbl(2)
  , x_return_status    => x_return_status
  );
  BIS_UTIL.Build_Report_URL
  ( p_report_type      => BIS_UTIL.G_ORACLE_REPORT_TYPE
  , p_report_name      => p_report_name3
  , p_report_params    => p_report_param3
  , p_report_resp_id   => p_report_resp3_id
  , p_report_app_id    => p_report_app3_id
  , x_report_url       => l_url_tbl(3)
  , x_return_status    => x_return_status
  );
  BIS_UTIL.Build_Report_URL
  ( p_report_type      => BIS_UTIL.G_ORACLE_REPORT_TYPE
  , p_report_name      => p_report_name4
  , p_report_params    => p_report_param4
  , p_report_resp_id   => p_report_resp4_id
  , p_report_app_id    => p_report_app4_id
  , x_report_url       => l_url_tbl(4)
  , x_return_status    => x_return_status
  );

  BIS_UTIL.Start_Workflow_Engine
  ( p_exception_message => p_exception_message
  , p_msg_subject       => p_msg_subject
  , p_exception_date    => p_exception_date
  , p_item_type         => p_item_type
  , p_wf_process        => p_wf_process
  , p_notify_resp_name  => p_notify_resp_name
  , p_live_report_url_tbl    => l_url_tbl
  , x_return_status     => x_return_status
  );

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Strt_WF_Process;


-- 1.2.x corrective actions
-- Added resp_application_id for bug#3756093
-- Added new parameter at last to support old code calling this
-- API by numbers
Procedure Strt_Wf_Process
   (p_exception_message Varchar2
   ,p_msg_subject       Varchar2
   ,p_exception_date    date
   ,p_wf_process        Varchar2
   ,p_report_name1      Varchar2 default null
   ,p_report_param1     Varchar2 default null
   ,p_report_name2      Varchar2 default null
   ,p_report_param2     Varchar2 default null
   ,p_report_name3      Varchar2 default null
   ,p_report_param3     Varchar2 default null
   ,p_report_name4      Varchar2 default null
   ,p_report_param4     Varchar2 default null
   ,p_role          Varchar2
   ,p_responsibility_id number
   ,x_return_status     OUT NOCOPY Varchar2
   ,p_application_id    NUMBER default null)
IS
l_item_type  Varchar2(30) := 'BISKPIWF';

Begin
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Strt_Wf_Process
   (p_exception_message => p_exception_message
   ,p_msg_subject       => p_msg_subject
   ,p_exception_date    => p_exception_date
   ,p_item_type         => l_item_type
   ,p_wf_process        => p_wf_process
   ,p_notify_resp_name  => p_role
   ,p_report_name1      => p_report_name1
   ,p_report_param1     => p_report_param1
   ,p_report_resp1_id   => p_responsibility_id
   ,p_report_app1_id    => p_application_id
   ,p_report_name2      => p_report_name2
   ,p_report_param2     => p_report_param2
   ,p_report_resp2_id   => p_responsibility_id
   ,p_report_app2_id    => p_application_id
   ,p_report_name3      => p_report_name3
   ,p_report_param3     => p_report_param3
   ,p_report_resp3_id   => p_responsibility_id
   ,p_report_app3_id    => p_application_id
   ,p_report_name4      => p_report_name4
   ,p_report_param4     => p_report_param4
   ,p_report_resp4_id   => p_responsibility_id
   ,p_report_app4_id    => p_application_id
   ,x_return_status     => x_return_status
   );

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END strt_wf_process;

PROCEDURE Get_Time_Level_Value
( p_Date               IN DATE default SYSDATE
, p_Target_Level_ID    IN NUMBER
, p_Organization_ID    IN NUMBER
, x_Time_Level_Value   OUT NOCOPY VARCHAR2
, x_Return_Status      OUT NOCOPY VARCHAR2
)
IS

BEGIN

  BIS_UTIL.Get_Time_Level_Value
  ( p_Date               => p_Date
  , p_Target_Level_ID    => p_Target_Level_id
  , p_Organization_ID    => TO_CHAR(p_Organization_ID)
  , x_Time_Level_Value   => x_Time_Level_value
  , x_Return_Status      => x_return_status
  );

EXCEPTION

  WHEN OTHERS THEN
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Time_Level_Value;


PROCEDURE Get_Time_Level_Value
( p_Date               IN DATE default SYSDATE
, p_Target_Level_ID    IN NUMBER
, p_Organization_ID    IN VARCHAR2
, x_Time_Level_Value   OUT NOCOPY VARCHAR2
, x_Return_Status      OUT NOCOPY VARCHAR2
)
IS
l_period_set_name    VARCHAR2(100) := NULL;
l_period_name        VARCHAR2(100) := NULL;
l_id                 VARCHAR2(2500) := NULL;
l_view_name          VARCHAR2(300);
l_time_level         VARCHAR2(300);
l_org_level          VARCHAR2(300);
l_select_stmt        VARCHAR2(32000);
l_cursor             INTEGER;
l_dummy              INTEGER;
l_num_rows           INTEGER;
l_Is_OrgRel          BOOLEAN;

BEGIN
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  SELECT lt.short_name
       , lo.short_name
       , lt.LEVEL_VALUES_VIEW_NAME
  INTO l_time_level
     , l_org_level
     , l_view_name
  FROM BIS_LEVELS lt
     , BIS_LEVELS lo
     , BIS_TARGET_LEVELS tl
  WHERE tl.Target_level_id = p_Target_Level_id
  AND lt.Level_ID = tl.Time_Level_id
  AND lo.Level_ID = tl.org_Level_id;

  l_cursor := DBMS_SQL.OPEN_CURSOR;

  -- the select statement depends on if the period_name is related to
  -- the organization's set of books.  If the organization is -1 (total_org)
  -- then the default calendar is used.
  --

  IF l_time_level <> 'TOTAL_TIME' THEN
    IF (BIS_UTILITIES_PUB.is_time_dependent_on_org(p_time_lvl_short_name => l_time_level)
    = BIS_UTILITIES_PUB.G_TIME_IS_DEPEN_ON_ORG) THEN --2684911
        l_Is_OrgRel := TRUE;
        l_select_stmt := ' SELECT PERIOD_SET_NAME, PERIOD_NAME, ID '||' '
                    ||'FROM '||l_view_name||' '
                    ||'WHERE ORGANIZATION_ID = :p_Organization_ID '
                    ||'AND NVL(ORGANIZATION_TYPE, ''%'') LIKE :l_org_level '
                    ||' AND '
                    ||' TO_DATE(TO_CHAR(:p_Date,'||''''||'DD-MM-RR'||''''
                    ||'), '||''''||'DD-MM-RR'||''''||')'
                    ||' BETWEEN '
                    ||' TO_DATE(TO_CHAR(START_DATE,'||''''||'DD-MM-RR'||''''
                    ||'), '||''''||'DD-MM-RR'||''''||') and '
                    ||' TO_DATE(TO_CHAR(END_DATE,'||''''||'DD-MM-RR'||''''
                    ||'), '||''''||'DD-MM-RR'||''''||')';
    ELSE
      l_Is_OrgRel := FALSE;
      l_select_stmt := ' SELECT PERIOD_SET_NAME, PERIOD_NAME, ID '||' '
                    ||'FROM '||l_view_name||' '
                    ||'WHERE :p_Date BETWEEN NVL(START_DATE,:p_Date) '
                    ||'AND NVL(END_DATE,:p_Date) ';

    END IF;

    DBMS_SQL.PARSE
    ( c             => l_cursor
    , statement     => l_select_stmt
    , language_flag => DBMS_SQL.NATIVE
    );

    IF( l_Is_OrgRel) THEN
      DBMS_SQL.BIND_VARIABLE
      ( c           => l_cursor
      , name        => ':p_Organization_ID'
      , value       => p_Organization_ID
      );

      DBMS_SQL.BIND_VARIABLE
      ( c           => l_cursor
      , name        => ':l_org_level'
      , value       => l_org_level
      );

    END IF;

    DBMS_SQL.BIND_VARIABLE
    ( c           => l_cursor
    , name        => ':p_Date'
    , value       => p_date
    );

    DBMS_SQL.DEFINE_COLUMN
    ( c           => l_cursor
    , position    => 1
    , column      => l_period_set_name
    , column_size => 100
    );
    DBMS_SQL.DEFINE_COLUMN
    ( c           => l_cursor
    , position    => 2
    , column      => l_period_name
    , column_size => 100
    );
    DBMS_SQL.DEFINE_COLUMN
    ( c           => l_cursor
    , position    => 3
    , column      => l_id
    , column_size => 2500
    );

    l_num_rows := DBMS_SQL.EXECUTE_AND_FETCH
                  ( c            => l_cursor
                  , exact        => TRUE
                  );

    DBMS_SQL.COLUMN_VALUE
    ( c           => l_cursor
    , position    => 1
    , value       => l_period_set_name
    );
    DBMS_SQL.COLUMN_VALUE
    ( c           => l_cursor
    , position    => 2
    , value       => l_period_name
    );
    DBMS_SQL.COLUMN_VALUE
    ( c           => l_cursor
    , position    => 3
    , value       => l_id
    );

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

  ELSE
    l_id := '-1';

  END IF;

  x_Time_Level_Value := l_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- No such time period exist.
    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    x_Time_Level_Value := NULL;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  WHEN TOO_MANY_ROWS THEN

    -- More than one row, but still get the first record
    DBMS_SQL.COLUMN_VALUE
    ( c           => l_cursor
    , position    => 1
    , value       => l_period_set_name
    );
    DBMS_SQL.COLUMN_VALUE
    ( c           => l_cursor
    , position    => 2
    , value       => l_period_name
    );
    x_Time_Level_Value := l_period_set_name||'+'||l_period_name;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);
    x_Return_Status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_Time_Level_Value;

Procedure Get_EPS
         ( p_change_in_income   in Number
         ,p_change_in_eps       out NOCOPY Number
         ,p_result              out NOCOPY Number
         ,p_exception_msg       OUT NOCOPY Varchar2) IS
l_outstanding_shares  Number;
l_est_tax_rate        Number;
Begin
  p_result := 0;
  p_change_in_eps := null;
  p_exception_msg := null;
  l_outstanding_shares := To_Number(FND_PROFILE.Value(
                               'BIS_EPS_SHARES_IN_ISSUE'));
  l_est_tax_rate := To_Number(FND_PROFILE.Value(
                               'BIS_EPS_EST_TAX_RATE'));
  if nvl(l_outstanding_shares,0) <= 0 then
     FND_Message.Set_Name('BIS','BIS_SHARES_IN_ISSUE_UNDEFINED');
     p_exception_msg := Fnd_Message.Get;
     p_result := 1;
     return;
  end if;
  if l_est_tax_rate  is null then
     p_result := 2;
     FND_Message.Set_Name('BIS','BIS_SHORT_NAME_INVALID_CHAR');
     p_exception_msg := Fnd_Message.Get;
     return;
  end if;
  p_change_in_eps := (p_change_in_income *
                (1-(l_est_tax_rate/100))) / l_outstanding_shares;
  exception when others then
    p_result := 3;
    p_exception_msg := sqlcode || ':' || sqlerrm;
End Get_EPS;

function EPS_PRECISION_FORMAT_MASK(
   CURRENCY_CODE                    IN VARCHAR2,
   FIELD_LENGTH                     IN NUMBER
                                  )
   return VARCHAR2
IS
  return_mask   VARCHAR2(80);
  precision     NUMBER;  /* number of digit to right of decimal */
  ext_precision NUMBER;  /* precision where more precision is needed */
  min_acct_unit NUMBER;  /* minimum value by which amt can vary */
  bis_precision NUMBER;  /* bis precision added to currency precision */
BEGIN

   return_mask := NULL;
   if (field_length > 80) OR (currency_code is NULL) then
      return return_mask;
   end if;
   FND_CURRENCY.get_info(currency_code, precision, ext_precision,
                         min_acct_unit);
   bis_precision := fnd_profile.value('BIS_EPS_PRECISION');
   precision := precision + bis_precision;
   FND_CURRENCY.build_format_mask(return_mask, field_length, precision,
                                  min_acct_unit);
   RETURN return_mask;

END EPS_PRECISION_FORMAT_MASK;

-- To start the workflow engine
--
Procedure Start_Workflow_Engine
(p_exception_message IN Varchar2
,p_msg_subject       IN Varchar2
,p_exception_date    IN date
,p_item_type         IN Varchar2
,p_wf_process        IN Varchar2
,p_notify_resp_name  IN Varchar2
,p_live_report_url_tbl   IN BIS_UTIL.Report_URL_Tbl_Type
   Default G_DEF_Report_URL_Tbl
,p_cached_report_url_tbl IN BIS_UTIL.Report_URL_Tbl_Type
   Default G_DEF_Report_URL_Tbl
,x_return_status     OUT NOCOPY VARCHAR2
)
IS

  l_wf_item_key   NUMBER;
  l_role_name     VARCHAR2(80);

  CURSOR c_role_name IS
    select name from wf_role_lov_vl
    where name = p_notify_resp_name;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Validate item type and process
  --
  IF p_item_type IS NULL
    OR p_wf_process IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Validate wf_role
  --
  OPEN c_role_name;
  FETCH c_role_name INTO l_role_name;
  IF c_role_name%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RETURN;
  END IF;

  SELECT bis_excpt_wf_s.nextval
  INTO l_wf_item_key
  FROM dual;

  -- create a new workflow process
  --
  wf_engine.CreateProcess(itemtype=>p_item_type
                         ,itemkey =>l_wf_item_key
                         ,process =>p_wf_process);

  -- set the workflow attributes
  --
  wf_engine.SetItemAttrDate(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'L_EXCEPTION_DATE'
                ,avalue=>p_exception_date);
  wf_engine.SetItemAttrText(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'L_SUBJECT'
                ,avalue=>P_MSG_SUBJECT);
  wf_engine.SetItemAttrText(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'L_EXCEPTION_MESSAGE'
                ,avalue=>p_EXCEPTION_MESSAGE);
  wf_engine.SetItemAttrText(itemtype=>p_item_type
                ,itemkey =>l_wf_item_key
                ,aname=>'L_ROLE_NAME'
                ,avalue=>L_ROLE_NAME);

  FOR i IN 1..p_live_report_url_tbl.Count LOOP

    -- need to modify to account for dynamic number of urls
    --
    -- Sets url for live report
    --
    IF p_live_report_url_tbl(p_live_report_url_tbl.FIRST) IS NOT NULL THEN

      wf_engine.SetItemAttrText
      ( itemtype  =>p_item_type
      , itemkey   =>l_wf_item_key
      , aname     =>'L_URL'
      , avalue    =>p_live_report_url_tbl(p_live_report_url_tbl.FIRST)
      );

    END IF;

  END LOOP;

  FOR i IN 1..p_cached_report_url_tbl.Count LOOP

    -- need to modify to account for dynamic number of urls
    --

    -- Sets url for cached report
    --
    IF p_cached_report_url_tbl(p_cached_report_url_tbl.FIRST) IS NOT NULL THEN

      wf_engine.SetItemAttrText
      ( itemtype  =>p_item_type
      , itemkey   =>l_wf_item_key
      , aname     =>'L_URL2'
      , avalue    =>p_cached_report_url_tbl(p_cached_report_url_tbl.FIRST)
      );

    END IF;

  END LOOP;

  wf_engine.StartProcess(itemtype=>p_item_type
                        ,itemkey => l_wf_item_key);

  commit;

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Start_Workflow_Engine;


-- For 11.5.1 BIS Reports
--
/*
  Example variables from Product Quality report.

  NAME="pFunctionName" VALUE="BIS_PRODUCT_QUALITY"
  NAME="pRegionCode" VALUE="PRODUCT_QUALITY"
  NAME="pSessionId" VALUE="134880"
  NAME="pUserId" VALUE="3259"
  NAME="pResponsibilityId" VALUE="21524"

  l_bis_report_tbl(1).region_code    :=  'PRODUCT_QUALITY';
  l_bis_report_tbl(1).reportFn_name  :=  'BIS_PRODUCT_QUALITY';
  l_bis_report_tbl(1).report_resp_id := l_resp_id;

  Final URL should look like: ( <amp> = ampersand )
  'http://ap804sun.us.oracle.com:778/dev115/plsql/bisviewer.ShowReport?pRegionCode=PRODUCT_QUALITY<amp>pFunctionName=BIS_PRODUCT_QUALITY<amp>pSessionId=134903<amp>pUserId=11788<amp>pResponsibilityId=21524'
*/

Procedure Build_Report_URL
( p_report_type      IN VARCHAR2 default BIS_UTIL.G_BIS_REPORT_TYPE
, p_reportFn_name    IN Varchar2
, p_region_code      IN Varchar2
, p_report_resp_id   IN VARCHAR2
, p_report_params    IN VARCHAR2
, x_report_url       OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
)
IS
  l_report_url       VARCHAR2(32000);
  l_report_link      VARCHAR2(32000) := NULL;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_report_link  := FND_PROFILE.value('ICX_REPORT_LINK');

  IF p_report_type = BIS_UTIL.G_BIS_REPORT_TYPE THEN

    IF p_report_params IS NOT NULL OR
       p_report_params <> FND_API.G_MISS_CHAR THEN
       l_report_url := l_report_link||
                    'BISVIEWER3.ShowReport?'||
                    'pRegionCode='|| p_region_code ||
                    '&pFunctionName='|| p_reportFN_name ||
                    '&pResponsibilityId='|| p_report_resp_id||
                    '&pParameters='||p_report_params;
    ELSE
       l_report_url := l_report_link||
                    'BISVIEWER3.ShowReport?'||
                    'pRegionCode='|| p_region_code ||
                    '&pFunctionName='|| p_reportFN_name ||
                    '&pResponsibilityId='|| p_report_resp_id;
    END IF;

  END IF;

  x_report_url := l_report_url;

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Build_Report_URL;


-- For 11.5.1 Cached BIS Reports
--
/*
  Report Identifier is the saved report id

  Final URL should look like: ( <amp> = ampersand )
  'http://ap804sun.us.oracle.com:778/dev115/plsql/BIS_CACHING_PVT.Display_Cache?p_identifier=1234567'
*/

Procedure Build_Report_URL
( p_report_type        IN VARCHAR2 default BIS_UTIL.G_BIS_CACHE_REPORT_TYPE
, p_report_identifier  IN VARCHAR2
, x_report_url         OUT NOCOPY VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
)
IS
  l_report_url       VARCHAR2(32000);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_report_type = BIS_UTIL.G_BIS_CACHE_REPORT_TYPE THEN

    l_report_url := 'BIS_CACHING_PVT.Display_Cache?'||
                    'p_identifier='||p_report_identifier;

  END IF;

  x_report_url := l_report_url;

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Build_Report_URL;

-- For 11.5.1 Oracle Reports
-- Added resp_application_id for bug#3756093
-- Added new parameter at last to support old code calling this
-- API by numbers
--
Procedure Build_Report_URL
( p_report_type      IN VARCHAR2 default BIS_UTIL.G_ORACLE_REPORT_TYPE
, p_report_name      IN Varchar2
, p_report_params    IN Varchar2
, p_report_resp_id   IN NUMBER
, x_report_url       OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, p_report_app_id    IN NUMBER DEFAULT NULL
)
IS
  l_report_url       VARCHAR2(32000) := NULL;
  l_report_link      VARCHAR2(32000) := NULL;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_report_link  := FND_PROFILE.value('ICX_REPORT_LINK');

  IF p_report_type = BIS_UTIL.G_ORACLE_REPORT_TYPE
  AND p_report_name IS NOT NULL
  THEN

    IF p_report_params IS NOT NULL OR
       p_report_params <> FND_API.G_MISS_CHAR THEN

       l_report_url := l_report_link
                    ||  'OracleOASIS.RunReport?report='|| p_report_name
                    || '&parameters=' || p_report_params
                    || '&responsibility_id=' || p_report_resp_id;

       IF (BIS_UTILITIES_PVT.Value_Not_Missing_Not_Null(p_report_app_id) = FND_API.G_TRUE) THEN
         l_report_url := l_report_url || '&responsibility_application_id=' || p_report_app_id;
       END IF;

    ELSE

       l_report_url := l_report_link
                    ||  'OracleOASIS.RunReport?report='|| p_report_name
                    || '&responsibility_id=' || p_report_resp_id;

       IF (BIS_UTILITIES_PVT.Value_Not_Missing_Not_Null(p_report_app_id) = FND_API.G_TRUE) THEN
         l_report_url := l_report_url || '&responsibility_application_id=' || p_report_app_id;
       END IF;

    END IF;
  END IF;

  x_report_url := l_report_url;


EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Build_Report_URL;

-- ankgoel: bug#4015335 - Returns 1 for Internal customers who will be shown all
-- the application ids. Returns 0 for External customers.
FUNCTION show_application
( p_application_id  IN NUMBER
, p_created_by  IN  NUMBER
)
RETURN NUMBER
IS
BEGIN
  -- currently we allow external customers to choose ONLY BSC (271) and
  -- customer created application.  If decision is changed later on to use
  -- BIS, the number 271 should be changed to 191, or whatever application
  -- id should be.
  IF(p_application_id = 271 OR BIS_UTIL.is_internal_customer OR BIS_UTIL.is_Seeded(p_created_by,'Y','N') = 'N') THEN
    RETURN 1;
  ELSE
    RETURN 0;
END IF;
END show_application;

FUNCTION show_application
( p_application_id  IN NUMBER
)
RETURN NUMBER
IS
l_created_by Number;
BEGIN
    select created_by into l_created_by
    from fnd_application
    where application_id = p_application_id;

    return show_application(p_application_id, l_created_by);
exception
    when others then return 0;
END show_application;



FUNCTION is_dev_env_set
RETURN BOOLEAN
IS
BEGIN
  IF('Y' = FND_PROFILE.value('BIS_PMF_DEV_ENV')) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END is_dev_env_set;

FUNCTION is_internal_customer
RETURN BOOLEAN
IS
BEGIN
  IF(BIS_UTIL.is_dev_env_set OR BIS_UTIL.is_Seeded(FND_GLOBAL.USER_ID,'Y','N') = 'Y') THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END is_internal_customer;

-- Returns the default application to be set in all the designers
-- It assumes that BSC is licensed.
FUNCTION get_default_application_id
RETURN NUMBER
IS
  CURSOR latest_creation_date_cur IS
  SELECT application_id
  FROM   FND_APPLICATION_VL
  WHERE created_by NOT IN (1,2)
        AND (created_by < 120 OR created_by > 129)
  ORDER BY creation_date desc;

  l_app_id  FND_APPLICATION_VL.application_id%TYPE;
BEGIN
  IF(BIS_UTIL.is_internal_customer) THEN
    l_app_id := BIS_UTIL.G_BSC_APP_ID;
  ELSE
    IF(latest_creation_date_cur%ISOPEN) THEN
      CLOSE latest_creation_date_cur;
    END IF;
    OPEN latest_creation_date_cur;
    FETCH latest_creation_date_cur INTO l_app_id;
    IF(latest_creation_date_cur%NOTFOUND) THEN
      l_app_id := BIS_UTIL.G_BSC_APP_ID;
    END IF;
    CLOSE latest_creation_date_cur;
  END IF;

  RETURN l_app_id;
EXCEPTION
  WHEN OTHERS THEN
    IF(latest_creation_date_cur%ISOPEN) THEN
      CLOSE latest_creation_date_cur;
    END IF;
    RETURN BIS_UTIL.G_BSC_APP_ID;
END get_default_application_id;

FUNCTION get_object_type
( p_function_type  IN FND_FORM_FUNCTIONS.type%TYPE
, p_parameters     IN FND_FORM_FUNCTIONS.parameters%TYPE
, p_web_html_call  IN FND_FORM_FUNCTIONS.web_html_call%TYPE
)
RETURN VARCHAR2
IS
  l_object_type    VARCHAR2(30);
BEGIN
  IF ( (p_function_type = 'WEBPORTLET' OR p_function_type = 'WEBPORTLETX') AND p_web_html_call like 'OA.jsp?akRegionCode=BIS_PM_PORTLET_TABLE_LAYOUT%' AND p_parameters like '%pRequestType=P%') THEN
    l_object_type := BIS_UTIL.G_FUNC_PARAMETER_PORTLET;
  ELSIF ((p_function_type = 'WEBPORTLET' OR p_function_type = 'WEBPORTLETX') AND p_web_html_call like 'OA.jsp?akRegionCode=BIS_PM_PORTLET_TABLE_LAYOUT%' AND p_parameters like '%pRequestType=T%') THEN
    l_object_type := BIS_UTIL.G_FUNC_TABLE_PORTLET;
  ELSIF ((p_function_type = 'WEBPORTLET' OR p_function_type = 'WEBPORTLETX') AND p_web_html_call like 'OA.jsp?akRegionCode=BIS_PM_PORTLET_TABLE_LAYOUT%' AND p_parameters like '%pRequestType=G%') THEN
    l_object_type := BIS_UTIL.G_FUNC_GRAPH_PORTLET;
  ELSIF ((p_function_type = 'WEBPORTLET' OR p_function_type = 'WEBPORTLETX') AND p_web_html_call like 'OA.jsp?akRegionCode=BIS_PM_RELATED_LINK_LAYOUT%') THEN
    l_object_type := BIS_UTIL.G_FUNC_RELATED_LINKS_PORTLET;
  ELSIF ((p_function_type = 'WEBPORTLET' OR p_function_type = 'WEBPORTLETX') AND p_web_html_call like 'OA.jsp?akRegionCode=BIS_PMF_PORTLET_TABLE_LAYOUT%') THEN
    l_object_type := BIS_UTIL.G_FUNC_KPI_LIST;
  ELSIF ((p_function_type = 'WEBPORTLET' OR p_function_type = 'WEBPORTLETX') AND p_web_html_call like 'OA.jsp?akRegionCode=BSC_PORTLET_CUSTOM_VIEW%' AND p_parameters like '%pRequestType=C%') THEN
    l_object_type := BIS_UTIL.G_FUNC_CUSTOM_VIEW;
  ELSIF ((p_function_type = 'WEBPORTLET' OR p_function_type = 'WEBPORTLETX') AND p_parameters like '%pRequestType=URL%') THEN
    l_object_type := BIS_UTIL.G_FUNC_URL_PORTLET;
  ELSIF ((p_function_type = 'WEBPORTLET' OR p_function_type = 'WEBPORTLETX')) THEN
    l_object_type := BIS_UTIL.G_FUNC_GENERIC_OA_PORTLET;
  ELSIF (p_function_type = 'JSP' AND p_web_html_call like 'OA.jsp?akRegionCode=BIS_COMPONENT_PAGE%' AND p_parameters IS NOT NULL) THEN
    l_object_type := BIS_UTIL.G_FUNC_PAGE;
  ELSIF (((lower(p_web_html_call) like 'bisviewm.jsp%' OR p_web_html_call like 'OA.jsp?page=/oracle/apps/bis/report/webui/BISReportPG%') AND p_function_type = 'JSP')
        OR (lower(p_web_html_call) like 'bisviewer.showreport%' AND p_function_type = 'WWW')) THEN
    l_object_type := BIS_UTIL.G_FUNC_REPORT;
  END IF;

  RETURN l_object_type;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_object_type;
END get_object_type;



-- get Application ID by Short Name
FUNCTION Get_Apps_Id_By_Short_Name (
  p_Application_Short_Name IN VARCHAR2
) RETURN NUMBER IS
  l_Apps_Id NUMBER;
BEGIN
   SELECT APPLICATION_ID
   INTO   l_Apps_Id
   FROM   FND_APPLICATION
   WHERE  UPPER(APPLICATION_SHORT_NAME) = UPPER(p_Application_Short_Name);

   RETURN l_Apps_Id;
EXCEPTION
  WHEN OTHERS THEN
     RETURN -1;
END Get_Apps_Id_By_Short_Name;

PROCEDURE Get_Update_Date_For_Owner (
 p_owner          IN   VARCHAR2
,p_last_update_date       IN   VARCHAR2
,x_file_last_update_date  OUT  NOCOPY  DATE
,x_return_status          OUT  NOCOPY  VARCHAR2
,x_msg_count              OUT  NOCOPY  NUMBER
,x_msg_data               OUT  NOCOPY  VARCHAR2
)
IS
BEGIN

  IF ( (p_owner = 'ORACLE') AND (p_last_update_date IS NULL) ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_file_last_update_date := NVL(to_date(p_last_update_date, 'YYYY/MM/DD'), SYSDATE);


  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data  :=  x_msg_data ||'  Upload failed: OWNER=''ORACLE'' and Last_Update_Date is missing.';
      ELSE
        x_msg_data  :=  'Upload failed: OWNER=''ORACLE'' and Last_Update_Date is missing.';
      END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
    RAISE;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data  :=  x_msg_data ||' -> BIS_UTIL.Get_Update_Date_For_Owner ';
     ELSE
       x_msg_data  :=  SQLERRM ||' at BIS_UTIL.Get_Update_Date_For_Owner ';
     END IF;
     RAISE;

END Get_Update_Date_For_Owner;


PROCEDURE  Validate_For_Update
(
 p_last_update_date  IN   DATE
,p_owner             IN   VARCHAR2
,p_force_mode        IN   BOOLEAN
,p_table_name        IN   VARCHAR2
,p_key_value         IN   VARCHAR2
,x_ret_code          OUT  NOCOPY  BOOLEAN
,x_return_status     OUT  NOCOPY  VARCHAR2
,x_msg_data          OUT  NOCOPY  VARCHAR2
)
IS

  l_file_last_updated_by  NUMBER;
  l_db_last_updated_by  NUMBER;
  l_db_last_update_date  DATE;
  l_custom_mode VARCHAR2(5);
  l_msg_count NUMBER;

BEGIN

  l_file_last_updated_by := fnd_load_util.OWNER_ID(p_owner);
  x_ret_code := FALSE;

  IF (p_force_mode) THEN
    l_custom_mode := 'FORCE';
  END IF;

  --Using static sql's becoz dynamic sql's has performance impact

  IF ( UPPER(p_table_name) = 'BIS_DIMENSIONS') THEN
    SELECT last_update_date, last_updated_by INTO l_db_last_update_date, l_db_last_updated_by
      FROM bis_dimensions
      WHERE short_name = p_key_value;

  ELSIF ( UPPER(p_table_name) = 'BIS_DIMENSIONS_TL') THEN
    SELECT dim_tl.last_update_date, dim_tl.last_updated_by INTO l_db_last_update_date, l_db_last_updated_by
      FROM bis_dimensions_tl dim_tl, bis_dimensions dim
      WHERE dim.short_name = p_key_value
      AND dim_tl.dimension_id = dim.dimension_id
      AND dim_tl.language = USERENV('LANG');

  ELSIF ( UPPER(p_table_name) = 'BIS_LEVELS_TL') THEN
    SELECT lev_tl.last_update_date, lev_tl.last_updated_by INTO l_db_last_update_date, l_db_last_updated_by
      FROM bis_levels_tl lev_tl, bis_levels lev
      WHERE lev.short_name = p_key_value
      AND lev.level_id = lev_tl.level_id
      AND USERENV('LANG') = lev_tl.language;

  ELSIF ( UPPER(p_table_name) = 'BIS_LEVELS') THEN
    SELECT last_update_date, last_updated_by INTO l_db_last_update_date, l_db_last_updated_by
      FROM bis_levels
      WHERE short_name = p_key_value;

  ELSIF ( UPPER(p_table_name) = 'BSC_SYS_DIM_GROUPS_VL') THEN
    SELECT last_update_date, last_updated_by INTO l_db_last_update_date, l_db_last_updated_by
      FROM bsc_sys_dim_groups_vl
      WHERE short_name = p_key_value;

  ELSIF ( UPPER(p_table_name) = 'BSC_SYS_DIM_LEVELS_B') THEN
    SELECT last_update_date, last_updated_by INTO l_db_last_update_date, l_db_last_updated_by
      FROM bsc_sys_dim_levels_b
      WHERE short_name = p_key_value;

  END IF;

  x_ret_code := fnd_load_util.UPLOAD_TEST( p_file_id      =>   l_file_last_updated_by
                                          ,p_file_lud     =>   p_last_update_date
                                          ,p_db_id        =>   l_db_last_updated_by
                                          ,p_db_lud       =>   l_db_last_update_date
                                          ,p_custom_mode  =>   l_custom_mode);

  -- commented becoz FND itself throws this error
  --IF(x_ret_code = FALSE) THEN
    --FND_MESSAGE.SET_NAME('BIS','BIS_DIM_UPLOAD_TEST_FAILED');
    --FND_MESSAGE.SET_TOKEN('SHORT_NAME', p_key_value);
    --FND_MSG_PUB.ADD;
    --RAISE FND_API.G_EXC_ERROR;
  --END IF;

  EXCEPTION

     --WHEN FND_API.G_EXC_ERROR THEN
       --x_return_status := FND_API.G_RET_STS_ERROR ;
       --IF(x_msg_data IS NULL) THEN
         --FND_MSG_PUB.Count_And_Get( p_encoded => 'F'
                                    --,p_count  =>  l_msg_count
                                    --,p_data   =>  x_msg_data);
       --END IF;
       --RAISE;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data :=  x_msg_data ||' -> BIS_UTIL.Validate_For_Update ';
      ELSE
        x_msg_data :=  SQLERRM ||' at BIS_UTIL.Validate_For_Update ';
      END IF;
      RAISE;

END Validate_For_Update;

FUNCTION get_dim_objects_by_dim
( p_dimension          IN VARCHAR2
, p_allow_all          IN VARCHAR2 := FND_API.G_FALSE --Added for bug 5250723
, p_append_short_names IN VARCHAR2 := FND_API.G_TRUE
) RETURN VARCHAR2
IS
  l_dim_object_names     VARCHAR2(2000);
  l_dim_object_sht_names VARCHAR2(2000);
  l_dim_object_name      bis_levels_vl.name%TYPE;
  l_dim_object_sht_name  bis_levels_vl.short_name%TYPE;
  TYPE refCursorType     IS REF CURSOR ;
  c_dim_object_rec       refCursorType;

  l_dim_objects_sql      VARCHAR2(1000) :=
    'SELECT bis_lvl.short_name, bis_lvl.name
    FROM bis_dimensions bis_dim, bsc_sys_dim_groups_vl bsc_dim, bis_levels_vl bis_lvl, bsc_sys_dim_levels_b bsc_lvl, bsc_sys_dim_levels_by_group lvl_by_grp
    WHERE bis_dim.dim_grp_id = bsc_dim.dim_group_id
    AND   bis_lvl.short_name = bsc_lvl.short_name
    AND   bsc_dim.dim_group_id = lvl_by_grp.dim_group_id
    AND   bsc_lvl.dim_level_id = lvl_by_grp.dim_level_id
    AND   bis_dim.short_name = :1';
  l_where_clause VARCHAR2(1000) :=
   'AND   NVL(bis_lvl.enabled, ''T'') = ''T''
    AND   bis_lvl.source = ''OLTP''
    AND ((bis_dim.short_name <> ''TIME'')
    OR ((bis_dim.short_name = ''TIME'') AND (bis_lvl.short_name IN (''FII_TIME_DAY'',''FII_TIME_WEEK'',''FII_TIME_ENT_PERIOD'',''FII_TIME_ENT_QTR'',''FII_TIME_ENT_YEAR''))))';

BEGIN

  IF(p_allow_all = FND_API.G_FALSE) THEN
    l_dim_objects_sql := l_dim_objects_sql || l_where_clause;
  END IF;

  OPEN c_dim_object_rec FOR l_dim_objects_sql USING p_dimension;
  LOOP
  FETCH c_dim_object_rec INTO l_dim_object_sht_name,l_dim_object_name;
  EXIT WHEN c_dim_object_rec%NOTFOUND;
    IF (l_dim_object_names IS NULL) THEN
      l_dim_object_names := l_dim_object_name;
      l_dim_object_sht_names := l_dim_object_sht_name;
    ELSE
      l_dim_object_names := l_dim_object_names || ', ' || l_dim_object_name;
      l_dim_object_sht_names := l_dim_object_sht_names || ', ' || l_dim_object_sht_name;
    END IF;
  END LOOP;
  CLOSE c_dim_object_rec;

  IF ((l_dim_object_names IS NOT NULL) AND (l_dim_object_sht_names IS NOT NULL)) THEN
    IF(p_append_short_names = FND_API.G_TRUE) THEN
      RETURN l_dim_object_names || '^' || l_dim_object_sht_names;
    ELSE
      RETURN l_dim_object_names;
    END IF;
  ELSE
    RETURN NULL;
  END IF;
END get_dim_objects_by_dim;

PROCEDURE save_prototype_values
( p_dim_object  IN VARCHAR2
, p_PV_array    IN BIS_STRING_ARRAY
)
IS
  l_dim_bsc_table  VARCHAR2(30);
  l_sql_stmt       VARCHAR2(2000);
  id               NUMBER;
  value            VARCHAR2(1000); -- max allowed size from Designer is '999'
  i                NUMBER;
BEGIN

  SELECT level_table_name INTO l_dim_bsc_table
    FROM bsc_sys_dim_levels_b
    WHERE short_name = p_dim_object;

  l_sql_stmt := ' DELETE FROM ' || l_dim_bsc_table;
  EXECUTE IMMEDIATE l_sql_stmt;

  i := 1;
  WHILE (i < p_PV_array.COUNT) LOOP
    id := p_PV_array(i);
    value := p_PV_array(i + 1);
    l_sql_stmt :=    ' INSERT  INTO '||l_dim_bsc_table||
                        ' (CODE, USER_CODE, NAME, LANGUAGE, SOURCE_LANG)  '||
                        ' SELECT     '||id||' AS CODE, '||
                        ' '''||TO_CHAR(id)||''' AS USER_CODE, '||
                        ' '''||value||''' AS NAME,    L.LANGUAGE_CODE, '||
                        '  USERENV(''LANG'') '||
                        ' FROM    FND_LANGUAGES L '||
                        ' WHERE   L.INSTALLED_FLAG IN (''I'', ''B'') '||
                        ' AND     NOT EXISTS '||
                        ' ( SELECT NULL FROM   '||l_dim_bsc_table||
                        ' T WHERE  T.CODE = '||id||' '||
                        ' AND    T.LANGUAGE     = L.LANGUAGE_CODE) ';
    EXECUTE IMMEDIATE l_sql_stmt;
    i := i + 2;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END save_prototype_values;

FUNCTION get_Pages_Using_ParamPortlet
( p_Region_Code    IN  VARCHAR2
, x_Return_Status  OUT NOCOPY VARCHAR2
, x_Msg_Count      OUT NOCOPY NUMBER
, x_Msg_Data       OUT NOCOPY VARCHAR2
)RETURN VARCHAR2
IS
l_form_function     FND_FORM_FUNCTIONS.function_name%TYPE;
l_parent_obj_table  BIS_RSG_PUB_API_PKG.t_BIA_RSG_Obj_Table;
l_msg               VARCHAR2(32000);
l_pages_found       BOOLEAN;

CURSOR c_param_portlets IS
  SELECT function_name
  FROM   fnd_form_functions_vl
  WHERE  parameters LIKE 'pRegionCode=' || p_Region_Code || '&pRequestType=P%';

BEGIN
  l_pages_found := FALSE;

  FOR CD IN c_param_portlets LOOP

    l_parent_obj_table := BIS_RSG_PUB_API_PKG.GetParentObjects
                          ( p_Dep_Obj_Name  => CD.function_name
                          , p_Dep_Obj_Type  => 'PORTLET'
                          , p_Obj_Type      => 'PAGE'
                          , x_Return_Status => x_Return_Status
                          , x_Msg_Data      => x_Msg_Data
                          );
    IF ((x_Return_Status IS NOT NULL) AND (x_Return_Status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BIS', x_Msg_Data);
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF(l_parent_obj_table.COUNT > 0) THEN
      l_pages_found := TRUE;
      FOR i IN 0..l_Parent_Obj_Table.COUNT-1 LOOP
         l_msg := l_msg || '<li>'||l_parent_obj_table(i).user_object_name;
      END LOOP;
    END IF;
  END LOOP;

  IF(l_pages_found) THEN
    l_msg := '<UL>' || l_msg|| '</UL>';
  END IF;

  RETURN l_msg;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_Msg_Data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_Msg_Count
      , p_data      =>  x_Msg_Data
      );
    END IF;
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_Msg_Data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_Msg_Count
      , p_data      =>  x_Msg_Data
      );
    END IF;
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_Msg_Data IS NOT NULL) THEN
    x_Msg_Data      :=  x_msg_data||' -> BIS_UTIL.get_Pages_Using_ParamPortlet';
    ELSE
     x_Msg_Data      :=  SQLERRM||' at BIS_UTIL.get_Pages_Using_ParamPortlet';
    END IF;
END  get_Pages_Using_ParamPortlet;

FUNCTION get_value
( p_id         VARCHAR2
, p_view_name  VARCHAR2
)
RETURN VARCHAR2
IS

  l_sql_stmt                VARCHAR2(100);
  l_value                   VARCHAR2(100);

BEGIN

  l_sql_stmt := ' SELECT value FROM ' || p_view_name || ' WHERE id = ''' || p_id || ''' AND rownum < 2';
  EXECUTE IMMEDIATE l_sql_stmt INTO l_value;

  RETURN l_value;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_value;

FUNCTION get_default_value
( p_ids         VARCHAR2
, p_view_name  VARCHAR2
)
RETURN VARCHAR2
IS

  l_ids                     VARCHAR2(1000);
  l_id                      VARCHAR2(100);
  l_values                  VARCHAR2(1000);
  l_value                   VARCHAR2(100);
  l_pos                     NUMBER;

BEGIN

  l_ids := p_ids;

  WHILE (l_ids IS NOT NULL) LOOP

    l_pos := INSTR(l_ids, ',');

    IF (l_pos > 0) THEN

      l_id := TRIM(SUBSTR(l_ids, 1, l_pos - 1));

      l_value := get_value
                   ( p_id => l_id
       , p_view_name => p_view_name
       );

      IF (l_values IS NULL) THEN
        l_values := l_value;
      ELSE
        l_values := l_values || '^^' || l_value;
      END IF;

      l_ids := TRIM(SUBSTR(l_ids, l_pos + 1));

    ELSE

      l_value := get_value
                   ( p_id => l_ids
       , p_view_name => p_view_name
       );

      IF (l_values IS NULL) THEN
        l_values := l_value;
      ELSE
        l_values := l_values || '^^' || l_value;
      END IF;
      l_ids := NULL;

    END IF;

  END LOOP;

  RETURN l_values;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_default_value;

PROCEDURE get_default_dim_object_value
( p_dim_object  IN VARCHAR2
, p_dimension   IN VARCHAR2
, p_id          IN VARCHAR2
, x_id          OUT NOCOPY VARCHAR2
, x_value       OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_view_name IS
    SELECT level_values_view_name
    FROM bis_levels
    WHERE short_name = p_dim_object;
  l_view_name_rec  c_view_name%ROWTYPE;

  CURSOR c_all_enabled IS
    SELECT total_flag
    FROM bsc_sys_dim_levels_b bsc_lvl, bis_dimensions bis_dim, bsc_sys_dim_levels_by_group lvl_by_grp
    WHERE bsc_lvl.dim_level_id = lvl_by_grp.dim_level_id
    AND   bis_dim.dim_grp_id = lvl_by_grp.dim_group_id
    AND   bsc_lvl.short_name = p_dim_object
    AND   bis_dim.short_name = p_dimension;
  l_all_enabled_rec  c_all_enabled%ROWTYPE;

  l_level_values_view_name  VARCHAR2(30);
  l_sql_stmt                VARCHAR2(100);

BEGIN

  x_value := NULL;
  x_id := p_id;

  IF(p_id IS NOT NULL) THEN
    FOR l_view_name_rec IN c_view_name LOOP  -- Only 1 record should be returned
      x_value := get_default_value
                 ( p_ids => p_id
                 , p_view_name => l_view_name_rec.level_values_view_name
     );
    END LOOP;
  ELSE
    IF(c_all_enabled%ISOPEN) THEN
      CLOSE c_all_enabled;
    END IF;
    OPEN c_all_enabled;
    FETCH c_all_enabled INTO l_all_enabled_rec;
    IF(c_all_enabled%FOUND AND l_all_enabled_rec.total_flag = -1) THEN
      x_id := 'All';
      x_value := BIS_UTILITIES_PVT.Get_FND_Message('BIS_ALL');
    ELSE
      FOR l_view_name_rec IN c_view_name LOOP  -- Only 1 record should be returned
        l_sql_stmt := ' SELECT id, value FROM ' || l_view_name_rec.level_values_view_name || ' WHERE rownum < 2 ';
        EXECUTE IMMEDIATE l_sql_stmt INTO x_id, x_value;
      END LOOP;
    END IF;
    CLOSE c_all_enabled;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF(c_all_enabled%ISOPEN) THEN
      CLOSE c_all_enabled;
    END IF;
END get_default_dim_object_value;

PROCEDURE get_parent_objects
( p_dep_object_name       IN VARCHAR2
, p_dep_object_type       IN VARCHAR2
, p_parent_object_type    IN VARCHAR2
, x_parent_objects        OUT NOCOPY VARCHAR2
, x_parent_object_owners  OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
) IS
 l_parent_user_objects VARCHAR(15000) := NULL;
BEGIN
  BIS_UTIL.get_parent_objects
  ( p_dep_object_name
   , p_dep_object_type
   , p_parent_object_type
   , x_parent_objects
   , l_parent_user_objects
   , x_parent_object_owners
   , x_return_status
   , x_msg_count
   , x_msg_data
  );
END get_parent_objects;


PROCEDURE get_parent_objects
( p_dep_object_name       IN VARCHAR2
, p_dep_object_type       IN VARCHAR2
, p_parent_object_type    IN VARCHAR2
, x_parent_objects        OUT NOCOPY VARCHAR2
, x_parent_user_objects   OUT NOCOPY VARCHAR2
, x_parent_object_owners  OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  l_parent_obj_table  BIS_RSG_PUB_API_PKG.t_BIA_RSG_Obj_Table;

BEGIN

  l_parent_obj_table := BIS_RSG_PUB_API_PKG.GetParentObjects
                        ( p_Dep_Obj_Name  => p_dep_object_name
                        , p_Dep_Obj_Type  => p_dep_object_type
                        , p_Obj_Type      => p_parent_object_type
                        , x_return_status => x_return_status
                        , x_msg_data      => x_msg_data
                        );
  IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
    FND_MSG_PUB.Initialize;
    FND_MESSAGE.SET_NAME('BIS', x_msg_data);
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF(l_parent_obj_table.COUNT > 0) THEN
    FOR i IN 0..l_parent_obj_table.COUNT - 1 LOOP
      IF(x_parent_objects IS NULL) THEN
        x_parent_objects := l_parent_obj_table(i).object_name;
      ELSE
        x_parent_objects := x_parent_objects || ',' || l_parent_obj_table(i).object_name;
      END IF;
      IF(x_parent_user_objects IS NULL) THEN
        x_parent_user_objects := l_parent_obj_table(i).user_object_name;
      ELSE
        x_parent_user_objects := x_parent_user_objects || ',' || l_parent_obj_table(i).user_object_name;
      END IF;
      IF(x_parent_object_owners IS NULL) THEN
        x_parent_object_owners := l_parent_obj_table(i).object_owner;
      ELSE
        x_parent_object_owners := x_parent_object_owners || ',' || l_parent_obj_table(i).object_owner;
      END IF;
    END LOOP;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BIS_UTIL.get_parent_objects';
    ELSE
      x_msg_data := SQLERRM || ' at BIS_UTIL.get_parent_objects';
    END IF;
END get_parent_objects;

/*This function uses PMV Function BIS_PMV_BSC_API_PUB.Get_DimLevel_Viewby to retrieve Dimension Short Name
 Values in ATTRIBUTE2 of AK_REGION_ITEMS */

FUNCTION get_dims_for_region(
  x_RegionCode IN VARCHAR2
 )
 RETURN VARCHAR2 IS

 l_DimObj_ViewBy_Tbl BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type;
 l_return_status VARCHAR2(10);
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(255);
 l_Dim_Value VARCHAR(1000) := NULL;
 l_dimension BIS_DIMENSIONS.SHORT_NAME%TYPE;

 BEGIN

 BIS_PMV_BSC_API_PUB.Get_DimLevel_Viewby(
   p_api_version         =>  1
 , p_Region_Code         => x_RegionCode
 , p_Measure_Short_Name  => NULL
 , x_DimLevel_Viewby_Tbl => l_DimObj_ViewBy_Tbl
 , x_return_status       => l_return_status
 , x_msg_count           => l_msg_count
 , x_msg_data            => l_msg_data
 );

 FOR i IN 1..(l_DimObj_ViewBy_Tbl.COUNT) LOOP
   IF l_DimObj_ViewBy_Tbl(i).Dim_DimLevel IS NOT NULL THEN
     l_dimension     :=  TRIM(SUBSTR(l_DimObj_ViewBy_Tbl(i).Dim_DimLevel, 1, (INSTR(l_DimObj_ViewBy_Tbl(i).Dim_DimLevel, '+') - 1)));
     IF ((l_Dim_Value IS NULL) AND (l_dimension IS NOT NULL))THEN
       l_Dim_Value := ','||l_dimension||',';
     ELSIF (INSTR(l_Dim_Value,','||l_dimension||',')=0 AND (l_dimension IS NOT NULL)) THEN
       l_Dim_Value := l_Dim_Value||l_dimension||',';
     END IF;
   END IF;
 END LOOP;

 RETURN l_Dim_Value;

 END get_dims_for_region;

 /* This procedure is to check the dependency of a portlet with the given
 form function name
 */
 PROCEDURE Check_Portlet_Dependency(
   p_portlet_func_name   IN       VARCHAR2
  ,p_portlet_type    IN       VARCHAR2
  ,x_parent_obj_exist    OUT NOCOPY   VARCHAR2
  ,x_parent_obj_list   OUT NOCOPY   VARCHAR2
  ,x_return_status     OUT NOCOPY   VARCHAR2
  ,x_msg_count       OUT NOCOPY   NUMBER
  ,x_msg_data      OUT NOCOPY   VARCHAR2
 ) IS

  l_par_obj_count       INTEGER;
  l_par_obj_list      VARCHAR2(1000);

  CURSOR c_par_objs IS
    SELECT att_value
  FROM jdr_attributes
  WHERE att_name = 'windowTitle' AND att_comp_docid IN
    (SELECT UNIQUE a.att_comp_docid
     FROM jdr_attributes a, jdr_attributes b
     WHERE a.att_comp_docid = b.att_comp_docid AND a.att_comp_seq = b.att_comp_seq
     AND a.att_name = 'user:akAttribute3' AND a.att_value = p_portlet_type
     AND b.att_name = 'user:akAttribute1' AND b.att_value = p_portlet_func_name);

 BEGIN
  l_par_obj_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_parent_obj_exist := FND_API.G_FALSE;

  FOR cd_par_obj IN c_par_objs LOOP
    IF (l_par_obj_count = 0) THEN
      l_par_obj_list := cd_par_obj.att_value;
    ELSE
      l_par_obj_list := l_par_obj_list || ', ' || cd_par_obj.att_value;
    END IF;
    l_par_obj_count := l_par_obj_count + 1;
  END LOOP;

  IF (l_par_obj_count > 0) THEN
    x_parent_obj_list := l_par_obj_list;
    x_parent_obj_exist := FND_API.G_TRUE;
  END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (   p_encoded   =>  FND_API.G_FALSE
           ,p_count     =>  x_msg_count
           ,p_data      =>  x_msg_data
        );
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
         );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> Check_Portlet_Dependency ';
     ELSE
        x_msg_data      :=  SQLERRM||' at Check_Portlet_Dependency ';
     END IF;

 END Check_Portlet_Dependency;

/* procedure to check dependency for objects like Graph, Custom View, etc
   Return the full list of dependency if p_list_dependency = FND_API.G_TRUE
   */

PROCEDURE Check_Object_Dependency(
   p_param_search_string   IN         VARCHAR2
  ,p_obj_portlet_type      IN         VARCHAR2
  ,p_list_dependency       IN         VARCHAR2
  ,x_exist_dependency      OUT NOCOPY VARCHAR2
  ,x_dep_obj_list          OUT NOCOPY VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
) IS

  l_portlet_name        VARCHAR2(200);
  l_portlet_func_name   VARCHAR2(200);
  l_dep_obj_list        VARCHAR2(6000);
  l_temp_list           VARCHAR2(1000);
  l_exist_dependency    VARCHAR2(10);
  l_return_status       VARCHAR2(10);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(1000);

  CURSOR c_portlets IS
   SELECT function_name, user_function_name
   FROM fnd_form_functions_vl
   WHERE parameters like p_param_search_string;

Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_exist_dependency := FND_API.G_FALSE;

  FOR cd_portlet IN c_portlets LOOP
    l_portlet_name := cd_portlet.user_function_name;
    l_portlet_func_name := cd_portlet.function_name;

    BIS_UTIL.Check_Portlet_Dependency(p_portlet_func_name => l_portlet_func_name,
                                      p_portlet_type      => p_obj_portlet_type,
                                      x_parent_obj_exist  => l_exist_dependency,
                                      x_parent_obj_list   => l_temp_list,
                                      x_return_status     => l_return_status,
                                      x_msg_count         => l_msg_count,
                                      x_msg_data          => l_msg_data);

    IF ((l_return_status IS NOT NULL) AND (l_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      FND_MSG_PUB.Initialize;
      FND_MESSAGE.SET_NAME('BIS',l_msg_data);
      FND_MSG_PUB.ADD;
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_exist_dependency = FND_API.G_TRUE) THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_DEPENDENCY_PAIR_MSG');
      FND_MESSAGE.SET_TOKEN('CHILD_NAME',l_portlet_name);
      FND_MESSAGE.SET_TOKEN('PARENT_NAMES',l_temp_list);
      --l_dep_obj_message := FND_MESSAGE.GET;
      l_dep_obj_list := l_dep_obj_list || '<li>' || FND_MESSAGE.GET;
      x_exist_dependency := FND_API.G_TRUE;
    END IF;

    EXIT WHEN p_list_dependency = FND_API.G_FALSE AND l_exist_dependency = FND_API.G_TRUE;

  END LOOP;

  x_dep_obj_list := l_dep_obj_list;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (   p_encoded   =>  FND_API.G_FALSE
           ,p_count     =>  x_msg_count
           ,p_data      =>  x_msg_data
        );
      END IF;
      x_return_status :=  FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
         );
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> Check_Object_Dependency ';
     ELSE
        x_msg_data      :=  SQLERRM||' at Check_Object_Dependency ';
     END IF;

 END Check_Object_Dependency;


/*
  This function returns the first responsibility id for the form function.
  This is a specific case called from SONAR notifications.
*/
FUNCTION get_form_function_resp_id (
  p_function_name IN VARCHAR2
, p_user_id       IN NUMBER
)
RETURN NUMBER
IS

  CURSOR c_menu_id IS
    SELECT menu_id
      FROM fnd_menu_entries fnd_mnu_ent, fnd_form_functions fnd_ff
      WHERE fnd_mnu_ent.function_id = fnd_ff.function_id
      AND   fnd_ff.function_name = p_function_name;
  l_menu_id_rec  c_menu_id%ROWTYPE;

  l_function_id  FND_FORM_FUNCTIONS.FUNCTION_ID%TYPE;
  l_resp_id      FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;

BEGIN

  IF (p_function_name IS NOT NULL) THEN

    FOR l_menu_id_rec IN c_menu_id LOOP
      l_resp_id := get_menu_resp_id
                                ( p_sub_menu_id => l_menu_id_rec.menu_id
        , p_user_id => p_user_id
                                , p_count => 0
                                );
      IF (l_resp_id IS NOT NULL) THEN
        RETURN l_resp_id;
      END IF;
    END LOOP;

  END IF;

  RETURN -1;

EXCEPTION
  WHEN OTHERS THEN
    RETURN -1;
END get_form_function_resp_id;


/*
  Recursive function call to get the respId.
*/
FUNCTION get_menu_resp_id (
  p_sub_menu_id IN NUMBER
, p_user_id     IN NUMBER
, p_count       IN NUMBER
)
RETURN NUMBER
IS

  CURSOR c_resp_id(l_menu_id NUMBER, l_user_id NUMBER) IS
    SELECT fnd_resp.responsibility_id
      FROM fnd_responsibility fnd_resp, fnd_menu_entries fnd_mnu_ent, fnd_user_resp_groups fnd_usr_resp
      WHERE fnd_resp.menu_id = fnd_mnu_ent.menu_id
      AND   fnd_usr_resp.responsibility_id = fnd_resp.responsibility_id
      AND   fnd_mnu_ent.menu_id = l_menu_id
      AND   fnd_usr_resp.user_id = l_user_id
      AND   fnd_usr_resp.start_date <= sysdate
      AND   (fnd_usr_resp.end_date is null or fnd_usr_resp.end_date >= sysdate)
      AND   fnd_resp.start_date <= sysdate
      AND   (fnd_resp.end_date is null or fnd_resp.end_date >= sysdate)
      AND   rownum < 2;

  CURSOR c_sub_menu_id(l_sub_menu_id NUMBER) IS
    SELECT menu_id
      FROM fnd_menu_entries
      WHERE sub_menu_id = l_sub_menu_id;
  l_sub_menu_id_rec  c_sub_menu_id%ROWTYPE;

  l_resp_id  FND_RESPONSIBILITY.RESPONSIBILITY_ID%TYPE;
  l_count    NUMBER;

BEGIN

  l_count := p_count;

  -- Just to avoid infinite loop we are taking this safety measure
  IF (l_count > 100) THEN
    RETURN -1;
  END IF;

  IF (c_resp_id%ISOPEN) THEN
    CLOSE c_resp_id;
  END IF;

  OPEN c_resp_id(p_sub_menu_id, p_user_id);
  FETCH c_resp_id INTO l_resp_id;

  IF (c_resp_id%FOUND) THEN
    CLOSE c_resp_id;
    RETURN l_resp_id;
  END IF;

  IF (c_resp_id%ISOPEN) THEN
    CLOSE c_resp_id;
  END IF;

  FOR l_sub_menu_id_rec IN c_sub_menu_id(p_sub_menu_id) LOOP
    l_resp_id := get_menu_resp_id
                              ( p_sub_menu_id => l_sub_menu_id_rec.menu_id
            , p_user_id => p_user_id
            , p_count => l_count + 1
            );
    IF (l_resp_id IS NOT NULL) THEN
      RETURN l_resp_id;
    END IF;
  END LOOP;

  RETURN l_resp_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_resp_id%ISOPEN) THEN
      CLOSE c_resp_id;
    END IF;
    RETURN -1;
END get_menu_resp_id;


/*
  Returns the first form function for the region code.
*/
FUNCTION get_form_function_from_region (
  p_region_code  IN  VARCHAR2
)
RETURN VARCHAR2
IS

  CURSOR c_function_name(p_region_code  VARCHAR2) IS
    SELECT function_name
      FROM fnd_form_functions
      WHERE ((type = 'JSP' AND (web_html_call LIKE 'bisviewm.jsp%' OR web_html_call like 'OA.jsp?page=/oracle/apps/bis/report/webui/BISReportPG%'))
              OR (type = 'WWW' AND LOWER(web_html_call) LIKE 'bisviewer.showreport%'))
      AND   UPPER(parameters) LIKE UPPER('%pRegionCode=' || p_region_code || '%')
      AND   rownum < 2;

  l_function_name  FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;

BEGIN

  IF (c_function_name%ISOPEN) THEN
    CLOSE c_function_name;
  END IF;
  OPEN c_function_name(p_region_code);
  FETCH c_function_name INTO l_function_name;
  IF (c_function_name%FOUND) THEN
    CLOSE c_function_name;
    RETURN l_function_name;
  END IF;

  CLOSE c_function_name;

  RETURN l_function_name;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_function_name%ISOPEN) THEN
      CLOSE c_function_name;
    END IF;
    RETURN NULL;
END get_form_function_from_region;

/*
  Returns responsibility id if the owner is a responsibility in wf_roles
*/
FUNCTION is_owner_responsibility (
  p_owner  IN VARCHAR2
)
RETURN NUMBER
IS
  l_resp_id  NUMBER;
  CURSOR c_resp(p_owner  VARCHAR2) IS
    SELECT fnd_resp.responsibility_id
      FROM fnd_responsibility fnd_resp, wf_role_lov_vl wf
      WHERE fnd_resp.responsibility_id = wf.orig_system_id
      AND   wf.name = p_owner
      AND   wf.orig_system like 'FND_RESP%'
      AND   rownum < 2;  -- Just to avoid any failure here.

BEGIN

  IF (c_resp%ISOPEN) THEN
    CLOSE c_resp;
  END IF;
  OPEN c_resp(p_owner);
  FETCH c_resp INTO l_resp_id;
  IF (c_resp%FOUND) THEN
    CLOSE c_resp;
    RETURN l_resp_id;
  END IF;

  CLOSE c_resp;

  RETURN l_resp_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_resp%ISOPEN) THEN
      CLOSE c_resp;
    END IF;
    RETURN NULL;
END is_owner_responsibility;


/*
  Returns user id if the owner is a user in wf_roles
*/

FUNCTION is_owner_user (
  p_owner  IN VARCHAR2
)
RETURN NUMBER
IS
  l_user_id  NUMBER;
  CURSOR c_user(p_owner  VARCHAR2) IS
    SELECT fnd_usr.user_id
      FROM fnd_user fnd_usr, wf_role_lov_vl wf
      WHERE wf.name = p_owner
        AND ((wf.orig_system = 'FND_USR' AND fnd_usr.user_id = wf.orig_system_id) OR
             (wf.orig_system = 'PER' AND fnd_usr.employee_id = wf.orig_system_id)
            );

BEGIN

  IF (c_user%ISOPEN) THEN
    CLOSE c_user;
  END IF;
  OPEN c_user(p_owner);
  FETCH c_user INTO l_user_id;
  IF (c_user%FOUND) THEN
    CLOSE c_user;
    RETURN l_user_id;
  END IF;

  CLOSE c_user;

  RETURN l_user_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_user%ISOPEN) THEN
      CLOSE c_user;
    END IF;
    RETURN NULL;
END is_owner_user;

/*
  Checks whether an object is created by 1,2 or 120 to 129 users
  p_created_By  : CREATED_BY value of the object
  Returns 1 if the object is seeded
  Returns 0 otherwise
  Followed the logic from AFLDUTLB.pls
*/

FUNCTION is_Seeded  (
  p_created_By IN NUMBER
)
RETURN NUMBER
IS
l_isSeeded NUMBER;
BEGIN
  IF(p_created_By = 1 OR p_created_By = 2 OR (p_created_By >= 120 AND p_created_By <= 129)) THEN
    RETURN 1;
  END IF;
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END is_Seeded;

/*
  Checks whether an object is created by 1,2 or 120 to 129 users
  p_created_By  : CREATED_BY value of the object
  p_TrueValue   : String to be returned if the object is seeded
  p_FalseValue  : String to be returned if the object is not seeded
  Followed the logic from AFLDUTLB.pls
*/

FUNCTION is_Seeded  (
  p_created_By IN NUMBER
, p_TrueValue  IN VARCHAR2
, p_FalseValue IN VARCHAR2
)
RETURN VARCHAR2
IS
l_isSeeded NUMBER;
BEGIN
  IF(p_created_By = 1 OR p_created_By = 2 OR (p_created_By >= 120 AND p_created_By <= 129)) THEN
    RETURN p_TrueValue;
  END IF;
  RETURN p_FalseValue;
EXCEPTION
  WHEN OTHERS THEN
    RETURN p_FalseValue;
END is_Seeded;

/*
  Called from PMFUtil.java to get the respId and secGrpId for a measure's report.
  p_function_name : BIS_INDICATORS.function_name
  p_region_code   : region code from BIS_INDICATORS.actual_data_source
  p_owner         : Target owner from wf_roles
  If the target owner is itself a responsibility, that will be used straightaway.
  If the owner is a user, we will use this user_id to get the responsibility for the form function.
  If the owner is neither a responsibility nor a user, then return -1.
*/
PROCEDURE get_respId_for_measure_report (
  p_function_name  IN VARCHAR2
, p_region_code    IN VARCHAR2
, p_owner          IN VARCHAR2
, x_resp_id        OUT NOCOPY NUMBER
, x_sec_grp_id     OUT NOCOPY NUMBER
)
IS
  l_resp_id         NUMBER;
  l_user_id         NUMBER;
  l_function_name   FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;

BEGIN

  x_resp_id := -1;

  l_resp_id := is_owner_responsibility(p_owner => p_owner);

  IF (l_resp_id IS NOT NULL) THEN

    x_resp_id := l_resp_id;
    x_sec_grp_id := get_sec_grp_id_for_resp_role(p_role_resp => p_owner);

  ELSE

    l_user_id := is_owner_user(p_owner => p_owner);

    IF (l_user_id IS NOT NULL) THEN

      l_function_name := p_function_name;
      IF ((l_function_name IS NULL) AND (p_region_code IS NOT NULL)) THEN
        l_function_name := get_form_function_from_region(p_region_code => p_region_code);
      END IF;

      IF (l_function_name IS NOT NULL) THEN
        x_resp_id := get_form_function_resp_id
                     ( p_function_name => l_function_name
         , p_user_id       => l_user_id
         );
        x_sec_grp_id := get_sec_grp_id_for_user_role
                  ( p_resp_id   => x_resp_id
      , p_user_id   => l_user_id
      );
      END IF;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END get_respId_for_measure_report;

/*
  Takes as input user id and responsibility id, and returns the first
  security group id for this combination from FND_USER_RESP_GROUPS_DIRECT
*/
FUNCTION get_sec_grp_id_for_user_role (
  p_resp_id   IN NUMBER
, p_user_id   IN NUMBER
)
RETURN NUMBER
IS
  l_sec_grp_id  NUMBER;

  CURSOR c_sec_grp_id IS
    SELECT security_group_id
      FROM fnd_user_resp_groups_direct
      WHERE user_id = p_user_id
      AND   responsibility_id = p_resp_id
      AND   rownum < 2;
BEGIN
  l_sec_grp_id := -1;

  IF (c_sec_grp_id%ISOPEN) THEN
    CLOSE c_sec_grp_id;
  END IF;
  OPEN c_sec_grp_id;
  FETCH c_sec_grp_id INTO l_sec_grp_id;
  IF (c_sec_grp_id%FOUND) THEN
    CLOSE c_sec_grp_id;
    RETURN l_sec_grp_id;
  END IF;
  CLOSE c_sec_grp_id;

  RETURN l_sec_grp_id;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_sec_grp_id%ISOPEN) THEN
      CLOSE c_sec_grp_id;
    END IF;
END get_sec_grp_id_for_user_role;

/*
  Takes as an input the role name which is assumed to be a responsibility.
  The role name is of the form FND_RESP|HRI|PKP_QAHRI2|8338. This API
  will parse this role name to get the SECURITY_GROUP_KEY which is the
  last part of the role name. Using this SECURITY_GROUP_KEY value we will
  find out the SECURITY_GROUP_ID using table FND_SECURITY_GROUPS_VL.
*/
FUNCTION get_sec_grp_id_for_resp_role (
  p_role_resp  IN VARCHAR2
)
RETURN NUMBER
IS
  l_role_name    VARCHAR2(320);
  l_sec_grp_key  VARCHAR2(30);
  l_sec_grp_id   NUMBER;
  l_index        NUMBER;

  CURSOR c_sec_grp_id IS
    SELECT security_group_id
      FROM fnd_security_groups
      WHERE security_group_key = l_sec_grp_key;
BEGIN
  l_sec_grp_id := -1;
  l_role_name := p_role_resp;

  l_index := INSTR(l_role_name, '|', -1);  -- indexOf '|' from end
  IF (l_index > 0) THEN
    l_sec_grp_key := SUBSTR(l_role_name, l_index + 1, LENGTH(l_role_name));
  END IF;

  IF (l_sec_grp_key IS NOT NULL) THEN
    IF (c_sec_grp_id%ISOPEN) THEN
      CLOSE c_sec_grp_id;
    END IF;
    OPEN c_sec_grp_id;
    FETCH c_sec_grp_id INTO l_sec_grp_id;
    IF (c_sec_grp_id%FOUND) THEN
      CLOSE c_sec_grp_id;
      RETURN l_sec_grp_id;
    END IF;
    CLOSE c_sec_grp_id;
  END IF;

  RETURN l_sec_grp_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_sec_grp_id%ISOPEN) THEN
      CLOSE c_sec_grp_id;
    END IF;
    RETURN -1;
END get_sec_grp_id_for_resp_role;

/*
    This api will take comma seperated dim plus dim levels in the report and
    returns comma seperated invalid dim plus dim levels.
*/

FUNCTION inv_dim_dimlevel_rel (
  p_comma_sep_dim_dimlevel IN VARCHAR2
)
RETURN VARCHAR2
IS

  l_comma_sep_dim_dimlevel    VARCHAR2(1000);
  l_pos         NUMBER;
  l_dim_plus_dimlevel     VARCHAR2(100);
  l_inv_dim_plus_dimlevel   VARCHAR2(100);
  l_inv_comma_sep_dim_dimlevel    VARCHAR2(1000);
  l_invalid       VARCHAR2(1);

BEGIN
  l_comma_sep_dim_dimlevel := p_comma_sep_dim_dimlevel;

  WHILE (l_comma_sep_dim_dimlevel IS NOT NULL) LOOP

    l_pos := INSTR(l_comma_sep_dim_dimlevel, ',');

    IF (l_pos > 0) THEN

      l_dim_plus_dimlevel := TRIM(SUBSTR(l_comma_sep_dim_dimlevel, 1, l_pos - 1));

      l_invalid := is_dim_plus_dimlevel_invalid(p_dim_plus_dimlevel => l_dim_plus_dimlevel);


      IF ( l_invalid = FND_API.G_TRUE ) THEN

        IF (l_inv_comma_sep_dim_dimlevel IS NULL) THEN
          l_inv_comma_sep_dim_dimlevel := l_dim_plus_dimlevel;
        ELSE
          l_inv_comma_sep_dim_dimlevel := l_dim_plus_dimlevel || ', ' || l_inv_comma_sep_dim_dimlevel;
        END IF;

      END IF;

      l_comma_sep_dim_dimlevel := TRIM(SUBSTR(l_comma_sep_dim_dimlevel, l_pos + 1));

    ELSE

      l_invalid := is_dim_plus_dimlevel_invalid(p_dim_plus_dimlevel => l_comma_sep_dim_dimlevel);


      IF ( l_invalid = FND_API.G_TRUE ) THEN

        IF (l_inv_comma_sep_dim_dimlevel IS NULL) THEN
          l_inv_comma_sep_dim_dimlevel := l_comma_sep_dim_dimlevel;
        ELSE
          l_inv_comma_sep_dim_dimlevel := l_comma_sep_dim_dimlevel || ', ' || l_inv_comma_sep_dim_dimlevel;
        END IF;

      END IF;

      l_comma_sep_dim_dimlevel := NULL;

    END IF;

   END LOOP;


   RETURN l_inv_comma_sep_dim_dimlevel;

   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;

END inv_dim_dimlevel_rel;




/*
    This api checks whether the dim plus dim level is valid or not. If valid returns false
*/

FUNCTION is_dim_plus_dimlevel_invalid (
  p_dim_plus_dimlevel IN VARCHAR2
)
RETURN VARCHAR2
IS

  l_dim_plus_dimlevel   VARCHAR2(100);
  l_pos     NUMBER;
  l_dim     bis_indicators.short_name%TYPE;
  l_dim_level   bis_levels.short_name%TYPE;
  l_num     NUMBER;

  CURSOR c_dim_plus_dimlevel_rel_cursor(l_dim VARCHAR2, l_dim_level VARCHAR2) IS
    SELECT 1
    FROM bsc_sys_dim_groups_vl sys_dim_group, bsc_sys_dim_levels_vl sys_dim_levels, bsc_sys_dim_levels_by_group sys_dim_level_group, bis_levels bis_level, bis_dimensions bis_dim
    WHERE sys_dim_group.dim_group_id = sys_dim_level_group.dim_group_id
          AND sys_dim_levels.dim_level_id = sys_dim_level_group.dim_level_id
          AND sys_dim_group.dim_group_id = bis_dim.dim_grp_id
          AND sys_dim_levels.short_name = bis_level.short_name
          AND sys_dim_group.short_name = l_dim
          AND sys_dim_levels.short_name = l_dim_level;


BEGIN

  l_dim_plus_dimlevel := p_dim_plus_dimlevel;

  l_pos := INSTR(l_dim_plus_dimlevel, '+');

  IF (l_pos > 0) THEN

    l_dim := TRIM(SUBSTR(l_dim_plus_dimlevel, 1, l_pos - 1));
    l_dim_level := TRIM(SUBSTR(l_dim_plus_dimlevel, l_pos + 1));



    IF (c_dim_plus_dimlevel_rel_cursor%ISOPEN) THEN
      CLOSE c_dim_plus_dimlevel_rel_cursor;
    END IF;

    OPEN c_dim_plus_dimlevel_rel_cursor(l_dim, l_dim_level);

    FETCH c_dim_plus_dimlevel_rel_cursor INTO l_num;

    IF (c_dim_plus_dimlevel_rel_cursor%FOUND) THEN


      IF (l_num > 0) THEN
        CLOSE c_dim_plus_dimlevel_rel_cursor;
        RETURN FND_API.G_FALSE;
      END IF;

    ELSE

      CLOSE c_dim_plus_dimlevel_rel_cursor;
      RETURN FND_API.G_TRUE;

    END IF;



  END IF;

  RETURN FND_API.G_FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (c_dim_plus_dimlevel_rel_cursor%ISOPEN) THEN
        CLOSE c_dim_plus_dimlevel_rel_cursor;
      END IF;
      RETURN FND_API.G_FALSE;

END is_dim_plus_dimlevel_invalid;

/*
Returns last date of previous time period as x_prev_asofdate
*/
PROCEDURE get_previous_asofdate
( p_dimensionlevel        IN   VARCHAR2
, p_time_comparison_type  IN   VARCHAR2
, p_asof_date             IN   DATE
, x_prev_asofdate         OUT  NOCOPY DATE
, x_return_status         OUT  NOCOPY VARCHAR2
, x_msg_count             OUT  NOCOPY NUMBER
, x_msg_data              OUT  NOCOPY VARCHAR2
)
IS
  l_sql        VARCHAR2(1000);
  l_asof_date  DATE;
BEGIN

  IF (p_asof_date IS NULL) THEN
    l_asof_date := SYSDATE;
  ELSE
    l_asof_date := p_asof_date;
  END IF;

  IF ( p_time_comparison_type IS NULL OR p_time_comparison_type = 'TIME_COMPARISON_TYPE+SEQUENTIAL') THEN

     IF (p_dimensionlevel = 'TIME+FII_TIME_WEEK') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.pwk_end(:2); END;';  -- Previous Week end date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate , IN l_asof_date;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_TIME_ENT_PERIOD') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.ent_pper_end(:2); END;';  -- Previous enterprise period end date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate , IN l_asof_date;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_TIME_ENT_QTR') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.ent_pqtr_end(:2); END;';  -- Previous enterprise quarter end date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate , IN l_asof_date;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_TIME_ENT_YEAR') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.ent_pyr_end(:2);  END;';  -- Previous Enterprise year end date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate , IN l_asof_date;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_TIME_DAY') THEN
        x_prev_asofdate := l_asof_date - 1;
     END IF;

     IF (p_dimensionlevel = 'TIME+FII_ROLLING_WEEK') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.rwk_start(:2); END;';  -- Rolling Week start date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate, IN l_asof_date;
  x_prev_asofdate := x_prev_asofdate - 1 ;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_ROLLING_MONTH') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.rmth_start(:2); END;';  -- Rolling Month start date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate, IN l_asof_date;
  x_prev_asofdate := x_prev_asofdate - 1 ;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_ROLLING_QTR') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.rqtr_start(:2); END;';  -- Rolling Quarter start date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate, IN l_asof_date;
  x_prev_asofdate := x_prev_asofdate - 1 ;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_ROLLING_YEAR') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.ryr_start(:2); END;';  -- Rolling Year start date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate, IN l_asof_date;
  x_prev_asofdate := x_prev_asofdate - 1 ;
     END IF;

  ELSE  -- p_time_comparison_type = 'TIME_COMPARISON_TYPE+YEARLY'

     IF (p_dimensionlevel = 'TIME+FII_TIME_WEEK') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.lyswk_end(:2);  END;';  -- Last year same week end date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate , IN l_asof_date;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_TIME_ENT_PERIOD') THEN
         l_sql := 'BEGIN :1 := FII_TIME_API.ent_lysper_end(:2); END;';  -- Last year same Enterprise period end date
         EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate , IN l_asof_date;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_TIME_ENT_QTR') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.ent_lysqtr_end(:2);  END;';  -- Last year same Enterprise quarter end date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate , IN l_asof_date;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_TIME_ENT_YEAR') THEN
        l_sql := 'BEGIN :1 := FII_TIME_API.ent_pyr_end(:2);  END;';  -- Previous Enterprise year end date
        EXECUTE IMMEDIATE l_sql USING OUT x_prev_asofdate , IN l_asof_date;
     END IF;
     IF (p_dimensionlevel = 'TIME+FII_TIME_DAY') THEN
        x_prev_asofdate := add_months(l_asof_date, -12);
     END IF;

     IF ( p_dimensionlevel = 'TIME+FII_ROLLING_WEEK' OR
          p_dimensionlevel = 'TIME+FII_ROLLING_MONTH' OR
          p_dimensionlevel = 'TIME+FII_ROLLING_QTR' OR
          p_dimensionlevel = 'TIME+FII_ROLLING_YEAR') THEN
         x_prev_asofdate := add_months(l_asof_date, -12);
     END IF;

  END IF;

  IF (x_prev_asofdate IS NULL OR (LENGTH(x_prev_asofdate) = 0)) THEN
    BIS_PMV_TIME_LEVELS_PVT.get_bis_common_start_date
    ( x_prev_asof_date => x_prev_asofdate
    , x_return_Status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);
  WHEN OTHERS THEN
    IF (x_prev_asofdate IS NULL or (LENGTH(x_prev_asofdate) = 0)) THEN
      BIS_PMV_TIME_LEVELS_PVT.get_bis_common_start_date
      ( x_prev_asof_date => x_prev_asofdate
      , x_return_Status  => x_return_status
      , x_msg_count      => x_msg_count
      , x_msg_data       => x_msg_data );
    END IF;
    FND_MSG_PUB.count_and_get ( p_count => x_msg_count, p_data => x_msg_data);
END get_previous_asofdate;

/* The following function returns measure name by taking RegionCode,Attribute1, Attribute2
   as parameters.
*/

FUNCTION get_measure_name(
  p_region_code IN VARCHAR2,
  p_attribute1 IN VARCHAR2,
  p_attribute2 IN VARCHAR2)
RETURN VARCHAR2
IS
  l_measure_name bis_indicators_vl.name%type;
BEGIN
  IF (p_attribute1 = BIS_AK_REGION_PUB.C_MEASURE_NO_TARGET OR p_attribute1 = BIS_AK_REGION_PUB.C_MEASURE) THEN
    SELECT
      bis_measures.name INTO l_measure_name
    FROM
      bis_indicators_vl bis_measures
    WHERE
      bis_measures.short_name = p_attribute2;
  ELSIF (p_attribute1 = BIS_AK_REGION_PUB.C_CHANGE_MEASURE_NO_TARGET OR p_attribute1 = BIS_AK_REGION_PUB.C_COMPARE_TO_MEASURE_NO_TARGET OR p_attribute1 = BIS_AK_REGION_PUB.C_PERCENT_OF_TOTAL) THEN
    SELECT
      bis_measures.name INTO l_measure_name
    FROM
      bis_indicators_vl bis_measures,
      ak_region_items_vl akRegionItems
    WHERE
      akRegionItems.region_code = p_region_code AND
      akRegionItems.attribute_code = p_attribute2 AND
      akRegionItems.attribute2 = bis_measures.short_name;
  END IF;
RETURN l_measure_name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_measure_name;

PROCEDURE get_next_measure_data_source
( p_measure_short_name     IN   VARCHAR2
, p_current_region_code    IN   VARCHAR2
, p_current_region_appid   IN   NUMBER
, x_next_region_code       OUT  NOCOPY VARCHAR2
, x_next_region_appid      OUT  NOCOPY NUMBER
, x_next_source_attrcode   OUT  NOCOPY VARCHAR2
, x_next_source_appid      OUT  NOCOPY NUMBER
, x_next_compare_attrcode  OUT  NOCOPY VARCHAR2
, x_next_compare_appid     OUT  NOCOPY NUMBER
, x_next_function_name     OUT  NOCOPY VARCHAR2 --Bug 5495960
, x_next_enable_link       OUT  NOCOPY VARCHAR2 --Bug 5495960
)
IS
 --////////Filtering out the Simulation reports from the next available report ////////////////

  CURSOR c_next_ds IS
    SELECT region_code, region_application_id, attribute_code, attribute_application_id
      FROM ak_region_items
      WHERE attribute2 = p_measure_short_name
      AND   attribute1 IN ('MEASURE_NOTARGET', 'MEASURE')
      AND   NOT(region_code = p_current_region_code AND region_application_id = p_current_region_appid)
      AND   NVL(BIS_REPORT_PUB.getRegionDataSourceType(p_current_region_code),' ') <> 'MULTIPLE_DATA_SOURCE'
      AND   BIS_UTIL.Is_Simulation_Report(region_code) <> FND_API.G_TRUE
      AND   rownum < 2 ;

  CURSOR c_compare_to_col(p_region_code VARCHAR2, p_region_appid NUMBER, p_measure_attrcode VARCHAR2) IS
    SELECT attribute_code, attribute_application_id
      FROM ak_region_items
      WHERE region_code = p_region_code
      AND   region_application_id = p_region_appid
      AND   attribute1 IN ('COMPARE_TO_MEASURE', 'COMPARE_TO_MEASURE_NO_TARGET')
      AND   attribute2 = p_measure_attrcode ;
BEGIN

  IF (c_next_ds%ISOPEN) THEN
    CLOSE c_next_ds;
  END IF;

  OPEN c_next_ds;
  FETCH c_next_ds INTO x_next_region_code, x_next_region_appid, x_next_source_attrcode, x_next_source_appid;
  IF (c_next_ds%FOUND) THEN
    IF (c_compare_to_col%ISOPEN) THEN
      CLOSE c_compare_to_col;
    END IF;

    OPEN c_compare_to_col(x_next_region_code, x_next_region_appid, x_next_source_attrcode);
    FETCH c_compare_to_col INTO x_next_compare_attrcode, x_next_compare_appid;
    CLOSE c_compare_to_col;

    x_next_function_name := get_form_function_from_region(x_next_region_code);
    IF x_next_function_name IS NOT NULL THEN
      x_next_enable_link := 'Y';
    END IF;
  END IF;

  CLOSE c_next_ds;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_next_ds%ISOPEN) THEN
      CLOSE c_next_ds;
    END IF;
    IF (c_compare_to_col%ISOPEN) THEN
      CLOSE c_compare_to_col;
    END IF;
END get_next_measure_data_source;

/* The following functions returns a comma seperated list of dimensions
    for which a particular dimension object is associated */

FUNCTION get_dimen_by_dim_object
( p_dim_lev_short_name  IN VARCHAR2
) RETURN VARCHAR2
IS
  l_dim_names     VARCHAR2(5000);
  CURSOR c_dimensions IS
    SELECT dim_group.name
    FROM
      bsc_sys_dim_levels_by_group dim_lev_by_group,
      bsc_sys_dim_levels_vl dim_lev,
      bsc_sys_dim_groups_vl dim_group
    WHERE
      dim_lev.short_name=p_dim_lev_short_name
      AND dim_lev_by_group.dim_level_id = dim_lev.dim_level_id
      AND dim_lev_by_group.dim_group_id = dim_group.dim_group_id
      AND bis_util.is_seeded(dim_group.created_by,'Y','N') = 'Y';

BEGIN
  FOR c_dimensions_rec IN c_dimensions LOOP
    IF (l_dim_names IS NULL) THEN
      l_dim_names := c_dimensions_rec.name;
    ELSE
      l_dim_names := l_dim_names || ', ' || c_dimensions_rec.name;
    END IF;
  END LOOP;
  RETURN l_dim_names;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_dimen_by_dim_object;


/******************************************
Get_Default_Value_From_Params : API is used to get the default values of
                                the dimension objects from parameters which are stored
                                in form function.
Input : p_parameters  : corresponds to the parameter column value
        p_attribute2  : attribute2 value corresponding to dim+dim_obj
Creator : ashankar 26-03-07
/******************************************/

FUNCTION Get_Default_Value_From_Params
(
   p_parameters     IN    FND_FORM_FUNCTIONS_VL.parameters%TYPE
 , p_attribute2     IN    AK_REGION_ITEMS_VL.attribute2%TYPE
)RETURN VARCHAR2 IS

 l_default_value     VARCHAR2(1000);
 l_posPParamsStart   NUMBER;
 l_posAttr2          NUMBER;
 l_posPParamsEnd     NUMBER;
 l_start             NUMBER;
 l_end               NUMBER;

BEGIN
  l_default_value :=NULL;

  IF((p_parameters IS NOT NULL) AND (p_attribute2 IS NOT NULL)) THEN

    l_posPParamsStart := INSTR(p_parameters,BIS_UTIL.C_FF_PARAM_PARAMETERS);
    IF(l_posPParamsStart >=0) THEN
      l_posAttr2 := INSTR(p_parameters,REPLACE(p_attribute2,BIS_UTIL.C_CHAR_PLUS,BIS_UTIL.C_CHAR_CARROT) || BIS_UTIL.C_CHAR_AT_THE_RATE,l_posPParamsStart);
      l_posPParamsEnd := INSTR(p_parameters,BIS_UTIL.C_PARAM_SEP,l_posAttr2);

      IF(l_posPParamsEnd=0)THEN
       l_posPParamsEnd := LENGTH(p_parameters);
      END IF;

      IF(l_posAttr2 >0 AND l_posAttr2 < l_posPParamsEnd) THEN

        l_start := INSTR(p_parameters,BIS_UTIL.C_CHAR_AT_THE_RATE,l_posAttr2) +1;
        l_end   := INSTR(p_parameters,BIS_UTIL.C_CHAR_TILDE,l_posAttr2);
        IF(l_end =0)THEN
         l_end :=l_posPParamsEnd;
        END IF;

        IF(l_end =l_start) THEN
         l_end := 1;
        ELSE
         l_end :=l_end-l_start;
        END IF;

        l_default_value :=SUBSTR(p_parameters,l_start,l_end);
      END IF;
    END IF;
  END IF;
  RETURN l_default_value;
EXCEPTION
 WHEN OTHERS THEN
  RETURN NULL;
END Get_Default_Value_From_Params;

END BIS_UTIL;

/
