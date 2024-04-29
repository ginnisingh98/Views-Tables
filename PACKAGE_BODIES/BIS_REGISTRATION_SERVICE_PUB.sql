--------------------------------------------------------
--  DDL for Package Body BIS_REGISTRATION_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_REGISTRATION_SERVICE_PUB" as
/* $Header: BISPARSB.pls 115.9 2002/12/16 10:22:44 rchandra ship $ */

PROCEDURE submit_request
( p_time            IN      varchar2
 ,p_request_id      OUT NOCOPY     varchar2
 ,p_parameter_type1 IN  varchar2   default null
 ,p_parameter_value1 IN  varchar2   default null
 ,p_parameter_type2 IN  varchar2   default null
 ,p_parameter_value2 IN  varchar2   default null
 ,p_parameter_type3 IN  varchar2   default null
 ,p_parameter_value3 IN  varchar2   default null
 ,p_parameter_type4 IN  varchar2   default null
 ,p_parameter_value4 IN  varchar2   default null
 ,p_parameter_type5 IN  varchar2   default null
 ,p_parameter_value5 IN  varchar2   default null
 ,p_parameter_type6 IN  varchar2   default null
 ,p_parameter_value6 IN  varchar2   default null
 ,p_parameter_type7 IN  varchar2   default null
 ,p_parameter_value7 IN  varchar2   default null
 ,p_parameter_type8 IN  varchar2   default null
 ,p_parameter_value8 IN  varchar2   default null
 ,p_parameter_type9 IN  varchar2   default null
 ,p_parameter_value9 IN  varchar2   default null
 ,p_parameter_type10 IN  varchar2   default null
 ,p_parameter_value10 IN  varchar2   default null
)
IS

 l_request_id NUMBER;
 l_measure_short_name varchar2(3000);
 l_dim_level_short_name varchar2(3000);
begin

  select dimLevel.DIMENSION_LEVEL_SHORT_NAME
  into l_dim_level_short_name
  from bisbv_dimension_levels dimLevel
  where dimLevel.DIMENSION_ID = to_number(p_parameter_value2) ;

  SELECT MEASURE_SHORT_NAME
  INTO L_MEASURE_SHORT_NAME
  FROM BISBV_PERFORMANCE_MEASURES
  where MEASURE_ID = to_number(p_parameter_value1);

  l_request_id := fnd_request.submit_request( application => 'BIS'
			    , program     => 'BIS_ALERT_MANAGER'
                            , description => 'BIS Alert Manager'
                            , start_time  => p_time
                            , argument1   => p_parameter_value1
                            , argument2   => l_measure_short_name
                            , argument3   => NULL
                            , argument4   => NULL
                            , argument5   => NULL
                            , argument6   => NULL
                            , argument7   => NULL
                            , argument8   => NULL
                            , argument9   => p_parameter_value2
                            , argument10  => l_measure_short_name
                            );

  if l_request_id = 0 then
    p_request_id := 'Failed for type - 1 ' || p_parameter_type1
                       || ' Value1 ' ||p_parameter_value1
                       || ' type -2 ' || p_parameter_type2
                       ||'Value 2 ' || p_parameter_value2  ;
  else
    p_request_id := 'Successful ' || to_char(l_request_id);
  end if;

end submit_request;

end bis_registration_service_pub;

/
