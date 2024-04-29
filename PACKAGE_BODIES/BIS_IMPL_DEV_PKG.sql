--------------------------------------------------------
--  DDL for Package Body BIS_IMPL_DEV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_IMPL_DEV_PKG" AS
/* $Header: BISCONCB.pls 120.10 2007/12/27 12:44:55 lbodired ship $ */
   version          CONSTANT CHAR (80)
            := '$Header: BISCONCB.pls 120.10 2007/12/27 12:44:55 lbodired ship $';

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------
   G_PKG_NAME                VARCHAR2(30) := 'BIS_IMPL_DEV_PKG';
   g_current_user_id         NUMBER  :=  FND_GLOBAL.User_id;
   g_current_login_id        NUMBER  :=  FND_GLOBAL.Login_id;

function clob_to_varchar2 (
  p_in      clob,
  p_size    integer
) return varchar2
is
  l_result  varchar2(32767) := '';
  l_amount  integer := 0;
  l_offset  integer := 1;
begin
   if (p_in is null or
      DBMS_LOB.getlength(p_in) = 0 ) then
     return '';
   else
     l_amount := p_size;
     DBMS_LOB.READ(p_in, l_amount, l_offset, l_result);
     return l_result;
   end if;
end;


procedure Create_Linkage_Inner (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROGRAM_NAME	in VARCHAR2,
 P_CONC_APP_ID		in NUMBER,
 P_CONC_APP_SHORT_NAME	in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_REFRESH_MODE         in VARCHAR2,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is
    l_sysdate               DATE         := sysdate;
    l_api_name           CONSTANT VARCHAR2(30)   := 'Create_Linkage';
    l_created_by         NUMBER := nvl(P_CREATED_BY,g_current_user_id);
    l_creation_date      DATE   := nvl(P_CREATION_DATE, l_Sysdate);
    l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
    l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
    l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);

    cursor c_in_properties(p_object_name varchar2, p_object_type varchar2) is
      select object_name
      from bis_obj_properties
      where object_name = p_object_name
        and object_type = p_object_type;

    l_object_name bis_obj_properties.object_name%type;

