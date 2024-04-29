--------------------------------------------------------
--  DDL for Package Body BIS_CONCURRENT_MANAGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CONCURRENT_MANAGER_PVT" AS
/* $Header: BISVCONB.pls 120.1 2005/11/18 05:50:50 ankgoel noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVCONB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing concurrent requests
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | June 2000    irchen creation
REM | 17-SEP-2002  rchandra port fix for 2562678 to 4004
REM | 30-OCT-2002  rchandra  fix for 2512994
REM | 20-JAN-2003  mahrao    fix for bug# 2649486
REM | 21-MAR-2003  rchandra  if frequency is ONCE , the resubmit interval
REM |                        unit code and end date are returned as null
REM |                        which are displayed on screen.  In this case the
REM |                        code is changed to return once , and  end date
REM |                        the same as start date, for bug 2834133
REM | 21-MAR-2003 sugopal    It should not be able to schedule an alert again
REM |                        when it is running. Added condition to check for
REM |                        the same - bug#2834155
REM | 26-MAR-2003 sugopal    Added the constant C_CONC_REQUEST_NORMAL
REM |                        for the bug#2871593
REM | 09-NOV-2003 ankgoel    Modified for bug #3153902		            |
REM | 14-NOV-2003 ankgoel    Modified for bug# 3153918		            |
REM | 15-Dec-2003 arhegde enh# 3148615 Change/Target based alerting.        |
REM | 25-Jan-2004 ankgoel bug# 3083617 Modified date format of next run date|
REM | 18-Nov-2005 ankgoel bug# 4675515 DBI Actuals for previous time period |
REM +=======================================================================+
*/


C_CONC_REQUEST_NORMAL CONSTANT VARCHAR2(30) := 'NORMAL';

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

  l_request_id NUMBER;
  l_Concurrent_Request_tbl Fnd_Concurrent_Requests_tbl;
  l_Param_Set_tbl          BIS_PMF_ALERT_REG_PUB.parameter_set_tbl_type;
  l_phase      VARCHAR2(32000);
  l_status     VARCHAR2(32000);
  l_debug      VARCHAR2(32000);
  l_debug2     VARCHAR2(32000);
  l_dev_phase  VARCHAR2(32000);
  l_dev_status VARCHAR2(32000);
  l_message    VARCHAR2(32000);
  l_request_status BOOLEAN;
  l_request_scheduled BOOLEAN := FALSE;

BEGIN

  BIS_UTILITIES_PUB.put_line(p_text =>'Managing alert registrations (concurrent manager mode)');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Get_All_Requests
  ( p_Param_Set_rec           => p_Param_Set_rec
  , x_Concurrent_Request_tbl  => l_Concurrent_Request_tbl
  , x_return_status           => x_return_status
  );

  IF l_Concurrent_Request_tbl.COUNT > 0 THEN
    -- BIS_UTILITIES_PUB.put_line(p_text =>'l_debug_text :'||l_debug_text);
    null;
  ELSE
    -- BIS_UTILITIES_PUB.put_line(p_text =>'l_debug_text :'||l_debug_text);
    null;
  END IF;

  FOR i IN 1..l_Concurrent_Request_tbl.COUNT LOOP
    l_request_status := FND_CONCURRENT.GET_REQUEST_STATUS
                       ( request_id  => l_Concurrent_Request_tbl(i).request_id
                       , phase       => l_phase
                       , status      => l_status
                       , dev_phase   => l_dev_phase
                       , dev_status  => l_dev_status
                       , message     => l_message
                       );

    IF  (((l_dev_phase = G_CONC_REQUEST_PENDING) OR (l_dev_phase = G_CONC_REQUEST_RUNNING))
    AND  ((l_dev_status = G_CONC_REQUEST_SCHEDULED) OR (l_dev_status = C_CONC_REQUEST_NORMAL)))
    THEN
      l_request_scheduled := TRUE;
      l_request_id := l_Concurrent_Request_tbl(i).request_id;
      BIS_UTILITIES_PUB.put_line(p_text =>'Concurrent request phase: '||l_dev_phase
      ||', status: '||l_dev_status);
      exit;
    END IF;
  END LOOP;

  IF l_request_scheduled THEN
    x_request_scheduled := FND_API.G_TRUE;
  ELSE
    x_request_scheduled := FND_API.G_FALSE;

    IF p_Param_Set_Rec.Target_Level_id IS NOT NULL THEN
      BIS_UTILITIES_PUB.put_line(p_text =>'Managing request by target level: '
      ||p_Param_Set_Rec.Target_Level_id );

      IF (p_param_set_rec.notify_owner_flag <> 'N') THEN
        BIS_PMF_ALERT_REG_PVT.Retrieve_Parameter_set
        ( p_api_version      => 1.0
        , p_Param_Set_Rec    => p_param_set_rec
        , x_Param_Set_tbl    => l_param_set_tbl
        , x_return_status    => x_return_status
        , x_error_Tbl        => x_error_Tbl
        );
      END IF;
    ELSIF p_Param_Set_Rec.performance_measure_id IS NOT NULL
    AND p_Param_Set_Rec.target_level_id IS NULL
    THEN
      BIS_UTILITIES_PUB.put_line(p_text =>'Managing request by measure: '
      ||p_Param_Set_Rec.performance_measure_id
      ||', time: '||p_Param_Set_Rec.time_dimension_level_id);

      BIS_PMF_ALERT_REG_PVT.Retrieve_Parameter_set
      ( p_api_version             => 1.0
      , p_measure_id              => p_Param_Set_Rec.performance_measure_id
      , p_time_dimension_level_id => p_Param_Set_Rec.time_dimension_level_id
      , x_Param_Set_tbl           => l_param_set_tbl
      , x_return_status           => x_return_status
      , x_error_Tbl               => x_error_Tbl
      );
    END IF;

    FOR i IN 1..l_param_set_tbl.COUNT LOOP
      BIS_UTILITIES_PUB.put_line(p_text =>'Deleting '||i||'th parameter set. Registration id: '
      ||l_param_set_tbl(i).registration_id);

      BEGIN
        BIS_PMF_ALERT_REG_PVT.Delete_Parameter_Set
        ( p_registration_ID => l_Param_Set_tbl(i).registration_id
        , x_return_status   => x_return_status
        );
