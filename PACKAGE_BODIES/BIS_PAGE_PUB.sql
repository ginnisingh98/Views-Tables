--------------------------------------------------------
--  DDL for Package Body BIS_PAGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PAGE_PUB" AS
  /* $Header: BISPPGEB.pls 120.2 2005/08/11 22:56:26 ashankar noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISPPGEB.pls
---
---  DESCRIPTION
---     Package Body File for Page transactions
---
---  NOTES
---
---  HISTORY
---
---  07-Oct-2003 mdamle     Created
---  03-Feb-2004 mdamle     Change function name while migrating if different from internal name
---  06-Feb-2004 mdamle     Remove AK Region Integration
---  18-Jan-2005 rpenneru   Enh#4059160- Opening up FA in Designers          |
---  29-Jan-2005 vtulasi   Enh#4102897- Increasing buffer size for function_name related variables
---  21-MAR-2005 ankagarw   bug#4235732 - changing count(*) to count(1)      |
---  13-JUL-2005 akoduri    Bug #4368221 Added the function Get_Custom_View_Name|
--   10-AUG-2005 ashankar   Bug #4548914 Added a new Function  Is_Simulatable_Cust_View |
---===========================================================================

procedure Create_Page_Region(
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,p_title      IN VARCHAR2
,p_page_function_name   IN VARCHAR2
,x_page_id      OUT NOCOPY NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_count   NUMBER;
l_parameters    FND_FORM_FUNCTIONS.Parameters%Type;
l_app_short_name VARCHAR2(30);
l_type    VARCHAR2(30);
begin

  fnd_msg_pub.initialize;

  begin
    select BIS_COMMON_UTILS.getParameterValue(parameters, c_SOURCE_TYPE) into l_type
    from fnd_form_functions
    where function_name = p_page_function_name;
  exception
    when no_data_found then l_type := null;
  end;

  if (l_type = c_FND_MENU) then
    Migrate_Menu_To_MDS(
      p_internal_name => p_internal_name,
      p_application_id => p_application_id,
      p_title => p_title,
      p_page_function_name => p_page_function_name,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

  else
    -- Check if either Form Function or Region code exists.

    select count(1) into l_count
    from fnd_form_functions
    where function_name = p_internal_name;

    if (l_count = 0) then
      select count(1) into l_count
      from ak_regions
      where region_code = p_internal_name
      and region_application_id = p_application_id;
    end if;

    if (l_count > 0) then
            FND_MESSAGE.SET_NAME('BIS','BIS_PD_UNIQUE_PGE_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    end if;

    -- Insert new Region
    BIS_AK_REGION_PUB.INSERT_REGION_ROW (
      p_REGION_CODE => p_internal_name,
      p_REGION_APPLICATION_ID => p_application_id,
      p_DATABASE_OBJECT_NAME => c_DUMMY_DB_OBJECT,
      p_APPL_MODULE_OBJECT_TYPE => c_APP_MOD,
      p_NAME => p_title,
      p_REGION_STYLE => c_PAGE_LAYOUT,
      p_ATTRIBUTE_CATEGORY => c_ATTRIBUTE_CATEGORY,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

    -- Insert Form Function
    select lower(application_short_name) into l_app_short_name
    from fnd_application
    where application_id = p_application_id;

    l_parameters := c_PAGE_NAME || '=' || c_MDS_PATH_PRE || l_app_short_name || c_MDS_PATH_POST || p_internal_name || '&' ||
        c_SOURCE_TYPE || '=' || c_MDS;


    BIS_FORM_FUNCTIONS_PUB.INSERT_ROW (
      p_FUNCTION_NAME => p_internal_name,
      p_WEB_HTML_CALL => c_WEB_HTML_CALL,
      p_PARAMETERS => l_parameters,
      p_TYPE => c_FUNCTION_TYPE,
      p_USER_FUNCTION_NAME => p_title,
      x_FUNCTION_ID => x_page_id,
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

end CREATE_PAGE_REGION;

procedure Update_Page_Region(
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,p_title      IN VARCHAR2
,p_page_id      IN NUMBER
,p_new_internal_name    IN VARCHAR2
,p_new_application_id   IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_count     NUMBER;
l_parameters      FND_FORM_FUNCTIONS.Parameters%Type;
l_app_short_name  VARCHAR2(30);
l_new_internal_name   VARCHAR2 (30);
l_new_application_id  NUMBER;

begin

  fnd_msg_pub.initialize;

  if p_new_internal_name is null then
    l_new_internal_name := p_internal_name;
  else
    l_new_internal_name := p_new_internal_name;
  end if;

  if p_new_application_id is null then
    l_new_application_id := p_application_id;
  else
    l_new_application_id := p_new_application_id;
  end if;

  if (l_new_internal_name = p_internal_name and p_application_id = l_new_application_id) then
        -- Update existing Region
    BIS_AK_REGION_PUB.UPDATE_REGION_ROW (
      p_REGION_CODE => p_internal_name,
      p_REGION_APPLICATION_ID => p_application_id,
      p_DATABASE_OBJECT_NAME => c_DUMMY_DB_OBJECT,
      p_NAME => p_title,
      p_ATTRIBUTE_CATEGORY => c_ATTRIBUTE_CATEGORY,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

    -- Update Form Function
    BIS_FORM_FUNCTIONS_PUB.UPDATE_ROW (
      p_FUNCTION_ID => p_page_id,
      p_USER_FUNCTION_NAME => p_title,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

  else
    -- If user changes the form function name or the application id

    -- Check if form function/region exists

    select count(1) into l_count
    from fnd_form_functions
    where function_name = l_new_internal_name;

    if (l_count = 0) then
      select count(1) into l_count
      from ak_regions
      where region_code = l_new_internal_name
      and region_application_id = l_new_application_id;
    end if;

    if (l_count > 0) then
            FND_MESSAGE.SET_NAME('BIS','BIS_PD_UNIQUE_PGE_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    end if;

    -- Delete existing region
    BIS_AK_REGION_PUB.DELETE_REGION_ROW(
      p_REGION_CODE => p_internal_name,
      p_REGION_APPLICATION_ID => p_application_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

    -- Create new region
    BIS_AK_REGION_PUB.INSERT_REGION_ROW (
      p_REGION_CODE => l_new_internal_name,
      p_REGION_APPLICATION_ID => l_new_application_id,
      p_DATABASE_OBJECT_NAME => c_DUMMY_DB_OBJECT,
      p_APPL_MODULE_OBJECT_TYPE => c_APP_MOD,
      p_NAME => p_title,
      p_REGION_STYLE => c_PAGE_LAYOUT,
      p_ATTRIBUTE_CATEGORY => c_ATTRIBUTE_CATEGORY,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

    -- Update Form Function
    select lower(application_short_name) into l_app_short_name
    from fnd_application
    where application_id = l_new_application_id;

    select parameters into l_parameters from fnd_form_functions
    where function_id = p_page_id;

    l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_PAGE_NAME, c_MDS_PATH_PRE || l_app_short_name || c_MDS_PATH_POST || l_new_internal_name);

    if l_new_internal_name <> p_internal_name then
      UPDATE fnd_form_functions
      SET    function_name = l_new_internal_name
      WHERE  function_id = p_page_id;
    end  if;

    BIS_FORM_FUNCTIONS_PUB.UPDATE_ROW (
      p_FUNCTION_ID => p_page_id,
      p_USER_FUNCTION_NAME => p_title,
      p_PARAMETERS => l_parameters,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

  end if;

  -- Delete Page Racks and Rack Items
  Delete_Page_Racks(
      p_internal_name => p_internal_name,
      p_application_id => p_application_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);


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

end Update_page_Region;

Procedure Delete_Page_Region (
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,p_page_id      IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

begin
  fnd_msg_pub.initialize;

  -- Delete Page Racks and Rack Items
  Delete_Page_Racks(
    p_internal_name => p_internal_name,
    p_application_id => p_application_id,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

  BIS_AK_REGION_PUB.DELETE_REGION_ROW(
    p_REGION_CODE => p_internal_name,
    p_REGION_APPLICATION_ID => p_application_id,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

  BIS_FORM_FUNCTIONS_PUB.DELETE_ROW(
    p_FUNCTION_ID => p_page_id,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

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


END Delete_Page_Region;

procedure Create_Rack_Region(
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

begin

  fnd_msg_pub.initialize;

  -- Insert new Region
  BIS_AK_REGION_PUB.INSERT_REGION_ROW (
    p_REGION_CODE => p_internal_name,
    p_REGION_APPLICATION_ID => p_application_id,
    p_DATABASE_OBJECT_NAME => c_DUMMY_DB_OBJECT,
    p_NAME => p_internal_name,
    p_REGION_STYLE => c_ROW_LAYOUT,
    p_ATTRIBUTE_CATEGORY => c_ATTRIBUTE_CATEGORY,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);


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

end CREATE_RACK_REGION;


Procedure Delete_Rack_Region (
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is
begin

  fnd_msg_pub.initialize;

  delete_region_items(
      p_internal_name => p_internal_name,
      p_application_id => p_application_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

  BIS_AK_REGION_PUB.DELETE_REGION_ROW(
    p_REGION_CODE => p_internal_name,
    p_REGION_APPLICATION_ID => p_application_id,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

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

END Delete_Rack_Region;

procedure Create_Rack_Item(
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,p_rack_Num     IN NUMBER
,p_display_flag     IN VARCHAR2 := 'Y'
,p_rack_region      IN VARCHAR2
,p_rack_region_application_id IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

begin

  fnd_msg_pub.initialize;

  -- Insert the Rack Region Item

  BIS_AK_REGION_PUB.INSERT_REGION_ITEM_ROW (
    p_REGION_CODE => p_internal_name,
    p_REGION_APPLICATION_ID => p_application_id,
    p_ATTRIBUTE_CODE => c_RACK_ATTRIBUTE_CODE || p_Rack_Num,
    p_ATTRIBUTE_APPLICATION_ID => c_BIS_APP_ID,
    p_DISPLAY_SEQUENCE => p_Rack_Num,
    p_NODE_DISPLAY_FLAG => p_display_flag,
    p_NESTED_REGION_CODE => p_rack_region,
    p_NESTED_REGION_APPL_ID => p_rack_region_application_id,
    p_ATTRIBUTE_CATEGORY => c_ATTRIBUTE_CATEGORY,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

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

end Create_Rack_Item;

Procedure Delete_Rack_Item (
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,p_rack_Num     IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is
begin

  fnd_msg_pub.initialize;

    BIS_AK_REGION_PUB.DELETE_REGION_ITEM_ROW(
        p_REGION_CODE => p_internal_name,
        p_REGION_APPLICATION_ID => p_application_id,
        p_ATTRIBUTE_CODE => c_RACK_ATTRIBUTE_CODE || p_Rack_Num,
        p_ATTRIBUTE_APPLICATION_ID => c_BIS_APP_ID,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);


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

END Delete_Rack_Item;

procedure Create_Portlet_Item(
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,p_Portlet_Num      IN NUMBER
,p_display_flag     IN VARCHAR2 := 'Y'
,p_function_name    IN VARCHAR2
,p_title      IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

begin

  fnd_msg_pub.initialize;

  -- Insert the Portlet Region Item

  BIS_AK_REGION_PUB.INSERT_REGION_ITEM_ROW (
    p_REGION_CODE => p_internal_name,
    p_REGION_APPLICATION_ID => p_application_id,
    p_ATTRIBUTE_CODE => c_PORTLET_ATTRIBUTE_CODE || p_Portlet_Num,
    p_ATTRIBUTE_APPLICATION_ID => c_BIS_APP_ID,
    p_DISPLAY_SEQUENCE => p_Portlet_Num,
    p_NODE_DISPLAY_FLAG => p_display_flag,
    p_ATTRIBUTE_LABEL_LONG => p_Title,
    p_ATTRIBUTE_CATEGORY => c_ATTRIBUTE_CATEGORY,
    p_ATTRIBUTE1 => p_function_name,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

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

end Create_Portlet_Item;

Procedure Delete_Rack_Item (
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,p_portlet_Num      IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is
begin

    fnd_msg_pub.initialize;

    BIS_AK_REGION_PUB.DELETE_REGION_ITEM_ROW(
        p_REGION_CODE => p_internal_name,
        p_REGION_APPLICATION_ID => p_application_id,
        p_ATTRIBUTE_CODE => c_PORTLET_ATTRIBUTE_CODE || p_Portlet_Num,
        p_ATTRIBUTE_APPLICATION_ID => c_BIS_APP_ID,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

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

END Delete_Rack_Item;

Procedure Delete_Page_Racks (
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

cursor pageRacks_cursor IS
    select nested_region_code, nested_region_application_id
    from ak_region_items
    where region_code = p_internal_name
    and region_application_id = p_application_id;

begin

      if pageRacks_cursor%ISOPEN THEN
          CLOSE pageRacks_cursor;
      end if;

  for cr in pageRacks_cursor loop
    Delete_Rack_Region(
      p_internal_name => cr.nested_region_code,
      p_application_id => cr.nested_region_application_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);
  end loop;

  delete_region_items(
      p_internal_name => p_internal_name,
      p_application_id => p_application_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);

      if pageRacks_cursor%ISOPEN THEN
          CLOSE pageRacks_cursor;
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


END Delete_Page_Racks;

Procedure Delete_Region_Items (
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

cursor items_cursor IS
    select attribute_code, attribute_application_id
    from ak_region_items
    where region_code = p_internal_name
    and region_application_id = p_application_id;

begin
  if items_cursor%ISOPEN then
          close items_cursor;
  end if;

  for cr in items_cursor loop
      BIS_AK_REGION_PUB.DELETE_REGION_ITEM_ROW(
          p_REGION_CODE => p_internal_name,
          p_REGION_APPLICATION_ID => p_application_id,
          p_ATTRIBUTE_CODE => cr.attribute_code,
          p_ATTRIBUTE_APPLICATION_ID => cr.attribute_application_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data =>x_msg_data);
  end loop;

  if items_cursor%ISOPEN then
          close items_cursor;
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


END Delete_Region_Items;

function getUniqueRegion(
 p_internal_name  IN VARCHAR2
,p_application_id IN NUMBER) return VARCHAR2 is

l_region_code   VARCHAR2(30);
l_count     NUMBER;
l_done      BOOLEAN := false;
l_index     NUMBER := 0;
l_ascii     NUMBER;
cursor regions_cursor(p_region_code varchar2) IS
  select region_code
  from ak_regions
  where region_code like p_region_code || '%'
  and region_application_id = p_application_id;

BEGIN

      if regions_cursor%ISOPEN THEN
        CLOSE regions_cursor;
  end if;

  l_region_code := p_internal_name;

  -- Keep 2 characters for rack num
  if (length(l_region_code) > 28) then
    -- Truncate to 28 characters
    l_region_code := substr(l_region_code, 1, 28);
  end if;

  while (l_index < 99 and not l_done) loop
    l_count := 0;
    for cr in regions_cursor(l_region_Code) loop
      l_ascii := ascii(substr(cr.region_code, length(l_region_code)+1));
      if ((cr.region_code = l_region_code) or  (l_ascii >=48 and l_ascii <= 57)) then
        l_count := 1;
      end if;
    end loop;

    if (l_count > 0) then
      if (length(l_region_code) = 28) then
        -- Truncate one more time and append a counter
        l_index := l_index + 1;
        l_region_code := substr(l_region_code, 1, 27) || l_index;
      else
        l_index := l_index + 1;
        l_region_code := p_internal_name || l_index;
      end if;
    else
      l_done := true;
    end if;

  end loop;

  if not l_done then
    l_region_code := null;
  end if;

      if regions_cursor%ISOPEN THEN
          CLOSE regions_cursor;
      end if;

  return l_region_code;
EXCEPTION
  WHEN OTHERS THEN return null;

END getUniqueRegion;

procedure Migrate_Menu_To_MDS(
 p_internal_name    IN VARCHAR2
,p_application_id               IN NUMBER
,p_title      IN VARCHAR2
,p_page_function_name   IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_count     NUMBER := 0;
l_parameters    FND_FORM_FUNCTIONS.Parameters%Type := null;
l_function_id   NUMBER := NULL;
l_menu_name   FND_MENUS.Menu_Name%Type := NULL;
l_menu_id   NUMBER := NULL;
l_attr_category   VARCHAR2(30) := NULL;
l_app_short_name  VARCHAR2(30);
begin

  -- Check if Region code exists.
  begin
    select 1, attribute_category into l_count, l_attr_category
    from ak_regions
    where region_code = p_internal_name
    and region_application_id = p_application_id;
  exception
    when no_data_found then l_count := 0;
  end;

  if (l_count > 0) then
    if (l_attr_category = c_ATTRIBUTE_CATEGORY) then
      -- Already migrated, but migration is running again for some reason
      -- Delete the region and re-migrate
      Delete_Page_Racks(
        p_internal_name => p_internal_name,
        p_application_id => p_application_id,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data =>x_msg_data);
      BIS_AK_REGION_PUB.DELETE_REGION_ROW(
        p_REGION_CODE => p_internal_name,
        p_REGION_APPLICATION_ID => p_application_id,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data =>x_msg_data);
    else
            FND_MESSAGE.SET_NAME('BIS','BIS_PD_UNIQUE_PGE_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  -- Insert new Region
  BIS_AK_REGION_PUB.INSERT_REGION_ROW (
    p_REGION_CODE => p_internal_name,
    p_REGION_APPLICATION_ID => p_application_id,
    p_DATABASE_OBJECT_NAME => c_DUMMY_DB_OBJECT,
    p_NAME => p_title,
    p_REGION_STYLE => c_PAGE_LAYOUT,
    p_APPL_MODULE_OBJECT_TYPE => c_APP_MOD,
    p_ATTRIBUTE_CATEGORY => c_ATTRIBUTE_CATEGORY,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);


  select parameters, function_id into l_parameters, l_function_id
  from fnd_form_functions
  where function_name = p_page_function_name;

  select lower(application_short_name) into l_app_short_name
  from fnd_application
  where application_id = p_application_id;

  l_menu_name := BIS_COMMON_UTILS.getParameterValue(l_parameters, c_PAGE_NAME);

  l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_PAGE_NAME, c_MDS_PATH_PRE || l_app_short_name || c_MDS_PATH_POST || p_internal_name);
  l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_SOURCE_TYPE, c_MDS);
  -- This is put back just in case you need to go back to the FND_MENU
  -- Will be added only for migrated functions.
  l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_MENU_NAME, l_menu_name);

  -- Update Form Function
  BIS_FORM_FUNCTIONS_PUB.UPDATE_ROW (
    p_FUNCTION_ID => l_function_id,
    p_PARAMETERS => l_parameters,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

  -- mdamle 02/03/2004 - Update function name
  if p_page_function_name <> p_internal_name then
    UPDATE fnd_form_functions
    SET    function_name = p_internal_name
    WHERE  function_id = l_function_id;
  end  if;



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
end Migrate_Menu_To_MDS;


-- mdamle 02/06/2004 - Remove AK Region Integration
procedure Create_Page_Function(
 p_page_function_name           IN VARCHAR2
,p_application_id               IN NUMBER
,p_title                        IN VARCHAR2
,p_page_xml_name                IN VARCHAR2 := null
,p_description                  IN VARCHAR2 := NULL
,x_page_id                      OUT NOCOPY NUMBER
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_count       NUMBER;
l_parameters        FND_FORM_FUNCTIONS.Parameters%Type;
l_app_short_name    VARCHAR2(30);
l_page_xml_name                 FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
begin
  fnd_msg_pub.initialize;

  select count(1) into l_count
  from fnd_form_functions
  where function_name = p_page_function_name;

  if (l_count > 0) then
    -- Trying to update a non-page function.
          FND_MESSAGE.SET_NAME('BIS','BIS_PD_UNIQUE_PGE_ERR');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
  else

    select lower(application_short_name) into l_app_short_name
    from fnd_application
    where application_id = p_application_id;

    -- Insert Form Function

    if(p_page_xml_name is null) then
        l_page_xml_name := p_page_function_name;
    else
        l_page_xml_name := p_page_xml_name;
    end if;

    l_parameters := c_PAGE_NAME || '=' || c_MDS_PATH_PRE || l_app_short_name || c_MDS_PATH_POST || l_page_xml_name || '&' ||
      c_SOURCE_TYPE || '=' || c_MDS;


    BIS_FORM_FUNCTIONS_PUB.INSERT_ROW (
      p_FUNCTION_NAME => p_page_function_name,
      p_WEB_HTML_CALL => c_WEB_HTML_CALL,
      p_PARAMETERS => l_parameters,
      p_TYPE => c_FUNCTION_TYPE,
      p_USER_FUNCTION_NAME => p_title,
      p_DESCRIPTION => p_description,
      x_FUNCTION_ID => x_page_id,
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

end Create_Page_Function;

-- mdamle 02/06/2004 - Remove AK Region Integration
procedure Update_Page_Function(
 p_page_function_name   IN VARCHAR2
,p_application_id           IN NUMBER
,p_title                    IN VARCHAR2
,p_page_xml_name            IN VARCHAR2 := null
,p_new_page_function_name   IN VARCHAR2
,p_new_application_id       IN NUMBER
,p_new_page_xml_name        IN VARCHAR2 := null
,p_description              IN VARCHAR2 := NULL
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) is

l_count       NUMBER;
l_function_id     NUMBER := 0;
l_parameters        FND_FORM_FUNCTIONS.Parameters%Type;
l_app_short_name    VARCHAR2(30);
l_type        VARCHAR2(30);
l_page_function_name    FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
l_application_id    NUMBER;
l_menu_name     FND_MENUS.Menu_Name%Type := NULL;
l_page_xml_name                 FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
begin
  fnd_msg_pub.initialize;

  begin
    select  BIS_COMMON_UTILS.getParameterValue(parameters, c_SOURCE_TYPE),
      function_id,
      parameters
      into l_type, l_function_id, l_parameters
    from fnd_form_functions
    where function_name = p_page_function_name;
  exception
    when no_data_found then l_type := null;
  end;

  if p_new_page_function_name is null then
    l_page_function_name := p_page_function_name;
  else
    l_page_function_name := p_new_page_function_name;
  end if;

  if p_new_application_id is null then
    l_application_id := p_application_id;
  else
    l_application_id := p_new_application_id;
  end if;

  select lower(application_short_name) into l_app_short_name
  from fnd_application
  where application_id = l_application_id;

  if (l_type = c_FND_MENU) then
    l_menu_name := BIS_COMMON_UTILS.getParameterValue(l_parameters, c_PAGE_NAME);
    -- This is put back just in case you need to go back to the FND_MENU
    -- Will be added only for migrated functions.
    l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_MENU_NAME, l_menu_name);
  end if;

  if p_new_page_xml_name is null then
    l_page_xml_name := p_page_xml_name;
  else
    l_page_xml_name := p_new_page_xml_name;
  end if;

  l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_PAGE_NAME, c_MDS_PATH_PRE || l_app_short_name || c_MDS_PATH_POST || l_page_xml_name);
  l_parameters := BIS_COMMON_UTILS.replaceParameterValue(l_parameters, c_SOURCE_TYPE, c_MDS);

  -- Update form function
  if l_page_function_name <> p_page_function_name then
    -- Check if new function already exists.
    select count(1) into l_count
    from fnd_form_functions
    where function_name = l_page_function_name;

    if (l_count > 0) then
      -- Duplicate function name
            FND_MESSAGE.SET_NAME('BIS','BIS_PD_UNIQUE_PGE_ERR');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    end if;

    UPDATE fnd_form_functions
    SET    function_name = l_page_function_name
    WHERE  function_id = l_function_id;
  end  if;

  BIS_FORM_FUNCTIONS_PUB.UPDATE_ROW (
    p_FUNCTION_ID => l_function_id,
    p_USER_FUNCTION_NAME => p_title,
    p_PARAMETERS => l_parameters,
    p_DESCRIPTION => p_description,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data =>x_msg_data);

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

end Update_Page_Function;

FUNCTION Get_Custom_View_Name
(
  p_Function_Id FND_FORM_FUNCTIONS.FUNCTION_ID%TYPE
)RETURN VARCHAR2
IS
  l_custom_view_name VARCHAR2(200); -- Should be greater than custom view name and tab name
  l_tab_id           VARCHAR(10);
  l_parameters       FND_FORM_FUNCTIONS.PARAMETERS%TYPE; -- Parameters
  l_start_pos        NUMBER;
  l_end_pos          NUMBER;
  l_tab_name         BSC_TABS_VL.NAME%TYPE;
BEGIN
  SELECT user_function_name,parameters
  INTO l_custom_view_name,l_parameters
  FROM fnd_form_functions_vl
  WHERE function_id = p_Function_Id;

  l_tab_id := BIS_COMMON_UTILS.getParameterValue(l_parameters,'pTabId');
  IF(l_tab_id IS NOT NULL) THEN
    SELECT name
    INTO l_tab_name
    FROM bsc_tabs_vl
    WHERE tab_id = l_tab_id;
    l_custom_view_name := l_custom_view_name || '[' || l_tab_name || ']';
  END IF;
  RETURN l_custom_view_name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Custom_View_Name;


/*******************************************************
 Name         : Is_Simulatable_Cust_View
 Description  : This Function returns whether a particular custom view
                is simulatable or not.
 Input        : Parameter column of FND_FORM_FUCNTIONS_VL table.
 Output       :
                 '1' --> Indicates that it is a simulatable custom view
                 '0' --> Indicates that it is a normal custom view

 Created By   : ashankar 10-AUG-2005
/*******************************************************/

FUNCTION Is_Simulatable_Cust_View
(
  p_parameters    IN   FND_FORM_FUNCTIONS.parameters%TYPE
) RETURN NUMBER
IS
    l_region_Code      VARCHAR(100);
    l_return_value     VARCHAR(3);
BEGIN

    l_return_value := BIS_PAGE_PUB.c_NON_SIMULATABLE;

    IF(p_parameters IS NOT NULL) THEN
      l_region_Code := BIS_COMMON_UTILS.getParameterValue(p_parameters,'pRegionCode');

      IF(l_region_Code IS NOT NULL)THEN
        l_return_value := BIS_PAGE_PUB.c_SIMULATABLE;
      ELSE
        l_return_value := BIS_PAGE_PUB.c_NON_SIMULATABLE;
      END IF;

    END IF;
    RETURN l_return_value;
EXCEPTION
    WHEN OTHERS THEN
     RETURN l_return_value;
END Is_Simulatable_Cust_View;



end BIS_PAGE_PUB;

/
