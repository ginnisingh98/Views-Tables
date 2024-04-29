--------------------------------------------------------
--  DDL for Package Body BIS_FORM_FUNCTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_FORM_FUNCTIONS_PUB" as
/* $Header: BISPFFNB.pls 120.3 2005/09/20 03:55:02 akoduri noship $ */
----------------------------------------------------------------------------
--  PACKAGE:      BIS_FORM_FUNCTIONS_PUB                                  --
--                                                                        --
--  DESCRIPTION:  Private package that calls the FND packages to          --
--        insert records in the FND tables.                   --
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                                                        --
--  11/21/01   mdamle     Initial creation                                --
--  12/25/03   mdamle     Page Definer Integration - overloaded for addnl --
--                functionality and error messaging   --
--  06/07/04   mdamle     Added delete_function_and_menu_ent              --
--  07/19/04   ppalpart   Create method DELETE_ROW_MENU_MENUENTRIES       --
--  08/04/04   mdamle     Bug#3823878 - Add lock_row                      --
--  09/24/04   mdamle     Bug#3893663 - Return SQLERRM for all unexp errs --
--                        Added rollback within the lock procedure        --
--  09/28/04   mdamle     Bug#3919538 - Update function menu prompts      --
--  10/27/04   mdamle     Bug#3972992 - Region code and app id in form fn --
--  11/29/04   mdamle     Enh#4024237 - Application id in form fn         --
--  01/03/05   mdamle     Enh#3014083 - Integrate with Extension table    --
--  01/13/05   vtulasi    Bug#4102897 - Change in size of variables       --
--  01/29/05   akoduri    Bug#4083833 - Select Content FROM OA Region     --
--  02/02/05   rpenneru   Bug#4139236 - Update description if p_description-
--                        is NULL                                         --
--  03/21/05   ankagarw   bug#4235732 - changing count(*) to count(1)     --
--  04/04/05   mdamle     Bug#4204828 - Call api to delete menu entries   --
--				  so cache is invalidated				  --
--  04/12/05   arhegde    Bug#4273118 - Remove the check for FA customer  --
--				  defnd before call to Create_Form_Func_Extension --
--  05/22/05   akoduri    Enhancement#3865711 -- Obsolete Seeded Objects  --
--  05/03/05   rpenneru   Enhancement#4346994 -- HTML Portlet             --
--  19-MAY-2005 visuri   GSCC Issues bug 4363854                         --
--  17-AUG-2005 kyadamak Bug#4516889 added regioncode,regionapplid to update_row --
--  20-SEP-2005 akoduri  bug#4607348 - Obsoletion of measures is not      --
--                       changing the last_update_date and last_updated_by--
----------------------------------------------------------------------------

procedure INSERT_ROW (
    X_ROWID in out NOCOPY VARCHAR2,
    X_USER_ID in NUMBER,
    X_FUNCTION_ID in out NOCOPY VARCHAR2,
    X_WEB_HTML_CALL in VARCHAR2,
    X_FUNCTION_NAME in VARCHAR2,
    X_PARAMETERS in VARCHAR2,
    X_TYPE in VARCHAR2,
    X_USER_FUNCTION_NAME in VARCHAR2,
    X_DESCRIPTION in VARCHAR2) is

l_new_function_id   NUMBER;