/* 2562678 request alert was not working as the users were removed
        WF_DIRECTORY.RemoveUsersFromAdHocRole
        ( role_name => p_Param_Set_rec.Notifiers_Code
        );
        WF_DIRECTORY.SetAdHocRoleExpiration
        ( role_name => p_Param_Set_rec.Notifiers_Code
        , expiration_date => sysdate-1
        );
2562678 */
      EXCEPTION
        WHEN OTHERS THEN
        BIS_UTILITIES_PUB.put_line(p_text =>i||'th param set did not get deleted.');
      END;
      BIS_UTILITIES_PUB.put_line(p_text =>i||'th deleted.');
    END LOOP;

  END IF;

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
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Manage_Alert_Registrations'
    , p_error_table       => x_error_tbl
    , x_error_table       => x_error_tbl
    );
END Manage_Alert_Registrations;


PROCEDURE Get_All_Requests
( p_Param_Set_rec         IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_Concurrent_Request_tbl    OUT NOCOPY Fnd_Concurrent_Requests_Tbl
, x_return_status             OUT NOCOPY VARCHAR2
)
IS

  l_Concurrent_Request_tbl Fnd_Concurrent_Requests_tbl;
  l_Concurrent_Request_Rec Fnd_Concurrent_Requests%ROWTYPE;
  l_target_level_rec       bisbv_target_levels%ROWTYPE;
  l_Concurrent_Program_ID NUMBER;
  l_Application_ID        NUMBER;
  l_request_ID         Fnd_Concurrent_Requests.REQUEST_ID%TYPE;
  l_Resubmit_Time      Fnd_Concurrent_Requests.RESUBMIT_TIME%TYPE;
  l_Resubmit_End_Date  Fnd_Concurrent_Requests.RESUBMIT_END_DATE%TYPE;
  l_Resubmit_Interval  Fnd_Concurrent_Requests.RESUBMIT_INTERVAL%TYPE;
  l_Resubmit_Interval_Unit_Code
    Fnd_Concurrent_Requests.RESUBMIT_INTERVAL_UNIT_CODE%TYPE;
  l_Resubmit_Interval_Type_Code
    Fnd_Concurrent_Requests.RESUBMIT_INTERVAL_TYPE_CODE%TYPE;

  l_count NUMBER := 0;

  CURSOR cr_conc_req_tl IS
  SELECT *
  FROM fnd_concurrent_requests
  WHERE Program_Application_ID = l_Application_ID
    And Concurrent_Program_ID  = l_Concurrent_Program_ID
    and argument3 = p_param_set_rec.target_level_id
    and argument5 = p_param_set_rec.plan_id
    and ((argument8 is null and p_param_set_rec.PARAMETER1_VALUE is null)
     or  (argument8 = p_param_set_rec.PARAMETER1_VALUE)
    )
    and ((argument11  is null and p_param_set_rec.PARAMETER2_VALUE IS NULL)
    or (argument11 = p_param_set_rec.PARAMETER2_VALUE)
    )
    and ((argument14  is null and p_param_set_rec.PARAMETER3_VALUE IS NULL)
    or (argument14 = p_param_set_rec.PARAMETER3_VALUE)
    )
    and ((argument17  is null and p_param_set_rec.PARAMETER4_VALUE IS NULL)
    or (argument17 = p_param_set_rec.PARAMETER4_VALUE)
    )
    and ((argument20  is null and p_param_set_rec.PARAMETER5_VALUE IS NULL)
    or (argument20 = p_param_set_rec.PARAMETER5_VALUE)
    )
    and ((argument23  is null and p_param_set_rec.PARAMETER6_VALUE IS NULL)
    or (argument23 = p_param_set_rec.PARAMETER6_VALUE)
    )
    order by request_id desc
    -- order by ACTUAL_START_DATE desc
    ;

  CURSOR cr_conc_req_meas IS
  SELECT *
  FROM fnd_concurrent_requests
  WHERE Program_Application_ID = l_Application_ID
    And Concurrent_Program_ID  = l_Concurrent_Program_ID
    and argument1 = p_param_set_rec.performance_measure_id
    and (p_param_set_rec.TIME_DIMENSION_LEVEL_ID is null
--    and ((argument7 is null
--          and p_param_set_rec.TIME_DIMENSION_LEVEL_ID is null)
     or argument7 = p_param_set_rec.TIME_DIMENSION_LEVEL_ID
    )
    and argument3 IS NULL
    order by request_id desc
  --  order by ACTUAL_START_DATE desc
    ;

  l_debug_text VARCHAR2(32000);

BEGIN

    BIS_UTILITIES_PUB.put_line(p_text =>'Getting request information. measure id: '
    ||p_param_set_rec.performance_measure_id||', target level id: '
    ||p_param_set_rec.target_level_id
    );

  IF p_param_set_rec.target_level_id IS NOT NULL THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving target level information ');

    Get_PMF_Concurrent_Program_ID
    ( x_Concurrent_Program_ID  => l_Concurrent_Program_ID
    , x_Application_ID         => l_Application_ID
    );

    BEGIN
      select * into l_target_level_rec
      from bisbv_target_levels
      where target_level_id = p_param_set_rec.target_level_id;

      BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved target level: '
          ||l_target_level_rec.TARGET_LEVEL_SHORT_NAME);
    EXCEPTION
      WHEN OTHERS THEN
        BIS_UTILITIES_PUB.put_line(p_text =>'exception while getting target level');
        return;
    END;

    FOR cr_conc IN cr_conc_req_tl LOOP
      l_count := l_count+1;
      l_Concurrent_Request_Rec := cr_conc;
      l_Concurrent_Request_tbl(l_Concurrent_Request_tbl.COUNT+1)
        := l_Concurrent_Request_Rec;

      /*
      l_debug_text := l_debug_text ||'count: '
      ||l_count||',    req id: '
      ||l_Concurrent_Request_Rec.request_id||',    start: '
      ||l_Concurrent_Request_Rec.ACTUAL_START_DATE||',    end: '
      ||l_Concurrent_Request_Rec.ACTUAL_COMPLETION_DATE
      ;
      BIS_UTILITIES_PUB.put_line(p_text =>'conc target level: '||l_Concurrent_Request_Rec.argument3);
      BIS_UTILITIES_PUB.put_line(p_text =>'conc plan: '||l_Concurrent_Request_Rec.argument5);
      BIS_UTILITIES_PUB.put_line(p_text =>'conc org id: '||l_Concurrent_Request_Rec.argument8);
      BIS_UTILITIES_PUB.put_line(p_text =>'conc time level: '||l_Concurrent_Request_Rec.argument9);
      BIS_UTILITIES_PUB.put_line(p_text =>'conc time id: '||l_Concurrent_Request_Rec.argument11);
      BIS_UTILITIES_PUB.put_line(p_text =>'param3: ' || l_Concurrent_Request_Rec.argument3 );
      BIS_UTILITIES_PUB.put_line(p_text =>'param6: ' || l_Concurrent_Request_Rec.argument6 );
      BIS_UTILITIES_PUB.put_line(p_text =>'param7 : '|| l_Concurrent_Request_Rec.argument7 );
      BIS_UTILITIES_PUB.put_line(p_text =>'param8: ' || l_Concurrent_Request_Rec.argument8 );
      BIS_UTILITIES_PUB.put_line(p_text =>'param9 : '|| l_Concurrent_Request_Rec.argument9 );
      BIS_UTILITIES_PUB.put_line(p_text =>'param10: '|| l_Concurrent_Request_Rec.argument10);
      BIS_UTILITIES_PUB.put_line(p_text =>'param11: '|| l_Concurrent_Request_Rec.argument11);
      BIS_UTILITIES_PUB.put_line(p_text =>'param12: '|| l_Concurrent_Request_Rec.argument12);
      BIS_UTILITIES_PUB.put_line(p_text =>'param11: '|| l_Concurrent_Request_Rec.argument11);
      BIS_UTILITIES_PUB.put_line(p_text =>'param12: '|| l_Concurrent_Request_Rec.argument12);
      BIS_UTILITIES_PUB.put_line(p_text =>'param14: '|| l_Concurrent_Request_Rec.argument14);
      BIS_UTILITIES_PUB.put_line(p_text =>'param15: '|| l_Concurrent_Request_Rec.argument15);
      BIS_UTILITIES_PUB.put_line(p_text =>'param17: '|| l_Concurrent_Request_Rec.argument17);
      BIS_UTILITIES_PUB.put_line(p_text =>'param18: '|| l_Concurrent_Request_Rec.argument18);
      BIS_UTILITIES_PUB.put_line(p_text =>'param20: '|| l_Concurrent_Request_Rec.argument20);
      BIS_UTILITIES_PUB.put_line(p_text =>'param21: '|| l_Concurrent_Request_Rec.argument21);
      BIS_UTILITIES_PUB.put_line(p_text =>'param23: '|| l_Concurrent_Request_Rec.argument23);
      BIS_UTILITIES_PUB.put_line(p_text =>'param24: '|| l_Concurrent_Request_Rec.argument24);
    */

    END LOOP;

  ELSIF p_param_set_rec.performance_measure_id IS NOT NULL THEN

    Get_PMF_Concurrent_Program_ID
    ( p_main_request_flag      => FND_API.G_TRUE
    , x_Concurrent_Program_ID  => l_Concurrent_Program_ID
    , x_Application_ID         => l_Application_ID
    );

    BIS_UTILITIES_PUB.put_line(p_text =>'Retrieving measure information ');
    FOR cr_conc IN cr_conc_req_meas LOOP
      l_count := l_count+1;
      l_Concurrent_Request_Rec := cr_conc;
      l_Concurrent_Request_tbl(l_Concurrent_Request_tbl.COUNT+1)
        := l_Concurrent_Request_Rec;

      /*
       BIS_UTILITIES_PUB.put_line(p_text =>'conc measure: '||l_Concurrent_Request_Rec.argument1);
       BIS_UTILITIES_PUB.put_line(p_text =>'conc time level: '||l_Concurrent_Request_Rec.argument7);

      l_debug_text := l_debug_text
        ||'param1 : '|| l_Concurrent_Request_Rec.argument1 ;
      l_debug_text := l_debug_text
        ||'param3 : '|| l_Concurrent_Request_Rec.argument3 ;
      l_debug_text := l_debug_text
        ||'param7 : '|| l_Concurrent_Request_Rec.argument7 ;
      BIS_UTILITIES_PUB.put_line(p_text =>'param8: ' || l_Concurrent_Request_Rec.argument8 );
      BIS_UTILITIES_PUB.put_line(p_text =>'param9 : '|| l_Concurrent_Request_Rec.argument9 );
      BIS_UTILITIES_PUB.put_line(p_text =>'param10: '|| l_Concurrent_Request_Rec.argument10);
      BIS_UTILITIES_PUB.put_line(p_text =>'param11: '|| l_Concurrent_Request_Rec.argument11);
      BIS_UTILITIES_PUB.put_line(p_text =>'param12: '|| l_Concurrent_Request_Rec.argument12);
      BIS_UTILITIES_PUB.put_line(p_text =>'param14: '|| l_Concurrent_Request_Rec.argument14);
      BIS_UTILITIES_PUB.put_line(p_text =>'param15: '|| l_Concurrent_Request_Rec.argument15);
      BIS_UTILITIES_PUB.put_line(p_text =>'param17: '|| l_Concurrent_Request_Rec.argument17);
      BIS_UTILITIES_PUB.put_line(p_text =>'param18: '|| l_Concurrent_Request_Rec.argument18);
      BIS_UTILITIES_PUB.put_line(p_text =>'param20: '|| l_Concurrent_Request_Rec.argument20);
      BIS_UTILITIES_PUB.put_line(p_text =>'param21: '|| l_Concurrent_Request_Rec.argument21);
      BIS_UTILITIES_PUB.put_line(p_text =>'param23: '|| l_Concurrent_Request_Rec.argument23);
      BIS_UTILITIES_PUB.put_line(p_text =>'param24: '|| l_Concurrent_Request_Rec.argument24);

      l_debug_text := l_debug_text ||'count: '
      ||l_count||',    req id: '
      ||l_Concurrent_Request_Rec.request_id||',    start: '
      ||l_Concurrent_Request_Rec.ACTUAL_START_DATE||',    end: '
      ||l_Concurrent_Request_Rec.ACTUAL_COMPLETION_DATE
      ;
      */

    END LOOP;

  END IF;

  x_return_status := l_debug_text;
  x_Concurrent_Request_tbl := l_Concurrent_Request_tbl;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Error in Get_All_Requests: '||SQLERRM);

