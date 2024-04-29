--------------------------------------------------------
--  DDL for Package Body BIS_RSG_PUB_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RSG_PUB_API_PKG" AS
/* $Header: BISRSGPB.pls 120.3 2005/11/14 01:44:41 amitgupt noship $ */
   version          CONSTANT CHAR (80)
            := '$Header: BISRSGPB.pls 120.3 2005/11/14 01:44:41 amitgupt noship $';

   g_pkg_name VARCHAR2(50) := 'bis_rsg_pub_api_pkg';

   g_curr_user_id         NUMBER  :=  FND_GLOBAL.User_id;
   g_curr_login_id        NUMBER  :=  FND_GLOBAL.Login_id;

-- As per discussion with Tiwang, Ian, the logic of this function is the following:
-- for given function name A, we will first try to find if there is A_OA page object
-- in RSG repository, if there is, return A_OA, otherwise, return A
-- Potential problem: if in a migrated environment, user indeed has A_OA and A in
-- fnd_form_function, and user intend to add dependencies for A, we will end up with
-- add dependencies to A_OA with this logic, currently there is no way for lct to handle this case
-- although we can handle it correctly by investigating if there is really a A_OA in
-- fnd_form_functions if there is, return A; if there is not, return A_OA
FUNCTION get_page_name_by_func (
 p_func_name   IN VARCHAR2) RETURN VARCHAR2
IS
   CURSOR c_page_object_name(p_func_name VARCHAR2) IS
      SELECT object_name FROM bis_obj_dependency
	WHERE object_type = 'PAGE' AND object_name = p_func_name || '_OA'
      UNION ALL
      SELECT object_name FROM bis_obj_properties
	WHERE object_type = 'PAGE' AND object_name = p_func_name || '_OA';

   v_object_name bis_obj_dependency.object_name%type; --Enhancement 4106617
BEGIN
   IF (p_func_name IS NULL OR p_func_name = '') THEN
      RETURN NULL;
   END IF;
   OPEN c_page_object_name(p_func_name);
   FETCH c_page_object_name INTO v_object_name;
   IF (c_page_object_name%notfound) THEN
      v_object_name := p_func_name;
   END IF;
   CLOSE c_page_object_name;
   RETURN v_object_name;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_page_name_by_func;

/* notice that this function has to work either for OA pages with or
 * without _OA attached to the object name
 */
PROCEDURE page_name_validation(
 P_OBJECT_NAME          IN VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2)
IS
   v_dummy                VARCHAR(5);
BEGIN
   x_return_status := 'Y';

   -- those with _OA attached must have already exist in RSG repository
   BEGIN
      execute immediate 'select 1 from bis_obj_properties
	WHERE object_type = :1 AND object_name = :2'
	INTO v_dummy
	using 'PAGE', p_object_name;
      RETURN;
   EXCEPTION
      WHEN no_data_found THEN
	 NULL;
   END;

   execute immediate 'select 1 from fnd_form_functions
     WHERE ( Upper(web_html_call) = :1 AND substr(parameters,10) = :2)
     OR ( Upper(web_html_call) LIKE :3 AND function_name = :4)'
     INTO v_dummy
     using 'ORACLESSWA.SWITCHPAGE', p_object_name, '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%', p_object_name;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'N';
END;

PROCEDURE object_name_validation (
 P_OBJECT_TYPE          IN VARCHAR2,
 P_OBJECT_NAME          IN VARCHAR2,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2
) IS
   v_dummy              VARCHAR2(5);
BEGIN
   IF (p_object_type IS NULL OR p_object_name IS NULL) THEN
      x_return_status := 'N';
      RETURN;
   END IF;

   x_return_status := 'Y';
   IF (p_object_type = 'TABLE' OR p_object_type = 'VIEW'
       OR p_object_type = 'MV' ) THEN
      x_return_status := 'Y';
    ELSIF (p_object_type = 'PORTLET') THEN
      execute immediate 'select 1 from fnd_form_functions
	WHERE TYPE in (''WEBPORTLET'',''WEBPORTLETX'') AND function_name = :1'
	INTO v_dummy
	using  p_object_name;
    ELSIF (p_object_type = 'REPORT') THEN
       execute immediate 'select 1 from fnd_form_functions
	WHERE TYPE in (:1,:2) AND function_name = :3'
	INTO v_dummy
	using 'WWW', 'JSP',p_object_name;
    ELSIF(p_object_type = 'PAGE') THEN
      page_name_validation(p_object_name, x_return_status);
    ELSE
      x_return_status := 'N';
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'N';
END object_name_validation;

PROCEDURE object_owner_validation(
  p_object_owner VARCHAR2,
  x_return_status OUT nocopy VARCHAR2)
IS
  v_dummy VARCHAR2(5);
