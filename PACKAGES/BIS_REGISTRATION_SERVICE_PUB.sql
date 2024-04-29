--------------------------------------------------------
--  DDL for Package BIS_REGISTRATION_SERVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_REGISTRATION_SERVICE_PUB" AUTHID CURRENT_USER as
/* $Header: BISPARSS.pls 115.9 2002/12/16 10:22:46 rchandra ship $ */

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
);

end bis_registration_service_pub;

 

/