END Get_All_Requests;

Procedure Get_PMF_Concurrent_Program_ID
( p_main_request_flag      IN VARCHAR2 := FND_API.G_FALSE
, x_Concurrent_Program_ID  OUT NOCOPY NUMBER
, x_Application_ID         OUT NOCOPY NUMBER
)
IS
  l_conc_program_name VARCHAR2(32000);
BEGIN

  IF p_main_request_flag = FND_API.G_TRUE THEN
    l_conc_program_name := G_ALERT_PROGRAM;
  ELSE
    l_conc_program_name := G_ALERT_PROGRAM_PVT;
  END IF;

  Select Concurrent_Program_ID, P.Application_ID
  Into x_Concurrent_Program_ID, x_Application_ID
  From Fnd_Concurrent_Programs P, Fnd_Application A
  Where Concurrent_Program_Name  = l_conc_program_name
  And P.Application_ID           = A.Application_ID
  And A.Application_Short_Name
    = BIS_UTILITIES_PVT.G_BIS_APPLICATION_SHORT_NAME;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Error in Get_PMF_Concurrent_Program_ID: '||SQLERRM);

END Get_PMF_Concurrent_Program_ID;

Procedure Submit_Concurrent_Request
( p_Concurrent_Request_Tbl IN PMF_Request_Tbl_Type
, x_request_id_tbl         OUT NOCOPY BIS_UTILITIES_PUB.BIS_VARCHAR_TBL
, x_errbuf                 OUT NOCOPY VARCHAR2
, x_retcode                OUT NOCOPY VARCHAR2
)
IS

  l_request_id VARCHAR2(32000);