BEGIN
  X_RETURN_STATUS := 'Y';  --default as Y.

  IF (P_OBJECT_OWNER IS NULL) THEN
     X_RETURN_STATUS := 'N';
     RETURN;
  END IF;

  execute immediate 'SELECT 1
    FROM FND_APPLICATION
    WHERE APPLICATION_SHORT_NAME = :1'
    INTO v_dummy
    using p_object_owner;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'N';
END object_owner_validation;

-- this procedure can only be invoked in create_dependency
-- thus here we don't need to call get_page_name_by_func
PROCEDURE create_property(
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Create_Property';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'insert into bis_obj_properties (
	object_type, OBJECT_NAME, OBJECT_OWNER,
        CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN, LAST_UPDATE_DATE)
     values(:1, :2, :3, :4, :5, :6, :7, :8)'
     using  P_OBJECT_TYPE, p_object_name, P_OBJECT_OWNER,
     g_curr_user_id, Sysdate, g_curr_user_id,
     g_curr_login_id, Sysdate;
EXCEPTION
   WHEN dup_val_on_index THEN
      RETURN;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END create_property;

-- for page definer
-- try to find object owner in RSG repository first
FUNCTION get_appl_short_name_for_obj(p_object_name VARCHAR2,
				     p_object_type VARCHAR2) RETURN VARCHAR2 IS

   CURSOR c_obj_appl_short_name IS
      SELECT DISTINCT object_owner
	FROM bis_obj_dependency
	WHERE object_name = p_object_name AND object_type = p_object_type;

   CURSOR c_depend_obj_appl_short_name IS
      SELECT DISTINCT depend_object_owner
	FROM bis_obj_dependency
	WHERE depend_object_name = p_object_name AND depend_object_type = p_object_type;

   l_obj_owner VARCHAR(50);
BEGIN
   OPEN c_obj_appl_short_name;
   FETCH c_obj_appl_short_name INTO l_obj_owner;
   CLOSE c_obj_appl_short_name;

   IF (l_obj_owner IS NOT NULL) THEN
      RETURN l_obj_owner;
   END IF;

   OPEN c_depend_obj_appl_short_name;
   FETCH c_depend_obj_appl_short_name INTO l_obj_owner;
   CLOSE c_depend_obj_appl_short_name;

   RETURN l_obj_owner;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_appl_short_name_for_obj;

PROCEDURE Create_Dependency (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Create_Dependency';
   l_object_owner VARCHAR2(50);
   l_depend_object_owner VARCHAR2(50);
   l_object_name bis_obj_dependency.object_name%type; --Enhancement 4106617
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   IF (p_object_type = 'PAGE') THEN
     l_object_name := get_page_name_by_func(p_object_name);
    ELSE
      l_object_name := p_object_name;
   END IF;

   l_object_owner := get_appl_short_name_for_obj(l_object_name, p_object_type);
   l_depend_object_owner := get_appl_short_name_for_obj(p_depend_object_name, p_depend_object_type);

   IF (l_object_owner IS NULL) THEN
      l_object_owner := p_object_owner;
   END IF;

   IF (l_depend_object_owner IS NULL) THEN
      l_depend_object_owner := p_depend_object_owner;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- validate (object_type, object_name)
   object_name_validation(p_object_type, l_object_name, x_return_status);
   IF (x_return_status = 'N') THEN
      --CHANGE FOR BUG 4698254
      IF (p_object_type <> 'PORTLET') THEN
        x_msg_data := 'BIS_BIA_RSG_INVALID_OBJ';
      ELSE
        x_msg_data := 'BIS_REGION_NOT_EXISTING_MSG';
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, x_msg_data);
      END IF;
      RETURN;
   END IF;

   -- validate object_owner
   object_owner_validation(l_object_owner, x_return_status);
   IF (x_return_status = 'N') THEN
      x_msg_data := 'BIS_BIA_RSG_INVALID_OBJ_OWNER';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INVALID_OBJ_OWNER');
      END IF;
      RETURN;
   END IF;

   -- validate (depend_object_type, depend_object_name)
   object_name_validation(p_depend_object_type, p_depend_object_name, x_return_status);
   IF (x_return_status = 'N') THEN
      --added for bug 4698254
      IF (p_depend_object_type <> 'PORTLET') THEN
        x_msg_data := 'BIS_BIA_RSG_INVALID_DEP_OBJ';
      ELSE
        x_msg_data := 'BIS_REGION_NOT_EXISTING_MSG';
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, x_msg_data);
      END IF;
      RETURN;
   END IF;

   -- validate depend_object_owner
   object_owner_validation(l_depend_object_owner, x_return_status);
   IF (x_return_status = 'N') THEN
      x_msg_data := 'BIS_BIA_RSG_INV_DEP_OBJ_OWNER';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_DEP_OBJ_OWNER');
      END IF;
      RETURN;
   END IF;

   -- validate enabled flag
   IF (p_enabled_flag IS NOT NULL AND p_enabled_flag <> 'Y'
       AND p_enabled_flag <> 'N') THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := 'BIS_BIA_RSG_INV_ENABLED_FLAG';
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_ENABLED_FLAG');
      END IF;
      RETURN;
   END IF;

   execute immediate 'insert into bis_obj_dependency (
     OBJECT_TYPE, OBJECT_OWNER, OBJECT_NAME,
     ENABLED_FLAG,
     DEPEND_OBJECT_TYPE, DEPEND_OBJECT_OWNER, DEPEND_OBJECT_NAME,
     CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN, LAST_UPDATE_DATE)
     values(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12)'
     using p_object_type, l_OBJECT_OWNER, l_object_name,
     P_ENABLED_FLAG,
     P_DEPEND_OBJECT_TYPE, l_DEPEND_OBJECT_OWNER, P_DEPEND_OBJECT_NAME,
     g_curr_user_id, sysdate, g_curr_user_id,
     g_curr_login_id, sysdate;

   -- create corresponding object property if it doesn't exist in RSG previously
   -- note that x_return_status and x_msg_data are set appropriately in create_property
   create_property(p_object_type, l_object_owner, l_object_name,
		   x_return_status, x_msg_data);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
   END IF;

   --create corresponding depend object property if it doesn't exist in RSG previously
   -- note that x_return_status and x_msg_data are set appropriately in create_property
   create_property(p_depend_object_type, l_depend_object_owner,
		   p_depend_object_name,
		   x_return_status, x_msg_data);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
   END IF;