begin
    select FND_FORM_FUNCTIONS_S.NEXTVAL into l_new_function_id from dual;

    FND_FORM_FUNCTIONS_PKG.INSERT_ROW(
            X_ROWID                  => X_ROWID,
            X_FUNCTION_ID            => l_new_function_id,
            X_WEB_HOST_NAME          => null,
            X_WEB_AGENT_NAME         => null,
            X_WEB_HTML_CALL          => X_WEB_HTML_CALL,
            X_WEB_ENCRYPT_PARAMETERS => c_WEB_ENCRYPT_PARAMETERS,
            X_WEB_SECURED            => c_WEB_SECURED,
            X_WEB_ICON               => null,
            X_OBJECT_ID              => null,
            X_REGION_APPLICATION_ID  => null,
            X_REGION_CODE            => null,
            X_FUNCTION_NAME          => upper(X_FUNCTION_NAME),
            X_APPLICATION_ID         => null,
            X_FORM_ID                => null,
            X_PARAMETERS             => X_PARAMETERS,
            X_TYPE                   => X_TYPE,
            X_USER_FUNCTION_NAME     => X_USER_FUNCTION_NAME,
            X_DESCRIPTION            => X_DESCRIPTION,
        X_CREATION_DATE => sysdate,
        X_CREATED_BY => X_USER_ID,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => X_USER_ID,
        X_LAST_UPDATE_LOGIN => X_USER_ID,
            X_MAINTENANCE_MODE_SUPPORT => NULL,
            X_CONTEXT_DEPENDENCE       => NULL);

    if X_ROWID is not null then
        X_FUNCTION_ID := l_new_function_id;
    end if;

end INSERT_ROW;

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
procedure INSERT_ROW (
 p_FUNCTION_NAME    in VARCHAR2
,p_WEB_HTML_CALL    in VARCHAR2
,p_PARAMETERS       in VARCHAR2
,p_TYPE         in VARCHAR2
,p_USER_FUNCTION_NAME   in VARCHAR2
,p_DESCRIPTION      in VARCHAR2 := NULL
,x_FUNCTION_ID      OUT NOCOPY NUMBER
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
,x_msg_data             OUT NOCOPY VARCHAR2
,p_REGION_CODE           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_REGION_APPLICATION_ID in NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
,p_APPLICATION_ID        in NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
,p_OBJECT_TYPE           in VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_FUNCTIONAL_AREA_ID        in NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
) is

l_rowid         VARCHAR2(30);
l_new_function_id   NUMBER;
l_region_application_id NUMBER := null;
l_region_code       VARCHAR2(30) := null;
l_application_id    NUMBER := null;
l_Form_Func_Extn_Rec BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
l_custom_functional_area_id number;

begin
    select FND_FORM_FUNCTIONS_S.NEXTVAL into l_new_function_id from dual;

    if p_region_application_id <> BIS_COMMON_UTILS.G_DEF_NUM then
        l_region_application_id := p_region_application_id;
    end if;

    if p_region_code <> BIS_COMMON_UTILS.G_DEF_CHAR then
        l_region_code := p_region_code;
    end if;

    if p_application_id <> BIS_COMMON_UTILS.G_DEF_NUM then
        l_application_id := p_application_id;
    end if;


    FND_FORM_FUNCTIONS_PKG.INSERT_ROW(
            X_ROWID                  => l_ROWID,
            X_FUNCTION_ID            => l_new_function_id,
            X_WEB_HOST_NAME          => null,
            X_WEB_AGENT_NAME         => null,
            X_WEB_HTML_CALL          => p_WEB_HTML_CALL,
            X_WEB_ENCRYPT_PARAMETERS => c_WEB_ENCRYPT_PARAMETERS,
            X_WEB_SECURED            => c_WEB_SECURED,
            X_WEB_ICON               => null,
            X_OBJECT_ID              => null,
            X_REGION_APPLICATION_ID  => l_region_application_id,
            X_REGION_CODE            => l_region_code,
            X_FUNCTION_NAME          => upper(p_FUNCTION_NAME),
            X_APPLICATION_ID         => null,
            X_FORM_ID                => null,
            X_PARAMETERS             => p_PARAMETERS,
            X_TYPE                   => p_TYPE,
            X_USER_FUNCTION_NAME     => p_USER_FUNCTION_NAME,
            X_DESCRIPTION            => p_DESCRIPTION,
        X_CREATION_DATE      => sysdate,
        X_CREATED_BY         => fnd_global.user_id,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_MAINTENANCE_MODE_SUPPORT => NULL,
        X_CONTEXT_DEPENDENCE       => NULL);

    if l_ROWID is not null then
        x_FUNCTION_ID := l_new_function_id;
    end if;

    -- mdamle 01/03/2005 - Integrate with extension table
    if p_functional_area_id <> BIS_COMMON_UTILS.G_DEF_NUM and p_object_type <> BIS_COMMON_UTILS.G_DEF_CHAR and p_application_id <> BIS_COMMON_UTILS.G_DEF_NUM then
      l_Form_Func_Extn_Rec.object_type := p_object_type;
      l_Form_Func_Extn_Rec.object_name := upper(p_FUNCTION_NAME);
      l_Form_Func_Extn_Rec.application_id := l_application_id;
      l_Form_Func_Extn_Rec.func_area_id := p_functional_area_id;
      BIS_OBJECT_EXTENSIONS_PUB.Create_Form_Func_Extension(
          p_Api_Version => 1.0
        , p_Commit => FND_API.G_FALSE
        , p_Form_Func_Extn_Rec  => l_Form_Func_Extn_Rec
        , x_Return_Status => x_return_status
        , x_Msg_Count => x_msg_count
        , x_Msg_Data  => x_msg_data);
    end if;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_FORM_FUNCTIONS_PUB.INSERT_ROW: ' || SQLERRM;
    end if;