BEGIN

  FOR i IN 1..p_Concurrent_Request_Tbl.COUNT LOOP
    Submit_Concurrent_Request
    ( p_Concurrent_Request_rec => p_Concurrent_Request_tbl(i)
    , x_request_id             => l_request_id
    , x_errbuf                 => x_errbuf
    , x_retcode                => x_retcode
    );
    x_request_id_tbl(x_request_id_tbl.COUNT+1) := l_request_id;
  END LOOP;

END Submit_Concurrent_Request;

Procedure Submit_Concurrent_Request
( p_Concurrent_Request_rec IN PMF_Request_rec_Type
, x_request_id             OUT NOCOPY VARCHAR2
, x_errbuf                 OUT NOCOPY VARCHAR2
, x_retcode                OUT NOCOPY VARCHAR2
)
IS

  l_request_number NUMBER;
  l_time_format    VARCHAR2(200);
  l_req_time_format VARCHAR2(200) := 'DD-MON-YYYY HH24:MI:SS';
BEGIN
  /*
  BIS_UTILITIES_PUB.put_line(p_text =>'concurrent request '||i||' of '
        ||p_Concurrent_Request_Tbl.COUNT||' being submitted');
  BIS_UTILITIES_PUB.put_line(p_text =>'Organization id: '||p_Concurrent_Request_Tbl(i).argument8);
  BIS_UTILITIES_PUB.put_line(p_text =>'time id: '||p_Concurrent_Request_Tbl(i).argument9;
  BIS_UTILITIES_PUB.put_line(p_text =>'dim1 id: '||p_Concurrent_Request_Tbl(i).argument14);
  BIS_UTILITIES_PUB.put_line(p_text =>'dim2 id: '||p_Concurrent_Request_Tbl(i).argument17);
  BIS_UTILITIES_PUB.put_line(p_text =>'target_id: '||p_Concurrent_Request_Tbl(i).argument27);
  */

  --BIS_UTILITIES_PUB.put_line(p_text =>'program: '||p_concurrent_Request_rec.program);
  -- use teh ICX date format mask while submitting request too.
  l_time_format :=  NVL(fnd_profile.value_Specific('ICX_DATE_FORMAT_MASK'),'DD-MON-YYYY') ||' HH24:MI:SS';

  IF p_concurrent_Request_rec.program = G_ALERT_PROGRAM THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'argument1: '||p_concurrent_Request_rec.argument1);
    BIS_UTILITIES_PUB.put_line(p_text =>'argument2: '||p_concurrent_Request_rec.argument2);
    BIS_UTILITIES_PUB.put_line(p_text =>'argument9: '||p_concurrent_Request_rec.argument9);
    BIS_UTILITIES_PUB.put_line(p_text =>'argument40: '||p_concurrent_Request_rec.argument40);
    BIS_UTILITIES_PUB.put_line(p_text =>'argument42: '||p_concurrent_Request_rec.argument42);

    -- Setting unused columns to null
    --
    l_request_number :=

    FND_REQUEST.SUBMIT_REQUEST
    ( p_concurrent_Request_rec.application_short_name
    , p_concurrent_Request_rec.program
    , p_concurrent_Request_rec.description
    , to_char(to_date(p_concurrent_Request_rec.start_time , l_time_format),l_req_time_format )
    , false
    , p_concurrent_Request_rec.argument1  -- measure id
    , p_concurrent_Request_rec.argument2  -- measure short name
    , NULL
    , NULL
    , NULL
    , NULL
    , p_concurrent_Request_rec.argument9 -- time level
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , NULL
    , p_concurrent_Request_rec.argument40 -- alert type
    , NULL
    , p_concurrent_Request_rec.argument42 -- current row
    , p_concurrent_Request_rec.argument43  -- p_alert_based_on (target or current)
    );

  ELSIF p_concurrent_Request_rec.program = G_ALERT_PROGRAM_PVT THEN

    -- Setting unused columns to null
    --
    l_request_number :=

    FND_REQUEST.SUBMIT_REQUEST
    ( p_concurrent_Request_rec.application_short_name
    , p_concurrent_Request_rec.program
    , p_concurrent_Request_rec.description
    , p_concurrent_Request_rec.start_time
    , false
    , p_concurrent_Request_rec.argument1   -- measure_id
    , p_concurrent_Request_rec.argument2   -- measure_short_name
    , p_concurrent_Request_rec.argument3   -- target_level_id
    , p_concurrent_Request_rec.argument4   -- target_level_short_name
    , p_concurrent_Request_rec.argument5   -- plan_id
    , NULL                                 -- org_level_id
    , NULL				   -- org_level_short_name
    , NULL                                 -- organization_id
    , p_concurrent_Request_rec.argument9   -- time_level_id
    , NULL				   -- time_level_short_name
    , NULL                                 -- time_level_value_id
    , p_concurrent_Request_rec.argument12  -- dim1_level_id
    , NULL				   -- dim1_level_short_name
    , p_concurrent_Request_rec.argument14  -- dim1_level_value_id
    , p_concurrent_Request_rec.argument15  -- dim2_level_id
    , NULL				   -- dim2_level_short_name
    , p_concurrent_Request_rec.argument17  -- dim2_level_value_id
    , p_concurrent_Request_rec.argument18  -- dim3_level_id
    , NULL 				   -- dim3_level_short_name
    , p_concurrent_Request_rec.argument20  -- dim3_level_value_id
    , p_concurrent_Request_rec.argument21  -- dim4_level_id
    , NULL 				   -- dim4_level_short_name
    , p_concurrent_Request_rec.argument23  -- dim4_level_value_id
    , p_concurrent_Request_rec.argument24  -- dim5_level_id
    , NULL                                 -- dim5_level_short_name
    , p_concurrent_Request_rec.argument26  -- dim5_level_value_id
    , p_concurrent_Request_rec.argument27  -- dim6_level_id
    , NULL                                 -- dim6_level_short_name
    , p_concurrent_Request_rec.argument29  -- dim6_level_value_id
    , p_concurrent_Request_rec.argument30  -- dim7_level_id
    , NULL				   -- dim7_level_short_name
    , p_concurrent_Request_rec.argument32  -- dim7_level_value_id
    , p_concurrent_Request_rec.argument33  -- target_id
    , NULL                                 -- target
    , NULL                                 -- actual_id
    , NULL                                 -- actual
    , NULL				   -- primary_dim_level_id
    , NULL				   -- primary_dim_level_short_name
    , NULL				   -- notify_set
    , p_concurrent_Request_rec.argument40  -- alert_type
    , NULL                                 -- alert_level
    , p_concurrent_Request_rec.argument43  -- p_alert_based_on (target or current)
    , p_concurrent_Request_rec.argument42  -- p_current_row (current or previous)
    );
  ELSE
    BIS_UTILITIES_PUB.put_line(p_text =>'Not a valid PMF concurrent program');
    l_request_number := 0;
  END IF;

  COMMIT;

  IF ( (l_request_number IS NULL ) or ( l_request_number = 0) ) THEN -- 2568688
    x_request_id := l_request_number;
    x_errbuf := FND_MESSAGE.GET;
  ELSE
    x_request_id := to_char(l_request_number);
  END IF;


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_errbuf := 'Request: '||to_char(l_request_number)
	                     ||', Error1: '||SQLERRM
	                     || 'Error from FND_REQUEST.SUBMIT_REQUEST : ' || FND_MESSAGE.GET;
      x_retcode := SQLCODE;

      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_errbuf := 'Request: '||to_char(l_request_number)
                             ||', Error2: '||SQLERRM
                             || 'Error from FND_REQUEST.SUBMIT_REQUEST : ' || FND_MESSAGE.GET;
      x_retcode := SQLCODE;
      RETURN;
   when others then
      x_errbuf := 'Request: '||to_char(l_request_number)
                             ||', Error3: '||SQLERRM
                             || 'Error from FND_REQUEST.SUBMIT_REQUEST : ' || FND_MESSAGE.GET;
      x_retcode := SQLCODE;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_Alert_Request'
      );
      RETURN;

