--------------------------------------------------------
--  DDL for Package Body BIS_PMV_PAGE_PARAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_PAGE_PARAMS_PUB" as
/* $Header: BISPPAGB.pls 120.0 2005/06/01 17:31:07 appldev noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.20=120.0):~PROD:~PATH:~FILE

PROCEDURE GET_KPI_HELP_TARGET
(p_function_name        IN  VARCHAR2
,p_function_parameters  IN  VARCHAR2
,p_web_html_call        IN  VARCHAR2
,x_region_application_id IN OUT NOCOPY NUMBER
,x_help_target           IN OUT NOCOPY VARCHAR2
,x_return_Status        IN OUT NOCOPY VARCHAR2
,x_msg_count            IN OUT NOCOPY NUMBER
,x_msg_data             IN OUT NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_LASTUPDATE_DATE
(p_user_name            IN  VARCHAR2
,p_page_id              IN  VARCHAR2
,p_session_id           IN  NUMBER default null
,x_last_update_date     OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  /* Bug 2551994 Modifications to default as of date to sysdate for every login */
  CURSOR c_lastupdatedate IS
  SELECT to_char(bua.last_update_date,'RRRR/MM/DD HH24:MI:SS')last_update_date
  ,bua.attribute_name, bua.session_value, bua.user_id, bua.session_id, bua.function_name
  FROM bis_user_attributes bua, fnd_user fu
  WHERE bua.page_id=p_page_id
  AND   bua.user_id = to_char(fu.user_id)
  AND   fu.user_name = p_user_name;

  --jprabhud - 07/16/03- Make this a dynamic sql to remove portal dependency
  --Removed the cursor which was using portal table, but was not reaaly being used

  l_function_name  fnd_form_functions.function_name%TYPE;
  CURSOR c_asofdatefunc IS
  SELECT parameters
  FROM fnd_form_functions
  WHERE function_name = l_function_name and
  instr(parameters,'pRequestType=P') > 0
  and instr(parameters, 'pAsOfDate=') > 0;
  l_session_id  varchar2(200);
  l_icx_session_id varchar2(200);
  l_user_id   varchar2(2000);
  l_asof_date  varchar2(2000);
  l_attribute_name  varchar2(200) := 'AS_OF_DATE';
  l_asOfDate_parameter varchar2(2000);
  l_asofdate_func varchar2(2000);
  l_new_asofdate varchar2(2000);
  l_index1 number;
  l_index2 number;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- We need to comment the part about icx_sec.validateSession since it is going to fail anyway.
  /*if (p_Session_id is null) then
     if (not icx_sec.validateSession) then
         null;
     end if;
     l_icx_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  else
  */
     l_icx_session_id := p_session_id;
  --end if;

  for c_rec in c_lastupdatedate loop
      if (c_rec.attribute_name = 'AS_OF_DATE') then
         l_asof_date := c_rec.session_value;
         x_last_update_date := c_rec.last_update_Date;
         l_user_id := c_rec.user_id;
         l_session_id := c_rec.session_id;
         l_function_name := c_rec.function_name;
         exit;
       end if;
  end loop;
  if ((l_session_id <> l_icx_session_id and l_icx_session_id <> '-1') or l_session_id is null) then

