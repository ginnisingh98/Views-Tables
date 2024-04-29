--------------------------------------------------------
--  DDL for Package Body CCT_LKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_LKUP_PUB" as
/* $Header: cctplovb.pls 120.0 2005/06/02 09:06:04 appldev noship $*/

G_PKG_NAME CONSTANT VARCHAR2(30) :='CCT_LKUP_PUB';



PROCEDURE GET_TRUE_FALSE_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_TRUE_FALSE_LOV';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_lov_meaning IEO_STRING_VARR;
l_lov_code IEO_STRING_VARR;
i number;
j number;

BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	GET_TRUE_FALSE_LOV_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;

  x_lov_count := 0;
  x_lov_data := IEO_STRING_VARR();
  l_lov_meaning := IEO_STRING_VARR();
  l_lov_code := IEO_STRING_VARR();

	-- API body

  SELECT lv.MEANING, lv.lookup_code BULK COLLECT INTO l_lov_meaning, l_lov_code FROM FND_LOOKUP_VALUES LV
  WHERE LV.VIEW_APPLICATION_ID = 0
  AND LV.SECURITY_GROUP_ID = fnd_global.lookup_security_group(LV.LOOKUP_TYPE, LV.VIEW_APPLICATION_ID)
  AND LV.ENABLED_FLAG='Y'
  AND LV.LANGUAGE = p_env_lang
  AND LV.LOOKUP_TYPE = 'CCT_BOOLEAN';

--dbms_output.put_line('  l_lov_meaning => ' ||  l_lov_meaning(1) || ' ' || l_lov_meaning(2));
--dbms_output.put_line('  l_lov_code => ' ||  l_lov_code(1) || ' ' || l_lov_code(2) );
--dbms_output.put_line('  l_lov_code.count => '|| l_lov_code.count);

  j := 0;

  FOR i IN 1..l_lov_code.count LOOP
    x_lov_data.extend();
    j :=  j+1;
    x_lov_data(j) := l_lov_code(i);
    x_lov_data.extend();
    j := j+1;
    x_lov_data(j) := l_lov_meaning(i);
  END LOOP;


  x_lov_count := x_lov_data.count;

	-- End of API body.

EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO GET_TRUE_FALSE_LOV_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_LKUP_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
  --dbms_output.put_line(x_msg_data);

END GET_TRUE_FALSE_LOV;


PROCEDURE GET_JDBC_CONN_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

)IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_JDBC_CONN_LOV';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);

BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	GET_JDBC_CONN_LOV_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;
	-- API body
  x_lov_count := 0;
  x_lov_data := IEO_STRING_VARR();



  FOR i IN 1..15 LOOP
    x_lov_data.extend;
    x_lov_data(i) := i;
  END LOOP;

  x_lov_count := x_lov_data.count;

	-- End of API body.

EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO GET_JDBC_CONN_LOV_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_LKUP_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
  --dbms_output.put_line(x_msg_data);

END GET_JDBC_CONN_LOV;


PROCEDURE GET_TRACE_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_TRACE_LOV';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_lov_meaning IEO_STRING_VARR;
l_lov_code IEO_STRING_VARR;
i number;
j number;
BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	GET_TRACE_LOV_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;

  x_lov_count := 0;
  x_lov_data := IEO_STRING_VARR();
  l_lov_meaning := IEO_STRING_VARR();
  l_lov_code := IEO_STRING_VARR();

	-- API body

  SELECT MEANING, lookup_code BULK COLLECT INTO l_lov_meaning, l_lov_code FROM FND_LOOKUP_VALUES LV
  WHERE LV.VIEW_APPLICATION_ID = 0
  AND LV.SECURITY_GROUP_ID = fnd_global.lookup_security_group(LV.LOOKUP_TYPE, LV.VIEW_APPLICATION_ID)
  AND LV.ENABLED_FLAG='Y'
  AND LV.LANGUAGE = p_env_lang
  AND LV.LOOKUP_TYPE = 'CCT_TRACE_LEVELS';


  j := 0;

  FOR i IN 1..l_lov_code.count LOOP
    x_lov_data.extend();
    j :=  j+1;
    x_lov_data(j) := l_lov_code(i);
    x_lov_data.extend();
    j := j+1;
    x_lov_data(j) := l_lov_meaning(i);
  END LOOP;


  x_lov_count := x_lov_data.count;

	-- End of API body.

EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO GET_TRACE_LOV_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_LKUP_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
  --dbms_output.put_line(x_msg_data);

END GET_TRACE_LOV;

PROCEDURE GET_TEST_TYPE_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_TEST_TYPE_LOV';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
l_lov_meaning IEO_STRING_VARR;
l_lov_code IEO_STRING_VARR;
i number;
j number;
BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	GET_TEST_TYPE_LOV_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;

  x_lov_count := 0;
  x_lov_data := IEO_STRING_VARR();
  l_lov_meaning := IEO_STRING_VARR();
  l_lov_code := IEO_STRING_VARR();

	-- API body

  SELECT MEANING, lookup_code BULK COLLECT INTO l_lov_meaning, l_lov_code FROM FND_LOOKUP_VALUES LV
  WHERE LV.VIEW_APPLICATION_ID = 0
  AND LV.SECURITY_GROUP_ID = fnd_global.lookup_security_group(LV.LOOKUP_TYPE, LV.VIEW_APPLICATION_ID)
  AND LV.ENABLED_FLAG='Y'
  AND LV.LANGUAGE = p_env_lang
  AND LV.LOOKUP_TYPE = 'CCT_TEST_TYPES';


  j := 0;

  FOR i IN 1..l_lov_code.count LOOP
    x_lov_data.extend();
    j :=  j+1;
    x_lov_data(j) := l_lov_code(i);
    x_lov_data.extend();
    j := j+1;
    x_lov_data(j) := l_lov_meaning(i);
  END LOOP;


  x_lov_count := x_lov_data.count;

	-- End of API body.

EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO GET_TRACE_LOV_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_LKUP_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
  --dbms_output.put_line(x_msg_data);

END GET_TEST_TYPE_LOV;


PROCEDURE GET_MW_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_MW_LOV';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);

BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	GET_MW_LOV_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;
	-- API body
  select config_name bulk collect into x_lov_data
    from CCT_MIDDLEWARES mw
    where mw.server_group_id = p_server_group_id
	  AND mw.f_deletedflag is NULL;
  x_lov_count := x_lov_data.count;
	-- End of API body.

EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO GET_MW_LOV_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_LKUP_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
  --dbms_output.put_line(x_msg_data);

END GET_MW_LOV;




PROCEDURE GET_ROUTE_POINT_LOV
(
  p_server_group_id IN NUMBER ,  -- server group id
  p_server_id IN NUMBER ,            -- server id
  p_server_parameter_id IN NUMBER ,   -- server parameter id
  p_env_lang IN VARCHAR2 ,           -- language
  x_lov_count OUT NOCOPY NUMBER ,            -- number of lov_data returned
  x_lov_data OUT NOCOPY IEO_STRING_VARR, -- list of lov_data returned.
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2

)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_ROUTE_POINT_LOV';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);
j number;
i number;

BEGIN
	-- Standard Start of API savepoint

  SAVEPOINT	GET_ROUTE_POINT_LOV_PUB;

	--  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;
	-- API body
  select config_name || ': ' || route_point_number bulk collect into x_lov_data
    from CCT_MIDDLEWARES mw, CCT_MW_ROUTE_POINTS rp
    where mw.middleware_id = rp.middleware_id
	  AND mw.server_group_id = p_server_group_id
	  AND rp.f_deletedflag is NULL;

  x_lov_data.extend();
  FOR i IN REVERSE 2..x_lov_data.count LOOP
    x_lov_data(i) := x_lov_data(i-1);
  END LOOP;
  x_lov_data(1) := '';

  x_lov_count := x_lov_data.count;
	-- End of API body.

EXCEPTION

	WHEN OTHERS THEN
    ROLLBACK TO GET_ROUTE_POINT_LOV_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_count := 1;
    x_err_num := SQLCODE;
    x_err_msg := SUBSTR(SQLERRM, 1, 100);
    x_msg_data := 'CCT_LKUP_PUB: CCT_ERROR '
                    || ' ErrorCode = ' || x_err_num
                    || ' ErrorMsg = ' || x_err_msg;
  --dbms_output.put_line(x_msg_data);

END GET_ROUTE_POINT_LOV;


END CCT_LKUP_PUB;


/