end INSERT_ROW;


procedure UPDATE_ROW (
    X_USER_ID in NUMBER,
    X_FUNCTION_ID in NUMBER,
    X_PARAMETERS in VARCHAR2,
    X_DESCRIPTION in VARCHAR2) is

l_formFunction_rec FormFunction_Rec_Type;

cursor cFormFunction is
select     function_name,
       user_function_name,
       type,
       web_html_call,
       web_host_name,
       web_agent_name,
       web_encrypt_parameters,
       web_secured,
       web_icon,
       object_id,
       region_application_id,
       region_code,
       application_id,
       form_id,
       maintenance_mode_support,
       context_dependence
from fnd_form_functions_vl
where function_id = X_FUNCTION_ID;

begin

    if cFormFunction%ISOPEN then
            CLOSE cFormFunction;
    end if;

        OPEN cFormFunction;
        FETCH cFormFunction INTO
        l_formFunction_rec.function_name,
        l_formFunction_rec.user_function_name,
        l_formFunction_rec.type,
        l_formFunction_rec.web_html_call,
        l_formFunction_rec.web_host_name,
        l_formFunction_rec.web_agent_name,
        l_formFunction_rec.web_encrypt_parameters,
        l_formFunction_rec.web_secured,
        l_formFunction_rec.web_icon,
        l_formFunction_rec.object_id,
        l_formFunction_rec.region_application_id,
        l_formFunction_rec.region_code,
        l_formFunction_rec.application_id,
        l_formFunction_rec.form_id,
        l_formFunction_rec.maintenance_mode_support,
        l_formFunction_rec.context_dependence;
    CLOSE cFormFunction;

    FND_FORM_FUNCTIONS_PKG.UPDATE_ROW(
        X_FUNCTION_ID => X_FUNCTION_ID,
        X_WEB_HOST_NAME => l_formFunction_rec.web_host_name,
        X_WEB_AGENT_NAME => l_formFunction_rec.web_agent_name,
        X_WEB_HTML_CALL => l_formFunction_rec.web_html_call,
        X_WEB_ENCRYPT_PARAMETERS => l_formFunction_rec.web_encrypt_parameters,
        X_WEB_SECURED => l_formFunction_rec.web_secured,
        X_WEB_ICON => l_formFunction_rec.web_icon,
        X_OBJECT_ID => l_formFunction_rec.object_id,
        X_REGION_APPLICATION_ID => l_formFunction_rec.region_application_id,
        X_REGION_CODE => l_formFunction_rec.region_code,
        X_FUNCTION_NAME => l_formFunction_rec.function_name,
        X_APPLICATION_ID => l_formFunction_rec.application_id,
        X_FORM_ID => l_formFunction_rec.form_id,
        X_PARAMETERS => X_PARAMETERS,
        X_TYPE => l_formFunction_rec.type,
        X_USER_FUNCTION_NAME => l_formFunction_rec.user_function_name,
        X_DESCRIPTION => X_DESCRIPTION,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => X_USER_ID,
        X_LAST_UPDATE_LOGIN => X_USER_ID,
        X_MAINTENANCE_MODE_SUPPORT => l_formFunction_rec.maintenance_mode_support,
        X_CONTEXT_DEPENDENCE => l_formFunction_rec.context_dependence);