END Submit_Concurrent_Request;

Procedure Get_Request_Schedule_Info
( p_measure_id            IN VARCHAR2 := NULL
, p_target_level_id       IN VARCHAR2 := NULL
, p_time_level_id         IN VARCHAR2 := NULL
, p_plan_id               IN VARCHAR2 := NULL
, p_parameter1_value      IN VARCHAR2 := NULL
, p_parameter2_value      IN VARCHAR2 := NULL
, p_parameter3_value      IN VARCHAR2 := NULL
, p_parameter4_value      IN VARCHAR2 := NULL
, p_parameter5_value      IN VARCHAR2 := NULL
, p_parameter6_value      IN VARCHAR2 := NULL
, p_parameter7_value      IN VARCHAR2 := NULL
, x_schedule_date         OUT NOCOPY VARCHAR2
, x_schedule_time         OUT NOCOPY VARCHAR2
, x_schedule_unit         OUT NOCOPY VARCHAR2
, x_schedule_freq         OUT NOCOPY VARCHAR2
, x_schedule_freq_unit    OUT NOCOPY VARCHAR2
, x_schedule_end_date     OUT NOCOPY VARCHAR2
, x_schedule_end_time     OUT NOCOPY VARCHAR2
, x_next_run_date         OUT NOCOPY VARCHAR2
, x_next_run_time         OUT NOCOPY VARCHAR2
, x_description           OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

  l_Param_Set_Rec BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type;

BEGIN

  IF p_measure_id IS NOT NULL THEN
    l_Param_Set_Rec.performance_measure_id  := TO_NUMBER(p_measure_id);
  END IF;
  IF p_target_level_id IS NOT NULL THEN
    l_Param_Set_Rec.target_level_id         := TO_NUMBER(p_target_level_id);
  END IF;
  IF p_time_level_id IS NOT NULL THEN
    l_Param_Set_Rec.time_dimension_level_id := TO_NUMBER(p_time_level_id);
  END IF;
  IF p_plan_id IS NOT NULL THEN
    l_Param_Set_Rec.plan_id                 := TO_NUMBER(p_plan_id);
  END IF;
  l_Param_Set_Rec.parameter1_value := p_parameter1_value;
  l_Param_Set_Rec.parameter2_value := p_parameter2_value;
  l_Param_Set_Rec.parameter3_value := p_parameter3_value;
  l_Param_Set_Rec.parameter4_value := p_parameter4_value;
  l_Param_Set_Rec.parameter5_value := p_parameter5_value;
  l_Param_Set_Rec.parameter6_value := p_parameter6_value;
  l_Param_Set_Rec.parameter7_value := p_parameter7_value;

  Get_Request_Schedule_Info
  ( p_Param_Set_rec      => l_Param_Set_rec
  , x_schedule_date      => x_schedule_date
  , x_schedule_time      => x_schedule_time
  , x_schedule_unit      => x_schedule_unit
  , x_schedule_freq      => x_schedule_freq
  , x_schedule_freq_unit => x_schedule_freq_unit
  , x_schedule_end_date  => x_schedule_end_date
  , x_schedule_end_time  => x_schedule_end_time
  , x_next_run_date      => x_next_run_date
  , x_next_run_time      => x_next_run_time
  , x_description        => x_description
  , x_return_status      => x_return_status
  );

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := 'error at Get_Request_Schedule_Info: '||sqlerrm;
  BIS_UTILITIES_PUB.put_line(p_text =>x_return_status);

END Get_Request_Schedule_Info;

Procedure Get_Request_Schedule_Info
( p_Param_Set_rec         IN BIS_PMF_ALERT_REG_PUB.parameter_set_rec_type
, x_schedule_date         OUT NOCOPY VARCHAR2
, x_schedule_time         OUT NOCOPY VARCHAR2
, x_schedule_unit         OUT NOCOPY VARCHAR2
, x_schedule_freq         OUT NOCOPY VARCHAR2
, x_schedule_freq_unit    OUT NOCOPY VARCHAR2
, x_schedule_end_date     OUT NOCOPY VARCHAR2
, x_schedule_end_time     OUT NOCOPY VARCHAR2
, x_next_run_date         OUT NOCOPY VARCHAR2
, x_next_run_time         OUT NOCOPY VARCHAR2
, x_description           OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
)
IS

  l_Concurrent_Request_tbl Fnd_Concurrent_Requests_tbl;
  l_schedule_date       VARCHAR2(32000) := NULL;
  l_schedule_time       VARCHAR2(32000) := NULL;
  l_schedule_unit       VARCHAR2(32000) := NULL;
  l_schedule_freq       VARCHAR2(32000) := NULL;
  l_schedule_freq_unit  VARCHAR2(32000) := NULL;
  l_schedule_end_date   VARCHAR2(32000) := NULL;
  l_schedule_end_time   VARCHAR2(32000) := NULL;
  l_next_run_date       VARCHAR2(32000) := NULL;
  l_next_run_time       VARCHAR2(32000) := NULL;
  l_description         VARCHAR2(32000) := NULL;
  l_date_format         VARCHAR2(32000) := NULL;
  l_time_format         VARCHAR2(32000) := NULL;
  l_return_status       VARCHAR2(32000) := NULL;
  l_request_status      BOOLEAN;
  l_message             VARCHAR2(32000) := NULL;
  l_dev_phase           VARCHAR2(32000) := NULL;
  l_dev_status          VARCHAR2(32000) := NULL;
  l_phase               VARCHAR2(32000) := NULL;
  l_status              VARCHAR2(32000) := NULL;

BEGIN

  Get_All_Requests
  ( p_Param_Set_rec          => p_Param_Set_Rec
  , x_Concurrent_Request_tbl => l_Concurrent_Request_tbl
  , x_return_status          => x_return_status
  );
  --BIS_UTILITIES_PUB.put_line(p_text =>'Number of rows: '||l_Concurrent_Request_tbl.COUNT);


  l_date_format := 'DD/MM/RRRR';
  l_time_format := 'HH24:MI:SS';

  FOR i IN 1..l_Concurrent_Request_tbl.COUNT LOOP
    l_request_status :=  FND_CONCURRENT.GET_REQUEST_STATUS
                      ( request_id  => l_Concurrent_Request_tbl(i).request_id
                      , phase       => l_phase
                      , status      => l_status
                      , dev_phase   => l_dev_phase
                      , dev_status  => l_dev_status
                      , message     => l_message
                      );
    l_return_status := l_dev_status;

    -- Get only requests scheduled once or asap, or not yet started
    --
    IF (l_Concurrent_Request_tbl(i).RESUBMIT_INTERVAL_UNIT_CODE IS NULL
    AND (l_dev_phase = G_CONC_REQUEST_RUNNING
      OR l_dev_phase = G_CONC_REQUEST_COMPLETE))
    THEN
      l_description := l_Concurrent_Request_tbl(i).DESCRIPTION;
      l_schedule_date
        := to_char(l_Concurrent_Request_tbl(i).ACTUAL_START_DATE
                  ,l_date_format);
      l_schedule_time
        := to_char(l_Concurrent_Request_tbl(i).ACTUAL_START_DATE
                  ,l_time_format);
      l_schedule_unit :='ONCE';
      l_schedule_freq := NULL;

      Format_Schedule_Freq_Unit
      ( p_schedule_unit => l_schedule_unit
      , p_schedule_freq => l_schedule_freq
      , x_schedule_freq_unit => l_schedule_freq_unit
      );

      l_schedule_end_date
        :=to_char(l_Concurrent_Request_tbl(i).ACTUAL_COMPLETION_DATE
                 ,l_date_format);
      l_schedule_end_time
        :=to_char(l_Concurrent_Request_tbl(i).ACTUAL_COMPLETION_DATE
                 ,l_time_format);
      l_next_run_date := NULL;
      l_next_run_time := NULL;

      exit;
    ELSIF (l_dev_phase = G_CONC_REQUEST_PENDING
      AND l_dev_status = G_CONC_REQUEST_SCHEDULED)
    THEN
      --BIS_UTILITIES_PUB.put_line(p_text =>'got request status.');
      --
      l_description := l_Concurrent_Request_tbl(i).DESCRIPTION;
      l_schedule_date
        := to_char(l_Concurrent_Request_tbl(i).REQUEST_DATE,l_date_format);
      l_schedule_time
        := to_char(l_Concurrent_Request_tbl(i).REQUEST_DATE,l_time_format);
      l_schedule_unit:=l_Concurrent_Request_tbl(i).RESUBMIT_INTERVAL_UNIT_CODE;
      l_schedule_freq
        := l_Concurrent_Request_tbl(i).RESUBMIT_INTERVAL;

      IF ( l_schedule_unit IS NULL ) THEN
        l_schedule_unit :='ONCE';
        l_schedule_freq := NULL;
      END IF;

      Format_Schedule_Freq_Unit
      ( p_schedule_unit => l_schedule_unit
      , p_schedule_freq => l_schedule_freq
      , x_schedule_freq_unit => l_schedule_freq_unit
      );

      l_schedule_end_date
        :=to_char(l_Concurrent_Request_tbl(i).RESUBMIT_END_DATE,l_date_format);
      l_schedule_end_time
        :=to_char(l_Concurrent_Request_tbl(i).RESUBMIT_END_DATE,l_time_format);

      IF ( l_schedule_unit ='ONCE' AND l_schedule_end_date IS NULL ) THEN
        l_schedule_end_date := l_schedule_date;
      END IF;

      l_next_run_date
        := to_char(l_Concurrent_Request_tbl(i).REQUESTED_START_DATE
                  ,l_date_format);
      l_next_run_time
        := to_char(l_Concurrent_Request_tbl(i).REQUESTED_START_DATE
                  ,l_time_format);

      /*
      BIS_UTILITIES_PUB.put_line(p_text =>'l_schedule_date: '||l_schedule_date);
      BIS_UTILITIES_PUB.put_line(p_text =>'l_schedule_unit: '||l_schedule_unit);
      BIS_UTILITIES_PUB.put_line(p_text =>'l_schedule_freq: '||l_schedule_freq);
      BIS_UTILITIES_PUB.put_line(p_text =>'l_next_run_time: '||l_next_run_time);
      BIS_UTILITIES_PUB.put_line(p_text =>'l_description: '|| l_description);
      */
      exit;
    END IF;
  END LOOP;

  x_schedule_date      := l_schedule_date;
  x_schedule_time      := l_schedule_time;
  x_schedule_unit      := l_schedule_unit;
  x_schedule_freq      := l_schedule_freq;
  x_schedule_freq_unit := l_schedule_freq_unit;
  x_schedule_end_date  := l_schedule_end_date;
  x_schedule_end_time  := l_schedule_end_time;
  x_next_run_date      := l_next_run_date;
  x_next_run_time      := l_next_run_time;
  x_description        := l_description;
  x_return_status      := l_return_status;

EXCEPTION
  WHEN OTHERS THEN
  BIS_UTILITIES_PUB.put_line(p_text =>'error at Get_Request_Schedule_Info: '||sqlerrm);
  x_return_status := 'error at Get_Request_Schedule_Info: '||sqlerrm;
END Get_Request_Schedule_Info;

-- then non-nls compliant way to handle plural units
-- result is something like 'every 1 day(s)' or 'once'
--
Procedure Format_Schedule_Freq_Unit
( p_schedule_unit     IN VARCHAR2
, p_schedule_freq     IN VARCHAR2
, x_schedule_freq_unit OUT NOCOPY VARCHAR2
)
IS

  l_schedule_unit      VARCHAR2(32000);
  l_schedule_freq      VARCHAR2(32000);
  l_schedule_freq_unit VARCHAR2(32000);
  l_every       VARCHAR2(32000);

BEGIN

  l_schedule_unit := Get_Freq_Display_Unit(p_schedule_unit);

  IF (upper(p_schedule_unit) <> 'ONCE') THEN
    l_every := BIS_UTILITIES_PVT.getPrompt( 'BIS_PERFORMANCE_ALERT_PROMPTS'
                                          , 'BIS_EVERY');
    l_schedule_freq_unit:=l_every||' '||p_schedule_freq||' '||l_schedule_unit;
  ELSE
    l_schedule_freq_unit := lower(l_schedule_unit);
  END IF;

  x_schedule_freq_unit := l_schedule_freq_unit;
  --BIS_UTILITIES_PUB.put_line(p_text =>'x_schedule_freq_unit: '||x_schedule_freq_unit);

EXCEPTION
  WHEN OTHERS THEN
  x_schedule_freq_unit := null;
  BIS_UTILITIES_PUB.put_line(p_text =>'error at Format_Schedule_Freq_Unit: '||sqlerrm);

END Format_Schedule_Freq_Unit;

FUNCTION Get_Freq_Display_Unit(p_freq_unit_code IN VARCHAR2)
RETURN VARCHAR2
IS
  l_repeat_unit VARCHAR2(32000);
  l_every       VARCHAR2(32000);

BEGIN

  --BIS_UTILITIES_PUB.put_line(p_text =>'Translating unit code: '||p_freq_unit_code);
  IF (UPPER(p_freq_unit_code) = 'ONCE') THEN
    l_repeat_unit := BIS_UTILITIES_PVT.Get_FND_Message(
                       p_message_name => 'BIS_PMF_ALERT_ONCE');
    RETURN l_repeat_unit;
  ELSE
  BEGIN
    Select lower(meaning)
    Into l_repeat_unit
    From Fnd_Lookups
    Where upper (Lookup_Code) = upper (p_freq_unit_code)
    And Lookup_Type = 'CP_RESUBMIT_INTERVAL_UNIT';
  EXCEPTION
    WHEN OTHERS THEN
    null;
  END;
  END IF;

  -- then non-nls compliant way to handle plural units
  -- result is something from 'Hours' to 'Hour(s)'.
  --
  IF l_repeat_unit IS NOT NULL THEN
    IF (substr(l_repeat_unit,-1,1)) = 's' THEN
      l_repeat_unit := substr(l_repeat_unit,0,length(l_repeat_unit)-1)
                       ||'(s)';
    END IF;
  END IF;
  return l_repeat_unit;

EXCEPTION
  WHEN OTHERS THEN
  l_repeat_unit := null;
  BIS_UTILITIES_PUB.put_line(p_text =>'error at  Get_Display_Unit: '||sqlerrm);
  return l_repeat_unit;

END Get_Freq_Display_Unit;

--
-- Helper routine to check and set concurrent manager
-- repeat options
--
PROCEDURE Set_Repeat_Options
( p_repeat_interval    IN VARCHAR2
, p_repeat_units       IN VARCHAR2
, P_Start_time         IN VARCHAR2
, P_end_time           IN VARCHAR2
, x_result             OUT NOCOPY VARCHAR2
)
IS

  l_start_date DATE;
  l_end_date   DATE;
  l_result     BOOLEAN;
  l_debug_text VARCHAR2(32000);
  l_repeat_interval NUMBER;
  l_start_time VARCHAR2(32000);
  l_end_time   VARCHAR2(32000);
  l_date_fmt   VARCHAR2(30) := 'DD-MON-YYYY HH24:MI:SS'; --2195810
  l_date_format VARCHAR2(200);

BEGIN

  l_debug_text := l_debug_text||' Repeat_interval, units: '
  ||p_repeat_interval||', '
  ||p_repeat_Units;
  l_debug_text := l_debug_text||' start time, end time: '||p_Start_Time||', '
  ||p_End_Time;

-- use the icx date format for converting the user entered value
  fnd_profile.get('ICX_DATE_FORMAT_MASK',l_date_format); --2512994
  l_date_format := NVL(l_date_format,'DD-MON-YYYY') ||' HH24:MI:SS';

--2512994 use the icx date format if it is not null
  IF P_start_time IS NOT NULL THEN
    IF l_date_format IS NOT NULL THEN
      l_start_date := to_date(to_char(to_date(P_start_time,l_date_format),l_date_fmt),l_date_fmt);
    ELSE
      l_start_date := to_date(P_start_time,l_date_fmt);
    END IF;
  END IF;
  IF P_end_time IS NOT NULL THEN
    IF l_date_format IS NOT NULL THEN
      l_end_date := to_date(to_char(to_date(P_End_time,l_date_format),l_date_fmt),l_date_fmt);
    ELSE
      l_end_date := to_date(P_End_time,l_date_fmt);
    END IF;
  END IF;

  l_debug_text := l_debug_text||' l_start_date: '||l_start_date;
  l_debug_text := l_debug_text||' l_end_date: '||l_end_date;

  IF p_repeat_interval IS NOT NULL THEN
    l_repeat_interval := TO_NUMBER(p_repeat_interval);
  END IF;
  l_debug_text := l_debug_text||' repeat interval: '||p_repeat_interval;

  IF P_End_time IS NOT NULL
  AND P_Start_time IS NOT NULL
  AND l_End_date < l_Start_date
  THEN
    return;
  END IF;

  IF l_repeat_interval IS NOT NULL
  AND p_repeat_Units IS NOT NULL
  THEN
    IF p_repeat_units <> 'ONCE' THEN
      l_start_time := to_char(l_start_date,l_date_fmt);
      l_end_time := to_char(l_End_date,l_date_fmt);
      l_result
        := fnd_request.set_repeat_options
           ( repeat_interval => l_repeat_interval
           , repeat_unit     => p_repeat_Units
           , repeat_end_time => l_End_Time
           );
    END IF;
  END IF;

  IF (l_result) THEN
    l_debug_text := l_debug_text||' -- Repeat interval set.';
  ELSE
    l_debug_text := l_debug_text||' -- Repeat interval NOT set.';
  END IF;

  x_result := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'exception in Set_Repeat_Options: '||sqlerrm);
    x_result := l_debug_text||'exception in Set_Repeat_Options: '||sqlerrm;

END Set_Repeat_Options;


END  BIS_CONCURRENT_MANAGER_PVT;

/
