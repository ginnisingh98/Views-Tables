--------------------------------------------------------
--  DDL for Package Body BIS_REPORT_XML_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_REPORT_XML_PUB" AS
  /* $Header: BISREPTB.pls 120.0 2005/06/01 16:30:58 appldev noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISREPTB.pls
---
---  DESCRIPTION
---     Package Body File for report transactions
---
---  NOTES
---
---  HISTORY
---
--  18-Jan-05 smargand    Enh #4031345 Report XML definition              --
---===========================================================================

procedure Create_Report_Function(
 p_report_function_name		IN VARCHAR2
,p_application_id		IN NUMBER
,p_title			IN VARCHAR2
,p_report_xml_name                IN VARCHAR2 := null
,x_report_id			OUT NOCOPY NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_count	NUMBER;
l_parameters    		FND_FORM_FUNCTIONS.Parameters%Type;
l_app_short_name 		VARCHAR2(30);
l_report_xml_name                 VARCHAR2(30);

begin

	fnd_msg_pub.initialize;

	select count(*) into l_count
	from fnd_form_functions
	where function_name = p_report_function_name;

	if (l_count > 0) then
		-- Trying to update a non-report function.
       		FND_MESSAGE.SET_NAME('BIS','BIS_PD_UNIQUE_PGE_ERR');
       		FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;
	else
		select lower(application_short_name) into l_app_short_name
		from fnd_application
		where application_id = p_application_id;

		-- --INSERT Form Function

		if(p_report_xml_name is null) then
		    l_report_xml_name := p_report_function_name;
		else
		    l_report_xml_name := p_report_xml_name;
		end if;

		l_parameters := c_REPORT_NAME || '=' || c_MDS_PATH_PRE || l_app_short_name || c_MDS_PATH_POST || l_report_xml_name || '&' ||
			c_SOURCE_TYPE || '=' || c_MDS || '&' ||c_FUNCTION_NAME || '=' || upper(p_report_function_name);


		BIS_FORM_FUNCTIONS_PUB.INSERT_ROW (
		 	p_FUNCTION_NAME => p_report_function_name,
			p_WEB_HTML_CALL => C_WEB_HTML_CALL,
			p_PARAMETERS => l_parameters,
			p_TYPE => C_FUNCTION_TYPE,
			p_USER_FUNCTION_NAME => p_title,
			x_FUNCTION_ID => x_report_id,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data =>x_msg_data);



	end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);


  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);


  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;
    end if;

end Create_Report_Function;



procedure Update_Report_Function(
 p_report_function_name		IN VARCHAR2
,p_application_id		IN NUMBER
,p_title			IN VARCHAR2
,p_report_xml_name                IN VARCHAR2 := null
,p_new_report_function_name	IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_count				NUMBER;
l_function_id			NUMBER := 0;
l_parameters    		FND_FORM_FUNCTIONS.Parameters%Type;
l_app_short_name 		VARCHAR2(30);
l_type 				VARCHAR2(30);
l_report_function_name 		fnd_form_functions.function_name%TYPE;
l_application_id		NUMBER;
l_menu_name			FND_MENUS.Menu_Name%Type := NULL;
l_report_xml_name                 VARCHAR2(30);
begin
	fnd_msg_pub.initialize;

	begin
		select 	BIS_COMMON_UTILS.getParameterValue(parameters, c_SOURCE_TYPE),
			function_id,
			parameters
			into l_type, l_function_id, l_parameters
		from fnd_form_functions
		where function_name = p_report_function_name;
	exception
		when no_data_found then l_type := null;
	end;


	if p_new_report_function_name is null then
		l_report_function_name := p_report_function_name;
	else
		l_report_function_name := p_new_report_function_name;
	end if;


	select lower(application_short_name) into l_app_short_name
	from fnd_application
	where application_id = p_application_id;



	/*
	if p_new_report_xml_name is null then
		l_report_xml_name := p_report_xml_name;
	else
		l_report_xml_name := p_new_report_xml_name;
	end if;
	*/

	l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, C_REPORT_NAME, C_MDS_PATH_PRE || l_app_short_name || C_MDS_PATH_POST || p_report_xml_name);
	l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_SOURCE_TYPE, C_MDS);
	l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_FUNCTION_NAME, upper(l_report_function_name));


	-- Update form function
	if l_report_function_name <> p_report_function_name then
		-- Check if new function already exists.
		select count(*) into l_count
		from fnd_form_functions
		where function_name = l_report_function_name;

		if (l_count > 0) then
			-- Duplicate function name
       			FND_MESSAGE.SET_NAME('BIS','BIS_PD_UNIQUE_PGE_ERR');
       			FND_MSG_PUB.ADD;
        		RAISE FND_API.G_EXC_ERROR;
		end if;

		UPDATE fnd_form_functions
		SET    function_name = l_report_function_name
		WHERE  function_id = l_function_id;
	end  if;

	BIS_FORM_FUNCTIONS_PUB.UPDATE_ROW (
		p_FUNCTION_ID => l_function_id,
		p_USER_FUNCTION_NAME => p_title,
		p_PARAMETERS => l_parameters,
		x_return_status => x_return_status,
		x_msg_count => x_msg_count,
		x_msg_data =>x_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := SQLERRM;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := SQLERRM;

    end if;

end Update_Report_Function;


end BIS_REPORT_XML_PUB;

/