end UPDATE_ROW;

-- mdamle 12/25/2003 - overloaded for additional functionality & error messaging
PROCEDURE UPDATE_ROW (
 p_FUNCTION_ID            IN  NUMBER
,p_USER_FUNCTION_NAME     IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_PARAMETERS             IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_DESCRIPTION            IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_WEB_HTML_CALL          IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_APPLICATION_ID         IN  NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
,p_OBJECT_TYPE            IN  VARCHAR2 := BIS_COMMON_UTILS.G_DEF_CHAR
,p_FUNCTIONAL_AREA_ID     IN  NUMBER := BIS_COMMON_UTILS.G_DEF_NUM
,x_return_status          OUT NOCOPY VARCHAR2
,x_msg_count              OUT NOCOPY NUMBER
,x_msg_data               OUT NOCOPY VARCHAR2
,p_REGION_CODE            IN  VARCHAR2 := NULL
,p_REGION_APPLICATION_ID  IN  NUMBER := NULL
) IS

l_formFunction_rec FormFunction_Rec_Type;
l_Form_Func_Extn_Rec BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
l_custom_functional_area_id number;
l_function_name FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
l_count number;

cursor cFormFunction is
select     function_name,
       type,
       web_html_call,
       web_host_name,
       web_agent_name,
       web_encrypt_parameters,
       web_secured,
       web_icon,
       object_id,
       region_application_id,
       region_code,
       application_id,
       form_id,
       maintenance_mode_support,
       context_dependence,
       user_function_name,
       description,
       parameters
from fnd_form_functions_vl
where function_id = p_FUNCTION_ID;