EXCEPTION
   WHEN dup_val_on_index THEN -- unique constraint violation
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_DUP_DEP_REC';
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END create_dependency;


PROCEDURE Update_Dependency (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Update_Dependency';
   l_object_name bis_obj_dependency.object_name%type; --Enhancement 4106617
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   IF (p_object_type = 'PAGE') THEN
     l_object_name := get_page_name_by_func(p_object_name);
    ELSE
      l_object_name := p_object_name;
   END IF;

   -- validate enabled_flag
   IF (p_enabled_flag IS NOT NULL AND p_enabled_flag <> 'Y'
       AND p_enabled_flag <> 'N') THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := 'BIS_BIA_RSG_INV_ENABLED_FLAG';
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_ENABLED_FLAG');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('enabled flag validated');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'update bis_obj_dependency
     set enabled_flag = :1,
         last_updated_by = :2,
 	 last_update_login = :3,
	 last_update_date = :4
     WHERE object_name = :5 AND object_type = :6
     AND depend_object_name = :7 AND depend_object_type = :8'
     using p_enabled_flag, g_curr_user_id, g_curr_login_id, Sysdate,
     l_object_name, p_object_type, p_depend_object_name, p_depend_object_type;

   --IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --  END IF;
   --  x_msg_data := 'BIS_BIA_RSG_DEP_NOT_EXISTS';
   --END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END Update_Dependency;

-- this procedure will only be called from delete_dependencies procedure
-- no need to call get_page_object_name_by_func
PROCEDURE delete_property (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2
) IS
   CURSOR c_dependencies (p_obj_name VARCHAR2, p_obj_type VARCHAR2) IS
      SELECT depend_object_name
	FROM bis_obj_dependency
	WHERE (object_name = p_obj_name AND object_type = p_obj_type)
	OR (depend_object_name = p_obj_name AND depend_object_type = p_obj_type);

   v_dep_obj_name bis_obj_dependency.depend_object_name%TYPE;  --Enhancement 4106617
BEGIN
   OPEN c_dependencies(p_object_name, p_object_type);
   FETCH c_dependencies INTO v_dep_obj_name;
   IF (c_dependencies%notfound) THEN
      execute immediate 'delete from bis_obj_properties
	where object_type = :1 and object_name = :2'
	using p_object_type, p_object_name;
   END IF;
   CLOSE c_dependencies;
EXCEPTION
   WHEN OTHERS THEN
      RETURN;
END delete_property;

PROCEDURE Delete_Dependency (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Delete_Dependency';
   l_object_name VARCHAR2(480); --Enhancement 4106617
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   IF (p_object_type = 'PAGE') THEN
     l_object_name := get_page_name_by_func(p_object_name);
    ELSE
      l_object_name := p_object_name;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'delete from bis_obj_dependency
     WHERE object_name = :1 AND object_type = :2
     AND depend_object_name = :3 AND depend_object_type = :4'
     using l_object_name, p_object_type, p_depend_object_name, p_depend_object_type;

   -- as per discussion with Tianyi, comment out the following code
   -- IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --   END IF;
   --   x_msg_data := 'BIS_BIA_RSG_DEP_NOT_EXISTS';
   -- END IF;

   -- delete the corresponding properties if neccessary
   delete_property(p_object_type, l_object_name);
   delete_property(p_depend_object_type, p_depend_object_name);

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END Delete_Dependency;

--Added for bug 4606455
-- is to delete depdendency based on rowid instead of object name
-- this will in turn call the above function
PROCEDURE Delete_Dependency (
 P_ROWID		in ROWID,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   l_object_type             VARCHAR2(30);
   l_object_name             VARCHAR2(480);
   l_depend_object_type      VARCHAR2(30);
   l_depend_object_name	     VARCHAR2(480);
   cursor get_names(rid varchar2) is
   select object_name,object_type,depend_object_name,depend_object_type
   from bis_obj_dependency where rowid = rid;
BEGIN
   open get_names(P_ROWID);
   fetch get_names into l_object_name,l_object_type,l_depend_object_name,l_depend_object_type;
   if get_names%NOTFOUND then
    close get_names;
    return;
   end if;
   close get_names;

   delete_dependency(l_object_type,l_object_name,l_depend_object_type,l_depend_object_name,
                     x_return_status,x_msg_data);
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END Delete_Dependency;

PROCEDURE Delete_Page_Dependencies (
 P_OBJECT_NAME		in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Delete_Page_Dependencies';
   l_object_name bis_obj_dependency.object_name%type;  --Enhancement 4106617
   CURSOR c_deps (p_page_name VARCHAR2) IS
      SELECT object_name, object_type, depend_object_name, depend_object_type
	FROM bis_obj_dependency
	WHERE object_type = 'PAGE' AND object_name = p_page_name;
   v_dep c_deps%ROWTYPE;
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   l_object_name := get_page_name_by_func(p_object_name);

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- execute immediate 'delete from bis_obj_dependency
   --   WHERE object_name = :1 AND object_type = :2'
   --   using l_object_name, 'PAGE';

   -- IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --   END IF;
   --   x_msg_data := 'BIS_BIA_RSG_PAGE_NOT_EXISTS';
   -- END IF;

   -- execute immediate 'delete from bis_obj_properties
   --   WHERE object_name = :1 AND object_type = :2'
   --   using l_object_name, 'PAGE';

   OPEN c_deps(l_object_name);
   LOOP
      FETCH c_deps INTO v_dep;
      EXIT WHEN c_deps%notfound;
      Delete_Dependency (v_dep.object_type,
			 v_dep.OBJECT_NAME,
			 v_dep.depend_object_type,
			 v_dep.depend_object_name,
			 x_return_status,
			 x_msg_data);
      EXIT WHEN (x_return_status <> FND_API.g_ret_sts_success);
   END LOOP;
   CLOSE c_deps;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END Delete_Page_Dependencies;

PROCEDURE Update_Property(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Update_Property';
   l_object_name VARCHAR2(480); --Enhancement 4106617
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   IF (p_object_type = 'PAGE') THEN
     l_object_name := get_page_name_by_func(p_object_name);
    ELSE
      l_object_name := p_object_name;
   END IF;

   -- validate dimension_flag
   IF (p_dimension_flag IS NOT NULL AND p_dimension_flag <> 'Y'
       AND p_dimension_flag <> 'N') THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := 'BIS_BIA_RSG_INVALID_DIM_FLAG';
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INVALID_DIM_FLAG');
      END IF;
      RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'update bis_obj_properties
     set dimension_flag = :1,
         custom_api = :2,
         last_updated_by = :3,
 	 last_update_login = :4,
	 last_update_date = :5
     WHERE object_name = :6 AND object_type = :7'
     using p_dimension_flag, p_custom_api, g_curr_user_id, g_curr_login_id, Sysdate,
     l_object_name, p_object_type;

   --IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   -- FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --   END IF;
   --  x_msg_data := 'BIS_BIA_RSG_PROP_NOT_EXISTS';
   --END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END update_property;


PROCEDURE Update_Property_Dim_Flag(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Update_Property_Dim_Flag';
   l_object_name VARCHAR2(480); --Enhancement 4106617
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   IF (p_object_type = 'PAGE') THEN
     l_object_name := get_page_name_by_func(p_object_name);
    ELSE
      l_object_name := p_object_name;
   END IF;

   -- validate dimension_flag
   IF (p_dimension_flag IS NOT NULL AND p_dimension_flag <> 'Y'
       AND p_dimension_flag <> 'N') THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := 'BIS_BIA_RSG_INVALID_DIM_FLAG';
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INVALID_DIM_FLAG');
      END IF;
      RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'update bis_obj_properties
     set dimension_flag = :1,
         last_updated_by = :2,
 	 last_update_login = :3,
	 last_update_date = :4
     WHERE object_name = :5 AND object_type = :6'
     using p_dimension_flag, g_curr_user_id, g_curr_login_id, Sysdate,
     l_object_name, p_object_type;

   --IF (SQL%notfound) THEN
   --  x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --   END IF;
   --   x_msg_data := 'BIS_BIA_RSG_PROP_NOT_EXISTS';
   --  END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END update_property_dim_flag;

PROCEDURE Update_Property_Custom_API(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Update_Property_Custom_API';
   l_object_name VARCHAR2(480); --Enhancement 4106617
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   IF (p_object_type = 'PAGE') THEN
     l_object_name := get_page_name_by_func(p_object_name);
    ELSE
      l_object_name := p_object_name;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'update bis_obj_properties
     set custom_api = :1,
         last_updated_by = :2,
 	 last_update_login = :3,
	 last_update_date = :4
     WHERE object_name = :5 AND object_type = :6'
     using p_custom_api, g_curr_user_id, g_curr_login_id, Sysdate,
     l_object_name, p_object_type;

   --IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --  IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --  END IF;
   --  x_msg_data := 'BIS_BIA_RSG_PROP_NOT_EXISTS';
   --END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END update_property_custom_api;
/**
 * remove for bug#3748713
 * the snapshot_log_sql should not be updated through any API other
 * than BIS_BIA_RSG_CUSTOM_API_MGMNT package.
PROCEDURE Update_Property_Snapshotlog(
 P_OBJECT_TYPE         in VARCHAR2,
 P_OBJECT_NAME         in VARCHAR2,
 P_SNAPSHOT_LOG        in VARCHAR2,
 x_return_status       OUT NOCOPY  VARCHAR2,
 x_msg_data            OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Update_Property_Snapshotlog';
   l_object_name VARCHAR2(80);
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   IF (p_object_type = 'PAGE') THEN
     l_object_name := get_page_name_by_func(p_object_name);
    ELSE
      l_object_name := p_object_name;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'update bis_obj_properties
     set SNAPSHOT_LOG_SQL = :1,
         last_updated_by = :2,
 	 last_update_login = :3,
	 last_update_date = :4
     WHERE object_name = :5 AND object_type = :6'
     using p_snapshot_log, g_curr_user_id, g_curr_login_id, Sysdate,
     l_object_name, p_object_type;

   --IF (SQL%notfound) THEN
   --    x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --  END IF;
   --   x_msg_data := 'BIS_BIA_RSG_PROP_NOT_EXISTS';
   --END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END update_property_snapshotlog;
*/

/**
 * remove for bug#3748713
 * the snapshot_log_sql should not be exposed through any API,
 * as it is currently centrally managed by
 * BIS_BIA_RSG_CUSTOM_API_MGMNT package.
FUNCTION Get_Property_Snapshotlog(
 P_OBJECT_TYPE         in VARCHAR2,
 P_OBJECT_NAME         in VARCHAR2,
 x_return_status       OUT NOCOPY  VARCHAR2,
 x_msg_data            OUT NOCOPY  VARCHAR2
) RETURN VARCHAR2 IS
   v_procedure_name VARCHAR2(50) := 'Get_Property_Snapshotlog';
   v_snapshot_log VARCHAR2(4000);
   l_object_name VARCHAR2(80);
BEGIN
   FND_MSG_PUB.initialize;

   -- since page designer passes in fnd_form_function name instead of object name
   -- we need take care of _OA problem by calling get_page_name_by_func, if object type is PAGE
   IF (p_object_type = 'PAGE') THEN
     l_object_name := get_page_name_by_func(p_object_name);
    ELSE
      l_object_name := p_object_name;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'select snapshot_log_sql
     from bis_obj_properties
     WHERE object_name = :1 AND object_type = :2'
     INTO v_snapshot_log
     using l_object_name, p_object_type;

   RETURN v_snapshot_log;

EXCEPTION
   WHEN no_data_found THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_PROP_NOT_EXISTS';
      RETURN NULL;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
      RETURN NULL;
END get_property_snapshotlog;
*/

PROCEDURE prog_validation(
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2
) IS
   v_dummy VARCHAR2(5);
BEGIN
   x_return_status := 'Y';

   IF (P_CONC_PROG_NAME IS NULL OR p_appl_short_name IS NULL) THEN
     X_RETURN_STATUS := 'N';
     RETURN;
   END IF;

   execute immediate ' SELECT 1
     FROM fnd_concurrent_programs prog, fnd_application appl
     WHERE prog.CONCURRENT_PROGRAM_NAME = :1
     AND prog.application_id = appl.application_id
     AND appl.application_short_name = :2'
     INTO v_dummy
     using p_conc_prog_name, p_appl_short_name;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'N';
END prog_validation;

PROCEDURE loading_mode_validation(
 p_loading_mode  VARCHAR2,
 x_return_status OUT nocopy VARCHAR2
) IS
   v_dummy VARCHAR2(5);
BEGIN
   x_return_status := 'Y';

   IF (P_LOADING_MODE IS NULL) THEN
     X_RETURN_STATUS := 'N';
     RETURN;
   END IF;

   execute immediate 'select 1
     from fnd_common_lookups
     where lookup_type = :1 AND lookup_code = :2'
     INTO v_dummy
     using 'BIS_REFRESH_MODE', p_loading_mode;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'N';
END loading_mode_validation;

PROCEDURE Create_Linkage (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 P_REFRESH_MODE	        in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Create_Linkage';
   v_appl_id   NUMBER;
BEGIN
   FND_MSG_PUB.initialize;

   -- page is not allowed to have refresh program associated
   IF (p_object_type = 'PAGE') THEN
      x_msg_data := 'BIS_BIA_RSG_NO_PAGE_LINKAGE';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_NO_PAGE_LINKAGE');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('1');

   -- validate (object_type, object_name)
   object_name_validation(p_object_type, p_object_name, x_return_status);
   IF (x_return_status = 'N') THEN
      x_msg_data := 'BIS_BIA_RSG_INVALID_OBJ';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INVALID_OBJ');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('2');

   -- validate object_owner
   object_owner_validation(p_object_owner, x_return_status);
   IF (x_return_status = 'N') THEN
      x_msg_data := 'BIS_BIA_RSG_INVALID_OBJ_OWNER';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INVALID_OBJ_OWNER');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('3');

   -- validate concurrent program
   prog_validation(P_CONC_PROG_NAME, P_APPL_SHORT_NAME, x_return_status);
   IF (x_return_status = 'N') THEN
      x_msg_data := 'BIS_BIA_RSG_INVALID_CONC_PROG';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INVALID_CONC_PROG');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('4');

   -- validate enabled flag
   IF (p_enabled_flag IS NOT NULL AND p_enabled_flag <> 'Y' AND p_enabled_flag <> 'N') THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := 'BIS_BIA_RSG_INV_ENABLED_FLAG';
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_ENABLED_FLAG');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('5');

   -- validate loading mode
   loading_mode_validation(p_refresh_mode, x_return_status);
   IF (x_return_status = 'N') THEN
      x_msg_data := 'BIS_BIA_RSG_INV_LOADING_MODE';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_LOADING_MODE');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('6');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'select application_id from fnd_application
     WHERE application_short_name = :1'
     INTO v_appl_id
     using p_appl_short_name;

   --dbms_output.put_line('7');

   execute immediate 'insert into bis_obj_prog_linkages (
     OBJECT_TYPE, OBJECT_OWNER, OBJECT_NAME,
     CONC_PROGRAM_NAME, CONC_APP_ID, CONC_APP_SHORT_NAME,
     ENABLED_FLAG, REFRESH_MODE,
     CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN, LAST_UPDATE_DATE)
     values(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13)'
     using P_OBJECT_TYPE, P_OBJECT_OWNER, P_OBJECT_NAME,
     P_CONC_PROG_NAME, V_APPL_ID, P_APPL_SHORT_NAME,
     P_ENABLED_FLAG, P_REFRESH_MODE,
     g_curr_user_id, sysdate, g_curr_user_id,
     g_curr_login_id, sysdate;

   --dbms_output.put_line('8');

   --create corresponding depend object property if it doesn't exist in RSG previously
   -- note that x_return_status and x_msg_data are set appropriately in create_property
   create_property(p_object_type, p_object_owner,
		   p_object_name, x_return_status, x_msg_data);
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RETURN;
   END IF;

EXCEPTION
   WHEN dup_val_on_index THEN -- unique constraint violation
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_DUP_LINKAGE_REC';
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END create_linkage;

PROCEDURE Update_Linkage (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 p_refresh_mode         IN VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Update_Linkage';
BEGIN
   FND_MSG_PUB.initialize;

   -- validate enabled_flag
   IF (p_enabled_flag IS NOT NULL AND p_enabled_flag <> 'Y'
       AND p_enabled_flag <> 'N') THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := 'BIS_BIA_RSG_INV_ENABLED_FLAG';
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_ENABLED_FLAG');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('1');

   --validate refresh mode
   loading_mode_validation(p_refresh_mode, x_return_status);
   IF (x_return_status = 'N') THEN
      x_msg_data := 'BIS_BIA_RSG_INV_LOADING_MODE';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_LOADING_MODE');
      END IF;
      RETURN;
   END IF;

   --dbms_output.put_line('2');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'update bis_obj_prog_linkages
     set enabled_flag = :1,
         refresh_mode = :2,
         last_updated_by = :3,
 	 last_update_login = :4,
	 last_update_date = :5
     WHERE object_name = :6 AND object_type = :7
     AND CONC_PROGRAM_NAME = :8 AND CONC_APP_SHORT_NAME = :9'
     using p_enabled_flag, p_refresh_mode, g_curr_user_id, g_curr_login_id, Sysdate,
     p_object_name, p_object_type, p_conc_prog_name, p_appl_short_name;

   --dbms_output.put_line('3');

   -- IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --  END IF;
   --   x_msg_data := 'BIS_BIA_RSG_LINKAGE_NOT_EXISTS';
   --END IF;

   --dbms_output.put_line('4');

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END update_linkage;


PROCEDURE Update_Linkage_Enabled_Flag (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Update_Linkage_Enabled_Flag';
BEGIN
   FND_MSG_PUB.initialize;

   -- validate enabled_flag
   IF (p_enabled_flag IS NOT NULL AND p_enabled_flag <> 'Y'
       AND p_enabled_flag <> 'N') THEN
      x_return_status := fnd_api.g_ret_sts_error;
      x_msg_data := 'BIS_BIA_RSG_INV_ENABLED_FLAG';
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_ENABLED_FLAG');
      END IF;
      RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'update bis_obj_prog_linkages
     set enabled_flag = :1,
         last_updated_by = :2,
 	 last_update_login = :3,
	 last_update_date = :4
     WHERE object_name = :5 AND object_type = :6
     AND CONC_PROGRAM_NAME = :7 AND CONC_APP_SHORT_NAME = :8'
     using p_enabled_flag, g_curr_user_id, g_curr_login_id, Sysdate,
     p_object_name, p_object_type, p_conc_prog_name, p_appl_short_name;

   --IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --   END IF;
   --   x_msg_data := 'BIS_BIA_RSG_LINKAGE_NOT_EXISTS';
   --END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END Update_Linkage_Enabled_Flag;


PROCEDURE Update_Linkage_Refresh_Mode (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 p_refresh_mode         IN VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Update_Linkage_Refresh_Mode';
BEGIN
   FND_MSG_PUB.initialize;

   --validate refresh mode
   loading_mode_validation(p_refresh_mode, x_return_status);
   IF (x_return_status = 'N') THEN
      x_msg_data := 'BIS_BIA_RSG_INV_LOADING_MODE';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_LOADING_MODE');
      END IF;
      RETURN;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'update bis_obj_prog_linkages
     set refresh_mode = :1,
         last_updated_by = :2,
 	 last_update_login = :3,
	 last_update_date = :4
     WHERE object_name = :5 AND object_type = :6
     AND CONC_PROGRAM_NAME = :7 AND CONC_APP_SHORT_NAME = :8'
     using p_refresh_mode, g_curr_user_id, g_curr_login_id, Sysdate,
     p_object_name, p_object_type, p_conc_prog_name, p_appl_short_name;

   --IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --   END IF;
   --   x_msg_data := 'BIS_BIA_RSG_LINKAGE_NOT_EXISTS';
   --END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END update_linkage_refresh_mode;

PROCEDURE Delete_Linkage (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name  VARCHAR2(50) := 'Delete_Linkage';
BEGIN
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'delete from bis_obj_prog_linkages
     WHERE object_name = :1 AND object_type = :2
     AND conc_program_name = :3 AND conc_app_short_name = :4'
     using p_object_name,  p_object_type,
     p_conc_prog_name, p_appl_short_name;

   --IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --  END IF;
   --   x_msg_data := 'BIS_BIA_RSG_LINKAGE_NOT_EXISTS';
   --END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END Delete_Linkage;

--Added for bug 4606455
-- is to delete linkage based on rowid instead of object name
-- this will in turn call the above function
PROCEDURE Delete_Linkage (
 P_ROWID		in ROWID,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   l_object_type             VARCHAR2(30);
   l_object_name             VARCHAR2(480);
   l_conc_prog_name          VARCHAR2(30);
   l_appl_short_name	     VARCHAR2(50);
   cursor get_names(rid varchar2) is
   select object_name,object_type,conc_program_name,conc_app_short_name
   from bis_obj_prog_linkages where rowid = rid;
BEGIN
   open get_names(P_ROWID);
   fetch get_names into l_object_name,l_object_type,l_conc_prog_name,l_appl_short_name;
   if get_names%NOTFOUND then
    close get_names;
    return;
   end if;
   close get_names;

   delete_linkage(l_object_type,l_object_name,l_conc_prog_name,l_appl_short_name,
                     x_return_status,x_msg_data);
EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END Delete_Linkage;

PROCEDURE Delete_Obj_Linkages (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) IS
   v_procedure_name VARCHAR2(50) := 'Delete_Obj_Linkages';
BEGIN
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   execute immediate 'delete from bis_obj_prog_linkages
     WHERE object_name = :1 AND object_type = :2'
     using p_object_name,  p_object_type;

   --IF (SQL%notfound) THEN
   --   x_return_status := FND_API.G_RET_STS_ERROR;
   --   IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
   --	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
   --   END IF;
   --   x_msg_data := 'BIS_BIA_RSG_NO_OBJ_LINKAGES';
   --END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
END Delete_Obj_Linkages;


--begin: added for enhancement bug 3686273
-- In order to fix bug 3867557, this function will get all the ancestor objects for the given
-- dependent object, considering both enabled and disabled dependencies
FUNCTION GetParentObjects(P_DEP_OBJ_NAME 		IN	VARCHAR2,
			  P_DEP_OBJ_TYPE		IN	VARCHAR2,
			  P_OBJ_TYPE			IN	VARCHAR2,
			  X_RETURN_STATUS		OUT	NOCOPY	VARCHAR2,
			  X_MSG_DATA			OUT	NOCOPY	VARCHAR2
			  ) RETURN t_bia_rsg_obj_table IS
   v_procedure_name VARCHAR2(50) := 'GetParentObjects';

   l_obj_rec  t_bia_rsg_obj_rec;
   x_parent_obj_table t_bia_rsg_obj_table;
   l_count INTEGER;
   l_index INTEGER;

   CURSOR c_parent_objs (p_dep_obj_name VARCHAR2, p_dep_obj_type VARCHAR2, p_obj_type VARCHAR2) IS
      SELECT object_name, user_object_name, object_owner
	FROM  (SELECT object_name, user_object_name, object_type, object_owner, depend_object_name, depend_object_type
	       FROM bis_obj_dependency_v
	       -- get rid of the filter for bug 3867557, i.e., conside both enabled and disabled dependencies
	       --WHERE enabled_flag = 'Y'
	       )
	WHERE object_type = p_obj_type
	START WITH depend_object_name = p_dep_obj_name AND depend_object_type = p_dep_obj_type
	CONNECT BY PRIOR object_name = depend_object_name AND PRIOR object_type = depend_object_type;
BEGIN
   FND_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_dep_obj_name IS NULL OR p_dep_obj_name = '') THEN
      x_msg_data := 'BIS_BIA_RSG_INV_DEP_OBJ_NAME';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_DEP_OBJ_NAME');
      END IF;
      RETURN x_parent_obj_table;
   END IF;

   IF (p_dep_obj_type IS NULL OR
       p_dep_obj_type NOT IN ('TABLE','VIEW', 'MV', 'PORTLET', 'PAGE', 'REPORT')) THEN
      x_msg_data := 'BIS_BIA_RSG_INV_DEP_OBJ_TYPE';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_DEP_OBJ_TYPE');
      END IF;
      RETURN x_parent_obj_table;
   END IF;

   IF (p_obj_type IS NULL OR
       p_obj_type NOT IN ('TABLE','VIEW', 'MV', 'PORTLET', 'PAGE', 'REPORT')) THEN
      x_msg_data := 'BIS_BIA_RSG_INV_OBJ_TYPE';
      x_return_status := fnd_api.g_ret_sts_error;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_ERROR)) THEN
	 fnd_msg_pub.add_exc_msg(g_pkg_name, v_procedure_name, 'BIS_BIA_RSG_INV_OBJ_TYPE');
      END IF;
      RETURN x_parent_obj_table;
   END IF;

   l_count := 0;

   OPEN c_parent_objs (p_dep_obj_name, p_dep_obj_type, p_obj_type);
   LOOP
      FETCH c_parent_objs INTO l_obj_rec;
      EXIT WHEN c_parent_objs%notfound;
      x_parent_obj_table(l_count) := l_obj_rec;
      l_count := l_count + 1;
   END LOOP;

   RETURN x_parent_obj_table;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,v_procedure_name, NULL);
      END IF;
      x_msg_data := 'BIS_BIA_RSG_UNEXP_ERROR';
      RETURN x_parent_obj_table;
END;


-- end: enhancement bug 3686273

-- begin: enhancement bug 3999642

procedure enable_index_mgmt(p_mv_name in varchar2, p_mv_schema in varchar2)
is
  begin
  BIS_BIA_RSG_INDEX_MGMT.enable_index_mgmt(p_mv_name, p_mv_schema);
  end;


procedure disable_index_mgmt(p_mv_name in varchar2, p_mv_schema in varchar2)
is
  begin
  BIS_BIA_RSG_INDEX_MGMT.disable_index_mgmt(p_mv_name, p_mv_schema);
  end;

-- end: enhancement bug 3999642

END bis_rsg_pub_api_pkg;

/