/* ARU Standards Issue : to_date cannot have a format like MON */

      /*OPEN  c_asOfDate;
      FETCH c_asOfDate INTO l_asOfDate_parameter;
      CLOSE c_asOfDate;*/
      if (l_function_name is not null) then
         OPEN c_asofdatefunc;
         FETCH c_asofdatefunc into l_asofdate_parameter;
         CLOSE c_asofdatefunc;
     end if;
        if l_asOfDate_parameter is not null then
          l_index1 := instr(l_asOfDate_parameter, 'pAsOfDate=');
          l_index2 := instr(l_asOfDate_parameter,'&', l_index1);
          if l_index2 > 0 then
             l_asofdate_func := substr(l_asOfDate_parameter,
l_index1+length('pAsOfDate='),l_index2-l_index1-length('pAsOfDate='));
          else
             l_asofdate_func := substr(l_asOfDate_parameter, l_index1+length('pAsOfDate='));
          end if;

          --l_asofdate_func := 'select to_char('||l_asofdate_func||',''DD-MON-YYYY'') from dual';
          --As of Date 3094234--dd/mm/yyyy format
          l_asofdate_func := 'select to_char('||l_asofdate_func||',''DD/MM/YYYY'') from dual';
          execute immediate l_asofdate_func into l_new_asofdate;

          if (upper(l_asof_date) <> upper(l_new_asofdate)) then

            update bis_user_attributes
            set session_value = l_new_asofdate
            ,session_description = l_new_asofdate
            , last_update_date = sysdate
            where page_id=p_page_id
            and user_id = l_user_id
            and attribute_name = l_attribute_name;
            x_last_update_date := to_char(sysdate,'RRRR/MM/DD HH24:MI:SS');
            commit;
          end if;
      else

        --if (l_asof_Date <> to_char(sysdate,'DD-MON-YYYY') and
        --As of Date 3094234--dd/mm/yyyy format
        if (l_asof_Date <> to_char(sysdate,'DD/MM/YYYY') and
            l_Asof_date is not null)
        then
          update bis_user_attributes
          set session_value = to_char(sysdate,'DD/MM/YYYY')
          ,session_description = to_char(sysdate,'DD/MM/YYYY')
          --As of Date 3094234--dd/mm/yyyy format
          --set session_value = to_char(sysdate,'DD-MON-YYYY')
          --,session_description = to_char(sysdate,'DD-MON-YYYY')
          , last_update_date = sysdate
            where page_id=p_page_id
            and user_id = l_user_id
            and attribute_name = l_attribute_name;
            x_last_update_date := to_char(sysdate,'RRRR/MM/DD HH24:MI:SS');
          commit;
        end if;
      end if; --end of l_asOfDate_parameter is not null
   end if;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
END;

PROCEDURE RETRIEVE_PARAMETER_STRING
(p_user_name            IN  VARCHAR2
,p_page_id              IN  VARCHAR2
,x_param_string         OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_paramstring IS
  SELECT bua.attribute_name, bua.session_description
  FROM bis_user_attributes bua, fnd_user fu
  WHERE bua.page_id=p_page_id AND
        bua.user_id=to_char(fu.user_id) AND
        fu.user_name = p_user_name
  ORDER BY bua.attribute_name;

  l_param_string  varchar2(32767);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR c_rec IN c_paramString LOOP
      if ( l_param_string is null ) then
        l_param_string := 'dbiParameters%3DY';
      end if;
      l_param_string := l_param_string || '%26' || wfa_html.conv_special_url_chars(c_rec.attribute_name);
      l_param_string := l_param_string || '%3D'; -- '='
      l_param_string := l_param_string ||  wfa_html.conv_special_url_chars(c_Rec.session_description);
  END LOOP;
  x_param_string := l_param_string;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
END;
PROCEDURE RETRIEVE_PARAMSTR_BYUSERID
(p_user_id              IN  VARCHAR2
,p_page_id              IN  VARCHAR2
,x_param_string         OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_paramstring IS
  SELECT bua.attribute_name, bua.session_description
  FROM bis_user_attributes bua
  WHERE bua.page_id=p_page_id AND
        bua.user_id=p_user_id
  ORDER BY bua.attribute_name;

  l_param_string  varchar2(32767);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR c_rec IN c_paramString LOOP
      if ( l_param_string is null ) then
        l_param_string := 'dbiParameters=Y';
      end if;
      l_param_string := l_param_string || '&' || wfa_html.conv_special_url_chars(c_rec.attribute_name);
      l_param_string := l_param_string || '='; -- '='
      l_param_string := l_param_string ||  wfa_html.conv_special_url_chars(c_Rec.session_description);
  END LOOP;
  x_param_string := l_param_string;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data =>
x_msg_data);
END;

/* This function is duplicated from bis_pmv_util  package for the sake of having no dependencies */
-- mdamle 12/12/01 - This routine will return the value of a parameter (given the param name) within the parameter string
-- defined in form function
function getParameterValue(pParameters IN VARCHAR2, pParameterKey IN VARCHAR2) return varchar2 is
l_value varchar2(1000);
l_index1 number;

l_value_begin number;
l_value_end number;

begin
	l_index1 := instr(pParameters, pParameterKey||'=');

	if  l_index1 > 0 then
		l_value_begin := l_index1 + length(pParameterKey||'=');

		l_value_end := instr(pParameters, '&', l_value_begin);

		if l_value_end > 0 then
			l_value := substr(pParameters, l_value_begin, l_value_end - l_value_begin);
		else
			l_value := substr(pParameters, l_value_begin);
		end if;

	else
		l_value := '';
	end if;

	return l_value;

end getParameterValue;


/* Returns the application id and the help target for the gevn args */
PROCEDURE GET_HELP_TARGET
(p_function_name        IN  VARCHAR2
,p_function_parameters  IN  VARCHAR2
,p_web_html_call        IN  VARCHAR2
,x_region_application_id           OUT NOCOPY NUMBER
,x_help_target           OUT NOCOPY VARCHAR2
,x_return_Status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
) IS

 lAKRegionCode VARCHAR2(30);
 lFunctionName VARCHAR2(30);
 lRegionCode VARCHAR2(30);
 lRegionHelpTarget VARCHAR2(256);

 CURSOR getRegionAttributes (pRegionCode IN VARCHAR2) IS
  SELECT region_application_id, help_target
  FROM ak_regions
  WHERE region_code = pRegionCode ;

 CURSOR getFndHelpTarget IS
  SELECT target_name
  FROM fnd_help_targets
  WHERE target_name = p_Function_Name ;

BEGIN


   -- The application_id column of fnd_form_functions could be null, so we use the
   --corr region_code to get the application_id
   -- get the help_target and the application_id from the region
   lAKRegionCode := getParameterValue(pParameters => p_web_html_call,
                                    pParameterKey => 'akRegionCode' );

   -- bug 2661052- do not show help for related links portlet
   IF NOT  (lAKRegionCode = 'BIS_PM_RELATED_LINK_LAYOUT' ) THEN

     --assumption that most of the product teams use function name as their help
     -- target name

     IF (getFndHelpTarget%ISOPEN ) THEN
       CLOSE getFndHelpTarget;
     END IF;
     OPEN getFndHelpTarget;
     FETCH getFndHelpTarget INTO x_help_target;
     CLOSE getFndHelpTarget;


      lRegionCode := getParameterValue(pParameters => p_function_parameters,
                                   pParameterKey => 'pRegionCode' );

      IF (getRegionAttributes%ISOPEN ) THEN
       CLOSE getRegionAttributes;
     END IF;
     OPEN getRegionAttributes(lRegionCode);
     FETCH getRegionAttributes INTO x_region_application_id, lRegionHelpTarget;
     CLOSE getRegionAttributes;

     IF (x_help_target IS NULL) THEN
      x_help_target := lRegionHelpTarget;
     END IF;

     IF (lAKRegionCode = 'BIS_PMF_PORTLET_TABLE_LAYOUT' ) THEN -- PMF
       GET_KPI_HELP_TARGET(
          p_function_name => p_function_name
	 ,p_function_parameters => p_function_parameters
	 ,p_web_html_call => p_web_html_call
	 ,x_region_application_id => x_region_application_id
	 ,x_help_target => x_help_target
	 ,x_return_Status => x_return_Status
	 ,x_msg_count => x_msg_count
	 ,x_msg_data => x_msg_data
       );
     END IF;
   END IF; -- not related link

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                  p_data =>x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data =>x_msg_data);
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                   p_data => x_msg_data);