begin
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    insert into bis_obj_prog_linkages (
        OBJECT_TYPE,
        OBJECT_OWNER,
        OBJECT_NAME,
        CONC_PROGRAM_NAME,
        CONC_APP_ID,
        CONC_APP_SHORT_NAME,
        ENABLED_FLAG,
        REFRESH_MODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
    values(
        P_OBJECT_TYPE,
        P_OBJECT_OWNER,
        P_OBJECT_NAME,
        P_CONC_PROGRAM_NAME,
        P_CONC_APP_ID,
        P_CONC_APP_SHORT_NAME,
        P_ENABLED_FLAG,
        P_REFRESH_MODE,
        L_CREATED_BY,
        L_CREATION_DATE,
        L_LAST_UPDATED_BY,
        L_LAST_UPDATE_LOGIN,
        L_LAST_UPDATE_DATE);

    /* create new rows in bis_obj_properties if it is a new object */

    /* temporarily remove this logic, leave this change to 4.0.9
    open c_in_properties(p_object_name, p_object_type);
    fetch c_in_properties into l_object_name;
    if c_in_properties%NOTFOUND then
       create_properties(
			 P_OBJECT_TYPE           => p_object_type,
			 P_OBJECT_NAME		=> p_object_name,
			 P_OBJECT_OWNER		=> p_object_owner,
			 P_SNAPSHOT_LOG_SQL	=> null,
			 P_FAST_REFRESH_FLAG	=> null,
			 P_DIMENSION_FLAG        => null,
			 x_return_status         => x_return_status,
			 x_errorcode             => x_errorcode,
			 x_msg_count             => x_msg_count,
			 x_msg_data              => x_msg_data
			 );
    end if;
    close c_in_properties;
    */

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      raise;
end Create_Linkage_Inner;


procedure Create_Linkage (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROGRAM_NAME	in VARCHAR2,
 P_CONC_APP_ID		in NUMBER,
 P_CONC_APP_SHORT_NAME	in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_REFRESH_MODE         in VARCHAR2,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is
begin
Create_Linkage_Inner (
 P_OBJECT_TYPE,
 P_OBJECT_OWNER,
 P_OBJECT_NAME,
 P_CONC_PROGRAM_NAME,
 P_CONC_APP_ID,
 P_CONC_APP_SHORT_NAME,
 P_ENABLED_FLAG,
 P_REFRESH_MODE,
 P_CREATED_BY,
 P_CREATION_DATE,
 P_LAST_UPDATED_BY,
 P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATE_DATE,
 p_init_msg_list,
 p_commit,
 x_return_status,
 x_errorcode,
 x_msg_count,
 x_msg_data
);
exception
    when others then
       null;
end Create_Linkage;


procedure Update_Linkage_Inner (
 P_ROWID		in ROWID,
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROGRAM_NAME	in VARCHAR2,
 P_CONC_APP_ID		in NUMBER,
 P_CONC_APP_SHORT_NAME	in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_REFRESH_MODE         in VARCHAR2,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is
    l_sysdate               DATE         := sysdate;
    l_api_name           CONSTANT VARCHAR2(30)   := 'Update_Linkage';
    l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
    l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
    l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);
begin
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    if (P_ROWID is not null) then
      update bis_obj_prog_linkages
      set enabled_flag            = P_ENABLED_FLAG,
          conc_program_name       = P_CONC_PROGRAM_NAME,
          conc_app_id             = P_CONC_APP_ID,
          conc_app_short_name     = P_CONC_APP_SHORT_NAME,
          refresh_mode            = P_REFRESH_MODE,
          last_updated_by         = l_last_updated_by,
          last_update_login       = l_last_update_login,
          last_update_date        = l_last_update_date
      where rowid  = P_ROWID;
    else
      UPDATE BIS_OBJ_PROG_LINKAGES
      SET
           ENABLED_FLAG          = P_ENABLED_FLAG,
           REFRESH_MODE          = P_REFRESH_MODE,
           LAST_UPDATE_DATE      = L_LAST_UPDATE_DATE,
           LAST_UPDATED_BY       = L_LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN     = L_LAST_UPDATE_LOGIN
      WHERE OBJECT_TYPE          = P_OBJECT_TYPE
      AND OBJECT_NAME       = P_OBJECT_NAME
      AND OBJECT_OWNER      = P_OBJECT_OWNER
      AND CONC_PROGRAM_NAME = P_CONC_PROGRAM_NAME
      AND CONC_APP_ID       = P_CONC_APP_ID;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      raise;
end Update_Linkage_Inner;

procedure Update_Linkage (
 P_ROWID		in ROWID,
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROGRAM_NAME	in VARCHAR2,
 P_CONC_APP_ID		in NUMBER,
 P_CONC_APP_SHORT_NAME	in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_REFRESH_MODE         in VARCHAR2,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is
begin
Update_Linkage_Inner (
 P_ROWID,
 P_OBJECT_TYPE,
 P_OBJECT_OWNER,
 P_OBJECT_NAME,
 P_CONC_PROGRAM_NAME,
 P_CONC_APP_ID,
 P_CONC_APP_SHORT_NAME,
 P_ENABLED_FLAG,
 P_REFRESH_MODE,
 P_LAST_UPDATED_BY,
 P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATE_DATE,
 p_init_msg_list,
 p_commit,
 x_return_status,
 x_errorcode,
 x_msg_count,
 x_msg_data
);
exception
    when others then
      null;
end Update_Linkage;



procedure Delete_Linkage (
 P_ROWID		in ROWID
) IS
BEGIN

    delete from bis_obj_prog_linkages
    where rowid = P_ROWID;
    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

end Delete_Linkage;


-- new implementation for removal of _OA
-- Note that x_is_oa_page is only meaningful as input parameter
-- when x_object_name as input parameter is not null
PROCEDURE page_name_validation (
 P_OBJECT_TYPE          IN VARCHAR2,
 P_USER_OBJECT_NAME     IN VARCHAR2,
 X_OBJECT_NAME          IN OUT NOCOPY VARCHAR2,
 X_IS_OA_PAGE           IN OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
) IS
 l_object_name      bis_obj_dependency.object_name%TYPE;
 l_user_object_name VARCHAR2(480); --Enhancement 4106617
 i                  NUMBER  := 0;
 j                  NUMBER  := 0;
 l_is_oa_page       VARCHAR2(1);

 -- new implementation to uptake the new page query to handle A and A_OA case
   CURSOR c_page(p_user_object_name VARCHAR2, p_object_name VARCHAR2, p_is_oa_page VARCHAR2) IS
     SELECT object_name, user_object_name, oa_page
       FROM (-- portal pages existing in RSG
	     (select DISTINCT dep.object_name object_name, func.user_function_name user_object_name, 'N' oa_page
	      from fnd_form_functions_vl func, bis_obj_dependency dep
	      where upper(web_html_call)='ORACLESSWA.SWITCHPAGE'
	      and dep.object_type = 'PAGE'
	      and dep.object_name = substr(parameters,10))
	     UNION ALL
	     -- oa page existing in RSG repository
	     (select DISTINCT dep.object_name object_name, func.user_function_name user_object_name, 'Y' oa_page
	      from fnd_form_functions_vl func, bis_obj_dependency dep
	      where upper(func.web_html_call) LIKE '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
	      and dep.object_type = 'PAGE'
	      and bis_impl_dev_pkg.get_function_by_page(dep.object_name) = func.function_name)
	     UNION ALL
	     -- oa page not in RSG repository
	     select func.function_name object_name, func.user_function_name user_object_name, 'Y' oa_page
	     from fnd_form_functions_vl func
	     where upper(func.web_html_call) LIKE '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
             and func.function_name not in (select f.function_name
					    from fnd_form_functions f, bis_obj_dependency dep
					    where upper(f.web_html_call) LIKE '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
					    and dep.object_type = 'PAGE'
					    and bis_impl_dev_pkg.get_function_by_page(dep.object_name) = f.function_name)
             UNION ALL
             -- page in RSG repository but w/o corresponding form function defined
             (select DISTINCT objdep.object_name object_name, /*objdep.user_object_name user_object_name*/ objdep.object_name user_object_name, 'N' oa_page
	      --from bis_obj_dependency_v objdep
	      from bis_obj_dependency objdep
	      where objdep.object_type = 'PAGE'
	      and not exists (select 1 from fnd_form_functions func
			      where (upper(func.web_html_call) = 'ORACLESSWA.SWITCHPAGE'
				     and substr(func.parameters,10) = objdep.object_name)
/*			      or (upper(func.web_html_call) LIKE '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
				  and (func.function_name = objdep.object_name
				       or func.function_name||'_OA' = objdep.object_name))))
*/
or (func.web_html_call like 'OA.jsp?akRegionCode=BIS_COMPONENT_PAGE'||'&'||'akRegionApplicationId=191%'
                    and (func.function_name = objdep.object_name
                         or (objdep.object_name like '%_OA'
                             and func.function_name = SUBSTR(object_name, 1, LENGTH(object_name) - 3))))))
       )
       WHERE object_name LIKE p_object_name
       AND user_object_name LIKE p_user_object_name
       AND oa_page LIKE p_is_oa_page;

begin
  X_RETURN_STATUS := 'Y';  --default as Y.

  -- none of p_object_type and p_user_object_name can be null
  if (P_OBJECT_TYPE is null) or (p_object_type <> 'PAGE') or (P_USER_OBJECT_NAME is null) then
    X_RETURN_STATUS := 'N';
    return;
  end if;

  -- x_is_oa_page is only meaningful when x_object_name is not null
  if (x_object_name is null) then
    x_is_oa_page := null;
  else  -- when x_object_name is not null, x_is_oa_page cannot be null either
    if (x_is_oa_page is null) then
        x_return_status := 'N';
        return;
    end if;
  end if;

  -- new implementation
  IF (x_object_name IS NULL) THEN
     OPEN c_page(p_user_object_name, '%', '%');
   ELSE
     OPEN c_page(p_user_object_name, x_object_name, x_is_oa_page);
  END IF;

  loop
    fetch c_page into l_object_name, l_user_object_name, l_is_oa_page;
    exit when c_page%NOTFOUND;
  end loop;

  i := c_page%ROWCOUNT;
  close c_page;

  IF (i = 0) THEN -- no row is fetched
     x_return_status := 'N';
   ELSIF (i = 1) then -- exactly one row is fetched
     x_return_status := 'Y';
   ELSE -- multiple rows are fetched
     x_return_status := 'Y';
     l_object_name := NULL;
  END IF;

  x_object_name := l_object_name;
  x_is_oa_page := l_is_oa_page;
EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'N';
end page_name_validation;


procedure object_name_validation (
 P_OBJECT_TYPE          IN VARCHAR2,
 P_USER_OBJECT_NAME     IN VARCHAR2,
 X_OBJECT_NAME          IN OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
) is
 l_object_name bis_obj_dependency.object_name%TYPE;
 i             NUMBER;

 ---fix bug 4067976. Added  type WEBPORTLETX for portlet form
 ---function
 cursor c_portlet_function(p_user_object_name VARCHAR2) is
    select function_name
      from fnd_form_functions_vl
      where type in ('WEBPORTLET','WEBPORTLETX')
      and user_function_name = p_user_object_name;

 cursor c_report_function(p_user_object_name VARCHAR2) is
    select function_name
      from fnd_form_functions_vl
      where type in ('WWW','JSP') --modified for bug 4717956
     and  user_function_name = p_user_object_name;

  cursor c_portlet_function_name(p_user_object_name VARCHAR2, p_function_name VARCHAR2) IS
      select function_name
	from fnd_form_functions_vl
	where type in ('WEBPORTLET','WEBPORTLETX')
	and user_function_name = p_user_object_name
	and function_name = p_function_name;

 cursor c_report_function_name(p_user_object_name VARCHAR2, p_function_name VARCHAR2) IS
      select function_name
	from fnd_form_functions_vl
	where type in ('WWW','JSP')  ---modified for bug 4717956
	and user_function_name = p_user_object_name
	and function_name = p_function_name;

 cursor c_rsg_object(p_object_type varchar2, p_user_object_name varchar2) is
    -- bis_obj_properties
    (SELECT prop.object_name FROM bis_obj_properties prop
     WHERE bis_impl_dev_pkg.get_user_object_name(prop.object_type,prop.object_name) = p_user_object_name
     AND prop.object_type = p_object_type)
    UNION ALL
    -- bis_obj_dependency object
    (select distinct d.object_name
     from bis_obj_dependency_v d
     where d.object_type = p_object_type
     and d.user_object_name = p_user_object_name
     AND NOT exists (SELECT 1 FROM bis_obj_properties prop
		     WHERE prop.object_type = d.object_type
		     AND prop.object_name = d.object_name))
    UNION ALL
    -- bis_obj_dependency depend_object
    (SELECT DISTINCT d.depend_object_name
     FROM bis_obj_dependency_v d
     WHERE d.depend_object_type = p_object_type
     AND d.user_depend_object_name = p_user_object_name
     AND NOT exists (SELECT 1 FROM bis_obj_properties prop
		     WHERE prop.object_type = d.object_type
		     AND prop.object_name = d.object_name)
     AND NOT exists (SELECT 1 FROM bis_obj_dependency dep
		     WHERE dep.object_type = d.depend_object_type
		     AND dep.object_name = d.depend_object_name))
    UNION ALL
    -- bis_obj_prog_linkages object
    (SELECT DISTINCT l.object_name
     FROM bis_obj_prog_linkages l
     WHERE bis_impl_dev_pkg.get_user_object_name(l.object_type, l.object_name) = p_user_object_name
     AND l.object_type = p_object_type
     AND NOT exists (SELECT 1 FROM bis_obj_properties prop
		     WHERE prop.object_type = l.object_type
		     AND prop.object_name = l.object_name)
     AND NOT exists (SELECT 1 FROM bis_obj_dependency d
		     WHERE (l.object_type = d.object_type AND l.object_name = d.object_name)
		     OR (l.object_type = d.depend_object_type AND l.object_name = d.depend_object_name)));

  cursor c_rsg_object_name(p_object_type varchar2, p_user_object_name varchar2, p_object_name varchar2) is
    -- bis_obj_properties
    (SELECT prop.object_name FROM bis_obj_properties prop
     WHERE bis_impl_dev_pkg.get_user_object_name(prop.object_type,prop.object_name) = p_user_object_name
     AND prop.object_type = p_object_type
     AND prop.object_name = p_object_name)
    UNION ALL
    -- bis_obj_dependency object
    (select distinct d.object_name
     from bis_obj_dependency_v d
     where d.object_type = p_object_type
     and d.user_object_name = p_user_object_name
     AND d.object_name = p_object_name
     AND NOT exists (SELECT 1 FROM bis_obj_properties prop
		     WHERE prop.object_type = d.object_type
		     AND prop.object_name = d.object_name))
    UNION ALL
    -- bis_obj_dependency depend_object
    (SELECT DISTINCT d.depend_object_name
     FROM bis_obj_dependency_v d
     WHERE d.depend_object_type = p_object_type
     AND d.depend_object_name = p_object_name
     AND d.user_depend_object_name = p_user_object_name
     AND NOT exists (SELECT 1 FROM bis_obj_properties prop
		     WHERE prop.object_type = d.object_type
		     AND prop.object_name = d.object_name)
     AND NOT exists (SELECT 1 FROM bis_obj_dependency dep
		     WHERE dep.object_type = d.depend_object_type
		     AND dep.object_name = d.depend_object_name))
    UNION ALL
    -- bis_obj_prog_linkages object
    (SELECT DISTINCT l.object_name
     FROM bis_obj_prog_linkages l
     WHERE bis_impl_dev_pkg.get_user_object_name(l.object_type, l.object_name) = p_user_object_name
     AND l.object_type = p_object_type
     AND l.object_name = p_object_name
     AND NOT exists (SELECT 1 FROM bis_obj_properties prop
		     WHERE prop.object_type = l.object_type
		     AND prop.object_name = l.object_name)
     AND NOT exists (SELECT 1 FROM bis_obj_dependency d
		     WHERE (l.object_type = d.object_type AND l.object_name = d.object_name)
		     OR (l.object_type = d.depend_object_type AND l.object_name = d.depend_object_name)));

begin
   X_RETURN_STATUS := 'Y';  --default as Y.

   if (P_OBJECT_TYPE is null) or (P_USER_OBJECT_NAME is null) then
      X_RETURN_STATUS := 'N';
      return;
   end if;

   --First check if the object exists in RSG
   if (x_object_name is null) then
      open c_rsg_object(P_OBJECT_TYPE, P_USER_OBJECT_NAME);
      loop
	 FETCH C_RSG_OBJECT into x_object_name;
	 exit when C_RSG_OBJECT%NOTFOUND;
      end loop;

      i := C_RSG_OBJECT%ROWCOUNT;
      if (i=1) then  --exactly one row was fetched
	 X_RETURN_STATUS := 'Y';
	 CLOSE C_RSG_OBJECT;
	 return;
       elsif (i>1) then   --more than one row was fetched
	 X_RETURN_STATUS := 'Y';
	 X_OBJECT_NAME := null;   -- indicate more than one row is fetched.
	 CLOSE C_RSG_OBJECT;
	 return;
      end if;
      close C_RSG_OBJECT;
    else
	    open c_rsg_object_name(P_OBJECT_TYPE, P_USER_OBJECT_NAME, X_OBJECT_NAME);
	    fetch c_rsg_object_name into x_object_name;
	    if c_rsg_object_name%FOUND then
	       X_RETURN_STATUS := 'Y';
	       close c_rsg_object_name;
	       return;
	    end if;
	    close c_rsg_object_name;
   end if;


   -- If object doesn't exists in RSG, validate against data source
   -- remove db object validation
   if P_OBJECT_TYPE = 'TABLE' OR p_object_type = 'VIEW'
     OR p_object_type = 'MV' OR p_object_type='AWCUBE' THEN
      x_return_status := 'Y';
      x_object_name := p_user_object_name;
    elsif P_OBJECT_TYPE= 'PORTLET' then
      if (X_OBJECT_NAME is null) then
   	 open c_portlet_function(p_user_object_name);
	 loop
	    FETCH C_portlet_FUNCTION into x_object_name;
	    exit when C_portlet_FUNCTION%NOTFOUND;
	 end loop;

	 i := C_portlet_FUNCTION%ROWCOUNT;
	 if (i=0) then   --no rows were fetched
	    X_RETURN_STATUS := 'N';
	  elsif (i=1) then  --exactly one row was fetched
	    X_RETURN_STATUS := 'Y';
	  elsif (i>1) then   --more than one row was fetched
	    X_RETURN_STATUS := 'Y';
	    X_OBJECT_NAME := null;   -- indicate more than one row is fetched.
	 end if;

	 close c_portlet_function;

       elsif (X_OBJECT_NAME is not null) then
	       open c_portlet_function_name(p_user_object_name, x_object_name);
	       FETCH C_portlet_FUNCTION_NAME into x_object_name;
	       if C_portlet_FUNCTION_NAME%NOTFOUND then
		  X_RETURN_STATUS := 'N';
	       end if;
	       close  C_portlet_FUNCTION_NAME;
      END IF;
    elsif P_OBJECT_TYPE='REPORT' THEN
	 if (X_OBJECT_NAME is null) then
	    open c_report_function(p_user_object_name);
	    loop
	       FETCH C_report_FUNCTION into x_object_name;
	       exit when C_report_FUNCTION%NOTFOUND;
	    end loop;

	    i := C_report_FUNCTION%ROWCOUNT;
	    if (i=0) then   --no rows were fetched
	       X_RETURN_STATUS := 'N';
	     elsif (i=1) then  --exactly one row was fetched
	       X_RETURN_STATUS := 'Y';
	     elsif (i>1) then   --more than one row was fetched
	       X_RETURN_STATUS := 'Y';
	       X_OBJECT_NAME := null;   -- indicate more than one row is fetched.
	    end if;

	    close c_report_function;

	  elsif (X_OBJECT_NAME is not null) then
		  open c_report_function_name(p_user_object_name, x_object_name);
		  FETCH C_report_FUNCTION_NAME into x_object_name;
		  if C_report_FUNCTION_NAME%NOTFOUND then
		     X_RETURN_STATUS := 'N';
		  end if;
		  close  C_report_FUNCTION_NAME;
	 end if;

    else
	    x_return_status := 'N';
   end if;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'N' ;
end  object_name_validation;

procedure object_owner_validation (
 P_OBJECT_OWNER         IN VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
) is
 l_object_owner VARCHAR2(50);
begin
  X_RETURN_STATUS := 'Y';  --default as Y.

  if (P_OBJECT_OWNER is null) then
	X_RETURN_STATUS := 'N';
	return;
  end if;

  SELECT APPLICATION_SHORT_NAME INTO l_object_owner
  FROM FND_APPLICATION
  WHERE APPLICATION_SHORT_NAME = P_OBJECT_OWNER;

  IF SQL%NOTFOUND THEN
    x_return_status := 'N';
  END IF;
end object_owner_validation;


-- added to detect loop for enabled dependency in RSG
PROCEDURE dep_loop_validation (
 p_object_type          IN VARCHAR2,
 p_object_name          IN VARCHAR2,
 p_dep_object_type      IN VARCHAR2,
 p_dep_object_name      IN VARCHAR2,
 p_enabled_flag         IN VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
) IS
   CURSOR c_dep_loop (p_object_type VARCHAR2, p_object_name VARCHAR2, p_dep_object_type VARCHAR2, p_dep_object_name VARCHAR2) IS
      SELECT obj_parents.object_name
	FROM (SELECT object_type, object_name
	      -- bug 3492509: loop detection regardless of enabled flag condition
	      -- FROM (SELECT object_type, object_name, depend_object_type, depend_object_name FROM bis_obj_dependency WHERE enabled_flag = 'Y') d
	      FROM bis_obj_dependency d
	      START WITH d.depend_object_type = p_object_type AND d.depend_object_name = p_object_name
	      CONNECT BY PRIOR d.object_name = d.depend_object_name
	      AND PRIOR d.object_type = d.depend_object_type) obj_parents
	WHERE obj_parents.object_type = p_dep_object_type
	AND obj_parents.object_name = p_dep_object_name;
   v_dummy_obj_name VARCHAR2(480); --Enhancement 4106617
BEGIN
   --bug 3492509: loop detection regardless of enabled flag condition
   --IF ( (p_enabled_flag IS NULL) OR Upper(p_enabled_flag) <> 'Y') THEN
   --   x_return_status := 'Y';
   --   RETURN;
   --END IF;

   --bug 3494363: dependent object cannot be the same as parent object
   IF (p_object_name = p_dep_object_name AND p_object_type = p_dep_object_type) THEN
      x_return_status := 'N';
      RETURN;
   END IF;

   OPEN c_dep_loop(p_object_type, p_object_name, p_dep_object_type, p_dep_object_name);
   LOOP
      FETCH c_dep_loop INTO v_dummy_obj_name;
      EXIT WHEN c_dep_loop%notfound;
   END LOOP;

   IF (c_dep_loop%rowcount > 0) THEN
      x_return_status := 'N';
    ELSE
      x_return_status := 'Y';
   END IF;

   CLOSE c_dep_loop;

   RETURN;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'N';
      RETURN;
END dep_loop_validation;

procedure conc_program_validation (
 P_USER_CONC_PROGRAM_NAME    IN VARCHAR2,
 X_CONC_APP_ID               IN OUT NOCOPY NUMBER,
 X_CONC_APP_SHORT_NAME       OUT NOCOPY VARCHAR2,
 X_CONC_PROGRAM_NAME         OUT NOCOPY VARCHAR2,
 X_RETURN_STATUS             OUT NOCOPY VARCHAR2
) is
 i                   NUMBER := 0;

 CURSOR C_PROGRAM_APP_ID(P_USER_CONC_PROGRAM_NAME VARCHAR2,P_CONC_APP_ID NUMBER) IS
	SELECT conc.CONCURRENT_PROGRAM_NAME, appl.APPLICATION_SHORT_NAME
	FROM FND_CONCURRENT_PROGRAMS_VL conc, FND_APPLICATION appl
	WHERE conc.USER_CONCURRENT_PROGRAM_NAME = P_USER_CONC_PROGRAM_NAME
	AND conc.APPLICATION_ID = P_CONC_APP_ID
	AND conc.APPLICATION_ID = appl.APPLICATION_ID
        AND conc.ENABLED_FLAG = 'Y';

 CURSOR C_PROGRAM(P_USER_CONC_PROGRAM_NAME VARCHAR2) IS
	SELECT conc.CONCURRENT_PROGRAM_NAME, conc.APPLICATION_ID, appl.APPLICATION_SHORT_NAME
	FROM FND_CONCURRENT_PROGRAMS_VL conc, FND_APPLICATION appl
	WHERE conc.USER_CONCURRENT_PROGRAM_NAME = P_USER_CONC_PROGRAM_NAME
	AND conc.APPLICATION_ID = appl.APPLICATION_ID
        AND conc.ENABLED_FLAG = 'Y';

begin
  X_RETURN_STATUS := 'Y';  --default as Y.

  if (P_USER_CONC_PROGRAM_NAME is null) or (X_RETURN_STATUS is null) then
	X_RETURN_STATUS := 'N';

  elsif (X_CONC_APP_ID is not null) then  --derive conc_program_name only
    OPEN C_PROGRAM_APP_ID(P_USER_CONC_PROGRAM_NAME,X_CONC_APP_ID);
    FETCH C_PROGRAM_APP_ID into X_CONC_PROGRAM_NAME, X_CONC_APP_SHORT_NAME;
    if C_PROGRAM_APP_ID%NOTFOUND then
	X_RETURN_STATUS := 'N';
    end if;
    close  C_PROGRAM_APP_ID;

  elsif (X_CONC_APP_ID is null) then   --derive both conc_program_name and conc_app_id
    OPEN C_PROGRAM(P_USER_CONC_PROGRAM_NAME);
    loop
      FETCH C_PROGRAM into X_CONC_PROGRAM_NAME, X_CONC_APP_ID, X_CONC_APP_SHORT_NAME;
      exit when C_PROGRAM%NOTFOUND;
    end loop;

    i := C_PROGRAM%ROWCOUNT;
    if (i=0) then   --no rows were fetched
	X_RETURN_STATUS := 'N';
    elsif (i=1) then  --exactly one row was fetched
	X_RETURN_STATUS := 'Y';
    elsif (i>1) then   --more than one row was fetched
	X_RETURN_STATUS := 'Y';
	X_CONC_APP_ID := -1;   -- indicate more than one row is fetched.
	X_CONC_PROGRAM_NAME := null;
	X_CONC_APP_SHORT_NAME := null;
    end if;

    close  C_PROGRAM;

  else
	X_RETURN_STATUS := 'N';
  end if;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := 'N' ;
    WHEN OTHERS THEN
      x_return_status := 'N' ;
end conc_program_validation;


FUNCTION Refresh_Program_Exists(
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2) RETURN VARCHAR2
IS
 Cursor C_Program(P_OBJECT_TYPE VARCHAR2, P_OBJECT_NAME VARCHAR2) IS
   select distinct conc_program_name
   from bis_obj_prog_linkages
   where object_type = P_OBJECT_TYPE
   and object_name = P_OBJECT_NAME
   and enabled_flag = 'Y';


 l_exists VARCHAR2(1) := 'N';
 l_conc_program_name VARCHAR2(30);

BEGIN
  OPEN C_Program(P_OBJECT_TYPE, P_OBJECT_NAME);
  FETCH C_PROGRAM into l_conc_program_name;
  if C_PROGRAM%FOUND then
     l_exists := 'Y';
  end if;
  close  C_PROGRAM;

  return l_exists;
END Refresh_Program_Exists;


procedure Create_Dependency_Inner (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 P_FROM_UI              in VARCHAR2,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
    l_sysdate            DATE         := sysdate;
    l_api_name           CONSTANT VARCHAR2(30)   := 'Create_Dependency';
    l_created_by         NUMBER := nvl(P_CREATED_BY,g_current_user_id);
    l_creation_date      DATE   := nvl(P_CREATION_DATE, l_Sysdate);
    l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
    l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
    l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);

    cursor c_in_properties(p_object_name varchar2, p_object_type varchar2) is
      select object_name
      from bis_obj_properties
      where object_name = p_object_name
        and object_type = p_object_type;

    l_object_name bis_obj_properties.object_name%type;
    l_return_status varchar2(10);
    l_errorcode     number;
    l_msg_count     number;
    l_msg_data      varchar2(4000);
begin
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    insert into bis_obj_dependency (
        OBJECT_TYPE,
        OBJECT_OWNER,
        OBJECT_NAME,
        ENABLED_FLAG,
        DEPEND_OBJECT_TYPE,
        DEPEND_OBJECT_OWNER,
        DEPEND_OBJECT_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
    values(
        P_OBJECT_TYPE,
        P_OBJECT_OWNER,
        P_OBJECT_NAME,
        P_ENABLED_FLAG,
        P_DEPEND_OBJECT_TYPE,
        P_DEPEND_OBJECT_OWNER,
        P_DEPEND_OBJECT_NAME,
        L_CREATED_BY,
        L_CREATION_DATE,
        L_LAST_UPDATED_BY,
        L_LAST_UPDATE_LOGIN,
        L_LAST_UPDATE_DATE);

    /* create new rows in bis_obj_properties if it is a new object */
    if (p_from_ui is not null) then
       -- check parent object
       open c_in_properties(p_object_name, p_object_type);
       fetch c_in_properties into l_object_name;
       if c_in_properties%NOTFOUND then
          create_properties(
		P_OBJECT_TYPE           => p_object_type,
		P_OBJECT_NAME		=> p_object_name,
		P_OBJECT_OWNER		=> p_object_owner,
		P_SNAPSHOT_LOG_SQL	=> null,
		P_FAST_REFRESH_FLAG	=> null,
		P_DIMENSION_FLAG        => null,
		x_return_status         => l_return_status,
		x_errorcode             => l_errorcode,
		x_msg_count             => l_msg_count,
		x_msg_data              => l_msg_data
		);
       end if;
       close c_in_properties;

       --check child object
       open c_in_properties(p_depend_object_name, p_depend_object_type);
       fetch c_in_properties into l_object_name;
       if c_in_properties%NOTFOUND then
          create_properties(
		P_OBJECT_TYPE           => p_depend_object_type,
		P_OBJECT_NAME		=> p_depend_object_name,
		P_OBJECT_OWNER		=> p_depend_object_owner,
		P_SNAPSHOT_LOG_SQL	=> null,
		P_FAST_REFRESH_FLAG	=> null,
		P_DIMENSION_FLAG        => null,
		x_return_status         => l_return_status,
		x_errorcode             => l_errorcode,
		x_msg_count             => l_msg_count,
		x_msg_data              => l_msg_data
		);
       end if;
       close c_in_properties;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      raise;
end Create_Dependency_Inner;

procedure Create_Dependency (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 P_FROM_UI              in VARCHAR2,
 P_CREATED_BY		in NUMBER       := null,
 P_CREATION_DATE	in DATE         := null,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
begin
Create_Dependency_Inner (
 P_OBJECT_TYPE,
 P_OBJECT_OWNER,
 P_OBJECT_NAME,
 P_ENABLED_FLAG,
 P_DEPEND_OBJECT_TYPE,
 P_DEPEND_OBJECT_OWNER,
 P_DEPEND_OBJECT_NAME,
 P_FROM_UI,
 P_CREATED_BY,
 P_CREATION_DATE,
 P_LAST_UPDATED_BY,
 P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATE_DATE,
 p_init_msg_list,
 p_commit,
 x_return_status,
 x_errorcode,
 x_msg_count,
 x_msg_data
);
exception
    when others then
      null;
end Create_Dependency;


procedure Update_Dependency_Inner (
 P_ROWID		in ROWID        := null,
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 P_FROM_UI              in VARCHAR2,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is
    l_sysdate            DATE         := sysdate;
    l_api_name           CONSTANT VARCHAR2(30)   := 'Update_Dependency';
    l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
    l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
    l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);

    cursor c_in_properties(p_object_name varchar2, p_object_type varchar2) is
      select object_name
      from bis_obj_properties
      where object_name = p_object_name
        and object_type = p_object_type;

    l_object_name bis_obj_properties.object_name%type;
    l_return_status varchar2(10);
    l_errorcode     number;
    l_msg_count     number;
    l_msg_data      varchar2(4000);
begin
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    if (P_ROWID IS NOT NULL) THEN
       update bis_obj_dependency
       SET object_owner            = p_object_owner,
	   enabled_flag            = P_ENABLED_FLAG,
           depend_object_type      = P_DEPEND_OBJECT_TYPE,
           depend_object_owner     = P_DEPEND_OBJECT_OWNER,
           depend_object_name      = P_DEPEND_OBJECT_NAME,
           last_updated_by         = L_LAST_UPDATED_BY,
           last_update_login       = L_LAST_UPDATE_LOGIN,
           last_update_date        = L_LAST_UPDATE_DATE
       where rowid  = P_ROWID;
    else
       UPDATE BIS_OBJ_DEPENDENCY
       SET object_owner            = p_object_owner,
           ENABLED_FLAG            = P_ENABLED_FLAG,
           DEPEND_OBJECT_OWNER     = P_DEPEND_OBJECT_OWNER,
           LAST_UPDATE_DATE        = L_LAST_UPDATE_DATE,
           LAST_UPDATED_BY         = L_LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN       = L_LAST_UPDATE_LOGIN
       WHERE OBJECT_TYPE           = P_OBJECT_TYPE
       AND OBJECT_NAME             = P_OBJECT_NAME
       AND DEPEND_OBJECT_NAME      = P_DEPEND_OBJECT_NAME
       AND DEPEND_OBJECT_TYPE      = P_DEPEND_OBJECT_TYPE;
    end if;

    /* create new rows in bis_obj_properties if it is a new object */
    if (p_from_ui is not null) then
       --check child object
       open c_in_properties(p_depend_object_name, p_depend_object_type);
       fetch c_in_properties into l_object_name;
       if c_in_properties%NOTFOUND then
          create_properties(
		P_OBJECT_TYPE           => p_depend_object_type,
		P_OBJECT_NAME		=> p_depend_object_name,
		P_OBJECT_OWNER		=> p_depend_object_owner,
		P_SNAPSHOT_LOG_SQL	=> null,
		P_FAST_REFRESH_FLAG	=> null,
		P_DIMENSION_FLAG        => null,
		x_return_status         => l_return_status,
		x_errorcode             => l_errorcode,
		x_msg_count             => l_msg_count,
		x_msg_data              => l_msg_data
		);
       end if;
       close c_in_properties;
    end if;

    /* update the owner of the depend object in property and linkage for bug 3562027 */
    execute immediate 'update bis_obj_properties set object_owner = :1
      WHERE object_type = :2 AND object_name = :3'
      using P_DEPEND_OBJECT_OWNER, P_DEPEND_OBJECT_TYPE, P_DEPEND_OBJECT_NAME;

    execute immediate 'update bis_obj_prog_linkages set object_owner = :1
      WHERE object_type = :2 AND object_name = :3'
      using P_DEPEND_OBJECT_OWNER, P_DEPEND_OBJECT_TYPE, P_DEPEND_OBJECT_NAME;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      raise;
end Update_Dependency_Inner;

procedure Update_Dependency (
 P_ROWID		in ROWID        := null,
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 P_FROM_UI              in VARCHAR2,
 P_LAST_UPDATED_BY	in NUMBER       := null,
 P_LAST_UPDATE_LOGIN	in NUMBER       := null,
 P_LAST_UPDATE_DATE	in DATE         := null,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) is
begin
Update_Dependency_Inner (
 P_ROWID,
 P_OBJECT_TYPE,
 P_OBJECT_OWNER,
 P_OBJECT_NAME,
 P_ENABLED_FLAG,
 P_DEPEND_OBJECT_TYPE,
 P_DEPEND_OBJECT_OWNER,
 P_DEPEND_OBJECT_NAME,
 P_FROM_UI,
 P_LAST_UPDATED_BY,
 P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATE_DATE,
 p_init_msg_list,
 p_commit,
 x_return_status,
 x_errorcode,
 x_msg_count,
 x_msg_data
);

exception
    when others then
      null;
end Update_Dependency;


procedure Delete_Dependency (
 P_ROWID		in ROWID
) is
BEGIN

    delete from bis_obj_dependency
    where rowid = P_ROWID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

end Delete_Dependency;



procedure Create_Properties_Inner(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 P_CREATED_BY             in NUMBER,
 P_CREATION_DATE          in DATE,
 P_LAST_UPDATED_BY        in NUMBER,
 P_LAST_UPDATE_LOGIN	in NUMBER,
 P_LAST_UPDATE_DATE	in DATE,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
    l_sysdate            DATE         := sysdate;
    l_api_name           CONSTANT VARCHAR2(30)   := 'Create_Properties';
    l_created_by         NUMBER := nvl(P_CREATED_BY,g_current_user_id);
    l_creation_date      DATE   := nvl(P_CREATION_DATE, l_Sysdate);
    l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
    l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
    l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);

begin
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    insert into bis_obj_properties (
	OBJECT_TYPE,
	OBJECT_NAME,
	OBJECT_OWNER,
	--SNAPSHOT_LOG_SQL,
	FAST_REFRESH_FLAG,
	DIMENSION_FLAG,
    CUSTOM_API,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE)
    values(
        P_OBJECT_TYPE,
        P_OBJECT_NAME,
	P_OBJECT_OWNER,
	--P_SNAPSHOT_LOG_SQL,
	P_FAST_REFRESH_FLAG,
	P_DIMENSION_FLAG,
    P_CUSTOM_API,
        L_CREATED_BY,
        L_CREATION_DATE,
        L_LAST_UPDATED_BY,
        L_LAST_UPDATE_LOGIN,
        L_LAST_UPDATE_DATE);

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      raise;
END Create_Properties_Inner;

procedure Create_Properties(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 P_CREATED_BY             in NUMBER,
 P_CREATION_DATE          in DATE,
 P_LAST_UPDATED_BY        in NUMBER,
 P_LAST_UPDATE_LOGIN	in NUMBER,
 P_LAST_UPDATE_DATE	in DATE,
 p_init_msg_list        IN   VARCHAR2   :=  fnd_api.g_FALSE,
 p_commit               IN   VARCHAR2   :=  fnd_api.g_FALSE,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
begin

Create_Properties_Inner(
 P_OBJECT_TYPE,
 P_OBJECT_NAME,
 P_OBJECT_OWNER,
 P_SNAPSHOT_LOG_SQL,
 P_FAST_REFRESH_FLAG,
 P_DIMENSION_FLAG,
 P_CUSTOM_API,
 P_CREATED_BY,
 P_CREATION_DATE,
 P_LAST_UPDATED_BY,
 P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATE_DATE,
 p_init_msg_list,
 p_commit,
 x_return_status,
 x_errorcode,
 x_msg_count,
 x_msg_data
);
exception
    when others then
      null;
END;


-- added for bug3040249
procedure Update_Obj_Last_Refresh_Date(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_LAST_REFRESH_DATE		in DATE
) IS
Begin
	  update bis_obj_properties
	  set
	   LAST_REFRESH_DATE	= P_LAST_REFRESH_DATE
      WHERE OBJECT_TYPE           = P_OBJECT_TYPE
      AND OBJECT_NAME             = P_OBJECT_NAME ;
END;

-- new API which consider the CUSTOM_API colomn.
procedure Update_Properties_Inner(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 P_LAST_UPDATED_BY        in NUMBER,
 P_LAST_UPDATE_LOGIN	in NUMBER,
 P_LAST_UPDATE_DATE	in DATE,
 p_init_msg_list        IN   VARCHAR2,
 p_commit               IN   VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
    l_sysdate            DATE         := sysdate;
    l_api_name           CONSTANT VARCHAR2(30)   := 'Update_Properties';
    l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
    l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
    l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);
begin
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

	  update bis_obj_properties
	  set
	   OBJECT_OWNER		= P_OBJECT_OWNER,
	   -- SNAPSHOT_LOG_SQL  	= P_SNAPSHOT_LOG_SQL,
         FAST_REFRESH_FLAG 	= P_FAST_REFRESH_FLAG,
 	   DIMENSION_FLAG 	= P_DIMENSION_FLAG,
       CUSTOM_API         = P_CUSTOM_API,
 	   LAST_UPDATED_BY        = L_LAST_UPDATED_BY,
 	   LAST_UPDATE_LOGIN	= L_LAST_UPDATE_LOGIN,
	   LAST_UPDATE_DATE	= L_LAST_UPDATE_DATE
      WHERE OBJECT_TYPE           = P_OBJECT_TYPE
      AND OBJECT_NAME             = P_OBJECT_NAME ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
      raise;
END Update_Properties_Inner;


procedure Update_Properties(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 P_LAST_UPDATED_BY        in NUMBER,
 P_LAST_UPDATE_LOGIN	in NUMBER,
 P_LAST_UPDATE_DATE	in DATE,
 p_init_msg_list        IN   VARCHAR2,
 p_commit               IN   VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
begin
Update_Properties_Inner(
 P_OBJECT_TYPE,
 P_OBJECT_NAME,
 P_OBJECT_OWNER,
 P_SNAPSHOT_LOG_SQL,
 P_FAST_REFRESH_FLAG,
 P_DIMENSION_FLAG,
 P_CUSTOM_API,
 P_LAST_UPDATED_BY,
 P_LAST_UPDATE_LOGIN,
 P_LAST_UPDATE_DATE,
 p_init_msg_list,
 p_commit,
 x_return_status,
 x_errorcode,
 x_msg_count,
 x_msg_data
);
exception
    when others then
      null;
END;


/*
-- this is for backward compitability
procedure Update_Properties(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_SNAPSHOT_LOG_SQL	in VARCHAR2,
 P_FAST_REFRESH_FLAG	in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_LAST_UPDATED_BY        in NUMBER,
 P_LAST_UPDATE_LOGIN	in NUMBER,
 P_LAST_UPDATE_DATE	in DATE,
 p_init_msg_list        IN   VARCHAR2,
 p_commit               IN   VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_errorcode            OUT NOCOPY  NUMBER,
 x_msg_count            OUT NOCOPY  NUMBER,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
    l_sysdate            DATE         := sysdate;
    l_api_name           CONSTANT VARCHAR2(30)   := 'Update_Properties';
    l_last_updated_by    NUMBER := nvl(P_LAST_UPDATED_BY, g_current_user_id);
    l_last_update_login  NUMBER := nvl(P_LAST_UPDATE_LOGIN, g_current_login_id);
    l_last_update_date   DATE   := nvl(P_LAST_UPDATE_DATE, l_Sysdate);
begin
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

	  update bis_obj_properties
	  set
	   OBJECT_OWNER		= P_OBJECT_OWNER,
	   SNAPSHOT_LOG_SQL  	= P_SNAPSHOT_LOG_SQL,
         FAST_REFRESH_FLAG 	= P_FAST_REFRESH_FLAG,
 	   DIMENSION_FLAG 	= P_DIMENSION_FLAG,
 	   LAST_UPDATED_BY        = L_LAST_UPDATED_BY,
 	   LAST_UPDATE_LOGIN	= L_LAST_UPDATE_LOGIN,
	   LAST_UPDATE_DATE	= L_LAST_UPDATE_DATE
      WHERE OBJECT_TYPE           = P_OBJECT_TYPE
      AND OBJECT_NAME             = P_OBJECT_NAME ;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------------------
    -- Make a standard call to get message count
    -- and if count is 1, get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else, i.e. if x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display them all at once or display one message after another.

    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

exception
    when no_data_found then
        return;
    when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level
         (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
          FND_MSG_PUB.Add_Exc_Msg
             (   G_PKG_NAME,
                 l_api_name
             );
      END IF;
      FND_MSG_PUB.Count_And_Get
         (   p_count        =>      x_msg_count,
             p_data         =>      x_msg_data
         );
      x_msg_data := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;

END;
*/

procedure Delete_Properties(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2
) IS
BEGIN
  delete bis_obj_properties
  where object_type = p_object_type
    and object_name = p_object_name;

  If (SQL%NOTFOUND) then
      RAISE NO_DATA_FOUND;
  End If;
end Delete_Properties;


-- new implementation for removal of _OA
function Get_User_Object_Name (
 P_OBJECT_TYPE          IN VARCHAR2,
 P_OBJECT_NAME          IN VARCHAR2
) RETURN varchar2 IS
 x_user_object_name     varchar2(480); --Enhancement 4106617
 i                      number;

 cursor c_portlet_report(p_object_name varchar2) is
    select user_function_name
    from fnd_form_functions_vl
    where function_name = p_object_name;

 -- new implementation to uptake get_function_by_page
 cursor c_oa_page(p_object_name varchar2) is
    select user_function_name
      from fnd_form_functions_vl
      where UPPER(web_html_call) like '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
      and get_function_by_page(p_object_name) = function_name;

begin
  if (P_OBJECT_TYPE = 'TABLE' OR P_OBJECT_TYPE = 'VIEW' OR P_OBJECT_TYPE = 'MV' or P_OBJECT_TYPE='AWCUBE') then
    X_USER_OBJECT_NAME := P_OBJECT_NAME;
  elsif (P_OBJECT_TYPE = 'PORTLET' OR P_OBJECT_TYPE = 'REPORT') then
    open c_portlet_report(p_object_name);
    fetch c_portlet_report into x_user_object_name;
    i := c_portlet_report%ROWCOUNT;
    close c_portlet_report;
    if (i <= 0) then -- nothing matches
        X_USER_OBJECT_NAME := P_OBJECT_NAME;
    end if;
   elsif (P_OBJECT_TYPE = 'PAGE') THEN
     open c_oa_page(p_object_name);
     fetch c_oa_page into x_user_object_name;
     i := c_oa_page%ROWCOUNT;
     close c_oa_page;
     IF (i > 0) THEN
	RETURN x_user_object_name;
     END IF;

     -- bug 3975359: if the given page is a portal page return its object name as user object name
     X_USER_OBJECT_NAME := P_OBJECT_NAME;
  end if;

  return X_USER_OBJECT_NAME;
EXCEPTION
  when no_data_found then
    return P_OBJECT_NAME;
  when others then
    return P_OBJECT_NAME;

end Get_User_Object_Name;

function is_page_migrated (
 P_PAGE_NAME		in VARCHAR2
) RETURN boolean
IS
  cursor c_page_migrated(P_PAGE_NAME varchar2) is
    SELECT /*+ FIRST_ROWS*/ 'Y'
    FROM BIS_OBJ_DEPENDENCY
    WHERE OBJECT_TYPE = 'PAGE'
    AND P_PAGE_NAME like '%_OA'
    AND OBJECT_NAME = SUBSTR(P_PAGE_NAME, 1, LENGTH(P_PAGE_NAME) - 3)
    AND ROWNUM = 1;
    L_MIGRATED  VARCHAR2(10) := NULL;

BEGIN
  open c_page_migrated(P_PAGE_NAME);
  fetch c_page_migrated into L_MIGRATED;
  close c_page_migrated;
  IF (L_MIGRATED = 'Y') THEN
    return true;
  else
    return false;
  end if;
END is_page_migrated;

function get_function_by_page (
 P_PAGE_NAME		in VARCHAR2
) RETURN varchar2
IS
  cursor c_page1(P_PAGE_NAME varchar2) is
    select f.function_name
    from
      fnd_form_functions f
    where
      UPPER(f.web_html_call) like '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
    and function_name = P_PAGE_NAME;

  cursor c_page2(P_PAGE_NAME varchar2) is
    select f.function_name
    from
      fnd_form_functions f
    where
      UPPER(f.web_html_call) like '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
    and P_PAGE_NAME like '%_OA'
    and function_name = SUBSTR(P_PAGE_NAME, 1, LENGTH(P_PAGE_NAME) - 3);

    L_FUNCTION_NAME  fnd_form_functions.function_name%TYPE := NULL;
BEGIN
  open c_page1(P_PAGE_NAME);
  fetch c_page1 into L_FUNCTION_NAME;
  close c_page1;
  if (L_FUNCTION_NAME is not null) then
    RETURN L_FUNCTION_NAME;
  end if;

  open c_page2(P_PAGE_NAME);
  fetch c_page2 into L_FUNCTION_NAME;
  close c_page2;
  RETURN L_FUNCTION_NAME;

END;


procedure migrate_page(
 P_PAGE_NAME		in VARCHAR2,
 P_NEW_PAGE_NAME	in VARCHAR2
) IS

  cursor skip_migrate(P_PAGE_NAME varchar2) is
    select /*+ FIRST_ROWS*/ 'Y'
    from
      fnd_form_functions f,
      bis_obj_dependency d
    where
        d.object_name = f.function_name
    and d.object_type = 'PAGE'
    and UPPER(f.web_html_call) like '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%'
    and function_name = P_PAGE_NAME;
   l_skip_migrate VARCHAR2(10);

BEGIN

  open skip_migrate(P_PAGE_NAME);
  fetch skip_migrate into l_skip_migrate;
  close skip_migrate;

  IF(l_skip_migrate = 'Y') THEN
    --FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'bis.maigrate_page', 'no nned to migrate');
    RETURN;
  END IF;

  update bis_obj_properties
  set object_name = P_NEW_PAGE_NAME
  where
       object_type = 'PAGE'
  and object_name = P_PAGE_NAME;
  --FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'bis.maigrate_page', SQL%rowcount || ' rows updated :' || P_PAGE_NAME || '->' || P_NEW_PAGE_NAME || ' in bis_obj_properties.object_name');

  update bis_obj_dependency
  set object_name = P_NEW_PAGE_NAME
  where
       object_type = 'PAGE'
  and object_name = P_PAGE_NAME;
  --FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'bis.maigrate_page', SQL%rowcount || ' rows updated :' || P_PAGE_NAME || '->' || P_NEW_PAGE_NAME || ' in bis_obj_dependency.object_name');

END migrate_page;
/* starts: bug 3562027 -- change owner for parent object */
/*Bug 4560963 : From now, we will get object owner from bis_obj_properties
  unlike the previous approach of getting it from bis_obj_dependency */
FUNCTION is_owner_changed (
 p_obj_name IN VARCHAR2,
 p_obj_type IN VARCHAR2,
 p_new_obj_owner IN VARCHAR2,
 p_actual_owner  OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS

   CURSOR c_owner(p_obj_name VARCHAR2, p_obj_type VARCHAR2) IS
      SELECT object_owner
	FROM bis_obj_properties
	WHERE object_type = p_obj_type
	AND object_name = p_obj_name;

   v_obj_owner VARCHAR2(50);
   v_changed   VARCHAR2(5);
BEGIN
   OPEN c_owner(p_obj_name, p_obj_type);
   FETCH c_owner INTO v_obj_owner;
   IF (c_owner%notfound) THEN
        v_changed := 'N';
        CLOSE c_owner;
        RETURN v_changed;
   END IF;
   CLOSE c_owner;

   IF (p_new_obj_owner = v_obj_owner) THEN
      v_changed := 'N';
    ELSE
      v_changed := 'Y';
      p_actual_owner := v_obj_owner;
   END IF;
   RETURN v_changed;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 'Y';
END is_owner_changed;

PROCEDURE change_prop_linkage_owner (
 p_obj_name IN VARCHAR2,
 p_obj_type IN VARCHAR2,
 p_obj_owner IN VARCHAR2
) IS

BEGIN
   IF (p_obj_name IS NULL OR p_obj_type IS NULL OR p_obj_owner IS NULL) THEN
      RETURN;
   END IF;

   execute immediate 'update bis_obj_properties set object_owner = :1
     WHERE object_type = :2 AND object_name = :3'
     using p_obj_owner, p_obj_type, p_obj_name;

   execute immediate 'update bis_obj_prog_linkages set object_owner = :1
     WHERE object_type = :2 AND object_name = :3'
     using p_obj_owner, p_obj_type, p_obj_name;
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END change_prop_linkage_owner;
/* sends: bug 3562027 -- change owner for parent object */

/*This procedure has been added for enhcnement 4391651. Given object name and type.
Find out if the object is seeded or not */

FUNCTION is_object_seeded( p_obj_name IN VARCHAR2, p_obj_type IN VARCHAR2) RETURN VARCHAR2 IS

cursor c_obj_depend(l_obj_name VARCHAR2, l_obj_type VARCHAR2) is
select CREATED_BY from bis_obj_dependency
where OBJECT_NAME = l_obj_name and OBJECT_TYPE = l_obj_type;

cursor c_obj_depend_depend(l_obj_name VARCHAR2, l_obj_type VARCHAR2) is
select CREATED_BY from bis_obj_dependency
where DEPEND_OBJECT_NAME = l_obj_name and depend_OBJECT_TYPE = l_obj_type;


cursor c_obj_prog(l_obj_name VARCHAR2, l_obj_type VARCHAR2) is
select CREATED_BY from bis_obj_prog_linkages
where OBJECT_NAME = l_obj_name and OBJECT_TYPE = l_obj_type;

cursor c_obj_prop(l_obj_name VARCHAR2, l_obj_type VARCHAR2) is
select CREATED_BY from bis_obj_properties
where OBJECT_NAME = l_obj_name and OBJECT_TYPE = l_obj_type;

created_user  number;

BEGIN

	for c_obj_depend_rec in c_obj_depend(p_obj_name,p_obj_type) loop
		created_user := c_obj_depend_rec.CREATED_BY;
                --Followed the logic as used in AFLDUTLB.pls for seeded user having 120 to 129 user_id range
		if (created_user =1 or created_user =2 or (created_user >=120 and created_user <=129)) then
			  exit;
		end if;
	end loop;
	if (created_user is null) then
		--check if the object is dependent object and seeded object
		for c_obj_depend_depend_rec in c_obj_depend_depend(p_obj_name,p_obj_type) loop
			created_user := c_obj_depend_depend_rec.CREATED_BY;
                        --Followed the logic as used in AFLDUTLB.pls for seeded user having 120 to 129 user_id range
			if (created_user =1 or created_user =2 or (created_user >=120 and created_user <=129)) then
			   exit;
			end if;
		end loop;
		if (created_user is null) then
			for c_obj_prog_rec in c_obj_prog(p_obj_name,p_obj_type) loop
				created_user := c_obj_prog_rec.CREATED_BY;
			end loop;
			if(created_user is null) then
				for c_obj_prop_rec in c_obj_prop(p_obj_name,p_obj_type) loop
					created_user := c_obj_prop_rec.CREATED_BY;
				end loop;
				if (created_user is null) then
					return 'FALSE'; --new object
				else
					if(created_user <>1 and created_user <>2 and (created_user < 120 or created_user > 129))then
					     return 'FALSE';
					else
					     return 'TRUE';
					end if;
				end if;
			else
				if(created_user <>1 and created_user <>2 and (created_user < 120 or created_user > 129))then
				     return 'FALSE';
				else
				     return 'TRUE';
				end if;
			end if;
		else
			  if(created_user <>1 and created_user <>2 and (created_user < 120 or created_user > 129))then
				return 'FALSE';
			   else
				return 'TRUE';
			   end if;
		end if;
	else
	  if(created_user <>1 and created_user <>2 and (created_user < 120 or created_user > 129))then
		return 'FALSE';
	   else
	        return 'TRUE';
	   end if;
	end if;

END is_object_seeded;

end BIS_IMPL_DEV_PKG;

/