begin

    if cFormFunction%ISOPEN then
            CLOSE cFormFunction;
    end if;

        OPEN cFormFunction;
        FETCH cFormFunction INTO
        l_formFunction_rec.function_name,
        l_formFunction_rec.type,
        l_formFunction_rec.web_html_call,
        l_formFunction_rec.web_host_name,
        l_formFunction_rec.web_agent_name,
        l_formFunction_rec.web_encrypt_parameters,
        l_formFunction_rec.web_secured,
        l_formFunction_rec.web_icon,
        l_formFunction_rec.object_id,
        l_formFunction_rec.region_application_id,
        l_formFunction_rec.region_code,
        l_formFunction_rec.application_id,
        l_formFunction_rec.form_id,
        l_formFunction_rec.maintenance_mode_support,
        l_formFunction_rec.context_dependence,
        l_formFunction_rec.user_function_name,
        l_formFunction_rec.description,
        l_formFunction_rec.parameters;
    CLOSE cFormFunction;

    if (p_user_function_name <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_formFunction_rec.user_function_name := p_user_function_name;
    end if;
    if (p_description IS NULL ) THEN
	   l_formFunction_rec.description := NULL;
    elsif (p_description <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_formFunction_rec.description := p_description;
    end if;
    if (p_parameters <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_formFunction_rec.parameters := p_parameters;
    end if;
    if (p_web_html_call <> BIS_COMMON_UTILS.G_DEF_CHAR) then
        l_formFunction_rec.web_html_call := p_web_html_call;
    end if;

    l_formFunction_rec.region_code  := p_REGION_CODE; --We need to update with null even in update case
    l_formFunction_rec.region_application_id := p_REGION_APPLICATION_ID;

    FND_FORM_FUNCTIONS_PKG.UPDATE_ROW(
        X_FUNCTION_ID => p_FUNCTION_ID,
        X_WEB_HOST_NAME => l_formFunction_rec.web_host_name,
        X_WEB_AGENT_NAME => l_formFunction_rec.web_agent_name,
        X_WEB_HTML_CALL => l_formFunction_rec.web_html_call,
        X_WEB_ENCRYPT_PARAMETERS => l_formFunction_rec.web_encrypt_parameters,
        X_WEB_SECURED => l_formFunction_rec.web_secured,
        X_WEB_ICON => l_formFunction_rec.web_icon,
        X_OBJECT_ID => l_formFunction_rec.object_id,
        X_REGION_APPLICATION_ID => l_formFunction_rec.region_application_id,
        X_REGION_CODE => l_formFunction_rec.region_code,
        X_FUNCTION_NAME => l_formFunction_rec.function_name,
        X_APPLICATION_ID => l_formFunction_rec.application_id,
        X_FORM_ID => l_formFunction_rec.form_id,
        X_PARAMETERS => l_formFunction_rec.parameters,
        X_TYPE => l_formFunction_rec.type,
        X_USER_FUNCTION_NAME => l_formFunction_rec.user_function_name,
        X_DESCRIPTION => l_formFunction_rec.description,
        X_LAST_UPDATE_DATE => sysdate,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.user_id,
        X_MAINTENANCE_MODE_SUPPORT => l_formFunction_rec.maintenance_mode_support,
        X_CONTEXT_DEPENDENCE => l_formFunction_rec.context_dependence);
    if p_functional_area_id <> BIS_COMMON_UTILS.G_DEF_NUM and p_object_type <> BIS_COMMON_UTILS.G_DEF_CHAR and p_application_id <> BIS_COMMON_UTILS.G_DEF_NUM then
        select function_name into l_function_name
        from fnd_form_functions_vl
        where function_id = p_FUNCTION_ID;
        select count(1) into l_count from bis_form_function_extension where upper(object_name) = upper(l_function_name);
        l_Form_Func_Extn_Rec.object_type := p_object_type;
        l_Form_Func_Extn_Rec.object_name := upper(l_function_name);
        l_Form_Func_Extn_Rec.application_id := p_application_id;
        l_Form_Func_Extn_Rec.func_area_id := p_functional_area_id;
        if l_count > 0 then
            BIS_OBJECT_EXTENSIONS_PUB.Update_Form_Func_Extension(
                 p_Api_Version => 1.0
              ,  p_Commit => FND_API.G_FALSE
              ,  p_Form_Func_Extn_Rec  => l_Form_Func_Extn_Rec
              ,  x_Return_Status => x_return_status
              ,  x_Msg_Count => x_msg_count
              ,  x_Msg_Data  => x_msg_data);
        else
           BIS_OBJECT_EXTENSIONS_PUB.Create_Form_Func_Extension(
                p_Api_Version => 1.0
              , p_Commit => FND_API.G_FALSE
              , p_Form_Func_Extn_Rec  => l_Form_Func_Extn_Rec
              , x_Return_Status => x_return_status
              , x_Msg_Count => x_msg_count
              , x_Msg_Data  => x_msg_data);

        end if;
    end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data :=  'BIS_FORM_FUNCTIONS_PUB.UPDATE_ROW: ' || SQLERRM;
    end if;

end UPDATE_ROW;

-- mdamle 12/25/2003
PROCEDURE DELETE_ROW (
 p_FUNCTION_ID          in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
 ) IS
l_function_name FND_FORM_FUNCTIONS.FUNCTION_NAME%TYPE;
l_Form_Func_Extn_Rec BIS_OBJECT_EXTENSIONS_PUB.Form_Function_Extension_Type;
l_count number;

BEGIN

  select function_name into l_function_name
  from fnd_form_functions
  where function_id = p_function_id;

  FND_FORM_FUNCTIONS_PKG.DELETE_ROW(
    X_FUNCTION_ID => p_FUNCTION_ID
  );

  -- mdamle 01/03/2005 - Integrate with extension table
  l_Form_Func_Extn_Rec.object_name := l_function_name;
  select count(1) into l_count from bis_form_function_extension where object_name = l_function_name;
  if l_count > 0 then

      BIS_OBJECT_EXTENSIONS_PUB.Delete_Form_Func_Extension(
            p_Api_Version => 1.0
         ,  p_Commit => FND_API.G_FALSE
         ,  p_Form_Func_Extn_Rec  => l_Form_Func_Extn_Rec
         ,  x_Return_Status => x_return_status
         ,  x_Msg_Count => x_msg_count
         ,  x_Msg_Data  => x_msg_data);
   end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
    x_msg_data := 'BIS_FORM_FUNCTIONS_PUB.DELETE_ROW: ' || SQLERRM;
    end if;

END DELETE_ROW;

--Copied from BIS_KPILIST_WIZARD_PKG
PROCEDURE DELETE_FUNCTION_AND_MENU_ENT
(p_function_name                IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
    l_function_id   fnd_form_functions.function_id%TYPE;

    CURSOR function_id_crsr IS
        SELECT function_id
        FROM fnd_form_functions
        WHERE function_name = p_function_name;

    CURSOR c_menu_entries (p_function_id fnd_menu_entries.function_id%TYPE) IS
    SELECT menu_id, entry_sequence
    FROM fnd_menu_entries
    WHERE function_id = p_function_id;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (function_id_crsr%ISOPEN) THEN
        CLOSE function_id_crsr;
    END IF;

    OPEN function_id_crsr;
    FETCH function_id_crsr INTO l_function_id;
    CLOSE function_id_crsr;

    /* Also delete the menu entries corresponding to this function */
    if c_menu_entries%ISOPEN then
      	CLOSE c_menu_entries;
    end if;

    for mentry in c_menu_entries(l_function_id) loop
	bis_menu_entries_pub.delete_row(x_menu_id=>mentry.menu_id,
								x_entry_sequence => mentry.entry_sequence,
								x_return_status=> x_return_status,
								x_msg_count => x_msg_count,
								x_msg_data => x_msg_data);

    end loop;

    delete_row(p_function_id => l_function_id,
						x_return_status=> x_return_status,
						x_msg_count => x_msg_count,
						x_msg_data => x_msg_data);

    IF (function_id_crsr%ISOPEN) THEN
        CLOSE function_id_crsr;
    END IF;

    IF (c_menu_entries%ISOPEN) THEN
        CLOSE c_menu_entries;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_FORM_FUNCTIONS_PUB.DELETE_FUNCTION_AND_MENU_ENT: ' || SQLERRM;
    end if;

END DELETE_FUNCTION_AND_MENU_ENT;

PROCEDURE DELETE_ROW_FUNC_MENUENTRIES (
 p_FUNCTION_ID          in VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
 ) IS

 l_return_status          VARCHAR2(40);
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(40);
 cursor entry_seq_menu_cursor is
                            select menu_id, entry_sequence
                            from fnd_menu_entries
                            where function_id = p_FUNCTION_ID;
BEGIN

for ent_seq_menu_cur in entry_seq_menu_cursor loop

   BIS_MENU_ENTRIES_PUB.DELETE_ROW (X_MENU_ID => ent_seq_menu_cur.menu_id,
                                    X_ENTRY_SEQUENCE => ent_seq_menu_cur.entry_sequence,
                                    x_return_status => l_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data);

end loop;

  FND_FORM_FUNCTIONS_PKG.DELETE_ROW(
    X_FUNCTION_ID => p_FUNCTION_ID
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_FORM_FUNCTIONS_PUB.DELETE_ROW_FUNC_MENUENTRIES: ' || SQLERRM;
    end if;

END DELETE_ROW_FUNC_MENUENTRIES;


PROCEDURE LOCK_FUNCTION_ROW
(  p_function_id                  IN         NUMBER
 , p_last_update_date             IN         VARCHAR2
 , x_record_status                OUT NOCOPY VARCHAR2
) IS

 l_last_update_date    date;

 cursor cFunction is select last_update_date
 from fnd_form_functions
 where function_id = p_function_id
 for update of function_id nowait;

BEGIN

    SAVEPOINT SP_LOCK_FUNCTION_ROW;

    IF cFunction%ISOPEN THEN
       CLOSE cFunction;
    END IF;
    OPEN cFunction;
    FETCH cFunction INTO l_last_update_date;

    if (cFunction%notfound) then
        x_record_status := BIS_FORM_FUNCTIONS_PUB.c_RECORD_DELETED;
    end if;

    if p_last_update_date is not null then
    if p_last_update_date <> TO_CHAR(l_last_update_date, BIS_FORM_FUNCTIONS_PUB.C_LAST_UPDATE_DATE_FORMAT) then
        x_record_status := BIS_FORM_FUNCTIONS_PUB.c_RECORD_CHANGED;
    end if;
    end if;

    rollback to SP_LOCK_FUNCTION_ROW;
    CLOSE cFunction;

EXCEPTION
  WHEN OTHERS THEN
    close cFunction;
    x_record_status := BIS_FORM_FUNCTIONS_PUB.c_RECORD_CHANGED;
    rollback to SP_LOCK_FUNCTION_ROW;
END LOCK_FUNCTION_ROW;

-- mdamle 09/28/2004 - Update menu prompts from user_function_name
PROCEDURE UPDATE_FUNCTION_MENU_PROMPTS
(p_function_id                  IN NUMBER
,p_user_function_name           IN VARCHAR2
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
    CURSOR menu_crsr (p_function_id fnd_menu_entries.function_id%TYPE) IS
    SELECT menu_id, entry_sequence
    FROM fnd_menu_entries
    WHERE function_id = p_function_id;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    for rec in menu_crsr(p_function_id) loop
        BIS_MENU_ENTRIES_PUB.UPDATE_PROMPT (
            X_USER_ID => fnd_global.user_id,
            X_MENU_ID => rec.menu_id,
            X_OLD_ENTRY_SEQUENCE => rec.entry_sequence,
            X_FUNCTION_ID => p_function_id,
            X_PROMPT => p_user_function_name);
    end loop;

        if (menu_crsr%ISOPEN) then
            close menu_crsr;
        end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BIS_FORM_FUNCTIONS_PUB.UPDATE_FUNCTION_MENU_PROMPTS: ' || SQLERRM;
    end if;

END UPDATE_FUNCTION_MENU_PROMPTS;


PROCEDURE Update_Form_Func_Obsolete_Flag (
    p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
    p_func_name                   IN VARCHAR2,
    p_obsolete                    IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT nocopy VARCHAR2
) IS
 l_form_func_parameters  FND_FORM_FUNCTIONS_VL.PARAMETERS%TYPE;
 l_form_function_id      FND_FORM_FUNCTIONS_VL.FUNCTION_ID%TYPE;
 l_form_func_description FND_FORM_FUNCTIONS_VL.DESCRIPTION%TYPE;

 BEGIN
    SAVEPOINT FormFunctionObsoleteUpdate;
    IF (p_func_name IS NULL OR p_func_name = '') THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_INV_FORM_FUNC_VAL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_obsolete IS NULL OR (p_obsolete <> 'Y' AND p_obsolete <> 'N')) THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_PMF_INVALID_OBSOLETE_FLAG');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT function_id,parameters,description
    INTO l_form_function_id,l_form_func_parameters,l_form_func_description
    FROM fnd_form_functions_vl
    WHERE function_name = p_func_name;

    IF (p_obsolete = 'Y') THEN
      l_form_func_parameters := l_form_func_parameters || '&pObsoleteFlag=Y';
    END IF;

    IF (p_obsolete = 'N') THEN
      l_form_func_parameters := REPLACE(l_form_func_parameters,'&pObsoleteFlag=Y');
    END IF;

    BIS_FORM_FUNCTIONS_PUB.UPDATE_ROW(
      X_USER_ID     => FND_GLOBAL.USER_ID,
      X_FUNCTION_ID => l_form_function_id,
      X_PARAMETERS  => l_form_func_parameters,
      X_DESCRIPTION => l_form_func_description
    );

    IF(p_Commit = FND_API.G_TRUE) THEN
      commit;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN;
 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ROLLBACK TO FormFunctionObsoleteUpdate;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BIS_FORM_FUNCTIONS_PUB.Update_Form_Func_Obsolete_Flag ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BIS_FORM_FUNCTIONS_PUB.Update_Form_Func_Obsolete_Flag ';
       END IF;
 END Update_Form_Func_Obsolete_Flag;


PROCEDURE Check_Form_Function (
   p_functionName                 IN  VARCHAR2
  ,p_user_functionName            IN  VARCHAR2
  ,x_return_status                OUT NOCOPY VARCHAR2
  ,x_msg_count                    OUT NOCOPY NUMBER
  ,x_msg_data                     OUT NOCOPY VARCHAR2
) IS
  l_ret_status            VARCHAR2(10);
  l_msg_data              VARCHAR2(100);
  l_parent_obj_table  BIS_RSG_PUB_API_PKG.t_BIA_RSG_Obj_Table;
  l_index  INTEGER;
  l_dep_obj_list          VARCHAR2(2000);
 BEGIN
    FND_MSG_PUB.Initialize;
    x_msg_data := '';
    IF (p_functionName IS NULL OR p_functionName = '') THEN
       FND_MESSAGE.SET_NAME('BIS','BIS_INV_FORM_FUNC_VAL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_parent_obj_table := BIS_RSG_PUB_API_PKG.GetParentObjects(p_functionName,'PORTLET','PAGE',l_ret_status,l_msg_data);

    IF ((l_ret_status IS NOT NULL) AND (l_ret_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
       FND_MESSAGE.SET_NAME('BIS',l_msg_data);
       FND_MSG_PUB.ADD;
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSE
      IF (l_parent_obj_table.COUNT > 0) THEN
        l_dep_obj_list := '';
        l_index := l_parent_obj_table.first;
        LOOP
          l_dep_obj_list := l_dep_obj_list ||'<li>'|| l_parent_obj_table(l_index).object_name ||'</li>';
          EXIT WHEN l_index = l_parent_obj_table.last;
          l_index := l_parent_obj_table.next(l_index);
        END LOOP;
        FND_MESSAGE.SET_NAME('BIS','BIS_HTML_PORTLET_DELETE');
        FND_MESSAGE.SET_TOKEN('PORTLET', p_user_functionName);
        FND_MESSAGE.SET_TOKEN('DEP_OBJ_LIST',l_dep_obj_list);
	FND_MSG_PUB.ADD;
     END IF;
   END IF;
   FND_MSG_PUB.Count_And_Get
    (      p_encoded   =>  FND_API.G_FALSE
       ,   p_count     =>  x_msg_count
       ,   p_data      =>  x_msg_data
    );
 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BIS_FORM_FUNCTIONS_PUB.Check_Form_Function ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BIS_FORM_FUNCTIONS_PUB.Check_Form_Function ';
       END IF;
 END Check_Form_Function;


END BIS_FORM_FUNCTIONS_PUB;

/