END GET_HELP_TARGET;

PROCEDURE GET_KPI_HELP_TARGET
(p_function_name        IN  VARCHAR2
,p_function_parameters  IN  VARCHAR2
,p_web_html_call        IN  VARCHAR2
,x_region_application_id IN OUT NOCOPY NUMBER
,x_help_target          IN OUT NOCOPY VARCHAR2
,x_return_Status        IN OUT NOCOPY VARCHAR2
,x_msg_count            IN OUT NOCOPY NUMBER
,x_msg_data             IN OUT NOCOPY VARCHAR2
) IS

  CURSOR getFormFunAppId IS
    SELECT fa.APPLICATION_ID
    FROM fnd_application fa
    WHERE fa.APPLICATION_SHORT_NAME = SUBSTR(p_Function_Name,1,3) ;
BEGIN

  -- when using form function level, set the application id correctly
  IF ((x_region_application_id IS NULL) AND
      (x_help_target = p_function_name)) THEN

       IF (getFormFunAppId%ISOPEN ) THEN
         CLOSE getFormFunAppId;
       END IF;
       OPEN getFormFunAppId;
       FETCH getFormFunAppId INTO x_region_application_id;
       CLOSE getFormFunAppId;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (getFormFunAppId%ISOPEN ) THEN
      CLOSE getFormFunAppId;
    END IF;
END GET_KPI_HELP_TARGET;

END BIS_PMV_PAGE_PARAMS_PUB;

/
